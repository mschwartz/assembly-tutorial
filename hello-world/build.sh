#!/bin/sh

nasm -f macho64 -o hello.o -l hello.lst hello.asm
ld -static -o hello hello.o
