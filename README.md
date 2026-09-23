# petalOS SystemUI development module

This packages the currently built `SystemUI.apk` as a KernelSU-compatible systemless module at
the device's real path, `/system_ext/priv-app/SystemUI/SystemUI.apk`.

```bash
source build/envsetup.sh
lunch petal_macanc-bp4a-eng
m SystemUI
tools/petal-systemui-module/build.sh
```

Install `out/target/product/macanc/petal-systemui-dev.zip` in KernelSU Manager and reboot. For
later iterations, rebuild the APK, regenerate the zip, update the same module, and reboot.

If SystemUI fails during startup, disable or remove `petal_systemui_dev` from KernelSU's safe mode
or recovery module manager. The underlying ROM APK is never modified.
