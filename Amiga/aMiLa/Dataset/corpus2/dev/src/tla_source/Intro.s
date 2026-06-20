; +--------------------------+
; | 'intro.s' Display Piccy. |
; +--------------------------+----------------------------------------+


INT_SCREENSIZE	= 80*304*4		; Largest screen = 640x304x16 Cols
					;  ( TLA = 320x256x64 Col )

	CNOP	0,4

INT_INT	;-- Get Screen Memory --
	Move.l	#INT_SCREENSIZE,d0
	Move.l	#MEMF_CHIP|MEMF_CLEAR,d1
	Call	_LVOAllocMem,exec
	Move.l	d0,INT_scrbase
	Bne.s	.memok

	Move.w	#-2,EXIT		; Not enough memory
	Rts				; Bail out NOW!!

.memok	Add.l	#80*4,d0
	Move.l	d0,INT_scrbase2

	;-- Init CopperList --

	Lea	$DFF000,a5
	Move.w	#$0180,DMACON(a5)	; Kill DMA: BPLEN | COPEN

	_LoadPalette24	INT_black, INT_Cp1, 1
	_LoadPalette24	INT_black, INT_Cp2, 1
	_LoadPlanes	INT_scrbase,  INT_CL1, 4, 80
	_LoadPlanes	INT_scrbase2, INT_CL2, 4, 80

	;-- Setup Long/Short frame swap --
	Lea	INT_C1,a0	; Pointer.1
	Move.l	#INT_CL2,d0	; Addr. of Short Frame
	Move.w	d0,6(a0)
	Swap	d0
	Move.w	d0,2(a0)

	Lea	INT_C2,a0	; Pointer.2
	Move.l	#INT_CL1,d0	; Addr. of Long Frame
	Move.w	d0,6(a0)
	Swap	d0
	Move.w	d0,2(a0)

	_ClearView
	_WaitTOP
	_WaitTOP			; Don't screw with hardware mid-frame! (sync.)
	Bset.b	#7,VPOSW(a5)		; Set to 2nd frame so 1st CL clears it

	_LoadCList	INT_CL1		; Show CopperList
	Move.w	#$8380,$DFF000+DMACON	; DMAEN | BPLEN | COPEN



	; +-------+
	; | START |
	; +-------+-------------------+




	;-- PART 1: 640x86x16 Col  --
	Move.l	INT_scrbase,a1
	Lea	80*4*109(a1),a1		; Start at line 109
	Move.l	a1,INT_plstrt		; Where to start decrunching to

	Lea	INT_packptr,a0		; Offsets of packed datas

	Moveq	#1,d7
.ol1	Move.l	(a0)+,INT_dds		; EXP Presents | Demo 4 Coven '97
	Jsr	WFS
	Jsr	LNW
	Tst.w	EXIT
	Bne.s	INT_bailout
	Dbra	d7,.ol1




	;-- PART 2: 640x116x16 Col --
	Move.l	INT_scrbase,a1
	Lea	80*4*94(a1),a1		; Start at line 94
	Move.l	a1,INT_plstrt		; Where to start decrunching to

	Jsr	WFS
	Move.l	#INT_credpal, INT_pal

	Move.l	(a0)+,INT_dds		; Me
	Jsr	LNW
	Tst.w	EXIT
	Bne.s	INT_bailout

	Moveq	#2,d7
.ol2	Move.l	(a0)+,INT_dds		; Steve | Adam | Dave
	Jsr	WFS
	Jsr	LNW
	Tst.w	EXIT
	Bne.s	INT_bailout
	Dbra	d7,.ol2




	;-- PART 3: 320x256x64 Col --
	Jsr	WFS
	_LoadPlanes	INT_scrbase, INT_TLA_CL, 6, 40*256
	_LoadPalette24	PAL_white, INT_TLA_Cp, 2
	_LoadCList	INT_TLA_CL

	Lea	INT_tlatrace,a1
	Move.l	INT_scrbase,a2
	Jsr	__STC_Decrunch

	;-- FADE PALETTE IN --
	Move.w	#255,d7			; Start Value
.1	Lea	INT_tlapal,a0
	Lea	PAL_white,a1
	Lea	INT_tmppal,a2
	Moveq	#63,d0			; # colours - 1
	Move.w	d7,d1			; Fade Level
	Jsr	__FadePalette24
	_WaitVBL
	_LoadPalette24	INT_tmppal, INT_TLA_Cp, 2

	Tst.w	EXIT
	Bne.s	INT_bailout		; We're outta here!

	Subq.w	#2,d7			; Fade Speed
	Bgt.s	.1




	_WaitVBL	50*5



	;+------------------+
	;| Finish (fadeout) |
	;+------------------+---------+

	Move.w	#255,d7
.fl	Lea	PAL_black,a0
	Lea	INT_tlapal,a1
	Lea	INT_tmppal,a2
	Moveq	#63,d0			; # colours - 1
	Move.w	d7,d1			; Fade Level
	Jsr	__FadePalette24
	_WaitVBL
	_LoadPalette24	INT_tmppal, INT_TLA_Cp, 2


	Tst.w	EXIT
	Bne.s	INT_bailout		; We're outta here!

	Subq	#4,d7
	Bgt.s	.fl



	_WaitVBL 20


	; +-| END |-----------------------------------+

	Move.l	#INT_SCREENSIZE,d0
	Move.l	INT_scrbase,a1
	Call	_LVOFreeMem,exec

	Move.w	#$0000,$DFF000+BPLCON4	; Clear Colour Palette XOR

	Move.w	#$0180,DMACON(a5)
	_WaitVBL

INT_bailout	Rts			; Finished





; --+-------------+-----------------------------------------------------------+
; --| SUBROUTINES |--
; --+-------------+--


WFS	;WaitForSync.
	Move.l	d0,-(sp)
	PT_ClearTrig
.w1	PT_TrigVal
	Tst.w	d0		; An event
	Bne.s	.w2		;  YES!	- spring out

	Tst.w	EXIT
	Beq.s	.w1

.w2	Move.l	(sp)+,d0
	Rts


LNW	; Load bitplanes & wait 
	Movem.l	d0-7/a0-6,-(sp)

	;-- MAKE SCREEN WHITE --
	_LoadPalette24	PAL_white, INT_Cp1, 1
	_LoadPalette24	PAL_white, INT_Cp2, 1
	_WaitVBL 2			; TIMING!!

	;-- DECRUNCH GRAPHICS DATA --
	Lea	INT_DataPack,a1		; Crunched Image Data (Base)
	Add.l	INT_dds,a1		; Offset
	Move.l	INT_plstrt,a2		; Decrunch Destination
	Jsr	__STC_Decrunch

	;-- FADE PALETTE --
	Move.w	#255,d7			; Start Value
.1	Lea	PAL_white,a1
	Move.l	INT_pal,a0
	Lea	INT_tmppal,a2
	Moveq	#31,d0			; # colours - 1
	Move.w	d7,d1			; Fade Level
	Jsr	__FadePalette24
	_WaitVBL
	_LoadPalette24	INT_tmppal, INT_Cp1, 1
	_LoadPalette24	INT_tmppal, INT_Cp2, 1

	Tst.w	EXIT
	Bne.s	.3			; We're outta here!

.2	Subq.w	#2,d7			; Fade Speed
	Bge.s	.1

	;-- END --
.3	Movem.l	(sp)+,d0-7/a0-6
	Rts


; +-------+
; | Datas |	
; +-------+-------------------------------------------+

INT_pal		Dc.l	INT_exppal	; Ptr 2 palette 2 ues
INT_plstrt	Dc.l	0		; -> Where to start drawing on ChipRam
INT_dds		Dc.l	0		; -> Crunched Data Offset

INT_packptr	Dc.l	0, 6440, 12296, 16612, 22412, 27992, 31692

INT_scrbase	Dc.l	0		; Base address of screen display
INT_scrbase2	Dc.l	0		;  (hack for 2nd frame)

INT_black	Dcb.l	16,$000000
		Dcb.l	16,$0a0a18
INT_tmppal	Dcb.l	64,$000000

INT_exppal	dcb.l	16,$000000
		dc.l	$0a0a18,$ffcc44,$eeaa33,$dd8822,$bb6622,$aa5511,$994400,$883300
		dc.l	$256ca3,$242424,$4a4a4a,$6e6e6e,$919191,$b5b5b5,$dbdbdb,$ffffff

INT_credpal	dcb.l	16,$000000
		dc.l	$0a0a18,$222222,$444444,$666666,$888888,$c2c2c2,$eeeeee,$ff5555
		dc.l	$4d4de6,$4545cd,$3c3cb4,$34349c,$2c2c83,$24246a,$1b1b51,$131338

INT_tlapal	dc.l	$000000,$08081a,$231c04,$272007,$2a2309,$2e260b,$32290d,$352d0f
		dc.l	$393011,$3d3314,$403616,$443a18,$473d1a,$4b401c,$4f431e,$524721
		dc.l	$564a23,$5a4d25,$5d5027,$615429,$64572b,$685a2e,$6c5d30,$6f6132
		dc.l	$736434,$776736,$7a6a38,$7e6e3b,$81713d,$85743f,$897741,$8c7a43
		dc.l	$907e46,$938148,$97844a,$9b874c,$9e8b4e,$a28e50,$a69153,$a99455
		dc.l	$ad9857,$b09b59,$b49e5b,$b8a15d,$bba560,$bfa862,$c3ab64,$c6ae66
		dc.l	$cab268,$cdb56a,$d1b86d,$d5bb6f,$d8bf71,$dcc273,$e0c575,$e3c877
		dc.l	$e7cc7a,$eacf7c,$eed27e,$f1db98,$f5e4b2,$f8edcb,$fcf6e5,$ffffff



	CNOP 0,8

INT_DataPack	incbin	'tla/intro/IntroData.STC'
INT_tlatrace	incbin	'tla/intro/TLA_trace.STC'


;+-------------+
;| CopperLists |
;+-------------+------------------------------+

	section	'Laced Copper',DATA_C

	; Long Frame

INT_CL1	Dc.w	BPL0PTH,0,BPL0PTL,0,BPL1PTH,0,BPL1PTL,0
	Dc.w	BPL2PTH,0,BPL2PTL,0,BPL3PTH,0,BPL3PTL,0
	Dc.w	BPLCON1,0,BPLCON2,0,BPLCON4,$1000
	Dc.w	DDFSTRT,$3C,DDFSTOP,$D4,DIWSTRT,$2C81,DIWSTOP,$2CC1
	Dc.w	BPL1MOD,80*7,BPL2MOD,80*7
INT_Cp1	ColBank	1
INT_d1a	Dc.w	$6007,$FFFE,BPLCON0,$C204		; Display On
INT_d1b	Dc.w	$F807,$FFFE,BPLCON0,$8204		; Display Off
	;-- COPPERLIST JUMP POINTER --
INT_C1	Dc.w	COP1LCH,0,COP1LCL,0			; Load Short Frame
	Dc.w	$FFFF,$FFFE				; END

	; Short Frame

INT_CL2	Dc.w	BPL0PTH,0,BPL0PTL,0,BPL1PTH,0,BPL1PTL,0
	Dc.w	BPL2PTH,0,BPL2PTL,0,BPL3PTH,0,BPL3PTL,0
INT_Cp2	ColBank	1
INT_d2a	Dc.w	$6007,$FFFE,BPLCON0,$C204		; Display On
INT_d2b	Dc.w	$F807,$FFFE,BPLCON0,$8204		; Display Off
	;-- COPPERLIST JUMP POINTER --
INT_C2	Dc.w	COP1LCH,0,COP1LCL,0			; Load Long Frame
	Dc.w	$FFFF,$FFFE				; END


	;-- SECOND COPPERLIST (TLA PICTURE ) --

INT_TLA_CL	Dc.w	BPL0PTH,0,BPL0PTL,0,BPL1PTH,0,BPL1PTL,0
		Dc.w	BPL2PTH,0,BPL2PTL,0,BPL3PTH,0,BPL3PTL,0
		Dc.w	BPL4PTH,0,BPL4PTL,0,BPL5PTH,0,BPL5PTL,0
		Dc.w	DDFSTRT,$38,DDFSTOP,$D0,DIWSTRT,$2C81,DIWSTOP,$2CC1
		Dc.w	BPL1MOD,0,BPL2MOD,0
		Dc.w	BPLCON0,$6200,BPLCON1,0,BPLCON2,$0200	; KillEHB
		Dc.w	BPLCON4,0
INT_TLA_Cp	ColBank	2				; 64 colours
		Dc.w	$FFFF,$FFFE	
