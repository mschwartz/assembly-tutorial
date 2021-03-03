#!/bin/sh

nasm -f elf64 -o hello-linux.o -l hello-linux.lst hello-linux.asm
ld -static -o hello-linux  hello-linux.o

echo "Run it via ./hello-linux"
