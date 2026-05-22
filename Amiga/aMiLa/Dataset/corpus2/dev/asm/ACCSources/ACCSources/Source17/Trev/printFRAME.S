0	SECTION LOWMEM,CODE_C	;Use Chip Memory only
 	OPT	C-,O+,A+	;No case sensitivity

****************************************************************************
*
*                   TEXT PRINTER ROUTINES+LOTS OF FONT STYLES
*                 ---------------------------------------------
*
* The main reason why I've included these text printing routine
* is for you to view the different 8*8 fonts I have put on this disk.
* I coded this routine to be as flexible as possible so it can be re-used
* Just change the name of the font to the diffent one, they range from font1
* to font 13,look in the fontdatas directory to see them all. I've included
* raw bitmapped versions of the fonts together with the iff,so you can make
* alterations using dpaint.The idea behind me sending you this is so that
* you can jazz up text screens with ease...
* 
* Had to stick my nose in and extend code to display all fonts in 1 run. MM
*
****************************************************************************

	movem.l	a0-a6/d0-d7,-(a7) ; Save all regesters
	move.l	a7,Stackpoint	  ; Save stack pointer
	bsr	kill_OS		  ; Take and Preserve system

	bsr	SetUp_Pic_Planes


;------- 

	lea	text(pc),a0	; ptr to text we want to print goes in a0
	lea	font1(pc),a3	; ptr to which font to use
	lea	screen(pc),a5	; print text to screen

	bsr	CallPrint		; call the print routine



	bsr	FadeIn
	bsr	Main
	bsr	FadeOut

;------- 
;------- 

	lea	text(pc),a0	; ptr to text we want to print goes in a0
	lea	font2(pc),a3	; ptr to which font to use
	lea	screen(pc),a5	; print text to screen

	bsr	CallPrint		; call the print routine



	bsr	FadeIn
	bsr	Main
	bsr	FadeOut

;------- 
;------- 

	lea	text(pc),a0	; ptr to text we want to print goes in a0
	lea	font3(pc),a3	; ptr to which font to use
	lea	screen(pc),a5	; print text to screen

	bsr	CallPrint		; call the print routine



	bsr	FadeIn
	bsr	Main
	bsr	FadeOut

;------- 
;------- 

	lea	text(pc),a0	; ptr to text we want to print goes in a0
	lea	font4(pc),a3	; ptr to which font to use
	lea	screen(pc),a5	; print text to screen

	bsr	CallPrint		; call the print routine



	bsr	FadeIn
	bsr	Main
	bsr	FadeOut

;------- 
;------- 

	lea	text(pc),a0	; ptr to text we want to print goes in a0
	lea	font5(pc),a3	; ptr to which font to use
	lea	screen(pc),a5	; print text to screen

	bsr	CallPrint		; call the print routine



	bsr	FadeIn
	bsr	Main
	bsr	FadeOut

;------- 
;------- 

	lea	text(pc),a0	; ptr to text we want to print goes in a0
	lea	font6(pc),a3	; ptr to which font to use
	lea	screen(pc),a5	; print text to screen

	bsr	CallPrint		; call the print routine



	bsr	FadeIn
	bsr	Main
	bsr	FadeOut

;------- 
;------- 

	lea	text(pc),a0	; ptr to text we want to print goes in a0
	lea	font7(pc),a3	; ptr to which font to use
	lea	screen(pc),a5	; print text to screen

	bsr	CallPrint		; call the print routine



	bsr	FadeIn
	bsr	Main
	bsr	FadeOut

;------- 
;------- 

	lea	text(pc),a0	; ptr to text we want to print goes in a0
	lea	font8(pc),a3	; ptr to which font to use
	lea	screen(pc),a5	; print text to screen

	bsr	CallPrint		; call the print routine



	bsr	FadeIn
	bsr	Main
	bsr	FadeOut

;------- 
;------- 

	lea	text(pc),a0	; ptr to text we want to print goes in a0
	lea	font9(pc),a3	; ptr to which font to use
	lea	screen(pc),a5	; print text to screen

	bsr	CallPrint		; call the print routine



	bsr	FadeIn
	bsr	Main
	bsr	FadeOut

;------- 
;------- 

	lea	text(pc),a0	; ptr to text we want to print goes in a0
	lea	font10(pc),a3	; ptr to which font to use
	lea	screen(pc),a5	; print text to screen

	bsr	CallPrint		; call the print routine



	bsr	FadeIn
	bsr	Main
	bsr	FadeOut

;------- 
;------- 

	lea	text(pc),a0	; ptr to text we want to print goes in a0
	lea	font11(pc),a3	; ptr to which font to use
	lea	screen(pc),a5	; print text to screen

	bsr	CallPrint		; call the print routine



	bsr	FadeIn
	bsr	Main
	bsr	FadeOut

;------- 
;------- 

	lea	text(pc),a0	; ptr to text we want to print goes in a0
	lea	font12(pc),a3	; ptr to which font to use
	lea	screen(pc),a5	; print text to screen

	bsr	CallPrint		; call the print routine



	bsr	FadeIn
	bsr	Main
	bsr	FadeOut

;------- 
;------- 

	lea	text(pc),a0	; ptr to text we want to print goes in a0
	lea	font13(pc),a3	; ptr to which font to use
	lea	screen(pc),a5	; print text to screen

	bsr	CallPrint		; call the print routine



	bsr	FadeIn
	bsr	Main
	bsr	FadeOut

;------- 

	bsr	Help_OS		  ; Restore system
	move.l	Stackpoint,a7	  ; Restore stack pointer
	movem.l	(a7)+,a0-a6/d0-d7 ; Restore all regesters
	rts			  ; Return back to CLI

****************************************************************************
*	    KILL THE OPERATING-SYSTEM AND SETUP NEW COPPERLIST	   *
****************************************************************************

Kill_OS MOVE.L	4.W,A6			        ; Get execbase
	MOVEQ.L	#0,D0			        ; Clear regester D0
	LEA	GFXlib(PC),A1		        ; Point to GFXname
	JSR	-552(A6)			; Open graphics library
	MOVE.L	D0,GFXBase    		        ; Save base addr to GFXBase
	JSR	-132(A6)			; Forbid multitasking
	MOVE.W	$DFF002.L,DMAsave	        ; Save DMA
	MOVE.W	$DFF01C.L,INTensave		; Save INTENA	
	MOVE.W	$DFF01E.L,INTrqsave		; Save INTERQ
	MOVE.W	#%0111111111111111,$DFF09A	; Switch INTENA off
	MOVE.W	#%0111111111111111,$DFF096	; Switch all DMA off
	MOVE.L	#Copperlist,$DFF080	        ; install new copperlist
	MOVE.W	$DFF088.L,D0		        ; clear second copperlist
	MOVE.W	#%1000001110100000,$DFF096      ; DMA:Cop/Bit/Sprite
	RTS				        ; return

SetUp_Pic_Planes
	MOVE.l #screen+0,D0
	MOVE.W D0,pl1l
	SWAP D0			;1ST BITPLANE
	MOVE.W D0,pl1h

	RTS

****************************************************************************
*		 MAIN LOOP					   *
****************************************************************************

Main	CMP.B   #255,$DFF006		; Vpos wait
	BNE.S    Main			; Loop


	BTST	#6,$BFE001.L		; test left mouse button
	BEQ.S	QUIT


	BNE.S	MAIN			; loop back to main

QUIT:	RTS

FADEIN	MOVEQ.W	#14,D0			;AMOUNT OF TIMES TO FADE
FADE1:	ADDI.W	#$111,COLOR01		;FADE COLOR 1 BY ADDING 
	ADDI.W	#$001,COLOR02		;FADE COLOR 2 BY ADDING
	ADDI.W	#$001,COLOR03		;FADE COLOR 3 BY ADDING
	MOVE.W	#$F000,D1		;AMOUNT OF TIME TO PAUSE 
PAUSE1:	DBF	D1,PAUSE1		;DO A PAUSE
	DBF	D0,FADE1		;FADE THE COLORS
	RTS
	

FADEOUT	MOVEQ.W	#14,D0			;AMOUNT OF TIMES TO FADE
FADE2:	SUBI.W	#$111,COLOR01		;FADE COLOR 1 BY SUBTRACTING 
	SUBI.W	#$001,COLOR02		;FADE COLOR 2 BY SUBTRACTING 
	SUBI.W	#$001,COLOR03		;FADE COLOR 3 BY SUBTRACTING 
	MOVE.W	#$F000,D1		;AMOUNT OF TIME TO PAUSE 
PAUSE2:	DBF	D1,PAUSE2		;DO A PAUSE
	DBF	D0,FADE2		;FADE THE COLORS
	RTS

****************************************************************************
* Text-2-Screen routines	    Registers effected d0-d1/a0-a5 smashed *
* ----------------------            -------------------------------------- *
*									   *
* These Paramters are required when calling the routine.		   *
*									   *
* a0 = pointer to text we want to display				   *
* a3 = font we want to display text with				   *
* a5 = output ( position to print text to in memory )			   *
*  									   *
****************************************************************************

callprint	MOVE.L	A5,A1		; print text to screen
		MOVEQ.L	#0,D0
		MOVE.B	(A0)+,D0
		MULU	#40,D0
		ADD.L	D0,A1
		MOVEQ.L	#0,D0
		MOVE.B	(A0)+,D0
		ADD.W	D0,A1
		MOVE.L	A1,A4

splitfont	MOVE.L	A3,A2		;get font selection
		MOVEQ.L	#0,D0
		MOVE.B	(A0)+,D0
		BEQ.S	callprint
		BMI.S	printdone
		SUB.B	#32,D0
		CMP.B	#39,D0
		BLE.S	locate
		ADD.L	#280,A2		;fetch fontdata nline

locate		MOVEQ.L	#7,D1
		LEA	(A2,D0.W),A2
getsize		MOVE.B	(A2),(A1)
		ADD.L	#40,A2
		ADD.L	#40,A1
		DBRA	D1,getsize
		ADDQ.L	#1,A4
		MOVE.L	A4,A1
		BRA.S	splitfont
printdone	rts

font1		incbin	"DF1:FONTDATAS/FONTDATAd.bm"
		dcb.b	40
font2		incbin	"DF1:FONTDATAS/FONTDATAc"
font3		incbin	"DF1:FONTDATAS/FONTDATAb"
font4		incbin	"DF1:FONTDATAS/FONTDATAa"
font5		incbin	"DF1:FONTDATAS/FONTDATA9"
font6		incbin	"DF1:FONTDATAS/FONTDATA8"
font7		incbin	"DF1:FONTDATAS/FONTDATA7"
font8		incbin	"DF1:FONTDATAS/FONTDATA6"
font9		incbin	"DF1:FONTDATAS/FONTDATA5"
font10		incbin	"DF1:FONTDATAS/FONTDATA4"
font11		incbin	"DF1:FONTDATAS/FONTDATA3"
font12		incbin	"DF1:FONTDATAS/FONTDATA2"
font13		incbin	"DF1:FONTDATAS/FONTDATA1"

****************************************************************************
*			 TEXT						   *
****************************************************************************

;USAGE-:	XPOS,YPOS,TEXT,ENDLINE   

TEXT:	DC.B	LINE10,04,"* HI EVERYONE I'VE ONLY SENT YOU *",ENDLINE
	DC.B	LINE12,04,"THIS TEXT ROUTINE TO SHOW YOU",ENDLINE
	DC.B	LINE14,02,"THE DIFFERENT FONTS I HAVE COLLECTED",ENDTEXT
	EVEN



****************************************************************************
*				HELP OS					   *
****************************************************************************

Help_OS:
	MOVE.W	#%0111111111111111,$DFF09A   Switch INTENA off
	MOVE.W	#%0111111111111111,$DFF096   Switch all DMA off
	MOVE.W INTensave,D7		
	BSET   #$F,D7			
	MOVE.W D7,$DFF09A		Restore INTen
	MOVE.W INTrqsave,D7		
	BSET   #$F,D7			
	MOVE.W D7,$DFF09C		Restore INTrq
	MOVE.W DMAsave,D7
	BSET   #$F,D7
	MOVE.W D7,$DFF096		Restore DMA
	MOVE.L GFXbase,A0
	MOVE.L $26(A0),$DFF080
	MOVE.L 4.W,A6
	JSR    -138(A6)			LVO Permit
	RTS

****************************************************************************
*				COPPER					   *
****************************************************************************
Copperlist
	dc.W $008e,$2c81
	dc.W $0090,$2cc1
	dc.W $0092,$0038
	dc.W $0094,$00D0
	dc.W $0100,$1200
	dc.W $0102,$0000
	dc.W $0108,$0000
	dc.W $010A,$0000	BPLINE1/2MOD
Sp_Ptr	dc.W $0120,$0002,$0122,$1000,$0124,$0002,$0126,$1000
	dc.W $0128,$0002,$012a,$1000,$012c,$0002,$012e,$1000 ;no jib
	dc.W $0130,$0002,$0132,$1000,$0134,$0002,$0136,$1000
	dc.W $0138,$0002,$013a,$1000,$013c,$0002,$013e,$1000

	dc.W $0180,$0000
	dc.W $0182
COLOR01	dc.W $0000

 	dc.W $00e0
pL1h	dc.W $0000
	dc.W $00e2
pL1l	dc.W $0000

	dc.w $2009,$fffe,$0180
color02	dc.w $0000
	dc.w $2109,$fffe,$0180,$0000

	dc.w $ffe1,$fffe

	dc.w $2009,$fffe,$0180
color03	dc.w $0000
	dc.w $2109,$fffe,$0180,$0000

	dc.W $FFFF,$FFFE

****************************************************************************
*				LABELS					   *
****************************************************************************
INTrqsave	dc.w	0
INTensave	dc.w	0
DMAsave		dc.w	0
GFXlib		DC.B	"graphics.library",0
GFXBase		DC.L	0
SYSStackPoint	DC.L	0
StackPoint	DC.L	0
Screen:		dcb.b	10280,0

****************************************************************************
*		 NEW LINE EQUATES ( EVERY NEW LINE FROM 1 TO 30 )	   *
****************************************************************************
LINE00	EQU	8*0
LINE01	EQU	8*1
LINE02	EQU	8*2
LINE03	EQU	8*3
LINE04	EQU	8*4
LINE05	EQU	8*5
LINE06	EQU	8*6
LINE07	EQU	8*7
LINE08	EQU	8*8
LINE09	EQU	8*9
LINE10	EQU	8*10

LINE11	EQU	8*11
LINE12	EQU	8*12
LINE13	EQU	8*13
LINE14	EQU	8*14
LINE15	EQU	8*15
LINE16	EQU	8*16
LINE17	EQU	8*17
LINE18	EQU	8*18
LINE19	EQU	8*19
LINE20	EQU	8*20

LINE21	EQU	8*21
LINE22	EQU	8*22
LINE23	EQU	8*23
LINE24	EQU	8*24
LINE25	EQU	8*25
LINE26	EQU	8*26
LINE27	EQU	8*27
LINE28	EQU	8*28
LINE29	EQU	8*29
LINE30	EQU	8*30

ENDLINE	EQU	0
ENDTEXT	EQU	255


