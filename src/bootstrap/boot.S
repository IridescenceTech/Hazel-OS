global _kstart ; This is the program entrypoint

section .text
bits 32 ;For now, we are in 32 bit mode.

extern kInit ;This function is our Zig Kernel entrypoint

_kstart: ;Entrypoint
	cli	;Clear interrupts
	mov esp, stack_top ;Give ourselves a 16KiB stack

	push ebx	; Push the multiboot header address
	push eax	; Push the multiboot magic number
	call kInit	; Call kernel initialization

	cli
	hlt	;Halt if we get here


section .bss
stack_bot: ;Set up our 16KiB stack
	resb 16384
stack_top:
