; This is a stub file to jump into the 64-bit Zig Kernel
global _lkStart ; We need to declare our Long Kernel Start functions
extern kInit ; This is the 64-bit Zig Kernel start

; Set up for 64 bit code
section .text
bits 64

_lkStart:

    ; Clear the segment registers
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

	push rbx	; Push the multiboot header address
	call kInit	; Call kernel initialization

    ; If we reach here, we halt
    cli
    hlt