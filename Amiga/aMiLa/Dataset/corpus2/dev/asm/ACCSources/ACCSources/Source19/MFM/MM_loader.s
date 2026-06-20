
; Yo Blaine, lots of changes have been made. Your original source is in
;the source directory of this disc.



	SECTION		chipmemory,data_c	
							;BY BLAINE EVANS
							;1 ERITH WAY
							;PONTYBODKIN
							;NR MOLD
							;CLWYD
							;CH7 4TR
							;TEL O352-771673

; The following line imports labels from Play.o

		XREF		IntOn,IntOff,LoadAndPlay,AddServer

; The following line exports labels to Play.o

		XDEF		_PPBase,_GfxBase

LogoHeight			equ	92
LogoWidth			equ	40
LogoSize			equ	LogoHeight*LogoWidth

Height				equ	119
Width				equ	40
ScreenSize			equ	Height*Width

ScrollHeight			equ	45
ScrollWidth			equ	44
ScrollArea			equ	ScrollHeight*ScrollWidth

	move.l	4.w,a6			;FIND EXEC BASE
	lea	gfxlib(pc),a1		;LOAD GRAPHICS LIBRARY IN A1
	moveq	#$00,d0			;VERSION 0
	jsr	-552(a6)		;OPEN LIBRARY
	move.l	d0,_GfxBase		;STORE D0 (GFX ADDRESS )
	beq	nolib_exit		;ELSE EXIT

; DOS library no longer required, changed to powerpacker library!

	lea	ppname,a1
	move.l	#0,d0
	jsr	-552(a6)
	tst.l	d0
	beq	NoDos_exit	
	move.l	d0,_PPBase

; Use routine from Play.o to initialise an interrupt.

	jsr	IntOn			ADD CIA INTERRUPT

	bsr	Logo_address
	bsr	Foreground_address	;BRANCH TO FOREGROUND ADDRESSES
	bsr	Scroll_Address
	bsr	Build_Cop_2
	bsr	Build_Cop
	lea	$dff000,a6
	bsr	Init
	bsr	Blit_Text

	move.l	_GfxBase,a0		;LOAD ADDRESS OF GRAPHICS LIB IN A0
	move.l	50(a0),Oldcop		;STORE CURRENT COPPER,ETC TO RETRIEVE LATER
S
	move.l	#Newcop,50(a0)		;POINT TO OUR COPPERLIST

; Load in initial tune and start playing it

	lea	Music_0,a0
	jsr	LoadAndPlay		DO THE BUISNESS

; Add a few more routines to the interrupt chain, these will need to be
;optomised later.

	lea	Scroller,a0
	jsr	AddServer		add scroll text to Interrupt

; Only need to test for buttons outside of interrupt now.

wait					;WAIT LOOP

	bsr	Fire


	cmp.b	#$37,$bfec01		;QUIT LEFT ALT PRESSED
	bne.s	wait
ended					;ELSE LOOP TO WAIT

; Use routine from Play.o to remove interrupt code.

	jsr	IntOff			REMOVE CIA INTERRUPT
	move.l	_GfxBase,a0		;LOAD GRAPHICS LIB ADDRESS IN A0
	move.l	Oldcop,50(a0)		;RESTORE OLD COPPER TO RETURN TO EDITTER
nomem_exit	
	move.l	4.w,a6			;FIND EXEC BASE
	move.l	_GfxBase,a1		;LOAD GRAPHICS BASE IN A1
	jsr	-414(a6)		;CLOSE LIBRARY
NoDos_exit	
	move.l	4.w,a6			; Exec base in a6
	move.l	_PPBase,a1		; A1=Address of dos base
	jsr	-414(a6)		; Close DOS lib
nolib_exit
	rts				;RETURN TO EDITER

Logo_address
	move.l	#Logo,d0
	move.w	d0,Bpl0ptl		;LOW WORD IN BIT PLANE 0 LOW
	swap	d0				
	move.w	d0,Bpl0pth		;HIGH WORD IN BIT PLANE 0 HIGH
	swap	d0
	add.l	#LogoSize,d0
	move.w	d0,Bpl1ptl		;LOW WORD IN BIT PLANE 0 LOW
	swap	d0				
	move.w	d0,Bpl1pth		;HIGH WORD IN BIT PLANE 0 HIGH
	swap	d0
	add.l	#LogoSize,d0
	move.w	d0,Bpl2ptl		;LOW WORD IN BIT PLANE 0 LOW
	swap	d0				
	move.w	d0,Bpl2pth		;HIGH WORD IN BIT PLANE 0 HIGH
	swap	d0
	add.l	#LogoSize,d0
	move.w	d0,Bpl3ptl		;LOW WORD IN BIT PLANE 0 LOW
	swap	d0				
	move.w	d0,Bpl3pth		;HIGH WORD IN BIT PLANE 0 HIGH
	swap	d0
	rts

Foreground_address			;START OF FOREGROUND DATA
	move.l	#Foreground,d0
	move.w	d0,Bpl0ptl1		;LOW WORD IN BIT PLANE 0 LOW
	swap	d0				
	move.w	d0,Bpl0pth1		;HIGH WORD IN BIT PLANE 0 HIGH
	swap	d0
	rts
Scroll_Address
	move.l	#Scroll_Area,d0
	move.w	d0,Bpl0ptl2	;LOW WORD IN BIT PLANE 0 LOW
	swap	d0				
	move.w	d0,Bpl0pth2	;HIGH WORD IN BIT PLANE 0 HIGH
	swap	d0
	rts
Init
	move.l	#Foreground,d0
	add.l	#4*Width,d0
	move.l	d0,Text_base		; store address to start text
	move.l	#Text,a0
	move.l	a0,Text_Address		; store current character
	move.l	#Scroll_Area,d0
	add.l	#(15*ScrollWidth)+40,d0
	move.l	d0,Screen
	clr.w	Plop
	lea	Text_2,a4
	move.l	a4,Char_address_2
	rts
Build_Cop
	lea	Cop,a0			* address of copper
	move.l	#$fa01fffe,d0		* $3b31=starting position
	move.l	#$01800000,d1		* colour0 + value
	move.w	#2-1,d2		* No. of bars
BuildLoop2
	moveq.l	#48-1,d3		* Elements in 1 row
	move.l	d0,(a0)+		* place into copperlist
BuildLoop
	move.l	d1,(a0)+		* "                  "
	dbf	d3,BuildLoop		* loop no.of times across
	addi.l	#$01000000,d0		* add 1 to co-ordinates
	dbf	d2,BuildLoop2		* loop no of times down
		
	lea	Cop+4,a0		* get to colour0 
	move.w	#2-1,d1		* no of lines down
CopLoop2
	lea	Cols4,a1		* colours to put in 
	moveq.l	#48-1,d0		* no of colours across
CopLoop	move.w	(a1)+,2(a0)		* place colours in copperlist
	addq.l	#4,a0			* increment to next colour
	dbf	d0,CopLoop		* loop till done 
	addq.w	#4,a0			* to next colour 
	dbf	d1,CopLoop2
	rts

Build_Cop_2
	lea	Cop_2,a0			* address of copper
	move.l	#$8501fffe,d0		* $3b31=starting position
	move.l	#$01800000,d1		* colour0 + value
	move.w	#2-1,d2		* No. of bars
BuildLoop2.1
	moveq.l	#48-1,d3		* Elements in 1 row
	move.l	d0,(a0)+		* place into copperlist
BuildLoop2.2
	move.l	d1,(a0)+		* "                  "
	dbf	d3,BuildLoop2.2		* loop no.of times across
	addi.l	#$01000000,d0		* add 1 to co-ordinates
	dbf	d2,BuildLoop2.1		* loop no of times down
		
	lea	Cop_2+4,a0		* get to colour0 
	move.w	#2-1,d1		* no of lines down
CopLoop2.1
	lea	Cols4,a1		* colours to put in 
	moveq.l	#48-1,d0		* no of colours across
CopLoop2.2	move.w	(a1)+,2(a0)		* place colours in copperlist
	addq.l	#4,a0			* increment to next colour
	dbf	d0,CopLoop2.2		* loop till done 
	addq.w	#4,a0			* to next colour 
	dbf	d1,CopLoop2.1
	rts
Copper_Movement
	lea	Cop,a0			* copperlist
	lea	6(a0),a0		* find first color
	lea	4(a0),a1		* Next colour

	move.w	#2-1,d2		* no of times

Position
	move.w	(a0),Save		* Store first in safe place
	move.w	#48-1,d1		* no of times
Loopy	move.w	(a1),(a0)		* Second goes in first
	add.w	#4,a0			* increment to next 
	add.w	#4,a1			* "               "
	dbra	d1,Loopy		* loop
	sub.w	#8,a1			* back to last value
	move.w	Save,(a1)		* replace saves value
	add.l	#4,a0			* increment for next color
	add.l	#12,a1			* make a1 catch up and be 1 color ahead of a0
	dbra	d2,Position		* loop
	rts
Copper_Movement_2
	lea	Cop_2,a0			* copperlist
	lea	6(a0),a0		* find first color
	lea	4(a0),a1		* Next colour

	move.w	#2-1,d2			* no of times

Position_2
	move.w	(a0),Save_2		* Store first in safe place
	move.w	#48-1,d1		* no of times
Loopy_2	move.w	(a1),(a0)		* Second goes in first
	add.w	#4,a0			* increment to next 
	add.w	#4,a1			* "               "
	dbra	d1,Loopy_2		* loop
	sub.w	#8,a1			* back to last value
	move.w	Save_2,(a1)		* replace saves value
	add.l	#4,a0			* increment for next color
	add.l	#12,a1			* make a1 catch up and be 1 color ahead of a0
	dbra	d2,Position_2		* loop
	rts

Sprite0
	lea	Sprites,a0		;CONTROL WORDS
	move.l	#Sprite,d0		;ADDRESS
	move.w	d0,6(a0)		;AND UPDATE COPPER
	swap	d0
	move.w	d0,2(a0)
	swap	d0	
	move.l	#Sprite,a0		;A0=SPRITE 0 ADDRESS
	move.w	#(20)-1,d7			;NO OF SPRITES-1
Move
	addq.b	#1,1(a0)		;ADD # TO HORIZONTAL POSITIONAL BYTE
	addq.b	#2,9(a0)
	addq.b	#3,17(a0)
	add.l	#24,a0			;LOCATE NEXT PAIR OF CO-ORDINATES
	dbf	d7,Move			;DECREMENT AND BRANCH WHEN =0
	rts

; Scroller has been added to interrupt chain, so it calls a few other
;routines to make sure they execute each VBL.

Scroller	
	bsr	Copper_Movement_2
	bsr	Copper_Movement
	bsr	Sprite0
	bsr	Mouse_Test

; Enter scrolly, my pathetic attempt at a non-blitter scroller!

	bsr	scrolly
	bsr	scrolly
	subq.b	#2,scrlcount
	bne	.ok
	bsr	printchar
	move.b	#16,scrlcount
.ok	rts

printchar	move.l	msgpoint,a0
	MOVEQ.L		#0,D0
	MOVE.B		(A0),D0
	SUB.b		#' ',D0
	asl.w		#5,d0		x32
	LEA		Font1,A0
	ADDA.L		D0,A0
	moveq.l		#15,d0
	move.l		Screen,a1		bpl1,a1
nextln	move.w		(a0)+,(a1)
	lea		44(a1),a1
	dbra		d0,nextln
	addq.l		#1,msgpoint
	move.l		msgpoint,a0
	tst.b		(a0)
	bne.s		more
	move.l		#MSG,msgpoint
more	RTS

scrolly	move.l		Screen,a0
	lea		2(a0),a0
	moveq.l		#15,d1
lp1	moveq.l		#21,d0
	andi.b		#%11101111,ccr
lp2	roxl.w		-(a0)
	dbra		d0,lp2
	lea		88(a0),a0
	dbra		d1,lp1
	rts


TstBBusy	btst	#14,$dff002
	bne.s	TstBBusy
	rts
	

Fire
	Btst	#$7,$bfe001		; Fire pressed
	beq	Fired			; yes branch
	Btst	#$6,$bfe001		; Fire pressed
	beq	Fired			; yes branch
	rts				; else return

; Modified all the Yes routines to implement LoadAndPlay from Play.o

Fired
	bsr	Function_1		; branches to check each
	bsr	Function_2		; number
	bsr	Function_3
	bsr	Function_4
	bsr	Function_5
	bsr	Function_6
	bsr	Function_7
	bsr	Function_8
	rts
Function_1
	lea	Copper_Bar,a0		; 1st value in moving bar 
	cmp.b	#$89+$09,0(a0)		; check co-ordinates
	bls	Try_End			; <=co-ordinate try next co-ordinate
	rts		
Try_End
	lea	Copper_Bar,a0		; end of bar
	move.b	0(a0),d0
	add.b	#9,d0
	cmp.b	#$89+$09+$09,d0			; >=co-ordinate
	bhs	Yes_1			; yes then branch
	rts
Yes_1

	lea	Music_1,a0
	jsr	LoadAndPlay		DO THE BUISNESS
	rts

Function_2
	lea	Copper_Bar,a0		; 1st value in moving bar 
	cmp.b	#$89+$09+$09,0(a0)		; check co-ordinates
	bls	Try_End_2			; <=co-ordinate try next co-ordinate
	rts		
Try_End_2
	lea	Copper_Bar,a0		; end of bar
	move.b	0(a0),d0
	add.b	#9,d0
	cmp.b	#$89+$12+$09,d0			; >=co-ordinate
	bhs	Yes_2			; yes then branch
	rts
Yes_2
	lea	Music_2,a0
	jsr	LoadAndPlay		DO THE BUISNESS
	rts

Function_3
	lea	Copper_Bar,a0
	cmp.b	#$89+$12+$09,0(a0)
	bls	Try_End_3
	rts
Try_End_3
	lea	Copper_Bar,a0		; end of bar
	move.b	0(a0),d0
	add.b	#09,d0
	cmp.b	#$89+$1b+$09,d0			; >=co-ordinate
	bhs	Yes_3
	rts
Yes_3
	lea	Music_3,a0
	jsr	LoadAndPlay		DO THE BUISNESS
	rts

Function_4
	lea	Copper_Bar,a0
	cmp.b	#$89+$1b+$09,0(a0)
	bls	Try_End_4
	rts
Try_End_4
	lea	Copper_Bar,a0		; end of bar
	move.b	0(a0),d0
	add.b	#09,d0
	cmp.b	#$89+$24+$09,d0			; >=co-ordinate
	bhs	Yes_4
	rts
Yes_4
	lea	Music_4,a0
	jsr	LoadAndPlay		DO THE BUISNESS
	rts

Function_5
	lea	Copper_Bar,a0
	cmp.b	#$89+$24+$09,0(a0)
	bls	Try_End_5
	rts
Try_End_5
	lea	Copper_Bar,a0		; end of bar
	move.b	0(a0),d0
	add.b	#09,d0
	cmp.b	#$89+$2d+$09,d0			; >=co-ordinate
	bhs	Yes_5
	rts
Yes_5
	lea	Music_5,a0
	jsr	LoadAndPlay		DO THE BUISNESS
	rts

Function_6
	lea	Copper_Bar,a0
	cmp.b	#$89+$2d+$09,0(a0)
	bls	Try_End_6
	rts
Try_End_6
	lea	Copper_Bar,a0		; end of bar
	move.b	0(a0),d0
	add.b	#09,d0
	cmp.b	#$89+$36+$09,d0			; >=co-ordinate
	bhs	Yes_6
	rts
Yes_6
	lea	Music_6,a0
	jsr	LoadAndPlay		DO THE BUISNESS
	rts

Function_7
	lea	Copper_Bar,a0
	cmp.b	#$89+$36+$09,0(a0)
	bls	Try_End_7
	rts
Try_End_7
	lea	Copper_Bar,a0		; end of bar
	move.b	0(a0),d0
	add.b	#09,d0
	cmp.b	#$89+$3f+$09,d0			; >=co-ordinate
	bhs	Yes_7
	rts
Yes_7
	lea	Music_7,a0
	jsr	LoadAndPlay		DO THE BUISNESS
	rts

Function_8
	lea	Copper_Bar,a0
	cmp.b	#$89+$3f+$09,0(a0)
	bls	Try_End_8
	rts
Try_End_8
	lea	Copper_Bar,a0		; end of bar
	move.b	0(a0),d0
	add.b	#09,d0
	cmp.b	#$89+$48+$09,d0			; >=co-ordinate
	bhs	Yes_8
	rts
Yes_8
	lea	Music_8,a0
	jsr	LoadAndPlay		DO THE BUISNESS
	rts

Mouse_Test
	addq.b	#1,Mousecount		; test every 7th frame
	cmpi.b	#9,Mousecount
	beq	YesCheckMouse
	rts
YesCheckMouse
	move.b	#0,Mousecount
	MOVE.B	OldMouseY,D0		; Last Y
	SUB.B	$DFF00A,D0
	BEQ	NoYMov
	BMI.S	DoDown
DoUp	
	lea	Copper_Bar,a0
	cmp.b	#$89+$09,(a0)		; is it within boundaries
	bls	NoXMov
	move.b	#-9,Value
	bsr	Bar			; Up Routine Here
	BRA.S	NoYMov
DoDown	
	lea	Copper_Bar,a0
	cmp.b	#$89+$39+$09,(a0)		; boundary test
	bhs	NoYMov
	move.b	#9,Value
	bsr	Bar			; Down Routine Here
NoYMov  
	move.b	#0,Value
	MOVE.B	$DFF00A,OldMouseY	; Save Y
	MOVE.B	OldMouseX,D0		; Last X
	SUB.B	$DFF00B,D0
NoXMov	
	move.b	#0,Value
	MOVE.B	$DFF00B,OldMouseX	; Save X
	rts
Bar
	lea	Copper_Bar,a0		; address
	move.w	#11,d1			; no of lines-1
	move.b	Value,d0		; store value to be added/sub from bar
Loop_Bar
	add.b	d0,0(a0)		; add/subtract to co-ordinates
	add.w	#12,a0			; increase to next line
	dbra	d1,Loop_Bar		; loop until done
	rts

Blit_Text
	move.l	Text_base,a1		; address in a1
	move.w	#12-1,d3		; no of lines-1
Again
        moveq	#39,d1     		; no of chars per line-1
LP1      
	moveq	#0,d0			; clear d0
	move.l	Text_Address,a0		; text chars in a0
       	move.b	(a0)+,d0		; next char
	move.l	a0,Text_Address		; store value
        sub.b	#32,d0		     	; take off offset
        mulu	#8,d0		   	; to find font gfx
        lea	Font(pc),a2		; font gfx in a2
        add.l	d0,a2	         	; add offset
        moveq	#7,d2	         	; no of lines high font is
        move.l	a1,a3			; a3 now =adress
LP2      
	move.b	(a2)+,(a3)	    	;font gfx into memory
        add.l	#40,a3	        	; add 1 line across
        dbra	d2,LP2	        	; loop till 0
        addq.l	#1,a1	         	; increase address by 1 byte
        dbra	d1,LP1	        	;	
	add.l	#8*40,a1		;add offset for next line
	dbra	d3,Again		;d3=no of lines to blit
	rts
Text	     	;12345678901234567899012345678901234567890
	DC.B	"       MUSIC COMPILATION DISK 1         "
	DC.B	"    1) GAMBLER .............. MERLIN    "
	DC.B	"    2) STOCK CUBE ........... MERLIN    "
	DC.B	"    3) BIKINI ............... MERLIN    "
	DC.B	"    4) RENT ................. MERLIN    "
	DC.B	"    5) HIPHOP HOUSE ......... NAFFY     "
	DC.B	"    6) SPIRIT ITS ........... MERLIN    "
	DC.B	"    7) CONCERT .............. MERLIN    "
	DC.B	"    8) POPCORN .............. MERLIN    "
	DC.B	"                                        "
	DC.B	"        USE LEFT MOUSE TO SELECT        "
	DC.B	"            CODE BY FM AND MM           "
	even


**************************************************************
*     Font by Vandal of P.E> ************
**************************************************************	
Font	 DC.B      $00,$00,$00,$00,$00,$00,$00,$00      ;SPACE
         DC.B      $18,$18,$18,$18,$00,$18,$18,$00	;!
         DC.B      $6C,$6C,$00,$00,$00,$00,$00,$00	;"
         DC.B      $1C,$36,$7C,$78,$7C,$3E,$1C,$00	;#
         DC.B      $1C,$36,$1F,$0F,$1F,$3E,$1C,$00	;$
         DC.B      $00,$00,$00,$00,$00,$00,$00,$00      ;%
         DC.B      $00,$00,$00,$00,$00,$00,$00,$00	;&
         DC.B      $0C,$0C,$18,$00,$00,$00,$00,$00	;'
         DC.B      $18,$30,$30,$30,$30,$30,$18,$00	;(
         DC.B      $18,$0C,$0C,$0C,$0C,$0C,$18,$00	;)
         DC.B      $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	;*
         DC.B      $00,$18,$18,$7E,$7E,$18,$18,$00	;+
         DC.B      $00,$00,$00,$00,$0C,$0C,$18,$00	;,
         DC.B      $00,$00,$00,$7E,$7E,$00,$00,$00	;-
         DC.B      $00,$00,$00,$00,$00,$18,$18,$00	;.
         DC.B      $02,$06,$0C,$18,$30,$60,$C0,$00	;/
         DC.B      $7C,$C6,$CE,$DE,$F6,$E6,$7C,$00	;0
         DC.B      $38,$78,$18,$18,$18,$18,$7E,$00	;1
         DC.B      $7C,$C6,$06,$7C,$C0,$C0,$FE,$00	;2
         DC.B      $FC,$06,$06,$7C,$06,$06,$FC,$00	;3
         DC.B      $1C,$3C,$6C,$CC,$FE,$0C,$0C,$00	;4
         DC.B      $FE,$C0,$C0,$FC,$06,$06,$FC,$00	;5
         DC.B      $7E,$C0,$C0,$FC,$C6,$C6,$7C,$00	;6
         DC.B      $FE,$06,$06,$0C,$0C,$18,$18,$00	;7
         DC.B      $7C,$C6,$C6,$7C,$C6,$C6,$7C,$00	;8
         DC.B      $7C,$C6,$C6,$7E,$06,$06,$06,$00	;9
         DC.B      $00,$18,$18,$00,$00,$18,$18,$00	;:
         DC.B      $00,$18,$18,$00,$18,$18,$30,$00	;;
         DC.B      $06,$1C,$70,$E0,$70,$1C,$06,$00	;<
         DC.B      $00,$00,$00,$00,$00,$00,$00,$00	;=
         DC.B      $60,$38,$0E,$07,$0E,$38,$60,$00	;>
         DC.B      $7C,$C6,$C6,$0C,$18,$00,$18,$00	;?
         DC.B      $00,$00,$00,$00,$00,$00,$00,$00	;@
         DC.B      $7C,$C6,$C6,$FE,$C6,$C6,$C6,$00	;A
         DC.B      $FC,$C6,$C6,$FC,$C6,$C6,$FC,$00	;B
         DC.B      $7E,$C0,$C0,$C0,$C0,$C0,$7E,$00	;C
         DC.B      $FC,$C6,$C6,$C6,$C6,$C6,$FC,$00	;D
         DC.B      $7E,$C0,$C0,$FE,$C0,$C0,$7E,$00	;E
         DC.B      $7E,$C0,$C0,$FE,$C0,$C0,$C0,$00	;F
         DC.B      $7E,$C0,$C0,$DE,$C6,$C6,$7C,$00	;G
         DC.B      $C6,$C6,$C6,$FE,$C6,$C6,$C6,$00	;H
         DC.B      $7E,$18,$18,$18,$18,$18,$7E,$00	;I
         DC.B      $FE,$06,$06,$C6,$C6,$C6,$7C,$00	;J
         DC.B      $C6,$CC,$D8,$F0,$D8,$CC,$C6,$00	;K
         DC.B      $C0,$C0,$C0,$C0,$C0,$C0,$FE,$00	;L
         DC.B      $C6,$EE,$FE,$D6,$C6,$C6,$C6,$00	;M
         DC.B      $E6,$F6,$DE,$CE,$C6,$C6,$C6,$00	;N
         DC.B      $7C,$C6,$C6,$C6,$C6,$C6,$7C,$00	;O
         DC.B      $FC,$C6,$C6,$FC,$C0,$C0,$C0,$00	;P
         DC.B      $7C,$C6,$C6,$C6,$C6,$DA,$C6,$00	;Q
         DC.B      $FC,$C6,$C6,$FE,$CC,$C6,$C6,$00	;R
         DC.B      $7E,$C0,$C0,$7C,$06,$06,$FC,$00	;S
         DC.B      $7E,$18,$18,$18,$18,$18,$18,$00	;T
         DC.B      $C6,$C6,$C6,$C6,$C6,$C6,$7C,$00	;U
         DC.B      $C6,$C6,$C6,$C6,$C6,$38,$38,$00	;V
         DC.B      $C6,$C6,$C6,$D6,$FE,$EE,$C6,$00	;W
         DC.B      $C6,$6C,$38,$10,$38,$6C,$C6,$00	;X
         DC.B      $C6,$C6,$C6,$7E,$06,$06,$FC,$00	;Y
         DC.B      $FE,$0E,$1C,$38,$70,$E0,$FE,$00	;Z

	EVEN

; A couple of equates required by my scroller.

msgpoint	dc.l	MSG
scrlcount	dc.b	16
	even
	DC.L	0


MSG	DC.B	'  Yo Baby! A NON-Blitter scroller....................'
	dc.b	' Well Blaine, I know there is still a slight flicker, but who said it cant be done????'
	dc.b	" I've added a CIA interrupt replayer, replaced your blitter scroller and generally butchered your code! "
	dc.b	" Did not have time to find out what's causing the little flicker in the scroller, sorry! If you want "
	dc.b	"it fixed, write and tell me. It may be a good idea to start from scratch. Back to you -------> "
	DC.B	" PENDLE EUROPA PRESENTS A NEW COOL COMPILATION DISK. "
	DC.B	"MARK,PRESS LEFT ALT KEY TO EXIT,BLAINE "
	DC.B	" PUT TOGETHER AND SPREAD BY  M.A.N.N.Y.  "
	DC.B	"CREDITS FOR THIS COOL MENU GOTO .... "
	DC.B	"CODE BY F.M WITH FINISHING TOUCHES BY MM,  MUSIC BY 4-MAT,  GFX'S BY GRAFITTI. "
	DC.B	" CONTACT US BY WRITING TO .... "
	DC.B	" MANNY,    67 GAINSBOROUGH AVE,    BURNLEY,    LANCS,    BB11 2PD,    ENGLAND.   "
	DC.B	"GREETINGS TO ALL OUR CONTACTS AROUND THE GLOBE !!    "
	DC.B	"SPECIAL GREETINGS TO TURBO MART, STV, UPPY, BAL, T.F.B, OVERLORD, FLUXOR, BLAINE EVANS, DEVISTATOR OF E.O.C, THE DUDE, ETC  AND TO DIANE (MY LOVED ONE !!)    "
	DC.B	"..........................W.R.A.P.........................                          ",0     

	EVEN

; The scroll text font.

Font1	 
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	;" "
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0380,$07C0,$07C0,$07C0,$07C0,$0380,$0380,$0380	;"!"
	dc.w	$0100,$0100,$0000,$0380,$07C0,$07C0,$0380,$0000
	dc.w	$1E3C,$3E7C,$3E7C,$3E7C,$3060,$2040,$0000,$0000	;"""
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$3C78,$3C78,$FFFE,$FFFE,$FFFE,$FFFE,$3C78,$3C78	;"#"
	dc.w	$3C78,$FFFE,$FFFE,$FFFE,$FFFE,$3C78,$3C78,$0000
	dc.w	$0380,$3FFE,$7FFE,$FFFE,$FBBE,$FB80,$FFF8,$7FFC	;"$"
	dc.w	$3FFE,$03BE,$FBBE,$FFFE,$FFFC,$FFF8,$0380,$0000
	dc.w	$700E,$F81E,$F83E,$F87C,$70F8,$01F0,$03E0,$07C0	;"%"
	dc.w	$0F80,$1F00,$3E1C,$7C3E,$F83E,$F03E,$E01C,$0000
	dc.w	$1FC0,$3FE0,$7FF0,$78F0,$7DE0,$3BCC,$179E,$0F3E	;"&"	
	dc.w	$1EDC,$3DE8,$79F0,$F2F8,$FF7C,$FFBC,$7F1C,$0000	
	dc.w	$03C0,$07C0,$07C0,$07C0,$0600,$0400,$0000,$0000	;"'"	
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	
	dc.w	$07F8,$0FF0,$1FE0,$0000,$1F00,$1F00,$1F00,$1F00	;"("	
	dc.w	$1F00,$1F00,$1F00,$1F80,$1FE0,$0FF0,$07F8,$0000	
	dc.w	$3FC0,$1FE0,$0FF0,$0000,$01F0,$01F0,$01F0,$01F0	;")"	
	dc.w	$01F0,$01F0,$01F0,$03F0,$0FF0,$1FE0,$3FC0,$0000	
	dc.w	$0100,$4104,$3398,$3BB8,$1FF0,$0FE0,$3FF8,$FFFE	;"*"	
	dc.w	$3FF8,$0FE0,$1FF0,$3BB8,$3398,$4104,$0100,$0000	
	dc.w	$0000,$0000,$03C0,$03C0,$03C,$03C0,$3FFC,$3FFC	;"+"	
	dc.w	$3FFC,$3FFC,$03C0,$03C0,$03C0,$03C0,$0000,$0000	
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	;","
	dc.w	$0000,$03C0,$07C0,$07C0,$07C0,$0600,$0400,$0000	
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FFC,$3FFC	;"-"
	dc.w	$3FFC,$3FFC,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	;"."
	dc.w	$0000,$0000,$03C0,$07C0,$07C0,$07C0,$0780,$0000
	dc.w	$000E,$001E,$003E,$007C,$00F8,$01F0,$03E0,$07C0	;"/"
	dc.w	$0F80,$1F00,$3E00,$7C00,$F800,$F000,$E000,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F83E,$F9FE,$FBBE	;"0"
	dc.w	$FF3E,$F83E,$F83E,$FC7E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$07C0,$07C0,$07C0,$07C0,$0FC0,$0FC0,$1FC0,$1FC0	;"1"
	dc.w	$07C0,$07C0,$07C0,$07C0,$FFFE,$FFFE,$FFFE,$0000
	dc.w	$3FF0,$7FFC,$FFFE,$F800,$003E,$007E,$3FFE,$7FFC	;"2"
	dc.w	$FFF8,$FC00,$F800,$F83E,$FFFE,$FFFE,$FFFE,$0000
	dc.w	$3FF8,$7FFC,$FFFE,$F800,$003E,$007E,$07FC,$07F8	;"3"
	dc.w	$07FC,$007E,$003E,$F87E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$F83E,$F83E,$F83E,$003E,$F83E,$FC0E,$FFFE,$7FFE	;"4"
	dc.w	$3FFE,$003E,$003E,$003E,$003E,$003E,$003E,$0000
	dc.w	$FFFE,$FFFE,$FFFE,$003E,$F800,$F800,$FFF8,$FFFC	;"5"
	dc.w	$FFFE,$007E,$003E,$F87E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$3FFE,$7FFE,$FFFE,$003E,$F800,$F800,$FFF8,$FFFC	;"6"
	dc.w	$FFFE,$F87E,$F83E,$FC7E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$F800,$003E,$003E,$07FE,$07FE	;"7"
	dc.w	$07FE,$003E,$003E,$003E,$003E,$003E,$003E,$0000
	dc.w	$3FF8,$7FFC,$FFFE,$007E,$F83E,$FC7E,$7FFC,$3FF8	;"8"
	dc.w	$7FFC,$FC7E,$F83E,$FC7E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$3FF8,$7FFC,$FFFE,$007E,$F83E,$FC3E,$FFFE,$7FFE	;"9"
	dc.w	$3FFE,$003E,$003E,$F87E,$FFFE,$FFFC,$FFF8,$0000	
	dc.w	$0000,$0000,$03C0,$07C0,$07C0,$07C0,$0780,$0000	;":"
	dc.w	$0000,$03C0,$07C0,$07C0,$07C0,$0780,$0000,$0000
	dc.w	$0000,$0000,$03C0,$07C0,$07C0,$07C0,$0780,$0000	;";"
	dc.w	$0000,$03C0,$07C0,$07C0,$07C0,$0600,$0400,$0000
	dc.w	$007C,$00F8,$01F0,$03E0,$07C0,$0F80,$1F00,$3E00	;"<"
	dc.w	$1F00,$0F80,$07C0,$03E0,$01F0,$00F8,$007C,$0000
	dc.w	$0000,$0000,$0000,$3FFC,$3FFC,$3FFC,$3FFC,$0000	;"="
	dc.w	$0000,$3FFC,$3FFC,$3FFC,$3FFC,$0000,$0000,$0000
	dc.w	$7C00,$3E00,$1F00,$0F80,$07C0,$03E0,$01F0,$00F8	;">"
	dc.w	$01F0,$03E0,$07C0,$0F80,$1F00,$3E00,$7C00,$0000
	dc.w	$3FF8,$7FFC,$FFFE,$F800,$003E,$007E,$03FE,$07FC	;"?"
	dc.w	$07F8,$07C0,$07C0,$0000,$07C0,$07C0,$07C0,$0000	
	dc.w	$3FF8,$7FFC,$FFFE,$FC7E,$F83E,$F83E,$F9FE,$F9FE	;"@"
	dc.w	$F9FE,$F9FE,$F9FE,$FC00,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F83E,$FFFE,$FFFE	;"A"
	dc.w	$FFFE,$F83E,$F83E,$F83E,$F83E,$F83E,$FF3E,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F87E,$FFFC,$FFF8	;"B"
	dc.w	$FFFC,$F87E,$F83E,$F87E,$FFFE,$FFFC,$FFF8,$0000	
	dc.w	$3FFE,$7FFE,$FFFE,$003E,$F800,$F800,$F800,$F800	;"C"
	dc.w	$F800,$F800,$F800,$FC3E,$FFFE,$7FFE,$3FFE,$0000	
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F83E,$F83E,$F83E	;"D"
	dc.w	$F83E,$F83E,$F83E,$F87E,$FFFE,$FFFC,$FFF8,$0000	
	dc.w	$FFF8,$FFFC,$FFFE,$003E,$F800,$F800,$FFC0,$FFC0	;"E"
	dc.w	$FFC0,$F800,$F800,$F83E,$FFFE,$FFFC,$FFF8,$0000	
	dc.w	$FFF8,$FFFC,$FFFE,$003E,$F800,$F800,$FFC0,$FFC0	;"F"
	dc.w	$FFC0,$F800,$F800,$F800,$F800,$F800,$F800,$0000
	dc.w	$3FFE,$7FFE,$FFFE,$003E,$F800,$F800,$F8FE,$F8FE	;"G"
	dc.w	$F8FE,$F83E,$F83E,$FC3E,$FFFE,$7FFE,$3FFE,$0000	
	dc.w	$F83E,$F83E,$F83E,$003E,$F83E,$F83E,$FFFE,$FFFE	;"H"
	dc.w	$FFFE,$F83E,$F83E,$F83E,$F83E,$F83E,$F83E,$0000
	dc.w	$FFFE,$FFFE,$FFFE,$0000,$07C0,$07C0,$07C0,$07C0	;"I"	
	dc.w	$07C0,$07C0,$07C0,$07C0,$FFFE,$FFFE,$FFFE,$0000
	dc.w	$FFFE,$FFFE,$FFFE,$F800,$003E,$003E,$07FE,$07FE	;"J"
	dc.w	$07FE,$003E,$003E,$F87E,$FFFE,$FFFC,$FFF8,$0000
	dc.w	$F83E,$F83E,$F83E,$003E,$F83E,$F87E,$FFFC,$FFF8	;"K"
	dc.w	$FFFC,$F87E,$F83E,$F83E,$F83E,$F83E,$F83E,$0000	
	dc.w	$F800,$F800,$F800,$0000,$F800,$F800,$F800,$F800	;"L"
	dc.w	$F800,$F800,$F800,$FC3E,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$F83E,$FC7E,$FEFE,$FFFE,$F7FE,$FBBE,$F93E,$F83E	;"M"
	dc.w	$F83E,$F83E,$F83E,$F83E,$F83E,$F83E,$F83E,$0000
	dc.w	$F83E,$FC3E,$FE3E,$0F3E,$F7BE,$FBFE,$F9FE,$F8FE	;"N"
	dc.w	$F87E,$F83E,$F83E,$F83E,$F83E,$F83E,$F83E,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F83E,$F83E,$F83E	"O"
	dc.w	$F83E,$F83E,$F83E,$FC7E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F87E,$FFFE,$FFFC	;"P"
	dc.w	$FFF8,$F800,$F800,$F800,$F800,$F800,$F800,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F83E,$F83E,$F83E	;"Q"
	dc.w	$F83E,$F8FE,$F8FE,$FCFE,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$007E,$F83E,$F87E,$FFFC,$FFF8	;"R"
	dc.w	$FFFC,$F87E,$F83E,$F83E,$F83E,$F83E,$F83E,$0000
	dc.w	$3FFE,$7FFE,$FFFE,$003E,$F800,$FC00,$FFF8,$7FFC	;"S"
	dc.w	$3FFE,$007E,$003E,$F87E,$FFFE,$FFFC,$FFF8,$0000
	dc.w	$FFF8,$FFFC,$FFFE,$F800,$003E,$003E,$003E,$003E	;"T"
	dc.w	$003E,$003E,$003E,$003E,$003E,$003E,$003E,$0000
	dc.w	$F83E,$F83E,$F83E,$003E,$F83E,$F83E,$F83E,$F83E	;"U"
	dc.w	$F83E,$F83E,$F83E,$FC3E,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$F83E,$F83E,$F83E,$003E,$F83E,$F83E,$F83E,$F83E	;"V"
	dc.w	$F87C,$F8F8,$F9F0,$FBE0,$FFC0,$7F80,$3F00,$0000
	dc.w	$F83E,$F83E,$F83E,$003E,$F83E,$F83E,$F83E,$F83E	;"W"
	dc.w	$F83E,$F93E,$FBBE,$FFFC,$FFF8,$7EF0,$3C60,$0000
	dc.w	$F01E,$F01E,$F83E,$007E,$7EFC,$3FF8,$1FF0,$0FE0	;"X"?
	dc.w	$1FF0,$3FF8,$7EFC,$FC7E,$F83E,$F01E,$F01E,$0000
	dc.w	$F83E,$F83E,$F83E,$003E,$F83E,$FC3E,$FFFE,$7FFE	;"Y"
	dc.w	$3FFE,$003E,$003E,$F87E,$FFFE,$FFFC,$FFF8,$0000
	dc.w	$FFFE,$FFFE,$FFFE,$F800,$00FC,$01F8,$03F0,$07E0	;"Z"
	dc.w	$0FC0,$1F80,$3F00,$7E3E,$FFFE,$FFFE,$FFFE,$0000
	dc.w	$1FF8,$1FF8,$1FF8,$0000,$1F00,$1F00,$1F00,$1F00	;"["
	dc.w	$1F00,$1F00,$1F00,$1F00,$1FF8,$1FF8,$1FF8,$0000
	dc.w	$E000,$F000,$F800,$7C00,$3E00,$1F00,$0F80,$07C0	;"\"
	dc.w	$03E0,$01F0,$00F8,$007C,$003E,$001E,$000E,$0000
	dc.w	$3FF0,$3FF0,$3FF0,$0000,$01F0,$01F0,$01F0,$01F0	;"]"
	dc.w	$01F0,$01F0,$01F0,$01F0,$3FF0,$3FF0,$3FF0,$0000
	dc.w	$0100,$0380,$07C0,$0FE0,$1EF0,$3C78,$783C,$0000	;"^"
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	;"_"
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$FFFF,$FFFF
	dc.w	$0780,$07C0,$07C0,$07C0,$00C0,$0040,$0000,$0000	;"`"
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FFE,$7FFE	;"a"
	dc.w	$FFFE,$FC3E,$F83E,$FC3E,$FFBE,$7FBE,$3FBE,$0000
	dc.w	$0000,$0000,$F800,$F800,$F800,$0000,$FFF8,$FFFC	;"b"
	dc.w	$FFFE,$F87E,$F83E,$F87E,$FFFE,$FFFC,$FFF8,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FFE,$7FFE	;"c"
	dc.w	$FFFE,$FC00,$F800,$FC00,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$0000,$0000,$003E,$003E,$003E,$0000,$3FFE,$7FFE	;"d"
	dc.w	$FFFE,$FC3E,$F83E,$FC3E,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FF8,$7FFC	;"e"
	dc.w	$FFFE,$FC3E,$FFFC,$FC00,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$0000,$0000,$1FF0,$3FF8,$7FFC,$0000,$7F80,$7F80	;"f"
	dc.w	$7F80,$7C00,$7C00,$7C00,$7C00,$7C00,$7C00,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FFE,$7FFE	;"g"
	dc.w	$FFFE,$FC00,$F9FE,$FC3E,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$0000,$0000,$F800,$F800,$F800,$0000,$FFF8,$FFFC	;"h"
	dc.w	$FFFE,$F87E,$F83E,$F83E,$F83E,$F83E,$F83E,$0000	
	dc.w	$0000,$0000,$07C0,$07C0,$07C0,$0000,$07C0,$07C0	;"i"
	dc.w	$07C0,$07C0,$07C0,$07C0,$07C0,$07C0,$07C0,$0000
	dc.w	$0000,$0000,$003E,$003E,$003E,$0000,$003E,$003E	;"j"
	dc.w	$003E,$003E,$003E,$F87E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$0000,$0000,$F800,$F800,$F800,$0000,$F83E,$F83E	;"k"
	dc.w	$F87E,$FFFC,$FFF8,$FFFC,$F87E,$F83E,$F83E,$0000
	dc.w	$0000,$0000,$0FC0,$07C0,$07C0,$0000,$07C0,$07C0	;"l"
	dc.w	$07C0,$07C0,$07C0,$07C0,$07C0,$07E0,$07F0,$0000	
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$FC78,$FEFC	;"m"
	dc.w	$FFFE,$FBBE,$F93E,$F83E,$F83E,$F83E,$F83E,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$FFF8,$FFFC	;"n"
	dc.w	$FFFE,$F87E,$F83E,$F83E,$F83E,$F83E,$F83E,$0000	
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FF8,$7FFC	;"o"
	dc.w	$FFFE,$FC7E,$F83E,$FC7E,$FFFE,$7FFC,$3FF8,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$FFF8,$FFFC	;"p"
	dc.w	$FFFE,$F87E,$FFFC,$F800,$F800,$F800,$F800,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FF8,$7FFC	;"q"
	dc.w	$FFFE,$FC3E,$F8FE,$FCFE,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$FFF8,$FFFC	;"r"
	dc.w	$FFFE,$F87E,$FFFC,$F87E,$F83E,$F83E,$F83E,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3FFE,$7FFE	;"s"
	dc.w	$FFFE,$FC08,$7FFC,$007E,$FFFE,$FFFC,$FFF8,$0000
	dc.w	$0000,$0000,$1F00,$1F00,$1F00,$0000,$3FE0,$3FE0	;"t"
	dc.w	$3FE0,$1F00,$1F00,$1F80,$1FE0,$0FE0,$07C0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$F83E,$F83E	;"u"
	dc.w	$F83E,$F83E,$F83E,$FC3E,$FFFE,$7FFE,$3FFE,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$F83E,$F83E	;"v"	
	dc.w	$F83E,$F83E,$F87E,$F8FC,$FFF8,$FFF0,$FFE0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$F83E,$F83E	;"w"
	dc.w	$F83E,$F83E,$F83E,$F97C,$FFF8,$FFF0,$FEE0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$F83E,$F83E	;"x"
	dc.w	$FC7E,$7FFC,$3FF8,$7FFC,$FC7E,$F83E,$F83E,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$F83E,$F83E	;"y"
	dc.w	$F83E,$7FFE,$003E,$F87E,$FFFE,$FFFC,$FFF8,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$FFFE,$FFFE	;"z"	
	dc.w	$FFFC,$0078,$1FF0,$3C00,$7FFE,$FFFE,$FFFE,$0000
	dc.w	$07F8,$0FF8,$1FF8,$0000,$1F00,$3F00,$7E00,$FC00	;"{"
	dc.w	$7E00,$3F00,$1F00,$1F80,$1FF8,$0FF8,$07F8,$0000	
	dc.w	$07C0,$07C0,$07C0,$07C0,$07C0,$07C0,$07C0,$07C0	;"|"
	dc.w	$07C0,$07C0,$07C0,$07C0,$07C0,$07C0,$07C0,$0000
	dc.w	$3FC0,$3FE0,$3FF0,$0000,$01F0,$01F8,$00FC,$007E	;"}"
	dc.w	$00FC,$01F8,$01F0,$03F0,$3FF0,$3FE0,$3FC0,$0000
	dc.w	$0800,$1C00,$3E00,$7700,$E380,$C1C1,$80E3,$0077	;"~"
	dc.w	$003E,$001C,$0008,$0000,$0000,$0000,$0000,$0000	
	dc.w	$CCCC,$CCCC,$3333,$3333,$CCCC,$CCCC,$3333,$3333	;""
	dc.w	$CCCC,$CCCC,$3333,$3333,$CCCC,$CCCC,$3333,$3333



gfxlib	dc.b	"graphics.library",0
	even

ppname	dc.b	'powerpacker.library',0
	even

_GfxBase	dc.l	0			;LONG WORD TO STORE GFX ADDRESS
_PPBase		dc.l	0
Oldcop		dc.l	0			;OLD COPPERLIST ADDRESS
Music		dc.l	0
Text_Address	dc.l	0
Text_base	dc.l	0
Char_address_2	dc.l	0
Screen		dc.l	0
Length		dc.l	0
FileName	dc.l	0
filehd		dc.l	0
Plop		dc.w	0
Save		dc.w	0
Save_2		dc.w	0
OldMouseY	dc.b	0
OldMouseX	dc.b	0
Value		dc.b	0
Mousecount	dc.b	0
	even

Newcop
	dc.w	$0100,%0100001000000000		
	dc.w	$0102
Scroll1	dc.w	$0000				;SCROLL VALUE
	dc.w	$0104,%0000000000000001		;NO PRIORITIES
	dc.w	$0108,$0000,$010a,$0000		;MODULAS
	dc.w	$0092,$0038,$0094,$00d0		;256*40 SCREEN
	dc.w	$008e,$2c81,$0090,$2cc1		;VISIBLE AREA
						
Planes
	dc.w	$00e0
Bpl0pth	dc.w	$0000,$00e2
Bpl0ptl	dc.w	$0000,$00e4
Bpl1pth	dc.w	$0000,$00e6
Bpl1ptl	dc.w	$0000,$00e8
Bpl2pth	dc.w	$0000,$00ea
Bpl2ptl	dc.w	$0000,$00ec
Bpl3pth	dc.w	$0000,$00ee
Bpl3ptl	dc.w	$0000,$00f0
Bpl4pth	dc.w	$0000,$00f2
Bpl4ptl	dc.w	$0000,$00f4
Bpl5pth	dc.w	$0000,$00f6
Bpl5ptl	dc.w	$0000

Sprites						;SPRITES
	dc.w	$0120
Spl0pth	dc.w	$0000,$0122
Spl0ptl	dc.w	$0000,$0124
Spl1pth	dc.w	$0000,$0126
Spl1ptl	dc.w	$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

	dc.w	$0180,$0000,$0182,$0fff,$0184,$0ca0,$0186,$0dc7
	dc.w	$0188,$0fff,$018a,$0d77,$018c,$0c00,$018e,$0ecc
	dc.w	$0190,$0fff,$0192,$0006,$0194,$0228,$0196,$044a
	dc.w	$0198,$077b,$019a,$0abd,$019c,$0fff,$019e,$0282

	dc.w	$01a0,$0000,$01a2,$0fff		;SPRITE COLORS
	dc.w	$01a4,$0f00,$01a6,$0b00
	dc.w	$01a8,$0600,$01aa,$0F40
	dc.w	$01ac,$0F80,$01ae,$0Fa0
	dc.w	$01b0,$0Ff0,$01b2,$000f
	dc.w	$01b4,$004f,$01b6,$008f
	dc.w	$01b8,$00ff,$01ba,$00f0
	dc.w	$01bc,$0283,$01be,$0f0f

Cop_2		dcb.b	(192+4)*2
	dc.w 	$8701,$ff00,$0180,$0000

Copper_2
	dc.w	$8801,$fffe
	dc.w	$0100,%0001001000000000		

	dc.w	$00e0
Bpl0pth1	dc.w	$0000,$00e2
Bpl0ptl1	dc.w	$0000


Copper_Bar
	dc.w 	$8901,$ff00,$0180,$0000,$0182,$0fff 	; start

	dc.w 	$8a01,$ff00,$0180,$0ff0,$0182,$0ff0
	dc.w 	$8b01,$ff00,$0180,$0f00,$0182,$0ff0
	dc.w 	$8c01,$ff00,$0180,$0f00,$0182,$0ff0
	dc.w 	$8d01,$ff00,$0180,$0f00,$0182,$0ff0
	dc.w 	$8e01,$ff00,$0180,$0f00,$0182,$0ff0
	dc.w 	$8f01,$ff00,$0180,$0f00,$0182,$0ff0
	dc.w 	$9001,$ff00,$0180,$0f00,$0182,$0ff0
	dc.w 	$9101,$ff00,$0180,$0f00,$0182,$0ff0
	dc.w 	$9201,$ff00,$0180,$0f00,$0182,$0ff0
	dc.w 	$9301,$ff00,$0180,$0ff0,$0182,$0ff0

	dc.w 	$9401,$ff00,$0180,$0000,$0182,$0fff	; end


	dc.w	$e601,$fffe,$0182,$0ff0
	dc.w	$e701,$fffe,$0182,$0fe0
	dc.w	$e801,$fffe,$0182,$0fd0
	dc.w	$e901,$fffe,$0182,$0fc0
	dc.w	$ea01,$fffe,$0182,$0fb0
	dc.w	$eb01,$fffe,$0182,$0fa0
	dc.w	$ec01,$fffe,$0182,$0f90
	dc.w	$ed01,$fffe,$0182,$0f80

	dc.w	$ee01,$fffe,$0182,$0f70

	dc.w	$ef01,$fffe,$0182,$0f80
	dc.w	$f001,$fffe,$0182,$0f90
	dc.w	$f101,$fffe,$0182,$0fa0
	dc.w	$f201,$fffe,$0182,$0fb0
	dc.w	$f301,$fffe,$0182,$0fc0
	dc.w	$f401,$fffe,$0182,$0fd0
	dc.w	$f501,$fffe,$0182,$0fe0
	dc.w	$f601,$fffe,$0182,$0ff0

Cop		dcb.b	(192+4)*2

	dc.w 	$fc01,$ff00,$0180,$0000

Copper_3
	dc.w	$ff01,$fffe
	dc.w	$0100,%0001001000000000		
	dc.w	$0108,$0004,$010a,$0004	;MODULAS

	dc.w	$00e0
Bpl0pth2	dc.w	$0000,$00e2
Bpl0ptl2	dc.w	$0000,$00e4
Bpl1pth2	dc.w	$0000,$00e6
Bpl1ptl2	dc.w	$0000,$00e8
Bpl2pth2	dc.w	$0000,$00ea
Bpl2ptl2	dc.w	$0000,$00ec
Bpl3pth2	dc.w	$0000,$00ee
Bpl3ptl2	dc.w	$0000

	dc.w	$0180,$0000,$0182,$02f2


	dc.w	$ffff,$fffe			;END OF COPPERLIST
Sprite
	dc.w    $88B9,$8900,$1000,$0000,$8AAF,$8B00,$1000,$0000
	dc.w    $8C48,$8D00,$1000,$0000,$8E68,$8F00,$1000,$0000
	dc.w    $90DF,$9100,$1000,$0000,$924F,$9300,$1000,$0000
	dc.w    $9424,$9500,$1000,$0000,$96D7,$9700,$1000,$0000
	dc.w    $9859,$9900,$1000,$0000,$9A4F,$9B00,$1000,$0000
	dc.w    $9C4A,$9D00,$1000,$0000,$9E5C,$9F00,$1000,$0000
	dc.w    $A046,$A100,$1000,$0000,$A2A6,$A300,$1000,$0000
	dc.w    $A423,$A500,$1000,$0000,$A6FA,$A700,$1000,$0000
	dc.w    $A86C,$A900,$1000,$0000,$AA44,$AB00,$1000,$0000
	dc.w    $AC88,$AD00,$1000,$0000,$AE9A,$AF00,$1000,$0000
	dc.w    $B06C,$B100,$1000,$0000,$B2D4,$B300,$1000,$0000
	dc.w    $B42A,$B500,$1000,$0000,$B636,$B700,$1000,$0000
	dc.w    $B875,$B900,$1000,$0000,$BA89,$BB00,$1000,$0000
	dc.w    $BC45,$BD00,$1000,$0000,$BE24,$BF00,$1000,$0000
	dc.w    $C0A3,$C100,$1000,$0000,$C29D,$C300,$1000,$0000		
	dc.w    $C43F,$C500,$1000,$0000,$C634,$C700,$1000,$0000		
	dc.w    $C87C,$C900,$1000,$0000,$CA1D,$CB00,$1000,$0000		
	dc.w    $CC6B,$CD00,$1000,$0000,$CEAC,$CF00,$1000,$0000		
	dc.w    $D0CF,$D100,$1000,$0000,$D2FF,$D300,$1000,$0000		
	dc.w    $D4A5,$D500,$1000,$0000,$D6D6,$D700,$1000,$0000		
	dc.w    $D8EF,$D900,$1000,$0000,$DAE1,$DB00,$1000,$0000		
	dc.w    $DCD9,$DD00,$1000,$0000,$DEA6,$DF00,$1000,$0000		
	dc.w    $E055,$E100,$1000,$0000,$E237,$E300,$1000,$0000		
	dc.w    $E47D,$E500,$1000,$0000,$E62E,$E700,$1000,$0000		
	dc.w    $E8AF,$E900,$1000,$0000,$EA46,$EB00,$1000,$0000
	dc.w	$EC65,$ED00,$1000,$0000,$EE87,$EF00,$1000,$0000
	dc.w	$F0D4,$F100,$1000,$0000,$F2F5,$F300,$1000,$0000
	dc.w	$F4FA,$F500,$1000,$0000,$F62C,$F700,$1000,$0000
	dc.w	$F84D,$F900,$1000,$0000,$FAAC,$FB00,$1000,$0000
SpriteE	dc.w 	$0000,$0000
	even

Cols4	dc.w	$000f,$001f,$002f,$003f,$004f,$005f,$006f,$007f,$008f
	dc.w	$009f,$00af,$00bf,$00cf,$00df,$00ef,$00ff,$01ef
	dc.w	$02df,$03cf,$04bf,$05af,$069f,$079f,$088f,$097f
	dc.w	$0a6f,$0b5f,$0c4f,$0d3f,$0e2f,$0f1f,$0e0f,$0d0f
	dc.w	$0c0f,$0b0f,$0a0f,$090f,$080f,$070f,$060f,$050f
	dc.w	$040f,$030f,$020f,$010f,$000f,$001f,$000f

Logo		incbin	PE.Music

Foreground	dcb.b	ScreenSize*1,$00
		
Scroll_Area	dcb.b	ScrollArea*1,$00

LoadingArea	incbin	Load.raw


; You may need to alter the drive to df1: when test assembling as that is
;where the modules are. Done away with module size specifier.

Music_1		dc.b	'Source:Modules/Mod.Gambler',0
		even

Music_2		dc.b	'Source:Modules/mod.stock cube',0
		even

Music_3		dc.b	'Source:Modules/Mod.bikini',0
		even

Music_4		dc.b	'Source:Modules/mod.rent',0
		even

Music_5		dc.b	'Source:Modules/mod.hiphop house',0
		even

Music_6		dc.b	'Source:Modules/Mod.spirit its',0
		even

Music_7		dc.b	'Source:Modules/mod.concert',0
		even

Music_8		dc.b	'Source:Modules/mod.popcorn',0
		even

Music_0		dc.b 	'Source:Modules/mod.Zapped-out',0
		even
	
; And they all lived happily ever after......



