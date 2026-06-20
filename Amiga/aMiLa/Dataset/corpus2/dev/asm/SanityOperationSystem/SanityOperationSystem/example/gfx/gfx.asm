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
		INCLUDE	"include:sos/agac.i"	; sinelist generator

		SECCODE				; section code
		INITSOS2 Main_C			; sos startup header



		include	'makex'			; incbin picture

		IFLE	COLORS-32
NOAGA		EQU	1
		ENDC

		IFNE	MODE&$8000
HIRES		EQU	1
		ENDC

		IFND	YOFFS
YOFFS		EQU	0
		ENDC

		IFND	FADETIME
FADETIME	EQU	64
		ENDC

; ==========================================================================
;
;  varables definition
;
; ==========================================================================

		rsreset		; Variables
SOSBase		rs.l	1	; library base ptr.
DBUGBase	rs.l	1
AGACBase	rs.l	1
DrawPl		rs.l	1	; current plane to draw in
Env		rs.l	1	; environment pointer
DBuff		rs.w	1	; counter for double-bufferig
FadeCount	rs.w	1
MyTotalTicks	rs.w	1
VARS_SIZEOF	rs.w	0	; size of variables

; ==========================================================================
;
;  constant definition
;
; ==========================================================================

PLN		equ	8		; number of planes
BPL		equ	XSIZE/8		; size of a line in bytes
ROWS		equ	YSIZE		; number of rows in display

BPR		equ	BPL*PLN		; increment to next line
BPP		equ	BPL		; increment to next plane

; Please note the difference between BPR and BPL. For interleaved bitmaps
; BPR will be BPL*PLN. See many comments from Chris Green and Commodore 
; about this subject.

; ==========================================================================
;
;  Startup-Code
;
; ==========================================================================

Main_C		lea	Vars,a5			; a5 = variablen
		move.l	a6,SOSBase(a5)		; a6 stored

;		AGAOFF

		ENVINIT	ENVFf_Normal,500	; init environments
		move.l	Env(a5),a0
		move.w	ENV_TotalTicks(a0),MyTotalTicks(a5)

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

.end		move.w	#$0070,$dff09c		; end of interrupt
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

Effect_Init:
		OPENLIB	AGAC
		SETCSPR	CopSpr			; reset sprites
		SETCADR	CopPln,#Picture,BPL,PLN,$e0 ; presette copperlist

		GENLOCK	CopGen1			; set BPLCON0 for genlocks

		IFD	DELTA
		bsr	UnDelta
		ENDC
		bsr	UnChunky

		AGABEGIN
		AGAFETCH	Cop1fc
		IFD		HIRES
		AGADDFSTOP	Cop094,#$0010
		ELSE
		AGADDFSTOP	Cop094,#$0020
		ENDC
		AGAEND

		move.l	AGACBase(a5),a4		; Prepare fading


		IFND	NOAGA

		lea	CopColA,a0
		jsr	_InitAgaCopper(a4)

		lea	Colors0,a0
		lea	CopColA,a1
		moveq	#0,d0
		move.w	#256,d1
		jsr	_CopyAgaCopper(a4)

		ENDC


		IFD	NOAGA

		lea	CopColA,a0
		jsr	_InitAgaCop32(a4)

		lea	Colors0,a0
		lea	CopColA,a1
		moveq	#0,d0
		move.w	#32,d1
		jsr	_CopyAgaCop32(a4)

		ENDC

		lea	Colors0,a0
		lea	Colors1,a1
		lea	FadeInData,a2
		move.w	#FADETIME,d0
		jsr	_InitAgaFade(a4)

		lea	Colors1,a0
		lea	Colors0,a1
		lea	FadeOutData,a2
		move.w	#FADETIME,d0
		jsr	_InitAgaFade(a4)

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
		DEBCOL	$000			; debug color at end

		move.w	FadeCount(a5),d0
		addq.w	#1,FadeCount(a5)

		cmp.w	#FADETIME,d0
		bhs.s	.nofadein
		lea	FadeInData,a0
		bsr.b	.Fade
.nofadeout	rts

.nofadein	move.w	MyTotalTicks(a5),d1
		cmp.w	d1,d0
		bhs.s	.nofadeout
		sub.w	#FADETIME,d1
		cmp.w	d1,d0
		ble.s	.nofadeout
		lea	FadeOutData,a0
;		bra.b	.Fade

.Fade		move.l	AGACBase(a5),a4

		lea	Colors256,a1
		moveq	#0,d0
		move.w	#COLORS,d1
		jsr	_DoAgaFade(a4)

		lea	Colors256,a0
		lea	CopColA,a1
		moveq	#0,d0
		move.w	#COLORS,d1
		IFND	NOAGA
		jsr	_CopyAgaCopper(a4)
		ENDC
		IFD	NOAGA
		jsr	_CopyAgaCop32(a4)
		ENDC
		rts

; ==========================================================================
;
;  Code:   Put more complex code here.
;
; ==========================================================================

		IFD	DELTA
UnDelta		move.l	#1024+8*BPL*ROWS,d0
		lea	PicChunky,a0

		moveq	#0,d1
.loop		add.b	(a0),d1
		move.b	d1,(a0)+
		subq.l	#1,d0
		bne.s	.loop
		rts
		ENDC

UnChunky	lea	C2PTab,a0
		moveq	#16-1,d0
		lea	.tab,a1
.loopx1		moveq	#16-1,d1
		lea	.tab,a2
		move.l	(a1)+,d2
.loopx2		move.l	d2,(a0)+
		move.l	(a2)+,(a0)+
		dbf	d1,.loopx2
		dbf	d0,.loopx1


		lea	PicChunky+1024,a0
		lea	Picture,a1
		lea	C2PTab,a2
		moveq	#0,d3
		move.w	#ROWS-1,d0
.loop0		move.w	#BPL*8/8-1,d1

.loop1		move.b	(a0)+,d3
		move.l	0(a2,d3.w*8),d4
		move.l	4(a2,d3.w*8),d5

		REPT	8-1
		add.l	d4,d4
		add.l	d5,d5
		move.b	(a0)+,d3
		or.l	0(a2,d3.w*8),d4
		or.l	4(a2,d3.w*8),d5
		ENDR

		move.b	d4,4*BPP(a1)
		swap	d4
		move.b	d4,6*BPP(a1)
		lsr.l	#8,d4
		move.b	d4,7*BPP(a1)
		swap	d4
		move.b	d4,5*BPP(a1)

		move.b	d5,(a1)+
		swap	d5
		move.b	d5,2*BPP-1(a1)
		lsr.l	#8,d5
		move.b	d5,3*BPP-1(a1)
		swap	d5
		move.b	d5,1*BPP-1(a1)

		dbf	d1,.loop1
		lea	BPR-BPL(a1),a1
		dbf	d0,.loop0
		rts		

.tab		dc.l	$00000000,$00000001,$00000100,$00000101
		dc.l	$00010000,$00010001,$00010100,$00010101
		dc.l	$01000000,$01000001,$01000100,$01000101
		dc.l	$01010000,$01010001,$01010100,$01010101

; ==========================================================================
;
;  Data:
;
; ==========================================================================

PicChunky
Colors1:
		PICDATA


; ==========================================================================
;
;  Copper
;
; ==========================================================================

		SECCODE_C

CopLst		dc.w	$008e,($2c81+(YOFFS+0000)*$100)&$ffff
		dc.w	$0090,($2bc1+(YOFFS+ROWS)*$100)&$ffff
		IFD	HIRES
		dc.w	$0092,$0034
Cop094		dc.w	$0094,$0030+BPL*2
		ENDC
		IFND	HIRES
		dc.w	$0092,$0038
Cop094		dc.w	$0094,$0030+BPL*4
		ENDC
		dc.w	$0096,$8020
		dc.w	$009c,$8010
		dc.w	$1cdf,$fffe		; wait 16 more lines
		dc.w	$0096,$800f		; reset audio channels

CopGen1		dc.w	$0100,MODE		; set bitplanes
		dc.w	$0102,$0000
		dc.w	$0104,$0000
		dc.w	$0106,$0c00
		dc.w	$0108,BPR-BPL
		dc.w	$010a,BPR-BPL
		dc.w	$010c,$0011
Cop1fc		dc.w	$01fc,$0000
CopSpr		dcb.l	16			; reset sprites
CopPln		dcb.l	PLN*2			; plane pointer

		IFND	NOAGA
CopColA		ds.b	AGACopSIZE
		ENDC
		IFD	NOAGA
CopColA		ds.b	AGACop32SIZE
		ENDC
		dc.w	$ffff,$fffe

Zeros		dcb.w	16			; sprite data and other

; ==========================================================================
;
;  General BSS
;
; ==========================================================================

		SECBSS_C


Picture		ds.b	BPL*ROWS*PLN

		SECBSS
Colors256	ds.l	256			; Aktuelle Farbtabelle
Colors0		ds.l	256
FadeInData	ds.b	AGAFadeSIZE
FadeOutData	ds.b	AGAFadeSIZE
C2PTab		ds.l	256*2
Vars		ds.b	VARS_SIZEOF		; variables

; allways put the variables at the last positon to avoid problems with
; word alignment. You should better keep all arrays aligned to 16 bytes,
; to avoid problems with the caches. SOS will allways give you the memory
; aligned to 16 byte.

; ==========================================================================

		END
