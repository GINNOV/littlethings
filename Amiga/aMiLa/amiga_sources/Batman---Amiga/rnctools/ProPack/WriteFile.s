;script assemble
;work:programming/languages/devpac/genam >ram:errors.txt ram:test.s
;script after
;copy ram:test "source:propack/WriteFile"
;copy ram:test "work:c/WriteFile"
;script end

****************************************************************************
*                                                                          *
*                             Write File V1.0                              *
*                    Copyright 1992 by Scott Johnston                      *
*                      All rights reserved worldwide                       *
*                                                                          *
****************************************************************************

;		opt	o+,ow-,d+,LINE		;development options
		opt	o+,ow-			;distribution options

		output	ram:test

;INCLUDE_TOOLS		equ	0
INTUI_V36_NAMES_ONLY	equ	0

		incdir	include_i:
		include	exec/types.i
		include	hardware/intbits.i
		include	hardware/custom.i
		include	hardware/cia.i
		include	exec/interrupts.i
		include	exec/exec_lib.i
		include	exec/execbase.i
		include	exec/memory.i
		include	exec/nodes.i
		include	workbench/startup.i
		include	graphics/graphics_lib.i
		include	graphics/gfx.i
		include	graphics/gfxbase.i
		include	intuition/screens.i
		include	intuition/intuition_lib.i
		include	intuition/intuition.i
		include	resources/misc.i
		include	resources/potgo_lib.i
		include	resources/cia_lib.i
		include	resources/disk_lib.i
		include	dos/dos_lib.i
		include	dos/dos.i
		include	dos/dosextens.i

WRITEINFO	MACRO

		move.l	\3,d0
		beq.s	.unknown\@
		lea	.value\@+4(pc),a0
		bsr	long_to_string
.unknown\@
		move.l	#.text\@,d2
		jsr	_STOutput
		tst.l	d0
		beq.s	.cont\@
		moveq.l	#17,d0				;error number 17
		bra	.error

.text\@		dc.b    \1
.value\@	dc.b	" = $",\2,0
		even
.cont\@
		ENDM

****************************************************************************
****************************************************************************
****************************************************************************

		section	Takeover,code_c

main_program
		lea	parameters,a5
		jsr	_STInitialise

		jsr	_STOpenLibraries
		tst.l	d0
		bne	.error

		jsr	_STOpenStdout
		tst.l	d0
		bne	.error

		jsr	_STParseArgs
		tst.l	d0
		bne	.error

		jsr	_STFileInfo
		tst.l	d0
		bne	.error

		move.l	fib_Size+code_fib(a5),public_chunk_max_amount(a5)
		move.l	fib_Size+code_fib(a5),public_chunk_min_amount(a5)
		jsr	_STAllocateResources
		tst.l	d0
		bne	.error

		tst.b	arg_info(a5)
		beq.s	.no_info
		jsr	_STInfo
		tst.l	d0
		bne	.error
		bra	.exit
.no_info
		lea	code_filename(a5),a0
		move.l	public_chunk_address(a5),a1
		move.l	fib_Size+code_fib(a5),d3
		jsr	_STLoadFile
		tst.l	d0
		bne.s	.error

		jsr	_STDisable

		moveq.l	#1,d0				;save file
		move.l	fib_Size+code_fib(a5),d1
		lea	code_output_filename(a5),a0
		move.l	public_chunk_address(a5),a1
		move.l	chip_chunk_address(a5),a2
		jsr	_STDosIO

		jsr	_STEnable

		tst.l	d0
		beq.s	.ok
		move.l	#14,d0				;error number 14
		bra.s	.error
.ok
		jsr	_STEnable

		tst.l	d0
		beq.s	.exit
.error		jsr	_STOutputError
.exit		jsr	_STDeallocateResources
		jsr	_STCloseConsole
		jsr	_STCloseLibraries
		moveq.l	#0,d0
		rts

****************************************************************************
****************************************************************************
****************************************************************************

		dc.b	"$VER: WriteFile V1.0",$a,$d,0
		even

MAX_ERROR_CODES	equ     41
NAME_SIZE	equ	160
TITLE_SIZE	equ	16
EOL		equ	10

ITEXT           MACRO
		dc.b	AUTOFRONTPEN		;front pen
                dc.b	AUTOBACKPEN		;back pen
		dc.b	AUTODRAWMODE		;draw mode
		dc.b	0			;pad
		dc.w	AUTOLEFTEDGE+\1		;left edge
		dc.w	AUTOTOPEDGE+\2		;top edge
		dc.l	AUTOITEXTFONT		;font
		dc.l    .message\@		;text
		dc.l	\4			;next itext
.message\@	dc.b	\3,0
		even
                ENDM

;initialised by user !!! Must be longword aligned !!!

 STRUCTURE	SystemTakeoverBase,0
	STRUCT	code_title,TITLE_SIZE	;title of program

	ULONG	chip_chunk_min_amount	;required minimum chip mem (bytes)
	ULONG	public_chunk_min_amount	;required minimum public mem (bytes)
	ULONG	chip_chunk_max_amount	;required maximum chip mem (bytes)
	ULONG	public_chunk_max_amount	;required maximum public mem (bytes)
	ULONG	temp_chunk_amount	;required temp chip mem (bytes)
	APTR	lvl2_server		;vector to user lvl2 routine
	APTR	lvl3_server		;vector to user lvl3 routine
	APTR	lvl6_server		;vector to user lvl6 routine

	UBYTE	code_load_dest		;chunk to load code to
	UBYTE	code_unpack_dest	;chunk to unpack code to
	UBYTE	code_reloc_dest		;chunk to relocate code to

DEST_CHIP		equ     0
DEST_PUBLIC		equ     1

	UBYTE	resources_to_allocate	;resource flags

FLAGF_SERIAL		equ	1<<0
FLAGF_PARALLEL		equ	1<<1
FLAGF_POTGO		equ	1<<2
FLAGF_CLOSE_WBENCH	equ	1<<3

FLAGB_SERIAL		equ     0
FLAGB_PARALLEL		equ     1
FLAGB_POTGO		equ     2
FLAGB_CLOSE_WBENCH	equ	3

	APTR	graphics_base		;graphics.library base
	APTR	intuition_base		;intuition.library base
	APTR	dos_base		;dos.library base
	APTR	misc_base		;misc.resource base
	APTR	potgo_base		;potgo.resource base
	APTR	disk_base		;disk.resource base
	APTR	hardware_base		;address of hardware registers

HARDWARE_BASE		equ	$dff000

	ULONG	chip_amount_allocated	;size of chip chunk allocated
	ULONG	public_amount_allocated	;size of public chunk allocated
	ULONG	largest_chip		;largest free chip chunk
	ULONG	largest_public		;largest free public chunk
	APTR	chip_chunk_address	;address of chip chunk
	APTR	public_chunk_address	;address of public chunk
	APTR	temp_chunk_address	;address of temp chunk
	APTR	chip_mem_address	;address of chip memory
	APTR	public_mem_address	;address of public memory
	APTR	screen_bitmaps		;address of screen bitmaps
	APTR	screen1_struct		;address of screen 1 struct
	APTR	screen2_struct		;address of screen 2 struct
	ULONG	stdout_handle		;handle for stdout
	ULONG	console_handle		;handle for console
	APTR	wbench_message		;address of wbench message
	APTR	arg_address		;address of cli arguments
	UWORD	arg_length		;length of cli arguments
	UBYTE	arg_info		;flag info required
	UBYTE	arg_relocate		;flag relocate code file
	STRUCT	code_filename,NAME_SIZE	;code filename
	STRUCT	code_output_filename,NAME_SIZE	;code filename
	APTR	code_load_address	;address to load code to
	APTR	code_unpack_address	;address to unpack code to
	APTR	code_reloc_address	;address to relocate code to
	APTR	code_address		;current address of code
	ULONG	code_size		;size of unpacked code file
	ULONG	code_lock		;lock on code file
	STRUCT	code_fib,fib_SIZEOF	;code file info block
	UBYTE	disk_units_req		;disk units required
	UBYTE	disk_units		;disk units allocated
	UBYTE	mem_alloc_failed	;flag memory allocation failed
	UBYTE	arg_unpack		;size of unpack buffer
	UBYTE	serial_port		;flag serial port opened
	UBYTE	serial_bits		;flag serial port allocated
	UBYTE	parallel_port		;flag parallel port opened
	UBYTE	parallel_bits		;flag parallel port allocated
	ULONG	potgo_bits		;parallel port bits allocated

POTGO_BITS	equ	%1111000000000001

	UBYTE	lvl2_flag		;flag lvl2 server in list
	UBYTE	lvl3_flag		;flag lvl3 server in list
	UBYTE	lvl6_flag		;flag lvl6 server in list
	UBYTE	arg_quiet		;flag quiet required
 LABEL	stb_SIZEOF

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;		a0.l=address of CLI command line arguments
;		d0.w=number of command line arguments
;OUTPUT:	none
;CHANGES:	none

_STInitialise
		movem.l	d0-d7/a0-a6,-(sp)

		move.l	#HARDWARE_BASE,hardware_base(a5)

		move.l	a0,arg_address(a5)
		move.w	d0,arg_length(a5)
		bne.s	.cli

		move.l	a5,-(sp)
		suba.l	a1,a1			;find this task
		move.l	4.w,a6
		jsr	_LVOFindTask(a6)
		move.l	(sp)+,a5

		move.l	d0,a0
		lea	pr_MsgPort(a0),a0

		move.l	a5,-(sp)
		move.l	4.w,a6
		jsr	_LVOWaitPort(a6)	;wait for workbench message
		move.l	(sp)+,a5

		move.l	a5,-(sp)
		move.l	4.w,a6
		jsr	_LVOGetMsg(a6)		;get workbench message
		move.l	(sp)+,a5

		move.l	d0,wbench_message(a5)

.cli		movem.l	(sp)+,d0-d7/a0-a6
		rts

****************************************************************************
************************** Allocate System Resources ***********************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:	none

_STAllocateResources
		movem.l	d1-d7/a0-a6,-(sp)

		btst.b	#FLAGB_CLOSE_WBENCH,resources_to_allocate(a5)
		beq.s	.dont_close_wbench
		move.l	a5,-(sp)
		move.l	intuition_base(a5),a6	;close workbench
		jsr	_LVOCloseWorkBench(a6)
		move.l	(sp)+,a5
.dont_close_wbench

		bsr	allocate_resources
		tst.l	d0
		bne	.error

		bsr	allocate_memory
		tst.l	d0
		bne	.error

		moveq.l	#0,d0			;no errors
.error		movem.l	(sp)+,d1-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	none
;CHANGES:	none

_STDeallocateResources
		movem.l	d0-d7/a0-a6,-(sp)

		bsr	deallocate_resources
		bsr	deallocate_memory

		btst.b	#FLAGB_CLOSE_WBENCH,resources_to_allocate(a5)
		beq.s	.dont_open_wbench
		move.l	a5,-(sp)
		move.l	intuition_base(a5),a6	;open workbench
		jsr	_LVOOpenWorkBench(a6)
		move.l	(sp)+,a5
.dont_open_wbench

		movem.l	(sp)+,d0-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;		a0.l=address of filename
;		a1.l=destination address
;		d3.l=length to read (bytes)
;OUTPUT:	d0.l=error code (0=no error)
;		d1.l=number of bytes read
;CHANGES:	none

_STLoadFile
		movem.l	d2-d7/a0-a6,-(sp)

		movem.l	a1-a5/d3,-(sp)
		move.l	a0,d1			;filename
		move.l	#MODE_OLDFILE,d2        ;mode
		move.l	dos_base(a5),a6
		jsr	_LVOOpen(a6)		;open file
		movem.l	(sp)+,a1-a5/d3
		move.l	d0,d2			;handle

		tst.l	d2
		bne.s	.open_ok
		moveq.l	#33,d0			;error number 33
		bra.s	.error
.open_ok

		movem.l	d2/a5,-(sp)
		move.l	d2,d1			;handle
		move.l	a1,d2			;destination buffer
		move.l	dos_base(a5),a6
		jsr	_LVORead(a6)		;read file
		movem.l	(sp)+,d2/a5
		move.l	d0,d1			;amount read

		tst.l	d1
		bpl.s	.read_ok
		move.l	d1,-(sp)
		move.l	d2,d1			;handle
		move.l	dos_base(a5),a6
		jsr	_LVOClose(a6)		;close file
		move.l	(sp)+,d1
		moveq.l	#33,d0			;error number 33
		bra.s	.error
.read_ok

		move.l	d1,-(sp)
		move.l	d2,d1			;handle
		move.l	dos_base(a5),a6
		jsr	_LVOClose(a6)		;close file
		move.l	(sp)+,d1

		moveq.l	#0,d0
.error		movem.l	(sp)+,d2-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:	none

_STFileInfo
		movem.l	d1-d7/a0-a6,-(sp)

		movem.l	a1-a5/d3,-(sp)
		lea	code_filename(a5),a1
		move.l	a1,d1			;filename
		move.l	#ACCESS_READ,d2		;mode
		move.l	dos_base(a5),a6
		jsr	_LVOLock(a6)		;lock file
		movem.l	(sp)+,a1-a5/d3
		move.l	d0,code_lock(a5)	;handle
		tst.l	d0
		bne.s	.lock_ok
		moveq.l	#20,d0			;error number 20
		bra.s	.error
.lock_ok

		movem.l	a5,-(sp)
		move.l	code_lock(a5),d1	;lock
		lea	code_fib(a5),a1
		move.l	a1,d2			;file info block
		move.l	dos_base(a5),a6
		jsr	_LVOExamine(a6)		;examine file
		movem.l	(sp)+,a5
		tst.l	d0
		bne.s	.examine_ok
		moveq.l	#32,d0			;error number 32
		bra.s	.error
.examine_ok

		tst.l	fib_DirEntryType+code_fib(a5)
		bmi.s	.file_entry
		moveq.l	#19,d0			;error number 19
		bra.s	.error
.file_entry

		moveq.l	#0,d0
.error
		move.l	d0,-(sp)
		move.l	code_lock(a5),d1	;lock
		move.l	dos_base(a5),a6
		jsr	_LVOUnLock(a6)		;unlock file
		move.l	(sp)+,d0

		movem.l	(sp)+,d1-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;		d0.l=error code
;OUTPUT:	none
;CHANGES:	none

_STOutputError
		movem.l	d0-d7/a0-a6,-(sp)

		cmpi.l	#-1,d0			;abort or error?
		beq.s	.end

		move.l	d0,d1			;get handle to error message
		jsr	_STWhy
		tst.l	d0
		bne.s	.alert

		tst.w	arg_length(a5)
		bne.s	.not_wbench

		jsr	_STBeep			;beep & flash screen
		move.l	a0,a1			;display error message
		jsr	_STSimpleAutoRequest	; from requestor if started
		tst.l	d0			; from workbench
		bne.s	.alert
		bra.s	.skip_cli
.not_wbench	move.l	a0,d2			;output error message on
		jsr	_STOutput		; cli if started from cli
		tst.l	d0
		bne.s	.alert
.skip_cli

.end		movem.l	(sp)+,d0-d7/a0-a6
		rts

;Serious error! Message displayed in alert box
;Enter with error code in d0

.alert		jsr	_STAlert		;alert error message

		movem.l	(sp)+,d0-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	none
;CHANGES:	none
_STForbid
		movem.l	d0-d7/a0-a6,-(sp)

		move.l  a5,-(sp)
		move.l	graphics_base(a5),a6	;own blitter
		jsr	_LVOOwnBlitter(a6)
		move.l  (sp)+,a5

		move.l	4.w,a6			;disable task switching
		jsr	_LVOForbid(a6)

		movem.l	(sp)+,d0-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	none
;CHANGES:	none

_STPermit
		movem.l	d0-d7/a0-a6,-(sp)

		move.l  a5,-(sp)
		move.l	4.w,a6			;enable task switching
		jsr	_LVOPermit(a6)
		move.l  (sp)+,a5

		move.l	graphics_base(a5),a6	;disown blitter
		jsr	_LVODisownBlitter(a6)

		movem.l	(sp)+,d0-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	none
;CHANGES:	none

_STDisable
		movem.l	d0-d7/a0-a6,-(sp)

		move.l	4.w,a6			;disable interrupts
		jsr	_LVODisable(a6)

		movem.l	(sp)+,d0-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	none
;CHANGES:	none

_STEnable
		movem.l	d0-d7/a0-a6,-(sp)

		move.l  a5,-(sp)
		move.l	4.w,a6			;enable interrupts
		jsr	_LVOEnable(a6)
		move.l  (sp)+,a5

		movem.l	(sp)+,d0-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block (long)
;OUTPUT:	none
;CHANGES:	none

_STBeep
		movem.l	d0-d7/a0-a6,-(sp)

		move.l	intuition_base(a5),a6
                suba.l	a0,a0
		jsr	_LVODisplayBeep(a6)

		movem.l	(sp)+,d0-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;		d2.l=address of string
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:	none

WRITELN		MACRO
		move.l	#.text\@,d2
		jsr	_STOutput
		tst.l	d0
		bne	.error
		bra.s	.cont\@
.text\@		dc.b	\1,0
		even
.cont\@
		ENDM

_STOutput
		movem.l	d1-d7/a0-a6,-(sp)

		tst.b	arg_quiet(a5)
		bne.s	.no_output

		move.l	d2,a0
		moveq.l	#0,d3			;calculate length of string
.loop		tst.b	(a0)+
		beq.s	.end_string
		addq.l	#1,d3
		bra.s	.loop
.end_string
		tst.w	d3
		bne.s	.string_ok
		moveq.l	#15,d0			;error number 15
		bra.s	.error
.string_ok
		move.l	stdout_handle(a5),d1
		beq.s	.no_output
		move.l	dos_base(a5),a6
		move.l	a5,-(sp)
		jsr	_LVOWrite(a6)
		move.l	(sp)+,a5

		tst.w	d0
		bpl.s	.write_ok1
		moveq.l	#16,d0			;error number 16
		bra.s	.error
.write_ok1
		move.l	#.cr,d2
		moveq.l	#1,d3
		move.l	stdout_handle(a5),d1
		move.l	dos_base(a5),a6
		jsr	_LVOWrite(a6)

		tst.w	d0
		bpl.s	.write_ok2
		moveq.l	#24,d0			;error number 24
		bra.s	.error

.no_output
.write_ok2	moveq.l	#0,d0			;no errors
.error		movem.l	(sp)+,d1-d7/a0-a6
		rts

.cr		dc.b	$a
		even

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;		a1.l=address of string
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:	none

_STSimpleAutoRequest
		movem.l	d1-d7/a0-a6,-(sp)

		lea	code_title(a5),a0
		move.l	a0,.mesg_head_ptr
		move.l	a1,.mesg_body_ptr

		lea	.itext_header(pc),a1	;body text
		suba.l	a0,a0			;window structure
		suba.l	a2,a2			;positive text
		lea	.itext_button(pc),a3	;negative text
		move.l	#0,d0			;positive flags
		move.l	#0,d1			;negative flags
		move.l	#640,d2			;width
		move.l	#60,d3			;height
		move.l	intuition_base(a5),a6
		jsr	_LVOAutoRequest(a6)

.write_ok	moveq.l	#0,d0			;no errors
.error		movem.l	(sp)+,d1-d7/a0-a6
		rts

.itext_button	dc.b	AUTOFRONTPEN		;front pen
                dc.b	AUTOBACKPEN		;back pen
		dc.b	AUTODRAWMODE		;draw mode
		dc.b	0			;pad
		dc.w	AUTOLEFTEDGE		;left edge
		dc.w	AUTOTOPEDGE		;top edge
		dc.l	AUTOITEXTFONT		;font
                dc.l    .button			;text
		dc.l	AUTONEXTTEXT		;next itext

.button		dc.b	"Abort",0
		even

.itext_header	dc.b	AUTOFRONTPEN		;front pen
                dc.b	AUTOBACKPEN		;back pen
		dc.b	AUTODRAWMODE		;draw mode
		dc.b	0			;pad
		dc.w	AUTOLEFTEDGE		;left edge
		dc.w	AUTOTOPEDGE		;top edge
		dc.l	AUTOITEXTFONT		;font
.mesg_head_ptr	dc.l	0			;text
		dc.l	.itext_body		;next itext
		even

.itext_body	dc.b	AUTOFRONTPEN		;front pen
                dc.b	AUTOBACKPEN		;back pen
		dc.b	AUTODRAWMODE		;draw mode
		dc.b	0			;pad
		dc.w	AUTOLEFTEDGE		;left edge
		dc.w	AUTOTOPEDGE+10		;top edge
		dc.l	AUTOITEXTFONT		;font
.mesg_body_ptr	dc.l    0			;text
		dc.l	AUTONEXTTEXT		;next itext
		even

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;		a1.l=address of itext structure for body
;		a2.l=address of itext structure for positive gadget
;		a3.l=address of itext structure for negative gadget
;		d0.l=width of requester in pixels
;		d1.l=height of requester in pixels
;OUTPUT:	d0.l=error code (0=no error)
;		d1.l= 1=True 0=False
;CHANGES:	none

_STAutoRequest
		movem.l	d2-d7/a0-a6,-(sp)

		suba.l	a0,a0			;window structure
		move.l	d0,d2			;width
		move.l	d1,d3			;height
		move.l	#0,d0			;positive flags
		move.l	#0,d1			;negative flags
		move.l	intuition_base(a5),a6
		jsr	_LVOAutoRequest(a6)

		move.l	d0,d1

.write_ok	moveq.l	#0,d0			;no errors
.error		movem.l	(sp)+,d2-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;		d0.l=alert message code
;OUTPUT:	d0.l=response (1=left button,0=right button)
;CHANGES:	none

_STAlert
		movem.l	d1-d7/a0-a6,-(sp)

		tst.l	d0
		beq.s	.no_error
		bpl.s	.code_above_min
		moveq.l	#25,d0			;error number 25
		bra.s	.code_below_max
.code_above_min	cmpi.l	#MAX_ERROR_CODES,d0
		ble.s	.code_below_max
		moveq.l	#25,d0			;error number 25
.code_below_max
		subq.l	#1,d0
		mulu	#100,d0
		lea	err_mesgs,a0
		lea	0(a0,d0.w),a0

		move.l	#RECOVERY_ALERT,d0
		move.l	#30,d1
		move.l	intuition_base(a5),a6
		jsr	_LVODisplayAlert(a6)

.no_error	movem.l	(sp)+,d1-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;		d1.l=error message code
;OUTPUT:	a0.l=address of error message string
;		d0.l=error code (0=no error)
;CHANGES:	none

ERROR_DEFN	MACRO
		CNOP	0,100
		IFND	err_mesgs
err_mesgs
		ENDC
		dc.b	0,\2,\3
		dc.b	\1,0
		even
		ENDM

_STWhy
		movem.l	d1-d7/a1-a6,-(sp)

		tst.l	d1
		beq.s	.code0
		bpl.s	.code_above_min
.code0		moveq.l	#21,d0			;error number 21
		bra.s	.error
.code_above_min	cmpi.l	#MAX_ERROR_CODES,d0
		ble.s	.code_below_max
		moveq.l	#21,d0			;error number 21
		bra.s	.error
.code_below_max
		subq.l	#1,d0
		mulu	#100,d0
		lea	err_mesgs+3(pc,d0.w),a0

.no_error	moveq.l	#0,d0			;no errors
.error		movem.l	(sp)+,d1-d7/a1-a6
		rts

		ERROR_DEFN <"ERROR #00001 : Could not open graphics.library">,24,17
		ERROR_DEFN <"ERROR #00002 : Could not open intuition.library">,24,17
		ERROR_DEFN <"ERROR #00003 : Could not open stdout">,24,17
		ERROR_DEFN <"ERROR #00004 : Could not open misc.resource">,24,17
		ERROR_DEFN <"ERROR #00005 : Could not allocate serial port bits">,24,17
		ERROR_DEFN <"ERROR #00006 : Could not allocate serial port">,24,17
		ERROR_DEFN <"ERROR #00007 : Could not open disk.resource">,24,17
		ERROR_DEFN <"ERROR #00008 : Could not allocate disk.resource unit">,24,17
		ERROR_DEFN <"ERROR #00009 : Could not open screen buffer 1">,24,17
		ERROR_DEFN <"ERROR #00010 : Could not open screen buffer 1">,24,17
		ERROR_DEFN <"ERROR #00011 : Could not allocate enough chip memory">,24,17
		ERROR_DEFN <"ERROR #00012 : Undefined">,24,17
		ERROR_DEFN <"ERROR #00013 : Could not allocate enough public memory">,24,17
		ERROR_DEFN <"ERROR #00014 : DosIO error">,24,17
		ERROR_DEFN <"ERROR #90015 : _STOutput string empty">,24,17
		ERROR_DEFN <"ERROR #80016 : _STOutput write to console failed (body)">,24,17
		ERROR_DEFN <"ERROR #80017 : _STInfo write to console failed (output info)">,24,17
		ERROR_DEFN <"ERROR #90018 : _STOpenScreen buffer address undefined">,24,17
		ERROR_DEFN <"ERROR #00019 : _STFileInfo lock is not a file">,24,17
		ERROR_DEFN <"ERROR #00020 : _STFileInfo could not get lock on file">,24,17
		ERROR_DEFN <"ERROR #90021 : _STWhy error code out of range">,24,17
		ERROR_DEFN <"ERROR #00022 : _STUnPack error in unpacking">,24,17
		ERROR_DEFN <"ERROR #90023 : _STRequest string empty">,24,17
		ERROR_DEFN <"ERROR #80024 : _STOutput write to console failed (cr)">,24,17
		ERROR_DEFN <"ERROR #90025 : _STAlert error code out of range">,24,17
		ERROR_DEFN <"ERROR #90026 : _STCopyString maximum length exceeded">,24,17
		ERROR_DEFN <"ERROR #00027 : Could not allocate parallel port bits">,24,17
		ERROR_DEFN <"ERROR #00028 : Could not allocate parallel port">,24,17
		ERROR_DEFN <"ERROR #00029 : Could not allocate CIAB timer A ICR bit">,24,17
		ERROR_DEFN <"ERROR #00030 : Could not allocate CIAB timer B ICR bit">,24,17
		ERROR_DEFN <"ERROR #00031 : Could not open output console">,24,17
		ERROR_DEFN <"ERROR #00032 : _STFileInfo examine failed">,24,17
		ERROR_DEFN <"ERROR #00033 : _STLoadFile AmigasDOS IO error">,24,17
		ERROR_DEFN <"ERROR #90034 : (_STRelocate) Missing or illegal relocation hunk">,24,17
		ERROR_DEFN <"ERROR #00035 : Not enough chip memory">,24,17
		ERROR_DEFN <"ERROR #00036 : Not enough expansion memory">,24,17
		ERROR_DEFN <"ERROR #00037 : Not enough memory">,24,17
		ERROR_DEFN <"ERROR #90038 : _STOpenConsole console already open">,24,17
		ERROR_DEFN <"ERROR #90039 : _STOpenStdout stdout already open">,24,17
		ERROR_DEFN <"ERROR #00040 : required parameter missing">,24,17
		ERROR_DEFN <"ERROR #00041 : Not enough temporarymemory">,24,17

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:	none

_STInfo
		movem.l	d1-d7/a0-a6,-(sp)

		tst.l	stdout_handle(a5)
		bne.s   .cli
		jsr	_STOpenConsole
		tst.l	d0
		bne	.error
.cli

		WRITELN <"---MEMORY REQUIRED----------------------------------">
		WRITEINFO <"    Maximum chunk of chip memory">,<"UNKNOWN  (bytes)">,chip_chunk_max_amount(a5)
		WRITEINFO <"  Maximum chunk of public memory">,<"UNKNOWN  (bytes)">,public_chunk_max_amount(a5)
		WRITEINFO <"    Minimum chunk of chip memory">,<"UNKNOWN  (bytes)">,chip_chunk_min_amount(a5)
		WRITEINFO <"  Minimum chunk of public memory">,<"UNKNOWN  (bytes)">,public_chunk_min_amount(a5)
		WRITEINFO <"   Required chunk of temp memory">,<"UNKNOWN  (bytes)">,temp_chunk_amount(a5)

		WRITELN <"---MEMORY ALLOCATED---------------------------------">
		WRITEINFO <"   Chip chunk / memory allocated">,<"UNKNOWN  (bytes)">,chip_amount_allocated(a5)
		WRITEINFO <" Public chunk / memory allocated">,<"UNKNOWN  (bytes)">,public_amount_allocated(a5)
		WRITEINFO <"              Chip chunk address">,<"UNKNOWN ">,chip_chunk_address(a5)
		WRITEINFO <"            Public chunk address">,<"UNKNOWN ">,public_chunk_address(a5)
		WRITEINFO <"             Chip memory address">,<"UNKNOWN ">,chip_mem_address(a5)
		WRITEINFO <"           Public memory address">,<"UNKNOWN ">,public_mem_address(a5)

		WRITELN <"---MEMORY GENERAL INFO------------------------------">
		WRITEINFO <"    Largest chunk of chip memory">,<"UNKNOWN  (bytes)">,largest_chip(a5)
		WRITEINFO <"  Largest chunk of public memory">,<"UNKNOWN  (bytes)">,largest_public(a5)

		WRITELN <"---CODE FILE----------------------------------------">
		WRITEINFO <"                       File size">,<"UNKNOWN  (bytes)">,fib_Size+code_fib(a5)
		WRITEINFO <"                    Load address">,<"UNKNOWN  (bytes)">,code_load_address(a5)
		WRITEINFO <"                  Unpack address">,<"UNKNOWN  (bytes)">,code_unpack_address(a5)
		WRITEINFO <"                Relocate address">,<"UNKNOWN  (bytes)">,code_reloc_address(a5)

		moveq.l	#0,d0			;no errors
.error		movem.l	(sp)+,d1-d7/a0-a6
		rts

****************************************************************************
long_to_string	movem.l	d0-d4/a0-a1,-(sp)

		move.b	#" ",(a0)
		move.b	#" ",1(a0)
		move.b	#" ",2(a0)
		move.b	#" ",3(a0)
		move.b	#" ",4(a0)
		move.b	#" ",5(a0)
		move.b	#" ",6(a0)
		move.b	#" ",7(a0)

		move.l	a0,a1
		move.w	#7,d2
		moveq.l	#0,d4

.loop		rol.l	#4,d0
		move.w	d0,d1
		and.w	#$f,d1
		move.b  hex_digits(pc,d1.w),d3
		tst.w	d4
		bne.s	.do_zeros
		cmpi.b	#"0",d3
		beq.s	.skip_zero
		st.b	d4
.do_zeros	move.b	d3,(a0)+
.skip_zero	dbf	d2,.loop

		movem.l	(sp)+,d0-d4/a0-a1
		rts

hex_digits	dc.b	"0123456789ABCDEF"

****************************************************************************
****************************************************************************
*------------------------------------------------------------------------------
* AmigaDOS File/Disk Functions for AmigaDos disks
*
* Copyright (c) 1988-92 Rob Northen Computing, U.K. All Rights Reserved.
*
* File: DOSio.s
*
* Date: 25.08.91
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* AmigaDOS File/Disk Functions
* on entry,
*	d0.l = function
*		0=load file
*		1=save file
*		2=delete file
*		3=read file/directory names from directory
*		4=format disk
*			to format DF0: a0.l = ptr to "DF0:Volume_Name",0
*			to format DF1: a0.l = ptr to "DF1:Volume_Name",0
*			Note: volume name must be <=30 characters
*	d1.l = length of file in bytes (for save function only)
*	a0.l = full pathname of file, terminated with 0
*	a1.l = file buffer (even word boundary)
*		if d0.l=3 a1.l = ptr to file name buffer
*	a2.l = workspace buffer ($4d00 bytes of CHIPmem required)
* on exit,
*	d0.l = result
*		  0 = no error
*		204 = directory not found
*		205 = file not found
*		221 = disk full
*		225 = not a DOS disk
*		405 = bad block checksum
*		see diskio.s for error codes
*	d1.l = length of file in bytes (for load and save file functions)
*	all others registers are preserved
*
* For the Directory function the output buffer is filled as follows:
*
* offset  field length  field description
*
* $00     1             entry type  (2=dir entry, -3=file entry)
* $01     1             entry name length
* $02     30            entry name
* $20     1             entry type
* $21     1             entry name length
* $22     30            entry name
* etc.
*
* Note: the output buffer must be large enough to hold all file names in the
* directory.
*------------------------------------------------------------------------------

_STDosIO	dc.l $48E7FFFE,$2C002E01,$28482A49,$2C4A6100,$05224A86,$6608614E,$2F410004,$6032BC3C
		dc.l $00016606,$610000E2,$6026BC3C,$00026606,$61000262,$601ABC3C,$0003660A,$61000352
		dc.l $2F410004,$600ABC3C,$00046604,$610003A8,$2E807200,$7400363C,$80006100,$060A4CDF
		dc.l $7FFF4A80,$4E756100,$04226670,$2E280144,$2F0745E8,$01386166,$665E2401,$2801264D
		dc.l $2C07E08E,$E28E6602,$264E6152,$664A5282,$2A016708,$B4816604,$538666EE,$22049484
		dc.l $204B6100,$05C06630,$61000550,$662A2028,$000C9E80,$41E80018,$E4986002,$2AD851C8
		dc.l $FFFC4240,$E5986002,$1AD851C8,$FFFC5382,$66D62205,$200766A2,$221F4A80,$4E752F02
		dc.l $204E2028,$00086610,$222801F8,$67146100,$0506660E,$45E80138,$22227001,$91A80008
		dc.l $7000241F,$4A804E75,$6100018A,$6712B0BC,$000000CD,$6600015E,$61000246,$66000156
		dc.l $610002C2,$70022080,$21470144,$6100024A,$317A04EC,$01F670FD,$214001FC,$70012D40
		dc.l $34FC7C02,$610001A8,$41FA04DC,$30806100,$019E6700,$011A6100,$01E42D46,$35045286
		dc.l $42AE3508,$42AE36F8,$45EE3638,$43EE3700,$61000190,$670000F8,$2A067600,$780BB284
		dc.l $6C022801,$25062006,$610001B2,$52862649,$700822C0,$22EE3504,$22EE34FC,$203C0000
		dc.l $01E8BE80,$6C022007,$9E8022C0,$22C64299,$4A406702,$534012DD,$51C8FFFC,$204B6100
		dc.l $04462140,$00145283,$7001D1AE,$34FCD1AE,$35084A87,$671A7048,$B0AE3508,$6706B883
		dc.l $66A26026,$61000108,$67000084,$2D4636F8,$41EE3500,$20280134,$21400010,$22280004
		dc.l $61000448,$666E7010,$20802007,$67166100,$00DE675A,$B0AE36F8,$660A5286,$610000D0
		dc.l $674C5386,$204B2140,$001042A8,$00146100,$03D62140,$00142205,$240341EE,$37006100
		dc.l $04166630,$4A87670E,$7048B0AE,$35086700,$FEFE6000,$FF18611E,$661A41EE,$3300323A
		dc.l $03C04290,$610003A0,$20806000,$03E8203C,$000000DD,$4E75323A,$03AA41EE,$35006100
		dc.l $03766668,$303A03A0,$363A039A,$21803000,$600003B8,$610001F4,$66522801,$610000C2
		dc.l $664A2004,$612443EE,$0138222E,$00085381,$20216116,$51C9FFFA,$222E01F8,$6798204E
		dc.l $61000334,$66262001,$60DA48E7,$C0005540,$80FC0020,$E5480640,$33042236,$00004840
		dc.l $01C14840,$2D810000,$4CDF0003,$4E752006,$53405240,$B07C06E0,$67066122,$67F42C00
		dc.l $4E757200,$61E86710,$20065241,$5240B07C,$06E06704,$610866F2,$20064A81,$4E7548E7
		dc.l $C0005540,$80FC0020,$E5480640,$33042236,$00004840,$01014CDF,$00034E75,$48E7C000
		dc.l $554080FC,$0020E548,$06403304,$22360000,$48400181,$48402D81,$00004CDF,$00034E75
		dc.l $323A02BE,$41EE3300,$610002F8,$66086100,$02966600,$028A4E75,$43E801B1,$70FF5200
		dc.l $B03C001E,$670412DC,$66F41140,$01B04E75,$610000F8,$664C7800,$7A002236,$40186736
		dc.l $41EE3300,$61000250,$66387002,$B0906626,$70FDB0A8,$01FC6708,$7002B0A8,$01FC6616
		dc.l $1AC043E8,$01B0701E,$1AD951C8,$FFFC5285,$222801F0,$66CA5844,$B87C0120,$66BC2205
		dc.l $70004E75,$41EE3500,$2248303C,$05FF4299,$51C8FFFC,$4E757200,$343C06E0,$76026100
		dc.l $02666600,$008461DC,$70022080,$70482140,$000C70FF,$21400138,$217C0000,$0371013C
		dc.l $6100FF56,$70012140,$01FCDCFC,$04007002,$6100FE98,$5240B07C,$06E066F4,$203C0000
		dc.l $03706100,$FEF85280,$6100FEF2,$9CFC0400,$610001B4,$21400014,$D0FC0200,$610001A8
		dc.l $208090FC,$0200323C,$03707402,$610001E8,$66162248,$303C007F,$22FC444F,$530051C8
		dc.l $FFF87200,$610001CE,$4E752F0C,$204E6100,$013E6600,$009843FA,$01863281,$2E8C6100
		dc.l $00DA6700,$0088E548,$43FA0178,$32C132C0,$22300000,$674E6100,$013E6670,$203C0000
		dc.l $00E17402,$B4906664,$7402BC3C,$00036706,$4A146602,$74FDB4A8,$01FC661E,$43E801B0
		dc.l $45FA0148,$74001419,$53021019,$6178B01A,$56CAFFF8,$66044A12,$6722303C,$01F04AB0
		dc.l $000066A4,$203C0000,$00CCBC3C,$0003671C,$4A146618,$203C0000,$00CD6010,$4A146600
		dc.l $FF7643FA,$010232A8,$01F27000,$285F4A80,$4E75204C,$612EB03C,$00446626,$6126B03C
		dc.l $0046661E,$10180400,$00306D16,$B03C0033,$6E100C18,$003A660A,$41FA00CE,$11400001
		dc.l $584C4E75,$1018B03C,$00616D0A,$B03C007A,$6E040200,$00DF4A00,$4E7548E7,$40C07000
		dc.l $72FF204C,$43FA00A4,$42115281,$4A146708,$0C1C002F,$66F4534C,$4A81672A,$C2FC000D
		dc.l $101861C2,$12C0D240,$02810000,$07FFB9C8,$66EA0C14,$002F6602,$524C4219,$82FC0048
		dc.l $42414841,$5C412001,$4CDF0302,$4E75323C,$03706122,$661E203C,$000000E1,$7402B490
		dc.l $66127401,$B4A801FC,$660A43FA,$003432A8,$013E7000,$4E75616A,$660A610A,$6706203C
		dc.l $00000195,$4E7548E7,$40807000,$323C007F,$D09851C9,$FFFC4480,$4CDF0102,$4E750000
		dc.l $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l $00000000,$00000000,$000042A8,$001461B6,$21400014,$74012F03,$7601610A,$261F4A80
		dc.l $4E757401,$7600224E,$303AFFBE

*------------------------------------------------------------------------------
* Low Level Read/Write/Format Disk Code for Commodore Amiga Dos Disks
*
* (c)1988-92 Rob Northen Computing, U.K. All Rights Reserved.
*
* File: DISKIO.S
*
* Date: 02.07.92
*------------------------------------------------------------------------------


*------------------------------------------------------------------------------
* Low Level Read/Write/Format Disk Code for AmigaDos Disks
* on entry,
*	d0.w = drive number
*		0 = DF0
*		1 = DF1
*		2 = DF2
*		3 = DF3
*		4 = DF0, side 0 only
*		5 = DF1, side 0 only
*		6 = DF2, side 0 only
*		7 = DF3, side 0 only
*	d1.w = start sector no.
*		(0-879 for single sided disk, 0-1759 for double sided disk)
*	d2.w = number of sectors to read/write
*		0 = turn motor off (bit 15 of d3 must be set)
*	d3.w = function
*		0 = read sectors
*		1 = write sectors
*		2 = format track
*			a1.l = address of $3300 byte buffer
*			d1.w = sector no. of track to format
*			       ie. 0=track 0, side 0
*			          11=track 0, side 1 or track 1, side 0
*				  depending upon d0.w
*			d2.w = sectors to format
*			       ie.11=1 track
*			          22=2 tracks
*	bit 15 of d3.w controls whether the drive motor is turned off
*	after use. If bit 15 is clear the drive motor is left on. If
*	bit 15 is set the drive motor is turned off. Leave the drive
*	motor on if another disk operation is to be made soon after
*	the current one.
*
*	a0.l = disk buffer address for transfer
*	a1.l = workspace buffer, ($3300 bytes of CHIPMEM required)
* on exit,
*	d0.l = error no., if d0.l <> 0 then d1.l = sector offset in error
*		00 = no error
*		21 = No Sector Header
*		22 = Bad Sector Preamble
*		23 = Bad Sector ID
*		24 = Bad Sector Header Checksum
*		25 = Bad Sector Sum
*		26 = Too Few Sectors
*		27 = Bad Sector Header
*		28 = Write Protected
*		29 = No Disk in Drive
*		30 = Seek Error
*		34 = Drive In Use
*		-1 = DMA timeout
*
* Note: The disk code uses Timer A of CIA B
*       Master DMA (bit 9, $dff096) must be enabled
*	The blitter is not used
*------------------------------------------------------------------------------

_STDiskIO	dc.l $48E77FFC,$4E56FFDC,$38000244,$00033D44,$FFDC3D41,$FFDE3D42,$FFE03D43,$FFE22D48
		dc.l $FFE42D49,$FFE8E458,$02400001,$52403D40,$FFEC7000,$36026700,$0088701E,$D641B67C
		dc.l $06E06E00,$00A60281,$0000FFFF,$82FC000B,$0C6E0001,$FFEC6702,$D2413D41,$FFEE4841
		dc.l $3D41FFF0,$610005DE,$4A2EFFE3,$67046100,$0454302E,$FFF0720B,$9240B26E,$FFE06F04
		dc.l $322EFFE0,$3D41FFF2,$616A6634,$4A2EFFE3,$67066100,$01526628,$302EFFE0,$906EFFF2
		dc.l $671E3D40,$FFE0302E,$FFF2E188,$D080D1AE,$FFE4426E,$FFF0302E,$FFECD16E,$FFEE60B2
		dc.l $2F006100,$0552201F,$67207200,$322EFFEE,$0C6E0001,$FFEC6702,$E249C2FC,$000BD26E
		dc.l $FFF0D26E,$FFFA2F41,$00284E5E,$4A804CDF,$3FFE4E75,$7802426E,$FFFC426E,$FFFA426E
		dc.l $FFF8342E,$FFEE6100,$05546600,$00BA701D,$08390002,$00BFE001,$670000AC,$70000C2E
		dc.l $0002FFE3,$670000BC,$2A6EFFE8,$4BED0400,$2ABCAAAA,$AAAA3B7C,$44890004,$61000310
		dc.l $61000172,$66000080,$302EFFF4,$674EC0FC,$044041ED,$00066100,$044849F9,$00DFF01E
		dc.l $610001AA,$66780C2E,$0001FFE3,$670A302E,$FFFA906E,$FFF2676A,$2A6EFFE8,$4BED0400
		dc.l $302EFFF4,$C0FC0440,$DBC02ABC,$AAAAAAAA,$3B7C4489,$0004204D,$610003BC,$302EFFF6
		dc.l $6718C0FC,$044041ED,$00066100,$03F449EE,$FFFE4254,$61000156,$6624302E,$FFFA906E
		dc.l $FFF2671E,$701A2F00,$74026100,$04906100,$04DA201F,$08390002,$00BFE001,$670451CC
		dc.l $FF166000,$041E7802,$426EFFFA,$0C2E0002,$FFE3660A,$302EFFEE,$206EFFE8,$61706100
		dc.l $05027064,$61000536,$701C0839,$000300BF,$E001674E,$41F900DF,$F000317C,$40000024
		dc.l $216EFFE8,$0020317C,$6600009E,$317C9100,$009E0C6E,$0050FFEE,$6506317C,$A000009E
		dc.l $317C8010,$0096317C,$0002009C,$317CD961,$0024317C,$D9610024,$61000384,$670451CC
		dc.l $FF9E2F00,$70026100,$04D4201F,$4E752600,$0043FF00,$4843363C,$000B41E8,$04005848
		dc.l $20FC4489,$44892003,$610002C2,$41E8FFF8,$610002C4,$72286100,$02126100,$02B041E8
		dc.l $FFF86100,$02B241E8,$04100643,$01005303,$66CC4E75,$740A41ED,$0006303C,$00406100
		dc.l $02E06100,$031A6636,$610001CC,$670651CA,$FFE6602C,$6100018A,$662AB26E,$FFEE6624
		dc.l $B43C000B,$6C1EB63C,$000B6E18,$53033D43,$FFF43D7C,$000BFFF6,$976EFFF6,$70004E75
		dc.l $70184E75,$701B4E75,$70194E75,$2A6EFFE8,$4BED0400,$302EFFF8,$C0FC0440,$DBC0203C
		dc.l $00001770,$61000436,$082C0001,$00016600,$00F66100,$041A6700,$00F24AAD,$044067E8
		dc.l $61000154,$66BA6100,$011866B8,$B26EFFEE,$66B23602,$41ED0008,$61000126,$103C000B
		dc.l $902EFFF9,$41ED0008,$610001E2,$61000136,$41ED0030,$610001D6,$B66EFFF0,$6D00009A
		dc.l $302EFFF2,$D06EFFF0,$B6406C00,$008C082C,$00010001,$66000090,$302EFFFC,$07006678
		dc.l $4A2EFFE3,$67326100,$0086206E,$FFE4D1C1,$43ED0040,$61000168,$082C0001,$00016666
		dc.l $41ED0040,$323C0400,$610000E0,$41ED0038,$6100017A,$61686040,$41ED0040,$323C0400
		dc.l $610000C8,$2F0041ED,$00386100,$0094B09F,$6600FF16,$082C0001,$0001662A,$613041ED
		dc.l $0040226E,$FFE4D3C1,$610000EC,$6130302E,$FFFAB06E,$FFF2670E,$526EFFF8,$0C6E000B
		dc.l $FFF86600,$FEE87000,$4E7570FF,$4E752203,$926EFFF0,$203C0000,$0200C2C0,$4E75302E
		dc.l $FFFC07C0,$3D40FFFC,$526EFFFA,$4E75204D,$720A7000,$41E80440,$208051C9,$FFF84E75
		dc.l $41ED0008,$611A3600,$024300FF,$3400E04A,$48403200,$024100FF,$E048B03C,$00FF4E75
		dc.l $20182218,$02805555,$55550281,$55555555,$D0808081,$4E75610C,$2F0041ED,$003061E0
		dc.l $B09F4E75,$41ED0008,$72282F02,$E4495341,$70002418,$B58051C9,$FFFA241F,$02805555
		dc.l $55554E75,$206EFFE8,$203CAAAA,$AAAA2200,$24002600,$28002A00,$2C002E00,$43E80400
		dc.l $0C2E0001,$FFE36704,$43E832C0,$48E1FF00,$B1C966F8,$4E7548E7,$F0E0707F,$45E80200
		dc.l $263C5555,$55552218,$241AC283,$C483D281,$828222C1,$51C8FFF0,$4CDF070F,$4E7548E7
		dc.l $FCC0C348,$2600E48B,$53832A00,$2011E288,$61422019,$41F058FC,$613A91C5,$51CBFFEE
		dc.l $6114D1C5,$61104CDF,$033F4E75,$2F00E288,$6122201F,$611E1010,$08280000,$FFFF660C
		dc.l $08000006,$660C08C0,$00076004,$08800007,$10804E75,$02805555,$55552400,$0A825555
		dc.l $55552202,$D482E289,$08C1001F,$C2828081,$08280000,$FFFF6704,$0880001F,$20C04E75
		dc.l $43F900DF,$F000337C,$40000024,$337C8010,$0096337C,$6600009E,$337C9500,$009E337C
		dc.l $4489007E,$23480020,$337C0002,$009CE248,$00408000,$33400024,$33400024,$4E7543F9
		dc.l $00DFF000,$203C0000,$09C46100,$01700829,$0001001F,$660A6100,$015666F2,$70FF6002
		dc.l $700033FC,$000200DF,$F09C33FC,$400000DF,$F0244A80,$4E7533FC,$040000DF,$F09E4A6E
		dc.l $FFE26A1E,$72FF13C1,$00BFD100,$302EFFDC,$56800181,$13C100BF,$D10001C1,$13C100BF
		dc.l $D1004E75,$72FF13C1,$00BFD100,$08810007,$61D4203C,$000000C8,$600000E2,$48E73000
		dc.l $26026100,$009E302E,$FFDCD040,$41FA0108,$30300000,$6A046132,$662AE248,$E24A7201
		dc.l $9440670E,$6A0472FF,$44427003,$61505342,$66F8302E,$FFDCD040,$41FA00DC,$31830000
		dc.l $61607000,$4CDF000C,$4E7548E7,$20007455,$08390004,$00BFE001,$670E7003,$72FF611E
		dc.l $51CAFFEE,$701E6010,$302EFFDC,$D04041FA,$00A64270,$00007000,$4CDF0004,$4E752F00
		dc.l $612A4A01,$6B040880,$00010880,$000013C0,$00BFD100,$08C00000,$13C000BF,$D100201F
		dc.l $603A6108,$13C000BF,$D1004E75,$48A76000,$302EFFDC,$143900BF,$D1000002,$007F5600
		dc.l $01825700,$D040323B,$004E0801,$00006704,$08820002,$10024C9F,$00064E75,$611E0839
		dc.l $000000BF,$DE0066F6,$538066F0,$4E750839,$000000BF,$DE00661C,$53806718,$13FC0008
		dc.l $00BFDE00,$13FC0058,$00BFD400,$13FC0002,$00BFD500,$4E75FFFF,$FFFFFFFF
		dc.w $FFFF

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:	none

_STOpenStdout
		movem.l	d1-d7/a0-a6,-(sp)

		tst.w	arg_length(a5)
		beq.s	.wbench

		tst.l	stdout_handle(a5)
		beq.s	.not_already_opened
		move.l	#39,d0			;error number 39
		bra.s	.error
.not_already_opened

		move.l	a5,-(sp)		;get stdout handle
		move.l	dos_base(a5),a6
		jsr	_LVOOutput(a6)
		move.l	(sp)+,a5
		move.l	d0,stdout_handle(a5)
		bne.s	.opened_stdout
		moveq.l	#4,d0			;error number 4
                bra.s	.error
.opened_stdout

		bsr	output_copyright_message
		tst.l	d0
		bne.s	.error

.wbench		moveq.l	#0,d0			;no error
.error		movem.l	(sp)+,d1-d7/a0-a6
		rts

****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:       none

_STOpenConsole
		movem.l	d1-d7/a0-a6,-(sp)

		tst.l	console_handle(a5)
		beq.s	.not_already_opened
		move.l	#38,d0			;error number 38
		bra.s	.error
.not_already_opened

		move.l	a5,-(sp)		;get con: handle
		move.l	#console_name,d1
		move.l  #MODE_NEWFILE,d2
		move.l	dos_base(a5),a6
		jsr	_LVOOpen(a6)
		move.l	(sp)+,a5
		move.l	d0,console_handle(a5)
		bne.s	.opened_con
		moveq.l	#31,d0			;error number 31
		bra	.error
.opened_con

		move.l	console_handle(a5),stdout_handle(a5)
		bsr	output_copyright_message
                tst.l d0
		bne	.error

.no_error	moveq.l	#0,d0			;no error
.error		movem.l	(sp)+,d1-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;               a0.l=address of command line
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:	none

_STParseArgs
		movem.l	d1-d7/a0-a6,-(sp)

		tst.w	arg_length(a5)
		bne.s	.not_wbench
		bsr	wbench_parse_args
		bra.s	.skip_cli
.not_wbench	bsr	cli_parse_args
.skip_cli	tst.l	d0
		bne.s	.error

		tst.b	code_filename(a5)
		bne.s	.code_filename_ok
		move.l	#40,d0			;error number 40
		bra.s	.error
.code_filename_ok

		tst.b	code_output_filename(a5)
		bne.s	.code_output_filename_ok
		move.l	#40,d0			;error number 40
		bra.s	.error
.code_output_filename_ok

		moveq.l	#0,d0			;no error
.error		movem.l	(sp)+,d1-d7/a0-a6
		rts

****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:       d0-d3/a0-a1

CLI_KEYWORD_DEF	MACRO
		IFND	cli_keyword_defs
cli_keyword_defs
		ENDC
		dc.b	\1,0
		even
		dc.l    \2
		ENDM

CLI_KEYWORD_END	MACRO
		dc.b	-1
		even
		ENDM

cli_parse_args	moveq.l	#0,d0
		move.l	arg_address(a5),a0

next_keyword	tst.l	d0
		bne.s	.error
.next_arg	bsr	get_next_arg
		tst.l	d0
		beq.s	.end_of_args
		move.l	d0,a1
		jmp	(a1)

.end_of_args	moveq.l	#0,d0			;no error
.error		rts

		CLI_KEYWORD_DEF	<"?">,keyword_1_def
		CLI_KEYWORD_DEF	<"input">,keyword_2_def
		CLI_KEYWORD_DEF	<"info">,keyword_3_def
		CLI_KEYWORD_DEF	<"output">,keyword_4_def
		CLI_KEYWORD_END

keyword_1_def	WRITELN	<"WRITEFILE,INPUT/A/K,OUTPUT/A/K,INFO/S">
		moveq.l	#-1,d0
.error		bra     next_keyword

keyword_2_def	lea	code_filename(a5),a1
		bsr	get_string
		moveq.l	#0,d0
.error		bra	next_keyword

keyword_3_def	st.b	arg_info(a5)
		moveq.l	#0,d0
		bra	next_keyword

keyword_4_def	lea	code_output_filename(a5),a1
		bsr	get_string
		moveq.l	#0,d0
.error		bra	next_keyword

****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:       d0-d3/a0-a2

wbench_parse_args
		move.l	wbench_message(a5),a2
		cmpi.l	#2,sm_NumArgs(a2)
		blt.s	.no_error
		move.l	sm_ArgList(a2),a2
		add.l	#wa_SIZEOF,a2

		move.l	wa_Name(a2),a0
		lea	code_filename(a5),a1
		move.w	#NAME_SIZE,d0
		jsr	_STCopyString
		tst.l	d0
		bne.s	.error

		movem.l	a5,-(sp)
		move.l	wa_Lock(a2),d1
		move.l	dos_base(a5),a6
		jsr	_LVOCurrentDir(a6)
		movem.l	(sp)+,a5

.no_error	moveq.l	#0,d0
.error		rts

****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;               a0.l=address of source
;		a1.l=address of destination
;		d0.l=maximum number of characters to copy
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:       none

_STCopyString
		movem.l	d1-d7/a0-a6,-(sp)

		subq.w	#1,d0
.loop		move.b	(a0)+,(a1)+
		beq.s	.no_error
		dbf	d0,.loop
		move.l	#26,d0			;error number 26
		bra.s	.error

.no_error	moveq.l	#0,d0
.error		movem.l	(sp)+,d1-d7/a0-a6
		rts

****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;               a0.l=address of command line
;		a1.l=address of output string
;OUTPUT:	a0.l=address of character after next keyword
;CHANGES:	d0-d1,a1

get_string
		move.b	#" ",d1		;default terminator

.find_start
		move.b	(a0)+,d0
		cmpi.b	#EOL,d0
		beq.s	.end
		cmpi.b	#" ",d0
		ble.s	.find_start

		cmpi.b	#34,d0
		bne.s	.not_new_terminator_34
		move.b	d0,d1
		bra.s	.new_terminator
.not_new_terminator_34

		move.b	d0,(a1)+
.new_terminator
.next_letter	move.b	(a0)+,(a1)+
		cmpi.b	#EOL,-1(a0)
		beq.s	.end
		cmp.b	-1(a0),d1
		bne.s	.next_letter

.end		move.b	#0,-1(a1)
		rts

****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;               a0.l=address of command line
;OUTPUT:	a0.l=address of character after next keyword
;		d3.l=address of keyword function routine (0=no keywords)
;CHANGES:	none

get_next_arg
		movem.l	a1-a2/d1-d2,-(sp)

		moveq.l	#0,d0

.next_argument	cmpi.b	#EOL,(a0)
		beq.s	.not_found
		cmpi.b	#" ",(a0)+
                ble.s	.next_argument
		sub.w	#1,a0
		move.l	a0,a2
		lea	cli_keyword_defs(pc),a1

.next_letter	move.b	(a0)+,d1
		move.b	(a1)+,d2
		beq.s	.found
		cmp.b	d1,d2
		beq.s	.next_letter
		cmp.b	#97,d2
		blt.s	.next_keyword
		sub.b	#32,d2
		cmp.b	d1,d2
		beq.s	.next_letter

.next_keyword	tst.b	(a1)+
		bne.s	.next_keyword
		move.l	a1,d1
		btst.l	#0,d1
		beq.s	.even
		add.w	#1,a1
.even		add.w	#4,a1
		tst.b	(a1)
		bmi.s	.find_next_argument
		move.l	a2,a0
		bra.s	.next_letter

.find_next_argument
		tst.b	(a1)+
		bne.s	.find_next_argument
		bra.s	.next_argument

.found		move.l	a1,d1
		btst.l	#0,d1
		beq.s	.even2
		add.w	#1,a1
.even2		move.b	(a1)+,d0
		rol.l	#8,d0
		move.b	(a1)+,d0
		rol.l	#8,d0
		move.b	(a1)+,d0
		rol.l	#8,d0
		move.b	(a1)+,d0
		sub.w	#1,a0

.not_found	movem.l	(sp)+,a1-a2/d1-d2
		rts

****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:	none

output_copyright_message
		WRITELN	<"WriteFile V1.0">
		WRITELN	<"An AmigaDOS framework by Scott Johnston around disk routines by Rob Northen">

		moveq.l	#0,d0			;no error
.error		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:	none

_STCloseConsole
		movem.l	d1-d7/a0-a6,-(sp)

		tst.l	console_handle(a5)
		beq.s	.no_console

		jsr	wait_for_return
		tst.l	d0
		bne.s	.error

		move.l	a5,-(sp)
		move.l	console_handle(a5),d1
		move.l	dos_base(a5),a6
		jsr	_LVOClose(a6)
		move.l	(sp)+,a5
		move.l	#0,console_handle(a5)

.no_console	moveq.l	#0,d0			;no error
.error		movem.l	(sp)+,d1-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:       d1

wait_for_return
		WRITELN	<"PRESS RETURN TO EXIT">

		move.l	a5,-(sp)
		move.l	stdout_handle(a5),d1
		move.l	dos_base(a5),a6
		jsr	_LVOFGetC(a6)
		move.l	(sp)+,a5

		moveq.l	#0,d0			;no error
.error		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:	none

_STOpenLibraries
		movem.l	d1-d7/a0-a6,-(sp)

		move.l	a5,-(sp)		;open graphics library
		lea	graphics_name,a1
		moveq.l	#LIBRARY_MINIMUM,d0
		move.l	4.w,a6
		jsr	_LVOOpenLibrary(a6)
		move.l	(sp)+,a5
		move.l	d0,graphics_base(a5)
		bne.s	.opened_graphics
		moveq.l	#1,d0			;error number 1
		bra.s	.error
.opened_graphics

		move.l	a5,-(sp)		;open intuition library
		lea	intuition_name,a1
		moveq.l	#LIBRARY_MINIMUM,d0
		move.l	4.w,a6
		jsr	_LVOOpenLibrary(a6)
		move.l	(sp)+,a5
		move.l	d0,intuition_base(a5)
		bne.s	.opened_intuition
		moveq.l	#2,d0			;error number 2
		bra.s	.error
.opened_intuition

		move.l	a5,-(sp)		;open dos library
		lea	dos_name,a1
		moveq.l	#LIBRARY_MINIMUM,d0
		move.l	4.w,a6
		jsr	_LVOOpenLibrary(a6)
		move.l	(sp)+,a5
		move.l	d0,dos_base(a5)
		bne.s	.opened_dos
		moveq.l	#3,d0			;error number 3
		bra.s	.error
.opened_dos
		moveq.l	#0,d0			;no errors
.error		movem.l	(sp)+,d1-d7/a0-a6
		rts

****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	none
;CHANGES:	none

_STCloseLibraries
		movem.l	d0-d7/a0-a6,-(sp)

		tst.l	dos_base(a5)
		beq.s	.skip_dos
		move.l	a5,-(sp)		;close dos library
		move.l	dos_base(a5),a1
		move.l	4.w,a6
		jsr	_LVOCloseLibrary(a6)
		move.l	(sp)+,a5
		clr.l	dos_base(a5)
.skip_dos

		tst.l	intuition_base(a5)
		beq.s	.skip_intuition
		move.l	a5,-(sp)		;close intuition library
		move.l	intuition_base(a5),a1
		move.l	4.w,a6
		jsr	_LVOCloseLibrary(a6)
		move.l	(sp)+,a5
		clr.l	intuition_base(a5)
.skip_intuition

		tst.l	graphics_base(a5)
		beq.s	.skip_graphics
		move.l	a5,-(sp)		;close graphics library
		move.l	graphics_base(a5),a1
		move.l	4.w,a6
		jsr	_LVOCloseLibrary(a6)
		move.l	(sp)+,a5
		clr.l	graphics_base(a5)
.skip_graphics

		movem.l	(sp)+,d0-d7/a0-a6
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:	none

allocate_memory
		move.l	a5,-(sp)		;find largest free chip
		move.l	#MEMF_CHIP!MEMF_LARGEST,d1
		move.l	4.w,a6
		jsr	_LVOAvailMem(a6)
		move.l	(sp)+,a5
		move.l	d0,largest_chip(a5)

		move.l	a5,-(sp)		;find largest free public
		move.l	#MEMF_PUBLIC!MEMF_LARGEST,d1
		move.l	4.w,a6
		jsr	_LVOAvailMem(a6)
		move.l	(sp)+,a5
		move.l	d0,largest_public(a5)

		move.l	chip_chunk_max_amount(a5),d0
		beq.s	.skip_chip_mem
		move.l	a5,-(sp)		;allocate maximum chip memory
		move.l	#MEMF_CHIP,d1
		move.l	4.w,a6
		jsr	_LVOAllocMem(a6)
		move.l	(sp)+,a5
		move.l	chip_chunk_max_amount(a5),chip_amount_allocated(a5)
		move.l	d0,chip_chunk_address(a5)
		bne.s	.skip_chip_mem
		move.l	chip_chunk_min_amount(a5),d0
		beq.s	.chip_error
		move.l	a5,-(sp)		;allocate minimum chip memory
		move.l	#MEMF_CHIP,d1
		move.l	4.w,a6
		jsr	_LVOAllocMem(a6)
		move.l	(sp)+,a5
		move.l	chip_chunk_min_amount(a5),chip_amount_allocated(a5)
		move.l	d0,chip_chunk_address(a5)
		bne.s	.skip_chip_mem
.chip_error	clr.l	chip_amount_allocated(a5)
		moveq.l	#11,d0			;error number 11
		bra	.error
.skip_chip_mem

		move.l	public_chunk_max_amount(a5),d0
		beq.s	.skip_public_mem
		move.l	a5,-(sp)		;allocate maximum public memory
		move.l	#MEMF_PUBLIC,d1
		move.l	4.w,a6
		jsr	_LVOAllocMem(a6)
		move.l	(sp)+,a5
		move.l	public_chunk_min_amount(a5),public_amount_allocated(a5)
		move.l	d0,public_chunk_address(a5)
		bne.s	.skip_public_mem
		move.l	public_chunk_min_amount(a5),d0
		beq.s	.public_error
		move.l	a5,-(sp)		;allocate minimum public memory
		move.l	#MEMF_PUBLIC,d1
		move.l	4.w,a6
		jsr	_LVOAllocMem(a6)
		move.l	(sp)+,a5
		move.l	public_chunk_min_amount(a5),public_amount_allocated(a5)
		move.l	d0,public_chunk_address(a5)
		bne.s	.skip_public_mem
.public_error	clr.l	public_amount_allocated(a5)
		moveq.l	#13,d0			;error number 13
                bra.s	.error
.skip_public_mem

		moveq.l	#0,d0			;no errors
.error		rts

****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	none
;CHANGES:	none

deallocate_memory
		tst.l	chip_chunk_address(a5)
		beq.s	.skip_free_chip
		move.l	a5,-(sp)		;free chip memory
		move.l	chip_chunk_address(a5),a1
		move.l	chip_amount_allocated(a5),d0
		move.l	4.w,a6
		jsr	_LVOFreeMem(a6)
		move.l	(sp)+,a5
		clr.l	chip_chunk_address(a5)
.skip_free_chip

		tst.l	public_chunk_address(a5)
		beq.s	.skip_free_public
		move.l	a5,-(sp)		;free public memory
		move.l	public_chunk_address(a5),a1
		move.l	public_amount_allocated(a5),d0
		move.l	4.w,a6
		jsr	_LVOFreeMem(a6)
		move.l	(sp)+,a5
		clr.l	public_chunk_address(a5)
.skip_free_public

		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:	none

allocate_resources
		bsr	allocate_disk_resource
		tst.l	d0
		bne.s	.error

		moveq.l	#0,d0			;no errors
.error		rts

****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	d0.l=error code (0=no error)
;CHANGES:	none

allocate_disk_resource
		move.l	a5,-(sp)        	;open disk resource
		lea	disk_name,a1
		move.l	4.w,a6
		jsr	_LVOOpenResource(a6)
		move.l	(sp)+,a5

		move.l	d0,disk_base(a5)
		bne.s	.opened_disk_resource
		moveq.l	#7,d0			;error number 7
                bra	.error
.opened_disk_resource
		sf.b	disk_units(a5)

		btst.b	#0,disk_units_req(a5)
		beq.s	.not_unit1
		moveq.l	#0,d0
		bsr	.alloc_unit
		tst.l	d0
		bne.s	.error
		bset.b	#0,disk_units_req(a5)
.not_unit1
		btst.b	#1,disk_units_req(a5)
		beq.s	.not_unit2
		moveq.l	#1,d0
		bsr	.alloc_unit
		tst.l	d0
		bne.s	.error
		bset.b	#1,disk_units_req(a5)
.not_unit2
		btst.b	#2,disk_units_req(a5)
		beq.s	.not_unit3
		moveq.l	#2,d0
		bsr	.alloc_unit
		tst.l	d0
		bne.s	.error
		bset.b	#2,disk_units_req(a5)
.not_unit3
		btst.b	#3,disk_units_req(a5)
		beq.s	.not_unit4
		moveq.l	#3,d0
		bsr	.alloc_unit
		tst.l	d0
		bne.s	.error
		bset.b	#3,disk_units_req(a5)
.not_unit4
		moveq.l	#0,d0
.error		rts

.alloc_unit	move.l	a5,-(sp)
		move.l	disk_base(a5),a6
		jsr	_LVOAllocUnit(a6)
		move.l	(sp)+,a5

		tst.l	d0
		bne.s	.allocated_unit
		moveq.l	#8,d0			;error number 8
               	rts

.allocated_unit	moveq.l	#0,d0
		rts

****************************************************************************
****************************************************************************
****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	none
;CHANGES:	none

deallocate_resources
		bsr	deallocate_disk_resource

		rts

****************************************************************************
;INPUT:		a5.l=address of parameters/variables block
;OUTPUT:	none
;CHANGES:	none

deallocate_disk_resource
		btst.b	#0,disk_units(a5)
		beq.s	.not_unit1
		moveq.l	#0,d0
		bsr	.dealloc_unit
		tst.l	d0
		bne.s	.error
		bclr.b	#0,disk_units(a5)
.not_unit1
		btst.b	#1,disk_units(a5)
		beq.s	.not_unit2
		moveq.l	#1,d0
		bsr	.dealloc_unit
		tst.l	d0
		bne.s	.error
		bclr.b	#1,disk_units(a5)
.not_unit2
		btst.b	#2,disk_units(a5)
		beq.s	.not_unit3
		moveq.l	#2,d0
		bsr	.dealloc_unit
		tst.l	d0
		bne.s	.error
		bclr.b	#2,disk_units(a5)
.not_unit3
		btst.b	#3,disk_units(a5)
		beq.s	.not_unit4
		moveq.l	#4,d0
		bsr	.dealloc_unit
		tst.l	d0
		bne.s	.error
		bclr.b	#3,disk_units(a5)
.not_unit4
		moveq.l	#0,d0
.error		rts

.dealloc_unit	move.l	a5,-(sp)
		move.l	disk_base(a5),a6
		jsr	_LVOFreeUnit(a6)
		move.l	(sp)+,a5
		rts

****************************************************************************
****************************************************************************
****************************************************************************

graphics_name	dc.b	"graphics.library",0
intuition_name	dc.b	"intuition.library",0
dos_name	dc.b	"dos.library",0
misc_name	dc.b	"misc.resource",0
potgo_name	dc.b	"potgo.resource",0
serial_name	dc.b	"serial.device",0
parallel_name	dc.b	"parallel.device",0
disk_name	dc.b	"disk.resource",0
console_name	dc.b	"con:0/11/640/150/System Takeover Output",0

		even

****************************************************************************
****************************************************************************
****************************************************************************

		CNOP	0,4		;!!! Must be long word aligned !!!

parameters	dc.b	"WriteFile",0,0,0,0,0,0
		dc.l	$5000		;chip memory min amount
		dc.l	0		;public memory min amount
		dc.l	$5000		;chip memory maximum amount
		dc.l	0		;public memory maximum amount

		dc.l	0		;temp memory amount
		dc.l	0		;level 2 user interrupt routine
		dc.l	0		;level 3 user interrupt routine
		dc.l	0		;level 6 user interrupt routine

		dc.b	0		;chunk to load code to
		dc.b	0		;chunk to unpack code to
		dc.b	0		;chunk to relocate code to

		dc.b	0		;resource allocation flags

		dc.l	0		;graphics_base
		dc.l	0		;intuition_base
		dc.l	0		;dos_base
		dc.l	0		;misc_base
		dc.l	0		;potgo_base
		dc.l	0		;disk_base
		dc.l	0		;hardware base
		dc.l	0		;size of chip chunk allocated
		dc.l	0		;size of public chunk allocated
		dc.l	0		;largest free chip chunk
		dc.l	0		;largest free public chunk
		dc.l	0		;chip chunk start address
		dc.l	0		;public chunk start address
		dc.l	0		;temp chunk start address
		dc.l	0		;chip mem start address
		dc.l	0		;public mem start address
		dc.l    0		;screen bitmaps
		dc.l	0		;screen1_struct
		dc.l	0		;screen2_struct
		dc.l	0		;stdout_handle
		dc.l	0		;console_handle
		dc.l	0		;wbench_message
		dc.l	0		;address of cli arguments
		dc.w	0		;number of characters in cli args
		dc.b	0		;flag for info output
		dc.b	0		;flag relocate required
		ds.b	NAME_SIZE	;code filename
		ds.b	NAME_SIZE	;code output filename
		dc.l	0		;address to load code to
		dc.l	0		;address to unpack code to
		dc.l	0		;address to relocate code to
		dc.l    0               ;current address of code
		dc.l	0		;size of unpacked code file
		dc.l    0		;lock on code file
		ds.b	fib_SIZEOF	;code file info block
		dc.b	%0000		;disk units required
		dc.b	0		;disk units allocated
		dc.b	0		;flag memory allocation failed
		dc.b	0		;flag code unpack
		dc.b	0		;serial_port
		dc.b	0		;serial_bits
		dc.b	0		;parallel_port
		dc.b	0		;parallel_bits
		dc.l	0		;potgo_bits
		dc.b	0		;int_ciaa_a
		dc.b	0		;int_vertb
		dc.b	0		;int_ciab_A
		dc.b	0		;flag quiet required

		even

		end
