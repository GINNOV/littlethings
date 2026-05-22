** This little proggy stops people ripping gfx with software rippers!
** Coldcapture routine by Steve Farrimonds
** Replay routine by Mike Cross
** Reset routine from Hardware Reference Manual
** Rest by Raist


       opt c-				   
       include sys:include/exec/exec_lib.i
       include source:include/hardware.i

; get enough memory to load program into and set cold capture
       move.l   4,a6
       move.l   #PROGRAM_END-PROGRAM,d0    ; size of program 
       move.l   #1,d1                      ; use chip memory
       jsr      _LVOallocmem(a6)           ; get the memory
       beq      ERROR                      ; an error
       move.l   d0,a1                      ; get address of memory to be used
       move.l   a1,42(a6)                  ; enter address into coldcapture
       move.w   #PROGRAM_END-PROGRAM,d0    ; size of program for loop
       lea      PROGRAM,a0                 ; program address
LOOP1  move.b   (a0)+,(a1)+                ; load program into memory
       dbra     d0,LOOP1   

; recalculate coldcapture checksum
 
          move.l   #0,d1                  
          lea      34(a6),a0
          move.w   #22,d0
LOOP2     add.w    (a0)+,d1
          dbra     d0,LOOP2
          not.w    d1
          move.w   d1,82(a6)
       	  jmp	   piccy	       ;Show the piccy
ERROR     rts



PROGRAM:
        move.l   a5,resume            	; store register a5
	jsr      DISP                 	; branch to program to execute
        move.l   resume,a5            	; put back contents of a5
        jmp      (a5)                 	; continue reset routine


DISP    
	move.l	#dragonend,d0	        ;End address Of module in d0
	move.l	#dragon,a0	        ;Start address of module in a0
LOOPY	move.l	#0,(a0)+	        ;Wipe long word & increment a0
	cmp.l	d0,a0		        ;Are we at end of module?
	blt	loopy		        ;No
 

RESET	cnop	0,4		  
	move.l	4,a6
	lea	MagicResetCode(pc),a5	;Location of code to strap to
	jsr	-30(a6)			;Get into supervisor mode

	cnop	0,4
MagicResetCode
	lea	2,a0			;Point to JMP instruction at start of ROM
	RESET				;All RAM goes away now!
	jmp	(a0)			;Rely on prefetch to execute this
					;Instruction
PROGRAM_END:

resume dc.l 0
	even


;Display the picture
piccy
	lea	$dff000,a5		;a5 is hardware base
	move.l	4,a6			;EXEC base
	jsr	-132(a6)		;Forbid!!
	lea	gfxname,a1		;we're use gfx.lib
	moveq.l	#0,d0			;any version
	jsr	-552(a6)		;And OPEN!!
	tst.l	d0			;dit it open?
	beq	quit			;no
	move.l	d0,gfxbase		;save gfx base address

*************************************************************************
;			DO THE INTRO 
*************************************************************************
;set-up picture
	move.l	#dragon,d0		;Address of intro grafix
;bitplane1
	move.w	d0,bp1l+2		;Load bitplane pointers
	swap	d0
	move.w	d0,bp1h+2
	swap	d0
	add.l	#40*256,d0		;Size of bitplanes
;bitplane2
	move.w	d0,bp2l+2
	swap	d0
	move.w	d0,bp2h+2
	swap	d0
	add.l	#40*256,d0
;bitplane3
	move.w	d0,bp3l+2
	swap	d0
	move.w	d0,bp3h+2
	swap	d0
	add.l	#40*256,d0
;bitplane4
	move.w	d0,bp4l+2
	swap	d0
	move.w	d0,bp4h+2
	swap	d0
	add.l	#40*256,d0
;bitplane5
	move.w	d0,bp5l+2
	swap	d0
	move.w	d0,bp5h+2
	move.l	#copper,cop1lch(a5)	;Load copper
	clr.w	copjmp1(a5)		;Run copper list


wait	btst	#6,$bfe001		;Test for LMP
	bne	wait

****************************************************************************
;		CLEAN-UP & BYE,BYE!!
****************************************************************************
clean_up
	move.w	#$83e0,dmacon(a5)
	move.l	gfxbase,a1	
	move.l	38(a1),cop1lch(a5)	;Restore system copper
	move.w	#$0,copjmp1(a5)		;& run sys copper
	move.l	4,a6			;EXEC base
	jsr	-138(a6)		;Permit!!
	move.l	gfxbase,a1		;gfx to close
	jsr	-414(a6)		;and close!!
	move.l	#dragonend,d0	        ;End address Of module in d0
	move.l	#dragon,a0	        ;Start address of module in a0
LOOPY1	move.l	#0,(a0)+	        ;Wipe long word & increment a0
	cmp.l	d0,a0		        ;Are we at end of module?
	blt	loopy1		        ;No
quit	rts				;BYE!BYE!

************************************************************************
;			 COPPER LIST
************************************************************************
	section	copperlist,code_c
copper
	dc.w	dmacon,$20		
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,%0101001000000000
	dc.w	bplcon1,$0

;colours
	dc.w	color00,$000,color01,$200,color02,$400,color03,$040
	dc.w	color04,$221,color05,$421,color06,$233,color07,$711
	dc.w	color08,$642,color09,$940,color10,$644,color11,$03b
	dc.w	color12,$654,color13,$15b,color14,$a34,color15,$42b
	dc.w	color16,$864,color17,$26c,color18,$a64,color19,$876
	dc.w	color20,$988,color21,$49d,color22,$d95,color23,$bc4
	dc.w	color24,$ba7,color25,$ba9,color26,$ed7,color27,$cbb
	dc.w	color28,$adc,color29,$dca,color30,$dec,color31,$ffe

bp1h	dc.w	bpl1pth,$0
bp1l	dc.w	bpl1ptl,$0
bp2h	dc.w	bpl2pth,$0
bp2l	dc.w	bpl2ptl,$0
bp3h	dc.w	bpl3pth,$0
bp3l	dc.w	bpl3ptl,$0
bp4h	dc.w	bpl4pth,$0
bp4l	dc.w	bpl4ptl,$0
bp5h	dc.w	bpl5pth,$0
bp5l	dc.w	bpl5ptl,$0
	dc.w	$ffff,$fffe


gfxname	dc.b	'graphics.library',0		;Load gfx lib
	even
gfxbase	dc.l	0				;Gfx base address goes here
dragon	incbin	source:bitmaps/dragonlogo.r
dragonend
