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

FuckSinCount	rs.l	1
JumpOffset	rs.l	1

VARS_SIZEOF	rs.w	0	; size of variables

; ==========================================================================
;
;  constant definition
;
; ==========================================================================

XSIZE		equ	320		; size of display
YSIZE		equ	256

COLORS		equ	32
PLN		equ	5		; number of planes
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

Main_C		lea	Vars,a5			; a5 = variablen
		move.l	a6,SOSBase(a5)		; a6 stored

		ENVINIT	ENVFf_Normal,$4000	; init environments

		bsr	Effect_Init		; init effect

		ENVWAIT				; sync effect start

		SETINT	CopLst,Main_I(pc),$10	; set copper & irq
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

Effect_Init:    OPENLIB	SINE			; open sine.soslibrary
		OPENLIB	AGAC
		GENSINUS Sine,SINE_WORD,15,7+4,4 ; create sinelist
						; it is not used, just
						; as an example

		SETCSPR	CopSpr			; reset sprites

		GENLOCK	CopGen1			; set BPLCON0 for genlocks


		move.l	#Piccy,d0
		lea	CopPln,a0
		rept	5
		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		addq.l	#8,a0
		add.l	#BPP,d0
		endr

                move.l	#PlaneEmpty,d0
		lea     CopPln2,a0
		rept	1
		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		addq.l	#8,a0
		endr



		move.l	AGACBase(a5),a4		; Prepare fading


		lea	Colors1+COLORS*4,a0
		move.w	#COLORS-1,d0
		move.l	#$00fce0,d1
.setcol		move.l	d1,(a0)+
		dbf	d0,.setcol


		lea	CopColA,a0
		jsr	_InitAgaCopper(a4)

		lea	Colors1,a0
		lea	CopColA,a1
		moveq	#0,d0
		move.w	#256,d1
		jsr	_CopyAgaCopper(a4)


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

		move.l	#Piccy,d0
		add.l	JumpOffset(a5),d0
		lea	CopPln,a0
		rept	5
		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		addq.l	#8,a0
		add.l	#BPP,d0
		endr



		lea	DBuff(a5),a0		; double buffering
		lea	.List(pc),a1
		moveq	#2,d0
		jsr	_DoubleBuffer(a6)


		move.l	(a0)+,DrawPl(a5)	; set draw plane
		move.l	(a0),d0
		move.w  d0,CopPln2+6
		swap	d0
		move.w  d0,CopPln2+2

		DEBCOL	$000			; debug color at end

		jsr	FuckSin

		rts

.List		dc.l	Plane1a			; liste der planes
		dc.l	Plane1b
		dc.l	Plane1a			; and again.
		dc.l	Plane1b

; ==========================================================================
;
;  Code:   Put more complex code here.
;
; ==========================================================================

FuckSin         ;rts

		move.l	DrawPl(a5),a0
                move.w	#BPR*ROWS/4-1,d0
                moveq	#0,d1
.loopi		move.l	d1,(a0)+
		dbf	d0,.loopi

		
		move.w	FuckSinCount(a5),d0
		add.l	#$100000/5,FuckSinCount(a5)

		not.w	d0
		and.w	#$3f,d0				; d0 = Count

		move.w	d0,d1				; d1 = ampl
		muls.w	#$3000,d1
		swap	d1
		lsl.w	#4,d1

		move.w	d0,d2				; d2 = Offset
		muls.w	#1400,d2


		move.l	#319,d3				; d3 = count
		move.l	DrawPl(a5),a0			; a0 = plane
		adda.w	#BPR*ROWS/2,a0
		lea	Sine,a1				; a1 = Sine
.loop		and.w	#$3ffe,d2
		move.w	(a1,d2.w),d4			; d4 = akku
		add.w	#100,d2
		muls.w	d1,d4
		swap	d4
		muls.w	#BPR,d4
		bfset	(a0,d4.l){d3:1}
		bfset	-2*BPR(a0,d4.l){d3:1}
		bfset	+1*BPR(a0,d4.l){d3:1}
		bfset	+2*BPR(a0,d4.l){d3:1}

		subq.w	#1,d3
		bmi.s	.end

		and.w	#$3ffe,d2
		move.w	(a1,d2.w),d4			; d4 = akku
		add.w	#100,d2
		muls.w	d1,d4
		swap	d4
		muls.w	#BPR,d4
		bfset	(a0,d4.l){d3:1}
		bfset	-2*BPR(a0,d4.l){d3:1}
		bfset	-1*BPR(a0,d4.l){d3:1}
		bfset	+2*BPR(a0,d4.l){d3:1}

		dbf	d3,.loop


.end
		move.w	FuckSinCount(a5),d0
		not.w	d0
		and.w	#$3f,d0				; d0 = Count

		move.w	d0,d1				; d1 = ampl
		muls.w	#$4500,d1
		swap	d1

		move.w	d0,d2				; d2 = Offset
		muls.w	#1000,d2

		and.w	#$3ffe,d2
		move.w	(a1,d2.w),d4			; d4 = akku
		muls.w	d1,d4
		swap	d4
		muls.w	#BPR,d4
		move.l	d4,JumpOffset(a5)



		move.w	FuckSinCount(a5),d0
		not.w	d0
		and.w	#$3f,d0				; d0 = Count

		move.w	d0,d1				; d1 = ampl
		muls.w	#$4000,d1
		swap	d1

		move.w	d0,d2				; d2 = Offset
		muls.w	#1000,d2

		add.w	#$e00,d2
		and.w	#$3ffe,d2
		move.w	(a1,d2.w),d4			; d4 = akku
		muls.w	d1,d4
		swap	d4
		add.w	#32,d4

		lsr.w	#2,d4
		and.w	#$f,d4

		move.w	d4,d5
		lsl.w	#4,d5
		or.w	d5,d4
		move.w	d4,Cop102+2


		rts


; ==========================================================================
;
;  Data:
;
; ==========================================================================

Colors1		incbin	"pic.col"

; ==========================================================================
;
;  Copper
;
; ==========================================================================

	SECCODE_C

CopLst		dc.w	$008e,$2c81		; set display size
		dc.w	$0090,($2bc1+ROWS*$100)&$ffff
		dc.w	$0092,$0038
		dc.w	$0094,$0030+BPL*4-$20


		dc.w	$009c,$8010		; set copper interrupt
		dc.w	$1cdf,$fffe		; wait 16 more lines
		dc.w	$0096,$800f		; reset audio channels

CopColA		ds.b	AGACopSIZE


CopGen1		dc.w	$0100,$1000*(PLN+1)+1	; set bitplanes
Cop102		dc.w	$0102,$0000
		dc.w	$0104,$0240
		dc.w	$0106,$0000
		dc.w	$0108,BPR-BPL
		dc.w	$010a,BPR-BPL
		dc.w	$010c,$0011
		dc.w	$01fc,$0003
CopSpr		dcb.l	16			; reset sprites


CopPln		dc.w	$00e0,$0000,$00e2,$0000
		dc.w	$00e4,$0000,$00e6,$0000
		dc.w	$00e8,$0000,$00ea,$0000
		dc.w	$00ec,$0000,$00ee,$0000
		dc.w	$00f0,$0000,$00f2,$0000

CopPln2		;dc.w	$00e0,$0000,$00e2,$0000
		dc.w	$00f4,$0000,$00f6,$0000
		dc.w	$00f8,$0000,$00fa,$0000
		dc.w	$00fc,$0000,$00fe,$0000

;d		dc.w	D0180,$0000		; color 0

		dc.w	$ffff,$fffe		; end of frame

Zeros		dcb.w	16			; sprite data and other


		cnop	0,8

		dcb.b	BPR*PLN*32
Piccy		incbin	"pic.raw"
		dcb.b	BPR*PLN*32

; ==========================================================================
;
;  Bitmaps and Chip-BSS
;
; ==========================================================================

		SECBSS_C

PlaneEmpty	ds.b	40*ROWS			; Planes
Plane1a		ds.b	40*ROWS
Plane1b		ds.b	40*ROWS

; ==========================================================================
;
;  General BSS
;
; ==========================================================================

		SECBSS

Sine		ds.b	$4000			; sinelist (not used)
Vars		ds.b	VARS_SIZEOF		; variables

; allways put the variables at the last positon to avoid problems with
; word alignment. You should better keep all arrays aligned to 16 bytes,
; to avoid problems with the caches. SOS will allways give you the memory
; aligned to 16 byte.

; ==========================================================================

		END
