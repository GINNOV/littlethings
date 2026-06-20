* The Player 6.0A for DevPac 3 and later *
;start = 6	;Starting position
fade  = 0	;0 = normal
		;1 = use master volume
system = 0	;0 = killer
		;1 = friendly
CIA = 0		;0 = disabled
		;1 = enabled
		;System friendly version always CIA
exec = 1	;0 = ExecBase destroyed
		;1 = ExecBase valid
lev6 = 1	;0 = NonLev6
		;1 = Lev6 used
opt020 = 1	;0 = MC680x0
		;1 = MC68020 or better
channels = 4	;amount of channels to be played
use	 =	$4000be0f	;The Usecode


	include	"music/include/Player6.i"

		section	Player6.0A,code

MUSIC_START	movem.l	d0-a6,-(sp)
		lea	$dff000,a6
		move.l	P60_data,a0	;Module
		addq.w	#MAGIC_NUMBER,a0
		sub.l	a1,a1		;Samples
		sub	a2,a2		;samples bufon
		moveq	#0,d0		;Auto Detect
		jsr	P60_Init

		move.l	$4.w,a6
		move.w	296(a6),d0
		and.w	#$e,d0
		bra.b	proc_68020
start_music
		;
		movem.l	(sp)+,d0-a6
		rts

;wyjscie z programu

MUSIC_STOP	bsr.b	clrinterrupt
		lea	$dff000,a6
		jsr	P60_End
		move.w	#$7fff,$dff09c
		clr.l	d0
		rts

;------------------------procesor 68020---------------------------		
proc_68020	move.l	$4.w,a6
		lea	setinterrupt,a5
		jsr	-$1e(a6)
		bra.b	start_music
;-------------------------------------------------------------------
setinterrupt	dc.w	$4e7a,$0801
		move.l	d0,a1
		move.l	d0,VBRaddr
		move.l	$6c(a1),adres
		lea	my_music,a0
		move.l	a0,$6c(a1)
		rte
;----------------------- Zerowanie przeywek -------------------------------
clrinterrupt	movem.l	a0,-(a7)
		move.l	VBRaddr,a0
		move.l	adres,$6c(a0)
		movem.l	(a7)+,a0
		rts
;-------------------------------------------------------------------
Disable_Int:
		move.w	$dff01c,Save
		ori.w	#$8000,Save
		move.w	#$7fff,$dff09a
		move.w	#$e020,$dff09a
;		move.w	#$7fff,$dff09c
		rts
Enable_Int:
		move.w	Save(pc),$dff09a
		rts

Save	   	dc.w	0

;---------------------------------------------------------------------------
my_music	movem.l	d0-d7/a0-a6,-(a7)

		tst.w	SynchroCntr
		beq.b	mm0
		subq.w	#1,SynchroCntr

mm0
		move.w	#$20,$dff09c
		lea	$dff000,a6
		jsr	P60_Music
		move.l	UserInt,a0
		jsr	(a0)
		movem.l	(a7)+,d0-d7/a0-a6
		addq.w	#1,IntFlag
		rte

adres		dc.l	$0
VBRaddr		dc.l	$0

;--------------------------------p60 player source======================
P60_IRQsave	dc	0
P60_DMAsave	dc	0
P60_raster	dc.l	0
P60_raster2	dc.l	0
P60_frames	dc.l	0
P60_diri	dc	1

*********************************
*        Player 6.0A о		*
*   All in one-DevPac3-version	*
*        Version 600.2		*
*   й 1992-93 Jarno Paananen	*
*     All rights reserved	*
*********************************

	section	muza,code
******** START OF BINARY FILE **************

P60_motuuli
	bra.b	P60_Init
	ifeq	CIA
	bra	P60_Music
	else
	rts
	rts
	endc
	bra	P60_End
	rts				;no P60_SetRepeat
	rts

P60_master	dc	64		;Master volume (0-64)
P60_Tempo	dc	1		;Use tempo? 0=no,non-zero=yes
P60_play	dc	1		;Stop flag (0=stop)
P60_E8		dc	0		;Info nybble after command E8

P60_Temp0Offset
	dc.l	P60_temp0-P60_motuuli
P60_Temp1Offset
	dc.l	P60_temp1-P60_motuuli
P60_Temp2Offset
	dc.l	P60_temp2-P60_motuuli
P60_Temp3Offset
	dc.l	P60_temp3-P60_motuuli

P60_getnote	macro
	moveq	#$7e,d0
	and.b	(a5),d0
	beq.b	.nonote
	ifne	P60_vib
	clr.b	P60_VibPos(a5)
	endc
	ifne	P60_tre
	clr.b	P60_TrePos(a5)
	endc

	ifne	P60_ft
	add	P60_Fine(a5),d0
	endc
	move	d0,P60_Note(a5)
	move	(a2,d0),P60_Period(a5)

.nonote
	endm

	ifne	CIA

	ifeq	system
P60_intti
	movem.l	d0-a6,-(sp)
	tst.b	$bfdd00
	move.b	#$7e,$bfdd00

	lea	$dff000,a6
;	move	#$fff,$180(a6)
	bsr	P60_Music
;	move	#0,$180(a6)
	move	#$2000,$9c(a6)
	movem.l	(sp)+,d0-a6
	rte

	else
P60_lev6server
	movem.l	d2-d7/a2-a6,-(sp)
	lea	$dff000,a6
	lea	P60_cn(pc),a3
	move	P60_server(pc),d0
	beq.b	P60_musica
	subq	#1,d0
	beq	P60_dmason
	bra	P60_setrepeat
P60_musica
	bsr	P60_Music
P60_ohi	movem.l	(sp)+,d2-d7/a2-a6
	moveq	#1,d0
	rts
	endc
	endc

;нннннннннннннннннннннннннннннннннннннннннннннннн
;н Call P60_Init to initialize the playroutine	н
;н D0 --> Timer detection (for CIA-version)	н
;н A0 --> Address to the module			н
;н A1 --> Address to samples/0			н
;н A2 --> Address to sample buffer		н
;н D0 <-- 0 if succeeded			н
;н A6 <-- $DFF000				н
;н 		Uses D0-A6			н
;нннннннннннннннннннннннннннннннннннннннннннннннн

P60_Init
	cmp.l	#"P60A",(a0)+
	beq.b	.modok
	subq.l	#4,a0

.modok	
	ifne	CIA
	move	d0,-(sp)
	endc

	moveq	#0,d0
	cmp.l	d0,a1
	bne.b	.redirect

	move	(a0),d0
	lea	(a0,d0.l),a1
.redirect
	move.l	a2,a6
	lea	8(a0),a2
	moveq	#$40,d0
	and.b	3(a0),d0
	bne.b	.buffer
	move.l	a1,a6
	subq.l	#4,a2
.buffer

	lea	P60_cn(pc),a3
	moveq	#$1f,d1
	and.b	3(a0),d1
	move.l	a0,-(sp)
	lea	P60_Samples(pc),a4
	subq	#1,d1
	moveq	#0,d4
P60_lopos
	move.l	a6,(a4)+
	move	(a2)+,d4
	bpl.b	P60_kook
	neg	d4
	lea	P60_Samples-16(pc),a5
	ifeq	opt020
	asl	#4,d4
	move.l	(a5,d4),d6
	else
	add	d4,d4
	move.l	(a5,d4*8),d6
	endc
	move.l	d6,-4(a4)
	move	4(a5,d4),d4
	sub.l	d4,a6
	sub.l	d4,a6
	bra.b	P60_jatk

P60_kook
	move.l	a6,d6
	tst.b	3(a0)
	bpl.b	P60_jatk

	move.l	d4,d0
	subq.l	#2,d0
	bmi.b	P60_jatk
	move.l	a6,a5
	move.b	(a5)+,d2
	sub.b	(a5),d2
	move.b	d2,(a5)+
.loop	sub.b	(a5),d2
	move.b	d2,(a5)+
	sub.b	(a5),d2
	move.b	d2,(a5)+
	dbf	d0,.loop

P60_jatk
	move	d4,(a4)+
	moveq	#0,d2
	move.b	(a2)+,d2
	moveq	#0,d3
	move.b	(a2)+,d3

	moveq	#0,d0
	move	(a2)+,d0
	bmi.b	.norepeat

	move	d4,d5
	sub	d0,d5
	move.l	d6,a5

	add.l	d0,a5
	add.l	d0,a5

	move.l	a5,(a4)+
	move	d5,(a4)+
	bra.b	P60_gene
.norepeat
	move.l	d6,(a4)+
	move	#1,(a4)+
P60_gene
	move	d3,(a4)+
	moveq	#$f,d0
	and	d2,d0
	mulu	#74,d0
	move	d0,(a4)+

	tst	-6(a2)
	bmi.b	.nobuffer

	moveq	#$40,d0
	and.b	3(a0),d0
	beq.b	.nobuffer

	move	d4,d7
	tst.b	d2
	bpl.b	.copy

	subq	#1,d7
	moveq	#0,d5
	moveq	#0,d4
.lo	move.b	(a1)+,d4
	moveq	#$f,d3
	and	d4,d3
	lsr	#4,d4

	sub.b	.table(pc,d4),d5
	move.b	d5,(a6)+
	sub.b	.table(pc,d3),d5
	move.b	d5,(a6)+
	dbf	d7,.lo
	bra.b	.kop

.copy	add	d7,d7
	subq	#1,d7
.cob	move.b	(a1)+,(a6)+
	dbf	d7,.cob
	bra.b	.kop

.table dc.b	0,1,2,4,8,16,32,64,128,-64,-32,-16,-8,-4,-2,-1

.nobuffer
	add.l	d4,a6
	add.l	d4,a6
.kop	dbf	d1,P60_lopos

	move.l	(sp)+,a0
	and.b	#$7f,3(a0)

	move.l	a2,-(sp)

	lea	P60_temp0(pc),a1
	lea	P60_temp1(pc),a2
	lea	P60_temp2(pc),a4
	lea	P60_temp3(pc),a5
	moveq	#Channel_Block_SIZE/2-2,d0

	moveq	#0,d1
.cl	move	d1,(a1)+
	move	d1,(a2)+
	move	d1,(a4)+
	move	d1,(a5)+
	dbf	d0,.cl

	move.l	(sp)+,a2
	move.l	a2,P60_positionbase-P60_cn(a3)

	moveq	#$7f,d1
	and.b	2(a0),d1

	ifeq	opt020
	lsl	#3,d1
	lea	(a2,d1.l),a4
	else
	lea	(a2,d1.l*8),a4
	endc
	move.l	a4,P60_possibase-P60_cn(a3)

	move.l	a4,a1
	moveq	#-1,d0
.search	cmp.b	(a1)+,d0
	bne.b	.search
	move.l	a1,P60_patternbase-P60_cn(a3)	

	ifd	start
	lea	start(a4),a4
	endc

	moveq	#0,d0
	move.b	(a4)+,d0
	move.l	a4,P60_spos-P60_cn(a3)
	lsl	#3,d0
	add.l	d0,a2

	move.l	a1,a4
	moveq	#0,d0	
	move	(a2)+,d0
	lea	(a4,d0.l),a1
	move.l	a1,P60_ChaPos+P60_temp0-P60_cn(a3)
	move	(a2)+,d0
	lea	(a4,d0.l),a1
	move.l	a1,P60_ChaPos+P60_temp1-P60_cn(a3)
	move	(a2)+,d0
	lea	(a4,d0.l),a1
	move.l	a1,P60_ChaPos+P60_temp2-P60_cn(a3)
	move	(a2)+,d0
	lea	(a4,d0.l),a1
	move.l	a1,P60_ChaPos+P60_temp3-P60_cn(a3)

	lea	P60_setrepeat(pc),a0
	move.l	a0,P60_intaddr-P60_cn(a3)

	move	#63,P60_rowpos-P60_cn(a3)
	move	#6,P60_speed-P60_cn(a3)
	move	#5,P60_speed2-P60_cn(a3)
	clr	P60_speedis1-P60_cn(a3)

	ifne	P60_pl
	clr.l	P60_plcount-P60_cn(a3)
	endc

	ifne	P60_pde
	clr	P60_pdelay-P60_cn(a3)
	endc
	clr	(a3)

	moveq	#2,d0
	and.b	$bfe001,d0
	move.b	d0,P60_ofilter-P60_cn(a3)
	bset	#1,$bfe001

	ifeq	system
	ifne	exec
	move.l	4.w,a6
	moveq	#0,d0
	btst	d0,297(a6)
	beq.b	.no68010

	lea	P60_liko(pc),a5
	jsr	-$1e(a6)

.no68010
	move.l	d0,a0
	lea	$78(a0),a0
	else
	lea	$78.w,a0
	endc

	move.l	a0,P60_vektori-P60_cn(a3)
	move.l	(a0),P60_oldlev6-P60_cn(a3)
	lea	P60_dmason(pc),a1
	move.l	a1,(a0)
	endc

	moveq	#0,d0
	lea	$dff000,a6
	move	d0,$a8(a6)
	move	d0,$b8(a6)
	move	d0,$c8(a6)
	move	d0,$d8(a6)
	move	#$f,$96(a6)

	ifeq	system
	move	#$2000,$9a(a6)
	lea	$bfd000,a0
	move.b	#$7f,$d00(a0)
	move.b	#8,$e00(a0)
	endc

	ifeq	CIA
	move.b	#$4a,$400(a0)
	move.b	#1,$500(a0)
	move.b	#$81,$d00(a0)
	endc

	ifne	CIA
	move	(sp)+,d0
	subq	#1,d0
	beq.b	P60_ForcePAL
	subq	#1,d0
	beq.b	P60_NTSC
	ifne	exec
	move.l	4.w,a1
	cmp.b	#60,$212(a1)	;VBlankFrequency
	beq.b	P60_NTSC
	endc
P60_ForcePAL
	move.l	#1773447,d0	;PAL
	bra.b	P60_setcia
P60_NTSC
	move.l	#1789773,d0	;NTSC
P60_setcia
	move.l	d0,P60_timer-P60_cn(a3)
	divu	#125,d0
	move	d0,P60_thi2-P60_cn(a3)
	sub	#$1c8*2,d0
	move	d0,P60_thi-P60_cn(a3)

	ifeq	system
	move.b	d0,$400(a0)
	lsr	#8,d0
	move.b	d0,$500(a0)

	lea	P60_intti(pc),a1
	move.l	a1,P60_tintti-P60_cn(a3)
	move.l	P60_vektori(pc),a2
	move.l	a1,(a2)

	move.b	#$81,$d00(a0)
	move.b	#$19,$e00(a0)
	moveq	#0,d0
	endc
	endc


	ifeq	system
	move	#$e000,$9a(a6)
	rts

	ifne	exec
P60_liko
	dc.l	$4E7A0801		;MOVEC	VBR,d0
	rte
	endc
	endc

	ifne	system
	move.l	a6,-(sp)
	clr	P60_server-P60_cn(a3)

	move.l	4.w,a6
	moveq	#-1,d0
	jsr	-$14a(a6)
	move.b	d0,P60_sigbit-P60_cn(a3)
	bmi	P60_err

	lea	P60_allocport(pc),a1
	move.l	a1,P60_portti-P60_cn(a3)
	move.b	d0,15(a1)
	move.l	a1,-(sp)
	suba.l	a1,a1
	jsr	-$126(a6)
	move.l	(sp)+,a1
	move.l	d0,16(a1)
	lea	P60_reqlist(pc),a0
	move.l	a0,(a0)
	addq.l	#4,(a0)
	clr.l	4(a0)
	move.l	a0,8(a0)

	lea	P60_dat(pc),a1
	move.l	a1,P60_reqdata-P60_cn(a3)
	lea	P60_allocreq(pc),a1
	lea	P60_audiodev(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	move.l	4.w,a6
	jsr	-$1bc(a6)
	tst.b	d0
	bne	P60_err
	st.b	P60_audioopen-P60_cn(a3)

	lea	P60_timerint(pc),a1
	move.l	a1,P60_timerdata-P60_cn(a3)
	lea	P60_lev6server(pc),a1
	move.l	a1,P60_timerdata+8-P60_cn(a3)

	moveq	#0,d3
	lea	P60_cianame(pc),a1
	move.b	#'b',3(a1)
P60_openciares
	moveq	#0,d0
	jsr	-$1f2(a6)
	move.l	d0,P60_ciares-P60_cn(a3)
	beq.b	P60_tryCIAA
	move.l	d0,a6
	lea	P60_timerinterrupt(pc),a1
	moveq	#0,d0
	jsr	-6(a6)
	tst.l	d0
	beq.b	P60_gottimer
	addq.l	#4,d3
	lea	P60_timerinterrupt(pc),a1
	moveq	#1,d0
	jsr	-6(a6)
	tst.l	d0
	beq.b	P60_gottimer
P60_tryCIAA
	lea	P60_cianame(pc),a1
	cmp.b	#'b',3(a1)
	bne.b	P60_err
	subq.b	#1,3(a1)
	moveq	#8,d3
	bra.b	P60_openciares

P60_gottimer
	lea	P60_craddr+8(pc),a6
	move.l	P60_ciaaddr(pc,d3),d0
	move.l	d0,(a6)
	sub	#$100,d0
	move.l	d0,-(a6)
	moveq	#2,d3
	btst	#9,d0
	bne.b	P60_timerB
	subq.b	#1,d3
	add	#$100,d0
P60_timerB
	add	#$900,d0
	move.l	d0,-(a6)
	move.l	d0,a0
	and.b	#%10000000,(a0)
	move.b	d3,P60_timeropen-P60_cn(a3)
	moveq	#0,d0

	move.l	P60_craddr+4(pc),a1
	move.b	P60_tlo(pc),(a1)
	move.b	P60_thi(pc),$100(a1)
	or.b	#$19,(a0)
P60_pois
	move.l	(sp)+,a6
	rts

P60_err	moveq	#-1,d0
	bra.b	P60_pois
	rts

P60_ciaaddr
	dc.l	$bfd500,$bfd700,$bfe501,$bfe701
	endc

;нннннннннннннннннннннннннннннннннннннннннннннннн
;н     	Call P60_End to stop the music		н
;н   A6 --> Customchip baseaddress ($DFF000)	н
;н		Uses D0/D1/A0/A1/A3		н
;нннннннннннннннннннннннннннннннннннннннннннннннн
	
P60_End	moveq	#0,d0
	move	d0,$a8(a6)
	move	d0,$b8(a6)
	move	d0,$c8(a6)
	move	d0,$d8(a6)
	move	#$f,$96(a6)

	and.b	#~2,$bfe001
	move.b	P60_ofilter(pc),d0
	or.b	d0,$bfe001

	ifeq	system
	move	#$2000,$9a(a6)
	move.l	P60_vektori(pc),a0
	move.l	P60_oldlev6(pc),(a0)

	else
	move.l	a6,-(sp)
	lea	P60_cn(pc),a3
	moveq	#0,d0
	move.b	P60_timeropen(pc),d0
	beq.b	P60_rem1
	move.l	P60_ciares(pc),a6
	lea	P60_timerinterrupt(pc),a1
	subq.b	#1,d0
	jsr	-12(a6)
P60_rem1
	move.l	4.w,a6
	tst.b	P60_audioopen-P60_cn(a3)
	beq.b	P60_rem2
	lea	P60_allocreq(pc),a1
	jsr	-$1c2(a6)
	clr.b	P60_audioopen-P60_cn(a3)
P60_rem2
	moveq	#0,d0
	move.b	P60_sigbit(pc),d0
	bmi.b	P60_rem3
	jsr	-$150(a6)
	st	P60_sigbit-P60_cn(a3)
P60_rem3
	move.l	(sp)+,a6
	endc
	rts

	ifne	fade
P60_mfade
	move	P60_master(pc),d0
	move	P60_temp0+P60_Shadow(pc),d1
	mulu	d0,d1
	lsr	#6,d1
	move	d1,$a8(a6)

	ifgt	channels-1
	move	P60_temp1+P60_Shadow(pc),d1
	mulu	d0,d1
	lsr	#6,d1
	move	d1,$b8(a6)
	endc

	ifgt	channels-2
	move	P60_temp2+P60_Shadow(pc),d1
	mulu	d0,d1
	lsr	#6,d1
	move	d1,$c8(a6)
	endc

	ifgt	channels-3
	move	P60_temp3+P60_Shadow(pc),d1
	mulu	d0,d1
	lsr	#6,d1
	move	d1,$d8(a6)
	endc
	rts
	endc
	
;нннннннннннннннннннннннннннннннннннннннннннннннн
;н Call P60_Music every frame to play the music	н
;н A6 --> Customchip baseaddress ($DFF000)	н
;н          	Uses A0-A5/D0-D7		н
;нннннннннннннннннннннннннннннннннннннннннннннннн

P60_Music
	lea	P60_cn(pc),a3

	tst	P60_play-P60_cn(a3)
	bne.b	P60_ohitaaa
	ifne	CIA
	ifeq	system
	move.l	P60_vektori(pc),a5
	move.l	P60_tintti(pc),(a5)
	move.b	P60_tlo2(pc),$bfd400
	move.b	P60_thi2(pc),$bfd500

	else
	move.l	P60_craddr+4(pc),a0
	move.b	P60_tlo2(pc),(a0)
	move.b	P60_thi2(pc),$100(a0)
	endc
	endc
	rts

P60_ohitaaa
	ifne	fade
	pea	P60_mfade(pc)
	endc

	moveq	#Channel_Block_SIZE,d6
	moveq	#16,d7

	move	(a3),d4
	addq	#1,d4
	cmp	P60_speed(pc),d4
	beq	P60_playtime

	move	d4,(a3)

P60_delay
	ifne	CIA
	ifeq	system
	move.l	P60_vektori(pc),a5
	move.l	P60_tintti(pc),(a5)
	move.b	P60_tlo2(pc),$bfd400
	move.b	P60_thi2(pc),$bfd500

	else
	move.l	P60_craddr+4(pc),a0
	move.b	P60_tlo2(pc),(a0)
	move.b	P60_thi2(pc),$100(a0)
	endc
	endc

	lea	P60_temp0(pc),a5
	lea	$a0(a6),a4

	moveq	#channels-1,d5
P60_lopas
	tst	P60_OnOff(a5)
	beq	P60_contfxdone
	moveq	#$f,d0
	and	(a5),d0
	ifeq	opt020
	add	d0,d0
	move	P60_jtab2(pc,d0),d0
	else
	move	P60_jtab2(pc,d0*2),d0
	endc
	jmp	P60_jtab2(pc,d0)

P60_jtab2
	dc	P60_contfxdone-P60_jtab2

	ifne	P60_pu
	dc	P60_portup-P60_jtab2
	else
	dc	P60_contfxdone-P60_jtab2
	endc

	ifne	P60_pd
	dc	P60_portdwn-P60_jtab2
	else
	dc	P60_contfxdone-P60_jtab2
	endc

	ifne	P60_tp
	dc	P60_toneport-P60_jtab2
	else
	dc	P60_contfxdone-P60_jtab2
	endc

	ifne	P60_vib
	dc	P60_vib2-P60_jtab2
	else
	dc	P60_contfxdone-P60_jtab2
	endc

	ifne	P60_tpvs
	dc	P60_tpochvslide-P60_jtab2
	else
	dc	P60_contfxdone-P60_jtab2
	endc

	ifne	P60_vbvs
	dc	P60_vibochvslide-P60_jtab2
	else
	dc	P60_contfxdone-P60_jtab2
	endc

	ifne	P60_tre
	dc	P60_tremo-P60_jtab2
	else
	dc	P60_contfxdone-P60_jtab2
	endc

	ifne	P60_arp
	dc	P60_arpeggio-P60_jtab2
	else
	dc	P60_contfxdone-P60_jtab2
	endc

	dc	P60_contfxdone-P60_jtab2

	ifne	P60_vs
	dc	P60_volslide-P60_jtab2
	else
	dc	P60_contfxdone-P60_jtab2
	endc

	dc	P60_contfxdone-P60_jtab2
	dc	P60_contfxdone-P60_jtab2
	dc	P60_contfxdone-P60_jtab2

	ifne	P60_ec
	dc	P60_contecommands-P60_jtab2
	else
	dc	P60_contfxdone-P60_jtab2
	endc
	dc	P60_contfxdone-P60_jtab2

	ifne	P60_ec
P60_contecommands
	move.b	P60_Info(a5),d0
	and	#$f0,d0
	lsr	#3,d0
	move	P60_etab2(pc,d0),d0
	jmp	P60_etab2(pc,d0)

P60_etab2
	dc	P60_contfxdone-P60_etab2

	ifne	P60_fsu
	dc	P60_fineup2-P60_etab2
	else
	dc	P60_contfxdone-P60_etab2
	endc

	ifne	P60_fsd
	dc	P60_finedwn2-P60_etab2
	else
	dc	P60_contfxdone-P60_etab2
	endc

	dc	P60_contfxdone-P60_etab2
	dc	P60_contfxdone-P60_etab2

	dc	P60_contfxdone-P60_etab2
	dc	P60_contfxdone-P60_etab2

	dc	P60_contfxdone-P60_etab2
	dc	P60_contfxdone-P60_etab2

	ifne	P60_rt
	dc	P60_retrig-P60_etab2
	else
	dc	P60_contfxdone-P60_etab2
	endc

	ifne	P60_fvu
	dc	P60_finevup2-P60_etab2
	else
	dc	P60_contfxdone-P60_etab2
	endc

	ifne	P60_fvd
	dc	P60_finevdwn2-P60_etab2
	else
	dc	P60_contfxdone-P60_etab2
	endc

	ifne	P60_nc
	dc	P60_notecut-P60_etab2
	else
	dc	P60_contfxdone-P60_etab2
	endc

	ifne	P60_nd
	dc	P60_notedelay-P60_etab2
	else
	dc	P60_contfxdone-P60_etab2
	endc

	dc	P60_contfxdone-P60_etab2
	dc	P60_contfxdone-P60_etab2
	endc

	ifne	P60_fsu
P60_fineup2
	tst	(a3)
	bne	P60_contfxdone
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	sub	d0,P60_Period(a5)
	moveq	#113,d0
	cmp	P60_Period(a5),d0
	ble.b	.jup
	move	d0,P60_Period(a5)
.jup	move	P60_Period(a5),6(a4)
	bra	P60_contfxdone
	endc

	ifne	P60_fsd
P60_finedwn2
	tst	(a3)
	bne	P60_contfxdone
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	add	d0,P60_Period(a5)
	cmp	#856,P60_Period(a5)
	ble.b	.jup
	move	#856,P60_Period(a5)
.jup	move	P60_Period(a5),6(a4)
	bra	P60_contfxdone
	endc

	ifne	P60_fvu
P60_finevup2
	tst	(a3)
	bne	P60_contfxdone
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	add	d0,P60_Volume(a5)
	moveq	#64,d0
	cmp	P60_Volume(a5),d0
	bge.b	.jup
	move	d0,P60_Volume(a5)
.jup	move	P60_Volume(a5),8(a4)
	bra	P60_contfxdone
	endc

	ifne	P60_fvd
P60_finevdwn2
	tst	(a3)
	bne	P60_contfxdone
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	sub	d0,P60_Volume(a5)
	bpl.b	.jup
	clr	P60_Volume(a5)
.jup	move	P60_Volume(a5),8(a4)
	bra	P60_contfxdone
	endc

	ifne	P60_nc
P60_notecut
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	cmp	(a3),d0
	bne	P60_contfxdone
	ifeq	fade
	clr	8(a4)
	else
	clr	P60_Shadow(a5)
	endc
	clr	P60_Volume(a5)
	bra	P60_contfxdone
	endc

	ifne	P60_nd
P60_notedelay
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	cmp	(a3),d0
	bne	P60_contfxdone

	moveq	#$7e,d0
	and.b	(a5),d0
	beq	P60_contfxdone
	move	P60_DMABit(a5),d0
	move	d0,$96(a6)
	or	d0,P60_dma-P60_cn(a3)
	move.l	P60_Sample(a5),a1
	move.l	(a1)+,(a4)+
	move	(a1),(a4)+
	move	P60_Period(a5),(a4)
	subq.l	#6,a4
	ifeq	system
	lea	P60_dmason(pc),a1
	move.l	P60_vektori(pc),a0
	move.l	a1,(a0)
	endc

	ifeq	CIA
	move.b	#$19,$bfde00
	else
	ifeq	system
	move.b	#$4a,$bfd400
	move.b	#1,$bfd500
	else
	move	#1,P60_server-P60_cn(a3)
	move.l	P60_craddr+4(pc),a1
	move.b	#$4a,(a1)
	move.b	#1,$100(a1)
	endc
	endc

	bra	P60_contfxdone
	endc

	ifne	P60_rt
P60_retrig
	subq	#1,P60_RetrigCount(a5)
	bne	P60_contfxdone
	move	P60_DMABit(a5),d0
	move	d0,$96(a6)
	or	d0,P60_dma-P60_cn(a3)
	move.l	P60_Sample(a5),a1
	move.l	(a1)+,(a4)
	move	(a1),4(a4)

	ifeq	system
	lea	P60_dmason(pc),a1
	move.l	P60_vektori(pc),a0
	move.l	a1,(a0)
	endc

	ifeq	CIA
	move.b	#$19,$bfde00
	else
	ifeq	system
	move.b	#$4a,$bfd400
	move.b	#1,$bfd500
	else
	move	#1,P60_server-P60_cn(a3)
	move.l	P60_craddr+4(pc),a1
	move.b	#$4a,(a1)
	move.b	#1,$100(a1)
	endc
	endc

	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	move	d0,P60_RetrigCount(a5)
	bra	P60_contfxdone
	endc

	ifne	P60_arp
P60_arplist
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

P60_arpeggio
	move	(a3),d0
	move.b	P60_arplist(pc,d0),d0
	beq.b	.arp0
	subq.b	#1,d0
	beq.b	P60_arp1
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	bra.b	P60_arp3

.arp0	move	P60_Note(a5),d0
	move	P60_periods(pc,d0),6(a4)
	bra	P60_contfxdone
P60_arp1
	move.b	P60_Info(a5),d0
	lsr	#4,d0
P60_arp3
	add	d0,d0
	add	P60_Note(a5),d0
	move	P60_periods(pc,d0),6(a4)
	bra	P60_contfxdone
	endc

P60_periods
	ifne	P60_ft
	incdir	demo:music/
	incbin	periods
	else
	incbin	periods.nft
	endc

	ifne	P60_vs
P60_volslide
	move.b	P60_Info(a5),d0
	sub.b	d0,P60_Volume+1(a5)
	bpl.b	.test
	clr	P60_Volume(a5)
	ifeq	fade
	clr	8(a4)
	else
	clr	P60_Shadow(a5)
	endc
	bra.w	P60_contfxdone
.test	moveq	#64,d0
	cmp	P60_Volume(a5),d0
	bge.b	.ncs
	move	d0,P60_Volume(a5)
	ifeq	fade
	move	d0,8(a4)
	else
	move	d0,P60_Shadow(a5)
	endc
	bra.b	P60_contfxdone
.ncs	
	ifeq	fade
	move	P60_Volume(a5),8(a4)
	else
	move	P60_Volume(a5),P60_Shadow(a5)
	endc
	bra.b	P60_contfxdone
	endc

	ifne	P60_tpvs
P60_tpochvslide
	move.b	P60_Info(a5),d0
	sub.b	d0,P60_Volume+1(a5)
	bpl.b	.test
	clr	P60_Volume(a5)
	ifeq	fade
	clr	8(a4)
	else
	clr	P60_Shadow(a5)
	endc
	bra.b	P60_toneport
.test	moveq	#64,d0
	cmp	P60_Volume(a5),d0
	bge.b	.ncs
	move	d0,P60_Volume(a5)
.ncs
	ifeq	fade
	move	P60_Volume(a5),8(a4)
	else
	move	P60_Volume(a5),P60_Shadow(a5)
	endc
	endc

	ifne	P60_tp
P60_toneport
	move	P60_ToPeriod(a5),d0
	beq.b	P60_contfxdone
	move	P60_TPSpeed(a5),d1
	cmp	P60_Period(a5),d0
	blt.b	.topoup

	add	d1,P60_Period(a5)
	cmp	P60_Period(a5),d0
	bgt.b	P60_toposetper
	move	d0,P60_Period(a5)
	clr	P60_ToPeriod(a5)
	move	d0,6(a4)
	bra.b	P60_contfxdone

.topoup
	sub	d1,P60_Period(a5)
	cmp	P60_Period(a5),d0
	blt.b	P60_toposetper
	move	d0,P60_Period(a5)
	clr	P60_ToPeriod(a5)
P60_toposetper
	move	P60_Period(a5),6(a4)
	else
	nop
	endc

P60_contfxdone
	ifne	P60_il
	bsr	P60_funk2
	endc

	add.l	d6,a5
	add.l	d7,a4
	dbf	d5,P60_lopas

	cmp	P60_speed2(pc),d4
	beq.b	P60_preplay
	rts

	ifne	P60_pu
P60_portup
	moveq	#0,D0
	move.b	P60_Info(a5),d0
	sub	d0,P60_Period(a5)
	moveq	#113,d0
	cmp	P60_Period(a5),d0
	ble.b	.skip
	move	d0,P60_Period(a5)
	move	d0,6(a4)
	bra.b	P60_contfxdone
.skip
	move	P60_Period(a5),6(a4)
	bra.b	P60_contfxdone
	endc

	ifne	P60_pd
P60_portdwn
	moveq	#0,d0
	move.b	P60_Info(a5),d0
	add	d0,P60_Period(a5)
	cmp	#856,P60_Period(a5)
	ble.b	.skip
	move	#856,d0
	move	d0,P60_Period(a5)
	move	d0,6(a4)
	bra.b	P60_contfxdone
.skip
	move	P60_Period(a5),6(a4)
	bra.b	P60_contfxdone
	endc

P60_preplay
	ifne	P60_pde
	tst	P60_pdelay-P60_cn(a3)
	beq.b	.djdj
	rts
.djdj
	endc

	lea	P60_temp0(pc),a5
	lea	P60_Samples-16(pc),a0

	moveq	#channels-1,d5
P60_loaps
	ifne	P60_pl
	lea	P60_TData(a5),a1
	move	2(a5),(a1)+
	move.l	P60_ChaPos(a5),(a1)+
	move.l	P60_TempPos(a5),(a1)+
	move	P60_TempLen(a5),(a1)
	endc

	tst.b	P60_Pack(a5)
	beq.b	P60_takeone
	bmi.b	.keepsame

	subq.b	#1,P60_Pack(a5)
	clr	P60_OnOff(a5)
	add.l	d6,a5
	dbf	d5,P60_loaps
	rts

.keepsame
	addq.b	#1,P60_Pack(a5)
	bra.b	P60_dko

P60_takeone
	tst.b	P60_TempLen+1(a5)
	beq.b	P60_takenorm

	subq.b	#1,P60_TempLen+1(a5)
	move.l	P60_TempPos(a5),a2

P60_jedi
	move.b	(a2)+,(a5)
	bpl.b	P60_normal
	not.b	(a5)+
	move.b	(a2)+,(a5)+
	ifeq	opt020
	move.b	(a2)+,(a5)+
	move.b	(a2)+,(a5)+
	else
	move	(a2)+,(a5)+
	endc

	subq.l	#4,a5
	move.l	a2,P60_TempPos(a5)
	bra.b	P60_dko
	
P60_normal
	ifeq	opt020
	move.b	(a2)+,1(a5)
	move.b	(a2)+,2(a5)
	else
	move	(a2)+,1(a5)
	endc

	move.l	a2,P60_TempPos(a5)
	bra.b	P60_dko

P60_takenorm
	move.l	P60_ChaPos(a5),a2
	move.b	(a2)+,(a5)
	bmi.b	P60_packed
	ifeq	opt020
	move.b	(a2)+,1(a5)
	move.b	(a2)+,2(a5)
	else
	move	(a2)+,1(a5)
	endc
	move.l	a2,P60_ChaPos(a5)
	bra.b	P60_dko

P60_kuiskus
	move.b	(a2)+,P60_TempLen+1(a5)
	moveq	#0,d0
	ifeq	opt020
	move.b	(a2)+,d0
	lsl	#8,d0
	move.b	(a2)+,d0
	else
	move	(a2)+,d0
	endc

	move.l	a2,P60_ChaPos(a5)
	sub.l	d0,a2
	bra.b	P60_jedi

P60_packed
	cmp.b	#$80,(a5)
	beq.b	P60_kuiskus
	not.b	(a5)+
	move.b	(a2)+,(a5)+
	ifeq	opt020
	move.b	(a2)+,(a5)+
	move.b	(a2)+,(a5)+
	else
	move	(a2)+,(a5)+
	endc
	subq.l	#4,a5
	move.l	a2,P60_ChaPos(a5)

P60_dko	st	P60_OnOff(a5)
	move	(a5),d0
	and	#$1f0,d0
	beq.b	.koto
	lea	(a0,d0),a1
	move.l	a1,P60_Sample(a5)
	ifne	P60_ft
	move.l	P60_SampleVolume(a1),P60_Volume(a5)
	else
	move	P60_SampleVolume(a1),P60_Volume(a5)
	endc
	ifne	P60_il
	move.l	P60_RepeatOffset(a1),P60_Wave(a5)
	endc
	ifne	P60_sof
	clr	P60_Offset(a5)
	endc

.koto	add.l	d6,a5
	dbf	d5,P60_loaps
	rts

P60_playtime
	clr	(a3)
	ifne	P60_pde
	tst	P60_pdelay-P60_cn(a3)
	beq.b	.djdj
	subq	#1,P60_pdelay-P60_cn(a3)
	bra	P60_delay
.djdj
	endc

	tst	P60_speedis1-P60_cn(a3)
	beq.b	.mo
	bsr	P60_preplay

.mo	lea	P60_temp0(pc),a5
	lea	$a0(a6),a4

	ifne	system
	moveq	#1,d4
	move	d4,P60_server-P60_cn(a3)
	move.l	P60_craddr+4(pc),a1
	move.b	#$4a,(a1)
	move.b	d4,$100(a1)
	else
	lea	P60_dmason(pc),a1
	move.l	P60_vektori(pc),a2
	move.l	a1,(a2)

	ifeq	CIA
	move.b	#$19,$bfde00
	else
	move.b	#$4a,$bfd400
	move.b	#1,$bfd500
	endc
	endc

	lea	P60_periods(pc),a2

	moveq	#0,d4
	moveq	#channels-1,d5
P60_los	tst	P60_OnOff(a5)
	beq.b	P60_nocha

	moveq	#$f,d0
	and	(a5),d0
	lea	P60_jtab(pc),a1
	add	d0,d0
	add.l	d0,a1
	add	(a1),a1
	jmp	(a1)

P60_fxdone
	moveq	#$7e,d0
	and.b	(a5),d0
	beq.b	P60_nocha
	ifne	P60_vib
	clr.b	P60_VibPos(a5)
	endc
	ifne	P60_tre
	clr.b	P60_TrePos(a5)
	endc

 	ifne	P60_ft
	add	P60_Fine(a5),d0
	endc
	move	d0,P60_Note(a5)
	move	(a2,d0),P60_Period(a5)

P60_zample
	ifne	P60_sof
	tst	P60_Offset(a5)
	bne	P60_pek
	endc

	or	P60_DMABit(a5),d4
	move	d4,$96(a6)
	move.l	P60_Sample(a5),a1
	move.l	(a1)+,(a4)
	move	(a1),4(a4)

P60_nocha
	ifeq	fade
	move.l	P60_Period(a5),6(a4)
	else
	move	P60_Period(a5),6(a4)
	move	P60_Volume(a5),P60_Shadow(a5)
	endc

P60_skip
	ifne	P60_il
	bsr	P60_funk2
	endc

	add.l	d6,a5
	add.l	d7,a4
	dbf	d5,P60_los

	move.b	d4,P60_dma+1-P60_cn(a3)

	ifne	P60_pl
	tst.b	P60_plflag+1-P60_cn(a3)
	beq.b	P60_ohittaa

	lea	P60_temp0(pc),a1
	lea	P60_looppos(pc),a0
	moveq	#channels-1,d0
.talt	move.b	1(a0),3(a1)
	addq.l	#2,a0
	move.l	(a0)+,P60_ChaPos(a1)
	move.l	(a0)+,P60_TempPos(a1)
	move	(a0)+,P60_TempLen(a1)
	add.l	d6,a1
	dbf	d0,.talt

	move	P60_plrowpos(pc),P60_rowpos-P60_cn(a3)
	clr.b	P60_plflag+1-P60_cn(a3)
	rts
	endc

P60_ohittaa
	subq	#1,P60_rowpos-P60_cn(a3)
	bmi.b	P60_nextpattern
	rts

P60_nextpattern
	ifne	P60_pl
	clr	P60_plflag-P60_cn(a3)
	endc
	move.l	P60_patternbase(pc),a4
	moveq	#63,d0
	move	d0,P60_rowpos-P60_cn(a3)
	move.l	P60_spos(pc),a1
	move.b	(a1)+,d0
	bpl.b	P60_dk
	move.l	P60_possibase(pc),a1
	move.b	(a1)+,d0
P60_dk	move.l	a1,P60_spos-P60_cn(a3)
	lsl	#3,d0
	move.l	P60_positionbase(pc),a1
	add.l	d0,a1

	move	(a1)+,d0
	lea	(a4,d0.l),a2
	move.l	a2,P60_ChaPos+P60_temp0-P60_cn(a3)
	move	(a1)+,d0
	lea	(a4,d0.l),a2
	move.l	a2,P60_ChaPos+P60_temp1-P60_cn(a3)
	move	(a1)+,d0
	lea	(a4,d0.l),a2
	move.l	a2,P60_ChaPos+P60_temp2-P60_cn(a3)
	move	(a1),d0
	add.l	d0,a4
	move.l	a4,P60_ChaPos+P60_temp3-P60_cn(a3)
	rts

	ifne	P60_tp
P60_settoneport
	move.b	P60_Info(a5),d0
	beq.b	P60_toponochange
	move.b	d0,P60_TPSpeed+1(a5)
P60_toponochange
	moveq	#$7e,d0
	and.b	(a5),d0
	beq.w	P60_nocha
	add	P60_Fine(a5),d0
	move	d0,P60_Note(a5)
	move	(a2,d0),P60_ToPeriod(a5)
	bra	P60_nocha
	endc

	ifne	P60_sof
P60_sampleoffse
	moveq	#$7e,d0
	and.b	(a5),d0
	beq	P60_nocha
	ifne	P60_vib
	clr.b	P60_VibPos(a5)
	endc
	ifne	P60_tre
	clr.b	P60_TrePos(a5)
	endc

	ifne	P60_ft
	add	P60_Fine(a5),d0
	endc
	move	d0,P60_Note(a5)
	move	(a2,d0),P60_Period(a5)

	moveq	#0,d1
	move	#$ff00,d1
	and	2(a5),d1
	beq.b	P60_pek
	add	d1,P60_Offset(a5)
P60_pek	move	P60_Offset(a5),d1
	move	d1,P60_Offset(a5)
	or	P60_DMABit(a5),d4
	move	d4,$96(a6)
	move.l	P60_Sample(a5),a1
	move.l	(a1)+,d0
	add.l	d1,d0
	move.l	d0,(a4)
	lsr	#1,d1
	move	(a1),d0
	sub	d1,d0
	bpl.b	P60_offok
	move.l	-4(a1),(a4)
	moveq	#1,d0
P60_offok
	move	d0,4(a4)
	bra	P60_nocha
	endc

	ifne	P60_vl
P60_volum
	move.b	P60_Info(a5),P60_Volume+1(a5)
	bra	P60_fxdone
	endc

	ifne	P60_pj
P60_posjmp
	moveq	#0,d0
	move.b	P60_Info(a5),d0
	add.l	P60_possibase(pc),d0
	move.l	d0,P60_spos-P60_cn(a3)
	endc

	ifne	P60_pb
P60_pattbreak
	moveq	#64,d0
	move	d0,P60_rowpos-P60_cn(a3)
	move.l	P60_spos(pc),a1
	move.l	P60_patternbase(pc),a0
	move.b	(a1)+,d0
	bpl.b	P60_dk2
	move.l	P60_possibase(pc),a1
	move.b	(a1)+,d0
P60_dk2	move.l	a1,P60_spos-P60_cn(a3)
	move.l	P60_positionbase(pc),a1
	lsl	#3,d0
	add.l	d0,a1
	movem	(a1),d0-d3
	lea	(a0,d0.l),a1
	move	d1,d0
	move.l	a1,P60_ChaPos+P60_temp0-P60_cn(a3)
	lea	(a0,d0.l),a1
	move.l	a1,P60_ChaPos+P60_temp1-P60_cn(a3)
	move	d2,d0
	lea	(a0,d0.l),a1
	move.l	a1,P60_ChaPos+P60_temp2-P60_cn(a3)
	move	d3,d0
	add.l	d0,a0
	move.l	a0,P60_ChaPos+P60_temp3-P60_cn(a3)
	bra	P60_fxdone
	endc

	ifne	P60_vib
P60_vibrato
	move.b	P60_Info(a5),d0
	beq	P60_fxdone
	move.b	d0,d1
	move.b	P60_VibCmd(a5),d2
	and.b	#$f,d0
	beq.b	P60_vibskip
	and.b	#$f0,d2
	or.b	d0,d2
P60_vibskip
	and.b	#$f0,d1
	beq.b	P60_vibskip2
	and.b	#$f,d2
	or.b	d1,d2
P60_vibskip2
	move.b	d2,P60_VibCmd(a5)
	bra	P60_fxdone
	endc

	ifne	P60_tre
P60_settremo
	move.b	P60_Info(a5),d0
	beq	P60_fxdone
	move.b	d0,d1
	move.b	P60_TreCmd(a5),d2
	moveq	#$f,d3
	and.b	d3,d0
	beq.b	P60_treskip
	and.b	#$f0,d2
	or.b	d0,d2
P60_treskip
	and.b	#$f0,d1
	beq.b	P60_treskip2
	and.b	d3,d2
	or.b	d1,d2
P60_treskip2
	move.b	d2,P60_TreCmd(a5)
	bra	P60_fxdone
	endc

	ifne	P60_ec
P60_ecommands
	move.b	P60_Info(a5),d0
	and.b	#$f0,d0
	lsr	#3,d0
	move	P60_etab(pc,d0),d0
	jmp	P60_etab(pc,d0)

P60_etab
	ifne	P60_fi
	dc	P60_filter-P60_etab
	else
	dc	P60_fxdone-P60_etab
	endc

	ifne	P60_fsu
	dc	P60_fineup-P60_etab
	else
	dc	P60_fxdone-P60_etab
	endc

	ifne	P60_fsd
	dc	P60_finedwn-P60_etab
	else
	dc	P60_fxdone-P60_etab
	endc

	dc	P60_fxdone-P60_etab
	dc	P60_fxdone-P60_etab

	ifne	P60_sft
	dc	P60_setfinetune-P60_etab
	else
	dc	P60_fxdone-P60_etab
	endc

	ifne	P60_pl
	dc	P60_patternloop-P60_etab
	else
	dc	P60_fxdone-P60_etab
	endc

	dc	P60_fxdone-P60_etab

	ifne	P60_timing
	dc	P60_sete8-P60_etab
	else
	dc	P60_fxdone-P60_etab
	endc

	ifne	P60_rt
	dc	P60_setretrig-P60_etab
	else
	dc	P60_fxdone-P60_etab
	endc

	ifne	P60_fvu
	dc	P60_finevup-P60_etab
	else
	dc	P60_fxdone-P60_etab
	endc

	ifne	P60_fvd
	dc	P60_finevdwn-P60_etab
	else
	dc	P60_fxdone-P60_etab
	endc

	dc	P60_fxdone-P60_etab

	ifne	P60_nd
	dc	P60_ndelay-P60_etab
	else
	dc	P60_fxdone-P60_etab
	endc

	ifne	P60_pde
	dc	P60_pattdelay-P60_etab
	else
	dc	P60_fxdone-P60_etab
	endc

	ifne	P60_il
	dc	P60_funk-P60_etab
	else
	dc	P60_fxdone-P60_etab
	endc
	endc

	ifne	P60_fi
P60_filter
	move.b	P60_Info(a5),d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	bra	P60_fxdone
	endc

	ifne	P60_fsu
P60_fineup
	P60_getnote

	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	sub	d0,P60_Period(a5)
	moveq	#113,d0
	cmp	P60_Period(a5),d0
	ble.b	.jup
	move	d0,P60_Period(a5)
.jup	moveq	#$7e,d0
	and.b	(a5),d0
	bne	P60_zample
	bra	P60_nocha
	endc

	ifne	P60_fsd
P60_finedwn
	P60_getnote

	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	add	d0,P60_Period(a5)
	cmp	#856,P60_Period(a5)
	ble.b	.jup
	move	#856,P60_Period(a5)
.jup	moveq	#$7e,d0
	and.b	(a5),d0
	bne	P60_zample
	bra	P60_nocha
	endc

	ifne	P60_sft
P60_setfinetune
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	ifeq	opt020
	add	d0,d0
	move	P60_mulutab(pc,d0),P60_Fine(a5)
	else
	move	P60_mulutab(pc,d0*2),P60_Fine(a5)
	endc
	bra	P60_fxdone

P60_mulutab
	dc	0,74,148,222,296,370,444,518,592,666,740,814,888,962,1036,1110
	endc

	ifne	P60_pl
P60_patternloop
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	beq.b	P60_setloop

	tst.b	P60_plflag-P60_cn(a3)
	bne.b	P60_noset

	move	d0,P60_plcount-P60_cn(a3)
	st.b	P60_plflag-P60_cn(a3)
P60_noset
	tst	P60_plcount-P60_cn(a3)
	bne.b	P60_looppaa
	clr.b	P60_plflag-P60_cn(a3)
	bra	P60_fxdone
	
P60_looppaa
	st.b	P60_plflag+1-P60_cn(a3)
	subq	#1,P60_plcount-P60_cn(a3)
	bra	P60_fxdone

P60_setloop
	tst.b	P60_plflag-P60_cn(a3)
	bne	P60_fxdone
	move	P60_rowpos(pc),P60_plrowpos-P60_cn(a3)
	lea	P60_temp0+P60_TData(pc),a1
	lea	P60_looppos(pc),a0
	moveq	#channels-1,d0
.talt	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1),(a0)+
	subq.l	#8,a1
	add.l	d6,a1
	dbf	d0,.talt
	bra	P60_fxdone
	endc

	ifne	P60_fvu
P60_finevup
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	add	d0,P60_Volume(a5)
	moveq	#64,d0
	cmp	P60_Volume(a5),d0
	bge	P60_fxdone
	move	d0,P60_Volume(a5)
	bra	P60_fxdone
	endc

	ifne	P60_fvd
P60_finevdwn
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	sub	d0,P60_Volume(a5)
	bpl	P60_fxdone
	clr	P60_Volume(a5)
	bra	P60_fxdone
	endc

	ifne	P60_timing
P60_sete8
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	move	d0,P60_E8-P60_cn(a3)
	bra	P60_fxdone
	endc

	ifne	P60_rt
P60_setretrig
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	move	d0,P60_RetrigCount(a5)
	bra	P60_fxdone
	endc

	ifne	P60_nd
P60_ndelay
	moveq	#$7e,d0
	and.b	(a5),d0
	beq	P60_skip
	ifne	P60_vib
	clr.b	P60_VibPos(a5)
	endc
	ifne	P60_tre
	clr.b	P60_TrePos(a5)
	endc
	ifne	P60_ft
	add	P60_Fine(a5),d0
	endc
	move	d0,P60_Note(a5)
	move	(a2,d0),P60_Period(a5)
	ifeq	fade
	move	P60_Volume(a5),8(a4)
	else
	move	P60_Volume(a5),P60_Shadow(a5)
	endc
	bra	P60_skip
	endc

	ifne	P60_pde
P60_pattdelay
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	move	d0,P60_pdelay-P60_cn(a3)
	bra	P60_fxdone
	endc

	ifne	P60_sd
P60_cspeed
	move.b	P60_Info(a5),d0

	ifne	CIA
	tst	P60_Tempo-P60_cn(a3)
	beq.b	P60_VBlank
	cmp.b	#32,d0
	bhs.b	P60_STempo
	endc

P60_VBlank
	cmp.b	#1,d0
	beq.b	P60_jkd

	move.b	d0,P60_speed+1-P60_cn(a3)
	subq.b	#1,d0
	move.b	d0,P60_speed2+1-P60_cn(a3)
	clr	P60_speedis1-P60_cn(a3)
	bra	P60_fxdone

P60_jkd	move.b	d0,P60_speed+1-P60_cn(a3)
	move.b	d0,P60_speed2+1-P60_cn(a3)
	st	P60_speedis1-P60_cn(a3)
	bra	P60_fxdone


	ifne	CIA
P60_STempo
	move.l	P60_timer(pc),d1
	divu	d0,d1
	move	d1,P60_thi2-P60_cn(a3)
	sub	#$1c8*2,d1
	move	d1,P60_thi-P60_cn(a3)
	bra	P60_fxdone
	endc
	endc

	ifne	P60_vbvs
P60_vibochvslide
	move.b	P60_Info(a5),d0
	sub.b	d0,P60_Volume+1(a5)
	bpl.b	P60_test62
	clr	P60_Volume(a5)
	ifeq	fade
	clr	8(a4)
	else
	clr	P60_Shadow(a5)
	endc
	bra.b	P60_vib2
P60_test62
	moveq	#64,d0
	cmp	P60_Volume(a5),d0
	bge.b	.ncs2
	move	d0,P60_Volume(a5)
.ncs2
	ifeq	fade
	move	P60_Volume(a5),8(a4)
	else
	move	P60_Volume(a5),P60_Shadow(a5)
	endc
	endc

	ifne	P60_vib
P60_vib2
	move	#$f00,d0
	move	P60_VibCmd(a5),d1
	and	d1,d0
	lsr	#2,d0
	
	lsr	#1,d1
	and	#$3e,d1
	add	d1,d0

	move	P60_Period(a5),d1
	tst.b	P60_VibPos(a5)
	bmi.b	.vibneg
	add	P60_vibtab(pc,d0),d1
	bra.b	P60_vib4

.vibneg	sub	P60_vibtab(pc,d0),d1

P60_vib4
	move	d1,6(a4)
	move.b	P60_VibCmd(a5),d0
	lsr.b	#2,d0
	and	#$3c,d0
	add.b	d0,P60_VibPos(a5)
	bra	P60_contfxdone
	endc

	ifne	P60_tre
P60_tremo
	move	#$f00,d0
	move	P60_TreCmd(a5),d1
	and	d1,d0
	lsr	#2,d0
	
	lsr	#1,d1
	and	#$3e,d1
	add	d1,d0

	move	P60_Volume(a5),d1
	tst.b	P60_TrePos(a5)
	bmi.b	.treneg
	add	P60_vibtab(pc,d0),d1
	cmp	#64,d1
	ble.b	P60_tre4
	moveq	#64,d1
	bra.b	P60_tre4

.treneg	sub	P60_vibtab(pc,d0),d1
	bpl.b	P60_tre4
	moveq	#0,d1
P60_tre4
	ifeq	fade
	move	d1,8(a4)
	else
	move	d1,P60_Shadow(a5)
	endc

	move.b	P60_TreCmd(a5),d0
	lsr.b	#2,d0
	and	#$3c,d0
	add.b	d0,P60_TrePos(a5)
	bra	P60_contfxdone
	endc

	ifne	P60_vib!P60_tre
P60_vibtab	incbin	vibtab
	endc

	ifne	P60_il
P60_funk
	moveq	#$f,d0
	and.b	P60_Info(a5),d0
	move.b	d0,P60_Funkspd(a5)
	bra	P60_fxdone

P60_funk2
	moveq	#0,d0
	move.b	P60_Funkspd(a5),d0
	beq.b	P60_funkend
	move.b	P60_FunkTable(pc,d0),d0
	add.b	d0,P60_Funkoff(a5)
	bpl.b	P60_funkend
	clr.b	P60_Funkoff(a5)

	move.l	P60_Sample(a5),a1
	move.l	P60_RepeatOffset(a1),d1
	move	P60_RepeatLength(a1),d0
	add.l	d0,d0
	add.l	d1,d0
	move.l	P60_Wave(a5),a0
	addq.l	#1,a0
	cmp.l	d0,a0
	blo.b	P60_funkok
	move.l	d1,a0
P60_funkok
	move.l	a0,P60_Wave(a5)
	not.b	(a0)
P60_funkend
	rts

P60_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
	endc

P60_jtab
	dc	P60_fxdone-*
	dc	P60_fxdone-*
	dc	P60_fxdone-*

	ifne	P60_tp
	dc	P60_settoneport-*
	else
	dc	P60_fxdone-*
	endc

	ifne	P60_vib
	dc	P60_vibrato-*
	else
	dc	P60_fxdone-*
	endc

	ifne	P60_tpvs
	dc	P60_toponochange-*
	else
	dc	P60_fxdone-*
	endc

	dc	P60_fxdone-*

	ifne	P60_tre
	dc	P60_settremo-*
	else
	dc	P60_fxdone-*
	endc

	dc	P60_fxdone-*

	ifne	P60_sof
	dc	P60_sampleoffse-*
	else
	dc	P60_fxdone-*
	endc
	dc	P60_fxdone-*

	ifne	P60_pj
	dc	P60_posjmp-*
	else
	dc	P60_fxdone-*
	endc

	ifne	P60_vl
	dc	P60_volum-*
	else
	dc	P60_fxdone-*
	endc

	ifne	P60_pb
	dc	P60_pattbreak-*
	else
	dc	P60_fxdone-*
	endc

	ifne	P60_ec
	dc	P60_ecommands-*
	else
	dc	P60_fxdone-*
	endc
	
	ifne	P60_sd
	dc	P60_cspeed-*
	else
	dc	P60_fxdone-*
	endc

P60_dmason
	ifeq	system
	tst.b	$bfdd00
	move.l	a0,-(sp)
	move.l	P60_vektori(pc),a0
	move.l	P60_intaddr(pc),(a0)
	move.l	(sp)+,a0
	move	P60_dma(pc),$dff096
	move	#$2000,$dff09c
	move.b	#$19,$bfde00
	rte

	else
	move	P60_dma(pc),$96(a6)
	addq	#1,P60_server-P60_cn(a3)
	move.l	P60_craddr(pc),a0
	move.b	#$19,(a0)
	bra	P60_ohi
	endc


P60_setrepeat
	ifeq	system
	tst.b	$bfdd00
	movem.l	a0/a1,-(sp)
	lea	$dff0a0,a1
	else
	lea	$a0(a6),a1
	endc

	move.l	P60_Sample+P60_temp0(pc),a0
	addq.l	#6,a0
	move.l	(a0)+,(a1)+
	move	(a0),(a1)

	ifgt	channels-1
	move.l	P60_Sample+P60_temp1(pc),a0
	addq.l	#6,a0
	move.l	(a0)+,12(a1)
	move	(a0),16(a1)
	endc
	
	ifgt	channels-2
	move.l	P60_Sample+P60_temp2(pc),a0
	addq.l	#6,a0
	move.l	(a0)+,28(a1)
	move	(a0),32(a1)
	endc

	ifgt	channels-3
	move.l	P60_Sample+P60_temp3(pc),a0
	addq.l	#6,a0
	move.l	(a0)+,44(a1)
	move	(a0),48(a1)
	endc

	ifne	system
	clr	P60_server-P60_cn(a3)
	move.l	P60_craddr+4(pc),a0
	move.b	P60_tlo(pc),(a0)
	move.b	P60_thi(pc),$100(a0)
	bra	P60_ohi
	else

	move	#$2000,-8(a1)
	ifne	CIA
	move.l	P60_vektori(pc),a0
	move.l	P60_tintti(pc),(a0)
	move.b	P60_tlo(pc),$bfd400
	move.b	P60_thi(pc),$bfd500
	endc

	movem.l	(sp)+,a0/a1
	rte
	endc

P60_temp0
	dcb.b	Channel_Block_SIZE-2
	dc	1
P60_temp1
	dcb.b	Channel_Block_SIZE-2
	dc	2
P60_temp2
	dcb.b	Channel_Block_SIZE-2
	dc	4
P60_temp3
	dcb.b	Channel_Block_SIZE-2
	dc	8

P60_cn	dc	0
P60_dma	dc	$8200
P60_rowpos
	dc	0
P60_speed
	dc	0
P60_speed2
	dc	0
P60_speedis1
	dc	0
P60_spos
	dc.l	0
	ifeq	system
P60_vektori
	dc.l	0
	endc
P60_ofilter
	dc	0
	ifne	CIA
P60_tintti
	dc.l	0
P60_thi	dc.b	0
P60_tlo	dc.b	0
P60_thi2
	dc.b	0
P60_tlo2
	dc.b	0
P60_timer
	dc.l	0
	endc

	ifne	P60_pl
P60_plcount
	dc	0
P60_plflag
	dc	0
P60_plreset
	dc	0
P60_plrowpos
	dc	0
P60_looppos
	dcb.b	12*channels
	endc

	ifne	P60_pde
P60_pdelay
	dc	0
	endc
P60_Samples
	dcb.b	16*31
P60_positionbase
	dc.l	0
P60_possibase
	dc.l	0
P60_patternbase
	dc.l	0
P60_intaddr
	dc.l	0
P60_oldlev6
	dc.l	0
	ifne	system
P60_server
	dc	0
P60_miscbase	dc.l	0
P60_audioopen	dc.b	0
P60_sigbit	dc.b	-1
P60_ciares	dc.l	0
P60_craddr	dc.l	0,0,0

P60_dat		dc	$f00
P60_timerinterrupt
		dc	0,0,0,0,127
P60_timerdata	dc.l	0,0,0

P60_allocport	dc.l	0,0
		dc.b	4,0
		dc.l	0
		dc.b	0,0
		dc.l	0
P60_reqlist	dc.l	0,0,0
		dc.b	5,0
P60_allocreq	dc.l	0,0
		dc	127
		dc.l	0
P60_portti	dc.l	0
		dc	68
		dc.l	0,0,0
		dc	0
P60_reqdata	dc.l	0
		dc.l	1,0,0,0,0,0,0
		dc	0
P60_audiodev	dc.b	'audio.device',0

P60_cianame	dc.b	'ciax.resource',0
P60_timeropen	dc.b	0
P60_timerint	dc.b	'P60TimerInterrupt',0
	endc
P60_etu
