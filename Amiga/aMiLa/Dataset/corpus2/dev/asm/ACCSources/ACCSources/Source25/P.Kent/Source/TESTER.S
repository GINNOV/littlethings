    OPT C-,O+,D+,OW2-

******************************************************************************
*
* WOKING TITLE: *GARISH* BOB & TEXTHANDLER TEST
*       AUTHOR: PAUL KENT
*     COMPILER: DEVPAC3
*       MEMORY:
*  DIARY/NOTES:
* 13/06/92 : Updated trace routines...
*          : General test of bob & texthandler routines....
* 23/06/92 : Using PKDOS V0.32 with *revised* bob routines
* SPECIFY ON GENAM COMMAND LINE:
* SYSTEM TO DISABLE INT DRIVERS/COPPER ETC.
* SMPI FOR SMPI CODE
* GENLOCK FOR ERSY
* NODISK FOR NO DISK ROUTINES
******************************************************************************

    SECTION PKDOS,CODE
	OUTPUT  :TESTER
	INCLUDE	Source:INCLUDE/HARDWARE.I
	INCLUDE	Source:P.Kent/INCLUDES/MYMACROS.I
	INCLUDE Source:P.Kent/INCLUDES/COMBISTART.S
	INCLUDE	Source:P.Kent/INCLUDES/HWSTART.S
;Text handler code for *ALL* text output :-)
	INCLUDE	Source:P.Kent/INCLUDES/TEXTHANDLER.S
;Memory alloc routines...
	INCLUDE	Source:P.Kent/INCLUDES/MEMORYMNGR.S
;Disk IO/control + DOS LOADER + LH decrunch code
	IFND	NODISK
	INCLUDE Source:P.Kent/INCLUDES/DISKMACROS2.I
	INCLUDE	Source:P.Kent/INCLUDES/DISK.S
	INCLUDE	Source:P.Kent/INCLUDES/LHDECODE.S
	ENDC
	INCLUDE Source:P.Kent/SOURCE/DISPFX.S
;AMOUNT OF K TO SIMULATE...
;NB Dont put 0K : MEMINFO will be incorrect!
;Delete entries in MEMINFO
SLOWK = 1	; Only small buffers: just need disk buff+pic buffs!
FASTK = 1
CHIPK = 128

	IFD	SMPI
	INCLUDE	Source:P.Kent/INCLUDES/SMPI.S
	ENDC

FLASHBGCOL	MACRO
	MOVE.L D0,-(A7)
	MOVEQ #-1,D0
.fbgc\@ MOVE.W D0,COLOR00+CUSTOM
	DBRA D0,.fbgc\@
	MOVE.L (A7)+,D0
	ENDM

SBLITWAIT	MACRO
;If we are going to debug this (-esystem etc.) >>dont<<
;use any supervisor/Sr tricks
	IFD	SYSTEM
	BLITWAIT \1
	ENDC

	IFND SYSTEM
;This macro by NICK PELLING from his article in JAM#20
	TST.W	DMACONR(\1)
	BTST	#6,DMACONR(\1)
	BEQ.S	.ok\@
.wait\@	STOP	#$2000
	BTST	#6,DMACONR(\1)
	BNE.S	.wait\@
.ok\@
	ENDC

	ENDM
****************************
*     SCREEN SIZES         *
****************************
;SCREEN IS 320 ($28 WIDB), 256 HGT
NPL = 5				; Only these need changing
NUMCOLS	= 32		; for different no. colours
PLWIDW = 20
PLWIDB = PLWIDW*2
PLHGT  = 256
PLLEN = PLWIDB*PLHGT

****************************

;BOB structure
			rsreset
B_ID		rs.l	1				; 'BOB0' ID characters
B_InitSig	rs.b	1				; NZERO after init
B_Options	rs.b	1				; 0 - use mask as present
									; 1 - calculate & use mask at ptr
									; 2 - no mask - direct copy
B_WWid		rs.w	1				; Width in words+1
B_Hgt		rs.w	1				; Height pixels
B_SMod		rs.w	1				; Source + modulo if any

B_BMap		rs.l	1				; Interleaved bitmap ptr
B_Mask		rs.l	1				; Interleaved mask ptr

B_CBSize	rs.w	1				; BlitSize
B_CMod		rs.w	1				; Generic modulo
B_CRMod		rs.w	1				; Reset modulo CMod-2
B_len		rs.w	1

****************************

_BOOT
	LEA	CUSTOM,A6
	LEA	MYVARS,A5
	BSR	InitStartUp

;Test of my bob handling routines.... : background saving unused....
	MOVE.L #lw.DispFXCols,plw.Cols(a5)
	Bsr LoadCopCols
	BSR DispFX_Init
	BSR RunDispFX
	BSR DelDispFX
	MOVE.L #lw.blackcols,plw.cols(a5)
	Bsr LoadCopCols
;

;Test of texthandler....
	LEA TESTMSG(PC),A0
	BSR HANDLETEXT
	BSR SWAPCOP
	MOVE.L #lw.CFontCols,plw.Cols(a5)
	MOVEQ	#2,D0
	BSR FADECOLS
LP	MOUSE	LP
	MOVE.L #lw.blackcols,plw.cols(a5)
	MOVEQ	#2,D0
	BSR FADECOLS
;
	RTS								; Back to DOS!

TESTMSG
;NB try putting errors into the text eg. '\CRASH' - _Error routine
;is called, and program exits safely - even showing you your error!
	DC.B	'\s0\f0\K\mc'
	DC.B	'\X0\Y100\jc\c2\tHow about this folks!!!'
	DC.B	'\y10\X32\jl\c3\tI mean like...\u\y10\c4\t...colours & space!'
	DC.B	'\Y200\jc\c8\tWritten in 1992 by P.Kent for ACC!!!'
	DC.B	'\jc\X0\Y0\c7\f1\tTESTING COLOUR FONTS'
	DC.B	'\y18\c15\tSTILL TESTING 1!'
	DC.B	'\y18\c23\tSTILL TESTING 2!'
	DC.B	'\y18\c31\tSTILL TESTING 3!'
;Put msg over coloured 'test 2' - in cookie mode, so colour font still visible
	DC.B	'\c8\Y40\jc\f0\tTEXT CAN BE PLACED PRECISELY!'
;Put down text in a column...
	DC.B	'\f0\c8\Y128\X0\jl\tHmmm...\y10\tPutting\y10\tdown\y10\ttext'
	DC.B	'\y10\tin columns\y10\tis all\y10\tto easy!'
	DC.B	'\q'
	EVEN


*****
*Initialisation routine for startup only
*****
InitStartUp
	IFND	SYSTEM
	lea	Int3_Handler(pc),a0				; Set up interrupt handlers
	move.l	a0,$6C.W
	lea	Trace_Handler(pc),a0			; Debug code..
	move.l	a0,$24.W
	ENDC
	BSR	InitMulTab

	LEA	MEMINFO,A1						; Init RAM alloc system...
	BSR	Minitialise

	MOVE.L	#lw.BlackCols,plw.Cols(A5)	; Put in initial colours...
	BSR LoadCopCols

	MOVE.L	#NPL*PLLEN*2,D1				; Allocate memory for screens
	BSR	AllocChip
	MOVE.L	D0,p.DrawPl(A5)				; Initial screen ptr
	ADD.L	#NPL*PLLEN,D0
	MOVE.L	D0,p.ShowPL(a5)
	BSR	SwapCop							; Load copper list values...
	BSR InitSpr
	IFND	SYSTEM
	CATCHPOS	A6,200     				; Wait for VBL
	MOVE.L	#MY_Copper,cop1lch(A6)		; Just set dma/ints and wait!
	MOVE.W	D0,COPJMP1(A6)
	MOVE.W	#SETIT!DMAEN!BPLEN!BLTEN!COPEN!DSKEN,dmacon(A6)
	MOVE.L	#(SETIT!INTEN!BLIT!VERTB!COPER)*65536+$7FFF,intena(A6)
										; My ints + zap intreq!
	BSR	InitKeys						; Init keyb handler, $68.w
	ENDC
	IFD	SMPI
	BSR	InitSmpi
	ENDC
	IFND	NODISK
	BSR	InitDisks
	ENDC
	RTS

*****
* Trace_Handler()
* Press+release LMB to step instructions....
* Hold RMB to quit trace mode...
* Handle a trace exception...
* Occurs whenever trace bit in SRis set, after execution of an instruction
* A Dave Edwards production - some mods by P.Kent
*****
Trace_Handler
;On entry stack will hold: (as per a normal exception)
; 0(sp).w SR : SAVED STATUS REGISTER
; 2(sp).l PC : Return Address
	movem.l	d0-d7/a0-a7,ll.TraceRegs ; Save all registers - saving stack also
	move.w	SR,w.TraceStat			; Save SR, for return...
	Lea	MYVARS,A5					; Need my variable block...
	move.w	#$2700,SR				; Prevent interrupts queueing up 

	move.l	2(sp),l.TracePC			; Get return address
	bsr.s	ShowRegs				; Print registers etc.
; Wait for the LMB to be pressed & released before continuing...
Trace_W1
	btst	#6,CIAAPRA				; wait for mouse press
	bne.s Trace_W1
Trace_W2
	btst	#6,CIAAPRA				; wait for release...
	beq.s Trace_W1

	btst	#10-8,$dff016			; If RMB pressed, kill trace mode...
	bne.s	Trace_Noff
	ClearTrace
Trace_Noff
	tst.w w.Tron(a5)				; continuing trace?
	bne.s Trace_B1 					; yes - branch...
; Stopping trace mode - clear trace bit of status register (SR)...
; BUT since RTE will reload the SR register from the stack, we must
; clear the bit there..
	move.w	(sp),d0					; get actual SR saved
	bclr	#15,d0					; clr trace bit
	move.w	d0,(sp)					; save back

Trace_B1
 	movem.l	ll.TraceRegs,d0-d7/a0-a7	; recover saved regs
	rte

*****
* ShowRegs()
* Print saved registers  etc on screen...
* d0-d2/a6 corrupt
*****
ShowRegs
 	lea	ll.TraceRegs,a6			; where saved regs are

;Print data registers...
	moveq #8,d7 				; show 1st 8 (d0-d7)
	move  #2*8,d1
	move.w	#170,d2
Trace_L1
 	move.l	(a6)+,d0 			; get reg
	bsr	showd0					; display it
	add.w #10,d2				; next display pos
	subq.w	#1,d7
	bne.s Trace_L1

;Print all address registers
	move #12*8,d1
	move.w	#170,d2
	moveq #8,d7 				; show 2nd 8 (a0-a7)
Trace_L2
 	move.l	(a6)+,d0 			; get reg
	bsr	showd0					; show it
	add.w #10,d2				; next display pos
	subq.w	#1,d7
	bne.s Trace_L2

;Print traced PC
	move.l	l.TracePC,d0 		; get PC
	move.w  #22*8,d1
	move.w	#170,d2
	bsr	showd0					; show it
	add.w #10,d2				; next display pos

;Print SR...
	moveq	#0,d0
	move.w	w.TraceStat,d0 		; get SR
	add.w #10,d2
	bsr	showd0					; display it

	rts

*****
* InitKeys
* Initialise keyboard routine!
*****
InitKeys
	MOVE.W	#PORTS,CUSTOM+intena
	MOVE.L	#KeybInterrupt,$68.W
	MOVE.B	#$77,CIAAICR
	MOVE.B	#$88,CIAAICR
	MOVE.W	#PORTS,CUSTOM+intreq
	MOVE.W	#SETIT!PORTS,CUSTOM+intena
	RTS	

KeybInterrupt
	MOVEM.L	D0/A0,-(SP)
	LEA CIAAPRA,A0
	MOVE.B	CIAICR(A0),D0
	BTST	#3,D0					;Keyboard ?
	BEQ.S	Keyb_rt

	MOVE.B	CIASDR(A0),D0			;SDATA
	BSET	#6,CIACRA(A0)			;(SPMODE)

	MOVE.B	#8,CIACRA(A0)			;(RUNMODE) ONESHOT
	MOVE.B	#25,CIATALO(A0)			; Wait for 75 micros.
	MOVE.B	#2,CIATAHI(A0)

	MOVE.B	#$81,CIAICR(A0)			;SETCLR!TA
	MOVE.B	#8,CIAICR(A0)			;SP

	NOT.B	D0						;PROCESS DATA
	LEA	KeyMap(PC),A0
	LSR.B	#1,D0
	BCS.S	ReleaseKey
	AND.W	#$7F,D0
	MOVE.B	#-1,(A0,D0.W)
	MOVE.B	D0,b.ordkey

KeyDone
	MOVE.W	#PORTS,CUSTOM+intreq
	MOVEM.L	(SP)+,D0/A0
	RTE	
 
ReleaseKey	AND.W	#$7F,D0
	CLR.B	(A0,D0.W)
	BRA.S	KeyDone

Keyb_rt
	BTST	#0,D0					; Timer ?
	BEQ.S	Keydone					; Nope...

	BCLR	#6,CIACRA(A0)			; Complete handshake... (SP MODE)
	MOVE.B	#1,CIAICR(A0)			; TA
	MOVE.B	#$88,CIAICR(A0)			; SETCLR!SP
	BRA.S	Keydone

KeyMap	ds.b	$7f					; Offset as keycode = -1 when pressed
b.ordkey	ds.b	1

*****
* Int3_Handler()
* Handle Level 3 Interrupt
*****
Int3_Handler
	movem.l	d0-d7/a0-a6,-(sp) 		;save these
;	move.w	#$2300,SR				; prevent interrupt nesting
	lea	custom,a6
	lea	myvars,a5
	move.w	INTREQR(a6),d0 			; check which int occurred

	moveq	#0,d7					; return code

;	move.w	d0,INTREQ(a6)			; and tell 4703 about it

	btst	#6,d0 					; Blitter?
	beq.s Int3_1					; no
	addq.l	#1,l.BlitCounter(a5)	; add to blitter counter
	or.w	#BLIT,D7
Int3_1
	btst	#5,d0 					; VBL?
	beq.s Int3_2					; no
	addq.l	#1,l.VBLCounter(a5)		; add to VBL counter
	or.w	#VERTB,d7
Int3_2
	btst	#4,d0 					; Copper?
	beq.s Int3_3					; no
	addq.l	#1,l.CopCounter(a5)		; add to Copper counter
	IFND	SYSTEM
	tst.b	b.vbsig(a5)
	beq.s	novb
	bsr	swapcop
	clr.b	b.vbsig(a5)
novb
	ENDC

	IFD	SMPI
	BSR	SMPIVBI
	ENDC
	or.w	#COPER,d7
Int3_3
	move.w	d7,INTREQ(A6)
	movem.l	(sp)+,d0-d7/a0-a6
	rte

*****
* InitMulTab()
*****
InitMulTab
	MOVEQ	#0,D1
	MOVE.W  #PLWIDB*NPL,D3
	MOVE.W  #PLHGT-1,D4
	LEa lw.plmultab(a5),a1
IMT_lp
	move.l d1,(a1)+
	add.w d3,d1
	dbra d4,imt_lp
	rts

*****
* WaitVBL()
* Wait for VBL to pass by
* INT CODE MUST BE RUNNING!
*****
WaitVBL
	IFND	SYSTEM
	move.w	d0,-(a7)
	move.w	l.VBLCounter+2(a5),d0
WaitVBL_1
	cmp.w l.VBLCounter+2(a5),d0
	beq.s WaitVBL_1
	move.w (a7)+,d0
	ENDC
	IFD SYSTEM
	CATCHPOS	A6,200
	ENDC
	rts

*****
* showd0 ( LONGWORD X Y) (d0,d1,d2)
* Print d0 HEX to showpl.
* At: d1 = x pos d2 = y pos >>>PIXELS<<<
* All regs preserved
*****
Showd0
	move.l a0,-(a7)
;convert no....
	lea showd0.dec(pc),a0
	bsr GetHexadecimall
;save texthandler font/x/y/screen/col etc
	bsr TH_SaveVars
;set according to d1-d2 + screen1 + font0 + wipe mode
	lea Thvars(pc),a0
	move.w d1,w.xpos(a0)
	move.w d2,w.ypos(a0)
;print in showpl
	lea showd0.txt(pc),a0
	bsr HandleText
	bsr TH_Recovars
	move.l (a7)+,a0
	rts
showd0.txt
	dc.b '\s1\f0\mw\jl\c1\t'	;show plane,font 0 (always 8*8*1)
								;wipe mode,left just,colour 1
Showd0.dec	dc.b '00000000\q'	; Hex no from convert routine
	even

*****
*InitBob(Ptr)(a0)
*Initialise a bob
*****
InitBob
	PUSH	A0/D0
	cmp.l	#'BOB0',B_ID(a0)
	bne.s	InitBob_error
	tst.b	B_InitSig(a0)			; Init already ?
	bne.s	InitBob_Done
	move.l	a0,d0
	add.l	d0,B_BMap(a0)			; Relocate bob struct
	tst.l	B_Mask(a0)
	Beq.s	InitBob_NoMask
	add.l	d0,B_Mask(a0)
InitBob_NoMask

	cmp.b	#1,B_Options(a0)		; Need to calc mask ?
	bne.s	InitBob_maskok
	bsr.s	MakeBobMask
	move.b	#0,B_Options(a0)		; Now have a mask
InitBob_maskok
	move.w	#Plwidb,d0
	sub.w	B_WWid(a0),d0
	sub.w	B_WWid(a0),d0
	move.w	d0,B_CMod(a0)			; Save standard modulo...
	move.w	B_SMod(a0),B_CRMod(a0)	; Reset modulo for COOKIES!
	subq.w	#2,B_CRMod(a0)
	move.w	B_Hgt(a0),d0			; Calc bsize...
	mulu	#64*npl,d0				; BHGT
	add.w	B_Wwid(a0),d0
	move.w	d0,B_CBSize(a0)
	st	b_initsig(a0)
InitBob_done
	POP	A0/D0
	rts

Initbob_error
	lea IB.err.txt(pc),a0
	bra _Error
IB.err.txt	dc.b	'INITBOB ERROR : Non ''BOB0'' structure',0
	even
*****
*MakeBobmask(ptr) (a0)
*Calc mask for bob
*****
MakeBobMask
	movem.l	a1/a2/d0-d5,-(a7)
	move.w  B_Wwid(a0),d0
	add.w	d0,d0		
	subq.w  #2,d0
	add.w	B_Smod(a0),d0			; d0= width,bytes of *1 plane*

	move.w	d0,d1
	mulu	#npl-1,d1				; d1=modulo for each plane of mask
	move.l	B_BMap(a0),a1			; Source
	move.l	B_Mask(a0),a2			; Dest

	move.w	B_Hgt(a0),d5
	subq.w	#1,d5
MBM_hgtlp
	move.w	d0,d2					; Do a line of mask...
	subq.w	#1,d2
MBM_widlp
	moveq	#0,d3
	moveq	#0,d4					; Offset count
	rept	npl
	or.b	(a1,d4.w),d3			; add to set bits
	add.w	d0,d4					; next plane
	endr
	moveq	#0,d4					; Offset count
	rept	npl
	move.b	d3,(a2,d4.w)
	add.w	d0,d4
	endr
	addq.l	#1,a1
	addq.l	#1,a2
	dbra	d2,MBM_widlp
	lea	(a1,d1.w),a1
	lea	(a2,d1.w),a2
	dbra	d5,MBM_hgtlp
	movem.l	(a7)+,a1/a2/d0-d5

	rts

*****
*DoBob(Ptr,Screen,Save,x,y,offset)(a0 a1 a2 d0 d1 d2)
*Save screen portion to save if a2 nz
*Blit bob at ptr to screen *no clipping*
*****
DoBob_Error
	lea Dobob.err.txt(pc),a0
	BRA _Error
Dobob.err.txt dc.b 'DOBOB ERROR : Attempt to process uninitialised bob!',0
	even

DoBob
	TST.B b_initsig(a0)
	Beq.s DoBob_Error
	MOVEM.L	D0-D3/A1-A3,-(A7)
	move.w	d0,d3
	lsr.w	#3,d3					; No. bytes
	lea	(a1,d3.w),a1

;	mulu	#plwidb*npl,d1			; Y offset Offset in plane
;lea etc.
	add.w d1,d1						; *4 table...
	add.w d1,d1
	add.l lw.plmultab(A5,d1.w),a1	; Dest for bob!

	and.w	#%1111,d0
	ror.w	#4,d0					; Bltcon value...

	move.l  a2,d1
;	cmp.l	#0,a2					; Saving ?
	beq.s	DoBob_NoSave

	move.l	a0,(a2)+				; Save bob struct address
	Move.l	a1,(a2)+				; Save address
	SBLITWAIT	a6					; Now do save
	Move.l	a1,bltapth(a6)
	move.l	a2,bltdpth(a6)
	move.w	B_CMod(a0),bltamod(a6)
	move.w	#0,bltdmod(a6)
	move.l	#$09f00000,bltcon0(a6)	; A>D blit
	move.l	#-1,bltafwm(a6)
	move.w	B_CBSize(a0),BltSize(a6)
DoBob_Nosave
	move.w	d0,d1
	or.w	#$0fca,d0
	move.l	B_Mask(a0),a2			; A ptr Mask data
	move.l	B_BMap(a0),a3		    ; B ptr GFX data
	lea	(a2,d2.w),a2
	lea	(a3,d2.w),a3
									; D ptr is a1
	SBLITWAIT	a6
	move.l	a2,bltapth(a6)			; Mask
	move.l	a3,bltbpth(a6)			; SRC
	move.l	a1,bltcpth(a6)			; Dest
	move.l	a1,bltdpth(a6)
	move.w	B_CRMod(a0),bltamod(a6)
	move.w	B_CRMod(a0),bltbmod(a6)
	move.w	B_CMod(a0),bltcmod(a6)
	move.w	B_CMod(a0),bltdmod(a6)
	move.w	d0,bltcon0(a6)
	move.w	d1,bltcon1(a6)
	move.l	#$ffff0000,bltafwm(a6)	; No last word!
	move.w	B_CBSize(a0),bltsize(a6)
	MOVEM.L	(SP)+,D0-D3/A1-A3
	rts

*****
*RecoBob(Save)(a2)
*Recover screen portion at save *no clipping*
*Safe: if (a2)=0 then abort!
*A0-A2 SCRUNGED
*****
RecoBob
	cmp.l	#0,a2
	beq.s	RecoBob_Abort
	SBLITWAIT	a6
	move.l	(a2),a0					; Recover save struct+addr
	clr.l	(a2)+					; Nuke for safety
	move.l	(a2)+,a1
	move.l	a1,bltdpth(a6)
	move.l	a2,bltapth(a6)
	move.l	#$09f00000,bltcon0(a6)	; A>D blit
	move.l	#-1,bltafwm(a6)
	move.w	B_CMod(a0),bltdmod(a6)
	move.w	#0,bltamod(a6)
	move.w	B_CBsize(a0),bltsize(a6)
	rts
RecoBob_Abort	
	Lea RecobobErr.txt(PC),a0
	BRA _Error
RecobobErr.txt	dc.b 'RECOVER BOB : Null Pointer passed!',0
	even


;HARD CODED IN JOY ROUTINE!!! DO NOT MODIFY!!!!
		rsreset
RIGHT	rs.b	1
LEFT	rs.b	1
DOWN	rs.b	1
UP		rs.b	1
FIRE	rs.b	1
;!!!!!
*****
* Rjoy0/1()
* Return d0=joycode
* 0 : STICK IN "MOUSE PORT" (PORT0)
* 1 : STICK IN JOY PORT (PORT 1)
*****
;	bit 0 set = right movement
;	bit 1 set = left movement
;	bit 2 set = down movemwnt
;	bit 3 set = up movement
;   bit 4 set = fire!

RJoy0	move.l #6*65536+Joy0DAT,d0	; #ciaa bit no. <<16 + hw reg
	bra.s RJoy_main
RJoy1	move.l #7*65536+Joy1DAT,d0
	
RJoy_Main	; d0 : low word = joyxdat high word = ciaapra BIT no.
	movem.l	d1/d2,-(a7)
	moveq		#0,d2
	move.w		(a6,d0),d0			; read stick
	btst		#1,d0				; right ?
	beq.s		Rjm.test_left		; if not jump!
	or.w		#1,d2				; set right bit
Rjm.test_left
	btst		#9,d0				; left ?
	beq.s		Rjm.test_updown		; if not jump
	or.w		#2,d2				; set left bit
Rjm.test_updown
	move.l		d0,d1				; copy JOY1DAT
	lsr.w		#1,d1				; shift u/d bits
	eor.w		d1,d0				; exclusive or 'em
	btst		#0,d0				; down ?
	beq.s		Rjm.test_down		; if not jump
	or.w		#4,d2				; set down bit
Rjm.test_down
	btst		#8,d0				; up ?
	beq.s		Rjm.no_joy			; if not jump
	or.w		#8,d2				; set up bit
Rjm.no_joy
	swap		d0					; Swap d0 to get test bit 
	btst		d0,ciaapra			; Fire ?
	bne.s		Rjm.no_fire	
	or.w		#16,d2
Rjm.no_fire
	move.l	d2,d0					; Longword to erase upper word
	movem.l	(a7)+,d1/d2
	rts


*****
*CopyShowToDraw
*Copies show plane to draw plane
*****
CopyShowToDraw
	PUSH A0/A1/D0
	MOVE.L p.Showpl(a5),a0
	MOVE.L p.Drawpl(a5),a1
	MOVE.L #NPL*PLWIDB*PLHGT/4,D0
CSTD_lp
	MOVE.L (A0)+,(A1)+
	SUBQ.L #1,D0
	BNE.S CSTD_lp
	POP A0/A1/D0
	RTS

*****
*Swap copper ptrs in copper list
*****
SwapCop
	MOVE.L	p.ShowPl(a5),a1
	MOVE.L	p.DrawPl(a5),a0
	MOVE.L	A0,p.Showpl(a5)
	MOVE.L	A1,p.Drawpl(a5)
	Lea	CopPls,a1
	moveq	#npl-1,d1
	moveQ	#plwidb,d2
	move.l	a0,d0
SwapCoplp
	move.w	d0,4(a1)				; Low word
	swap	d0
	move.w	d0,(a1) 				; High word
	swap	d0
	add.l 	d2,d0
	addq.l	#8,a1
	dbra	d1,SwapCoplp
	RTS

*****
* LoadCopCols()
* Copy cols into copper list
*****
LoadCopCols
	push a0/a1/d0
	Lea CopCols,a0
	MOVE.l plw.cols(a5),a1
	move.w	#Numcols-1,d0
LCC_lp
	move.w (a1)+,(a0)
	addq.l #4,a0
	dbra d0,LCC_lp
	pop	a0/a1/d0
	rts

*****
* InitSpr()
* Put in dummy sprite into copper sprite entries...
*****
InitSpr
	push a0/d0/d1
	Lea SprPtrs,a0			;0:highw,...,4:low,...,8:Highw2 etc.
	MOVE.L #DEADSPRITE,d1
	moveq #8-1,d0
IS_lp
	move.w d1,4(a0)
	swap d1
	move.w d1,(a0)
	swap d1
	addq.l #8,a0
	dbra d0,is_lp
	pop a0/d0/d1
	rts

*****
* Fade Colours into copper,d0=framing rate
*****
FadeCols
	movem.l	d1-d4/a1,-(a7)
	move.l	d0,d2
FC_olp
	Lea	CopCols,a0
	move.l	plw.Cols(a5),a1
	move.w	#Numcols-1,d4			; Counter
	moveq	#0,d3					; number of colours the same
FC_ilp
	move.w	(a0),d0					; Cur col
	move.w	(a1)+,d1
	cmp.w	d0,d1
	bne.s	FC_NSame
	addq.w	#1,d3					; add to no matches
	bra.s	Fc_nxt
FC_NSAME
	BSR.S	Fader
	move.w	d0,(a0)					; Save new colour
Fc_nxt	Addq.l	#4,a0
	Dbra	d4,FC_ilp				; Repeat for all colours
	cmp.w	#numcols,d3				; done ?
	beq.s	FC_DoneAll
	move.w	d2,d3
FC_Pauselp
	BSR	WAITVBL						; NB scrunges d0
	dbra	d3,FC_Pauselp
	BRA.S	FC_olp
FC_DoneAll
	movem.l (a7)+,d1-d4/a1
	RTS

*****
* D0 = FADER ( CUR DEST ) ( D0 D1 )
* Intelligent fade routine d0 cur col,d1 dest col returns d0=faded
*****
Fader
	CMP.W	D0,D1
	BEQ.S	FADER_DONE
	MOVEM.W D1-D6,-(SP)
	MOVE.W  D1,D2   			; d1-3 : dest values
	MOVE.W  D1,D3
	MOVE.W  D0,D4   			; d4-6 Init values
	MOVE.W  D0,D5
	MOVE.W  D0,D6
	AND.W   #$00F,D1  			; D1-3 B-G-R
	AND.W   #$0F0,D2
	AND.W   #$F00,D3
	AND.W   #$00F,D4  			; d4-6 B-G-R
	AND.W   #$0F0,D5
	AND.W   #$F00,D6
	CMP.W   D4,D1
	BCC.S   Blue_NOTdown
	SUBQ.W  #1,D4
Blue_NOTdown
	CMP.W   D4,D1
	BLS.S   Blue_Fin
	ADDQ.W  #1,D4
Blue_Fin
	CMP.W   D5,D2
	BCC.S   Green_NOTdown
	SUB.W   #$010,D5
Green_NOTdown
	CMP.W   D5,D2
	BLS.S   Green_Fin
	ADD.W   #$010,D5
Green_Fin
    CMP.W   D6,D3
	BCC.S   Red_NOTdown
	SUB.W   #$100,D6
Red_NOTdown
	CMP.W   D6,D3
	BLS.S   REd_FIn
	ADD.W   #$100,D6
REd_FIn
	MOVE.W  D4,D0   			; -> d0 is finished value...
	OR.W    D5,D0
	OR.W    D6,D0
	MOVEM.W (SP)+,D1-D6
FADER_DONE
	RTS

*****
* GETDECIMALL( BUFF LONGWORD ) ( a0 d0 )
* a0 = ASCII Output buffer 10 bytes (>decimal number in ASCII)
* d0 = Hex Longword to Convert
* All regs preserrved
*****
 
getdecimal
	movem.l	d0-d5/a0-a1,-(a7)
	move.b	#" ",d5			; replace leading zero's with spaces
	lea	hextable(pc),a1
	move.w	#8,d4
ccloop	
	move.l	(a1)+,d1
	cmp.l	d1,d0
	bcs.s	get3
 	move.w	#32-1,d3
	moveq.l	#0,d2
get1	asl.l	#1,d0
	roxl.l	#1,d2
	cmp.l	d1,d2
	bcs.s	get2
 	sub.l	d1,d2
	addq.l	#1,d0
get2	dbra	d3,get1
	add.b	#48,d0
	move.b	d0,(a0)+
	move.l	d2,d0
	move.b	#48,d5
	bra.s	get4
get3	move.b	d5,(a0)+
get4	dbra	d4,ccloop
 	add.b	#48,d0
	move.b	d0,(a0)+
	movem.l	(a7)+,d0-d5/a0-a1
	rts

hextable
	dc.l	1000000000
	dc.l	100000000
	dc.l	10000000
	dc.l	1000000
	dc.l	100000
	dc.l	10000
	dc.l	1000
	dc.l	100
	dc.l	10

*****
* GETHEXADECIMALL( BUFF LONGWORD ) ( a0 d0 )
* GETHEXADECIMALW( BUFF WORD ) ( A0 D0 )
* a0 = ASCII Output buffer 4/8 bytes (>HEX number in ASCII)
* d0 = Hex (Long-)word to Convert
* All regs preserrved
*****

;BINW->ASCIIHEXW ROUTINE: D0.W = WORD TO BE ASCIId A0=4 bytes text dest
GexHexadecimalw
	movem.l	d0-d2/a1,-(a7)
	moveq	#3,d1			; count
	addq.l	#4,a0			; end dest str
	bra.s	BinHexMain 

;BINL->ASCIIHEXL ROUTINE: D0.L = LWORD TO BE ASCIId A0=8 bytes text dest
GetHexadecimall
	movem.l	d0-d2/a1,-(a7)
	moveq	#7,d1			; count
	addq.l	#8,a0 			; end dest string
BinHexMain
	lea	hextab(pc),a1		; chr tab
BinHexlp
	move.l	d0,d2
	and.l	#15,d2			; get 4 bits
	move.b	(a1,d2),-(a0)
	lsr.l	#4,d0
	dbra	d1,BinHexlp
	movem.l	(a7)+,d0-d2/a1
	rts
hextab	dc.b	"0123456789ABCDEF"
	even

	SECTION	PKDOS_CHIPSTUFF,DATA_C
;All chip datas here!
*****
*Copper list for main program
*****
MY_Copper
	dc.w	diwstrt,$2C81,diwstop,$2CC1
	dc.w	ddfstrt,$38,ddfstop,$D0,bplcon0
	IFND	GENLOCK
	dc.w	(NPL<<12)!COLOR
	ENDC
	IFD	GENLOCK
	DC.W	(NPL<<12)!COLOR!ERSY
	ENDC
	dc.w	bplcon1,0,bplcon2,0
;PUT +2 HERE IN MODULOS FOR CLIP BORDERS...
	dc.w	bpl1mod,PLWIDB*(NPL-1),bpl2mod,PLWIDB*(NPL-1)

	dc.w	COLOR00
CopCols	dc.w	0,COLOR01,0,COLOR02,0,COLOR03,0,COLOR04,0
	DC.W	COLOR05,0,COLOR06,0,COLOR07,0,COLOR08,0	
	DC.W	COLOR09,0,COLOR10,0,COLOR11,0,COLOR12,0
	DC.W	COLOR13,0,COLOR14,0,COLOR15,0,COLOR16,0
	DC.W	COLOR17,0,COLOR18,0,COLOR19,0,COLOR20,0
	DC.W	COLOR21,0,COLOR22,0,COLOR23,0,COLOR24,0
	DC.W	COLOR25,0,COLOR26,0,COLOR27,0,COLOR28,0
	DC.W	COLOR29,0,COLOR30,0,COLOR31,0

	DC.W	SPR0PTH
SprPtrs	DC.W	0,SPR0PTL,0
	DC.W	SPR1PTH,0,SPR1PTL,0
	DC.W	SPR2PTH,0,SPR2PTL,0
	DC.W	SPR3PTH,0,SPR3PTL,0
	DC.W	SPR4PTH,0,SPR4PTL,0
	DC.W	SPR5PTH,0,SPR5PTL,0
	DC.W	SPR6PTH,0,SPR6PTL,0
	DC.W	SPR7PTH,0,SPR7PTL,0

	DC.W	BPL1PTH
CopPls	DC.W	0,BPL1PTL,0,BPL2PTH,0,BPL2PTL,0
	DC.W	BPL3PTH,0,BPL3PTL,0,BPL4PTH,0,BPL4PTL,0
	DC.W	BPL5PTH,0,BPL5PTL,0
	DC.W	$FFDF,$FFFE
;Trigger copper interrupt at boottom of display screen
	DC.W	$2C09,$FFFE,INTREQ,SETIT!COPER	
	DC.W	$FFFF,$FFFE

	IFD	SMPI
BLANKSAMPLE	DS.W	2				; 0 sample for PLAYSND
	ENDC

DEADSPRITE  DS.L	1


SpinBlocks_Bobs				; 32 pixels height:full>blank over 9 frames total!
	dc.l	'BOB0'
	dc.b	0,0
	dc.w	2+1,32,(9-1)*4
	dc.l	SpinBlocksBMap-SpinBlocks_Bobs,SpinBlocksMask-SpinBlocks_Bobs
	ds.w	5
	dc.l	0
SpinBlocksBMAP	incbin	Source:P.Kent/gfx/Spinblocks.irawc
lw.dispfxcols = *-32*2
SpinBlocksmask
	rept	32
	dcb.l 9*3,-1
	dcb.l 9*2,0
	endr

	SECTION	PKDOS_VIEWS,BSS_C

SCREEN1			ds.b	pllen*npl			; Screens...
SCREEN2			ds.b	pllen*npl

	SECTION	PKDOS_DATA,DATA
*****
*Static data
*****

lw.BlackCols	ds.w	numcols		; List of blacks...
lw.WhiteCols	dc.w	0
				dcb.w	numcols-1,$fff
ll.TraceRegs	dc.l	0,0,0,0,0,0,0,0
				dc.l	0,0,0,0,0,0,0,0
l.TracePC		dc.l	0
w.TraceStat		dc.w	0

LP.SCREENS
	DC.L SCREEND-LP.SCREENS
	DC.L SCREENS-LP.SCREENS,0	
SCREEND								;Draw screen
	DC.L	'SCN0'
	DC.W PLWIDB,NPL,NPL*PLWIDB,PLHGT
	MOVE.L P.DRAWPL(A5),A3
	RTS
SCREENS								;Show screen
	DC.L	'SCN0'
	DC.W PLWIDB,NPL,NPL*PLWIDB,PLHGT
	MOVE.L P.SHOWPL(A5),A3
	RTS

LP.FONTS DC.L FONT0-LP.FONTS,CFONT0-LP.FONTS,0
FONT0	DC.L 'FNT0'
		DC.W	1,8,1,8
		INCBIN 	Source:P.Kent/GFX/METALLION10.8
		EVEN
CFONT0	DC.L 'FNT0'
		DC.W	2,16,3,3*2*16
		INCBIN	Source:P.Kent/GFX/GREYFONT.16*16*3.BLOCK
		EVEN
LW.CFONTCOLS
		dc.w	$000,$dcc,$baa,$a9a,$877,$766,$544,$000
		dc.w	$fff,$cdc,$aba,$9a9,$787,$676,$454,$000
		dc.w	$000,$ccd,$aab,$99a,$778,$667,$445,$000
		dc.w	$000,$ddc,$bba,$aa9,$887,$776,$554,$000


MEMINFO DC.L 'RAMC',CHIPLIST,$400*CHIPK	;Chip ram : must be 1st in list!
		DC.L 'RAMS',SLOWLIST,$400*SLOWK	;Slow fast ram
		DC.L 'RAMF',FASTLIST,$400*FASTK	;True fast ram...
		DC.L 0

;Simulate CHIP ram...
	SECTION MEM,BSS_C
CHIPLIST	DS.B $400*ChipK
;Simulate 'slow' FAST ram $c00000+ (trapdoor)
	SECTION MOREMEM,BSS
SLOWLIST	DS.B $400*SlowK
;Simulate $200000+ ram (autoconfig etc)
	SECTION	AUTOMEM,BSS
FASTLIST	DS.B $400*FastK

*****
*Variable definitions
*****
			rsreset
lw.Plmultab rs.l    plhgt
p.DrawPl	rs.l	1			; Ptr to current draw plane
p.Showpl	rs.l	1			; Ptr to shown plane
plw.Cols    rs.l	1      		; Ptr to list of current colours, or target

	ifNd	SYSTEM
b.vbsig		rs.b	1
			rs.b	1
	endc

	ifnd	NODISK
			DISKVARS
	endc
	ifd	SMPI
			SMPIVARS
	endc

l.VBLCounter	rs.l	1
l.CopCounter	rs.l	1
l.BlitCounter	rs.l	1
l.CIACounter	rs.l	1
w.Tron			rs.w	1		; Trace control - on/off

myvars_len	rs.b	1	

			SECTION	MYVARS,BSS
MYVARS		DS.B	MYVARS_LEN
			EVEN
