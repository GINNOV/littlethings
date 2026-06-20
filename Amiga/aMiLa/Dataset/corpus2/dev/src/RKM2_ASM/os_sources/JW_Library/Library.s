
 * Insert your own functions by replacing the Double() and AddThese()
 * example functions.
 *
 * Simply compile this program, as Linkable, to make an object (.o or .obj)
 * file and then BLink the created object file, with:
 *
 * BLink FROM ram:filename.o LIBRARY Libs:Amiga.lib TO ram:filename.library
 *
 * For example. Compile this program into Ram:, using the devpac Linkable
 * option instead of the Executable option. Use a filename like jw.o 
 * When the compiler has created jw.o you then:
 *
 * Blink FROM Ram:jw.o LIBRARY Libs:Amiga.lib TO Ram:jw.library
 *
 * The file created with BLink is then a Shared Run-Time Library, with the
 * Double() and AddThese() functions inside it.
 *

	SECTION	CODE

	NOLIST

	INCDIR	WORK:Include/

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/memory.i
	INCLUDE	exec/initializers.i
	INCLUDE	exec/lists.i
	INCLUDE	exec/alerts.i
	INCLUDE	exec/libraries.i
	INCLUDE	exec/resident.i
	INCLUDE	exec/memory.i
	INCLUDE	exec/types.i
	INCLUDE	intuition/intuition_lib.i
	INCLUDE	intuition/intuition.i
	INCLUDE dos/dos_lib.i
	INCLUDE dos/dos.i
	INCLUDE dos/dosextens.i
	INCLUDE	graphics/graphics_lib.i
	INCLUDE	graphics/text.i
	INCLUDE	graphics/gels.i
	INCLUDE	workbench/icon_lib.i
	INCLUDE	workbench/startup.i
	INCLUDE	workbench/workbench.i

	INCLUDE	misc/jw_library.i

	LIST

	XDEF	InitTable
	XDEF	Open
	XDEF	Close
	XDEF	Expunge
	XDEF	Null
	XDEF	Double
	XDEF	AddThese

	XREF	_AbsExecBase

Start:
	moveq	#-1,d0
	rts

JWPRI	EQU	0

RomTag:
	dc.w	RTC_MATCHWORD
	dc.l	RomTag
	dc.l	EndCode
	dc.b	RTF_AUTOINIT
	dc.b	JWVER
	dc.b	NT_LIBRARY
	dc.b	JWPRI
	dc.l	LibName
	dc.l	IDString
	dc.l	InitTable

LibName:	JWNAME

IDString:	JWID

dosName:	DOSNAME

	ds.w	0

InitTable:
	dc.l	JwBase_SIZEOF
	dc.l	funcTable
	dc.l	dataTable
	dc.l	initRoutine

funcTable:
	dc.l	Open
	dc.l	Close
	dc.l	Expunge
	dc.l	Null
	dc.l	Double
	dc.l	AddThese
	dc.l	-1

dataTable:
	INITBYTE	LN_TYPE,NT_LIBRARY
	INITLONG	LN_NAME,LibName
	INITBYTE	LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
	INITWORD	LIB_VERSION,JWVER
	INITWORD	LIB_REVISION,JWREV
	INITLONG	LIB_IDSTRING,IDString
	DC.L	0

initRoutine:
	move.l	a5,-(sp)
	move.l	d0,a5
	move.l	a6,jw_SysLib(a5)
	move.l	a0,jw_SegList(a5)
	lea	dosName(pc),a1
	clr.l	d0
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,jw_DosLib(a5)
	bne.s	1$
	ALERT	AG_OpenLib!AO_DOSLib
1$:
	move.l	a5,d0
	move.l	(sp)+,a5
	rts

Open:
	addq.w	#1,LIB_OPENCNT(a6)
	bclr	#LIBB_DELEXP,jw_Flags(a6)
	move.l	a6,d0
	rts

Close:
	clr.l	d0
	subq.w	#1,LIB_OPENCNT(a6)
	bne.s	1$
	btst	#LIBB_DELEXP,jw_Flags(a6)
	beq.s	1$
	bsr	Expunge
1$:
	rts

Expunge:
	movem.l	d2/a5/a6,-(sp)
	move.l	a6,a5
	move.l	jw_SysLib(a5),a6
	tst.w	LIB_OPENCNT(a5)
	beq.s	1$
	bset	#LIBB_DELEXP,jw_Flags(a5)
	clr.l	d0
	bra.s	Expunge_End
1$:
	move.l	jw_SegList(a5),d2
	move.l	a5,a1
	jsr	_LVORemove(a6)
	move.l	jw_DosLib(a5),a1
	jsr	_LVOCloseLibrary(a6)
	clr.l	d0
	move.l	a5,a1
	move.w	LIB_NEGSIZE(a5),d0
	sub.l	d0,a1
	add.w	LIB_POSSIZE(a5),d0
	jsr	_LVOFreeMem(a6)
	move.l	d2,d0
Expunge_End:
	movem.l	(sp)+,d2/a5/a6
	rts

Null:
	clr.l	d0
	rts

Double:
	lsl	#1,d0
	rts

AddThese:
	add.l	d0,d1
	rts

EndCode:

	END