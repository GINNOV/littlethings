		section	trackloader,code_c
		opt	o+,c-,a+

***************************************************************************
* Hardware Disk Tracker Routines                 (Assembles with DEVPAC v2)
* ------------------------------                 --------------------------
*
* These routines allow loading and decoding of disk tracks without the need
* for the operating system, thus allowing it to be killed for memory usage
* purposes. This routine is ideal for multi-part loading, e.g. in games,
* megademos,etc that require ALL memory
*			     ^^^
* Paramters Required :
* --------------------
* TRACKS   = number of tracks to load ( Word length .W)
* TRACKPOS = postion on disk to load from ( Word in length .W)
* then call "SetTrack"
*
* a0 = buffer or memory location to read tracks into
* then call "LoadTracks"
*
***************************************************************************
* Example Call

Kill_OS:	move.l	4.w,a6		  ; get execbase
		jsr	-132(a6)	  ; Forbid () multitasking 

ExampleLoad:	move.w	#0,TRACKPOS	  ; track to load from
		move.w	#4,TRACKS	  ; number of tracks to load
		bsr	SetTrack	  ; set disk heads at desired track
		lea	(LoadBuffer).l,a0 ; load destination
		bsr.s	LoadTracks	  ; read tracks into trackbuffer

Help_OS:	move.l	4.w,a6
		jsr	-138(a6)	  ; turn multitasking back on
		rts

*****************************************************************************
* Define equ's used

_ciaa		equ	$bfe001
_ciab		equ	$bfd100
_ciac		equ	$bfdd00
_custom		equ	$dff000
sync		equ	$4489
dskdatr		equ	$008
dskbytr		equ	$01a
intenar		equ	$01c
intreqr		equ	$01e
dskpth		equ	$020
dsklen		equ	$024
dskdat		equ	$026
dsksync		equ	$07e
dmacon		equ	$096
intena		equ	$09a
intreq		equ	$09c
dmaconr		equ	$002
adkconr		equ	$010
adkcon		equ	$09e

*****************************************************************************
* Reads defined number of tracks into buffer
*****************************************************************************

LoadTracks	lea	(_ciaa).l,a4
		lea	(_ciab).l,a5
		lea	(_custom).l,a6
		bsr	st1
		bsr	st2
		bset	#2,(a5)
		move.l	a0,a3
		move.w	TRACKPOS,d6
		subq.w	#1,d6
		bmi.s	track0
 
		bsr	gettrak
track0		bclr	#1,(a5)
		move.w	TRACKS,d7
		subq.w	#1,d7
readloop	bsr.s	LoadaTrack
		dbra	d7,readloop
 
		bset	#3,(a5)
		bset	#7,(a5)
		bclr	#3,(a5)
		rts	
 
LoadaTrack	bsr.s	readtrack
		bchg	#2,(a5)
		bsr.s	decode
		bsr.s	readtrack
		bchg	#2,(a5)
		bsr	st3
		bsr.s	decode
		rts	
 
readtrack	lea	TrackBuffer(pc),a1
		move.w	#$4000,dsklen(a6)
		move.w	#$1002,intreq(a6)
		move.l	a1,dskpth(a6)
		move.w	#sync,dsksync(a6)
		move.w	#$7F00,adkcon(a6)
		move.w	#$9500,adkcon(a6)
		move.w	#$A000,dsklen(a6)
		move.w	#$A000,dsklen(a6)
		moveq.l	#0,d1
intrwait	move.w	intreqr(a6),d0
		btst	#1,d0
		bne.s	done
 
		addq.l	#1,d1
		cmp.l	#400000,d1
		bne.s	intrwait
 
done		move.w	#$4000,dsklen(a6)
		rts	
 
decode		move.w	#10,d5
		move.l	#"UUUU",d4
chksync		cmp.w	#sync,(a1)+
		bne.s	chksync
 	
		cmp.w	#sync,(a1)
		beq.s	chksync
 	
		move.l	(a1)+,d0
		and.l	d4,d0
		add.l	d0,d0
		move.l	(a1)+,d1
		and.l	d4,d1
		or.l	d1,d0
		add.w	d0,d0
		and.w	#$1E00,d0
		lea	(a3,d0.w),a2
		lea	$02C(a1),a1
		move.l	(a1)+,d2
		move.w	#127,d3
deloop		move.l	512(a1),d1
		eor.l	d1,d2
		move.l	(a1)+,d0
		eor.l	d0,d2
		and.l	d4,d0
		add.l	d0,d0
		and.l	d4,d1
		or.l	d1,d0
		move.l	d0,(a2)+
		dbra	d3,deloop
 
		and.l	d4,d2
		dbra	d5,chksync
 		lea	$1600(a3),a3
		rts	
 
gettrak		bclr	#1,(a5)
twait		bsr.s	st3
		dbra	d6,twait
 		rts	

*****************************************************************************
* Sets track to load from
*****************************************************************************
 	
SetTrack	lea	(_ciaa).l,a4
		lea	(_ciab).l,a5
		lea	(_custom).l,a6
		bsr.s	st1
		bsr.s	st2
		bset	#1,(a5)
		bsr.s	st3
		btst	#4,(a4)
		bne.s	st4
		rts	
 
st1		bset	#3,(a5)
		nop	
		nop	
		nop	
		bclr	#7,(a5)
		nop	
		nop	
		nop	
		bclr	#3,(a5)
		nop	
		nop	
		nop
		rts	
 
st2		btst	#5,(a4)
		bne.s	st2
 		rts	
 
st3		bclr	#0,(a5)
		nop	
		nop	
		nop	
		bset	#0,(a5)
		nop	
		nop	
		nop	
		bsr.s	st5
		bsr.s	st2
		rts	
 
st4		bsr.s	st3
		btst	#4,(a4)
		bne.s	st4
	 	rts	
 
st5		move.w	#3000,d0
st6		dbra	d0,st6
 		rts

*****************************************************************************
* Data Section
*****************************************************************************
		even
trackpos	dc.w	0
tracks		dc.w	0
		even
trackbuffer	dcb.b	$4000,0
		even
LoadBuffer	equ	$40000

