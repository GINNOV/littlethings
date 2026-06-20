; This is version 2 of my move bob routine.

; A note to my contacts, I sent you the bugged version, sorry.
; this one doesn't flicker!  Compare the two sources & you'll see
; that 4 or 5 lines needed deleting & a branch instruction was put
; in.  Pritty small bug to remove eh?  It needed removing not fixing!

; Coding by Raistlin of DragonMasters/Unity
; Grafix by Wing of DragonMasters/Unity

; *Note because during a barrel shift the last 15 bits are moved down
;       1 line I advise saving an extra blank word at the end of the
;       bob.  Unless you really don't want to waste memory & then you
;       can use a simple masking technique.



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


; Reset the flags
	move.b	#0,ScrollL
	move.b	#0,ScrollR

	
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



****************************************************************************
;		Get the colours for this screen
****************************************************************************
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


****************************************************************************
;			 Set-up the DMA
****************************************************************************
.Wait1	btst	#0,Vposr(a5)		; Stop
	bne	.Wait1			; the sprite
.Wait2	cmpi.b	#55,Vhposr(a5)		; being
	bne	.Wait2			; corrupted

	move.w	#$20,dmacon(a5)		; Disable sprites
	move.l	#Copperlist,cop1lch(a5)	; Load my copper list
	move.w	#$0,copjmp1(a5)		; Run my copper list



****************************************************************************	
; set-up D1 & D3 & D5 for bltcon0 & bltcon1.  perform the blitter subroutines
****************************************************************************
	move.w	#%0000111111110010,d3	; ABCD blit for bob blit
	move.w	#$0,d5			; Reset bltcon1

	bra	start
MouseWait
	bsr	WaitVbl
	bsr	MoveBob			; Move the bob

	bsr	ClearSource		; Replace the background tile
start	bsr	GetSource		; Get the background tile
	bsr	Blitter			; Blit the bob

	btst	#6,$bfe001		; Test LMB
	bne	MouseWait
	bra	Clean_Up

WaitVbl
	cmpi.b	#255,vhposr(a5)
	bne	WaitVbl
	rts


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
	lea	Screen,a3		; A3=Address of screen + offset
	add.l	Offset,a3
	
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
	move.w	#18,bltdmod(a5)		; D modulo=20
	move.w	#$ffff,bltafwm(a5)	; no mask
	move.w	#$ffff,bltalwm(a5)	; no mask
	move.w	d3,bltcon0(a5) 		;ABCD blit
	move.w	d5,bltcon1(a5)
	move.w	#%0000110111001011,bltsize(a5) ;160*55
	rts				; Else return



; Copy the destination area into a safe place (not local labels used)
GetSource
	lea	Screen,a0		; A0=Address of screen + offset
	add.l	offset,a0
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
	move.w	#18,bltamod(a5)		; A's modulo=20
	move.w	#$0,bltdmod(a5)		; D's modulo=0
	move.w	#$ffff,bltafwm(a5)	; no mask
	move.w	#$ffff,bltalwm(a5)	; no mask
	move.w	#%0000100111110000,bltcon0(a5) ; A-D blit
	move.w	$0,bltcon1(a5)		; B's barrel shift
	move.w	#%0000110111001011,bltsize(a5) ;160*55
	rts



; Clear the bob from screen by replacing background
ClearSource
	lea	Backgr,a0		; Address of Source
	lea	Screen,a1		; A1=Address of screen + offset
	add.l	Offset,a1

	move.l	#3,d0			; D0=number of bitplanes -1
.BlitLoop
	bsr	BlitterBusy		; Check blitter status
	bsr	.BlitBob		; Blit the bob
	add.l	#256*40,a1		; Get to next screen plane
	add.l	#22*55,a0
	dbra	d0,.BlitLoop		; Keep blitting them planes!	
	rts				; And return

.BlitBob
	move.l	a0,bltapth(a5) 		; A=Source
	move.l	a1,bltdpth(a5)		; D=screen
	move.w	#0,bltamod(a5)		; A's modulo=20
	move.w	#18,bltdmod(a5)		; D's modulo=0
	move.w	#$ffff,bltafwm(a5)	; no mask
	move.w	#$ffff,bltalwm(a5)	; no mask
	move.w	#%0000100111110000,bltcon0(a5) ;A-D blit
	move.w	#$0,bltcon1(a5)
	move.w	#%0000110111001011,bltsize(a5) ;160*55
	rts





BlitterBusy
	btst	#14,$dff002		; Is blitter working?
	bne	BlitterBusy		; If yes keep looping
	rts	





****************************************************************************
;		Work out how & where to move the bob
****************************************************************************
MoveBob
	cmpi.b	#160,ScrollR		; Which way?
	bne	Right			; Where scrolling it left
	cmpi.b	#160,ScrollL
	bne	Left

	move.w	#0,ScrollR		; reset the counters
					; with a word write



; Scroll the logo right
Right
	add.b	#1,ScrollR		; Increment scroll counter
	move.w	d3,d4			; Bltcon values	
	and.w	#%1111000000000000,d4	; Get rid of lower 12bits
	cmpi.w	#%1111000000000000,d4	; End of barrel shift
	beq	.IncDest
	add.w	#%0001000000000000,d3	; Increment A & B shift values
	add.w	#%0001000000000000,d5	
	rts

.IncDest
	and.w	#%0000111111111111,d3
	and.w	#%0000111111111111,d5	; Scrub shift values (keep rest)
	bsr	ClearSource		; Replace background
	add.l	#2,Offset		; Add 2 to the offset
	bsr	GetSource		; Get the background data
	rts				; and return


; Scroll the logo left
Left
	add.b	#1,ScrollL		; Increment scroll counter
	move.w	d3,d4			; Bltcon values	
	and.w	#%1111000000000000,d4	; Get rid of lower 12bits
	cmpi.w	#%0000000000000000,d4	; End of barrel shift
	beq	.IncDest
	sub.w	#%0001000000000000,d3	; Increment A & B shift values
	sub.w	#%0001000000000000,d5	
	rts
.IncDest
	or.w	#%1111000000000000,d3	; Insert all shift values
	or.w	#%1111000000000000,d5	; Leave the rest alone
	bsr	ClearSource		; Replace background
	sub.l	#2,Offset		; Add 2 to the offset
	bsr	GetSource		; Get the background data
	rts				; and return





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


Offset	dc.l	40*153

ScrollR	dc.b	0
ScrollL	dc.b	0


screen	incbin	'source:bitmaps1/Dragon-Background'
bobmask	incbin	'source:bitmaps1/Dragon.mask'
bob	incbin	'source:bitmaps1/Dragon.Bob'

Backgr	dcb.b	22*55*4,0		; Space to save background
