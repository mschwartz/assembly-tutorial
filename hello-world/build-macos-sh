#!/bin/sh

nasm -f macho64 -o hello-macos.o -l hello-macos.lst hello-macos.asm
ld -static -o hello-macos hello-macos.o

echo "Run it via ./hello-macos"
