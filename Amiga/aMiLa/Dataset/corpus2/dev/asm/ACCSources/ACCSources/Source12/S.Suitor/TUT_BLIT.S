
**	Code By MEGABASS
**	Thanx to Mark, Mike, Neil and Spanner.
*---------------------------------------------------------------------------
	OPT C-			Case Independant
*---------------------------------------------------------------------------
	include	sys:include/hardware/custom.i
*---------------------------------------------------------------------------
Number		=	2-1	number of colours for the picture
Custom		=	$dff000	Base Address of cutom chips
Port_A		=	$bfe001	Mouse and Joystick Register
KeyBoard		=	$bfec01	Whats this 	
Left_Mouse	=	6	Rodents Left-Eye
Joy1		=	7	Blast Em'
Screen_Size	=	256*40	Screen Size For Blitter
Logo_Size		=	64*8	Logo (BOB) Size For Blitter
*---------------------------------------------------------------------------
*		Main Calling Routine
*---------------------------------------------------------------------------
	movem.l	a0-a6/d0-d7,-(a7)		 Save all Registers
	move.l	a7,Stack_Save		 Save Pointer
	lea	Custom,a5			 Move Base-Address
	jsr	Kill_OS			 Disable Multitasking etc.
	jsr	Setup			 Setup Bitplanes etc.
	jsr	Main			 Mouse Wait etc.	
	jsr	Help_OS			 Enable Multitasking etc.
	move.l	Stack_Save,a7		 Restore Pointer
	movem.l	(a7)+,a0-a6/d0-d7		 Restore Registers
	rts
*---------------------------------------------------------------------------
Kill_OS:
*---------------------------------------------------------------------------
	move.l	4.w,a6			 Move Execbase 
	jsr	-132(a6)			 Open Library
	move.l	(a6),a6			 Graphics
	move.l	(a6),a6			 library
	move.l	a6,a0
	move.l	38(a0),Sys_Copper		 Store CLI Copper											
	move.w	intenar(a5),Sys_Intena	 Save INTERUPT State	
	move.l	$68.w,Sys_Level2		 Save LEVEL 2	
	move.l	$6c.w,Sys_Level3		 Save LEVEL 3	
	move.w	dmaconr(a5),Sys_Dma		 Save present state
	move.w	#$7fff,dmacon(a5)		 Clear all DMA
	move.w	#%1000001111000000,dmacon(a5)	 Select DMA
	rts				 Return to calling Routine
*---------------------------------------------------------------------------
Setup:
*---------------------------------------------------------------------------
	move.l	#Screen,d0		 Load Screen into d0

	move.w	d0,Pl1l			 Move LO word out
	swap	d0			 Swap LO <-> HI
	move.w	d0,pl1h			 Move HI word out
	swap	d0
	add.l	#Screen_Size,d0
	move.w	d0,Pl2l			 Move LO word out
	swap	d0			 Swap LO <-> HI
	move.w	d0,pl2h			 Move HI word out
	swap	d0
	add.l	#Screen_Size,d0
	move.w	d0,Pl3l			 Move LO word out
	swap	d0			 Swap LO <-> HI
	move.w	d0,pl3h			 Move HI word out
	swap	d0
	add.l	#Screen_Size,d0
	move.w	d0,Pl4l			 Move LO word out
	swap	d0			 Swap LO <-> HI
	move.w	d0,pl4h			 Move HI word out
	swap	d0
	add.l	#Screen_Size,d0
	move.w	d0,Pl5l			 Move LO word out
	swap	d0			 Swap LO <-> HI
	move.w	d0,pl5h			 Move HI word out
	move.l	#Copperlist,Cop1lc(a5)	 Move My Copper in 
	clr.w	Copjmp1(a5)		 Strobe Copper to Start
	rts				 Return to calling Routine
*---------------------------------------------------------------------------
Main:
*---------------------------------------------------------------------------
	cmpi.b	#$f0,VHPosr(a5)	 Compare VHPOSR to 240
	bne.s	Main		 Not Equal GO to Main
	bsr	Start_Blitter	 Go and Start Blit_op		
	btst	#Left_Mouse,Port_A	 Check for mouse
	bne	Main		 Not Equal GO to Main
	rts			 Return to calling Routine
*---------------------------------------------------------------------------
Start_Blitter:
*---------------------------------------------------------------------------
	lea	Logo,a0
	lea	Screen,a1
	bsr	Blit_Table_Loop	Get Bob Position
	add.l	d3,a1		Adds contents of d3 from table below
	moveq.w	#4,d0
SBL:			         ;Start Blit Loop for each Plane	
	bsr	Go_Blit_1	          do this 4* to blit each plane
	dbra	d0,SBL		Do all Bitplanes (5-1)
	rts
*---------------------------------------------------------------------------
Blit_Table_Loop:
*---------------------------------------------------------------------------
	move.l	Table_Ptr,a3		Moves Table Pointer to a3
	move.w	(a3)+,d3			Moves first word out 			
	cmp.w	#$fffe,d3			Compares for end of Table
	bne	Return			Not met, so branch
	move.l	#Blit_Pos_Table,Table_Ptr		
	bra	Blit_Table_Loop		Branch until $fffe
Return:
	move.l	a3,Table_Ptr		Store A3
	rts				Return to Start_Blitter
	
Table_Ptr:	dc.l	Blit_Pos_Table	Pointer to Position table

Blit_Pos_Table:	dc.w	7680,5120,2560,0,8	     Screen Positions
		dc.w	16,24,32,2592,5152	     for Blitter operations	
		dc.w	7712,7704,7696,7688		
		dc.w	5128,2568,2576,2584
		dc.w	5144,5136,$fffe

*---	The Formula I`ve used for the position Calculations is as follows:-
*---	the BOB = 64 lines deep, The width of the screen is 40 bytes wide
*---	so to Blit one directly below another you would do:-

*---	64*40 = 2560 (Hex $0A00), So in the above table the 7680 =
*---	64*40*3 (Bottom blit), The 8, 16, 24 and 32 are bytes, and position
*---	the blits along the top line.

*---------------------------------------------------------------------------
Go_Blit_1:
*---------------------------------------------------------------------------
; Thanx to Mike and Neil for all the help in understanding the blitter


	bsr	Wait_Blit			 Is Blitter ready

	move.l	a0,BltApt(a5)	Set BLTAPTH = A0 = BOB	
	move.l	a1,BltDpt(a5)	Set BLTDPTH = A1 = SCREEN
	move.w	#0,BltAmod(a5)	Set BLTAMOD = Clear 
	move.w	#32,BltDmod(a5)	Set BLTDMOD = to get to next line
	move.w	#$ffff,BltAfwm(a5)	Set BLTAFWM = No MASKING
	move.w	#$ffff,BltAlwm(a5)	Set BLTDLWM = No MASKING
	move.w	#$09f0,Bltcon0(a5) 	Set BLTCON0 = straight A to D
	move.w	#0,Bltcon1(a5)	Set BLTCON1 = Clear
	move.w	#64*64+4,Bltsize(a5)  Set BLITSIZE 64x64/4 (decimal 4100)
	add.l	#Logo_Size,a0	Variable at top
	add.l	#Screen_Size,a1	Variable at top	
	rts			Return to calling Routine
*---------------------------------------------------------------------------
Wait_Blit:
*---------------------------------------------------------------------------
	btst	#14,Dmaconr(a5)		 Is Blitter free ?
	bne.s	Wait_Blit			 No, Not yet!!
	rts 				 Return to calling Routine
*---------------------------------------------------------------------------
Help_OS:
*---------------------------------------------------------------------------
	move.l	$4,a6
	jsr	-138(a6)
	move.w	#$7fff,intena(a5)
	move.l	Sys_Level2,$68.w	
	move.l	Sys_Level3,$6c.w
	move.w	Sys_Intena,d0
	bset	#$f,d0			 Reset Interupt enable
	move.w	d0,intena(a5)
	move.l	Sys_Copper,cop1lc(a5)
	clr.w	copjmp1(a5)
	move.w	Sys_Dma,d0
	bset	#$f,d0			 Reset DMA
	move.w	d0,dmacon(a5)
	rts				 Return to calling Routine
*---------------------------------------------------------------------------
*		Variables and Includes
*---------------------------------------------------------------------------
Stack_Save:	dc.l	0
Sys_Copper	dc.l	0
Sys_Level2	dc.l	0
Sys_Level3	dc.l	0
Off_Set		dc.l	0
Sys_Dma		dc.w	0
Sys_Intena	dc.w	0
Sys_Intreq	dc.w	0
*---------------------------------------------------------------------------
	SECTION  LOWMEM,DATA_C
*---------------------------------------------------------------------------
Copperlist
*---------------------------------------------------------------------------
	dc.w	$0001,$fffe
	dc.w	diwstrt,$2c81		 Start of Screen Window	
	dc.w	diwstop,$2cc1		 Screen window Finish
	dc.w	ddfstrt,$38		 Fetch Data
	dc.w	ddfstop,$d0		 Stop Fetching Data
		
	dc.w	bplcon0,$5200		 Set 1 low-res bitplane

	dc.w	$0180,$0000,$0182,$05ff,$0184,$0001,$0186,$0011
	dc.w	$0188,$0012,$018a,$0023,$018c,$0233,$018e,$0003
	dc.w	$0190,$0113,$0192,$0226,$0194,$0337,$0196,$0035
	dc.w	$0198,$0256,$019a,$0110,$019c,$0210,$019e,$0320
	dc.w	$01a0,$0310,$01a2,$0430,$01a4,$0540,$01a6,$0850
	dc.w	$01a8,$0640,$01aa,$0740,$01ac,$0751,$01ae,$0861
	dc.w	$01b0,$0a72,$01b2,$0850,$01b4,$0862,$01b6,$0a71
	dc.w	$01b8,$0d93,$01ba,$0fc5,$01bc,$0530,$01be,$0000

	dc.w	$e0			 Bitplane 1 High word 
Pl1h	dc.w	0,$e2			 Bitplane 1 Low word				
Pl1l	dc.w	0,$e4
Pl2h	dc.w	0,$e6
Pl2l	dc.w	0,$e8			 Bitplane 1 High word 
Pl3h	dc.w	0,$ea			 Bitplane 1 Low word				
Pl3l	dc.w	0,$ec
Pl4h	dc.w	0,$ee
Pl4l	dc.w	0,$f0			 Bitplane 1 High word 
Pl5h	dc.w	0,$f2			 Bitplane 1 Low word				
Pl5l	dc.w	0
	
	dc.w	$ff99,$fffe,$ffdd,$fffe	 Enable PAL

	dc.w	$ffff,$fffe		 Impossible position		
	even
*---------------------------------------------------------------------------
Logo:		incbin	Source:bitmaps/KING.raw
*---------------------------------------------------------------------------
	even
Screen:		dcb.b	256*40*5,0
	end
