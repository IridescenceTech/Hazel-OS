ENTRY(_kstart)

SECTIONS {
	. = 1M;

	/* Dedicated boot section, comprised of the multiboot header. */	
	.boot : {
		*(.mboot_header)
	}
	
	/* Aligned blocks for code */
	.text BLOCK(4K) : ALIGN(4K) {
		__TEXT_START = .;
		*(.text)
		__TEXT_END = .;
	}

	/* Aligned blocks for data */
	.data BLOCK(4K) : ALIGN (4K) {
		__DATA_START = .;
		*(.text)
		__DATA_END = .;
	}

	/* Aligned blocks for stack */
	.bss BLOCK(4K) : ALIGN (4K) {
		*(.bss)
	}

	. = ALIGN(4K);
	__KERNEL_END = .;
}
