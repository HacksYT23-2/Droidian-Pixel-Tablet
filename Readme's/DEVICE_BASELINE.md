# TangorPro factory image baseline

Collected from the factory package in this workspace on 2026-10-07. This file records what the package actually contains so later builds can be matched to it.

## Device and boot chain

- Device codename: `tangorpro`; Android board requirement: `tangorpro`.
- Bootloader requirement recorded by the package: `tangorpro-14.5-12088398`.
- SoC/device tree family: Google Tensor GS201. The extracted vendor DTB root reports `compatible = "google,gs201"`.
- `boot.img`: Android boot header v4; kernel payload is LZ4 and reports Linux `5.10.198-android13-4-00050-g12f3388846c3-ab11920634`; ramdisk is empty.
- `vendor_boot.img`: header v4; contains a vendor ramdisk and boot config. Its command line requests early serial output on `ttySAC0` at 115200 and uses Exynos display/boot settings.
- `vendor_kernel_boot.img`: contains the DTB and another vendor ramdisk. Extracted DTB data is device-tree version 17.
- `init_boot.img`: contains a 2.3 MB ramdisk.
- `dtbo.img`: Android DT table, version 0, 4 KiB page size, 7 overlay entries.
- `fastboot-info.txt` flashes boot artifacts separately, reboots to fastbootd, then updates the dynamic system/vendor partitions. Do not treat the system image as a standalone full-device image.

## Porting implications

This is a split GKI-era boot layout. A Halium/Droidian boot image must account for the separate `boot`, `init_boot`, `vendor_boot`, `vendor_kernel_boot`, and `dtbo` roles. Replacing only `boot.img` is not a complete kernel port, and the vendor DTB/ramdisks must remain compatible with the selected kernel build.

The factory image's 5.10.198 Android 13 kernel is the matching base for this package. The LineageOS device tree declares a separate TangorPro kernel-prebuilt repository, and a separate GS201 common device repository. Any move to a newer 6.1 kernel must use its matching Lineage/vendor/kernel set rather than mixing it with these factory boot files.

## Host-side extraction performed

The boot headers were unpacked to `/tmp/tangorpro-boot`, `/tmp/tangorpro-init-boot`, `/tmp/tangorpro-vendor-boot`, and `/tmp/tangorpro-vkb`; the DTB was decompiled to `/tmp/tangorpro-stock.dts`. The factory images in this workspace were not modified.
