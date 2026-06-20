;SOURCE TO MOVE AND ANIMATE SPRITES
;MOVEMENT LEFT AND RIGHT ONLY
							;BY BLAINE EVANS
							;1 ERITH WAY
							;PONTYBODKIN
							;NR MOLD
							;CLWYD
							;CH7 4TR
							;TEL O352-771673
	opt	c-,d+

custom=$dff000				;custom chip base
pf1_width=40				;playfield_1 width40 words by
pf1_height=200				;height		200 lines
pf1_depth=3				;depth of 3 planes
pf1_planesize=pf1_width*pf1_height	;calculate size of plane in bytes
pf1_sizeof=pf1_planesize*pf1_depth	;*depth
spritesize=14*4				;SPRITE SIZE IN BYTES					
mem_required=pf1_sizeof+spritesize		;memeory required=(40*200)*3=24000 bytes

	move.l	4.w,a6			;FIND EXEC BASE
	lea	gfxlib(pc),a1		;LOAD GRAPHICS LIBRARY IN A1
	moveq	#$00,d0			;VERSION 0
	jsr	-552(a6)		;OPEN LIBRARY
	move.l	d0,_gfxbase		;STORE D0 (GFX ADDRESS )
	beq	nolib_exit		;ELSE EXIT

	move.l	#mem_required,d0	;LOAD MEMORY REQUIRED IN D0
	move.l	#2,d1			;2=CHIP MEMEORY
	jsr	-198(a6)		;ALLOCMEN 
	move.l	d0,membase		;STORE ADDRESS OF MEMORY IN MEMBASE FOR LATER
	beq	nomem_exit		;ELSE IF MEMORY NOT AVAIL EXIT
	bsr	plane_addresses		;BRANCH TO CALCULATE PLANE ADDRESSES
	bsr	sprite_address		;AND TO SPRITE ADDRESSES
	bsr	clear_screen		;CLEAR SCREEN
	bsr	draw_squares		;DRAW GRAPHICS TO MEMORY
	bsr	build_sprite0		;DRAW SPRITE TO MEMORY
	lea	custom,a6		;LOAD A6 WITH CUSTOM BASE ADDRESS
	lea	movement_data,a2
	move.l	_gfxbase,a0		LOAD ADDRESS OF GRAPHICS LIB IN A0
	move.l	50(a0),oldcop		;STORE CURRENT COPPER,ETC TO RETRIEVE LATER
S
	move.l	#newcop,50(a0)		;POINT TO OUR COPPERLIST

wait					;WAIT LOOP
	cmpi.b	#0,$dff006		;VERTICAL BLANKING GAP 
	bne.s	wait			;
	bsr	move_ship0		;BRANCH TO MOVE SPRITE0
	bsr	animate_sprite		;BRANCH TO ANIMATE ROUTINE
	bsr	sprite_movement		;BRANCH TO MOVE ROUTINE
	btst	#$06,$bfe001		;QUIT LEFT MOUSE PRESSED
	bne	wait			;ELSE LOOP TO WAIT
	move.l	_gfxbase,a0		;LOAD GRAPHICS LIB ADDRESS IN A0
	move.l	oldcop,50(a0)		;RESTORE OLD COPPER TO RETURN TO EDITTER
dealloc	
	move.l	4.w,a6			;FIND EXEC BASE
	move.l	membase,a1		;LOAD MEMORY BASE IN A1
	move.l	#mem_required,d0	;AND MEMORY REQUIRED IN D0
	jsr	-210(a6)		;FREEM	MEMORY WE TOOK 
nomem_exit	
	move.l	_gfxbase,a1		;LOAD GRAPHICS BASE IN A1
	jsr	-414(a6)		;CLOSE LIBRARY
nolib_exit
	rts				;RETURN TO EDITER

plane_addresses				;CALCULATE PLANE ADDRESSES
	move.l	membase,d0		;LOAD MEMORY STARTING ADDRESS IN D0
	lea	planes,a0		;LOAD	ODD_PLANE(1) IN A0
	move.l	#pf1_planesize,d1	;SIZE OF PLANE IN D1
pa_looP
	move.w	d0,6(a0)		;LOW WORD OF ADDRESS 
	swap	d0			;SWAP
	move.w	d0,2(a0)		;HIGH WORD OF ADDRESS
	swap	d0			;SWAP
	add.l	d1,d0			;ADD SIZE OF PLANE
	lea	8(a0),a0		;INCREMENT A0 TO NEXT CONTROL WORD
	move.w	d0,6(a0)		;LOW WORD
	swap	d0			;SWAP
	move.w	d0,2(a0)		;HIGH WORD
	swap	d0			;SWAP
	add.l	d1,d0			;ADD SIZE OF PLANE 
	lea	8(a0),a0		;INCREMENT A0 TO NEXT CONTROL WORD
	move.w	d0,6(a0)		;LOW WORD
	swap	d0			;SWAP
	move.w	d0,2(a0)		;HIGH WORD
	swap	d0			;SWAP
	add.l	d1,d0			;ADD SIZE OF PLANE 
	lea	8(a0),a0
	rts
sprite_address
	LEA	sprites,a0		;SPRITE CONTROL WORD
	move.l	d0,sprite0adr		;STORE SPRITE0 ADDRESS FOR LATER
	move.l	#spritesize,d1		;SIZE OF SPRITE IN BYTES
sp_loop
	move.w	d0,6(a0)		;STORE LOW WORD
	swap	d0			
	move.w	d0,2(a0)		;HIGH WORD
	swap	d0
	add.l	d1,d0
	lea	8(a0),a0
	rts
clear_screen				;CLEAR SCREEN WITH 0'S
	move.l	membase,a0
	move.l	#0,d4
	move.w	#(6000-1),d2		;NO OF LONG WORDS REQUIRED
cl_screen
	move.l	d4,(a0)+
	dbra	d2,cl_screen
	rts
draw_squares
	move.l	membase,a0		;MEMORY START
	lea	screen_graphics,a4	;LOAD SCREEN GRAPHICS IN A4
	move.w	#2,d3			;NO OF PLANES -1.I.E 3 PLANES
fill_all_3_planes
	move.w	#(pf1_planesize/4-1),d2	;NO OF LONG WORDS IN 1 PLANE (8000/4)-1
fill_play_1				;
	move.l	(a4)+,(a0)+		;TRANSFER GRAPHICS TO MEMORY
	dbra	d2,fill_play_1		;LOOP TILL 0
	dbra	d3,fill_all_3_planes	;LOOP 3 TIMES
	rts

build_sprite0				;BUILD SPRITE 0
	move.b	#138,vstart0		;LOAD VSTART0 WITH VERTICAL START OF SPRITE
	move.b	#120,hstart0		;HSTART0 WITH HORIZONTAL START 
	move.b	#152,vstop0		;VERTICAL STOP
	move.b	#00,attach0		;NO ATTACH WITH SPRITE1
	move.w	#spritesize/4-1,d2	;NO OF LONGWORDS TO WRITE-1
	lea	alien_data_0,a3		;LOAD GRAPHIC DATA
	lea	4(a3),a3		;MISS CONTROL WORD
	move.l	sprite0adr,a0		;SPRITE0 ADDRESS IN A0
	move.b	vstart0,(a0)+		;LOAD VERTICAL POSITION AND INCREMENT A0
	move.b	hstart0,(a0)+		;SAME FOR HSTATR
	move.b	vstop0,(a0)+		;SAME FOR VSTOP
	move.b	attach0,(a0)+		;SAME FOR ATTACH BIT		
sprite
	move.l	(a3)+,(a0)+		;LOAD GRAPHICS INTO A0 AND INCREMENT
	dbf	d2,sprite		;DEDUCT ONE AND LOOP IF D2 IS NOT 0
	rts

**********************************************
	

move_ship0				;ROUTINE TO MOVE SPRITE 0
	move.l	sprite0adr,a0		;FIND STARTING ADDRESS
	move.b	vstart0,(a0)+		;WRITE NEW VERTICAL POSITION
	move.b	hstart0,(a0)+		;NEW HORIZONTAL
	move.b	vstop0,(a0)+		;VERTICAL STOP
	move.b	attach0,(a0)+		;NO ATTACH(NOT NEEDED BUT TO KEEP THINGS EVEN
	rts
sprite_movement
	move.b	(a2)+,d3		;A2 CONTAINS DATA
	cmp.b	#$f0,d3			;TEST IF D3 CONTAINS $F0
	beq	reset_movement		;IF YES BRANCH TO RESET
	add.b	d3,hstart0		;ELSE ADD D3 TO HSTART 0
	rts
reset_movement
	lea	movement_data,a2	;RESET TO START OF MOVEMENT DATA
	move.b	#0,d3			;CLEAR D3
	rts
animate_sprite
	move.l	sprite0adr,a0		;SPRITE ADDRESS 
	lea	4(a0),a0		;SKIP CONTROL WORDS
	move.w	#spritesize/4-1,d2	;NO OF LONG WORDS TO WRITE
	addi.b	#1,anim_delay_1		;ADD 1 TO ANIMATION COUNT
	cmpi.b	#20,anim_delay_1	;DEALY OF 20 FRAMES
	bgt	animation_1		;GREATER THAN 20 GOTO NEXT ANIMATION
	lea	alien_data_0,a3		;GRAPHICS
sprite0					;SPEED UP BY REDUCING NO
	move.l	(a3)+,(a0)+		;TRANSFER NEW GRAPHICS DATA GIVEN
	dbf	d2,sprite0		;IN A3
	rts
animation_1			
	cmpi.b	#40,anim_delay_1	;GREATER THAN 40	
	bgt	clear_anim_delay	;YES BRANCH
	lea	alien_data_1,a3		;ELSE LOAD GRAPHICS
sprite0.1
	move.l	(a3)+,(a0)+		;TRANSFER NEW GRAPHICS DATA GIVEN
	dbf	d2,sprite0.1		;IN A3
	rts	
clear_anim_delay
	move.b	#0,anim_delay_1		;CLEAR ANIMATION DEALY 
	rts

gfxlib	dc.b	"graphics.library",0	
	even
_gfxbase	dc.l	0		;LONG WORD TO STORE GFX ADDRESS
membase	dc.l	0			;MEMORY ADDRESS
oldcop	dc.l	0			;OLD COPPERLIST ADDRESS
sprite0adr	dc.l	0		;SPRITE 0 ADDRESS

vstart0		dc.b	0		;VERTICAL
hstart0		dc.b	0		;HORIZONTAL
vstop0		dc.b	0		;VERTICAL STOP
attach0		dc.b	0		;ATTACH
anim_delay_1	dc.b	0		;BYTE FOR ANIMATION_DELAY

	even				;EVEN UP
movement_data
	dc.b	1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1	;0'S INCLUDED TO SLOW 
	dc.b	1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1	;MOVEMENT DOWN
	dc.b	1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1	;REMOVE THESE TO SPPED
	dc.b	1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1	;SPRITE UP
	dc.b	1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1
	dc.b	-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1
	dc.b	-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1
	dc.b	-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1
	dc.b	-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1
	dc.b	-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1,0,0,0,-1
	dc.b	$f0				;END MARKER FOR RESET

	SECTION		chipmemory,data_c	;GRAPHICS IN CHIP MEMORY
screen_graphics		incbin source9:bitmaps/screen_demo
;screen_graphics				;REMOVE ; IF MY GRAPHICS AREN'T
;	dcb.b	(200*40*3),$00			;REQUIRED
alien_data_0
	dc.w	%0000000000000000,%0000110000110000	;USED BINARY AS EASIER TO SEE
	dc.w	%0000000000000000,%0000011001100000	;HOW SPRITE ISBUILT UP
	dc.w	%0000000000000000,%0000001001000000	;NO CONTROL WORDS IN THIS DATA
	dc.w	%0000000110000000,%0011000110001100	;BINARY 00=COLOR 0(TRANSPARENT)
	dc.w	%0000011111100000,%0110011111100110	;BINARY 10=COLOR 1
	dc.w	%0000011111100000,%1100100110010011	;BINARY 01=COLOR 2
	dc.w	%0000110110110000,%1111100110011111	;BINARY 11=COLOR 3
	dc.w	%0000011111100000,%0000011111100000	
	dc.w	%0000011111100000,%0001111001111000
	dc.w	%0000001111000000,%0011101111011100
	dc.w	%0000000110000000,%0011000110001100
	dc.w	%0000000000000000,%1111000000001111
	dc.w	%0000000000000000,%1111000000001111
	dc.l	$0
alien_data_1
	dc.w	%0000000000000000,%0000011001100000
	dc.w	%0000000000000000,%0000011001100000
	dc.w	%0000000000000000,%1100011001100011
	dc.w	%0000000110000000,%1100000110000011
	dc.w	%0000011111100000,%1100011111100011
	dc.w	%0000011111100000,%1110100110010111
	dc.w	%0000110110110000,%0111100110011110
	dc.w	%0000011111100000,%0000011111100000
	dc.w	%0000011111100000,%0001111111111000
	dc.w	%0000001111000000,%0011101111011100
	dc.w	%0000000110000000,%0011000110001100
	dc.w	%0000000000000000,%0001110000111000
	dc.w	%0000000000000000,%0000011001100000
	dc.l	$0
newcop
	dc.w	$0100,%0011001000000000		;3 BIT PLANES
	dc.w	$0102,$0000			;NO SCROLLING
	dc.w	$0104,%0000000000001000		;PRIORITY for sprites 0,1
	dc.w	$0108,$0000,$010a,$0000		;NO MODULAS
	dc.w	$0092,$0038,$0094,$00d0		;200*40 SCREEN
	dc.w	$008e,$3881,$0090,$ffc1		;CENTRED TO LEAVE GAP AT TOP 
						;AND BOTTOM MORE EVEN
planes
	dc.w	$00e0,$0000,$00e2,$0000		;PLANES
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000	
	dc.w	$00f0,$0000,$00f2,$0000
	dc.w	$00f4,$0000,$00f6,$0000

sprites						;SPRITES
	dc.w	$0120,$0000,$0122,$0000	
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

	dc.w	$0180,$0000,$0182,$0fFf		;COLORS 
	dc.w	$0184,$0d00,$0186,$0f5f
	dc.w	$0188,$0FF0,$018a,$0888
	dc.w	$018c,$0666,$018e,$0333
	dc.w	$0190,$0000,$0192,$00f0
	dc.w	$0194,$0f0f,$0196,$00ff
	dc.w	$0198,$0000,$019a,$000d
	dc.w	$019c,$000f,$019e,$0fe0
	dc.w	$01a0,$0000,$01a2,$0fff		;SPRITE COLORS
	dc.w	$01a4,$0ff0,$01a6,$0d00
	dc.w	$01a8,$0000,$01aa,$0ff0
	dc.w	$01ac,$006f,$01ae,$0f0f
	dc.w	$01b0,$0000,$01b2,$0ff0
	dc.w	$01b4,$006f,$01b6,$0f0f
	dc.w	$01b8,$0000,$01ba,$0fff
	dc.w	$01bc,$006f,$01be,$0f0f


	dc.w	$ffff,$fffe			;END OF COPPERLIST


