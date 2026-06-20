*-----	Coded by MEGABASS 
*-----	for Compakts spread by DC
*-----	total size when assembled = 41646
*-----	sets up 4 bitplane piccy (16 colours) and uses
*-----	modulos with a value of -40 for the melt effect.
*-----	This routine can easily be adapted to show multiple
*-----	pages. The only use I`ve had for it so far is for disk letters
*-----    where I`ve now got it showing 6 pages of demos and to letter
*-----	pages all in medium res. if you would like a copy get in touch.
*----------------------------------------------------------------------------
	SECTION LOWMEM,CODE_C	Force Code To Chip RAM
	OPT C-			Case Independant
*----------------------------------------------------------------------------
	include	sys:include/hardware/custom.i
*----------------------------------------------------------------------------
Number		=	16-1	;number of colours for the picture
Custom		=	$dff000	;Base Address of cutom chips
Port_A		=	$bfe001	;Mouse
KeyBoard		=	$bfec01	;The thing with letters on (isn`t it?)
Left_Mouse	=	6	;The bit to test	
Joy1		=	7	;The fire button
*--------------------------------------------------------------------------
Start:					
*--------------------------------------------------------------------------
	movem.l	d0-d7/a0-a7,-(sp)		;Move all to stack
	move.l	a7,Stack_Pointer		;save everything
	lea	Custom,a5			;base address
	jsr	Kill_Sys			;goodbye Mr. Dos
	jsr	De_Crunch			;confuse lamers
	jsr	SetUp			;set up the first message
	jsr	Main			;main program loop
	jsr	Rest_Sys			;welcome Mr. Dos
	move.l	Stack_Pointer,a7		;bring it all back
	movem.l	(sp)+,d0-d7/a0-a7		;reset everything
	rts
*--------------------------------------------------------------------------
Kill_Sys:
*--------------------------------------------------------------------------
	move.l	4.w,a6			;welcome Mr. Exec
	jsr	-132(a6)			;forbid what the can`t do
	move.l	(a6),a6
	move.l	(a6),a6			
	move.l	a6,a0			;gfx
	move.l	38(a0),Sys_Copper		;store CLI copper									
	move.w	intenar(a5),Sys_Intena	;store interrupt state 
	move.w	#$8008,intena(a5)
	move.l	$68.w,Sys_Level2		;store level 2 (keyboard etc.)	
	move.l	$6c.w,Sys_Level3		;store level 3 (copper etc.)
	move.w	dmaconr(a5),Sys_Dma		;store DMA state
	move.w	#$7fff,dmacon(a5)		;clear DMA
	move.w	#$87c0,dmacon(a5)		;set DMA
	rts				;dirrr, I dont know.
*--------------------------------------------------------------------------
Rest_Sys:
*--------------------------------------------------------------------------
	move.l	4.w,a6			;welcome Mr. Exec
	jsr	-138(a6)			;bring the power back
	move.w	#$7fff,intena(a5)		;clear my interrupts
	move.l	Sys_Level2,$68.w		;restore level 2			
	move.l	Sys_Level3,$6c.w		;restore level 3
	move.w	Sys_Intena,d0		;restore interrupts
	bset	#$f,d0			
	move.w	d0,intena(a5)		;reset system interrupts
	move.l	Sys_Copper,cop1lc(a5)	;restore CLI copper
	clr.w	copjmp1(a5)		;strobe it
	move.w	Sys_Dma,d0		;restore system DMA		
	bset	#$f,d0			;reset dma
	move.w	d0,dmacon(a5)
	rts
*--------------------------------------------------------------------------
De_Crunch:
*--------------------------------------------------------------------------
	move.w	#9,d1
	move.l	#$ffffffff,d0
J:	move.w	d0,$dff180
F:	dbf	d0,J
	dbf	d1,F
	rts
*--------------------------------------------------------------------------
Main	
*--------------------------------------------------------------------------
	cmpi.b	#$ff,$dff006
	bne.s	Main
	btst	#Left_Mouse,Port_A
	bne	Main			;it hasn`t been pressed
	move.w	#9,d1			;the second decrunch
	move.l	#$ffffffff,d0
P:	move.w	d0,$dff180		;Try any colour register
O:	dbf	d0,P
	dbf	d1,O
	rts
*--------------------------------------------------------------------------
;	data	area
*--------------------------------------------------------------------------
Stack_Pointer:	dc.l	0
Sys_Copper	dc.l	0
Sys_Level2	dc.l	0
Sys_Level3	dc.l	0
Off_Set		dc.l	0
Sys_Dma		dc.w	0
Sys_Intena	dc.w	0
Sys_Intreq	dc.w	0
	even
*--------------------------------------------------------------------------
SetUp:
*--------------------------------------------------------------------------
	lea	Logo,a0
	lea	col,a1
	move.l	#Number,d4
loop:	move.w	(a0)+,(a1)+
	add.w	#2,a1
	dbra	d4,loop
	move.l	a0,d0
	  
	move.w	d0,Pl1l
	swap	d0
	move.w	d0,Pl1h
	swap	d0
	add.w	#256*40,d0
	move.w	d0,Pl2l
	swap	d0
	move.w	d0,Pl2h
	swap	d0
	add.w	#256*40,d0
	move.w	d0,Pl3l
	swap	d0
	move.w	d0,Pl3h
	swap	d0
	add.w	#256*40,d0
	move.w	d0,Pl4l
	swap	d0
	move.w	d0,Pl4h
	move.l	#Copperlist,cop1lc(a5)
	clr.w	copjmp1(a5)
	bsr	Move_Black_Bar
	rts
*--------------------------------------------------------------------------
Move_Black_Bar:
*--------------------------------------------------------------------------
	cmp.b	#1,Move_Flag
	add.w	#$0100,Black_Bar
	bsr	Pause_2
	cmp.w	#$ff01,Black_Bar
	bne	Move_Black_Bar
	move.b	#0,Move_Flag
	rts
BB_Upbarpos:
	rts
Move_Flag:
	dc.b	1
	even
*--------------------------------------------------------------------------
Pause_2:
*--------------------------------------------------------------------------
	moveq.l	#0,d0
	move.l	#$2fff,d0
Nt:
	dbf	d0,Nt
	rts
*--------------------------------------------------------------------------
Copperlist
*--------------------------------------------------------------------------
	dc.w	diwstrt,$2081	
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
		
	dc.w	bplcon0,$4200
	dc.w	$108,$0
	dc.w	$10a,$0

	dc.w	$180
Col:	dc.w	$0,$182,$0,$184,$0,$186,$0,$188,$0,$18a,$0,$18c,$0,$18e,$0
	dc.w	$190,$0,$192,$0,$194,$0,$196,$0,$198,$0,$19a,$0,$19c,$0,$19e,$0

	dc.w	$e0
Pl1h	dc.w	0,$e2				
Pl1l	dc.w	0,$e4		
Pl2h	dc.w	0,$e6				
Pl2l	dc.w	0,$e8		
Pl3h	dc.w	0,$ea				
Pl3l	dc.w	0,$ec		
Pl4h	dc.w	0,$ee				
Pl4l	dc.w	0		

Black_Bar:
	dc.w	$1f01,$fffe,$180,$0000,$108,-40,$10a,-40
	dc.w	$ff01,$fffe,$ffdd,$fffe	; Enable PAL

	dc.w	$ffff,$fffe		
*--------------------------------------------------------------------------
*		Variables and Includes
*--------------------------------------------------------------------------
GFXlib		dc.b	"graphics.library"
		even	
*--------------------------------------------------------------------------
Logo	incbin	source:bitmaps1/ACC_1.raw
	end
