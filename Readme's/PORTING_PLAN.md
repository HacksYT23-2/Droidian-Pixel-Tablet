# Mobian on Pixel Tablet (TangorPro)

## What this checkout tells us

This directory is a TangorPro factory image, not a Mobian or kernel source tree. The supplied `boot.img` has an Android boot header v4 and contains Linux `5.10.198-android13-4-00050-g12f3388846c3-ab11920634`. The factory flash script uses separate `boot`, `init_boot`, `dtbo`, `vendor_kernel_boot`, `vendor_boot`, and dynamic system/vendor partitions.

## Chosen route: Halium 13 with a Debian mobile userspace

We are following the user's preference to use Halium. The current practical target is **Droidian**, a Debian mobile distribution that uses Halium/libhybris to reuse Android hardware support. Regular Mobian uses a mainline kernel and does not use Halium. The end result can provide the Mobian-style Debian tablet experience, while the technically accurate name for this Halium port is Droidian/TangorPro.

Halium's generic Android 13 device configuration is available, and TangorPro has a public LineageOS device tree on `lineage-23.2`. Neither is an existing TangorPro Halium port. The supplied factory dump and Google's public kernel source both match Android 13 / Linux 5.10.198, so that is the first coherent base to adapt. Newer TangorPro branches also exist; do not mix their Android 16 / Linux 6.1 artifacts with this Android 13 base.

## Milestones

1. **Preserve a recovery path.** Keep this exact factory package and verify bootloader/fastboot access before changing partitions. Record the installed build and partition layout.
2. **Pin a coherent Android base.** Use the TangorPro LineageOS device tree and its declared dependencies to choose the matching vendor files, kernel, and Android API level. The supplied image is an older 5.10 base; current LineageOS uses a newer branch, so do not mix their boot artifacts.
3. **Make the kernel Halium-compatible.** Build the matching kernel and satisfy Droidian's kernel requirements for Android binder, namespaces/cgroups, LXC, required filesystems, and Android boot image layout. Start with an Android booting kernel before changing the initramfs.
4. **Boot the Halium/Droidian base.** Adapt the device's boot image and dynamic partition setup, then reach a shell over USB or serial. Keep the first boot reversible and test on the device before packaging.
5. **Bring up tablet basics.** Validate display/touch, USB, Wi-Fi, audio, battery, suspend/resume, and the dock/pogo accessory; track sensors/cameras separately.
6. **Package the port.** Create the TangorPro adaptation package and installable image after boot and core hardware are stable. Document tested firmware, unlock, flash, and recovery steps.

## Immediate next inputs

- Confirmation that the tablet's bootloader is unlockable and that you can use fastboot; do not unlock or flash until user data is backed up.
- A serial/debug route if available. Without early boot logs, diagnosing a first kernel boot will be much harder.
- Source code and firmware matching the installed build. The supplied factory image is enough to identify the boot layout and inspect its device tree, but it does not contain the full buildable kernel source.

## References

- [Mobian porting guide](https://wiki.debian.org/Mobian/Porting)
- [Mobian's explanation of its device support approach](https://blog.mobian-project.org/posts/2023/03/07/porting-to-new-devices/)
- [Google's TangorPro Android kernel/device tree](https://android.googlesource.com/kernel/devices/google/tangorpro/)
- [Google's Pixel kernel build and partition guidance](https://source.android.com/docs/setup/build/building-pixel-kernels)
- [Droidian kernel adaptation guide](https://docs.droidian.org/porting-guide/kernel-compilation/)
- [Droidian device porting guide](https://docs.droidian.org/porting-guide/)
- [Halium 13 generic Android device configuration](https://github.com/Halium/android_device_halium_halium/tree/halium-13.0)
- [LineageOS TangorPro device tree](https://github.com/LineageOS/android_device_google_tangorpro/tree/lineage-23.2)
