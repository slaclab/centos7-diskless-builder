#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"

qemu-system-x86_64 \
	-m size=2048 \
	-nographic -no-reboot \
	-kernel ./$(find output -iname "vmlinuz-*" | head -n 1) \
	-initrd ./output/CentOs7_Lite_dev_$(cat VERSION)_fs.cpio.gz \
	-append "console=ttyS0 init=/init root=/dev/ram0"

