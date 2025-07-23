;vasm -Fhunkexe -o rainbow_bar.exe rainbow_bar.asm
;vasm -Fbin -o rainbow_bar.bin rainbow_bar.asm

; rainbow_bar.asm - Corrected Rainbow Sine Bar Demo
; Targets: Amiga 500 OCS, 512KB Chip RAM, PAL 50Hz
; (c) Adjustments for crash fix

    SECTION CODE,CODE

; Constants
SCREEN_WIDTH	EQU	320		; Low-res mode
SCREEN_HEIGHT	EQU	256
BPLS		EQU	1		; Single bitplane
COLORS		EQU	1<<BPLS		; 2 colors
BAR_HEIGHT	EQU	32		; Thickness of the rainbow bar
SINE_AMP	EQU	50		; Sine wave amplitude for bar wobble

; System includes
ExecBase	EQU	4
OpenLibrary	EQU	-552
CloseLibrary	EQU	-414
AllocMem	EQU	-198
FreeMem		EQU	-210
Forbid		EQU	-132
Permit		EQU	-138
Wait		EQU	-312

; Graphics library
gfxName		DC.B	'graphics.library',0
customBase	EQU	$dff000

    CNOP 0,2
START:
    move.l	ExecBase,a6
    jsr	Forbid(a6)

    lea	gfxName,a1
    moveq	#0,d0
    jsr	OpenLibrary(a6)
    move.l	d0,gfxBase
    beq	EXIT

    move.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT*BPLS,d0	; Bitplane size
    add.l	#1024,d0	; Extra for Copper list
    move.l	#2,d1		; MEMF_CHIP
    jsr	AllocMem(a6)
    move.l	d0,bitplane
    beq	CLOSE_GFX

    ; Clear bitplane (fill with $ff for solid background)
    move.l	d0,a1
    move.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT*BPLS/4-1,d1
.fill_bp: move.l	#$ffffffff,(a1)+
    dbra	d1,.fill_bp

    ; Fill Copper list area with safe END ($FFFFFFFE)
    move.l	bitplane,a1
    add.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT*BPLS,a1
    move.l	a1,copperlist
    move.w	#1024/4-1,d1
.fill_cop: move.l	#$fffffffe,(a1)+
    dbra	d1,.fill_cop

    ; Setup display (low-res, single bpl)
    move.w	#$1200,$dff100	; BPLCON0: 1 bpl, color, lores (fixed)
    move.w	#0,$dff102	; BPLCON1: no scroll
    move.w	#$2c81,$dff08e	; DIWSTRT
    move.w	#$f4c1,$dff090	; DIWSTOP
    move.w	#0,$dff108 ; BPL1MOD (fixed)
    move.w	#0,$dff10a ; BPL2MOD (fixed)

    ; Point bitplane pointers (fixed to BPL1)
    move.l	bitplane,d0
    swap	d0
    move.w	d0,$dff0e0	; BPL1PTH
    swap	d0
    move.w	d0,$dff0e2	; BPL1PTL

    ; Initial colors
    move.w	#0,$dff180	; COLOR00 black
    move.w	#$fff,$dff182	; COLOR01 white

    ; Generate sine table (fixed loop for better approx; simple linear for demo)
    lea	sine_table,a1
    move.w	#255,d1
.sine_loop:
    move.w	d1,d0
    lsl.w	#1,d0		; Adjusted scale
    muls	#SINE_AMP,d0	; Simple ramp approx (replace with real sine if needed)
    asr.l	#8,d0
    move.w	d0,(a1)+
    dbra	d1,.sine_loop

    ; Install custom Copper list (now safe)
    move.l	copperlist,$dff080
    move.w	#0,$dff082
    move.w	#$0080,$dff088

    ; Setup VBlank interrupt
    move.l	$6c.w,old_int
    lea	vblank_int,a0
    move.l	a0,$6c.w
    move.w	#$c020,$dff09a	; Enable VERTB

    ; Main loop
.main_loop:
    btst	#6,$bfe001
    beq	EXIT_MAIN
    addq.b	#1,sine_index
    bra	.main_loop

EXIT_MAIN:
    move.l	old_int,$6c.w
    move.w	#$8020,$dff09a

    move.l	gfxBase,a6
    move.l	38(a6),$dff080	; Restore Copper
    move.w	#0,$dff082
    move.w	#$0080,$dff088

    move.l	ExecBase,a6
    move.l	bitplane,a1
    move.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT*BPLS+1024,d0
    jsr	FreeMem(a6)

CLOSE_GFX:
    move.l	gfxBase,a1
    jsr	CloseLibrary(a6)

EXIT:
    jsr	Permit(a6)
    moveq	#0,d0
    rts

; VBlank: Update Copper for rainbow and wobble
vblank_int:
    movem.l	d0-a6,-(sp)

    moveq	#0,d0
    move.b	sine_index,d0
    add.w	d0,d0
    lea	sine_table,a0
    move.w	(a0,d0.w),d1
    asr.w	#8,d1
    add.w	#SCREEN_HEIGHT/2,d1
    sub.w	#BAR_HEIGHT/2,d1

    move.l	copperlist,a1

    move.w	#$2c01,(a1)+
    move.w	#$fffe,(a1)+

    moveq	#BAR_HEIGHT-1,d2
    move.w	d1,d3
.rainbow_loop:
    move.w	d2,d4
    lsl.w	#4,d4
    move.w	d4,d5
    lsr.w	#8,d5
    and.w	#$f,d5
    add.w	#$0f0,d5

    move.w	#$0180,(a1)+
    move.w	d5,(a1)+

    addq.w	#1,d3
    move.b	d3,d6
    lsl.w	#8,d6
    or.w	#$0001,d6	; WAIT line, fixed
    move.w	d6,(a1)+
    move.w	#$fffe,(a1)+

    dbra	d2,.rainbow_loop

    move.l	#$fffffffe,(a1)+

    move.w	#$0020,$dff09c	; Clear INTREQ

    movem.l	(sp)+,d0-a6
    rte

; Data
    SECTION DATA,DATA_C

bitplane	DC.L	0
copperlist	DC.L	0
gfxBase		DC.L	0
old_int		DC.L	0
sine_index	DC.B	0
        EVEN
sine_table	DS.W	256

    END