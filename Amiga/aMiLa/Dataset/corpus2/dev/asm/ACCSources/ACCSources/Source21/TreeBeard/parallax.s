; PROGRAM: 16 Colour Parallax

; Scrolls a 2 colour parallax screen up behind a 16 colour screen.

	opt	c-
	include source:include/hardware.i

; Some library functions:

OpenLibrary	=-552
CloseLibrary	=-414
AllocMem	=-198
FreeMem		=-210
Forbid		=-132
Permit		=-138

	move.l	4,a6
	lea	gfxname,a1	; Open Gfx library
	moveq.l	#0,d0		; Any version
	jsr	OpenLibrary(a6)
	move.l	d0,gfxbase	; Store its base
	move.l	#Screen1,d0	; d0 = start of 1st bitplane
	moveq.l	#4,d1		; d1 = no. of bitplanes -1
	lea	b1l,a0		; a0 = place in copper list to put pointers
dobpls	move.w	d0,(a0)		; Store low word of address in copper list
	swap	d0
	move.w	d0,4(a0)	; Store high word of address in copper list
	swap	d0
	add.l	#200*40,d0	; Next bpl
	add.l	#8,a0		; Next part in copper list
	dbra	d1,dobpls	; Do other bpls
	move.l	#Screen2,d0	; After copper wait instruction, set bpl5
	move.w	d0,B5WaitL	; to start of parallax screen.
	swap	d0
	move.w	d0,B5WaitH

	jsr	Forbid(a6)	; No Multi-tasking

	lea	$dff000,a5

	bsr	VWait		; Switch off sprites
	move.w	#$20,dmacon(a5)
	move.w	#$8400,dmacon(a5)	; Give blitter priority

	move.l	#copper,cop1lch(a5)	; Strobe our copper list
	move.w	#0,copjmp1(a5)

	move.w	#200,ScrollCount	; 200 scrolls before reseting bpls
					; (screen 200 lines high)
wait	bsr	VWait		; Wait for vertical blanking
	bsr	ScrollScreen	; Scroll the screen
	btst	#6,$bfe001	; LMB pressed?
	bne.s	wait

	move.w	#$8020,dmacon(a5)	; Switch on sprites

free	move.l	4,a6
	jsr	Permit(a6)	; Enable multi-tasking
	move.l	gfxbase,a1	; Enter old copper list
	move.l	38(a1),cop1lch(a5)
	jmp	CloseLibrary(a6)	; And close the gfx library

VWait	cmp.b	#255,vhposr(a5)	; Wait for vertical blanking
	bne.s	VWait
	rts

ScrollScreen:
	subq.w	#1,ScrollCount		; Have we scrolled the whole screen?
	bne.s	NormalScroll		; No, then just a normal up scroll
	move.l	#Screen2,d0		; Reset bpl 5 to top of parralax screen
	move.w	d0,b5l			; Put low word of screen in copper list
	swap	d0
	move.w	d0,b5h			; Do same for high word
	move.w	#200,ScrollCount	; Reset scroll counter
	move.b	#$f4,CopperWait		; Reset wait command in copper
	rts
NormalScroll:
	subq.b	#1,CopperWait		; Take 1 from vertical position where
					; the bpl 5 pointers are set to top of
					; screen
	add.w	#40,b5l			; Move down screen 1 line
	bcc	.loop			; Modify high word if necessary
	addq.w	#1,b5h
.loop	rts

gfxbase		dc.l	0
ScrollCount	dc.w	0
gfxname		dc.b	'graphics.library',0

	even
	section	Copper,data_c

copper	dc.w	bplcon0,%101001000000000
	dc.w	bplcon1,0
	dc.w	bplcon2,0
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$f4c1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bpl1ptl
b1l	dc.w	0,bpl1pth
b1h	dc.w	0,bpl2ptl
b2l	dc.w	0,bpl2pth
b2h	dc.w	0,bpl3ptl
b3l	dc.w	0,bpl3pth
b3h	dc.w	0,bpl4ptl
b4l	dc.w	0,bpl4pth
b4h	dc.w	0,bpl5ptl
b5l	dc.w	0,bpl5pth
b5h	dc.w	0
	dc.w	$0180,$0000,$0182,$0877,$0184,$0920,$0186,$0600
	dc.w	$0188,$0071,$018a,$03b1,$018c,$000f,$018e,$02cd
	dc.w	$0190,$0901,$0192,$0609,$0194,$0950,$0196,$0fca
	dc.w	$0198,$0fe0,$019a,$0ccc,$019c,$0888,$019e,$0444
; These colours are just the same as 0-15 except for colour 16. COLOR00
; and COLOR16 are the colours for the parallax screen.
	dc.w	$01a0,$0125,$01a2,$0877,$01a4,$0920,$01a6,$0600
	dc.w	$01a8,$0071,$01aa,$03b1,$01ac,$000f,$01ae,$02cd
	dc.w	$01b0,$0901,$01b2,$0609,$01b4,$0950,$01b6,$0fca
	dc.w	$01b8,$0fe0,$01ba,$0ccc,$01bc,$0888,$01be,$0444
CopperWait:
	dc.w	$f401,$fffe
	dc.w	bpl5ptl
B5WaitL	dc.w	0,bpl5pth
B5WaitH	dc.w	0
	dc.w	$ffff,$fffe

Screen1:
	incbin	Parallax.raw
Screen2:
	incbin	Parallax1.raw

