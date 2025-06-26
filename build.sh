#!/usr/bin/env bash

# Kernel Source
KERNEL_SOURCE="https://github.com/iambinaytiwari/android_kernel_samsung_m51"
KERNEL_BRANCH="lineage-21"
KERNEL_DEFCONFIG="m51_defconfig"

# Prebuilt Clang Toolchain (AOSP)
CLANG_URL="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r547379.tar.gz"

# Prebuilt GCC Utilities (AOSP)
GCC_x64="https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9"
GCC_x32="https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9"

# Setup make Command
make_fun() {
	make O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 \
		CLANG_TRIPLE=aarch64-linux-gnu- \
		CROSS_COMPILE=aarch64-linux-android- \
                CROSS_COMPILE_ARM32=arm-linux-androideabi- "$@"
}

# Work Path
WORK="${HOME}/work"

# Kernel Folder Name
KERNEL="myKernel"

# Kernel Source Path
KERNEL_SRC="${WORK}/${KERNEL}"

# Prepare Directory
mkdir -p "${WORK}"
cd "${WORK}" || exit 1

# Cloning all the Necessary files
if [ ! -d clang ]; then mkdir clang && curl "${CLANG_URL}" -RLO && tar -C clang/ -xf clang-*.tar.gz; fi
[ ! -d x64 ] && git clone --depth=1 "${GCC_x64}" ./x64
[ ! -d x32 ] && git clone --depth=1 "${GCC_x32}" ./x32
[ ! -d "${KERNEL}" ] && git clone --depth=1 "${KERNEL_SOURCE}" -b "${KERNEL_BRANCH}" "${KERNEL}"

# Setting Toolchain Path
PATH="${WORK}/clang/bin:${WORK}/x64/bin:${WORK}/x32/bin:/bin"

# Enter Kernel root directory
cd "${KERNEL_SRC}" || exit 1

# KernelSU - Disable if not building one.
curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/next-susfs/kernel/setup.sh" | bash -s next-susfs

# Start Compiling Kernel
make_fun "${KERNEL_DEFCONFIG}"
make_fun -j"$(nproc --all)" 2>&1 | tee build.log
tools/mkdtimg create out/arch/arm64/boot/dtbo.img --page_size=4096 $(find out/arch -name "*.dtbo")
