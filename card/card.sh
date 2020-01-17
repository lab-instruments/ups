# Setup Paths
BOOTG=~/tools/Xilinx/SDK/2018.2/bin/bootgen

# Clear Card
rm /media/mdelong20/boot/*

# Rename u-boot Executable
cp /home/mdelong20/projects/scratch/u-boot-xlnx-fork/build/u-boot /home/mdelong20/projects/scratch/u-boot-xlnx-fork/build/u-boot.elf

# Build BOOT.BIN
$BOOTG -image boot.bif -o i BOOT.bin -w

cp ./BOOT.bin                                                                                           /media/mdelong20/boot/
cp ~/git/poky/build/tmp/deploy/images/zedboard-zynq7/core-image-minimal-zedboard-zynq7.cpio.gz.u-boot   /media/mdelong20/boot/rootfs
cp ~/git/poky/build/tmp/deploy/images/zedboard-zynq7/uImage                                             /media/mdelong20/boot/
cp ~/projects/scratch/u-boot-xlnx-fork/build/arch/arm/dts/zynq-coraz7.dtb                                          /media/mdelong20/boot/
cp ./uEnv.txt                                                                                           /media/mdelong20/boot/

