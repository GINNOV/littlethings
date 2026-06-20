*************************************************************************
*			  uTiLiTy bOoT				v1.0	*
*-----------------------------------------------------------------------*
* -> FastVBR (only if 68010+ and FAST ram found)			*
* -> Mouse Acceleration 						*
* -> AmigaDOS PAL window (for PAL users like me)			*
*									*
* 	>>> Very useful (I think) for floppy only Amigas! <<<		*
*-----------------------------------------------------------------------*
*			-oOo- Instructions -oOo-			*
*-----------------------------------------------------------------------*
* - Hold LEFT mousebut. during boot to disable Mouse Accel. feature	*
* - Hold RIGHT mousebut. during boot to disable	PAL Window feature	*
* - Press LEFT ALT+LEFT AMIGA+F1 .. F8 keys to set Mouse Accel. Factor	*
*   anytime after the system has booted. (I know, it may conflict	*
*   with other Hotkeys. But you can change this here.)			*
*-----------------------------------------------------------------------*
* Assembled using Asm-One 1.20						*
* (Trash'm-one 1.6 won't accept 68010+ opcodes)				*
* Should work with all Kickstarts. Tested under 1.3, 2.04 and 3.1	*
* on my good old A500 (68010, 4meg FAST, 1meg CHIP, 1.5 fake FAST)	*
*-----------------------------------------------------------------------*
* Coded by:			Frédéric BASSALER			*
*				La Serre				*
*				19500 Collonges				*
*				France					*
*									*
*				fbas@club-internet.fr			*
*									*
* Send remarks, suggestions, flames, hellos, donations(?!)		*
*************************************************************************

	Incdir	ASM:/Include/
	Include equ.s
	include exec/types.i
	include exec/interrupts.i
	include intuition/intuition.i

Width		=	320	;screen with
Height		=	256	;screen height
BytesPerRow	=	Width/8

	rsreset
handler 	rs.l	1
handlercode	rs.l	1
newvector	rs.l	1
olddma		rs.w	1
inputio 	rs.b	48
msgport		rs.b	34
planes		rs.b	(BytesPerRow*Height)
mycop		rs.b	64	;large enough to contain the coplist data
VARSIZE 	rs.w	0


DEFXFACT	=	8	;default mouse acceleration factor
DLAY		=	100	;delay value in 1/50 secs

;DBUG=0 ;enable it for debugging

******** Bootblock data
Start:
	IFND	DBUG
	dc.b	"DOS"		;disk type: DOS
	dc.b	0		;0 is OFS, 1 is FFS (OS 2+ only)
	dc.l	0		;checksum
	dc.l	$370		;root block ($370 = 880)
	ENDC

******** Our bootcode starts here
Main:
	movem.l d0-a6,-(sp)

	IFD	DBUG
	move.l	4.w,a6
	ENDC

; transfer the Vector Base Register (VBR) to FAST ram to speed up the system!
; will only work with MC68010+ processors and if you have some (real) FAST ram

;this routine was inspired by Frank Wille's Vbr.s (PhxAss package)

FastVBR:
;test if we have a 68010 or higher
	btst	#0,296+1(a6)		;execbase->AttnFlags
	beq.s	.I_only_found_a_68000

;	move.l	#$400,d0	;VBR_SIZE=$400 (1024 bytes)
	moveq	#$40,d0		;this two lines are equivalent to
	lsl	#4,d0		;'move.l #$400,d0', but they save 2 bytes!

	moveq	#4!1,d1		;memf_fast!memf_public
	jsr	AllocMem(a6)
	tst.l	d0
	beq.s	.no_fast
	move.l	d0,a3
	move.l	a3,a4

	suba.l	a0,a0
	move	#($400/4)-1,d0
.cop	move.l	(a0)+,(a3)+
	dbf	d0,.cop

	lea	put_vbr(pc),a5
	jsr	-30(a6)		;Supervisor()

	cmp	#36,20(a6)	;test execbase version
	blt.s	.old_OS
	jsr	CacheClearU(a6)	;only under OS 2.0+
.old_OS
.no_fast
.I_only_found_a_68000


; alloc memory for global vars
	move.l	#VARSIZE,d0
	move.l	#$10002,d1	;chip!clear (the copperlist must be in CHIP)
	jsr	AllocMem(a6)
	move.l	d0,a5
; alloc buffer for the new input-handler structure
	IFND	DBUG
	moveq	#IS_SIZE,d0
;	move.l	#$10000,d1
	moveq	#1,d1		;this two lines equal to 'move.l #$10000,d1'
	swap	d1		;but the produced code is smaller!
	jsr	AllocMem(a6)
	move.l	d0,handler(a5)
; alloc buffer for the input-handler code (is_code)
	moveq	#codesize,d0
	moveq	#$1,d1		;MEMF_PUBLIC
	jsr	AllocMem(a6)
	move.l	d0,handlercode(a5)
	ENDC

******** copy RAW gfx data into bitplane
X=100	;x coordinates of picture to appear
Y=100	;y coords.

	lea	[planes+(Y*BytesPerRow)+(X/8)](a5),a2	;bitplane addr
	lea	rawgfx(pc),a0	;source: raw gfx data
	moveq	#5-1,d7 	;# lines
.cop0
	move.l	a2,a1
	moveq	#14-1,d0	;# bytes per line = datasize/# lines
.cop	move.b	(a0)+,(a1)+
	dbf	d0,.cop
	lea	BytesPerRow(a2),a2	;next line
	dbf	d7,.cop0

	lea	$dff000,a4
	move	2(a4),olddma(a5)	;save old dma
	or	#$8400,olddma(a5)
	move	#$7fff,$96(a4)		;dma off
	lea	coplist(pc),a1
; set bitplane address in copperlist
	lea	planes(a5),a2
	move.l	a2,d0
	move	d0,lo1-coplist(a1)
	swap	d0
	move	d0,hi1-coplist(a1)
; copy copperlist into (CHIP MEM) buffer
	lea	mycop(a5),a2
	move.l	a2,$80(a4)	;new coplist adr

	moveq	#(copsize/4)-1,d0
.copy	move.l	(a1)+,(a2)+
	dbf	d0,.copy

	clr	$88(a4) 	;start new coplist
	move	#%1000001111000000,$96(a4)	;new dma
; put 1 here ----------^ (instead of 0) if you want the BLITTER_NASTY feature

******** Wait for some delay... so we can see the little logo!
	IFD	DBUG
.wd	btst	#6,$bfe001	;test left mouse button
	bne.s	.wd
	bra	closeall
	ELSE

;	move.l	4.w,a6
	move.l	$9c(a6),a6	;GfxBase in A6 (little hack!)
				;seems to work with all kickstarts!
	moveq	#DLAY,d7	;number of 1/50 secs to wait for
.wait	jsr	WaitTOF(a6)	;wait VBL
	dbf	d7,.wait
	ENDC

******* Hold left mousebutton while booting to disable Mouse Acceleration
	btst	#6,$bfe001	;test left mouse button
	beq.s	PAL_Win

******* Create a new message port and open input.device
	lea	msgport(a5),a1
	move.l	a1,d7
	move.l	4.w,a6			;execbase in A6
	move.l	276(a6),$10(a1) 	;execbase->ThisTask
	jsr	AddPort(a6)
OpenDev:
	lea	inputio(a5),a1		;struct iostreq
	move.l	d7,14(a1)		;msg port
	moveq	#0,d0			;unit=0
	moveq	#0,d1			;no flags
	lea	inputname(pc),a0	;device name
	jsr	OpenDevice(a6)

******** set up the new input-handler
AddInputHandler:
	move.l	handler(a5),a0
;	move.b	#2,LN_TYPE(a0)	;type: interrupt
;	move.b	#51,LN_PRI(a0)	;handler priority
	move	#$0233,LN_TYPE(a0)	;optimization!
	move.l	handlercode(a5),a1
	move.l	a1,IS_CODE(a0)

; copy the input-handler's code to public memory
	lea	NewHandlerCode(pc),a2
	moveq	#codesize-1,d0
.copy	move.b	(a2)+,(a1)+
	dbf	d0,.copy

; add out new input-handler to the list
	lea	inputio(a5),a1
	move	#9,28(a1)	;IND_ADDHANDLER
	move.l	a0,40(a1)	;io_data: Handler addr
	jsr	DoIO(a6)

; close input.device
.closedev
	lea	inputio(a5),a1
	move.l	14(a1),-(sp)
	jsr	CloseDevice(a6)
	move.l	(sp)+,a1
	jsr	RemPort(a6)

******** Hold right mousebutton while booting to disable PAL Window
PAL_Win:
	move	$dff016,d0
	btst	#10,d0	   ;test right mouse button
	beq.s	CloseAll

******** Patch OpenWindow() or OpenWindowTagList() (when OS 2.0+)
; with a new code which will set the initial CLI window
; with a PAL (256 pixels) Height
Init_PAL_Window:
	moveq	#codesize2,d0
	moveq	#1,d1
	move.l	4.w,a6
	jsr	AllocMem(a6)
	move.l	d0,newvector(a5)
	beq.s	.end

	lea	intname(pc),a1
	jsr	OldOpenLibrary(a6)
	move.l	d0,d7
;	beq.s	.end
	move.l	d0,a1
	move	#OpenWindowTagList,a0
	cmp	#36,20(a1)	;LIB_VERSION OS 2.0+ ?
	bge.s	.v
	move	#OpenWindow,a0	;if not, we patch OpenWindow()
.v
	lea	vector(pc),a2
	move	a0,(a2)
	move.l	newvector(a5),d0
	jsr	SetFunction(a6)
	lea	oldvector(pc),a0
	move.l	d0,(a0)

	lea	New.Open(pc),a0
	move.l	newvector(a5),a1
	moveq	#codesize2-1,d0
.cop	move.b	(a0)+,(a1)+
	dbf	d0,.cop

	move.l	d7,a1
	jsr	CloseLibrary(a6)
.end

******** Close, free & restore all
CloseAll:
	move.l	a5,a1
	move.l	#VARSIZE,d0
	move.l	4.w,a6
	jsr	FreeMem(a6)

Restore:
	move.l	$9c(a6),a0	;execbase->gfxbase
	move.l	38(a0),$80(a4)	;restore system coplist
	clr	$88(a4) 	;restart system coplist
	move	olddma(a5),$96(a4)	;restore DMA

	movem.l (sp)+,d0-a6

******** Boot up system
Init:
	IFND	DBUG
	lea	dosname(pc),a1
	move.l	#'dos.',(a1)	;the address of 'dosname' MUST be EVEN !
	jsr	FindResident(a6)
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	ENDC
	rts

put_vbr:
	movec	a4,VBR		;put the new vbr address
	rte

******** Input-Handler's Code
; featuring: Mouse Acceleration

LSHIFT=1
RSHIFT=2
CONTROL=8
LALT=$10
RALT=$20
LCOMMAND=$40	;the left Amiga key
RCOMMAND=$80	;the right one...

NewHandlerCode:
	movem.l d0-a6,-(sp)
	move.b	4(a0),d2	;ie_class
	cmp.b	#2,d2		;rawmouse?
	beq.b	.mousemov
	cmp.b	#1,d2		;rawkey?
	bne.b	.no
.key
	moveq	#0,d0
	movem	6(a0),d0-d1	;ie_code, ie_qualifier

* Change here the 'HOTKEY' combination if you need it
	cmp.b	#LALT!LCOMMAND,d1

	bne.b	.no
	sub.b	#$50,d0		;RAWKEY value for F1 key = $50
	bcs.b	.no
	cmp.b	#9,d0		;F8 is $58
	bhi.b	.no
	lea	xfact(pc),a1
	move	d0,(a1) 	;save new acceleration factor
	bra.b	.no
.mousemov
	movem	10(a0),d0-d1	;deltaX, deltaY

; roll faster, little mouse!
	move	xfact(pc),d7	;accel. factor
	muls	d7,d0
	muls	d7,d1
	movem	d0-d1,10(a0)	;save new values
.no
	movem.l (sp)+,d0-a6
	move.l	a0,d0		;inputevent en d0
	rts

xfact	dc.w	DEFXFACT	;contains the accel. factor

NewHandlerEnd:
codesize=NewHandlerEnd-NewHandlerCode

******** The 'new' OpenWindow() function
New.Open:
	cmp	#256,nw_Height(a0)
	bge.s	.already_max_height
	move	#256,nw_Height(a0)	;set new window Height
.already_max_height
;	or.l	#$200,nw_IDCMPFlags(a0)	;set some new flags
;	or.l	#8,nw_Flags(a0)

	pea	new.title(pc)		;pointer to new window title
	move.l	(sp)+,nw_Title(a0)	;set window title
; The window structure has now been patched,
; we can restore the old function vector
	movem.l d0-a6,-(sp)
	move.l	a6,a1
	move.l	4.w,a6
	move	vector(pc),a0
	move.l	oldvector(pc),d0
	jsr	SetFunction(a6)
	movem.l (sp)+,d0-a6

.jmp	dc.w	$4ef9	;hex equivalent for a 'jmp' instruction...

oldvector	dc.l	0	;... to the old function address
vector	   	dc.w	0

new.title:	dc.b "AmigaDOS - UtilBoot 1.0 © Frédéric BASSALER",0
codesize2=*-New.Open

	even
******** This is the copperlist, which has to be copied into CHIP memory
LORES=%0001001000000000
HIRES=LORES!$8000
LACE=4

RES=LORES	;this is the resolution (LORES or HIRES), LACEd or not

coplist:
 DC.w $0100,RES
 dc.w $0102,$0000
 dc.w $0108,$0000
 dc.w $008E,$2981
 DC.w $0090,$29c1
 IF RES=LORES
 dc.w $0092,$0038
 DC.w $0094,$00d0
 ELSE
 dc.w $0092,$003c
 dc.w $0094,$00d4
 ENDC
 dc.w $00e0		;ptr to bitplane
hi1:dc.w 0
 dc.w $00e2
lo1:dc.w 0
 dc.w $0180,$777	;background color
 dc.w $0182,$fff	;foreground (pen) color
 dc.w $FFFF,$FFFE	;end of coplist
copsize=*-coplist

******** RAW gfx data
; first drawn using dpaint, then converted to raw data
rawgfx:
	DC.B	$04,$58,$40,$00,$84,$20,$7C,$0E
	DC.B	$71,$8C,$CC,$87,$70,$00,$9F,$08
	DC.B	$71,$8C,$EC,$50,$9A,$10,$08,$51
	DC.B	$02,$88,$08,$00,$94,$4B,$4A,$52
	DC.B	$84,$50,$A2,$1C,$73,$C8,$9E,$8E
	DC.B	$70,$00,$94,$48,$4A,$52,$84,$50
	DC.B	$9A,$10,$4A,$44,$52,$88,$48,$00
	DC.B	$64,$5C,$71,$8C,$85,$20,$7C,$11
	DC.B	$72,$59,$92,$67,$48,0
rawsize=*-rawgfx

	even
intname 	dc.b "intuit"
dosname 	dc.b "ion.library",0    ;a little trick: how to save 6 bytes!!
inputname	dc.b "input.device",0

; Let's put some info text, so that everybody can see that
; this wonderful bootblock ain't another fuckin' virus !!!

 dc.b "<LMB> TO DISABLE MOUSE_ACCEL, <RMB> TO DISABLE PAL_WINDOW"
 dc.b " HOTKEY: LALT+LCOMMAND+F1..F8 TO CONTROL ACCEL_FACTOR"

End:

Size=*-Start

	IF	Size>1024
	FAIL	Bootblock too big!
	ENDC

	dcb.b	1024-Size,0       ;fill the remainder of bootblock with 0's
