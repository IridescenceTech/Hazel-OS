section .mboot_header
header_start:
	dd 0xe85250d6	; Magic
	dd 0		; Arch
	dd header_end - header_start ; Length

	; Checksum
	dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

	; More Tags Here

header_end_tag:
	dw 0    ; Type
	dw 0    ; Flags
	dd 8    ; Size
header_end:
