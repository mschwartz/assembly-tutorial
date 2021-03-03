# Programming in assembly language tutorial

## Introduction

How CPUs work has become something of a lost art.  There are a small percentage of software engineers that need to understand the inner workings of CPUs, typically those who work on embedded software or operating systems, or compilers or JIT compilers...

Assembly language was one of the first languages I ever learned.  Back in the early/mid 1970s, my high school classes progressed from BASIC to FORTRAN IV, to BAL (Basic Assembly Language) for the IBM 360 to which we had access.  One of the earliest lessons we were taught used a cardboard teaching aid, CARDIAC.  CARDIAC stands for "CARDboard Illiustrative Aid to Computation"; it wwas developed at Bell Labs, which was a big deal back then (Unix was invented there, as well as the C programming language).

See https://www.cs.drexel.edu/~bls96/museum/cardiac.html.

With CARDIAC, you simulated the memory, operation, and CPU cycles of a mythical CPU.  The numbers and instructions for this CPU were in base 10, so the student doesn't have to understand how to convert to the common base 2, base 8, 8 or base 16 used in computing.  CARDIAC provided a cardboard device that had representation for memory, program steps, and ALU (math and logic operations).

You wrote your program and variables on the cardboard and then step by step, followed the program and performed the operations for each step.  The steps are identified by a single digit, 0-9:

- 0 INP read a card into memory
- 1 CLA clear accumulator and add from memory
- 2 ADD add from memory to accumulator
- 3 TAC test accumulator and jump if negative
- 4 SFT shift accumulator
- 5 OUT write memory location to output card
- 6 STO store accumulator to memory
- 7 SUB subtract memory from accumulator
- 8 JMP jump and save PC
- 9 HRS halt and reset

These values are "opcodes" and the encoded instructions/steps include the opcode plus address, number of bits to shift, etc.

The CPU features only two registers:  accumulator and program counter.  More complex and modern CPUs have many more registers than these two.

These instructions and registers are enough to learn from.  You learn about memory layout, instruction opcodes, instruction encoding, memory access, and so on.

In this tutorial, I will cover the basics of programming the x64/AMD64 CPU in assembly language.  As I progress, you will see how the CPU is really a glorified version of CARDIAC!

## Bits, Bytes, Words, and Nuamber Bases

The smallest piece of information that a CPU processes is a "bit."  A bit is a small integer or boolean type value, either 0 (off/false) or 1 (on/true).

Bits are then organized as "bytes," or 8 bits grouped together.  You can visualize a byte like this:

```
76543210
```

The digits represent what we call a bit number, and each digit (bits 0-7))may be a 0 or a 1.  A byte can represent an unsigned value of 0-255, or a signed value of -128-127.  Bit 7 of the byte is considered the "sign bit" - if it is 1, then the byte as a signed value is negative, if it is 0, then the byte is positive.  Note that you decide whether the byte is processed as signed or unsigned; more on this later, but for now it is important to understand how the bits make up bytes and signed/unsigned values are represented.

A "word" is two bytes grouped together, which means we have 16 bits together.  You can visualize a word like this:
```
5432109876543210
111111
```

The high order, sign bit, is bit 15.

The x86 also has DWORD values, which are two words combined.  It also has QWORD values which are two DWORDs combined.  The pattern is the same for any of these size values - the high bit is the sign bit, etc.  

From this point forward, I'll use "word" to mean one of these sized values, unless otherwise stated.

When we talk about the value of the word, we typically use base 2, base 4, base 8, base 10, and base 16.  Of these, base 8 isn't used much, but I'll explain a common use case for base 8.

In base 2 (also called "binary""), we simply talk about the value as the bits.  That is, an unsigned byte might be 11111111, or 11101110, and so on.  We might add a lead 0 and terminating b for clarity (and this is the syntax used in assembly programming): 011111111b.

Base 10 is the number base we use every day.  You count from 0 to 9 for each digit position in base 10.  When you add 1 to the value 9, you clear it (set to 0), and bump the 10s digit.  That is, 9+1 becomes 10.  As you go right to left in base 10, the digits are: n x 10 to the power of 0, n x 10 , or 10 to the power of 1, n x 100, or 10 to the power of 2, and so on.

In base 2, we count from 0 to 1 for each digit position.  When you add 1 to a 1 in a position in the byte, you clear it and increment the next higher bit (and continue until you find an existing 0 in position, which becomes 1).  As you go right to left in base 2, the digits are n x 2 to the power of 0, n x 2, or 2 to the power of 1, n x 4, or 2 to the power of 2, and so on.

In base 8 (also called "octal"), we count from 0-7 for each digit position.  Going right to left, n x 8 to the power of 0, n x 8 to the power of 1, n x 8 to the power of 2, etc.

In base 16 (also called "hex"), we count from 0-15 for each digit position.  We use a counting system that is 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F, then 10.  So going from right to left in a hex number, the digits are n x 16 to the power of 0, n x 16 to the power of 1, n x 16 to the power of 2, and so on.

A "nybble" is useful for working with hex.  A nybble is 4 bits.  It turns out that the value you can store in 4 bits is 0-15, perfect for hex.  You already get the pattern about power of 4s when using nybbles.

Let's look at the unsigned value ranges for the common word sizes:
```
1 bit: 0-1
2 bits: 0-3
3 bits: 0-7
4 bits: 0-15
5 bits, 0-31
...
```


The pattern here is that the max value is 2 to the number of bits minus 1.  That is for 5 bits, the max value 31 is 2 to the 5th power (32) minus 1.

When we convert a binary byte to hex, we visualize it something like this:

```
76543210 is 7654 3210
```
We've grouped the bits as two nybbles.  We can then convert the two nybbles (4 bits each) to two hex digits.

This table makes the conversion simple.  But if you practice using hex, you will know this table by heart.

```
0000 | 0
0001 | 1
0010 | 2
0011 | 3
0100 | 4
0101 | 5
0110 | 6
0117 | 7
1000 | 8
1001 | 9
1010 | A
1011 | B
1100 | C
1101 | D
1110 | E
1111 | F
```

For example, we visualize the binary value 010100101b as 1010 0101.  Using the table above, we see 1010 is A, and 0101 is 5.  So the byte value is A5.  We represent hex numbers in assembly as 0xa5, or 0a5h, or sometimes $a5.

We can use the same scheme to convert 16 bit or 32 bit or 64 bit values to hex!

I promised to discuss a use for Octal, something we might use every day.  In the linux/mac/*nix filesystem, permissions are actually octal values.
```
-rw-r--r--  1 mschwartz  staff   5.9K Feb 16 14:13 README.md
```
See the -rw-r--r-- ?  What we have here is 9 bits in octal.  rw- is 110, r-- is 100, r-- is 100.  So we can convert this to the internal filesystem represenation of 644.  If you want to make a file rw-r--r--, you use the chmod command:
```
chmod 644 README.md
```
The three bits, technically, are "able to read", "able to write", and "able to execute."  The first octal value is for the owner, the second is for anyone in the same user group as the owner, and the third is for everyone else.  So to allow the owner and group to read and write, but nobody else can read or write the file, we want rw-rw---- or 660.

## Math

Adding two values of the same word size is simple.  The byte 100 plus the byte 50 = 150.  100 + 50 = 150.

This works for signed and unsigned values.  The math is always unsigned, but the result is up to you.  If the high order bit (bit 7 of a byte, bit 15 of a 16-bit word...) is 1, the signed value is negative.

What happens when we add a byte value to a 16-bit word value?  The byte value is really a 16-bit value, but the upper 8 bits are zeros.  That is, 0xaa can be visualized as 0x00aa.  We just add the full 16-bit values together.

What happens when we add 1 to a byte size value of 255?  We only have 8 bits for the result, but we have 9 bits of actual value.  That is, 255 + 1 is 256.  Represented in binary, you have 255 = 011111111b + 1 = 0100000000b (9 bits!).  The 9th bit is basically ignored as far as the result byte goes (more on this later).  So if you look at the lower 8 bits of our 9 bit result, we get 0!

All this extends to 32 bit and 64 bit words.

Multiplication of two values requires a double-sized result, or you lose a lot more than just the 9th bit!  Consider 255 x 255 = 65025 (0xfe01), which fits in 16 bits but not in 8.  If we have a byte result, we get 0x01 due to the overflow, losing over 665000 in result value.

## Boolean Algebra

Boolean Algebra is a form of math that we use to deal with true/false values.  We use Boolean Algebra all the time in various programming languages, with operators like & (AND), | (OR), ^ (exclusive XOR, or XOR), and ! (NOT), ~ (also NOT) and so on.  These operators are equivalent to "math-like" operators.

The simplest way to visualize Boolean Algebra is using single bit values and truth tables.  0 = false, 1 = true.  For single bit value operands, there are only (always) 4 combinations possible.

```
AND (if both operands are true, the result is true)
0 & 0 = 0
0 & 1 = 0
1 & 0 = 0
1 & 1 = 1

OR (if either operand is true, the result is true)
0 | 0 = 0
0 | 1 = 1
1 | 0 = 1
1 | 1 = 1

XOR (if only one operand is true, the result is true)
0 ^ 0 = 0
0 ^ 1 = 1
1 ^ 1 = 1
1 ^ 1 = 0
```

The ! (NOT) operator only has one operand.  If the operand is true, the result is false.  If the operand is false, the result is true.  The result is also known as a 1's complement, or we've just inverted the state of all the bits.

The ~ (1's complement) operator inverts the bits in the word.

If we look at the operands as byte values, we have something like:
```
00000000 & 00000000 = 0
00000000 & 00000001 = 0
...
```
BUT, we have 8 bits, so the operation is performed on all 8 bits in the two operands.
```
   10000000 
OR 00000001 
   --------
   ^      ^
=  10000001
   ^      ^
   
NOT 10000001
=   01111110
```
This is a most important concept to grasp!

We use the Boolean Algebra operators on words to achieve useful results.  

A typical use of the AND operator is to clear bits in a value.  If we AND with a value that is a power of 2, we are simple clearing a bit.  n AND 4 clears bit 3 in n. 

A typical use of the OR operator is tto set bits in a value.  If we OR with a value that is a power of 2, we are simply setting a bit.  n OR 4 sets bit 3 in n.

A great use of the AND operator is to do a modulo of a number to a power of 2.  For example, AND with 3 gets you a result between 0 and 2.  AND with 7 gets y ou a result between 0 and 8.

## Bit Shifting

You can shift a byte to the left (<< operator in C) 1-7 bits.  For example:

```
001111101b << 1 = 001111100b

 001111101b  shifted left becomes
 ////////
001111100b  (bit 0 becomes 0)
```
Note that we have the overflow problem here, as we did with addition.  We have an upper bit that ends up in the "bit bucket" (thrown away).

A left shift of 1 bit is effectively a multply by 2.  Consider 001b<<1 is 010b, or 2.  A left shift of 2 bits is a multiply by 4, and so on.

Shifting to the right works similarly, but we now end up with the high bit being cleared and the low bit in the bit bucket. 

A right shift of 1 bit is effectively a divide by 2. But this right shift will take a negative number and make it positive because the sign bit is cleared.  So we need a second kind of right shift for signed values that sets the high bit in the result to the high bit in the initial value.

A rotate left/right is the same as a shift, except instead of the lost bit ending up in the bit bucket, it becomes the new high/low bit.

Other than for the multiply and divide effects, we use bit shifting frequently with Boolean Algebra.  To set bit 3:

```
n | (1<<3)

To clear bit 3:

n & ~(1<<3)

Note that 1<<3 = 01000b, 
and ~(1<<3) is  ~01000b 
              or 00111b.   (all the bits are inverted)
When you AND with 00111b, you are clearing bit 3.
```

## Memory

Memory (RAM) can be viewed as an array of bytes.  If you have 1MB of RAM, your array is indexed from 0 to 1MB-1.  The index is better known as an address.

Memory is used to store your program, for your program stack, for your program's heap (memory allocation) and to store your variables.  In a simple CPU and RAM setup, you might have your program start at index 0, your variables start at the end of the program, your heap starts at the end of your variables, and your stack starts at the top of memory and works its way downward as you push onto it.

The way words of the different sizes are stored in memory is determined by the "endianess" of the CPU.  A CPU that is big endian stores the high byte first in memory, the next highest byte next, ... and finally the lowest byte last.  A CPU that is little endian stores the low byte first, ... the high byte last.

In modern operating systems, the CPU uses an MMU (Memory Management Unit) to assign a subset of the system's memory to each program that you run.  The MMU maps an address in physical memory to a logical address that the program sees and uses.  This allows, for example, a CPU to split the 1MB of RAM into 2x 512K address spaces to run two programs.  The address translation makes it so each program thinks it has 512K of RAM starting at address 0 and ending at address 512K - 1.  

The use of the MMU is much more clever than I just explained, but the end result is the same.  When a program is launched, it is allocated a small amount of RAM, enough for the program's code and variables and stack and a minimal heap.  As the program needs more stack or more heap, the OS adds physical memory to the program's address space using the MMU.  The program grows on demand.

For our purposes, we're going to assume we're the only program running on the machine.  It matters not if there's an OS using the MMU or not, the programming effort and techniques are the same either way.

## ALU

The cost of having circuitry to add two arbitrary memory locations together is prohibitive.  You have 1M x 1M add circuits required, and that's just for addition!  

The math (add) capability is, instead, implemented in the ALU (Arithmetic-Logic Unit) of the CPU.  The CPU provides some (small) number of general purpose "registers" and the ALU implements the add circuitry just between those registers.  

You can think of a register as a (temporary) variable that is on chip, usable by the ALU to do math and logic operations.  You have to load your operand or operands into registers to perform math, then you can store the result to a variable in memory.

For example, to add two numbers at memory locations (addresses) 0x100 and 0x200 and store the result at address 0x300, and we have two registers named a and b:
```
  load value at 0x100 into a
  load value at 0x200 into b
  add a and b, leaving result in a
  store a at 0x3000
```

I have just introduced something like a snippet of assembly language code!  We need operations to be able to load memory into registers, add registers together, and store registers to memory.  Each of these operations is a CPU "opcode."  The CPU reads the byte opcode from memory and executes it.  Some opcodes, like the load and store ones require parameters like the address to load from or store to.  These addresses are stored in the program immediately following the opcode.  As we progress, we're going to see that the instruction sizes (op code plus parameters) are different depending on the instruction (op code) and parameters.  

In the simplest view of the CPU, the above program is 4 instructions.  The load and store instructions use 1 byte for opcode and 2 more for the addresses.  The add uses just the one byte for the opcode (add b to a).  

Each instruction uses 1 or more "clock cycles," depending on the complexity of the operation.  The load instruction requires a clock cycle to load the opcode, another 2 for each byte of the address, and another 2 to load the value from RAM at the address specified in the parameters, for 5 total clock cycles.  The add instruction takes just 1 clock cycle.  The store takes 5 as well.

## x64/AMD64 Registers

For all intents and purposes, the Intel and AMD processors have the same registers until you get into exotic features (like hardware video decoding).  I use the term x64 and AMD64 interchangable throughout this tutorial.

### General Purpose Registers

You have 4 general purpose registers, A, B, C, and D, though we don't use these specific names for the rgisters.  The size of the register/contents matters.  So for a byte value, we use AL or AH, or BL/BH, or CL/CH, or DL/DH.  The L means "low order byte" and H means "high order byte."  For word values, we use AX, BX, CX, and DX.  For 32 bit word values, we use EAX, EBX, ECX, and EDX.  And for 64 bit word values, we use RAX, RBX, RCX, and RDX.

When we use the registers whose size are smaller than 64 bits, the remaining bits in the register are not affected.  For example, if AX contains 0x0102 and we load 0x03 into AL, AX will contain 0x0103.  This will only matter if you load bytes into registers and add word registers together, in error.  There might be tricks you play to take advantage of the nature of the register loads/stores.

AMD64 and x64 add 8 more general purpose registers, R8, R9, R10, R11, R12, R13, R14, and R15.  These are accessed as 8, 16, 33, and 64 bit registers.  R8D through R15D (32 bits), R8W-R15W (16 bits), R8B-R15B (8 bits), and R8-R15 (64 bits).

### Special Purpose Registers

The RCX/RCX/CX (CX) register doubles as a counter for dedicated instructions.  The AMD64 instruction set includes instructions to fill, copy, and compare memory, and loops that use this register as the number of bytes/words/dwords/qwords to fill/copy/compare.  The special loop instructions use this register as the loop counter as well.

The RSI/ESI/SI and RDI/EDI/DI/ registers are general purpose "source" and "destination" registers for the fill, copy, and compare instructions.

The RBP register is a general purpose register that is typically used as a base address register or by high level language compilers to maintain function stack frames (arguments, return address, and local variables allocated on the stack).

### CPU Control Registers

#### Stack 
The RSP register contains the address of the last thing pushed on the processor stack. You can push registers on the stack to preserve their values, you can pop them to restore their values, address values already on the stack by index, etc.

#### Instruction Pointer
The RIP register contains the address of the next instruction to be executed.  The CPU automatically adds the correct number to it as it executes instructions to keep it pointed at the correct next instruction.  When you call a subroutine, the RIP is pushed on the RSP stack and RIP is loaded with the address of the subroutine.  When the subroutine returns, the RIP that was pushed before the call is popped from the stack into RIP.  Execution continues at the instruction after the call.

#### Flags
The FLAGS register is 64 bits containing information provided by the CPU to the program, and commands from the program to the CPU.  Not all the bits are used.  See https://en.wikipedia.org/wiki/FLAGS_register.

An example of the bits in FLAGS set by the CPU is the Carry Flag.  It is set when you have a carry after an arithmetic operation.  For example, if you add 1 to the AL regsister that contains 255, you will get AL=0, Carry = 1.  If you add 1 to AL=254, the Carry will be 0.

An example of the bits in the FLAGS set by the program is the Direction Flag.  If this is 0, the fill/copy/etc. instructions work from start address forward (auto-increments SI and DI).  If this is 1, the operations are done backward (auto-decrement).

The FLAGS register is there to use, but we might really only directly use the Carry bit and Direction bit.  We might use the Carry bit to return a true/false result from a function.  The CLC and STC instructions clear and set the Carry bit.  

The various branch instructions use the Carry and Zero bits internally.

There are several instructions that set and clear these bits, programatically.

# AMD64 Instruction Set

You will learn the instruction set as you go.  The instruction set is documented as a reference manual, not a programming manual.  That is, each instruction is documented as to what it does.  But there is no particular "how to use this instruction" documentation.  "

You can find the instruction set documented on various Web Sites.  The best source is the Intel Programmer's Manual or the AMD64 Programmer's Manual.

Here is a decent Web Page that lists the instructions in a table, one line per instruction with a short description.

https://www.felixcloutier.com/x86/

There are over 1500 instructions, from AAA to XTEST that we can use.  Too many to document every one here. However, there are much fewer commonly used instructions that we use for most things.

The format of a line of source code in assembly is:
```
[optional label] instruction
or
[optional label] instruction operand
or
[optional label] instruction operand1, operand2
```


When assembled, the instructions are encoded as opcode and operands as a sequence of bytes.  The CPU is able to execute these instructions.

## Assembly source

In assembly source, the NASM assembler expects operands to be specified as ```destination, source``` (Intel syntax) while the gas assembler expects operands to be specified as ```source, destination``` (AT&T syntax).  The assembler language for the various CPUs (e.g. MC68000, AMD64, ARM, etc.) each specify whether the left operand is source or destination.  The gas assembler can be used to assemble source for various processors so it defaults to source, destination format, though you can tell it to use Intel (NASM) syntax.

In Intel syntax source programs, the semicolon (;) character introduces the start of a comment.  All characters from that point on, to the end of the line, are ignored.

Before we look at some of these instructions, we need to look at addressing modes.

## Addressing Modes

Addressing modes are the means by which operands to instructions are described and how they execute.  For example, Register operands indicate specific registers, but memory operands can be addressed through a variety of combinations of offsets and/or regsister contents.

To examine the addressing modes, we'll use the MOV instruction, which copies a value in a register to memory or loads a value to a register from memory.

The source and/or destination operand is specified using one of the addressing modes.

The instruction-set/addressing.asm file contains example usage of the various addressing modes.

### Register Operands

Rather than memory being the source or destination, the operand is a register.  For example, 
```
	mov rax, rbx ; moves contents of rbx register into the rax register.
```

### Direct Memory Operands (better known as Immediate operands)

This mode moves a constant into a register.  The constant is encoded in the instruction, after the opcode. For example,
```
        mov rax, 10 	; source operand is a constant
```

#### Indirect Operands

This mode uses a register as the address of a memory location to be operated on (e.g. load from, store to).  For example,
```
        mov (rax), rbx   ; store contents of rbx to memory location contained in rax 
```

#### Indirect with Displacement

This mode uses a register as the base address of a memory location, added to a fixed offset, to determine the address of a memory location to be operated on.  For example,
```
        mov rax, 24(rbx)  ; access memory at 24 + contents of rbx
```
The purpose of this addressing mode is to facilitate accessing a structure and its members.  Consider:
```
struct {
  char *name,
       *address,
	   *phone;
} person;
person.name = nullptr;
person.address = nullptr;
person.phone = nullptr;

```

In assembly, we'd do something like this:
```
NAME equ 0
ADDRESS equ 8
PHONE equ 12

mov rsi, person  ; load address of person into RSI
mov rax, 0       ; nullptr
mov NAME[rsi], rax
mov ADDRESS[rsi], rax
mov PHONE[rsi], rax
```

Another use of this addressing mode is for stack frames for a language such as "C", especially for calling subroutines.  A subroutine may have arguments passed to it on the stack, by value (like an int) or reference (like an address of a struct or string or whatever).  A subroutine may need its own local variables.  When a subroutine is called recursively, each recursive call must prepare the stack so it has arguments to pass, and allow for the next iteration's local variables on the stack.

The RBP register is used for stack frames when stack conventions are used for calling functions in "C".  

The calling function pushes arguments on the stack (right to left).  That is, for foo(a, b, c);, the compiler will generate code to push c, then b, then a.

Upon entry to a function, RBP contains the stack frame pointer for the calling function.  The compiler generates code to immediately push it.  Then the RSP stack pointer is loaded into RBP.  

At this point,  RBP points to the return address on the stack, and negative offsets from RBP are the arguments to the function.  

For local variables, the compiler generates a subtract to RSP to make the desired space on the stack.  When the function calls another, RSP is after the allocated variables, so it all works.  Positive offsets from RBP are used to access the local variables.

To return, the compiler generates code to pop rbp (restore caller's stack frame) and returns.  The calling code has to adjust RSP to remove the pushed arguments.

Let's see a little bit of example code and the assembly generated by the compiler.  Note that this is in AT&T syntax, ```source, destination``` format.  The register names are prefixed with %.

```
// source
void bar(int a, int b) {
    int x, y;

    x = 555;
    y = a+b;
}

void foo(void) {
    bar(111,222);
}

; compiles to:
bar:
    pushl   %ebp
    movl    %esp, %ebp
    subl    $16, %esp
    movl    $555, -4(%ebp)
    movl    12(%ebp), %eax
    movl    8(%ebp), %edx
    addl    %edx, %eax
    movl    %eax, -8(%ebp)
    leave
    ret

foo:
    pushl   %ebp
    movl    %esp, %ebp
    subl    $8, %esp
    movl    $222, 4(%esp)
    movl    $111, (%esp)
    call    bar
    leave
    ret
```

Note the use of indirect with offset addressing modes!

#### indirect with displacement and scaled index

This addressing mode is used to access array elements.  To illustrate how this mode works:

* an array of bytes, each element is 1 byte each
* an array of words, each element is 2 bytes each
* an array of dwords, each element is 4 bytes each
* an array of qwords, each element is 8 bytes each

As you index the array, you have to "scale" the index before adding it to the base of the array.  The scale operating assures we are addressing byte, word, dword, or qword elements properly.  

```
        mov member(rsi, rbx, 4), eax   ; store dword in eax at rsi+ member(offset) + rbx x 4
```
The above example stores a dword into memory.  We are accessing a struct member that is an array of dwords.  The rbx register contains the index into the array, [0 ... array.length-1].  The 4 is the scale factor, or size of the dword.  

Note that member may be 0 - in this case, rsi simply contains the address of the array.



# Commonly Used Instructions

## Aritmetic

ADC - add a value, plus 
ADD - add two registers together
DEC - decrement by 1
DIV - unsigned divide
IDIV - signed divide
IMUL - signed multiply
INC - increment by 1
MUL - unsigned multiply
NEG - two's complement (multiply by -1)
SBB - subtract with borrow (carry flag)
SUB - subtract
LEA - load effective address (formed by some expression / addressing mode) into register

## Boolean Algebra
AND - logical AND to registers together
NOT - one's complement (invert all the bits in the operand)
OR - logical OR
XOR - logical exclusive or
TEST - logical compare

## Branching and Subroutines
CALL - call a subroutine/function/procedure
SYSCALL - call an OS function (Linux, Mac)
ENTER - make stack from for procedure parameters
LEAVE - high level procedure exit
RET - return from subroutine
CMP - compare two operaands
JA - jump if result of unsigned compare is above
JAE - jump if result of unsigned compare is above or equal
JB - jump if result of unsigned compare is below
JBE - jump if result of unsigned compare is below or equal
JC - jump if carry flag is set
JE - jump if equal
JG - jump if greater than 
JGE - jump if greater than or equal
JNC - jump if carry not set
JMP - go to / jmp (simply loads the RPC register with the address)

## Bit manipulation
BT - bit test (test a bit)
BTC - bit test and complement
BTR - bit test and reset
BTS - bit test and set
RCL - rotate 9 bits (carry flag, 8 bits in operand) left count bits
RCR - rotate 9 bits (carry flag, 8 bits in operand) right count bits
ROL - rotate 8 bits in operand left count bits
ROR - rotate 8 bits in operand right count bits
SAL - arithmetic shift operand left count bits
SAR - arithmetic shift operand right count bits (maintains sign bit)
SHL - logical shift operand left count bits (same as SAL)
SHR - logical shift operand right count bits (does not maintain sign bit)

## Register manipulation, Casting/Conversions
MOV - move register to register, move register to memory, move memory to register
XCHG - exchange register/memory with register
CBW - convert byte to word
CDQ - convert word to double word/convert double word to quad word

## Flags manipulation
CLC - clear carry flag/bit in flags register
CLD - clear direction bit in flags register
STC - set carry flag
STD - set direction flag

## Stack manipulation
POP - pop a register off the stack
POPF - pop stack into flags register
PUSH - push a register on the stack
PUSHF - push flags register on the stack

# Hello, World

## MacOS Version

See hello-world/ directory for a build script and this assembly source.

```
; Use the build-macos.sh script to assemble and link this.

global start


section .text

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
```

It works.  Here's the output:

```
# ./build-mac.sh
Run it via ./hello-macos
# ./hello-macos
Hello, World!
#
```

## Linux version

Linux has different (from MacOS) syscall numbers passed in rax.  The entry point for Linux programs is "_start"" vs "start" on MacOS.

Otherwise, the program is the same.

```
; use the build-linux.sh script to assemble and link this

        global _start
section .text

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
```

```
# ./build-linux.sh
Run it via ./hello-linux
i# ./hello-linux
Hello, world!
#
```

## How it works

MacOS and Linux provide quite a few syscalls each, or operating system calls that we can call from any language.  There are quite a few syscalls in common between the two, but they are different flavors of Unix (linux vs. BSD-ish/MacOS).  The two flavors have several syscalls that are provided in one OS but not the other.  The syscall numbers (passed in rax) are also different between the operating systems.

The C libraries contain code similar to our code above, to write strings to a file.  For our purposes we use the file number for stdout to write to he console.

For most C calls that are not provided by a library or the standard C/C++ libraries, there is a syscall.  For example, malloc and free are provided by libc so there is no syscall for it.  However, sbrk() is not provided by the libraries and is provided as a syscall.

The syscalls take arguments in the CPU registers.  RAX contains the syscall number (one for write, one for exit in the above).

### Linux Syscalls

Linux syscalls are documented here:
    https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md
The syscalls for Linux are defined in:
    /usr/include/sys/syscall.h

### MacOS Syscalls

The syscalls for MacOS are defined in:
    ./Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/sys/syscall.h
