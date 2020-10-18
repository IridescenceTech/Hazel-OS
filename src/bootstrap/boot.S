global _kstart
global kCrash

section .text
bits 32

extern kInit

_kstart:
	cli
	mov esp, stack_top

	push ebx	
	push eax
	call kInit

	hlt

kCrash:
	cli
	hlt

section .bss
stack_bot:
	resb 16384
stack_top:
