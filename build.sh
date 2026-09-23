#!/usr/bin/env bash
set -euo pipefail

ANDROID_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MODULE_ROOT="$ANDROID_ROOT/tools/petal-systemui-module"
PRODUCT_OUT="${ANDROID_PRODUCT_OUT:-$ANDROID_ROOT/out/target/product/macanc}"
SOURCE_APK="$PRODUCT_OUT/system_ext/priv-app/SystemUI/SystemUI.apk"
STAGE_DIR="$(mktemp -d)"
OUTPUT_ZIP="$PRODUCT_OUT/petal-systemui-dev.zip"

trap 'rm -rf "$STAGE_DIR"' EXIT

if [ ! -f "$SOURCE_APK" ]; then
  echo "SystemUI.apk was not found at: $SOURCE_APK" >&2
  echo "Build it first with: m SystemUI" >&2
  exit 1
fi

mkdir -p "$STAGE_DIR/system/system_ext/priv-app/SystemUI"
cp "$MODULE_ROOT/module.prop" "$MODULE_ROOT/customize.sh" "$STAGE_DIR/"
cp "$SOURCE_APK" "$STAGE_DIR/system/system_ext/priv-app/SystemUI/SystemUI.apk"
chmod 0755 "$STAGE_DIR/customize.sh"

rm -f "$OUTPUT_ZIP"
(cd "$STAGE_DIR" && zip -q -r -9 "$OUTPUT_ZIP" .)
echo "$OUTPUT_ZIP"
