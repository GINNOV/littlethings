**************************************************************************
*  here is the semi completed  source code to a game i started coding
*  quite some time ago. I release  it to public domain for people to look
*  at  and learn from, to modify or do  generally whatever.
*  Its 100% coded  in 68000 assember and should compile  using devpac 2
*  I have just  done a test  compile  on a  stock 2mb A1200  using the 
*  low memory assemble  option and  it  compiled fine.
*  the  source contains mainly contains cpu copy routines and runs pretty
*  well of alot of flags.. Rather a slack effort (although i thought
*  it was great at the time..
*
*  PLEASE NOTE THIS PROJECT IS NOT FINISHED AND WILL PROB NEVER BE
*  FINISHED BY ME. THERE WERE ALOT OF PLANS I HAD FOR THIS BUT TIME
*  RAN AWAY FROM ME.
*
*  TO  MAKE THIS BABY  WORK
*   use the keypad for movement.
*   also certain keys do certain thiings (sortof) during gameplay  
* LMB to  exit.
* there are 3 maps implimented so far. default map is 1
* to  change maps you will need to do it before compiling
* change the variables  SECTION and MAPSEEN  to  change maps
*
*
* if you use this for any medium please  let me  know..
*
* you can email me at dan@qldnet.com.au
* 
**************************************************************************










***************************************************************
** TO DO
**<DONE>1> MAKE THE MAP DISPLAY VARIABLE ADJUST TO THE SECTION MAPTYPE#
**<DONE>2> MAKE READ PATH WITH VARIABLE PATHS FOR EACH MAP FOR CURRENT MAP
**<DONE>3> IMPLIMENT STARTING POSITION AND CROSS REFS FOR CHARACTER ON
**	   DIFFERENT MAPS	0,1,2
**<DONE>4> IMPLIMENT TEXT RUNNER
**	5> IMPLIMENT BLITTER COPY INSTEAD OF CPU COPY
**<DONE>6> IMPLIMENT RANDOM ENCOUNTERS 
**<DONE>7> IMPLIMENTED FAST RAM OPTION
**	8> IMPLIMENT THE SCORE SCREEN AT BOTTOM
**      9> INTERACTION WITH VISIBLE OBJECTS
**      C> IMPLIMENT SOUND EFFECTS
**	E> IMPLIMENT MORE MAP SIZES	(1*2,2*3,3*3)
***************************************************************

	Section StartUpCode,Code
	opt	w-,o+,c+,NODEBUG

	include graphics/gfxbase.i
	include	graphics/graphics_lib.i
	include	exec/exec_lib.i
	include exec/execbase.i
	include exec/tasks.i
	include dos/dosextens.i
	include intuition/intuition_lib.i
	include	intuition/intuition.i
***************************************************************
ml_output_size	=	40*256
ml_output_planes	=	5			;32 cols
sc_output_size	=	80*50
sc_output_planes	=	1
***************************************************************
*             start demo here
*********************************************************************
	bsr	initsystem
	lea	$dff000,a5		; base Register
	bsr	initint			; Set Interrupts
	bsr	StartCopper		; Start da copper
****************************************************************************
		;lea     pt_data,a0
		;jsr     pt_InitMusic

		bsr	setupoutput2	; SET UP STATS SCREEN AT BOTTOM
		bsr	setupoutput		; set up the frontend

		

		bsr	setstart	; get variables for map placement
					; and player start pos

		bsr	copydisplay		; display the map from x,y

		bsr	ml_saveoldbob
		bsr	ml_docharacterbob	; do character
****************************************************************************
mouse:		bsr	checkmessagetonuke
		bsr	mainlandcheckkeyroutine
		btst	#6,$bfe001
		beq.s	.end
		jmp	mouse
.end		jmp 	allova
		rts

****************************************************************************

***************************************************************************
section:	dc.b	0		;	0 [ 2*1 ]
					;	1 [ 3*2 ]
					;	2 [ 2*2 ]
					;	3 [ 1*2 ](not implimented)
					;	4 [ 2*3 ](not implimented)
					;	5 [ 3*3 ](not implimented)
		even			
mapseen:	dc.b	0		;	0 montezumas pass (2*1)
					;	1 maze	(3*2)
					;	2 city	(2*2)
		even
player_level:	dc.b	0		;	players level
		even
****************************************************************************
action_armour:	cmp.b	#0,mode
		bne	cant_armour
		bsr	Select_armour
		rts
cant_armour	bsr     cantdothathere
		rts	;select armour

action_weapon:	cmp.b	#0,mode
		bne	cant_weapon
		bsr	Select_weapon
		rts
cant_weapon	bsr	cantdothathere
		rts

action_fight:	cmp.b	#1,mode
		bne	cant_fight
		bsr	fight_foe
		
		rts
cant_fight	bsr	cantdothathere
		rts	;attack person

action_magic:	bsr	Select_spell
		rts	;cast spell

action_get:	bsr	get_item
		rts

action_use:	bsr	use_item
		rts

action_buy:	cmp.b	#1,mode
		bne	cant_buy
		bsr	buy_from
		rts
cant_buy	bsr	cantdothathere
		rts

action_sell:	cmp.b	#1,mode
		bne	cant_sell
		bsr	sell_to
		rts
cant_sell	bsr	cantdothathere
		rts
		
action_talk:	cmp.b	#1,mode
		bne	cant_talk
		bsr	talk_to
		rts
cant_talk	bsr	cantdothathere
		rts
action_open:	cmp.b	#1,mode
		bne	cant_open
		bsr	open_it
		rts
cant_open	bsr	cantdothathere
		rts
action_pass:	add.b	#1,section	;testing
		add.b	#1,mapseen	
		cmp.b	#3,section
		bne	.stillinplay
		move.b	#0,section
		move.b	#0,mapseen
.stillinplay	bsr     setstart		; init all variables
		bsr     copydisplay		; show current page
		bsr	ml_saveoldbob		; save old spot
		bsr	ml_docharacterbob	; do character
		bsr	loop13
		bsr	loop13
		bsr	loop13
;		bsr     cantdothathere
		rts
****************************************************************************
fight_foe:	bsr	clearline1
		move.b	#0,slowyn
		move.w	#(80*1),cxpos
		move.l	#fight_text1,textpt
		bsr	domsg
		bsr	loop13
		move.l	#0,eraser1
		rts
fight_text1:	dc.b	"YOU DRAW YOUR WEAPON AGAINST THIS FOOL!",0
		even		
****************************************************************************
open_it:	bsr     clearline1
		move.b  #0,slowyn
		move.w  #(80*1),cxpos
		move.l  #open_text1,textpt
		bsr     domsg
		bsr     loop13
		move.l  #0,eraser1
		rts
open_text1:	dc.b	"YOU TRY TO OPEN THIS THING",0
		even		
****************************************************************************
talk_to:	bsr     clearline1
		move.b	#0,slowyn
		move.w	#(80*1),cxpos
		move.l  #talk_text1,textpt
		bsr	domsg
		bsr	loop13
		move.l	#0,eraser1
		rts
talk_text1:	dc.b	"YOU GREET THE TRAVELLER",0
		even		
****************************************************************************
buy_from:	bsr	clearline1
		move.b	#0,slowyn
		move.w	#(80*1),cxpos
		move.l	#buy_text1,textpt
		bsr	domsg
		bsr	loop13
		move.l	#0,eraser1
		rts
buy_text1:	dc.b	"HMMM LOTS OF THINGS TO BUY...",0
		even
****************************************************************************
sell_to:	bsr	clearline1
		move.b	#0,slowyn
		move.w	#(80*1),cxpos
		move.l	#sell_text1,textpt
		bsr	domsg
		bsr	loop13
		move.l	#0,eraser1
		rts
sell_text1:	dc.b	"IM STRAPPED FOR CASH..... GOTTA SELL SOME GOODS",0
		even
****************************************************************************
get_item:
		bsr     clearline1
		move.b	#0,slowyn
		move.w	#(80*1),cxpos
		move.l	#get_text1,textpt
		bsr	domsg
		bsr	loop13
		move.l	#0,eraser1
		rts
get_text1:	dc.b	"HEY MAN, I GOT IT!",0
		even
****************************************************************************				
use_item:
		bsr     clearline1
		move.b	#0,slowyn
		move.w	#(80*1),cxpos
		move.l	#use_text1,textpt
		bsr	domsg
		bsr	loop13
		move.l  #0,eraser1
		rts
use_text1:	dc.b	"WOW! THIS DOES SOMETHING!",0
		even		
****************************************************************************
meetrandom:
		move.w  #$0014,randommax	;maxrnd#-1 ->d0
		bsr	GetRandom	; 0-9
		
		cmp.w	#$0000,d0
		bne	.pencounter1
		move.l  #mpmessage_0text,textpt
		bsr	meet_line1p
		rts
.pencounter1	cmp.w	#$0001,d0
		bne	.pencounter2
		move.l  #mpmessage_1text,textpt
		bsr     meet_line1p
		rts
.pencounter2	cmp.w	#$0002,d0
		bne	.pencounter3
		move.l  #mpmessage_2text,textpt
		bsr     meet_line1p
		rts
.pencounter3	cmp.w	#$0003,d0
		bne     .pencounter4
		move.l  #mpmessage_3text,textpt
		bsr	meet_line1p
		rts
.pencounter4	cmp.w	#$0004,d0
		bne	.pencounter5
		move.l  #mpmessage_4text,textpt
		bsr	meet_line1p
		rts
.pencounter5	cmp.w	#$0005,d0
		bne	.pencounter6
		move.l  #mpmessage_5text,textpt
		bsr	meet_line1p
		rts
.pencounter6	cmp.w	#$0006,d0
		bne     .pencounter7
		move.l  #mpmessage_6text,textpt
		bsr     meet_line1p
		rts
.pencounter7	cmp.w	#$0007,d0
		bne	.pencounter8
		move.l  #mpmessage_7text,textpt
		bsr	meet_line1p
		rts
.pencounter8	cmp.w	#$0008,d0
		bne	.pencounter9
		move.l  #mpmessage_8text,textpt
		bsr     meet_line1p
		rts
.pencounter9	cmp.w	#$0009,d0
		bne     .pencounter10
		move.l  #mpmessage_9text,textpt
		bsr	meet_line1p
		rts
.pencounter10	cmp.w	#$000a,d0
		bne	.pencounter11
		move.l	#mpmessage_10text,textpt
		bsr	meet_line1p
		rts
.pencounter11	cmp.w	#$000b,d0
		bne	.pencounter12
		move.l	#mpmessage_11text,textpt
		bsr	meet_line1p
		rts
.pencounter12	cmp.w	#$000c,d0
		bne	.pencounter13
		move.l	#mpmessage_12text,textpt
		bsr	meet_line1p
		rts
.pencounter13	cmp.w	#$000d,d0
		bne	.pencounter14
		move.l	#mpmessage_13text,textpt
		bsr	meet_line1p
		rts
.pencounter14	cmp.w	#$000e,d0
		bne	.pencounter15
		move.l	#mpmessage_14text,textpt
		bsr	meet_line1p
		rts
.pencounter15	cmp.w	#$000f,d0
		bne	.pencounter16
		move.l	#mpmessage_15text,textpt
		bsr	meet_line1p
		rts
.pencounter16	cmp.w	#$0010,d0
		bne	.pencounter17
		move.l	#mpmessage_16text,textpt
		bsr	meet_line1p
		rts
.pencounter17	cmp.w	#$0011,d0
		bne	.pencounter18
		move.l	#mpmessage_17text,textpt
		bsr	meet_line1p
		rts
.pencounter18	cmp.w	#$0012,d0
		bne	.pencounter19
		move.l	#mpmessage_18text,textpt
		bsr	meet_line1p
		rts
.pencounter19	cmp.w	#$0013,d0
		bne	.pencounter20
		move.l	mpmessage_19text,textpt
		bsr	meet_line1p
		rts
.pencounter20	cmp.w	#$0014,d0
		bne	.pencounter21
		move.l	mpmessage_20text,textpt
		bsr	meet_line1p
		rts
.pencounter21	cmp.w	#$0015,d0
		bne	.pencounter22
		move.l	mpmessage_21text,textpt
		bsr	meet_line1p
		rts
.pencounter22	rts		
************************************************************************
meet_line1p:	move.l  #0,eraser1
		bsr	clearline1	; clear output
		move.b  #1,slowyn	; turn off slow text
		move.w  #(80*1),cxpos	; destination
		bsr	domsg
		move.b	#1,mode		;set key mode
		bsr	loop13
		bsr	loop13
		bsr	loop13
		move.l	#0,eraser1	; reset line nuke timer
		rts
		even
mpmessage_0text:	dc.b	"*APEMEN* HP:1D6+9 AT:12 DEF:5 MD:2 MOVE:8",0
		even
mpmessage_1text:	dc.b	"*BASILISK* HP:1D6+13 AT:16 DEF:5 MD:10 MOVE:8",0
		even
mpmessage_2text:	dc.b	"*BATS* HP:1 AT:11 DEF:9 MD:2 MOVE:1",0
		even
mpmessage_3text:	dc.b	"*BEAR* HP:2D6+20 AT:17 DEF:7 MD:3 MOVE:10",0
		even
mpmessage_4text:	dc.b	"*BULL* HP:2D6+16 AT:16 DEF:4 MD:3 MOVE:10",0
		even
mpmessage_5text:	dc.b	"*DEATH HEADS* HP:1D6+2 AT:16 DEF:18 MD:7 MOVE:6",0
		even
mpmessage_6text:	dc.b	"*DWARVES* HP:1D6+3 AT:11 DEF:5 MD:3 MOVE:10",0
		even
mpmessage_7text:	dc.b	"*ELVES* HP:3D6+10 AT:19 DEF:14 MD:8 MOVE 10",0
		even
mpmessage_8text:	dc.b	"*GARGOYLES* HP:3D6+4 AT:16 DEF:8 MD:6 MOVE:8/15",0
		even
mpmessage_9text:	dc.b	"*GIANT RATS* HP:1D6+1 AT:9 DEF:2 MD:2 MOVE:12",0
		even
mpmessage_10text:	dc.b	"*GIANT SCORPIONS* HP:3D6+9 AT:22 DEF:3 MD:4 MOVE:10",0
		even
mpmessage_11text:       dc.b    "*GIANT SPIDERS* HP:3D6+9 AT:22 DEF:3 MD:4 MOVE:10",0
		even
mpmessage_12text:       dc.b    "*GNOMES* HP:1D6+5 AT:15 DEF:2 MD:4 MOVE:15",0
		even
mpmessage_13text:       dc.b    "*GOBLINS* HP:1D6+4 AT:13 DEF:7 MD:5 MOVE:12",0
		even
mpmessage_14text:	dc.b	"*GORGONS* HP:1D6+8 AT:16 DEF:10 MA:19 MD:9 MOVE:10",0
		even
mpmessage_15text:       dc.b    "*HALFLINGS * HP:1D6+1 AT:9 DEF:5 MD:3 MOVE:8",0
		even
mpmessage_16text:       dc.b    "*HOBGOBLINS* HP:1D6+9 AT:16 DEF:10 MA:17 MD:7 MOVE:12",0
		even
mpmessage_17text:       dc.b    "*MANTICORE* HP:3D6+18 AT:20 DEF:12 MOVE:12",0
		even
mpmessage_18text:       dc.b    "*ORGES* HP:2D6+18 AT:20 DEF:12 MD:8 MOVE:10",0
		even
mpmessage_19text:       dc.b    "*ORCS* HP:1D6+3 AT:12 DEF:5 MD:3 MOVE:10",0
		even
mpmessage_20text:       dc.b    "*GHOULS* HP:1D6+10 AT:17 DEF:9 MD:7 MOVE:12",0
		even
mpmessage_21text:	dc.b	"*SKELETONS* HP:1D6+1 AT:11 DEF:5 MD:3 MOVE:10",0
		even	
mode:		dc.b	0
		even
****************************************************************************
cantdothathere:
		bsr	clearline1	; clear output
		move.b  #0,slowyn	; turn on slow text
		move.w  #(80*1),cxpos	; destination
		move.l	#message_2text,textpt
		bsr	domsg
		bsr     loop13
		move.l #0,eraser1
		rts
message_2text:	dc.b	"NO MAN, YOU CANT DO THAT RIGHT NOW.",0
		even
****************************************************************************
Select_armour:	
		bsr	clearline1
		move.b	#0,slowyn		;
		move.w	#(80*1),cxpos		;
		move.l	#message_1,textpt	;
		bsr	domsg			; display gameinfo
		bsr     loop13
		move.l	#0,eraser1
		rts
message_1:	dc.b    "CHOOSE YOUR MOST FABULOUS ARMOUR",0
		even
****************************************************************************
Select_weapon:	
		bsr	clearline1
		move.b	#0,slowyn		;
		move.w	#(80*1),cxpos		;
		move.l	#message_2,textpt	;
		bsr	domsg			; display gameinfo
		bsr     loop13
		move.l	#0,eraser1
		rts
message_2:	dc.b	"HANG 5, I GOTTA CHANGE WEAPONS DUDE!",0
		even
****************************************************************************
Select_spell:	
		bsr	clearline1
		move.b	#0,slowyn	;slow text 0y/1n
		move.w	#(80*1),cxpos
		move.l	#message_3,textpt
		bsr	domsg
		bsr     loop13
		move.l #0,eraser1	;reset nuke message clock
		rts
message_3:	dc.b		"SELECT SPELL",0
		even
**************************************************************************
****************************************************************************
checkmessagetonuke:	cmp.l	#120000,eraser1		;nuke after x vbl's
			bls	notlongenoughtonuke	;or 4 moves
			bsr	clearline1
			move.l	#0,eraser1
			rts
notlongenoughtonuke:	add.l	#1,eraser1
			rts			
eraser1:		dc.l	0
			even
****************************************************************************
**************************************************************************
clearline1:			; clears first line of information screen
		lea	sc_output_d+(80*1),a0
.cb1		move.b	#0,(a0)+
		add.w	#1,countbyte1
		cmp.w	#80*8,countbyte1
		bne	.cb1
		move.w	#0,countbyte1
		rts
countbyte1:	dc.w	0
		even
**************************************************************************
setstart:	
		move.l	#10,chxpos			;x = 0 on display screen
		move.l	#15,chypos			;y = 0 on display screen

		move.l	chxpos,d0
		move.l	chypos,d1
		move.l	d0,oldchxpos
		move.l	d1,oldchypos
;-------------------
		cmp.b	#0,mapseen	; montezumas pass
		bne	.notmap0

		move.l	#0,msxpos		; position to display from
		move.l	#0,msypos		; on the map x,y

		move.l	#2,chxpossy
		move.l	#12,chypossy

		MOVE.L	#1,CHARWANTPOSX
		MOVE.L	#11,CHARWANTPOSY

		add.l	#2,chxpos		; x start bytes
		add.l   #165,chypos		; y start pixels

		rts

.notmap0	cmp.b	#1,mapseen	; maze
		bne	.notmap1

		move.l	#44,msxpos		; position to display from
		move.l	#330,msypos		; on the map x,y
		
		move.l	#8,chxpossy	; grid reference X
		move.l	#12,chypossy	; grid reference Y
		
		MOVE.L	#29,CHARWANTPOSX ; get co'ords of grid(1-
		MOVE.L	#33,CHARWANTPOSY ; get co'ords of grid(1-

		add.l	#14,chxpos	;(chxpossy*2)-2
		add.l   #165,chypos	;(chypossy*15)-15

		rts

.notmap1	cmp.b	#2,mapseen	; city
		bne	.notmap2		

		move.l	#20,msxpos
		move.l	#330,msypos
		
		move.l	#3,chxpossy	; character on grid reference X 
		move.l	#10,chypossy	; character on grid reference Y (1-12)

		MOVE.L  #12,CHARWANTPOSX	;map grid (1-
		MOVE.L  #31,CHARWANTPOSY	;map grid (1-		

		add.l   #4,chxpos
		add.l   #135,chypos


.notmap2	rts
****************************************************************************
mapnorth:
		add.l	#1,CHARWANTPOSY
		moveq.l	#5,d4
.pace1		sub.l	#15,msypos		
		bsr	copydisplay		; display the map from x,y
		dbf	d4,.pace1
		bsr	loop13
		rts
mapsouth:
		sub.l	#1,CHARWANTPOSY
		moveq.l	#5,d4
.pace2		add.l	#15,msypos
		bsr	copydisplay
		dbf	d4,.pace2
		bsr	loop13
		rts
mapeast:
		sub.l	#1,CHARWANTPOSX
		moveq.l	#5,d4
.pace3		add.l	#2,msxpos
		bsr	copydisplay
		dbf	d4,.pace3
		bsr	loop13
		rts
mapwest:
		add.l	#1,CHARWANTPOSX
		moveq.l	#5,d4
.pace4		sub.l	#2,msxpos
		bsr	copydisplay
		dbf	d4,.pace4
		bsr	loop13
		rts
****************************************************************************
copydisplay:
		movem.l	d0-d7/a0-a6,-(sp)
		moveq.l	#10,d0
		moveq.l	#15,d1
		moveq.l	#0,d2
		moveq.l	#0,d5
		move.l	d0,dsxstart
		move.l	d1,dsystart
****************************************************************************
		cmp.b	#0,section
		bne	.notmap0
		lea.l   mapdata,a0
		jmp	mapchosen
.notmap0	cmp.b	#1,section
		bne	.notmap1
		lea.l   mapdata1,a0
		jmp	mapchosen
.notmap1	cmp.b	#2,section
		bne	.notmap2
		lea.l   mapdata2,a0
		jmp	mapchosen
.notmap2	rts			; on error (section not= 0,1,2)
mapchosen:	lea.l	ml_output_d,a1

		bsr	calc_ds
		add.l	d2,a1
		add.l	d5,a0

		moveq.l	#127,d4
loop2		bsr	copypxlline
		add.b	#12,a1
		
		cmp.b	#0,section
		bne	.notsection0
		add.b	#52,a0		; 0=52 ! 1=92 ! 2=52
		jmp	mapchosen2
.notsection0	cmp.b	#2,section
		bne	.notsection2
		add.b	#52,a0
		jmp	mapchosen2
.notsection2	cmp.b	#1,section
		bne	.notsection1
		add.b	#92,a0
		jmp	mapchosen2
.notsection1	rts		

mapchosen2:	dbf	d4,loop2

		cmp.b	#0,section
		bne	.notsection0
		lea.l	mapdata+(128*80),a0   ;mapdata1,mapdata2+offsets
		jmp	mapchosen3		
.notsection0	cmp.b	#1,section
		bne	.notsection1
		lea.l	mapdata1+(128*120),a0
		jmp	mapchosen3			
.notsection1	cmp.b	#2,section
		bne	.notsection2
		lea.l	mapdata2+(128*80),a0
		jmp	mapchosen3
.notsection2	rts

mapchosen3	lea.l	ml_output_d+(128*40),a1
		bsr	calc_ds
		add.l	d2,a1
		add.l	d5,a0

		moveq.l	#51,d4
_loop3		bsr	copypxlline
		add.b	#12,a1

		cmp.b	#0,section
		bne	.notsection0
		add.b	#52,a0		; 0=52 ! 1=92 ! 2=52
		jmp	mapchosen4
.notsection0	cmp.b	#2,section
		bne	.notsection2
		add.b	#52,a0
		jmp	mapchosen4
.notsection2	cmp.b	#1,section
		bne	.notsection1
		add.b	#92,a0
		jmp	mapchosen4
.notsection1	rts		


mapchosen4	dbf	d4,_loop3
****************************************************************************
		cmp.b	#0,section
		bne	.notsection0
		lea.l   mapdata+20480,a0
		jmp	mapchosen5
.notsection0	cmp.b	#2,section
		bne	.notsection2
		lea.l   mapdata2+40960,a0
		jmp	mapchosen5
.notsection2	cmp.b	#1,section
		bne	.notsection1
		lea.l   mapdata1+61440,a0
		jmp	mapchosen5
.notsection1	rts		
mapchosen5	lea.l   ml_output_d+10240,a1
		bsr     calc_ds
		add.l   d2,a1
		add.l	d5,a0

		moveq.l	#127,d4
__loop3		bsr	copypxlline
		add.b	#12,a1

		cmp.b	#0,section
		bne	.notsection0
		add.b   #52,a0
		jmp	mapchosen7
.notsection0	cmp.b	#2,section
		bne	.notsection2
		add.b	#52,a0
		jmp	mapchosen7
.notsection2	cmp.b	#1,section
		bne	.notsection1
		add.b	#92,a0
		jmp	mapchosen7
.notsection1	rts		

mapchosen7	dbf	d4,__loop3


		cmp.b	#0,section
		bne	.notsection0
		lea.l   mapdata+20480+(128*80),a0
		jmp	mapchosen6
.notsection0	cmp.b	#2,section
		bne	.notsection2
		lea.l   mapdata2+40960+(128*80),a0
		jmp	mapchosen6
.notsection2	cmp.b	#1,section
		bne	.notsection1
		lea.l   mapdata1+61440+(128*120),a0
		jmp	mapchosen6
.notsection1	rts		

mapchosen6	lea.l	ml_output_d+10240+(128*40),a1
		bsr	calc_ds
		add.l	d2,a1
		add.l	d5,a0

		moveq.l	#51,d4
_loop3_		bsr	copypxlline
		add.b	#12,a1

		cmp.b	#0,section
		bne	.notsection0
		add.b   #52,a0
		jmp	mapchosen8
.notsection0	cmp.b	#2,section
		bne	.notsection2
		add.b	#52,a0
		jmp	mapchosen8
.notsection2	cmp.b	#1,section
		bne	.notsection1
		add.b	#92,a0
		jmp	mapchosen8
.notsection1	rts		
mapchosen8	dbf	d4,_loop3_
****************************************************************************
		cmp.b	#0,section
		bne	.notsection0
		lea.l   mapdata+(20480*2),a0
		jmp	mapchosen9
.notsection0	cmp.b	#2,section
		bne	.notsection2
		lea.l   mapdata2+(40960*2),a0
		jmp	mapchosen9
.notsection2	cmp.b	#1,section
		bne	.notsection1
		lea.l   mapdata1+(61440*2),a0
		jmp	mapchosen9
.notsection1	rts		
mapchosen9      lea.l   ml_output_d+(10240*2),a1
		bsr     calc_ds
		add.l   d2,a1
		add.l	d5,a0

		moveq.l	#127,d4
__loop4__		bsr	copypxlline
		add.b	#12,a1

		cmp.b	#0,section
		bne	.notsection0
		add.b   #52,a0
		jmp	mapchosen10
.notsection0	cmp.b	#2,section
		bne	.notsection2
		add.b	#52,a0
		jmp	mapchosen10
.notsection2	cmp.b	#1,section
		bne	.notsection1
		add.b	#92,a0
		jmp	mapchosen10
.notsection1	rts		
mapchosen10	dbf	d4,__loop4__

		cmp.b	#0,section
		bne	.notsection0
		lea.l   mapdata+(20480*2)+(128*80),a0
		jmp	mapchosen11
.notsection0	cmp.b	#2,section
		bne	.notsection2
		lea.l   mapdata2+(40960*2)+(128*80),a0
		jmp	mapchosen11
.notsection2	cmp.b	#1,section
		bne	.notsection1
		lea.l   mapdata1+(61440*2)+(128*120),a0
		jmp	mapchosen11
.notsection1	rts		
mapchosen11	lea.l	ml_output_d+(10240*2)+(128*40),a1
		bsr	calc_ds
		add.l	d2,a1
		add.l	d5,a0

		moveq.l	#51,d4
_0loop4		bsr	copypxlline
		add.b	#12,a1

		cmp.b	#0,section
		bne	.notsection0
		add.b   #52,a0
		jmp	mapchosen12
.notsection0	cmp.b	#2,section
		bne	.notsection2
		add.b	#52,a0
		jmp	mapchosen12
.notsection2	cmp.b	#1,section
		bne	.notsection1
		add.b	#92,a0
		jmp	mapchosen12
.notsection1	rts		
mapchosen12	dbf	d4,_0loop4
****************************************************************************

		cmp.b	#0,section
		bne	.notsection0
		lea.l   mapdata+(20480*3),a0
		jmp	mapchosen13
.notsection0	cmp.b	#2,section
		bne	.notsection2
		lea.l   mapdata2+(40960*3),a0
		jmp	mapchosen13
.notsection2	cmp.b	#1,section
		bne	.notsection1
		lea.l   mapdata1+(61440*3),a0
		jmp	mapchosen13
.notsection1	rts		
mapchosen13	lea.l   ml_output_d+(10240*3),a1
		bsr     calc_ds
		add.l   d2,a1
		add.l	d5,a0

		moveq.l	#127,d4
__loop5		bsr	copypxlline
		add.b	#12,a1

		cmp.b	#0,section
		bne	.notsection0
		add.b   #52,a0
		jmp	mapchosen14
.notsection0	cmp.b	#2,section
		bne	.notsection2
		add.b	#52,a0
		jmp	mapchosen14
.notsection2	cmp.b	#1,section
		bne	.notsection1
		add.b	#92,a0
		jmp	mapchosen14
.notsection1	rts		
mapchosen14	dbf	d4,__loop5

		cmp.b	#0,section
		bne	.notsection0
		lea.l   mapdata+(20480*3)+(128*80),a0
		jmp	mapchosen15
.notsection0	cmp.b	#2,section
		bne	.notsection2
		lea.l   mapdata2+(40960*3)+(128*80),a0
		jmp	mapchosen15
.notsection2	cmp.b	#1,section
		bne	.notsection1
		lea.l   mapdata1+(61440*3)+(128*120),a0
		jmp	mapchosen15
.notsection1	rts		
mapchosen15	lea.l	ml_output_d+(10240*3)+(128*40),a1
		bsr	calc_ds
		add.l	d2,a1
		add.l	d5,a0

		moveq.l	#51,d4
_loop5__	bsr	copypxlline
		add.b	#12,a1

		cmp.b	#0,section
		bne	.notsection0
		add.b   #52,a0
		jmp	mapchosen16
.notsection0	cmp.b	#2,section
		bne	.notsection2
		add.b	#52,a0
		jmp	mapchosen16
.notsection2	cmp.b	#1,section
		bne	.notsection1
		add.b	#92,a0
		jmp	mapchosen16
.notsection1	rts		
mapchosen16	dbf	d4,_loop5__




****************************************************************************
		cmp.b	#0,section
		bne	.notsection0
		lea.l   mapdata+(20480*4),a0
		jmp	mapchosen17
.notsection0	cmp.b	#2,section
		bne	.notsection2
		lea.l   mapdata2+(40960*4),a0
		jmp	mapchosen17
.notsection2	cmp.b	#1,section
		bne	.notsection1
		lea.l   mapdata1+(61440*4),a0
		jmp	mapchosen17
.notsection1	rts		
mapchosen17	lea.l   ml_output_d+(10240*4),a1
		bsr     calc_ds
		add.l   d2,a1
		add.l	d5,a0

		moveq.l	#127,d4
_loop6		bsr	copypxlline
		add.b	#12,a1

		cmp.b	#0,section
		bne	.notsection0
		add.b   #52,a0
		jmp	mapchosen18
.notsection0	cmp.b	#2,section
		bne	.notsection2
		add.b	#52,a0
		jmp	mapchosen18
.notsection2	cmp.b	#1,section
		bne	.notsection1
		add.b	#92,a0
		jmp	mapchosen18
.notsection1	rts		
mapchosen18	dbf	d4,_loop6

		cmp.b	#0,section
		bne	.notsection0
		lea.l   mapdata+(20480*4)+(128*80),a0
		jmp	mapchosen19
.notsection0	cmp.b	#2,section
		bne	.notsection2
		lea.l   mapdata2+(40960*4)+(128*80),a0
		jmp	mapchosen19
.notsection2	cmp.b	#1,section
		bne	.notsection1
		lea.l   mapdata1+(61440*4)+(128*120),a0
		jmp	mapchosen19
.notsection1	rts		
mapchosen19	lea.l   ml_output_d+(10240*4)+(128*40),a1
		bsr	calc_ds
		add.l	d2,a1
		add.l	d5,a0

		moveq.l	#51,d4
_loop6___	bsr	copypxlline
		add.b	#12,a1

		cmp.b	#0,section
		bne	.notsection0
		add.b   #52,a0
		jmp	mapchosen20
.notsection0	cmp.b	#2,section
		bne	.notsection2
		add.b	#52,a0
		jmp	mapchosen20
.notsection2	cmp.b	#1,section
		bne	.notsection1
		add.b	#92,a0
		jmp	mapchosen20
.notsection1	rts		
mapchosen20	dbf	d4,_loop6___
		movem.l	(sp)+,d0-d7/a0-a6
		rts
****************************************************************************			
calc_ds:	moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d6
		moveq.l	#0,d7
		moveq.l	#0,d5

		move.l	dsxstart,d0
		move.l	dsystart,d1
		mulu.l	#40,d1
		add.l	d1,d0
		move.l	d0,d2

		move.l	msxpos,d6
		move.l	msypos,d7

		cmp.b	#0,section
		bne	.notsection0
		mulu.l  #80,d7
		jmp	mapchosen21
.notsection0	cmp.b	#2,section
		bne	.notsection2
		mulu.l  #80,d7
		jmp	mapchosen21
.notsection2	cmp.b	#1,section
		bne	.notsection1
		mulu.l  #120,d7
		jmp	mapchosen21
.notsection1	rts		
mapchosen21	add.l	d7,d6
		move.l	d6,d5
		rts
msypos:	dc.l	0
msxpos:	dc.l	0
****************************************************************************
copypxlline:	moveq.l	#6,d3
.loop		move.l	(a0)+,(a1)+
		dbf	d3,.loop
		rts
****************************************************************************
dsstart:	dc.l	0
dsxstart:	dc.l	0
dsystart:	dc.l	0
****************************************************************************
action_north:	
		sub.l	#1,CHARWANTPOSY
		bsr	checkpath
		cmp.b	#1,mok1
		bne	noactionnorth2

		bsr     checkifcannorth
		cmp.b	#1,oknorth
		bne	noactionnorth
		move.b	#0,oknorth
		
		add.l   #30000,eraser1
		
		bsr	ml_getoldbob
		sub.l	#15,chypos
		bsr	ml_saveoldbob
		bsr     ml_docharacterbob
		bsr	checkencounter
		bsr	loop13
		rts
noactionnorth	move.l	#120,chypos	; bob spot
		move.l	#8,chypossy	; grid reference
		bsr	mapnorth
		bsr     ml_saveoldbob
		bsr     ml_docharacterbob
		rts
noactionnorth2	add.l	#1,CHARWANTPOSY
		rts
				
action_east:	
		add.l	#1,CHARWANTPOSX
		bsr	checkpath
		cmp.b	#1,mok1
		bne	noactioneast2
		
		bsr     checkifcaneast
		cmp.b	#1,okeast
		bne	noactioneast
		move.b	#0,okeast

		add.l	#30000,eraser1

		bsr	ml_getoldbob
		add.l	#2,chxpos
		bsr	ml_saveoldbob
		bsr	ml_docharacterbob
		bsr     checkencounter
		bsr	loop13
		rts
noactioneast	move.l	#7,chxpossy
		move.l	#22,chxpos
		bsr	mapeast
		bsr     ml_saveoldbob
		bsr     ml_docharacterbob
		rts
noactioneast2	sub.l	#1,CHARWANTPOSX
		rts

action_south:	add.l	#1,CHARWANTPOSY
		bsr	checkpath
		cmp.b	#1,mok1
		bne	noactionsouth2

		bsr     checkifcansouth
		cmp.b	#1,oksouth
		bne	noactionsouth
		move.b	#0,oksouth
		
		add.l   #30000,eraser1
		
		bsr	ml_getoldbob
		add.l   #15,chypos
		bsr	ml_saveoldbob
		bsr	ml_docharacterbob
		bsr     checkencounter
		bsr	loop13
		rts
noactionsouth	move.l	#75,chypos	; bob spot
		move.l	#5,chypossy	; grid reference
		bsr	mapsouth
		bsr     ml_saveoldbob
		bsr     ml_docharacterbob
		rts
noactionsouth2:	sub.l	#1,CHARWANTPOSY
		rts

action_west:	sub.l	#1,CHARWANTPOSX
		bsr	checkpath
		cmp.b	#1,mok1
		bne	noactionwest2
		bsr	checkifcanwest
		cmp.b	#1,okwest
		bne	noactionwest	
		move.b	#0,okwest
		
		add.l   #30000,eraser1
		
		bsr	ml_getoldbob
		sub.l	#2,chxpos
		bsr	ml_saveoldbob
		bsr     ml_docharacterbob
		bsr     checkencounter
		bsr	loop13
		rts
noactionwest	move.l	#8,chxpossy
		move.l	#24,chxpos
		bsr	mapwest
		bsr     ml_saveoldbob
		bsr     ml_docharacterbob
		rts
noactionwest2	add.l	#1,CHARWANTPOSX
		rts										
****************************************************************************
checkencounter:	move.w  #$000a,randommax	;max rnd#-1 ->d0
		bsr	GetRandom
		cmp.w	#$0001,d0
		beq	encounter
noencounter:	rts
encounter:      move.w	#$000f,randommax	;max rnd #-1 -> d0
		bsr     GetRandom
		cmp.w	#$0001,d0
		beq	encounter2
		cmp.w	#$0003,d0
		beq	encounter2
		cmp.w	#$0005,d0
		beq	encounter2
		cmp.w	#$0006,d0
		beq	encounter2
		cmp.w	#$0007,d0
		beq	encounter2
		cmp.w	#$0009,d0
		beq	encounter2
		cmp.w	#$000b,d0
		beq     encounter2
		cmp.w	#$000c,d0
		beq     encounter2
		cmp.w	#$000f,d0
		beq	encounter2
		rts		
encounter2	bsr	meetrandom
		rts

****************************************************************************
 dc.b "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
****************************************************************************

MAP0DATA:	DC.B	"  T H                             TTTTTT"
		DC.B	"T T                   LLLLLL   OWWWWWWWT"
		DC.B	"  TT                  LLLSSL      111FWT"
		DC.B	" T     WWWWWWWWWW     LLHSSL   OWWWWWWWT"
		DC.B	"TTTT  RWF       W     LLPSSL      TTT   "
		DC.B	"T     RW        W     LLSSLL     T    R "
		DC.B	"T T    W WWWWW      SRLLSSLL     T PRRR "
		DC.B	"T TT   W W  RW  WP  RRLLSSSL     T R    "
		DC.B	"T TTT  WWW  RWE W     LLRRSL     T R TR "
		DC.B	"T T          WFEW     LLRCSL    T  R TRR"
		DC.B	"T TT         WWWW     LLRRRLT     TR    "
		DC.B	"T TT                  LLLLLL    TTTTRRR "
		DC.B	"T TT                  LLLLLL      TTRTR "
		DC.B	"T TTT                 LLLLLL      TTR   "
		DC.B	"T   T                 LLLLLL     TTTR RT"
		DC.B	"T   TT                LLLLLL    TTTTT  C"
****************************************************************************
 dc.b "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
****************************************************************************
MAP1DATA:
   DC.B	"WWWWWWWWWWWWWWWWWWWW           WWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
   DC.B	"W W W W W W W W W  W WWWWWWWWW W               W           W"
   DC.B	"W W                W W       W W           WWW W WWWWWWW W W"
   DC.B	"W   WWWWWWWWWWWWWWWWWW WWWWW W W           W W W W     W W W"
   DC.B	"W W                        W WWWWWWWWWWWWWWW W W W LLL W W W"
   DC.B	"W W W W  WWWW WWWWWWWWWWWW W W             W W W W L L W W W"
   DC.B	"W W WWWWWW  W            W W W WWWWWWWWWWW W W W W LLL W W W"
   DC.B	"W W    W W  WWWWWW WWWWW W     W         W W W W W     W W W"
   DC.B	"W W W  WWW     W W     W W W W WWWWWWWWW W W W W WWW WWW W W"
   DC.B	"W WWWW  W   W  WWWWWWW W W W             W W W W W W W W W W"
   DC.B	"W W     W WWW WW   W W W W W W WWWWWWWWW W W W         W W W"
   DC.B	"W   W W W W W  W   W W W W W W W       W W W WWWWWWWWW W W W"
   DC.B	"W WWWWW W   WW W   W W W W W W W WWWWW W   W           W W W"
   DC.B	"WWW   WWWW  W  W   W W W WWW W W     W WWWWWWWWWWWWWWWWW W W"
   DC.B	"W WWW W  WWWW WW   W W W     W WWWWWWW W               W W W"
   DC.B	"W     W     W  W   W W WWWWWWW         W WWWWWWWWWWWWW W W W"
   DC.B	"W WWW W W   WW W   W W W       WWWWWWWWW W           W W   W"
   DC.B	"W W   W W   W  W   W W W WWWWW         W W WWWWWWWWW W W W W"
   DC.B	"W W   W W   W WW   W W W W   W WWWWWWW W W W       W W W W W"
   DC.B	"W W   W W   W  W   W W W W W W W     W   W W WWWWW W W W W W"
   DC.B	"W W   W W   WW W   W W W WWW W W WWWWW W W W W       W W W W"
   DC.B	"W WWWWW WWWWW  W   W W W     W W       W   W W WWWWWWW W W W"
   DC.B	"W              WWWWW W WWWWWWWWWWWWWWWWW W W W W       W W W"
   DC.B	"W WWWWWWWWWWWW                W          W W W W WWWWWWW W W"
   DC.B	"W            WW WWWWWWWWWWWWW WWWWWWWW WWW W W W W       W W"
   DC.B	"W WWWWWWWWWWWW  W W W W W W W W W W W  W W W W W W WWW W W W"
   DC.B	"W            W  W W W W W W W W W W W WW W W W W W W W W W W"
   DC.B	"W WWWWWWWWWWWWWWW W W W W W W W W W W W  W W W W W W W W W W"
   DC.B	"W                 W W W W W W W W W W W  W W W W W W W W W W"
   DC.B	"W WWWWWWWWWWWWWWW   W   W   W   W   W W  W W WWW W W W W W W"
   DC.B	"W            W  WW WWW WWW WWW WWW WW W  W W     W W W WWW W"
   DC.B	"W WWWWWWWWWWWW  W          W     W    W  W WWWWWWW W W     W"
   DC.B	"W               W          W     W       W           W W W W"
   DC.B	"WWWWWWWWWWWWWWWWWWWWWWWWWWWW     WWWWWWWWWWWWWWWWWWWWWWWWWWW"
   DC.B	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"

****************************************************************************
 dc.b "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
****************************************************************************

MAP2DATA:
	DC.B	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"W                                      W"
	DC.B	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
	
***************************************************************************
checkifcansouth:	move.l	chypossy,d0
			cmp.l	#11,d0
			bge	.nosouthonmap
			
			add.l   #1,chypossy
			move.b	#1,oksouth
.nosouthonmap		rts			
****************************************************************************
checkifcannorth:	move.l	chypossy,d0
			cmp.l	#2,d0
			bls	.nonorthonmap
			sub.l	#1,chypossy
			move.b	#1,oknorth
.nonorthonmap		rts			
****************************************************************************
checkifcaneast:		move.l	chxpossy,d0
			cmp.l	#13,d0
			bge	.noeastonmap		
			add.l	#1,chxpossy
			move.b	#1,okeast
.noeastonmap		rts
****************************************************************************
checkifcanwest		move.l	chxpossy,d0
			cmp.l	#2,d0
			bls	.nowestonmap
			sub.l	#1,chxpossy
			move.b	#1,okwest
.nowestonmap:		rts			
****************************************************************************
checkpath:		move.b	#0,mok1
			move.l	CHARWANTPOSX,d0
			move.l	CHARWANTPOSY,d1
			
			
			cmp.b	#0,section
			bne	.notmap0
			mulu.w	#40,d1
			jmp	plotted
.notmap0		cmp.b	#1,section
			bne	.notmap1
			mulu.w	#60,d1
			jmp	plotted
.notmap1		cmp.b	#2,section
			bne	.notmap2
			mulu.w	#40,d1
			jmp	plotted
.notmap2		rts			; error not 0,1,2			
plotted:		add.w	d0,d1

			cmp.b	#0,mapseen
			bne	.notmap0
			lea	MAP0DATA,a0
			jmp	mapped
.notmap0		cmp.b	#1,mapseen
			bne	.notmap1
			lea	MAP1DATA,a0
			jmp	mapped
.notmap1		cmp.b	#2,mapseen
			bne	.notmap2
			lea	MAP2DATA,a0
			jmp	mapped
.notmap2		rts			; error not 0,1,2
mapped:			add.w	d1,a0
			moveq.l	#0,d0
			move.b	(a0),d0
			cmp.b	#" ",d0		; ' ' = nothing..
			bne	.gothere
			move.b	#1,mok1		;yes can move there
			move.b	#0,mode		; setkeymode
			rts
.gothere		rts
mok1:	dc.b	0,0
****************************************************************************
chxpossy:	dc.l	0
chypossy:	dc.l	0
oknorth:	dc.b	0
oksouth:	dc.b	0
okeast:		dc.b	0
okwest:		dc.b	0
CHARWANTPOSX:	DC.L	0
CHARWANTPOSY:	DC.L	0
****************************************************************************
ml_getoldbob:	move.l	oldchxpos,d0
		move.l	oldchypos,d1
		mulu	#40,d1
		add	d1,d0
		
		lea	storebob_d,a0
		lea	ml_output_d,a1
		add	d0,a0
		add	d0,a1
		bsr	ml_oldbob_put
		
		lea	storebob_d+10240,a0
		lea	ml_output_d+10240,a1
		add	d0,a0
		add	d0,a1
		bsr	ml_oldbob_put

		lea	storebob_d+(10240*2),a0
		lea	ml_output_d+(10240*2),a1
		add	d0,a0
		add	d0,a1
		bsr	ml_oldbob_put

		lea	storebob_d+(10240*3),a0
		lea	ml_output_d+(10240*3),a1
		add	d0,a0
		add	d0,a1
		bsr	ml_oldbob_put

		lea	storebob_d+(10240*4),a0
		lea	ml_output_d+(10240*4),a1
		add	d0,a0
		add	d0,a1
		bsr	ml_oldbob_put
		rts

ml_oldbob_put:	moveq.l	#14,d1
.obploop	move.w	(a0)+,(a1)+
		add.b	#38,a0
		add.b	#38,a1
		dbf	d1,.obploop
		rts
****************************************************************************
ml_saveoldbob:
		move.l	chxpos,d0
		move.l	chypos,d1
		move.l	d0,oldchxpos
		move.l	d1,oldchypos
		
		mulu	#40,d1
		add	d1,d0
		
		lea	ml_output_d,a0
		lea	storebob_d,a1
		add     d0,a0
		add	d0,a1
		bsr	ml_oldbob_save
		
		lea	ml_output_d+10240,a0
		lea	storebob_d+10240,a1
		add	d0,a0
		add	d0,a1
		bsr	ml_oldbob_save
		
		lea	ml_output_d+(10240*2),a0
		lea	storebob_d+(10240*2),a1
		add	d0,a0
		add	d0,a1
		bsr	ml_oldbob_save
		
		lea	ml_output_d+(10240*3),a0
		lea     storebob_d+(10240*3),a1
		add	d0,a0
		add	d0,a1
		bsr	ml_oldbob_save
		
		lea	ml_output_d+(10240*4),a0
		lea     storebob_d+(10240*4),a1
		add	d0,a0
		add	d0,a1
		bsr	ml_oldbob_save
		rts

ml_oldbob_save:	moveq.l	#14,d1
.obsloop	move.w	(a0)+,(a1)+
		add.b	#38,a0
		add.b	#38,a1
		dbf	d1,.obsloop
		rts
****************************************************************************
oldchxpos:	dc.l	0
oldchypos:	dc.l	0
****************************************************************************
ml_docharacterbob:
		
		move.l	chxpos,d0
		move.l	chypos,d1

		
		cmp.b	#1,whichwayman
		bne	equa0
		move.l	#94,chuse	;94 = player character left
		move.l	chuse,d2
		jmp	endeq
equa0:		move.l	#92,chuse	;92 = player character right
		move.l	chuse,d2

endeq:		mulu	#40,d1
		add	d1,d0		;x+y position in d0
		
		lea	bobs_d,a0
		lea	ml_output_d,a1
		add	d0,a1		; x/y pos to a1
		add	d2,a0		; add pos to a0 (first bob)
		bsr	char_copyloop

		lea	bobs_d+2520,a0
		lea	ml_output_d+10240,a1
		add	d0,a1
		add	d2,a0
		bsr	char_copyloop
		
		lea	bobs_d+(2*2520),a0
		lea	ml_output_d+(2*10240),a1
		add	d0,a1
		add	d2,a0
		bsr	char_copyloop

		lea	bobs_d+(3*2520),a0
		lea	ml_output_d+(3*10240),a1
		add	d0,a1
		add	d2,a0
		bsr	char_copyloop
		
		lea	bobs_d+(4*2520),a0
		lea	ml_output_d+(4*10240),a1
		add	d0,a1
		add	d2,a0
		bsr	char_copyloop
		rts

char_copyloop:	moveq.l	#14,d1
.cc_loop	move.w	(a0)+,(a1)+
		add.b	#118,a0
		add.b	#38,a1
		dbf	d1,.cc_loop	; done bitplane
		rts
	
chxpos:	dc.l	0
chypos:	dc.l	0		
chuse:	dc.l	0
whichwayman:	dc.b	0
		even
****************************************************************************
****************************************************************************
loop20:		moveq.l	#20,d1
.loop		bsr	waitvbl
		dbf	d1,.loop
		rts				
loop13:		moveq.l	#13,d1
.loop		bsr	waitvbl
		dbf	d1,.loop
		rts
loop3:		moveq.l	#1,d1
.loop		bsr	waitvbl
		dbf	d1,.loop
		rts
***************************************************************************
***************************************************************************
mainlandcheckkeyroutine:
		bsr	mainlandcheckkeys
		cmpi.b	#$20,mainland_inputted_key	; is it 'A'	armour
		bne.s   ml_nextkey1
		bsr	action_armour
		rts
ml_nextkey1:	cmpi.b  #$11,mainland_inputted_key	; is it 'W'	weapon
		bne.s	ml_nextkey2
		bsr	action_weapon
		rts
ml_nextkey2:	cmpi.b	#$23,mainland_inputted_key	; is it 'F'	fight
		bne.s	ml_nextkey3
		bsr	action_fight
		rts
ml_nextkey3:	cmpi.b	#$37,mainland_inputted_key	; is it 'M'	magic
		bne.s	ml_nextkey4
		bsr	action_magic
		rts
ml_nextkey4:	cmpi.b	#$24,mainland_inputted_key	; is it 'G'	get
		bne.s	ml_nextkey5
		bsr	action_get
		rts
ml_nextkey5:	cmpi.b	#$16,mainland_inputted_key	; is it U	use
		bne.s	ml_nextkey6
		bsr	action_use
		rts
ml_nextkey6:	cmpi.b	#$35,mainland_inputted_key	; is it B	buy
		bne.s	ml_nextkey7
		bsr	action_buy
		rts
ml_nextkey7:	cmpi.b	#$21,mainland_inputted_key	; is it S	sell
		bne.s	ml_nextkey8
		bsr	action_sell
		rts
ml_nextkey8:	cmpi.b	#$14,mainland_inputted_key	; is it T	talk
		bne.s	ml_nextkey9
		bsr	action_talk
		rts
ml_nextkey9:	cmpi.b	#$3e,mainland_inputted_key	; is it numerical 8
		bne.s	ml_nextkey10
		bsr	action_north
		rts
ml_nextkey10:	cmpi.b	#$2f,mainland_inputted_key	; is it 6 east
		bne.s	ml_nextkey11
		move.b	#0,whichwayman
		bsr	action_east
		rts
ml_nextkey11:	cmpi.b	#$1e,mainland_inputted_key	; is it 2 south
		bne.s	ml_nextkey12
		bsr	action_south
		rts
ml_nextkey12:	cmpi.b	#$2d,mainland_inputted_key	; is it 4 west
		bne.s	ml_nextkey13
		move.b  #1,whichwayman
		bsr	action_west
		rts
ml_nextkey13:	cmpi.b	#$18,mainland_inputted_key	; is it Open
		bne.s   ml_nextkey14
		bsr     action_open
		rts
ml_nextkey14:	cmpi.b  #$19,mainland_inputted_key	; is it P pass
		bne.s	ml_nextkey15
		bsr	action_pass
		rts
ml_nextkey15:	rts
****************************************************************************
****************************************************************************
mainlandcheckkeys:
a_00044E52:	move.b  $BFED01,d0
		btst    #3,d0
		beq.s   a_00044E9E
		move.b  $BFEC01,d0
		bset    #6,$BFEE01
		moveq   #2,d2
a_00044E6E:	move.b  $DFF006,d1
a_00044E74:     move.b  #$FF,$BFEC01
		cmp.b   $DFF006,d1
		beq.s   a_00044E74
		dbf     d2,a_00044E6E
		bclr    #6,$BFEE01
		tst.b   d0
		beq.s   a_00044E9E
		ror.b   #1,d0
		not.b   d0
		move.b  d0,mainland_inputted_key
a_00044E9E:	rts
mainland_inputted_key:	dc.b	0,0
****************************************************************************
setupoutput:	lea	ml_output_d,a0			; point to screen data
		lea	ml_bpl0,a1			; point to bitplane pointers
		move.l	a0,d0
		moveq.l	#ml_output_planes-1,d1
.outputed	move.w	d0,6(a1)		; ls word into bplxptl
		swap	d0
		move.w	d0,2(a1)		; ms word into bplxpth
		swap	d0
		addi.l	#ml_output_size,d0		; point to data for next plane
		addq.l	#8,a1
		dbf	d1,.outputed
		rts
****************************************************************************
setupoutput2:	lea	sc_output_d,a0			; point to screen data
		lea	SC_bpl0,a1			; point to bitplane pointers
		move.l	a0,d0
		moveq.l	#sc_output_planes-1,d1
.outputed3	move.w	d0,6(a1)		; ls word into bplxptl
		swap	d0
		move.w	d0,2(a1)		; ms word into bplxpth
		swap	d0
		addi.l	#sc_output_size,d0		; point to data for next plane
		addq.l	#8,a1
		dbf	d1,.outputed3
		rts
****************************************************************************
GetRandom:
		bsr	RandomizeTimer
		bsr	RandomSeed
		move.w  randommax,d0	
		bsr	Random
		rts
randommax:	dc.w	0
		even
Random:
          movem.l   d1-d7,-(sp)
          move.w    d2,-(sp)
          move.w    d0,d2
          beq.s     ra01
          bsr.s     Longrnd
          clr.w     d0
          swap      d0
          divu      d2,d0
          clr.w     d0
          swap      d0
ra01:     move.w    (sp)+,d2
          movem.l   (sp)+,d1-d7
          rts
RandomSeed:
          add.l     d0,d1
          movem.l   d0/d1,rnd
Longrnd:
          movem.l   d2-d3,-(sp)
          movem.l   rnd,d0/d1
          andi.b    #$0e,d0
          ori.b     #$20,d0
          move.l    d0,d2
          move.l    d1,d3
          add.l     d2,d2
          addx.l    d3,d3
          add.l     d2,d0
          addx.l    d3,d1
          swap      d3
          swap      d2
          move.w    d2,d3
          clr.w     d2
          add.l     d2,d0
          addx.l    d3,d1
          movem.l   d0/d1,rnd
          move.l    d1,d0
          movem.l   (sp)+,d2-d3
          rts
RandomizeTimer:
          moveq     #0,d0
          move.b    $BFEA01,d0
          lsl.l     #8,d0
          move.b    $BFE901,d0
          lsl.l     #8,d0
          move.b    $BFE801,d0                    ;d0 = hardware clock
          bsr.s     RandomSeed
          rts
rnd:      dc.l      0,0
          rts
*****************************************************************************
domsg	move.l	#sc_output_d,textsc
	move.w	#80,textmod
	bsr.s	dotext
	rts
****************************************************************************
dotext	movem.l	d0-d7/a0-a6,-(sp)
	move.l	textpt,a0
	moveq	#0,d6
	move.w	textmod,d6
nextchar	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#0,d0
	beq.s	textend
	sub.b	#32,d0
	asl.w	#3,d0
charshow:
slowitdown:
	cmp.b	#1,slowyn
	beq.s	noslow
;	BSR	waitvbl
	bsr	waitvbl
noslow:
	lea	fontgfx,a4
	add.l	d0,a4
	lea	sc_output_d,a5
	moveq	#0,d0
	move.w	cxpos,d0
	add.l	d0,a5
	move.w	#7,d7
charcopy	move.b	(a4)+,(a5)
	add.l	d6,a5
	dbf	d7,charcopy
space	add.w	#1,cxpos
	bra	nextchar
textend	movem.l	(sp)+,d0-d7/a0-a6
	rts
slowtext:	dc.w	0
slowyn:		dc.b	1	;slow text/fast text
		even
textpt	dc.l	0	; text pointer.
textsc	dc.l	0	; text screen pointer.
textmod	dc.w	0	; text modulo width.
cxpos	dc.w	0	; font print x & y co-ords.
cypos	dc.w	0	; 
****************************************************************************
initsystem:
	suba.l	a1,a1				; Start from the CLI or the WB ???
	move.l	$4.w,a6
	jsr	_LVOFindTask(a6)
	move.l	d0,a4
	tst.l	pr_CLI(a4)
	bne.s	.from_cli

	lea	pr_MsgPort(a4),a0
	jsr	_LVOWaitPort(a6)
	lea	pr_MsgPort(a4),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,WBMessage
*************************************************
***	Open the Libs				*
*************************************************
.from_cli
	move.l	$4.w,a6				; Open Graphics Lib
	lea 	GfxName(PC),a1
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_GfxBase
	beq	_exit				; Geen Graphics lib gevonden

	move.l	$4.w,a6	
	lea	DosName(PC),a1
	moveq	#0,d0	
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_DOSBase
	beq	_exit	
	
	move.l	$4.w,a6				; Open Intuition lib
	lea	IntName(PC),a1
	moveq	#37,d0				; 37 omdat we dan ineens weten of we onder 2.0 draaien
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_IntBase
	beq.s	.no_os20			; We draaien op 1.X
*************************************************
***	Check Mode				*
*************************************************
	move.l	#(NTSC_MONITOR_ID|LORES_KEY),d0
	bsr	CheckModeAvail
	beq.s	.found

	move.l	#(PAL_MONITOR_ID|LORES_KEY),d0
	bsr	CheckModeAvail
	beq.s	.found
	bra.s	.no_os20			; Geen goede mode gevonden...
*************************************************
***	Mode found, Open Screen (2.X, 3.x)	*
*************************************************
.found
	suba.l	a0,a0				; NewScreen struct
	lea	ScrTagList(PC),a1		; Get screen tag list
	move.l	d7,4(a1)			; Set SA_DisplayID
	move.l	_IntBase(PC),a6
	jsr	_LVOOpenScreenTagList(a6)	; Open screen
	move.l	d0,screen			; Store Screen Ptr
*************************************************
***	Continue, (1.x, 2.x, 3.x)		*
*************************************************
.no_os20					; DUS : Onder 1.3 openen we geen screen...
	move.l	_GfxBase(PC),a6
	move.l	gb_ActiView(a6),OldView		; Get old screenview

	suba.l	a1,a1
	jsr	_LVOLoadView(a6)		; Reset Display
		
	jsr	_LVOWaitTOF(a6)			; Wait twice to reset an
	jsr	_LVOWaitTOF(a6)			; interlace display
	jsr	_LVOOwnBlitter(a6)		; We WANT the blitter!
	jsr	_LVOWaitBlit(a6)		; but first wait until it's finished

	move.l	$4.w,a6
	jsr	_LVOForbid(a6)			; Now we pratically OWN the system!
	
	move.w	$dff07c,d0			; AGA Register
	cmpi.b	#$f8,d0				; Check for AGA
	bne.s	.not_aga			; No AGA
	move.w	#$0,$dff1fc			; reset AGA sprites to normal mode
	move.w	#$0,$dff106			; dunno but should Set Sprite and colours
						; to normal!
.not_aga rts
*************************************************
***	Exit Demo here				*
*************************************************
allova:
.Exit_Routine:
	
	bsr	ReInitInts
	;jsr     pt_StopMusic
	move.l	$4.w,a6
	jsr	_LVOPermit(a6)
	move.l	_GfxBase(PC),a6
	jsr	_LVOWaitBlit(a6)		; Wait in case of a blit operation 
	jsr	_LVODisownBlitter(a6)		; Return Blitter
	cmp.l	#0,screen			; Did we open a screen ? (NOT 1.x)
	beq.s	.noscreen			; NOT ! Dan moeten we het ook niet sluiten
	move.l	screen(PC),a0
	move.l	_IntBase(PC),a6
	jsr	_LVOCloseScreen(a6)		; Close da screen
.noscreen:
	move.l	$4.w,a6
	cmp.l	#0,_IntBase			; Hebben Intuition geopend ?
	beq.s	.skip				; NOT ! Dan ook niet sluiten he
	move.l	_IntBase(PC),a1
	jsr	_LVOCloseLibrary(a6)		; Close Intuition lib
.skip:	cmp.l	#0,_GfxBase			; Hebben we de GFX geopend ?
	beq.s	.return				; NOT ! Dan ook niet sluiten, simpele
	move.l	_GfxBase(PC),a6
	move.l	OldView(PC),a1			
	jsr	_LVOLoadView(a6)		; Restore old screenview
	move.l	$4.w,a6

	move.l	_DOSBase(PC),a1			; Close GFX lib
	jsr	_LVOCloseLibrary(a6)

	move.l	_GfxBase(PC),a1			; Close GFX lib
	jsr	_LVOCloseLibrary(a6)
.return:

_exit
	tst.l	WBMessage
	beq.s	.no_msg

	move.l	$4.w,a6
	move.l	WBMessage(PC),a1
	jsr	_LVOReplyMsg(a6)
.no_msg	
	moveq	#0,d0
	rts
		
CheckModeAvail:
	move.l	d0,d7
	move.l	_GfxBase(PC),a6
	jsr	_LVOModeNotAvailable(a6)
	tst.l	d0
	rts
*************************************************
***	Data's					*
*************************************************
_IntBase:	dc.l	0
_GfxBase:	dc.l	0
_DOSBase:	dc.l	0
screen:		dc.l	0
WBMessage:	dc.l	0
OldView:	dc.l	0
ScrTagList:
	dc.l	SA_DisplayID,0
	dc.l	SA_Draggable,0
	dc.l	SA_Left,0
	dc.l	SA_Top,0
	dc.l	SA_Height,12
	dc.l	SA_Width,260
	dc.l	TAG_DONE,0
GfxName:	dc.b	"graphics.library",0
IntName:	dc.b	"intuition.library",0
DosName:	dc.b	"dos.library",0
Level3Int:	dc.l	0
Interrupts:	dc.w	0
		;include "hd0:include/players/PT-Play3B.S"
				
	even
****************************************************************************
; vbl wait. (waits for one screen flyback).
****************************************************************************
waitvbl		cmp.b	#$50,$dff006
		bne	waitvbl
waitvbl2:	cmp.b	#$51,$dff006
		bne	waitvbl2
		rts
***************************************************
*** Init Interrupt				***
***************************************************
initint:
	suba.l	a0,a0
	move.l	$4.w,a6
	btst	#AFB_68010,AttnFlags+1(a6)	; Check 4 68010+ Processor
	beq.s	skip				; Niet gevonden !
	lea	_SuperVBRCode(PC),a5
	jsr	-30(a6)				; Get in Supervisor Mode
skip:	move.l	a0,_VbrBase			; Store Vbrbase
	lea	$dff000,a5			; base Register
	move.w	$1c(a5),d0			; Save INTENA
	bset	#15,d0
	move.w	d0,Interrupts
	move.w	#$7fff,$9a(a5)			; turn off all Ints (INTENA)
	move.l	_VbrBase(PC),a1
	move.l	$6c(a1),Level3Int		; Save old Level 3 Int
	lea	Interrupt(pc),a0		; Set New Routine Ptr
	move.l	a0,$6c(a1)
	move.w	#$7fff,$9c(a5)			; Clear INTREQ
	move.w	#$c020,$9a(a5)			; Permit Level 3 Int
	rts

_SuperVBRCode
	OPT	P=68010
	movec	vbr,a0
	OPT	P=68000
	rte

_VbrBase:
	dc.l	0
	
***************************************************
*** ReInit Interrupts				***
***************************************************
ReInitInts:
	lea	$dff000,a5		; Base Register
	move.l	_VbrBase(PC),a1		; Don't forget da VBR !!!
	move.w	#$7fff,$9a(a5)		; Zet alle Ints af (INTENA)
	move.l	Level3Int(pc),$6c(a1)	; zet oude Level3Int Ptr
	move.w	Interrupts(pc),$9a(a5)	; zet oude INTENA 0contents
	rts
***************************************************
*** Start/Stop Copper				***
***************************************************
StartCopper:
	move.w	#$03a0,$96(a5)		; DMA's OFF
	move.l	#NCList,$84(a5)		; Copperlist
	clr.w	$8a(a5)
	move.w	#$8380,$96(a5)		; DMA's ON
	rts
StopCopper:	
	move.w	#$03a0,$96(a5)		; DMA's OFF
	clr.w	$88(a5)
	move.w	#$83a0,$96(a5)		; DMA's ON
	rts
***************************************************
*** Level3Int					***
***************************************************
Interrupt:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	$dff000,a5
	btst	#5,$1e+1(a5)		;VBI ? (INTREQR+1)
	beq.s	ExitI			;no-> Exit
	move.w	#$0020,$9c(a5)		;Clear VBI Bit
;	Doe hier uw timing belangrijke routines (zoals scroller, music enz)
	
	nop		; interrupt routines here
	;bsr	pt_PlayMusic
	nop
	nop
	
ExitI:
 	movem.l	(sp)+,d0-d7/a0-a6
	rte

****************************************************************************
	section copperdata,data_c	        ;  newcopper
****************************************************************************
NCList:
Copper:
newcopper:
copper_list_start:
		dc.w	$0106,$0000	; a1200 fix
		dc.w	$01fc,$0000	; a1200 fix
		
		dc.w	$0011,$fffe	; wait for line 0

		dc.w	$008e,$2c81     ; diwstrt & diwstop
		dc.w	$0090,$2cc1	; usable sceen size
					; same for hi and lo res
		dc.w	$0102
		dc.w	$0000		; bplcon1 - h fine tuning
		dc.w	$0108
		dc.w	$0000		; modulo odd
		dc.w	$010a
		dc.w	$0000		; modulo even
		dc.w	$0104,$0000	; bplcon2
					; controls priority between 
					; bitplanes & sprites
		dc.w    $0092,$0038	; ddfstrt data fetch start
		dc.w    $0094,$00d0	; ddfstop data fetch stop

ml_bpl0:	dc.w	$00e0
		dc.w	$0000	; bit plane pointers (hi word) bpl1pth		
		dc.w	$00e2
		dc.w	$0000	; high & low for bit plane 1	(low word)		
		dc.w	$00e4
		dc.w	$0000	;	2
		dc.w	$00e6
		dc.w	$0000	;	2
		dc.w	$00e8
		dc.w	$0000	;	3
		dc.w	$00ea
		dc.w	$0000	;	3
		dc.w	$00ec
		dc.w	$0000	;	4
		dc.w	$00ee
		dc.w	$0000	;	4
		dc.w	$00f0
		dc.w	$0000	;	5
		dc.w	$00f2
		dc.w	$0000	;	5
pallette0:
	dc.w	$0180,$0000
	dc.w	$0182,$0FCA
	dc.w	$0184,$0080
	dc.w	$0186,$00B6
	dc.w	$0188,$0A00
	dc.w	$018a,$0A52
	dc.w	$018c,$0D80
	dc.w	$018e,$0620
	dc.w	$0190,$0AAA
	dc.w	$0192,$0AAA
	dc.w	$0194,$0FCA
	dc.w	$0196,$0333
	dc.w	$0198,$0620
	dc.w	$019a,$00CC
	dc.w	$019c,$006F
	dc.w	$019e,$000A
	dc.w	$01a0,$000a
	dc.w	$01a2,$001c
	dc.w	$01a4,$003e
	dc.w	$01a6,$006f
	dc.w	$01a8,$0333
	dc.w	$01aa,$0444
	dc.w	$01ac,$0555
	dc.w	$01ae,$0666
	dc.w	$01b0,$0777
	dc.w	$01b2,$0888
	dc.w	$01b4,$0999
	dc.w	$01b6,$0AAA
	dc.w	$01b8,$0CCC
	dc.w	$01ba,$0DDD
	dc.w	$01bc,$0EEE
	dc.w	$01be,$0FFF

		dc.w	$0111,$fffe
		dc.w	$0100,$5200		;5 lowres bitplane on

		dc.w	$fe11,$fffe		;start 2nd screen

		dc.w    $0092,$003c	; ddfstrt data fetch start
		dc.w    $0094,$00d4	; ddfstop data fetch stop

		dc.w	$0180,$0000
		dc.w	$0182,$0fff

		dc.w	$0100,$9200	; 1 hires bitplane

SC_bpl0:	dc.w	$00e0
		dc.w	$0000	; bit plane pointers (hi word) bpl1pth		
		dc.w	$00e2
		dc.w	$0000	; high & low for bit plane 1	(low word)		
		dc.w	$00e4
		dc.w	$0000	;	2
		dc.w	$00e6
		dc.w	$0000	;	2
		dc.w	$00e8
		dc.w	$0000	;	3
		dc.w	$00ea
		dc.w	$0000	;	3
		dc.w	$00ec
		dc.w	$0000	;	4
		dc.w	$00ee
		dc.w	$0000	;	4

		dc.w	$ffff,$fffe
************************************************************************
;pt_data:	incbin	"hd1:work/code/badkarma/Intro_005/MOD.sid.fright"
************************************************************************
ml_output_d:	incbin	hd0:code/magewars/rawgfx/MAINSCREEN2.RAW
sc_output_d:	dcb.b	((80*50)*4),0	; testing
	Section FASTSTORE,Code
bobs_d:		incbin	hd0:code/magewars/rawgfx/bobs3.raw
storebob_d:	dcb.b	(10240*4),0
fontgfx:	incbin	hd0:code/magewars/rawgfx/font.raw	;font graphics
mapdata:	incbin	hd0:code/magewars/rawgfx/map.raw	;2*1
mapdata1:	incbin	hd0:code/magewars/rawgfx/map2.raw	;3*2
mapdata2:	incbin  hd0:code/magewars/rawgfx/map3.raw	;2*2
