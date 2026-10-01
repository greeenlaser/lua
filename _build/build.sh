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

        TARGET_REL_DIR=release-linux
        TARGET_DEB_DIR=debug-linux
        ;;
    --windows-gnu)
        BUILD_RELEASE="--compile ${KMAKE_ORIGIN} release-windows-gnu"
        BUILD_DEBUG="--compile ${KMAKE_ORIGIN} debug-windows-gnu"

        TARGET_REL_DIR=release-windows-gnu
        TARGET_DEB_DIR=debug-windows-gnu
        ;;
    --windows)
        BUILD_RELEASE="--compile ${KMAKE_ORIGIN} release-windows"
        BUILD_DEBUG="--compile ${KMAKE_ORIGIN} debug-windows"

        TARGET_REL_DIR=release-windows
        TARGET_DEB_DIR=debug-windows
        ;;
    *)
        echo "Error: Argument must be --linux, --windows-gnu or --windows" >&2
        exit 1
        ;;
esac

#
# Copy dependencies
#

if [ -d "${SRC_TARGET}" ]; then
    rm -rf "${SRC_TARGET}"
fi
mkdir "${SRC_TARGET}"

if [ -d "${INCLUDE_TARGET}" ]; then
    rm -rf "${INCLUDE_TARGET}"
fi
mkdir "${INCLUDE_TARGET}"

for file in "${SRC_ORIGIN}"/*.c
do
    [ -f "$file" ] || continue
    cp "$file" "${SRC_TARGET}/"
done

for file in "${INCLUDE_ORIGIN}"/*.h
do
    [ -f "$file" ] || continue
    cp "$file" "${INCLUDE_TARGET}/"
done

#
# Compile
#

kalamake ${BUILD_RELEASE} || exit 1
kalamake ${BUILD_DEBUG} || exit 1

#
# Cleanup
#

rm -rf "${SRC_TARGET}"

if [ -d "${TARGET_REL_DIR}/obj" ]; then
    rm -rf "${TARGET_REL_DIR}/obj"
fi

if [ -d "${TARGET_DEB_DIR}/obj" ]; then
    rm -rf "${TARGET_DEB_DIR}/obj"
fi

mf --o --f "${INCLUDE_TARGET}" --t "${TARGET_REL_DIR}"
mf --o --f "${INCLUDE_TARGET}" --t "${TARGET_DEB_DIR}"

# Lua license

cat > LICENSE <<'EOF'
Copyright © 1994–2026 Lua.org, PUC-Rio.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EOF

mf --o --f "LICENSE" --t "${TARGET_REL_DIR}/LICENSE"
mf --o --f "LICENSE" --t "${TARGET_DEB_DIR}/LICENSE"

rm -rf "${INCLUDE_TARGET}"
rm -rf "LICENSE"
