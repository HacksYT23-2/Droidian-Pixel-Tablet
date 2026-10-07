# Halium kernel audit

## Current findings

The factory `boot.img` embeds its kernel configuration, so we can assess compatibility without booting or changing the tablet. This is a static configuration check only; runtime validation with `lxc-checkconfig` still requires a running image.

### Present in the shipped kernel

- Android binder IPC and binderfs, with `binder`, `hwbinder`, and `vndbinder` devices.
- Ashmem, seccomp, cgroups, freezer, CPU accounting, memory cgroups, network namespaces, UTS namespaces, bridge, veth, tun, loop devices, ext4, F2FS, FUSE, and overlayfs.
- The exact kernel version is `5.10.198-android13-4-00050-g12f3388846c3-ab11920634`.

### Missing and likely required for a Halium container

- `CONFIG_PID_NS` is disabled.
- `CONFIG_USER_NS` is disabled.
- `CONFIG_CGROUP_PIDS` is disabled.
- `CONFIG_CGROUP_DEVICE` is disabled.

These are concrete configuration changes to investigate in the device kernel build. The stock kernel also already supplies several requirements, so the port does not start from zero.

## Source availability and build setup

Google publishes the exact matching GS201 branch `android-gs-tangorpro-5.10-android13-qpr3` in `kernel/gs`, and the device-specific TangorPro build files are published in `kernel/devices/google/tangorpro`. The device build config points its kernel directory at `private/gs-google`; the kernel manifest maps the public `kernel/gs` repository into that path. The full matching manifest and its public Google module repositories are synced under `/tmp/tangorpro-halium`. Google's Android Clang 14.0.7 is included in that source tree.

The local port files now include [`droidian/build-kernel.sh`](droidian/build-kernel.sh), a wrapper for the mixed GKI/device build, and [`droidian/tangorpro-gki-build.config`](droidian/tangorpro-gki-build.config), which applies the container options to the GKI build as well as the TangorPro device kernel. The kernel config fragment is at [`droidian/tangorpro.fragment`](droidian/tangorpro.fragment).

## Build and boot compatibility risks

- The stock image uses Android boot header v4 with kernel, init ramdisk, vendor ramdisk, DTB, and DTBO in separate partitions. Droidian's published kernel packaging guide documents older layouts and must be adapted for this split layout.
- The factory package's DTB/DTBO and vendor modules must match the chosen kernel branch. Keep the initial work on the exact Android 13 / 5.10 branch represented by this dump.
- Kernel source/config changes are not enough to confirm the Android compatibility container, display stack, Wi-Fi, audio, or suspend work. Those need device boot logs and on-device tests.

## Build status and next technical steps

1. Finish the current mixed GKI/device kernel build. The Android build needs Google's host OpenSSL prebuilt and explicit host linker flags in this container; using its system OpenSSL 3 led to missing legacy symbols. The workspace sandbox also imposes a roughly 4 GB build-output quota, so this run writes to `/var/tmp/tangorpro-kernel-out`.
2. Inspect the produced kernel, modules, DTBs, and config, then package a boot image that preserves the stock DTB/DTBO and vendor partitions.
3. Validate first boot over early serial/USB logs, then use `lxc-checkconfig` and a Halium/Droidian shell to confirm runtime container requirements.

The kernel config was extracted to `/tmp/tangorpro-stock.config`; the factory files remain unchanged.

The extracted stock config snapshot is also saved as [`tangorpro-stock.config`](tangorpro-stock.config). A first-pass four-option fragment is at [`droidian/tangorpro.fragment`](droidian/tangorpro.fragment). I applied those four options to a temporary copy of the stock config and ran the matching kernel tree's `olddefconfig`; all four remain enabled. A full kernel build is now running using the matching Google manifest and Android Clang prebuilt. Its generated output is under `/var/tmp/tangorpro-kernel-out` because the workspace sandbox stopped the first run at its build-output quota.

Reference branches: [Google GS201 kernel source](https://android.googlesource.com/kernel/gs/+/refs/heads/android-gs-tangorpro-5.10-android13-qpr3), [TangorPro device kernel build files](https://android.googlesource.com/kernel/devices/google/tangorpro/+/refs/heads/android-gs-tangorpro-5.10-android13-qpr3), and [Halium 13 generic device config](https://github.com/Halium/android_device_halium_halium/tree/halium-13.0).
