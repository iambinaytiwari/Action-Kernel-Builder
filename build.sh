#!/bin/sh

set -e -x

# Kernel Source
KERNEL_SOURCE=https://github.com/iambinaytiwari/android_kernel_samsung_m51.git
KERNEL_BRANCH=13
KERNEL_DEFCONFIG=m51_defconfig

# Prebuilt Clang Toolchain (AOSP)
CLANG_URL=https://android.googlesource.com/platform//prebuilts/clang/host/linux-x86/+archive/4c6fbc28d3b078a5308894fc175f962bb26a5718/clang-r383902b1.tar.gz

# Prebuilt GCC Utilities (AOSP)
GCC_x64=https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9
GCC_x32=https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9
GCC_BRANCH=master-kernel-build-2021

# Setup make Command
make_fun() {
  make O=out ARCH=arm64 \
       CC=clang HOSTCC=clang LLVM=1 \
       CLANG_TRIPLE=aarch64-linux-gnu- \
       CROSS_COMPILE=aarch64-linux-android- \
       CROSS_COMPILE_COMPAT=arm-linux-androideabi- "$@"
}

# Work Path
WORK=${HOME}/work

# Kernel Folder Name
KERNEL=android-kernel

# Kernel Source Path
KERNEL_SRC=${WORK}/${KERNEL}

# Prepare Directory
mkdir -p "${WORK}"
cd "${WORK}" || exit 1

# Cloning all the Necessary files
if [ ! -d clang ]; then mkdir clang && curl -Lsq "${CLANG_URL}" -o clang.tgz && tar -xzf clang.tgz -C clang; fi
[ ! -d x64 ] && git clone --depth=1 "${GCC_x64}" -b "${GCC_BRANCH}" ./x64
[ ! -d x32 ] && git clone --depth=1 "${GCC_x32}" -b "${GCC_BRANCH}" ./x32
[ ! -d "${KERNEL}" ] && git clone --depth=1 "${KERNEL_SOURCE}" -b "${KERNEL_BRANCH}" "${KERNEL}"

# Setting Toolchain Path
PATH="${WORK}/clang/bin:${WORK}/x64/bin:${WORK}/x32/bin:/bin"

# Enter Kernel root directory
cd "${KERNEL_SRC}" || exit 1

# Export Additional Information, change it all according to your wants.
export KBUILD_BUILD_HOST="${KERNEL}"
export KBUILD_BUILD_USER="iambinaytiwari"

# Install KernelSu-Next
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -

# Start Compiling Kernel
make_fun "${KERNEL_DEFCONFIG}"
make_fun -j"$(nproc --all)" 2>&1 | tee build.log || exit 1
tools/mkdtimg create out/arch/arm64/boot/dtbo.img --page_size=4096 $(find out/arch -name "*.dtbo")
