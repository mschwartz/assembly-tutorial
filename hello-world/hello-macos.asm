; use the build-macos.sh script to assemble and link this

        section .text

        global start
start:
        mov     rax, 0x2000004 ; write
        mov     rdi, 1 ; stdout
        mov     rsi, msg
        mov     rdx, msg.len
        syscall

        mov     rax, 0x2000001 ; exit
        mov     rdi, 0
        syscall


        section .data

msg:    db      "Hello, world!", 10
.len:   equ     $ - msg
