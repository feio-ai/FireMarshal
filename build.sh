#!/bin/bash
set -e

LINUX_SRC=${PWD}/riscv-linux

# Update the overlay with pfa_tests
mkdir -p buildroot-overlay/root
rm -rf buildroot-overlay/root/*
cp -r pfa_tests/* buildroot-overlay/root/

cp buildroot-config buildroot/.config
pushd buildroot
# Note: Buildroot doesn't support parallel make
make -j1
popd
cp buildroot/output/images/rootfs.ext2 .

cp linux-config-pfa riscv-linux/.config
pushd $LINUX_SRC
make -j16 ARCH=riscv vmlinux
popd

pushd riscv-pk
mkdir -p build
pushd build
../configure --host=riscv64-unknown-elf --with-payload=$LINUX_SRC/vmlinux
make -j16
cp bbl ../../bbl-vmlinux
popd
popd
