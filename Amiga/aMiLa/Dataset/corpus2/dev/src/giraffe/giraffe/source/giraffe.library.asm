*******************************************************************
*                                                                 *
*   giraffe.library.asm -- exec run-time library code             *
*                                                                 *
*   Copyright (C) 1994 Luke Emmert       All rights reserved.     *
*                                                                 *
*******************************************************************

	SECTION	section

	NOLIST
	INCLUDE	"exec/types.i"
	INCLUDE	"exec/libraries.i"
	INCLUDE	"exec/lists.i"
	INCLUDE	"exec/alerts.i"
	INCLUDE	"exec/initializers.i"
	INCLUDE	"exec/resident.i"
	INCLUDE	"libraries/dos.i"

	include	"common.i"

	LIST

CLEAR	MACRO
		MOVEQ	#0,\1
		ENDM

EVEN	MACRO
		DS.W	0
		ENDM

CALLSYS	MACRO
		jsr		_LVO\1(a6)
		ENDM

XLIB	MACRO
		XREF	_LVO\1
		ENDM

	xlib    Remove
	xlib    FreeMem

	xref	_LinkerDB
	xref	_AbsExecBase


Start:
	moveq	#-1,d0
	rts

	; force word allignment
	ds.w	0


**************************************
*                                    *
* giraffe.library function table     *
*                                    *
**************************************

 xdef _funcTable
_funcTable:
	;------ standard system routines
	dc.l	Open
	dc.l	Close
	dc.l	Expunge
	dc.l	Null

	;------ my libraries definitions
	;--primitives...
	dc.l	pixel
	dc.l	pixels
	dc.l	line
	dc.l	lines
	dc.l	polyline
	dc.l	rectangle
	dc.l	rectangles
	dc.l	rectanglefill
	dc.l	rectanglefills
	dc.l	polygon
	dc.l	polygons
	dc.l	arc
	dc.l	arcs
	dc.l	wedge
	dc.l	wedges
	dc.l	spline
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0

	;--blitter functions--
	dc.l	blit
	dc.l	blitmask
	dc.l	blitscale
	dc.l	blitline
	dc.l	0
	dc.l	0

	dc.l	copy
	dc.l	copymask
	dc.l	copyscale
	dc.l	0

	dc.l	template
	dc.l	templatescale
	dc.l	templateline
	dc.l	0

	;--layer functions--
	dc.l	openrootlayer
	dc.l	openlayer
	dc.l	closelayer
	dc.l	ownlayer
	dc.l	disownlayer
	dc.l	uselayer
	dc.l	droplayer

	dc.l	locklayer
	dc.l	unlocklayer
	dc.l	locklayers
	dc.l	unlocklayers

	dc.l	maplayer
	dc.l	unmaplayer

	dc.l	pushlayer
	dc.l	pulllayer
	dc.l	cyclelayer
	dc.l	shufflelayer

	dc.l	sizelayer
	dc.l	movelayer
	dc.l	movesizelayer

	dc.l	beginupdate
	dc.l	endupdate
	dc.l	refreshlayer

	dc.l	whichlayer
	dc.l	layerfromroot
	dc.l	layertoroot

	dc.l	getlayerbitmap
	dc.l	getlayerorigin
	dc.l	getlayersize
	dc.l	getlayerframe
	dc.l	getlayerbounds

	dc.l	getlayerparent
	dc.l	getlayerhead
	dc.l	getlayertail
	dc.l	getlayernext
	dc.l	getlayerprev

	dc.l	getlayerid
	dc.l	getlayerminimum
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0


	; graphics stack.
	dc.l	newstack
	dc.l	disposestack
	dc.l	usestack
	dc.l	interpret
	dc.l	interpretarg
	dc.l	interpretargarg
	dc.l	interpretargargarg
	dc.l	interpretargs
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0

	;--font stuff--
	dc.l	openfont
	dc.l	closefont
	dc.l	text
	dc.l	textlength
	dc.l	justifytext

	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	;--These all need to be moved to appropriate locations--


	;--library objects--


	;------ function table end marker
	dc.l	-1


	; The data table initializes static data structures.
	; The format is specified in exec/InitStruct routine's
	; manual pages.  The INITBYTE/INITWORD/INITLONG routines
	; are in the file "exec/initializers.i".  The first argument
	; is the offset from the library base for this byte/word/long.
	; The second argument is the value to put in that cell.
	; The table is null terminated
	; NOTE - LN_TYPE below is a correction - old example had LH_TYPE

 xref _giraffe_id
 xref _giraffe_name

VERSION  equ 1
REVISION equ 0

 xdef _dataTable
_dataTable:
	INITBYTE	LN_TYPE,NT_LIBRARY
	INITLONG	LN_NAME,_giraffe_name
	INITBYTE	LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
	INITWORD	LIB_VERSION,VERSION
	INITWORD	LIB_REVISION,REVISION
	INITLONG	LIB_IDSTRING,_giraffe_id
	DC.L	0


	; This routine gets called after the library has been allocated.
	; The library pointer is in d0.  The segment list in in a0.
	; If it returns non-zero then the library will be linked inot 
	; the library list
 xdef _initRoutine
_initRoutine:

	;------ get the library pointer into a convenient A register
	move.l	a5,-(sp)
	move.l	d0,a5

	;----- save a pointer to exec
	move.l	a6,gb_SysLib(a5)

	;----- save a pointer to our loaded code
	move.l	a0,gb_SegList(a5)

1$:
	;------ now build the static data that we need
 xref _InitLibrary	; c function for initializing the library.

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	move.l	a5,_GiraffeBase(a4)
	move.l	a6,_SysBase(a4)
	jsr	_InitLibrary

	move.l	(a7)+,a4
	tst.l	d0
	beq	2$

	move.l	a5,d0
	move.l	(sp)+,a5
	rts

2$:
	move.l	(a7)+,a5
	moveq	#0,d0
	rts

;----------------------------------------------------------------
;
; here begins the system interface commands.  When the user calls 
; OpenLibrar/CloseLibrary/RemoveLibrary, this eventually get
; translated into a call to the following routines (Open/Close/
; Expunge).  Exec has already put our library pointer in a6 for
; us.  Exec has turned off task switching while in these rouintes
; (via Forbid/Permit), os we shoot take too long in them.
;
;----------------------------------------------------------------


	; Open returns the library pointer in d0 if the open
	; was successful.  If the open failed then null is returned.
	; It might fail if we allocated memory on each open, or
	; if only open application could have the library open 
	; at a time...

Open:		; ( libptr:a6, version:d0 )

	;------ mark us as having another opener
	addq.w	#1,LIB_OPENCNT(a6)

o_exit:
	move.l	a6,d0
	rts

	; There are two different things that might be returned from 
	; the Close routine.  If the library is no longer open and
	; there is a delayed expunge then Close should return the
	; segment list (as given to Init).  Otherwise close should
	; return NULL.

Close:		; ( libptr:a6 )

	;------ set the return value
	CLEAR	d0

	;------ mark us having one fewer openers
	subq.w	#1,LIB_OPENCNT(a6)

	;------ see if there is anyone left with us open
	bne.w	1$

	;------ do the expunge
	bsr	Expunge
1$:
	rts


	; There are two different things that might be returned from 
	; the Expunge routine.  If the library is no longer opne
	; then Expunge should return the segment list (as given to 
	; INit).  Otherwise Expunge should set the delayed expunge
	; flag and return NULL.
	;
	; One other important note: because Expunge is called from
	; the memory allocator, it may NEVER Wait() or otherwise
	; take long time to complete.

Expunge:	; ( libptr: a6 )

	movem.l	d2/a4/a5/a6,-(sp)
	move.l	a6,a5
	move.l	gb_SysLib(a5),a6

	;------ see if anyone has us open
	tst.w	LIB_OPENCNT(a5)
	bne	Expunge_Abort

	;------ it is still open.  set the delayed expunge flag

1$:
	;------ get ahead and get rid of us.  Store our seglist in d2
	move.l	gb_SegList(a5),d2

	;------ unlink from library list
	move.l	a5,a1
	CALLSYS	Remove

	;
	; device specific closings here...
	;
 xref _ShutDownGiraffe
	lea.l	_LinkerDB,a4
	jsr	_ShutDownGiraffe

	;------ free our memory
	moveq	#0,d0
	move.l	a5,a1
	move.w	LIB_NEGSIZE(a5),d0

	sub.l	d0,a1
	add.w	LIB_POSSIZE(a5),d0

	CALLSYS	FreeMem

	;------ set up our return value
	move.l	d2,d0

Expunge_End:
	movem.l	(sp)+,d2/a4/a5/a6
	rts
Expunge_Abort:
	movem.l	(sp)+,d2/a4/a5/a6
	moveq	#0,d0
	rts

Null:
	CLEAR	d0
	rts

;-------------------------------------------------------------------
;
; Here begins the library specific functions.
;
; Both of these simple functions are entirely in assembler, but you
; can write your functions in C if you wish and interface to them here.
; If, for instance, the bulk of the AddThese function was written
; in C, you could interface to it as follows:
;
;	- write a Cfunction  addTheseC(n1,n2) and compile it
;   - XDEF _addThereC in this library code
;	- change the AddThese function code below to:
;		move.l	d1,-(sp)		; push rightmost C arg first
;		move.l	d0,-(sp)		; push other C arg(s), right to left
;		jsr		_addTheseC		; call the C code
;		addq	#8,sp			; fix stack
;		rts						; return with result in d0
;
;--------------------------------------------------------------------

* This macro was created for losers who pass null pointers
* as objects.
RETURN_ON_NULL MACRO
	cmpa.l	#0,\1
	beq	return_zero
	ENDM

BRANCH_IF_LAYER MACRO
	move.l	a0,d0
	cmp.w	obj_match-obj_SIZEOF(a0),d0
	bne	5$
	cmp.b	#GT_Layer,obj_type-obj_SIZEOF(a0)
	beq	\1
5$:
	pea.l	$0.w        ; push NULL for cliplist.
	ENDM

CHECK_OBJECT MACRO
	moveq	#0,d0
	move.l	a0,d1
	cmp.w	obj_match-obj_SIZEOF(a0),d1
	bne	1$
	cmp.b	#\1,obj_type-obj_SIZEOF(a0)
	bne	1$
	jsr	\2
1$:
	ENDM

CHECK_FONT MACRO
	moveq	#-1,d0
	move.l	a0,d1
	cmp.w	obj_match-obj_SIZEOF(a0),d1
	bne	\1
	cmp.b	#GT_Font,obj_type-obj_SIZEOF(a0)
	bne	\1
	ENDM
	
	
CHECK_OBJECT2 MACRO
	moveq	#0,d0
	move.l	a0,d1
	cmp.w	obj_match-obj_SIZEOF(a0),d1
	bne	1$
	cmp.b	#\1,obj_type-obj_SIZEOF(a0)
	bne	1$
	move.l	a1,d1
	cmp.w	obj_match-obj_SIZEOF(a1),d1
	bne	1$
	cmp.b	#\2,obj_type-obj_SIZEOF(a1)
	bne	1$
	jsr	\3
1$:
	ENDM



	;
	; Library object/resource calls.
	;
	;
	; geometrical primitive stubs.
	;
 xref _lpixel
 xref _lline
 xref _llines
 xref _lrectangle
 xref _lrectangles
 xref _lrectanglefill
 xref _lrectanglefills
 xref _lpolygon
 xref _lpolygons
 xref _larc
 xref _larcs
 xref _lwedge
 xref _lwedges
 xref _lspline

 xref _pixel
 xref _line
 xref _lines
 xref _rectangle
 xref _rectangles
 xref _rectanglefill
 xref _rectanglefills
 xref _polygon
 xref _polygons
 xref _arc
 xref _arcs
 xref _wedge
 xref _wedges
 xref _spline

pixel:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	movem.l	d0-d1,-(a7)
	movem.l	a0-a1,-(a7)
	BRANCH_IF_LAYER 2$

	jsr	_pixel
	lea.l	20(a7),a7
	move.l	(a7)+,a4
	rts
2$:
	jsr	_lpixel
	lea.l	16(a7),a7
	move.l	(a7)+,a4
pixel_exit:
	rts

pixels:
	rts

line:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	d0-d3,-(a7)
	movem.l	a0-a1,-(a7)
	BRANCH_IF_LAYER 2$

	jsr	_line
	lea.l	28(a7),a7
	move.l	(a7)+,a4
	rts
2$:
	jsr	_lline
	lea.l	24(a7),a7
	move.l	(a7)+,a4
line_exit:
	rts

lines:
	rts
polyline:
	rts

rectangle:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	d0-d3,-(a7)
	movem.l	a0-a1,-(a7)
	BRANCH_IF_LAYER 6$

	jsr	_rectangle
	lea.l	28(a7),a7
	move.l	(a7)+,a4
	rts
6$:
	jsr	_lrectangle
	lea.l	24(a7),a7
	move.l	(a7)+,a4
rectangle_exit:
	rts

rectangles:
	rts

rectanglefill:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	d0-d3,-(a7)
	movem.l	a0-a1,-(a7)
	BRANCH_IF_LAYER 6$

	jsr	_rectanglefill
	lea.l	28(a7),a7
	move.l	(a7)+,a4
	rts
6$:
	jsr	_lrectanglefill
	lea.l	24(a7),a7
	move.l	(a7)+,a4
rectanglefill_exit:
	rts

rectanglefills:
	rts

polygon:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	move.l	d0,-(a7)
	movem.l	a0-a2,-(a7)
	BRANCH_IF_LAYER 6$

	jsr	_polygon
	lea.l	20(a7),a7
	move.l	(a7)+,a4
	rts
6$:
	jsr	_lpolygon
	lea.l	16(a7),a7
	move.l	(a7)+,a4
polygon_exit:
	rts

polygons:
	rts

arc:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	d0-d5,-(a7)
	movem.l	a0-a1,-(a7)
	BRANCH_IF_LAYER 6$

	jsr	_arc
	lea.l	36(a7),a7
	move.l	(a7)+,a4
	rts
6$:
	jsr	_larc
	lea.l	32(a7),a7
	move.l	(a7)+,a4
arc_exit:
	rts

arcs:
	rts

wedge:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	d0-d5,-(a7)
	movem.l	a0-a1,-(a7)
	BRANCH_IF_LAYER 6$

	jsr	_wedge
	lea.l	36(a7),a7
	move.l	(a7)+,a4
	rts
6$:
	jsr	_lwedge
	lea.l	32(a7),a7
	move.l	(a7)+,a4
wedge_exit:
	rts

wedges:
	rts

spline:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	a0-a2,-(a7)
	BRANCH_IF_LAYER 6$

	jsr	_spline
	lea.l	16(a7),a7
	move.l	(a7)+,a4
	rts
6$:
*	jsr	_lspline
	lea.l	12(a7),a7
	move.l	(a7)+,a4
spline_exit:
	rts

	;
	; library bitblit functions
	;
 xref _lblit
 xref _lblitmask
 xref _lblitscale
 xref _lblitline

 xref _blit
 xref _blitmask
 xref _blitscale
 xref _blitline

blit:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	d4-d5,-(a7)
	movem.l	d0-d3/a2,-(a7)
	movem.l	a0-a1,-(a7)
	BRANCH_IF_LAYER 6$

	jsr	_blit
	lea.l	40(a7),a7
	move.l	(a7)+,a4
	rts
6$:
	jsr	_lblit
	lea.l	36(a7),a7
	move.l	(a7)+,a4
blit_exit:
	rts


blitmask:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	d6-d7,-(a7)
	movem.l	d4-d5/a3,-(a7)
	movem.l	d0-d3/a2,-(a7)
	movem.l	a0-a1,-(a7)
	BRANCH_IF_LAYER 6$

*	jsr	_blitmask
	lea.l	52(a7),a7
	move.l	(a7)+,a4
	rts
6$:
	jsr	_lblitmask
	lea.l	48(a7),a7
	move.l	(a7)+,a4
blitmask_exit:
	rts

blitscale:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	d4-d7,-(a7)
	movem.l	d0-d3/a2,-(a7)
	movem.l	a0-a1,-(a7)
	BRANCH_IF_LAYER 6$

*	jsr	_blitscale
	lea.l	48(a7),a7
	move.l	(a7)+,a4	
	rts
6$:
	jsr	_lblitscale
	lea.l	44(a7),a7
	move.l	(a7)+,a4
blitscale_exit:
	rts

blitline:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	d3-d4,-(a7)
	movem.l	d0-d2/a2,-(a7)
	movem.l	a0-a1,-(a7)
	BRANCH_IF_LAYER 6$

*	jsr	_blitline
	lea.l	40(a7),a7
	move.l	(a7)+,a4	
	rts
6$:
	jsr	_lblitline
	lea.l	36(a7),a7
	move.l	(a7)+,a4
blitline_exit:
	rts


copy:
copymask:
copyscale:
	rts

 xref _ltemplate
 xref _ltemplatescale
 xref _ltemplateline

 xref _template
 xref _templatescale
 xref _templateline

template:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	d4-d5,-(a7)
	movem.l	d0-d3/a2,-(a7)
	movem.l	a0-a1,-(a7)
	BRANCH_IF_LAYER 6$

	jsr	_template
	lea.l	40(a7),a7
	move.l	(a7)+,a4
	rts
6$:
	jsr	_ltemplate
	lea.l	36(a7),a7
	move.l	(a7)+,a4
template_exit:
	rts

templatescale:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	d4-d7,-(a7)
	movem.l	d0-d3/a2,-(a7)
	movem.l	a0-a1,-(a7)
	BRANCH_IF_LAYER 6$

*	jsr	_templatescale
	lea.l	48(a7),a7
	move.l	(a7)+,a4
	rts
6$:
	jsr	_ltemplatescale
	lea.l	44(a7),a7

	move.l	(a7)+,a4
templatescale_exit:
	rts

templateline:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	d3-d4,-(a7)
	movem.l	d0-d2/a2,-(a7)
	movem.l	a0-a1,-(a7)
	BRANCH_IF_LAYER 6$

*	jsr	_templateline
	lea.l	40(a7),a7
	move.l	(a7)+,a4
	rts
6$:
	jsr	_ltemplateline
	lea.l	36(a7),a7
	move.l	(a7)+,a4
templateline_exit:
	rts

	;
	; layer functions.
	;
 xref _openrootlayer
 xref _openlayer
 xref _closelayer
 xref _uselayer
 xref _droplayer
 xref _ownlayer
 xref _disownlayer
 xref _locklayer
 xref _locklayers
 xref _unlocklayer
 xref _unlocklayers
 xref _maplayer
 xref _unmaplayer
 xref _pushlayer
 xref _pulllayer
 xref _cyclelayer
 xref _shufflelayer
 xref _sizelayer
 xref _movelayer
 xref _movesizelayer
 xref _refreshparent
 xref _whichlayer
 xref _beginupdate
 xref _endupdate
 xref _layerrelative
 xref _getlayerparent
 xref _getlayerbitmap
 xref _getlayerorigin
 xref _getlayersize
 xref _getlayerframe
 xref _getlayerbounds
 xref _getlayerminimum
 xref _getlayerhead
 xref _getlayertail
 xref _getlayernext
 xref _getlayerprev
 xref _getlayerid


return_zero:
	moveq	#0,d0
	rts

openrootlayer:
	RETURN_ON_NULL a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	movem.l	a0-a1,-(a7)
	jsr	_openrootlayer
	addq	#8,a7

	move.l	(a7)+,a4
	rts

openlayer_skip:
	moveq	#0,d0
	rts

openlayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	
	movem.l	a0-a1,-(a7)
	CHECK_OBJECT GT_Layer,_openlayer
	addq	#8,a7
	
	move.l	(a7)+,a4
	rts
	

closelayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_closelayer
	addq	#4,a7

	move.l	(a7)+,a4
	rts

uselayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_uselayer
	addq	#4,a7
	move.l	(a7)+,a4
	rts

droplayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_droplayer
	addq	#4,a7
	move.l	(a7)+,a4
	rts

ownlayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_ownlayer
	addq	#4,a7
	move.l	(a7)+,a4
	rts

disownlayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_disownlayer
	addq	#4,a7
	move.l	(a7)+,a4
	rts

locklayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_locklayer
	addq	#4,a7
	move.l	(a7)+,a4
	rts

locklayers:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_locklayers
	addq	#4,a7
	move.l	(a7)+,a4
	rts

unlocklayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_unlocklayer
	addq	#4,a7
	move.l	(a7)+,a4
	rts

unlocklayers:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_unlocklayers
	addq	#4,a7
	move.l	(a7)+,a4
	rts

maplayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_maplayer
	addq	#4,a7

	move.l	(a7)+,a4
	rts

unmaplayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_unmaplayer
	addq	#4,a7

	move.l	(a7)+,a4
	rts

pushlayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_pushlayer
	addq	#4,a7

	move.l	(a7)+,a4
	rts

pulllayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_pulllayer
	addq	#4,a7

	move.l	(a7)+,a4
	rts

cyclelayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_cyclelayer
	addq	#4,a7

	move.l	(a7)+,a4
	rts

shufflelayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	move.l	a1,-(a7)
	CHECK_OBJECT GT_Layer,_shufflelayer
	addq	#8,a7

	move.l	(a7)+,a4
	rts

sizelayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	d1,-(a7)
	move.l	d0,-(a7)
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_sizelayer
	lea.l	12(a7),a7

	move.l	(a7)+,a4
	rts

movelayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	d1,-(a7)
	move.l	d0,-(a7)
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_movelayer
	lea.l	12(a7),a7

	move.l	(a7)+,a4
	rts

movesizelayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	d3,-(a7)
	move.l	d2,-(a7)
	move.l	d1,-(a7)
	move.l	d0,-(a7)
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_movesizelayer
	lea.l	20(a7),a7

	move.l	(a7)+,a4
	rts

* This function is special since the names
* may get a bit confusing.  refreshlayer() in
* layers.c is only for complete layer (ie all
* clipping).  refreshparent() can be used with
* any layers.  I have to load the stack with
* NULLs because this function takes more than
* one argument.
refreshlayer:
	RETURN_ON_NULL   a0
	
	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	pea.l	$0.w     ; UPDATE = NULL.
	pea.l	$0.w     ; except = NULL.
	pea.l	$0.w     ; damage = NULL.
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_refreshparent
	lea.l	16(a7),a7

	move.l	(a7)+,a4
	rts

whichlayer:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	movem.l	a0/a1,-(a7)
	CHECK_OBJECT GT_Layer,_whichlayer
	addq	#8,a7

	move.l	(a7)+,a4
	rts

beginupdate:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_beginupdate
	addq	#4,a7

	move.l	(a7)+,a4
	rts

endupdate:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_endupdate
	addq	#4,a7

	move.l	(a7)+,a4
	rts

layerfromroot:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	a1,-(a7)
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_layerrelative
	addq	#8,a7

	move.l	(a7)+,a4
	rts

layertoroot:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	a1,-(a7)
	move.l	a0,-(a7)
*	CHECK_OBJECT GT_Layer,_layerrelative
	addq	#8,a7

	move.l	(a7)+,a4
	rts






getlayerparent:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)	
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_getlayerparent
	addq	#4,a7

	move.l	(a7)+,a4
	rts

getlayerbitmap:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)	
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_getlayerbitmap
	addq	#4,a7

	move.l	(a7)+,a4
	rts

getlayerorigin:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)	
	lea.l	_LinkerDB,a4

	move.l	d0,-(a7)
	move.l	a1,-(a7)
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_getlayerorigin
	lea.l	12(a7),a7

	move.l	(a7)+,a4
	rts

getlayersize:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)	
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_getlayersize
	addq	#4,a7

	move.l	(a7)+,a4
	rts

getlayerframe:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)	
	lea.l	_LinkerDB,a4

	move.l	d0,-(a7)
	movem.l	a0-a1,-(a7)
	CHECK_OBJECT GT_Layer,_getlayerframe
	lea.l	12(a7),a7

	move.l	(a7)+,a4
	rts

getlayerbounds:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)	
	lea.l	_LinkerDB,a4

	movem.l	a0-a1,-(a7)
	CHECK_OBJECT GT_Layer,_getlayerbounds
	addq	#8,a7
	move.l	(a7)+,a4
	rts

getlayerminimum:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)	
	lea.l	_LinkerDB,a4

	movem.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_getlayerminimum
	addq	#4,a7
	move.l	(a7)+,a4
	rts

getlayerhead:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_getlayerhead
	addq	#4,a7
	move.l	(a7)+,a4
	rts

getlayertail:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_getlayertail
	addq	#4,a7
	move.l	(a7)+,a4
	rts

getlayernext:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_getlayernext
	addq	#4,a7
	move.l	(a7)+,a4
	rts

getlayerprev:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_getlayerprev
	addq	#4,a7
	move.l	(a7)+,a4
	rts
	
getlayerid:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4
	movem.l	a0,-(a7)
	CHECK_OBJECT GT_Layer,_getlayerid
	addq	#4,a7
	move.l	(a7)+,a4
	rts
	

	;
	; font/glyph functions
	;

 xref _openfont
 xref _closefont
 xref _text
 xref _ltext
 xref _textlength
 xref _clearswath
 xref _justifytext

openfont:
	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	d0,-(a7)
	move.l	a0,-(a7)
	jsr	_openfont
	addq	#8,a7

	move.l	(a7)+,a4
	rts


closefont:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	CHECK_OBJECT GT_Font,_closefont
	addq	#4,a7

	move.l	(a7)+,a4
	rts



text:
	RETURN_ON_NULL  a0
	RETURN_ON_NULL  a1

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	d2,-(a7)
	move.l	a3,-(a7)
	move.l	d1,-(a7)
	move.l	d0,-(a7)
	move.l	a2,-(a7)
	move.l	a1,-(a7)
	move.l	a0,-(a7)

	CHECK_FONT	7$

	move.l	a1,a0		; i'll have to change macro.
	BRANCH_IF_LAYER 6$

	jsr	_text
	addq	#4,a7
	bra	7$
	nop
6$:
	jsr	_ltext
7$:
	lea.l	28(a7),a7

	move.l	(a7)+,a4
	rts




textlength:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	d0,-(a7)
	movem.l	a0/a1/a2,-(a7)
	CHECK_OBJECT GT_Font,_textlength
	lea.l	16(a7),a7

	move.l	(a7)+,a4
	rts

justifytext:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	movem.l	d0-d3,-(a7)
	move.l	a2,-(a7)
	move.l	a1,-(a7)
	move.l	a0,-(a7)
	CHECK_OBJECT GT_Font,_justifytext
	lea.l	24(a7),a7

	move.l	(a7)+,a4
	rts


 xref _lclearswath
clearswath:
	RETURN_ON_NULL  a0
	RETURN_ON_NULL  a1

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	movem.l	d0/d1,-(a7)
	movem.l	a0-a2,-(a7)
	CHECK_OBJECT GT_Font,_lclearswath
	lea.l	20(a7),a7

	move.l	(a7)+,a4
	rts

*
* Stack Stubs:
*

 xref _newstack
 xref _disposestack
 xref _usestack
 xref _beginstack

newstack:
	RETURN_ON_NULL  a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	movem.l	a0/a1,-(a7)
	jsr	_newstack
	addq	#8,a7

	move.l	(a7)+,a4
	rts

disposestack:
	RETURN_ON_NULL	a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	CHECK_OBJECT	GT_Stack,_disposestack
	addq	#4,a7

	move.l	(a7)+,a4
	rts

usestack:
	RETURN_ON_NULL	a0

	move.l	a4,-(a7)
	lea.l	_LinkerDB,a4

	move.l	a0,-(a7)
	CHECK_OBJECT	GT_Stack,_usestack
	addq	#4,a7

	move.l	(a7)+,a4
	rts

interpret:
	RETURN_ON_NULL a0
	RETURN_ON_NULL a1

	movem.l	d2-d7/a2-a6,-(a7)
	lea.l	_LinkerDB,a4

	subq	#4,a7		; mark the stack in case
	move.l	a7,(a7)		; of error.

	pea.l	$0.w
	pea.l	$0.w
	move.l	a1,-(a7)
	move.l	a0,-(a7)
	CHECK_OBJECT2	GT_Layer,GT_Stack,_beginstack
	lea.l	20(a7),a7

	movem.l	(a7)+,d2-d7/a2-a6
	rts

interpretarg:
	RETURN_ON_NULL a0
	RETURN_ON_NULL a1

	movem.l	d2-d7/a2-a6,-(a7)
	lea.l	_LinkerDB,a4
	
	subq	#4,a7
	move.l	a7,(a7)

	move.l	d0,-(a7)
	move.l	a7,-(a7)    ; argv
	pea.l	$1.w		; argc
	move.l	a1,-(a7)
	move.l	a0,-(a7)
	CHECK_OBJECT2	GT_Layer,GT_Stack,_beginstack
	lea.l	24(a7),a7

	movem.l	(a7)+,d2-d7/a2-a6
	rts
	
interpretargarg:
	RETURN_ON_NULL a0
	RETURN_ON_NULL a1

	movem.l	d2-d7/a2-a6,-(a7)
	lea.l	_LinkerDB,a4
	
	subq	#4,a7
	move.l	a7,(a7)

	move.l	d1,-(a7)	; second argument.
	move.l	d0,-(a7)        ; first argument.
	move.l	a7,-(a7)        ; argv
	pea.l	$2.w		; argc
	move.l	a1,-(a7)
	move.l	a0,-(a7)
	CHECK_OBJECT2	GT_Layer,GT_Stack,_beginstack
	lea.l	28(a7),a7

	movem.l	(a7)+,d2-d7/a2-a6
	rts
	
interpretargargarg:
	RETURN_ON_NULL a0
	RETURN_ON_NULL a1

	movem.l	d2-d7/a2-a6,-(a7)
	lea.l	_LinkerDB,a4
	
	subq	#4,a7
	move.l	a7,(a7)

	move.l	d2,-(a7)	; third argument.
	move.l	d1,-(a7)	; second argument.
	move.l	d0,-(a7)	; first argument.
	move.l	a7,-(a7)	; argv
	pea.l	$3.w		; argc
	move.l	a1,-(a7)
	move.l	a0,-(a7)
	CHECK_OBJECT2	GT_Layer,GT_Stack,_beginstack
	lea.l	32(a7),a7

	movem.l	(a7)+,d2-d7/a2-a6
	rts

interpretargs:
	RETURN_ON_NULL  a0
	RETURN_ON_NULL  a1
	
	movem.l	d2-d7/a2-a6,-(a7)
	lea.l	_LinkerDB,a4
	
	subq	#4,a7
	move.l	a7,(a7)

	move.l	a2,-(a7)	; argv
	move.l	d0,-(a7)	; argc
	move.l	a1,-(a7)
	move.l	a0,-(a7)
	CHECK_OBJECT2	GT_Layer,GT_Stack,_beginstack
	lea.l	20(a7),a7

	movem.l	(a7)+,d2-d7/a2-a6
	rts
	

*
* This function is to break out of a
* stack durint operation in case of an
* error.  First we need to find where
* we marked the stack.  Then reset
* all of the registers and return.
_break:
loop:
	addq	#4,a7
	move.l	(a7),d1
	cmpa.l	d1,a7
	bne	loop
	addq	#4,a7
	movem.l	(a7)+,d2-d7/a2-a6
	rts


	; EndCode is a marker that show the end of your code
	; Make sure it does not space sections nor is before the 
	; rom tag in memory!  It is ok to put it right after
	; the rom tag -- that way you are always safe.  I put
	; it here because it happens to be the "right" thing
	; to do, and I know that it is safe in this case.
 xdef _EndCode
_EndCode:

 csect __MERGED,2
	xdef	_SysBase
	xdef	_GiraffeBase
	xdef	_EGSBase
	xdef   	_EGSBlitBase
	xdef 	_UtilityBase
	xdef 	_GfxBase

_SysBase:	ds.b	4
_GiraffeBase:	ds.b	4
_EGSBase:	ds.b	4
_EGSBlitBase:	ds.b	4
_UtilityBase:   ds.b	4
_GfxBase	ds.b	4

	END


