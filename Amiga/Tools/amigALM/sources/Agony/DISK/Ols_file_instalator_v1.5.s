

*****************************************************************************
;                 Ordilogic systems file instalator
*****************************************************************************


; code:   	Michel Janssens
; release: 	1.5
; change:	Yves Grolet
; tab:	8

;----------------------------------------------------------------------------



	opt	o+,o3-,c-,d+,w-

	section	chip,code_c

debug	set	1

	include work:global/preset.s










;----------------------------------------------------------------------------

;	parametres pour l'instalation

;----------------------------------------------------------------------------


Disque	set	0	;disque d'Agony (0,1,2)

Asm_vdo_mode	set     0


;----------------------------------------------------------------------------


















;declaration
;-----------

Old_Open_Library	=	-408
Close_Library		=	-414
Open			=	-30
Close			= 	-36
Read			=  	-42
Write			= 	-48
Workbenchtofront	=	-342


Exec_Base		= 	4
Mode_old		=	1005
Mode_new		=	1006

Synchro			=	$51225122
Synchrow		=	$5122

longueur		=	$1800
Drive			=	0	;drive physique pour l'ecriture

;***************************************************
;*	ROUTINE PRINCIPALE			   *
;***************************************************

debut
	bsr	Initialisation
	bne	fin
	bsr	traitement
bcl	btst	#6,$bfe001
	bne	bcl
	bsr	cloture
fin	clr.l	d0
	rts

;***************************************************
;*	Routine d'initialisation		   *
;***************************************************

Initialisation


	move	#%0010000000000000,intena+custom
	lea	Intui_Name(pc),a1
	clr.l	d0
	move.l	Exec_Base,a6
	jsr	Old_Open_Library(a6)
	beq	err_init
	move.l	d0,Intui_Base
        move.l	Intui_Base,a6
	jsr	Workbenchtofront(a6)

        lea	Dos_Name(pc),a1
        clr.l	d0
        move.l	Exec_Base,a6
        jsr	Old_Open_Library(a6)
        beq	err_init
        move.l	d0,Dos_Base

        move.l	#fenetre,d1
        move.l	#Mode_old,d2
        move.l	Dos_Base,a6
        jsr	Open(a6)
        move.l	d0,Con_Handle

	lea	text1,a6
	move.b	#drive,d1
	add.b	#30,d1
	move.b	d1,$34(a6)

        move.l	Con_Handle,d1
        move.l	#text1,d2
        move.l	#text2-text1,d3
        move.l	Dos_Base,a6
        jsr	Write(a6)

        move.l	Con_Handle,d1
        move.l	#text2,d2
        move.l	#text3-text2,d3
        move.l	Dos_Base,a6
        jsr	Write(a6)

        move.l	Con_Handle,d1
        move.l	#buffer,d2
        move.l	#1,d3
        move.l	Dos_Base,a6
        jsr	Read(a6)

	clr.l	d0
	rts
err_init
	move.b	#$ff,d0
	rts

;********************************************************
traitement
	clr.l	Numero_du_fichier
	clr.l	switch
	clr.l	longueur_tampon
	bsr	Demarrage_du_drive
	tst.l	d0
	bne	fin_1
	bsr	position_sur_track_zero
	bsr	position_sur_track_desire
trait_1
	bsr	lecture_du_fichier
	tst	d0
	bne	fin_1
	bsr	ecriture_du_fichier
	addq.l	#1,Numero_du_fichier
	cmp.l	#Nombre_de_fichier-1,Numero_du_fichier
	ble	trait_1

	tst.l	switch
	beq	fin_du_traitement
	bsr	ecr_f0
fin_du_traitement
	bsr	sauvegarde_table
fin_1	bsr	cloture_du_drive
	rts
;********************************************************
sauvegarde_table

	move.l	Con_Handle,d1
	move.l	#text9,d2
	move.l	#text10-text9,d3
	move.l	Dos_Base,a6
	jsr	Write(a6)

	move.l	#Nom_fichier_table,d1
	move.l	#Mode_new,d2
	move.l	Dos_Base,a6
	jsr	Open(a6)

	move.l	d0,d7
	move.l	d0,d1
	move.l	#table_disk,d2
	move.l	#nombre_de_fichier,d3
	mulu	#52,d3
	addq	#4,d3
	jsr	write(a6)

	move.l	d7,d1
	jsr	Close(a6)

	move.l	Con_Handle,d1
	move.l	#text10,d2
	move.l	#text11-text10,d3
	move.l	Dos_Base,a6
	jsr	Write(a6)

	rts
;********************************************************
Demarrage_du_drive:
	move.w	#$4000,$dff09a
	move.b	#$7d,$bfd100
	nop
	nop
	bclr	#drive+3,$bfd100
	move.w	#$b000,d0
dem_1:	dbra	d0,dem_1
	btst	#2,$bfe001
	beq.s	dem_4
	btst	#3,$bfe001
	beq.s	dem_3
	clr.l	d0
	move.w	#$c000,$dff09a
	rts
dem_3:
	move.l	Con_Handle,d1
	move.l	#text7,d2
	move.l	#text8-text7,d3
	move.l	Dos_Base,a6
	jsr	Write(a6)
dem_4:	moveq	#-1,d0
	move.w	#$c000,$dff09a
	rts
;*********************************************************
position_sur_track_zero:
	move.w	#$4000,$dff09a
	move.b	#$7d,$bfd100
	nop
	nop
	bclr	#drive+3,$bfd100
	move.l	#$b000,d0
pos_z0:	dbra	d0,pos_z0
pos_z1:	btst	#4,$bfe001
	beq.s	pos_z4
	bset	#$0001,$bfd100
	bsr	av_track
pos_z3:	btst	#5,$bfe001
	bne.s	pos_z3
	bra.s	pos_z1
pos_z4:	clr.l	position_track
	move.w	#$c000,$dff09a
	rts

av_track:
	bclr	#$0000,$bfd100
	nop
	nop
	bset	#$0000,$bfd100
	move.b	#$ac,$bfd400
	move.b	#$0d,$bfd500
	move.b	#$99,$bfde00
	tst.b	$bfdd00
p_2:	btst	#$000,$bfdd00
	beq.s	p_2
	rts
;*********************************************************
position_sur_track_desire:
	move.w	#$4000,$dff09a
	move.b	#$7d,$bfd100
	nop
	nop
	bclr	#drive+3,$bfd100
pos_d0:	btst	#5,$bfe001
	bne.s	pos_d0
	move.l	#track_depart,d1
	move.l	Position_track,d0
pos_d1:	cmp.l	d0,d1
	beq.s	pos_d4
	bclr	#$0001,$bfd100
	bsr	av_track
	addq.l	#1,d0
pos_d3:	btst	#5,$bfe001
	bne.s	pos_d3
	bra.s	pos_d1
pos_d4:	mulu	#2,d0
	move.l	d0,position_track
	move.w	#$c000,$dff09a
	rts
;*******************************************************
Ecrire_table
	lea	table_disk,a0
	move    #nombre_de_fichier,(a0)+
	move.w	#disque,(a0)+
	move.l	numero_du_fichier,d1
	mulu	#52,d1
	lea	$00(a0,d1.w),a0
	move.l	position_track,d0
	mulu	#longueur,d0
	add.l	longueur_tampon,d0
	move.l	d0,(a0)+
	move.l	longueur_du_fichier,d0
	move.l	d0,(a0)+
	move.l	curent_code,(a0)+
	lea	nom_du_fichier,a4
	moveq	#9,d0
recopie_loop
	move.l  (a4)+,(a0)+
	dbra	d0,recopie_loop
	rts
;********************************************************
Avance_track_suivant:
	move.w	#$4000,$dff09a
	move.b	#$7d,$bfd100
	nop
	nop
	bclr	#drive+3,$bfd100
	move.l	#$b000,d0
av_0:	dbra	d0,av_0
av_4:	btst	#5,$bfe001
	bne.s	av_4
	move.l	Position_track,d0
	addq.l	#1,d0
	move.l	d0,position_track
	btst	#0,d0
	bne.s	av_3
	bclr	#$0001,$bfd100
	bsr	av_track
av_1:	btst	#5,$bfe001
	bne.s	av_1
	bset	#$0002,$bfd100
av_2:	move.w	#$c000,$dff09a
	rts
av_3:	bclr	#$0002,$bfd100
	bra.s	av_2
;********************************************************
Cloture_du_drive
	move.b	#$fd,$bfd100
	nop
	nop
	move.b	#$d7,$bfd100
	move.w	#$b000,d0
clot_1	dbra	d0,clot_1
	rts
;********************************************************
lecture_du_fichier

	lea	Fichier,a0
	move.l	Numero_du_fichier,d0
	mulu	#40,d0
	lea	(a0,d0.w),a0
	lea	Nom_du_fichier,a1
	clr.l	d0

lect_1	move.b	(a0)+,(a1)+
	addq.b	#1,d0
	cmp.b	#$20,(a0)
	bne	lect_1
	move.b	#$00,(a1)
	addq.b	#1,d0
	move.l	d0,Longueur_du_nom

	move.l	Con_Handle,d1
	move.l	#text3,d2
	move.l	#text4-text3,d3
	move.l	Dos_Base,a6
	jsr	Write(a6)

	move.l	Con_Handle,d1
	move.l	#Nom_du_fichier,d2
	move.l	Longueur_du_nom,d3
	move.l	Dos_Base,a6
	jsr	Write(a6)

	move.l	#Nom_du_fichier,d1
	move.l	#Mode_old,d2
	move.l	Dos_Base,a6
	jsr	Open(a6)

	move.l	d0,d7
	beq	lect_e
	move.l	d0,d1
	move.l	#Adresse_chargement,d2
	move.l	#$f0000,d3
	jsr	Read(a6)
	move.l	d0,longueur_du_fichier
	beq	lect_e
	move.l	d7,d1
	jsr	Close(a6)

	move.l	Con_Handle,d1
	move.l	#text6,d2
	move.l	#text7-text6,d3
	move.l	Dos_Base,a6
	jsr	Write(a6)
	move.l	#Adresse_chargement,a0
	move.l	longueur_du_fichier,d0
	move.l	a0,a1
	add.l	d0,a1
	lea	code,a3
	move.l	Numero_du_fichier,d3
	mulu	#4,d3
	move.l	$00(a3,d3.w),d0
	move.l	d0,curent_code
lect_2	eor.l	d0,(a0)+
	cmp.l	a0,a1
	bgt	lect_2
	bsr	ecrire_table
	clr	d0
	rts
lect_e
        move.l	Con_Handle,d1
	move.l	#text15,d2
	move.l	#text16-text15,d3
	move.l	Dos_Base,a6
	jsr	Write(a6)
	st	d0
	rts

;********************************************************
ecriture_du_fichier:
	movem.l	a0-a2,-(a7)
	tst.l	switch
	bne	ecr_4
	lea	Adresse_chargement,a1
	move.l	a1,a2
	adda.l	Longueur_du_fichier,a2
ecr_0:	move.l	a1,a0
	add.l	#longueur,a0
	cmp.l	a0,a2
	blt	ecr_1

	moveq	#$08,d2
ecr_0a:	bsr	codification_track
	bsr	ecriture_track
	bsr	lecture_track
	bsr	controle_buffer
	tst.l	d0
	beq.s	ecr_0b
	subq.l	#1,d2
	bne.s	ecr_0a
ecr_0b:
	bsr	avance_track_suivant
	add.l	#longueur,a1
	bra.s	ecr_0
ecr_1:	cmp.l	a1,a2
	beq.s	ecr_3
	move.l	a1,d0
	lea	Tampon,a0
ecr_2:	move.l	(a1)+,(a0)+
	cmp.l	a1,a2
	bgt.s	ecr_2
	move.l	a1,d1
	sub.l	d0,d1
	move.l	d1,longueur_tampon
	move.b	#$ff,switch
	movem.l	(a7)+,a0-a2
	rts
ecr_3:	clr.l	switch
	clr.l	longueur_tampon
	movem.l	(a7)+,a0-a2
	rts
ecr_4:	lea	Adresse_chargement,a0
	lea	tampon,a1
	move.l	longueur_tampon,d0
	add.l	d0,a1
ecr_5:	move.l	(a0)+,(a1)+
	addq.l	#4,d0
	cmp.l	#longueur,d0
	bne.s	ecr_5
	lea	tampon,a1
	moveq	#$08,d2
ecr_5a:	bsr	codification_track
	bsr	ecriture_track
	bsr	lecture_track
	bsr	controle_buffer
	tst.l	d0
	beq.s	ecr_6
	subq.l	#1,d2
	bne.s	ecr_5a
ecr_6:	bsr	avance_track_suivant
	move.l	a0,a1
	lea	Adresse_chargement,a2
	add.l	longueur_du_fichier,a2
	bra	ecr_0

ecr_f0:	lea	Adresse_chargement,a0
	lea	tampon,a1
	move.l	longueur_tampon,d0
	add.l	d0,a1
ecr_f1:	clr.l	(a1)+
	addq.l	#4,d0
	cmp.l	#longueur,d0
	bne.s	ecr_f1
	lea	tampon,a1
	moveq	#$08,d2
ecr_f2:	bsr	codification_track
	bsr	ecriture_track
	bsr	lecture_track
	bsr	controle_buffer
	tst.l	d0
	beq.s	ecr_f3
	subq.l	#1,d2
	bne.s	ecr_f2
ecr_f3:	bsr	avance_track_suivant
	rts

;************************************************
codification_track:
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	a1,a0
	lea	buffer_disk,a1
	move.w	#$d00,d0
cod_0:	move.l	#$aaaaaaaa,(a1)+
	dbf	d0,cod_0
	lea	buffer_disk,a1
          move.l	#$aaaaa54a,(a1)+
	move.l	#$54949252,(a1)+
	moveq	#$24,d0
	move.l	a0,d1
.loop
 	and.l	#$ffffff00,d1
	bsr	code_mot_long
	add.l	#$12345600,d1
	dbra	d0,.loop
	move.l	#$ff300000,d7
	moveq	#$0b,d0
	move.l	#$a244a244,(a1)+
	move.l	#$45224522,(a1)+
cod_1:	move.l	#synchro,(a1)+
	bsr	calcul_checksum
	add.l	#$10000,d7
	or.l	d7,d1
	bsr	code_mot_long

	moveq	#$7f,d5
cod_2:	move.l	(a0)+,d1
	bsr	code_mot_long
	dbf	d5,cod_2
	btst	#0,-1(a1)
	beq	.ok
	move.l	#$2a44894a,(a1)+
	bra	.cont
.ok
	move.l	#$aa44894a,(a1)+
.cont
	dbf	d0,cod_1
	move.l	#$aaaaaaaa,(a1)
	movem.l	(a7)+,d0-d7/a0-a6
	rts

code_mot_long:
	movem.l	d0-d3,-(a7)
	move.l	d1,d0
	move.l	d0,d3
	lsr.l	#1,d0
	bsr	cod_m1
	move.l	d3,d0
	bsr	cod_m1
	bsr	place_bord
	movem.l	(a7)+,d0-d3
	rts

cod_m1:	andi.l	#$55555555,d0
	move.l	d0,d2
	eori.l	#$55555555,d2
	move.l	d2,d1
	lsl.l	#1,d2
	lsr.l	#1,d1
	bset	#$1f,d1
	and.l	d2,d1
	or.l	d1,d0
	btst	#0,-1(a1)
	beq.s	cod_m2
	bclr	#$1f,d0
cod_m2:	move.l	d0,(a1)+
	rts

place_bord:
	move.l	a1,-(a7)
	subq.l	#8,a1
	move.b	(a1),d0
	btst	#0,-1(a1)
	bne.s	plc1
	btst	#6,d0
	bne.s	plc3
	bset	#7,d0
	bra.s	plc2
plc1:	bclr	#7,d0
plc2:	move.b	d0,(a1)
plc3:	move.l	(a7)+,a1
	rts

calcul_checksum:
	movem.l	d0/d2/a0,-(a7)
	move.l	#$ff,d0
	clr.l	d1
	clr.l	d2
cal_1:	move.w	(a0)+,d2
	add.w	d2,d1
	dbf	d0,cal_1
	movem.l	(a7)+,d0/d2/a0
	rts
;**************************************************
ecriture_track:
	movem.l	d0-d2/a0-a2,-(a7)
	clr.l	d0
	clr.l	d1
	clr.l	d2
	lea	text4,a0
	move.l	position_track,d0
	move.b	#$30,$1c(a0)
	btst	#0,d0
	beq.s	ecr_p0
	move.b	#$31,$1c(a0)
ecr_p0:	divu	#2,d0
	and.l	#$000000ff,d0
	add.l	#20,a0
	divu	#10,d0
	move.w	d0,d1
	swap	d0
	add.b	#$30,d1
	add.b	#$30,d0
	move.b	d1,(a0)+
	move.b	d0,(a0)
	
	move.l	Con_Handle,d1
	move.l	#text4,d2
	move.l	#text5-text4,d3
	move.l	Dos_Base,a6
	jsr	Write(a6)

	move.w	#$4000,$dff09a

	move.b	#$7d,$bfd100
	nop
	nop
	bclr	#drive+3,$bfd100
	move.l	position_track,d0
	bset	#$0002,$bfd100
	btst	#$00,d0
	beq.s	ecr_i0
	bclr	#$0002,$bfd100

ecr_i0:	bsr	index
	lea	$dff000,a6
	move.w	#$0002,$9c(a6)
	move.l	#buffer_disk,$20(a6)
	move.w	#$8210,$96(a6)
	move.w	#$7f00,$9e(a6)
	nop
	nop
	move.w	#$a100,$9e(a6)
	move.w	#$4000,$24(a6)
	bsr	index
	move.w	#$d900,$24(a6)
	move.w	#$d900,$24(a6)
ecr_t1:	btst	#$01,$1f(a6)
	beq.s	ecr_t1
	move.w	#$4000,$24(a6)

	move.w	#$c000,$dff09a
	movem.l	(a7)+,d0-d2/a0-a2
	rts
;********************************************************
index:
	movem.l	d0-d1,-(a7)
	clr.l	d0
	move.l	#$30000,d1
	move.b	$bfdd00,d0
index1:	move.b	$bfdd00,d0
	btst	#4,d0
	bne.s	index2
	subq.l	#1,d1
	bne.s	index1
index2:	movem.l	(a7)+,d0-d1
	rts
;********************************************************
lecture_track:
	movem.l	d0-d2/a0-a2,-(a7)
	move.w	#$4000,$dff09a
	bclr	#$07,$bfd100
	nop
	nop
	bclr	#drive+3,$bfd100
	move.l	position_track,d0
	bset	#$02,$bfd100
	btst	#0,d0
	beq.L	lect_a
	bclr	#$02,$bfd100
lect_a:	lea	buffer_disk,a1
	move.w	#$d00,d0
lect_t:	move.l	#$00000000,(a1)+
	dbf	d0,lect_t
lect_first_synchro:
	lea	$dff000,a6
	move.w	#$0002,$9c(a6)
	move.l	#buffer_disk,$20(a6)
	move.w	#$4522,$7e(a6)
	move.w	#$8210,$96(a6)
	move.w	#$7f00,$9e(a6)
	nop
	nop
	move.w	#$a500,$9e(a6)
	move.w	#$4000,$24(a6)
	bsr	index
	move.w	#$9800,$24(a6)
	move.w	#$9800,$24(a6)
	clr.l	d0
	move.l	#$20000,d1
lect_f_s1:
	move.w	$1e(a6),d2
	btst	#1,d2
	bne.s	lect_f_s2
	subq.l	#1,d1
	bne.s	lect_f_s1
	bra.L	lcl
lect_f_s2:
	lea	Buffer_disk,a1
lect_f_s3:
	cmp.w	#$4522,(a1)+
	bne.s	lc0
	cmp.w	#$4522,(a1)
	bne.s	lect_f_s4
	adda.l	#2,a1
lect_f_s4:
	cmp.l	#synchro,(a1)
	beq.s	lect_t0
lc0:	move.w	#$240,$dff180
	btst	#7,$bfe001
	bne.s	lc0
	bra	lcl
lect_t0:
	lea	$dff000,a6
	move.w	#$0002,$9c(a6)
	move.l	#buffer_disk,$20(a6)
	move.w	#synchrow,$7e(a6)
	move.w	#$8210,$96(a6)
	move.w	#$7f00,$9e(a6)
	nop
	nop
	move.w	#$a500,$9e(a6)
	move.w	#$4000,$24(a6)
	bsr	index
	move.w	#$9880,$24(a6)
	move.w	#$9880,$24(a6)
	clr.l	d0
	move.l	#$20000,d1
lect_t1:
	move.w	$1e(a6),d2
	btst	#1,d2
	bne.s	lect_t2
	subq.l	#1,d1
	bne.s	lect_t1
lcl:	move.w	#$380,$dff180
	btst	#6,$bfe001
	bne.s	lcl
lect_t2:
	move.w	#$4000,$24(a6)
	move.w	#$c000,$dff09a
	movem.l	(a7)+,d0-d2/a0-a2
	rts
controle_buffer:
	movem.l	d1-d7/a0-a4,-(a7)
	lea	buffer_disk,a1
	move.w	#$ff30,d4
	clr.l	d5
ctrl_w:	cmp.w	#synchrow,(a1)+
	bne.s	ctrl_w
ctrl_x:	cmp.w	#synchrow,(a1)
	bne.s	ctrl_y
	adda.l	#2,a1
ctrl_y:	adda.l	#6,a1
ctrl_1:	cmp.w	#synchrow,(a1)+
	bne.s	err_0
ctrl_2:	cmp.w	#synchrow,(a1)
	bne.s	ctrl_2a
	adda.l	#2,a1
ctrl_2a:
	addq.w	#1,d4

	move.l	(a1)+,d0
	move.l	(a1)+,d1
	asl.l	#1,d0
	and.l	#$aaaaaaaa,d0
	and.l	#$55555555,d1
	or.l	d1,d0
	swap	d0
	cmp.w	d4,d0
	bne.s	err_1
	swap	d0
	clr.l	d6
	move.w	d0,d6
	clr.l	d2
	moveq	#$7f,d3
ctrl_3:	move.l	(a1)+,d0
	move.l	(a1)+,d1
	asl.l	#1,d0
	and.l	#$aaaaaaaa,d0
	and.l	#$55555555,d1
	or.l	d1,d0
	add.w	d0,d2
	swap	d0
	add.w	d0,d2
	dbf	d3,ctrl_3
	cmp.w	d2,d6
	bne.s	err_2
	addq.l	#4,a1
	addq.l	#1,d5
	cmp.l	#buffer_disk+$3200,a1
	bgt.s	err_3
	cmp.b	#$0c,d5
	blt	ctrl_1
	clr.l	d0
fin_ctrl:
	movem.l	(a7)+,d1-d7/a0-a4
	rts
err_0:
	move.l	Con_Handle,d1
	move.l	#text11,d2
	move.l	#text12-text11,d3
	move.l	Dos_Base,a6
	jsr	Write(a6)

	moveq	#-1,d0
	bra.s	fin_ctrl
err_1:
	move.l	Con_Handle,d1
	move.l	#text12,d2
	move.l	#text13-text12,d3
	move.l	Dos_Base,a6
	jsr	Write(a6)
	moveq	#-1,d0
	bra.s	fin_ctrl
err_2:
	illegal
	move.l	Con_Handle,d1
	move.l	#text13,d2
	move.l	#text14-text13,d3
	move.l	Dos_Base,a6
	jsr	Write(a6)
	moveq	#-1,d0
	bra.s	fin_ctrl
err_3:
	move.l	Con_Handle,d1
	move.l	#text14,d2
	move.l	#text15-text14,d3
	move.l	Dos_Base,a6
	jsr	Write(a6)
	moveq	#-1,d0
	bra.L	fin_ctrl

;********************************************************
Cloture
	move.l	Con_Handle,d1
	move.l	Dos_Base,a6
	jsr	Close(a6)

	move.l	Dos_Base,a1
	move.l	Exec_Base,a6
	jsr	Close_Library(a6)
	rts
;********************************************************
	even
fenetre	dc.b	'CON:0/0/640/200/ ** ORDILOGIC System file installator V1.5 ** ',0
	even
Dos_Name	dc.b	'dos.library',0
	even
Intui_Name	dc.b	'intuition.library',0
	even
Dos_Base		dcb.l	1,0
Intui_Base		dcb.l	1,0
Con_Handle		dcb.l	1,0
Buffer			dcb.l	1,0
File_Adresse		dcb.l	1,0
position_track		dcb.l	1,0
switch			dcb.l	1,0
longueur_tampon		dcb.l	1,0
Numero_du_fichier	dcb.l	1,0

text1	dc.b	$0d,$0a
	dc.b	'Inserer la disquette destination dans le drive'
	dc.b	$0a,$0d,0
text2	dc.b	'Et appuyer sur une touche pour demarrer le programme'
	dc.b	$0a,$0d,0
text3	dc.b	'Chargement de  ',0
text4	dc.b	'Ecriture      track 00 side 0 '
	dc.b	$0a,$0d,0
text5	dc.b	'Verification  track 00 side 0 '
	dc.b	$0a,0
text6	dc.b	$0a,$0d,'Codification du fichier ',$0a,$0d,0
text7  	dc.b	'Disque protege en ecriture ',$0a,$0d,0
text8	dc.b	'erreur        track 00 '
	dc.b	$0a,0
text9	dc.b	'Ecriture fichier table '
	dc.b	$0a,$0d,0
text10	dc.b	'Fin du travail (cliquez bouton gauche de la souris)'
	dc.b	$0a,$0d,0
text11	dc.b	'synchro pas trouve ',$0a,$0d,0
text12	dc.b	'erreur secteur ',$0a,$0d,0
text13	dc.b	'erreur checksum data ',$0a,$0d,0
text14	dc.b	'erreur secteur < 12 ',$0a,$0d,0
text15	dc.b	$0a,$0d,'Amiga dos erreur sur fichier en lecture (clicker pour continuer)',$0a,$0d,0
text16
	even
table_disk		dcb.b	$1000,0
	even
tampon			dcb.l	$802,0
	even
controle		dcb.l	$802,0
	even
Buffer_disk		dcb.l	$1000,0
adresse_chargement	dcb.b	400000,0

	even
longueur_du_fichier	dcb.l	1,0
longueur_du_nom		dcb.l	1,0
curent_code		dc.l	0

Nom_du_fichier		dc.b	'***************************************',0

	even

















*****************************************************************************
;                 Agony disk #0	P A L
*****************************************************************************

	ifne	disque=0

track_depart	equ	1	;1 track pour ecrire
Nombre_de_fichier	equ	6	;nombre de fichier a ecrire
Nom_fichier_table	dc.b	'Work:agony/DISK/disk0_info',0

	even

fichier
	dc.b	'WORK:agony/DISK/DiskID0                ',0
	dc.b	'dh0:ag/Present                         ',0
	dc.b	'dh0:ag/fire                            ',0
	dc.b	'dh0:ag/ending                          ',0
	dc.b	'WORK:agony/DISK/DiskID0                ',0
	dc.b	'WORK:agony/DISK/DiskID0                ',0

code
	dc.l	$00000000
	dc.l	$25a103bc
	dc.l	$272f9a6b
	dc.l	$965a38fe
	dc.l	$250ad2fc
	dc.l	$fa5829ff
	dc.l	$af7ef0ad
	dc.l	$44bc1e9a
	dc.l	$16590ad7
	dc.l	$ace4b9ff

	endc



*****************************************************************************
;                 Agony disk #1	P A L
*****************************************************************************

	ifne	disque=1

track_depart		equ	1		;1 track pour ecrire
Nombre_de_fichier	equ	8		;nombre de fichier a ecrire
Nom_fichier_table	dc.b	'Work:Agony/DISK/disk1_info',0

	even

fichier
	dc.b	'WORK:Agony/DISK/DiskID1                ',0
	dc.b	'dh0:ag/igt                             ',0
	dc.b	'dh0:ag/load_sea                        ',0
	dc.b	'dh0:ag/sea                             ',0
	dc.b	'dh0:ag/load_forest                     ',0
	dc.b	'dh0:ag/forest                          ',0
	dc.b	'dh0:ag/load_marshes                    ',0
	dc.b	'WORK:Agony/DISK/DiskID1                ',0

code
	dc.l	$00000000
	dc.l	$23a153bc
	dc.l	$2d2f9a6b
	dc.l	$905a08fe
	dc.l	$280ad2fc
	dc.l	$fe5889ff
	dc.l	$a57ef0ad
	dc.l	$985a08fe
	endc



*****************************************************************************
;                 Agony disk #2	P A L
*****************************************************************************

	ifne	disque=2
track_depart		equ	0	;1 track pour ecrire
Nombre_de_fichier	equ	8	;nombre de fichier a ecrire
Nom_fichier_table	dc.b	'Work:Agony/DISK/disk2_info',0
	even

fichier
	dc.b	'WORK:Agony/DISK/DiskID2                ',0
	dc.b	'dh0:ag/marshes                         ',0
	dc.b	'dh0:ag/load_mountains                  ',0
	dc.b	'dh0:ag/mountains                       ',0
	dc.b	'dh0:ag/load_highlands                  ',0
	dc.b	'dh0:ag/highlands                       ',0
	dc.b	'dh0:ag/load_fire                       ',0
	dc.b	'WORK:Agony/DISK/DiskID2                ',0
code
	dc.l	$00000000
	dc.l	$4abc6e9a
	dc.l	$12590ad7
	dc.l	$a4e489ff
	dc.l	$cdfa5a9e
	dc.l	$df2689ff
	dc.l	$df2609ff
	dc.l	$12590ab7
	endc











