global _lkStart
extern kInit

section .text
bits 64
_lkStart:
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

	push rbx	; Push the multiboot header address
	call kInit	; Call kernel initialization

    cli
    hlt