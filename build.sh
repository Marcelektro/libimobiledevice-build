#!/bin/bash

######################################
## Build script for libimobiledevice #
##          by Marcelektro           #
######################################


# exit on error
set -e


# project root absolute path
SCRIPT_ABSOLUTE_PATH=$(readlink -f "$0")
PROJECT_ROOT=$(dirname "$SCRIPT_ABSOLUTE_PATH")
echo "[i] Project root is at '$PROJECT_ROOT'"


# build directory path
BUILD_DIR="$PROJECT_ROOT/build"
echo "[i] Build working directory at '$BUILD_DIR'"

# dist directory path
DIST_DIR="$PROJECT_ROOT/dist"
echo "[i] Dist directory at '$DIST_DIR'"


# if arg 0 is clean, clean the build directory
if [ "$1" == "clean" ]; then

    if [ -d "$BUILD_DIR" ]; then
        echo "[i] Cleaning build directory"
        rm -rf "$BUILD_DIR"
    else
        echo "[i] Build directory does not exist"
    fi

    if [ -d "$DIST_DIR" ]; then
        echo "[i] Cleaning dist directory"
        rm -rf "$DIST_DIR"
    else
        echo "[i] Dist directory does not exist"
    fi

    echo "[i] Exiting..."
    exit 0
fi


# create directories
echo "[i] Creating build and dist directories"
mkdir -p "$BUILD_DIR"
mkdir -p "$DIST_DIR"


# build and install to dist directory
export PKG_CONFIG_PATH="$DIST_DIR/lib/pkgconfig"
export CFLGAS="-I$DIST_DIR/include"
export LDFLAGS="-L$DIST_DIR/lib"


######

build_and_install() {
    # function parameters
    local name="$1"
    local repo_url="$2"

    echo "[i] Setting up $name"

    local dir="$BUILD_DIR/$name"
    mkdir -p "$dir"
    cd "$dir"

    echo "[i] Cloning $name from $repo_url to $dir"
    git clone --depth 1 "$repo_url" .

    echo "[i] Configuring $name"

    ./autogen.sh --prefix="$DIST_DIR"

    echo "[i] Building $name"

    make -j"$(nproc)"
    make install

    echo "[i] $name build and install complete"
}


# build libraries
build_and_install "libplist" "https://github.com/libimobiledevice/libplist"
build_and_install "libimobiledevice-glue" "https://github.com/libimobiledevice/libimobiledevice-glue"
build_and_install "libusbmuxd" "https://github.com/libimobiledevice/libusbmuxd"
build_and_install "libtatsu" "https://github.com/libimobiledevice/libtatsu"
build_and_install "libimobiledevice" "https://github.com/libimobiledevice/libimobiledevice"


echo "[i] Build complete"