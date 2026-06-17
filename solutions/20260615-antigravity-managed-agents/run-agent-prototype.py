#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "google-genai",
#     "requests",
# ]
# ///
"""
Orologia.io Git Clone and Managed Agent Test
This script mounts the https://github.com/palladius/orologia.io repo into the remote sandbox workspace,
injects the GITHUB_TOKEN if available, and commands the agent to:
1. Inspect the mounted repo (/workspace) and read docs/PRD.md.
2. Implement a beautiful, fully functional clock-learning game (e.g. single-page HTML5/CSS/JS).
3. Start a local server, take a screenshot of the app, save it, commit/push the branch, and file a PR to the GitHub repo.
4. Download the environment snapshot locally and extract it.
"""

import os
import sys
import tarfile
import requests
from google import genai

def main():
    print("==================================================")
    print("🚀 Starting Git Clone & Managed Agent Test (08)")
    print("==================================================")

    # Verify API key
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("❌ Error: GEMINI_API_KEY environment variable is not set.")
        sys.exit(1)

    github_token = os.environ.get("GITHUB_TOKEN")
    if not github_token:
        print("⚠️ Warning: GITHUB_TOKEN is not set. The agent will not be able to push to GitHub or file a PR.")
    else:
        print("🔑 GITHUB_TOKEN found. Will inject it into the remote sandbox.")

    client = genai.Client()

    # Configure sources to mount the repository and inject GITHUB_TOKEN
    sources = [
        {
            "type": "repository",
            "source": "https://github.com/palladius/orologia.io",
            "target": "/workspace"
        }
    ]

    if github_token:
        sources.append({
            "type": "inline",
            "target": "/workspace/.github_token",
            "content": github_token
        })

    prompt = """
You are an expert full-stack developer agent.
We have mounted the repository `https://github.com/palladius/orologia.io` into `/workspace`.
Inside, you will find `README.md` and `docs/PRD.md`.

Your tasks:
1. Inspect the repository at `/workspace` and read the requirements in `docs/PRD.md`.
2. Implement a beautiful, fully functional, and highly interactive clock-learning game as described in `docs/PRD.md`.
   You should build this as a modern single-page web application (index.html, style.css, script.js) directly inside the repository.
   Make it visually stunning, responsive, with an interactive analog clock (can rotate hands), digital display, scoring system, and BCD (Binary Coded Decimal) visualization.
3. (Optional) If browser screenshot automation is quick and straightforward, you can take a screenshot of the running game and save it as `screenshot.png` in `/workspace`. If it is slow, hangs, or fails, skip the screenshot to avoid blocking, and proceed.
4. Commit your files (code and optional screenshot) and open a Pull Request (PR) on GitHub:
   - Read the GitHub token from `/workspace/.github_token` (if it exists).
   - Configure git user name and email (e.g., "Antigravity Agent" / "antigravity-agent@google.com").
   - Create a branch named `feature/clock-implementation`.
   - If the token exists, set git remote url to use the token for authentication: `git remote set-url origin https://<token>@github.com/palladius/orologia.io.git` and push the branch, then create a PR back to the main branch of `palladius/orologia.io`.
   - If the token is missing, just commit your files locally and print a clear notice that you are skipping the push/PR step. We will retrieve the committed files from the snapshot.

Please display the detailed steps of your execution and the PR link (if created).
If the PR doesn't work (eg due to missing token), ensure that the code is still committed in the sandbox,
and we will retrieve it from the snapshot. Add a FINAL_MESSAGE.md in the root of the repo summarizing your work, including the PR text you would have used, and any instructions for running the game locally.
"""

    print("🤖 Launching remote managed agent interaction...")
    try:
        interaction = client.interactions.create(
            agent="antigravity-preview-05-2026",
            input=prompt,
            environment={
                "type": "remote",
                "sources": sources
            }
        )

        print("\n🤖 [Agent Output]:")
        print("==================================================")
        print(interaction.output_text)
        print("==================================================")

        env_id = interaction.environment_id
        print(f"\n📂 Downloading sandbox environment snapshot (ID: {env_id})...")

        # Download the snapshot tar
        response = requests.get(
            f"https://generativelanguage.googleapis.com/v1beta/files/environment-{env_id}:download",
            params={"alt": "media"},
            headers={"x-goog-api-key": api_key},
            allow_redirects=True,
        )

        out_dir = os.path.join("out", "08-git-clone-test")
        os.makedirs(out_dir, exist_ok=True)

        tar_path = os.path.join(out_dir, "snapshot_env.tar")
        with open(tar_path, "wb") as f:
            f.write(response.content)

        extracted_dir = os.path.join(out_dir, "extracted_env_snapshot")
        os.makedirs(extracted_dir, exist_ok=True)

        print(f"📦 Extracting snapshot to {extracted_dir}...")
        with tarfile.open(tar_path) as tar:
            tar.extractall(path=extracted_dir)

        print("✅ Extraction complete! Code downloaded successfully.")

    except Exception as e:
        print(f"❌ Error occurred: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
