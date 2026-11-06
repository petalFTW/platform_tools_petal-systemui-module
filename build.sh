#!/usr/bin/env bash
set -euo pipefail

ANDROID_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MODULE_ROOT="$ANDROID_ROOT/tools/petal-systemui-module"
PRODUCT_OUT="${ANDROID_PRODUCT_OUT:-$ANDROID_ROOT/out/target/product/macanc}"
SOURCE_APK="$PRODUCT_OUT/system_ext/priv-app/SystemUI/SystemUI.apk"
SOURCE_OAT="$PRODUCT_OUT/system_ext/priv-app/SystemUI/oat/arm64"
SOURCE_SF="$PRODUCT_OUT/system/bin/surfaceflinger"
STAGE_DIR="$(mktemp -d)"
OUTPUT_ZIP="$PRODUCT_OUT/petal-systemui-dev.zip"
PAYLOAD="$STAGE_DIR/payload"
ARCHIVE="$STAGE_DIR/module.zip"

trap 'rm -rf "$STAGE_DIR"' EXIT

if [ ! -s "$SOURCE_APK" ]; then
  echo "SystemUI.apk was not found at: $SOURCE_APK" >&2
  echo "Build it first with: m SystemUI" >&2
  exit 1
fi
if [ ! -s "$SOURCE_SF" ]; then
  echo "surfaceflinger was not found at: $SOURCE_SF" >&2
  echo "Build it first with: m surfaceflinger" >&2
  exit 1
fi

mkdir -p "$PAYLOAD/system/system_ext/priv-app/SystemUI" "$PAYLOAD/system/bin"
cp "$MODULE_ROOT/module.prop" "$MODULE_ROOT/customize.sh" "$PAYLOAD/"
cp "$SOURCE_APK" "$PAYLOAD/system/system_ext/priv-app/SystemUI/SystemUI.apk"
# The ROM's preopt belongs to the old APK; ship the matching one or ART rejects it.
if [ -s "$SOURCE_OAT/SystemUI.odex" ] && [ -s "$SOURCE_OAT/SystemUI.vdex" ] &&
    [ ! "$SOURCE_OAT/SystemUI.odex" -ot "$SOURCE_APK" ]; then
  mkdir -p "$PAYLOAD/system/system_ext/priv-app/SystemUI/oat/arm64"
  cp "$SOURCE_OAT/SystemUI.odex" "$SOURCE_OAT/SystemUI.vdex" \
    "$PAYLOAD/system/system_ext/priv-app/SystemUI/oat/arm64/"
else
  echo "warning: no preopt newer than SystemUI.apk, shipping APK only" >&2
fi
# hub rides along so the popup toggle exists
HUB_SRC="$PRODUCT_OUT/system_ext/priv-app/PetalHub"
if [ -s "$HUB_SRC/PetalHub.apk" ]; then
  mkdir -p "$PAYLOAD/system/system_ext/priv-app/PetalHub"
  cp "$HUB_SRC/PetalHub.apk" "$PAYLOAD/system/system_ext/priv-app/PetalHub/"
  if [ -s "$HUB_SRC/oat/arm64/PetalHub.odex" ] && [ ! "$HUB_SRC/oat/arm64/PetalHub.odex" -ot "$HUB_SRC/PetalHub.apk" ]; then
    mkdir -p "$PAYLOAD/system/system_ext/priv-app/PetalHub/oat/arm64"
    cp "$HUB_SRC"/oat/arm64/PetalHub.{odex,vdex} "$PAYLOAD/system/system_ext/priv-app/PetalHub/oat/arm64/"
  fi
fi
cp "$SOURCE_SF" "$PAYLOAD/system/bin/surfaceflinger"
chmod 0755 "$PAYLOAD/customize.sh" "$PAYLOAD/system/bin/surfaceflinger"

(cd "$PAYLOAD" && zip -q -r -9 "$ARCHIVE" .)
zip -q -T "$ARCHIVE"
cp "$ARCHIVE" "$OUTPUT_ZIP.tmp"
mv -f "$OUTPUT_ZIP.tmp" "$OUTPUT_ZIP"
echo "$OUTPUT_ZIP"
