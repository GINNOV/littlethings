
**************************************************************************
*
* 	ORDILOGIC DISK LOADING SUBROUTINES & comon protection routines
*	--------------------------------------------------------------
*
* Code :		Michel Janssens
* Update :	Art & Magic  (software protection & interface)
* Release :	1.5
* Date : 		4/10/90
* Tab :		10
*
**************************************************************************

		INCLUDE	WORK:Agony/Disk/load_label.s

DISK_DEBUG	SET       0
dsynchro_VAL	SET	$51225122		;51455145 $a5a4

; Disk macros
; -----------

LOAD		MACRO	FILE_x_x,addr
                    lea	\2,a0
		move	#\1_disk,d6
		move.l	#\1_code,d7
                    move	#\1_num,d0
                    lea	\1_num*87+$200,a2
                    lsl	#3,d0
		add	d0,a2
		move.l	-\1_num*87(a2),d0
		move.l	-\1_num*87+4(a2),d1
		move.l	d1,-(sp)
;		lea	.return_off\@,a6
;		move.l	(a6),d2
;                    lea	.return\@,a2
;		sub.l	d2,a2
;                    jmp	(a2)
;.return_off\@
;		dc.l	.return\@-loadroutine1
;.return\@
		jsr	loadroutine1
		move.l	(sp)+,d0		* return file len in d0
		ENDM

cm		MACRO
		dc.w	\2,\1
		ENDM
cw		MACRO
		dc.w	((((\2))&$ff)<<8)+\1+1,$fffe
		ENDM
DERROR		MACRO
		IFNE	DISK_DEBUG=1
		move.l	#'YANN',d1
		trap	#0
		dc.b	\1,0
		even
		ENDC
		ENDM
wait_sync		macro
		move.l	d0,-(sp)
.ws_loop\@
		move.l	$4+custom,d0
		and.l	#$0001ff00,d0
		cmp.l	#$00001000,d0
		bne	.ws_loop\@
		move.l	(sp)+,d0
		endm

; Anti-cartridge macros
; ---------------------

anti_cartridge_cl	MACRO		ac_cl line_to_wait

		c_move	0,cop1lc
		c_move	$80,cop1lc+2
		c_move	%1100000000000000,intena
		c_move	%1100000000000000,intreq
		ENDM

kill_init		MACRO		kill_init first_addr_of_init_to_kill
                    IFNE	asm_protect=1
		lea	\1,a1
kill_loop\@
		clr.b	(a1)+
		cmp.l	#kill_loop\@,a1
		blt	kill_loop\@
		ENDC
		ENDM

res_black_cl	equ	$ac

dma_off		equ	%0000000101101111

black		MACRO
		wait_sync
		move.l	#black_cl,curent_cl
		move.l	#black_cl,cop1lc+custom
		move.l    #res_black_cl,cop1lc_bak
		move	d0,copjmp1+custom
		ENDM

*********************************************************
*         MAIN LOADING ROUTINES
*	a0=adresse chargement
*	d0=pointeur track
*	d1=longueur fichier
*	d6=disque	0 a 3
*	d7=code
********************************************************

LOAD_1		MACRO
LoadRoutine1
		move	d6,i_d_num
.debut
                    IFNE	asm_protect=1
		move.l	$60,a4
		ELSEIF
                    lea	$df0001,a4
		ENDC
		move.l	a4,d2
		eor.l	#dsynchro_val^$df0001,d2
		move.l	d2,dsynchro
		lea	position_track(pc),a2
		move.l	a0,a5			a0=adresse chargement
		add.l	d1,a5			a5=adresse fin
		moveq	#0,d3
		moveq	#0,d4
		move.l	d0,d5
		divu	#$1800,d5
		move	d5,d3			d3=track de chargement
		swap	d5
		move	d5,d4			d4=distance data dans track
		clr.b	dswitch
		move.l	a4,a3
		add	#$eff1,a4
		sub.l	#$1f0000,a3
		movem.l	d3-d4/d7/a0/a2/a5,-(sp)
		jsr	init_0
		movem.l	(sp)+,d3-d4/d7/a0/a2/a5

		jsr	position_sur_track_zero
		clr.l	(a2)
.gototrack
		cmp.l	(a2),d3
		beq	.readtrack
		jsr	avance_track_suivant
		bra	.gototrack
.readtrack
		moveq	#8,d2			8 essais
.tryagain
		jsr	lecture_track
		jsr	controle_buffer
		tst.l	d0
		beq	.readok
		subq.l	#1,d2
		bne	.tryagain
		DERROR	<'READ ERROR'>
.loaderror
		move	d0,$dff180
		addq	#1,d0
		bra       .loaderror
.readok
		jsr	decodification
		cmp.l	a0,a5
		ble	.end
		jsr	avance_track_suivant
		move.b	#-1,dswitch
		bra	.tryagain
.end
		jsr	cloture_drives
		DERROR	<'FIN DE PROGRAMME'>
		rts
;          	lea	LoadRoutine1(pc),a0
;                   add.l	(a6),a0
;		jmp	(a0)

chk_zone3_e

* RESIDENT LABEL
* --------------
		IFNE	asm_absolute=1
          	RSSET	$1b0
Mem_Config	RS.L	1	4
Score		RS.L	1	4
Life		RS.W	1	2
Axe_Up_On		RS.W	1	2
Axe_Down_On	RS.W	1	2
Fw_Fire_Weapon	RS.W	1	2
Extra_Life	RS.L	1         4
Spell_Advailable	RS.W	8	16
Spell_Next_Bonus	RS.W	1	2
Audio_Mode	RS.W	1	2
Sheet_flag	RS.W	1	2
Curent_cl		RS.L	1	4
Cop1lc_bak	RS.L	1	4
*                                    -------
*				50
		ELSEIF

Mem_Config	DC.L	$c00000	4
Score		DS.L	1	4
Life		DC.W	%111	2
Axe_Up_On		DS.W	1	2
Axe_Down_On	DS.W	1	2
Fw_Fire_Weapon	DS.W	1	2
Extra_Life	DS.L	1         4
Spell_Advailable	DS.W	8	16
Spell_Next_Bonus	DS.W	1	2
Audio_Mode	DS.W	1	2
Sheet_flag	DC.W	1	2
Curent_cl		DS.L	1	4
Cop1lc_bak	DS.L	1	4

		ENDC


		ENDM
    	

*******************************************
*	INITIALISATION DU DRIVE
*******************************************

LOAD_2		MACRO
init_0
	moveq	#3,d5
		jsr	test_drive
	tst.l	d0
	beq	.end
	moveq	#4,d5
		jsr	test_drive
		tst.l	d0
		beq	.end
		moveq	#5,d5
		jsr	test_drive
		tst.l	d0
		beq	.end

		IFD	DISK_DEBUG
		btst	#6,$bfe001-$c00001(a3)
		bne	.skip
	DERROR	<'INTERRUPTION SOURIS'>
.skip
	ENDC


* ------ routine affichage message

		movem.l	d0-d7/a0-a3,-(sp)
		jsr	message
		st	cop_chg_flag+1
		tst.l	curent_cl
		bne	.no2
    		move.l	#black_cl,curent_cl
.no2
		movem.l	(sp)+,d0-d7/a0-a3
		bra	init_0
.end
		move	#%10,$2e+$e(a4)
                    move.l	curent_cl,d0
		beq	.no
		tst	cop_chg_flag
		beq	.no
		clr	cop_chg_flag
		wait_sync
		cmp.l	#black_cl,d0
		bne	.no_blcl
		move.l	#res_black_cl,cop1lc_bak
		bra	.cont
.no_blcl
		move.l	d0,cop1lc_bak
.cont
		move.l	d0,$80+$e(a4)
		move	d0,copjmp1+$e(a4)
.no
		rts

cop_chg_flag
		dc.w	0
		ENDM

***************************************************

LOAD_3		MACRO
test_drive
		move.b	#$7d,$bfd100-$c00001(a3)
		jsr	mini_pause
		bclr	d5,$bfd100-$c00001(a3)	select drive d5-3
		jsr	l_pause
		move.l	#$4000,d1          ;;;
.loop
		btst	#5,$bfe001-$c00001(a3)	drive ready ?
		beq	.driveok
		jsr	mini_pause
		subq.l	#1,d1
		bne	.loop
		bra	.error		drive debranche ou malfonctionnant
.driveok

*		btst	#2,$bfe001-$c00001(a3)
*		beq	.error

.gototrack0	jsr	position_sur_track_zero
		bclr	#$0001,$bfd100-$c00001(a3)	avance +

		cmp	#2,d6		test DISK 3
		beq	.skip

.gototrack1	bset	#$0002,$bfd100-$c00001(a3)	face 0
		addq.l	#2,(a2)
		jsr	av_track
.skip

		moveq	#$0a,d2		10 tests
.readtrack1	jsr	lecture_track
		tst.l	d0
		bne	.error
		jsr	controle_buffer
		tst.l	d0
		beq	.testdisk
		subq.l	#1,d2
		beq	.error
		bra	.readtrack1
.testdisk

		jsr	controle_disque
		tst.l	d0
		bne	.error
		rts

.error
		jsr	cloture_drives
		DERROR	<'DRIVE NOT READY / TEST_DRIVE ERROR'>
		moveq	#-1,d0
		rts

		ENDM

**********************************************************
LOAD_4		MACRO
l_pause
*		move.l	d1,-(sp)
*		move.l	#$b000,d1
*.loop		dbra	d1,.loop
*		move.l	(sp)+,d1

		bsr       pause_track
		bsr       pause_track
		bsr       pause_track
		bsr       pause_track

		rts
		ENDM

**********************************************************

LOAD_5		MACRO
pause_track
*		move.l	d1,-(sp)
*		move.l	#$3000,d1
*.loop		dbra	d1,.loop
*		move.l	(sp)+,d1
*		rts

		move.b	#$ac,$bfd400
		move.b	#$0d,$bfd500
		move.b	#$99,$bfde00
		tst.b	$bfdd00
.wait		btst	#0,$bfdd00
		beq	.wait

		rts
mini_pause
		move.l	d0,-(sp)
		move.b	Vhpos+Custom,d0
.wait
		cmp.b	Vhpos+Custom,d0
		beq	.wait
		move.l  (sp)+,d0
		rts
		ENDM

**********************************************************

LOAD_6		MACRO
position_sur_track_zero
.loop		btst	#4,$bfe001-$c00001(a3)		track 0 ?
		beq	.skip
		bset	#1,$bfd100-$c00001(a3)		sens -
		jsr	av_track
.wait		btst	#5,$bfe001-$c00001(a3)		ready ?
		bne	.wait
		bra	.loop
.skip		clr.l	(a2)
		rts
		ENDM


**********************************************************

LOAD_7		MACRO
Avance_track_suivant
		move.l	(a2),d0
		addq.l	#1,d0
		move.l	d0,(a2)
		btst	#0,d0		chgt face ?
		bne	.face1
		bclr	#1,$bfd100-$c00001(a3)	sens +
		jsr	av_track
.wait		btst	#5,$bfe001-$c00001(a3)	ready ?
		bne	.wait
		bset	#2,$bfd100-$c00001(a3)	face 0
		rts
.face1		bclr	#$0002,$bfd100-$c00001(a3)
		rts
		ENDM
	
;********************************************************

LOAD_8		MACRO
av_track
		bclr	#0,$bfd100-$c00001(a3)	ST
		jsr	mini_pause
		bset	#0,$bfd100-$c00001(a3)	ST
		jsr	pause_track
.wait		btst	#5,$bfe001-$c00001(a3)	ready ?
		bne	.wait
		rts
		ENDM

;********************************************************

LOAD_9		MACRO
Cloture_drives
		move.b	#$fd,$bfd100-$c00001(a3)	MOTOR OFF
		jsr	mini_pause
		bclr	d5,$bfd100-$c00001(a3)	select drive off
		jsr	l_pause
		rts
		ENDM

;********************************************************

LOAD_10		MACRO
index
		movem.l	d0-d1,-(sp)
		moveq	#0,d0
		move.l	#$6000,d1		;;;;
		move.b	$bfdd00-$c00001(a3),d0
.loop		move.b	$bfdd00-$c00001(a3),d0
		btst	#4,d0
		bne	.end
		jsr	mini_pause
		subq.l	#1,d1
		bne	.loop
.end		movem.l	(sp)+,d0-d1
		rts
		ENDM

;********************************************************

LOAD_11	MACRO
lecture_track			;!!!!
		movem.l	d1-d2/a0-a2,-(sp)
		move.l	(a2),d0
		bset	#$0002,$bfd100-$c00001(a3)
		btst	#$00,d0
		beq	lect_s1
		bclr	#$0002,$bfd100-$c00001(a3)
lect_s1
;		lea	$dff000,a6	;!
		tst.b	dswitch
		bne	lect_t0
		move	#$4522,d0
		move	#$8500,d1
		jsr	transfert
		tst.l	d0
		bne	lect_t3
lect_f_s2
		lea	Buffer_disk,a1
lect_f_s3
		cmp	#$4522,(a1)+
		bne	lect_f_s5
		cmp	#$4522,(a1)
		bne	lect_f_s4
		add.l	#2,a1
lect_f_s4
		move.l	dsynchro,d1	;!!!
		cmp.l	(a1),d1
		beq	lect_t0
lect_f_s5
		moveq	#-1,d0
		bra	lect_t3
lect_t0
		move.l	#$5122,d0
		move.l	#$9880,d1
		jsr	transfert
lect_t3		movem.l	(sp)+,d1-d2/a0-a2
		rts
transfert
		move.l	#buffer_disk,$20+$e(a4)
		move	d0,$7e+$e(a4)
		move	#$8210,$96+$e(a4)
		move	#$7f00,$9e+$e(a4)
		jsr	mini_pause
		move	#$9500,$9e+$e(a4)
		move	#$4000,$24+$e(a4)
		jsr	index
		move	d1,$24+$e(a4)
		move	d1,$24+$e(a4)
		moveq	#0,d0
		move	#$0002,$9c+$e(a4)
		move.l	#$4000,d1		;;;
trsf1
		move	$1e+$e(a4),d2
		btst	#1,d2
		bne	trsf2
		jsr	mini_pause
		subq.l	#1,d1
		bne	trsf1
		moveq	#-1,d0
		bra	trsf3
trsf2
		moveq	#$00,d0
trsf3		move	#$4000,$24+$e(a4)
		rts
		ENDM


********************************************************

LOAD_12		MACRO
Controle_buffer				;!!!!
		movem.l	d1-d7/a1,-(sp)
		lea	buffer_disk,a1
		move	#$ff30,d4
		moveq	#0,d5
ctrl_w
		move	dsynchro,d2
		cmp	(a1)+,d2		;!!!
		bne	ctrl_w
ctrl_x
		move	dsynchro,d2
		cmp	(a1),d2		;!!!
		bne	ctrl_y
		add.l	#2,a1
ctrl_y
		add.l	#6,a1
ctrl_1
		move	dsynchro,d2	;!!!
		cmp	(a1)+,d2
		bne	err_1
ctrl_2
		move	dsynchro,d2	;!!!
		cmp	(a1),d2
		bne	ctrl_2a
		add.l	#2,a1
ctrl_2a
		addq.w	#1,d4
		jsr	decodification_long_word
		swap	d0
		cmp	d4,d0
		bne	err_1
		swap	d0
		move	d0,d6
		moveq	#0,d2
		moveq	#$7f,d3
ctrl_3		jsr	decodification_long_word
		add.w	d0,d2
		swap	d0
		add.w	d0,d2
		dbf	d3,ctrl_3
		cmp	d2,d6
		bne	err_1
		add.l	#$4,a1
		addq.l	#1,d5
		cmp.l	#buffer_disk+$3200,a1
		bgt	err_1
		cmp.l	#$0c,d5
		beq	ctrl_4
		bra	ctrl_1
ctrl_4
		moveq	#0,d0
ctrl_f
		movem.l	(sp)+,d1-d7/a1
		rts
err_1
		moveq	#-1,d0
		bra	ctrl_f

		ENDM


****************************************************

LOAD_13	MACRO
controle_disque
		movem.l	d1-d2/a1,-(sp)
		lea	buffer_disk,a1
		add.w	#$12,a1
		jsr	decodification_long_word

*		bra	.ok		???????  test drive a modifier

		cmp	#$0000,d6	;compare si disque 0
		bne	.dsk_1
		cmp.l	#'ur00',d0	;compare donnee disque
		bne	.error
		bra	.ok
.dsk_1		cmp	#$0001,d6	;compare si disque 1
		bne	.dsk_2
		cmp.l	#'ur01',d0	;compare donnee disque
		bne	.error
		bra	.ok
.dsk_2		cmp	#$0002,d6	;compare si disque 1
		bne	.dsk_3
		cmp.l	#'ur02',d0	;compare donnee disque
		bne	.error
		bra	.ok
.dsk_3		cmp	#$0003,d6	;compare si disque 2
		bne	.error
		cmp.l	#'ur03',d0	;compare donnee disque
		bne	.error
.ok		moveq	#0,d0
.end		movem.l	(sp)+,d1-d2/a1
		rts
.error		DERROR	<'MAUVAIS DISK'>
		moveq	#-1,d0
		bra	.end
		ENDM

;******************************************************

LOAD_14		MACRO
decodification			;!!!!
		movem.l d0-d2/d5/a1,-(sp)
		lea	buffer_disk,a1
		moveq	#$0b,d2
		moveq	#0,d3
dec_a
		move	dsynchro,d5	;!!!
		cmp	(a1)+,d5
		beq	dec_a
		add.l	#4,a1
dec_0
		move	dsynchro,d5	;!!!
		cmp	(a1)+,d5
		beq	dec_0
		addq.l	#6,a1

		moveq	#$7f,d5
dec_1
		jsr	decodification_long_word
		eor.l	d7,d0			   ;elimination code
		cmp.l	d3,d4			   ;si longueur track > data
		bgt	dec_2
		cmp.l	a0,a5
		ble	dec_f
		move.l	d0,(a0)+
dec_2
		addq.l	#4,d3
		dbf	d5,dec_1
		addq.l	#4,a1
		dbf	d2,dec_0
dec_f
		moveq	#0,d4
		movem.l	(sp)+,d0-d2/d5/a1
		rts

		ENDM

********************************************

LOAD_15		MACRO
decodification_long_word
		move.l	(a1)+,d0
		move.l	(a1)+,d1
		asl.l	#1,d0
		and.l	#$aaaaaaaa,d0
		and.l	#$55555555,d1
		or.l	d1,d0
		rts	
position_track
		ds.l      1
dswitch
		ds.l	1
dsynchro
		ds.l	1

		ENDM


********************************************


LOAD_16		MACRO
message
		wait_synch
		move	#%0000000111100000,dmacon+$e(a4)
		move.l	#id_cl,$80+$e(a4)
		move.l	#id_cl,cop1lc_bak
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
		rts

id_image
		incbin	WORK:Agony/Disk/insert_disk.bin
i_d_num
		ds.w	1
id_cl
		ifne	asm_protect=1
		anti_cartridge_cl
		endc
id_clp
	CM	0,$e0
	CM	0,$e2
          	CM	0,$144
          	CM	0,$146
	CM	0,$148
	CM	0,$14a
	CM	0,$14c
	CM	0,$14e
	CM	0,$150
	CM	0,$152
	CM	0,$154
	CM	0,$156
	CM	0,$158
	CM	0,$15a
	CM	0,$15c
	CM	0,$15e
	CM	0,$160
 	CM	0,$162
	CM	0,$180
	CM	$fff,$182
	dc.l	$fffffffe

black_cl
		cm	%0000000101101111,dmacon
		cm	$7fff,intena
		cm	0,$180
		cm	0,$144
		cm	0,$146
		cm	0,$148
		cm	0,$14a
		cm	0,$14c
		cm	0,$14e
		cm	0,$150
		cm	0,$152
		cm	0,$154
		cm	0,$156
		cm	0,$158
		cm	0,$15a
		cm	0,$15c
		cm	0,$15e
		cm	0,$160
		cm	0,$162
	dc.l	$fffffffe

		ENDM


;********************************************************
;********************************************************

LOAD_FALSE	MACRO

deb_d1
		move.l	a0,a5
		add.l	d2,a5
		move.w	#$0001,d2		;recherche disk 1
                    trap	#0
		moveq	#$08,d3
deb_d2
		trap	#1
		trap	#2
		tst.l	d1
		bne.s	deb_d5
		bsr	lecture_dos
		tst.l	d0
		beq.s	deb_d3
		subq.l	#1,d3
		bne.s	deb_d2
		moveq	#-1,d0
		bra.s	deb_df
deb_d3
		bsr	decodage_dos
		tst.l	d0
		beq.s	deb_d4
		subq.l	#1,d3
		bne.s	deb_d2
		moveq	#-1,d0
		bra.s	deb_df
deb_d4
		moveq	#$00,d0
		bra.s	deb_df
deb_d5:
		btst	#3,$bfe001
		beq.s	deb_df
		bsr	lecture_dos
		tst.l	d0
		beq.s	deb_d6
		subq.l	#1,d3
		bne.s	deb_d2
		moveq	#-1,d0
		bra.s	deb_df
deb_d6
		bsr	codification_dos
		bsr	ecriture_dos
		moveq	#$00,d0
deb_df
		trap	#7
		movem.l	(a7)+,d1-d7/a0-a6
		rts
;********************************************************
lecture_dos
		movem.l	d1-d7/a0-a6,-(a7)
lect0
		lea	buffer_disk+$1000,a1

		move.l	a1,$20+custom
		move.w	#$8210,$96+custom
		move.w	#$4489,$7e+custom
		move.w	#$7f00,$9e+custom
		move.w	#$8500,$9e+custom
		move.w	#$4000,$24+custom
		trap	#6
		move.w	#$9860,$24+custom
		move.w	#$9860,$24+custom
		move.l	#$4000,d1		;;;
		move.w	#$0002,$9c+custom
lect1
		jsr	mini_pause
		move.w	$1e+custom,d2
		btst	#1,d2
		bne.s	lect2
		subq.l	#1,d1
		bne.s	lect1
		moveq	#-1,d0
		bra.s	lectf
lect2
		moveq	#$00,d0
lectf
		move.w	#$4000,$24+custom
		movem.l	(a7)+,d1-d7/a0-a6
		rts
;**************************************************
decodage_dos
		movem.l	d1-d7/a0-a6,-(a7)
		lea	buffer_disk+$1000,a1
		cmp.w	#$4489,(a1)
		bne.s	dec_df
		moveq	#$0a,d5
dec_d1
		bsr	dec_header
		tst.l	d0
		bne.s	dec_df
		moveq	#$7f,d6
dec_d2
		move.l	$200(a1),d1
		move.l	(a1)+,d0
		asl.l	#1,d0
		and.l	#$aaaaaaaa,d0
		and.l	#$55555555,d1
		or.l	d1,d0
		cmp.l	a5,a2		;compare si fin adresse
		bge.s	dec_d3		;si oui pas de transfert
		move.l	d0,(a2)+	;transfert
dec_d3
		dbf	d6,dec_d2
		dbf	d5,dec_d1
		clr.l	d0
dec_df
		movem.l	(a7)+,d1-d7/a0-a6
		rts
;*************************************************
dec_header
		move.w	#$4489,d0
		cmp.l	#buffer_disk+$4200,a1
		bgt.s	err_header
dec1
		cmp.w	(a1)+,d0	;compare si dsynchro trouve
		bne.s	dec1
		cmp.w	(a1),d0		;compare si 2eme dsynchro
		bne.s	dec2
		addq.l	#2,a1		;si oui adr buff=buff + 2
dec2
		move.l	(a1),d0
		move.l	$4(a1),d1
		asl.l	#1,d0
		and.l	#$aaaaaaaa,d0	;decodage header
		and.l	#$55555555,d1
		or.l	d1,d0
		move.l	d0,d1
		rol.l	#8,d1
		cmp.b	#$ff,d1		;teste si bonne valeur
		bne.s	err_header
		lsr.w	#8,d0
		lea	$38(a1),a1	;se positionne sur pointeur data
		add.w	d0,d0
		asl.w	#8,d0
		lea	$00(a0,d0.w),a2	;calcule adresse transfert
		moveq	#0,d0
		move.w	#$a5a4,$7e+custom
		rts
err_header
		moveq	#-1,d0
		rts
;***************************************************
codification_dos
		movem.l	d0-d7/a0-a6,-(a7)
		lea	buffer_disk+$1000,a1
		moveq	#$0b,d2
		moveq	#$00,d1
		move.w	#$f9,d6
cod_0
		move.l	#$aaaaaaaa,(a1)+
		dbf	d6,cod_0
		moveq	#$0a,d3
		moveq	#$0b,d2
cod_1
		move.l	#$aaaaaaaa,(a1)+
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
		bsr	correction_bit
		eor.l	d6,d7
		move.l	a1,a2
		moveq	#$07,d6
cod_2
		move.l	#$aaaaaaaa,(a1)+
		dbf	d6,cod_2
		move.l	d7,d6
		and.l	#$aaaaaaaa,d6
		lsr.l	#1,d6
		move.l	d6,(a1)+
		and.l	#$55555555,d7
		move.l	d7,(a1)+
		moveq	#5,d5
		bsr	correction_bit
		move.l	a1,a3
		addq.l	#8,a1
		move.l	a1,a4
		moveq	#$7f,d5
		moveq	#$00,d4
cod_3
		move.l	(a0)+,d7
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
		bsr	correction_bit
		move.l	a4,a2
		move.w	#$80,d5
		bsr	correction_bit
		addq.b	#1,d1
		subq.b	#1,d2
		adda.l	#$200,a1
		dbf	d3,cod_1
		move.l	#$aaaaaaaa,(a1)+
		movem.l	(a7)+,d0-d7/a0-a6
		rts

correction_bit
		movem.l	d0-d5/a2,-(a7)
		add.w	d5,d5
		subq.w	#1,d5
		move.b	-1(a2),d0
corr_1
		move.l	(a2),d4
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
ecriture_dos
		movem.l	d0-d2/a0-a2,-(a7)
		move.w	#$0002,$9c+custom
		move.l	#buffer_disk+$1000,$20+custom
		move.w	#$8210,$96+custom
		move.w	#$7f00,$9e+custom
		move.w	#$9100,$9e+custom
		move.w	#$4000,$24+custom
		trap	#6
		move.w	#$d956,$24+custom
		move.w	#$d956,$24+custom
ecr_t1
		btst	#$01,$1f+custom
		beq.s	ecr_t1

		move.w	#$4000,$24+custom
		movem.l	(a7)+,d0-d2/a0-a2
		rts

		ENDM

;********************************************************
;********************************************************


