;********************************************************
;*	ROUTINE chargement / ecriture DOS 		*
;*	a0=adresse chargement				*
;*	d0=pointeur track				*
;*	d1=longueur file				*
;*	d2=disque	0,1 ou 2			*
;*	d7=code						*
;********************************************************

debug	set	1
asm_absolute	set	0
asm_protect	set	0
asm_vdo_mode	set	0

	section	chip,code_c

	include	work:global/preset.s
	include	work:agony/disk/load.s

deb_dos:
	movem.l	d1-d7/a0-a6,-(a7)
	lea	info_buffer,a0	;adresse depart
	moveq	#-1,d1	;0=lecture/ff=ecriture
                  lea	$df0001,a4
	move.l	a4,d2
	eor.l	#dsynchro_val^$df0001,d2
	move.l	d2,dsynchro
	moveq	#1,d6	;recherche disk 2 (1)
	move.l	#48,d2	;longueur pour lecture
	move.l	a4,a3
	add	#$eff1,a4
	sub.l	#$1f0000,a3

deb_d1:
	move.l	a0,a5
	add.l	d2,a5
	move	d6,i_d_num
	movem.l	d0-d4/d6-d7/a0-a6,-(a7)
	jsr	init_0
	movem.l	(a7)+,d0-d4/d6-d7/a0-a6
	moveq	#$08,d3
deb_d2:	lea	position_track,a2
	jsr	position_sur_track_zero
	jsr	avance_track_suivant	;se positionne face dessous
	tst.l	d1
	bne.s	deb_d5
	jsr	lecture_dos
	tst.l	d0
	beq.s	deb_d3
	subq.l	#1,d3
	bne.s	deb_d2
	moveq	#-1,d0
	bra.s	deb_df
deb_d3:	jsr	decodage_dos
	tst.l	d0
	beq.s	deb_d4
	subq.l	#1,d3
	bne.s	deb_d2
	moveq	#-1,d0
	bra.s	deb_df
deb_d4:	moveq	#$00,d0
	bra.s	deb_df
deb_d5:
	btst	#3,$bfe001
	beq.s	deb_df
	jsr	lecture_dos
	tst.l	d0
	beq.s	deb_d6
	subq.l	#1,d3
	bne.s	deb_d2
	moveq	#-1,d0
	bra.s	deb_df
deb_d6:	jsr	codification_dos
	jsr	ecriture_dos
	moveq	#$00,d0
deb_df:	jsr	cloture_drives
	movem.l	(a7)+,d1-d7/a0-a6
	rts
;********************************************************
lecture_dos:
	movem.l	d1-d7/a0-a6,-(a7)
lect0:	lea	buffer_disk,a1
	move.l	a1,$20+$e(a4)
	move.w	#$8210,$96+$e(a4)
	move.w	#$4489,$7e+$e(a4)
	move.w	#$7f00,$9e+$e(a4)
	move.w	#$8500,$9e+$e(a4)
	move.w	#$4000,$24+$e(a4)
	jsr	index
	move.w	#$9860,$24+$e(a4)
	move.w	#$9860,$24+$e(a4)
	move.l	#$20000,d1
	move.w	#$0002,$9c+$e(a4)
lect1:	move.w	$1e+$e(a4),d2
	btst	#1,d2
	bne.s	lect2
	subq.l	#1,d1
	bne.s	lect1
	moveq	#-1,d0
	bra.s	lectf
lect2:	moveq	#$00,d0
lectf:	move.w	#$4000,$24+$e(a4)
	movem.l	(a7)+,d1-d7/a0-a6
	rts
;**************************************************
decodage_dos:
	movem.l	d1-d7/a0-a6,-(a7)
	lea	buffer_disk,a1
	cmp.w	#$4489,(a1)
	bne.s	dec_df
	moveq	#$0a,d5
dec_d1:	jsr	dec_header
	tst.l	d0
	bne.s	dec_df
	moveq	#$7f,d6
dec_d2:	move.l	$200(a1),d1
	move.l	(a1)+,d0
	asl.l	#1,d0
	and.l	#$aaaaaaaa,d0	
	and.l	#$55555555,d1
	or.l	d1,d0
	cmp.l	a5,a2	;compare si fin adresse
	bge.s	dec_d3	;si oui pas de transfert
	move.l	d0,(a2)+	;transfert
dec_d3:	dbf	d6,dec_d2
	dbf	d5,dec_d1
	clr.l	d0
dec_df:	movem.l	(a7)+,d1-d7/a0-a6
	rts
;*************************************************
dec_header:
	move.w	#$4489,d0
	cmp.l	#buffer_disk+$3200,a1
	bgt.s	err_header
dec1:	cmp.w	(a1)+,d0	;compare si synchro trouve
	bne.s	dec1
	cmp.w	(a1),d0	;compare si 2eme synchro
	bne.s	dec2
	addq.l	#2,a1	;si oui adr buff=buff + 2
dec2:	move.l	(a1),d0
	move.l	$4(a1),d1
	asl.l	#1,d0
	and.l	#$aaaaaaaa,d0	;decodage header
	and.l	#$55555555,d1
	or.l	d1,d0
	move.l	d0,d1
	rol.l	#8,d1
	cmp.b	#$ff,d1	;teste si bonne valeur
	bne.s	err_header
	lsr.w	#8,d0
	lea	$38(a1),a1	;se positionne sur pointeur data
	add.w	d0,d0
	asl.w	#8,d0
	lea	$00(a0,d0.w),a2	;calcule adresse transfert
	moveq	#0,d0
	rts
err_header:
	moveq	#-1,d0
	rts
;***************************************************
codification_dos:
	movem.l	d0-d7/a0-a6,-(a7)
	lea	buffer_disk,a1
	moveq	#$0b,d2
	moveq	#$00,d1
	move.w	#$f9,d6
cod_0:	move.l	#$aaaaaaaa,(a1)+
	dbf	d6,cod_0
	moveq	#$0a,d3
	moveq	#$0b,d2
cod_1:	move.l	#$aaaaaaaa,(a1)+
	move.l	#$44894489,(a1)+
	move.b	#$ff,d7
	asl.l	#8,d7
	move.l	(a2),d0
	move.b	d0,d7
	asl.l	#8,d7
	move.b	d1,d7
	asl.l	#8,d7
	move.b	d2,d7
	move.l	a1,a2
	move.l	d7,d6
	and.l	#$aaaaaaaa,d6
	lsr.l	#1,d6
	move.l	d6,(a1)+
	and.l	#$55555555,d7
	move.l	d7,(a1)+
	moveq	#$01,d5
	jsr	correction_bit
	eor.l	d6,d7
	move.l	a1,a2
	moveq	#$07,d6
cod_2:	move.l	#$aaaaaaaa,(a1)+
	dbf	d6,cod_2
	move.l	d7,d6
	and.l	#$aaaaaaaa,d6
	lsr.l	#1,d6
	move.l	d6,(a1)+
	and.l	#$55555555,d7
	move.l	d7,(a1)+
	moveq	#5,d5
	jsr	correction_bit
	move.l	a1,a3
	addq.l	#8,a1
	move.l	a1,a4
	moveq	#$7f,d5
	moveq	#$00,d4
cod_3:	move.l	(a0)+,d7
	move.l	d7,d6
	and.l	#$aaaaaaaa,d6
	lsr.l	#1,d6
	and.l	#$55555555,d7
	move.l	d7,$200(a1)
	move.l	d6,(a1)+
	eor.l	d6,d4
	eor.l	d7,d4
	dbf	d5,cod_3
	move.l	d4,d7
	and.l	#$aaaaaaaa,d4
	lsr.l	#1,d4
	and.l	#$55555555,d7
	move.l	a3,a2
	move.l	d4,(a3)+
	move.l	d7,(a3)
	moveq	#$01,d5
	jsr	correction_bit
	move.l	a4,a2
	move.w	#$80,d5
	jsr	correction_bit
	addq.b	#1,d1
	subq.b	#1,d2
	adda.l	#$200,a1
	dbf	d3,cod_1
	move.l	#$aaaaaaaa,(a1)+
	movem.l	(a7)+,d0-d7/a0-a6
	rts

correction_bit:
	movem.l	d0-d5/a2,-(a7)
	add.w	d5,d5
	subq.w	#1,d5
	move.b	-1(a2),d0
corr_1:	move.l	(a2),d4
	move.l	d4,d1
	move.l	d4,d2
	not.l	d1
	andi.l	#$55555555,d1
	asl.l	#1,d1
	move.l	d1,d3
	roxr.b	#1,d0
	roxr.l	#1,d4
	eor.l	d4,d1
	and.l	d3,d1
	or.l	d1,d2
	move.l	d2,(a2)+
	move.b	d2,d0
	dbf	d5,corr_1
	movem.l	(a7)+,d0-d5/a2
	rts
;********************************************************
ecriture_dos:
	movem.l	d0-d2/a0-a2,-(a7)
	lea	$dff000,a6
	move.w	#$0002,$9c(a6)
	move.l	#buffer_disk,$20(a6)
	move.w	#$8210,$96(a6)
	move.w	#$7f00,$9e(a6)
	move.w	#$9100,$9e(a6)
	move.w	#$4000,$24(a6)
	jsr	index
	move.w	#$d956,$24(a6)
	move.w	#$d956,$24(a6)
ecr_t1:	btst	#$01,$1f(a6)
	beq.s	ecr_t1

	move.w	#$4000,$24(a6)
	movem.l	(a7)+,d0-d2/a0-a2
	rts

*****************************************************************************

	LOAD_1
	LOAD_2
	LOAD_3
	LOAD_4
	LOAD_5
	LOAD_6
	LOAD_7
	LOAD_8
	LOAD_9
	LOAD_10
	LOAD_11
	LOAD_12
	LOAD_13
	LOAD_14
	LOAD_15
	LOAD_16

buffer_disk
	ds.b	$4000
info_buffer

	DC.B    0,41,12,0
	DC.L	$200000
	DC.B    0,41,12,0
	DC.L	$180000
	DC.B    0,41,12,0
	DC.L	$150000
	DC.B    0,41,12,0
	DC.L	$120000
	DC.B    0,41,12,0
	DC.L	$100000
	DC.B    0,41,12,0
	DC.L	$050000



