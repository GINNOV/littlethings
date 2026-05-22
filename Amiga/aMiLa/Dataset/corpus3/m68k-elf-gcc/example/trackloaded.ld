STARTUP(crt0.o)
ENTRY(start)
OUTPUT_ARCH(m68k)
SEARCH_DIR(.)
__DYNAMIC  =  0;

/*
 * Setup the memory map of the M68332BCC Business Card Computer.
 * stack grows down from high memory.
 *
 * The memory map look like this:
 * +--------------------+ <- low memory
 * | .text              |
 * |        _etext      |
 * |        ctor list   | the ctor and dtor lists are for
 * |        dtor list   | C++ support
 * +--------------------+
 * | .data              | initialized data goes here
 * |        _edata      |
 * +--------------------+
 * | .bss               |
 * |        __bss_start | start of bss, cleared by crt0
 * |        _end        | start of heap, used by sbrk()
 * +--------------------+
 * .                    .
 * .                    .
 * .                    .
 * |        __stack     | top of stack
 * +--------------------+
 */
MEMORY
{
  reserved			: ORIGIN =     0x0, LENGTH = 0x5000
  ramApp (rwx)		: ORIGIN = 0x05000, LENGTH = 0x70B40
  ramStack (rwx)	: ORIGIN = 0x7FB40, LENGTH = 0x4C0
  ramUpperChip (rw)	: ORIGIN = 0x80000, LENGTH = 0x556E8
}

/*
 * allocate the stack to be at the top of memory, since the stack
 * grows down
 */

PROVIDE (__stack = 0x07FF00);

/*
 * Initalize some symbols to be zero so we can reference them in the
 * crt0 without core dumping. These functions are all optional, but
 * we do this so we can have our crt0 always use them if they exist. 
 * This is so BSPs work better when using the crt0 installed with gcc.
 * We have to initalize them twice, so we cover a.out (which prepends
 * an underscore) and coff object file formats.
 */
PROVIDE (hardware_init_hook = 0);
PROVIDE (_hardware_init_hook = 0);
PROVIDE (software_init_hook = 0);
PROVIDE (_software_init_hook = 0);
/*
 * stick everything in ram (of course)
 */
 
/* https://gcc.gnu.org/ml/gcc-help/2010-12/msg00177.html
*/
SECTIONS
{
  /DISCARD/ :
  {
  
  	*/libgcc.a:unwind-dw2.o
  
  }
  .text :
  {
  	*(.text.*_start)
  	*(.text.*start)
    *(.text .text.*)
    . = ALIGN(0x4);
     __CTOR_LIST__ = .;
    ___CTOR_LIST__ = .;
    LONG((__CTOR_END__ - __CTOR_LIST__) / 4 - 2)
    KEEP(*(.ctors))
    LONG(0)
    __CTOR_END__ = .;
    __DTOR_LIST__ = .;
   ___DTOR_LIST__ = .;
    LONG((__DTOR_END__ - __DTOR_LIST__) / 4 - 2)
    KEEP(*(.dtors))
     LONG(0)
    __DTOR_END__ = .;
    *(.rodata .rodata.*)
    *(.gcc_except_table.*)
    *(.eh_frame)
     
    . = ALIGN(0x2);
    __INIT_SECTION__ = . ;
    LONG (0x4e560000)	/* linkw %fp,#0 */
    KEEP(*(.init))
    SHORT (0x4e5e)	/* unlk %fp */
    SHORT (0x4e75)	/* rts */

    __FINI_SECTION__ = . ;
    LONG (0x4e560000)	/* linkw %fp,#0 */
    KEEP(*(.fini))
    SHORT (0x4e5e)	/* unlk %fp */
    SHORT (0x4e75)	/* rts */

    _etext = .;
    *(.lit)
  } > ramApp

  .data :
  {
    *(.got.plt) *(.got)
    *(.shdata)
    *(.data .data.*)

    

    _edata = .;
  } > ramApp
  
  .bss :
  {
    . = ALIGN(0x4);
    __bss_start = . ;
    *(.shbss)
    *(.bss .bss.*)
    *(COMMON)
    _end =  ALIGN (0x8);
    __end = _end;
  } > ramApp

  .stab 0 (NOLOAD) :
  {
    *(.stab)
  }

  .stabstr 0 (NOLOAD) :
  {
    *(.stabstr)
  }
  
  .ramStack :
  {
  	stack_start = . ;
  	stack_userend = __stack;
  	stack_end = stack_start + 0x4C0 ;
  } > ramStack

}
