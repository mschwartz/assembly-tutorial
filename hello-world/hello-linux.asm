; use the build-linux.sh script to assemble and link this
        bits 64

section .text

        global _start
_start:
        mov     rax, 1 ; write
        mov     rdi, 1 ; stdout
        mov     rsi, msg
        mov     rdx, msg.len
        syscall

        mov     rax, 60 ; exit
        mov     rdi, 0
        syscall


        section .data

msg:    db      "Hello, world!", 10
.len:   equ     $ - msg
