
debug             set	1
Asm_Vdo_Mode	SET     0	* 0 Pal   1 Ntsc
Asm_Protect	SET	0

	OPT	o+,c-,w-,o3-
	SECTION	Chip,Code_c
	INCLUDE	WORK:Global/Preset.s


	SYSTEM_OFF

	lea	Custom-$e,a4

	wait_synch
	move.l	#%0000000111101111,dmacon+$e(a4)
	move.l	#id_cl,$80+$e(a4)
;	move.l	#id_cl,cop1lc_bak
	move	d0,copjmp1+$e(a4)

	clr.l	bpl1mod+$e(a4)
	ifne	asm_vdo_mode=0
	move.l	#$a0dda987,diwstrt+$e(a4)
	elseif
	move.l	#$62ff9441,diwstrt+$e(a4)
	endc
	move.l	#$006600a6,ddfstrt+$e(a4)

	move	#%0001001000000000,bplcon0+$e(a4)
	clr.l	bplcon1+$e(a4)

	move.l	#id_image,d0
	lea	id_clp+2,a1
	move	d0,4(a1)
	swap	d0
	move	d0,(a1)

	lea	id_image+14,a1		;ptr on bitmap
	lea	id_image+180,a2		;ptr on charset (1,2,3)
	move	i_d_num,d0
	mulu	#18,d0
	add	d0,a2
	moveq	#8,d0
.char_loop
	move.w	(a2)+,(a1)+
	add	#16,a1
	dbra	d0,.char_loop
	wait_synch
	move	#%1000001110000000,dmacon+$e(a4)

	WAIT_CLICK
	SYSTEM_ON
	rts

id_image
	incbin	WORK:Agony/Disk/insert_disk.bin
i_d_num
	dc.w    2

id_cl
	ifne	asm_protect=1
	anti_cartridge_cl
	endc
id_clp
	C_Move	0,$e0
	C_Move	0,$e2
          	C_Move	0,spr0data
          	C_Move	0,spr0datb
	C_Move	0,spr1data
	C_Move	0,spr1datb
	C_Move	0,spr2data
	C_Move	0,spr2datb
	C_Move	0,spr3data
	C_Move	0,spr3datb
	C_Move	0,spr4data
	C_Move	0,spr4datb
	C_Move	0,spr5data
	C_Move	0,spr5datb
	C_Move	0,spr6data
	C_Move	0,spr6datb
	C_Move	0,spr7data
 	C_Move	0,spr7datb
	C_Move	0,$180
	C_Move	$fff,$182
                  C_END




