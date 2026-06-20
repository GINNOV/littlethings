; An example for my MaskMaker routine

; Coded by Raistlin
; Grafix by Wing (wheres Notman?)



	include	ram:hardware.i		; Harware equates
	opt	c-			; Case independant
	section	Cookie,code		; Use public memory

	lea	$dff000,a5		; Address of DMA in a5

	move.l	4,a6			; A6=Exec base
	lea	gfxname,a1		; address of lib name in a1
	moveq.l	#0,d0			; Any version
	jsr	-552(a6)		; Open the lib
	move.l	d0,gfxbase		; Save base address of gfx lib
	beq	error			; Quit if error found
	
	jsr	-132(a6)		; Forbid

	
****************************************************************************
;		Load the bitplane pointers
****************************************************************************
	move.l	#Screen,d0		; D0=Address of the screen

	move.w	d0,bpl1+2		; Load the bpl pointers
	swap	d0
	move.w	d0,bph1+2
	swap	d0
	add.l	#40*256,d0
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2
	swap	d0
	add.l	#40*256,d0
	move.w	d0,bpl3+2
	swap	d0
	move.w	d0,bph3+2
	swap	d0
	add.l	#40*256,d0
	move.w	d0,bpl4+2
	swap	d0
	move.w	d0,bph4+2
	swap	d0
	add.l	#40*256,d0		; Get to end of picture data

Make_Palette
	lea	colours,a3		; Address of colours in CList
	move.l	d0,a4			; Address of colours in file
	move.w	#$180,d0		; d0=Colorregister 0
	moveq.l	#15,d5			; D5=Number of colours to load

Colloop
	move.w	d0,(a3)+		; Insert color register into a3
	move.w	(a4)+,(a3)+		; Color into a3
	addq.l	#2,d0			; Next colour register in d0
	dbra	d5,colloop		; Keep loading colours until end

; Set-up the DMA
	move.w	#$20,dmacon(a5)		; Disable sprites
	move.l	#Copperlist,cop1lch(a5)	; Load my copper list
	move.w	#$0,copjmp1(a5)		; Run my copper list




; ©1991 Mask Maker Version 1.0    by Raistlin of DragonMasters/Unity

; To get the best results from this sub-routine you will probably want
; to optimise the code, feel free.


	move.l	#Bob,a0			; A0=Address of the bob data
	move.l	#BobMask,a1		; A1=Address of where mask will
					; go
	move.l	width,d0		; width of bob in words-1
	move.l	height,d1		; Height of bob in lines-1
	move.l	bpls,d2			; Amount of bitplanes-1
MaskLoop
	move.w	(a0)+,d3		; Copy bob data into d3
	or.w	d3,(a1)+		; Build the mask
	
	dbra	d0,MaskLoop	
	
	move.l	width,d0		; Reset width counter
	dbra	d1,Maskloop		; Decrease height counter

	move.l	width,d0		; Reset width counter
	move.l	Height,d1		; Reset height counter
	move.l	#BobMask,a1		; Reset mask pointer
	dbra	d2,MaskLoop		; Decrement bitplane counter




; Start of the cookie-cut!	
	bsr	GetSource		; Save the background data
MouseWait
	bsr	Blitter			; Blit the bob
	btst	#6,$bfe001		; Test LMB
	bne	MouseWait


****************************************************************************
;		Clean-up the system ready to leave
****************************************************************************
Clean_Up
	move.w	#$8e30,dmacon(a5)	; Enable sprites
	move.l	gfxbase,a1
	move.l	38(a1),cop1lch(a5)	; System copper list
	move.w	#$0,copjmp1(a5)		; Run the system copper
	move.l	4,a6			; A6=Exec base
	move.l	gfxbase,a1		; address of gfx lib in a1
	jsr	-408(a6)		; Close the lib
	jsr	-138(a6)		; Permit

error	rts				; End the program




****************************************************************************
;		The Blitter Operations!
****************************************************************************
; Blit the bob to the screen (note local labels used)

Blitter
	lea	Bob,a0			; A0=Address of bob
	lea	BobMask,a1		; A1=Mask
	lea	Backgr,a2		; A2=Saved background data
	lea	Screen+40*153+6,a3	; A3=Address of screen + offset
	
	move.l	#3,d0			; D0=Number of bitplanes-1
.BlitLoop
	bsr	BlitterBusy		; Check the blitter status
	bsr	.BlitBob		; blit the bob	
	add.l	#22*55,a0		; Get to next bob plane
	add.l	#22*55,a2		; Get to next saved data plane
	add.l	#40*256,a3		; Get to next screen plane
	dbra	d0,.BlitLoop		; Keep blitting them planes!
	rts				; And return

.BlitBob
	move.l	a0,bltapth(a5)		; A=bob data
	move.l	a1,bltbpth(a5)		; B=Mask data
	move.l	a2,bltcpth(a5)		; C=Saved background data
	move.l	a3,bltdpth(a5)		; D=Screen
	move.w	#$0,bltamod(a5)		; Clear A's modulo
	move.w	#$0,bltbmod(a5)		; Clear B's modulo
	move.w	#$0,bltcmod(a5)		; clear C's modulo
	move.w	#18,bltdmod(a5)		; D modulo=18
	move.w	#$ffff,bltafwm(a5)	; no mask
	move.w	#$ffff,bltalwm(a5)	; no mask
	move.w	#%0000111111110010,bltcon0(a5) ;ABCD blit
	move.w	#%0000110111001011,bltsize(a5) ;176*55
	rts				; Else return



; Copy the destination area into a safe place (not local labels used)

GetSource
	lea	Screen+40*153+6,a0	; A0=Address of screen + offset
	lea	Backgr,a1		; Address of destination

	move.l	#3,d0			; D0=number of bitplanes -1
.BlitLoop
	bsr	BlitterBusy		; Check blitter status
	bsr	.BlitBob		; Blit the bob
	add.l	#256*40,a0		; Get to next screen plane
	add.l	#22*55,a1
	dbra	d0,.BlitLoop		; Keep blitting them planes!	
	rts				; And return

.BlitBob
	move.l	a0,bltapth(a5) 		; A=Screen
	move.l	a1,bltdpth(a5)		; D=Memory to hold data
	move.w	#18,bltamod(a5)		; A's modulo=18
	move.w	#$0,bltdmod(a5)		; D's modulo=0
	move.w	#$ffff,bltafwm(a5)	; no mask
	move.w	#$ffff,bltalwm(a5)	; no mask
	move.w	#%0000100111110000,bltcon0(a5) ;A-D blit
	move.w	#%0000110111001011,bltsize(a5) ;176*55
	rts




BlitterBusy
	btst	#14,$dff002		; Is blitter working?
	bne	BlitterBusy		; If yes keep looping
	rts	



****************************************************************************
;			THE COPPER LIST
****************************************************************************
	section	copperlist,code_c	; Chip memory
Copperlist	
	dc.w	diwstrt,$2c81		; Window start
	dc.w	diwstop,$2cc1		; Window stop
	dc.w	ddfstrt,$38		; Data fetch start
	dc.w	ddfstop,$d0		; Data fetch stop
	dc.w	bplcon0,%0100001000000000
	dc.w	bplcon1,$0

colours	ds.w	32			; Space for colours
	dc.w	color00,$0		; Make background colour black as it
					; is green in the file!

bph1	dc.w	bpl1pth,$0		; The bitplane pointers
bpl1	dc.w	bpl1ptl,$0
bph2	dc.w	bpl2pth,$0
bpl2	dc.w	bpl2ptl,$0
bph3	dc.w	bpl3pth,$0
bpl3	dc.w	bpl3ptl,$0
bph4	dc.w	bpl4pth,$0
bpl4	dc.w	bpl4ptl,$0

	dc.w	$ffff,$fffe



****************************************************************************
;			Variables
****************************************************************************
gfxname	dc.b	'graphics.library',0	; Name of lib to load
	even
gfxbase	dc.l	0			; Space for libs address

screen	incbin	'source:bitmaps1/Dragon-Background'
bobmask	dcb.b	55*22
bob	incbin	'source:bitmaps1/Dragon.Bob'

Backgr	dcb.b	22*55*4,0		; Space to save background


Width	dc.l	10			; Width in words-1
Height	dc.l	54			; Height-1
bpls	dc.l	3			; Amount of bitplanes-1
