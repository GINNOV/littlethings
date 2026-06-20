

; Start of a displayer that will load in 1 picture ( bitmap: 320x256x4 CMAP
;behind ) and 1 module. When mouse is pressed, will load and display the next
;one. Pics and modules may be crunched by powerpacker, but make sure the
;buffers in this code are big enough to suffice! Currently:

;	Max Crunched File Size 		= 130000 
;	Max DeCrunched Module Size 	= 150000
;	BitMap Size			= (320/8)*256*4+32

; I have a load of fade/wipe/wobble routines to add to this code. Routines
;are currently sat in a version that relied on powerpacker.library and I
;have not had a chance to pull them out yet.

; You will have to add your own pics and modules I'm afraid.

; Demostrates use of the following:

;	1/ Load & Decrunch without powerpacker.library
;	2/ Legal vertical blanking interrupt that does not screw up
;	   when drive motor is running!




		incdir		sys:include/
		include		exec/exec_lib.i
		INCLUDE		hardware/intbits.i
		include		exec/exec.i
		include		libraries/dos_lib.i
		include		libraries/dosextens.i
		include		graphics/gfxbase.i
		include		source:include/hardware.i

CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm


; Little macro to stop a drive motor after a disc operation.

STOP_DRIVE	macro
		or.b		#$f8,CIABPRB
		and.b		#$87,CIABPRB
		or.b		#$f8,CIABPRB
		endm


Start		lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq.s		.error

		bsr.s		SysOff		disable system, set a5
		tst.l		d0		error ?
		beq.s		.error		if so quit now !
		bsr		Main		do da
		bsr		SysOn		enable system
.error		rts

*****************************************************************************

;-------------- Disable the operating system.

; Cannot obtain blitter as disc operations also require access to this
;wonderfull bit of kit!

; On exit d0=0 if no gfx library.

SysOff		lea		$DFF000,a5	a5->hardware

		move.w		DMACONR(a5),sysDMA	save DMA settings

		lea		grafname,a1	a1->lib name
		moveq.l		#0,d0		any version
		move.l		$4.w,a6		a6->SysBase
		jsr		-$0228(a6)	OpenLibrary
		move.l		d0,_GfxBase	open ok?
		beq		.error		quit if not
		move.l		d0,a6		a6->GfxBase
		move.l		38(a6),syscop	save addr of sys list

		move.l		$4,a6		a6->sysbase
		jsr		-$0084(a6)	Forbid

; Wait for vertical blank and disable unwanted DMA ( eg. Sprites ).

.BeamWait	move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		.BeamWait	if not loop back

		move.w		#$01e0,DMACON(a5) kill all dma
		move.w		#SETIT!COPEN!BPLEN!BLTEN,DMACON(a5) enable copper

; Write bitplane addresses into Copper List.

		lea		CopPlanes,a0	a0->dest in copper list
		lea		BitPlane1,a1	a1->raw data, cmap behind
		lea		CopColours,a2	a2->dest in copper list
		bsr		PutPlanes	build the list

; Strobe our list

		move.l		#CopList,COP1LCH(a5)
		clr.w		COPJMP1(a5)

; Stop drives 
		STOP_DRIVE

		moveq.l		#1,d0
.error		rts

*****************************************************************************

;--------------	Bring back the operating system

SysOn		move.l		syscop,COP1LCH(a5)
		clr.w		COPJMP1		restart system list

		move.w		#$8000,d0	set bit 15 of d0
		or.w		sysDMA,d0	add DMA flags
		move.w		d0,DMACON(a5)	enable systems DMA

		move.l		$4.w,a6		a6->SysBase
		jsr		-$008A(a6)	Permit

		move.l		$4.w,a6		a6->SysBase
		move.l		_GfxBase,a1	a1->Graphics base
		jsr		-$019e(a6)	CloseLibrary

		rts

*****************************************************************************

Main		

; load first picture		
		
		lea		Pic1,a0
		lea		BitPlane1,a1
		bsr		LoadFile

; load first module

		lea		Mod1,a0
		lea		Module2,a1
		bsr		LoadFile

; Write bitplane addresses into Copper List.

		lea		CopPlanes,a0	a0->dest in copper list
		lea		BitPlane1,a1	a1->raw data, cmap behind
		lea		CopColours,a2	a2->dest in copper list
		bsr		PutPlanes	build the list

; Start module playing

		suba.l		a0,a0
		lea		Module2,a1
		bsr		AddInt

; load second picture

		lea		Pic2,a0
		lea		BitPlane2,a1
		bsr		LoadFile

; load second module

		lea		Mod2,a0
		lea		Module1,a1
		bsr		LoadFile

; wait for mouse button to be pressed

Loopy		btst		#6,CIAAPRA
		bne.s		Loopy
Loopy1		btst		#6,CIAAPRA
		beq.s		Loopy1


; Write bitplane addresses into Copper List.

		lea		CopPlanes,a0	a0->dest in copper list
		lea		BitPlane2,a1	a1->raw data, cmap behind
		lea		CopColours,a2	a2->dest in copper list
		bsr		PutPlanes	build the list

; start module playing

		suba.l		a0,a0
		lea		Module1,a1
		bsr		AddInt

; wait for mouse

Loopy2		btst		#6,CIAAPRA
		bne.s		Loopy2
Loopy3		btst		#6,CIAAPRA
		beq.s		Loopy3

; kill replayer

		bsr		KillInt

; exit

		rts

****************************************************************************

; Waits for LMB to be pressed and then released before returning.

Mousey		btst		#6,CIAAPRA	wait for LMB down
		bne.s		Mousey
.mouse		btst		#6,CIAAPRA	wait for LMB up
		beq.s		.mouse
		rts				exit

****************************************************************************
*		Load and Decrunch a File				   *
****************************************************************************

; This routine utalises a file load buffer currently set to 130000 bytes in
;size. Do not attempt to load crunched files larger than this! Do not attempt
;to load files that have not been crunched! M.Meany.

; Entry		a0->filename
;		a1->buffer

; Exit		d0=0 if error occurs

; Corrupt	d0-d7, a0,a1,a4


LoadFile	move.l		a1,a4			save

; open the file

		move.l		a0,d1			name
		move.l		#MODE_OLDFILE,d2	access mode
		CALLDOS		Open			open the file
		move.l		d0,d7			save handle
		beq		.error			quit if error

; read in crunched data. Note, always uses same buffer.

		move.l		d7,d1			handle
		move.l		#_DecBuff,d2		buffer
		move.l		#130000,d3		max size
		CALLDOS		Read			read in the data
		move.l		d0,d6			save file length

; close file

		move.l		d7,d1			handle
		CALLDOS		Close			and close it

; decrunch the data into required buffer.

		lea		_DecBuff,a0		buffer
		move.l		4(a0),d0		efficiency
	
		adda.l		d6,a0			end of data
		move.l		a4,a1			dest buffer
		bsr		PPDecrunch		decrunch it!

; and exit!
		moveq.l		#1,d0			no errors!
.error		rts					and exit


;
; PowerPacker Decrunch assembler subroutine V1.1
;
; NOTE:
;    Decrunch a few bytes higher (safety margin) than the crunched file
;    to decrunch in the same memory space. (64 bytes suffice)
;

* Entry	a0->End of crunched data + 1
*	a1->Start of decrunch block
*	d0=efficiency file was crunched with.

PPDecrunch
	movem.l d1-d7/a2-a6,-(a7)
	bsr.s Decrunch
	movem.l (a7)+,d1-d7/a2-a6
	rts

Decrunch:
	lea myBitsTable(PC),a5
	move.l d0,(a5)
	move.l a1,a2
	move.l -(a0),d5
	moveq #0,d1
	move.b d5,d1
	lsr.l #8,d5
	add.l d5,a1
	move.l -(a0),d5
	lsr.l d1,d5
	move.b #32,d7
	sub.b d1,d7
LoopCheckCrunch:
	bsr.s ReadBit
	tst.b d1
	bne.s CrunchedBytes
NormalBytes:
	moveq #0,d2
Read2BitsRow:
	moveq #2,d0
	bsr.s ReadD1
	add.w d1,d2
	cmp.w #3,d1
	beq.s Read2BitsRow
ReadNormalByte:
	move.w #8,d0
	bsr.s ReadD1
	move.b d1,-(a1)
	dbf d2,ReadNormalByte
	cmp.l a1,a2
	bcs.s CrunchedBytes
	rts
CrunchedBytes:
	moveq #2,d0
	bsr.s ReadD1
	moveq #0,d0
	move.b (a5,d1.w),d0
	move.l d0,d4
	move.w d1,d2
	addq.w #1,d2
	cmp.w #4,d2
	bne.s ReadOffset
	bsr.s ReadBit
	move.l d4,d0
	tst.b d1
	bne.s LongBlockOffset
	moveq #7,d0
LongBlockOffset:
	bsr.s ReadD1
	move.w d1,d3
Read3BitsRow:
	moveq #3,d0
	bsr.s ReadD1
	add.w d1,d2
	cmp.w #7,d1
	beq.s Read3BitsRow
	bra.s DecrunchBlock
ReadOffset:
	bsr.s ReadD1
	move.w d1,d3
DecrunchBlock:
	move.b (a1,d3.w),d0
	move.b d0,-(a1)
	dbf d2,DecrunchBlock
EndOfLoop:
_pp_DecrunchColor:
	move.w a1,$dff1a2
	cmp.l a1,a2
	bcs.s LoopCheckCrunch
	rts
ReadBit:
	moveq #1,d0
ReadD1:
	moveq #0,d1
	subq.w #1,d0
ReadBits:
	lsr.l #1,d5
	roxl.l #1,d1
	subq.b #1,d7
	bne.s No32Read
	move.b #32,d7
	move.l -(a0),d5
No32Read:
	dbf d0,ReadBits
	rts
myBitsTable:
	dc.b $09,$0a,$0b,$0b

_pp_CalcCheckSum:
	move.l 4(a7),a0
	moveq #0,d0
	moveq #0,d1
sumloop:
	move.b (a0)+,d1
	beq.s exitasm
	ror.w d1,d0
	add.w d1,d0
	bra.s sumloop
_pp_CalcPasskey:
	move.l 4(a7),a0
	moveq #0,d0
	moveq #0,d1
keyloop:
	move.b (a0)+,d1
	beq.s exitasm
	rol.l #1,d0
	add.l d1,d0
	swap d0
	bra.s keyloop
exitasm:
	rts
_pp_Decrypt:
	move.l 4(a7),a0
	move.l 8(a7),d1
	move.l 12(a7),d0
	move.l d2,-(a7)
	addq.l #3,d1
	lsr.l #2,d1
	subq.l #1,d1
encryptloop:
	move.l (a0),d2
	eor.l d0,d2
	move.l d2,(a0)+
	dbf d1,encryptloop
	move.l (a7)+,d2
	rts

*****************************************************************************

*****************************************************************************

;--------------	Routine to plonk bitplane pointers into copper list

; This subroutine sets up planes for a 320x256x4 display and sets up the
;colour. Assumes raw data saved as CMAP BEHIND.

;Entry		a0->start of Copper List
;		a1->start of bitplane data
;		a2->position in list to store colour data.

;Corrupted	d0,d1,d2,a0

PutPlanes	moveq.l		#3,d0		num of planes -1
		move.l		#(320/8)*256,d1	size of each bitplane
		move.l		a1,d2		d2=addr of 1st bitplane
.PlaneLoop	swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		lea		4(a0),a0	point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		lea		4(a0),a0	point to next pos in list
		add.l		d1,d2		point to next plane
		dbra		d0,.PlaneLoop	repeat for all planes

		move.l		#$180,d0	color00 offset
		moveq.l		#15,d1		colour counter
		move.l		d2,a1		a1->colourmap
.colourloop	move.w		d0,(a2)+	set colour register
		move.w		(a1)+,(a2)+	and the RGB value
		addq.l		#2,d0		bump colour register
		dbra		d1,.colourloop	for all 16 colours

		rts

****************************************************************************
*		Switch Interrupt Servers For New Module			   *
****************************************************************************

; entry		a0->interrupt subroutine
; 		a1->module

; exit		none

AddInt		move.l		a0,a4			save address
		move.l		a1,a3
		
; if interrupt is already running stop it.

		tst.l		IntOnFlag		set if one running
		beq.s		.not_one		skip if clear

		moveq.l		#INTB_VERTB,d0		interrupt number
		lea		MyInt,a1		Interrupt struct
		CALLEXEC	RemIntServer		remove interrupt

		jsr		mt_end			stop all sounds
		move.l		#0,IntOnFlag		clear

; no interrupt running so set one up.

.not_one	move.l		a3,mt_data		write module address
		jsr		mt_init			Initialise data

		move.l		a4,_routine		write address of sub

		lea		MyInt,a1		a1->Interrupt struct
		move.b		#9,LN_PRI(a1)		priority = 9
		move.l		#IntCode,IS_CODE(a1)	address of server
		moveq.l		#INTB_VERTB,d0		interrupt number
		CALLEXEC	AddIntServer		start it!

		move.l		#1,IntOnFlag		signal running

		rts					exit

IntOnFlag	dc.l		0

****************************************************************************
*			Kill Interrupt Server				   *
****************************************************************************

KillInt		tst.l		IntOnFlag		set if one running
		beq.s		.not_one		skip if clear

		moveq.l		#INTB_VERTB,d0		interrupt number
		lea		MyInt,a1		Interrupt struct
		CALLEXEC	RemIntServer		remove interrupt

		jsr		mt_end			stop all sounds
		move.l		#0,IntOnFlag		clear

.not_one	rts

****************************************************************************
*			The Interrupt Server				   *
****************************************************************************

IntCode		movem.l		a0-a4/d2-d7,-(a7)	Save all registers
		jsr		mt_music			play routine
		move.l		_routine,d0		d0->subroutine
		beq.s		.done			quit if none
		move.l		d0,a0			a0->subroutine
		jsr		(a0)			call it
.done		movem.l		(a7)+,a0-a4/d2-d7	Bring back registers
		moveq.l		#0,d0			clear Z flag
		rts					exit

_routine	dc.l		0

****************************************************************************
*			   Data Section					   *
****************************************************************************

MyInt		ds.l		IS_SIZE			Interrupt structure

	


****************************************************************************

		section		replay,code_c
		
	
**************************************
*   NoisetrackerV1.0 replayroutine   *
* Mahoney & Kaktus - HALLONSOFT 1989 *
*				     *
* Converted to indirect addressing   *
* sometime in 91, Mark.		     *
**************************************


mt_init:move.l	mt_data,a0
	move.l	a0,a1
	add.l	#$3b8,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop:move.l	d1,d2
	subq.w	#1,d0
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$43c,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#$2,$bfe001
	move.b	#$6,mt_speed
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts

mt_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

mt_music:
	movem.l	d0-d4/a0-a3/a5-a6,-(a7)
	move.l	mt_data,a0
	addq.b	#$1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.s	mt_nonew
	clr.b	mt_counter
	bra	mt_getnew

mt_nonew:
	lea	mt_voice1(pc),a6
	lea	$dff0a0,a5
	bsr	mt_checkcom
	lea	mt_voice2(pc),a6
	lea	$dff0b0,a5
	bsr	mt_checkcom
	lea	mt_voice3(pc),a6
	lea	$dff0c0,a5
	bsr	mt_checkcom
	lea	mt_voice4(pc),a6
	lea	$dff0d0,a5
	bsr	mt_checkcom
	bra	mt_endr

mt_arpeggio:
	moveq	#0,d0
	move.b	mt_counter,d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.s	mt_arp2
	cmp.w	#$2,d0
	beq.s	mt_arp1

	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1:moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.s	mt_arp3
mt_arp2:move.w	$10(a6),d2
	bra.s	mt_arp4
mt_arp3:asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	mt_periods(pc),a0
	moveq	#$24,d7
mt_arploop:
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts
mt_arp4:move.w	d2,$6(a5)
	rts

mt_getnew:
	move.l	mt_data,a0
	move.l	a0,a3
	move.l	a0,a2
	add.l	#$c,a3
	add.l	#$3b8,a2
	add.l	#$43c,a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	$4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$4(a3,d4.l),d0
	add.w	$6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
	bra.s	mt_setregs
mt_noloop:
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
mt_setregs:
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	mt_checkcom2
	move.b	$2(a6),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.s	mt_setperiod
	bsr	mt_setmyport
	bra	mt_checkcom2
mt_setperiod:
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	move.w	$14(a6),d0
	move.w	d0,$dff096
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	move.w	$14(a6),d0
	or.w	d0,mt_dmacon
	bra	mt_checkcom2

mt_setdma:
	move.w	#$12c,d0
mt_wait:dbf	d0,mt_wait
	move.w	mt_dmacon,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.w	#$12c,d0
mt_wai2:dbf	d0,mt_wai2
	lea	$dff000,a5
	lea	mt_voice4(pc),a6
	move.l	$a(a6),$d0(a5)
	move.w	$e(a6),$d4(a5)
	lea	mt_voice3(pc),a6
	move.l	$a(a6),$c0(a5)
	move.w	$e(a6),$c4(a5)
	lea	mt_voice2(pc),a6
	move.l	$a(a6),$b0(a5)
	move.w	$e(a6),$b4(a5)
	lea	mt_voice1(pc),a6
	move.l	$a(a6),$a0(a5)
	move.w	$e(a6),$a4(a5)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_endr
mt_nex:	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	move.l	mt_data,a0
	cmp.b	$3b6(a0),d1
	bne.s	mt_endr
	clr.b	mt_songpos
mt_endr:tst.b	mt_break
	bne.s	mt_nex
	movem.l	(a7)+,d0-d4/a0-a3/a5-a6
	rts

mt_setmyport:
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rt
	move.b	#$1,$16(a6)
	rts
mt_clrport:
	clr.w	$18(a6)
mt_rt:	rts

mt_myport:
	move.b	$3(a6),d0
	beq.s	mt_myslide
	move.b	d0,$17(a6)
	clr.b	$3(a6)
mt_myslide:
	tst.w	$18(a6)
	beq.s	mt_rt
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	mt_mysub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
mt_myok:move.w	$10(a6),$6(a5)
	rts
mt_mysub:
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$6(a5)
	rts

mt_vib:	move.b	$3(a6),d0
	beq.s	mt_vi
	move.b	d0,$1a(a6)

mt_vi:	move.b	$1b(a6),d0
	lea	mt_sin(pc),a4
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.s	mt_vibmin
	add.w	d2,d0
	bra.s	mt_vib2
mt_vibmin:
	sub.w	d2,d0
mt_vib2:move.w	d0,$6(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

mt_nop:	move.w	$10(a6),$6(a5)
	rts

mt_checkcom:
	move.w	$2(a6),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	$2(a6),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpeggio
	cmp.b	#$1,d0
	beq.s	mt_portup
	cmp.b	#$2,d0
	beq	mt_portdown
	cmp.b	#$3,d0
	beq	mt_myport
	cmp.b	#$4,d0
	beq	mt_vib
	move.w	$10(a6),$6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_volslide:
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldown
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.s	mt_vol2
	move.w	#$40,$12(a6)
mt_vol2:move.w	$12(a6),$8(a5)
	rts

mt_voldown:
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.s	mt_vol3
	clr.w	$12(a6)
mt_vol3:move.w	$12(a6),$8(a5)
	rts

mt_portup:
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.s	mt_por2
	and.w	#$f000,$10(a6)
	or.w	#$71,$10(a6)
mt_por2:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_portdown:
	clr.w	d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$358,d0
	bmi.s	mt_por3
	and.w	#$f000,$10(a6)
	or.w	#$358,$10(a6)
mt_por3:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_checkcom2:
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_setfilt
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_posjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_setfilt:
	rts
mt_pattbreak:
	not.b	mt_break
	rts
mt_posjmp:
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts
mt_setvol:
	cmp.b	#$40,$3(a6)
	ble.s	mt_vol4
	move.b	#$40,$3(a6)
mt_vol4:move.b	$3(a6),$8(a5)
	rts
mt_setspeed:
	move.b	$3(a6),d0
	and.w	#$1f,d0
	beq.s	mt_rts2
	clr.b	mt_counter
	move.b	d0,mt_speed
mt_rts2:rts




mt_sin:
 dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
 dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:
 dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
 dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
 dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
 dc.w $007f,$0078,$0071,$0000,$0000

mt_speed:	dc.b	$6
mt_songpos:	dc.b	$0
mt_pattpos:	dc.w	$0
mt_counter:	dc.b	$0

mt_break:	dc.b	$0
mt_dmacon:	dc.w	$0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	10,0
		dc.w	$1
		dcb.w	3,0
mt_voice2:	dcb.w	10,0
		dc.w	$2
		dcb.w	3,0
mt_voice3:	dcb.w	10,0
		dc.w	$4
		dcb.w	3,0
mt_voice4:	dcb.w	10,0
		dc.w	$8
		dcb.w	3,0

mt_data		dc.l	0

****************************************************************************

		section		misc,data

****************************************************************************
****************************************************************************
***************************** Data *****************************************
****************************************************************************
****************************************************************************


grafname	dc.b		'graphics.library',0
		even

dosname		DOSNAME

_DOSBase	dc.l		0

WobTab		dc.w	$11,$11,$11,$22,$22,$33,$33,$33,$33,$44
		dc.w	$44,$44,$33,$33,$33,$33,$22,$22,$11,$11
		dc.w	$11,$11,$11,$11,$11
		
_GfxBase	ds.l		1
sysDMA		ds.l		1
syscop		ds.l		1

Pic1		dc.b		'df1:bitmaps/pic1.bm',0
		even
Mod1		dc.b		'df1:modules/mod.5',0
		even

Pic2		dc.b		'df1:bitmaps/pic5.bm',0
		even
Mod2		dc.b		'df1:modules/mod.6',0
		even

		section		yummy,BSS
_DecBuff	ds.b	130000


*****************************************************************************
*****************************************************************************
***************************** CHIP Data *************************************
*****************************************************************************
*****************************************************************************

		section		cop,data_c


CopList		dc.w DIWSTRT,$2c81		Top left of screen
		dc.w DIWSTOP,$2cc1		Bottom right of screen (PAL)
		dc.w DDFSTRT,$38		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$4200		Select lo-res 16 colours
		dc.w BPLCON1,0			No horizontal offset
		dc.w BPL1MOD,0			No modulo
		dc.w BPL2MOD,0			on either plane

CopColours	ds.w 32				space for colours

		dc.w DMACON,$0100		bpl off

WaitAbout	dc.w $2c09,$fffe	$f209,$fffe		wait

		dc.w DMACON,$8100		bpl on

		dc.w BPL1PTH			Plane pointers for 1 plane
CopPlanes	dc.w 0,BPL1PTL          
		dc.w 0,BPL2PTH          
		dc.w 0,BPL2PTL          
		dc.w 0,BPL3PTH          
		dc.w 0,BPL3PTL          
		dc.w 0,BPL4PTH          
		dc.w 0,BPL4PTL          
		dc.w 0

		dc.w	$ffff,$fffe		end of list
		
		section	yummy_again,BSS_C
		
BitPlane1	ds.b	(320/8)*256*4+32
BitPlane2	ds.b	(320/8)*256*4+32
Module1		ds.b	150000
Module2		ds.b	150000
