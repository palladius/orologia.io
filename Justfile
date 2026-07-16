FLUTTER_DIR := "solutions/antigravity2.0-multi-agent-flutter"

# List all available commands
default:
    @just --list

# Run the Flutter dev server with hot reload (port 8080)
run port="8080":
    cd {{FLUTTER_DIR}} && flutter run -d web-server --web-port={{port}} --web-hostname=0.0.0.0

# Serve the pre-built web app — fast, no debug overhead (port 8080)
run-linux-fast port="8080":
    @echo "Serving on http://localhost:{{port}} ..."
    cd {{FLUTTER_DIR}} && python3 -m http.server {{port}} --directory build/web --bind 0.0.0.0

# Run unit and widget tests
test:
    cd {{FLUTTER_DIR}} && flutter test

# Build the web application
build-web:
    cd {{FLUTTER_DIR}} && flutter build web

# Build the production Android App Bundle (.aab)
build-android-aab:
    cd {{FLUTTER_DIR}} && flutter build appbundle --release

# Upload the built release AAB to Google Play Store
upload-to-google-play *ARGS:
    just {{FLUTTER_DIR}}/upload-to-google-play {{ARGS}}

# Run the app natively as a macOS desktop application
run-mac:
    just {{FLUTTER_DIR}}/run-mac

# Run the app in Google Chrome
run-chrome:
    just {{FLUTTER_DIR}}/run-chrome

# Clean up build artifacts, node_modules, and .dart_tool to save space
clean:
    cd {{FLUTTER_DIR}} && flutter clean || true
    rm -rf build .dart_tool node_modules
    rm -rf {{FLUTTER_DIR}}/node_modules
    @echo "✅ Cleaned up bloat and regeneratable files!"
