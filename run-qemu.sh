#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"

qemu-system-x86_64 \
	-m size=2048 \
	-cpu max \
	-nographic -no-reboot \
	-kernel ./$(find output -iname "vmlinuz*" | head -n 1) \
	-initrd ./output/Rocky9_Lite_dev_$(cat VERSION)_fs.cpio.gz \
	-append "console=ttyS0 init=/init root=/dev/ram0"

