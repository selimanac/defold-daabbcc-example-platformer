#!/bin/zsh

OUTPUT_DIR="./bundle"
BUILD_SERVER="https://build-stage.defold.com"
DESKTOP_SETTINGS_FILE="./desktop_release.project"
MOBILE_SETTINGS_FILE="./mobile_release.project"
PROJECT_ROOT="../"
VARIANT="release"

echo "-> Starting Defold build process..."


build_platform() {
    local PLATFORM="$1"
    local ARCH="$2"
    local SETTINGS="$3"
    local OUTPUT="$OUTPUT_DIR/$PLATFORM/$ARCH"  

    echo "-> Building for $PLATFORM ($ARCH)..."
    if [[ -n "$ARCH" ]]; then
        java -jar bob.jar --archive --platform "$PLATFORM" --architectures "$ARCH" resolve distclean build bundle \
            --bundle-output "$OUTPUT" \
            --build-server "$BUILD_SERVER" \
            --settings "$SETTINGS" \
            --variant  "$VARIANT" \
            --root "$PROJECT_ROOT" || exit 1
    else
        java -jar bob.jar --archive --platform "$PLATFORM" resolve distclean build bundle \
            --bundle-output "$OUTPUT" \
            --build-server "$BUILD_SERVER" \
            --settings "$SETTINGS" \
            --variant  "$VARIANT" \
            --root "$PROJECT_ROOT" || exit 1
    fi
}


# build_platform "arm64-macos" "arm64-macos" "arm64-macos"

# build_platform "x86_64-macos" "x86_64-macos" "x86_64-macos"

# build_platform "x86_64-win32" "x86_64-win32" "x86_64-win32"

# build_platform "x86_64-linux" "x86_64-linux" "x86_64-linux"#Fails for Vulkan

build_platform "wasm-web" "wasm-web" "$MOBILE_SETTINGS_FILE"

echo "-> All builds completed successfully!"