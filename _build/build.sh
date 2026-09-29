#!/bin/sh

# Move file for use with mf, read more at https://github.com/greeenlaser/personal-stash/tree/main/mf

set -e

#
# References
#

KMAKE_ORIGIN=project.kmake

SRC_ORIGIN=..
SRC_TARGET=src
INCLUDE_ORIGIN=..
INCLUDE_TARGET=include

case "$1" in
    --linux)
        BUILD_RELEASE="--compile ${KMAKE_ORIGIN} release-linux"
        BUILD_DEBUG="--compile ${KMAKE_ORIGIN} debug-linux"
        ;;
    --windows-gnu)
        BUILD_RELEASE="--compile ${KMAKE_ORIGIN} release-windows-gnu"
        BUILD_DEBUG="--compile ${KMAKE_ORIGIN} debug-windows-gnu"
        ;;
    --windows)
        BUILD_RELEASE="--compile ${KMAKE_ORIGIN} release-windows"
        BUILD_DEBUG="--compile ${KMAKE_ORIGIN} debug-windows"
        ;;
    *)
        echo "Error: Argument must be --linux, --windows-gnu or --windows" >&2
        exit 1
        ;;
esac

#
# Copy sources, headers and license
#

if [ -d "${SRC_TARGET}" ]; then
    rm -rf "${SRC_TARGET}"
fi
mkdir "${SRC_TARGET}"

if [ -d "${INCLUDE_TARGET}" ]; then
    rm -rf "${INCLUDE_TARGET}"
fi
mkdir "${INCLUDE_TARGET}"

# Lua license

if [ ! -f "LICENSE" ]; then
cat > LICENSE <<'EOF'
Copyright © 1994–2026 Lua.org, PUC-Rio.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EOF
fi

# Source files

for file in "${SRC_ORIGIN}"/*.c
do
    [ -f "$file" ] || continue
    cp "$file" "${SRC_TARGET}/"
done

# Headers

for file in "${INCLUDE_ORIGIN}"/*.h
do
    [ -f "$file" ] || continue
    cp "$file" "${INCLUDE_TARGET}/"
done

#
# Compile
#

kalamake ${BUILD_RELEASE} && kalamake ${BUILD_DEBUG}

#
# Cleanup
#

# Only delete src but keep include because its needed by the libraries
rm -rf "${SRC_TARGET}"

rm -rf "release/obj"
rm -rf "debug/obj"
