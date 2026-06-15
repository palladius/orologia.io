# Orologia.io: Secure Release and Play Store Upload Guide

This guide details how to configure release signing locally on your machine and generate the production **Android App Bundle (.aab)** without exposing credentials on the public repository.

> [!WARNING]
> Because this repository is **public**, **NEVER** commit your keystore (`.jks`) or `key.properties` file. They are added to the `.gitignore` so they are not tracked, but double-check your commits!

---

## Step 1: Generate a Release Keystore

To sign your app, you need a Keystore file. If you have Java installed, run this command in your terminal inside `/android/app/` or a secure folder on your machine:

```bash
keytool -genkey -v -keystore android/app/orologia-upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias orologia
```

If you do not have Java in your system PATH, you can run the `keytool` from Android Studio's bundled runtime. On macOS:
```bash
/Applications/Android\ Studio.app/Contents/jbr/Contents/Home/bin/keytool -genkey -v -keystore android/app/orologia-upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias orologia
```

*Follow the prompts and enter a password. Keep this password safe!*

---

## Step 2: Create a Local `key.properties` File

Create a file named `key.properties` under the `android/` directory (inside the Flutter project `/android/key.properties`):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=orologia
storeFile=app/orologia-upload-keystore.jks
```

*Replace `YOUR_KEYSTORE_PASSWORD` and `YOUR_KEY_PASSWORD` with the passwords you entered in Step 1.*

---

## Step 3: Build the Signed Production App Bundle (.aab)

Once the keystore and `key.properties` are in place locally, run the build command in the root of the solutions folder:

```bash
flutter build appbundle --release
```

This will produce the signed production package:
📦 `build/app/outputs/bundle/release/app-release.aab`

---

## Step 4: Upload to Google Play Console

1. Once your proof of address is approved by Google, go to your [Google Play Console](https://play.google.com/console).
2. Go to **Dashboard ➔ Create Release** (e.g. under Internal Testing, Closed Testing, or Production).
3. Drag and drop the `app-release.aab` file.
4. Fill out the target age (kids) policies, app description, and upload screenshots.
5. Click **Save** and **Publish**.
