
    OPT C-,O+,D+

****************************
*	   3 PLANE STARTUP	   *
*	  OVERSCANNED + VBI    *
****************************
*  SCREEN TYPER V3.0 DEMO  *
*ASSEMBLES WITH DEVPAC 3.01*
*      SET TABS TO 4       *
****************************
*      P.KENT 11.1.92      *
****************************

    SECTION YUMYUM,CODE_C

	INCLUDE	source:include/HARDWARE.I			; Equate & macro files
	INCLUDE	MYMACROS.I
	
	INCLUDE	HWSTART.S				; My hardware startup file

	INCLUDE	SCREENTYPER3.S		; <<<<< THIS IS IT!
	INCLUDE	FADEROUTINE.MOD ; Hmm...
	INCLUDE	STR_LEN.S			; Needed by text routine
	INCLUDE	LOADPOINTERS.S			; Insert bitplane ptrs
			
RASTERCHECK =   0   					; 1 FOR TIMING BACKGROUND, 0 BLACK.

CUSTOM	equ	$dff000

****************************
*     SCREEN SIZES         *
* SCREEN TYPER USES THESE  *
* EQUATES!! (& SO DO I!)   *
****************************
;SCREEN IS 352 ($2C WIDB), 268 HGT
NPL = 3								; NO OF PLANES *INTERLEAVED*
PLWIDW = 22							; WIDTH IN WORDS OF ONE PLANE
PLWIDB = PLWIDW*2					; BYTES WIDTH
PLHGT  = 268						; HEIGHT OF 1 PLANE
PLLEN = PLWIDB*PLHGT				; LENGTH OF ONE PLANE 


_BOOT								; Code kicks in here...
	LEA	CUSTOM,A6
	CATCHVB	A6	        			; Wait for VBL
	MOVE.W	#SETIT!DMAEN!BPLEN!BLTEN!COPEN,dmacon(A6)

	BSR	SetCopper					; Put in ptrs.

;Other inits...

	CATCHVB A6	
	MOVE.L	#MY_Copper,cop1lch(A6)	; Just set dma/ints and wait!
	MOVE.W	D0,COPJMP1(A6)
	MOVE.L	#MY_VBI,$6C.W
	MOVE.L	#(SETIT!INTEN!VERTB)*65536+$7FFF,intena(A6)
									; My ints + zap intreq!

;Put down text using linked text function...
	LEA	TS1(PC),A0
	BSR	DOTXTSTRUCT

;Can also put down text in lines with no formatting...
;	Lea	Text(pc),a0
;	Lea	FontC(pc),a1
;	moveq	#2,d1		; XPos
;	MOVE	#250,D2		; YPos
;	BSR	PRINTLINE

;Fade in copper list...
	MOVEQ	#8,D0		; 8 colours
	MOVEQ	#2,D1		; Speed
	MOVEQ	#1,D2		; IN
	LEA	COLPTR1(PC),A0
	LEA	FONTCCOLS(PC),A1
	BSR	FADE
INLP	CATCHVB	A6
	TST.L	D0
	BEQ.S	INLP_FIN
	BSR	FADE
	BRA.S	INLP
INLP_FIN
			
; Run to button
.LP	MOUSE	.LP

;Fade out copper list...
	MOVEQ	#8,D0		; 8 colours
	MOVEQ	#2,D1		; Speed
	MOVEQ	#0,D2		; OUT
	LEA	COLPTR1(PC),A0
	LEA	FADECOLS(PC),A1
	BSR	FADE
OUTLP	CATCHVB	A6
	TST.L	D0
	BEQ.S	OUTLP_FIN
	BSR	FADE
	BRA.S	OUTLP
OUTLP_FIN

;Au revoir.
	RTS	

MY_VBI
	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	CUSTOM,A6
    IFNE    RASTERCHECK
    MOVE.W  #$300,$180(A6)
    ENDC

;Int code here...

;

    IFNE    RASTERCHECK
    MOVE.W  #0,$180(A6)
    ENDC

	MOVE.W	#INTEN!VERTB,intreq(A6)
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTE	

SetCopper							; Set up loadpointers for my bitplane...
	Lea	Screen,a0
	Lea	Plptr1(pc),a1
	moveq	#npl,d1
	move.w	#plwidb,d2
	BSR	LoadPointers
	rts

MY_Copper
	dc.w	diwstrt,$2A71,diwstop,$36D1
	dc.w	ddfstrt,$30,ddfstop,$D8
	dc.w	bplcon0,$3200
	dc.w	bplcon1,0,bplcon2,0
	dc.w	bpl1mod,PLWIDB*(NPL-1),bpl2mod,PLWIDB*(NPL-1)

COLPTR1
    IFEQ    RASTERCHECK
	dc.w	COLOR00
    ENDC
	IFNE	RASTERCHECK
	dc.w	COLOR01
	ENDC
	dc.w	0,COLOR01,$0,COLOR02,0,COLOR03,0,COLOR04,0
	DC.W	COLOR05,0,COLOR06,0,COLOR07,0,COLOR08,0	
	dc.w	bpl1pth
Plptr1	dc.w	0,bpl1ptl,0
	dc.w	bpl2pth,0,bpl2ptl,0
	dc.w	bpl3pth,0,bpl3ptl,0
	dc.w	$FFFF,$FFFE

;Page of text, various fonts...:
;MESSY. Maybe I will code those paging routines.
;Maybe I should allow use of control codes to manipulate text ?

;Usage: _TEXT next,x,y,justify(LRC),fontname,text

TS1 _TEXT TS2,0,22,'C',FontC,<'*** TEXTER 3 ***'>	
TS2	_TEXT TS3,0,40,'C',FontB,<'CREDITS'>
TS3	_TEXT TS31,0,60,'L',FontB,<'M.CROSS:'>
TS31 _TEXT TS4,0,84,'C',FontS,<'Original 16*16 code ; Text structure'>
TS4 _TEXT TS41,0,100,'L',FontB,<'P.KENT:'>
TS41 _TEXT TS5,0,124,'C',FontS,<'Any sized fonts ; Colour ; Justification'>
TS5	_TEXT	TS6,0,140,'C',FONTC,<'Hi everyone! This is just a little test of'>
TS6	_TEXT	TS7,0,152,'C',FONTC,<'my revised version of the screen typer'>
TS7	_TEXT	TS8,0,164,'C',FONTC,<'program that was featured a few months back.'>
TS8	_TEXT	TS9,0,176,'C',FONTC,<'If there is any call for them, I will code'>
TS9	_TEXT	TS10,0,188,'L',FONTC,<'the following routines:'>
TS10	_TEXT	TS12,0,200,'C',FONTS,<'vertical scrolly'>
;Dont ask where TS11 went!
TS12	_TEXT	TS13,0,212,'C',FONTS,<'horizontal scrolly'>
TS13	_TEXT	TS14,0,224,'C',FONTS,<'& maybe some paging routines'>
TS14	_TEXT	TS15,0,238,'C',FONTC,<'Signing off... P.Kent 11.1.92'>
TS15	_TEXT 0,0,250,'C',FontC,<'...one step closer...'>

;Usage: _FONT name,width bytes,height,planes,filename
;N.B.: USE NAMING CONVENTIONS LIKE	`.8` FOR 8*8 FONTS,
; AND `.8*3` FOR 8*8 3 PLANES FONTS TO AVOID HAVING TO GUESS VALUES!

	_FONT	FONTB,2,16,1,<'source:p.kent/FONTS/BROADWAY.16'>
	_FONT	FONTS,1,8,1,<'source:p.kent/FONTS/PEARL.8'>
	_FONT	FONTC,1,8,3,<'source:p.kent/FONTS/BARS.8*3'>
FONTCCols	include	source:p.kent/fonts/bars.8*3.cols
FADECOLS	DS.W	8				;8 cols to fade out		

    SECTION	VIEWME,BSS_C

SCREEN      DS.B	NPL*PLLEN		;View planes

