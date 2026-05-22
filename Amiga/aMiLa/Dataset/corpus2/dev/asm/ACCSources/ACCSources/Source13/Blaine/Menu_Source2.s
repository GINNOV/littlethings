							;BY BLAINE EVANS
							;1 ERITH WAY
							;PONTYBODKIN
							;NR MOLD
							;CLWYD
							;CH7 4TR
							;TEL O352-771673
	opt	c-,d+

	move.l	4.w,a6			;FIND EXEC BASE
	lea	gfxlib(pc),a1		;LOAD GRAPHICS LIBRARY IN A1
	moveq	#$00,d0			;VERSION 0
	jsr	-552(a6)		;OPEN LIBRARY
	move.l	d0,_gfxbase		;STORE D0 (GFX ADDRESS )
	beq	nolib_exit		;ELSE EXIT
	moveq	#0,d0			; Dos version
	move.l	4.w,a6			;FIND EXEC BASE
	lea	Dosname(pc),a1		; load dos address
	jsr	-552(a6)		; open library
	move.l	d0,Dosbase		; store dos address
	move.l	4.w,a6			;FIND EXEC BASE
	jsr	-132(a6)		; forbid 
	bsr	Foreground_addresses	;BRANCH TO FOREGROUND ADDRESSES
	bsr	Screen_2
	bsr	Set_Copper
	bsr	Init
	Bsr	mt_init
	lea	$dff000,a6
	move.l	_gfxbase,a0		;LOAD ADDRESS OF GRAPHICS LIB IN A0
	move.l	50(a0),Oldcop		;STORE CURRENT COPPER,ETC TO RETRIEVE LATER
S
	move.l	#Newcop,50(a0)		;POINT TO OUR COPPERLIST

wait					;WAIT LOOP

	cmp.b	#255,$dff006		;VERTICAL BLANKING GAP 
	bne.s	wait			;
;	move.w	#$0fff,$180(a6)		;REMOVE TO MEASURE RASTER TIME
	bsr	Bars
	bsr	Fire
	bsr	Joytest
	bsr	Sprite0
	bsr	Map
	bsr	mt_music	
;	move.w	#$000,$180(a6)		;REMOVE TO MEASURE RASTER TIME
	cmp.w	#1,Flag
	bne	Wait
	move.w	#0,Flag   
ended					;ELSE LOOP TO WAIT
	bsr	mt_end
	move.l	_gfxbase,a0		;LOAD GRAPHICS LIB ADDRESS IN A0
	move.l	oldcop,50(a0)		;RESTORE OLD COPPER TO RETURN TO EDITTER
nomem_exit	
	move.l	4.w,a6			;FIND EXEC BASE
	move.l	_gfxbase,a1		;LOAD GRAPHICS BASE IN A1
	jsr	-414(a6)		;CLOSE LIBRARY
	move.l	4.w,a6			;FIND EXEC BASE
        jsr      -138(a6)               ; Permit Multitasking
	lea	Connam(pc),a1
	move.l	#1005,d0
	move.l	a1,d1
	move.l	d0,d2
	move.l	Dosbase,a6		; Dos address
	jsr	-30(a6)
	move.l	d0,Conhdle
	move.l	Dosbase,a6		; Dos address
	move.l	Com,d1			; Name of program
	move.l	#0,d2			; no input
	move.l	Conhdle,d3
	jsr	-222(a6)		; execute command/program
	move.l	Conhdle,d1		; close window
	move.l	Dosbase,a6		; dos address
	jsr	-36(a6)
	moveq	#0,d0			; exit
nolib_exit
	rts				;RETURN TO EDITER
Foreground_addresses			;START OF FOREGROUND DATA
	move.l	#Foreground,d0
	move.w	d0,Bpl0ptl		;LOW WORD IN BIT PLANE 0 LOW
	swap	d0				
	move.w	d0,Bpl0pth		;HIGH WORD IN BIT PLANE 0 HIGH
	swap	d0
	add.l	#212*40,d0
	move.w	d0,Bpl1ptl		;LOW WORD IN BIT PLANE 1 LOW
	swap	d0				
	move.w	d0,Bpl1pth		;HIGH WORD IN BIT PLANE 1 HIGH
	swap	d0
	add.l	#212*40,d0
	move.w	d0,Bpl2ptl		;LOW WORD IN BIT PLANE 2 LOW
	swap	d0				
	move.w	d0,Bpl2pth		;HIGH WORD IN BIT PLANE 2 HIGH
	swap	d0
	add.l	#212*40,d0
	move.w	d0,Bpl3ptl		;LOW WORD IN BIT PLANE 3 LOW
	swap	d0				
	move.w	d0,Bpl3pth		;HIGH WORD IN BIT PLANE 3 HIGH
	swap	d0
	lea	sprites,a0		;CONTROL WORDS
	move.l	#Sprite,d0		;ADDRESS
	move.w	d0,6(a0)		;AND UPDATE COPPER
	swap	d0
	move.w	d0,2(a0)
	swap	d0	
	rts
Screen_2
	move.l	#Screen,d0
	move.w	d0,Bpl0ptl2		;LOW WORD IN BIT PLANE 0 LOW
	swap	d0				
	move.w	d0,Bpl0pth2		;HIGH WORD IN BIT PLANE 0 HIGH
	swap	d0
	add.l	#44*40,d0
	move.w	d0,Bpl1ptl2		;LOW WORD IN BIT PLANE 0 LOW
	swap	d0				
	move.w	d0,Bpl1pth2		;HIGH WORD IN BIT PLANE 0 HIGH
	swap	d0
	rts
Set_Copper
	lea	copper,a0		; address
	move.w	#$0180,(a0)+		; color 0 control word
	move.w	#$0f0f,(a0)+		; make it purple
	move.w	#$2b01,d0		; co-cordinates
	move.w	d0,(a0)+		; into copperlist
	move.w	#$ff01,(a0)+		; $2b01,$ff01 = jump to this row

	move.w	#110,d1			; no of times-1
	move.l	a0,copptr		; store address
coplp:
	move.w	#$0180,(a0)+		; color 0 control word
	move.w	#0,(a0)+		; into copperlist
	add.w	#$0100,d0		; add #1 to x co-ordinates
	move.w	d0,(a0)+		; into copperlist
	move.w	#$fffe,(a0)+		; wait
	dbf	d1,coplp		; loop

	move.w	#10,d1			; no of times -1
	lea	Copper_bar,a0		; starting address
	move.w	#$a901,d0		; starting co-ordinates
	move.w	d0,(a0)+		; co-ordinates
	move.w	#$fffe,(a0)+		; wait
	move.w	#$0180,(a0)+		; colour control word #0
	move.w	#$0000,(a0)+		; colour
	move.w	#$0184,(a0)+		; colour control word #2
	move.w	#$0d00,(a0)+		; colour
	add.w	#$0100,d0		; add #1 to co-ordinates
	move.w	d0,(a0)+		; co-ordinates
	move.w	#$fffe,(a0)+		; wait
	move.w	#$0180,(a0)+		; colour control word #0
	move.w	#$000f,(a0)+		; colour
	move.w	#$0184,(a0)+		; colour control word #2
	move.w	#$0d00,(a0)+		; colour
	add.w	#$0100,d0		; add #1 to co-ordinates

	move.w	d0,(a0)+		; co-ordinates
	move.w	#$fffe,(a0)+		; wait
	move.w	#$0180,(a0)+		; colour control word #0
	move.w	#$000f,(a0)+		; colour
	move.w	#$0184,(a0)+		; colour control word #2
	move.w	#$0d00,(a0)+		; colour
	add.w	#$0100,d0		; add #1 to co-ordinates
	move.w	#$0fff,d2		; starting colour
	move.w	#$0dd0,d4		; starting colour
CCC
	move.w	d0,(a0)+		; co-ordinates
	move.w	#$fffe,(a0)+		; wait
	move.w	#$0180,(a0)+		; colour control word #0
	move.w	d2,(a0)+		; colour
	move.w	#$0184,(a0)+		; colour control word #2
	move.w	d4,(a0)+		; colour
	add.w	#$0100,d0		; add #1 to co-ordinates
	dbf	d1,CCC			; loop

	move.w	d0,(a0)+		; co-ordinates
	move.w	#$fffe,(a0)+		; wait
	move.w	#$0180,(a0)+		; colour control word #0
	move.w	#$000f,(a0)+		; colour
	move.w	#$0184,(a0)+		; colour control word #2
	move.w	#$0d00,(a0)+		; colour
	add.w	#$0100,d0
	move.w	d0,(a0)+		; co-ordinates
	move.w	#$fffe,(a0)+		; wait
	move.w	#$0180,(a0)+		; colour control word #0
	move.w	#$000f,(a0)+		; colour
	move.w	#$0184,(a0)+		; colour control word #2
	move.w	#$0d00,(a0)+		; colour


	add.w	#$0100,d0
	move.w	d0,(a0)+		; co-ordinates
	move.w	#$fffe,(a0)+		; wait
	move.w	#$0180,(a0)+		; colour control word #0
	move.w	#$0000,(a0)+		; colour
	move.w	#$0184,(a0)+		; colour control word #2
	move.w	#$0d00,(a0)+		; colour
	rts
Init
	move.l	#Screen,d0
	add.l	#21*40,d0
	move.l	d0,Blit_Base
	lea	Graphics,a0
	add.l	#21*40,a0
	move.l	a0,Gra_base
	move.w	#0,Inc
	lea	Map_a,a1
	move.l	a1,Map_Address
	rts
Map
	add.b	#1,Frame
	cmp.b	#3,Frame
	beq	Yes_Frame
	rts
Yes_Frame
	move.b	#0,Frame
	move.l	Map_Address,a1
	move.w	(a1)+,d0
	cmp.w	#$eeee,d0
	beq	Reset_1
	cmp.w	#$dddd,d0
	beq	Reset_2
	cmp.w	#$cccc,d0
	beq	Reset_3
	cmp.w	#$bbbb,d0
	beq	Reset_4
	move.w	d0,Inc
	move.l	a1,Map_Address	
	move.l	Gra_Base,a0
	add.w	d0,a0
	move.l	a0,Gra_Address
	bsr	Blitter
	rts	
Reset_1
	lea	Map_b,a1
	move.l	a1,Map_Address
	lea	Graphics_2,a0
	add.l	#21*40,a0
	move.l	a0,Gra_base
	rts
Reset_2
	lea	Map_c,a1
	move.l	a1,Map_Address
	lea	Graphics_3,a0
	add.l	#22*40,a0
	move.l	a0,Gra_base
	rts
Reset_3
	lea	Map_d,a1
	move.l	a1,Map_Address
	lea	Graphics_2,a0
	add.l	#22*40,a0
	move.l	a0,Gra_base
	rts
Reset_4
	lea	Map_a,a1
	move.l	a1,Map_Address
	lea	Graphics,a0
	add.l	#22*40,a0
	move.l	a0,Gra_base
	rts
Blitter					;
	move.l	Blit_base,a3		;ADDRESS OF DESIGNATION
	add.w	Inc,a3			
	move.l	Gra_Address,a0		;GRAPHICS IN A0
	move.l	#0,d0			;MODULA OF GRAPHICS
	move.l	#0,d1			;MODULA OF DESIGNATION
	move.l	#(1*64)+20,d3		;SIZE OF BLIT(200*1WORD)
	move.w	#$ffff,d6		;NO MASK
	move.w	#$ffff,d4		;NO MASK
	move.w	#1,d7			;NO OF PLANES -1
	lea	$dff000,a6		
	move.l	#$09f00000,d2		;A-D BLIT NO SHIFT

bb_loop
	bsr	stuff_blitter
	lea	44*40(a0),a0		;ADD PLANE SIZE	TO GRAPHICS 
	lea	44*40(a3),a3		;ADD PLANE SIZE TO DESIGNATION 
	dbra	d7,bb_loop		;LOOP TILL 0
	rts

Stuff_blitter				;LOAD BLITTER WITH VALUES

wfblit
	btst	#14,2(a6)			;dmaconr(a6)
	bne.s	wfblit
	move.l	a0,$50(a6)			;bltapt(a6)
	move.l	a3,$54(a6)			;bltdpt(a6)
	move.w	d0,$64(a6)			;bltamod(a6)
	move.w	d1,$66(a6)			;bltdmod(a6)
	move.l	d2,$40(a6)			;bltcon0(a6)
	move.l	#00,$42(a6)			;bltcon1(a6)
	move.w	d6,$46(a6)			;bltalwm(a6)
	move.w	d4,$44(a6)			;bltafwm(a6)
	move.w	d3,$58(a6)			;bltsize(a6)
	rts



Fire
	Btst	#$7,$bfe001		; Fire pressed
	beq	Fired			; yes branch
	rts				; else return

Fired
	bsr	Function_1		; branches to check each
	bsr	Function_2		; number
	bsr	Function_3
	bsr	Function_4
	bsr	Function_5
	rts
Function_1
	lea	Copper_Bar,a0		; 1st value in moving bar 
	cmp.b	#$ab,0(a0)		; check co-ordinates
	bls	Try_End			; <=co-ordinate try next co-ordinate
	rts		
Try_End
	lea	Copper_Bar,a0		; end of bar
	move.b	0(a0),d0
	add.b	#17,d0
	cmp.b	#$ba,d0			; >=co-ordinate
	bhs	Yes_1			; yes then branch
	rts
Yes_1
	move.l	#Com1,d2		; load program name 
	move.l	d2,com			; variable to store above
	move.w	#1,Flag			; set flag
	rts
Function_2
	lea	Copper_Bar,a0		; same for all menu items
	cmp.b	#$bc,0(a0)		; just simple co-ordinate
	bls	Try_End_2		; checking and loading name
	rts				; of program
Try_End_2
	lea	Copper_Bar,a0		; end of bar
	move.b	0(a0),d0
	add.b	#17,d0
	cmp.b	#$cb,d0			; >=co-ordinate
	bhs	Yes_2
	rts
Yes_2
	move.l	#Com2,d1
	move.l	d1,com
	move.w	#1,Flag			; set flag
	rts
Function_3
	lea	Copper_Bar,a0
	cmp.b	#$cd,0(a0)
	bls	Try_End_3
	rts
Try_End_3
	lea	Copper_Bar,a0		; end of bar
	move.b	0(a0),d0
	add.b	#17,d0
	cmp.b	#$dc,d0			; >=co-ordinate
	bhs	Yes_3
	rts
Yes_3
	move.l	#Com3,d1
	move.l	d1,com
	move.w	#1,Flag			; set flag
	rts
Function_4
	lea	Copper_Bar,a0
	cmp.b	#$de,0(a0)
	bls	Try_End_4
	rts
Try_End_4
	lea	Copper_Bar,a0		; end of bar
	move.b	0(a0),d0
	add.b	#17,d0
	cmp.b	#$ed,d0			; >=co-ordinate
	bhs	Yes_4
	rts
Yes_4
	move.l	#Com4,d1
	move.l	d1,com
	move.w	#1,Flag			; set flag
	rts
Function_5
	lea	Copper_Bar,a0
	cmp.b	#$ef,0(a0)
	bls	Try_End_5
	rts
Try_End_5
	lea	Copper_Bar,a0		; end of bar
	move.b	0(a0),d0
	add.b	#17,d0
	cmp.b	#$fe,d0			; >=co-ordinate
	bhs	Yes_5
	rts
Yes_5
	move.l	#Com5,d1
	move.l	d1,com
	move.w	#1,Flag			; set flag
	rts

Sprite0
	lea	sprites,a0		;CONTROL WORDS
	move.l	#Sprite,d0		;ADDRESS
	move.w	d0,6(a0)		;AND UPDATE COPPER
	swap	d0
	move.w	d0,2(a0)
	swap	d0	
	move.l	#Sprite,a0		;A0=SPRITE 0 ADDRESS
	move.w	#40,d7			;NO OF SPRITES-1
Move
	addq.b	#1,1(a0)		;ADD # TO HORIZONTAL POSITIONAL BYTE
	addq.b	#2,9(a0)
	addq.b	#3,17(a0)
	add.l	#24,a0			;LOCATE NEXT PAIR OF CO-ORDINATES
	dbf	d7,Move			;DECREMENT AND BRANCH WHEN =0
	rts


Bars
	move.l	copptr,a0		; address
	move.w	#110,d0			; no of bars created
clearlp
	clr.w	2(a0)			; clear color 0(i.e. Black)
	addq.w	#8,a0			; next 
	dbf	d0,clearlp		; loop till 0

	lea	infront,a6		
	lea	intable,a5
	lea	thycols,a4		; colours
	lea	sine,a3			; sine table
	moveq	#0,d0			; First bar
blp
	move.l	copptr,a2
	move.w	(a5)+,d7
	tst.b	(a6)+
	bne.s	nonow
	addq.b	#1,-1(a5)
	move.b	(a3,d7.w),d1		; Y Position
	and.w	#$ff,d1
	asl.w	#3,d1			;*8(each coplist entry=8bytes)
	move.w	d0,d6
	asl.w	#5,d6			; *16 each colorlist e = 16
	moveq	#15,d5
mclp
	move.w	(a4,d6.w),2(a2,d1.w)
	addq.l	#8,a2
	addq.l	#2,d6
	dbf	d5,mclp
nonow
	addq.l	#1,d0
	cmpi.b	#8,d0
	bne.s	blp
	lea	infront,a6
	lea	intable,a5
	lea	thycols,a4
	lea	sine,a3
	moveq	#0,d0			; First bar
blp2
	move.l	copptr,a2
	move.w	(a5)+,d7
	tst.b	(a6)+
	beq.s	nonow2
	addq.b	#1,-1(a5)
	move.b	(a3,d7.w),d1		; Y Position
	and.w	#$ff,d1
	asl.w	#3,d1			;*8(each coplist entry=8bytes)
	move.w	d0,d6
	asl.w	#5,d6			; *16 each colorlist e = 16
	moveq	#15,d5
mclp2
	move.w	(a4,d6.w),2(a2,d1.w)
	addq.l	#8,a2
	addq.l	#2,d6
	dbf	d5,mclp2
nonow2
	addq.l	#1,d0
	cmpi.b	#8,d0
	bne.s	blp2

	lea	intable,a0
	lea	infront,a1
	moveq	#7,d2
checklp
	move.w	(a0)+,d0
	sub.b	#$40,d0
	dbf	d2,checklp
	rts	

Bar
	lea	Copper_Bar,a0		; address
	move.w	#16,d1			; no of lines-1
	move.b	Value,d0		; store value to be added/sub from bar
Loop_Bar
	add.b	d0,0(a0)		; add/subtract to co-ordinates
	add.w	#12,a0			; increase to next line
	dbra	d1,Loop_Bar		; loop until done
	rts
	
Joytest
	add.b	#1,Joy_Count		; delay to slow down
	cmp.b	#5,Joy_Count		; joystick movement
	beq	Yes_Joy
	rts
Yes_Joy
	move.b	#0,Joy_Count		; clear delay value
	move.w	$DFF00c,d2		;joy value to d2
	move.w	d2,d1			; 
	lsr.w	#1,d1			; logocally shift right #1
	eor.w	d2,d1			; exclusively or with d1
try_down	
	btst	#0,d1			; bit 0 =down
	beq	try_up			; 
	lea	Copper_bar,a0
	cmp.b	#$ed,(a0)		; boundary test
	bhs	No_Down
	move.b	#17,Value		; #1 to Value
	bsr	Bar
	rts
No_Down
	move.b	#0,Value		; outside then no move
	bsr	Bar
	rts
try_up	
	btst	#8,d1			; bit 8 =up
	beq	no_move
	lea	Copper_Bar,a0
	cmp.b	#$a9,(a0)		; is it within boundaries
	bls	No_Up
	move.b	#-17,Value		; #1 to Value
	bsr	Bar
	rts
No_Up
	move.b	#0,Value		; if outside then no move
	bsr	Bar
	rts
no_move
	move.b	#0,Value		; none of above
	bsr	Bar
	rts				; #0 to Value

;нннннннннннннннннннннннннннннннннннннннн
;н     NoisetrackerV2.0 FASTreplay      н
;н  Uses lev6irq - takes 8 rasterlines  н
;н Do not disable Master irq in $dff09a н
;н Used registers: d0-d3/a0-a7|	=INTENA н
;н  Mahoney & Kaktus - (C) E.A.S. 1990  н
;нннннннннннннннннннннннннннннннннннннннн

mt_init:lea	mt_data,a0
	lea	mt_mulu(pc),a1
	move.l	#mt_data+$c,d0
	moveq	#$1f,d1
	moveq	#$1e,d3
mt_lop4:move.l	d0,(a1)+
	add.l	d3,d0
	dbf	d1,mt_lop4

	lea	$3b8(a0),a1
	moveq	#$7f,d0
	moveq	#0,d1
	moveq	#0,d2
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	mt_lop
	move.l	d1,d2
mt_lop:	dbf	d0,mt_lop2
	addq.w	#1,d2

	asl.l	#8,d2
	asl.l	#2,d2
	lea	4(a1,d2.l),a2
	lea	mt_samplestarts(pc),a1
	add.w	#$2a,a0
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.b	d1,2(a0)
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	d3,a0
	dbf	d0,mt_lop3

	move.l	$78.w,mt_oldirq-mt_samplestarts-$7c(a1)
	or.b	#2,$bfe001
	move.b	#6,mt_speed-mt_samplestarts-$7c(a1)
	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.b	d0,mt_songpos-mt_samplestarts-$7c(a1)
	move.b	d0,mt_counter-mt_samplestarts-$7c(a1)
	move.w	d0,mt_pattpos-mt_samplestarts-$7c(a1)
	rts


mt_end:	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.w	#$f,$dff096
	rts


mt_music:
	lea	mt_data,a0
	lea	mt_voice1(pc),a4
	addq.b	#1,mt_counter-mt_voice1(a4)
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blt	mt_nonew
	moveq	#0,d0
	move.b	d0,mt_counter-mt_voice1(a4)
	move.w	d0,mt_dmacon-mt_voice1(a4)
	lea	mt_data,a0
	lea	$3b8(a0),a2
	lea	$43c(a0),a0

	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0.w),d1
	lsl.w	#8,d1
	lsl.w	#2,d1
	add.w	mt_pattpos(pc),d1

	lea	$dff0a0,a5
	lea	mt_samplestarts-4(pc),a1
	lea	mt_playvoice(pc),a6
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a4
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a4
	jsr	(a6)
	addq.l	#4,d1
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a4
	jsr	(a6)

	move.w	mt_dmacon(pc),d0
	beq.s	mt_nodma

	lea	$bfd000,a3
	move.b	#$7f,$d00(a3)
	move.w	#$2000,$dff09c
	move.w	#$a000,$dff09a
	move.l	#mt_irq1,$78.w
	moveq	#0,d0
	move.b	d0,$e00(a3)
	move.b	#$a8,$400(a3)
	move.b	d0,$500(a3)
	or.w	#$8000,mt_dmacon-mt_voice4(a4)
	move.b	#$11,$e00(a3)
	move.b	#$81,$d00(a3)

mt_nodma:
	add.w	#$10,mt_pattpos-mt_voice4(a4)
	cmp.w	#$400,mt_pattpos-mt_voice4(a4)
	bne.s	mt_exit
mt_next:clr.w	mt_pattpos-mt_voice4(a4)
	clr.b	mt_break-mt_voice4(a4)
	addq.b	#1,mt_songpos-mt_voice4(a4)
	and.b	#$7f,mt_songpos-mt_voice4(a4)
	move.b	-2(a2),d0
	cmp.b	mt_songpos(pc),d0
	bne.s	mt_exit
	move.b	-1(a2),mt_songpos-mt_voice4(a4)
mt_exit:tst.b	mt_break-mt_voice4(a4)
	bne.s	mt_next
	rts

mt_nonew:
	lea	$dff0a0,a5
	lea	mt_com(pc),a6
	jsr	(a6)
	lea	mt_voice2(pc),a4
	lea	$dff0b0,a5
	jsr	(a6)
	lea	mt_voice3(pc),a4
	lea	$dff0c0,a5
	jsr	(a6)
	lea	mt_voice4(pc),a4
	lea	$dff0d0,a5
	jsr	(a6)
	tst.b	mt_break-mt_voice4(a4)
	bne.s	mt_next
	rts

mt_irq1:tst.b	$bfdd00
	move.w	mt_dmacon(pc),$dff096
	move.l	#mt_irq2,$78.w
	move.w	#$2000,$dff09c
	rte

mt_irq2:tst.b	$bfdd00
	movem.l	a3/a4,-(a7)
	lea	mt_voice1(pc),a4
	lea	$dff000,a3
	move.l	$a(a4),$a0(a3)
	move.w	$e(a4),$a4(a3)
	move.l	$a+$1c(a4),$b0(a3)
	move.w	$e+$1c(a4),$b4(a3)
	move.l	$a+$38(a4),$c0(a3)
	move.w	$e+$38(a4),$c4(a3)
	move.l	$a+$54(a4),$d0(a3)
	move.w	$e+$54(a4),$d4(a3)
	movem.l	(a7)+,a3/a4
	move.b	#0,$bfde00
	move.b	#$7f,$bfdd00
	move.l	mt_oldirq(pc),$78.w
	move.w	#$2000,$dff09c
	move.w	#$2000,$dff09a
	rte

mt_playvoice:
	move.l	(a0,d1.l),(a4)
	moveq	#0,d2
	move.b	2(a4),d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$f0,d0
	or.b	d0,d2
	beq	mt_oldinstr

	asl.w	#2,d2
	move.l	(a1,d2.l),4(a4)
	move.l	mt_mulu(pc,d2.w),a3
	move.w	(a3)+,8(a4)
	move.w	(a3)+,$12(a4)
	move.l	4(a4),d0
	moveq	#0,d3
	move.w	(a3)+,d3
	beq	mt_noloop
	asl.w	#1,d3
	add.l	d3,d0
	move.l	d0,$a(a4)
	move.w	-2(a3),d0
	add.w	(a3),d0
	move.w	d0,8(a4)
	bra	mt_hejaSverige

mt_mulu:dcb.l	$20,0

mt_noloop:
	add.l	d3,d0
	move.l	d0,$a(a4)
mt_hejaSverige:
	move.w	(a3),$e(a4)
	move.w	$12(a4),8(a5)

mt_oldinstr:
	move.w	(a4),d3
	and.w	#$fff,d3
	beq	mt_com2
	tst.w	8(a4)
	beq.s	mt_stopsound
	move.b	2(a4),d0
	and.b	#$f,d0
	cmp.b	#5,d0
	beq.s	mt_setport
	cmp.b	#3,d0
	beq.s	mt_setport

	move.w	d3,$10(a4)
	move.w	$1a(a4),$dff096
	clr.b	$19(a4)

	move.l	4(a4),(a5)
	move.w	8(a4),4(a5)
	move.w	$10(a4),6(a5)

	move.w	$1a(a4),d0
	or.w	d0,mt_dmacon-mt_playvoice(a6)
	bra	mt_com2

mt_stopsound:
	move.w	$1a(a4),$dff096
	bra	mt_com2

mt_setport:
	move.w	(a4),d2
	and.w	#$fff,d2
	move.w	d2,$16(a4)
	move.w	$10(a4),d0
	clr.b	$14(a4)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge	mt_com2
	move.b	#1,$14(a4)
	bra	mt_com2
mt_clrport:
	clr.w	$16(a4)
	rts

mt_port:moveq	#0,d0
	move.b	3(a4),d2
	beq.s	mt_port2
	move.b	d2,$15(a4)
	move.b	d0,3(a4)
mt_port2:
	tst.w	$16(a4)
	beq.s	mt_rts
	move.b	$15(a4),d0
	tst.b	$14(a4)
	bne.s	mt_sub
	add.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
mt_portok:
	move.w	$10(a4),6(a5)
mt_rts:	rts

mt_sub:	sub.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	blt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
	move.w	$10(a4),6(a5)
	rts

mt_sin:
	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_vib:	move.b	$3(a4),d0
	beq.s	mt_vib2
	move.b	d0,$18(a4)

mt_vib2:move.b	$19(a4),d0
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	mt_sin(pc,d0.w),d2
	move.b	$18(a4),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	$10(a4),d0
	tst.b	$19(a4)
	bmi.s	mt_vibsub
	add.w	d2,d0
	bra.s	mt_vib3
mt_vibsub:
	sub.w	d2,d0
mt_vib3:move.w	d0,6(a5)
	move.b	$18(a4),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,$19(a4)
	rts


mt_arplist:
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

mt_arp:	moveq	#0,d0
	move.b	mt_counter(pc),d0
	move.b	mt_arplist(pc,d0.w),d0
	beq.s	mt_normper
	cmp.b	#2,d0
	beq.s	mt_arp2
mt_arp1:move.b	3(a4),d0
	lsr.w	#4,d0
	bra.s	mt_arpdo
mt_arp2:move.b	3(a4),d0
	and.w	#$f,d0
mt_arpdo:
	asl.w	#1,d0
	move.w	$10(a4),d1
	lea	mt_periods(pc),a0
mt_arp3:cmp.w	(a0)+,d1
	blt.s	mt_arp3
	move.w	-2(a0,d0.w),6(a5)
	rts

mt_normper:
	move.w	$10(a4),6(a5)
	rts

mt_com:	move.w	2(a4),d0
	and.w	#$fff,d0
	beq.s	mt_normper
	move.b	2(a4),d0
	and.b	#$f,d0
	beq.s	mt_arp
	cmp.b	#6,d0
	beq.s	mt_volvib
	cmp.b	#4,d0
	beq	mt_vib
	cmp.b	#5,d0
	beq.s	mt_volport
	cmp.b	#3,d0
	beq	mt_port
	cmp.b	#1,d0
	beq.s	mt_portup
	cmp.b	#2,d0
	beq.s	mt_portdown
	move.w	$10(a4),6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$71,d0
	bpl.s	mt_portup2
	move.w	#$71,$10(a4)
mt_portup2:
	move.w	$10(a4),6(a5)
	rts

mt_portdown:
	moveq	#0,d0
	move.b	3(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$358,d0
	bmi.s	mt_portdown2
	move.w	#$358,$10(a4)
mt_portdown2:
	move.w	$10(a4),6(a5)
	rts

mt_volvib:
	 bsr	mt_vib2
	 bra.s	mt_volslide
mt_volport:
	 bsr	mt_port2

mt_volslide:
	moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	beq.s	mt_vol3
	add.b	d0,$13(a4)
	cmp.b	#$40,$13(a4)
	bmi.s	mt_vol2
	move.b	#$40,$13(a4)
mt_vol2:move.w	$12(a4),8(a5)
	rts

mt_vol3:move.b	3(a4),d0
	and.b	#$f,d0
	sub.b	d0,$13(a4)
	bpl.s	mt_vol4
	clr.b	$13(a4)
mt_vol4:move.w	$12(a4),8(a5)
	rts

mt_com2:move.b	2(a4),d0
	and.b	#$f,d0
	beq	mt_rts
	cmp.b	#$e,d0
	beq.s	mt_filter
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_songjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_filter:
	move.b	3(a4),d0
	and.b	#1,d0
	asl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_pattbreak:
	move.b	#1,mt_break-mt_playvoice(a6)
	rts

mt_songjmp:
	move.b	#1,mt_break-mt_playvoice(a6)
	move.b	3(a4),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos-mt_playvoice(a6)
	rts

mt_setvol:
	cmp.b	#$40,3(a4)
	bls.s	mt_sv2
	move.b	#$40,3(a4)
mt_sv2:	moveq	#0,d0
	move.b	3(a4),d0
	move.b	d0,$13(a4)
	move.w	d0,8(a5)
	rts

mt_setspeed:
	moveq	#0,d0
	move.b	3(a4),d0
	cmp.b	#$1f,d0
	bls.s	mt_sp2
	moveq	#$1f,d0
mt_sp2:	tst.w	d0
	bne.s	mt_sp3
	moveq	#1,d0
mt_sp3:	move.b	d0,mt_speed-mt_playvoice(a6)
	rts

mt_periods:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
	dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
	dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
	dc.w $007f,$0078,$0071,$0000

mt_speed:	dc.b	6
mt_counter:	dc.b	0
mt_pattpos:	dc.w	0
mt_songpos:	dc.b	0
mt_break:	dc.b	0
mt_dmacon:	dc.w	0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	13,0
		dc.w	1
mt_voice2:	dcb.w	13,0
		dc.w	2
mt_voice3:	dcb.w	13,0
		dc.w	4
mt_voice4:	dcb.w	13,0
		dc.w	8
mt_oldirq:	dc.l	0



gfxlib	dc.b	"graphics.library",0	
	even
_gfxbase	dc.l	0		;LONG WORD TO STORE GFX ADDRESS
oldcop		dc.l	0		;OLD COPPERLIST ADDRESS
copptr		dc.l 	0
Dosname	dc.b	"dos.library",0
	even
DosBase	dc.l	0

Com	dc.l	0
Com1	dc.b	"1",0
Com2	dc.b	"2",0
Com3	dc.b	"3",0
Com4	dc.b	"4",0
Com5	dc.b	"5",0
	even
Conhdle	dc.l	0
Connam	dc.b	"CON:0/0/640/256/Now Loading Your Choice.......",0
	even
Value	dc.b	0
	even
Flag	dc.w	0
Blit_Base	dc.l	0
Gra_Base	dc.l	0
Inc		dc.w	0
Map_Address	dc.l	0
Gra_Address	dc.l	0
Joy_Count	dc.b	0
Frame		dc.b	0
	even
	SECTION		chipmemory,data_c	


Newcop
	dc.w	$0100,%0100001000000000		;4 PLANES DUAL PLAYFIELD MODE
	dc.w	$0102
Scroll	dc.w	$0000			;	SCROLL VALUE
	dc.w	$0104,%0000000000000001		;NO PRIORITIES
	dc.w	$0108,$0000,$010a,$0000		;MODULAS
	dc.w	$0092,$0038,$0094,$00d0		;200*39 SCREEN
	dc.w	$008e,$2C81,$0090,$2Cc1		;VISIBLE AREA
						
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

	dc.w	$0180,$0000,$0182,$0eca,$0184,$0e00,$0186,$0a00
	dc.w	$0188,$0333,$018a,$0444,$018c,$0555,$018e,$0666
	dc.w	$0190,$0777,$0192,$0888,$0194,$0999,$0196,$0aaa
	dc.w	$0198,$0ccc,$019a,$0ddd,$019c,$0eee,$019e,$0fff

	dc.w	$01a0,$0000,$01a2,$0fff		;SPRITE COLORS
	dc.w	$01a4,$0f00,$01a6,$0b00
	dc.w	$01a8,$0600,$01aa,$0F40
	dc.w	$01ac,$0F80,$01ae,$0Fa0
	dc.w	$01b0,$0Ff0,$01b2,$000f
	dc.w	$01b4,$004f,$01b6,$008f
	dc.w	$01b8,$00ff,$01ba,$00f0
	dc.w	$01bc,$0283,$01be,$0f0f

copper
	dcb.w	(110*4),0
	dcb.w	(4*2),0
Copper_Bar
	dcb.w	(17*6),0
	;dc.w	$ffff,$fffe			;END OF COPPERLIST

	dc.w	$ff01,$fffe
	dc.w	$0100,%0010001000000000	
	dc.w	$00e0
Bpl0pth2	dc.w	$0000,$00e2
Bpl0ptl2	dc.w	$0000,$00e4
Bpl1pth2	dc.w	$0000,$00e6
Bpl1ptl2	dc.w	$0000,$00e8
Bpl2pth2	dc.w	$0000,$00ea
Bpl2ptl2	dc.w	$0000,$00ec
Bpl3pth2	dc.w	$0000,$00ee
Bpl3ptl2	dc.w	$0000

	dc.w	$0180,$0000,$0182,$0800,$0184,$0400,$0186,$0b12
	dc.w	$0188,$0333,$018a,$0444,$018c,$0555,$018e,$0666
	dc.w	$0190,$0777,$0192,$0888,$0194,$0999,$0196,$0aaa
	dc.w	$0198,$0ccc,$019a,$0ddd,$019c,$0eee,$019e,$0fff

	dc.w	$ffff,$fffe			;END OF COPPERLIST
infront:dc.b 1,1,1,1,1,1,1,1
intable:dc.w $8,$10,$18,$20,$28,$30,$38,$40
thycols:
	dc.w $0000,$0202,$0404,$0606,$0808,$0a0a,$0c0c,$0e0e
	dc.w $0e0e,$0c0c,$0a0a,$0808,$0606,$0404,$0202,$0000

	dc.w $0000,$0002,$0004,$0006,$0008,$000a,$000c,$000e
	dc.w $000e,$000c,$000a,$0008,$0006,$0004,$0002,$0000

	dc.w $0000,$0022,$0044,$0066,$0088,$00aa,$00cc,$00ee
	dc.w $00ee,$00cc,$00aa,$0088,$0066,$0044,$0022,$0000

	dc.w $0000,$0020,$0040,$0060,$0080,$00a0,$00c0,$00e0
	dc.w $00e0,$00c0,$00a0,$0080,$0060,$0040,$0020,$0000

	dc.w $0000,$0220,$0440,$0660,$0880,$0aa0,$0cc0,$0ee0
	dc.w $0ee0,$0cc0,$0aa0,$0880,$0660,$0440,$0220,$0000

	dc.w $0000,$0200,$0400,$0600,$0800,$0a00,$0c00,$0e00
	dc.w $0e00,$0c00,$0a00,$0800,$0600,$0400,$0200,$0000

	dc.w $0000,$0222,$0444,$0666,$0888,$0aaa,$0ccc,$0eee
	dc.w $0eee,$0ccc,$0aaa,$0888,$0666,$0444,$0222,$0000

	dc.w $0,$002,$004,$006,$008,$00a,$00c,$00e
	dc.w $00e,$00c,$00a,$0008,$006,$004,$002,$00

sine:
	dc.b 95,93,91,89,86,84,82,79,77,75,72,70,68,66,63
	dc.b 61,59,57,55,53,51,49,47,45,43,41,39,37,35,33
	dc.b 32,30,28,27,25,24,22,21,19,18,17,15,14,13,12
	dc.b 11,10,9,8,7,6,5,5,4,3,3,2,2,2,1
	dc.b 1,1,1,1,0,1,1,1,1,1,2,2,2,3,3
	dc.b 4,5,5,6,7,8,9,10,11,12,13,14,15,17,18
	dc.b 19,21,22,24,25,27,28,30,32,33,35,37,39,41,43
	dc.b 45,47,49,51,53,55,57,59,61,63,66,68,70,72,75
	dc.b 77,79,82,84,86,89,91,93,95,92,90,88,85,83,81
	dc.b 78,76,74,71,69,67,65,62,60,58,56,54,52,50,48
	dc.b 46,44,42,40,38,36,34,32,31,29,27,26,24,23,21
	dc.b 20,18,17,16,14,13,12,11,10,9,8,7,6,5,4
	dc.b 4,3,2,2,1,1,1,0,0,0,0,0,0,0,0
	dc.b 0,0,0,1,1,1,2,2,3,4,4,5,6,7,8
	dc.b 9,10,11,12,13,14,16,17,18,20,21,23,24,26,27
	dc.b 29,31,32,34,36,38,40,42,44,46,48,50,52,54,56
	dc.b 58,60,62,65,67,69,71,74,76,78,81,83,85,88,90
	dc.b 92
	even
	
Sprite
	dc.w    $307A,$3100,$1000,$0000,$3220,$3300,$1000,$0000
	dc.w    $34C0,$3500,$1000,$0000,$3650,$3700,$1000,$0000
	dc.w    $3842,$3900,$1000,$0000,$3A6D,$3B00,$1000,$0000
	dc.w    $3CA2,$3D00,$1000,$0000,$3E9C,$3F00,$1000,$0000
	dc.w    $40DA,$4100,$1000,$0000,$4243,$4300,$1000,$0000
	dc.w    $445A,$4500,$1000,$0000,$4615,$4700,$1000,$0000
	dc.w    $4845,$4900,$1000,$0000,$4A68,$4B00,$1000,$0000
	dc.w    $4CB8,$4D00,$1000,$0000,$4EB4,$4F00,$1000,$0000
	dc.w    $5082,$5100,$1000,$0000,$5292,$5300,$1000,$0000
	dc.w    $54D0,$5500,$1000,$0000,$56D3,$5700,$1000,$0000
	dc.w    $58F0,$5900,$1000,$0000,$5A6A,$5B00,$1000,$0000
	dc.w    $5CA5,$5D00,$1000,$0000,$5E46,$5F00,$1000,$0000
	dc.w    $606A,$6100,$1000,$0000,$62A0,$6300,$1000,$0000
	dc.w    $64D7,$6500,$1000,$0000,$667C,$6700,$1000,$0000
	dc.w    $68C4,$6900,$1000,$0000,$6AC0,$6B00,$1000,$0000
	dc.w    $6C4A,$6D00,$1000,$0000,$6EDA,$6F00,$1000,$0000
	dc.w    $70D7,$7100,$1000,$0000,$7243,$7300,$1000,$0000
	dc.w    $74A2,$7500,$1000,$0000,$7699,$7700,$1000,$0000
	dc.w    $7872,$7900,$1000,$0000,$7A77,$7B00,$1000,$0000
	dc.w    $7CC2,$7D00,$1000,$0000,$7E56,$7F00,$1000,$0000
	dc.w    $805A,$8100,$1000,$0000,$82CC,$8300,$1000,$0000
	dc.w    $848F,$8500,$1000,$0000,$8688,$8700,$1000,$0000
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
	dc.w	$FCB2,$FD00,$1000,$0000,$FE9A,$FF00,$1000,$0000
	dc.w	$009A,$0106,$1000,$0000,$02DF,$0306,$1000,$0000
	dc.w	$0446,$0506,$1000,$0000,$0688,$0706,$1000,$0000
	dc.w	$0899,$0906,$1000,$0000,$0ADD,$0B06,$1000,$0000
	dc.w	$0CEE,$0D06,$1000,$0000,$0EFF,$0F06,$1000,$0000
	dc.w	$10CD,$1106,$1000,$0000,$1267,$1306,$1000,$0000
	dc.w	$1443,$1506,$1000,$0000,$1664,$1706,$1000,$0000
	dc.w	$1823,$1906,$1000,$0000,$1A6D,$1B06,$1000,$0000
	dc.w	$1C4F,$1D06,$1000,$0000,$1E5F,$1F06,$1000,$0000
	dc.w	$2055,$2106,$1000,$0000,$2267,$2306,$1000,$0000
	dc.w	$2445,$2506,$1000,$0000,$2623,$2706,$1000,$0000
	dc.w	$2834,$2906,$1000,$0000,$2AF0,$2B06,$1000,$0000
	dc.w	$2CBC,$2D06,$1000,$0000
SpriteE	dc.w 	$0000,$0000
	even
Foreground	incbin	source:bitmaps/B.raw_2
Screen
		dcb.b	(46*40)*1,$00
		dcb.b	(46*40)*1,$00
mt_data	incbin	"source:modules/mod.musix5"
	even
	DC.L	0,0

Map_a
	dc.w	0,0,40,-40,80,-80,120,-120,160,-160,200,-200,240,-240,280,-280
	dc.w	320,-320,360,-360,400,-400,440,-440,480,-480,520,-520
	dc.w	560,-560,600,-600,640,-640,680,-680,720,-720,760,-760
	dc.w	800,-800,840,-840
	dc.w	$eeee
Map_b
	dc.w	840,-840,800,-800,760,-760,720,-720,680,-680,640,-640
	dc.w	600,-600,560,-560,520,-520,480,-480,440,-440,400,-400
	dc.w	360,-360,320,-320,280,-280,240,-240,200,-200,160,-160
	dc.w	120,-120,80,-80,40,-40,0,0
	dc.w	$dddd
Map_c
	dc.w	0,0,40,-40,80,-80,120,-120,160,-160,200,-200,240,-240,280,-280
	dc.w	320,-320,360,-360,400,-400,440,-440,480,-480,520,-520
	dc.w	560,-560,600,-600,640,-640,680,-680,720,-720,760,-760
	dc.w	800,-800,840,-840
	dc.w	$cccc
Map_d
	dc.w	840,-840,800,-800,760,-760,720,-720,680,-680,640,-640
	dc.w	600,-600,560,-560,520,-520,480,-480,440,-440,400,-400
	dc.w	360,-360,320,-320,280,-280,240,-240,200,-200,160,-160
	dc.w	120,-120,80,-80,40,-40,0,0
	dc.w	$bbbb

Graphics	
		incbin	source:bitmaps/BE.raw
Graphics_2
		dcb.b	(44*40),$00
		dcb.b	(44*40),$00
Graphics_3	
		incbin	source:bitmaps/BE.raw_2


