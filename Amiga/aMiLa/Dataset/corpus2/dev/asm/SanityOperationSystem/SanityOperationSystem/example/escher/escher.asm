; ==========================================================================
;
;  Startupcode for SOS V2.0 (Release 8)
;
; ==========================================================================

; ==========================================================================
;
;  Programm   :
;
;  For Projekt:
;
;  Coder      :
;
;
;  History:
;    21-dez-92: started
;    07-feb-93: SOS V2.0ß
;    15-feb-93: A4000
;    07-jun-93: SOS V2.0
;    20-apr-94: BPR/BPL
;    27-jul-94: english version
;
; ==========================================================================

HARDWARE	equ	$dff002			; gimme hardware labels
;DEBUG		equ	1			; debug stripes
;CHIPMEM	equ	1			; force to chipmem

WAVESIZE	equ	$2000
FADETIME	equ	80
SHOWTIME	equ	160
COLORS		equ	256

		INCLUDE	"include:sos/sos.i"		; general includes
		INCLUDE	"include:sos/sosmacros.i"	; sos macros
		INCLUDE	"include:sos/sine.i"	; sinelist generator
		INCLUDE	"include:sos/agac.i"	; sinelist generator

		SECCODE				; section code
		INITSOS2 Main_C			; sos startup header

; ==========================================================================
;
;  varables definition
;
; ==========================================================================

		rsreset		; Variables
SOSBase		rs.l	1	; library base ptr.
DBUGBase	rs.l	1
SINEBase	rs.l	1
AGACBase	rs.l	1
DrawPl		rs.l	1	; current plane to draw in
Env		rs.l	1	; environment pointer
DBuff		rs.w	1	; counter for double-bufferig
Pad		rs.w	1

DestLastMod	rs.w	1	; destorter: last modulo
DestCount	rs.w	1	; destorter: frame counter for waves

FadePtr		rs.l	1
FadeCnt		rs.w	1

VARS_SIZEOF	rs.w	0	; size of variables

; ==========================================================================
;
;  constant definition
;
; ==========================================================================

XSIZE		equ	320+64		; size of display
YSIZE		equ	284

PLN		equ	4		; number of planes
BPL		equ	XSIZE/8		; size of a line in bytes
ROWS		equ	YSIZE		; number of rows in display

					; Normal Bitmaps
BPR		equ	BPL		; increment to next line
BPP		equ	ROWS*BPR	; increment to next plane

					; Interleaved Bitmaps
;BPR		equ	BPL*PLN		; increment to next line
;BPP		equ	BPL		; increment to next plane


; ==========================================================================
;
;  Startup-Code
;
; ==========================================================================

Main_C
		lea	Vars,a5			; a5 = variablen
		move.l	a6,SOSBase(a5)		; a6 stored

		ENVINIT	ENVFf_Normal,$4000	; init environments

		bsr	Effect_Init		; init effect


		ENVWAIT				; sync effect start


		SETINT	CopLst,Main_I(pc),$20	; set copper & irq
		moveq	#T13_Standard,d0
		trap	#13


.wait		bsr	Effect_Job		; mainloop
		ENVEND	.wait

		moveq	#0,d0			; end
_Rts		rts


; ==========================================================================

Main_I		movem.l	d0-d7/a0-a6,-(a7)
		lea	Vars,a5			; a5 = Vars
		move.l	SOSBase(a5),a6		; a6 = SOSBase

		ENVDO	.end			; standart int handling

		bsr	Effect_Irq		; do your effect

.end		move.w	#$0030,$dff09c		; end of interrupt
		movem.l	(a7)+,d0-d7/a0-a6
		nop				; just to be shure
		rte

; Please don't change the order of the last 4 commands. Don't remove the nop

; ==========================================================================
;
;  initialise your effect
;
; ==========================================================================

Effect_Init:	OPENLIB	SINE			; open sine.soslibrary
		OPENLIB	AGAC
		GENSINUS Sine,SINE_WORD,15,7+4,4 ; create sinelist
						; it is not used, just
						; as an example

		SETCSPR	CopSpr			; reset sprites
		SETCADR	CopPln,0,0,PLN,$e0 	; presette copperlist

		GENLOCK	CopGen1			; set BPLCON0 for genlocks



		jsr	EInitPyramid
		jsr	EInitWaves

		lea	Muster1,a0
		lea	Colors1,a1
		bsr	ConvMuster
		lea	Muster2,a0
		lea	Colors2,a1
		bsr	ConvMuster
;		lea	Muster3,a0
;		lea	Colors3,a1
;		bsr	ConvMuster
;		lea	Muster4,a0
;		lea	Colors4,a1
;		bsr	ConvMuster

		lea	Muster1,a0
		lea	Colors256,a1
		bsr	ConvMuster

		move.l	AGACBase(a5),a4
		lea	CopColA,a0
		jsr	_InitAgaCopper(a4)
		lea	Colors1,a0	
		lea	CopColA,a1
		moveq	#0,d0
		move.w	#256,d1
		jsr	_CopyAgaCopper(a4)


		lea	Colors1,a0
		lea	Colors2,a1
		lea	FadeData1,a2
		move.w	#FADETIME,d0
		jsr	_InitAgaFade(a4)

		lea	Colors2,a0
		lea	Colors3,a1
		lea	FadeData2,a2
		move.w	#FADETIME,d0
		jsr	_InitAgaFade(a4)

		lea	Colors3,a0
		lea	Colors4,a1
		lea	FadeData3,a2
		move.w	#FADETIME,d0
		jsr	_InitAgaFade(a4)

		lea	Colors4,a0
		lea	Colors1,a1
		lea	FadeData4,a2
		move.w	#FADETIME,d0
		jsr	_InitAgaFade(a4)


		move.l	#FadeSeq,FadePtr(a5)
		move.w	#SHOWTIME,FadeCnt(a5)

		move.w	#0,DestCount(a5)
		move.w	#ROWS/2*BPR,DestLastMod(a5)

		bsr	Effect_Irq		; do your effect

		rts



; ==========================================================================
;
;  JOB: this routine is called continously in the mainloop. If your
;       Effect might take more then 1 frame, put it here and syncronise
;	it to the interrupt in some way.
;
; ==========================================================================

Effect_Job	rts				; nothing here

; ==========================================================================
;
;  Interrupt: This routine is calles each VBL. If your effect takes more
; 	      then 1 frame, then put it in the JOB loop and set a flag
;	      at each interrupt for syncronisation. You should count
;	      the interrupts between to pictures of the effect to
;	      syncronise the movements for computers with different 
;	      speed.
;
; ==========================================================================

Effect_Irq:	DEBCOL	$ff0			; debug colors at begin


		move.w	DestCount(a5),d0	; a0 = Wave
		add.w	d0,d0
		add.w	d0,d0
		lea	EWave1,a0
		add.w	d0,a0
		lea	EWave2,a1
		eor.w	#WAVESIZE*4-4,d0
		add.w	d0,a1
		move.w	(a0),d0
		add.w	#BPR,d0
		add.w	d0,DestLastMod(a5)

		movem.l	a0/a1,-(a7)
		lea	EPyramid,a0
		add.w	DestLastMod(a5),a0
		SETCADR	CopPln,a0,BPP,PLN,$e0	; show finished plane
		movem.l	(a7)+,a0/a1

		move.w	(a1),d0
		sub.w	d0,DestLastMod(a5)
		move.w	#ROWS-2,d0		; d0 = Count
		lea	CopIn+6,a2		; a1 = Copperlist
		lea	.bplcon4,a3
		addq.l	#4,a0
		addq.l	#4,a1

.loop		move.l	(a0)+,d1		; write copper
		add.l	(a1)+,d1
		move.w	(a3,d1.w),8(a2)
		swap	d1
		move.w	d1,(a2)
		move.w	d1,4(a2)
		lea	16(a2),a2
		dbf	d0,.loop

		addq.w	#1,DestCount(a5)

		jsr	DoFade

		DEBCOL	$000			; debug color at end

		rts

.bplcon4	dc.w	$0000,$1000,$2000,$3000,$4000,$5000,$6000,$7000
		dc.w	$8000,$9000,$a000,$b000,$c000,$d000,$e000;,$f000
		dc.w	$0000,$1000,$2000,$3000,$4000,$5000,$6000,$7000
		dc.w	$8000,$9000,$a000,$b000,$c000,$d000,$e000;,$f000

DoFade		move.l	AGACBase(a5),a4

		subq.w	#1,FadeCnt(a5)
		move.w	FadeCnt(a5),d0
		bpl.s	.ok
		move.w	#SHOWTIME-1,d0
		move.w	d0,FadeCnt(a5)
		addq.l	#4,FadePtr(a5)
		move.l	FadePtr(a5),a0
		tst.l	(a0)
		bne.s	.ok
		move.l	#FadeSeq,FadePtr(a5)

.ok		cmp.w	#FADETIME-1,d0
		bhi.s	.nofade
		
		move.l	FadePtr(a5),a0
		move.l	(a0),a0
		lea	Colors256,a1
		moveq	#0,d0
		move.w	#COLORS,d1
		jsr	_DoAgaFade(a4)

		lea	Colors256,a0
		lea	CopColA,a1
		moveq	#0,d0
		move.w	#COLORS,d1
		jsr	_CopyAgaCopper(a4)


.nofade		rts


FadeSeq		dc.l	FadeData1,FadeData2,FadeData3,FadeData4,FadeData1,FadeData2,FadeData3,FadeData4,0


; a0 > Colors+Picture 
; a1 > Colors

ConvMuster	movem.l	a2-a4,-(a7)

		lea	1024(a0),a2
		move.w	#256-1,d0
		moveq	#0,d1
.loop		move.b	(a2)+,d1
		move.l	(a0,d1.w*4),(a1)+
		dbf	d0,.loop

		movem.l	(a7)+,a2-a4
		rts

	
; ==========================================================================
;
;  Code:   Put more complex code here.
;
; ==========================================================================

EInitPyramid	movem.l	a5/a6,-(a7)
		lea	EPyramid,a0
		move.l	#BPP,d0
		move.l	a0,a1
		add.l	d0,a1
		move.l	a1,a2
		add.l	d0,a2
		move.l	a2,a3
		add.l	d0,a3

		move.w	#ROWS-1,d0		; d0 = Zeilen
		move.l	#$0020*20,a4		; a4 = Increment
		move.l	#0,a5
.Zeile		move.l	a5,d1			; d1 = Akku
		adda.w	#$0002*4,a4
		suba.w	#$0002*BPL*8*4,a5
		moveq	#BPL/2-1,d3		; d3 = Words
.Spalte:
		REPT	16
		add.w	a4,d1
		move.l	d1,d2			; d2 = Scratch
		add.l	a4,d1			; Calc
		add.w	d2,d2			; Shift
		addx.w	d4,d4
		add.w	d2,d2
		addx.w	d5,d5
		add.w	d2,d2
		addx.w	d6,d6
		add.w	d2,d2
		addx.w	d7,d7
		ENDR
		move.w	d4,(a3)+
		move.w	d5,(a2)+
		move.w	d6,(a1)+
		move.w	d7,(a0)+
		dbf	d3,.Spalte
		dbf	d0,.Zeile

		movem.l	(a7)+,a5/a6
		rts

EInitWaves	movem.l	a5/a6,-(a7)
		lea	EWave1,a2			; a2 = dest
		move.l	#$40000000/WAVESIZE*32,a0	; a0 = Sine1 Freq
		move.l	#$40000000/WAVESIZE*17,a1	; a1 = Sine2 Freq
		move.w	#20*4,d2			; d2 = Sine1 Amp
		move.w	#12*4,d3			; d3 = Sine2 Amp
		move.w	#BPR,a4
		bsr.w	.dowave
	
		lea	EWave2,a2			; a2 = dest
		move.l	#$40000000/WAVESIZE*42,a0	; a0 = Sine1 Freq
		move.l	#$40000000/WAVESIZE*55,a1	; a1 = Sine2 Freq
		move.w	#14*4,d2			; d2 = Sine1 Amp
		move.w	#18*4,d3			; d3 = Sine2 Amp
		move.w	#0,a4
		bsr.w	.dowave
		movem.l	(a7)+,a5/a6
		rts

.dowave		move.l	a2,-(a7)
		move.l	a4,-(a7)
		move.w	#WAVESIZE+ROWS-1,d4		; d4 = Count
		moveq	#0,d0				; d0 = Sine 1 Akku
		moveq	#0,d1				; d1 = Sine 2 Akku
		lea	Sine,a3				; a3 = Sine
		moveq	#0,d7				; d7 = last mod

.loop		move.l	d0,d5				; calc value
		swap	d5
		and.w	#$3ffe,d5
		move.w	(a3,d5.w),d5
		muls.w	d2,d5
		move.l	d1,d6
		swap	d6
		and.w	#$3ffe,d6
		move.w	(a3,d6.w),d6
		muls.w	d3,d6
		add.l	d6,d5
		swap	d5
		move.w	d5,a5
		muls.w	#BPR,d5				; calc modulo
		move.w	d5,d6
		sub.w	d7,d5
		sub.w	a4,d5
		move.w	d5,(a2)+
		move.w	a5,(a2)+
		move.w	d6,d7

		add.l	a0,d0				; next
		add.l	a1,d1		
		dbf	d4,.loop

		move.l	(a7)+,d0		; d0 = flag
		move.l	(a7)+,a0		; a0 = dest
		move.w	#WAVESIZE+ROWS-1,d4	; d4 = Count

		moveq	#0,d0

.loop2		move.l	d0,d1			; 
		clr.w	d1
		swap	d1
		lsr.w	#1,d1
		divu.w	#15,d1
		swap	d1
		add.w	d1,d1
		move.w	(a0)+,d2
		move.w	(a0),d2
		ext.l	d2
		lsl.l	#8,d2
		lsl.l	#2,d2
		move.w	d1,(a0)+
		add.l	#$00010000,d0
		add.l	d2,d0
		dbf	d4,.loop2

.end		rts


Muster1		incbin	"pattern1.mus"
Muster2		incbin	"pattern4.mus"
;Muster3		incbin	"pattern1.mus"
;Muster4		incbin	"pattern2.mus"


; ==========================================================================
;
;  Data:
;
; ==========================================================================


; ==========================================================================
;
;  Copper
;
; ==========================================================================

	SECCODE_C



CopLst
		dc.w	$009c,$8010
		dc.w	$008e,$2061		; set display size
		dc.w	$0090,($40e1+ROWS*$100)&$ffff
		dc.w	$0092,$0018
		dc.w	$0094,$0010+BPL*4-$20
		dc.w	$01fc,$0003


CopColA		ds.b	AGACopSIZE

		dc.w	$1c0f,$fffe
		dc.w	$0096,$800f

CopGen1		dc.w	$0100,$1000*PLN		; set bitplanes
		dc.w	$0102,$8800
		dc.w	$0104,$0000
		dc.w	$0106,$0c00
		dc.w	$0108,0
		dc.w	$010a,0
CopSpr		dcb.l	16			; reset sprites
CopPln		dcb.l	PLN*2			; plane pointer


CopIn:
CNT		SET	$1fdf
		REPT	ROWS
		dc.w	CNT,$fffe		; 2
		dc.w	$0108,0			; 6
		dc.w	$010a,0			; 10
		dc.w	$010c,(CNT&$f000)	; 14
CNT		SET 	(CNT+$100)&$ffff
		ENDR
		dc.w	$ffff,$fffe		; end of frame



	
Zeros		dcb.w	16			; sprite data and other

; ==========================================================================
;
;  Bitmaps and Chip-BSS
;
; ==========================================================================

		SECBSS_C

EPyramid	ds.b	$40000

; ==========================================================================
;
;  General BSS
;
; ==========================================================================

		SECBSS

Sine		ds.b	$4000			; sinelist (not used)
EWave1		ds.l	WAVESIZE+ROWS
		ds.b	32			; cache-entkopplung!
EWave2		ds.l	WAVESIZE+ROWS
Colors1		ds.l	$100
Colors2		ds.l	$100
Colors3		ds.l	$100
Colors4		ds.l	$100
Colors256	ds.l	$100
FadeData1	ds.b	AGAFadeSIZE
FadeData2	ds.b	AGAFadeSIZE
FadeData3	ds.b	AGAFadeSIZE
FadeData4	ds.b	AGAFadeSIZE
Vars		ds.b	VARS_SIZEOF		; variables

; allways put the variables at the last positon to avoid problems with
; word alignment. You should better keep all arrays aligned to 16 bytes,
; to avoid problems with the caches. SOS will allways give you the memory
; aligned to 16 byte.

; ==========================================================================

		END
