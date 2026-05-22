;****** Auto-Revision Header (do not edit) *******************************
;*
;* © Copyright by MMSoftware
;*
;* Filename         : WinAnim.i
;* Created on       : 01-Sep-93
;* Created by       : M.Meany
;* Current revision : V0.000
;*
;*
;* Purpose: Logo Animation Routine
;*                                                    M.Meany (05-May-93)
;*          
;*
;* V0.000 : --- Initial release ---
;*
;*************************************************************************


; Subroutine for displaying an animated cell in a window or on a screen

;AnimWidth	equ		16		pixel width
;AnimHeight	equ		16		raster height
;AnimDepth	equ		2		depth of underlying screen

; Note that frame pointers should follow the structure itself, so an anim
;comprising of 4 frames will be followed by 5 long words: 4 frame pointers
;and one NULL pointer.

		rsreset
mam_Width	rs.l		1
mam_Height	rs.l		1
mam_Depth	rs.l		1
mam_Bytes	rs.l		1
mam_Rp		rs.l		1
mam_Bm		rs.l		1
mam_Frame	rs.l		1		current fram pointer
mam_SIZE	rs.b		0

;--------------
;--------------	Create and initialise RastPort and BitMap for anim frames
;--------------

;Entry		a0->Anim structure
;Exit		d0=0 if error, else structure will have been initialised
;corrupt	d0

A_InitAnim	movem.l		d1-d7/a0-a6,-(sp)

		move.l		a0,a4

; Allocate memory for a RastPort structure

		moveq.l		#rp_SIZEOF,d0
		move.l		#MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l		d0,mam_Rp(a4)		save RPort addr
		beq		.done

; Allocate memory for a BitMap structure

		moveq.l		#bm_SIZEOF,d0
		move.l		#MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l		d0,mam_Bm(a4)		save RPort addr
		bne.s		.Init
	
	;Memory allocation error, abort!
	
		move.l		mam_Rp(a4),a1		free RastPort
		moveq.l		#rp_SIZEOF,d0
		CALLEXEC	FreeMem

		moveq.l		#0,d0			signal error
		bra.s		.done			and exit!

; Initialise the RastPort

.Init		move.l		mam_Rp(a4),a1
		CALLGRAF	InitRastPort

; Link BitMap to RastPort

		move.l		mam_Rp(a4),a1
		move.l		mam_Bm(a4),a0
		move.l		a0,rp_BitMap(a1)

; Initialise the BitMap, already pointed to by a0!

		move.l		mam_Depth(a4),d0	number of bpl's
		move.l		mam_Width(a4),d1	pixel width
		move.l		mam_Height(a4),d2	raster height
		CALLGRAF	InitBitMap
		
; Determine the number of bytes per bitplane and store in Anim structure

		move.l		mam_Bm(a4),a0		a0->BitMap
		moveq.l		#0,d0
		move.w		bm_BytesPerRow(a0),d0	get raster width
		mulu		bm_Rows(a0),d0		x by number of lines
		move.l		d0,mam_Bytes(a4)	save value

		moveq.l		#1,d0			no errors

.done		movem.l		(sp)+,d1-d7/a0-a6
		rts

;--------------
;--------------	Display next cell
;--------------

;Entry		a0->Anim structure
;		a1->Destination RastPort
;		d0=x coordinate in RastPort
;		d1=y coordinate in RastPort

;Exit		none

;corrupt	none

A_NextFrame	movem.l		d0-d7/a0-a6,-(sp)

; Copy entry parameters into a safe place

		move.l		a0,a4			a4->Anim structure
		move.l		a1,a3			a3->Dest RP
		move.l		d0,d6			d6=X
		move.l		d1,d7			d7=Y

; Get pointer to raw data and stuff into BitMap structure

		move.l		mam_Bm(a4),a0		a0->BitMap
		lea		bm_Planes(a0),a0	a0->pointer storage
		move.l		mam_Depth(a4),d1	number of bitplanes
		subq.w		#1,d1			dbra adjust
		move.l		mam_Bytes(a4),d0	bytes per bpl
		move.l		mam_Frame(a4),a1	a1-Frame pointer
		move.l		(a1)+,d2		d2=addr of 1st bpl
		tst.l		(a1)			last frame?
		bne.s		.ok			no, get on with it!
		lea		mam_SIZE(a4),a1

.ok		move.l		a1,mam_Frame(a4)	save pointer

.loop		move.l		d2,(a0)+		set bpl pointers
		add.l		d0,d2
		dbra		d1,.loop

; Now blit the image into Window/Screen using ClipBlit()

		move.l		mam_Rp(a4),a0		source RastPort
		moveq.l		#0,d0			source x
		moveq.l		#0,d1			source y
		move.l		a3,a1			destination RastPort
		move.l		d6,d2			dest x
		move.l		d7,d3			dest y
		move.l		mam_Width(a4),d4	pixel width
		move.l		mam_Height(a4),d5	raster height
		move.l		#$c0,d6			Minterm for blit
		CALLGRAF	ClipBlit

.done		movem.l		(sp)+,d0-d7/a0-a6
		rts

;--------------
;--------------	Release Anim RastPort and Frames
;--------------

;Entry		a0->Anim structure
;Exit		none
;corrupt	none

A_FreeAnim	movem.l		d0-d3/a0-a6,-(sp)

		move.l		a0,a4

; Free the BitMap structure

		move.l		mam_Bm(a4),d0		get pointer
		beq.s		.done			exit if error
		move.l		d0,a1
		moveq.l		#bm_SIZEOF,d0
		CALLEXEC	FreeMem

; Free the RastPort structure

		move.l		mam_Rp(a4),d0		get pointer
		beq.s		.done			exit if error
		move.l		d0,a1
		moveq.l		#rp_SIZEOF,d0
		CALLEXEC	FreeMem

.done		movem.l		(sp)+,d0-d3/a0-a6
		rts
