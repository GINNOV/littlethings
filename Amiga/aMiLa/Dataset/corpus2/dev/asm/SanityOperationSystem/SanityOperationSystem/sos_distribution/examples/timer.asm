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
DEBUG		equ	1			; debug stripes
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
DrawPl		rs.l	1	; current plane to draw in
Env		rs.l	1	; environment pointer
VARS_SIZEOF	rs.w	0	; size of variables

; ==========================================================================
;
;  constant definition
;
; ==========================================================================

XSIZE		equ	320		; size of display
YSIZE		equ	256

PLN		equ	0		; number of planes
BPL		equ	XSIZE/8		; size of a line in bytes
ROWS		equ	YSIZE		; number of rows in display

BPR		equ	BPL		; increment to next line
BPP		equ	ROWS*BPR	; increment to next plane

; Please note the difference between BPR and BPL. For interleaved bitmaps
; BPR will be BPL*PLN. See many comments from Chris Green and Commodore 
; about this subject.


; ==========================================================================
;
;  Startup-Code
;
; ==========================================================================

Main_C		moveq	#8,d0			; check version number
		sub.l	a0,a0
		jsr	_CheckRelease(a6)

		lea	Vars,a5			; a5 = variablen
		move.l	a6,SOSBase(a5)		; a6 stored

		ENVINIT	ENVFf_Normal,$400	; init environments

		bsr	Effect_Init		; init effect

		ENVWAIT				; sync effect start

		SETINT	CopLst,Main_I(pc),$10	; set copper & irq

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

; Please don't change the order of the last 4 commands. Don't remove the
; nop. See Compass 2 for further details. I made the experience that
; small changes to this can make dramatic problems, exspecially on 
; 68030 & 68040. Nobody knows what happens on a 68060.

; ==========================================================================
;
;  initialise your effect
;
; ==========================================================================

Effect_Init:	SETCSPR	CopSpr			; reset sprites
		GENLOCK	CopGen1			; set BPLCON0 for genlocks

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

Effect_Irq:	DEBCOL	$f00			; RED:
		move.w	#530,d0			; cia timed wait
		move.w	#TI_MICRO,d1
		jsr	_WaitTimer(a6)

		DEBCOL	$fff			; WHITE:
		move.w	#300,d0			; dbf timed wait
.w3		dbf	d0,.w3			; (never use this!)

		DEBCOL	$000	
		rts

; ==========================================================================
;
;  Copper
;
; ==========================================================================

	SECCODE_C

CopLst		dc.w	$008e,$2c81
		dc.w	$0090,($2bc1+ROWS*$100)&$ffff
		dc.w	$0092,$0038
		dc.w	$0094,$0030+BPL*4
CopGen1		dc.w	$0100,$1000*PLN
		dc.w	$0102,$0000
		dc.w	$0104,$0000
		dc.w	$0108,0
		dc.w	$010a,0
CopSpr		dcb.l	16
		dc.w	D0180,$0000

		dc.w	$4cdf,$fffe
		dc.w	$009c,$8010
		dc.w	$ffff,$fffe

Zeros		dcb.w	16

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

Vars		ds.b	VARS_SIZEOF		; variables

; allways put the variables at the last positon to avoid problems with
; word alignment. You should better keep all arrays aligned to 16 bytes,
; to avoid problems with the caches. SOS will allways give you the memory
; aligned to 16 byte.

; ==========================================================================

		END
