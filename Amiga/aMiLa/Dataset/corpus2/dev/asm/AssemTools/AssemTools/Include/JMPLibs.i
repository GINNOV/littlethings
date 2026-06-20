; ***********************************************************************
; *									*
; *	Library include file for assembly programming.			*
; *									*
; *	### VERSION 1.72 ###						*
; *									*
; *									*
; *	Created by JM 880110 021500					*
; *									*
; *	Edited:								*
; *	880110	- print creates primm automatically			*
; *		- libnames added					*
; *		- lib6 added						*
; *		- print simplified					*
; *									*
; *	880227	- notc and notx macros added				*
; *									*
; *	880305	- flib and printa added					*
; *		- double nulls changed to singles in libnames		*
; *									*
; *	880307	- push and pull by Tomi Marin				*
; *									*
; *	880426	- closlab, liba, liba6 by Jukka Marin			*
; *									*
; *	880501	- fileptr added to print				*
; *									*
; *	880513	- printa edited						*
; *	880515	- printa edited: accepts a filehandle, too		*
; *									*
; *	880603	- clrv, setv, notc added				*
; *									*
; *	880605	- printa edited: works also with a0/a1/d0/d1		*
; *									*
; *	880609	- printa edited: now always prints right # of chars	*
; *									*
; *	880612	- closl added to save memory (doesn't check or reset	*
; *		  library base pointer)					*
; *									*
; *	881030	- a4 RELATIVE addressing added to certain routines.	*
; *		  for use with Aztec Assembler etc.			*
; *		- relbase, rlong, rword, rbyte written			*
; *									*
; *	881105	- if filehandle in print[a] is NULL don't call Write()	*
; *		- bugs fixed in print[a] RELATIVE			*
; *		- dir added to relbase					*
; *									*
; *	890122	- clrz, setz, notz added				*
; *		- extra "d" removed from line:				*
; *	880603  - clrv, setv, notc addded				*
; *									*
; *	890303	- peek added						*
; *									*
; *	890310	- defines blo and bhs macros if A68k is used.		*
; *									*
; *	890311	- .s-extensions added.					*
; *		- libnames no longer defines lib base prts if RELATIVE	*
; *		  mode is used.						*
; *									*
; *	890612	- lbase written.  Gets the library base pointer		*
; *		  into given register.					*
; *									*
; *	890612	- expansion library support added.			*
; *									*
; *	890617	- rbase, rlong, rword, and rbyte removed.  Use the	*
; *		  macros provided in util.i instead.			*
; *									*
; *	890701	- ckeven added.						*
; *									*
; *	890714	- openlib version number can now be specified.		*
; *									*
; ***********************************************************************
;
;  setz		sets the zero flag
;  clrz		clears  -  "  -
;  notz		toggles -  "  -
;  setc		sets the carry flag
;  clrc		clears  -  "  -
;  notc		toggles -  "  -
;  setx		sets the extend flag
;  clrx		clears  -  "  -
;  notx		toggles -  "  -
;  setv		sets the overflow flag
;  clrv		clears  -  "  -
;  notv		toggles -  "  -
;
;  print	Prints the text immediately following the command.
;		Text must NOT be null-terminated. The second parameter,
;		if specified, is the file pointer.
;
;  printa	Prints the text from address given. Text must be
;		null-terminated.
;		Example: printa a2
;		prints a text from (a2) on.
;		Example: printa text(pc),outfile(pc)
;		prints a text from (text(pc)) on to outfile(pc)
;
;  openlib	Opens a library. Example: openlib Dos,cleanup
;		tries to open dos.library. If fails, branches to label
;		cleanup. Label is optional.
;		openlib Dos,cleanup,34 specifies the oldest library
;		version number to be accepted.
;
;  closlib	Closes a library if its pointer is not zero. Finally
;		the pointer is set to zero to prevent closing lib again.
;		Example: closlib Dos
;		tries to close dos.library.
;
;  closl	Closes a library regardless of its pointer.  Doesn't reset
;		the pointer.  Saves memory but is not so safe to use as
;		closlib.
;		Example: closl Intuition
;		tries to close intuition.library.
;
;  closlab	As closlib but doesn't use PC-relative addressing.
;
;  lib		Calls a library routine. Example: lib Dos,Delay
;		loads _DosBase into a6 and calls _LVODelay(a6).
;  liba		As lib but doesn't use PC-relative addressing.
;
;  lib6		lib6 = lib but saves a6 first.
;  liba6	liba6 = liba but saves a6 first.
;
;  flib		Calls a library routine without loading a6 first.
;		Use only when a6 already contains right library base address.
;		Example: flib Dos,Delay or flib Delay
;
;  lbase	Gets the library base pointer into given register.  Example:
;		lbase Dos,a2	gets dosbase into a2.
;
;  libnames	Defines library names and pointers needed by openlib.
;		Must be added to the end of the program if print or lib
;		macros are used.
;
;  push		Pushes processor register(s) onto the stack.
;  pull		Pulls processor register(s) from the stack.
;  peek		Peeks processor register(s) from the stack
;  		without altering the value of SP.
;		Examples: push all  = movem.l d0-d7/a0-a6,-(sp)
;			  push a0-a5
;			  pull d0-d4/a4
;
;  ckeven	Checks if current PC value is even.  Causes an error if not.
;		Needs a label (at even address) as a parameter.
;
;



setz		macro
		ori	#4,ccr
		endm

clrz		macro
		andi	#251,ccr
		endm

notz		macro
		eori	#4,ccr
		endm

setc		macro
		ori	#1,ccr
		endm

clrc		macro
		andi	#254,ccr
		endm

notc		macro
		eori	#1,ccr
		endm

setx		macro
		ori	#16,ccr
		endm

clrx		macro
		andi	#239,ccr
		endm

notx		macro
		eori	#16,ccr
		endm

setv		macro
		ori	#2,ccr
		endm

clrv		macro
		andi	#253,ccr
		endm

notv		macro
		eori	#2,ccr
		endm


		ifd	.A68k
		include	"bb.i"		; defines blo and bhs
		endc



ckeven		macro	*label_at_even_addr
		ifne	(*-\1)&1
		Error: This line begins at odd address!!!
		endc
		endm



print		macro	*STRING		print <'This is a test',10> [,file]
		ifnd	Dprimm
		bra.s	_primmover

primm		move.l	(sp)+,a2
		move.l	a2,d2
primmloop1	tst.b	(a2)+
		bne.s	primmloop1
		move.l	a2,d3
		sub.l	d2,d3
		subq.l	#1,d3
		beq.s	primmloop2
		tst.l	d1
		beq.s	primmloop2
		jsr	_LVOWrite(a6)
primmloop2	move.l	a2,d0
		addq.l	#3,d0
		and.b	#252,d0
		move.l	d0,-(sp)
		rts
_primmover
Dprimm		set	1
		endc
		movem.l	a0-a2/a6/d0-d3,-(sp)
		ifc	'\2',''
		lib	Dos,Output
		move.l	d0,d1
		endc
		ifnc	'\2',''
		move.l	\2,d1		optional filehandle
		endc
		ifd	RELATIVE
		move.l	_DosBase(a4),a6
		endc
		ifnd	RELATIVE
		move.l	_DosBase(pc),a6
		endc
		jsr	primm(pc)
		dc.b	\1
		dc.b	0
		cnop	0,4
		movem.l	(sp)+,a0-a2/a6/d0-d3
		endm

printa		macro	*STRINGPTR	printa a4//printa #STARTMSG
		movem.l	a0-a1/a6/d0-d3,-(sp)
		move.l	\1,d2
		ifc	'\2',''
		lib	Dos,Output
		move.l	d0,d1
		endc
		ifnc	'\2',''
		move.l	\2,d1		optional filehandle
		endc
		beq.s	printa\@
		ifd	RELATIVE
		move.l	_DosBase(a4),a6
		endc
		ifnd	RELATIVE
		move.l	_DosBase(pc),a6
		endc
		jsr	print_addr(pc)
printa\@	movem.l	(sp)+,a0-a1/a6/d0-d3
		ifnd	Dprinta
		bra.s	_printaovr

print_addr	move.l	d2,a0		buffer
printadloop	tst.b	(a0)+
		bne.s	printadloop
		subq.l	#1,a0
		move.l	a0,d3		length
		sub.l	d2,d3
		flib	Write
		rts
_printaovr
Dprinta		set	1
		endc
		endm



push		macro	* push <reg list | all>
		ifc	'\1','all'
		movem.l	d0-d7/a0-a6,-(sp)
		endc
		ifnc	'\1','all'
		movem.l	\1,-(sp)
		endc
		endm

pull		macro	* pull <reg list | all>
		ifc	'\1','all'
		movem.l	(sp)+,d0-d7/a0-a6
		endc
		ifnc	'\1','all'
		movem.l	(sp)+,\1
		endc
		endm

peek		macro	* peek <reg list | all>
		ifc	'\1','all'
		movem.l	(sp),d0-d7/a0-a6
		endc
		ifnc	'\1','all'
		movem.l	(sp),\1
		endc
		endm



openlib		macro	*LIB_ID,CLEANUP	openlib Dos[,cleanup[,ver]]
D\1		set	1
		move.l	4,a6
		lea	_\1Lib(pc),a1
		ifc	'\3',''
		moveq.l	#0,d0
		endc
		ifnc	'\3',''
		moveq	#\3,d0
		endc
		jsr	_LVOOpenLibrary(a6)
		ifd	RELATIVE
		move.l	d0,_\1Base(a4)
		endc
		ifnd	RELATIVE
		move.l	d0,_\1Base
		endc
		ifnc	'\2',''
		beq	\2
		endc
		endm

closlib		macro	*LIB_ID		closlib Dos
		ifd	RELATIVE
		move.l	_\1Base(a4),a1
		endc
		ifnd	RELATIVE
		move.l	_\1Base(pc),a1
		endc
		move.l	a1,d0
		beq.s	cLIB\@
		move.l	4,a6
		jsr	_LVOCloseLibrary(a6)
cLIB\@		
		ifd	RELATIVE
		clr.l	_\1Base(a4)
		endc
		ifnd	RELATIVE
		clr.l	_\1Base
		endc
		endm

closl		macro	*LIB_ID		closl Dos (no security measures)
		ifd	RELATIVE
		move.l	_\1Base(a4),a1
		endc
		ifnd	RELATIVE
		move.l	_\1Base(pc),a1
		endc
		move.l	4,a6
		jsr	_LVOCloseLibrary(a6)
		endm

closlab		macro	*LIB_ID		closlab Dos, absolute addressing
		move.l	_\1Base,a1
		move.l	a1,d0
		beq.s	cLIBa\@
		move.l	4,a6
		jsr	_LVOCloseLibrary(a6)
cLIBa\@		clr.l	_\1Base
		endm

lib		macro	*LIB_ID,ROUTINE	lib Dos, Delay
		ifnc	'\1','Exec'
		ifd	RELATIVE
		move.l	_\1Base(a4),a6
		endc
		ifnd	RELATIVE
		move.l	_\1Base(pc),a6
		endc
		endc
		ifc	'\1','Exec'
		move.l	$4,a6
		endc
		jsr	_LVO\2(a6)
		endm

liba		macro	*LIB_ID,ROUTINE	liba Dos,Delay, absolute addressing
		ifnc	'\1','Exec'
		move.l	_\1Base,a6
		endc
		ifc	'\1','Exec'
		move.l	$4,a6
		endc
		jsr	_LVO\2(a6)
		endm

lib6		macro	*LIB_ID,ROUTINE	lib6 Dos, Delay
		move.l	a6,-(sp)
		lib	\1,\2
		move.l	(sp)+,a6
		endm

liba6		macro	*LIB_ID,ROUTINE	lib Dos, Delay
		move.l	a6,-(sp)
		liba	\1,\2
		move.l	(sp)+,a6
		endm

flib		macro	*LIB_ID,ROUTINE//ROUTINE flib Dos,Delay//flib Delay
		ifnc	'\2',''
		jsr	_LVO\2(a6)
		endc
		ifc	'\2',''
		jsr	_LVO\1(a6)
		endc
		endm


lbase		macro	*LIB_ID,REGISTER lib Dos,a4
		ifnc	'\1','Exec'
		ifd	RELATIVE
		move.l	_\1Base(a4),\2
		endc
		ifnd	RELATIVE
		move.l	_\1Base(pc),\2
		endc
		endc
		ifc	'\1','Exec'
		move.l	$4,\2
		endc
		endm


libnames	macro
		ifd	DClist
_ClistLib	dc.b	'clist.library',0
		cnop	0,2
		ifnd	_ClistBase
		ifnd	RELATIVE
_ClistBase	dc.l	0
		endc
		endc
		endc

		ifd	DGfx
_GfxLib		dc.b	'graphics.library',0
		cnop	0,2
		ifnd	_GfxBase
		ifnd	RELATIVE
_GfxBase	dc.l	0
		endc
		endc
		endc

		ifd	DLayers
_LayersLib	dc.b	'layers.library',0
		cnop	0,2
		ifnd	_LayersBase
		ifnd	RELATIVE
_LayersBase	dc.l	0
		endc
		endc
		endc

		ifd	DIntuition
_IntuitionLib	dc.b	'intuition.library',0
		cnop	0,2
		ifnd	_IntuitionBase
		ifnd	RELATIVE
_IntuitionBase	dc.l	0
		endc
		endc
		endc

		ifd	DMath
_MathLib	dc.b	'mathffp.library',0
		cnop	0,2
		ifnd	_MathBase
		ifnd	RELATIVE
_MathBase	dc.l	0
		endc
		endc
		endc

		ifd	DMathTrans
_MathTransLib	dc.b	'mathtrans.library',0
		cnop	0,2
		ifnd	_MathTransBase
		ifnd	RELATIVE
_MathTransBase	dc.l	0
		endc
		endc
		endc

		ifd	DMathIeeeDoubBas
_MathIeeeDoubBasLib	dc.b	'mathieeedoubbas.library',0
		cnop	0,2
		ifnd	_MathIeeeDoubBasBase
		ifnd	RELATIVE
_MathIeeeDoubBasBase	dc.l	0
		endc
		endc
		endc

		ifd	DDos
_DosLib		dc.b	'dos.library',0
		cnop	0,2
		ifnd	_DosBase
		ifnd	RELATIVE
_DosBase	dc.l	0
		endc
		endc
		endc

		ifd	DTranslator
_TranslatorLib	dc.b	'translator.library',0
		cnop	0,2
		ifnd	_TranslatorBase
		ifnd	RELATIVE
_TranslatorBase	ds.l	1
		endc
		endc
		endc

		ifd	DIcon
_IconLib	dc.b	'icon.library',0
		cnop	0,2
		ifnd	_IconBase
		ifnd	RELATIVE
_IconBase	dc.l	0
		endc
		endc
		endc

		ifd	DDiskfont
_DiskfontLib	dc.b	'diskfont.library',0
		cnop	0,2
		ifnd	_DiskfontBase
		ifnd	RELATIVE
_DiskfontBase	dc.l	0
		endc
		endc
		endc

		ifd	DExpansion
_ExpansionLib	dc.b	'expansion.library',0
		cnop	0,2
		ifnd	_ExpansionBase
		ifnd	RELATIVE
_ExpansionBase	dc.l	0
		endc
		endc
		endc

		ifnd	_ExecBase
_ExecBase	equ	$4
		endc

		endm

