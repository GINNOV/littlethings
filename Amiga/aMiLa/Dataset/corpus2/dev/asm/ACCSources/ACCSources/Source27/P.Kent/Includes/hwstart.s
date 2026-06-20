
	OPT	W-
	 rsreset
SysInts	rs.w 	1
SYsDMA	rs.w 	1
Cop1	rs.l	1
Cop2	rs.l	1
LowMem	rs.b	$c0
InfoSize rs.b 	1

* UPGRADED SO COMPATIBLE WITH WB 2.04.
* NUKES INTS, MORE MODULAR
* P.KENT 23/3/91.
* KNOWS ABOUT WB - USING COMBISTART.S : 2/6/92
* KEYBOARD BACK ON : 6/6/92
* Ability to recover from _main + print an error message
* using reqtools.library (©N.Francois) ; also stack saving : 8/6/92

	list
* HWStart V6 by P.Kent *
	nolist
	Push d1-d7/a0-A6
	Lea SaveSP(pc),a0
	MOVE.L sp,(a0)
	BSR.S	SaveSystem
	IFND	SYSTEM
	BSR	TakeSystem
	MOVE.L	#Except,$80.W
	TRAP	#0
	ENDC
	IFD	SYSTEM
	BSR	_Boot
	ENDC
	BSR	RecoverSystem
Quit
	move.l Savesp(pc),sp
	Pop d1-d7/a0-a6
	MOVEQ   #0,D0
	rts
gfx	dc.b	"graphics.library",0
	even

*****
*Save DMA, lowmem
*****
SaveSystem
	move.l	4.w,a6
	lea	gfx(pc),a1
	moveq	#0,d0
	jsr	-552(a6)					open library
	tst.l	d0						something must be v wrong for no gfx lib!
	beq.S	Quit					abort, stack recovered...

	move.l	d0,a1	 				gfx ptr...
	Lea	SysInfo(pc),a5
	move.l	$26(a1),cop1(a5)	  	copper list ptrs
	move.l	$32(a1),cop2(a5)
	jsr	-414(a6)					close library
	
	lea	custom,a6
	blitwait a6
	move.w	intenar(a6),SysInts(a5)	save system interupts
	move.w	dmaconr(a6),SysDMA(a5)	and DMA settings

	Sub.l	a0,a0					Save low memory...
	LEA	Lowmem(a5),a1
SaveLowMem
	MOVE.L	(A0)+,(A1)+
	CMP.W	#$C0,A0
	BNE.S	SaveLowmem
	RTS

*****
*Kill DMA,nuke int vectors
*****
TakeSystem
	catchpos	a6,200
	move.w	#$7fff,intena(a6) 		kill everything!
	move.w	#$7fff,dmacon(a6)
	lea	null_vector(pc),a0
	lea	$64.W,a1
	moveq	#6,d0
TS_Ints	move.l	a0,(a1)+
	dbra	d0,TS_Ints
; Switch drives off
	or.b		#$f8,CIABPRB
	and.b		#$87,CIABPRB
	or.b		#$f8,CIABPRB
	rts

*****
*Restore low mem,recover DMA
*****
RecoverSystem
	Lea custom,a6
	Lea Sysinfo(pc),a5
	Sub.l	a0,a0					recover low memory...
	LEA	Lowmem(a5),a1
LoadLowMem
	MOVE.L	(A1)+,(A0)+
	CMP.W	#$C0,A0
	BNE.S	LoadLowmem
	move.l	cop1(a5),cop1lch(a6)	reinsert copper lists
	move.l	cop2(a5),cop2lch(a6)
	MOVE.B	#%10011011,CIAAICR		; Keyb etc. back on
	catchvb	a6
	move.w	SysInts(a5),d0
	or.w	#$c000,d0
	move.w	d0,intena(a6)
	move.w	SysDMA(a5),d0
	or.w	#$8100,d0
	move.w	d0,dmacon(a6)
	rts

Except		lea savesp2(pc),a0
			move.l sp,(a0)
			bsr	_boot
			move.l savesp2(pc),sp
Null_Vector	rte


_Error
;Print an error message : a0 = NULL termed string!
;Will recover from _main! (most of the time!)
	IFND	SYSTEM
	move.l savesp2(pc),sp
	lea _Error_2(pc),a1
	move.l	a1,2(sp)
	rte
_Error_2
	ENDC
	MOVE.L A0,-(A7)
	BSR RecoverSystem
	MOVE.L (A7)+,A0
	BSR.S DoRequester
	BRA Quit

;Requester function for HWStart!
;NB Would normally use LOTS of includes for this,
;BUT I dont want to use lots of system includes, on a 'non-system code'
;disk, for a minor use!
;This code can easily be nabbed + reused!
;CALL with A0 = ascii string!

DoRequester
	movem.l	d0-d7/a1-a6,-(a7)
	move.l	a0,-(a7)
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
	dbra d0,err_nrlp
	addq.l	#4,a7
	Bra.s	ReqError
Reqname	dc.b 'reqtools.library',0
	even
Req_ok
	move.l		d0,a6
	move.l (a7)+,a1
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
	movem.l	(a7)+,a1-a6/d0-d7
	rts

ErrorGadget:
			dc.b	"OH NO!",0
			even
ErrorTags:								; Taglist for Error requester!
			dc.l	$80000000+22		; RTEZ_Flags = tag_user+22
			dc.l	4					; CENTER TEXT

			dc.l	0,0					; TagDone!

SaveSp2		ds.l	1
SaveSp		ds.l	1
Sysinfo 	ds.b	 Infosize
			even
	
	OPT	W+
