
**	$Filename: Player61.i $
**	$Release: 6.1A $
**	$Revision: 610.1 $
**	$Date: 94/12/23 $
**
**	The Player 6.1A definitions
**
**	(C) Copyright 1992-94 Jarno Paananen
**	All Rights Reserved
**

lev6 =	1	;0 = NonLev6 (non implementato)
		;1 = Lev6 used

channels = 4	;amount of channels to be played


STRUCTURE   MACRO		; structure name, initial offset
\1	    EQU     0
SOFFSET     SET     \2
	    ENDM

UBYTE	    MACRO		; unsigned byte (8 bits)
\1	    EQU     SOFFSET
SOFFSET     SET     SOFFSET+1
	    ENDM

UWORD	    MACRO		; unsigned word (16 bits)
\1	    EQU     SOFFSET
SOFFSET     SET     SOFFSET+2
	    ENDM

ULONG	    MACRO		; unsigned long (32 bits)
\1	    EQU     SOFFSET
SOFFSET     SET     SOFFSET+4
	    ENDM

APTR	    MACRO		; untyped pointer (32 bits - all bits valid)
\1	    EQU     SOFFSET
SOFFSET     SET     SOFFSET+4
	    ENDM

LABEL	    MACRO		; Define a label without bumping the offset
\1	    EQU     SOFFSET
	    ENDM

**************
* The header *
**************

  STRUCTURE Player_Header,0
** Instructions to jump to P61_Init
	ULONG	P61_InitOffset
** ... to P61_Music (rts, if CIA-Version)
	ULONG	P61_MusicOffset
** ... to P61_End
	ULONG	P61_EndOffset
** ... to P61_SetRepeat (if present, otherwise rts)
	ULONG	P61_SetRepeatOffset
** ... to P61_SetPosition
	ULONG	P61_SetPositionOffset
** Master volume (used if told to...)
	UWORD	P61_MasterVolume
** If non-zero, tempo will be used
	UWORD	P61_UseTempo
** If zero, playing is stopped
	UWORD	P61_PlayFlag
** Info nybble after command E8
	UWORD	P61_E8_info
** Vector Base Register VBR passed to the player (default 0)
	APTR	P61_UseVBR
** Current song position
	UWORD	P61_Position
** Current pattern
	UWORD	P61_Pattern
** Current row
	UWORD	P61_Row
** Offset to channel 0 block from the beginning
	APTR	P61_Cha0Offset
** Offset to channel 1 block from the beginning
	APTR	P61_Cha1Offset
** Offset to channel 2 block from the beginning
	APTR	P61_Cha2Offset
** Offset to channel 3 block from the beginning
	APTR	P61_Cha3Offset

	LABEL Player_Header_SIZE


*********************************************************
** The structure of the channel blocks (P61_Temp[0-3]) **
*********************************************************

  STRUCTURE Channel_Block,0

** Note and the MSB of the sample number
	UBYTE	P61_SN_Note
** Lower nybble of the sample number and the command
	UBYTE	P61_Command
** Info byte
	UBYTE	P61_Info
** Packing info
	UBYTE	P61_Pack
** Pointer to the sample block of the current sample
	APTR	P61_Sample
** Current note (offset to the period table)
	UWORD	P61_Note
** Period
	UWORD	P61_Period
** Volume (NOT updated in tremolo!)
	UWORD	P61_Volume
** Current finetune
	UWORD	P61_Fine
** Sample offset
	UWORD	P61_Offset
** Last sample Offset
	UWORD	P61_LOffset
** To period for tone portamento
	UWORD	P61_ToPeriod
** Speed for tone portamento
	UWORD	P61_TPSpeed
** Vibrato command
	UBYTE	P61_VibCmd
** Vibrato position
	UBYTE	P61_VibPos
** Tremolo command
	UBYTE	P61_TreCmd
** Tremolo position
	UBYTE	P61_TrePos
** Retrig note counter
	UWORD	P61_RetrigCount

** Invert loop speed
	UBYTE	P61_Funkspd
** Invert loop offset
	UBYTE	P61_Funkoff
** Invert loop offset
	APTR	P61_Wave

** Internal switch to the packing
	UWORD	P61_OnOff
** Pointer to the current pattern data
	APTR	P61_ChaPos
** A packing pointer to data elsewhere in the pattern data
	APTR	P61_TempPos
** Lenght of the temporary positions
	UWORD	P61_TempLen
** Temp pointers for patternloop
	UWORD	P61_TData
	APTR	P61_TChaPos
	APTR	P61_TTempPos
	UWORD	P61_TTempLen

** Shadow address for fading (updated also in tremolo!)
	UWORD	P61_Shadow

** Bit in DMACON ($DFF096)
	UWORD	P61_DMABit

	LABEL Channel_Block_SIZE



************************************************
** The structure of the sample block that     **
** the Player does at the init to P61_Samples **
************************************************

  STRUCTURE Sample_Block,0

** Pointer to the beginning of the sample
	APTR	P61_SampleOffset
** Lenght of the sample
	UWORD	P61_SampleLength
** Pointer to the repeat
	APTR	P61_RepeatOffset
** Lenght of the repeat
	UWORD	P61_RepeatLength
** Volume of the sample
	UWORD	P61_SampleVolume
** Finetune (offset to the period table)
	UWORD	P61_FineTune

	LABEL Sample_Block_SIZE

************************************************
** Some internal stuff for the Usecode-system **
************************************************


** if finetune is used
P61_ft = use&1
** portamento up
P61_pu = use&2
** portamento down
P61_pd = use&4
** tone portamento
P61_tp = use&40
** vibrato
P61_vib = use&80
** tone portamento and volume slide
P61_tpvs = use&32
** vibrato and volume slide
P61_vbvs = use&64
** tremolo
P61_tre = use&$80
** arpeggio
P61_arp = use&$100
** sample offset
P61_sof = use&$200
** volume slide
P61_vs = use&$400
** position jump
P61_pj = use&$800
** set volume
P61_vl = use&$1000
** pattern break
P61_pb = use&$2800
** set speed
P61_sd = use&$8000

** E-commands
P61_ec = use&$ffff0000

** filter
P61_fi = use&$10000
** fine slide up
P61_fsu = use&$20000
** fine slide down
P61_fsd = use&$40000
** set finetune
P61_sft = use&$200000
** pattern loop
P61_pl = use&$400000
** E8 for timing purposes
P61_timing = use&$1000000
** retrig note
P61_rt = use&$2000000
** fine volume slide up
P61_fvu = use&$4000000
** fine volume slide down
P61_fvd = use&$8000000
** note cut
P61_nc = use&$10000000
** note delay
P61_nd = use&$20000000
** pattern delay
P61_pde = 1	;use&$40000000 buggato, va tenuto sempre ad 1!
** invert loop
P61_il = use&$80000000


*-----------------------------------------------*

	printt	""
	printt	"Options used:"
	printt	"-------------"
	ifd	startP
;	printt	"Starting from position"
;	printv	startP
	endc
	ifne	fade
	printt	"Mastervolume on"
	else
	printt	"Mastervolume off"
	endc
	ifne	system
	printt	"System friendly"
	else
	printt	"System killer"
	endc
	ifne	CIA
	printt	"CIA-tempo on"
	else
	printt	"CIA-tempo off"
	endc
	ifne	exec
	printt	"ExecBase valid"
	else
	printt	"ExecBase invalid"
	endc
	ifne	lev6
	printt	"Level 6 IRQ on"
	else
;	printt	"Non-lev6 NOT IMPLEMENTED!"
	if2
	fail
	endc
	endc
	ifne	opt020
	printt	"MC68020 optimizations"
	else
	printt	"Normal MC68000 code"
	endc
;	printt	"Channels:"
;	printv	channels
	ifgt	channels-4
;	printt	"NO MORE THAN 4 CHANNELS!"
	if2
	fail
	endc
	endc
	ifeq	channels
;	printt	"MUST HAVE AT LEAST 1 CHANNEL!"
	if2
	fail
	endc
	endc
;	printt	"UseCode:"
;	printv	use

*-----------------------------------------------*

*********************************
*        Player 6.1A о		*
*      All in one-version	*
*        Version 610.1		*
*   й 1992-95 Jarno Paananen	*
*     All rights reserved	*
*********************************


******** START OF BINARY FILE **************

P61_motuuli
	bra	P61_Init
	ifeq	CIA
	bra	P61_Music
	else
	rts
	rts
	endc
	bra	P61_End
	rts				;no P61_SetRepeat
	rts
	bra	P61_SetPosition

P61_Master	dc	64		;Master volume (0-64)
P61_Tempo	dc	1		;Use tempo? 0=no,non-zero=yes
P61_Play	dc	1		;Stop flag (0=stop)
P61_E8		dc	0		;Info nybble after command E8
P61_VBR		dc.l	0		;If you're using non-valid execbase
					;put VBR here! (Otherwise 0 assumed)
					;You can also get VBR from here, if
					;using exec-valid version

P61_Pos		dc	0		;Current song position
P61_Patt	dc	0		;Current pattern
P61_CRow	dc	0		;Current pattern row

P61_Temp0Offset
	dc.l	P61_temp0-P61_motuuli
P61_Temp1Offset
	dc.l	P61_temp1-P61_motuuli
P61_Temp2Offset
	dc.l	P61_temp2-P61_motuuli
P61_Temp3Offset
	dc.l	P61_temp3-P61_motuuli

P61_getnote	macro
	moveq	#$7e,d0
	and.b	(a5),d0
	beq.b	.nonote
	ifne	P61_vib
	clr.b	P61_VibPos(a5)
	endc
	ifne	P61_tre
	clr.b	P61_TrePos(a5)
	endc

	ifne	P61_ft
	add	P61_Fine(a5),d0
	endc
	move	d0,P61_Note(a5)
	move	(a2,d0),P61_Period(a5)

.nonote
	endm

	ifeq	system
	ifne	CIA
P61_intti
	movem.l	d0-a6,-(sp)
	tst.b	$bfdd00
	lea	$dff000,a6
	move	#$2000,$9c(a6)
;	move	#$fff,$180(a6)
	bsr	P61_Music
;	move	#0,$180(a6)
	movem.l	(sp)+,d0-a6
	nop
	rte
	endc
	endc

	ifne	system
P61_lev6server
	movem.l	d2-d7/a2-a6,-(sp)
	lea	$dff000,a6

	move	P61_server(pc),d0
	beq.b	P61_musica
	subq	#1,d0
	beq	P61_dmason
	bra	P61_setrepeat

P61_musica
	bsr	P61_Music

P61_ohi	movem.l	(sp)+,d2-d7/a2-a6
	moveq	#1,d0
	rts
	endc

;нннннннннннннннннннннннннннннннннннннннннннннннн
;н Call P61_Init to initialize the playroutine	н
;н D0 --> Timer detection (for CIA-version)	н
;н A0 --> Address to the module			н
;н A1 --> Address to samples/0			н
;н A2 --> Address to sample buffer		н
;н D0 <-- 0 if succeeded			н
;н A6 <-- $DFF000				н
;н 		Uses D0-A6			н
;нннннннннннннннннннннннннннннннннннннннннннннннн

P61_Init
	cmp.l	#"P61A",(a0)+
	beq.b	.modok
	subq.l	#4,a0

.modok	basereg	P61_cn,a3

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

	lea	P61_cn(pc),a3
	moveq	#$1f,d1
	and.b	3(a0),d1
	move.l	a0,-(sp)
	lea	P61_Samples(pc),a4
	subq	#1,d1
	moveq	#0,d4
P61_lopos
	move.l	a6,(a4)+
	move	(a2)+,d4
	bpl.b	P61_kook
	neg	d4
	lea	P61_Samples-16(pc),a5
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
	bra.b	P61_jatk

P61_kook
	move.l	a6,d6
	tst.b	3(a0)
	bpl.b	P61_jatk

	tst.b	(a2)
	bmi.b	P61_jatk

	move	d4,d0
	subq	#2,d0
	bmi.b	P61_jatk

	move.l	a1,a5
	move.b	(a5)+,d2
	sub.b	(a5),d2
	move.b	d2,(a5)+
.loop	sub.b	(a5),d2
	move.b	d2,(a5)+
	sub.b	(a5),d2
	move.b	d2,(a5)+
	dbf	d0,.loop

P61_jatk
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
	bra.b	P61_gene
.norepeat
	move.l	d6,(a4)+
	move	#1,(a4)+
P61_gene
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
	move.l	d4,d6
	add.l	d6,d6
	add.l	d6,a6
	add.l	d6,a1
.kop	dbf	d1,P61_lopos

	move.l	(sp)+,a0
	and.b	#$7f,3(a0)

	move.l	a2,-(sp)

	lea	P61_temp0(pc),a1
	lea	P61_temp1(pc),a2
	lea	P61_temp2(pc),a4
	lea	P61_temp3(pc),a5
	moveq	#Channel_Block_SIZE/2-2,d0

	moveq	#0,d1
.cl	move	d1,(a1)+
	move	d1,(a2)+
	move	d1,(a4)+
	move	d1,(a5)+
	dbf	d0,.cl

	move.l	(sp)+,a2
	move.l	a2,P61_positionbase(a3)

	moveq	#$7f,d1
	and.b	2(a0),d1

	ifeq	opt020
	lsl	#3,d1
	lea	(a2,d1.l),a4
	else
	lea	(a2,d1.l*8),a4
	endc
	move.l	a4,P61_possibase(a3)

	move.l	a4,a1
	moveq	#-1,d0
.search	cmp.b	(a1)+,d0
	bne.b	.search
	move.l	a1,P61_patternbase(a3)	
	move.l	a1,d0
	sub.l	a4,d0
	move	d0,P61_slen(a3)

	ifd	startP
	lea	startP(a4),a4
	endc

	moveq	#0,d0
	move.b	(a4)+,d0
	move.l	a4,P61_spos(a3)
	lsl	#3,d0
	add.l	d0,a2

	move.l	a1,a4
	moveq	#0,d0	
	move	(a2)+,d0
	lea	(a4,d0.l),a1
	move.l	a1,P61_ChaPos+P61_temp0(a3)
	move	(a2)+,d0
	lea	(a4,d0.l),a1
	move.l	a1,P61_ChaPos+P61_temp1(a3)
	move	(a2)+,d0
	lea	(a4,d0.l),a1
	move.l	a1,P61_ChaPos+P61_temp2(a3)
	move	(a2)+,d0
	lea	(a4,d0.l),a1
	move.l	a1,P61_ChaPos+P61_temp3(a3)

	lea	P61_setrepeat(pc),a0
	move.l	a0,P61_intaddr(a3)

	move	#63,P61_rowpos(a3)
	move	#6,P61_speed(a3)
	move	#5,P61_speed2(a3)
	clr	P61_speedis1(a3)

	ifne	P61_pl
	clr.l	P61_plcount(a3)
	endc

	ifne	P61_pde
	clr	P61_pdelay(a3)
	clr	P61_pdflag(a3)
	endc
	clr	(a3)

	moveq	#2,d0
	and.b	$bfe001,d0
	move.b	d0,P61_ofilter(a3)
	bset	#1,$bfe001

	ifeq	system
	ifne	exec
	move.l	4.w,a6
	moveq	#0,d0
	btst	d0,297(a6)
	beq.b	.no68010

	lea	P61_liko(pc),a5
	jsr	-$1e(a6)

.no68010
	move.l	d0,P61_VBR(a3)
	endc

	move.l	P61_VBR(a3),a0
	lea	$78(a0),a0
	move.l	a0,P61_vektori(a3)

	move.l	(a0),P61_oldlev6(a3)
	lea	P61_dmason(pc),a1
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
	lea	P61_dmason(pc),a1
	move.l	a1,(a0)
	move	#$2000,$9a(a6)
	lea	$bfd000,a0
	lea	P61_Timers(pc),a1
	move.b	#$7f,$d00(a0)
	move.b	#$10,$e00(a0)
	move.b	#$10,$f00(a0)
	move.b	$400(a0),(a1)+
	move.b	$500(a0),(a1)+
	move.b	$600(a0),(a1)+
	move.b	$700(a0),(a1)
	endc

	ifeq	system!CIA
	move.b	#$82,$d00(a0)
	endc

	ifne	CIA
	move	(sp)+,d0
	subq	#1,d0
	beq.b	P61_ForcePAL
	subq	#1,d0
	beq.b	P61_NTSC
	ifne	exec
	move.l	4.w,a1
	cmp.b	#60,$213(a1)	;PowerSupplyFrequency
	beq.b	P61_NTSC
	endc
P61_ForcePAL
	move.l	#1773447,d0	;PAL
	bra.b	P61_setcia
P61_NTSC
	move.l	#1789773,d0	;NTSC
P61_setcia
	move.l	d0,P61_timer(a3)
	divu	#125,d0
	move	d0,P61_thi2(a3)
	sub	#$1f0*2,d0
	move	d0,P61_thi(a3)

	ifeq	system
	move	P61_thi2(a3),d0
	move.b	d0,$400(a0)
	lsr	#8,d0
	move.b	d0,$500(a0)
	lea	P61_intti(pc),a1
	move.l	a1,P61_tintti(a3)
	move.l	P61_vektori(pc),a2
	move.l	a1,(a2)
	move.b	#$83,$d00(a0)
	move.b	#$11,$e00(a0)
	endc
	endc

	ifeq	system
	move	#$e000,$9a(a6)
	moveq	#0,d0
	rts

	ifne	exec
P61_liko
	dc.l	$4E7A0801		;MOVEC	VBR,d0
	rte
	endc
	endc

	ifne	system
	move.l	a6,-(sp)

	ifne	CIA
	clr	P61_server(a3)
	else
	move	#1,P61_server(a3)
	endc

	move.l	4.w,a6
	moveq	#-1,d0
	jsr	-$14a(a6)
	move.b	d0,P61_sigbit(a3)
	bmi	P61_err

	lea	P61_allocport(pc),a1
	move.l	a1,P61_portti(a3)
	move.b	d0,15(a1)
	move.l	a1,-(sp)
	suba.l	a1,a1
	jsr	-$126(a6)
	move.l	(sp)+,a1
	move.l	d0,16(a1)
	lea	P61_reqlist(pc),a0
	move.l	a0,(a0)
	addq.l	#4,(a0)
	clr.l	4(a0)
	move.l	a0,8(a0)

	lea	P61_dat(pc),a1
	move.l	a1,P61_reqdata(a3)
	lea	P61_allocreq(pc),a1
	lea	P61_audiodev(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	jsr	-$1bc(a6)
	tst.b	d0
	bne	P61_err
	st.b	P61_audioopen(a3)

	lea	P61_timerint(pc),a1
	move.l	a1,P61_timerdata(a3)
	lea	P61_lev6server(pc),a1
	move.l	a1,P61_timerdata+8(a3)

	moveq	#0,d3
	lea	P61_cianame(pc),a1
P61_openciares
	moveq	#0,d0
	move.l	4.w,a6
	jsr	-$1f2(a6)
	move.l	d0,P61_ciares(a3)
	beq.b	P61_err
	move.l	d0,a6
	lea	P61_timerinterrupt(pc),a1
	moveq	#0,d0
	jsr	-6(a6)
	tst.l	d0
	beq.b	P61_gottimer
	addq.l	#4,d3
	lea	P61_timerinterrupt(pc),a1
	moveq	#1,d0
	jsr	-6(a6)
	tst.l	d0
	bne.b	P61_err

P61_gottimer
	lea	P61_craddr+8(pc),a6
	move.l	P61_ciaaddr(pc,d3),d0
	move.l	d0,(a6)
	sub	#$100,d0
	move.l	d0,-(a6)
	moveq	#2,d3
	btst	#9,d0
	bne.b	P61_timerB
	subq.b	#1,d3
	add	#$100,d0
P61_timerB
	add	#$900,d0
	move.l	d0,-(a6)
	move.l	d0,a0
	and.b	#%10000000,(a0)
	move.b	d3,P61_timeropen(a3)
	moveq	#0,d0

	ifne	CIA
	move.l	P61_craddr+4(pc),a1
	move.b	P61_tlo(pc),(a1)
	move.b	P61_thi(pc),$100(a1)
	endc
	or.b	#$19,(a0)
P61_pois
	move.l	(sp)+,a6
	rts

P61_err	moveq	#-1,d0
	bra.b	P61_pois
	rts

P61_ciaaddr
	dc.l	$bfd500,$bfd700
	endc

;нннннннннннннннннннннннннннннннннннннннннннннннн
;н     	Call P61_End to stop the music		н
;н   A6 --> Customchip baseaddress ($DFF000)	н
;н		Uses D0/D1/A0/A1/A3		н
;нннннннннннннннннннннннннннннннннннннннннннннннн

P61_End	moveq	#0,d0
	move	d0,$a8(a6)
	move	d0,$b8(a6)
	move	d0,$c8(a6)
	move	d0,$d8(a6)
	move	#$f,$96(a6)

	and.b	#~2,$bfe001
	move.b	P61_ofilter(pc),d0
	or.b	d0,$bfe001

	ifeq	system
	move	#$2000,$9a(a6)
	move.l	P61_vektori(pc),a0
	move.l	P61_oldlev6(pc),(a0)
	lea	$bfd000,a0
	lea	P61_Timers(pc),a1
	move.b	(a1)+,$400(a0)
	move.b	(a1)+,$500(a0)
	move.b	(a1)+,$600(a0)
	move.b	(a1)+,$700(a0)
	move.b	#$10,$e00(a0)
	move.b	#$10,$f00(a0)

	else
	move.l	a6,-(sp)
	lea	P61_cn(pc),a3
	moveq	#0,d0
	move.b	P61_timeropen(pc),d0
	beq.b	P61_rem1
	move.l	P61_ciares(pc),a6
	lea	P61_timerinterrupt(pc),a1
	subq.b	#1,d0
	jsr	-12(a6)
P61_rem1
	move.l	4.w,a6
	tst.b	P61_audioopen(a3)
	beq.b	P61_rem2
	lea	P61_allocreq(pc),a1
	jsr	-$1c2(a6)
	clr.b	P61_audioopen(a3)
P61_rem2
	moveq	#0,d0
	move.b	P61_sigbit(pc),d0
	bmi.b	P61_rem3
	jsr	-$150(a6)
	st	P61_sigbit(a3)
P61_rem3
	move.l	(sp)+,a6
	endc
	rts

	ifne	fade
P61_mfade
	move	P61_Master(pc),d0
	move	P61_temp0+P61_Shadow(pc),d1
	mulu	d0,d1
	lsr	#6,d1
	move	d1,$a8(a6)

	ifgt	channels-1
	move	P61_temp1+P61_Shadow(pc),d1
	mulu	d0,d1
	lsr	#6,d1
	move	d1,$b8(a6)
	endc

	ifgt	channels-2
	move	P61_temp2+P61_Shadow(pc),d1
	mulu	d0,d1
	lsr	#6,d1
	move	d1,$c8(a6)
	endc

	ifgt	channels-3
	move	P61_temp3+P61_Shadow(pc),d1
	mulu	d0,d1
	lsr	#6,d1
	move	d1,$d8(a6)
	endc
	rts
	endc
	

;нннннннннннннннннннннннннннннннннннннннннннннннн
;н Call P61_SetPosition to jump to a specific	н
;н	      position in the song.		н
;н D0.l --> Position				н
;н Starts from the beginning if out of limits.	н
;н          	Uses A0/A1/A3/D0-D3		н
;нннннннннннннннннннннннннннннннннннннннннннннннн

P61_SetPosition
	ifne	jump
	lea	P61_cn(pc),a3
	ifne	P61_pl
	clr	P61_plflag(a3)
	endc
	moveq	#0,d1
	move.b	d0,d1
	move.l	d1,d0
	cmp	P61_slen(a3),d0
	blo.b	.e
	moveq	#0,d0
.e	move	d0,P61_Pos(a3)
	add.l	P61_possibase(pc),d0
	move.l	d0,P61_spos(a3)

	moveq	#64,d0
	move	d0,P61_rowpos(a3)
	clr	P61_CRow(a3)
	move.l	P61_spos(pc),a1
	move.l	P61_patternbase(pc),a0
	addq	#1,P61_Pos(a3)
	move.b	(a1)+,d0
	move.l	a1,P61_spos(a3)
	move.l	P61_positionbase(pc),a1
	move	d0,P61_Patt(a3)
	lsl	#3,d0
	add.l	d0,a1
	movem	(a1),d0-d3
	lea	(a0,d0.l),a1
	move	d1,d0
	move.l	a1,P61_ChaPos+P61_temp0(a3)
	lea	(a0,d0.l),a1
	move.l	a1,P61_ChaPos+P61_temp1(a3)
	move	d2,d0
	lea	(a0,d0.l),a1
	move.l	a1,P61_ChaPos+P61_temp2(a3)
	move	d3,d0
	add.l	d0,a0
	move.l	a0,P61_ChaPos+P61_temp3(a3)
	rts
	endc

;нннннннннннннннннннннннннннннннннннннннннннннннн
;н Call P61_Music every frame to play the music	н
;н	  _NOT_ if CIA-version is used!		н
;н A6 --> Customchip baseaddress ($DFF000)	н
;н          	Uses A0-A5/D0-D7		н
;нннннннннннннннннннннннннннннннннннннннннннннннн

P61_Music
	lea	P61_cn(pc),a3

	tst	P61_Play(a3)
	bne.b	P61_ohitaaa
	ifne	CIA
	ifne	system
	move.l	P61_craddr+4(pc),a0
	move.b	P61_tlo2(pc),(a0)
	move.b	P61_thi2(pc),$100(a0)
	endc
	endc
	rts

P61_ohitaaa
	ifne	fade
	pea	P61_mfade(pc)
	endc

	moveq	#Channel_Block_SIZE,d6
	moveq	#16,d7

	move	(a3),d4
	addq	#1,d4
	cmp	P61_speed(pc),d4
	beq	P61_playtime

	move	d4,(a3)

P61_delay
	ifne	CIA
	ifne	system
	move.l	P61_craddr+4(pc),a0
	move.b	P61_tlo2(pc),(a0)
	move.b	P61_thi2(pc),$100(a0)
	endc
	endc

	lea	P61_temp0(pc),a5
	lea	$a0(a6),a4

	moveq	#channels-1,d5
P61_lopas
	tst	P61_OnOff(a5)
	beq	P61_contfxdone
	moveq	#$f,d0
	and	(a5),d0
	ifeq	opt020
	add	d0,d0
	move	P61_jtab2(pc,d0),d0
	else
	move	P61_jtab2(pc,d0*2),d0
	endc
	jmp	P61_jtab2(pc,d0)

P61_jtab2
	dc	P61_contfxdone-P61_jtab2

	ifne	P61_pu
	dc	P61_portup-P61_jtab2
	else
	dc	P61_contfxdone-P61_jtab2
	endc

	ifne	P61_pd
	dc	P61_portdwn-P61_jtab2
	else
	dc	P61_contfxdone-P61_jtab2
	endc

	ifne	P61_tp
	dc	P61_toneport-P61_jtab2
	else
	dc	P61_contfxdone-P61_jtab2
	endc

	ifne	P61_vib
	dc	P61_vib2-P61_jtab2
	else
	dc	P61_contfxdone-P61_jtab2
	endc

	ifne	P61_tpvs
	dc	P61_tpochvslide-P61_jtab2
	else
	dc	P61_contfxdone-P61_jtab2
	endc

	ifne	P61_vbvs
	dc	P61_vibochvslide-P61_jtab2
	else
	dc	P61_contfxdone-P61_jtab2
	endc

	ifne	P61_tre
	dc	P61_tremo-P61_jtab2
	else
	dc	P61_contfxdone-P61_jtab2
	endc

	ifne	P61_arp
	dc	P61_arpeggio-P61_jtab2
	else
	dc	P61_contfxdone-P61_jtab2
	endc

	dc	P61_contfxdone-P61_jtab2

	ifne	P61_vs
	dc	P61_volslide-P61_jtab2
	else
	dc	P61_contfxdone-P61_jtab2
	endc

	dc	P61_contfxdone-P61_jtab2
	dc	P61_contfxdone-P61_jtab2
	dc	P61_contfxdone-P61_jtab2

	ifne	P61_ec
	dc	P61_contecommands-P61_jtab2
	else
	dc	P61_contfxdone-P61_jtab2
	endc
	dc	P61_contfxdone-P61_jtab2

	ifne	P61_ec
P61_contecommands
	move.b	P61_Info(a5),d0
	and	#$f0,d0
	lsr	#3,d0
	move	P61_etab2(pc,d0),d0
	jmp	P61_etab2(pc,d0)

P61_etab2
	dc	P61_contfxdone-P61_etab2

	ifne	P61_fsu
	dc	P61_fineup2-P61_etab2
	else
	dc	P61_contfxdone-P61_etab2
	endc

	ifne	P61_fsd
	dc	P61_finedwn2-P61_etab2
	else
	dc	P61_contfxdone-P61_etab2
	endc

	dc	P61_contfxdone-P61_etab2
	dc	P61_contfxdone-P61_etab2

	dc	P61_contfxdone-P61_etab2
	dc	P61_contfxdone-P61_etab2

	dc	P61_contfxdone-P61_etab2
	dc	P61_contfxdone-P61_etab2

	ifne	P61_rt
	dc	P61_retrig-P61_etab2
	else
	dc	P61_contfxdone-P61_etab2
	endc

	ifne	P61_fvu
	dc	P61_finevup2-P61_etab2
	else
	dc	P61_contfxdone-P61_etab2
	endc

	ifne	P61_fvd
	dc	P61_finevdwn2-P61_etab2
	else
	dc	P61_contfxdone-P61_etab2
	endc

	ifne	P61_nc
	dc	P61_notecut-P61_etab2
	else
	dc	P61_contfxdone-P61_etab2
	endc

	ifne	P61_nd
	dc	P61_notedelay-P61_etab2
	else
	dc	P61_contfxdone-P61_etab2
	endc

	dc	P61_contfxdone-P61_etab2
	dc	P61_contfxdone-P61_etab2
	endc

	ifne	P61_fsu
P61_fineup2
	tst	(a3)
	bne	P61_contfxdone
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	sub	d0,P61_Period(a5)
	moveq	#113,d0
	cmp	P61_Period(a5),d0
	ble.b	.jup
	move	d0,P61_Period(a5)
.jup	move	P61_Period(a5),6(a4)
	bra	P61_contfxdone
	endc

	ifne	P61_fsd
P61_finedwn2
	tst	(a3)
	bne	P61_contfxdone
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	add	d0,P61_Period(a5)
	cmp	#856,P61_Period(a5)
	ble.b	.jup
	move	#856,P61_Period(a5)
.jup	move	P61_Period(a5),6(a4)
	bra	P61_contfxdone
	endc

	ifne	P61_fvu
P61_finevup2
	tst	(a3)
	bne	P61_contfxdone
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	add	d0,P61_Volume(a5)
	moveq	#64,d0
	cmp	P61_Volume(a5),d0
	bge.b	.jup
	move	d0,P61_Volume(a5)
.jup	move	P61_Volume(a5),8(a4)
	bra	P61_contfxdone
	endc

	ifne	P61_fvd
P61_finevdwn2
	tst	(a3)
	bne	P61_contfxdone
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	sub	d0,P61_Volume(a5)
	bpl.b	.jup
	clr	P61_Volume(a5)
.jup	move	P61_Volume(a5),8(a4)
	bra	P61_contfxdone
	endc

	ifne	P61_nc
P61_notecut
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	cmp	(a3),d0
	bne	P61_contfxdone
	ifeq	fade
	clr	8(a4)
	else
	clr	P61_Shadow(a5)
	endc
	clr	P61_Volume(a5)
	bra	P61_contfxdone
	endc

	ifne	P61_nd
P61_notedelay
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	cmp	(a3),d0
	bne	P61_contfxdone

	moveq	#$7e,d0
	and.b	(a5),d0
	beq	P61_contfxdone
	move	P61_DMABit(a5),d0
	move	d0,$96(a6)
	or	d0,P61_dma(a3)
	move.l	P61_Sample(a5),a1		;* Trigger *
	move.l	(a1)+,(a4)+			;Pointer
	move	(a1),(a4)+			;Length
	move	P61_Period(a5),(a4)
	subq.l	#6,a4

	ifeq	system
	lea	P61_dmason(pc),a1
	move.l	P61_vektori(pc),a0
	move.l	a1,(a0)
	move.b	#$f0,$bfd600
	move.b	#$01,$bfd700
	move.b	#$19,$bfdf00
	else
	move	#1,P61_server(a3)
	move.l	P61_craddr+4(pc),a1
	move.b	#$f0,(a1)
	move.b	#1,$100(a1)
	endc
	bra	P61_contfxdone
	endc

	ifne	P61_rt
P61_retrig
	subq	#1,P61_RetrigCount(a5)
	bne	P61_contfxdone
	move	P61_DMABit(a5),d0
	move	d0,$96(a6)
	or	d0,P61_dma(a3)
	move.l	P61_Sample(a5),a1		;* Trigger *
	move.l	(a1)+,(a4)			;Pointer
	move	(a1),4(a4)			;Length

	ifeq	system
	lea	P61_dmason(pc),a1
	move.l	P61_vektori(pc),a0
	move.l	a1,(a0)
	move.b	#$f0,$bfd600
	move.b	#$01,$bfd700
	move.b	#$19,$bfdf00
	else
	move	#1,P61_server(a3)
	move.l	P61_craddr+4(pc),a1
	move.b	#$f0,(a1)
	move.b	#1,$100(a1)
	endc

	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	move	d0,P61_RetrigCount(a5)
	bra	P61_contfxdone
	endc

	ifne	P61_arp
P61_arplist
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

P61_arpeggio
	move	(a3),d0
	move.b	P61_arplist(pc,d0),d0
	beq.b	.arp0
	subq.b	#1,d0
	beq.b	P61_arp1
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	bra.b	P61_arp3

.arp0	move	P61_Note(a5),d0
	move	P61_periods(pc,d0),6(a4)
	bra	P61_contfxdone
P61_arp1
	move.b	P61_Info(a5),d0
	lsr	#4,d0
P61_arp3
	add	d0,d0
	add	P61_Note(a5),d0
	move	P61_periods(pc,d0),6(a4)
	bra	P61_contfxdone
	endc

P61_periods
	ifne	P61_ft

	dc.w	$358,$358,$328,$2FA,$2D0,$2A6,$280,$25C,$23A,$21A
	dc.w	$1FC,$1E0,$1C5,$1AC,$194,$17D,$168,$153,$140,$12E
	dc.w	$11D,$10D,$FE,$F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97
	dc.w	$8F,$87,$7F,$78,$71,$352,$352,$322,$2F5,$2CB,$2A2
	dc.w	$27D,$259,$237,$217,$1F9,$1DD,$1C2,$1A9,$191,$17B
	dc.w	$165,$151,$13E,$12C,$11C,$10C,$FD,$EF,$E1,$D5,$C9
	dc.w	$BD,$B3,$A9,$9F,$96,$8E,$86,$7E,$77,$71,$34C,$34C
	dc.w	$31C,$2F0,$2C5,$29E,$278,$255,$233,$214,$1F6,$1DA
	dc.w	$1BF,$1A6,$18E,$178,$163,$14F,$13C,$12A,$11A,$10A
	dc.w	$FB,$ED,$E0,$D3,$C7,$BC,$B1,$A7,$9E,$95,$8D,$85
	dc.w	$7D,$76,$70,$346,$346,$317,$2EA,$2C0,$299,$274
	dc.w	$250,$22F,$210,$1F2,$1D6,$1BC,$1A3,$18B,$175,$160
	dc.w	$14C,$13A,$128,$118,$108,$F9,$EB,$DE,$D1,$C6,$BB
	dc.w	$B0,$A6,$9D,$94,$8C,$84,$7D,$76,$6F,$340,$340
	dc.w	$311,$2E5,$2BB,$294,$26F,$24C,$22B,$20C,$1EF,$1D3
	dc.w	$1B9,$1A0,$188,$172,$15E,$14A,$138,$126,$116,$106
	dc.w	$F7,$E9,$DC,$D0,$C4,$B9,$AF,$A5,$9C,$93,$8B,$83
	dc.w	$7C,$75,$6E,$33A,$33A,$30B,$2E0,$2B6,$28F,$26B
	dc.w	$248,$227,$208,$1EB,$1CF,$1B5,$19D,$186,$170,$15B
	dc.w	$148,$135,$124,$114,$104,$F5,$E8,$DB,$CE,$C3,$B8
	dc.w	$AE,$A4,$9B,$92,$8A,$82,$7B,$74,$6D,$334,$334
	dc.w	$306,$2DA,$2B1,$28B,$266,$244,$223,$204,$1E7,$1CC
	dc.w	$1B2,$19A,$183,$16D,$159,$145,$133,$122,$112,$102
	dc.w	$F4,$E6,$D9,$CD,$C1,$B7,$AC,$A3,$9A,$91,$89,$81
	dc.w	$7A,$73,$6D,$32E,$32E,$300,$2D5,$2AC,$286,$262
	dc.w	$23F,$21F,$201,$1E4,$1C9,$1AF,$197,$180,$16B,$156
	dc.w	$143,$131,$120,$110,$100,$F2,$E4,$D8,$CC,$C0,$B5
	dc.w	$AB,$A1,$98,$90,$88,$80,$79,$72,$6C,$38B,$38B
	dc.w	$358,$328,$2FA,$2D0,$2A6,$280,$25C,$23A,$21A,$1FC
	dc.w	$1E0,$1C5,$1AC,$194,$17D,$168,$153,$140,$12E,$11D
	dc.w	$10D,$FE,$F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F
	dc.w	$87,$7F,$78,$384,$384,$352,$322,$2F5,$2CB,$2A3
	dc.w	$27C,$259,$237,$217,$1F9,$1DD,$1C2,$1A9,$191,$17B
	dc.w	$165,$151,$13E,$12C,$11C,$10C,$FD,$EE,$E1,$D4,$C8
	dc.w	$BD,$B3,$A9,$9F,$96,$8E,$86,$7E,$77,$37E,$37E
	dc.w	$34C,$31C,$2F0,$2C5,$29E,$278,$255,$233,$214,$1F6
	dc.w	$1DA,$1BF,$1A6,$18E,$178,$163,$14F,$13C,$12A,$11A
	dc.w	$10A,$FB,$ED,$DF,$D3,$C7,$BC,$B1,$A7,$9E,$95,$8D
	dc.w	$85,$7D,$76,$377,$377,$346,$317,$2EA,$2C0,$299
	dc.w	$274,$250,$22F,$210,$1F2,$1D6,$1BC,$1A3,$18B,$175
	dc.w	$160,$14C,$13A,$128,$118,$108,$F9,$EB,$DE,$D1,$C6
	dc.w	$BB,$B0,$A6,$9D,$94,$8C,$84,$7D,$76,$371,$371
	dc.w	$340,$311,$2E5,$2BB,$294,$26F,$24C,$22B,$20C,$1EE
	dc.w	$1D3,$1B9,$1A0,$188,$172,$15E,$14A,$138,$126,$116
	dc.w	$106,$F7,$E9,$DC,$D0,$C4,$B9,$AF,$A5,$9C,$93,$8B
	dc.w	$83,$7B,$75,$36B,$36B,$33A,$30B,$2E0,$2B6,$28F
	dc.w	$26B,$248,$227,$208,$1EB,$1CF,$1B5,$19D,$186,$170
	dc.w	$15B,$148,$135,$124,$114,$104,$F5,$E8,$DB,$CE,$C3
	dc.w	$B8,$AE,$A4,$9B,$92,$8A,$82,$7B,$74,$364,$364
	dc.w	$334,$306,$2DA,$2B1,$28B,$266,$244,$223,$204,$1E7
	dc.w	$1CC,$1B2,$19A,$183,$16D,$159,$145,$133,$122,$112
	dc.w	$102,$F4,$E6,$D9,$CD,$C1,$B7,$AC,$A3,$9A,$91,$89
	dc.w	$81,$7A,$73,$35E,$35E,$32E,$300,$2D5,$2AC,$286
	dc.w	$262,$23F,$21F,$201,$1E4,$1C9,$1AF,$197,$180,$16B
	dc.w	$156,$143,$131,$120,$110,$100,$F2,$E4,$D8,$CB,$C0
	dc.w	$B5,$AB,$A1,$98,$90,$88,$80,$79,$72

	else

	dc.w	$358,$358,$328,$2FA,$2D0,$2A6,$280,$25C,$23A,$21A
	dc.w	$1FC,$1E0,$1C5,$1AC,$194,$17D,$168,$153,$140,$12E
	dc.w	$11D,$10D,$FE,$F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97
	dc.w	$8F,$87,$7F,$78,$71

	endc

	ifne	P61_vs
P61_volslide
	move.b	P61_Info(a5),d0
	sub.b	d0,P61_Volume+1(a5)
	bpl.b	.test
	clr	P61_Volume(a5)
	ifeq	fade
	clr	8(a4)
	else
	clr	P61_Shadow(a5)
	endc
	bra	P61_contfxdone
.test	moveq	#64,d0
	cmp	P61_Volume(a5),d0
	bge.b	.ncs
	move	d0,P61_Volume(a5)
	ifeq	fade
	move	d0,8(a4)
	else
	move	d0,P61_Shadow(a5)
	endc
	bra.b	P61_contfxdone
.ncs	ifeq	fade
	move	P61_Volume(a5),8(a4)
	else
	move	P61_Volume(a5),P61_Shadow(a5)
	endc
	bra.b	P61_contfxdone
	endc

	ifne	P61_tpvs
P61_tpochvslide
	move.b	P61_Info(a5),d0
	sub.b	d0,P61_Volume+1(a5)
	bpl.b	.test
	clr	P61_Volume(a5)
	ifeq	fade
	clr	8(a4)
	else
	clr	P61_Shadow(a5)
	endc
	bra.b	P61_toneport
.test	moveq	#64,d0
	cmp	P61_Volume(a5),d0
	bge.b	.ncs
	move	d0,P61_Volume(a5)
.ncs	ifeq	fade
	move	P61_Volume(a5),8(a4)
	else
	move	P61_Volume(a5),P61_Shadow(a5)
	endc
	endc

	ifne	P61_tp
P61_toneport
	move	P61_ToPeriod(a5),d0
	beq.b	P61_contfxdone
	move	P61_TPSpeed(a5),d1
	cmp	P61_Period(a5),d0
	blt.b	.topoup

	add	d1,P61_Period(a5)
	cmp	P61_Period(a5),d0
	bgt.b	P61_toposetper
	move	d0,P61_Period(a5)
	clr	P61_ToPeriod(a5)
	move	d0,6(a4)
	bra.b	P61_contfxdone

.topoup
	sub	d1,P61_Period(a5)
	cmp	P61_Period(a5),d0
	blt.b	P61_toposetper
	move	d0,P61_Period(a5)
	clr	P61_ToPeriod(a5)
P61_toposetper
	move	P61_Period(a5),6(a4)
	else
	nop
	endc

P61_contfxdone
	ifne	P61_il
	bsr	P61_funk2
	endc

	add.l	d6,a5
	add.l	d7,a4
	dbf	d5,P61_lopas

	cmp	P61_speed2(pc),d4
	beq.b	P61_preplay
	rts

	ifne	P61_pu
P61_portup
	moveq	#0,D0
	move.b	P61_Info(a5),d0
	sub	d0,P61_Period(a5)
	moveq	#113,d0
	cmp	P61_Period(a5),d0
	ble.b	.skip
	move	d0,P61_Period(a5)
	move	d0,6(a4)
	bra.b	P61_contfxdone
.skip
	move	P61_Period(a5),6(a4)
	bra.b	P61_contfxdone
	endc

	ifne	P61_pd
P61_portdwn
	moveq	#0,d0
	move.b	P61_Info(a5),d0
	add	d0,P61_Period(a5)
	cmp	#856,P61_Period(a5)
	ble.b	.skip
	move	#856,d0
	move	d0,P61_Period(a5)
	move	d0,6(a4)
	bra.b	P61_contfxdone
.skip
	move	P61_Period(a5),6(a4)
	bra.b	P61_contfxdone
	endc

	ifne	P61_pde
P61_return
	rts

P61_preplay
	tst	P61_pdflag(a3)
	bne.b	P61_return
	else
P61_preplay
	endc

	lea	P61_temp0(pc),a5
	lea	P61_Samples-16(pc),a0

	moveq	#channels-1,d5
P61_loaps
	ifne	P61_pl
	lea	P61_TData(a5),a1
	move	2(a5),(a1)+
	move.l	P61_ChaPos(a5),(a1)+
	move.l	P61_TempPos(a5),(a1)+
	move	P61_TempLen(a5),(a1)
	endc

	move.b	P61_Pack(a5),d0
	and.b	#$3f,d0
	beq.b	P61_takeone

	tst.b	P61_Pack(a5)
	bmi.b	.keepsame

	subq.b	#1,P61_Pack(a5)
	clr	P61_OnOff(a5)			; Empty row
	add.l	d6,a5
	dbf	d5,P61_loaps
	rts

.keepsame
	subq.b	#1,P61_Pack(a5)
	bra	P61_dko

P61_takeone
	tst.b	P61_TempLen+1(a5)
	beq	P61_takenorm

	subq.b	#1,P61_TempLen+1(a5)
	move.l	P61_TempPos(a5),a2

P61_jedi
	move.b	(a2)+,d0
	moveq	#%01100000,d1
	and.b	d0,d1
	cmp.b	#%01100000,d1
	bne.b	.all

	moveq	#%01110000,d1
	and.b	d0,d1
	cmp.b	#%01110000,d1
	bne.b	.cmd

	moveq	#%01111000,d1
	and.b	d0,d1
	cmp.b	#%01111000,d1
	bne.b	.note

.empty	clr	P61_OnOff(a5)			; Empty row
	clr	(a5)+
	clr.b	(a5)+
	tst.b	d0
	bpl.b	.ex
	move.b	(a2)+,(a5)			; Compression info
	bra.b	.ex

.all	move.b	d0,(a5)+
	ifeq	opt020
	move.b	(a2)+,(a5)+
	move.b	(a2)+,(a5)+
	else
	move	(a2)+,(a5)+
	endc
	tst.b	d0
	bpl.b	.ex
	move.b	(a2)+,(a5)			; Compression info
	bra.b	.ex

.cmd	moveq	#$f,d1
	and	d0,d1
	move	d1,(a5)+			; cmd
	move.b	(a2)+,(a5)+			; info
	tst.b	d0
	bpl.b	.ex
	move.b	(a2)+,(a5)			; Compression info
	bra.b	.ex

.note	moveq	#7,d1
	and	d0,d1
	lsl	#8,d1
	move.b	(a2)+,d1
	lsl	#4,d1
	move	d1,(a5)+
	clr.b	(a5)+	
	tst.b	d0
	bpl.b	.ex
	move.b	(a2)+,(a5)			; Compression info
.ex	subq.l	#3,a5
	move.l	a2,P61_TempPos(a5)
	bra	P61_dko


P61_takenorm
	move.l	P61_ChaPos(a5),a2

	move.b	(a2)+,d0
	moveq	#%01100000,d1
	and.b	d0,d1
	cmp.b	#%01100000,d1
	bne.b	.all

	moveq	#%01110000,d1
	and.b	d0,d1
	cmp.b	#%01110000,d1
	bne.b	.cmd

	moveq	#%01111000,d1
	and.b	d0,d1
	cmp.b	#%01111000,d1
	bne.b	.note

.empty	clr	P61_OnOff(a5)			; Empty row
	clr	(a5)+
	clr.b	(a5)+
	tst.b	d0
	bpl.b	.proccomp
	move.b	(a2)+,(a5)			; Compression info
	bra.b	.proccomp


.all	move.b	d0,(a5)+
	ifeq	opt020
	move.b	(a2)+,(a5)+
	move.b	(a2)+,(a5)+
	else
	move	(a2)+,(a5)+
	endc
	tst.b	d0
	bpl.b	.proccomp
	move.b	(a2)+,(a5)			; Compression info
	bra.b	.proccomp

.cmd	moveq	#$f,d1
	and	d0,d1
	move	d1,(a5)+			; cmd
	move.b	(a2)+,(a5)+			; info
	tst.b	d0
	bpl.b	.proccomp
	move.b	(a2)+,(a5)			; Compression info
	bra.b	.proccomp

.note	moveq	#7,d1
	and	d0,d1
	lsl	#8,d1
	move.b	(a2)+,d1
	lsl	#4,d1
	move	d1,(a5)+
	clr.b	(a5)+	
	tst.b	d0
	bpl.b	.proccomp
	move.b	(a2)+,(a5)			; Compression info

.proccomp
	subq.l	#3,a5
	move.l	a2,P61_ChaPos(a5)

	tst.b	d0
	bpl.b	P61_dko

	move.b	3(a5),d0
	move.b	d0,d1
	and	#%11000000,d1
	beq.b	P61_dko				; Empty datas
	cmp.b	#%10000000,d1
	beq.b	P61_dko				; Same datas

	clr.b	3(a5)
	and	#$3f,d0
	move.b	d0,P61_TempLen+1(a5)

	cmp.b	#%11000000,d1
	beq.b	.bit16				; 16-bit

	moveq	#0,d0				; 8-bit
	move.b	(a2)+,d0
	move.l	a2,P61_ChaPos(a5)
	sub.l	d0,a2
	bra	P61_jedi

.bit16	moveq	#0,d0
	ifeq	opt020
	move.b	(a2)+,d0
	lsl	#8,d0
	move.b	(a2)+,d0
	else
	move	(a2)+,d0
	endc

	move.l	a2,P61_ChaPos(a5)
	sub.l	d0,a2
	bra	P61_jedi


P61_dko	st	P61_OnOff(a5)
	move	(a5),d0
	and	#$1f0,d0
	beq.b	.koto
	lea	(a0,d0),a1
	move.l	a1,P61_Sample(a5)
	ifne	P61_ft
	move.l	P61_SampleVolume(a1),P61_Volume(a5)
	else
	move	P61_SampleVolume(a1),P61_Volume(a5)
	endc
	ifne	P61_il
	move.l	P61_RepeatOffset(a1),P61_Wave(a5)
	endc
	ifne	P61_sof
	clr	P61_Offset(a5)
	endc

.koto	add.l	d6,a5
	dbf	d5,P61_loaps
	rts

P61_playtime
	clr	(a3)

	ifne	P61_pde
	tst	P61_pdelay(a3)
	beq.b	.djdj
	subq	#1,P61_pdelay(a3)
	bra	P61_delay
.djdj
	endc

	clr	P61_pdflag(a3)

	tst	P61_speedis1(a3)
	beq.b	.mo
	bsr	P61_preplay

.mo	lea	P61_temp0(pc),a5
	lea	$a0(a6),a4

	ifeq	system
	lea	P61_dmason(pc),a1
	move.l	P61_vektori(pc),a0
	move.l	a1,(a0)
	move.b	#$f0,$bfd600
	move.b	#$01,$bfd700
	move.b	#$19,$bfdf00
	else
	move	#1,P61_server(a3)
	move.l	P61_craddr+4(pc),a1
	move.b	#$f0,(a1)
	move.b	#1,$100(a1)
	endc

	lea	P61_periods(pc),a2

	moveq	#0,d4
	moveq	#channels-1,d5
P61_los	tst	P61_OnOff(a5)
	beq	P61_nocha

	moveq	#$f,d0
	and	(a5),d0
	lea	P61_jtab(pc),a1
	add	d0,d0
	add.l	d0,a1
	add	(a1),a1
	jmp	(a1)

P61_fxdone
	moveq	#$7e,d0
	and.b	(a5),d0
	beq.b	P61_nocha
	ifne	P61_vib
	clr.b	P61_VibPos(a5)
	endc
	ifne	P61_tre
	clr.b	P61_TrePos(a5)
	endc

 	ifne	P61_ft
	add	P61_Fine(a5),d0
	endc
	move	d0,P61_Note(a5)
	move	(a2,d0),P61_Period(a5)

P61_zample
	ifne	P61_sof
	tst	P61_Offset(a5)
	bne	P61_pek
	endc

	or	P61_DMABit(a5),d4
	move	d4,$96(a6)
	move.l	P61_Sample(a5),a1		;* Trigger *
	move.l	(a1)+,(a4)			;Pointer
	move	(a1),4(a4)			;Length

P61_nocha
	ifeq	fade
	move.l	P61_Period(a5),6(a4)
	else
	move	P61_Period(a5),6(a4)
	move	P61_Volume(a5),P61_Shadow(a5)
	endc

P61_skip
	ifne	P61_il
	bsr	P61_funk2
	endc

	add.l	d6,a5
	add.l	d7,a4
	dbf	d5,P61_los

	move.b	d4,P61_dma+1(a3)

	ifne	P61_pl
	tst.b	P61_plflag+1(a3)
	beq.b	P61_ohittaa

	lea	P61_temp0(pc),a1
	lea	P61_looppos(pc),a0
	moveq	#channels-1,d0
.talt	move.b	1(a0),3(a1)
	addq.l	#2,a0
	move.l	(a0)+,P61_ChaPos(a1)
	move.l	(a0)+,P61_TempPos(a1)
	move	(a0)+,P61_TempLen(a1)
	add.l	d6,a1
	dbf	d0,.talt

	move	P61_plrowpos(pc),P61_rowpos(a3)
	clr.b	P61_plflag+1(a3)
	moveq	#63,d0
	sub	P61_rowpos(a3),d0
	move	d0,P61_CRow(a3)
	rts
	endc

P61_ohittaa
	subq	#1,P61_rowpos(a3)
	bmi.b	P61_nextpattern
	moveq	#63,d0
	sub	P61_rowpos(a3),d0
	move	d0,P61_CRow(a3)
	rts

P61_nextpattern
	ifne	P61_pl
	clr	P61_plflag(a3)
	endc
	move.l	P61_patternbase(pc),a4
	moveq	#63,d0
	move	d0,P61_rowpos(a3)
	clr	P61_CRow(a3)
	move.l	P61_spos(pc),a1
	addq	#1,P61_Pos(a3)
	move.b	(a1)+,d0
	bpl.b	P61_dk
	move.l	P61_possibase(pc),a1
	move.b	(a1)+,d0
	clr	P61_Pos(a3)
P61_dk	move.l	a1,P61_spos(a3)
	move	d0,P61_Patt(a3)
	lsl	#3,d0
	move.l	P61_positionbase(pc),a1
	add.l	d0,a1

	move	(a1)+,d0
	lea	(a4,d0.l),a2
	move.l	a2,P61_ChaPos+P61_temp0(a3)
	move	(a1)+,d0
	lea	(a4,d0.l),a2
	move.l	a2,P61_ChaPos+P61_temp1(a3)
	move	(a1)+,d0
	lea	(a4,d0.l),a2
	move.l	a2,P61_ChaPos+P61_temp2(a3)
	move	(a1),d0
	add.l	d0,a4
	move.l	a4,P61_ChaPos+P61_temp3(a3)
	rts

	ifne	P61_tp
P61_settoneport
	move.b	P61_Info(a5),d0
	beq.b	P61_toponochange
	move.b	d0,P61_TPSpeed+1(a5)
P61_toponochange
	moveq	#$7e,d0
	and.b	(a5),d0
	beq	P61_nocha
	add	P61_Fine(a5),d0
	move	d0,P61_Note(a5)
	move	(a2,d0),P61_ToPeriod(a5)
	bra	P61_nocha
	endc

	ifne	P61_sof
P61_sampleoffse
	moveq	#$7e,d0
	and.b	(a5),d0
	beq	P61_nocha
	ifne	P61_vib
	clr.b	P61_VibPos(a5)
	endc
	ifne	P61_tre
	clr.b	P61_TrePos(a5)
	endc

	ifne	P61_ft
	add	P61_Fine(a5),d0
	endc
	move	d0,P61_Note(a5)
	move	(a2,d0),P61_Period(a5)

	moveq	#0,d1
	move	#$ff00,d1
	and	2(a5),d1
	bne.b	.deq
	move	P61_LOffset(a5),d1
.deq	move	d1,P61_LOffset(a5)
	add	d1,P61_Offset(a5)
	move	P61_Offset(a5),d2

	add	d1,P61_Offset(a5)		; THIS IS A PT-FEATURE!
	bra.b	P61_hup

P61_pek	moveq	#0,d1
	move	P61_Offset(a5),d1
P61_hup	or	P61_DMABit(a5),d4
	move	d4,$96(a6)
	move.l	P61_Sample(a5),a1		;* Trigger *
	move.l	(a1)+,d0
	add.l	d1,d0
	move.l	d0,(a4)				;Pointer
	lsr	#1,d1
	move	(a1),d0
	sub	d1,d0
	bpl.b	P61_offok
	move.l	-4(a1),(a4)			;Pointer is over the end
	moveq	#1,d0
P61_offok
	move	d0,4(a4)			;Length
	bra	P61_nocha
	endc

	ifne	P61_vl
P61_volum
	move.b	P61_Info(a5),P61_Volume+1(a5)
	bra	P61_fxdone
	endc

	ifne	P61_pj
P61_posjmp
	moveq	#0,d0
	move.b	P61_Info(a5),d0
	cmp	P61_slen(a3),d0
	blo.b	.e
	moveq	#0,d0
.e	move	d0,P61_Pos(a3)
	add.l	P61_possibase(pc),d0
	move.l	d0,P61_spos(a3)
	endc

	ifne	P61_pb
P61_pattbreak
	moveq	#64,d0
	move	d0,P61_rowpos(a3)
	clr	P61_CRow(a3)
	move.l	P61_spos(pc),a1
	move.l	P61_patternbase(pc),a0
	addq	#1,P61_Pos(a3)
	move.b	(a1)+,d0
	bpl.b	P61_dk2
	move.l	P61_possibase(pc),a1
	move.b	(a1)+,d0
	clr	P61_Pos(a3)
P61_dk2	move.l	a1,P61_spos(a3)
	move.l	P61_positionbase(pc),a1
	move	d0,P61_Patt(a3)
	lsl	#3,d0
	add.l	d0,a1
	movem	(a1),d0-d3
	lea	(a0,d0.l),a1
	move	d1,d0
	move.l	a1,P61_ChaPos+P61_temp0(a3)
	lea	(a0,d0.l),a1
	move.l	a1,P61_ChaPos+P61_temp1(a3)
	move	d2,d0
	lea	(a0,d0.l),a1
	move.l	a1,P61_ChaPos+P61_temp2(a3)
	move	d3,d0
	add.l	d0,a0
	move.l	a0,P61_ChaPos+P61_temp3(a3)
	bra	P61_fxdone
	endc

	ifne	P61_vib
P61_vibrato
	move.b	P61_Info(a5),d0
	beq	P61_fxdone
	move.b	d0,d1
	move.b	P61_VibCmd(a5),d2
	and.b	#$f,d0
	beq.b	P61_vibskip
	and.b	#$f0,d2
	or.b	d0,d2
P61_vibskip
	and.b	#$f0,d1
	beq.b	P61_vibskip2
	and.b	#$f,d2
	or.b	d1,d2
P61_vibskip2
	move.b	d2,P61_VibCmd(a5)
	bra	P61_fxdone
	endc

	ifne	P61_tre
P61_settremo
	move.b	P61_Info(a5),d0
	beq	P61_fxdone
	move.b	d0,d1
	move.b	P61_TreCmd(a5),d2
	moveq	#$f,d3
	and.b	d3,d0
	beq.b	P61_treskip
	and.b	#$f0,d2
	or.b	d0,d2
P61_treskip
	and.b	#$f0,d1
	beq.b	P61_treskip2
	and.b	d3,d2
	or.b	d1,d2
P61_treskip2
	move.b	d2,P61_TreCmd(a5)
	bra	P61_fxdone
	endc

	ifne	P61_ec
P61_ecommands
	move.b	P61_Info(a5),d0
	and.b	#$f0,d0
	lsr	#3,d0
	move	P61_etab(pc,d0),d0
	jmp	P61_etab(pc,d0)

P61_etab
	ifne	P61_fi
	dc	P61_filter-P61_etab
	else
	dc	P61_fxdone-P61_etab
	endc

	ifne	P61_fsu
	dc	P61_fineup-P61_etab
	else
	dc	P61_fxdone-P61_etab
	endc

	ifne	P61_fsd
	dc	P61_finedwn-P61_etab
	else
	dc	P61_fxdone-P61_etab
	endc

	dc	P61_fxdone-P61_etab
	dc	P61_fxdone-P61_etab

	ifne	P61_sft
	dc	P61_setfinetune-P61_etab
	else
	dc	P61_fxdone-P61_etab
	endc

	ifne	P61_pl
	dc	P61_patternloop-P61_etab
	else
	dc	P61_fxdone-P61_etab
	endc

	dc	P61_fxdone-P61_etab

	ifne	P61_timing
	dc	P61_sete8-P61_etab
	else
	dc	P61_fxdone-P61_etab
	endc

	ifne	P61_rt
	dc	P61_setretrig-P61_etab
	else
	dc	P61_fxdone-P61_etab
	endc

	ifne	P61_fvu
	dc	P61_finevup-P61_etab
	else
	dc	P61_fxdone-P61_etab
	endc

	ifne	P61_fvd
	dc	P61_finevdwn-P61_etab
	else
	dc	P61_fxdone-P61_etab
	endc

	dc	P61_fxdone-P61_etab

	ifne	P61_nd
	dc	P61_ndelay-P61_etab
	else
	dc	P61_fxdone-P61_etab
	endc

	ifne	P61_pde
	dc	P61_pattdelay-P61_etab
	else
	dc	P61_fxdone-P61_etab
	endc

	ifne	P61_il
	dc	P61_funk-P61_etab
	else
	dc	P61_fxdone-P61_etab
	endc
	endc

	ifne	P61_fi
P61_filter
	move.b	P61_Info(a5),d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	bra	P61_fxdone
	endc

	ifne	P61_fsu
P61_fineup
	P61_getnote

	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	sub	d0,P61_Period(a5)
	moveq	#113,d0
	cmp	P61_Period(a5),d0
	ble.b	.jup
	move	d0,P61_Period(a5)
.jup	moveq	#$7e,d0
	and.b	(a5),d0
	bne	P61_zample
	bra	P61_nocha
	endc

	ifne	P61_fsd
P61_finedwn
	P61_getnote

	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	add	d0,P61_Period(a5)
	cmp	#856,P61_Period(a5)
	ble.b	.jup
	move	#856,P61_Period(a5)
.jup	moveq	#$7e,d0
	and.b	(a5),d0
	bne	P61_zample
	bra	P61_nocha
	endc

	ifne	P61_sft
P61_setfinetune
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	ifeq	opt020
	add	d0,d0
	move	P61_mulutab(pc,d0),P61_Fine(a5)
	else
	move	P61_mulutab(pc,d0*2),P61_Fine(a5)
	endc
	bra	P61_fxdone

P61_mulutab
	dc	0,74,148,222,296,370,444,518,592,666,740,814,888,962,1036,1110
	endc

	ifne	P61_pl
P61_patternloop
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	beq.b	P61_setloop

	tst.b	P61_plflag(a3)
	bne.b	P61_noset

	move	d0,P61_plcount(a3)
	st.b	P61_plflag(a3)
P61_noset
	tst	P61_plcount(a3)
	bne.b	P61_looppaa
	clr.b	P61_plflag(a3)
	bra	P61_fxdone
	
P61_looppaa
	st.b	P61_plflag+1(a3)
	subq	#1,P61_plcount(a3)
	bra	P61_fxdone

P61_setloop
	tst.b	P61_plflag(a3)
	bne	P61_fxdone
	move	P61_rowpos(pc),P61_plrowpos(a3)
	lea	P61_temp0+P61_TData(pc),a1
	lea	P61_looppos(pc),a0
	moveq	#channels-1,d0
.talt	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1),(a0)+
	subq.l	#8,a1
	add.l	d6,a1
	dbf	d0,.talt
	bra	P61_fxdone
	endc

	ifne	P61_fvu
P61_finevup
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	add	d0,P61_Volume(a5)
	moveq	#64,d0
	cmp	P61_Volume(a5),d0
	bge	P61_fxdone
	move	d0,P61_Volume(a5)
	bra	P61_fxdone
	endc

	ifne	P61_fvd
P61_finevdwn
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	sub	d0,P61_Volume(a5)
	bpl	P61_fxdone
	clr	P61_Volume(a5)
	bra	P61_fxdone
	endc

	ifne	P61_timing
P61_sete8
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	move	d0,P61_E8(a3)
	bra	P61_fxdone
	endc

	ifne	P61_rt
P61_setretrig
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	move	d0,P61_RetrigCount(a5)
	bra	P61_fxdone
	endc

	ifne	P61_nd
P61_ndelay
	moveq	#$7e,d0
	and.b	(a5),d0
	beq	P61_skip
	ifne	P61_vib
	clr.b	P61_VibPos(a5)
	endc
	ifne	P61_tre
	clr.b	P61_TrePos(a5)
	endc
	ifne	P61_ft
	add	P61_Fine(a5),d0
	endc
	move	d0,P61_Note(a5)
	move	(a2,d0),P61_Period(a5)
	ifeq	fade
	move	P61_Volume(a5),8(a4)
	else
	move	P61_Volume(a5),P61_Shadow(a5)
	endc
	bra	P61_skip
	endc

	ifne	P61_pde
P61_pattdelay
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	move	d0,P61_pdelay(a3)
	st	P61_pdflag(a3)
	bra	P61_fxdone
	endc

	ifne	P61_sd
P61_cspeed
	moveq	#0,d0
	move.b	P61_Info(a5),d0

	ifne	CIA
	tst	P61_Tempo(a3)
	beq.b	P61_VBlank
	cmp.b	#32,d0
	bhs.b	P61_STempo
	endc

P61_VBlank
	cmp.b	#1,d0
	beq.b	P61_jkd

	move.b	d0,P61_speed+1(a3)
	subq.b	#1,d0
	move.b	d0,P61_speed2+1(a3)
	clr	P61_speedis1(a3)
	bra	P61_fxdone

P61_jkd	move.b	d0,P61_speed+1(a3)
	move.b	d0,P61_speed2+1(a3)
	st	P61_speedis1(a3)
	bra	P61_fxdone


	ifne	CIA
P61_STempo
	move.l	P61_timer(pc),d1
	divu	d0,d1
	move	d1,P61_thi2(a3)
	sub	#$1f0*2,d1
	move	d1,P61_thi(a3)

	ifeq	system
	move	P61_thi2(a3),d1
	move.b	d1,$bfd400
	lsr	#8,d1
	move.b	d1,$bfd500
	endc

	bra	P61_fxdone
	endc
	endc



	ifne	P61_vbvs
P61_vibochvslide
	move.b	P61_Info(a5),d0
	sub.b	d0,P61_Volume+1(a5)
	bpl.b	P61_test62
	clr	P61_Volume(a5)
	ifeq	fade
	clr	8(a4)
	else
	clr	P61_Shadow(a5)
	endc
	bra.b	P61_vib2
P61_test62
	moveq	#64,d0
	cmp	P61_Volume(a5),d0
	bge.b	.ncs2
	move	d0,P61_Volume(a5)
.ncs2	ifeq	fade
	move	P61_Volume(a5),8(a4)
	else
	move	P61_Volume(a5),P61_Shadow(a5)
	endc
	endc

	ifne	P61_vib
P61_vib2
	move	#$f00,d0
	move	P61_VibCmd(a5),d1
	and	d1,d0
	lsr	#3,d0

	lsr	#2,d1
	and	#$1f,d1
	add	d1,d0

	move	P61_Period(a5),d1
	moveq	#0,d2
	move.b	P61_vibtab(pc,d0),d2

	tst.b	P61_VibPos(a5)
	bmi.b	.vibneg
	add	d2,d1
	bra.b	P61_vib4

.vibneg	sub	d2,d1

P61_vib4
	move	d1,6(a4)
	move.b	P61_VibCmd(a5),d0
	lsr.b	#2,d0
	and	#$3c,d0
	add.b	d0,P61_VibPos(a5)
	bra	P61_contfxdone
	endc

	ifne	P61_tre
P61_tremo
	move	#$f00,d0
	move	P61_TreCmd(a5),d1
	and	d1,d0
	lsr	#3,d0
	
	lsr	#2,d1
	and	#$1f,d1
	add	d1,d0

	move	P61_Volume(a5),d1
	moveq	#0,d2
	move.b	P61_vibtab(pc,d0),d2

	tst.b	P61_TrePos(a5)
	bmi.b	.treneg
	add	d2,d1
	cmp	#64,d1
	ble.b	P61_tre4
	moveq	#64,d1
	bra.b	P61_tre4

.treneg	sub	d2,d1
	bpl.b	P61_tre4
	moveq	#0,d1
P61_tre4
	ifeq	fade
	move	d1,8(a4)
	else
	move	d1,P61_Shadow(a5)
	endc

	move.b	P61_TreCmd(a5),d0
	lsr.b	#2,d0
	and	#$3c,d0
	add.b	d0,P61_TrePos(a5)
	bra	P61_contfxdone
	endc

	ifne	P61_vib!P61_tre
P61_vibtab:


	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$101,$101
	dc.w	$101,$101,$101,$101,$101,$101,$101,$101,$100,0,0
	dc.w	0,1,$101,$202,$203,$303,$303,$303,$303,$303,$303
	dc.w	$303,$202,$201,$101,0,0,$101,$202,$303,$404,$405
	dc.w	$505,$505,$505,$505,$505,$404,$403,$302,$201,$100
	dc.w	0,$102,$303,$405,$506,$607,$707,$707,$707,$707
	dc.w	$707,$606,$505,$403,$302,$100,0,$102,$304,$506
	dc.w	$707,$808,$909,$909,$909,$909,$908,$807,$706,$504
	dc.w	$302,$100,1,$203,$405,$607,$809,$90A,$B0B,$B0B
	dc.w	$B0B,$B0B,$B0A,$909,$807,$605,$403,$201,1,$204
	dc.w	$506,$708,$90A,$B0C,$C0D,$D0D,$D0D,$D0D,$C0C,$B0A
	dc.w	$908,$706,$504,$201,1,$304,$607,$80A,$B0C,$D0E
	dc.w	$E0F,$F0F,$F0F,$F0F,$E0E,$D0C,$B0A,$807,$604,$301
	dc.w	1,$305,$608,$90B,$C0D,$E0F,$1011,$1111,$1111
	dc.w	$1111,$100F,$E0D,$C0B,$908,$605,$301,1,$305,$709
	dc.w	$B0C,$E0F,$1011,$1213,$1313,$1313,$1313,$1211
	dc.w	$100F,$E0C,$B09,$705,$301,2,$406,$80A,$C0D,$F10
	dc.w	$1213,$1414,$1515,$1515,$1514,$1413,$1210,$F0D
	dc.w	$C0A,$806,$402,2,$406,$90B,$D0F,$1012,$1315,$1616
	dc.w	$1717,$1717,$1716,$1615,$1312,$100F,$D0B,$906
	dc.w	$402,2,$407,$90C,$E10,$1214,$1516,$1718,$1919
	dc.w	$1919,$1918,$1716,$1514,$1210,$E0C,$907,$402,2
	dc.w	$508,$A0D,$F11,$1315,$1718,$191A,$1B1B,$1B1B
	dc.w	$1B1A,$1918,$1715,$1311,$F0D,$A08,$502,2,$508
	dc.w	$B0E,$1012,$1517,$181A,$1B1C,$1D1D,$1D1D,$1D1C
	dc.w	$1B1A,$1817,$1512,$100E,$B08,$502

	endc

	ifne	P61_il
P61_funk
	moveq	#$f,d0
	and.b	P61_Info(a5),d0
	move.b	d0,P61_Funkspd(a5)
	bra	P61_fxdone

P61_funk2
	moveq	#0,d0
	move.b	P61_Funkspd(a5),d0
	beq.b	P61_funkend
	move.b	P61_FunkTable(pc,d0),d0
	add.b	d0,P61_Funkoff(a5)
	bpl.b	P61_funkend
	clr.b	P61_Funkoff(a5)

	move.l	P61_Sample(a5),a1
	move.l	P61_RepeatOffset(a1),d1
	move	P61_RepeatLength(a1),d0
	add.l	d0,d0
	add.l	d1,d0
	move.l	P61_Wave(a5),a0
	addq.l	#1,a0
	cmp.l	d0,a0
	blo.b	P61_funkok
	move.l	d1,a0
P61_funkok
	move.l	a0,P61_Wave(a5)
	not.b	(a0)
P61_funkend
	rts

P61_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
	endc

P61_jtab
	dr	P61_fxdone
	dr	P61_fxdone
	dr	P61_fxdone

	ifne	P61_tp
	dr	P61_settoneport
	else
	dr	P61_fxdone
	endc

	ifne	P61_vib
	dr	P61_vibrato
	else
	dr	P61_fxdone
	endc

	ifne	P61_tpvs
	dr	P61_toponochange
	else
	dr	P61_fxdone
	endc

	dr	P61_fxdone

	ifne	P61_tre
	dr	P61_settremo
	else
	dr	P61_fxdone
	endc

	dr	P61_fxdone

	ifne	P61_sof
	dr	P61_sampleoffse
	else
	dr	P61_fxdone
	endc
	dr	P61_fxdone

	ifne	P61_pj
	dr	P61_posjmp
	else
	dr	P61_fxdone
	endc

	ifne	P61_vl
	dr	P61_volum
	else
	dr	P61_fxdone
	endc

	ifne	P61_pb
	dr	P61_pattbreak
	else
	dr	P61_fxdone
	endc

	ifne	P61_ec
	dr	P61_ecommands
	else
	dr	P61_fxdone
	endc
	
	ifne	P61_sd
	dr	P61_cspeed
	else
	dr	P61_fxdone
	endc


P61_dmason
	ifeq	system
	tst.b	$bfdd00
	move	#$2000,$dff09c
	move.b	#$19,$bfdf00
	move.l	a0,-(sp)
	move.l	P61_vektori(pc),a0
	move.l	P61_intaddr(pc),(a0)
	move.l	(sp)+,a0
	move	P61_dma(pc),$dff096
	nop
	rte

	else

	move	P61_dma(pc),$96(a6)
	lea	P61_server(pc),a3
	addq	#1,(a3)
	move.l	P61_craddr(pc),a0
	move.b	#$19,(a0)
	bra	P61_ohi
	endc


P61_setrepeat
	ifeq	system
	tst.b	$bfdd00
	movem.l	a0/a1,-(sp)
	lea	$dff0a0,a1
	move	#$2000,-4(a1)
	else
	lea	$a0(a6),a1
	endc

	move.l	P61_Sample+P61_temp0(pc),a0
	addq.l	#6,a0
	move.l	(a0)+,(a1)+
	move	(a0),(a1)

	ifgt	channels-1
	move.l	P61_Sample+P61_temp1(pc),a0
	addq.l	#6,a0
	move.l	(a0)+,12(a1)
	move	(a0),16(a1)
	endc
	
	ifgt	channels-2
	move.l	P61_Sample+P61_temp2(pc),a0
	addq.l	#6,a0
	move.l	(a0)+,28(a1)
	move	(a0),32(a1)
	endc

	ifgt	channels-3
	move.l	P61_Sample+P61_temp3(pc),a0
	addq.l	#6,a0
	move.l	(a0)+,44(a1)
	move	(a0),48(a1)
	endc

	ifne	system
	ifne	CIA
	lea	P61_server(pc),a3
	clr	(a3)
	move.l	P61_craddr+4(pc),a0
	move.b	P61_tlo(pc),(a0)
	move.b	P61_thi(pc),$100(a0)
	endc
	bra	P61_ohi
	endc

	ifeq	system
	ifne	CIA
	move.l	P61_vektori(pc),a0
	move.l	P61_tintti(pc),(a0)
	endc
	movem.l	(sp)+,a0/a1
	nop
	rte
	endc

P61_temp0	dcb.b	Channel_Block_SIZE-2
		dc	1

P61_temp1	dcb.b	Channel_Block_SIZE-2
		dc	2

P61_temp2	dcb.b	Channel_Block_SIZE-2
		dc	4

P61_temp3	dcb.b	Channel_Block_SIZE-2
		dc	8

P61_cn		dc	0
P61_dma		dc	$8200
P61_rowpos	dc	0
P61_slen	dc	0
P61_speed	dc	0
P61_speed2	dc	0
P61_speedis1	dc	0
P61_spos	dc.l	0

	ifeq	system
P61_vektori	dc.l	0
P61_oldlev6	dc.l	0
	endc

P61_ofilter	dc	0
P61_Timers	dc.l	0

	ifne	CIA
P61_tintti	dc.l	0
P61_thi		dc.b	0
P61_tlo		dc.b	0
P61_thi2	dc.b	0
P61_tlo2	dc.b	0
P61_timer	dc.l	0
	endc

	ifne	P61_pl
P61_plcount	dc	0
P61_plflag	dc	0
P61_plreset	dc	0
P61_plrowpos	dc	0
P61_looppos	dcb.b	12*channels
	endc

	ifne	P61_pde
P61_pdelay	dc	0
P61_pdflag	dc	0
	endc

P61_Samples	dcb.b	16*31
P61_positionbase dc.l	0
P61_possibase	dc.l	0
P61_patternbase	dc.l	0
P61_intaddr	dc.l	0

	ifne	system
P61_server	dc	0
P61_miscbase	dc.l	0
P61_audioopen	dc.b	0
P61_sigbit	dc.b	-1
P61_ciares	dc.l	0
P61_craddr	dc.l	0,0,0
P61_dat		dc	$f00
P61_timerinterrupt dc	0,0,0,0,127
P61_timerdata	dc.l	0,0,0

P61_allocport	dc.l	0,0
		dc.b	4,0
		dc.l	0
		dc.b	0,0
		dc.l	0
P61_reqlist	dc.l	0,0,0
		dc.b	5,0
P61_allocreq	dc.l	0,0
		dc	127
		dc.l	0
P61_portti	dc.l	0
		dc	68
		dc.l	0,0,0
		dc	0
P61_reqdata	dc.l	0
		dc.l	1,0,0,0,0,0,0
		dc	0
P61_audiodev	dc.b	'audio.device',0

P61_cianame	dc.b	'ciab.resource',0
P61_timeropen	dc.b	0
P61_timerint	dc.b	'P61_TimerInterrupt',0,0
	endc
P61_etu

