#!/bin/zsh

OUTPUT_DIR="./bundle"
BUILD_SERVER="https://build-stage.defold.com/"
DESKTOP_SETTINGS_FILE="./desktop_release.project"
MOBILE_SETTINGS_FILE="./mobile_release.project"
PROJECT_ROOT="../"
VARIANT="debug"

echo "-> Starting Defold build process..."


build_platform() {
    local PLATFORM="$1"
    local ARCH="$2"
    local SETTINGS="$3"
    local LIVEUPDATE="$4"
    local OUTPUT="$OUTPUT_DIR/$PLATFORM/$ARCH"  

    echo "-> Building for $PLATFORM ($ARCH)..."
    if [[ -n "$ARCH" ]]; then
        java -jar bob.jar --archive --platform "$PLATFORM" --architectures "$ARCH" clean resolve distclean build bundle \
            --bundle-output "$OUTPUT" \
            --build-server "$BUILD_SERVER" \
            --settings "$SETTINGS" \
            --variant  "$VARIANT" \
            --liveupdate "$LIVEUPDATE" \
            --root "$PROJECT_ROOT" || exit 1
    else
        java -jar bob.jar --archive --platform "$PLATFORM" clean resolve distclean build bundle \
            --bundle-output "$OUTPUT" \
            --build-server "$BUILD_SERVER" \
            --settings "$SETTINGS" \
            --variant  "$VARIANT" \
            --liveupdate "$LIVEUPDATE" \
            --root "$PROJECT_ROOT" || exit 1
    fi
}


 # build_platform "arm64-macos" "arm64-macos" "$DESKTOP_SETTINGS_FILE" "no"

# build_platform "x86_64-win32" "x86_64-win32" "$DESKTOP_SETTINGS_FILE" "no"

# build_platform "x86_64-linux" "x86_64-linux" "$DESKTOP_SETTINGS_FILE" "no"

build_platform "wasm-web" "wasm-web" "$MOBILE_SETTINGS_FILE" "yes"

echo "-> All builds completed successfully!"