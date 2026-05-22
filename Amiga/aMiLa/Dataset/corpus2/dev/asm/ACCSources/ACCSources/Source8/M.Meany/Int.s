
; This program brings together Steve Marshalls interrupt routine, my screen
;routine and the NoiseTracker replay source. A picture is displayed and a
;tune plays, but the o/s is still accessable.

; Press both mouse buttons to stop.

; This program will run from the workbench if given an icon.

; M.Meany 1991


		opt 		o+,ow-

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"exec/ports.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		include		"misc/arpbase.i"
		INCLUDE	resources/cia.i
		INCLUDE	hardware/cia.i
		INCLUDE	misc/easystart.i


		LIBINIT	LIB_BASE		;lib offsets for CIA resource
		LIBDEF	CIA_ADDICRVECTOR	;as not defined in recources/cia.i :-)
		LIBDEF	CIA_REMICRVECTOR	;I think these are correct anyway the 
		LIBDEF	CIA_ABLEICR		;two used in this program are.Does 
		LIBDEF	CIA_SETICR		;Commodore think we are telepathic ?
	
PALTIME		EQU	14187		;sets interrupt timer to 50Hz
NTSCTIME	EQU	14318

;*****************************************

CALLSYS    MACRO		;added CALLSYS macro - using CALLARP
	IFGT	NARG-1       	;CALLINT etc can slow code down and  
	FAIL	!!!         	;waste a lot of memory  S.M. 
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM
		
*****************************************************************************

; The main routine that opens and closes things

start		OPENARP				
		movem.l		(sp)+,d0/a0	
						
						
		move.l		a6,_ArpBase	
		
;--------------	the ARP library opens and uses the graphics and intuition 
;		libs and it is quite legal for us to get these bases for 
;		our own use.

		move.l		IntuiBase(a6),_IntuitionBase
		move.l		GfxBase(a6),_GfxBase

		jsr		mt_init

		lea		InterruptVector(pc),a0	;set a0 to interrupt vector
		bsr.s		InitCIA			;set it running
		tst.l		d0			;check for errors
		beq.s		go			;branch if no error
		move.l		#5,errorMsg		;set error to WARN
		bra.s		_exit2			;branch if error

go		bsr		OpenScreen		open screen
		beq.s		_exit

loop:
		btst		#6,$bfe001		;check for left mouseclick
		bne.s		loop 			;branch if not left mouse	
		btst		#$0a,$dff016		;check for right mouseclick
		bne.s		loop
	
		bsr		CloseScreen
_exit
		lea		InterruptVector(pc),a0	;set interrupt to stop
		bsr		CIAOff			;and stop it
		clr.l		errorMsg		;no errors so clear error msg
_exit2
		jsr		mt_end
		bclr  		#1,$bfe001  		;**** LED on ****	
		move.l		_ArpBase,a1		close ARP library
		CALLEXEC	CloseLibrary
		rts					;EXIT program



InitCIA:
		move.l		a0,-(sp)		;save a0
		lea		CIAname(pc),a1		;get cia resource name 
		CALLEXEC	OpenResource		;open resource
		move.l		d0,CIAbase		;store resource base
		beq		CIA_Error		;branch if open failed
	
		move.l		_GfxBase,d6		d6=addr of lib base
	  	beq.s		.Pal			;default to pal if no graf lib
  	
	  	move.l		d0,a1			;graphics lib base in a0
		move.w		206(a1),d1		;get Display flags
		btst		#2,d1			;does DisplayFlags = PAL
		beq.s		.Ntsc 			;branch if not PAL
.Pal
		move.w		#PALTIME,d7		;set PAL time delay
		bra.s		Timeset			;branch always
.Ntsc
		move.w		#NTSCTIME,d7		;set NTSC time delay

Timeset	
		lea		$bfd000,a5		;get peripheral data reg a
		move.l		CIAbase(pc),a6		;get cia base
		move.l		(sp),a1			;get Interrupt vector
		moveq		#1,d0			;set ICRBit (timer B)
		jsr		CIA_ADDICRVECTOR(a6)	;add interrupt
		move.l		d0,CIAFlag		;store return value
		bne.s		TryTimerA		;branch to try timer A
	
		move.b		d7,ciatblo(a5)		;set timer B low
		lsr.w		#8,d7			;shift left for high byte
		move.b		d7,ciatbhi(a5)		;set timer B high
		bset		#0,ciacrb(a5)		;start timer (continuous)
		bra.s		CIA_End			;branch to finish
	
TryTimerA:
		move.l		(sp),a1			;get Interrupt vector
		moveq		#0,d0			;set ICRBit (timer A)
		jsr		CIA_ADDICRVECTOR(a6)	;add interrupt
		tst.l		d0			;check for error
		bne.s		CIA_Error		;branch if error
  	
		move.b		d7,ciatalo(a5)		;set timer A low
		lsr.w		#8,d7			;shift left for hight byte
		move.b		d7,ciatahi(a5)		;set timer B high
		bset		#0,ciacra(a5)		;start timer A

CIA_End:
		moveq		#0,d0			;flag no error
		addq.l		#4,sp			;pop a0 from stack
		rts					;quit
	
CIAOff:
		move.l		a0,-(sp)		;save a0
		lea		$bfd000,a5		;get peripheral data reg a
		tst.l		CIAFlag			;check for timer B
		bne.s		TimerA			;branch if not timer B
	
		bclr		#0,ciacrb(a5)		;stop timer B
		moveq		#1,d0			;set ICRBit (timer B)
		bra.s		RemInt			;branch to remove
TimerA
		bclr		#0,ciacra(a5)		;stop timer A
		moveq		#0,d0			;set ICRBit (timer A)
	
RemInt
		move.l		CIAbase(pc),a6		;get CIA base
		move.l		(sp),a1			;get interrup to remove
		jsr		CIA_REMICRVECTOR(a6)	;and remove it

CIA_Error:
		moveq		#-1,d0			;flag error
		addq.l		#4,sp			;pop a0 from stack
		rts					;quit

Interrupt_handler:
		movem.l		d2-d7/a2-a6,-(a7)	;save regs
	
		jsr		mt_music
	
		movem.l		(a7)+,d2-d7/a2-a6	;restore regs
		moveq		#0,d0			;allow other interrupts to run
		rts	

;-------------- Open the intuition screen.

		

; First we must set up a custom bit map structure.
; See the file  Include/graphics/gfx.i for more info on structure.
		
OpenScreen	lea		bitmap,a0	a0->uninitialised bm struct
		move.l		a0,a3		store a copy for later
		moveq.l		#5,d0		d0=screen depth
		move.l		#320,d1		d1=screen width
		move.l		#200,d2		d2=screen height
		CALLGRAF	InitBitMap

; Now copy address of each bitplane into the bitmap structure.

		move.l		a3,a0		a0->bitmap structure
		add.l		#bm_Planes,a0	a0->addr of plane pointers
		move.l		#Picture,d0	d0=addr of picture
		move.l		#(320/8)*200,d1	d1=size of each plane
		moveq.l		#4,d2		d2=num of planes - 1
.loop		move.l		d0,(a0)+	addr of next plane into struct
		add.l		d1,d0		d0=addr of next plane
		dbra		d2,.loop		for all planes
		move.l		d0,a3		a3->colours
		
; Open the screen

		lea		custom_screen,a0 a0->new screen structure
		CALLINT		OpenScreen	open the screen
		move.l		d0,screen.ptr	store pointer returned
		beq.s		error1		leave if screen failed to open
		
; Load correct colours into this screens viewport.

		move.l		d0,a0		a0->screen structure
		add.l		#sc_ViewPort,a0 a0->screens viewport struct
		move.l		a3,a1		a1->colours
		moveq.l		#32,d0		d0=number of colours
		CALLGRAF	LoadRGB4	load colours
		moveq.l		#1,d1		no errors

error1		rts				and return

;--------------	Close the screen

CloseScreen	move.l		screen.ptr,a0	a0->screen 
		CALLINT		CloseScreen	and close it
		rts

	
********** variables and structures ********
;------	Interrupt structure	
InterruptVector:
		dc.l	0	;LN_SUCC
		dc.l	0	;LN_PRED
		dc.b	0	;LN_TYPE
		dc.b	127	;LN_PRI
		dc.l	0	;LN_NAME
		dc.l	0	;is_Data
		dc.l	Interrupt_handler	;address of routine to call

errorMsg:	dc.l	0

CIAFlag:	dc.l	0		

CIAbase:	dc.l	0	

CIAname:
	CIABNAME
	
;-------------- Data Section
		even
custom_screen	dc.w		0,0		x,y starting position
		dc.w		320,200		width,height
		dc.w		5		depth
		dc.b		0,0		fgr pen,bgr pen
		dc.w		2		normal mode
		dc.w		CUSTOMSCREEN!CUSTOMBITMAP	screen type
		dc.l		0		standard font
		dc.l		0		no title
		dc.l		0		no gadgets
		dc.l		bitmap		addr of bitmap struct
		
		section		piccy,bss

_ArpBase	ds.l		1
_GfxBase	ds.l		1
_IntuitionBase	ds.l		1

screen.ptr	ds.l		1

bitmap		ds.b		bm_SIZEOF
		even
		
		section		pic,code_c
		
Picture		incbin		'workdisk:bitmaps/piccy.bm'
		even


**************************************
*   NoisetrackerV1.0 replayroutine   *
* Mahoney & Kaktus - HALLONSOFT 1989 *
**************************************


mt_init:lea	mt_data,a0
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
	lea	mt_data,a0
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
	lea	mt_data,a0
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
	cmp.b	mt_data+$3b6,d1
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

mt_data incbin "workdisk:modules/mod.music"




