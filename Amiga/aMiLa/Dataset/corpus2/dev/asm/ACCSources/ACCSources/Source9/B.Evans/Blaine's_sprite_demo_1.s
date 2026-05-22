	opt	c-,d+

custom=$dff000				;custom chip base
pf1_width=40				;playfield_1 width40 words by
pf1_height=200				;height		200 lines
pf1_depth=3				;depth of 3 planes
pf1_planesize=pf1_width*pf1_height	;calculate size of plane in bytes
pf1_sizeof=pf1_planesize*pf1_depth	;*depth
spritesize=16*4				;SPRITE SIZE IN BYTES					
mem_required=pf1_sizeof+spritesize		;memory required=(40*200)*3=24000 bytes

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
	move.l	_gfxbase,a0		LOAD ADDRESS OF GRAPHICS LIB IN A0
	move.l	50(a0),oldcop		;STORE CURRENT COPPER,ETC TO RETRIEVE LATER
S
	move.l	#newcop,50(a0)		;POINT TO OUR COPPERLIST

wait					;WAIT LOOP
	cmpi.b	#0,$dff006		;VERTICAL BLANKING GAP 
	bne.s	wait			;
	bsr	joy_test		;BRANCH TO JOYSTICK TEST
	bsr	bound_test		;BRANCH TO BOUNDARY TEST
	bsr	move_ship0		;BRANCH TO MOVE SPRITE0
	btst	#$06,$bfe001		;QUIT
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
	LEA	sprites,a0		;SPRITE CONTROL WORDS
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
	move.b	#200,hstart0		;HSTART0 WITH HORIZONTAL START 
	move.b	#154,vstop0		;VERTICAL STOP=VSTART+16(NO OF LINES»
	move.b	#00,attach0		;NO ATTACH WITH SPRITE1
	move.w	#spritesize/4-1,d2	;NO OF LONGWORDS TO WRITE-1
	lea	left_right_graphics,a3	;LOAD GRAPHIC DATA
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
	
joy_test				;JOYSTICK TEST
	move.w	$DFF00c,d2		;ADDRESS OF STICK 2
	move.w	d2,d1			;COPY TO D1
	lsr.w	#1,d1			;LOGICAL SHIFT RIGHT
	eor.w	d2,d1			;EXCLUSIVE OR D2 WITH D1
	btst	#1,d2			;TEST BIT 1 OF D2 (RIGHT)
	beq	try_left		;IF NOT EQUAL THEN TRY LEFT
	add.b	#1,hstart0		;MOVE RIGHT (ADD 1 TO HSTART)
	lea	left_right_graphics,a3	;LOAD GRAPHICS FOR RIGHT INTO A3
	rts
try_left
	btst	#9,d2			;TEST BIT 9 (LEFT)
	beq	try_down		;IF NOT EQUAL TRY DOWN
	sub.b	#1,hstart0		;MOVE LEFT (SUB 1 FROM HSTART)
	lea	left_right_graphics,a3	;GRAPHICS FOR LEFT
	rts
try_down
	btst	#0,d1			;TEST BIT 0 OF D1
	beq	try_up			;IF NOT EQUAL TRY UP
	add.b	#1,vstart0		;MOVE DOWN (ADD 1 TO VSTART)
	add.b	#1,vstop0		;ADD 1 TO VSTOP ALSO
	lea	down_graphics,a3		;GRAPHICS FOR DOWN
	rts
try_up	
	btst	#8,d1			;TEST BIT 8 OF D1
	beq	no_move			;IF NOT EQUAL MUST BE NO MOVE
	sub.b	#1,vstart0		;MOVE UP (SUBTRACT 1 FROM VSTART)
	sub.b	#1,vstop0		;SUBTRACT FROM VSTOP
	lea	up_graphics,a3		;GRAPHICS FOR UP
	rts
no_move
	lea	left_right_graphics,a3	;GRAPHICS FOR NO MOVE
	rts
move_ship0				;ROUTINE TO MOVE SPRITE 0
	move.l	sprite0adr,a0		;FIND STARTING ADDRESS
	move.b	vstart0,(a0)+		;WRITE NEW VERTICAL POSITION
	move.b	hstart0,(a0)+		;NEW HORIZONTAL
	move.b	vstop0,(a0)+		;VERTICAL STOP
	move.b	attach0,(a0)+		;NO ATTACH(NOT NEEDED BUT TO KEEP THINGS EVEN
	move.w	#spritesize/4-1,d2	;NO OF LONG WORDS TO WRITE
	lea	4(a3),a3		;SKIP PREVIOUS CONTROL WORDS
sprite0
	move.l	(a3)+,(a0)+		;TRANSFER NEW GRAPHICS DATA GIVEN
	dbf	d2,sprite0		;IN A3
	rts
bound_test
	move.b	vstart0,d0		;TEST IF VERTICAL POSITION
	cmpi.b	#54,d0			;IS LESS THAN OR EQUAL 54
	bls	hit_bound_top		;IF YES GO TO ROUTINE ELSE CHECK NEXT 
	cmpi.b	#242,d0			;MORE THAN OR EQUAL TO 242
	bhs	hit_bound_bottom	;IF YES BRANCH ELSE 
	move.b	hstart0,d0		;CHECK HORIZONTAL POSITION
	cmpi.b	#70,d0			;LESS OR EQUAL TO 70
	bls	hit_bound_left		;BRANCH ELSE
	cmpi.b	#215,d0			;MORE  OR EQUAL TO 215
	bhs	hit_bound_right		;BRANCH	ELSE
	rts				
hit_bound_top
	addi.b	#1,vstart0		;ADD 1 TO VSTART,VSTOP TO MOVE BACK IN
	addi.b	#1,vstop0		;BOUNDARY AREA
	rts
hit_bound_bottom
	subi.b	#1,vstart0		;SUBTRACT 1 
	subi.b	#1,vstop0
	rts
hit_bound_right
	subi.b	#1,hstart0		;SUBTRACT 1
	rts
hit_bound_left
	addi.b	#1,hstart0		;ADD 1
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


	even
	SECTION		chipmemory,data_c	;GRAPHICS IN CHIP MEMORY
screen_graphics		incbin source9:bitmaps/screen_demo
;screen_graphics				;REMOVE ; IF MY GRAPHICS AREN'T
;	dcb.b	(200*40*3),$ff			;REQUIRED
left_right_graphics
	dc.w	$0000,$0000,$0000,$0078,$0000,$00f0,$0000,$01e0
	dc.w	$07c0,$03e0,$0fe3,$03e0,$1ff6,$03f0,$7fff,$63f0
	dc.w	$7fff,$7ff0,$1876,$1ff0,$0823,$0fe0,$0400,$07e0	
	dc.w	$0000,$01f0,$0000,$00f8,$0000,$007c,$0000,$0000
	dc.L	$0

up_graphics
	dc.w	$0000,$0000,$0000,$0078,$0200,$00fc,$1fc0,$03f0
	dc.w	$7fc0,$63e0,$7fe0,$73e0,$3ff3,$3ff0,$13fc,$1fe0
	dc.w	$10fe,$1fe0,$106e,$1fe0,$0008,$0780,$000c,$0380
	dc.w	$0000,$03c0,$0000,$03c0,$0000,$0060,$0000,$0000
	dc.L	$0
down_graphics
	dc.w	$0000,$01c0,$0000,$0380,$0000,$0700,$0108,$0f80
	dc.w	$079c,$0780,$1ffe,$0fc0,$3ffc,$0fe0,$3fee,$07e0
	dc.w	$3fe0,$07e0,$7820,$7fe0,$7800,$7ff0,$0800,$0ffe	
	dc.w	$0000,$00fc,$0000,$0030,$0000,$0000,$0000,$0000
	dc.L	$0

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
	dc.w	$01a0,$0000,$01a2,$0ff0		;SPRITE COLORS
	dc.w	$01a4,$0ff0,$01a6,$0f40
	dc.w	$01a8,$0000,$01aa,$0ff0
	dc.w	$01ac,$006f,$01ae,$0f0f
	dc.w	$01b0,$0000,$01b2,$0ff0
	dc.w	$01b4,$006f,$01b6,$0f0f
	dc.w	$01b8,$0000,$01ba,$0fff
	dc.w	$01bc,$006f,$01be,$0f0f


	dc.w	$ffff,$fffe			;END OF COPPERLIST


