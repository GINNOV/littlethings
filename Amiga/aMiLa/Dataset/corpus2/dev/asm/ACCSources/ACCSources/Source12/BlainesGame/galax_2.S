;						BLAINE EVANS
;						1,ERITH WAY
;						PONTYBOBKIN
;						NR MOLD
;						CLWYD
;						CH7 4TR
;This was written 5-6 months ago  
;it has a few minor bugs but shows what can be done with sprites
;I know its impossible to follow
;sorry
;Blaine


	opt	c-,d+
	incdir	:include/
	include	exec/exec_lib.i
	include	hardware/custom.i

custom=$dff000
blit_data_size=800*40
planesize=40*400
pf1_sizeof=400*40*1
spritesize0=16*4
spritesize1=6*4
spritesize2=16*4
sprite2.2size=9*4
base=$60000
m_base=$57b30
cop_size=25*40
missile_size=10*4
mem_required=pf1_sizeof
start
	lea	gfxlib,a1
	moveq	#$00,d0
	Callexec	OpenLibrary
	move.l	d0,_gfxbase

	move.l	#base-(2*planesize)-2000,membase
	move.l	#base,base_2
	move.l	#0,d6
	MOVE.W	#0,SCOUNT
	MOVE.W	#0,COUNT
	MOVE.W	#0,COUNT_2
	move.l	#0,hit_alien_1
	move.l	#0,hit_alien_5
	move.l	#0,hit_alien_9
	move.l	#0,hit_alien_13
	move.l	#0,hit_alien_17
	move.l	#0,hit_alien_21
	move.b	#0,hit_alien
	move.b	#0,h_motion
	move.l	#0,alien_1_explosion
	move.l	#0,alien_5_explosion
	move.l	#0,alien_9_explosion
	move.l	#0,alien_13_explosion
	move.l	#0,alien_17_explosion
	move.l	#0,alien_21_explosion
	move.l	#0,missile_reduction
	move.b	#3,lives
	move.b	#0,m_vstart_reduction

	lea	$dff000,a6
	MOVE.L	#m_base+8000,BIT_BASE
	MOVE.L	#m_base+16000+8000,BIT_BASE_2
	MOVE.L	#m_base+8000,TEMP_BASE
	move.l	#m_base+16000,temp_base_2
	move.l	_gfxbase,a0
	move.l	50(a0),oldcop
S
	move.l	#newcop,50(a0)
	bsr	plane_addresses
	lea	split_2,a0
	move.w	#0,a2
	move.w	#7,d2
split_1
	move.w	(a2),(a0)+
	dbf	d2,split_1
	lea	colors,a0
	lea	intro_colors,a2
	move.w	#3,d2
cop
	add.w	#2,a0
	move.w	(a2)+,(a0)
	add.w	#2,a0
	dbf	d2,cop
backgrounds
	move.l	membase,a0
	lea	intro,a4
	move.l	#(planesize/2-1),d2
fill_1
	move.l	(a4)+,(a0)+
	dbra	d2,fill_1

	move.l	base_2,a0
	move.l	#0,d4
	move.l	#(planesize/2-1),d2
fill_2
	move.l	d4,(a0)+
	dbra	d2,fill_2
	move.l	#0,D4
	MOVE.L	cop2adr,A0
	MOVE.W	#COP_SIZE/2-1,D2
FILL_COP
	MOVE.l	d4,(A0)+
	DBRA	D2,FILL_COP
	move.l	#$ffffff,d2
pause
	dbf	d2,pause
l
	btst	#7,$bfe001
	bne	l
	lea	colors,a0
	lea	GAME_colors,a2
	move.w	#3,d2
cop_2
	add.w	#2,a0
	move.w	(a2)+,(a0)
	add.w	#2,a0
	dbf	d2,cop_2
	lea	sprite_colors,a0
	move.w	#15,d2
spr_colors
	add.w	#2,a0
	move.w	(a0),(a0)
	add.w	#2,a0
	dbf	d2,spr_colors
	bsr	sprite_addresses
	lea	split_2,a0
	lea	split_screen,a2
	move.w	#7,d2
split
	move.w	(a2)+,(a0)+
	dbf	d2,split
	bsr	draw_backgrounds
	bsr	blit_lives
	bsr	build_ship0
	lea	block,a4
	move.l	a4,scroll_base_2
	lea	galax1,a3
	move.l	a3,galax_base
	lea	alien_2_vpath,a3
	move.l	a3,alien_2_vtrack
	lea	alien_2_hpath,a3
	move.l	a3,alien_2_htrack
	;lea	map_1,a5


wait
	move.l	vposr(a6),d2
	and.l	#$0001ff00,d2
	cmp.l	#$00001000,d2
	bne.s	wait

	bsr	internal_clock
	bsr	internal_clock_2
	bsr	internal_clock_3
	bsr	joy_test
	bsr	fire
	bsr	bound_test
	bsr	move_ship0
	bsr	anim_ship0
	bsr	move_missile1
	bsr	alien_motion
	bsr	move_alien2
	bsr	move_alien2.1
	bsr	move_alien2.2
	bsr	move_alien2.3
	bsr	move_alien3
	bsr	move_alien3.1
	bsr	move_alien3.2
	bsr	move_alien3.3
	bsr	move_alien4
	bsr	move_alien4.1
	bsr	move_alien4.2
	bsr	move_alien4.3
	bsr	move_alien5
	bsr	move_alien5.1
	bsr	move_alien5.2
	bsr	move_alien5.3
	bsr	move_alien6
	bsr	move_alien6.1
	bsr	move_alien6.2
	bsr	move_alien6.3
	bsr	move_alien7
	bsr	move_alien7.1
	bsr	move_alien7.2
	bsr	move_alien7.3
	bsr	fire_miss_1	
	bsr	fire_miss_1.1
	bsr	fire_miss_2
	bsr	fire_miss_3
	bsr	fire_miss_4
	bsr	fire_miss_5
	bsr	fire_miss_6
	bsr	setup_blit
	bsr	setup_blit_2
	bsr	adjust_playfield
	bsr	update_score
	cmp.b	#$37,$bfec01
	bne	wait
	move.l	_gfxbase,a0
	move.l	oldcop,50(a0)
nomem_exit
	move.l	_gfxbase,a1
	Callexec	CloseLibrary
nolib_exit
	rts
plane_addresses
	move.l	membase,d0
	move.l	d0,d3
	lea	top_planes,a0
	move.l	#planesize,d1
pa_main
	moveq	#$00,d2
pa_loop
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	d1,d0
	lea	8(a0),a0
	move.l	d0,playfield2adr
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	d1,d0
	;lea	8(a0),a0
plane_add_2
SSS
	move.l	base_2,d0
	move.l	d0,d3
	lea	bottom_planes,a0
	move.l	#planesize,d1
pa_main_2
	moveq	#$00,d2
pa_loop_2
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	d1,d0
	lea	8(a0),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	d1,d0

cop2
	MOVE.L	D0,COP2ADR 
	lea	copper2,a0
	move.l	#cop_size,d1
cop_main
	moveq	#$01,d2
cop_loop
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	d1,d0
	lea	8(a0),a0
	dbra	d2,cop_loop
	rts
sprite_addresses
	add.l	#80,d0
	move.l	d0,sprite0adr
	lea	sprites,a0
	move.l	#spritesize0+8,d1
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	d1,d0
	lea	8(a0),a0
	move.l	d0,sprite1adr
	move.l	#spritesize1+8,d1
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	d1,d0
	lea	8(a0),a0
	move.l	d0,sprite2adr
	move.l	#4*spritesize2+24,d1
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	d1,d0
	lea	8(a0),a0
	move.l	d0,sprite3adr
	move.l	#4*spritesize2+24,d1
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	d1,d0
	lea	8(a0),a0
	move.l	d0,sprite4adr
	move.l	#4*spritesize2+24,d1
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	d1,d0
	lea	8(a0),a0
	move.l	d0,sprite5adr
	move.l	#4*spritesize2+24,d1
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	d1,d0
	lea	8(a0),a0
	move.l	d0,sprite6adr
	move.l	#4*spritesize2+24,d1
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	d1,d0
	lea	8(a0),a0
	move.l	d0,sprite7adr
	move.l	#4*spritesize2+24,d1
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	d1,d0
	lea	8(a0),a0
	rts
draw_backgrounds
	move.l	membase,a0
	lea	block,a4
	move.l	#(planesize/2-1),d2
fill_play_1
	move.l	(a4)+,(a0)+
	dbra	d2,fill_play_1

	move.l	base_2,a0
	move.l	#0,d4
	move.l	#(planesize/2-1),d2
fill_play_2
	move.l	d4,(a0)+
	dbra	d2,fill_play_2
	lea	panel,a4
	MOVE.L	cop2adr,A0
	MOVE.W	#COP_SIZE/2-1,D2
FILL_COP2
	MOVE.l	(a4)+,(A0)+
	DBRA	D2,FILL_COP2
	;RTS
	move.l	cop2adr,a0
	lea	328(a0),a0
	lea	score0,a3
	move.L	#(8*64)+2,d3
blit_score0
	moveq	#0,d0
	move.L	#37,d1
	MOVE.L	#$ffffffff,D4
	move.l	#$09f00000,d2
	lea	custom,a6	
	move.w	#1,d7
b_loop_score0
	bsr	blitter_score0
	lea	cop_size(a0),a0
	lea	28(a3),a3
	dbra	d7,b_loop_score0
	rts
blitter_score0
	btst	#6,dmaconr(a6)
	bne.s	blitter_score0
	move.l	a3,bltapt(a6)
	move.l	a0,bltdpt(a6)
	move.w	d0,bltamod(a6)
	move.w	d1,bltdmod(a6)
	move.l	d2,bltcon0(a6)
	move.l	d4,bltafwm(a6)
	move.l	d4,bltalwm(a6)
	move.w	d3,bltsize(a6)
	rts
blit_lives
	move.l	cop2adr,a0
	lea	356(a0),a0
	lea	lives3,a3
	move.L	#(8*64)+1,d3
blit_lives3
	moveq	#0,d0
	move.L	#38,d1
	MOVE.L	#$FFffffFF,D4
	move.l	#$09f00000,d2
	lea	custom,a6	
	move.w	#1,d7
b_loop_lives3
	bsr	blitter_lives3
	lea	cop_size(a0),a0
	lea	14(a3),a3
	dbra	d7,b_loop_lives3
	rts
blitter_lives3
	btst	#6,dmaconr(a6)
	bne.s	blitter_lives3
	move.l	a3,bltapt(a6)
	move.l	a0,bltdpt(a6)
	move.w	d0,bltamod(a6)
	move.w	d1,bltdmod(a6)
	move.l	d2,bltcon0(a6)
	move.l	d4,bltafwm(a6)
	move.l	d4,bltalwm(a6)
	move.w	d3,bltsize(a6)
	rts
build_ship0
	move.b	#204,vstart0
	move.b	#70,hstart0
	move.b	#219,vstop0
	move.b	#000,attach0
	move.w	#spritesize0/4-1,d3
	lea	ship_data0,a3
	move.l	sprite0adr,a0
	move.b	vstart0,(a0)+
	move.b	hstart0,(a0)+
	move.b	vstop0,(a0)+
	move.b	attach0,(a0)+
sprite
	move.l	(a3)+,(a0)+
	dbf	d3,sprite
build_sprite1
	move.b	vstart0,vstart1
	sub.b	#4,vstart1
	move.b	hstart0,hstart1
	move.b	vstart1,vstop1
	add.b	#5,vstop1
	move.w	#spritesize1/4-1,d3
	lea	missile_data1,a3
	move.l	sprite1adr,a0
	move.b	vstart1,(a0)+
	move.b	hstart1,(a0)+
	move.b	vstop1,(a0)+
	move.b	attach1,(a0)+
sprite1
	move.l	(a3)+,(a0)+
	dbf	d3,sprite1
build_alien2
	move.b	#50,vstart2
	move.b	#90,hstart2
	move.b	#66,vstop2
	move.b	#0,attach2
	move.w	#spritesize2/4-1,d3
	lea	galax1,a3
	move.l	sprite2adr,a0
	move.b	vstart2,(a0)+
	move.b	hstart2,(a0)+
	move.b	vstop2,(a0)+
	move.b	attach2,(a0)+
sprite2
	move.l	(a3)+,(a0)+
	dbf	d3,sprite2
	move.b	#70,vstart2.1
	move.b	#90,hstart2.1
	move.b	#86,vstop2.1
	move.b	#0,attach2.1
	move.w	#(spritesize2)/4-1,d3
	move.l	a0,sprite2.1adr
	move.b	vstart2.1,(a0)+
	move.b	hstart2.1,(a0)+
	move.b	vstop2.1,(a0)+
	move.b	attach2.1,(a0)+
	lea	4(a3),a3
sprite2.1
	move.l	(a3)+,(a0)+
	dbf	d3,sprite2.1
	move.b	#90,vstart2.2
	move.b	#90,hstart2.2
	move.b	#106,vstop2.2
	move.b	#0,attach2.2
	move.w	#(spritesize2)/4-1,d3
	move.l	a0,sprite2.2adr
	move.b	vstart2.2,(a0)+
	move.b	hstart2.2,(a0)+
	move.b	vstop2.2,(a0)+
	move.b	attach2.2,(a0)+
	lea	4(a3),a3
sprite2.2
	move.l	(a3)+,(a0)+
	dbf	d3,sprite2.2
	move.b	#110,vstart2.3
	move.b	#90,hstart2.3
	move.b	#126,vstop2.3
	move.b	#0,attach2.3
	move.b	#114,m_vstart1
	move.b	#90,m_hstart1
	move.w	#(spritesize2+4)/4-1,d3
	move.l	a0,sprite2.3adr
	move.b	vstart2.3,(a0)+
	move.b	hstart2.3,(a0)+
	move.b	vstop2.3,(a0)+
	move.b	attach2.3,(a0)+
	lea	4(a3),a3
sprite2.3
	move.l	(a3)+,(a0)+
	dbf	d3,sprite2.3
build_alien3
	move.b	#50,vstart3
	move.b	#106,hstart3
	move.b	#66,vstop3
	move.b	#0,attach3
	move.w	#spritesize2/4-1,d3
	move.l	sprite3adr,a0
	move.b	vstart3,(a0)+
	move.b	hstart3,(a0)+
	move.b	vstop3,(a0)+
	move.b	attach3,(a0)+
	lea	galax1,a3
sprite3
	move.l	(a3)+,(a0)+
	dbf	d3,sprite3
	move.b	#70,vstart3.1
	move.b	#106,hstart3.1
	move.b	#86,vstop3.1
	move.b	#0,attach3.1
	move.w	#(spritesize2)/4-1,d3
	move.l	a0,sprite3.1adr
	move.b	vstart3.1,(a0)+
	move.b	hstart3.1,(a0)+
	move.b	vstop3.1,(a0)+
	move.b	attach3.1,(a0)+
	lea	4(a3),a3
sprite3.1
	move.l	(a3)+,(a0)+
	dbf	d3,sprite3.1
	move.b	#90,vstart3.2
	move.b	#106,hstart3.2
	move.b	#106,vstop3.2
	move.b	#0,attach3.2
	move.w	#(spritesize2)/4-1,d3
	move.l	a0,sprite3.2adr
	move.b	vstart3.2,(a0)+
	move.b	hstart3.2,(a0)+
	move.b	vstop3.2,(a0)+
	move.b	attach3.2,(a0)+
	lea	4(a3),a3
sprite3.2
	move.l	(a3)+,(a0)+
	dbf	d3,sprite3.2
	move.b	#110,vstart3.3
	move.b	#106,hstart3.3
	move.b	#126,vstop3.3
	move.b	#0,attach3.3
	move.b	#114,m_vstart2
	move.w	#(spritesize2+4)/4-1,d3
	move.l	a0,sprite3.3adr
	move.b	vstart3.3,(a0)+
	move.b	hstart3.3,(a0)+
	move.b	vstop3.3,(a0)+
	move.b	attach3.3,(a0)+
	lea	4(a3),a3
sprite3.3
	move.l	(a3)+,(a0)+
	dbf	d3,sprite3.3
build_alien4
	move.b	#50,vstart4
	move.b	#122,hstart4
	move.b	#66,vstop4
	move.b	#0,attach4
	move.w	#spritesize2/4-1,d3
	move.l	sprite4adr,a0
	move.b	vstart4,(a0)+
	move.b	hstart4,(a0)+
	move.b	vstop4,(a0)+
	move.b	attach4,(a0)+
	lea	galax1,a3
sprite4
	move.l	(a3)+,(a0)+
	dbf	d3,sprite4
	move.b	#70,vstart4.1
	move.b	#122,hstart4.1
	move.b	#86,vstop4.1
	move.b	#0,attach4.1
	move.w	#(spritesize2)/4-1,d3
	move.l	a0,sprite4.1adr
	move.b	vstart4.1,(a0)+
	move.b	hstart4.1,(a0)+
	move.b	vstop4.1,(a0)+
	move.b	attach4.1,(a0)+
	lea	4(a3),a3
sprite4.1
	move.l	(a3)+,(a0)+
	dbf	d3,sprite4.1
	move.b	#90,vstart4.2
	move.b	#122,hstart4.2
	move.b	#106,vstop4.2
	move.b	#0,attach4.2
	move.w	#(spritesize2)/4-1,d3
	move.l	a0,sprite4.2adr
	move.b	vstart4.2,(a0)+
	move.b	hstart4.2,(a0)+
	move.b	vstop4.2,(a0)+
	move.b	attach4.2,(a0)+
	lea	4(a3),a3
sprite4.2
	move.l	(a3)+,(a0)+
	dbf	d3,sprite4.2
	move.b	#110,vstart4.3
	move.b	#122,hstart4.3
	move.b	#126,vstop4.3
	move.b	#0,attach4.3
	move.b	#114,m_vstart3
	move.w	#(spritesize2+4)/4-1,d3
	move.l	a0,sprite4.3adr
	move.b	vstart4.3,(a0)+
	move.b	hstart4.3,(a0)+
	move.b	vstop4.3,(a0)+
	move.b	attach4.3,(a0)+
	lea	4(a3),a3
sprite4.3
	move.l	(a3)+,(a0)+
	dbf	d3,sprite4.3
build_alien5
	move.b	#50,vstart5
	move.b	#138,hstart5
	move.b	#66,vstop5
	move.b	#0,attach5
	move.w	#spritesize2/4-1,d3
	move.l	sprite5adr,a0
	move.b	vstart5,(a0)+
	move.b	hstart5,(a0)+
	move.b	vstop5,(a0)+
	move.b	attach5,(a0)+
	lea	galax1,a3
sprite5
	move.l	(a3)+,(a0)+
	dbf	d3,sprite5
	move.b	#70,vstart5.1
	move.b	#138,hstart5.1
	move.b	#86,vstop5.1
	move.b	#0,attach5.1
	move.w	#(spritesize2)/4-1,d3
	move.l	a0,sprite5.1adr
	move.b	vstart5.1,(a0)+
	move.b	hstart5.1,(a0)+
	move.b	vstop5.1,(a0)+
	move.b	attach5.1,(a0)+
	lea	4(a3),a3
sprite5.1
	move.l	(a3)+,(a0)+
	dbf	d3,sprite5.1
	move.b	#90,vstart5.2
	move.b	#138,hstart5.2
	move.b	#106,vstop5.2
	move.b	#0,attach5.2
	move.w	#(spritesize2)/4-1,d3
	move.l	a0,sprite5.2adr
	move.b	vstart5.2,(a0)+
	move.b	hstart5.2,(a0)+
	move.b	vstop5.2,(a0)+
	move.b	attach5.2,(a0)+
	lea	4(a3),a3
sprite5.2
	move.l	(a3)+,(a0)+
	dbf	d3,sprite5.2
	move.b	#110,vstart5.3
	move.b	#138,hstart5.3
	move.b	#126,vstop5.3
	move.b	#0,attach5.3
	move.b	#114,m_vstart4
	move.w	#(spritesize2+4)/4-1,d3
	move.l	a0,sprite5.3adr
	move.b	vstart5.3,(a0)+
	move.b	hstart5.3,(a0)+
	move.b	vstop5.3,(a0)+
	move.b	attach5.3,(a0)+
	lea	4(a3),a3
sprite5.3
	move.l	(a3)+,(a0)+
	dbf	d3,sprite5.3
build_alien6
	move.b	#50,vstart6
	move.b	#154,hstart6
	move.b	#66,vstop6
	move.b	#0,attach6
	move.w	#spritesize2/4-1,d3
	move.l	sprite6adr,a0
	move.b	vstart6,(a0)+
	move.b	hstart6,(a0)+
	move.b	vstop6,(a0)+
	move.b	attach6,(a0)+
	lea	galax1,a3
sprite6
	move.l	(a3)+,(a0)+
	dbf	d3,sprite6
	move.b	#70,vstart6.1
	move.b	#154,hstart6.1
	move.b	#86,vstop6.1
	move.b	#0,attach6.1
	move.w	#(spritesize2)/4-1,d3
	move.l	a0,sprite6.1adr
	move.b	vstart6.1,(a0)+
	move.b	hstart6.1,(a0)+
	move.b	vstop6.1,(a0)+
	move.b	attach6.1,(a0)+
	lea	4(a3),a3
sprite6.1
	move.l	(a3)+,(a0)+
	dbf	d3,sprite6.1
	move.b	#90,vstart6.2
	move.b	#154,hstart6.2
	move.b	#106,vstop6.2
	move.b	#0,attach6.2
	move.w	#(spritesize2)/4-1,d3
	move.l	a0,sprite6.2adr
	move.b	vstart6.2,(a0)+
	move.b	hstart6.2,(a0)+
	move.b	vstop6.2,(a0)+
	move.b	attach6.2,(a0)+
	lea	4(a3),a3
sprite6.2
	move.l	(a3)+,(a0)+
	dbf	d3,sprite6.2
	move.b	#110,vstart6.3
	move.b	#154,hstart6.3
	move.b	#126,vstop6.3
	move.b	#0,attach6.3
	move.w	#(spritesize2+4)/4-1,d3
	move.l	a0,sprite6.3adr
	move.b	vstart6.3,(a0)+
	move.b	hstart6.3,(a0)+
	move.b	vstop6.3,(a0)+
	move.b	attach6.3,(a0)+
	lea	4(a3),a3
sprite6.3
	move.l	(a3)+,(a0)+
	dbf	d3,sprite6.3
build_alien7
	move.b	#50,vstart7
	move.b	#170,hstart7
	move.b	#66,vstop7
	move.b	#0,attach7
	move.w	#spritesize2/4-1,d3
	move.l	sprite7adr,a0
	move.b	vstart7,(a0)+
	move.b	hstart7,(a0)+
	move.b	vstop7,(a0)+
	move.b	attach7,(a0)+
	lea	galax1,a3
sprite7
	move.l	(a3)+,(a0)+
	dbf	d3,sprite7
	move.b	#70,vstart7.1
	move.b	#170,hstart7.1
	move.b	#86,vstop7.1
	move.b	#0,attach7.1
	move.w	#(spritesize2)/4-1,d3
	move.l	a0,sprite7.1adr
	move.b	vstart7.1,(a0)+
	move.b	hstart7.1,(a0)+
	move.b	vstop7.1,(a0)+
	move.b	attach7.1,(a0)+
	lea	4(a3),a3
sprite7.1
	move.l	(a3)+,(a0)+
	dbf	d3,sprite7.1
	move.b	#90,vstart7.2
	move.b	#170,hstart7.2
	move.b	#106,vstop7.2
	move.b	#0,attach7.2
	move.w	#(spritesize2)/4-1,d3
	move.l	a0,sprite7.2adr
	move.b	vstart7.2,(a0)+
	move.b	hstart7.2,(a0)+
	move.b	vstop7.2,(a0)+
	move.b	attach7.2,(a0)+
	lea	4(a3),a3
sprite7.2
	move.l	(a3)+,(a0)+
	dbf	d3,sprite7.2
	move.b	#110,vstart7.3
	move.b	#170,hstart7.3
	move.b	#126,vstop7.3
	move.b	#0,attach7.3
	move.w	#(spritesize2+4)/4-1,d3
	move.l	a0,sprite7.3adr
	move.b	vstart7.3,(a0)+
	move.b	hstart7.3,(a0)+
	move.b	vstop7.3,(a0)+
	move.b	attach7.3,(a0)+
	lea	4(a3),a3
sprite7.3
	move.l	(a3)+,(a0)+
	dbf	d3,sprite7.3
	rts
fire_miss_1
	cmp.b	#0,fire_missile_1
	beq	no_miss_fired
	add.b	#6,m_vstart1
	move.b	m_vstart1,m_vstart
	move.b	m_hstart1,m_hstart
	add.L	#6*40,missile_base_1
	move.l	missile_base_1,a0
	move.l	a0,missile_base
	lea	alien_missile,a3
	move.L	#(12*64)+1,d3
	bsr	blit_missile
	add.l	#6*40,missile_base_11.2
	move.l	missile_base_11.2,a0
	lea	alien_missile_MASK,a3
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	bsr	collision
	subI	#1,COUNT_3
	CMPI	#0,COUNT_3
	ble	RE_BUILD_3
	rts
re_build_3
	move.w	#32,count_3
	move.b	#0,fire_missile_1
	move.b	#114,m_vstart1
	add.l	#6*40,missile_base_11.2
	lea	alien_missile_MASK,a3
	move.l	missile_base_11.2,a0
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	rts

fire_miss_1.1
	cmp.b	#0,fire_missile_1.1
	beq	no_miss_fired
	add.b	#6,m_vstart1.1
	move.b	m_vstart1.1,m_vstart
	move.b	m_hstart1.1,m_hstart
	add.L	#6*40,missile_base_1.1
	move.l	missile_base_1.1,a0
	move.l	a0,missile_base
	lea	alien_missile_mk3,a3
	move.L	#(12*64)+1,d3
	bsr	blit_missile
	add.l	#6*40,missile_base_21.1
	move.l	missile_base_21.1,a0
	lea	alien_missile_MASK,a3
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	bsr	collision
	subI	#1,COUNT_4
	CMPI	#0,COUNT_4
	BLE	RE_BUILD_4
	rts
re_build_4
	move.w	#29,count_4
	move.b	#0,fire_missile_1.1
	move.b	#114,m_vstart1.1
	add.l	#6*40,missile_base_21.1
	lea	alien_missile_MASK,a3
	move.l	missile_base_21.1,a0
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	rts
fire_miss_2
	cmp.b	#0,fire_missile_2
	beq	no_miss_fired
	add.b	#6,m_vstart2
	move.b	m_vstart2,m_vstart
	move.b	m_hstart2,m_hstart
	add.L	#6*40,missile_base_2
	move.l	missile_base_2,a0
	move.l	a0,missile_base
	lea	alien_missile_mk2,a3
	move.L	#(12*64)+1,d3
	bsr	blit_missile
	add.l	#6*40,missile_base_21.2
	move.l	missile_base_21.2,a0
	lea	alien_missile_MASK,a3
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	bsr	collision
	SUBI	#1,COUNT_5
	CMPI	#0,COUNT_5
	BLE	RE_BUILD_5
	rts
re_build_5
	move.w	#29,count_5
	move.b	#0,fire_missile_2
	move.b	#114,m_vstart2
	add.l	#6*40,missile_base_21.2
	lea	alien_missile_MASK,a3
	move.l	missile_base_21.2,a0
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	rts
fire_miss_3
	cmp.b	#0,fire_missile_3
	beq	no_miss_fired
	add.b	#6,m_vstart3
	move.b	m_vstart3,m_vstart
	move.b	m_hstart3,m_hstart
	add.L	#6*40,missile_base_3
	move.l	missile_base_3,a0
	move.l	a0,missile_base
	lea	alien_missile_mk4,a3
	move.L	#(12*64)+1,d3
	bsr	blit_missile
	add.l	#6*40,missile_base_3.1
	move.l	missile_base_3.1,a0
	lea	alien_missile_MASK,a3
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	bsr	collision_2
	SUBI	#1,COUNT_6
	CMPI	#0,COUNT_6
	BLE	RE_BUILD_6
	rts
re_build_6
	move.w	#29,count_6
	move.b	#0,fire_missile_3
	move.b	#114,m_vstart3
	add.l	#6*40,missile_base_3.1
	lea	alien_missile_MASK,a3
	move.l	missile_base_3.1,a0
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	rts
fire_miss_4
	cmp.b	#0,fire_missile_4
	beq	no_miss_fired
	add.b	#6,m_vstart4
	move.b	m_vstart4,m_vstart
	move.b	m_hstart4,m_hstart
	add.L	#6*40,missile_base_4
	move.l	missile_base_4,a0
	move.l	a0,missile_base
	lea	alien_missile_mk3,a3
	move.L	#(12*64)+1,d3
	bsr	blit_missile
	add.l	#6*40,missile_base_4.1
	move.l	missile_base_4.1,a0
	lea	alien_missile_MASK,a3
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	bsr	collision_2
	SUBI	#1,COUNT_7
	CMPI	#0,COUNT_7
	BLE	RE_BUILD_7
	rts
re_build_7
	move.w	#29,count_7
	move.b	#0,fire_missile_4
	move.b	#114,m_vstart4
	add.l	#6*40,missile_base_4.1
	lea	alien_missile_MASK,a3
	move.l	missile_base_4.1,a0
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	rts
fire_miss_5
	cmp.b	#0,fire_missile_5
	beq	no_miss_fired
	add.b	#6,m_vstart5
	move.b	m_vstart5,m_vstart
	move.b	m_hstart5,m_hstart
	add.L	#6*40,missile_base_5
	move.l	missile_base_5,a0
	move.l	a0,missile_base
	lea	alien_missile,a3
	move.L	#(12*64)+1,d3
	bsr	blit_missile
	add.l	#6*40,missile_base_5.1
	move.l	missile_base_5.1,a0
	lea	alien_missile_MASK,a3
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	bsr	collision
	SUBI	#1,COUNT_8
	CMPI	#0,COUNT_8
	BLE	RE_BUILD_8
	rts
re_build_8
	move.w	#29,count_8
	move.b	#0,fire_missile_5
	move.b	#114,m_vstart5
	add.l	#6*40,missile_base_5.1
	lea	alien_missile_MASK,a3
	move.l	missile_base_5.1,a0
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	rts
fire_miss_6
	cmp.b	#0,fire_missile_6
	beq	no_miss_fired
	add.b	#6,m_vstart6
	move.b	m_vstart6,m_vstart
	move.b	m_hstart6,m_hstart
	add.L	#6*40,missile_base_6
	move.l	missile_base_6,a0
	move.l	a0,missile_base
	lea	alien_missile_mk2,a3
	move.L	#(12*64)+1,d3
	bsr	blit_missile
	add.l	#6*40,missile_base_6.1
	move.l	missile_base_6.1,a0
	lea	alien_missile_MASK,a3
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	bsr	collision
	SUBI	#1,COUNT_9
	CMPI	#0,COUNT_9
	BLE	RE_BUILD_9
	rts
re_build_9
	move.w	#29,count_9
	move.b	#0,fire_missile_6
	move.b	#114,m_vstart6
	add.l	#6*40,missile_base_6.1
	lea	alien_missile_MASK,a3
	move.l	missile_base_6.1,a0
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	rts
collision
	move.b	vstart0,d2
	sub.b	#2,d2
	cmp.b	m_vstart,d2
	bhs	miss_yes
	add.b	#17,d2
	cmp.b	m_vstart,d2
	bhs	coll_yes
	rts
coll_yes
	move.b	m_hstart,d2
	add.b	#4,d2
	cmp.b	HSTART0,d2
	bls	miss_yes
	move.b	m_hstart,d2
	sub.b	#4,d2
	cmp.b	hstart0,d2
	bls	test_numberoflives
miss_yes
	rts
collision_2
	move.b	vstart0,d2
	cmp.b	m_vstart,d2
	bhs	miss_yes_2
	add.b	#17,d2
	cmp.b	m_vstart,d2
	bhs	coll_yes_2
	rts
coll_yes_2
	move.b	m_hstart,d2
	add.b	#6,d2
	cmp.b	HSTART0,d2
	bls	miss_yes_2
	move.b	m_hstart,d2
	sub.b	#2,d2
	cmp.b	hstart0,d2
	bls	test_numberoflives
miss_yes_2
	rts
test_numberoflives
	move.l	sprite1adr,a0
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.l	missile_base,a0
	add.l	#6*40,a0
	lea	alien_missile_mask,a3
	move.L	#(6*64)+1,d3
	bsr	blit_missile_2
	LEA	sprite_colors,a0
	add.w	#6,a0
	move.w	#$0fff,(a0)
	add.w	#4,a0
	move.w	#$0ff0,(a0)
	add.w	#4,a0
	move.w	#$0d00,(a0)
	move.l	sprite0adr,a0
	lea	4(a0),a0
	move.w	#spritesize0/4-1,d2
	lea	explosion_2,a3
expl0
	move.l	(a3)+,(a0)+
	dbf	d2,expl0
	move.l	#$ffffff,d2
ship_hold
	dbf	d2,ship_hold	
	move.l	sprite0adr,a0
	lea	4(a0),a0
	move.w	#spritesize0/4-1,d2
	lea	explosion,a3
expl1
	move.l	(a3)+,(a0)+
	dbf	d2,expl1
	move.l	#$ffffff,d2
ship_hol
	dbf	d2,ship_hol	
	move.l	sprite0adr,a0
	lea	4(a0),a0
	move.w	#spritesize0/4-1,d2
	lea	explosion_2,a3
expl3
	move.l	(a3)+,(a0)+
	dbf	d2,expl3
	move.l	#$ffffff,d2
ship_ho
	dbf	d2,ship_ho	
	move.b	#204,vstart0
	move.b	#70,hstart0
	move.b	#219,vstop0
	move.b	#0,attach0
	move.l	sprite0adr,a0
	move.b	vstart0,(a0)+
	move.b	hstart0,(a0)+
	move.b	vstop0,(a0)+
	move.b	attach0,(A0)+
	MOVE.W	#0,COUNT_3
	MOVE.W	#0,COUNT_4
	MOVE.W	#0,COUNT_5
	MOVE.W	#0,COUNT_6
	MOVE.W	#0,COUNT_7
	MOVE.W	#0,COUNT_8
	sub.b	#1,lives
	LEA	sprite_colors,a0
	add.w	#6,a0
	move.w	#$0f00,(a0)
	add.w	#4,a0
	move.w	#$0FF0,(a0)
	add.w	#4,a0
	move.w	#$006F,(a0)
	move.l	cop2adr,a0
	lea	356(a0),a0
	lea	lives2,a3
	move.L	#(8*64)+1,d3
	MOVE.L	#0,d5
	move.w	#18,d5
	move.w	#$3e8,d0
	move.L	#38,d1
	cmp.b	#2,lives
	beq	blit_live2
	cmp.b	#1,lives
	beq	blit_live1
	cmp.b	#0,lives
	beq	game_over
	rts
blit_live2
	lea	lives2,a3
	bsr	blit_live
	rts
blit_live1
	lea	lives1,a3
	bsr	blit_live
	rts
blit_live
	MOVE.L	#$FFffffFF,D4
	move.l	#$09f00000,d2
	lea	custom,a6	
	move.w	#1,d7
b_loop_lives
	bsr	blitter_lives
	lea	(a0,d0),a0
	lea	(a3,d5),a3
	dbra	d7,b_loop_lives
	rts
blitter_lives
	btst	#6,dmaconr(a6)
	bne.s	blitter_lives
	move.l	a3,bltapt(a6)
	move.l	a0,bltdpt(a6)
	move.w	#$0,bltamod(a6)
	move.w	d1,bltdmod(a6)
	move.l	d2,bltcon0(a6)
	move.l	d4,bltafwm(a6)
	move.l	d4,bltalwm(a6)
	move.w	d3,bltsize(a6)
	rts
game_over
	lea	lives0,a3
	bsr	blit_live
	move.l	sprite0adr,a0
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(A0)+
	move.l	sprite2adr,a0
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(A0)+
	move.l	sprite3adr,a0
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(A0)+
	move.l	sprite4adr,a0
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(A0)+
	move.l	sprite5adr,a0
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(A0)+
	move.l	sprite6adr,a0
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(A0)+
	move.l	sprite7adr,a0
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(A0)+
	move.l	base_2,a0
	lea	2008(a0),a0
	lea	gameover,a3
	move.L	#(92*64)+11,d3
	move.L	#18,d1
	move.w	#40*400,d0
	MOVE.L	#0,d5
	move.w	#92*22,d5
	bsr	blit_live
	move.w	#0,d1
game_over_hold
	btst	#7,$bfe001
	bne	game_over_hold
	bra	start
blit_missile
	moveq	#0,d0
	move.L	#38,d1
	MOVE.L	#$FFffffFF,D4
	move.l	#$09f00000,d2
	lea	custom,a6	
	move.w	#1,d7
b_loop
	bsr	blitter
	lea	planesize(a0),a0
	lea	18(a3),a3
	dbra	d7,b_loop
	rts
blitter
	btst	#6,dmaconr(a6)
	bne.s	blitter
	move.l	a3,bltapt(a6)
	move.l	a0,bltdpt(a6)
	move.w	d0,bltamod(a6)
	move.w	d1,bltdmod(a6)
	move.l	d2,bltcon0(a6)
	move.w	d3,bltsize(a6)
	rts
blit_missile_2
	moveq	#0,d0
	move.L	#38,d1
	MOVE.L	#$FFffffFF,D4
	move.l	#$09f00000,d2
	lea	custom,a6	
	move.w	#1,d7
b_loop_2
	bsr	blitter_2
	lea	planesize(a0),a0
	lea	18(a3),a3
	dbra	d7,b_loop_2
	rts
blitter_2
	btst	#6,dmaconr(a6)
	bne.s	blitter_2
	move.l	a3,bltapt(a6)
	move.l	a0,bltdpt(a6)
	move.w	d0,bltamod(a6)
	move.w	d1,bltdmod(a6)
	move.l	d2,bltcon0(a6)
	move.w	d3,bltsize(a6)
	rts

no_miss_fired
	rts
internal_clock
	cmp.b	#90,hstart2
	beq	set_clock_1
	cmp.b	#114,hstart2
	beq	set_clock_1.1
	cmp.b	#116,hstart3
	beq	set_clock_2
	cmp.b	#128,hstart4
	beq	set_clock_3
	rts
internal_clock_2
	cmp.b	#154,hstart5
	beq	set_clock_4
	cmp.b	#162,hstart6
	beq	set_clock_5
internal_clock_3
	cmp.b	#186,hstart7
	beq	set_clock_6
	rts
set_clock_1
	move.b	#1,fire_missile_1
	move.l	#base+2727,missile_base_1
	move.l	#base+2727,missile_base_11.2
	move.l	missile_reduction,d4
	add.l	d4,missile_base_1
	add.l	d4,missile_base_11.2
	move.b	#114,m_vstart1
	move.b	m_vstart_reduction,d5
	add.b	d5,m_vstart1
	move.w	#19,count_3
	cmp.b	#1,hit_alien_19
	beq	sub800
	MOVE.B	HSTART2.3,d2
	move.b	d2,m_hstart1
	rts
sub800
	sub.l	#20*40,missile_base_1
	sub.l	#20*40,missile_base_11.2
	ADD.W	#3,COUNT_3
	cmp.b	#1,hit_alien_13
	beq	sub800_1.1
	MOVE.B	HSTART2.2,d2
	move.b	d2,m_hstart1
	sub.b	#20,m_vstart1
	rts
sub800_1.1
	sub.l	#20*40,missile_base_1
	sub.l	#20*40,missile_base_11.2
	ADD.W	#3,COUNT_3
	cmp.b	#1,hit_alien_2
	beq	sub800_1.11
	MOVE.B	HSTART2.1,d2
	move.b	d2,m_hstart1
	sub.b	#40,m_vstart1
	rts
sub800_1.11
	sub.l	#20*40,missile_base_1
	sub.l	#20*40,missile_base_11.2
	ADD.W	#3,COUNT_3
	MOVE.B	HSTART2,d2
	move.b	d2,m_hstart1
	sub.b	#60,m_vstart1
	rts
set_clock_1.1
	move.b	#1,fire_missile_1.1
	move.l	#base+2727,missile_base_1.1
	move.l	#base+2727,missile_base_21.1
	add.L	#5,missile_base_1.1
	add.L	#5,missile_base_21.1
	move.l	missile_reduction,d4
	add.l	d4,missile_base_1.1
	add.l	d4,missile_base_21.1
	move.b	#114,m_vstart1.1
	move.b	m_vstart_reduction,d5
	add.b	d5,m_vstart1.1
	move.W	#19,COUNT_4
	cmp.b	#1,hit_alien_19
	beq	sub800_1
	MOVE.B	HSTART2.3,d2
	move.b	d2,m_hstart1.1
	rts
sub800_1
	sub.l	#20*40,missile_base_1.1
	sub.l	#20*40,missile_base_21.1
	ADD.W	#3,COUNT_4
	cmp.b	#1,hit_alien_13
	beq	sub800_1.12
	MOVE.B	HSTART2.2,d2
	move.b	d2,m_hstart1.1
	sub.b	#20,m_vstart1.1
	rts
sub800_1.12
	sub.l	#20*40,missile_base_1.1
	sub.l	#20*40,missile_base_21.1
	ADD.W	#3,COUNT_4
	cmp.b	#1,hit_alien_2
	beq	sub800_1.123
	MOVE.B	HSTART2.1,d2
	move.b	d2,m_hstart1.1
	sub.b	#40,m_vstart1.1
	rts
sub800_1.123
	sub.l	#20*40,missile_base_1.1
	sub.l	#20*40,missile_base_21.1
	ADD.W	#3,COUNT_4
	MOVE.B	HSTART2,d2
	move.b	d2,m_hstart1.1
	sub.b	#60,m_vstart1.1
	rts
set_clock_2
	move.b	#0,fire_missile_2
	move.l	#base+2727,missile_base_2
	move.l	#base+2727,missile_base_21.2
	add.L	#6,missile_base_2
	add.L	#6,missile_base_21.2
	move.l	missile_reduction,d4
	add.l	d4,missile_base_2
	add.l	d4,missile_base_21.2
	move.b	#114,m_vstart2
	move.b	m_vstart_reduction,d5
	add.b	d5,m_vstart2
	move.W	#19,COUNT_5
	cmp.b	#1,hit_alien_20
	beq	sub800_2
	MOVE.B	HSTART3.3,d2
	move.b	d2,m_hstart
	rts
sub800_2
	move.b	#1,fire_missile_2
	sub.l	#20*40,missile_base_2
	sub.l	#20*40,missile_base_21.2
	ADD.W	#3,COUNT_5
	cmp.b	#1,hit_alien_14
	beq	sub800_2.1
	MOVE.B	HSTART3.2,d2
	move.b	d2,m_hstart2
	sub.b	#20,m_vstart2
	rts
sub800_2.1
	sub.l	#20*40,missile_base_2
	sub.l	#20*40,missile_base_21.2
	ADD.W	#3,COUNT_5
	cmp.b	#1,hit_alien_4
	beq	sub800_2.2
	MOVE.B	HSTART3.1,d2
	move.b	d2,m_hstart2
	sub.b	#40,m_vstart2
	rts
sub800_2.2
	sub.l	#20*40,missile_base_2
	sub.l	#20*40,missile_base_21.2
	ADD.W	#3,COUNT_5
	MOVE.B	HSTART3,d2
	move.b	d2,m_hstart2
	sub.b	#60,m_vstart2
	rts
set_clock_3
	move.b	#1,fire_missile_3
	move.l	#base+2727,missile_base_3
	move.l	#base+2727,missile_base_3.1
	add.L	#9,missile_base_3
	add.L	#9,missile_base_3.1
	move.l	missile_reduction,d4
	add.l	d4,missile_base_3
	add.l	d4,missile_base_3.1
	move.b	#114,m_vstart3
	move.b	m_vstart_reduction,d5
	add.b	d5,m_vstart3
	move.W	#19,COUNT_6
	cmp.b	#1,hit_alien_21
	beq	sub800_3
	MOVE.B	HSTART4.3,d2
	move.b	d2,m_hstart3
	rts
sub800_3
	sub.l	#20*40,missile_base_3
	sub.l	#20*40,missile_base_3.1
	ADD.W	#3,COUNT_6
	cmp.b	#1,hit_alien_15
	beq	sub800_3.1
	MOVE.B	HSTART4.2,d2
	move.b	d2,m_hstart3
	sub.b	#20,m_vstart3
	rts
sub800_3.1
	sub.l	#20*40,missile_base_3
	sub.l	#20*40,missile_base_3.1
	ADD.W	#3,COUNT_6
	cmp.b	#1,hit_alien_6
	beq	sub800_3.2
	MOVE.B	HSTART4.1,d2
	move.b	d2,m_hstart3
	sub.b	#40,m_vstart3
	rts
sub800_3.2
	sub.l	#20*40,missile_base_3
	sub.l	#20*40,missile_base_3.1
	ADD.W	#3,COUNT_6
	MOVE.B	HSTART4,d2
	move.b	d2,m_hstart3
	sub.b	#60,m_vstart3
	rts
set_clock_4
	move.b	#1,fire_missile_4
	move.l	#base+2727,missile_base_4
	move.l	#base+2727,missile_base_4.1
	add.L	#16,missile_base_4
	add.L	#16,missile_base_4.1
	move.l	missile_reduction,d4
	add.l	d4,missile_base_4
	add.l	d4,missile_base_4.1
	move.b	#114,m_vstart4
	move.b	m_vstart_reduction,d5
	add.b	d5,m_vstart4
	move.W	#19,COUNT_7
	cmp.b	#1,hit_alien_22
	beq	sub800_4
	MOVE.B	HSTART5.3,d2
	move.b	d2,m_hstart4
	rts
sub800_4
	sub.l	#20*40,missile_base_4
	sub.l	#20*40,missile_base_4.1
	ADD.W	#3,COUNT_7
	cmp.b	#1,hit_alien_16
	beq	sub800_4.1
	MOVE.B	HSTART5.2,d2
	move.b	d2,m_hstart4
	sub.b	#20,m_vstart4
	rts
sub800_4.1
	sub.l	#20*40,missile_base_4
	sub.l	#20*40,missile_base_4.1
	ADD.W	#3,COUNT_7
	cmp.b	#1,hit_alien_8
	beq	sub800_4.2
	MOVE.B	HSTART5.1,d2
	move.b	d2,m_hstart4
	sub.b	#40,m_vstart4
	rts
sub800_4.2
	sub.l	#20*40,missile_base_4
	sub.l	#20*40,missile_base_4.1
	ADD.W	#3,COUNT_7
	MOVE.B	HSTART5,d2
	move.b	d2,m_hstart4
	sub.b	#60,m_vstart4
	rts
set_clock_5
	move.b	#1,fire_missile_5
	move.l	#base+2727,missile_base_5
	move.l	#base+2727,missile_base_5.1
	add.L	#17,missile_base_5
	add.L	#17,missile_base_5.1
	move.l	missile_reduction,d4
	add.l	d4,missile_base_5
	add.l	d4,missile_base_5.1
	move.b	#114,m_vstart5
	move.b	m_vstart_reduction,d5
	add.b	d5,m_vstart5
	move.w	#19,count_8
	cmp.b	#1,hit_alien_23
	beq	sub800_5
	MOVE.B	HSTART6.3,d2
	move.b	d2,m_hstart5
	rts
sub800_5
	sub.l	#20*40,missile_base_5
	sub.l	#20*40,missile_base_5.1
	ADD.W	#3,COUNT_8
	cmp.b	#1,hit_alien_17
	beq	sub800_5.1
	MOVE.B	HSTART6.2,d2
	move.b	d2,m_hstart5
	sub.b	#20,m_vstart5
	rts
sub800_5.1
	sub.l	#20*40,missile_base_5
	sub.l	#20*40,missile_base_5.1
	ADD.W	#3,COUNT_8
	cmp.b	#1,hit_alien_10
	beq	sub800_5.2
	MOVE.B	HSTART6.1,d2
	move.b	d2,m_hstart5
	sub.b	#40,m_vstart5
	rts
sub800_5.2
	sub.l	#20*40,missile_base_5
	sub.l	#20*40,missile_base_5.1
	ADD.W	#3,COUNT_8
	MOVE.B	HSTART6,d2
	move.b	d2,m_hstart5
	sub.b	#60,m_vstart5
	rts
set_clock_6
	move.b	#1,fire_missile_6
	move.l	#base+2727,missile_base_6
	move.l	#base+2727,missile_base_6.1
	add.L	#23,missile_base_6
	add.L	#23,missile_base_6.1
	move.l	missile_reduction,d4
	add.l	d4,missile_base_6
	add.l	d4,missile_base_6.1
	move.b	#114,m_vstart6
	move.b	m_vstart_reduction,d5
	add.b	d5,m_vstart6
	move.w	#19,count_9
	cmp.b	#1,hit_alien_24
	beq	sub800_6
	MOVE.B	HSTART7.3,d2
	move.b	d2,m_hstart6
	rts
sub800_6
	sub.l	#20*40,missile_base_6
	sub.l	#20*40,missile_base_6.1
	ADD.W	#3,COUNT_9
	cmp.b	#1,hit_alien_18
	beq	sub800_6.1
	MOVE.B	HSTART7.2,d2
	move.b	d2,m_hstart6
	sub.b	#20,m_vstart6
	rts
sub800_6.1
	sub.l	#20*40,missile_base_6
	sub.l	#20*40,missile_base_6.1
	ADD.W	#3,COUNT_9
	cmp.b	#1,hit_alien_11
	beq	sub800_6.2
	MOVE.B	HSTART7.1,d2
	move.b	d2,m_hstart6
	sub.b	#40,m_vstart6
	rts
sub800_6.2
	sub.l	#20*40,missile_base_6
	sub.l	#20*40,missile_base_6.1
	ADD.W	#3,COUNT_9
	MOVE.B	HSTART7,d2
	move.b	d2,m_hstart6
	sub.b	#60,m_vstart6
	rts
joy_test
	move.w	$DFF00c,d2
	move.w	d2,d1
	lsr.w	#1,d1
	eor.w	d2,d1
	btst	#1,d2
	beq	try_left
	add.b	#1,hstart0
	rts
try_left
	btst	#9,d2
	beq	no_move
	sub.b	#1,hstart0
	rts
try_down
	btst	#0,d1
	beq	try_up
	add.b	#1,vstart0
	add.b	#1,vstop0
	rts
try_up
	btst	#8,d1
	beq	no_move
	sub.b	#1,vstart0
	sub.b	#1,vstop0
	rts
no_move
	rts
bound_test
	move.b	hstart0,d1
	cmp.b	#63,d1
	bls	no_move_left
	cmp.b	#216,d1
	bhi	no_move_right
	rts
no_move_left
	add.b	#1,hstart0
	move.b	hstart0,hstart1
	rts
no_move_right
	sub.b	#1,hstart0
	move.b	hstart0,hstart1
	rts
move_ship0
	move.l	sprite0adr,a0
	move.b	vstart0,(a0)+
	move.b	hstart0,(a0)+
	move.b	vstop0,(a0)+
	move.b	attach0,(a0)+
	rts
anim_ship0
	move.l	sprite0adr,a0
	lea	4(a0),a0
	move.w	#spritesize0/4-1,d2
	add.b	#1,anim.delay
	cmp.b	#9,anim.delay
	bge	animation.0
	lea	SPRITE_data_1,a3
transfer
	move.l	(a3)+,(a0)+
	dbf	d2,transfer	
	rts
animation.0
	lea	SPRITE_data,a3
transfer.2
	move.l	(a3)+,(a0)+
	dbf	d2,transfer.2	
	add.b	#1,anim.delay.1
	cmp.b	#9,anim.delay.1
	bge	delay.2
	rts
delay.2
	move.b	#0,anim.delay
	move.b	#0,anim.delay.1
	rts
fire
	cmp.w	#1,scount
	beq	on_way
	cmp.b	#24,hit_alien
	beq	not_fired
	btst	#7,$bfe001
	bne	not_fired
	move.w	#1,scount
	cmp.w	#1,scount
	bne	not_fired
	move.b	vstart0,vstart1
	sub.b	#4,vstart1
	move.b	hstart0,hstart1
	move.b	vstart1,vstop1
	add.b	#5,vstop1
	move.b	attach0,attach1
	rts
on_way
	sub.b	#6,vstart1
	sub.b	#6,vstop1
	rts
not_fired
	move.b	vstart0,vstart1
	sub.b	#4,vstart1
	move.b	hstart0,hstart1
	move.b	vstart1,vstop1
	add.b	#5,vstop1
	move.b	attach0,attach1
	rts
move_missile1
	move.l	sprite1adr,a0
	move.b	vstart1,(a0)+
	move.b	hstart1,(a0)+
	move.b	vstop1,(a0)+
	move.b	attach1,(a0)+
	rts
test_collision
	move.b	vstop1,d2
	add.b	#4,d2
	cmp.b	vstop_test,d2
	bhi	try_vstart
	cmp.b	#10,vstart1
	bls	hit_top
	RTS
try_vstart
	move.b	vstop1,d2
	sub.b	#2,d2
	cmp.b	vstop_test,d2
	bls	try_hstart
	cmp.b	#10,vstart1
	bls	hit_top
	RTS
try_hstart
	move.b	hstart1,d2
	ADD.b	#5,d2
	cmp.b	h_test,d2
	bls	missed
	move.b	hstart1,d2
	SUB.b	#5,d2
	cmp.b	h_test,d2
	bhs	missed
	add.b	#1,hit_alien
	bsr	which_alien_hit

	move.w	#0,scount
	rts
missed
	cmp.b	#10,vstart1
	bls	hit_top
	rts
update_score
	move.l	cop2adr,a0
	lea	330(a0),a0
	move.L	#(8*64)+1,d3
	cmp.b	#1,hit_alien
	beq	set_blit_10
	cmp.b	#2,hit_alien
	beq	set_blit_20
	cmp.b	#3,hit_alien
	beq	set_blit_30
	cmp.b	#4,hit_alien
	beq	set_blit_40
	cmp.b	#5,hit_alien
	beq	set_blit_50
	cmp.b	#6,hit_alien
	beq	set_blit_60
	cmp.b	#7,hit_alien
	beq	set_blit_70
	cmp.b	#8,hit_alien
	beq	set_blit_80
	cmp.b	#9,hit_alien
	beq	set_blit_90
	cmp.b	#10,hit_alien
	beq	set_blit_0100
	cmp.b	#11,hit_alien
	beq	set_blit_10
	cmp.b	#12,hit_alien
	beq	set_blit_20
	cmp.b	#13,hit_alien
	beq	set_blit_30
	cmp.b	#14,hit_alien
	beq	set_blit_40
	cmp.b	#15,hit_alien
	beq	set_blit_50
	cmp.b	#16,hit_alien
	beq	set_blit_60
	cmp.b	#17,hit_alien
	beq	set_blit_70
	cmp.b	#18,hit_alien
	beq	set_blit_80
	cmp.b	#19,hit_alien
	beq	set_blit_90
	cmp.b	#20,hit_alien
	beq	set_blit_0200
	cmp.b	#21,hit_alien
	beq	set_blit_10
	cmp.b	#22,hit_alien
	beq	set_blit_20
	cmp.b	#23,hit_alien
	beq	set_blit_30
	cmp.b	#24,hit_alien
	beq	set_blit_40_restart
	rts
set_blit_10
	lea	number_10,a3
	bsr	blit_score
	rts
set_blit_20
	lea	number_20,a3
	bsr	blit_score
	rts
set_blit_30
	lea	number_30,a3
	bsr	blit_score
	rts
set_blit_40
	lea	number_40,a3
	bsr	blit_score
	rts
set_blit_50
	lea	number_50,a3
	bsr	blit_score
	rts
set_blit_60
	lea	number_60,a3
	bsr	blit_score
	rts
set_blit_70
	lea	number_70,a3
	bsr	blit_score
	rts
set_blit_80
	lea	number_80,a3
	bsr	blit_score
	rts
set_blit_90
	lea	number_90,a3
	bsr	blit_score
	rts
set_blit_0100
	lea	number_01,a3
	move.l	cop2adr,a0
	lea	328(a0),a0
	bsr	blit_score
	lea	number_00,a3
	move.l	cop2adr,a0
	lea	330(a0),a0
	bsr	blit_score
	rts
set_blit_0200
	lea	number_02,a3
	move.l	cop2adr,a0
	lea	328(a0),a0
	bsr	blit_score
	lea	number_00,a3
	move.l	cop2adr,a0
	lea	330(a0),a0
	bsr	blit_score
	rts
set_blit_40_restart
	lea	number_40,a3
	bsr	blit_score
	move.l	sprite1adr,a0
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.l	base_2,a0
	lea	2008(a0),a0
	lea	you_win,a3
	move.L	#(64*64)+15,d3
	move.L	#10,d1
	move.w	#40*400,d0
	MOVE.L	#0,d5
	move.w	#64*30,d5
	bsr	blit_live
	move.w	#0,d1
game_over_hold_2
	btst	#7,$bfe001
	bne	game_over_hold_2
	bra	start
	rts
blit_score
	moveq	#0,d0
	move.L	#38,d1
	MOVE.L	#$FFffffFF,D4
	move.l	#$09f00000,d2
	lea	custom,a6	
	move.w	#1,d7
b_loop_score
	bsr	blitter_score
	lea	cop_size(a0),a0
	lea	16(a3),a3
	dbra	d7,b_loop_score
	rts
blitter_score
	btst	#6,dmaconr(a6)
	bne.s	blitter_score
	move.l	a3,bltapt(a6)
	move.l	a0,bltdpt(a6)
	move.w	d0,bltamod(a6)
	move.w	d1,bltdmod(a6)
	move.l	d2,bltcon0(a6)
	move.l	d4,bltafwm(a6)
	move.l	d4,bltalwm(a6)
	move.w	d3,bltsize(a6)
	rts
hit_top
	move.b	vstart0,vstart1
	sub.b	#4,vstart1
	move.b	hstart0,hstart1
	move.b	vstart1,vstop1
	add.b	#5,vstop1
	move.b	attach0,attach1
	move.w	#0,scount
	rts
which_alien_hit
	cmp.b	#1,alien_number
	beq	hit_number1
	cmp.b	#2,alien_number
	beq	hit_number2
	CMP.B	#3,alien_number
	beq	hit_number3
	cmp.b	#4,alien_number
	beq	hit_number4
	cmp.b	#5,alien_number
	beq	hit_number5
	CMP.B	#6,alien_number
	beq	hit_number6
	cmp.b	#7,alien_number
	beq	hit_number7
	cmp.b	#8,alien_number
	beq	hit_number8
	CMP.B	#9,alien_number
	beq	hit_number9
	cmp.b	#10,alien_number
	beq	hit_number10
	cmp.b	#11,alien_number
	beq	hit_number11
	CMP.B	#12,alien_number
	beq	hit_number12
	CMP.B	#13,alien_number
	beq	hit_number13
	CMP.B	#14,alien_number
	beq	hit_number14
	CMP.B	#15,alien_number
	beq	hit_number15
	CMP.B	#16,alien_number
	beq	hit_number16
	CMP.B	#17,alien_number
	beq	hit_number17
	CMP.B	#18,alien_number
	beq	hit_number18
	CMP.B	#19,alien_number
	beq	hit_number19
	CMP.B	#20,alien_number
	beq	hit_number20
	CMP.B	#21,alien_number
	beq	hit_number21
	CMP.B	#22,alien_number
	beq	hit_number22
	CMP.B	#23,alien_number
	beq	hit_number23
	CMP.B	#24,alien_number
	beq	hit_number24
	rts
hit_number1
	move.b	#1,hit_alien_1
	bsr	explosion_2.3
	rts
hit_number2
	move.b	#1,hit_alien_2
	bsr	explosion_2.3
	rts
hit_number3
	move.b	#1,hit_alien_3
	bsr	explosion_2.3
	rts
hit_number4
	move.b	#1,hit_alien_4
	bsr	explosion_2.3
	rts
hit_number5
	move.b	#1,hit_alien_5
	bsr	explosion_2.3
	rts
hit_number6
	move.b	#1,hit_alien_6
	bsr	explosion_2.3
	rts
hit_number7
	move.b	#1,hit_alien_7
	bsr	explosion_2.3
	rts
hit_number8
	move.b	#1,hit_alien_8
	bsr	explosion_2.3
	rts
hit_number9
	move.b	#1,hit_alien_9
	bsr	explosion_2.3
	rts
hit_number10
	move.b	#1,hit_alien_10
	bsr	explosion_2.3
	rts
hit_number11
	move.b	#1,hit_alien_11
	bsr	explosion_2.3
	rts
hit_number12
	move.b	#1,hit_alien_12
	bsr	explosion_2.3
	rts
hit_number13
	move.b	#1,hit_alien_13
	bsr	explosion_2.3
	rts
hit_number14
	move.b	#1,hit_alien_14
	bsr	explosion_2.3
	rts
hit_number15
	move.b	#1,hit_alien_15
	bsr	explosion_2.3
	rts
hit_number16
	move.b	#1,hit_alien_16
	bsr	explosion_2.3
	rts
hit_number17
	move.b	#1,hit_alien_17
	bsr	explosion_2.3
	rts
hit_number18
	move.b	#1,hit_alien_18
	bsr	explosion_2.3
	rts
hit_number19
	move.b	#1,hit_alien_19
	bsr	explosion_2.3
	rts
hit_number20
	move.b	#1,hit_alien_20
	bsr	explosion_2.3
	rts
hit_number21
	move.b	#1,hit_alien_21
	bsr	explosion_2.3
	rts
hit_number22
	move.b	#1,hit_alien_22
	bsr	explosion_2.3
	rts
hit_number23
	move.b	#1,hit_alien_23
	bsr	explosion_2.3
	rts
hit_number24
	move.b	#1,hit_alien_24
	bsr	explosion_2.3
	rts
remove_from_display_
	move.b	#50,vstart
	move.b	#0,hstart
	move.b	#66,vstop
	move.b	#0,attach
	move.l	spriteadr,a0
	move.b	vstart,(a0)+
	move.b	hstart,(a0)+
	move.b	vstop,(a0)+
	move.b	attach,(a0)+
	rts
remove_from_display_2
	move.b	#70,vstart
	move.b	#0,hstart
	move.b	#86,vstop
	move.b	#0,attach
	move.l	spriteadr,a0
	move.b	vstart,(a0)+
	move.b	hstart,(a0)+
	move.b	vstop,(a0)+
	move.b	attach,(a0)+
	rts
remove_from_display_3
	move.b	#90,vstart
	move.b	#0,hstart
	move.b	#106,vstop
	move.b	#0,attach
	move.l	spriteadr,a0
	move.b	vstart,(a0)+
	move.b	hstart,(a0)+
	move.b	vstop,(a0)+
	move.b	attach,(a0)+
	rts
remove_from_display_4
	move.b	#110,vstart
	move.b	#0,hstart
	move.b	#126,vstop
	move.b	#0,attach
	move.l	spriteadr,a0
	move.b	vstart,(a0)+
	move.b	hstart,(a0)+
	move.b	vstop,(a0)+
	move.b	attach,(a0)+
	rts
explosion_2.3
	move.l	spriteadr,a0
	lea	4(a0),a0
	move.w	#spritesize2/4-1,d2
	lea	explosion_2,a3
	add.b	#1,anim.delay_10
	cmp.b	#6,anim.delay_10
	bge	animation.10
transfer_10
	move.l	(a3)+,(a0)+
	dbf	d2,transfer_10	
	rts
animation.10
	LEA	explosion,a3
transfer.2.10
	move.l	(a3)+,(a0)+
	dbf	d2,transfer.2.10	
	add.b	#1,anim.delay_11
	cmp.b	#6,anim.delay_11
	bge	delay_10
	rts
delay_10
	move.b	#0,anim.delay_10
	move.b	#0,anim.delay_11
	rts
;alien_motion
	move.l	alien_2_vtrack,a3
	MOVE.b	(a3)+,d3
	move.l	a3,alien_2_vtrack
	cmp.b	test,d3
	beq	reset_alienmove
	add.b	d3,m_vstart_reduction
	move.l	#0,d7
	move.b	d3,d7
	mulu	#40,d7
	add.l	d7,missile_reduction
	move.l	alien_2_htrack,a3
	MOVE.b	(a3)+,d4
	move.l	a3,alien_2_htrack
	rts
reset_alienmove
	lea	alien_2_vpath,a3
	move.l	a3,alien_2_vtrack
	lea	alien_2_hpath,a3
	move.l	a3,alien_2_htrack
	MOVE.B	#0,D3
	MOVE.B	#0,D4
	rts
alien_motion
	;ILLEGAL
	move.b	#0,d3
	move.b	#2,d5
	move.b	#0,d4
	add.b	#1,skip
	cmp.b	#4,skip
	beq	skip_it
	rts
skip_it

	move.b	#0,skip
	add.b	d5,d4
	ADD.b	d4,h_motion
	cmp.b	#36,h_motion
	bhs	other_way
	rts
other_way
	add.b	#1,skip_2
	cmp.b	#1,skip_2
	bgt	negate
	add.b	#6,d3
	neg	d4
	add.b	d3,m_vstart_reduction
	move.l	#0,d7
	move.b	d3,d7
	mulu	#40,d7
	add.l	d7,missile_reduction
	rts
negate	
	neg	d4
	CMP.B	#68,H_MOTION
	bhs	back
	rts
back
	move.b	#6,d3
	add.b	d3,m_vstart_reduction
	move.l	#0,d7
	move.b	d3,d7
	mulu	#40,d7
	add.l	d7,missile_reduction
	move.b	#0,h_motion
	move.b	#0,skip_2
	rts
	
move_alien2
	move.l	sprite2adr,spriteadr
	cmp.b	#1,hit_alien_1
	blt	miss_out_2
	add.b	#1,alien_1_explosion
	cmp.b	#10,alien_1_explosion
	ble	explosion_2.3
	move.b	#15,alien_1_explosion
	bsr	remove_from_display_
	rts
miss_out_2
	move.b	#1,alien_number
	move.l	sprite2adr,spriteadr
	add.b	d3,vstart2
	add.b	d4,hstart2
	add.b	d3,vstop2
	move.b	vstart2,vstart
	move.b	hstart2,hstart
	move.b	vstop2,vstop
	move.b	attach2,attach
	bsr	anim_aliens
	rts
move_alien2.1
	move.l	sprite2.1adr,spriteadr
	cmp.b	#1,hit_alien_2
	blt	miss_out_2.1
	add.b	#1,alien_2_explosion
	cmp.b	#10,alien_2_explosion
	ble	explosion_2.3
	move.b	#15,alien_2_explosion
	bsr	remove_from_display_2
	rts
miss_out_2.1
	move.b	#2,alien_number
	move.l	sprite2.1adr,spriteadr
	add.b	d3,vstart2.1
	add.b	d4,hstart2.1
	add.b	d3,vstop2.1
	move.b	vstart2.1,vstart
	move.b	hstart2.1,hstart
	move.b	vstop2.1,vstop
	move.b	attach2.1,attach
	bsr	anim_aliens_2
	rts
move_alien2.2
	move.l	sprite2.2adr,spriteadr
	cmp.b	#1,hit_alien_13
	blt	miss_out_2.2
	add.b	#1,alien_13_explosion
	cmp.b	#10,alien_13_explosion
	ble	explosion_2.3
	move.b	#15,alien_13_explosion
	bsr	remove_from_display_3
	rts
miss_out_2.2
	move.b	#13,alien_number
	move.l	sprite2.2adr,spriteadr
	add.b	d3,vstart2.2
	add.b	d4,hstart2.2
	add.b	d3,vstop2.2
	move.b	vstart2.2,vstart
	move.b	hstart2.2,hstart
	move.b	vstop2.2,vstop
	move.b	attach2.2,attach
	bsr	anim_aliens_3
	rts
move_alien2.3
	move.l	sprite2.3adr,spriteadr
	cmp.b	#1,hit_alien_19
	blt	miss_out_2.3
	add.b	#1,alien_19_explosion
	cmp.b	#10,alien_19_explosion
	ble	explosion_2.3
	move.b	#15,alien_19_explosion
	bsr	remove_from_display_4	
	rts
miss_out_2.3
	move.b	#19,alien_number
	move.l	sprite2.3adr,spriteadr
	add.b	d3,vstart2.3
	add.b	d4,hstart2.3
	add.b	d3,vstop2.3
	move.b	vstart2.3,vstart
	move.b	hstart2.3,hstart
	move.b	vstop2.3,vstop
	move.b	attach2.3,attach
	bsr	anim_aliens_4
	rts
move_alien3
	move.l	sprite3adr,spriteadr
	cmp.b	#1,hit_alien_3
	blt	miss_out_3
	add.b	#1,alien_3_explosion
	cmp.b	#10,alien_3_explosion
	ble	explosion_2.3
	move.b	#15,alien_3_explosion
	bsr	remove_from_display_
	rts
miss_out_3
	move.b	#3,alien_number
	move.l	sprite3adr,spriteadr
	add.b	d3,vstart3
	add.b	d4,hstart3
	add.b	d3,vstop3
	move.b	vstart3,vstart
	move.b	hstart3,hstart
	move.b	vstop3,vstop
	move.b	attach3,attach
	bsr	anim_aliens
	rts
move_alien3.1
	move.l	sprite3.1adr,spriteadr
	cmp.b	#1,hit_alien_4
	blt	miss_out_4
	add.b	#1,alien_4_explosion
	cmp.b	#10,alien_4_explosion
	ble	explosion_2.3
	move.b	#15,alien_4_explosion
	bsr	remove_from_display_2
	rts
miss_out_4
	move.b	#4,alien_number
	move.l	sprite3.1adr,spriteadr
	add.b	d3,vstart3.1
	add.b	d4,hstart3.1
	add.b	d3,vstop3.1
	move.b	vstart3.1,vstart
	move.b	hstart3.1,hstart
	move.b	vstop3.1,vstop
	move.b	attach3.1,attach
	bsr	anim_aliens_2
	rts
move_alien3.2
	move.l	sprite3.2adr,spriteadr
	cmp.b	#1,hit_alien_14
	blt	miss_out_14
	add.b	#1,alien_14_explosion
	cmp.b	#10,alien_14_explosion
	ble	explosion_2.3
	move.b	#15,alien_14_explosion
	bsr	remove_from_display_3
	rts
miss_out_14
	move.b	#14,alien_number
	move.l	sprite3.2adr,spriteadr
	add.b	d3,vstart3.2
	add.b	d4,hstart3.2
	add.b	d3,vstop3.2
	move.b	vstart3.2,vstart
	move.b	hstart3.2,hstart
	move.b	vstop3.2,vstop
	move.b	attach3.2,attach
	bsr	anim_aliens_3
	rts
move_alien3.3
	move.l	sprite3.3adr,spriteadr
	cmp.b	#1,hit_alien_20
	blt	miss_out_20
	add.b	#1,alien_20_explosion
	cmp.b	#10,alien_20_explosion
	ble	explosion_2.3
	move.b	#15,alien_20_explosion
	bsr	remove_from_display_4	
	rts
miss_out_20
	move.b	#20,alien_number
	move.l	sprite3.3adr,spriteadr
	add.b	d3,vstart3.3
	add.b	d4,hstart3.3
	add.b	d3,vstop3.3
	move.b	vstart3.3,vstart
	move.b	hstart3.3,hstart
	move.b	vstop3.3,vstop
	move.b	attach3.3,attach
	bsr	anim_aliens_4
	rts
move_alien4
	move.l	sprite4adr,spriteadr
	cmp.b	#1,hit_alien_5
	blt	miss_out_5
	add.b	#1,alien_5_explosion
	cmp.b	#10,alien_5_explosion
	ble	explosion_2.3
	move.b	#15,alien_5_explosion
	bsr	remove_from_display_
	rts
miss_out_5
	move.b	#5,alien_number
	move.l	sprite4adr,spriteadr
	add.b	d3,vstart4
	add.b	d4,hstart4
	add.b	d3,vstop4
	move.b	vstart4,vstart
	move.b	hstart4,hstart
	move.b	vstop4,vstop
	move.b	attach4,attach
	bsr	anim_aliens
	rts
move_alien4.1
	move.l	sprite4.1adr,spriteadr
	cmp.b	#1,hit_alien_6
	blt	miss_out_6
	add.b	#1,alien_6_explosion
	cmp.b	#10,alien_6_explosion
	ble	explosion_2.3
	move.b	#15,alien_6_explosion
	bsr	remove_from_display_2
	rts
miss_out_6
	move.b	#6,alien_number
	move.l	sprite4.1adr,spriteadr
	add.b	d3,vstart4.1
	add.b	d4,hstart4.1
	add.b	d3,vstop4.1
	move.b	vstart4.1,vstart
	move.b	hstart4.1,hstart
	move.b	vstop4.1,vstop
	move.b	attach4.1,attach
	bsr	anim_aliens_2
	rts
move_alien4.2
	move.l	sprite4.2adr,spriteadr
	cmp.b	#1,hit_alien_15
	blt	miss_out_15
	add.b	#1,alien_15_explosion
	cmp.b	#10,alien_15_explosion
	ble	explosion_2.3
	move.b	#15,alien_15_explosion
	bsr	remove_from_display_3
	rts
miss_out_15
	move.b	#15,alien_number
	move.l	sprite4.2adr,spriteadr
	add.b	d3,vstart4.2
	add.b	d4,hstart4.2
	add.b	d3,vstop4.2
	move.b	vstart4.2,vstart
	move.b	hstart4.2,hstart
	move.b	vstop4.2,vstop
	move.b	attach4.2,attach
	bsr	anim_aliens_3
	rts
move_alien4.3
	move.l	sprite4.3adr,spriteadr
	cmp.b	#1,hit_alien_21
	blt	miss_out_21
	add.b	#1,alien_21_explosion
	cmp.b	#10,alien_21_explosion
	ble	explosion_2.3
	move.b	#15,alien_21_explosion
	bsr	remove_from_display_4	
	rts
miss_out_21
	move.b	#21,alien_number
	move.l	sprite4.3adr,spriteadr
	add.b	d3,vstart4.3
	add.b	d4,hstart4.3
	add.b	d3,vstop4.3
	move.b	vstart4.3,vstart
	move.b	hstart4.3,hstart
	move.b	vstop4.3,vstop
	move.b	attach4.3,attach
	bsr	anim_aliens_4
	rts
move_alien5
	move.l	sprite5adr,spriteadr
	cmp.b	#1,hit_alien_7
	blt	miss_out_7
	add.b	#1,alien_7_explosion
	cmp.b	#10,alien_7_explosion
	ble	explosion_2.3
	move.b	#15,alien_7_explosion
	bsr	remove_from_display_
	rts
miss_out_7
	move.b	#7,alien_number
	move.l	sprite5adr,spriteadr
	add.b	d3,vstart5
	add.b	d4,hstart5
	add.b	d3,vstop5
	move.b	vstart5,vstart
	move.b	hstart5,hstart
	move.b	vstop5,vstop
	move.b	attach5,attach
	bsr	anim_aliens
	rts
move_alien5.1
	move.l	sprite5.1adr,spriteadr
	cmp.b	#1,hit_alien_8
	blt	miss_out_8
	add.b	#1,alien_8_explosion
	cmp.b	#10,alien_8_explosion
	ble	explosion_2.3
	move.b	#15,alien_8_explosion
	bsr	remove_from_display_2
	rts
miss_out_8
	move.b	#8,alien_number
	move.l	sprite5.1adr,spriteadr
	add.b	d3,vstart5.1
	add.b	d4,hstart5.1
	add.b	d3,vstop5.1
	move.b	vstart5.1,vstart
	move.b	hstart5.1,hstart
	move.b	vstop5.1,vstop
	move.b	attach5.1,attach
	bsr	anim_aliens_2
	rts
move_alien5.2
	move.l	sprite5.2adr,spriteadr
	cmp.b	#1,hit_alien_16
	blt	miss_out_16
	add.b	#1,alien_16_explosion
	cmp.b	#10,alien_16_explosion
	ble	explosion_2.3
	move.b	#15,alien_16_explosion
	bsr	remove_from_display_3
	rts
miss_out_16
	move.b	#16,alien_number
	move.l	sprite5.2adr,spriteadr
	add.b	d3,vstart5.2
	add.b	d4,hstart5.2
	add.b	d3,vstop5.2
	move.b	vstart5.2,vstart
	move.b	hstart5.2,hstart
	move.b	vstop5.2,vstop
	move.b	attach5.2,attach
	bsr	anim_aliens_3
	rts
move_alien5.3
	move.l	sprite5.3adr,spriteadr
	cmp.b	#1,hit_alien_22
	blt	miss_out_22
	add.b	#1,alien_22_explosion
	cmp.b	#10,alien_22_explosion
	ble	explosion_2.3
	move.b	#15,alien_22_explosion
	bsr	remove_from_display_4	
	rts
miss_out_22
	move.b	#22,alien_number
	move.l	sprite5.3adr,spriteadr
	add.b	d3,vstart5.3
	add.b	d4,hstart5.3
	add.b	d3,vstop5.3
	move.b	vstart5.3,vstart
	move.b	hstart5.3,hstart
	move.b	vstop5.3,vstop
	move.b	attach5.3,attach
	bsr	anim_aliens_4
	rts
move_alien6
	move.l	sprite6adr,spriteadr
	cmp.b	#1,hit_alien_9
	blt	miss_out_9
	add.b	#1,alien_9_explosion
	cmp.b	#10,alien_9_explosion
	ble	explosion_2.3
	move.b	#15,alien_9_explosion
	bsr	remove_from_display_
	rts
miss_out_9
	move.b	#9,alien_number
	add.b	d3,vstart6
	add.b	d4,hstart6
	add.b	d3,vstop6
	move.b	vstart6,vstart
	move.b	hstart6,hstart
	move.b	vstop6,vstop
	move.b	attach6,attach
	bsr	anim_aliens
	rts
move_alien6.1
	move.l	sprite6.1adr,spriteadr
	cmp.b	#1,hit_alien_10
	blt	miss_out_10
	add.b	#1,alien_10_explosion
	cmp.b	#10,alien_10_explosion
	ble	explosion_2.3
	move.b	#15,alien_10_explosion
	bsr	remove_from_display_2
	rts
miss_out_10
	move.b	#10,alien_number
	add.b	d3,vstart6.1
	add.b	d4,hstart6.1
	add.b	d3,vstop6.1
	move.b	vstart6.1,vstart
	move.b	hstart6.1,hstart
	move.b	vstop6.1,vstop
	move.b	attach6.1,attach
	bsr	anim_aliens_2
	rts
move_alien6.2
	move.l	sprite6.2adr,spriteadr
	cmp.b	#1,hit_alien_17
	blt	miss_out_17
	add.b	#1,alien_17_explosion
	cmp.b	#10,alien_17_explosion
	ble	explosion_2.3
	move.b	#15,alien_17_explosion
	bsr	remove_from_display_3
	rts
miss_out_17
	move.b	#17,alien_number
	add.b	d3,vstart6.2
	add.b	d4,hstart6.2
	add.b	d3,vstop6.2
	move.b	vstart6.2,vstart
	move.b	hstart6.2,hstart
	move.b	vstop6.2,vstop
	move.b	attach6.2,attach
	bsr	anim_aliens_3
	rts
move_alien6.3
	move.l	sprite6.3adr,spriteadr
	cmp.b	#1,hit_alien_23
	blt	miss_out_23
	add.b	#1,alien_23_explosion
	cmp.b	#10,alien_23_explosion
	ble	explosion_2.3
	move.b	#15,alien_23_explosion
	bsr	remove_from_display_4	
	rts
miss_out_23
	move.b	#23,alien_number
	add.b	d3,vstart6.3
	add.b	d4,hstart6.3
	add.b	d3,vstop6.3
	move.b	vstart6.3,vstart
	move.b	hstart6.3,hstart
	move.b	vstop6.3,vstop
	move.b	attach6.3,attach
	bsr	anim_aliens_4
	rts
move_alien7
	move.l	sprite7adr,spriteadr
	cmp.b	#1,hit_alien_11
	blt	miss_out_11
	add.b	#1,alien_11_explosion
	cmp.b	#10,alien_11_explosion
	ble	explosion_2.3
	move.b	#15,alien_11_explosion
	bsr	remove_from_display_
	rts
miss_out_11
	move.b	#11,alien_number
	add.b	d3,vstart7
	add.b	d4,hstart7
	add.b	d3,vstop7
	move.b	vstart7,vstart
	move.b	hstart7,hstart
	move.b	vstop7,vstop
	move.b	attach7,attach
	bsr	anim_aliens
	rts
move_alien7.1
	move.l	sprite7.1adr,spriteadr
	cmp.b	#1,hit_alien_12
	blt	miss_out_12
	add.b	#1,alien_12_explosion
	cmp.b	#10,alien_12_explosion
	ble	explosion_2.3
	move.b	#15,alien_12_explosion
	bsr	remove_from_display_2
	rts
miss_out_12
	move.b	#12,alien_number
	add.b	d3,vstart7.1
	add.b	d4,hstart7.1
	add.b	d3,vstop7.1
	move.b	vstart7.1,vstart
	move.b	hstart7.1,hstart
	move.b	vstop7.1,vstop
	move.b	attach7.1,attach
	bsr	anim_aliens_2
	rts
move_alien7.2
	move.l	sprite7.2adr,spriteadr
	cmp.b	#1,hit_alien_18
	blt	miss_out_18
	add.b	#1,alien_18_explosion
	cmp.b	#10,alien_18_explosion
	ble	explosion_2.3
	move.b	#15,alien_18_explosion
	bsr	remove_from_display_3
	rts
miss_out_18
	move.b	#18,alien_number
	add.b	d3,vstart7.2
	add.b	d4,hstart7.2
	add.b	d3,vstop7.2
	move.b	vstart7.2,vstart
	move.b	hstart7.2,hstart
	move.b	vstop7.2,vstop
	move.b	attach7.2,attach
	bsr	anim_aliens_3
	rts
move_alien7.3
	move.l	sprite7.3adr,spriteadr
	cmp.b	#1,hit_alien_24
	blt	miss_out_24
	add.b	#1,alien_24_explosion
	cmp.b	#10,alien_24_explosion
	ble	explosion_2.3
	move.b	#15,alien_24_explosion
	bsr	remove_from_display_4	
	rts
miss_out_24
	move.b	#24,alien_number
	add.b	d3,vstart7.3
	add.b	d4,hstart7.3
	add.b	d3,vstop7.3
	move.b	vstart7.3,vstart
	move.b	hstart7.3,hstart
	move.b	vstop7.3,vstop
	move.b	attach7.3,attach
	bsr	anim_aliens_4
	rts
anim_aliens
	move.l	spriteadr,a0
	move.b	vstart,(a0)+
	move.b	hstart,(a0)+
	move.b	vstop,(a0)+
	move.b	attach,(a0)+
	move.b	vstop,vstop_test
	move.b	hstart,h_test
	bsr	test_collision
	move.w	#spritesize2/4-1,d2
	move.l	galax_base,a3
	add.b	#1,anim.delay_2
	cmp.b	#60,anim.delay_2
	bge	animation.2
transfer_2
	move.l	(a3)+,(a0)+
	dbf	d2,transfer_2	
	rts
animation.2
	LEA	galax2,a3
transfer.2.1
	move.l	(a3)+,(a0)+
	dbf	d2,transfer.2.1	
	add.b	#1,anim.delay_2.2
	cmp.b	#60,anim.delay_2.2
	bge	delay_2
	rts
delay_2
	move.b	#0,anim.delay_2
	move.b	#0,anim.delay_2.2
	rts
anim_aliens_2
	move.l	spriteadr,a0
	move.b	vstart,(a0)+
	move.b	hstart,(a0)+
	move.b	vstop,(a0)+
	move.b	attach,(a0)+
	move.b	vstop,vstop_test
	move.b	hstart,h_test
	bsr	test_collision
	move.w	#spritesize2/4-1,d2
	lea	galax1,a3
	add.b	#1,anim.delay_2.4
	cmp.b	#60,anim.delay_2.4
	bge	animation.2.3
transfer_2.4
	move.l	(a3)+,(a0)+
	dbf	d2,transfer_2.4	
	rts
animation.2.3
	LEA	galax2,a3
transfer.2.3
	move.l	(a3)+,(a0)+
	dbf	d2,transfer.2.3	
	add.b	#1,anim.delay_2.3
	cmp.b	#60,anim.delay_2.3
	bge	delay_2.2
	rts
delay_2.2
	move.b	#0,anim.delay_2.3
	move.b	#0,anim.delay_2.4
	rts
anim_aliens_3
	move.l	spriteadr,a0
	move.b	vstart,(a0)+
	move.b	hstart,(a0)+
	move.b	vstop,(a0)+
	move.b	attach,(a0)+
	move.b	vstop,vstop_test
	move.b	hstart,h_test
	bsr	test_collision
	move.w	#spritesize2/4-1,d2
	move.l	galax_base,a3
	add.b	#1,anim.delay_2.5
	cmp.b	#60,anim.delay_2.5
	bge	animation.2.6
transfer_2.5
	move.l	(a3)+,(a0)+
	dbf	d2,transfer_2.5
	rts
animation.2.6
	LEA	galax2,a3
transfer.2.6
	move.l	(a3)+,(a0)+
	dbf	d2,transfer.2.6	
	add.b	#1,anim.delay_2.6
	cmp.b	#60,anim.delay_2.6
	bge	delay_2.6
	rts
delay_2.6
	move.b	#0,anim.delay_2.5
	move.b	#0,anim.delay_2.6
	rts
anim_aliens_4
	move.l	spriteadr,a0
	move.b	vstart,(a0)+
	move.b	hstart,(a0)+
	move.b	vstop,(a0)+
	move.b	attach,(a0)+
	move.b	vstop,vstop_test
	move.b	hstart,h_test
	bsr	test_collision
	move.w	#spritesize2/4-1,d2
	move.l	galax_base,a3
	add.b	#1,anim.delay_2.7
	cmp.b	#60,anim.delay_2.7
	bge	animation.2.7
transfer_2.7
	move.l	(a3)+,(a0)+
	dbf	d2,transfer_2.7
	rts
animation.2.7
	LEA	galax2,a3
transfer.2.8
	move.l	(a3)+,(a0)+
	dbf	d2,transfer.2.8	
	add.b	#1,anim.delay_2.8
	cmp.b	#60,anim.delay_2.8
	bge	delay_2.3
	rts
delay_2.3
	move.b	#0,anim.delay_2.7
	move.b	#0,anim.delay_2.8
	rts
adjust_playfield
	lea	top_planes,a0
	move.l	bit_base,d7
	sub.w	#40,d7
	move.l	d7,bit_base
	move.w	d7,6(a0)
	swap	d7
	move.w	d7,2(a0)
	swap	d7
	LEA	8(a0),a0
	move.l	bit_base_2,d5
	sub.w	#40,d5
	move.l	d5,bit_base_2
	move.w	d5,6(a0)
	swap	d5
	move.w	d5,2(a0)
	swap	d5
	addi	#1,d6
	cmpi	#200,d6
	bge	reset
	rts
reset
	MOVE.l	#0,d6
	move.l	#m_base+8000,bit_base
	move.l	#m_base+16000+8000,bit_base_2
	rts
setup_blit
	;move.w	(a5)+,d7
	;lea	(a4,D7),a4
	move.l	scroll_base_2,a4
	move.l	TEMP_BASE,a0
	moveq	#0,d0
	move.L	#0,d1
	MOVE.L	#$ffffffff,D4
	move.l	#$09f00000,d2
	move.L	#(1*64)+20,d3
	lea	custom,a6	
	move.w	#1,d7
bb_loop
	bsr	stuff_blitter
	lea	planesize(a0),a0
	lea	blit_data_size(a4),a4
	dbra	d7,bb_loop
	lea	-blit_data_size(a4),a4
	lea	-blit_data_size(a4),a4
	sub.L	#1*40,TEMP_BASE
	ADDI	#1,COUNT
	CMPI	#200,COUNT
	BGE	RE_BUILD
	rts
stuff_blitter
wfblit1
	btst	#6,dmaconr(a6)
	bne.s	wfblit1
	move.l	a4,bltapt(a6)
	move.l	a0,bltdpt(a6)
	move.w	d0,bltamod(a6)
	move.w	d1,bltdmod(a6)
	move.l	d2,bltcon0(a6)
	move.l	d4,bltafwm(a6)
	move.w	d3,bltsize(a6)
	rts
re_build
	move.l	#m_base+8000,temp_base
	move.w	#0,count
	rts
setup_blit_2
	move.l	TEMP_base_2,a0
	moveq	#0,d0
	move.L	#0,d1
	MOVE.L	#$FFffffFF,D4
	move.l	#$09f00000,d2
	move.L	#(1*64)+20,d3
	lea	custom,a6	
	move.w	#1,d7
bb_loop_2
	bsr	stuff_blitter_2
	lea	planesize(a0),a0
	lea	blit_data_size(a4),a4
	dbra	d7,bb_loop_2
	lea	-blit_data_size(a4),a4
	lea	-blit_data_size(a4),a4
	sub.L	#1*40,TEMP_BASE_2
	ADDI	#1,COUNT_2
	CMPI	#200,COUNT_2
	BGE	RE_BUILD_2
	lea	1*40(a4),a4
	move.l	a4,scroll_base_2
	move.l	scroll_base_2,d7
	rts
stuff_blitter_2
wfblit1_2
	btst	#6,dmaconr(a6)
	bne.s	wfblit1_2
	move.l	a4,bltapt(a6)
	move.l	a0,bltdpt(a6)
	move.w	d0,bltamod(a6)
	move.w	d1,bltdmod(a6)
	move.l	d2,bltcon0(a6)
	move.l	d4,bltafwm(a6)
	move.w	d3,bltsize(a6)
	rts
re_build_2
	move.l	#m_base+16000,temp_base_2
	move.w	#0,count_2
	addi	#1,counter
	cmpi	#3,counter
	bge	re_set
	rts
re_set
	move.w	#0,counter
	lea	block,a4
	MOVE.L	A4,SCROLL_BASE_2
	;lea	map_1,a5
	rts

alien_2_vpath
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,$f0
alien_2_hpath
	DC.B	2,0,0,0,0,2,0,0,0,0,2,0,0,0,0,2,0,0,0,0,2,0,0,0,0,2,0,0,0,0,2,0,0,0,0
	dc.b	2,0,0,0,0,2,0,0,0,0,2,0,0,0,0,2,0,0,0,0,2,0,0,0,0
	dc.b	-2,0,0,0,0,-2,0,0,0,0,-2,0,0,0,0,-2,0,0,0,0,-2,0,0,0,0,-2,0,0,0,0
	dc.b	-2,0,0,0,0,-2,0,0,0,0,-2,0,0,0,0,-2,0,0,0,0,-2,0,0,0,0,-2,0,0,0,0,0,0

	even
gfxlib	dc.b	"graphics.library",0
	even
_gfxbase	dc.l	0
base_2		dc.l	0
membase		dc.l	0
oldcop		dc.l	0
bit_BASE	dc.L	0
bit_base_2	dc.l	0
TEMP_BASE	dc.L	0
TEMP_BASE_2	dc.L	0
cop2adr		dc.l	0
playfield2adr	dc.l	0
scroll_base_2	dc.l	0
missile_base	dc.l	0
missile_base_1	dc.l	0
missile_base_11.2	dc.l	0
missile_base_1.1	dc.l	0
missile_base_21.1	dc.l	0
missile_base_2	dc.l	0
missile_base_21.2	dc.l	0
missile_base_3	dc.l	0
missile_base_3.1	dc.l	0
missile_base_4	dc.l	0
missile_base_4.1	dc.l	0
missile_base_5	dc.l	0
missile_base_5.1	dc.l	0
missile_base_6	dc.l	0
missile_base_6.1	dc.l	0
galax_base	dc.l	0
alien_2_vtrack	dc.l	0
alien_2_htrack	dc.l	0
count		dc.w	0
countER		dc.w	0
count_2		dc.w	0
count_3		dc.w	0
count_4		dc.w	0
count_5		dc.w	0
count_6		dc.w	0
count_7		dc.w	0
count_8		dc.w	0
count_9		dc.w	0
scount		dc.w	0
hstart2.2_inc	dc.w	0
temp		dc.l	0
spriteadr	dc.l	0
sprite0adr	dc.l	0
sprite1adr	dc.l	0
sprite2adr	dc.l	0
sprite2.1adr	dc.l	0
sprite2.2adr	dc.l	0
sprite2.3adr	dc.l	0
sprite3adr	dc.l	0
sprite3.1adr	dc.l	0
sprite3.2adr	dc.l	0
sprite3.3adr	dc.l	0
sprite4adr	dc.l	0
sprite4.1adr	dc.l	0
sprite4.2adr	dc.l	0
sprite4.3adr	dc.l	0
sprite5adr	dc.l	0
sprite5.1adr	dc.l	0
sprite5.2adr	dc.l	0
sprite5.3adr	dc.l	0
sprite6adr	dc.l	0
sprite6.1adr	dc.l	0
sprite6.2adr	dc.l	0
sprite6.3adr	dc.l	0
sprite7adr	dc.l	0
sprite7.1adr	dc.l	0
sprite7.2adr	dc.l	0
sprite7.3adr	dc.l	0
missile_reduction	dc.l	0
vstart		dc.b	0
hstart		dc.b	0
vstop		dc.b	0
attach		dc.b	0
vstart0		dc.b	0
hstart0		dc.b	0
vstop0		dc.b	0
attach0		dc.b	0
vstart1		dc.b	0
hstart1		dc.b	0
vstop1		dc.b	0
attach1		dc.b	0
vstart2		dc.b	0
hstart2		dc.b	0
vstop2		dc.b	0
attach2		dc.b	0
vstart2.1	dc.b	0
hstart2.1	dc.b	0
vstop2.1	dc.b	0
attach2.1	dc.b	0
vstart2.2	dc.b	0
hstart2.2	dc.b	0
vstop2.2	dc.b	0
attach2.2	dc.b	0
vstart2.3	dc.b	0
hstart2.3	dc.b	0
vstop2.3	dc.b	0
attach2.3	dc.b	0
vstart3		dc.b	0
hstart3		dc.b	0
vstop3		dc.b	0
attach3		dc.b	0
vstart3.1	dc.b	0
hstart3.1	dc.b	0
vstop3.1	dc.b	0
attach3.1	dc.b	0
vstart3.2	dc.b	0
hstart3.2	dc.b	0
vstop3.2	dc.b	0
attach3.2	dc.b	0
vstart3.3	dc.b	0
hstart3.3	dc.b	0
vstop3.3	dc.b	0
attach3.3	dc.b	0
vstart4		dc.b	0
hstart4		dc.b	0
vstop4		dc.b	0
attach4		dc.b	0
vstart4.1	dc.b	0
hstart4.1	dc.b	0
vstop4.1	dc.b	0
attach4.1	dc.b	0
vstart4.2	dc.b	0
hstart4.2	dc.b	0
vstop4.2	dc.b	0
attach4.2	dc.b	0
vstart4.3	dc.b	0
hstart4.3	dc.b	0
vstop4.3	dc.b	0
attach4.3	dc.b	0
vstart5		dc.b	0
hstart5		dc.b	0
vstop5		dc.b	0
attach5		dc.b	0
vstart5.1	dc.b	0
hstart5.1	dc.b	0
vstop5.1	dc.b	0
attach5.1	dc.b	0
vstart5.2	dc.b	0
hstart5.2	dc.b	0
vstop5.2	dc.b	0
attach5.2	dc.b	0
vstart5.3	dc.b	0
hstart5.3	dc.b	0
vstop5.3	dc.b	0
attach5.3	dc.b	0
vstart6		dc.b	0
hstart6		dc.b	0
vstop6		dc.b	0
attach6		dc.b	0
vstart6.1	dc.b	0
hstart6.1	dc.b	0
vstop6.1	dc.b	0
attach6.1	dc.b	0
vstart6.2	dc.b	0
hstart6.2	dc.b	0
vstop6.2	dc.b	0
attach6.2	dc.b	0
vstart6.3	dc.b	0
hstart6.3	dc.b	0
vstop6.3	dc.b	0
attach6.3	dc.b	0
vstart7		dc.b	0
hstart7		dc.b	0
vstop7		dc.b	0
attach7		dc.b	0
vstart7.1	dc.b	0
hstart7.1	dc.b	0
vstop7.1	dc.b	0
attach7.1	dc.b	0
vstart7.2	dc.b	0
hstart7.2	dc.b	0
vstop7.2	dc.b	0
attach7.2	dc.b	0
vstart7.3	dc.b	0
hstart7.3	dc.b	0
vstop7.3	dc.b	0
attach7.3	dc.b	0
anim.delay	dc.b	0
anim.delay.1	dc.b	0
anim.delay_2	dc.b	0
anim.delay_2.2	dc.b	0
anim.delay_2.3	dc.b	0
anim.delay_2.4	dc.b	0
anim.delay_2.5	dc.b	0
anim.delay_2.6	dc.b	0
anim.delay_2.7	dc.b	0
anim.delay_10	dc.b	0
anim.delay_11	dc.b	0
anim.delay_2.8	dc.b	0
hit_alien	dc.b	0 
kill_count	dc.b	0
test		dc.b	$f0
vstop_test	dc.b	0
h_test		dc.b	0
hstart_motion	dc.b	0
alien_number	dc.b	0
	even
hit_alien_1	dc.b	0
hit_alien_2	dc.b	0
hit_alien_3	dc.b	0
hit_alien_4	dc.b	0
hit_alien_5	dc.b	0
hit_alien_6	dc.b	0
hit_alien_7	dc.b	0
hit_alien_8	dc.b	0
hit_alien_9	dc.b	0
hit_alien_10	dc.b	0
hit_alien_11	dc.b	0
hit_alien_12	dc.b	0
hit_alien_13	DC.B	0
hit_alien_14	dc.b	0
hit_alien_15	dc.b	0
hit_alien_16	DC.B	0
hit_alien_17	dc.b	0
hit_alien_18	DC.B	0
hit_alien_19	DC.B	0
hit_alien_20	DC.B	0
hit_alien_21	DC.B	0
hit_alien_22	DC.B	0
hit_alien_23	DC.B	0
hit_alien_24	DC.B	0
missile_no	dc.b	0
fire_missile_1	dc.b	0
fire_missile_1.1	dc.b	0
fire_missile_2	dc.b	0
fire_missile_2.1	dc.b	0
fire_missile_3	dc.b	0
fire_missile_4	dc.b	0
fire_missile_5	dc.b	0
fire_missile_6	dc.b	0
clock		dc.b	0
lives		dc.b	0
keep_track	dc.b	0
missile_1	dc.b	0
m_vstart	dc.b	0
m_hstart	dc.b	0
m_vstart1	dc.b	0
m_hstart1	dc.b	0
m_vstart1.1	dc.b	0
m_hstart1.1	dc.b	0
m_vstart2	dc.b	0
m_hstart2	dc.b	0
m_vstart2.1	dc.b	0
m_hstart2.1	dc.b	0
m_vstart3	dc.b	0
m_hstart3	dc.b	0
m_vstart4	dc.b	0
m_hstart4	dc.b	0
m_vstart5	dc.b	0
m_hstart5	dc.b	0
m_vstart6	dc.b	0
m_hstart6	dc.b	0
	even
alien_1_explosion	DC.B	0
alien_2_explosion	DC.B	0
alien_3_explosion	DC.B	0
alien_4_explosion	DC.B	0
alien_5_explosion	DC.B	0
alien_6_explosion	DC.B	0
alien_7_explosion	DC.B	0
alien_8_explosion	dc.b	0
alien_9_explosion	DC.B	0
alien_10_explosion	dc.b	0
alien_11_explosion	DC.B	0
alien_12_explosion	dc.b	0
alien_13_explosion	DC.B	0
alien_14_explosion	DC.B	0
alien_15_explosion	DC.B	0
alien_16_explosion	DC.B	0
alien_17_explosion	DC.B	0
alien_18_explosion	DC.B	0
alien_19_explosion	DC.B	0
alien_20_explosion	dc.b	0
alien_21_explosion	DC.B	0
alien_22_explosion	dc.b	0
alien_23_explosion	DC.B	0
alien_24_explosion	dc.b	0
m_vstart_reduction	dc.b	0
h_motion	dc.b	0
skip	dc.b	0
skip_2	dc.b	0
	even
	SECTION		CHIPSTUFF,DATA_C

block		incbin	Source:BlainesGame/star_drop_800
panel		incbin	Source:BlainesGame/bottom_panel_2
ship_data0	include	Source:BlainesGame/ship_data1.s
gameover	incbin	Source:BlainesGame/game_over
intro		incbin	Source:BlainesGame/intro_screen
you_win		incbin	Source:BlainesGame/you_win_1
score0
	dc.w	$0000,$0000,$3c3c,$3c3c,$6666,$6666,$6e6e,$6e6e
	dc.w	$7e7e,$7e7e,$7676,$7676,$6666,$6666,$3c3c,$3c3c
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
number_10
	dc.w	$0000,$183c,$3866,$186e,$187e,$1876,$1866,$7e3c
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
number_20
	dc.w	$0000,$3c3c,$6666,$066e,$1c7e,$3076,$6066,$7e3c
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
number_30
	dc.w	$0000,$3c3c,$6666,$066e,$1c7e,$0676,$6666,$3c3c
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
number_40
	dc.w	$0000,$1c3c,$3c66,$6c6e,$cc7e,$fe76,$0c66,$1e3c
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
number_50
	dc.w	$0000,$7e3c,$6066,$7c6e,$067e,$0676,$6666,$3c3c
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
number_60
	dc.w	$0000,$1c3c,$3066,$606e,$7c7e,$6676,$6666,$3c3c
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
number_70
	dc.w	$0000,$7e3c,$6666,$066e,$0c7e,$1876,$1866,$183c
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
number_80
	dc.w	$0000,$3c3c,$6666,$666e,$3c7e,$6676,$6666,$3c3c
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
number_90
	dc.w	$0000,$3c3c,$6666,$666e,$3e7e,$0676,$0c66,$383c
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
number_00
	dc.w	$0000,$3c3c,$6666,$6e6e,$7e7e,$7676,$6666,$3c3c
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
number_01
	dc.w	$0000,$3c18,$6638,$6e18,$7e18,$7618,$6618,$3c7e
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
number_02
	dc.w	$0000,$3c3c,$6666,$6e06,$7e1c,$7630,$6660,$3c7e
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
lives3	
	dc.w	$0000,$003c,$0066,$0006,$001c,$0006,$0066,$003c
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
lives2
	dc.w	$0000,$003c,$0066,$0006,$001c,$0030,$0060,$007e
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
lives1
	dc.w	$0000,$0018,$0038,$0018,$0018,$0018,$0018,$007e
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
lives0
	dc.w	$0000,$003c,$0066,$006e,$007e,$0076,$0066,$003c
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
intro_colors
	dc.w	$0000,$0fff
	dc.w	$0f00,$0f80
game_colors
	dc.w	$0000,$0f0f
	dc.w	$0e17,$008f
split_screen
	dc.w	$db01,$ff00
	dc.w	$0100,%0010001000000000,$0102,$0000,$0104,$0024
newcop
	dc.w	$0100,%0100011000000000,$0102,$0000,$0104,$0024
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$008e,$2c81,$0090,$F4c0
top_planes
	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00f0,$0000,$00f2,$0000
bottom_planes
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f4,$0000,$00f6,$0000
sprites
	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

colors
	dc.w	$0180,$0000,$0182,$0f0f
	dc.w	$0184,$0e17,$0186,$008f
	dc.w	$0188,$0fF0,$018a,$0fff
	dc.w	$018c,$0840,$018e,$05c0
	dc.w	$0190,$0000,$0192,$008f
	dc.w	$0194,$0fff,$0196,$0f40
	dc.w	$0198,$00aa,$019a,$000f
	dc.w	$019c,$0c17,$019e,$0c7a

sprite_colors
	dc.w	$01a0,$000f,$01a2,$0f00
	dc.w	$01a4,$0ff0,$01a6,$006f
	dc.w	$01a8,$0f0f,$01aa,$0fff
	dc.w	$01ac,$0f70,$01ae,$0f00
	dc.w	$01b0,$046a,$01b2,$0fFF
	dc.w	$01b4,$0f70,$01b6,$0f00
	dc.w	$01b8,$0000,$01ba,$0fff
	dc.w	$01bc,$0f70,$01be,$0f00
SPLIT_2
	DS.W	8
copper2
	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$0180,$0000,$0182,$0fff
	dc.w	$0184,$0f00,$0186,$0f52
	dc.w	$ffff,$fffe
