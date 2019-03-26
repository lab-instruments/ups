# Setup Paths
BOOTG=~/tools/Xilinx/SDK/2018.2/bin/bootgen

# Clear Card
rm /media/mdelong20/boot/*

# Build BOOT.BIN
$BOOTG -image boot.bif -o i BOOT.bin -w

cp ./BOOT.bin                                                                                           /media/mdelong20/boot/
cp ~/git/poky/build/tmp/deploy/images/zedboard-zynq7/core-image-minimal-zedboard-zynq7.cpio.gz.u-boot   /media/mdelong20/boot/rootfs
cp ~/git/poky/build/tmp/deploy/images/zedboard-zynq7/uImage                                             /media/mdelong20/boot/
cp ~/projects/scratch/u-boot-xlnx/arch/arm/dts/zynq-artyz7.dtb                                          /media/mdelong20/boot/
cp ./uEnv.txt                                                                                           /media/mdelong20/boot/

