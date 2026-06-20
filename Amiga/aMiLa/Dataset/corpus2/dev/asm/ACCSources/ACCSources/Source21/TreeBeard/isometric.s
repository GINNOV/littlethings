; ISOMETRIC 3-D DISPLAYING ROUTINES
; Coded by Treebeard   10.12.91

; Displays a map of isometric blocks - press RMB to move along the
; landscape.  Had to disable the screen when the screen was cleared
; and redrawn to tidy it up

	opt	c-
	section	Treebeard,code_c
	include Source:Include/hardware.i

; Some library functions:

OpenLibrary	=-552
CloseLibrary	=-414
AllocMem	=-198
FreeMem		=-210
Forbid		=-132
Permit		=-138

MapHeight	=7
MapWidth	=13

DisplaySize	=6		; Width and height of the displayed bit

	move.l	4,a6
	lea	gfxname,a1	; Open Gfx library
	moveq.l	#0,d0		; Any version
	jsr	OpenLibrary(a6)
	move.l	d0,gfxbase	; Store its base
	move.l	#256*200,d0	; Reserve 5 bitplane space
	move.l	#2+(1<<16),d1	; Chip RAM
	jsr	AllocMem(a6)	; Reserve it
	tst.l	d0		; Check if available
	beq	quit		; If unavailable quit
	moveq.l	#4,d1		; d1 = no. of bitplanes -1
	lea	b1,a0		; a0 = place to store address of bpl 1
	lea	b1l,a1		; a1 = place in copper list to put pointers
dobpls	move.l	d0,(a0)+	; Store address in b1,b2,b3 or b4
	move.w	d0,(a1)		; Store address in copper list
	swap	d0
	move.w	d0,4(a1)
	swap	d0
	add.l	#256*40,d0	; Next bpl
	add.l	#8,a1		; Next part in copper list
	dbra	d1,dobpls

	jsr	Forbid(a6)	; No Multi-tasking

	lea	$dff000,a5

	bsr	vwait		; Switch off sprites
	move.w	#$20,dmacon(a5)
	move.w	#$8400,dmacon(a5)	; Give blitter priority

	move.l	#copper,cop1lch(a5)	; Strobe our copper list
	move.w	#0,copjmp1(a5)

	move.l	#Map,MapAddr	; Start display at top left
	bsr	BlitMap

wait	btst	#10,$16(a5)	; RMB pressed?
	bne.s	.loop1		; No!
	cmp.l	#Map+Mapwidth-DisplaySize,MapAddr	; Reached end of map?
	beq.s	.loop1		; Yep!
	bsr	vwait		; Wait for Vbl
	move.w	#$100,dmacon(a5)	; Switch off screen
	bsr	ClearScr	; Clear screen
	addq.l	#1,MapAddr	; Move along map 1 block
	bsr	BlitMap		; Redraw it
	bsr	vwait		; Wait for Vbl
	move.w	#$8100,dmacon(a5)	; Switch screen on
.loop	btst	#10,$16(a5)	; Wait for RMB to be released
	beq.s	.loop
.loop1	btst	#6,$bfe001	; Wait for LMB
	bne.s	wait

	move.w	#$8020,dmacon(a5)	; Switch on sprites

free	move.l	4,a6
	jsr	Permit(a6)	; Enable multi-tasking
	move.l	#256*200,d0	; 5 bitplanes space
	move.l	b1,a1		; Free the memory
	jsr	FreeMem(a6)
	move.l	gfxbase,a1	; Enter old copper list
	move.l	38(a1),cop1lch(a5)
	jmp	CloseLibrary(a6)	; And close the gfx library


vwait	cmp.b	#255,vhposr(a5)	; Wait for vertical blanking
	bne.s	vwait
quit	rts

bwait	btst	#14,dmaconr(a5)
	bne.s	bwait
	rts

; Set up registers which remain constant during Cookie Cut routines

StartBlit:
	bsr	bwait
	move.w	#%111111100010,bltcon0(a5)	; Cookie Cut value
	move.w	#0,bltcon1(a5)
	move.w	#$ffff,bltalwm(a5)
	move.w	#$ffff,bltafwm(a5)
	move.w	#0,bltamod(a5)
	move.w	#0,bltbmod(a5)
	move.w	#36,bltcmod(a5)
	move.w	#36,bltdmod(a5)
	rts

BlitMap:
	bsr	StartBlit	; Set up constant blitter regs
	move.l	b1,d1		; Get start address (20 lines down from top)
	add.l	#20*40+18,d1	; Add offset of 1st block
	moveq.l	#0,d2		; Do 1 blit on this line
	move.l	MapAddr,a0	; Get address of place in map to start
	move.l	a0,a1		; Keep it in a1
	move.l	#DisplaySize-1,d4	; Number of lines to do
.loop	bsr	DrawLine	; Draw the current line of blocks
	add.l	#8*40-2,d5	; Move down to start of next line on screen
	move.l	d5,d1		; Put it in d1 for Drawline
	addq.l	#1,d2		; Do 1 more block on this line
	add.l	#MapWidth,a1	; Move onto next line of map
	move.l	a1,a0		; Put it in a0 for Drawline
	dbra	d4,.loop	; Do other lines
	move.l	#DisplaySize-1,d4	; Number of lines to do
.loop1	subq.l	#1,d2		; Do 1 less block on this line
	bsr	DrawLine	; And draw it
	add.l	#8*40+2,d5	; Move onto next line
	move.l	d5,d1		; Put it in d1
	addq.l	#1,a1		; Point a1 to next block
	move.l	a1,a0		; Copy it to a0
	dbra	d4,.loop1	; Do other lines
	rts

DrawLine:
	move.l	d2,d3		; Keep d2 as it is - use d3
	move.l	d1,d5		; Ditto d1 - use d5
.loop	clr.l	d0		; Clear d0 - just in case
	move.b	(a0),d0		; Get block no.
	move.l	d1,a3		; d1 is place on screen
	bsr	DrawIso		; Draw block
	add.l	#4,d1		; Go to next place on screen
	sub.l	#MapWidth-1,a0	; Point to next block in map
	dbra	d3,.loop	; do rest of line
	rts

; d0 = Block no.
; a3 = Address to put it at

DrawIso:
	movem.l	d0-d7/a0-a6,-(sp)
	lsl.l	#2,d0		; Multiply block no. by 2
	lea	BlockHeights,a0
	move.l	(a0,d0),d7	; Get height of block
	lea	BlockAddrs,a0
	move.l	(a0,d0),a4	; Get address of block data
	move.l	d7,d0		; Modify position on screen if block higher than 15:
	sub.l	#15,d0		; - Take 15 from height
	mulu	#40,d0		; And take this number x 40 from a3
	sub.l	d0,a3
	bsr	DrawBlock	; Draw the block
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; a4 points to block address
; a3 points to place on screen
; d7 is its height

DrawBlock:
	move.l	a4,a0		; Get block address in a0
	lea	Mask,a1		; Place to put mask in a1
	move.l	d7,d0		; Get height in d0
	subq.l	#1,d0		; Modify height for dbra
	move.l	d7,d2
	lsl.l	#2,d2
.loop	move.l	(a0),d1		; Get number on plane 1
	move.l	a0,a2
	moveq.l	#3,d3
.loop1	add.l	d2,a2
	or.l	(a2),d1
	dbra	d3,.loop1
	move.l	d1,(a1)+	; Save mask
	addq.l	#4,a0		; Next line
	dbra	d0,.loop	; Do other lines

	bsr	bwait
	move.l	a4,bltapth(a5)	; A = Data
	lsl.l	#6,d7		; x height by 64
	add.b	#2,d7		; Add width to get bltsize number
	moveq.l	#4,d0		; Number of bpls
.loop2	bsr	bwait
	move.l	#Mask,bltbpth(a5)	; B = Mask
	move.l	a3,bltcpth(a5)		; C = Screen pos
	move.l	a3,bltdpth(a5)		; D = C
	move.w	d7,bltsize(a5)		; bltsize worked out above
	add.l	#256*40,a3		; Move to next bpl
	dbra	d0,.loop2		; Do other bpls
	rts

ClearScr:
	bsr	bwait			; Wait for blitter
	move.l	b1,bltdpth(a5)		; Wipe first three bpls
	move.w	#0,bltdmod(a5)		; (can't do it one go)
	move.w	#$100,bltcon0(a5)
	move.w	#256*64+60,bltsize(a5)
	bsr	bwait			; Clear last 2 bpls
	move.l	b4,bltdpth(a5)
	move.w	#256*64+40,bltsize(a5)
	rts

	even
copper	dc.w	bplcon0,%101001000000000
	dc.w	bplcon1,0
	dc.w	bplcon2,0
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
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
	dc.w	$0180,$0000,$0182,$0eca,$0184,$0e00,$0186,$0a00
	dc.w	$0188,$0d80,$018a,$0cb0,$018c,$08f0,$018e,$0080
	dc.w	$0190,$02c0,$0192,$00a0,$0194,$00af,$0196,$007c
	dc.w	$0198,$000f,$019a,$0060,$019c,$0c0e,$019e,$0c08
	dc.w	$01a0,$0620,$01a2,$0740,$01a4,$0852,$01a6,$0fca
	dc.w	$01a8,$0333,$01aa,$0444,$01ac,$0555,$01ae,$0666
	dc.w	$01b0,$0777,$01b2,$0888,$01b4,$0999,$01b6,$0aaa
	dc.w	$01b8,$0ccc,$01ba,$0ddd,$01bc,$0eee,$01be,$0fff
	dc.w	$ffff,$fffe
gfxbase	dc.l	0
b1	dc.l	0
b2	dc.l	0
b3	dc.l	0
b4	dc.l	0
b5	dc.l	0
MapAddr	dc.l	0
gfxname	dc.b	'graphics.library',0

	even
Blocks	incbin	Source:Treebeard/Isometric.raw
Mask	ds.b	128	; Space to create mask

; The BADD command (Block ADDress) will do a dc.l statement containing
; the address of the wanted block.  The parameter sent to it is the
; height of the blockso it can point C (the variable it uses) to the next
; block

BADD	Macro		; Little macro to help make table below easier
	dc.l	c	; C contains address of this block
c	set	c+\1*4*5	; Get address of next (4 bytes wide, 5 bpls)
	Endm
	
C	Set	Blocks
BlockAddrs:		; List of addresses
	BADD	15	; Soil
	BADD	15	; Water
	BADD	15	; Desert (or sand)
	BADD	15	; Grass
	BADD	15	; Road
	BADD	29	; N/S wall
	BADD	24	; E/W wall
	BADD	29	; Wall corner
	BADD	31	; Bushy tree
	BADD	26	; Conifer tree
BlockHeights:
	dc.l	15,15,15,15,15,29,24,29,31,26

; A tiny landscape, incorporating all blocks so far available

Map:
	dc.b	0,0,3,3,5,4,3,3,2,2,1,1,1
	dc.b	0,0,0,3,5,4,3,3,2,2,2,1,1
	dc.b	0,0,3,9,5,4,3,8,3,2,2,1,1
	dc.b	0,3,9,3,5,4,3,8,8,2,1,1,1
	dc.b	0,9,9,9,5,4,3,8,2,2,2,1,1
	dc.b	9,3,9,3,5,4,4,4,4,4,2,2,1
	dc.b	3,3,3,3,7,6,6,6,6,6,6,6,6
