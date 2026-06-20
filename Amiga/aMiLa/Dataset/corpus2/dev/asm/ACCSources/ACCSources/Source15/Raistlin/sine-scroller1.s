**
** First Ever Sine-Scroller   (Don't laugh!!)
**
** Coded by Raistlin of Dragon Masters
**


	include	ram:hardware.i		; Harware equates
	opt	c-			; Case independant
	section	Scrolling,code		; Use public memory

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


****************************************************************************
;		Turn The Sine Data Into What We Need
****************************************************************************
	lea	Sines,a1		; A1=Address of sine table
SineLoop
	move.l	(a1),d0			; D0=Next sine value
	mulu	#40,d0			; Multiply sine by 40
	move.l	d0,(a1)+		; Insert new sine value
	cmpa.l	#SineEnd,a1		; End of sine table
	bne	SineLoop		; If not keep converting
	



****************************************************************************
; 			Set-up the DMA
****************************************************************************
	move.w	#$20,dmacon(a5)		; Disable sprites
	move.w	#%1000010000000000,dmacon(a5)
	move.l	#Copperlist,cop1lch(a5)	; Load my copper list
	move.w	#$0,copjmp1(a5)		; Run my copper list


MouseWait
	bsr	ScrollIt		; Scroll the text
	bsr	DoSine			; Build the sine-wave

WaitVbl	cmpi.b	#250,vhposr(a5)
	bne	WaitVBL

	bsr	TransferIt		; Transfer the data

	btst	#6,$bfe001		; Test LMB
	bne	MouseWait
	bra	Clean_up		; Exit







****************************************************************************
;		Clean-up the system ready to leave
****************************************************************************
Clean_Up
	move.w	#%0000010000000000,dmacon(a5)
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
;		  The Scroll Text Routine -Simple one
****************************************************************************
ScrollIt
	btst	#$a,$dff016		; RMB?
	bne	NoPause
	rts
NoPause
	cmpi.b	#0,Plop			; Time to plop a new character?
	beq	GetChar			; If so get a new one
	bra	Scroll			; Else scoll the window
	bra	PlopIt

; This section gets the next character to blit
getChar
	lea	Font,a2			; A2=Address of font
	move.l	TextP,a4		; A4=Address of text
	move.l	#0,d0			; Clear d0
	move.b	(a4)+,d0		; D0=Character to blit
	cmpi.b	#'x',d0			; End of text?
	bne	.Nope
	move.l	#Text,TextP		; Reload text pointer
	move.l	TextP,a4		; A4=Address of text
	move.b	(a4)+,d0		; D0=character to bllit
.Nope
	move.l	a4,TextP		; Save text pointer

	cmpi.b	#' ',d0			; Is it a space?
	bne	Line?
	move.b	#'[',d0			; Works out as a space

Line?	cmpi.b	#'T',d0			; Which line?
	bls	Line1			; A-T = Line1
	bra	Line2			; U-Z = Line2
Line1
	sub.b	#65,d0			; Work out charcters place
	mulu	#2,d0			; In font
	add.l	d0,a2			
	bra	PlopIt			; And plop it
Line2
	sub.b	#85,d0			; Work out character place
	mulu	#2,d0			; in font
 	add.l	#640,d0
	add.l	d0,a2
	bra	PlopIt


; This routine plops the next character to the screen
PlopIt
	bsr	BlitterBusy		; Test the blitter
	lea	Scrlplane+42,a0		; A0=Destination
	move.l	a2,bltapth(a5)		; Source=Font
	move.l	a0,bltdpth(a5)		; Dest=Screen
	move.w	#38,bltamod(a5)		; 38 A modulo	
	move.w	#44,bltdmod(a5)		; 44 D modulo
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	#$0,bltcon1(a5)		; Clear
	move.w	#%100111110000,bltcon0(a5) ; A-D
	move.w	#(16*64)+1,bltsize(a5)	; 16*16
	move.b	#4,Plop			; reset plop value

; This routine scrolls the window
Scroll
	bsr	BlitterBusy		; Test the blitter state
	lea	Scrlplane+42,a0		; A0=Source
	move.l	a0,bltapth(a5)		; Screen=Source
	sub.l	#2,a0			
	move.l	a0,bltdpth(a5)		; Screen-2=Destination
	move.w	#0,bltamod(a5)		; No A modulo	
	move.w	#0,bltdmod(a5)		; No D modulo
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	#$0,bltcon1(a5)		; Clear bltcon1
	move.w	#%1100100111110000,bltcon0(a5) ; A-D blit 14 pixels shift
	move.w	#(16*64)+23,bltsize(a5) ; 16*368
	sub.b	#1,Plop			; Decrement plop counter
	rts

****************************************************************************
;			Do Sine Wave
****************************************************************************
; Wipe the screen
DoSine
	bsr	BlitterBusy
	move.l	#Buffer,bltdpth(a5)
	move.w	#$0,bltdmod(a5)
	move.w	#%100000000,bltcon0(a5)
	move.w	#(76*64)+20,bltsize(a5)

; Perform the sine wave
	move.l	#15,d0			; D0=Number of pixels in word-1
	move.l	#19,d1			; D1=Number of worrds to blit-1
	move.l	#$8000,d2		; D2=Mask value
	move.l	#0,d3			; D3=Offset
	move.l	#Sines,SineP
GetSine1
	move.l	SineP,a4
	move.l	(a4)+,d4		; D4=Sine value
	cmpi.l	#$ff,d4			; End of sine table?
	bne	.Nope
	move.l	#Sines,a4		; A4=Sine pointer
	move.l	(a4)+,d4		; D4=Sine value
.Nope
	move.l	a4,SineP		; Save sine pointer
	lea	ScrlPlane,a0		; Source=ScrollText plane
	lea	Buffer,a1		; Dest=Buffer+Offset
	add.l	d3,a0			; Get to word to blit
	add.l	d3,a1			; Get to word to blit
	add.l	d4,a1			; Add Y offset to dest
	
	bsr	BlitterBusy		; test blitter busy
	move.l	a0,bltapth(a5)		; Source=Scroll plane
	move.l	a1,bltbpth(a5)		; Source=Destination
	move.l	a1,bltdpth(a5)		; Dest=Buffer
	move.w	#44,bltamod(a5)		; A modulo=46-2
	move.w	#38,bltbmod(a5)		; B modulo=40-2
	move.w	#38,bltdmod(a5)		; D modulo=40-2
	move.w	d2,bltafwm(a5)		; D2=Pre-loaded mask value
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	#$0,bltcon1(a5)		; Clear
	move.w	#%110111111100,bltcon0(a5) ; AB-D blit
	move.w	#(16*64)+1,bltsize(a5)	; 16*16
	
	lsr.w	#1,d2			; Mask next pixel to the right
	dbra	d0,GetSine1		; Blit rest of word

	move.l	#$8000,d2		; Reset mask value
	move.l	#15,d0			; Reset counter 1
	add.l	#2,d3			; Get to next word
	dbra	d1,GetSine1		; Blit next word
	rts




****************************************************************************
;		    Transfer The Sine-Wave
****************************************************************************	
; First wipe the screen
TransferIt
	bsr	BlitterBusy
	move.l	#Screen+4000,bltdpth(a5); Dest=Screen
	move.w	#$0,bltdmod(a5)		; No D modulo
	move.w	#%100000000,bltcon0(a5)	; D blit -Wipe
	move.w	#(76*64)+20,bltsize(a5)	; 60*320


; Now transfer the sine-wave
	bsr	BlitterBusy
	move.l	#Buffer,bltapth(a5)	; Source=Buffer
	move.l	#Screen+4000,bltdpth(a5); Dest=Screen
	move.w	#$0,bltamod(a5)		; No A modulo
	move.w	#$0,bltdmod(a5)		; No D modulo
	move.w	#$0,bltcon1(a5)		; Clear
	move.w	#%100111110000,bltcon0(a5); A-D blit
	move.w	#(76*64)+20,bltsize(a5)	; 60*320
	rts





BlitterBusy
	btst	#14,dmaconr(a5)		; whats the blitter upto?
	bne	BlitterBusy		; Slaving away
	rts				; Fuck-all



****************************************************************************
;			THE COPPER LIST
****************************************************************************
	section	copperlist,code_c	; Chip memory
Copperlist	
	dc.w	diwstrt,$2c81		; Window start
	dc.w	diwstop,$2cc1		; Window stop
	dc.w	ddfstrt,$38		; Data fetch start
	dc.w	ddfstop,$d0		; Data fetch stop
	dc.w	bplcon0,%0001001000000000
	dc.w	bplcon1,$0

	dc.w	bpl1mod,$0,bpl2mod,$0

	dc.w	color00,$000,color01,$fff

bph1	dc.w	bpl1pth,$0		; The bitplane pointers
bpl1	dc.w	bpl1ptl,$0



	dc.w	$9001,$fffe,$0182,$0f00
	dc.w	$9101,$fffe,$0182,$0f10
	dc.w	$9201,$fffe,$0182,$0f20
	dc.w	$9301,$fffe,$0182,$0f30
	dc.w	$9401,$fffe,$0182,$0f40
	dc.w	$9501,$fffe,$0182,$0f50
	dc.w	$9601,$fffe,$0182,$0f60
	dc.w	$9701,$fffe,$0182,$0f70
	dc.w	$9801,$fffe,$0182,$0f80
	dc.w	$9901,$fffe,$0182,$0f90
	dc.w	$9a01,$fffe,$0182,$0fa0
	dc.w	$9b01,$fffe,$0182,$0fb0
	dc.w	$9c01,$fffe,$0182,$0fc0
	dc.w	$9d01,$fffe,$0182,$0fd0
	dc.w	$9e01,$fffe,$0182,$0fe0
	dc.w	$9f01,$fffe,$0182,$0ff0
	dc.w	$a001,$fffe,$0182,$0ef0
	dc.w	$a101,$fffe,$0182,$0df0
	dc.w	$a201,$fffe,$0182,$0cf0
	dc.w	$a301,$fffe,$0182,$0bf0
	dc.w	$a401,$fffe,$0182,$0af0
	dc.w	$a501,$fffe,$0182,$09f0
	dc.w	$a601,$fffe,$0182,$08f0
	dc.w	$a701,$fffe,$0182,$07f0
	dc.w	$a801,$fffe,$0182,$06f0
	dc.w	$a901,$fffe,$0182,$05f0
	dc.w	$aa01,$fffe,$0182,$04f0
	dc.w	$ab01,$fffe,$0182,$03f0
	dc.w	$ac01,$fffe,$0182,$02f0
	dc.w	$ad01,$fffe,$0182,$01f0
	dc.w	$ae01,$fffe,$0182,$00f0
	dc.w	$af01,$fffe,$0182,$00f1
	dc.w	$b001,$fffe,$0182,$00f2
	dc.w	$b101,$fffe,$0182,$00f3
	dc.w	$b201,$fffe,$0182,$00f4
	dc.w	$b301,$fffe,$0182,$00f5	
	dc.w	$b401,$fffe,$0182,$00f6
	dc.w	$b501,$fffe,$0182,$00f7
	dc.w	$b601,$fffe,$0182,$00f8
	dc.w	$b701,$fffe,$0182,$00f9
	dc.w	$b801,$fffe,$0182,$00fa
	dc.w	$b901,$fffe,$0182,$00fb
	dc.w	$ba01,$fffe,$0182,$00fc
	dc.w	$bb01,$fffe,$0182,$00fd
	dc.w	$bc01,$fffe,$0182,$00fe
	dc.w	$bd01,$fffe,$0182,$00ff
	dc.w	$be01,$fffe,$0182,$00ef
	dc.w	$bf01,$fffe,$0182,$00df
	dc.w	$c001,$fffe,$0182,$00cf
	dc.w	$c101,$fffe,$0182,$00bf
	dc.w	$c201,$fffe,$0182,$00af
	dc.w	$c301,$fffe,$0182,$009f
	dc.w	$c401,$fffe,$0182,$008f
	dc.w	$c501,$fffe,$0182,$007f
	dc.w	$c601,$fffe,$0182,$006f
	dc.w	$c701,$fffe,$0182,$005f
	dc.w	$c801,$fffe,$0182,$004f
	dc.w	$c901,$fffe,$0182,$003f
	dc.w	$ca01,$fffe,$0182,$002f
	dc.w	$cb01,$fffe,$0182,$001f
	dc.w	$cc01,$fffe,$0182,$000f
	dc.w	$cd01,$fffe,$0182,$000d
	dc.w	$ce01,$fffe,$0182,$000b
	dc.w	$cf01,$fffe,$0182,$0009
	dc.w	$d001,$fffe,$0182,$0007
	dc.w	$d101,$fffe,$0182,$0005

	


	dc.w	$ffff,$fffe



****************************************************************************
;			Variables
****************************************************************************
gfxname	dc.b	'graphics.library',0	; Name of lib to load
	even
gfxbase	dc.l	0			; Space for libs address

screen	dcb.b	256*46,0
Buffer	dcb.b	76*40,0
scrlplane 	dcb.b	16*46,0


; The ScrollText variables
Font	incbin	'source:bitmaps1/Sine.Font'
Plop	dc.b	0
TextP	dc.l	Text
Text	dc.b	'HI TO ALL YOU ACC READERS      AS YOU CAN SEE I HAVE NOT '
	dc.b	'YET PERFECTED THE SINE SCROLLER        HOWEVER I HOPE TO '
	dc.b	'DO BETTER AFTER READING TECHS TUTORIAL         GREETS TO     '
	dc.b 	'BLAINE EVANS      MARK MEANY     TECH     MIKE CROSS     MASTER BEAT        '
	dc.b	'DAVE EDWARDS      TREE BEARD     NIPPER     WIG          SIMON FARRIMONDS     '
	dc.b	'MARK FLEMANS      STEVE SUITOR      AND ANYONE ELSE WHO HAS CONTRIBUTED TO ACC            RAISTLIN                  x'


; The SineWave variables
SineP	dc.l	Sines
Sines	dc.l	50,50,50,50,50,50,49,49,49,49,48,48,48,47,47,47
	dc.l	46,46,45,45,44,44,43,42,42,41,40,40,39,38,37,37
	dc.l	36,35,34,34,33,32,31,30,29,28,28,27,26,25,24,23
	dc.l	22,22,21,20,19,18,17,16,16,15,14,13,12,12,11,10
	dc.l	10,9,8,8,7,6,6,5,5,4,4,3,3,3,2,2,2,1,1,1,1,0,0,0
	dc.l	0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,3
	dc.l	3,3,4,4,5,5,6,6,7,8,8,9,10,10,11,12
	dc.l	13,13,14,15,16,16,17,18,19,20,21,22,22,23,24,25
	dc.l	26,27,28,28,29,30,31,32,33,34,34,35,36,37,37,38
	dc.l	39,40,40,41,42,42,43,44,44,45,45,46,46,47,47,47
	dc.l	48,48,48,49,49,49,49,50,50,50,50,50
SineEnd	dc.l	$ff
