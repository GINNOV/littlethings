*	TERMINATOR INTRO. (C) MIKE CROSS  FEBRUARY 1990
*	CODE - MIKE CROSS . GFX - LEE BARKER

*	PLEASE NOTE:
*	THE MUSIC PLAYER HAS BEEN DISABLED. BECAUSE THE PROGRAM NOW
*	HAS ONE LESS ROUTINE TO EXECUTE EVERY FRAME, THE SCROLL WILL
*	RUN FASTER.

*	TO INSERT YOUR OWN SOUNDTRACKER MODULE REMOVE THE `*' FROM
*	LINES 17, 88 AND 549 


 	SECTION TERMINATOR_INTRO,CODE_C

	OPT C-

	*jsr	start_muzak		* Initialise Tune
	clr.w	ScrlFlag1		* Clear Scroll Flags
	clr.w	ScrlFlag2

	move.l 	#credits,d1        	* Read Gfx into planes
	move.w 	d1,cr0l			* for Credits.
	swap 	d1
	move.w 	d1,cr0h
	swap 	d1
	add.l 	#$398,d1 		* Credit plane size          
	move.w 	d1,cr1l
	swap 	d1
	move.w 	d1,cr1h
 	
	move.l 	#screen+$2d0,d0		* Read Arnold Gfx        
	move.w 	d0,pl0l
	swap	d0
	move.w	d0,pl0h
	swap 	d0
	add.l 	#$3e80,d0 		* Main Gfx plane size          
	move.w	d0,pl1l			* 400 x 320 x 5
	swap 	d0
	move.w 	d0,pl1h
 	swap 	d0
	add.l 	#$3e80,d0
	move.w 	d0,pl2l
	swap 	d0
 	move.w 	d0,pl2h
        swap 	d0
        add.l 	#$3e80,d0
	move.w 	d0,pl3l
	swap 	d0
	move.w 	d0,pl3h
	swap 	d0
	add.l 	#$3e80,d0
	move.w 	d0,pl4l
	swap 	d0
	move.w 	d0,pl4h
	
	movem.l a0-a6/d0-d7,-(a7)	* Save all on stack
	move.L   a7,Stackpoint
	
	
kill_OS move.l  $4,a6			* Kill operating system 
	clr.l   d0
	lea     GFXlib(PC),a1
	jsr	-552(a6)		     
	move.l  d0,GFXBase    		     
	jsr	-132(a6)		     
	move.w	$dff002,DMAsave		     
	move.w  #%0111111111111111,$dff096   
	move.l  #COPPER,COP1LCH	     
	move.w  COPJMP1,d0		     
	move.w  #%1000001110000000,$dff096   
	
	lea	$dff144,a0		* Disable sprites
	moveq	#7,d0
sprclr	clr.l	(a0)
	addq.l	#8,a0
	dbf	d0,sprclr
	
	
	
Main	cmpi.b	#200,$dff006		* Vertical blanking interrupt
	bne.s	main
	
	jsr	bouncy			* Every 50th frame
	
	*jsr	replay_muzak
	
	btst	#6,$bfe001		* Left mouse ?
	bne.s	Main

exit	move.w 	DMAsave,d7		* Restore operating system
	bset   	#$f,d7		
	move.w 	d7,$dff096	
	move.l 	GFXbase,a0
	move.l 	$26(a0),$dff080	
	move.l 	$4,a6
	jsr    	-138(a6)		
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.L  Stackpoint,a7
	movem.L (a7)+,A0-a6/d0-D7
	rts
	

bouncy	cmpi 	#125,ScrlFlag1		* Are we going up or down ?
	bne 	up
	cmpi 	#125,ScrlFlag2
	bne 	down 
	clr.w 	ScrlFlag1
	clr.w 	ScrlFlag2
	rts

up      add.w 	#40,pl0l
	add.w 	#40,pl1l
	add.w 	#40,pl2l
	add.w 	#40,pl3l
	add.w 	#40,pl4l
	addq 	#1,ScrlFlag1
	rts

down	sub.w 	#40,pl0l
	sub.w 	#40,pl1l
	sub.w 	#40,pl2l
	sub.w 	#40,pl3l
	sub.w 	#40,pl4l
	addq 	#1,ScrlFlag2
	rts


ScrlFlag1	dc.w 0

ScrlFlag2	dc.w 0


	
*****************************************************************************

COPPER	dc.w	$008e,$2281	
	dc.w 	$0090,$32c1	* Make screen longer, so image scrolls
	dc.w	$0092,$0038	* off the bottom
	dc.w	$0094,$00d0
	dc.w 	$0100,$0200	
	dc.w	$0102,$0000
	dc.w	$0104,$0000
	dc.w	$0108,$0000
	dc.w 	$010a,$0000
	
	dc.w	$0180,$0000,$0182,$0aaa
	dc.w	$0184,$0888,$0186,$0666
	
	dc.w	$2409,$fffe,$0180,$0232
	dc.w	$2509,$fffe,$0180,$0000

	
	dc.w	$2809,$fffe,$0100,$2200
	dc.w	$00e0
cr0h	dc.w	$0000,$00e2
cr0l	dc.w	$0000,$00e4
cr1h	dc.w	$0000,$00e6
cr1l	dc.w	$0000
	dc.w	$3e09,$fffe,$0100,$0000
	
	dc.w	$3f09,$fffe,$0180,$0232
	dc.w	$4009,$fffe,$0180,$0000
	
	
	dc.w 	$4109,$fffe,$0100,$5200
 	
 	dc.w 	$00e0
pl0h	dc.w 	$0000,$00e2
pl0l	dc.w 	$0000,$00e4	
pl1h	dc.w	$0000,$00e6
pl1l	dc.w	$0000,$00e8
pl2h	dc.w	$0000,$00ea
pl2l	dc.w 	$0000,$00ec
pl3h	dc.w 	$0000,$00ee
pl3l	dc.w 	$0000,$00f0
pl4h	dc.w	$0000,$00f2
pl4l	dc.w 	$0000

	dc.w	$0180,$0000,$0182,$0fff,$0184,$0310,$0186
	dc.w	$0410,$0188,$0520,$018a,$0621,$018c,$0731
	dc.w	$018e,$0932,$0190,$0a43,$0192,$0c63,$0194
	dc.w	$0d74,$0196,$0f85,$0198,$0c42,$019a,$0d74
	dc.w	$019c,$0e97,$019e,$0fca,$01a0,$0111,$01a2
	dc.w	$0333,$01a4,$0666,$01a6,$0888,$01a8,$0300
	dc.w	$01aa,$0501,$01ac,$0701,$01ae,$0903,$01b0
	dc.w	$0112,$01b2,$0224,$01b4,$0335,$01b6,$0557
	dc.w	$01b8,$0779,$01ba,$088a,$01bc,$0bbc,$01be
	dc.w	$0dde

     	dc.w 	$ffff,$fffe

*****************************************************************************

COP1LCH =$DFF080
COPJMP1 =$DFF088
Stackpoint:	dc.l	0
GFXlib		dc.b	"graphics.library",0
GFXbase		dc.l	0
SYSstackpoint	dc.l	0

DMAsave		dc.w	0

credits		incbin source_1:bitmaps/Credits.bm
screen		incbin source_1:bitmaps/Arnold.bm


	SECTION	MUSIC_ROUTINE,CODE_C

start_muzak
	move.l	#data,muzakoffset	;** get offset

init0:	move.l	muzakoffset,a0		;** get highest used pattern
	add.l	#472,a0
	move.l	#$80,d0
	clr.l	d1
init1:	move.l	d1,d2
	subq.w	#1,d0
init2:	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	init1
	dbf	d0,init2
	addq.b	#1,d2

init3:	move.l	muzakoffset,a0		;** calc samplepointers
	lea	pointers(pc),a1
	lsl.l	#8,d2
	lsl.l	#2,d2
	add.l	#600,d2
	add.l	a0,d2
	moveq	#14,d0
init4:	move.l	d2,(a1)+
	clr.l	d1
	move.w	42(a0),d1
	lsl.l	#1,d1
	add.l	d1,d2
	add.l	#30,a0
	dbf	d0,init4

init5:	clr.w	$dff0a8			;** clear used values
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.w	timpos
	clr.l	trkpos
	clr.l	patpos

init6:	move.l	muzakoffset,a0		;** initialize timer irq
	move.b	470(a0),numpat+1	;number of patterns
	rts

stop_muzak:
	move.l	lev3save+2,$6c.w
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

lev3interrupt:
	bsr.s	replay_muzak
lev3save:
	jmp	$0

replay_muzak:
	movem.l	d0-d7/a0-a6,-(a7)
	addq.w	#1,timpos
speed:	cmp.w	#6,timpos
	beq.w	replaystep

chaneleffects:				;** seek effects
	lea	datach0(pc),a6
	tst.b	3(a6)
	beq.s	ceff1
	lea	$dff0a0,a5
	bsr.s	ceff5
ceff1:	lea	datach1(pc),a6
	tst.b	3(a6)
	beq.s	ceff2
	lea	$dff0b0,a5
	bsr.s	ceff5
ceff2:	lea	datach2(pc),a6
	tst.b	3(a6)
	beq.s	ceff3
	lea	$dff0c0,a5
	bsr.s	ceff5
ceff3:	lea	datach3(pc),a6
	tst.b	3(a6)
	beq.s	ceff4
	lea	$dff0d0,a5
	bsr.s	ceff5
ceff4:	movem.l	(a7)+,d0-d7/a0-a6
	rts

ceff5:	move.b	2(a6),d0		;room for some more
	and.b	#$f,d0			;implementations below
	tst.b	d0
	beq.s	arpreggiato
	cmp.b	#1,d0
	beq.w	pitchup
	cmp.b	#2,d0
	beq.w	pitchdown
	cmp.b	#12,d0
	beq.w	setvol
	cmp.b	#14,d0
	beq.w	setfilt
	cmp.b	#15,d0
	beq.w	setspeed
	rts

arpreggiato:				;** spread by time
	cmp.w	#1,timpos
	beq.s	arp1
	cmp.w	#2,timpos
	beq.s	arp2
	cmp.w	#3,timpos
	beq.s	arp3
	cmp.w	#4,timpos
	beq.s	arp1
	cmp.w	#5,timpos
	beq.s	arp2
	rts

arp1:	clr.l	d0			;** get higher note-values
	move.b	3(a6),d0		;   or play original
	lsr.b	#4,d0
	bra.s	arp4
arp2:	clr.l	d0
	move.b	3(a6),d0
	and.b	#$f,d0
	bra.s	arp4
arp3:	move.w	16(a6),d2
	bra.s	arp6
arp4:	lsl.w	#1,d0
	clr.l	d1
	move.w	16(a6),d1
	lea	notetable,a0
arp5:	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	beq.s	arp6
	addq.l	#2,a0
	bra.s	arp5
arp6:	move.w	d2,6(a5)
	rts

pitchdown:
	bsr.s	newrou
	clr.l	d0
	move.b	3(a6),d0
	and.b	#$f,d0
	add.w	d0,(a4)
	cmp.w	#$358,(a4)
	bmi.s	ok1
	move.w	#$358,(a4)
ok1:	move.w	(a4),6(a5)
	rts

pitchup:bsr.s	newrou
	clr.l	d0
	move.b	3(a6),d0
	and.b	#$f,d0
	sub.w	d0,(a4)
	cmp.w	#$71,(a4)
	bpl.s	ok2
	move.w	#$71,(a4)
ok2:	move.w	(a4),6(a5)
	rts

setvol:	move.b	3(a6),8(a5)
	rts

setfilt:move.b	3(a6),d0
	and.b	#1,d0
	lsl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

setspeed:
	clr.l	d0
	move.b	3(a6),d0
	and.b	#$f,d0
	move.w	d0,speed+2
	rts

newrou:	cmp.l	#datach0,a6
	bne.s	next1
	lea	voi1(pc),a4
	rts
next1:	cmp.l	#datach1,a6
	bne.s	next2
	lea	voi2(pc),a4
	rts
next2:	cmp.l	#datach2,a6
	bne.s	next3
	lea	voi3(pc),a4
	rts
next3:	lea	voi4(pc),a4
	rts

replaystep:				;** work next pattern-step
	clr.w	timpos
	move.l	muzakoffset,a0
	move.l	a0,a3
	add.l	#12,a3			;ptr to soundprefs
	move.l	a0,a2
	add.l	#472,a2			;ptr to pattern-table
	add.l	#600,a0			;ptr to first pattern
	clr.l	d1
	move.l	trkpos,d0		;get ptr to current pattern
	move.b	(a2,d0),d1
	lsl.l	#8,d1
	lsl.l	#2,d1
	add.l	patpos,d1		;get ptr to current step
	clr.w	enbits
	lea	$dff0a0,a5		;chanel 0
	lea	datach0(pc),a6
	bsr.w	chanelhandler
	lea	$dff0b0,a5		;chanel 1
	lea	datach1(pc),a6
	bsr.w	chanelhandler
	lea	$dff0c0,a5		;chanel 2
	lea	datach2(pc),a6
	bsr.w	chanelhandler
	lea	$dff0d0,a5		;chanel 3
	lea	datach3(pc),a6
	bsr.w	chanelhandler
	move.w	#400,d0			;** wait a while and set len
rep1:	dbf	d0,rep1			;   of oneshot to 1 word
	move.w	#$8000,d0
	or.w	enbits,d0
	move.w	d0,$dff096
	cmp.w	#1,datach0+14
	bne.s	rep2
	clr.w	datach0+14
	move.w	#1,$dff0a4
rep2:	cmp.w	#1,datach1+14
	bne.s	rep3
	clr.w	datach1+14
	move.w	#1,$dff0b4
rep3:	cmp.w	#1,datach2+14
	bne.s	rep4
	clr.w	datach2+14
	move.w	#1,$dff0c4
rep4:	cmp.w	#1,datach3+14
	bne.s	rep5
	clr.w	datach3+14
	move.w	#1,$dff0d4

rep5:	add.l	#16,patpos		;next step
	cmp.l	#64*16,patpos		;pattern finished ?
	bne.s	rep6
	clr.l	patpos
	addq.l	#1,trkpos		;next pattern in table
	clr.l	d0
	move.w	numpat,d0
	cmp.l	trkpos,d0		;song finished ?
	bne.s	rep6
	clr.l	trkpos
rep6:	movem.l	(a7)+,d0-d7/a0-a6
	rts

chanelhandler:
	move.l	(a0,d1.l),(a6)		;get period & action-word
	addq.l	#4,d1			;point to next chanel
	clr.l	d2
	move.b	2(a6),d2		;get nibble for soundnumber
	lsr.b	#4,d2
	beq.s	chan2			;no soundchange !
	move.l	d2,d4			;** calc ptr to sample
	lsl.l	#2,d2
	mulu	#30,d4
	lea	pointers-4(pc),a1
	move.l	(a1,d2.l),4(a6)		;store sample-address
	move.w	(a3,d4.l),8(a6)		;store sample-len in words
	move.w	2(a3,d4.l),18(a6)	;store sample-volume

	move.l	d0,-(a7)
	move.b	2(a6),d0
	and.b	#$f,d0
	cmp.b	#$c,d0
	bne.s	ok3
	move.b	3(a6),8(a5)
	bra.s	ok4
ok3:	move.w	2(a3,d4.l),8(a5)	;change chanel-volume
ok4:	move.l	(a7)+,d0

	clr.l	d3
	move.w	4(a3,d4),d3		;** calc repeatstart
	add.l	4(a6),d3
	move.l	d3,10(a6)		;store repeatstart
	move.w	6(a3,d4),14(a6)		;store repeatlength
	cmp.w	#1,14(a6)
	beq.s	chan2			;no sustainsound !
	move.l	10(a6),4(a6)		;repstart  = sndstart
	move.w	6(a3,d4),8(a6)		;replength = sndlength
chan2:	tst.w	(a6)
	beq.s	chan4			;no new note set !
	move.w	22(a6),$dff096		;clear dma
	tst.w	14(a6)
	bne.s	chan3			;no oneshot-sample
	move.w	#1,14(a6)		;allow resume (later)
chan3:	bsr.w	newrou
	move.w	(a6),(a4)
	move.w	(a6),16(a6)		;save note for effect
	move.l	4(a6),0(a5)		;set samplestart
	move.w	8(a6),4(a5)		;set samplelength
	move.w	(a6),6(a5)		;set period
	move.w	22(a6),d0
	or.w	d0,enbits		;store dma-bit
	move.w	18(a6),20(a6)		;volume trigger
chan4:	rts

datach0:	dcb.w	11,0
		dc.w	1
datach1:	dcb.w	11,0
		dc.w	2
datach2:	dcb.w	11,0
		dc.w	4
datach3:	dcb.w	11,0
		dc.w	8
voi1:		dc.w	0
voi2:		dc.w	0
voi3:		dc.w	0
voi4:		dc.w	0
pointers:	dcb.l	15,0
notetable:	dc.w	856,808,762,720,678,640,604,570
		dc.w	538,508,480,453,428,404,381,360
		dc.w	339,320,302,285,269,254,240,226  
		dc.w	214,202,190,180,170,160,151,143
		dc.w	135,127,120,113,000
muzakoffset:	dc.l	0
trkpos:		dc.l	0
patpos:		dc.l	0
numpat:		dc.w	0
enbits:		dc.w	0
timpos:		dc.w	0
data:		*incbin df0:arnold-intro/mod.Arnie-Tune

