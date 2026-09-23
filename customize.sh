#!/system/bin/sh

ui_print "- Installing petalOS SystemUI development override"
ui_print "- Target: /system_ext/priv-app/SystemUI/SystemUI.apk"

if [ "$ARCH" != "arm64" ]; then
  abort "! This module is intended for arm64 petalOS builds"
fi

set_perm_recursive "$MODPATH/system/system_ext/priv-app/SystemUI" 0 0 0755 0644
