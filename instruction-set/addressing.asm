;; NOTE that this is not a program meant to be run.  It is just a way to demonstrate
;; that the instructions and addressing modes to assemble without error.

        section .text
global start
start:
        ;; register addressing mode
        mov rax, rbx

        ; direct (or immediate) addressing mode
        ; you cannot store to a constant, so only the source may be a constant
        mov rax, 10 	; source operand is a constant

        ; indirect addressing mode
        ; one of the operands is the address of the memory location in a register
        mov rax, [rbx]
        mov [rbx], rax
        ; invalid!
        ; mov [rax], [rbx]

        
        ; indirect with displacement
        ; address = base + displacement
        ;
        ; typical use is to access structure elements (the displacement is the offset
        ; to the structure member)
        mov rax, [24+rbx] 	; base is rbx, displacement is 24
        mov [24+rbx], rax

        ; indirect with displacement and scaled index
        mov rax, [array + rbx * 4]
        mov [array + rbx * 4], rax

        ; indirect with displacement in a second register
        mov rax, [rbx + rcx]
        mov [rbx + rcx], rax
        
        ; indirect with displacement in a second register scaled
        mov rax, [rbx + rcx *4]
        mov [rbx + rcx *4], rax
        
        ; indirect with displacement and another displacement in a second register scaled
        mov rax, [24 + rbx + rcx *4]
        mov [24 + rbx + rcx *4], rax
        
       section .bss 
array: resb 8192
        
