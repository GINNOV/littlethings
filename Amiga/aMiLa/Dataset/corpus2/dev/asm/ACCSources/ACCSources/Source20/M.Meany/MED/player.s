
; I can't take credit for this code as 99.9% of it was written by Teijo.
;So why bother? Well, according to the docs on the OctaMed 2 disc there is
;an asembler file called easyplayer.a similar to a NoiseTracker replayer.
; I searched the disc but could not find it, so I`ve constructed one from
;the supplied code modules. NOTE this file is huge!

; Also, there is a mistake in the docs. When calling _RelocModule, the
;pointer to the module should be in a0, not on the stack! If you follow
;the documentation all you get is a Guru ... Illegal Address type.

; Note that you can set the flags for Midi, SynthSounds etc as explained
;in the MedPlayer docs. I`ve moved them all to the front to make life that
;little bit easier.

; If you want your code to read modules from disc then see notes further
;down. All the code required is available.

; I hope this is of use to anyone wanting to replay MED modules!

	bsr		StartPlaying


MWait	btst		#6,$bfe001
	bne.s		MWait
	
	bsr		StopPlaying
	rts	


; A self contained module replayer for MED, four channel version. These two
;subroutines play a module already in memory. The module is defined in the
;last line of this code, change the filename after incbin for your own
;module.

StartPlaying
	movem.l a0-a6/d0-d7,-(sp)
	jsr	_InitPlayer		;no error checking needed here!!

	lea	_sng,a0			a0->module loaded by INCBIN
	jsr	_RelocModule

	lea	_sng,a0
	jsr	_PlayModule

	movem.l	(sp)+,a0-a6/d0-d7

	rts


StopPlaying
	movem.l	a0-a6/d0-d7,-(sp)
	jsr	_StopPlayer
	jsr	_RemPlayer
	movem.l (sp)+,a0-a6/d0-d7
	moveq	#0,d0
	rts

; If you wanted to load a module from disc and play it, use these routines
;that are currently commented out:

		********************************

; Set up the replayer

; Entry		NONE
; Exit		d0=0 if all went well and player initialised.

;GetPlayer	jsr		_InitPlayer	set up replay system
;		rts				and return

		********************************

; Load a module and start playing it.

; Entry	a0->filename of module.
; Exit	d0=addr of relocated module or 0 if any errors occurred.

;LoadAndPlay	jsr		_LoadModule	load & relocate file
;		tst.l		d0		loaded ok?
;		beq.s		.error		if not quit!
;
;		move.l		d0,a0		a0->relocated module
;		move.l		d0,-(sp)	save pointer to module
;		jsr		_PlayModule	start playing
;		move.l		(sp)+,d0	d0=pointer to module
;.error		rts				and return

		********************************

; Stop playing a module and release its memory -- ie UnLoad it.

; Entry		a0->relocated module ( returned by LoadAndPlay )
; Exit		NONE

;StopPlaying	move.l		a0,-(sp)	save pointer to module
;
;		jsr		_StopPlayer	stop module playing
;		
;		move.l		(sp)+,a0	a0->module
;		jsr		_UnLoadModule	free module memory
;		
;		rts

		********************************

; Free resources used by the replayer

; Entry		NONE
; Exit		NONE

;FreePlayer	jsr		_RemPlayer	free resources
;		rts

		********************************

;============================================================================
;		Teijos` code starts here
;============================================================================

MIDI	EQU	0	;1 = include MIDI code
AUDDEV	EQU	1	;1 = allocate channels using audio.device
SYNTH	EQU	1	;1 = include synth-sound handler
CHECK	EQU	1	;1 = do range checkings (track, sample in mem etc.)
RELVOL	EQU	1	;1 = include relative volume handling code
IFF53	EQU	0	;1 = play IFF 3- and 5-octave samples correctly
HOLD	EQU	1	;1 = handle hold/decay
;****** Timing control ******
VBLANK	EQU	0	;1 = use VBlank interrupt (when absolutely necessary)
CIAB	EQU	1	;1 = use CIAB timers (default)
; Please use CIAB whenever possible to avoid problems with variable
; VBlank speeds and to allow the use of command F01 - FF0 (set tempo)
; If both are set to 0, the timing is left for you (never set both to 1!!),
; then you just call _IntHandler for each timing pulse.

;============================================================================

_LoadModule:
	movem.l a2-a4/a6/d2-d6,-(sp)
	moveq	#0,d6			;d6 = return value (zero = error)
	move.l  a0,a4			;a4 = module name
	movea.l 4,a6
	lea     dosname(pc),a1
	moveq	#0,d0
	jsr     -$228(a6)		;OpenLibrary()
	tst.l   d0
	beq     xlm1
	move.l  d0,a3			;a3 = DOSBase
	move.l  d0,a6
	move.l  a4,d1			;name = d1
	move.l  #1005,d2		;accessmode = MODE_OLDFILE
	jsr     -$1e(a6)		;Open()
	move.l  d0,d4			;d4 = file handle
	beq     xlm2
	move.l  d4,d1
	moveq   #0,d2
	moveq   #1,d3			;OFFSET_END
	jsr     -$42(a6)		;Seek(fh,0,OFFSET_END)
	move.l  d4,d1
	moveq	#0,d3
	not.l   d3			;OFFSET_BEGINNING
	jsr     -$42(a6)		;Seek(fh,0,OFFSET_BEGINNING)
	move.l  d0,d5			;d5 = file size
	movea.l 4,a6
	moveq   #2,d1			;get chip mem
	jsr     -$c6(a6)		;AllocMem()
	tst.l   d0
	beq.s   xlm3
	move.l  d0,a2			;a2 = pointer to module
	move.l  d4,d1	;file
	move.l  d0,d2	;buffer
	move.l  d5,d3	;length
	move.l  a3,a6
	jsr     -$2a(a6)		;Read()
	cmp.l   d5,d0
	bne.s   xlm4			;something wrong...
	cmp.l   #'MMD0',(a2)
	bne.s   xlm4			;this is not a module!!!
	movea.l a2,a0
	bsr.s   _RelocModule
	move.l  a2,d6			;no error...
	bra.s   xlm3
xlm4:	move.l  a2,a1			;error: free the memory
	move.l  d5,d0
	movea.l 4,a6
	jsr     -$d2(a6)		;FreeMem()
xlm3:	move.l  a3,a6			;close the file
	move.l  d4,d1
	jsr     -$24(a6)		;Close(fhandle)
xlm2:	move.l  a3,a1			;close dos.library
	movea.l 4,a6
	jsr     -$19e(a6)
xlm1:	move.l  d6,d0			;push return value
	movem.l (sp)+,a2-a4/a6/d2-d6	;restore registers
	rts				;and exit...
dosname dc.b	'dos.library',0

;	Function: _RelocModule(a0)
;	a0 = pointer to module

; THIS FUNCTION IS A BIT STRANGELY ARRANGED AROUND THE SMALL RELOC-ROUTINE.
reloci	move.l	24(a2),d0
	beq.s	xloci
	movea.l	d0,a0
	moveq   #0,d0
	move.b  787(a1),d0	;number of samples
	subq.b  #1,d0
relocs:	bsr.s   relocentr
	move.l	-4(a0),d3	;sample ptr
	beq.s	nosyn
	move.l	d3,a3
	tst.w	4(a3)
	bpl.s	nosyn		;type >= 0
	move.w	20(a3),d2	;number of waveforms
	lea	278(a3),a3	;ptr to wf ptrs
	subq.w	#1,d2
relsyn:	add.l	d3,(a3)+
	dbf	d2,relsyn
nosyn:	dbf     d0,relocs
xloci	rts
norel	addq.l	#4,a0
	rts
relocentr:
	tst.l   (a0)
	beq.s   norel
	add.l   d1,(a0)+
	rts
_RelocModule:
	movem.l	a2-a3/d2-d3,-(sp)
	movea.l a0,a2
	move.l  a2,d1		;d1 = ptr to start of module
	bsr.s	relocp
	movea.l 8(a2),a1
	bsr.s	reloci
rel_lp	bsr.s	relocb
	move.l	32(a2),d0	;extension struct
	beq.s	rel_ex
	move.l	d0,a0
	bsr.s	relocentr	;ptr to next module
	bsr.s	relocentr	;InstrExt...
	addq.l	#4,a0		;skip sizes of InstrExt
; We reloc the pointers of MMD0exp, so anybody who needs them can easily
; read them.
	bsr.s	relocentr	;annotxt
	addq.l	#4,a0		;annolen
	bsr.s	relocentr	;InstrInfo
	addq.l	#8,a0
	bsr.s	relocentr	;rgbtable (not useful for most people)
	addq.l	#4,a0		;skip channelsplit
	bsr.s	relocentr	;NotationInfo
	move.l	d0,a0
	move.l	(a0),d0
	beq.s	rel_ex
	move.l	d0,a2
	bsr.s	relocp
	movea.l 8(a2),a1
	bra.s	rel_lp
rel_ex	movem.l	(sp)+,d2-d3/a2-a3
	rts

relocb	move.l	16(a2),d0
	beq.s	xlocb
	movea.l	d0,a0
	move.w  504(a1),d0
	subq.b  #1,d0
rebl	bsr.s   relocentr
	dbf     d0,rebl
xlocb	rts

relocp	lea	8(a2),a0
	bsr.s	relocentr
	addq.l	#4,a0
	bsr.s	relocentr
	addq.l	#4,a0
	bsr.s	relocentr
	addq.l	#4,a0
	bra.s	relocentr

;	Function: _UnLoadModule(a0)
;	a0 = pointer to module
_UnLoadModule:
	move.l  a6,-(sp)
	move.l  a0,d0
	beq.w   xunl
	movea.l 4,a6
	move.l  4(a0),d0
	beq.s   xunl
	movea.l a0,a1
	jsr     -$d2(a6)	;FreeMem()
xunl:	move.l	(sp)+,a6
	rts
	
;	modplayer.a
;	~~~~~~~~~~~
; The music player routine for OctaMED V2.00 four channel/MIDI songs.
; Written by Teijo Kinnunen.

;the MMD0 structure offsets
mmd_id		EQU	0
mmd_modlen	EQU	4
mmd_songinfo	EQU	8
mmd_songlen	EQU	12	;currently unused
mmd_blockarr	EQU	16
mmd_blockarrlen	EQU	20
mmd_smplarr	EQU	24
mmd_smplarrlen	EQU	28
mmd_expdata	EQU	32
mmd_expsize	EQU	36
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
msng_reserved	EQU	768
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

;Trackdata sizes
T03SZ	EQU	88
T415SZ	EQU	18

		section	"text",code

_ChannelOff:	;d0 = channel #
		lea	trackdataptrs(pc),a1
		lsl.b	#2,d0
		adda.w	d0,a1
		lsr.b	#2,d0
		movea.l	(a1),a1
	IFNE	MIDI
		move.b	trk_prevmidin(a1),d1	;is it MIDI??
		beq.s	notcomidi		;not a MIDI note
choff_midi:	clr.b	trk_prevmidin(a1)
		lea	noteondata(pc),a0
		move.b	d1,1(a0)
		move.b	trk_prevmidich(a1),(a0)	;prev MIDI channel
		clr.b	2(a0)
		or.b	#$90,(a0)		;note off
		moveq	#3,d0
		bra.w	_AddMIDIData
	ENDC
notcomidi:	cmp.b	#4,d0
		bge.s	notamigatrk
	IFNE	SYNTH
		clr.l	trk_synthptr(a1)
		clr.b	trk_synthtype(a1)
	ENDC
		moveq	#1,d1
		lsl.w	d0,d1
		move.w	d1,$dff096
notamigatrk:	rts

SoundOff:	move.l	d2,-(sp)
		moveq	#15,d2
SO_loop0	move.l	d2,d0
		bsr.s	_ChannelOff
		dbf	d2,SO_loop0
		lea	_module(pc),a0
		clr.l	(a0)		;play nothing
		move.l	(sp)+,d2
		rts

_PlayNote:	;d0(w) = trk #, d1 = note #, d2 = vol, d3(w) = instr # a3 = addr of instr
		moveq	#0,d4
		bset	d0,d4	;d4 is mask for this channel
		movea.l	mmd_smplarr(a6),a0
		add.w	d3,d3			;d3 = instr.num << 2
		add.w	d3,d3
		move.l	0(a0,d3.w),d5		;get address of instrument
	IFNE	MIDI
		bne.s	inmem
		tst.b	inst_midich(a3)		;is MIDI channel set
	ENDC
	IFNE	CHECK
		beq.w	pnote_rts		; NO!!!
	ENDC
inmem:		add.b	msng_playtransp(a4),d1	;add play transpose
		add.b	inst_strans(a3),d1	;and instr. transpose
		cmp.b	#4,d0
		bge.s	nodmaoff	;track # >= 4: not an Amiga channel
		move.l	d5,a1
	IFNE	SYNTH
		tst.l	d5
		beq.s	stpdma
		tst.b	trk_synthtype(a5)
		ble.s	stpdma		;prev. type = sample/hybrid
		cmp.w	#-1,4(a1)	;type == SYNTHETIC??
		beq.s	nostpdma
	ENDC
stpdma:		move.w	d4,$dff096		;stop this channel (dmacon)
nostpdma:
	IFNE	SYNTH
		clr.l	trk_synthptr(a5)
	ENDC
nodmaoff:
	IFNE	MIDI
		move.b	trk_prevmidin(a5),d3	;get prev. midi note
		beq.s	noprevmidi
		clr.b	trk_prevmidin(a5)
		lea	noteondata+2(pc),a0
		clr.b	(a0)				;volume = 0
		move.b	d3,-(a0)
		move.b	trk_prevmidich(a5),-(a0)	;prev midi channel
		or.b	#$90,(a0)			;note off
		movem.w	d0-d1,-(sp)
		moveq	#3,d0
		bsr.w	_AddMIDIData
		movem.w	(sp)+,d0-d1
noprevmidi:	tst.b	inst_midich(a3)
		bne.w	handleMIDInote
	ENDC
	IFNE	CHECK
		cmp.w	#4,d0		;track > 3???
		bge.w	pnote_rts	;no Amiga instruments here!!!
	ENDC
; handle decay (for tracks 0 - 3 only!!)
	IFNE	HOLD
		clr.b	trk_fadespd(a5)		;no fade yet..
		move.b	trk_initdecay(a5),trk_decay(a5)	;set decay
	ENDC
		clr.b	trk_vibroffs(a5)	;clr vibrato offset
		or.w	d4,dmaonmsk
		move.l	d5,a0
		subq.b	#1,d1
	IFNE	SYNTH
		tst.w	4(a0)
		bmi.w	handleSynthnote
		clr.b	trk_synthtype(a5)
	ENDC
tlwtst0:	tst.b	d1
		bpl.s	notenot2low
		add.b	#12,d1	;note was too low, octave up
		bra.s	tlwtst0
notenot2low:	cmp.b	#62,d1
		ble.s	endpttest
		sub.b	#12,d1	;note was too high, octave down
endpttest:
		moveq	#0,d4
	IFNE	IFF53
		move.w	4(a0),d0	;Soitin-struct in a0
		bne.s	iff5or3oct	;note # in d1 (0 - ...)
	ENDC
		move.l	a0,d0
		lea	_periods(pc),a0
		move.l	a0,trk_periodtbl(a5)
		add.b	d1,d1
		move.w	0(a0,d1.w),d5 ;put period to d5
		move.l	d0,a0
		addq.l	#6,d0		;Skip structure
		move.l	(a0),d1		;length
		move.w	(a3),d4		;inst_repeat
		move.w	inst_replen(a3),d3
	IFNE	IFF53
		bra.s	end_getdata
shiftcnt	dc.b	4,3,2,1,1,0,2,2,1,1,0,0
mullencnt	dc.b	15,7,3,1,1,0,3,3,1,1,0,0
octstart	dc.b	12,12,12,12,24,24,0,12,12,24,24,36
iff5or3oct:	movem.l	d6-d7,-(sp)
		moveq	#0,d7
		move.w	d1,d7
		divu	#12,d7	;octave #
		move.l	d7,d5
		swap	d5	;note number in this oct (0-11) is in d5
		move.l	(a0),d1
		cmp.b	#2,d0
		bne.s	no3oct
		addq.l	#6,d7
		divu	#7,d1	;get length of the 1st octave
		bra.s	no5oct
no3oct:		divu	#31,d1	;get length of the 1st octave (5 octaves)
no5oct:		move.l	d1,d0		;d0 and d1 = length of the 1st oct
		move.w	(a3),d4		;inst_repeat
		move.w	inst_replen(a3),d3
		moveq	#0,d6
		move.b	shiftcnt(pc,d7.w),d6
		lsl.w	d6,d4
		lsl.w	d6,d3
		lsl.w	d6,d1
		move.b	mullencnt(pc,d7.w),d6
		mulu	d6,d0		;offset of this oct from 1st oct
		add.l	a0,d0		;add base address to offset
		addq.l	#6,d0		;skip structure
		lea	_periods(pc),a1
		add.b	octstart(pc,d7.w),d5
		add.b	d5,d5
		move.w	0(a1,d5.w),d5
		movem.l	(sp)+,d6-d7
	ENDC
end_getdata	movea.l	trk_audioaddr(a5),a1 ;base of this channel's regs
		move.l	d0,(a1)+		;put it in ac_ptr (= 0)
		cmp.w	#1,d3
		bhi.s	repeat
		
		move.l	#_chipzero,trk_sampleptr(a5) ;pointer of zero word
		move.w	#1,trk_samplelen(a5)	;length: 1 word
		lsr.l	#1,d1			;shift length right
		move.w	d1,(a1)+	;and put to custom chip (ac_len)
		bra.s	retsn1

repeat:		tst.w	d4
		beq.s	begin0		;rep. start < 2
		move.w	d4,(a1)+	;move repeat to hardware
		bra.s	beginn0
begin0:		move.w	d3,(a1)+	;ac_len
beginn0:	add.l	d4,d4		;shift
		add.l	d4,d0		;d0 = starting address of repeat
		move.l	d0,trk_sampleptr(a5)	;remember rep. start
		move.w	d3,trk_samplelen(a5)	;remember rep. length
				
retsn1:		move.w	d5,(a1)+ ;getinsdata puts period to d5 (a1 = ac_per)
		move.w	d2,(a1)	;a1 = ac_vol
		move.w	d5,trk_prevper(a5)
	IFNE	SYNTH
		tst.b	trk_synthtype(a5)
		bne.w	hSn2
	ENDC
pnote_rts	rts

	IFNE	MIDI
handleMIDInote:	add.b	#23,d1		;2 octaves higher and -1
		bpl.s	hmn_not2low	;note number not too low
hmn_2low	add.b	#12,d1		;it was too low, 1 octave up
		bmi.s	hmn_2low
hmn_not2low
		add.b	d2,d2		;volume 0 - 63 => 0 - 127
		subq.b	#1,d2		;if 128 => 127
		bpl.s	hmn_notvolu0
		moveq	#0,d2
hmn_notvolu0
		moveq	#0,d5
		move.b	inst_midich(a3),d5	;get midi chan of this instrument
		bpl.s	hmn_nosmof	;bit 7 clear
		clr.b	trk_prevmidin(a5)	;suppress note off!
		and.b	#$1F,d5		;clear all flag bits etc...
		bra.s	hmn_smof
hmn_nosmof	move.b	d1,trk_prevmidin(a5)
hmn_smof	subq.b	#1,d5		;from 1-16 to 0-15
		move.b	d5,trk_prevmidich(a5)	;save to prev midi channel

		move.b	inst_midipreset(a3),d0	;get preset #
		beq.s	nochgpres	;zero = no preset
		cmp.b	prevmidicpres(pc,d5.w),d0	;is this previous preset ??
		beq.s	nochgpres	;yes...no need to change
		lea	prevmidicpres(pc,d5.w),a1
		move.b	d0,(a1)		;save preset to prevmidicpres
		subq.b	#1,d0		;sub 1 to get 0 - 127
		lea	preschgdata+1(pc),a0
		move.b	d0,(a0)		;push the number to second byte
		move.b	#$c0,-(a0)	;command: $C
		or.b	d5,(a0)		;"or" midi channel
		moveq	#2,d0
		move.w	d1,-(sp)
		bsr.w	_AddMIDIData
		move.w	(sp)+,d1
		tst.b	d2
		beq.s	hmn_suppress	;vol = 0, don't send NOTE ON

nochgpres	lea	bytesinnotebuff(pc),a0
		movea.l	a0,a1
		adda.w	(a0)+,a0
		or.b	#$90,d5		;MIDI: Note on
		move.b	d5,(a0)+	;MIDI msg Note on & channel
		move.b	d1,(a0)+	;MIDI msg note #
		move.b	d2,(a0)		;MIDI msg volume
		beq.s	hmn_suppress	;vol = 0 -> no note
		addq.w	#3,(a1)
		rts
hmn_suppress	clr.b	trk_prevmidin(a5)
		rts

prevmidicpres:	dc.l	0,0,0,0 ; 16 bytes
	ENDC

	IFNE	SYNTH
handleSynthnote:
		move.b	d1,trk_prevnote2(a5)
		move.l	a0,trk_synthptr(a5)
		cmp.w	#-2,4(a0)	;HYBRID??
		bne.s	hSn_nossn
		st	trk_synthtype(a5)
		movea.l	278(a0),a0	;yep, get the waveform pointer
		bra.w	tlwtst0		;go and play it
hSn_nossn:	move.b	#1,trk_synthtype(a5)
		lea	_synthper(pc),a1
		move.l	a1,trk_periodtbl(a5) ;save table ptr for synth periods
		add.w	d1,d1
		move.w	0(a1,d1.w),d1
		movea.l	trk_audioaddr(a5),a1
		move.w	d1,trk_prevper(a5)
		move.w	d1,ac_per(a1)
		clr.l	trk_sampleptr(a5)
hSn2:		lea	trk_arpgoffs(a5),a1
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		clr.l	(a1)+
		move.l	#sinetable,(a1)+
		clr.w	(a1)+
		movea.l	trk_synthptr(a5),a0
                move.w	18(a0),(a1)+
                clr.b	(a1)
                cmp.b	#$E,trk_cmd(a5)
                bne.s	synth_start
                move.b	trk_cmdqual(a5),trk_wfcmd+1(a5)

synth_start:	move.l	a3,-(sp)
		movea.l	trk_audioaddr(a5),a3	;audio channel base address
		subq.b	#1,trk_volxcnt(a5)	;decrease execute counter..
		bgt.w	synth_wftbl		;not 0...go to waveform
		move.b	trk_initvolxspd(a5),trk_volxcnt(a5) ;reset counter
		move.b	trk_volchgspd(a5),d0	;volume change??
		beq.s	synth_nochgvol		;no.
		add.b	trk_synvol(a5),d0	;add previous volume
		bpl.s	synth_voln2l		;not negative
		moveq	#0,d0			;was negative => 0
synth_voln2l:	cmp.b	#$40,d0			;too high??
		ble.s	synth_voln2h		;not 2 high.
		moveq	#$40,d0			;was 2 high => 64
synth_voln2h:	move.b	d0,trk_synvol(a5)	;remember new...
		move.b	d0,ac_vol+1(a3)		;and change it
synth_nochgvol:	move.l	trk_envptr(a5),d1	;envelope pointer
		beq.s	synth_novolenv
		movea.l	d1,a1
		move.b	(a1)+,d0
		add.b	#128,d0
		lsr.b	#2,d0
		move.b	d0,trk_synvol(a5)
		move.b	d0,ac_vol+1(a3)
		addq.b	#1,trk_envcount(a5)
		bpl.s	synth_endenv
		clr.b	trk_envcount(a5)
		move.l	trk_envrestart(a5),a1
synth_endenv	move.l	a1,trk_envptr(a5)
synth_novolenv	move.w	trk_volcmd(a5),d0	;get table position ptr
		tst.b	trk_volwait(a5)		;WAI(t) active
		beq.s	synth_getvolcmd		;no
		subq.b	#1,trk_volwait(a5)	;yep, decr wait ctr
		ble.s	synth_getvolcmd		;0 => continue
		bra.w	synth_wftbl		;> 0 => still wait
synth_inccnt:	addq.b	#1,d0
synth_getvolcmd:
		addq.b	#1,d0			;advance pointer
		move.b	21(a0,d0.w),d1		;get command
		bmi.s	synth_cmd		;negative = command
		move.b	d1,trk_synvol(a5)	;set synthvol
		move.b	d1,ac_vol+1(a3)		;change it!!
		bra.w	synth_endvol		;end of volume executing
synth_cmd:	and.w	#$000f,d1
		add.b	d1,d1
		move.w	synth_vtbl(pc,d1.w),d1
		jmp	syv(pc,d1.w)
synth_vtbl:	dc.w	syv_f0-syv,syv_f1-syv,syv_f2-syv,syv_f3-syv
		dc.w	syv_f4-syv,syv_f5-syv,syv_f6-syv
		dc.w	synth_endvol-syv,synth_endvol-syv,synth_endvol-syv
		dc.w	syv_fa-syv,syv_ff-syv,synth_endvol-syv
		dc.w	synth_endvol-syv,syv_fe-syv,syv_ff-syv
syv:
syv_fe:		move.b	22(a0,d0.w),d0		;JMP
		bra.s	synth_getvolcmd
syv_f0:		move.b	22(a0,d0.w),trk_initvolxspd(a5) ;change volume ex. speed
		bra.s	synth_inccnt
syv_f1:		move.b	22(a0,d0.w),trk_volwait(a5)	;WAI(t)
		addq.b	#1,d0
		bra.s	synth_endvol
syv_f3:		move.b	22(a0,d0.w),trk_volchgspd(a5) ;set volume slide up
		bra.s	synth_inccnt
syv_f2:		move.b	22(a0,d0.w),d1
		neg.b	d1
		move.b	d1,trk_volchgspd(a5) ;set volume slide down
		bra.s	synth_inccnt
syv_fa:		move.b	22(a0,d0.w),trk_wfcmd+1(a5) ;JWS (jump wform sequence)
		clr.b	trk_wfwait(a5)
		bra.s	synth_inccnt
syv_f4:		move.b	22(a0,d0.w),d1
		bsr.s	synth_getwf
		clr.l	trk_envrestart(a5)
syv_f4end	move.l	a1,trk_envptr(a5)
		clr.b	trk_envcount(a5)
		bra.w	synth_inccnt
syv_f5:		move.b	22(a0,d0.w),d1
		bsr.s	synth_getwf
		move.l	a1,trk_envrestart(a5)
		bra.s	syv_f4end
syv_f6		clr.l	trk_envptr(a5)
		bra.w	synth_getvolcmd
synth_getwf	ext.w	d1	;d1 = wform number, returns ptr in a1
		add.w	d1,d1	;create index
		add.w	d1,d1
		lea	278(a0),a1
		adda.w	d1,a1
		movea.l	(a1),a1		;get wform address
		addq.l	#2,a1		;skip length
		rts
syv_ff:		subq.b	#1,d0
synth_endvol:	move.w	d0,trk_volcmd(a5)
synth_wftbl:	move.b	trk_synvol(a5),trk_prevvol(a5)
		adda.w	#158,a0
		subq.b	#1,trk_wfxcnt(a5)	;decr. wf speed counter
		bgt.w	synth_arpeggio		;not yet...
		move.b	trk_initwfxspd(a5),trk_wfxcnt(a5) ;restore speed counter
		move.w	trk_wfcmd(a5),d0	;get table pos offset
		move.w	trk_wfchgspd(a5),d1	;CHU/CHD ??
		beq.s	synth_tstwfwai		;0 = no change
wytanwet:	add.w	trk_perchg(a5),d1	;add value to current change
		move.w	d1,trk_perchg(a5)	;remember amount of change
		add.w	trk_prevper(a5),d1	;add initial period to it
		cmp.w	#113,d1			;overflow??
		bge.s	synth_pern2h
		moveq	#113,d1
synth_pern2h:	move.w	d1,ac_per(a3)		;push the changed period
synth_tstwfwai:	tst.b	trk_wfwait(a5)		;WAI ??
		beq.s	synth_getwfcmd		;not waiting...
		subq.b	#1,trk_wfwait(a5)	;decr wait counter
		beq.s	synth_getwfcmd		;waiting finished
		bra.w	synth_arpeggio		;still sleep...
synth_incwfc:	addq.b	#1,d0
synth_getwfcmd:	addq.b	#1,d0			;advance position counter
		move.b	-9(a0,d0.w),d1		;get command
		bmi.s	synth_wfcmd		;negative = command
		ext.w	d1
		add.w	d1,d1
		add.w	d1,d1
		movea.l	120(a0,d1.w),a1
		move.w	(a1)+,ac_len(a3)	;push waveform length
		move.l	a1,(a3) 		;and the new pointer (0 = ac_ptr)
		bra.w	synth_wfend		;no new commands now...
synth_wfcmd:	and.w	#$000f,d1		;get the right nibble
		add.b	d1,d1			;* 2
		move.w	synth_wfctbl(pc,d1.w),d1
		jmp	syw(pc,d1.w)		;jump to command
synth_wfctbl:	dc.w	syw_f0-syw,syw_f1-syw,syw_f2-syw,syw_f3-syw,syw_f4-syw
		dc.w	syw_f5-syw,syw_f6-syw,syw_f7-syw,synth_wfend-syw
		dc.w	synth_wfend-syw,syw_fa-syw,syw_ff-syw
		dc.w	syw_fc-syw,synth_getwfcmd-syw,syw_fe-syw,syw_ff-syw
syw:
syw_f7:		move.b	-8(a0,d0.w),d1
		ext.w	d1
		add.w	d1,d1
		add.w	d1,d1
		movea.l	120(a0,d1.w),a1
		addq.l	#2,a1
		move.l	a1,trk_synvibwf(a5)
		bra.s	synth_incwfc
syw_fe:		move.b	-8(a0,d0.w),d0		;jump (JMP)
		bra.s	synth_getwfcmd
syw_fc:		move.w	d0,trk_arpsoffs(a5)	;new arpeggio begin
		move.w	d0,trk_arpgoffs(a5)
synth_findare:	addq.b	#1,d0
		tst.b	-9(a0,d0.w)
		bpl.s	synth_findare
		bra.s	synth_getwfcmd
syw_f0:		move.b	-8(a0,d0.w),trk_initwfxspd(a5)	;new waveform speed
		bra	synth_incwfc
syw_f1:		move.b	-8(a0,d0.w),trk_wfwait(a5)	;wait waveform
		addq.b	#1,d0
		bra.s	synth_wfend
syw_f4:		move.b	-8(a0,d0.w),trk_synvibdep+1(a5)	;set vibrato depth
		bra.w	synth_incwfc
syw_f5:		move.b	-8(a0,d0.w),trk_synthvibspd+1(a5) ;set vibrato speed
		addq.b	#1,trk_synthvibspd+1(a5)
		bra.w	synth_incwfc
syw_f2:		moveq	#0,d1			;set slide down
		move.b	-8(a0,d0.w),d1
synth_setsld:	move.w	d1,trk_wfchgspd(a5)
		bra.w	synth_incwfc
syw_f3:		move.b	-8(a0,d0.w),d1		;set slide up
		neg.b	d1
		ext.w	d1
		bra.s	synth_setsld
syw_f6:		clr.w	trk_perchg(a5)		;reset period
		move.w	trk_prevper(a5),ac_per(a3)
		bra.w	synth_getwfcmd
syw_fa:		move.b	-8(a0,d0.w),trk_volcmd+1(a5) ;JVS (jump volume sequence)
		clr.b	trk_volwait(a5)
		bra.w	synth_incwfc
syw_ff:		subq.b	#1,d0		;pointer = END - 1
synth_wfend:	move.w	d0,trk_wfcmd(a5)
synth_arpeggio:	move.w	trk_arpgoffs(a5),d0
		beq.s	synth_vibrato
		moveq	#0,d1
		move.b	-8(a0,d0.w),d1
		add.b	trk_prevnote2(a5),d1
		movea.l	trk_periodtbl(a5),a1	;get period table
		add.w	d1,d1
		move.w	0(a1,d1.w),d1
		add.w	trk_perchg(a5),d1
		move.w	d1,trk_prevper(a5)
		move.w	d1,ac_per(a3)
		addq.b	#1,d0
		tst.b	-8(a0,d0.w)
		bpl.s	synth_noarpres
		move.w	trk_arpsoffs(a5),d0
synth_noarpres:	move.w	d0,trk_arpgoffs(a5)
synth_vibrato:	move.w	trk_synvibdep(a5),d1	;get vibrato depth
		beq.s	synth_rts		;0 => no vibrato
		move.w	trk_synviboffs(a5),d0	;get offset
		lsr.w	#4,d0			;/ 16
		and.w	#$1f,d0			;sinetable offset (0-31)
		movea.l trk_synvibwf(a5),a0
		move.b	0(a0,d0.w),d0   	;get a byte
		ext.w	d0			;to word
		muls	d1,d0			;amplify (* depth)
		asr.w	#8,d0			;and divide by 64
		move.w	trk_prevper(a5),d1	;get the old period
		add.w	d0,d1			;add vibrato...
		add.w	trk_perchg(a5),d1	;and pitch change...
		move.w	d1,ac_per(a3)		;change.
		move.w	trk_synthvibspd(a5),d0	;vibrato speed
		add.w	d0,trk_synviboffs(a5)	;add to offset
synth_rts:	move.l	(sp)+,a3
		rts
	ENDC
sinetable:	dc.b	0,25,49,71,90,106,117,125,127,125,117,106,90,71,49
		dc.b	25,0,-25,-49,-71,-90,-106,-117,-125,-127,-125,-117
		dc.b	-106,-90,-71,-49,-25,0

_Wait1line:	move.l	d0,-(sp)	;d1 = vsync counters to wait - 1
wl0:		move.b	$dff007,d0
wl1:		cmp.b	$dff007,d0
		beq.s	wl1
		dbf	d1,wl0
		move.l	(sp)+,d0
		rts
pushnewvals:	movea.l	(a1)+,a5
		lsr.b	#1,d0
		bcc.s	rpnewv
		move.l	trk_sampleptr(a5),d1
		beq.s	rpnewv
		movea.l	trk_audioaddr(a5),a0
		move.l	d1,(a0)+		;0 = ac_ptr
		move.w	trk_samplelen(a5),(a0)	;4 = ac_len
rpnewv:		rts
_StartDMA:		;This small routine turns on audio DMA
		move.w	dmaonmsk(pc),d0	;dmaonmsk contains the mask of
	IFNE MIDI
		beq.s	sdma_nodmaon	;the channels that must be turned on
	ELSEIF
		beq.s	rpnewv
	ENDC
		bset	#15,d0	;DMAF_SETCLR: set these bits in dmacon
		moveq	#80,d1
	IFNE	SYNTH
		add.w	d1,d1	;sometimes double wait time is required
	ENDC
		bsr.s	_Wait1line
		move.w	d0,$dff096	;do that!!!
		moveq	#79,d1
		bsr.s	_Wait1line
		lea	trackdataptrs(pc),a1
		bsr.s	pushnewvals
		bsr.s	pushnewvals
		bsr.s	pushnewvals
	IFNE MIDI
		bsr.s	pushnewvals
sdma_nodmaon	lea	bytesinnotebuff(pc),a0
		move.w	(a0)+,d0
		beq.s	rpnewv
		bra.w	_AddMIDIData
	ELSEIF
		bra.s	pushnewvals
	ENDC

	IFNE MIDI
prevmidipbend:	dc.w	$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
		dc.w	$2000,$2000,$2000,$2000,$2000,$2000,$2000,$2000
	ENDC
; TRACK-data structures (see definitions at the end of this file)
t03d:		ds.b	20
		dc.l	$dff0a0
		ds.b	64+20
		dc.l	$dff0b0
		ds.b	64+20
		dc.l	$dff0c0
		ds.b	64+20
		dc.l	$dff0d0
		ds.b	64
t415d:		ds.b	4*T415SZ
t815d:		ds.b	8*T415SZ	;8 bytes * 12 tracks = 96 bytes
trackdataptrs:	dc.l	t03d,t03d+T03SZ,t03d+2*T03SZ,t03d+3*T03SZ
		dc.l	t415d,t415d+T415SZ,t415d+2*T415SZ,t415d+3*T415SZ
		dc.l	t815d,t815d+T415SZ,t815d+2*T415SZ,t815d+3*T415SZ
		dc.l	t815d+4*T415SZ,t815d+5*T415SZ,t815d+6*T415SZ
		dc.l	t815d+7*T415SZ
numtracks:	dc.w	0
numlines:	dc.w	0
nextblock:	dc.b	0,0


_IntHandler:	movem.l	d2-d7/a2-a5,-(sp)
		movea.l	_module(pc),a6	;a6 = pointer of MMD0
		move.l	a6,d0
		beq.w	plr_exit
		tst.w	mmd_pstate(a6)
		beq.w	plr_exit
	IFNE	MIDI
		clr.l	dmaonmsk
	ELSEIF
		clr.w	dmaonmsk
	ENDC
		movea.l	mmd_songinfo(a6),a4
		move.l	a4,d0
		beq.w	plr_exit
		moveq	#0,d3
		move.b	mmd_counter(a6),d3
		addq.b	#1,d3
		cmp.b	msng_tempo2(a4),d3
		bge.s	plr_pnewnote	;play new note
		move.b	d3,mmd_counter(a6)
		bne.w	nonewnote	;do just fx
; --- new note!! first get address of current block
plr_pnewnote:	clr.b	mmd_counter(a6)
; --- now start to play it
		move.w	mmd_pblock(a6),d0
		movea.l	mmd_blockarr(a6),a0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	0(a0,d0.w),a2	;block...
		move.b	(a2)+,numtracks+1
		move.b	(a2)+,numlines+1
		move.w	mmd_pline(a6),d0
		move.w	d0,d1
		add.w	d0,d0	;d0 * 2
		add.w	d1,d0	;+ d0 = d0 * 3
		mulu	numtracks(pc),d0
		adda.w	d0,a2		;a2 => pointer of curr. note
		moveq	#0,d7		;number of track
		pea	trackdataptrs(pc)
plr_loop0:	moveq	#0,d5
		move.l	(sp),a1
		movea.l	(a1)+,a5	;get address of this track's struct
		move.l	a1,(sp)
; ---------------- get the note numbers
		move.b	(a2)+,d5	;get the number of this note
		move.b	(a2)+,d6	;and the 4 numbers containing fx
		move.b	(a2)+,trk_cmdqual(a5)	;get & save the fx numbers
; ---------------- clear some instrument # flags
		moveq	#0,d4		;d4 is a flag: if set, instr. is
		moveq	#0,d3		;in range G-V. If clr, it's 1-F.
; ---------------- and set them, if needed
		bclr	#7,d5		;d3 is also a flag. If it's set,
		sne	d4		;the instr. is in range 10 - 1V
		bclr	#6,d5
		sne	d3
; ---------------- check if there's an instrument number
		move.b	d6,d0
		and.w	#$f0,d0		;d0 now contains only the # of instr
		bne.s	instnum		;instrument number is not 0
		tst.b	d4		;maybe it's G (instr. #0, d4 set)
		bne.s	instnum		;yes, it really was G!!
		tst.b	d3
		beq.s	noinstnum	;it wasn't 10 - 1V either..
; ---------------- if there was, get it
instnum:	lsr.b	#4,d0		;shift it right to get number 0-F
		tst.b	d4
		beq.s	nogtov2
		add.w	#16,d0		;if G-V, add 16 to the number
nogtov2:	tst.b	d3
		beq.s	no10to1v
		add.w	#32,d0
; ---------------- finally, save the number
no10to1v:	subq.b	#1,d0
		move.b	d0,trk_previnstr(a5) ;remember instr. number!
	IFNE	HOLD
; ---------------- remember hold/decay values
		lea	holdvals(pc),a0
		move.b	0(a0,d0.w),trk_inithold(a5)
		move.b	63(a0,d0.w),trk_initdecay(a5)
	ENDC
; ---------------- get the pointer of data's of this sample in Song-struct
		asl.w	#3,d0
		lea	0(a4,d0.w),a3	;a3 contains now address of it
		move.l	a3,trk_previnstra(a5)
		moveq	#0,d0
; ---------------- get volume and make it relative (1 - 100 %)
	IFNE	RELVOL
		move.b	inst_svol(a3),d0
		mulu	trk_trackvol(a5),d0
		lsr.w	#8,d0
		move.b	d0,trk_prevvol(a5) ;vol of this instr
	ELSEIF
		move.b	inst_svol(a3),trk_prevvol(a5)
	ENDC
; ---------------- remember transpose
		move.b	inst_strans(a3),trk_stransp(a5)
; ---------------- check the commands
noinstnum	and.b	#$0f,d6		;now check only the effect part
		move.b	d6,trk_cmd(a5)	;save the effect number
		beq.w	plr_nocmd	;no effect
		move.b	d6,d0
		move.b	trk_cmdqual(a5),d6	;get qualifier...
; ---------------- there was a command (effect), but which one??
		cmp.b	#$0f,d0		;yes effect...is it Tempo???
		bne.w	not0f		;not Tempo
; ---------------- it was tempo (F)
		tst.b	d6		;test effect qual..
		beq.s	fx0fchgblck	;if effect qualifier (last 2 #'s)..
		cmp.b	#$f0,d6		;..is zero, go to next block
		bhi.s	fx0fspecial	;if it's F1-FF something special
; ---------------- just an ordinary "change tempo"-request
	IFNE	CIAB
		moveq	#0,d0		;will happen!!!
		move.b	d6,d0
		bsr	_SetTempo	;change The Tempo
		move.b	d6,msng_deftempo(a4)
	ENDC
		bra.w	plr_nocmd
; ---------------- it was FFx
fx0fspecial:	cmp.b	#$f2,d6
		bne.s	isfxfe
; ---------------- it was FF2, nothing to do now
		move.b	d5,(a5)
		moveq	#0,d5
		bra.w	plr_nocmd
isfxfe:		cmp.b	#$fe,d6
		bne.s	notcmdfe
; ---------------- it was FFE, stop playing
		clr.w	mmd_pstate(a6)
	IFNE	CIAB
		movea.l	craddr(pc),a0
		bclr	#0,(a0)
	ENDC
		bsr.w	SoundOff
		addq.l	#4,sp
		bra.w	plr_exit
notcmdfe:	cmp.b	#$fd,d6 ;change period
		bne.s	isfxff
; ---------------- FFD, change the period, don't replay the note
	IFNE	CHECK
		cmp.w	#4,d7 ;no tracks 4 - 15
		bge.w	plr_nocmd
	ENDC
		movea.l	trk_periodtbl(a5),a0	;period table
		subq.b	#1,d5    ;sub 1 to make "real" note number
		bmi.w	plr_endloop0	;under zero, do nothing
		add.b	d5,d5
		move.w	0(a0,d5.w),d0 ;get the period
		movea.l	trk_audioaddr(a5),a0
		move.w	d0,ac_per(a0) ;push the period
		moveq	#0,d5 ;and clear it so that it won't be replayed
		bra.w	plr_nocmd	;done!!
isfxff:		cmp.b	#$ff,d6		;note off??
		bne.w	plr_nocmd
		move.w	d7,d0
		bsr.w	_ChannelOff
		bra.w	plr_nocmd
; ---------------- F00, called Pattern Break in ST
fx0fchgblck:	addq.b	#1,nextblock	;next block... (F00)
		bra.w	plr_nocmd
; ---------------- was not Fxx, then it's something else!!
not0f:		cmp.b	#$0e,d0
		bne.s	not0e
		move.b	d6,trk_wfcmd+1(a5) ;set waveform command position ptr
		bra.w	plr_nocmd
not0e:		cmp.b	#$0c,d0		;new volume???
		bne.s	not0c		;NO
; ---------------- change volume
		move.b	d6,d0
		bpl.s	plr_nosetdefvol
		and.b	#$7F,d0
	IFNE	CHECK
		cmp.b	#64,d0
		bgt.s	go_nocmd
	ENDC
		moveq	#0,d1
		move.b	trk_previnstr(a5),d1
		asl.w	#3,d1
		move.b	d0,inst_svol(a4,d1.w)	;set new svol
		bra.s	plr_setvol
plr_nosetdefvol	btst	#4,msng_flags(a4)	;look at flags
		bne.s	volhex
		lsr.b	#4,d0		;get number from left
		mulu	#10,d0		;number of tens
		move.b	d6,d1		;get again
		and.b	#$0f,d1		;this time don't get tens
		add.b	d1,d0		;add them
volhex:
	IFNE	CHECK
		cmp.b	#64,d0
		bhi.s	go_nocmd
	ENDC
plr_setvol
	IFNE	RELVOL
		mulu	trk_trackvol(a5),d0
		lsr.w	#8,d0
	ENDC
		move.b	d0,trk_prevvol(a5)
go_nocmd	bra.w	plr_nocmd
; ---------------- tempo2 change??
not0c:		cmp.b	#$09,d0
		bne.s	not09
	IFNE	CHECK
		and.b	#$1F,d6
		bne.s	fx9chk
		moveq	#$20,d6
	ENDC
fx9chk:		move.b	d6,msng_tempo2(a4)
		bra.s	plr_nocmd
; ---------------- note off time set??
	IFNE	HOLD
not09:		cmp.b	#$08,d0
		bne.s	not08
		move.b	d6,d0
		lsr.b	#4,d6		;extract left  nibble
		and.b	#$0f,d0		; "   "  right  "  "
		move.b	d6,trk_initdecay(a5)	;left = decay
		move.b	d0,trk_inithold(a5)	;right = hold
		bra.s	plr_nocmd
	ELSEIF
not09
	ENDC
; ---------------- cmd Bxx, "position jump", like Goto, yäk!!
not08:		cmp.b	#$0b,d0
		bne.s	not0b
		move.w	d6,d0
		and.w	#$00ff,d0
	IFNE	CHECK
		cmp.w	msng_songlen(a4),d0	;test the song length
		bhi.s	plr_nocmd
	ENDC
		move.w	d0,mmd_pseqnum(a6)
		st	nextblock	; = -1
		bra.s	plr_nocmd
; ---------------- try portamento (3)
not0b:		cmp.b	#$03,d0
		bne.s	plr_nocmd
		subq.b	#1,d5		;subtract note number
		bpl.s	plr_fx3note	;there's a note...
		tst.b	d6		;qual??
		beq.s	plr_endloop0	;0 -> do nothing
		bra.s	plr_setfx3spd	;not 0 -> set new speed
plr_fx3note:
	IFNE	CHECK
		cmp.w	#4,d7
		bge.s	plr_endloop0	;hey, what are you trying to do??
	ENDC
		movea.l	trk_periodtbl(a5),a0
		add.b	msng_playtransp(a4),d5	;play transpose
		add.b	trk_stransp(a5),d5 ;and instrument transpose
		bmi.s	plr_endloop0	;again.. too low
		add.w	d5,d5
		move.w	0(a0,d5.w),trk_porttrgper(a5) ;period of this note is the target
plr_setfx3spd:	move.b	d6,trk_prevportspd(a5)	;remember size
		moveq	#0,d5	;don't play this one
; ---------------- everything is checked now: play or not to play??
plr_nocmd:	tst.b	d5	;Now we'll check if we have to play a note
		beq.s	plr_endloop0	;no.
; ---------------- we decided to play
		move.b	d5,(a5)
		move.w	d7,d0
		move.w	d5,d1
		moveq	#0,d2
		move.b	trk_prevvol(a5),d2	;get volume
		moveq	#0,d3
		move.b	trk_previnstr(a5),d3	;instr #
		movea.l	trk_previnstra(a5),a3	;instr data address
; ---------------- does this instrument have holding??
	IFNE	HOLD
		move.b	trk_inithold(a5),trk_noteoffcnt(a5) ;initialize hold
		bne.s	plr_holdok	;not 0 -> OK
		st	trk_noteoffcnt(a5)	;0 -> hold = 0xff (-1)
	ENDC
; ---------------- and finally:
plr_holdok:	bsr	_PlayNote	;play it!!!!!!!!!!!
; ---------------- end of loop: handle next track, or quit
plr_endloop0:	addq.b	#1,d7
		cmp.w	numtracks(pc),d7
		blt.w	plr_loop0
		addq.l	#4,sp		;trackdataptrs

; and advance song pointers
		lea	nextblock(pc),a2
		move.w	mmd_pline(a6),d1	;pline
		addq.w	#1,d1			;advance line
		cmp.w	numlines(pc),d1		;advance block?
		bgt.s	plr_chgblock		;yes
		tst.b	(a2)			;command F00 ??
		beq.s	plr_nochgblock		;no, don't change block
plr_chgblock:	moveq	#0,d1			;clear the line number
		tst.w	mmd_pstate(a6)		;play block or play song
		bpl.s	plr_nonewseq		;play block only...
		move.w	mmd_pseqnum(a6),d0	;get play sequence number
		tst.b	(a2)
		bmi.s	plr_noadvseq	;Bxx sets nextblock to 0xff (= neg)
		addq.w	#1,d0			;advance sequence number
plr_noadvseq:	cmp.w	msng_songlen(a4),d0	;is this the highest seq number??
		blt.s	plr_notagain		;no.
		moveq	#0,d0			;yes: play song again
		moveq	#0,d1			;...forever
plr_notagain:	move.b	d0,mmd_pseqnum+1(a6)	;remember new playseq-#
		lea	msng_playseq(a4),a0	;offset of sequence table
		move.b	0(a0,d0.w),d0		;get number of the block
	IFNE	CHECK
		cmp.b	msng_numblocks+1(a4),d0	;beyond last block??
		blt.s	plr_nolstblk		;no..
		moveq	#0,d0			;play block 0
	ENDC
plr_nolstblk:	move.b	d0,mmd_pblock+1(a6)	;store pblock
plr_nonewseq:	clr.b	(a2)			;clear this if F00 set it
plr_nochgblock:	move.w	d1,mmd_pline(a6)	;set new pline

	IFNE	HOLD
		movea.l	mmd_blockarr(a6),a0
		move.w	mmd_pblock(a6),d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	0(a0,d0.w),a2
		move.b	(a2),d7			;# of tracks
		move.w	mmd_pline(a6),d0	;play line
		move.w	d0,d1
		add.w	d0,d0	;d0 * 2
		add.w	d1,d0	;+ d0 = d0 * 3
		mulu	d7,d0
		lea	2(a2,d0.w),a2
		move.b	msng_tempo2(a4),d3	;interrupts/note
		lea	trackdataptrs(pc),a0
		subq.b	#1,d7
plr_chkhold:	movea.l	(a0)+,a1		;track data
		tst.b	trk_noteoffcnt(a1)	;hold??
		bmi.s	plr_holdend		;no.
		move.b	(a2),d1			;get the 1st byte..
		bne.s	plr_hold1
		move.b	1(a2),d1
		and.b	#$f0,d1
		beq.s	plr_holdend		;don't hold
		bra.s	plr_hold2
plr_hold1:	and.b	#$3f,d1			;note??
		beq.s	plr_hold2		;no, cont hold..
		move.b	1(a2),d1
		and.b	#$0f,d1			;get cmd
		subq.b	#3,d1			;is there command 3 (slide)
		bne.s	plr_holdend		;no -> end holding
plr_hold2:	add.b	d3,trk_noteoffcnt(a1)	;continue holding...
plr_holdend:	addq.l	#3,a2		;next note
		dbf	d7,plr_chkhold
	ENDC
		btst	#5,msng_flags(a4)	;FLAG_STSLIDE??
		bne.w	plr_endfx		;yes, no effects this time...
		moveq	#0,d3			;counter = 0
nonewnote:
;	*********************** This code produces the effects **
		moveq	#0,d7	;clear track count
		moveq	#0,d6
		lea	trackdataptrs(pc),a2
plr_loop1:	movea.l	(a2)+,a5
		moveq	#0,d5
		moveq	#0,d4
		move.b	trk_cmd(a5),d6	;get the fx number
		move.b	trk_cmdqual(a5),d4	;and the last 2 #'s
	IFNE	MIDI
		tst.b	trk_prevmidin(a5)	;first: is it MIDI??
		bne.w	midicmds
	ENDC
		cmp.w	#4,d7
		bge.w	endl	;no non-MIDI effects in tracks 4 - 15
	IFNE	HOLD
		tst.b	trk_noteoffcnt(a5)
		bmi.s	plr_nowaitoff
		subq.b	#1,trk_noteoffcnt(a5)
		bpl.s	plr_nowaitoff
		IFNE	SYNTH
		tst.b	trk_synthtype(a5)	;synth/hybrid??
		beq.s	plr_nosyndec
		move.b	trk_decay(a5),trk_volcmd+1(a5)	;set volume command pointer
		clr.b	trk_volwait(a5)	;abort WAI
		move.l	trk_synthptr(a5),d0
		bra.s	plr_gosynth
		ENDC
plr_nosyndec:	move.b	trk_decay(a5),trk_fadespd(a5)	;set fade...
		bne.s	plr_nowaitoff	;if > 0, don't stop sound
		bset	d7,d5
		move.w	d5,$dff096	;shut DMA...
		moveq	#0,d5
	ENDC
plr_nowaitoff:
	IFNE	SYNTH
		move.l	trk_synthptr(a5),d0
		beq.s	plr_nosynth
plr_gosynth:	move.l	d0,a0
		bsr.w	synth_start
	ENDC
plr_nosynth:
	IFNE	HOLD
		move.b	trk_fadespd(a5),d0	;fade??
		beq.s	plr_nofade	;no.
		sub.b	d0,trk_prevvol(a5)
		bpl.s	plr_nofade2low
		clr.b	trk_prevvol(a5)
		clr.b	trk_fadespd(a5)		;fade no more
plr_nofade2low:
	ENDC
plr_nofade:	movea.l	trk_audioaddr(a5),a1
		add.b	d6,d6	;* 2
		move.w	fx_table(pc,d6.w),d0
		jmp	fxs(pc,d0.w)
fx_table:	dc.w	fx_00-fxs,fx_01-fxs,fx_02-fxs,fx_03-fxs,fx_04-fxs
		dc.w	fx_05-fxs,fx_xx-fxs,fx_xx-fxs,fx_xx-fxs,fx_xx-fxs
		dc.w	fx_0a-fxs,fx_xx-fxs,fx_xx-fxs,fx_0d-fxs,fx_xx-fxs
		dc.w	fx_0f-fxs
fxs:
;	**************************************** Effect 01 ******
fx_01:		sub.w	d4,trk_prevper(a5)	;slide up
		move.w	trk_prevper(a5),d5
		cmp.w	#113,d5		;too high?
		bge.s	fx_01_pushper
		move.w	#113,d5		;too high
		move.w	d5,trk_prevper(a5)
fx_01_pushper	move.w	d5,ac_per(a1)
		bra.w	fx_xx
;	**************************************** Effect 02 ******
fx_02:		add.w	d4,trk_prevper(a5)	;slide down
		move.w	trk_prevper(a5),d5
		bra.s	fx_01_pushper
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
		add.b	d4,d4		;shift to make index for UWORD
		movea.l	trk_periodtbl(a5),a0
		move.w	0(a0,d4.w),ac_per(a1)
		bra.w	fx_xx
;	**************************************** Effect 0D/0A ***
fx_0a:
fx_0d:		move.b	d4,d1
		move.b	trk_prevvol(a5),d0	;move previous vol to d0
		and.b	#$f0,d1
		bne.s	crescendo
		sub.b	d4,d0	;sub from prev. vol
		bpl.s	fx_0d_pushvol
		moveq	#0,d0	;volumes under zero not accepted
		bra.s	fx_0d_pushvol
crescendo:	lsr.b	#4,d1
		add.b	d1,d0
		cmp.b	#64,d0
		ble.s	fx_0d_pushvol
		moveq	#64,d0
fx_0d_pushvol	move.b	d0,trk_prevvol(a5)
		move.b	d0,ac_vol+1(a1)
		bra.w	endl
;	**************************************** Effect 05 ******
fx_05:		move.w	trk_prevper(a5),d5 ;this is very simple: get the old period
		cmp.b	#3,d3		;and..
		bge.w	fx_05b		;if counter < 3
		sub.w	d4,d5	;subtract effect qualifier
fx_05b		move.w	d5,ac_per(a1)
		bra.w	fx_xx
;	**************************************** Effect 03 ******
fx_03:		move.w	trk_porttrgper(a5),d0	;d0 = target period
		beq.w	fx_xx		;no target period specified
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
		move.w	d1,ac_per(a1)
		bra.w	fx_xx
;	**************************************** Effect 04 ******
fx_04:		tst.b	d4
		beq.s	nonvib
		move.b	d4,trk_vibrspdsz(a5)
nonvib:		move.b	trk_vibroffs(a5),d0
		lsr.b	#2,d0
		and.w	#$1f,d0
		moveq	#0,d1
		lea	sinetable(pc),a0
		move.b	0(a0,d0.w),d5
		ext.w	d5
		move.b	trk_vibrspdsz(a5),d0
		and.w	#$000f,d0
		muls	d0,d5
		asr.w	#5,d5
		add.w	trk_prevper(a5),d5
		move.b	trk_vibrspdsz(a5),d0
		lsr.b	#3,d0
		and.b	#$3e,d0
		add.b	d0,trk_vibroffs(a5)
		move.w	d5,ac_per(a1)
		bra.s	fx_xx
;	**************************************** Effect 0F ******
fx_0f:		cmp.b	#$f1,d4
		bne.s	no0ff1
		cmp.b	#3,d3
		bne.w	fx_xx
		bra.s	playfxnote
no0ff1:		cmp.b	#$f2,d4
		bne.s	no0ff2
		cmp.b	#3,d3
		bne.w	fx_xx
		bra.s	playfxnote
no0ff2:		cmp.b	#$f3,d4
		bne.s	no0ff3
		move.b	d3,d0
		and.b	#2+4,d0		;is 2 or 4
		beq.s	fx_xx
playfxnote:	move.w	d7,d0		;track # to d0...
		moveq	#0,d1
		move.b	(a5),d1		;get note # of previous note
		beq.s	fx_xx
		moveq	#0,d2
		move.b	trk_prevvol(a5),d2	;get previous volume
		move.l	d3,-(sp)
		moveq	#0,d3
		move.b	trk_previnstr(a5),d3	;and prev. sample #
		movea.l	trk_previnstra(a5),a3
		bsr	_PlayNote
		move.l	(sp)+,d3
		bra.s	fx_xx
no0ff3:		cmp.b	#$f8,d4		;f8 = filter off
		beq.s	plr_filteroff
		cmp.b	#$f9,d4		;f9 = filter on
		bne.s	fx_xx
		bclr	#1,$bfe001
		bra.s	fx_xx
plr_filteroff:	bset	#1,$bfe001
;	*********************************************************
fx_xx:		move.b	trk_prevvol(a5),ac_vol+1(a1)
endl:		addq.b	#1,d7	;increment channel number
		cmp.w	numtracks(pc),d7	;all channels done???
		blt.w	plr_loop1	;not yet!!!
plr_endfx	bsr	_StartDMA	;turn on DMA
plr_exit	movem.l	(sp)+,d2-d7/a2-a5
	IFNE	VBLANK
		moveq	#0,d0
	ENDC
		rts

_SetTempo:
	IFNE	CIAB
		cmp.b	#10,d0	;If tempo <= 10, use SoundTracker tempo
		bhi.s	calctempo
		subq.b	#1,d0
		add.w	d0,d0
		move.w	sttempo+2(pc,d0.w),d1
		bra.s	pushtempo
calctempo:	move.l	timerdiv(pc),d1
		divu	d0,d1
pushtempo:	movea.l	craddr+4(pc),a0
		move.b	d1,(a0)		;and set the CIA timer
		lsr.w	#8,d1
		movea.l	craddr+8(pc),a0
		move.b	d1,(a0)
	ENDC
		rts ;   vv-- These values are the SoundTracker tempos (approx.)
sttempo:	dc.w	$0f00
	IFNE	CIAB
		dc.w	2417,4833,7250,9666,12083,14500,16916,19332,21436,24163
timerdiv	dc.l	470000
	ENDC

	IFNE	MIDI
midicmds
	IFNE	HOLD
		tst.b	trk_noteoffcnt(a5)
		bmi.s	midi_nowaitoff
		subq.b	#1,trk_noteoffcnt(a5)
		bpl.s	midi_nowaitoff
		move.l	a5,a1
		move.b	trk_prevmidin(a5),d1
		beq.s	midi_nowaitoff	;no note
		bsr.w	choff_midi
midi_nowaitoff:
	ENDC
		add.b	d6,d6	;* 2
		move.w	midicmd_table(pc,d6.w),d0
		jmp	midifx(pc,d0.w)
midicmd_table:	dc.w	mfx_00-midifx,mfx_01-midifx,mfx_02-midifx,mfx_03-midifx,mfx_04-midifx
		dc.w	mfx_05-midifx,endl-midifx,endl-midifx,endl-midifx,endl-midifx
		dc.w	mfx_0a-midifx,endl-midifx,endl-midifx,mfx_0d-midifx,mfx_0e-midifx
		dc.w	mfx_0f-midifx
midifx		
mfx_01		lea	prevmidipbend(pc),a0
		moveq	#0,d1
		move.b	trk_prevmidich(a5),d1	;get previous midi channel
		add.b	d1,d1		;UWORD index
		tst.b	d4		;x100??
		beq.s	resetpbend
		move.w	0(a0,d1.w),d0	;get previous pitch bend
		lsl.w	#3,d4		;multiply bend value by 8
		add.w	d4,d0
		cmp.w	#$3fff,d0
		bls.s	bendpitch
		move.w	#$3fff,d0
bendpitch:	move.w	d0,0(a0,d1.w)	;save current pitch bend
		lsr.b	#1,d1		;back to UBYTE
		or.b	#$e0,d1
		lea	noteondata(pc),a0
		move.b	d1,(a0)		;midi command & channel
		move.b	d0,1(a0)	;lower value
		and.b	#$7f,1(a0)	;clear bit 7
		lsr.w	#7,d0
		and.b	#$7f,d0		;clr bit 7
		move.b	d0,2(a0)	;higher 7 bits
		moveq	#3,d0
		bsr.w	_AddMIDIData
		bra.w	endl

mfx_02		lea	prevmidipbend(pc),a0
		moveq	#0,d1
		move.b	trk_prevmidich(a5),d1
		add.b	d1,d1
		tst.b	d4
		beq.s	resetpbend	;x200??
		move.w	0(a0,d1.w),d0
		lsl.w	#3,d4
		sub.w	d4,d0
		bpl.s	bendpitch	;not under 0
		moveq	#0,d0
		bra.s	bendpitch
resetpbend:	tst.b	d3		;d3 = counter (remember??)
		bne.w	endl
		move.w	#$2000,d0
		bra.s	bendpitch

mfx_03		tst.b	d3
		bne.w	endl
		lea	prevmidipbend(pc),a0
		moveq	#0,d1
		move.b	trk_prevmidich(a5),d1
		add.b	d1,d1
		move.b	d4,d0
		add.b	#128,d0
		lsl.w	#6,d0
		bra.s	bendpitch

mfx_0d		tst.b	d3
		bne.w	endl
		lea	noteondata+1(pc),a0	;CHANNEL AFTERTOUCH
		move.b	d4,(a0)	;value
		bmi.w	endl
		move.b	trk_prevmidich(a5),-(a0)
		or.b	#$d0,(a0)
		moveq	#2,d0
		bsr.w	_AddMIDIData
		bra.w	endl

mfx_0a		tst.b	d3
		bne.w	endl
		lea	noteondata+2(pc),a0	;POLYPHONIC AFTERTOUCH
		and.b	#$7f,d4
		move.b	d4,(a0)
		move.b	trk_prevmidin(a5),-(a0)
		beq.w	endl
		move.b	trk_prevmidich(a5),-(a0)
		or.b	#$A0,(a0)
		moveq	#3,d0
		bsr.w	_AddMIDIData
		bra.w	endl

mfx_04		moveq	#$01,d0
		bra.s	pushctrldata

mfx_0e		moveq	#$0a,d0
pushctrldata	tst.b	d3		;do it only once in a note
		bne.w	endl		;(when counter = 0)
		lea	noteondata+2(pc),a0 ;push "control change" data,
		move.b	d4,(a0)		;second databyte
		bmi.w	endl	;I said 0 - $7f!!! (for future compability)
		move.b	d0,-(a0)	;1st databyte
		move.b	trk_prevmidich(a5),-(a0)	;MIDI channel
		or.b	#$b0,(a0)	;command (B)
		moveq	#3,d0
		bsr.w	_AddMIDIData
		bra.w	endl

mfx_05		and.b	#$7f,d4		;set contr. value of curr. MIDI ch.
		move.b	trk_prevmidich(a5),d6
		lea	midicontrnum(pc,d6.w),a0
		move.b	d4,(a0)
		bra.w	endl

mfx_0f		cmp.b	#$fa,d4		;hold pedal ON
		bne.s	nomffa
		moveq	#$40,d0
		moveq	#$7f,d4
		bra.s	pushctrldata
nomffa		cmp.b	#$fb,d4		;hold pedal OFF
		bne.s	nomffb
		moveq	#$40,d0
		moveq	#$00,d4
		bra.s	pushctrldata
nomffb		bra.w	fx_0f

mfx_00		tst.b	d4
		beq.w	endl
		and.b	#$7f,d4
		move.b	trk_prevmidich(a5),d6
		move.b	midicontrnum(pc,d6.w),d0
		bra.s	pushctrldata

midicontrnum	ds.b	16

_ResetMIDI:	movem.l	d2/a2,-(sp)
		lea	prevmidicpres(pc),a0
		clr.l	(a0)+	;force presets to be set again
		clr.l	(a0)+	;(clear prev. preset numbers)
		clr.l	(a0)+
		clr.l	(a0)
		clr.b	lastcmdbyte
		lea	midiresd(pc),a2
		move.b	#$e0,(a2)	;reset pitchbenders & mod. wheel
		move.b	#$b0,3(a2)
		moveq	#15,d2
respbendl:	movea.l	a2,a0
		moveq	#6,d0
		bsr.w	_AddMIDIData
		addq.b	#1,(a2)
		addq.b	#1,3(a2)
		dbf	d2,respbendl
		lea	prevmidipbend(pc),a2
		moveq	#15,d2
resprevpbends:	move.w	#$2000,(a2)+
		dbf	d2,resprevpbends
		movem.l	(sp)+,d2/a2
		rts
midiresd:	dc.b	$e0,$00,$40,$b0,$01,$00
	ENDC

; *************************************************************************
; *************************************************************************
; ***********          P U B L I C   F U N C T I O N S          ***********
; *************************************************************************
; *************************************************************************

		xdef	_InitModule,_PlayModule,_PlayModule2
		xdef	_InitPlayer,_RemPlayer,_StopPlayer
		xdef	_SetTempo,_ContModule

; *************************************************************************
; InitModule(a0 = module) -- extract expansion data etc.. from V3.00 module
; *************************************************************************

_InitModule:	movem.l	a2-a3/d2,-(sp)
		move.l	a0,d0
		beq.s	IM_exit			;0 => xit
	IFNE	RELVOL
		movea.l	mmd_songinfo(a0),a1	;MMD0song
		move.b	msng_mastervol(a1),d0	;d0 = mastervol
		ext.w	d0
		lea	msng_trkvol(a1),a1	;a1 = trkvol
		lea	trackdataptrs(pc),a2
		moveq	#15,d1
IM_loop0	move.b	(a1)+,d2	;get vol...
		ext.w	d2
		move.l	(a2)+,a3	;pointer to track data
		mulu	d0,d2		;mastervol * trackvol
		lsr.w	#4,d2
		move.w	d2,trk_trackvol(a3)
		dbf	d1,IM_loop0
	ENDC
		lea	holdvals(pc),a2
		movea.l	a0,a3
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
	IFNE	MIDI
		movea.l	mmd_songinfo(a3),a3	;MMD0song
	ENDC
IM_loop1
	IFNE	MIDI
		cmp.w	#2,d0
		ble.s	IM_nsmnoff
		tst.b	2(a0)		;suppress MIDI note off?
		beq.s	IM_nsmnoff
		bset	#7,inst_midich(a3)
IM_nsmnoff	addq.l	#8,a3		;next instr
	ENDC
		move.b	1(a0),63(a2)	;InstrExt.decay ->decay
		move.b	(a0),(a2)+	;InstrExt.hold -> holdvals
		adda.w	d0,a0		;ptr to next InstrExt
		dbf	d2,IM_loop1
		bra.s	IM_exit
IM_clrhlddec	move.w	#3*63,d0		;no InstrExt => clear holdvals/decays
IM_loop2	clr.b	(a2)+
		dbf	d0,IM_loop2
IM_exit		movem.l	(sp)+,a2-a3/d2
		rts
; *************************************************************************
; InitPlayer() -- allocate interrupt, audio, serial port etc...
; *************************************************************************
_InitPlayer:
	IFNE	MIDI
		bsr.w	_GetSerial
		tst.l	d0
		bne.s	IP_error
	ENDC
		bsr.w	_AudioInit
		tst.l	d0
		bne.s	IP_error
		moveq	#33,d0
		bsr.w	_SetTempo	;set default tempo
		moveq	#0,d0
		rts
IP_error	bsr.s	_RemPlayer
		moveq	#-1,d0
		rts
; *************************************************************************
; RemPlayer() -- free interrupt, audio, serial port etc..
; *************************************************************************
_RemPlayer:	move.b	_timeropen(pc),d0
		beq.s	RP_notimer	;timer is not ours
		bsr.s	_StopPlayer
RP_notimer:	bsr.w	_AudioRem
	IFNE	MIDI
		bsr.w	_FreeSerial
	ENDC
		rts
; *************************************************************************
; StopPlayer() -- stop music
; *************************************************************************
_StopPlayer:	move.b	_timeropen(pc),d0
		beq.s	SP_end		;res. alloc fail.
	IFNE	CIAB
		movea.l	craddr(pc),a0
		bclr	#0,(a0)		;stop timer
	ENDC
		move.l	_module(pc),d0
		beq.s	SP_nomod
		move.l	d0,a0
		clr.w	mmd_pstate(a0)
		clr.l	_module
SP_nomod
	IFNE	MIDI
		clr.b	lastcmdbyte
	ENDC
		bsr.w	SoundOff
SP_end		rts


_ContModule	move.b	_timeropen(pc),d0
		beq.s	SP_end
		movea.l	craddr(pc),a1
		bclr	#0,(a1)
		move.l	a0,-(sp)
		bsr.w	SoundOff
		move.l	(sp)+,a0
		moveq	#0,d0
		bra.s	contpoint
; *************************************************************************
; PlayModule(a0 = module)  -- initialize & play it!!
; PlayModule2(a0 = module) -- play module (must be initialized)
; *************************************************************************
_PlayModule:	st	d0
contpoint	movem.l	a0/d0,-(sp)
		bsr	_InitModule
		movem.l	(sp)+,a0/d0
_PlayModule2:	move.b	_timeropen(pc),d1
		beq.s	SP_end		;resource allocation failure
		move.l	a0,d1
		beq.s	SP_end		;module failure
	IFNE	CIAB
		movea.l	craddr(pc),a1
		bclr	#0,(a1)		;stop timer...
	ENDC
		clr.l	_module
	IFNE	MIDI
		clr.b	lastcmdbyte
	ENDC
		move.w	_modnum,d1
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
		move.b	0(a1,d1.w),d1		;get first playseq entry
		move.b	d1,mmd_pblock+1(a0)
		move.w	#-1,mmd_pstate(a0)
		move.l	a0,_module
	IFNE	CIAB
		move.w	msng_deftempo(a1),d0	;get default tempo
		movea.l	craddr(pc),a1
		bsr.w	_SetTempo	;set default tempo
		bset	#0,(a1)		;start timer => PLAY!!
	ENDC
PM_end		rts
; *************************************************************************

_AudioInit:	movem.l	a4/a6/d2-d3,-(sp)
		moveq	#0,d2
		movea.l	4,a6
;	+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ alloc signal bit
	IFNE	AUDDEV
		addq.l	#1,d2
		moveq	#-1,d0
		jsr	-$14a(a6)	;AllocSignal()
		tst.b	d0
		bmi.w	initerr
		move.b	d0,sigbitnum
;	+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ prepare IORequest
		lea	allocport(pc),a1
		move.b	d0,15(a1)	;set mp_SigBit
		move.l	a1,-(sp)
		suba.l	a1,a1
		jsr	-$126(a6)	;FindTask(0)
		move.l	(sp)+,a1
		move.l	d0,16(a1)	;set mp_SigTask
		lea	reqlist(pc),a0
		move.l	a0,(a0)		;NEWLIST begins...
		addq.l	#4,(a0)
		clr.l	4(a0)
		move.l	a0,8(a0)	;NEWLIST ends...
;	+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ open audio.device
		addq.l	#1,d2
		lea	allocreq(pc),a1
		lea	audiodevname(pc),a0
		moveq	#0,d0
		moveq	#0,d1
		jsr	-$1bc(a6)	;OpenDevice()
		tst.b	d0
		bne.w	initerr
		st.b	audiodevopen
;	+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ open ciaa.resource
		addq.l	#1,d2
	ENDC
	IFNE	CIAB
		cmp.b	#50,$212(a6)	;ExecBase->VBlankFrequency
		beq.s	init_pal
		move.l	#474326,timerdiv ;Assume that CIA freq is 715 909 Hz
init_pal	moveq	#0,d0
		lea	ciabname(pc),a1
		jsr	-$1f2(a6)	;OpenResource()
		tst.l	d0
		beq.s	initerr
		move.l	d0,_ciaresource
;	+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ attach interrupt
		addq.l	#1,d2
		moveq	#2,d3
		lea	craddr(pc),a4
		move.l	#$bfdf00,(a4)+	;Initialize Timer B addresses
		move.l	#$bfd600,(a4)+
		move.l	#$bfd700,(a4)
		move.l	d0,a6
		lea	timerinterrupt(pc),a1	;Attempt to get timer B
		moveq	#1,d0	;Bit number 1: Timer B
		jsr	-$6(a6)	;AddICRVector
		tst.l	d0
		beq.s	gotTimerB		;succeeded!!
		moveq	#1,d3
		lea	timerinterrupt(pc),a1	;no. Get timer A then...
		moveq	#0,d0	;Bit number 0: Timer A
		jsr	-$6(a6)
		tst.l	d0
		bne.s	initerr
		move.l	#$bfd500,(a4)		;Set Timer A addresses
		move.l	#$bfd400,-(a4)
		move.l	#$bfde00,-(a4)
gotTimerB:	movea.l	craddr(pc),a0	;get Control Register address
		and.b	#%10000000,(a0) ;clear CtrlReg bits 0 - 6
		move.b	d3,_timeropen	;d3: 1 = TimerA 2 = TimerB
	ENDC
	IFNE	VBLANK
		moveq	#5,d0		;INTB_VERTB
		lea	timerinterrupt(pc),a1
		jsr	-$a8(a6)	;AddIntServer
		st	_timeropen
	ENDC
		moveq	#0,d0
initret:	movem.l	(sp)+,a4/a6/d2-d3
		rts
initerr:	move.l	d2,d0
		bra.s	initret

_AudioRem:	move.l	a6,-(sp)
		moveq	#0,d0
		move.b	_timeropen(pc),d0
		beq.s	rem1
;	+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ remove interrupt
		clr.b	_timeropen
	IFNE	CIAB
		move.l	_ciaresource,a6
		lea	timerinterrupt(pc),a1
		subq.b	#1,d0
		jsr	-$c(a6)		;RemICRVector
	ENDC
	IFNE	VBLANK
		movea.l	4,a6
		lea	timerinterrupt(pc),a1
		moveq	#5,d0
		jsr	-$ae(a6)	;RemIntServer
	ENDC
rem1:
	IFNE	AUDDEV
		movea.l	4,a6
		tst.b	audiodevopen
		beq.s	rem2
		move.w	#$000f,$dff096	;stop audio DMA
;	+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ close audio.device
		lea	allocreq(pc),a1
		jsr	-$1c2(a6)	;CloseDevice()
rem2:		moveq	#0,d0
		move.b	sigbitnum(pc),d0
		bmi.s	rem3
;	+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ free signal bit
		jsr	-$150(a6)	;FreeSignal()
	ENDC
rem3:		move.l	(sp)+,a6
		rts

	IFNE	MIDI
_GetSerial:	move.l	a6,-(sp)	;Get serial port for MIDI
		bsr.s	GetSer2
		tst.l	d0		;got the port??
		beq.s	rgser		;yes
		movea.l	4,a6		;no..try to flush serial.device:
		jsr	-$84(a6)		;Forbid
		lea	$15e(a6),a0		;ExecBase->DeviceList
		lea	serdev(pc),a1		;"serial.device"
		jsr	-$114(a6)		;FindName
		tst.l	d0
		beq.s	serdnotf		;no serial.device!!
		move.l	d0,a1
		jsr	-$1b6(a6)		;RemDevice
serdnotf:	jsr	-$8a(a6)		;and Permit
		bsr.s	GetSer2		;now try it again...
rgser:		move.l	(sp)+,a6
		rts

GetSer2:	movea.l	4,a6
		moveq	#0,d0
		lea	miscresname(pc),a1
		jsr	-$1f2(a6)	;OpenResource()
		move.l	d0,miscresbase
		tst.l	d0
		beq.s	gserror
		move.l	d0,a6
		lea	medname(pc),a1
		moveq	#0,d0		;serial port
		jsr	-$6(a6)		;AllocMiscResource()
		tst.l	d0
		bne.s	gserror
		moveq	#0,d0		;TBE
		lea	serinterrupt(pc),a1
		move.l	4,a6
		jsr	-$a2(a6)	;SetIntVector()
		move.l	d0,prevtbe
		move.w	#$8001,$dff09a	;TBE on!!
		move.w	#114,$dff032	;set baud rate (SERPER)
		st.b	serportalloc
		moveq	#0,d0
		rts
gserror:	moveq	#-1,d0
		rts


_FreeSerial:	move.l	a6,-(sp)
		tst.l	miscresbase
		beq.s	retfs
		tst.b	serportalloc
		beq.s	retfs
		movea.l	4,a6
		tst.b	$126(a6)	;interrupts disabled?
		bge.s	fs_skipwait	;yes, can't busy loop...
fs_waitempty	move.b	buffempty(pc),d0
		beq.s	fs_waitempty
fs_skipwait	move.w	#$0001,$dff09a	;disable TBE
		move.l	prevtbe(pc),a1
		moveq	#0,d0
		jsr	-$a2(a6)	;SetIntVector()
fs_noptbe	movea.l	miscresbase(pc),a6
		moveq	#0,d0		;serial port
		jsr	-$c(a6)		;FreeMiscResource()
		clr.b	serportalloc
		clr.b	lastcmdbyte
retfs:		move.l	(sp)+,a6
		rts

prevtbe:	dc.l	0

SerIntHandler:	move.w	#$4000,$9a(a0)	;disable...
		addq.b	#1,$126(a6)	(Interrupts are enabled anyway...)
		move.w	#1,$9c(a0)	;clear intreq bit
		move.b	8(a1),d0	;bytesinbuff
		beq.s	sih_buffe	;buffer empty
		movea.l	4(a1),a5	;get buffer read pointer
		move.w	#$100,d1	;Stop bit
		move.b	(a5)+,d1	;get byte
		move.w	d1,$30(a0)	;and push it out!! (SERDAT)
		cmpa.l	a1,a5		;shall we reset ptr??
		bne.s	norrbuffptr	;not yet..
		lea	sendbuffer(pc),a5
norrbuffptr:	subq.b	#1,d0		;one less bytes in buffer
		move.b	d0,8(a1)	;remember it
		move.l	a5,4(a1)	;push new read pointer back
exsih:		subq.b	#1,$126(a6)
		bge.s	exsih0
		move.w	#$c000,$9a(a0)
exsih0:		rts
sih_buffe	st	9(a1)
		bra.s	exsih

_AddMIDIData:	tst.b	serportalloc
		beq.s	retamd
		movem.l	a2/a6,-(sp)
		movea.l	4,a6
		move.w	#$4000,$dff09a	;Disable interrupts
		addq.b	#1,$126(a6)	;ExecBase->IDNestCnt
		lea	buffptr(pc),a2	;end of buffer (ptr)
		tst.b	9(a2)
		beq.s	noTBEreq
		clr.b	9(a2)
		move.w	#$8001,$dff09c	;request TBE
noTBEreq	movea.l	(a2),a1		;buffer pointer
adddataloop:	move.b	(a0)+,d1	;get byte
		bpl.s	norscheck	;this isn't a status byte
		cmp.b	#$ef,d1		;forget system messages
		bhi.s	norscheck
		cmp.b	lastcmdbyte(pc),d1 ;same as previos status byte??
		beq.s	samesb		;yes, skip
		move.b	d1,10(a2)	;no, don't skip but remember!!
norscheck:	move.b	d1,(a1)+	;push it to midi send buffer
		addq.b	#1,8(a2)
samesb:		cmpa.l	a2,a1	;end of buffer??
		bne.s	noresbuffptr	;no, no!!
		lea	sendbuffer(pc),a1 ;better reset it to avoid trashing
noresbuffptr:	subq.b	#1,d0
		bne.s	adddataloop
		move.l	a1,(a2)		;push new buffer ptr back
		subq.b	#1,$126(a6)
		bge.s	retamd1
		move.w	#$c000,$dff09a	;enable interrupts again
retamd1		movem.l	(sp)+,a2/a6
retamd		rts
sendbuffer	ds.b	128
buffptr		dc.l	sendbuffer
readbuffptr	dc.l	sendbuffer
bytesinbuff	dc.b	0
buffempty	dc.b	-1
lastcmdbyte	dc.b	0
	ENDC
	IFNE	AUDDEV
sigbitnum	dc.b	-1
	ENDC
		EVEN
	IFNE	AUDDEV
audiodevopen	dc.b	0
	ENDC
serportalloc	dc.b	0
_timeropen	dc.b	0
		even
	IFNE	MIDI
preschgdata	dc.w	0
noteondata	dc.l	0
miscresbase	dc.l	0
	ENDC
dmaonmsk	dc.w	0
	IFNE	MIDI
bytesinnotebuff	dc.w	0
noteonbuff	ds.b	18*3
	ENDC
		even
	IFNE	CIAB
_ciaresource	dc.l	0
craddr		dc.l	0
		dc.l	0	;tloaddr
		dc.l	0	;thiaddr
	ENDC
_module:	dc.l	0
timerinterrupt	dc.w	0,0,0,0,0
		dc.l	timerintname,serportalloc,_IntHandler
	IFNE	MIDI
serinterrupt	dc.w	0,0,0,0,0
		dc.l	serintname,buffptr,SerIntHandler
	ENDC
	IFNE	AUDDEV
allocport	dc.l	0,0	;succ, pred
		dc.b	4,0	;NT_MSGPORT
		dc.l	0	;name
		dc.b	0,0	;flags = PA_SIGNAL
		dc.l	0	;task
reqlist		dc.l	0,0,0	;list head, tail and tailpred
		dc.b	5,0
allocreq	dc.l	0,0
		dc.b	5,127	;NT_MESSAGE, use maximum priority (127)
		dc.l	0,allocport	;name, replyport
		dc.w	68		;length
		dc.l	0	;io_Device
		dc.l	0	;io_Unit
		dc.w	0	;io_Command
		dc.b	0,0	;io_Flags, io_Error
		dc.w	0	;ioa_AllocKey
		dc.l	sttempo	;ioa_Data
		dc.l	1	;ioa_Length
		dc.w	0,0,0	;ioa_Period, Volume, Cycles
		dc.w	0,0,0,0,0,0,0,0,0,0	;ioa_WriteMsg
audiodevname	dc.b	'audio.device',0
	ENDC
	IFNE	CIAB
ciabname	dc.b	'ciab.resource',0
	ENDC
timerintname	dc.b	'MEDTimerInterrupt',0
	IFNE	MIDI
serintname	dc.b	'MEDSerialInterrupt',0
miscresname	dc.b	'misc.resource',0
serdev		dc.b	'serial.device',0
medname		dc.b	'MED modplayer',0 ;yeah, our name
	ENDC

	IFNE	SYNTH
_synthper:	dc.w 3424,3232,3048,2880,2712,2560,2416,2280,2152,2032
		dc.w 1920,1812,1712,1616,1524,1440,1356,1280,1208,1140
		dc.w 1076,1016,960,906
	ENDC
_periods:	dc.w 856,808,762,720,678,640,604,570,538,508,480,453
		dc.w 428,404,381,360,339,320,302,285,269,254,240,226
		dc.w 214,202,190,180,170,160,151,143,135,127,120,113
		dc.w 214,202,190,180,170,160,151,143,135,127,120,113
		dc.w 214,202,190,180,170,160,151,143,135,127,120,113
		dc.w 214,202,190,180,170,160,151,143,135,127,120,113

holdvals:	ds.b 63
decays:		ds.b 63

	IFND	__G2
		section "datachip",data,chip ;for A68k
	ENDC
	IFD	__G2
		section "datachip",data_c ;this is for Devpac 2
	ENDC
		xdef	_modnum
_chipzero:	dc.l	0
_modnum:	dc.w	0	;number of module to play

; the track-data structure definition:
trk_prevnote	equ	0	;previous note number
trk_previnstr	equ	1	;previous instrument number
trk_prevvol	equ	2	;previous volume
trk_prevmidich	equ	3	;previous MIDI channel
trk_cmd		equ	4	;command (the 3rd number from right)
trk_cmdqual	equ	5	;command qualifier (infobyte, databyte..)
trk_prevmidin	equ	6	;previous MIDI note
trk_noteoffcnt	equ	7	;note-off counter (hold)
trk_inithold	equ	8	;default hold for this instrument
trk_initdecay	equ	9	;default decay for....
trk_stransp	equ	10	;instrument transpose
trk_pad0	equ	11
trk_previnstra	equ	12	;address of the previous instrument data
trk_trackvol	equ	16
;	the following data only on tracks 0 - 3
trk_prevper	equ	18	;previous period
trk_audioaddr	equ	20	;hardware audio channel base address
trk_sampleptr	equ	24	;pointer to sample
trk_samplelen	equ	28	;length (>> 1)
trk_porttrgper	equ	30	;portamento (cmd 3) target period
trk_vibroffs	equ	32	;vibrato table offset
trk_vibrspdsz	equ	33	;vibrato speed/size (cmd 4 qualifier)
trk_synthptr	equ	34	;pointer to synthetic/hybrid instrument
trk_arpgoffs	equ	38	;SYNTH: current arpeggio offset
trk_arpsoffs	equ	40	;SYNTH: arpeggio restart offset
trk_volxcnt	equ	42	;SYNTH: volume execute counter
trk_wfxcnt	equ	43	;SYNTH: waveform execute counter
trk_volcmd	equ	44	;SYNTH: volume command pointer
trk_wfcmd	equ	46	;SYNTH: waveform command pointer
trk_volwait	equ	48	;SYNTH: counter for WAI (volume list)
trk_wfwait	equ	49	;SYNTH: counter for WAI (waveform list)
trk_synthvibspd	equ	50	;SYNTH: vibrato speed
trk_wfchgspd	equ	52	;SYNTH: period change
trk_perchg	equ	54	;SYNTH: curr. period change from trk_prevper
trk_envptr	equ	56	;SYNTH: envelope waveform pointer
trk_synvibdep	equ	60	;SYNTH: vibrato depth
trk_synvibwf    equ	62	;SYNTH: vibrato waveform
trk_synviboffs	equ	66	;SYNTH: vibrato pointer
trk_initvolxspd	equ	68	;SYNTH: volume execute speed
trk_initwfxspd	equ	69	;SYNTH: waveform execute speed
trk_volchgspd	equ	70	;SYNTH: volume change
trk_prevnote2	equ	71	;SYNTH: previous note
trk_synvol	equ	72	;SYNTH: current volume
trk_synthtype	equ	73	;>0 = synth, -1 = hybrid, 0 = no synth
trk_periodtbl	equ	74	;pointer to period table
trk_prevportspd	equ	78	;portamento (cmd 3) speed
trk_decay	equ	80	;decay
trk_fadespd	equ	81	;decay speed
trk_envrestart	equ	82	;SYNTH: envelope waveform restart point
trk_envcount	equ	86	;SYNTH: envelope counter
trk_split	equ	87	;0 = this channel not splitted (OctaMED V2)

		section		music,data_c

_sng		incbin		"med.mod"
		even
