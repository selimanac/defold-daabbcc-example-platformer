#!/bin/zsh

# Define output directory and settings
OUTPUT_DIR="./bundle"
BUILD_SERVER="https://build-stage.defold.com"
SETTINGS_FILE="./release.project"
PROJECT_ROOT="../"

echo "🚀 Starting Defold build process..."

# Function to build for a platform
build_platform() {
    local PLATFORM="$1"
    local ARCH="$2"
    local OUTPUT="$OUTPUT_DIR/$PLATFORM/$ARCH"  # Place each build in its architecture folder

    echo "🔹 Building for $PLATFORM ($ARCH)..."
    if [[ -n "$ARCH" ]]; then
        java -jar bob.jar --archive --platform "$PLATFORM" --architectures "$ARCH" resolve distclean build bundle \
            --bundle-output "$OUTPUT" \
            --build-server "$BUILD_SERVER" \
            --settings "$SETTINGS_FILE" \
            --root "$PROJECT_ROOT" || exit 1
    else
        java -jar bob.jar --archive --platform "$PLATFORM" resolve distclean build bundle \
            --bundle-output "$OUTPUT" \
            --build-server "$BUILD_SERVER" \
            --settings "$SETTINGS_FILE" \
            --root "$PROJECT_ROOT" || exit 1
    fi
}

# Build for macOS ARM64 (Apple Silicon)
#build_platform "arm64-macos" "" "macos-arm64"  # Correct platform: arm64-macos

# Build for WebAssembly (WASM) - No architecture required
build_platform "wasm-web" "wasm-web" "wasm-web"

echo "✅ All builds completed successfully!"