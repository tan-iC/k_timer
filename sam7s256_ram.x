MEMORY
{
  VECT(r)   : org = 0x00000000, len = 0x3c
  RAM(rwx)  : org = 0x00000040, len = 64k-0x3c
  STACK(rw) : org = 0x00010000, len = 0x00000000
}

SECTIONS
{
  .vectors : {
    *(.vectors)
  } > VECT

  .text : {
    CREATE_OBJECT_SYMBOLS
    *(.text)
    *(.glue_7t)
    *(.glue_7)
    etext = .;
  }  > RAM

  .init : {
    *(.init)
  } > RAM

  . = ALIGN(4);

  .rodata : {
    *(.rodata)
    *(.rodata*)
  } > RAM

  . = ALIGN(4);

  .ctors : {
    PROVIDE(__ctors_start__ = .);
    KEEP(*(SORT(.ctors.*)))
    KEEP(*(.ctors))
    PROVIDE(__ctors_end__ = .);
  } >RAM

  .dtors : {
    PROVIDE(__dtors_start__ = .); 
    KEEP(*(SORT(.dtors.*)))
    KEEP(*(.dtors))
    PROVIDE(__dtors_end__ = .);
  } >RAM
  
  . = ALIGN(4);

  _etext = . ;
  PROVIDE (etext = .);

  /* .data section which is used for initialized data */

  .data : AT (_etext) {
    _data = . ;
    *(.data)
    *(.ramfunc)

    CONSTRUCTORS
/*
    SORT(CONSTRUCTORS)
*/
  } > RAM
  . = ALIGN(4);

  _edata = . ;
   PROVIDE (edata = .);

  /* .bss section which is used for uninitialized data */

  .bss : {
    __bss_start = . ;
    __bss_start__ = . ;
    *(.bss)
    *(COMMON)
  }
  . = ALIGN(4);
  __bss_end__ = . ;
  __bss_end__ = . ;
  _end = .;

  . = ALIGN(4);

  .int_data : {
    *(.internal_ram_top) 
  } > STACK

  PROVIDE (end = .);

  /* Stabs debugging sections.  */
  .stab          0 : { *(.stab) }
  .stabstr       0 : { *(.stabstr) }
  .stab.excl     0 : { *(.stab.excl) }
  .stab.exclstr  0 : { *(.stab.exclstr) }
  .stab.index    0 : { *(.stab.index) }
  .stab.indexstr 0 : { *(.stab.indexstr) }
  .comment       0 : { *(.comment) }
  /* DWARF debug sections.
     Symbols in the DWARF debugging sections are relative to the beginning
     of the section so we begin them at 0.  */
  /* DWARF 1 */
  .debug          0 : { *(.debug) }
  .line           0 : { *(.line) }
  /* GNU DWARF 1 extensions */
  .debug_srcinfo  0 : { *(.debug_srcinfo) }
  .debug_sfnames  0 : { *(.debug_sfnames) }
  /* DWARF 1.1 and DWARF 2 */
  .debug_aranges  0 : { *(.debug_aranges) }
  .debug_pubnames 0 : { *(.debug_pubnames) }
  /* DWARF 2 */
  .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
  .debug_abbrev   0 : { *(.debug_abbrev) }
  .debug_line     0 : { *(.debug_line) }
  .debug_frame    0 : { *(.debug_frame) }
  .debug_str      0 : { *(.debug_str) }
  .debug_loc      0 : { *(.debug_loc) }
  .debug_macinfo  0 : { *(.debug_macinfo) }
  /* SGI/MIPS DWARF 2 extensions */
  .debug_weaknames 0 : { *(.debug_weaknames) }
  .debug_funcnames 0 : { *(.debug_funcnames) }
  .debug_typenames 0 : { *(.debug_typenames) }
  .debug_varnames  0 : { *(.debug_varnames) }
}
