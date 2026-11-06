#!/system/bin/sh
ui_print "- Installing petalOS SystemUI development override"
ui_print "- Targets: /system_ext/priv-app/SystemUI (apk + oat), /system/bin/surfaceflinger"

if [ "$ARCH" != "arm64" ]; then
  abort "! This module is intended for arm64 petalOS builds"
fi

set_perm_recursive "$MODPATH/system/system_ext/priv-app/SystemUI" 0 0 0755 0644
set_perm "$MODPATH/system/bin/surfaceflinger" 0 0 0755 u:object_r:surfaceflinger_exec:s0
[ -d "$MODPATH/system/system_ext/priv-app/PetalHub" ] && set_perm_recursive "$MODPATH/system/system_ext/priv-app/PetalHub" 0 0 0755 0644
