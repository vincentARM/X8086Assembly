SECTIONS
{
. = 0x80000;
.text : { *(.text) }
.data : { *(.data) }
.bss : { *(.bss) }
	/DISCARD/ : {
		*(*)
	}
}