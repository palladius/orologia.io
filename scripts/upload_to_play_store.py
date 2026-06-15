#!/usr/bin/env python3
import argparse
import os
import sys

def main():
    parser = argparse.ArgumentParser(description="Upload Android App Bundle (.aab) to Google Play Console.")
    parser.add_argument("--aab", required=True, help="Path to the app-release.aab file")
    parser.add_argument("--package-name", default="io.orologia.orologia_io", help="Android package name/ID")
    parser.add_argument("--track", default="internal", choices=["internal", "alpha", "beta", "production"], help="Release track")
    parser.add_argument("--service-account-json", default="/Users/ricc/git/gic/private/google-play/google-play-service-account.json", help="Path to Google Play Service Account JSON key")
    
    args = parser.parse_args()
    
    if not os.path.exists(args.aab):
        print(f"❌ Error: AAB file not found at: {args.aab}")
        print("Please build it first using: flutter build appbundle --release")
        sys.exit(1)
        
    if not os.path.exists(args.service-account-json if hasattr(args, "service-account-json") else args.service_account_json):
        sa_path = args.service_account_json
        print(f"❌ Error: Service Account credentials not found at: {sa_path}")
        print("\nTo set up automatic uploads to Google Play:")
        print("1. Go to Google Play Console ➔ Setup ➔ API Access.")
        print("2. Create or link a Google Cloud Project.")
        print("3. Create a Service Account, grant it 'Release Manager' permissions, and generate a JSON key.")
        print(f"4. Save the JSON key file to: {sa_path} (which is safe and private).")
        print("\nNote: For a brand new app, your very first release (.aab) MUST be uploaded manually via the Web Console before you can use API-based uploads.")
        sys.exit(1)

    # Lazily import googleapiclient to avoid dependency check failure before run
    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build
        from googleapiclient.http import MediaFileUpload
    except ImportError:
        print("❌ Error: google-api-python-client and google-auth are required.")
        print("Please run this command with 'uv run --with google-api-python-client --with google-auth ...'")
        sys.exit(1)

    print(f"🚀 Preparing to upload {args.aab} to Google Play Store...")
    print(f"📦 Package: {args.package_name}")
    print(f"📍 Track: {args.track}")

    try:
        credentials = service_account.Credentials.from_service_account_file(
            args.service_account_json,
            scopes=["https://www.googleapis.com/auth/androidpublisher"]
        )
        service = build("androidpublisher", "v3", credentials=credentials)
        
        # 1. Insert a new edit
        print("Creating a new edit session...")
        edit = service.edits().insert(packageName=args.package_name, body={}).execute()
        edit_id = edit["id"]
        
        # 2. Upload the AAB bundle
        print(f"Uploading App Bundle: {args.aab}...")
        media = MediaFileUpload(args.aab, mimetype="application/octet-stream", resumable=True)
        bundle = service.edits().bundles().upload(
            packageName=args.package_name,
            editId=edit_id,
            media_body=media
        ).execute()
        
        version_code = bundle["versionCode"]
        print(f"✅ Successfully uploaded AAB (Version Code: {version_code})")
        
        # 3. Assign bundle to target track
        print(f"Assigning version {version_code} to '{args.track}' track...")
        track_body = {
            "releases": [
                {
                    "versionCodes": [str(version_code)],
                    "status": "completed"
                }
            ]
        }
        service.edits().tracks().update(
            packageName=args.package_name,
            editId=edit_id,
            track=args.track,
            body=track_body
        ).execute()
        
        # 4. Commit the edit
        print("Committing the edit session...")
        service.edits().commit(packageName=args.package_name, editId=edit_id).execute()
        print("🎉 Release successfully pushed and committed to Google Play Console!")
        
    except Exception as e:
        print(f"❌ API Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
