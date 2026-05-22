;SOURCE TO MOVE AND ANIMATE SPRITES
;SHIP MOVEMENT BY JOYSTICK 2
;MISSILE FIRED BY FIRE BUTTON 2	
;MISSILE TO ALIEN COLLISION DETECTION
;BY CO-ORDINATE CHECKING (I.E.BOX DRAWN AROUND ALIEN)
							;BY BLAINE EVANS
							;1 ERITH WAY
							;PONTYBODKIN
							;NR MOLD
							;CLWYD
							;CH7 4TR
							;TEL O352-771673
;********************************************************************
;********************************************************************

	opt	c-,d+

custom=$dff000				;custom chip base
pf1_width=40				;playfield_1 width40 words by
pf1_height=200				;height		200 lines
pf1_depth=3				;depth of 3 planes
pf1_planesize=pf1_width*pf1_height	;calculate size of plane in bytes
pf1_sizeof=pf1_planesize*pf1_depth	;*depth
spritesize=16*4				;SPRITE SIZE IN BYTES		
mem_required=pf1_sizeof+(spritesize*4)	;MEMORY REQUIRED=(40*200)*3=24000 bytes
					;+SPRITESIZE*NUMBER OF SPRITES			
	move.l	4.w,a6			;FIND EXEC BASE
	lea	gfxlib(pc),a1		;LOAD GRAPHICS LIBRARY IN A1
	moveq	#$00,d0			;VERSION 0
	jsr	-552(a6)		;OPEN LIBRARY
	move.l	d0,_gfxbase		;STORE D0 (GFX ADDRESS )
	beq	nolib_exit		;ELSE EXIT

	move.l	#mem_required,d0	;LOAD MEMORY REQUIRED IN D0
	move.l	#2,d1			;2=CHIP MEMORY
	jsr	-198(a6)		;ALLOCMEN 
	move.l	d0,membase		;STORE ADDRESS OF MEMORY IN MEMBASE FOR LATER
	beq	nomem_exit		;ELSE IF MEMORY NOT AVAIL EXIT
	bsr	plane_addresses		;BRANCH TO CALCULATE PLANE ADDRESSES
	bsr	sprite_addresses	;AND TO SPRITE ADDRESSES
	bsr	clear_screen		;CLEAR SCREEN
	bsr	draw_squares		;DRAW GRAPHICS TO MEMORY
	bsr	build_sprites		;DRAW SPRITE TO MEMORY
	move.b	#0,fire_flag
	lea	custom,a6		;LOAD A6 WITH CUSTOM BASE ADDRESS
	move.l	_gfxbase,a0		;LOAD ADDRESS OF GRAPHICS LIB IN A0
	move.l	50(a0),oldcop		;STORE CURRENT COPPER,ETC TO RETRIEVE LATER
S
	move.l	#newcop,50(a0)		;POINT TO OUR COPPERLIST

wait					;WAIT LOOP
	cmpi.b	#0,$dff006		;VERTICAL BLANKING GAP 
	bne.s	wait			;
	bsr	joy_test		;READ JOYSTICK 2 
	bsr	bound_test		;BOUNDARY CHECK
	bsr	move_ship0		;BRANCH TO MOVE SPRITE0
	bsr	animate_sprite0		;BRANCH TO ANIMATE ROUTINE
	bsr	fire			;READ FIRE BUTTON
	bsr	misslie_to_top_screen	;CHECK FOE MISSILE/TOP SCREEN 
	bsr	move_missile1		;MOVE SPRITE 1
	bsr	animate_sprite2
	bsr	alien_missile_collision	;ALIEN/MISSILE COLLISION DETECT
	btst	#$06,$bfe001		;QUIT LEFT MOUSE PRESSED
	bne	wait			;ELSE LOOP TO WAIT
	move.l	_gfxbase,a0		;LOAD GRAPHICS LIB ADDRESS IN A0
	move.l	oldcop,50(a0)		;RESTORE OLD COPPER TO RETURN TO EDITTER
dealloc	
	move.l	4.w,a6			;FIND EXEC BASE
	move.l	membase,a1		;LOAD MEMORY BASE IN A1
	move.l	#mem_required,d0	;AND MEMORY REQUIRED IN D0
	jsr	-210(a6)		;FREE	MEMORY WE TOOK 
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
	RTS
sprite_addresses
	LEA	sprites,a0		;SPRITE CONTROL WORDS
	move.l	d0,sprite0adr		;STORE SPRITE0 ADDRESS FOR LATER
	move.l	#spritesize+16,d1	;SIZE OF SPRITE IN BYTES
sp_loop
	move.w	d0,6(a0)		;STORE LOW WORD
	swap	d0			
	move.w	d0,2(a0)		;HIGH WORD
	swap	d0
	add.l	d1,d0
	lea	8(a0),a0
	move.l	d0,sprite1adr		;STORE SPRITE 1 ADDRESS FOR LATER
	move.w	d0,6(a0)		;STORE LOW WORD
	swap	d0			
	move.w	d0,2(a0)		;HIGH WORD
	swap	d0
	add.l	d1,d0
	lea	8(a0),a0
	move.l	d0,sprite2adr		;STORE SPRITE 2 ADDRESS FOR LATER
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

build_sprites

build_sprite0				;BUILD SPRITE 0
	move.b	#224,vstart0		;LOAD VSTART0 WITH VERTICAL START OF SPRITE
	move.b	#100,hstart0		;HSTART0 WITH HORIZONTAL START 
	move.b	#240,vstop0		;VERTICAL STOP
	move.b	#00,attach0		;NO ATTACH WITH SPRITE1
	move.w	#spritesize/4-1,d2	;NO OF LONGWORDS TO WRITE-1
	lea	ship_data_1,a3		;LOAD GRAPHIC DATA
	lea	4(a3),a3		;MISS CONTROL WORD
	move.l	sprite0adr,a0		;SPRITE0 ADDRESS IN A0
	move.b	vstart0,(a0)+		;LOAD VERTICAL POSITION AND INCREMENT A0
	move.b	hstart0,(a0)+		;SAME FOR HSTATR
	move.b	vstop0,(a0)+		;SAME FOR VSTOP
	move.b	attach0,(a0)+		;SAME FOR ATTACH BIT		
sprite
	move.l	(a3)+,(a0)+		;LOAD GRAPHICS INTO A0 AND INCREMENT
	dbf	d2,sprite		;DEDUCT ONE AND LOOP IF D2 IS NOT 0
build_sprite01				;BUILD SPRITE 1
	move.b	vstart0,d1		;VSTART 1 TO D1
	sub.b	#3,d1			;SUBTRACT 3 TO LINE MISSILE WITH SHIP
	move.b	d1,vstart1		;LOAD VSTART0 WITH VERTICAL START OF SPRITE
	move.b	hstart0,hstart1		;HSTART0 WITH HORIZONTAL START 
	move.b	vstop0,d1		;VSTOP TO D1
	sub.b	#3,d1			;SUBTRACT 3 TO LINE UP
	move.b	d1,vstop1		;VERTICAL STOP
	move.b	#00,attach1		;NO ATTACH WITH SPRITE1
	move.w	#spritesize/4-1,d2	;NO OF LONGWORDS TO WRITE-1
	lea	missile_data1,a3		;LOAD GRAPHIC DATA
	lea	4(a3),a3		;MISS CONTROL WORD
	move.l	sprite1adr,a0		;SPRITE0 ADDRESS IN A0
	move.b	vstart1,(a0)+		;LOAD VERTICAL POSITION AND INCREMENT A0
	move.b	hstart1,(a0)+		;SAME FOR HSTART
	move.b	vstop1,(a0)+		;SAME FOR VSTOP
	move.b	attach1,(a0)+		;SAME FOR ATTACH BIT		
sprite1
	move.l	(a3)+,(a0)+		;LOAD GRAPHICS INTO A0 AND INCREMENT
	dbf	d2,sprite1		;DECREASE D2 AND LOOP IF NOT 0
build_sprite02				;BUILD SPRITE 2
	move.b	#74,vstart2		;LOAD VSTART2 WITH VERTICAL START OF SPRITE
	move.b	#140,hstart2		;HSTART2 WITH HORIZONTAL START 
	move.b	#90,vstop2		;VERTICAL STOP
	move.b	#00,attach2		;NO ATTACH WITH SPRITE1
	move.w	#spritesize/4-1,d2	;NO OF LONGWORDS TO WRITE-1
	lea	alien_data_1,a3		;LOAD GRAPHIC DATA
	lea	4(a3),a3		;MISS CONTROL WORD
	move.l	sprite2adr,a0		;SPRITE0 ADDRESS IN A0
	move.b	vstart2,(a0)+		;LOAD VERTICAL POSITION AND INCREMENT A0
	move.b	hstart2,(a0)+		;SAME FOR HSTATR
	move.b	vstop2,(a0)+		;SAME FOR VSTOP
	move.b	attach2,(a0)+		;SAME FOR ATTACH BIT		
sprite2
	move.l	(a3)+,(a0)+		;LOAD GRAPHICS INTO A0 AND INCREMENT
	dbf	d2,sprite2		;DEDUCT ONE AND LOOP IF D2 IS NOT 0

	rts

**********************************************
joy_test				;JOYSTICK TEST
	move.w	$DFF00c,d2		;ADDRESS OF STICK 2
	move.w	d2,d1			;COPY TO D1
	lsr.w	#1,d1			;LOGICAL SHIFT RIGHT
	eor.w	d2,d1			;EXCLUSIVE OR D2 WITH D1
	btst	#1,d2			;TEST BIT 1 OF D2 (RIGHT)
	beq	try_left		;IF NOT EQUAL THEN TRY LEFT
	add.b	#1,hstart0		;MOVE RIGHT (ADD 1 TO HSTART
	rts
try_left
	btst	#9,d2			;TEST BIT 9 (LEFT)
	beq	try_down		;IF NOT EQUAL TRY DOWN
	sub.b	#1,hstart0		;MOVE LEFT (SUB 1 FROM HSTART)
	rts
try_down
	btst	#0,d1			;TEST BIT 0 OF D1
	beq	try_up			;IF NOT EQUAL TRY UP
	add.b	#1,vstart0		;MOVE DOWN (ADD 1 TO VSTART)
	add.b	#1,vstop0		;ADD 1 TO VSTOP ALSO
	rts
try_up	
	btst	#8,d1			;TEST BIT 8 OF D1
	beq	no_move			;IF NOT EQUAL MUST BE NO MOVE
	sub.b	#1,vstart0		;MOVE UP (SUBTRACT 1 FROM VSTART)
	sub.b	#1,vstop0		;SUBTRACT FROM VSTOP
	rts
no_move
	rts

bound_test
	move.b	vstart0,d0		;TEST IF VERTICAL POSITION
	cmpi.b	#54,d0			;IS LESS THAN OR EQUAL 54
	bls	hit_bound_top		;IF YES GO TO ROUTINE ELSE CHECK NEXT 
	cmpi.b	#240,d0			;MORE THAN OR EQUAL TO 242
	bhs	hit_bound_bottom	;IF YES BRANCH ELSE 
	move.b	hstart0,d0		;CHECK HORIZONTAL POSITION
	cmpi.b	#63,d0			;LESS OR EQUAL TO 63
	bls	hit_bound_left		;BRANCH ELSE
	cmpi.b	#216,d0			;MORE  OR EQUAL TO 216
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
	

move_ship0				;ROUTINE TO MOVE SPRITE 0
	move.l	sprite0adr,a0		;FIND STARTING ADDRESS
	move.b	vstart0,(a0)+		;WRITE NEW VERTICAL POSITION
	move.b	hstart0,(a0)+		;NEW HORIZONTAL
	move.b	vstop0,(a0)+		;VERTICAL STOP
	move.b	attach0,(a0)+		;NO ATTACH(NOT NEEDED BUT TO KEEP THINGS EVEN
	rts
animate_sprite0
	move.l	sprite0adr,a0		;SPRITE ADDRESS 
	lea	4(a0),a0		;SKIP CONTROL WORDS
	move.w	#spritesize/4-1,d2	;NO OF LONG WORDS TO WRITE
	addi.b	#1,anim_delay_1		;ADD 1 TO ANIMATION COUNT
	cmpi.b	#20,anim_delay_1	;DEALY OF 20 FRAMES
	bgt	animation_1		;GREATER THAN 20 GOTO NEXT ANIMATION
	lea	ship_data_1,a3		;GRAPHICS
sprite0					;SPEED UP BY REDUCING NO
	move.l	(a3)+,(a0)+		;TRANSFER NEW GRAPHICS DATA GIVEN
	dbf	d2,sprite0		;IN A3
	rts
animation_1			
	cmpi.b	#40,anim_delay_1	;GREATER THAN 40	
	bgt	clear_anim_delay	;YES BRANCH
	lea	ship_data_2,a3		;ELSE LOAD GRAPHICS
sprite0.1
	move.l	(a3)+,(a0)+		;TRANSFER NEW GRAPHICS DATA GIVEN
	dbf	d2,sprite0.1		;IN A3
	rts	
clear_anim_delay
	move.b	#0,anim_delay_1		;CLEAR ANIMATION DEALY 
	rts
fire
	cmp.b	#1,fire_flag		;COMPARE FIRE FLAG WITH 1
	beq	on_way			;BRANCH IF EQUAL TO ON_WAY
	btst	#7,$bfe001		;TEST BIT 7 (JOY 2 FIRE BUTTON)
	bne	not_fired		;BRANCH IF NOT PRESSED
	move.b	#1,fire_flag		;ELSE  LOAD FIRE FLAG WITH 1
	cmp.b	#1,fire_flag		;COMPARE FLAG
	bne	not_fired		;BRANCH IF NOT EQUAL
	rts
on_way
	sub.b	#4,vstart1		;SUBTRACT 4 FROM VSTART 1 
	sub.b	#4,vstop1		;SUBTARCT 4 FROM VSTOP 1
	rts
not_fired
	move.b	vstart0,d1		;LOAD VSTART 0 POSITION IN D1
	sub.b	#3,d1			;TAKE AWAY 3 TO POSITION MISSILE ON TOP OF SHIP
	move.b	d1,vstart1		;LOAD VSTART 1 WITH VALUE
	move.b	hstart0,hstart1		;SAME HORIZONTAL POSITION
	move.b	vstop0,d1		;LOAD VSTOP 0 POSITION IN D1
	sub.b	#3,d1			;TAKE AWAY 3 TO POSITION MISSILE ON TOP OF SHIP
	move.b	d1,vstop1		;LOAD VSTOP WITH POSITION
	move.b	#00,attach1		;NO ATTACH
	rts
move_missile1
	move.l	sprite1adr,a0		;SPRITE 1 ADDRESS
	move.b	vstart1,(a0)+		
	move.b	hstart1,(a0)+
	move.b	vstop1,(a0)+
	move.b	attach1,(a0)+
	rts
misslie_to_top_screen			;CHECK TOP OF SCREEN
	cmp.b	#45,vstart1		;COMPARE VSTART WITH POSITION 45
	bls	reset_fire		;IF LESS BRANCH
	rts				;ELSE RETURN
reset_fire
	move.b	#0,fire_flag		;CLEAR FLAG
	move.b	vstart0,d1		;RE-POSITION ON TOP OF SHIP
	sub.b	#3,d1
	move.b	d1,vstart1
	move.b	hstart0,hstart1
	move.b	vstop0,d1
	sub.b	#3,d1
	move.b	d1,vstop1
	move.b	#00,attach1
	rts
animate_sprite2
	move.l	sprite2adr,a0		;SPRITE ADDRESS 
	lea	4(a0),a0		;SKIP CONTROL WORDS
	move.w	#spritesize/4-1,d2	;NO OF LONG WORDS TO WRITE
	addi.b	#1,anim_delay_alien	;ADD 1 TO ANIMATION COUNT
	cmpi.b	#20,anim_delay_alien	;DELAY OF 20 FRAMES
	bgt	animation_alien		;GREATER THAN 20 GOTO NEXT ANIMATION
	lea	alien_data_1,a3		;GRAPHICS
sprite_alien				;SPEED UP BY REDUCING NUMBER
	move.l	(a3)+,(a0)+		;TRANSFER NEW GRAPHICS DATA GIVEN
	dbf	d2,sprite_alien		;IN A3
	rts
animation_alien
	cmpi.b	#40,anim_delay_alien	;GREATER THAN 40	
	bgt	clear_anim_delay_alien	;YES BRANCH
	lea	alien_data_2,a3		;ELSE LOAD GRAPHICS
sprite_alien1
	move.l	(a3)+,(a0)+		;TRANSFER NEW GRAPHICS DATA GIVEN
	dbf	d2,sprite_alien1	;IN A3
	rts	
clear_anim_delay_alien
	move.b	#0,anim_delay_alien	;CLEAR ANIMATION DEALY 
	rts
alien_missile_collision			
	move.b	vstart2,d1		;VERTICAL POSITION SPRITE 2 TO D1
	add.b	#10,d1			;ADD 10 TO FIND THE POINT WHERE MISSILE CROSSES ALIEN 
	cmp.b	vstart1,d1		;COMPARE VERTICAL SPRITE 1 WITH  D1
	blo	missed_alien		;LESS THAN D1 THEN NOT REACHED ALIEN YET
	move.b	vstart2,d1		;VERTTCAL SPRITE 2 TO D1
	cmp.b	vstart1,d1		;COMPARE TOP OF MISSILE/ALIEN 
	bhi	missed_alien		;HIGHER THAN THEN NEVER GONE THROUGH ALIEN
	move.b	hstart2,d1		;HORIZONTAL SPRITE 2 TO D1
	sub.b	#6,d1			;SUBTRACT 6 TO ALLOW FOR MISSILE SIZE
	cmp.b	hstart1,d1		;COMPARE MISSILE/ALIEN
	bhi	missed_alien		;HIGHER THAN THEN NO HIT
	move.b	hstart2,d1		
	add.b	#6,d1			;ADD 6 TO ALLOW FOR MISSILE SIZE
	cmp.b	hstart1,d1		;COMPARE MISSILE/ALIEN
	blo	missed_alien		;LESS THAN THEN NO HIT
hit_wait				;HALT PROGRAM
	btst	#$06,$bfe001
	bne.s	hit_wait		;LEFT MOUSE PRESSED
	rts				;NO THEN DON'T MOVE 
					;RETURN AND EXIT FROM HERE
missed_alien
	rts				;MISSED ALIEN THEN RETURN
gfxlib	dc.b	"graphics.library",0	
	even
_gfxbase	dc.l	0		;LONG WORD TO STORE GFX ADDRESS
membase	dc.l	0			;MEMORY ADDRESS
oldcop	dc.l	0			;OLD COPPERLIST ADDRESS
sprite0adr	dc.l	0		;SPRITE 0 ADDRESS
sprite1adr	dc.l	0		;SPRITE 1 ADDRESS
sprite2adr	dc.l	0		;SPRITE 2 ADDRESS

vstart0		dc.b	0		;VERTICAL
hstart0		dc.b	0		;HORIZONTAL
vstop0		dc.b	0		;VERTICAL STOP
attach0		dc.b	0		;ATTACH
vstart1		dc.b	0		;VERTICAL
hstart1		dc.b	0		;HORIZONTAL
vstop1		dc.b	0		;VERTICAL STOP
attach1		dc.b	0		;ATTACH
vstart2		dc.b	0		;VERTICAL
hstart2		dc.b	0		;HORIZONTAL
vstop2		dc.b	0		;VERTICAL STOP
attach2		dc.b	0		;ATTACH
anim_delay_1	dc.b	0		;BYTE FOR ANIMATION_DELAY
anim_delay_alien	dc.b	0	;ALIEN ANIMATION DELAY
fire_flag	dc.b	0		;FIRE_FLAG
	even				;EVEN UP
	SECTION		chipmemory,data_c	;GRAPHICS IN CHIP MEMORY

ship_data_1
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000001111000000,%0000001111000000
	dc.w	%0000001111000000,%0000001111000000
	dc.w	%0001111111111000,%0001111111111000
	dc.w	%0011111111111100,%0011111111111100
	dc.w	%0011111111111100,%0011111111111100
	dc.w	%0011111111111100,%0011111111111100
	dc.w	%0011111111111100,%0011111111111100
	dc.w	%0011001111001100,%0011001111001100
	dc.w	%0011001111001100,%0011001111001100
	dc.w	%0011001111001100,%0000001111000000
	dc.w	%0011001111001100,%0100101111010010
	dc.w	%0011001111001100,%0100101111010010
	dc.w	%0000011111100000,%0011011111101100
	dc.w	%0001111111111000,%0001111111111000
	dc.l	$0,$0
ship_data_2
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000001111000000,%0000001111000000
	dc.w	%0000001111000000,%0000001111000000
	dc.w	%0001111111111000,%0001111111111000
	dc.w	%0011111111111100,%0011111111111100
	dc.w	%0011111111111100,%0011111111111100
	dc.w	%0011111111111100,%0011111111111100
	dc.w	%0011111111111100,%0011111111111100
	dc.w	%0011001111001100,%0011001111001100
	dc.w	%0011001111001100,%0011001111001100
	dc.w	%0011001111001100,%0000001111000000
	dc.w	%0011001111001100,%0000001111000000
	dc.w	%0011001111001100,%0000001111000000
	dc.w	%0000011111100000,%0000011111100000
	dc.w	%0001111111111000,%0001111111111000
	dc.l	$0,$0
missile_data1
	dc.w	%0000000000000000,%0000000110000000
	dc.w	%0000000000000000,%0000000110000000
	dc.w	%0000000000000000,%0000000110000000
	dc.w	%0000000000000000,%0000001111000000
	dc.w	%0000000000000000,%0000001001000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000	
	dc.w	%0000000000000000,%0000000000000000
	dc.l	$0,$0

alien_data_1
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
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000	
	dc.l	$0,$0
alien_data_2
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
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000	
	dc.l	$0,$0
screen_graphics				
	dcb.b	(200*40*3),$ff		;SCREEN DATA

newcop
	dc.w	$0100,%0011001000000000		;3 BIT PLANES
	dc.w	$0102,$0000			;NO SCROLLING
	dc.w	$0104,%0000000000011000		;PRIORITY for sprites 0,1,2,3
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
	dc.w	$018c,$0666,$018e,$0222
	dc.w	$0190,$0000,$0192,$00f0
	dc.w	$0194,$0f0f,$0196,$00ff
	dc.w	$0198,$0000,$019a,$000d
	dc.w	$019c,$000f,$019e,$0fe0

	dc.w	$01a0,$0000,$01a2,$0d00		;SPRITE COLORS
	dc.w	$01a4,$0ff0,$01a6,$004f
	dc.w	$01a8,$0000,$01aa,$0fff
	dc.w	$01ac,$04c0,$01ae,$0d00
	dc.w	$01b0,$0d00,$01b2,$0ff0
	dc.w	$01b4,$006f,$01b6,$0f0f
	dc.w	$01b8,$0000,$01ba,$0fff
	dc.w	$01bc,$006f,$01be,$0f0f


	dc.w	$ffff,$fffe			;END OF COPPERLIST


