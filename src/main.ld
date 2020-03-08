OUTPUT_FORMAT("elf32-tradlittlemips")
OUTPUT_ARCH(mips)

ENTRY(start)
SECTIONS {
   . = 0x80010000;
   .text : { *(.text) }
   . = 0x80080000;
   .data : { *(.data) }
   .bss : { *(.bss) }
}
