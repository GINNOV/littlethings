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
DrawPl		rs.l	1	; current plane to draw in
Env		rs.l	1	; environment pointer
DBuff		rs.w	1	; counter for double-bufferig
Pad		rs.w	1
VARS_SIZEOF	rs.w	0	; size of variables

; ==========================================================================
;
;  constant definition
;
; ==========================================================================

XSIZE		equ	320		; size of display
YSIZE		equ	256

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

Effect_Init:	CLRFAST	Plane1a,ROWS*BPL*PLN	; clear planes
		OPENLIB	SINE			; open sine.soslibrary
		GENSINUS Sine,SINE_WORD,15,7+4,4 ; create sinelist
						; it is not used, just
						; as an example

		SETCSPR	CopSpr			; reset sprites
		SETCADR	CopPln,#Plane1a,BPP,PLN,$e0 ; presette copperlist
		SETCCOL	CopCol,Colors+2,1,15	; set palette

		GENLOCK	CopGen1			; set BPLCON0 for genlocks

		move.l	#$aaaaaaaa,Plane1a	; draw something in bitmaps.
		move.l	#$cccccccc,Plane1b	; just to make the doublebuffer
						; visible.
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

		lea	DBuff(a5),a0		; double buffering
		lea	.List(pc),a1
		moveq	#2,d0
		jsr	_DoubleBuffer(a6)

		move.l	(a0)+,DrawPl(a5)	; set draw plane
		SETCADR	CopPln,(a0),BPP,PLN,$e0 ; show finished plane

		addq.l	#1,Plane1a+40		; do something that moves.
		addq.l	#1,Plane1b+44		; ... sort of it...

		DEBCOL	$000			; debug color at end

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


; ==========================================================================
;
;  Data:
;
; ==========================================================================

Colors		dc.w	$000,$00f,$0f0,$0ff,$f00,$f0f,$ff0,$fff
		dc.w	$444,$008,$080,$088,$800,$808,$880,$888

; ==========================================================================
;
;  Copper
;
; ==========================================================================

	SECCODE_C

CopLst		dc.w	$008e,$2c81		; set display size
		dc.w	$0090,($2bc1+ROWS*$100)&$ffff
		dc.w	$0092,$0038
		dc.w	$0094,$0030+BPL*4

CopGen1		dc.w	$0100,$1000*PLN		; set bitplanes
		dc.w	$0102,$0000
		dc.w	$0104,$0000
		dc.w	$0106,$0cc1
		dc.w	$0108,BPR-BPL
		dc.w	$010a,BPR-BPL
		dc.w	$010c,$0011
		dc.w	$01fc,$0000
CopSpr		dcb.l	16			; reset sprites
CopPln		dcb.l	PLN*2			; plane pointer
		dc.w	D0180,$0000		; color 0
CopCol		dcb.l	15			; other colors

		dc.w	$ffdf,$fffe		; wait to end of view
		dc.w	$1cdf,$fffe
		dc.w	$009c,$8010		; set copper interrupt
		dc.w	$2cdf,$fffe		; wait 16 more lines
		dc.w	$0096,$800f		; reset audio channels
						; (for my fast replay)
		dc.w	$ffff,$fffe		; end of frame

Zeros		dcb.w	16			; sprite data and other

; ==========================================================================
;
;  Bitmaps and Chip-BSS
;
; ==========================================================================

		SECBSS_C

Plane1a		ds.b	ROWS*BPL*PLN		; Planes
Plane1b		ds.b	ROWS*BPL*PLN

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
