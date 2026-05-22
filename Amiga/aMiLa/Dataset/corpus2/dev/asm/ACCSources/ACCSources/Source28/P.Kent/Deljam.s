	opt	o+,d+
;
; deljam.s
; --------
;
; replaces Delete() with our own patch with a 'deny' requester!
; NEEDS WB20
;
; Set TABS to 4

;	INCLUDE	SYSTEM.GS

	incdir	sys:Include/
	include	exec/exec_lib.i
	include	libraries/dos_lib.i

call	MACRO
	xref	_LVO\1
	jsr	_LVO\1(a6)
	ENDM


	section	"init",code
entry
	move.l	4.w,a6
	lea	dosname(pc),a1
	moveq	#36,d0
	call	OldOpenLibrary
	tst.l	d0
	beq NotDOS2
	move.l	d0,a3					; A3 = DOSLIB
	move.l	d0,a6
	call	Output
	move.l	d0,d7

	move.l	d0,d1
	lea	head(pc),a0
	move.l	a0,d2
	moveq	#headlen,d3
	call	Write

	move.l	_LVODeleteFile+2(a3),a5
	cmp.l	#'DELJ',-8(a5)
	bne.s	install

	move.l	4.w,a6
	move.l	-4(a5),d0
	move.w	#_LVODeleteFile,a0
	move.l	a3,a1
	call	SetFunction
	lea	-12(a5),a0
	move.l	a0,d1
	ror.l	#2,d1
	move.l	a3,a6
	call	UnLoadSeg
	lea	rem(pc),a0
	bra.s	exit

install:
	lea	entry-4(pc),a5
	move.l	(a5),d0
	addq.l	#3,d0
	add.l	d0,d0
	add.l	d0,d0
	move.l	d0,a4	; pointer to new func
	clr.l	(a5)	; kill segment pointer
	move.l	a3,a1
	move.w	#_LVODeleteFile,a0
	move.l	4.w,a6
	call	SetFunction
	move.l	d0,-4(a4)

	lea	ins(pc),a0
exit:
	move.l	d7,d1
	move.l	a3,a6
	move.l	a0,d2
	moveq	#10,d3
	call	Write
	moveq	#0,d0
	rts
NotDOS2	moveq	#5,d0
	rts

dosname	dc.b	"dos.library",0
head	dc.b	$9b,"1mDELJAM",$9b,"0m v1.0 By P.Kent : "
headlen = *-head
ins		dc.b	"installed",10
rem		dc.b	"removed  ",10

	section	"patch",data
id:			dc.l	'DELJ'
oldfunc:	dc.l	0
	movem.l	d0-d7/a0-a6,-(a7)
	moveq		#37,d0	;Open req lib (v37+)
	lea			Reqname(pc),a1
;Openlibrary
	move.l	4.w,a6
	jsr -$228(a6)
	tst.l	d0
	bne.s		Req_ok
;NO lib: Flash screen + recover instead!
	MOVEQ	#-1,D0
Err_nrlp	move.w $dff006,$dff180
	dbra d0,Err_nrlp
	addq.l	#4,a7
	Bra.s	ReqError
Reqname	dc.b 'reqtools.library',0
	even
Req_ok
	move.l		d0,a6
	lea Deltxt(pc),a1
	lea	ErrorGadget(pc),a2
	moveq	#0,d0
	move.l	d0,a3				;no rtReqInfo
	move.l	d0,a4				;no arg array
	lea	ErrorTags(pc),a0		;my taglist
	jsr	-$42(a6)				;_LVOrtEZRequestA(a6)
	move.l	a6,a1
;CloseLibrary
	move.l	4.w,a6
	jsr	-$19e(a6)
;
ReqError
	movem.l	(a7)+,d0-d7/a0-a6
;	move.l oldfunc(pc),-(a7)
	moveq.l	#-1,d0
	rts

Deltxt:		dc.b	"Attempt to delete a file!",$a,"Re-run deljam to remove",0
			even
ErrorGadget:			dc.b	" Sorry ",0
			even
ErrorTags:								; Taglist for Error requester!
			dc.l	$80000000+22		; RTEZ_Flags = tag_user+22
			dc.l	4					; CENTER TEXT

			dc.l	0,0					; TagDone!
