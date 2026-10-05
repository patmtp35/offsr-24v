#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
rm -rf "$HERE/build" && mkdir -p "$HERE/build"
git clone --depth 1 https://github.com/SeByDocKy/myESPhome.git "$HERE/build/upstream"
(cd "$HERE/build/upstream" && patch -p1 < "$HERE/patches/offsr-24v.patch")
mkdir -p "$HERE/build/components"
cp -r "$HERE/build/upstream/components/offsr" "$HERE/build/components/offsr"
echo "OK : composant patché dans $HERE/build/components/offsr"
