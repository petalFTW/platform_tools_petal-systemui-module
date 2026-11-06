# petalOS SystemUI development module

This packages the built `SystemUI.apk` and `surfaceflinger` as a KernelSU-compatible
systemless development module for the matching arm64 petalOS ROM:

- `system/system_ext/priv-app/SystemUI/SystemUI.apk` → `/system_ext/priv-app/SystemUI/SystemUI.apk`
- `system/bin/surfaceflinger` → `/system/bin/surfaceflinger`

The native payload keeps the `surfaceflinger_exec` SELinux label. It must not be
packaged under `system/system/bin`, which does not override the real executable.

```bash
source build/envsetup.sh
lunch petal_macanc-bp4a-user
m SystemUI surfaceflinger -j"$(nproc)"
tools/petal-systemui-module/build.sh
```

Install `out/target/product/macanc/petal-systemui-dev.zip` in KernelSU Manager and reboot. For
later iterations, rebuild both targets, regenerate the zip, update the same module,
and reboot. The native compositor change retains the ten-request limit for ordinary
blurs; only bounded, disjoint, same-radius small lens batches share request accounting.

If SystemUI fails during startup, disable or remove `petal_systemui_dev` from KernelSU's safe mode
or recovery module manager. The underlying ROM APK is never modified.
