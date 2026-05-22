 SECTION Framework,CODE_C

* PROGRAM NAME 'pix32scrl.s'


* This will set up a 5 bitplane 320*256 pixel screen.
* NEEDS TO BE IN CHIP MEMORY.





OpenLib:	equ	-552	; Offset for OpenLibrary.
CloseLib:	equ	-414	; Offset for CloseLibrary.

diwstart:	equ	$8e	; Screen hardware registers.
diwstop:	equ	$90
ddfstart:	equ	$92
ddfstop:	equ	$94
bplcon0:	equ	$100
bplcon1:	equ	$102

bpl1pth:	equ	$e0
bpl1ptl:	equ	$e2
bpl2pth:	equ	$e4
bpl2ptl:	equ	$e6
bpl3pth:	equ	$e8
bpl3ptl:	equ	$ea
bpl4pth:	equ	$ec
bpl4ptl:	equ	$ee
bpl5pth:	equ	$f0
bpl5ptl:	equ	$f2

start:

************
*  PART 1  *
************
	MOVEM.L	D0-D7/A0-A6,-(A7)	;SAVE ALL REGISTERS

	JSR	mt_init

	bset	#1,$bfe001	; filter off

	MOVE.L	4,A6		; EXECBASE IN A6
	JSR	-132(A6)	; FORBID (DISABLE MULTITASKING)

	MOVE.W	#$0008,$DFF09A	; TURN OF DRIVE & KEYBOARD


	move.l	#screen,d0	; Get address of our screen memory.
	move.w	d0,pl1l		; Move the low word into copper list.
	swap	d0		; Swap the low and high words in d0.
	move.w	d0,pl1h		; Move the high word into the copper
				; list.
	swap	d0
	add.l	#8000,d0
	move.w	d0,pl2l
	swap	d0
	move.w	d0,pl2h
	swap	d0
	add.l	#8000,d0
	move.w	d0,pl3l
	swap	d0
	move.w	d0,pl3h
	swap	d0
	add.l	#8000,d0
	move.w	d0,pl4l
	swap	d0
	move.w	d0,pl4h
	swap	d0
	add.l	#8000,d0
	move.w	d0,pl5l
	swap	d0
	move.w	d0,pl5h
	swap	d0

; Set up colours for screen picture
  
	add.l	#8000,d0	; add correct amount to point
	move.l	d0,a0		; to colour palette in buffer.
	lea	cols2,a1
	moveq	#31,d1
	move.w	#$180,d2

palette:
	move.w	d2,(a1)+
	addq.w	#2,d2
	move.w	(a0)+,(a1)+
	dbf	d1,palette

* FOR 1 BITPLANE SCROLLER

	move.l	#scrlpic,d0
	move.w	d0,scrlplanel1
	swap	d0
	move.w	d0,scrlplaneh1

*************************

num_stars=118
layer1=$60000 ;remember change spr pointer acording
layer2=$62000

	move.l #$60000,a0
clr:	clr.l (a0)+
	cmp.l #$70000,a0
	bne clr
;-----set out dummy sprite data table in memory-----

	lea layer1,a0         ;table at
	move.b #num_stars,times
	move.b #$30,d0        ;spr start position vertical
	move.b #$31,d2        ;spr tail end byte
	move.l #%00000000000000010000000000000000,d4 ;spr design data
**********************
pokein1:
	move.b d0,(a0)+
	move.b #$5f,(a0)+   ;horizontal cont byte
	move.b d2,(a0)+
	move.b #$00,(a0)+
	move.l d4,(a0)+ 
	add.b #$02,d0
	add.b #$02,d2
	sub.b #01,times
	bne pokein1
****************
	lea starpos1,a0      ;work out star positions
	lea layer1+1,a1

again1:	move.b (a0)+,(a1)
	add.w #08,a1
	cmp.b #0,(a0)
	bne again1


;second layer


	lea layer2,a0         ;table at
	move.b #num_stars,times
	move.b #$32,d0        ;spr start position vertical
	move.b #$33,d2        ;spr tail end byte
	move.l #%00000000000000000000000000000001,d4 ;spr design data
**********************
pokein2:
	move.b d0,(a0)+
	move.b #$5f,(a0)+   ;horizontal cont byte
	move.b d2,(a0)+
	move.b #$00,(a0)+
	move.l d4,(a0)+ 
	add.b #$02,d0
	add.b #$02,d2
	sub.b #01,times
	bne pokein2
**********************************
	lea starpos2,a0      ;work out star positions
	lea layer2+1,a1
again2:	move.b (a0)+,(a1)
	add.w #08,a1
	cmp.b #0,(a0)
	bne again2

**********************************

	move.l	4.w,a6		; Get EXECBASE.
	lea	gfxname(PC),a1	; Point to 'graphics.library' string.
	moveq	#0,d0		; Ignore version number.
	jsr	OpenLib(a6)	; Open the library.
	move.l	d0,a1		; Store library address.
	move.l	38(a1),old	; Store workbench copper address.
	move.l	4.w,a6		; Get EXECBASE again.
	jsr	CloseLib(a6)	; Close the library.

	MOVE.L	$78,LEV6SAVE		;SAVE OLD LEVEL 6 INT
	MOVE.L	#LEV6INT0,$78		;NEW INTERUPT ROUTINE

	move.w	#$00ff,scroll

	move.l	#scrolltext,textpoint

	move.l	#new,$dff080	; Set new copper.

************
*  PART 3  *
************

WAIT:
	BTST	#6,$BFE001
	BNE.S	WAIT
FINISH:
	MOVE.L	LEV6SAVE,$78		;REPLACE OLD LEVEL 6 INT
	MOVE.L	old,$DFF080		;REPLACE OLD COPPERLIST
	MOVE.L	4,A6
	JSR	-138(A6)		;PERMIT (MULTITASKING ON)
	JSR	mt_end
	bclr	#1,$bfe001		;filter on
	MOVE.W	#$8008,$DFF09A		;DRIVE & KEYBOARD ON
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

stop:	nop


LEV6INT0:
	MOVEM.L	D0-D7/A0-A6,-(A7)	;SAVE REGISTERS
	BSR	INTERRUPTROUTINE	;JMP TO ROUTINE
	MOVEM.L	(A7)+,D0-D7/A0-A6	;RESTORE REGISTERS
	MOVE.W	#$2000,$DFF09C		;CLEAR LEV6 INTERRUPT FLAG
	RTE				;RETURN

INTERRUPTROUTINE:
	jsr	leftscrl
	jsr	bar
	jsr	movestars
	JSR	mt_music	
	rts

leftscrl:
	sub.w	#$0022,scroll
	move.w	scroll,d1
	cmp	#$0077,d1
	bne	nxtblock

waitblit1:
	btst	#14,$dff002
	bne	waitblit1	;blitter busy

; #SCRLPIC+1 means #SCRLPIC+1 BYTE

	move.l	#scrlpic,$dff050 ;start of source data 
	move.w	#$0000,$dff064	;modulo for source is 0
	move.w	#$0000,$dff066	;modulo for destination is 0
	move.l	#scrlpic-2,$dff054 ;start of destination data
	move.w	#$89f0,$dff040
	clr.w	$dff042		
	move.w	#$ffff,$dff044
	move.w	#$ffff,$dff046
	move.w	#$0816,$dff058	;window size 32 lines by 20 wrds wide

waitblit2:
	btst	#14,$dff002
	bne	waitblit2	;blitter busy

copydone:
	move.w	#$00ff,scroll
	add.b	#1,blockcnt
	cmp.b	#4,blockcnt	; four 8 pixel blocks copied
	beq	newchar		; put new char to screen
	bra	nxtblock	; next 8 pixel shift to left

newchar:
	move.b	#0,blockcnt


getchar:
	move.l	textpoint,a1
	move.b	(a1),d1
	cmp.b	#$ff,d1
	bne	nextchar
	move.l	#scrolltext,a1
	move.l	#scrolltext,textpoint

nextchar:
	move.b	(a1),d1
	cmp.b	#65,d1
	blt	nmbs
	sub.b	#65,d1
	bra	findchar
nmbs:
	cmp.b	#48,d1
	blt	spc
	sub.b	#21,d1
	bra	findchar

spc:
	sub.b	#6,d1
		
	
findchar:
	cmp.b	#10,d1
	blt	aj
	cmp.b	#30,d1
	blt	numlet
	sub.b	#30,d1
	mulu	#4,d1
	add.l	#3840,d1
	bra	frstln
	
numlet:
	cmp.b	#20,d1
	blt	scndln
	sub.b	#20,d1
	mulu	#4,d1
	add.l	#2560,d1	; if d1 > ascii of T
	bra	frstln

scndln:
	sub.b	#10,d1
	mulu	#4,d1
	add.l	#1280,d1	; if d1 > ascii of J
	bra	frstln
aj:
	mulu	#4,d1
frstln:
	move.l	#chardfn,a2
	add.l	d1,a2
	move.l	a2,charstart
	add.l	#1,textpoint
	
	

putchar:
	move.l	#scrlpic,a0
	moveq	#31,d0		; character height
	add.l	#40,a0		; 4 bytes before end of screen
	move.l	charstart,a2

loop:
	move.l	(a2),(a0)
	subq	#$01,d0
	cmp.b	#$00,d0
	beq	nxtblock
	add.l	#44,a0		;point to next line on screen
	add.l	#40,a2		;next line in character buffer
	bra	loop

	
	
nxtblock:

	
	RTS

bar:


	cmp.b	#1,barflag
	bne	barup


	add.w	#$0100,barcop1
	add.w	#$0100,barcop2
	add.w	#$0100,barcop3
	add.w	#$0100,barcop4
	add.w	#$0100,barcop5
	add.w	#$0100,barcop6
	add.w	#$0100,barcop7
	add.w	#$0100,barcop8
	add.w	#$0100,barcop9
	add.w	#$0100,barcop10
	add.w	#$0100,barcop11
	add.w	#$0100,barcop12
	add.w	#$0100,barcop13
	add.w	#$0100,barcop14
	add.w	#$0100,barcop15
	add.w	#$0100,barcop16
	cmp.w	#$e001,barcop1	; bar lowerlimit line 224
	bne	upbarpos
	move.b	#0,barflag
	bra	upbarpos

barup:


	sub.w	#$0100,barcop1
	sub.w	#$0100,barcop2
	sub.w	#$0100,barcop3
	sub.w	#$0100,barcop4
	sub.w	#$0100,barcop5
	sub.w	#$0100,barcop6
	sub.w	#$0100,barcop7
	sub.w	#$0100,barcop8
	sub.w	#$0100,barcop9
	sub.w	#$0100,barcop10
	sub.w	#$0100,barcop11
	sub.w	#$0100,barcop12
	sub.w	#$0100,barcop13
	sub.w	#$0100,barcop14
	sub.w	#$0100,barcop15
	sub.w	#$0100,barcop16
	cmp.w	#$2901,barcop1	; bar upperlimit line 41
	bne	upbarpos
	move.b	#1,barflag

upbarpos:
	rts

movestars:

	bsr slit
	bsr slit2
	rts

************************************
slit:	lea layer1+1,a4	
	lea speeds1,a3
	move.w #num_stars,d7
suck1:	move.b (a3)+,d3
	add.b d3,(a4)
	add.l #8,a4
	dbra d7,suck1
	rts

slit2:	lea layer2+1,a4	
	lea speeds2,a3
	move.w #num_stars,d7
suck2:	move.b (a3)+,d3
	add.b d3,(a4)
	add.l #8,a4
	dbra d7,suck2
	rts

	even

times:	dc.b 0

	even

starpos1:
	dc.b 55,66,50,90,123,88,100,190,11,69
	dc.b 11,22,133,44,55,166,77,188,99,101
	dc.b 111,122,133,144,155,166,177,188,129,101
	dc.b 11,55,90,56,64,81,255,222,164,01
	dc.b 1,18,14,19,110,03,15,20,25,01
	dc.b 115,20,125,30,135,40,145,50,155,160
	dc.b 100,200,110,150,200,220,2,20,11,11
	dc.b 110,11,20,100,170,111,70,91,92,144
	dc.b 80,20,50,10,90,200,240,250,14,19
	dc.b 120,1,10,150,112,141,40,91,02,44
	dc.b 10,50,55,15,18,55,140,150,44,79

	
	even

speeds1:
	dc.b 05,02,05,04,05,01,04,04,02,04
	dc.b 01,02,01,04,03,02,01,04,01,03
	dc.b 01,05,02,01,02,03,01,01,02,04
	dc.b 01,05,04,05,02,05,02,03,03,05
	dc.b 04,03,02,01,02,03,04,03,02,01
	dc.b 01,03,01,02,04,02,01,03,02,01
	dc.b 01,02,05,05,02,04,01,04,03,06	
	dc.b 04,03,04,01,04,03,02,02,01,03
	dc.b 01,05,02,04,05,01,02,04,05,05
	dc.b 04,03,04,01,04,03,02,02,01,03
	dc.b 01,05,02,04,05,01,02,04,05,05


	even

starpos2:
	dc.b 10,50,55,15,18,55,140,150,44,79
	dc.b 55,66,50,90,123,88,100,190,11,69
	dc.b 11,22,133,44,55,166,77,188,99,101
	dc.b 111,122,133,144,155,166,177,188,129,101
	dc.b 11,55,90,56,64,81,255,222,164,01
	dc.b 10,50,55,15,18,55,140,150,44,79
	dc.b 1,18,14,19,110,03,15,20,25,01
	dc.b 115,20,125,30,135,40,145,50,155,160
	dc.b 110,11,20,100,170,111,70,91,92,144
	dc.b 100,200,110,150,200,220,2,20,11,11
	dc.b 80,20,50,10,90,200,240,250,14,19


	even
	

speeds2:
	dc.b 05,02,05,04,05,01,04,04,02,04
	dc.b 01,05,04,05,02,05,02,03,03,05
	dc.b 01,05,02,01,02,03,01,01,02,04
	dc.b 04,03,02,01,02,03,04,03,02,01
	dc.b 01,02,01,04,03,02,01,04,01,03
	dc.b 01,03,01,02,04,02,01,03,02,01
	dc.b 04,03,04,01,04,03,02,02,01,03
	dc.b 04,03,04,01,04,03,02,02,01,03
	dc.b 01,05,02,04,05,01,02,04,05,05
	dc.b 01,05,02,04,05,01,02,04,05,05
	dc.b 01,02,05,05,02,04,01,04,03,06	

	even


new:				; Start of our copper list.
	dc.w diwstart,$2981	; Top left corner of screen.
	dc.w diwstop,$29c1	; Bottom right corner of screen.
	dc.w ddfstart,$38	; Data fetch start 42 bytes line
	dc.w ddfstop,$d0	; Data fetch stop.
	
	dc.w bplcon0,$5200	; Set BPLCON0 to 5 bitplane lo-res.
	dc.w bplcon1,$0		; No horizontal offset.

cols2:
	dcb.l 32

	dc.w bpl1pth		; Bitplane high word.
pl1h:
	dc.w 0

	dc.w bpl1ptl		; Bitplane low word.
pl1l:
	dc.w 0

	dc.w bpl2pth		; Bitplane high word.
pl2h:
	dc.w 0

	dc.w bpl2ptl		; Bitplane low word.
pl2l:
	dc.w 0

	dc.w bpl3pth		; Bitplane high word.
pl3h:
	dc.w 0

	dc.w bpl3ptl		; Bitplane low word.
pl3l:
	dc.w 0

	dc.w bpl4pth		; Bitplane high word.
pl4h:
	dc.w 0

	dc.w bpl4ptl		; Bitplane low word.
pl4l:
	dc.w 0

	dc.w bpl5pth		; Bitplane high word.
pl5h:
	dc.w 0

	dc.w bpl5ptl		; Bitplane low word.
pl5l:
	dc.w 0

SPRITES:
	DC.W	$0128,$0000,$012A,$0000,$012C,$0000,$012E,$0000
	DC.W	$0130,$0000,$0132,$0000,$0134,$0000,$0136,$0000
	DC.W	$0138,$0000,$013A,$0000,$013C,$0000,$013E,$0000

	DC.W $0120,$0006  ;sprite at $20000
	DC.W $0122,$0000

	dc.w $0124,$0006
	dc.w $0126,$2000

	dc.w $1a2,$ffff
	dc.w $1a4,$ffff

COPINT:	
	DC.W	$009C,$A000


* bar is 16 lines

barcop1:
	dc.w $2901
	dc.w $fffe
	dc.w $180,$0001
barcop2:
	dc.w $2a01
	dc.w $fffe
	dc.w $180,$0003

barcop3:
	dc.w $2b01
	dc.w $fffe
	dc.w $180,$0005

barcop4:
	dc.w $2c01
	dc.w $fffe
	dc.w $180,$0007	
barcop5:
	dc.w $2d01
	dc.w $fffe
	dc.w $180,$0009
barcop6:
	dc.w $2e01
	dc.w $fffe
	dc.w $180,$000b
barcop7:
	dc.w $2f01
	dc.w $fffe
	dc.w $180,$000d
barcop8:
	dc.w $3001
	dc.w $fffe
	dc.w $180,$000f
barcop9:
	dc.w $3101
	dc.w $fffe
	dc.w $180,$000d
barcop10:
	dc.w $3201
	dc.w $fffe
	dc.w $180,$000b
barcop11:
	dc.w $3301
	dc.w $fffe
	dc.w $180,$0009
barcop12:
	dc.w $3401
	dc.w $fffe
	dc.w $180,$0007
barcop13:
	dc.w $3501
	dc.w $fffe
	dc.w $180,$0005
barcop14:
	dc.w $3601
	dc.w $fffe
	dc.w $180,$0003
barcop15:
	dc.w $3701
	dc.w $fffe
	dc.w $180,$0001
barcop16:
	dc.w $3801
	dc.w $fffe
	dc.w $180,$0000

	dc.w	$f029,$fffe	; wait until line 240,41.

	dc.w	bplcon0,$1200	; one bitplane

	dc.w	ddfstart,$30

	dc.w	ddfstop,$d8	; fourty four pixels per line
	
	dc.w	bplcon1
scroll:
	dc.w 0
	
	dc.w bpl1pth		; Bitplane high word.
scrlplaneh1:
	dc.w 0

	dc.w bpl1ptl		; Bitplane low word.
scrlplanel1:
	dc.w 0

	dc.w	$f229,$fffe	; wait until line 242,41
	dc.w 	$182,$0400	; set colour 1 to red
	dc.w	$f429,$fffe	; wait until line 244,41
	dc.w	$182,$0600
	dc.w	$f629,$fffe	; wait until line 246,41
	dc.w	$182,$0800
	dc.w	$f829,$fffe	; wait until line 248,41
	dc.w	$182,$0a00

	dc.w $ffff,$fffe	; End copper list.

	even

old:	dc.l	0

	even

gfxname: dc.b "graphics.library",0

	even

screen:	incbin source_1:bitmaps/redgwlogo.bm

	even

scrlpic: dcb.b 3168,$00		; 44 x 72

	even

textpoint: dc.l 0

	even

blockcnt: dc.b 1

	even

hlfcnt: dc.b 0

	even

flag:	dc.b 1

	even

charstart: dc.l 0

	even

LEV6SAVE:	DC.L	0

	even

chardfn: incbin source_1:bitmaps/outlnchars.bm

	even

barflag: dc.b 1

	even

scrolltext: dc.b 'STARSTORM PRESENTS         '
	    dc.b 'FIRSTDEMO           '
	    dc.b 'THE FIRST DEMO I HAVE EVERY CODED ON '
	    dc.b 'ANY COMPUTER  ALL MUSIC AND GRAPHICS '
	    dc.b 'BY STARSTORM  GREETINGS GO TO  '
	    dc.b 'MARK  THIS DEMO IS FOR THE MC USERS '
	    dc.b 'GROUP DISK  HOPE YOU LIKE THE DEMO '
	    dc.b ' TIM OF JESTER BROTHERS INTERNATIONAL '
	    dc.b ' FOR HELPING ME WHEN I WAS JUST '
	    dc.b 'STARTING TO CODE  LYNX OF MIRAGE '
	    dc.b 'UK FOR HELP WITH SOURCE CODE  '
	    dc.b 'ALSO TO ANY MEMBERS OF THE MC USERS '
	    dc.b 'GROUP  IF ANYONE WANTS TO GET IN CONTACT '
	    dc.b 'WITH ME  I ESPECIALLY WANT TO GET '
	    dc.b 'IN CONTACT WITH ANY GRAPHICS ARTISTS '
	    dc.b ' WRITE TO    GARY WRIGHT  14 '
	    dc.b 'BEESTON ROAD  BROUGHTON  NR CHESTER '
	    dc.b ' CLWYD  CH4 OSB          '          	            
	    dc.b 'MARK  ENCLOSED IS THE CORRECT AMOUNT '
	    dc.b ' OF STAMPS TO POST THIS BAG BACK TO ME '
	    dc.b ' IF YOU ARE SENDING A MEMBERS DISK '
	    dc.b 'OUT AT THE MOMENT  COULD YOU '
	    dc.b 'PLEASE COPY THE MEMBERS DISK ON TO '
	    dc.b 'THE DISK ENCLOSED  LAST OF ALL  THE '
	    dc.b 'DEVPAC V2 SOURCE CODE FOR THIS DEMO '
	    dc.b 'IS ALSO ON THIS DISK FOR ANYONE TO '
	    dc.b 'LOOK THROUGH  BYE FOR NOW MARK  AND ' 
	    dc.b 'I HOPE TO HEAR FROM YOU SOON '
	    dc.b '         '       
	    dc.b $ff

	even









******************************
*     MUSIC ROUTINE          *
******************************

; -----------------------------------------------
; ------- Soundtracker V2.4 - playroutine -------
; -----------------------------------------------

; call 'mt_init' to initialize the playroutine

mt_init:lea	mt_data,a0
	add.l	#$03b8,a0
	moveq	#$7f,d0
	moveq	#0,d1
mt_init1:
	move.l	d1,d2
	subq.w	#1,d0
mt_init2:
	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	mt_init1
	dbf	d0,mt_init2
	addq.b	#1,d2

mt_init3:
	lea	mt_data,a0
	lea	mt_sample1(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$438,d2
	add.l	a0,d2
	moveq	#$1e,d0
mt_init4:
	move.l	d2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,d2
	add.l	#$1e,a0
	dbf	d0,mt_init4

	lea	mt_sample1(PC),a0
	moveq	#0,d0
mt_clear:
	move.l	(a0,d0.w),a1
	clr.l	(a1)
	addq.w	#4,d0
	cmp.w	#$7c,d0
	bne.s	mt_clear

	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.l	mt_partnrplay
	clr.l	mt_partnote
	clr.l	mt_partpoint

	move.b	mt_data+$3b6,mt_maxpart+1
	rts

; call 'mt_end' to switch the sound off

mt_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

; the playroutine - call this every frame

mt_music:
	addq.w	#1,mt_counter
mt_cool:cmp.w	#6,mt_counter
	bne.s	mt_notsix
	clr.w	mt_counter
	bra	mt_rout2

mt_notsix:
	lea	mt_aud1temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp1
	lea	$dff0a0,a5		
	bsr.s	mt_arprout
mt_arp1:lea	mt_aud2temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp2
	lea	$dff0b0,a5
	bsr.s	mt_arprout
mt_arp2:lea	mt_aud3temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp3
	lea	$dff0c0,a5
	bsr.s	mt_arprout
mt_arp3:lea	mt_aud4temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp4
	lea	$dff0d0,a5
	bra.s	mt_arprout
mt_arp4:rts

mt_arprout:
	move.b	2(a6),d0
	and.b	#$0f,d0
	tst.b	d0
	beq	mt_arpegrt
	cmp.b	#$01,d0
	beq.s	mt_portup
	cmp.b	#$02,d0
	beq.s	mt_portdwn
	cmp.b	#$0a,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a6),d0
	sub.w	d0,22(a6)
	cmp.w	#$71,22(a6)
	bpl.s	mt_ok1
	move.w	#$71,22(a6)
mt_ok1:	move.w	22(a6),6(a5)
	rts

mt_portdwn:
	moveq	#0,d0
	move.b	3(a6),d0
	add.w	d0,22(a6)
	cmp.w	#$538,22(a6)
	bmi.s	mt_ok2
	move.w	#$538,22(a6)
mt_ok2:	move.w	22(a6),6(a5)
	rts

mt_volslide:
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldwn
	add.w	d0,18(a6)
	cmp.w	#64,18(a6)
	bmi.s	mt_ok3
	move.w	#64,18(a6)
mt_ok3:	move.w	18(a6),8(a5)
	rts
mt_voldwn:
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	sub.w	d0,18(a6)
	bpl.s	mt_ok4
	clr.w	18(a6)
mt_ok4:	move.w	18(a6),8(a5)
	rts

mt_arpegrt:
	move.w	mt_counter(PC),d0
	cmp.w	#1,d0
	beq.s	mt_loop2
	cmp.w	#2,d0
	beq.s	mt_loop3
	cmp.w	#3,d0
	beq.s	mt_loop4
	cmp.w	#4,d0
	beq.s	mt_loop2
	cmp.w	#5,d0
	beq.s	mt_loop3
	rts

mt_loop2:
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_cont
mt_loop3:
	moveq	#$00,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	bra.s	mt_cont
mt_loop4:
	move.w	16(a6),d2
	bra.s	mt_endpart
mt_cont:
	add.w	d0,d0
	moveq	#0,d1
	move.w	16(a6),d1
	and.w	#$fff,d1
	lea	mt_arpeggio(PC),a0
mt_loop5:
	move.w	(a0,d0),d2
	cmp.w	(a0),d1
	beq.s	mt_endpart
	addq.l	#2,a0
	bra.s	mt_loop5
mt_endpart:
	move.w	d2,6(a5)
	rts

mt_rout2:
	lea	mt_data,a0
	move.l	a0,a3
	add.l	#$0c,a3
	move.l	a0,a2
	add.l	#$3b8,a2
	add.l	#$43c,a0
	move.l	mt_partnrplay(PC),d0
	moveq	#0,d1
	move.b	(a2,d0),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.l	mt_partnote(PC),d1
	move.l	d1,mt_partpoint
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_aud1temp(PC),a6
	bsr	mt_playit
	lea	$dff0b0,a5
	lea	mt_aud2temp(PC),a6
	bsr	mt_playit
	lea	$dff0c0,a5
	lea	mt_aud3temp(PC),a6
	bsr	mt_playit
	lea	$dff0d0,a5
	lea	mt_aud4temp(PC),a6
	bsr	mt_playit
	move.w	#$01f4,d0
mt_rls:	dbf	d0,mt_rls

	move.w	#$8000,d0
	or.w	mt_dmacon,d0
	move.w	d0,$dff096

	lea	mt_aud4temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice3
	move.l	10(a6),$dff0d0
	move.w	#1,$dff0d4
mt_voice3:
	lea	mt_aud3temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice2
	move.l	10(a6),$dff0c0
	move.w	#1,$dff0c4
mt_voice2:
	lea	mt_aud2temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice1
	move.l	10(a6),$dff0b0
	move.w	#1,$dff0b4
mt_voice1:
	lea	mt_aud1temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice0
	move.l	10(a6),$dff0a0
	move.w	#1,$dff0a4
mt_voice0:
	move.l	mt_partnote(PC),d0
	add.l	#$10,d0
	move.l	d0,mt_partnote
	cmp.l	#$400,d0
	bne.s	mt_stop
mt_higher:
	clr.l	mt_partnote
	addq.l	#1,mt_partnrplay
	moveq	#0,d0
	move.w	mt_maxpart(PC),d0
	move.l	mt_partnrplay(PC),d1
	cmp.l	d0,d1
	bne.s	mt_stop
	clr.l	mt_partnrplay
;	st	Pflag
mt_stop:tst.w	mt_status
	beq.s	mt_stop2
	clr.w	mt_status
	bra.s	mt_higher
mt_stop2:
	rts

mt_playit:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2

	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_nosamplechange

	moveq	#0,d3
	lea	mt_samples(PC),a1
	move.l	d2,d4
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2),4(a6)
	move.w	(a3,d4.l),8(a6)
	move.w	2(a3,d4.l),18(a6)
	move.w	4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,4(a6)
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),8(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
	bra.s	mt_nosamplechange

mt_displace:
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
mt_nosamplechange:
	move.w	(a6),d0
	and.w	#$fff,d0
	tst.w	d0
	beq.s	mt_retrout
	move.w	(a6),16(a6)
	move.w	20(a6),$dff096
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	(a6),d0
	and.w	#$fff,d0
	move.w	d0,6(a5)
	move.w	20(a6),d0
	or.w	d0,mt_dmacon

mt_retrout:
	tst.w	(a6)
	beq.s	mt_nonewper
	move.w	(a6),22(a6)

mt_nonewper:
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$0b,d0
	beq.s	mt_posjmp
	cmp.b	#$0c,d0
	beq.s	mt_setvol
	cmp.b	#$0d,d0
	beq.s	mt_break
	cmp.b	#$0e,d0
	beq.s	mt_setfil
	cmp.b	#$0f,d0
	beq.s	mt_setspeed
	rts

mt_posjmp:
	not.w	mt_status
	moveq	#0,d0
	move.b	3(a6),d0
	subq.b	#1,d0
	move.l	d0,mt_partnrplay
	rts

mt_setvol:
	move.b	3(a6),8(a5)
	rts

mt_break:
	not.w	mt_status
	rts

mt_setfil:
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#1,d0
	rol.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_setspeed:
	move.b	3(a6),d0
	and.b	#$0f,d0
	beq.s	mt_back
	clr.w	mt_counter
	move.b	d0,mt_cool+3
mt_back:rts

mt_aud1temp:
	dcb.w	10,0
	dc.w	1
	dcb.w	2,0
mt_aud2temp:
	dcb.w	10,0
	dc.w	2
	dcb.w	2,0
mt_aud3temp:
	dcb.w	10,0
	dc.w	4
	dcb.w	2,0
mt_aud4temp:
	dcb.w	10,0
	dc.w	8
	dcb.w	2,0

mt_partnote:	dc.l	0
mt_partnrplay:	dc.l	0
mt_counter:	dc.w	0
mt_partpoint:	dc.l	0
mt_samples:	dc.l	0
mt_sample1:	dcb.l	31,0
mt_maxpart:	dc.w	0
mt_dmacon:	dc.w	0
mt_status:	dc.w	0

mt_arpeggio:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000

mt_data:	incbin	source_1:modules/mod.tune
				;the first value represents the length
				;of the module


