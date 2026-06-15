# List all available commands
default:
    @just --list

# Run unit and widget tests
test:
    cd solutions/antigravity2.0-multi-agent-flutter && flutter test

# Build the web application
build-web:
    cd solutions/antigravity2.0-multi-agent-flutter && flutter build web

# Build the production Android App Bundle (.aab)
build-android-aab:
    cd solutions/antigravity2.0-multi-agent-flutter && flutter build appbundle --release

# Upload the built release AAB to Google Play Store using Developer API
upload-to-google-play track="internal":
    uv run --with google-api-python-client --with google-auth \
      python3 scripts/upload_to_play_store.py \
      --aab solutions/antigravity2.0-multi-agent-flutter/build/app/outputs/bundle/release/app-release.aab \
      --package-name io.orologia.orologia_io \
      --track "{{track}}" \
      --service-account-json /Users/ricc/git/gic/private/google-play/google-play-service-account.json
