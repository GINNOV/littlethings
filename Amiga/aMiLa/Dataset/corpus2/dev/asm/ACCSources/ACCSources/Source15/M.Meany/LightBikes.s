**
** Light Bikes Version 1.0  simpler design of the full game for ACC15
**
** Written by Raistlin of Dragon Masters
**
** Grafix by me (all my artists are on their hols!)
**
** I plan to make this game far better & use it in the Mega Demo!!
**


	include	source:include/hardware.i		; Harware equates
	opt	c-			; Case independant
	section	Light-Bikes,code	; Use public memory
	
***************************
;Decrunch gfx data, MM.

	lea	piccy,a5		a5->gfx data
	move.l	(a5),d0			get decrunched length
	move.l	d0,ScrnSize		and save it for later
	move.l	#$10002,d1		CHIP,CLEAR
	move.l	$4.w,a6			SysBase
	jsr	-$00c6(a6)		AllocMem
	move.l	d0,Screen		save addr of screen memory
	beq	error			quit if no memory

	move.l	a5,a0			a0->crunched data
	move.l	d0,a1			a1->decrunch buffer

; ByteRun decrunch algorithm. For ArtWerk by M.Meany, July 1991.

; The 1st long word of a crunched data block is the length of the block
;when decrunched. It is up to you to allocate memory for the decrunched
;data. This is not a problem if you have crunched a series of graphics
;that all fit into the same size display as only one block need be obtained.

; Entry		a0->Crunched Data
;		a1->Memory to decrunch into

DeCrunch	lea		4(a0),a0	a0->data

.outer		tst.w		(a0)		end of crunched data ?
		beq		.done		if so quit

		moveq.l		#0,d1		clear register
		move.b		(a0)+,d0	get value

; Remove the semi-colon from the following line for pp efx.

		move.w		d0,$dff180	change color0 

		move.b		(a0)+,d1	and count
		subq.l		#1,d1		adjust for dbra

.inner		move.b		d0,(a1)+	copy next byte
		dbra		d1,.inner	count times

		bra		.outer		go back for more

****************************************
; Back to Raistlins code!

.done	lea	$dff000,a5		; Address of DMA in a5

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
	move.l	Screen,d0		; D0=Address of the screen

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
	add.l	#40*256,d0
	move.w	d0,bpl5+2
	swap	d0
	move.w	d0,bph5+2
	swap	d0
	add.l	#40*256,d0		; Get to end of picture data



****************
; Set-up the DMA
****************
Wait1
	btst	#0,vposr(a5)		; Wait vbl to stop
	bne	Wait1			; sprites corrupting
Wait2	cmpi.b	#55,vhposr(a5)		
	bne	Wait2
	move.w	#$20,dmacon(a5)		; Disable sprites
	move.l	#Copperlist,cop1lch(a5)	; Load my copper list
	move.w	#$0,copjmp1(a5)		; Run my copper list



************************
; Set-Up a VBL interrupt
************************
	move.l	$6c,Oldint+2		; Save old interrupt
	move.l	#NewInt,$6c		; Insert mine




****************************************************************************
;		    The Main Branching Routine
****************************************************************************
MouseWait
	cmpi.b	#6,vhposr(a5)		; Wait vbl
	bne	MouseWait

; Move Bike #1
	move.l	Speed1,d7		; Bike 1's Speed in d7 (see bikes loop)
.loop1	bsr	Movebike1		; Move bike 1
	cmpi.b	#1,Crash1F		; Crash?
	beq	Clean_up		; If so exit
	dbra	d7,.loop1		; Move Bike 1 again if necessary

; Move Bike #2
	move.l	Speed2,d7		; Bike 1's Speed in d7 (see bikes loop)
.loop2	bsr	Movebike2		; Move bike 2
	cmpi.b	#1,Crash2F		; Crash?
	beq	Clean_up		; If so exit
	dbra	d7,.loop2		; Move Bike 2 again if necessary


	bra	MouseWait		; Continue loop





****************************************************************************
;		Clean-up the system ready to leave
****************************************************************************
Clean_Up
	move.l	Oldint+2,$6c		; Restore old int
	move.w	#$8e30,dmacon(a5)	; Enable sprites
	move.l	gfxbase,a1
	move.l	38(a1),cop1lch(a5)	; System copper list
	move.w	#$0,copjmp1(a5)		; Run the system copper
	move.l	4,a6			; A6=Exec base
	move.l	gfxbase,a1		; address of gfx lib in a1
	jsr	-408(a6)		; Close the lib
	jsr	-138(a6)		; Permit

	move.l	Screen,a1		a1->allocated screen mem
	move.l	ScrnSize,d0		Size of block
	jsr	-$00d2(a6)		FreeMem


error	rts				; End the program





****************************************************************************
;			Move Bike #1
****************************************************************************
; If the speed value is more than 1 then this routine will be called more
; than once a frame & hence the bike will move faster.  The speed value is
; reset to make sure that the user is actualy pushing joystick into a
; poisition as well as pressing fire.  This allows fire on its own to be
; used for something else.
MoveBike1
	move.l	#0,Speed1		; Reset speed value
	move.l	Screen,a0
	lea	3001(a0),a0
	move.l	a0,a1
	add.l	Bike1Offset,a0		; Add the offset
	add.l	Bike1Offset,a1		; Add the bikes offset
	move.b	Bike1Bit,d0		; D0=Bit number to set

; This part tests for collisions & sets the bit if no col is detected
; First of all check for a collision with a bike trail
	move.l	#2,d2			; D2=Number of bitplanes to check-1
	move.l	#0,d1			; D1=Counter
.Tail
	btst.b	d0,(a1)			
	bne	.Colission
	add.l	#256*40,a1		; Else check next bitplane
	dbra	d2,.Tail
	cmpi.b	#1,d1
	beq	.CheckCol
	bra	.Hazards		
.Colission
	add.l	#1,d1
	add.l	#256*40,a1
	dbra	d2,.Tail
	cmpi.b	#1,d1
	beq	.CheckCol
	bra	.Hazards

; Check to see if the bike really collided with a tail or if the code
; was something like 1001.  Because only the first 3 bits are checked
; this code would appear to be a collision with a bike tail because it
; would be read as 001.  So lets test the top two bits to make sure
.CheckCol
	btst	d0,(a1)			; Test bit4
	bne	.Hazards		; If set collision was false
	add.l	#256*40,a1		; Test bit5
	btst	d0,(a1)			; If set collision was false
	bne	.Hazards
	bra	Crash1			; If not set collision was true

; Check to see if the bike collided with a hazard by simply checking
; 5th bit because the hazards are made from colours 16-31 so bit must
; be set if a collision has happended
.Hazards
	move.l	Screen,a1
	lea	3001(a1),a1
	add.l	Bike1Offset,a1
	add.l	#(256*40)*4,a1		; Get to hazard bitplane
	btst.b	d0,(a1)			; Is the bit already set?
	bne	Crash1			; If yes then the bikes crashed!
	bset	d0,(a0)			; Set the bit
	move.l	#3,d1			; D1=Number of bitplanes-1
.loop
	add.l	#256*40,a0		; get to next bitplane
	bclr.b	d0,(a0)			; Wipe bits in planes 2-4

	dbra	d1,.loop

; Now work out which bit will be set next frame
	move.b	Right1F,d0		; Copy the direction variables
	move.b	Left1F,d1		; Into the data registers
	move.l	Up1F,d2
	move.l	Down1F,d3

	sub.b	d0,Bike1Bit		; sub right value, if set
	add.b	d1,Bike1Bit		; add the left value, if set
	sub.l	d2,Bike1Offset		; Subtact up value, if set
	add.l	d3,Bike1Offset		; Add down value, if set

	cmpi.b	#-1,Bike1Bit		; 0th bit in this byte set?
	beq	.AddByte		; If so add a byte
	cmpi.b	#8,Bike1Bit		; 7th bit in this byte set?
	beq	.SubByte		; If so subtract a byte
	rts				; Return
.SubByte
	sub.l	#1,Bike1Offset		; Subtract 1 byte
	move.b	#0,Bike1Bit		; Point to 0th bit
	rts				; And return
.AddByte
	add.l	#1,Bike1Offset		; Add 1 byte
	move.b	#7,Bike1Bit		; Point to 7th bit
	rts				; And return

Crash1
	move.b	#1,Crash1F		; Set the crash flag
	rts				; and return

****************************************************************************
;			Move Bike #2
****************************************************************************
; If the speed value is more than 1 then this routine will be called more
; than once a frame & hence the bike will move faster.  The speed value is
; reset to make sure that the user is actualy pushing joystick into a
; poisition as well as pressing fire.  This allows fire on its own to be
; used for something else.
MoveBike2
	move.l	#0,Speed2		; Reset speed value
	move.l	Screen,a0
	lea	3008(a0),a0
	move.l	a0,a1
	add.l	Bike2Offset,a0		; Add the offset
	add.l	Bike2Offset,a1		; Add the bikes offset
	move.b	Bike2Bit,d0		; D0=Bit number to set

; This part tests for collisions & sets the bit if no col is detected
; First of all check for a collision with a bike trail
	move.l	#2,d2			; D2=Number of bitplanes to check-1
	move.l	#0,d1			; D1=Counter
.Tail
	btst.b	d0,(a1)			
	bne	.Colission
	add.l	#256*40,a1		; Else check next bitplane
	dbra	d2,.Tail
	cmpi.b	#1,d1
	beq	.CheckCol
	bra	.Hazards		
.Colission
	add.l	#1,d1
	add.l	#256*40,a1
	dbra	d2,.Tail
	cmpi.b	#1,d1
	beq	.CheckCol
	bra	.Hazards

; Check to see if the bike really collided with a tail or if the code
; was something like 1001.  Because only the first 3 bits are checked
; this code would appear to be a collision with a bike tail because it
; would be read as 001.  So lets test the top two bits to make sure
.CheckCol
	btst	d0,(a1)			; Test bit4
	bne	.Hazards		; If set collision was false
	add.l	#256*40,a1		; Test bit5
	btst	d0,(a1)			; If set collision was false
	bne	.Hazards
	bra	Crash2			; If not set collision was true

; Check to see if the bike collided with a hazard by simply checking
; 5th bit because the hazards are made from colours 16-31 so bit must
; be set if a collision has happended
.Hazards
	move.l	Screen,a1
	lea	3008(a1),a1
	add.l	Bike2Offset,a1
	add.l	#(256*40)*4,a1		; Get to hazard bitplane
	btst.b	d0,(a1)			; Is the bit already set?
	bne	Crash2			; If yes then the bikes crashed!
	add.l	#256*40,a0		; Get to bitplane 2
	bset	d0,(a0)			; Set the bit in plane2 for bike 2
	move.l	#2,d1			; D1=Number of bitplanes-1
.loop
	add.l	#256*40,a0		; get to next bitplane
	bclr.b	d0,(a0)			; Wipe bits in planes 3-4
	dbra	d1,.loop
	move.l	Screen,a0
	lea	3008(a1),a0
	add.l	Bike2Offset,a0		
	bclr.b	d0,(a0)			; Wipe plane1

; Now work out which bit will be set next frame
	move.b	Right2F,d0		; Copy the direction variables
	move.b	Left2F,d1		; Into the data registers
	move.l	Up2F,d2
	move.l	Down2F,d3

	sub.b	d0,Bike2Bit		; sub right value, if set
	add.b	d1,Bike2Bit		; add the left value, if set
	sub.l	d2,Bike2Offset		; Subtact up value, if set
	add.l	d3,Bike2Offset		; Add down value, if set

	cmpi.b	#-1,Bike2Bit		; 0th bit in this byte set?
	beq	.AddByte		; If so add a byte
	cmpi.b	#8,Bike2Bit		; 7th bit in this byte set?
	beq	.SubByte		; If so subtract a byte
	rts				; Return
.SubByte
	sub.l	#1,Bike2Offset		; Subtract 1 byte
	move.b	#0,Bike2Bit		; Point to 0th bit
	rts				; And return
.AddByte
	add.l	#1,Bike2Offset		; Add 1 byte
	move.b	#7,Bike2Bit		; Point to 7th bit
	rts				; And return

Crash2
	move.b	#1,Crash2F		; Set the crash flag
	rts				; and return




****************************************************************************
;		        The New Interrupt
****************************************************************************
NewInt
	movem.l	a0-a6/d0-d7,-(sp)	; Save all registers

	bsr	TestJoy1		; Test the joystick in port 2
	bsr	TestJoy2		; Test the joystick on port 1
	bsr	Flash			; Flash the bikes

	movem.l	(sp)+,a0-a6/d0-d7	; Restore all registers

OldInt	jmp	$0			; Perform old interrupt


****************************************************************************
;		Test The Joystick In Port 2's State
****************************************************************************
TestJoy1
	move.w	$dff00c,d0	; Move JOY1DAT into D0
	btst	#1,d0		; Test bit no. 1
	bne	right1		; Set? If so, joystick right
	btst	#9,d0		; Test bit no. 9
	bne	left1		; Set? If so, joystick left

	move.w	d0,d1		; copy D0 to D1
	lsr.w	#1,d1		; Move Y1 & X1 to pos of Y0 & X0
	eor.w	d0,d1		; Exclusive OR: Y1 EOR X1 & Y0 EOR X0
	btst	#0,d1		; Test result of X1 EOR X0
	bne	back1		; Equal 1? If so, joystick backward
	btst	#8,d1		; Test result of Y1 EOR Y0
	bne	forward1	; Equal 1? If so, joystick forward
	rts			; Joystick not moved

******
Right1
******
	move.b	#1,Right1F	; Set the Right flag (1bit)
	move.b	#0,Left1F	; Reset the left flag 
	move.l	#0,Down1F	; Reset the down flag 
	move.l	#0,Up1F		; Reset the Up flag
	bra	TestFire1a	; Only test for nitro if joystick is in either
	rts			; left, right, up, down position
*****
Left1
*****
	move.b	#1,Left1F	; Set the left flag (1bit)
	move.b	#0,Right1F	; Reset the right flag
	move.l	#0,Up1F		; Reset the up flag
	move.l	#0,Down1F	; Reset the down flag
	bra	TestFire1a	; Test for nitro
	rts			; Return
*****
Back1
*****
	move.l	#40,Down1F	; Set the down flag 
	move.l	#0,Up1F		; Reset the up flag
	move.b	#0,Right1F	; Reset the right flag
	move.b	#0,Left1F	; Reset the left flag
	bra	TestFire1a	; Test for nitro
	rts
********
Forward1
********	
	move.l	#40,Up1F	; Set the up flag (40 bytes, 1 line)
	move.l	#0,Down1F	; Reset the down flag
	move.b	#0,Right1F	; Reset the right flag
	move.b	#0,Left1F	; Reset the left flag
	bra	TestFire1a	; Test for nitro
	rts			; And return


****************************
* Test For The Fire Button *
****************************
; This test for the fire button activates the nitro.  The joystick must be
; in up, down, left ot right poisition.
TestFire1a
	btst	#7,$bfe001	; Test for fire button
	beq	.Fire		; Fire button is pressed
	move.l	#0,Speed1	; Set speed to normal
	rts			; Exit
.Fire
	move.l	#1,Speed1	; Set speed to turbo
	rts			; And return



****************************************************************************
;		Test The Joystick In Port 1's State
****************************************************************************
TestJoy2
	move.w	$dff00a,d0	; Move JOY1DAT into D0
	btst	#1,d0		; Test bit no. 1
	bne	right2		; Set? If so, joystick right
	btst	#9,d0		; Test bit no. 9
	bne	left2		; Set? If so, joystick left

	move.w	d0,d1		; copy D0 to D1
	lsr.w	#1,d1		; Move Y1 & X1 to pos of Y0 & X0
	eor.w	d0,d1		; Exclusive OR: Y1 EOR X1 & Y0 EOR X0
	btst	#0,d1		; Test result of X1 EOR X0
	bne	back2		; Equal 1? If so, joystick backward
	btst	#8,d1		; Test result of Y1 EOR Y0
	bne	forward2	; Equal 1? If so, joystick forward
	rts			; Joystick not moved

******
Right2
******
	move.b	#1,Right2F	; Set the Right flag (1bit)
	move.b	#0,Left2F	; Reset the left flag 
	move.l	#0,Down2F	; Reset the down flag 
	move.l	#0,Up2F		; Reset the Up flag
	bra	TestFire2a	; Only test for nitro if joystick is in either
	rts			; left, right, up, down position
*****
Left2
*****
	move.b	#1,Left2F	; Set the left flag (1bit)
	move.b	#0,Right2F	; Reset the right flag
	move.l	#0,Up2F		; Reset the up flag
	move.l	#0,Down2F	; Reset the down flag
	bra	TestFire2a	; Test for nitro
	rts			; Return
*****
Back2
*****
	move.l	#40,Down2F	; Set the down flag 
	move.l	#0,Up2F		; Reset the up flag
	move.b	#0,Right2F	; Reset the right flag
	move.b	#0,Left2F	; Reset the left flag
	bra	TestFire2a	; Test for nitro
	rts
********
Forward2
********	
	move.l	#40,Up2F	; Set the up flag (40 bytes, 1 line)
	move.l	#0,Down2F	; Reset the down flag
	move.b	#0,Right2F	; Reset the right flag
	move.b	#0,Left2F	; Reset the left flag
	bra	TestFire2a	; Test for nitro
	rts			; And return


****************************
* Test For The Fire Button *
****************************
; This test for the fire button activates the nitro.  The joystick must be
; in up, down, left ot right poisition.
TestFire2a
	btst	#6,$bfe001	; Test for fire button
	beq	.Fire		; Fire button is pressed
	move.l	#0,Speed2	; Set speed to normal
	rts			; Exit
.Fire
	move.l	#1,Speed2	; Set speed to turbo
	rts			; And return




****************************************************************************
;		   Flash The Bikes Tail Colour
****************************************************************************
Flash
	cmpi.b	#0,Delay1	; Is delay at 0?
	bne	DecDelay1	; If not derement it
	move.b	#5,Delay1	; Else restore the delay
	lea	Colours,a0	; A0=Address of colours
	add.l	#6,a0		; Point to desired colour
	move.w	Bike1Col,d0	; D0=Bike 1's second colour
	move.w	Bike2Col,d1	; D1=Bike 2's second colour
	move.w	(a0),Bike1Col	; Save the old colour01
	move.w	d0,(a0)		; Place new colour in palette
	move.w	4(a0),Bike2Col	; Save old colour02
	move.w	d1,4(a0)	; Place new colour in plaette
	rts			; And return
DecDelay1
	sub.b	#1,Delay1	; Decrement the delay
	rts			; And return
	
***************************************************************
; My addittions to make use of ByteRun cruncher, M.Meany.

ScrnSize	dc.l		0
Screen		dc.l		0

piccy	incbin	'source:bitmaps/Crunched_Level1.gfx'


****************************************************************************
;			THE COPPER LIST
****************************************************************************
	section	copperlist,data_c	; Chip memory
Copperlist	
	dc.w	diwstrt,$2c81		; Window start
	dc.w	diwstop,$2cc1		; Window stop
	dc.w	ddfstrt,$38		; Data fetch start
	dc.w	ddfstop,$d0		; Data fetch stop
	dc.w	bplcon0,%0101001000000000
	dc.w	bplcon1,$0

Colours
	dc.w	$0180,$0000,$0182,$00ff,$0184,$0f0f,$0186,$0333
	dc.w	$0188,$0fff,$018a,$0444,$018c,$0555,$018e,$0666	
	dc.w	$0190,$00a0,$0192,$0777,$0194,$0888,$0196,$0aaa
	dc.w	$0198,$0bbb,$019a,$0ccc,$019c,$0eee,$019e,$0fff
	dc.w	$01a0,$0620,$01a2,$0e52,$01a4,$0a52,$01a6,$0fca
	dc.w	$01a8,$0333,$01aa,$0444,$01ac,$0555,$01ae,$0666
	dc.w	$01b0,$0777,$01b2,$0888,$01b4,$0999,$01b6,$0aaa
	dc.w	$01b8,$0ccc,$01ba,$0ddd,$01bc,$0eee,$01be,$0fff


; Bitplanes
bph1	dc.w	bpl1pth,$0		; The bitplane pointers
bpl1	dc.w	bpl1ptl,$0
bph2	dc.w	bpl2pth,$0
bpl2	dc.w	bpl2ptl,$0
bph3	dc.w	bpl3pth,$0
bpl3	dc.w	bpl3ptl,$0
bph4	dc.w	bpl4pth,$0
bpl4	dc.w	bpl4ptl,$0
bph5	dc.w	bpl5pth,$0
bpl5	dc.w	bpl5ptl,$0

	dc.w	$ffff,$fffe



****************************************************************************
;			Variables
****************************************************************************
gfxname	dc.b	'graphics.library',0	; Name of lib to load
	even
gfxbase	dc.l	0			; Space for libs address



*******************
* Data for bike 1 *
*******************
Bike1Offset dc.l	0
Speed1	    dc.l	0
Bike1Col    dc.w	$00f
Bike1Bit    dc.b	0
Crash1F	    dc.b	0
Delay1	    dc.b	5		; Set delay value to 1		
* The joystick variables
Up1F	dc.l	40			; Start bike off by going up
Down1F	dc.l	0
Right1F	dc.b	0
Left1F	dc.b	0

	even

*******************
* Data for bike 2 *
*******************
Bike2Offset dc.l	0
Speed2	    dc.l	0
Bike2Col    dc.w	$f00
Bike2Bit    dc.b	0
Crash2F	    dc.b	0
Delay2	    dc.b	5		; Set delay value to 1		
* The joystick variables
Up2F	dc.l	0
Down2F	dc.l	0
Right2F	dc.b	0
Left2F	dc.b	1			; Start bike of by goin left

	even





