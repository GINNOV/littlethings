**
** MouseBobs (Stolen Data 1)
** 
** Coded by Raistlin
**
** Coded this after seeing the mousebob code on SD1.  It needs double 
** buffering & the bobs need seperating better.
**

	include	Source:Include/hardware.i		; Hardware offset
	section	hardware,code		; Public memory
	opt	c- d+

	lea	$dff000,a5		; Hardware offset

	move.w	joy0dat(a5),d0		; D0=Mouse count
	move.b	d0,d1
	lsr.w	#8,d0
	move.b	d0,oldv
	move.b	d1,oldh


	move.l	4,a6			; Exec base
	lea	gfxname,a1
	moveq.l	#0,d0			; Any version
	jsr	-552(a6)		; Open library
	move.l	d0,gfxbase		; Save gfx base
	beq	error
	
	jsr	-132(a6)		; Permit

*****************************************************************************
;			Set-Up The Bitplane Pointers
*****************************************************************************
	move.l	#Screen,d0		; Address of screen
	move.w	d0,bpl1+2		; Load bitplane pointers
	swap	d0
	move.w	d0,bph1+2
	swap	d0
	add.l	#40,d0			; Get to next bitplane
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2
	swap	d0
	add.l	#40,d0
	move.w	d0,bpl3+2
	swap	d0
	move.w	d0,bph3+2


*****************************************************************************
;			  Set-Up DMA
*****************************************************************************
DMA
.Wait1	btst	#0,vposr(a5)		; Wait VBL
	bne	.Wait1
.Wait2	cmpi.b	#55,vhposr(a5)
	bne	.Wait2
	move.w	#$20,dmacon(a5)		; Disable sprites
	move.l	#Copperlist,cop1lch(a5)	; Insert new copper list
	move.w	#$0,copjmp1(a5)		; Run that copper list

*****************************************************************************
;			Main Branching Routine
*****************************************************************************
WaitVBL
	cmpi.b	#255,vhposr(a5)		; Wait VBL
	bne	WaitVBL

	bsr	Clear	

	btst	#6,$bfe001		; Mouse Wait
	bne	WaitVBL
	bra	CleanUp			; Clean-up system



*****************************************************************************
;			The Bob Routines
*****************************************************************************
; First clear the old images
Clear	lea	XCords,a0		; A0=Address of X cords
	lea	YCords,a1		; A1=Address of Y cords
	moveq.l	#8,d0			; D0=Number of bobs to clear
Loop1	moveq.l	#0,d1			; Clear D0-D3
	moveq.l	#0,d2
	moveq.l	#0,d3
	move.w	(a0)+,d1		; D1=X cord
	move.w	(a1)+,d3		; D3=Y cord
	divu	#16,d1			; Convert X
	lsl.w	d1			; Multiply by 2
	mulu	#120,d3			; Convert Y
	add.w	d1,d3			; Add X to Y
	add.l	#Screen,d3		; Add address of screen
.Wait	btst	#14,dmaconr(a5)
	bne	.Wait
	move.l	d3,bltdpth(a5)		; Dest=Screen
	move.w	#32,bltdmod(a5)		; 40-8
	move.w	#%100000000,bltcon0(a5)	; Clear blit
	move.w	#$0,bltcon1(a5)		; Clear
	move.w	#(41*64*3)+4,bltsize(a5)	; Clear
	dbra	d0,Loop1		; Clear rest of bobs

; Now move all cords along
	lea	XCords+18,a0		; A0=Last X cord
	lea	XCords+20,a1		; A1=Last X cord +2
	lea	YCords+18,a2		; A2=Last Y cord
	lea	YCords+20,a3		; A3=Last Y cord +2
	moveq.l	#8,d0
Loop3	move.w	-(a0),-(a1)		; Swap X cords
	move.w	-(a2),-(a3)		; Swap Y cords
	dbra	d0,Loop3


; Next test the mouse
TestMouse
	moveq.l	#0,d0			; Clear d0-d3
	moveq.l	#0,d1	
	moveq.l	#0,d2
	moveq.l	#0,d3
	move.w	joy0dat(a5),d0		; D0=Mouse count
	move.b	d0,d1			; D1=Horiz count
	lsr.w	#8,d0			; D0=Vert count
	move.b	d0,d2			; D2=Vert count
	move.b	d1,d3			; D3=Horiz count
	sub.b	oldv,d0			; Find vertical speed
	sub.b	oldh,d1			; Find horiz speed
	move.b	d2,oldv			; Save current vert count
	move.b	d3,oldh			; Save current horiz count
	ext.w	d0			; Make d0 word incase of neg numb
	ext.w	d1			; Ditto
	add.w	d0,YCords		; Calculate new Y cord
	add.w	d1,XCords		; Calculate new X cord

; Check XY cords to make sure cord aint off screen
	cmp.w	#0,XCords		; Is X neg?
	bge	.Ok1
	move.w	#0,XCords
.Ok1	cmp.w	#0,YCords		; Is Y neg?
	bge	.Ok2
	move.w	0,YCords
.Ok2	cmpi.w	#257,XCords		; Is X at max?
	blt	.Ok3
	move.w	#256,XCords
.Ok3	cmpi.w	#216,YCords		; Is Y at max?
	blt	Bobs
	move.w	#215,YCords

; Work out XY cords
Bobs	lea	XCords,a0		; A0=Address of X cords
	lea	YCords,a1		; A1=Address of Y cords
	moveq.l	#8,d0			; D0=Number of bobs to blit
Loop2	moveq.l	#0,d1			; clear d0-d3
	moveq.l	#0,d2
	moveq.l	#0,d3	
	move.w	(a0)+,d1		; D1=X cord
	move.w	(a1)+,d3		; D3=Y cord
	mulu	#120,d3			; Convert Y
	divu	#16,d1			; Convert X
	lsl.w	d1			; Multiply by 2
	add.w	d1,d3			; Add X to Y
	add.l	#Screen,d3		; D3=Address of screen
	swap	d1			; Get shift value
	lsl.w	#8,d1			; Shift 12
	lsl.w	#4,d1			
	move.w	#%111111110010,d2	; D2=bltcon0 Value
	or.w	d1,d2			; OR shift value
	
; First copy background data
Copy	btst	#14,dmaconr(a5)
	bne	Copy	
	move.l	d3,bltapth(a5)		; Source=Screen
	move.l	#SavedD,bltdpth(a5)	; Dest=mem
	move.w	#32,bltamod(a5)		; 40-8
	move.w	#0,bltdmod(a5)		; No D modulo
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	#%100111110000,bltcon0(a5) ; A-D blit
	move.w	#$0,bltcon1(a5)		; Clear
	move.w	#(41*64*3)+4,bltsize(a5)

; Now blit bob
Bobb	btst	#14,dmaconr(a5)
	bne	Bobb
	move.l	#bob,bltapth(a5)	; A Source=bob
	move.l	#Mask,bltbpth(a5)	; B Source=Mask
	move.l	#SavedD,bltcpth(a5)	; C Source=Saved data
	move.l	d3,bltdpth(a5)		; D Destin=Screen+XY
	move.w	#0,bltamod(a5)		; No A-c modulos
	move.w	#0,bltbmod(a5)
	move.w	#0,bltcmod(a5)
	move.w	#32,bltdmod(a5)		; 40-8
	move.w	d2,bltcon0(a5)
	move.w	d1,bltcon1(a5)
	move.w	#(41*64*3)+4,bltsize(a5) ; Blit!	
	dbra	d0,Loop2
	rts

*****************************************************************************
;			       Clean Up
*****************************************************************************
CleanUp
	move.w	#$83e0,dmacon(a5)	; Enable sprite dma
	move.l	gfxbase,a1		; A1=Address of gfx lib
	move.l	38(a1),cop1lch(a5)	; Load sys copper list
	move.w	#$0,copjmp1(a5)		; Run sys copper list
	move.l	4,a6			; Exec base
	move.l	gfxbase,a1
	jsr	-408(a6)		; Close library
	jsr	-138(a6)		; Permit
	moveq.l	#0,d0			; Keep CLI happy
error	rts				; Bye Bye



*****************************************************************************
;			Copper List
*****************************************************************************
	section	copper,data_c		; Chip data
Copperlist
	dc.w	diwstrt,$2c81		; window start	
	dc.w	diwstop,$2cc1		; window stop
	dc.w	ddfstrt,$38		; data fetch start
	dc.w	ddfstop,$d0		; data fect stop
	dc.w	bplcon0,%0011001000000000 ; 5 bitplanes
	dc.w	bplcon1,$0		; Clear scroll register
	dc.w	bplcon2,$0		; Clear priority register
	dc.w	bpl1mod,80		; No modulo (odd)
	dc.w	bpl2mod,80		; No modulo (even)
; Bitplane pointers
bph1	dc.w	bpl1pth,$0	
bpl1	dc.w	bpl1ptl,$0
bph2	dc.w	bpl2pth,$0
bpl2	dc.w	bpl2ptl,$0
bph3	dc.w	bpl3pth,$0
bpl3	dc.w	bpl3ptl,$0
; Colours
	dc.w	$0180,$0000,$0182,$0500,$0184,$0600,$0186,$0700
	dc.w	$0188,$0800,$018a,$0900,$018c,$0a00,$018e,$0b00

	
	dc.w	$ffff,$fffe		; Wait for lufc to win something!


*****************************************************************************
;			     Variables
*****************************************************************************
	section	variables,data		; Public
gfxname	dc.b	'graphics.library',0
	even
gfxbase	dc.l	0			; Space for gfx base address

oldh	dc.b	0
oldv	dc.b	0
	even
XCords	dcb.w	30,$0
YCords	dcb.w	30,$0

*************************
* Chip Data & Variables *
*************************
	section	gfxstuff,data_c
screen	dcb.b	256*40*3,$0		; Screen data 
savedD	dcb.b	41*8*3,$0		; Saved screen space
Bob	incbin	'Source:Raistlin/MouseBob.gfx'
Mask	incbin	'Source:Raistlin/MouseBob.mask'
