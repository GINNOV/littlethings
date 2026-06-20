;============================================================================
CHECK		EQU 1	;1 = do range checkings (track, sample in mem etc.)
IFFMOCT		EQU 1	;1 = play IFF multi-octave samples correctly
HOLD		EQU 1	;1 = handle hold/decay
PLAYMMD0	EQU 1	;1 = play old MMD0 modules
;============================================================================

;the MMD0 structure offsets
mmd_id		EQU	0
mmd_modlen	EQU	4
mmd_songinfo	EQU	8
mmd_blockarr	EQU	16
mmd_smplarr	EQU	24
mmd_expdata	EQU	32
mmd_pstate	EQU	40 ; <0 = play song, 0 = don't play, >0 = play block
mmd_pblock	EQU	42
mmd_pline	EQU	44
mmd_pseqnum	EQU	46
mmd_actplayline	EQU	48
mmd_counter	EQU	50
mmd_songsleft	EQU	51

;the MMD0song structure
;Instrument data here (504 bytes = 63 * 8)
msng_numblocks	EQU	504
msng_songlen	EQU	506
msng_playseq	EQU	508
msng_deftempo	EQU	764
msng_playtransp	EQU	766
msng_flags	EQU	767
msng_flags2	EQU	768
msng_tempo2	EQU	769
msng_trkvol	EQU	770
msng_mastervol	EQU	786
msng_numsamples	EQU	787

;Instrument data
inst_repeat	EQU	0
inst_replen	EQU	2
inst_midich	EQU	4
inst_midipreset	EQU	5
inst_svol	EQU	6
inst_strans	EQU	7

;Audio hardware offsets
ac_ptr	EQU	$00
ac_len	EQU	$04
ac_per	EQU	$06
ac_vol	EQU	$08
ac_end	EQU	$0C
ac_rest	EQU	$10
ac_mask	EQU	$14
ac_rhw	EQU	$16

T03SZ	EQU	98
T415SZ	EQU	18
		
;**************************************************************************
*
*		Simple test code
*
;**************************************************************************
		
		lea		Module,a0	;get module
		bsr		PlayMod		;play it (simple enough !)
		
Mouse		btst		#6,$bfe001	;test mouse
		bne.s		Mouse		;branch if left mouse up
		
		bsr		StopMod		;stop module playing
		
Mouse2		btst		#6,$bfe001	;test mouse
		beq.s		Mouse2		;wait until mouse released
		
		lea		Module,a0	;get module
		bsr		ReStartMod	;start it again
		
Mouse3		btst		#6,$bfe001	;test mouse
		bne.s		Mouse3		;wait until left pressed

		bsr		StopMod		;kill module

		moveq		#0,d0		;set no error return
		rts				;and quit

;**************************************************************************
;*
;*		8 CHANNEL PLAY ROUTINE
;*
;**************************************************************************

PlayMod		move.l	a0,a2
		move.l	a0,-(sp)
		bsr.s	_RelocModule
		bra.s	Init

ReStartMod	move.l	a0,-(sp)
Init		bsr.w	_InitPlayer8
		move.l	(sp)+,a0
		bra.w	_PlayModule8
		

; ***** The relocation routine *****
reloci		move.l	24(a2),d0
		beq.s	xloci
		movea.l	d0,a0
		moveq   #0,d0
		move.b  787(a1),d0	;number of samples
		subq.b  #1,d0
relocs:		bsr.s   relocentr
		move.l	-4(a0),d3	;sample ptr
		beq.s	nosyn
		move.l	d3,a3
		tst.w	4(a3)
		bpl.s	nosyn		;type >= 0
		move.w	20(a3),d2	;number of waveforms
		lea	278(a3),a3	;ptr to wf ptrs
		subq.w	#1,d2
relsyn		add.l	d3,(a3)+
		dbf	d2,relsyn
nosyn		dbf     d0,relocs
xloci		rts
norel		addq.l	#4,a0
		rts
relocentr	tst.l   (a0)
		beq.s   norel
		add.l   d1,(a0)+
		rts
_RelocModule	movem.l	a2-a3/d2-d3,-(sp)
		move.l  a2,d1		;d1 = ptr to start of module
		bsr.s	relocp
		movea.l 8(a2),a1
		bsr.s	reloci
rel_lp		bsr.s	relocb
		move.l	32(a2),d0	;extension struct
		beq.s	rel_ex
		move.l	d0,a0
		bsr.s	relocentr	;ptr to next module
		bsr.s	relocentr	;InstrExt...
		addq.l	#4,a0		;skip sizes of InstrExt
		bsr.s	relocentr	;annotxt
		addq.l	#4,a0		;annolen
		bsr.s	relocentr	;InstrInfo
		addq.l	#8,a0
		bsr.s	relocentr	;rgbtable (not useful for most people)
		addq.l	#4,a0		;skip channelsplit
		bsr.s	relocentr	;NotationInfo
		bsr.s	relocentr	;songname
		addq.l	#4,a0		;skip song name length
		bsr.s	relocentr	;MIDI dumps
		bsr.s	relocmdd
		move.l	d0,a0
		move.l	(a0),d0
		beq.s	rel_ex
		move.l	d0,a2
		bsr.s	relocp
		movea.l 8(a2),a1
		bra.s	rel_lp
rel_ex		movem.l	(sp)+,d2-d3/a2-a3
		rts
relocp		lea	8(a2),a0
		bsr.s	relocentr
		addq.l	#4,a0
		bsr.s	relocentr
		addq.l	#4,a0
		bsr.s	relocentr
		addq.l	#4,a0
		bra.s	relocentr
relocb		move.l	16(a2),d0
		beq.s	xlocb
		movea.l	d0,a0
		move.w  504(a1),d0
		subq.b  #1,d0
rebl		bsr.s   relocentr
		dbf     d0,rebl
		cmp.b	#'1',3(a2)	;test MMD type
		beq.s	relocbi
xlocb		rts
relocmdd	tst.l	-(a0)
		beq.s	xlocmdd
		movea.l	(a0),a0
		move.w	(a0),d0		;# of msg dumps
		addq.l	#8,a0
mddloop		beq.s	xlocmdd
		bsr	relocentr
		bsr.s	relocdmp
		subq.w	#1,d0
		bra.s	mddloop
xlocmdd		rts
relocdmp	move.l	-4(a0),d3
		beq.s	xlocdmp
		exg.l	a0,d3		;save
		addq.l	#4,a0
		bsr	relocentr	;reloc data pointer
		move.l	d3,a0		;restore
xlocdmp		rts
relocbi		move.w	504(a1),d0
		move.l	a0,a3
biloop		subq.w	#1,d0
		bmi.s	xlocdmp
		move.l	-(a3),a0
		addq.l	#4,a0
		bsr	relocentr	;BlockInfo ptr
		tst.l	-(a0)
		beq.s	biloop
		move.l	(a0),a0
		bsr	relocentr	;hldata
		bsr	relocentr	;block name
		bra.s	biloop

; This code does the magic 8 channel thing (mixing).
MAGIC_8TRK	MACRO
		swap	d6
		swap	d7
		move.b	0(a3,d6.w),d0
		add.b	0(a4,d7.w),d0
		move.b	d0,(a1)+
		swap	d6
		swap	d7
		add.l	d1,d6
		add.l	d2,d7
		ENDM

_ChannelO8	lea	trackdata8-DB(a6),a1
		cmp.b	#8,d0
		bge.s	xco8
		lsl.b	#2,d0
		adda.w	d0,a1
		movea.l	(a1),a1
		clr.w	trk_prevper(a1)
		movea.l	trk_audioaddr(a1),a1
		clr.w	ac_per(a1)
xco8		rts

_PlayNote8:	;d7(w) = trk #, d1 = note #, d3(w) = instr # a3 = addr of instr
		movea.l	mmd_smplarr(a2),a0
		add.w	d3,d3			;d3 = instr.num << 2
		add.w	d3,d3
		move.l	0(a0,d3.w),d5		;get address of instrument
	IFNE	CHECK
		beq.s	xco8
	ENDC
inmem8:		add.b	msng_playtransp(a4),d1	;add play transpose
		add.b	inst_strans(a3),d1	;and instr. transpose
	IFNE	CHECK
		tst.b	inst_midich(a3)
		bne.s	xco8		;MIDI
	ENDC
		clr.b	trk_vibroffs(a5)	;clr vibrato offset
		move.l	d5,a0
		subq.b	#1,d1
	IFNE	CHECK
		tst.w	4(a0)
		bmi.s	xco8		;Synth
	ENDC
tlwtst08:	tst.b	d1
		bpl.s	notenot2low8
		add.b	#12,d1	;note was too low, octave up
		bra.s	tlwtst08
notenot2low8:	cmp.b	#62,d1
		ble.s	endpttest8
		sub.b	#12,d1	;note was too high, octave down
endpttest8:
		moveq	#0,d2
		moveq	#0,d3
	IFNE	IFFMOCT
		move.w	4(a0),d0	;Soitin-struct in a0
		bne.s	iff5or3oct	;note # in d1 (0 - ...)
	ENDC
		lea	_periodtable+32-DB(a6),a1
		move.b	trk_finetune(a5),d2	;finetune value
		add.b	d2,d2
		add.b	d2,d2		;multiply by 4...
		ext.w	d2		;extend
		movea.l	0(a1,d2.w),a1	;period table address
		move.l	a1,trk_periodtbl(a5)
		add.b	d1,d1
		move.w	0(a1,d1.w),d5 ;put period to d5
		move.l	a0,d0
		addq.l	#6,d0		;Skip structure
		move.l	(a0),d1		;length
		add.l	d0,d1		;sample end pointer
		move.w	(a3),d2
		move.w	inst_replen(a3),d3
	IFNE	IFFMOCT
		bra	gid_setrept
gid_addtable	dc.b	0,6,12,18,24,30
gid_divtable	dc.b	31,7,3,15,63,127
iff5or3oct:	move.l	d7,-(sp)
		moveq	#0,d7
		move.w	d1,d7
		divu	#12,d7	;octave #
		move.l	d7,d5
		cmp.w	#6,d7	;if oct > 5, oct = 5
		blt.s	nohioct
		moveq	#5,d7
nohioct		swap	d5	;note number in this oct (0-11) is in d5
		move.l	(a0),d1
		cmp.w	#6,d0
		ble.s	nounrecit
		moveq	#6,d0
nounrecit	add.b	gid_addtable-1(pc,d0.w),d7
		move.b	gid_divtable-1(pc,d0.w),d0
		divu	d0,d1	;get length of the highest octave
		swap	d1
		clr.w	d1
		swap	d1
		move.l	d1,d0		;d0 and d1 = length of the 1st oct
		move.w	(a3),d2
		move.w	inst_replen(a3),d3
		moveq	#0,d6
		move.b	shiftcnt(pc,d7.w),d6
		lsl.w	d6,d2
		lsl.w	d6,d3
		lsl.w	d6,d1
		move.b	mullencnt(pc,d7.w),d6
		mulu	d6,d0		;offset of this oct from 1st oct
		add.l	a0,d0		;add base address to offset
		addq.l	#6,d0		;skip structure
		add.l	d0,d1
		lea	_periodtable+32-DB(a6),a1
		move.b	trk_finetune(a5),d6
		add.b	d6,d6
		add.b	d6,d6
		ext.w	d6
		movea.l	0(a1,d6.w),a1
		move.l	a1,trk_periodtbl(a5)
		add.b	octstart(pc,d7.w),d5
		add.b	d5,d5
		move.w	0(a1,d5.w),d5
		move.l	(sp)+,d7
		bra.s	gid_setrept
shiftcnt:	dc.b	4,3,2,1,1,0,2,2,1,1,0,0,1,1,0,0,0,0
		dc.b	3,3,2,2,1,0,5,4,3,2,1,0,6,5,4,3,2,1
mullencnt:	dc.b	15,7,3,1,1,0,3,3,1,1,0,0,1,1,0,0,0,0
		dc.b	7,7,3,3,1,0,31,15,7,3,1,0,63,31,15,7,3,1
octstart:	dc.b	12,12,12,12,24,24,0,12,12,24,24,36,0,12,12,24,36,36
		dc.b	0,12,12,24,24,24,12,12,12,12,12,12,12,12,12,12,12,12
	ENDC
gid_setrept	add.l	d2,d2
		add.l	d0,d2		;rep. start pointer
		cmp.w	#1,d3
		bhi.s	gid_noreplen2
		moveq	#0,d3		;no repeat
		bra.s	gid_cont
gid_noreplen2	add.l	d3,d3
		add.l	d2,d3		;rep. end pointer

gid_cont	movea.l	trk_audioaddr(a5),a1 ;base of this channel's regs
		move.l	d0,(a1)		;put it in ac_ptr
		cmp.l	d0,d3
		bhi.s	repeat8

		tst.b	trk_split(a5)
		beq.s	pn8_nosplit0
		clr.l	ac_rest(a1)
		subq.l	#1,d1
		move.l	d1,ac_end(a1)
		bra.s	retsn18

pn8_nosplit0	sub.l	d0,d1
		lsr.l	#1,d1
		move.w	d1,ac_len(a1)
		move.l	#_chipzero,ac_rest(a1)
		move.w	#1,ac_end(a1)
		bra.s	retsn18

repeat8:	tst.b	trk_split(a5)
		bne.s	pn8_split1
		move.l	d3,d1
		sub.l	d0,d1
		lsr.l	#1,d1
		move.w	d1,ac_len(a1)
		move.l	d2,ac_rest(a1)	;remember rep. start
		sub.l	d2,d3
		lsr.l	#1,d3
		move.w	d3,ac_end(a1)	;remember rep. length
		bra.s	retsn18

pn8_split1	move.l	d2,ac_rest(a1)
		move.l	d3,ac_end(a1)
retsn18:	move.w	d5,ac_per(a1)	;getinsdata puts period to d5
		move.w	d5,trk_prevper(a5)
retsn28:	rts

_IntHandler8:	movem.l	d0-d7/a0-a6,-(sp)
		lea	$dff000,a0		;a0 = CUSTOM
		lea	_audiobuff,a1

		lea	DB,a6
		lea	trksplit-DB(a6),a2
		move.w	currchsize2-DB(a6),d4
; ================ 8 channel handling (buffer swap) ======
		move.w	#800,d0
		not.b	whichbuff-DB(a6)	;swap buffer
		bne.s	usebuff1
		tst.b	(a2)+
		beq.s	tnspl0
		move.l	a1,$a0(a0)
		move.w	d4,$a4(a0)
tnspl0		lea	800(a1),a5
		tst.b	(a2)+
		beq.s	tnspl1
		move.l	a5,$b0(a0)
		move.w	d4,$b4(a0)
tnspl1		adda.w	d0,a5
		tst.b	(a2)+
		beq.s	tnspl2
		move.l	a5,$c0(a0)
		move.w	d4,$c4(a0)
tnspl2		adda.w	d0,a5
		tst.b	(a2)
		beq.s	buffset
		move.l	a5,$d0(a0)
		move.w	d4,$d4(a0)
		bra.s	buffset
usebuff1	lea	400(a1),a1
		tst.b	(a2)+
		beq.s	tnspl0b
		move.l	a1,$a0(a0)
		move.w	d4,$a4(a0)
tnspl0b		lea	800(a1),a5
		tst.b	(a2)+
		beq.s	tnspl1b
		move.l	a5,$b0(a0)
		move.w	d4,$b4(a0)
tnspl1b		adda.w	d0,a5
		tst.b	(a2)+
		beq.s	tnspl2b
		move.l	a5,$c0(a0)
		move.w	d4,$c4(a0)
tnspl2b		tst.b	(a2)
		beq.s	buffset
		adda.w	d0,a5
		move.l	a5,$d0(a0)
		move.w	d4,$d4(a0)
buffset		move.w	#1<<7,$9c(a0)
		move.l	#3719168,d3	;227 * 16384
; ============== fill buffers ============
startfillb	moveq	#0,d4		;mask for DMA
		lea	track0hw-DB(a6),a2
		tst.b	trksplit-DB(a6)
		bne.s	tspl0c
		bsr.w	pushregs
		bra.s	tnspl0c
tspl0c		bsr.s	fillbuf
		movea.l	a5,a1
tnspl0c		lea	track1hw-DB(a6),a2
		tst.b	trksplit+1-DB(a6)
		bne.s	tspl1c
		bsr.w	pushregs
		bra.s	tnspl1c
tspl1c		bsr.s	fillbuf
		movea.l	a5,a1
tnspl1c		lea	track2hw-DB(a6),a2
		tst.b	trksplit+2-DB(a6)
		bne.s	tspl2c
		bsr.w	pushregs
		bra.s	tnspl2c
tspl2c		bsr.s	fillbuf
		movea.l	a5,a1
tnspl2c		lea	track3hw-DB(a6),a2
		tst.b	trksplit+3-DB(a6)
		bne.s	tspl3c
		bsr.w	pushregs
		bra.w	do_play8
tspl3c		bsr.s	fillbuf
		bra.w	do_play8
; =========================================================
;calculate channel A period
fillbuf:	move.l	d3,d7
		move.w	ac_per(a2),d6
		beq.s	setpzero0
		move.l	d7,d2
		divu 	d6,d2
		moveq	#0,d1
		move.w	d2,d1
		add.l	d1,d1
		add.l	d1,d1
;get channel A addresses
		move.l	ac_end(a2),a5
		move.l	(a2),d0
		beq.s	setpzero0
chA_dfnd	move.l	d0,a3	;a3 = start address, a5 = end address
;calc bytes before end
		mulu	currchsize-DB(a6),d2
		clr.w	d2
		swap	d2
; d2 = # of bytes/fill
		add.l	a3,d2	;d2 = end position after this fill
		sub.l	a5,d2	;subtract sample end
		bmi.s	norestart0
		move.l	ac_rest(a2),d0
		beq.s	rst0end
		move.l	d0,(a2)
		move.l	d0,a3
		bra.s	norestart0
rst0end		clr.l	(a2)
setpzero0	lea	zerodata-DB(a6),a3
		moveq	#0,d1
norestart0
;channel B period
		move.w	SIZE4TRKHW+ac_per(a2),d6
		beq.s	setpzero0b
		divu	d6,d7
		moveq	#0,d2
		move.w	d7,d2
		add.l	d2,d2
		add.l	d2,d2
;channel B addresses
		move.l	SIZE4TRKHW+ac_end(a2),a5
		move.l	SIZE4TRKHW(a2),d0
		beq.s	setpzero0b
		move.l	d0,a4
		mulu	currchsize-DB(a6),d7
		clr.w	d7
		swap	d7
		add.l	a4,d7
		sub.l	a5,d7
		bmi.s	norestart0b
		move.l	SIZE4TRKHW+ac_rest(a2),d0
		beq.s	rst0endb
		move.l	d0,SIZE4TRKHW(a2)
		move.l	d0,a4
		bra.s	norestart0b
rst0endb	clr.l	SIZE4TRKHW(a2)
setpzero0b	lea	zerodata-DB(a6),a4
		moveq	#0,d2
norestart0b	moveq	#0,d6
		moveq	#0,d7
		move.w	currchszcnt-DB(a6),d5
		lea	800(a1),a5	;get addr. of next buffer
do8trkmagic
		MAGIC_8TRK	;20 times..
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK
		MAGIC_8TRK

		dbf	d5,do8trkmagic	;do until cnt zero
end8trkmagic	clr.w	d6
		clr.w	d7
		swap	d6
		swap	d7
		add.l	d6,(a2)
		add.l	d7,SIZE4TRKHW(a2)
		rts

_Wait1line:	move.l	d0,-(sp)
		moveq	#$79,d0
wl0:		move.b	$dff007,d1
wl1:		cmp.b	$dff007,d1
		beq.s	wl1
		dbf	d0,wl0
		move.l	(sp)+,d0
		rts
; ========== this channel is not splitted
pushregs	move.l	ac_rhw(a2),a3		;address of real hardware
		move.w	ac_per(a2),ac_per(a3)	;push new period
		move.l	(a2),d0	;ac_ptr
		beq.s	pregs_nonewp
		move.w	ac_mask(a2),d1
		move.w	d1,$96(a0)	;stop DMA of curr. channel
		or.w	d1,d4
		clr.l	(a2)+
		move.l	d0,(a3)+	;to real ac_ptr
		move.w	(a2),(a3)	;push ac_len
pregs_nonewp	lea	400(a1),a1	;next buffer
		rts
; ========== should we start DMA of non-splitted channels?
do_play8	tst.w	d4
		beq.s	do_play8_b	;no.
		bsr.s	_Wait1line
		bset	#15,d4
		move.w	d4,$96(a0)
		bsr.s	_Wait1line
		lsr.b	#1,d4
		bcc.s	plr_nos8dma0
		move.l	track0hw+ac_rest-DB(a6),$a0(a0)
		move.w	track0hw+ac_end-DB(a6),$a4(a0)
plr_nos8dma0	lsr.b	#1,d4
		bcc.s	plr_nos8dma1
		move.l	track1hw+ac_rest-DB(a6),$b0(a0)
		move.w	track1hw+ac_end-DB(a6),$b4(a0)
plr_nos8dma1	lsr.b	#1,d4
		bcc.s	plr_nos8dma2
		move.l	track2hw+ac_rest-DB(a6),$c0(a0)
		move.w	track2hw+ac_end-DB(a6),$c4(a0)
plr_nos8dma2	lsr.b	#1,d4
		bcc.s	do_play8_b
		move.l	track3hw+ac_rest-DB(a6),$d0(a0)
		move.w	track3hw+ac_end-DB(a6),$d4(a0)
; ========== player starts here...
do_play8_b	movea.l	_module8-DB(a6),a2
		move.l	a2,d0
		beq.w	plr_exit8
		move.l	mmd_songinfo(a2),a4
		moveq	#0,d3
		lea	mmd_counter(a2),a0
		move.b	(a0),d3
		addq.b	#1,d3
		cmp.b	msng_tempo2(a4),d3
		bge.s	plr_pnewnote8	;play new note
		move.b	d3,(a0)
		bra.w	nonewnote8	;do just fx
; --- new note!! first get address of current block
plr_pnewnote8:	clr.b	(a0)
		tst.w	blkdelay-DB(a6)
		beq.s	plr_noblkdelay8
		subq.w	#1,blkdelay-DB(a6)
		bne.w	nonewnote8
plr_noblkdelay8	move.w	mmd_pblock(a2),d0
		movea.l	mmd_blockarr(a2),a0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	0(a0,d0.w),a1	;block...
		move.w	mmd_pline(a2),d0
	IFNE	PLAYMMD0
		cmp.b	#'1',3(a2)	;check ID type
		beq.s	plr_mmd1_0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0		;d0 = d0 * 3
		clr.l	numtracks-DB(a6)
		move.b	(a1)+,numtracks+1-DB(a6)
		move.b	(a1),numlines+1-DB(a6)
		mulu	numtracks-DB(a6),d0
		pea	1(a1,d0.w)
		bra.s	plr_begloop
plr_mmd1_0
	ENDC
		add.w	d0,d0
		add.w	d0,d0		;d0 = d0 * 4
		mulu	(a1),d0		;numtracks * d0
		pea	8(a1,d0.l)	;address of the current note
		move.w	(a1)+,numtracks-DB(a6)
		move.w	(a1),numlines-DB(a6)
plr_begloop	moveq	#0,d7		;number of track
		moveq	#0,d4
		pea	trackdata8-DB(a6)
plr_loop08	moveq	#0,d5
		cmp.w	#8,d7
		bge.w	plr_endloop08
		move.l	(sp),a1
		movea.l	(a1)+,a5	;get address of this track's struct
		move.l	a1,(sp)
; ---------------- get the note numbers
		moveq	#0,d3
		move.l	4(sp),a1
	IFNE	PLAYMMD0
		cmp.b	#'1',3(a2)
		beq.s	plr_mmd1_1
		move.b	(a1)+,d5
		move.b	(a1)+,d6
		move.b	(a1)+,trk_cmdqual(a5)
		move.b	d6,d3
		and.w	#$0F,d6
		lsr.b	#4,d3
		bclr	#7,d5
		beq.s	plr_bseti4
		bset	#4,d3
plr_bseti4	bclr	#6,d5
		beq.s	plr_bseti5
		bset	#5,d3
plr_bseti5	bra.s	plr_nngok
plr_mmd1_1
	ENDC
		move.b	(a1)+,d5	;get the number of this note
		bpl.s	plr_nothinote
		moveq	#0,d5
plr_nothinote	move.b	(a1)+,d3	;instrument number
		move.b	(a1)+,d6	;cmd number
		and.w	#$1F,d6		;recognize only cmds 00 - 1F
		move.b	(a1)+,trk_cmdqual(a5)	;databyte (qualifier)
plr_nngok	move.l	a1,4(sp)
; ---------------- check if there's an instrument number
		and.w	#$3F,d3
		beq.s	noinstnum8
; ---------------- finally, save the number
		subq.b	#1,d3
		move.b	d3,trk_previnstr(a5) ;remember instr. number!
	IFNE	HOLD
		lea	holdvals-DB(a6),a0
		adda.w	d3,a0
		move.b	(a0),trk_inithold(a5)
		move.b	63(a0),trk_finetune(a5)
	ENDC
		asl.w	#3,d3
		lea	0(a4,d3.w),a3	;a3 contains now address of it
		move.l	a3,trk_previnstra(a5)
		moveq	#0,d0
; ---------------- set volume to 64
		movea.l	trk_audioaddr(a5),a0
		movea.l	ac_vol(a0),a0	;ptr to volume hardware register
		moveq	#64,d0
		move.b	d0,(a0)
		move.b	d0,trk_prevvol(a5)
; ---------------- remember transpose
		move.b	inst_strans(a3),trk_stransp(a5)
		clr.w	trk_soffset(a5)		;sample offset
; ---------------- check the commands
noinstnum8	move.b	d6,trk_cmd(a5)	;save the effect number
		beq.w	fx8	;no effect
		move.b	trk_cmdqual(a5),d4	;get qualifier...
		add.b	d6,d6	;* 2
		move.w	f_table8(pc,d6.w),d0
		jmp	fst8(pc,d0.w)
f_table8	dc.w	fx8-fst8,fx8-fst8,fx8-fst8,f_038-fst8,fx8-fst8,fx8-fst8,fx8-fst8,fx8-fst8
		dc.w	f_088-fst8,f_098-fst8,fx8-fst8,f_0b8-fst8,f_0c8-fst8,fx8-fst8,fx8-fst8,f_0f8-fst8
		dc.w	fx8-fst8,fx8-fst8,fx8-fst8,fx8-fst8,fx8-fst8,f_158-fst8,f_168-fst8,fx8-fst8
		dc.w	fx8-fst8,f_198-fst8,fx8-fst8,fx8-fst8,fx8-fst8,f_1d8-fst8,fx8-fst8,f_1f8-fst8
fst8
; ---------------- tempo (F)
f_0f8		tst.b	d4		;test effect qual..
		beq.s	fx0fchgblck8	;if effect qualifier (last 2 #'s)..
		cmp.b	#$f0,d4		;..is zero, go to next block
		bhi.s	fx0fspecial8
		moveq	#0,d0
		move.b	d4,d0
		bsr.w	_SetTempo
		bra.w	fx8
; ---------------- no, it was FFx
fx0fspecial8	cmp.b	#$f2,d4
		bne.s	isfxfe8
; ---------------- it was FF2, nothing to do now
f_1f8		move.b	d5,(a5)	; save the note number
		moveq	#0,d5	; clear the number for awhile
	IFNE	HOLD
		move.b	trk_inithold(a5),trk_noteoffcnt(a5) ;initialize hold
		bne.w	plr_endloop08	
		st	trk_noteoffcnt(a5)
	ENDC
		bra.w	plr_endloop08
isfxfe8		cmp.b	#$fe,d4
		bne.s	notcmdfe8
; ---------------- it was FFE, stop playing
		clr.w	mmd_pstate(a2)
		bra.w	fx8
notcmdfe8	cmp.b	#$fd,d4 ;change period
		bne.s	isfxff8
; ---------------- FFD, change the period, don't replay the note
		cmp.w	#8,d7
		bge.w	fx8
		movea.l	trk_periodtbl(a5),a0	;period table
		subq.b	#1,d5
		bmi.w	plr_endloop08	;under zero, do nothing
		add.b	d5,d5
		move.w	0(a0,d5.w),trk_prevper(a5) ;get & push the period
		moveq	#0,d5		;don't retrigger note
		bra.w	fx8	;done!!
isfxff8		cmp.b	#$ff,d4		;note off??
		bne.w	fx8
		move.w	d7,d0
		bsr.w	_ChannelO8
		bra.w	fx8
; ---------------- F00
fx0fchgblck8	move.b	#1,nextblock-DB(a6)
		bra.w	fx8
; ---------------- change volume
f_0c8		btst	#4,msng_flags(a4)	;look at flags
		bne.s	volhex8
		move.b	d4,d1		;get again
		lsr.b	#4,d4		;get number from left
		mulu	#10,d4		;number of tens
		and.b	#$0f,d1		;this time don't get tens
		add.b	d1,d4		;add them
volhex8		cmp.b	#64,d4
		bhi.s	go_nocmd8
		movea.l	trk_audioaddr(a5),a0
		movea.l	ac_vol(a0),a0
		move.b	d4,(a0)
go_nocmd8	bra.w	fx8
; ---------------- tempo2 change??
f_098
	IFNE	CHECK
		and.b	#$1F,d4
		bne.s	fx9chk8
		moveq	#$20,d4
	ENDC
fx9chk8		move.b	d4,msng_tempo2(a4)
		bra	fx8
; ---------------- finetune
f_158
	IFNE	CHECK
		cmp.b	#7,d4
		bgt	fx8
		cmp.b	#-8,d4
		blt	fx8
	ENDC
		move.b	d4,trk_finetune(a5)
		bra	fx8
; ---------------- repeat loop
f_168		tst.b	d4
		bne.s	plr_dorpt8
		move.w	mmd_pline(a2),rptline-DB(a6)
		bra	fx8
plr_dorpt8	tst.w	rptcounter-DB(a6)
		beq.s	plr_newrpt8
		subq.w	#1,rptcounter-DB(a6)
		beq.s	fx8
		bra.s	plr_setrptline8
plr_newrpt8	move.b	d4,rptcounter+1-DB(a6)
plr_setrptline8	move.w	rptline-DB(a6),d0
		addq.w	#1,d0
		move.w	d0,nextblockline-DB(a6)
		bra.s	fx8
; ---------------- note off time set??
f_088
	IFNE	HOLD
		move.b	d4,d0
		and.b	#$0f,d4
		move.b	d4,trk_inithold(a5)	;right = hold
	ENDC
		bra.s	fx8
; ---------------- sample begin offset
f_198		tst.b	d4
		beq.s	fx8
		lsl.w	#8,d4
		move.w	d4,trk_soffset(a5)
		bra.s	fx8
; ---------------- cmd Bxx, "position jump"
f_0b8	
	IFNE	CHECK
		cmp.w	msng_songlen(a4),d4	;test the song length
		bhi.s	fx8
	ENDC
		move.w	d4,mmd_pseqnum(a2)
		st	nextblock-DB(a6)
		bra.s	fx8
; ---------------- cmd 1Dxx, jump to next seq, line # specified
f_1d8		move.w	#$1ff,nextblock-DB(a6)
		addq.w	#1,d4
		move.w	d4,nextblockline-DB(a6)
		bra.s	fx8
; ---------------- try portamento (3)
f_038		subq.b	#1,d5
		bmi.s	plr_setfx3spd8
plr_fx3note8	movea.l	trk_periodtbl(a5),a0
		add.b	msng_playtransp(a4),d5	;play transpose
		add.b	trk_stransp(a5),d5 ;and instrument transpose
		bmi.s	plr_endloop08	;again.. too low
		add.w	d5,d5
		move.w	0(a0,d5.w),trk_porttrgper(a5) ;period of this note is the target
plr_setfx3spd8	tst.b	d4		;qual?
		beq.s	plr_endloop08	;0 -> do nothing
		move.b	d4,trk_prevportspd(a5)	;remember size
		bra.s	plr_endloop08
; ---------------- everything is checked now: play or not to play??
fx8		tst.b	d5	;Now we'll check if we have to play a note
		beq.s	plr_endloop08	;no.
; ---------------- we decided to play
		move.b	d5,(a5)
		move.w	d5,d1
		moveq	#0,d3
		move.b	trk_previnstr(a5),d3	;instr #
		movea.l	trk_previnstra(a5),a3	;instr data address
	IFNE	HOLD
		move.b	trk_inithold(a5),trk_noteoffcnt(a5)
		bne.s	plr_nohold8
		st	trk_noteoffcnt(a5)
	ENDC
; ---------------- and finally:
plr_nohold8	bsr	_PlayNote8
; ---------------- end of loop: handle next track, or quit
plr_endloop08	addq.b	#1,d7
		cmp.w	numtracks-DB(a6),d7
		blt.w	plr_loop08
		addq.l	#8,sp		;trackdataptrs
		lea	trackdata8-DB(a6),a5
; and advance song pointers
		lea	nextblock-DB(a6),a3
		move.w	nextblockline-DB(a6),d1
		beq.s	plr_advlinenum
		clr.w	nextblockline-DB(a6)
		subq.w	#1,d1
		bra.s	plr_linenumset
plr_advlinenum	move.w	mmd_pline(a2),d1	;get current line #
		addq.w	#1,d1			;advance line number
plr_linenumset	cmp.w	numlines-DB(a6),d1 	;advance block?
		bhi.s	plr_chgblock		;yes.
		tst.b	(a3)			;command F00/1Dxx?
		beq.s	plr_nochgblock		;no, don't change block
plr_chgblock	tst.b	nxtnoclrln-DB(a6)
		bne.s	plr_noclrln
		moveq	#0,d1			;clear line number
plr_noclrln	tst.w	mmd_pstate(a2)		;play block or play song
		bpl.s	plr_nonewseq		;play block only...
		move.w	mmd_pseqnum(a2),d0	;get play sequence number
		tst.b	(a3)
		bmi.s	plr_noadvseq		;Bxx sets nextblock to -1
		addq.w	#1,d0			;advance sequence number
plr_noadvseq	cmp.w	msng_songlen(a4),d0	;is this the highest seq number??
		blt.s	plr_notagain		;no.
		moveq	#0,d0			;yes: restart song
plr_notagain	move.b	d0,mmd_pseqnum+1(a2)	;remember new playseq-#
		lea	msng_playseq(a4),a0	;offset of sequence table
		move.b	0(a0,d0.w),d0		;get number of the block
	IFNE	CHECK
		cmp.w	msng_numblocks(a4),d0	;beyond last block??
		blt.s	plr_nolstblk		;no..
		moveq	#0,d0			;play block 0
	ENDC
plr_nolstblk	move.b	d0,mmd_pblock+1(a2)	;store block number
plr_nonewseq	clr.w	(a3)		 	;clear this if F00 set it
plr_nochgblock	move.w	d1,mmd_pline(a2)	;set new line number

	IFNE	HOLD
		lea	trackdata8-DB(a6),a5
		movea.l	mmd_blockarr(a2),a0
		move.w	mmd_pblock(a2),d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	0(a0,d0.w),a1	;block...
		move.w	mmd_pline(a2),d0
		move.b	msng_tempo2(a4),d3	;interrupts/note
	IFNE	PLAYMMD0
		cmp.b	#'1',3(a2)
		beq.s	plr_mmd1_2
		move.b	(a1),d7			;# of tracks
		move.w	d0,d1
		add.w	d0,d0	;d0 * 2
		add.w	d1,d0	;+ d0 = d0 * 3
		mulu	d7,d0
		lea	2(a1,d0.w),a3
		subq.b	#1,d7
plr_chkholdb	movea.l	(a5)+,a1		;track data
		tst.b	trk_noteoffcnt(a1)	;hold??
		bmi.s	plr_holdendb		;no.
		move.b	(a3),d1			;get the 1st byte..
		bne.s	plr_hold1b
		move.b	1(a3),d1
		and.b	#$f0,d1
		beq.s	plr_holdendb		;don't hold
		bra.s	plr_hold2b
plr_hold1b	and.b	#$3f,d1			;note??
		beq.s	plr_hold2b		;no, cont hold..
		move.b	1(a3),d1
		and.b	#$0f,d1			;get cmd
		subq.b	#3,d1			;is there command 3 (slide)
		bne.s	plr_holdendb		;no -> end holding
plr_hold2b	add.b	d3,trk_noteoffcnt(a1)	;continue holding...
plr_holdendb	addq.l	#3,a3		;next note
		dbf	d7,plr_chkholdb
		bra.s	nonewnote8
plr_mmd1_2
	ENDC
		move.w	(a1),d7		;# of tracks
		add.w	d0,d0
		add.w	d0,d0	;d0 = d0 * 4
		mulu	d7,d0
		lea	8(a1,d0.l),a3
		subq.b	#1,d7
plr_chkhold	movea.l	(a5)+,a1		;track data
		tst.b	trk_noteoffcnt(a1)	;hold??
		bmi.s	plr_holdend		;no.
		move.b	(a3),d1			;get the 1st byte..
		bne.s	plr_hold1
		move.b	1(a3),d0
		and.b	#$3F,d0
		beq.s	plr_holdend		;don't hold
		bra.s	plr_hold2
plr_hold1	and.b	#$7f,d1			;note??
		beq.s	plr_hold2		;no, cont hold..
		move.b	2(a3),d1
		subq.b	#3,d1			;is there command 3 (slide)
		bne.s	plr_holdend		;no -> end holding
plr_hold2	add.b	d3,trk_noteoffcnt(a1)	;continue holding...
plr_holdend	addq.l	#4,a3		;next note
		dbf	d7,plr_chkhold
	ENDC	
nonewnote8	moveq	#0,d3
		move.b	mmd_counter(a2),d3
plr_fxtime	lea	trackdata8-DB(a6),a3
		moveq	#0,d7	;clear track count
plr_loop1:	movea.l	(a3)+,a5
		cmp.w	#8,d7
		bge.w	endl
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		move.b	trk_cmd(a5),d6	;get the fx number
		move.b	trk_cmdqual(a5),d4	;and the last 2 #'s
	IFNE	HOLD
		tst.b	trk_noteoffcnt(a5)
		bmi.s	plr_nofade
		subq.b	#1,trk_noteoffcnt(a5)
		bpl.s	plr_nofade
		move.w	d7,d0
		bsr.w	_ChannelO8
plr_nofade
	ENDC
		add.b	d6,d6	;* 2
		move.w	fx_table(pc,d6.w),d0
		jmp	fxs(pc,d0.w)
fx_table	dc.w	fx_00-fxs,fx_01-fxs,fx_02-fxs,fx_03-fxs,fx_04-fxs
		dc.w	fx_05-fxs,fx_06-fxs,fx_07-fxs,fx_xx-fxs,fx_xx-fxs
		dc.w	fx_0a-fxs,fx_xx-fxs,endl-fxs,fx_0d-fxs,fx_xx-fxs
		dc.w	fx_0f-fxs
		dc.w	fx_xx-fxs,fx_11-fxs,fx_12-fxs,fx_13-fxs,fx_14-fxs
		dc.w	fx_xx-fxs,fx_xx-fxs,fx_xx-fxs,fx_18-fxs,fx_xx-fxs
		dc.w	fx_1a-fxs,fx_1b-fxs,fx_xx-fxs,fx_xx-fxs,fx_1e-fxs
		dc.w	fx_1f-fxs
fxs:
;	**************************************** Effect 01 ******
fx_01:		tst.b	d3
		bne.s	fx_01nocnt0
		btst	#5,msng_flags(a4)	;FLAG_STSLIDE??
		bne	endl
fx_01nocnt0	sub.w	d4,trk_prevper(a5)
		move.w	trk_prevper(a5),d5
		cmp.w	#113,d5
		bge	plr_newper
		move.w	#113,d5
		move.w	d5,trk_prevper(a5)
		bra	plr_newper
;	**************************************** Effect 11 ******
fx_11		tst.b	d3
		bne	fx_xx
		sub.w	d4,trk_prevper(a5)
		move.w	trk_prevper(a5),d5
		bra	plr_newper
;	**************************************** Effect 02 ******
fx_02:		tst.b	d3
		bne.s	fx_02nocnt0
		btst	#5,msng_flags(a4)
		bne	endl
fx_02nocnt0	add.w	d4,trk_prevper(a5)
		move.w	trk_prevper(a5),d5
		bra.w	plr_newper
;	**************************************** Effect 12 ******
fx_12		tst.b	d3
		bne	fx_xx
		add.w	d4,trk_prevper(a5)
		move.w	trk_prevper(a5),d5
		bra	plr_newper
;	**************************************** Effect 00 ******
fx_00:		tst.b	d4	;both fxqualifiers are 0s: no arpeggio
		beq.w	fx_xx
		move.l	d3,d0
		divu	#3,d0
		swap	d0
		tst.w	d0
		bne.s	fx_arp12
		and.b	#$0f,d4
		add.b	(a5),d4
		bra.s	fx_doarp
fx_arp12:	subq.b	#1,d0
		bne.s	fx_arp2
		lsr.b	#4,d4
		add.b	(a5),d4
		bra.s	fx_doarp
fx_arp2:	move.b	(a5),d4
fx_doarp:	subq.b	#1,d4		;-1 to make it 0 - 127
		add.b	msng_playtransp(a4),d4	;add play transpose
		add.b	trk_stransp(a5),d4	;add instrument transpose
		add.b	d4,d4
		movea.l	trk_periodtbl(a5),a1
		move.w	0(a1,d4.w),d5
		bra.w	plr_newper
;	**************************************** Effect 04 ******
fx_14		move.b	#6,trk_vibshift(a5)
		bra.s	vib_cont
fx_04		move.b	#5,trk_vibshift(a5)
vib_cont	tst.b	d3
		bne.s	nonvib
		move.b	d4,d1
		beq.s	nonvib
		and.w	#$0f,d1
		beq.s	plr_chgvibspd
		move.w	d1,trk_vibrsz(a5)
plr_chgvibspd:	and.b	#$f0,d4
		beq.s	nonvib
		lsr.b	#3,d4
		and.b	#$3e,d4
		move.b	d4,trk_vibrspd(a5)
nonvib:		move.b	trk_vibroffs(a5),d0
		lsr.b	#2,d0
		and.w	#$1f,d0
		moveq	#0,d1
		move.b	sinetable(pc,d0.w),d5
		ext.w	d5
		muls	trk_vibrsz(a5),d5
		move.b	trk_vibshift(a5),d1
		asr.w	d1,d5
		add.w	trk_prevper(a5),d5
		move.b	trk_vibrspd(a5),d0
		add.b	d0,trk_vibroffs(a5)
		bra.w	plr_newper
sinetable:	dc.b	0,25,49,71,90,106,117,125,127,125,117,106,90,71,49
		dc.b	25,0,-25,-49,-71,-90,-106,-117,-125,-127,-125,-117
		dc.b	-106,-90,-71,-49,-25,0
;	**************************************** Effect 06 ******
fx_06:		tst.b	d3
		bne.s	fx_06nocnt0
		btst	#5,msng_flags(a4)
		bne	newvals
fx_06nocnt0	bsr.s	plr_volslide		;Volume slide
		bra.s	nonvib			;+ Vibrato
;	**************************************** Effect 07 ******
fx_07		tst.b	d3
		bne.s	nontre
		move.b	d4,d1
		beq.s	nontre
		and.w	#$0f,d1
		beq.s	plr_chgtrespd
		move.w	d1,trk_tremsz(a5)
plr_chgtrespd	and.b	#$f0,d4
		beq.s	nonvib
		lsr.b	#2,d4
		and.b	#$3e,d4
		move.b	d4,trk_tremspd(a5)
nontre		move.b	trk_tremoffs(a5),d0
		lsr.b	#3,d0
		and.w	#$1f,d0
		moveq	#0,d1
		move.b	sinetable(pc,d0.w),d5
		ext.w	d5
		muls	trk_tremsz(a5),d5
		asr.w	#7,d5
		move.b	trk_tremspd(a5),d0
		add.b	d0,trk_tremoffs(a5)
		move.b	trk_prevvol(a5),d1
		add.b	d5,d1
		bpl.s	tre_pos
		moveq	#0,d1
tre_pos		cmp.b	#64,d1
		ble.s	tre_no2hi
		moveq	#64,d1
tre_no2hi	move.b	d1,trk_tempvol(a5)
		bra.w	newvals
;	**************************************** Effect 0D/0A ***
fx_0a:
fx_0d:		tst.b	d3
		bne.s	fx_0dnocnt0
		btst	#5,msng_flags(a4)
		bne	newvals
fx_0dnocnt0	bsr.s	plr_volslide
		bra	newvals
;	********* VOLUME SLIDE FUNCTION *************************
plr_volslide	move.b	d4,d0
		moveq	#0,d1
		move.b	trk_prevvol(a5),d1 ;move previous vol to d1
		and.b	#$f0,d0
		bne.s	crescendo
		sub.b	d4,d1	;sub from prev. vol
voltest0	bpl.s	novolover64
		moveq	#0,d1	;volumes under zero not accepted!!!
		bra.s	novolover64
crescendo:	lsr.b	#4,d0
		add.b	d0,d1
voltest		cmp.b	#64,d1
		ble.s	novolover64
		moveq	#64,d1
novolover64	move.b	d1,trk_prevvol(a5)
		movea.l	trk_audioaddr(a5),a0
		movea.l	ac_vol(a0),a0
		move.b	d1,(a0)
		rts
;	**************************************** Effect 1A ******
fx_1a		tst.b	d3
		bne	fx_xx
		move.b	trk_prevvol(a5),d1
		add.b	d4,d1
		bsr.s	voltest
		bra	newvals
;	**************************************** Effect 1B ******
fx_1b		tst.b	d3
		bne	fx_xx
		move.b	trk_prevvol(a5),d1
		sub.b	d4,d1
		bsr.s	voltest0
		bra	newvals
;	**************************************** Effect 05 ******
fx_05:		tst.b	d3
		bne.s	fx_05nocnt0
		btst	#5,msng_flags(a4)
		bne	newvals
fx_05nocnt0	bsr.s	plr_volslide		;Volume slide
		bra.s	fx_03nocnt0
;	**************************************** Effect 03 ******
fx_03:		tst.b	d3
		bne.s	fx_03nocnt0
		btst	#5,msng_flags(a4)
		bne	newvals
fx_03nocnt0	move.w	trk_porttrgper(a5),d0	;d0 = target period
		beq.w	newvals	;no target period specified
		move.w	trk_prevper(a5),d1	;d1 = curr. period
		move.b	trk_prevportspd(a5),d4	;get prev. speed
		cmp.w	d0,d1
		bhi.s	subper	;curr. period > target period
		add.w	d4,d1	;add the period
		cmp.w	d0,d1
		bge.s	targreached
		bra.s	targnreach
subper:		sub.w	d4,d1	;subtract
		cmp.w	d0,d1	;compare current period to target period
		bgt.s	targnreach
targreached:	move.w	trk_porttrgper(a5),d1 ;eventually push target period
		clr.w	trk_porttrgper(a5) ;now we can forget everything
targnreach:	move.w	d1,trk_prevper(a5)
		move.w	d1,d5
		bra.s	plr_newper
;	**************************************** Effect 13 ******
fx_13:		move.w	trk_prevper(a5),d5 ;this is very simple: get the old period
		cmp.b	#3,d3		;and..
		bge.s	plr_newper	;if counter < 3
		sub.w	d4,d5	;subtract effect qualifier
		bra.s	plr_newper
;	**************************************** Effect 1E ******
fx_1e		tst.w	blkdelay-DB(a6)
		bne.s	fx_xx
		addq.w	#1,d4
		move.w	d4,blkdelay-DB(a6)
		bra.s	fx_xx
;	**************************************** Effect 18 ******
fx_18		cmp.b	d4,d3
		bne	fx_xx
		clr.w	trk_prevper(a5)
		bra.s	endl
;	**************************************** Effect 1F ******
fx_1f		move.b	d4,d1
		lsr.b	#4,d4		;note delay
		beq.s	nonotedelay
		cmp.b	d4,d3		;compare to counter
		blt.s	fx_xx		;tick not reached
		bne.s	nonotedelay
		bsr	playfxnote	;trigger note
nonotedelay	and.w	#$0f,d1		;retrig?
		beq.s	fx_xx
		moveq	#0,d0
		move.b	d3,d0
		divu	d1,d0
		swap	d0		;get modulo of counter/tick
		tst.w	d0
		bne.s	fx_xx
		bsr.s	playfxnote	;retrigger
		bra.s	fx_xx
;	**************************************** Effect 0F ******
fx_0f:		bsr.s	cmd_F
;	*********************************************************
fx_xx:
newvals:	move.w	trk_prevper(a5),d5
plr_newper
plr_tmpper	movea.l	trk_audioaddr(a5),a1	;get channel address
		move.w	d5,ac_per(a1)		;push period
endl:		addq.b	#1,d7	;increment channel number
		cmp.w	numtracks-DB(a6),d7	;all channels done???
		blt.w	plr_loop1	;not yet!!!

		lea	$dff000,a0		;a0 = CUSTOM
		move.w	#1,$9c(a0)		;clear interrupt
plr_exit8	movem.l	(sp)+,d0-d7/a0-a6
		rte

cmd_F		cmp.b	#$f1,d4
		bne.s	no0ff1
		cmp.b	#3,d3
		beq.s	playfxnote
		rts
no0ff1:		cmp.b	#$f2,d4
		bne.s	no0ff2
		cmp.b	#3,d3
		beq.s	playfxnote
		rts
no0ff2:		cmp.b	#$f3,d4
		bne.s	no0ff3
		move.b	d3,d0
		and.b	#2+4,d0		;is 2 or 4
		beq.s	cF_rts
playfxnote:	moveq	#0,d1
		move.b	(a5),d1		;get note # of previous note
		beq.s	cF_rts
		move.b	trk_noteoffcnt(a5),d0	;get hold counter
		bmi.s	pfxn_nohold		;no hold, or hold over
		add.b	d3,d0			;increase by counter val
		bra.s	pfxn_hold
pfxn_nohold	move.b	trk_inithold(a5),d0	;get initial hold
		bne.s	pfxn_hold
		st	d0
pfxn_hold	move.b	d0,trk_noteoffcnt(a5)
		move.l	d3,-(sp)
		moveq	#0,d3
		move.b	trk_previnstr(a5),d3	;and prev. sample #
		move.l	a3,-(sp)
		movea.l	trk_previnstra(a5),a3
		bsr	_PlayNote8
		movea.l	(sp)+,a3
		move.l	(sp)+,d3
		rts
no0ff3:		cmp.b	#$f8,d4		;f8 = filter off
		beq.s	plr_filteroff
		cmp.b	#$f9,d4		;f9 = filter on
		bne.s	cF_rts
		bclr	#1,$bfe001
		rts
plr_filteroff:	bset	#1,$bfe001
cF_rts		rts

_SetTempo:	move.l	_module8-DB(a6),d1
		beq.s	ST_x
		movea.l	d1,a0
		movea.l	mmd_songinfo(a0),a0
		move.w	d0,msng_deftempo(a0)
		tst.w	d0
		ble.s	ST_maxszcnt
		cmp.w	#9,d0
		bls.s	ST_nodef8tempo
ST_maxszcnt	moveq	#10,d0
ST_nodef8tempo	add.b	#9,d0
		move.b	d0,currchszcnt-DB+1(a6)
		lea	eightchsizes-10-DB(a6),a0
		move.b	0(a0,d0.w),d0	;get buffersize / 2
		move.w	d0,currchsize2-DB(a6)
		asl.w	#3,d0		;get buffersize * 4
		move.w	d0,currchsize-DB(a6)
ST_x		rts

_Rem8chan:	move.l	a6,-(sp)
		lea	DB,a6
		move.b	eightrkon-DB(a6),d0
		beq.s	no8init
		clr.b	eightrkon-DB(a6)
		move.w	#1<<7,$dff09a
		moveq	#7,d0
		move.l	prevaud-DB(a6),$7c.w
no8init		move.l	(sp)+,a6
		rts

_End8Play:	tst.b	play8
		beq.s	noend8play
		move.w	#1<<7,$dff09a
		move.w	#$F,$dff096
		clr.b	play8
noend8play	rts

; *************************************************************************
; *************************************************************************
; ***********          P U B L I C   F U N C T I O N S          ***********
; *************************************************************************
; *************************************************************************

		xdef	_PlayModule8
		xdef	_InitPlayer8,StopMod,_StopPlayer8
		xdef	_ContModule8

; *************************************************************************
; InitModule8(a0 = module) -- extract expansion data etc.. from the module
; *************************************************************************

_InitModule8:	movem.l	a2-a3/d2,-(sp)
		move.l	a0,d0
		beq.s	IM_exit			;0 => xit
		lea	holdvals-DB(a6),a2
		move.l	mmd_expdata(a0),d0	;expdata...
		beq.s	IM_clrhlddec		;none here
		move.l	d0,a1
		move.l	4(a1),d0		;exp_smp
		beq.s	IM_clrhlddec	;again.. nothing
		move.l	d0,a0		;InstrExt...
		move.w	8(a1),d2	;# of entries
		beq.s	IM_clrhlddec
		subq.w	#1,d2		;- 1 (for dbf)
		move.w	10(a1),d0	;entry size
IM_loop1	cmp.w	#3,d0
		ble.s	IM_noftune
		move.b	3(a0),63(a2)
IM_noftune	move.b	(a0),(a2)+	;InstrExt.hold -> holdvals
		adda.w	d0,a0		;ptr to next InstrExt
		dbf	d2,IM_loop1
		bra.s	IM_exit
IM_clrhlddec	moveq	#125,d0		;no InstrExt => clear holdvals/decays
IM_loop2	clr.b	(a2)+
		dbf	d0,IM_loop2
IM_exit		movem.l	(sp)+,a2-a3/d2
		rts


; *************************************************************************
; ContModule8(a0 = module) -- continue playing
; *************************************************************************
_ContModule8	bsr.w	_End8Play
		moveq	#0,d0
		bra.s	contpoint8
; *************************************************************************
; PlayModule8(a0 = module)  -- init and play a module
; *************************************************************************
_PlayModule8:	st	d0
contpoint8	move.l	a6,-(sp)
		lea	DB,a6
		movem.l	a0/d0,-(sp)
		bsr.s	_InitModule8
		movem.l	(sp)+,a0/d0
		move.l	a0,d1
		beq.s	PM_end		;module failure
		bsr.w	_End8Play
		clr.l	_module8-DB(a6)
		move.w	_modnum8,d1
		beq.s	PM_modfound
PM_nextmod	tst.l	mmd_expdata(a0)
		beq.s	PM_modfound
		move.l	mmd_expdata(a0),a1
		tst.l	(a1)
		beq.s	PM_modfound		;no more modules here!
		move.l	(a1),a0
		subq.w	#1,d1
		bgt.s	PM_nextmod
PM_modfound	movea.l	mmd_songinfo(a0),a1		;song
		move.b	msng_tempo2(a1),mmd_counter(a0)	;init counter
		btst	#0,msng_flags(a1)
		bne.s	PM_filon
		bset	#1,$bfe001
		bra.s	PM_filset
PM_filon	bclr	#1,$bfe001
PM_filset	tst.b	d0
		beq.s	PM_noclr
		clr.l	mmd_pline(a0)
PM_noclr	move.w	mmd_pseqnum(a0),d1
		add.w	#msng_playseq,d1
		move.b	0(a1,d1.w),d1
		move.b	d1,mmd_pblock+1(a0)
		move.w	#-1,mmd_pstate(a0)
		move.l	a0,_module8-DB(a6)
		move.l	mmd_expdata(a0),d0
		beq.s	PM_start
		movea.l	d0,a0
		lea	36(a0),a0	;track split mask
		bsr.s	_SetChMode
PM_start	bsr.s	_Start8Play
PM_end		move.l	(sp)+,a6
		rts

_SetChMode	;a0 = address of 4 UBYTEs
		movem.l	a2/d2,-(sp)
		lea	trksplit-DB(a6),a2
		lea	t038+trk_split-DB(a6),a1
		moveq	#3,d0
		moveq	#0,d1
scm_loop	lsr.b	#1,d1
		move.b	(a0)+,d2
		beq.s	scm_split
		moveq	#0,d2
		bra.s	scm_nosplit
scm_split	or.b	#8,d1
		st	d2
scm_nosplit	move.b	d2,(a1)
		move.b	d2,4*T03SZ(a1)
		lea	T03SZ(a1),a1
		move.b	d2,(a2)+
		dbf	d0,scm_loop
		move.w	d1,chdmamask-DB(a6)
		movem.l	(sp)+,a2/d2
rts:		rts

_Start8Play:	;d0 = pstate
		lea	_audiobuff,a0
		move.w	#1600-1,d1
clrbuffloop:	clr.w	(a0)+		;clear track buffers
		dbf	d1,clrbuffloop
		move.l	_module8-DB(a6),d0
		beq.s	rts
		move.l	d0,a0
		movea.l	mmd_songinfo(a0),a0
		move.w	msng_deftempo(a0),d0	;get deftempo
		bsr.w	_SetTempo
		lea	$dff000,a0
		move.w	currchsize2-DB(a6),d0
		move.w	d0,$a4(a0)	;set audio buffer sizes
		move.w	d0,$b4(a0)	;according to tempo selection
		move.w	d0,$c4(a0)
		move.w	d0,$d4(a0)
		move.w	#227,d1
		move.w	d1,$a6(a0)
		move.w	d1,$b6(a0)
		move.w	d1,$c6(a0)
		move.w	d1,$d6(a0)
		move.l	#_audiobuff,$a0(a0)
		move.l	#_audiobuff+800,$b0(a0)
		move.l	#_audiobuff+1600,$c0(a0)
		move.l	#_audiobuff+2400,$d0(a0)
		moveq	#64,d1
		move.w	d1,$a8(a0)
		move.w	d1,$b8(a0)
		move.w	d1,$c8(a0)
		move.w	d1,$d8(a0)
		clr.b	whichbuff-DB(a6)
		movea.l	4.w,a1
		move.w	#$4000,$9a(a0)
		addq.b	#1,$126(a1)
		lea	track0hw-DB(a6),a1
		moveq	#7,d1
clrtrkloop	clr.l	(a1)
		clr.w	ac_per(a1)
		adda.w	#SIZE4TRKHW/4,a1
		dbf	d1,clrtrkloop
		move.w	#$F,$dff096	;audio DMA off
		bsr.w	_Wait1line	;wait until all stopped
		st	play8-DB(a6)
		move.w	#$8080,$9a(a0)
		move.w	chdmamask-DB(a6),d1
		bset	#15,d1
		move.w	d1,$96(a0)
		movea.l	4.w,a1
		subq.b	#1,$126(a1)
		bge.s	x8play
		move.w	#$c000,$9a(a0)
x8play		rts
; *************************************************************************
; InitPlayer8() -- allocate interrupt, audio, serial port etc...
; *************************************************************************
_InitPlayer8:	bsr.s	_AudioInit
		tst.l	d0
		bne.s	IP_error
		rts
IP_error	bsr.s	StopMod
		moveq	#-1,d0
		rts
; *************************************************************************
; StopPlayer8() -- stop music
; *************************************************************************
_StopPlayer8:	move.l	_module8,d0
		beq.s	SP_nomod
		movea.l	d0,a0
		clr.w	mmd_pstate(a0)
		clr.l	_module8
SP_nomod	bra.w	_End8Play

; *************************************************************************
; RemPlayer8() -- free interrupt, audio, serial port etc..
; *************************************************************************
StopMod:	bsr.s	_StopPlayer8
;		vvvvvvvvvvvvvvvv  to _AudioRem
; *************************************************************************
_AudioRem:	movem.l	a5-a6,-(sp)
		lea	DB,a5
		bsr.w	_Rem8chan
rem3:		movem.l	(sp)+,a5-a6
		rts

_AudioInit:	movem.l	a4/a6/d2-d3,-(sp)
		lea	DB,a4
		movea.l	4.w,a6
		move.w	#1<<7,$dff09a	;Init 8 channel stuff
			
		move.l	$70.w,prevaud-DB(a4)
		move.l	#_IntHandler8,$70.w	;set new vector		
		
		st	eightrkon-DB(a4)
		moveq	#0,d0
initret:	movem.l	(sp)+,a4/a6/d2-d3
		rts
		
DB:		;Data base pointer
chdmamask	dc.w	0
trksplit	dc.b	0,0,0,0
		even

zerodata	dc.w	0
whichbuff	dc.w	0

track0hw	dc.l	0,0,$dff0a9,0,0
		dc.w	$0001,$df,$f0a0
track1hw	dc.l	0,0,$dff0b9,0,0
		dc.w	$0002,$df,$f0b0
track2hw	dc.l	0,0,$dff0c9,0,0
		dc.w	$0004,$df,$f0c0
track3hw	dc.l	0,0,$dff0d9,0,0
		dc.w	$0008,$df,$f0d0
track4hw	dc.l	0,0,$dff0a9,0,0
		dc.w	0,0,0
track5hw	dc.l	0,0,$dff0b9,0,0
		dc.w	0,0,0
track6hw	dc.l	0,0,$dff0c9,0,0
		dc.w	0,0,0
track7hw	dc.l	0,0,$dff0d9,0,0
		dc.w	0,0,0
SIZE4TRKHW	equ	4*$1A

prevaud		dc.l	0
play8		dc.b	0
eightrkon	dc.b	0

t038:		ds.b	22
		dc.l	track0hw
		ds.b	71
		dc.b	$ff
		ds.b	22
		dc.l	track1hw
		ds.b	71
		dc.b	$ff
		ds.b	22
t238		dc.l	track2hw
		ds.b	71
		dc.b	$ff
		ds.b	22
		dc.l	track3hw
		ds.b	71
		dc.b	$ff
t4158		ds.b	22
		dc.l	track4hw
		ds.b	71
		dc.b	$ff
		ds.b	22
		dc.l	track5hw
		ds.b	71
		dc.b	$ff
		ds.b	22
t6158		dc.l	track6hw
		ds.b	71
		dc.b	$ff
		ds.b	22
		dc.l	track7hw
		ds.b	71
		dc.b	$ff
		
trackdata8	dc.l	t038,t038+T03SZ,t038+2*T03SZ,t038+3*T03SZ
		dc.l	t4158,t4158+T03SZ,t4158+2*T03SZ,t4158+3*T03SZ

blkdelay	dc.w	0	;block delay (PT PatternDelay)

eightchsizes	dc.b	110,120,130,140,150,160,170,180,190,200
currchsize	dc.w	0	;<< 3
currchsize2	dc.w	0
currchszcnt	dc.w	0

nextblock	dc.b	0 ;\ DON'T SEPARATE
nxtnoclrln	dc.b	0 :/
numtracks	dc.w	0
numlines	dc.w	0
nextblockline	dc.w	0
rptline		dc.w	0
rptcounter	dc.w	0
_module8	dc.l	0

		EVEN
holdvals	ds.b	63
		ds.b	63	;finetune

per0	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
per1	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
per2	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
per3	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
per4	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
per5	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
per6	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
per7	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
per_8	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
per_7	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
per_6	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
per_5	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
per_4	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
per_3	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
per_2	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
per_1	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

_periodtable
	dc.l	per_8,per_7,per_6,per_5,per_4,per_3,per_2,per_1,per0
	dc.l	per1,per2,per3,per4,per5,per6,per7

; the track-data structure definition:
trk_prevnote	EQU	0	;previous note number
trk_previnstr	EQU	1	;previous instrument number
trk_prevvol	EQU	2	;previous volume
trk_prevmidich	EQU	3	;previous MIDI channel
trk_cmd		EQU	4	;command (the 3rd number from right)
trk_cmdqual	EQU	5	;command qualifier (infobyte, databyte..)
trk_prevmidin	EQU	6	;previous MIDI note
trk_noteoffcnt	EQU	7	;note-off counter (hold)
trk_inithold	EQU	8	;default hold for this instrument
trk_initdecay	EQU	9	;default decay for....
trk_stransp	EQU	10	;instrument transpose
trk_finetune	EQU	11	;finetune
trk_soffset	EQU	12	;new sample offset
trk_previnstra	EQU	14	;address of the previous instrument data
trk_trackvol	EQU	18
;	the following data only on tracks 0 - 3
trk_prevper	EQU	20	;previous period
trk_audioaddr	EQU	22	;hardware audio channel base address
trk_sampleptr	EQU	26	;pointer to sample
trk_samplelen	EQU	30	;length (>> 1)
trk_porttrgper	EQU	32	;portamento (cmd 3) target period
trk_vibshift	EQU	34	;vibrato shift for ASR instruction
trk_vibrspd	EQU	35	;vibrato speed/size (cmd 4 qualifier)
trk_vibrsz	EQU	36	;vibrato size
trk_synthptr	EQU	38	;pointer to synthetic/hybrid instrument
trk_arpgoffs	EQU	42	;SYNTH: current arpeggio offset
trk_arpsoffs	EQU	44	;SYNTH: arpeggio restart offset
trk_volxcnt	EQU	46	;SYNTH: volume execute counter
trk_wfxcnt	EQU	47	;SYNTH: waveform execute counter
trk_volcmd	EQU	48	;SYNTH: volume command pointer
trk_wfcmd	EQU	50	;SYNTH: waveform command pointer
trk_volwait	EQU	52	;SYNTH: counter for WAI (volume list)
trk_wfwait	EQU	53	;SYNTH: counter for WAI (waveform list)
trk_synthvibspd	EQU	54	;SYNTH: vibrato speed
trk_wfchgspd	EQU	56	;SYNTH: period change
trk_perchg	EQU	58	;SYNTH: curr. period change from trk_prevper
trk_envptr	EQU	60	;SYNTH: envelope waveform pointer
trk_synvibdep	EQU	64	;SYNTH: vibrato depth
trk_synvibwf    EQU	66       ;SYNTH: vibrato waveform
trk_synviboffs	EQU	70	;SYNTH: vibrato pointer
trk_initvolxspd	EQU	72	;SYNTH: volume execute speed
trk_initwfxspd	EQU	73	;SYNTH: waveform execute speed
trk_volchgspd	EQU	74	;SYNTH: volume change
trk_prevnote2	EQU	75	;SYNTH: previous note
trk_synvol	EQU	76	;SYNTH: current volume
trk_synthtype	EQU	77	;>0 = synth, -1 = hybrid, 0 = no synth
trk_periodtbl	EQU	78	;pointer to period table
trk_prevportspd	EQU	82	;portamento (cmd 3) speed
trk_decay	EQU	84	;decay
trk_fadespd	EQU	85	;decay speed
trk_envrestart	EQU	86	;SYNTH: envelope waveform restart point
trk_envcount	EQU	90	;SYNTH: envelope counter
trk_split	EQU	91	;0 = this channel not splitted (OctaMED V2)
trk_vibroffs	EQU	92	;vibrato table offset \ DON'T SEPARATE
trk_tremoffs	EQU	93	;tremolo table offset /
trk_tremsz	EQU	94	;tremolo size
trk_tremspd	EQU	96	;tremolo speed
trk_tempvol	EQU	97	;temporary volume (for tremolo)

***********************************************************************
		SECTION song,DATA_C
***********************************************************************

_audiobuff:	ds.w	200*8
_modnum8:	ds.w	1
_chipzero:	ds.w	1

; Please note that Bonita.MOD on ACC29_B has been powerpacked

Module		incbin	ram:Bonita.mod

