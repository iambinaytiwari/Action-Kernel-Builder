## (Work/Update in Progress)
Github Action for Compiling Kernel from Source

## Notes
Make sure to edit `build` file to suits your need.

Change kernel source url with your own, with respective branch you wanna use (if theres a lot branches).

Change defconfig, you could find it in default directory `arch/arm64/configs/`, or in `arch/arm64/configs/vendor`. If your defconfig is in the vendor/ directory, make sure to add your defconfig as `name_defconfig`.

Change compiler and toolchain based on your preferred version, or based on what your kernel source needs. If you can extract ikconfig on your current kernel, you can check what version used in compiling your stock.

## Flashable Template
Use this template: [AnyKernel3 by osmOsis](https://github.com/osm0sis/AnyKernel3). Please read carefully all the information it before trying.
