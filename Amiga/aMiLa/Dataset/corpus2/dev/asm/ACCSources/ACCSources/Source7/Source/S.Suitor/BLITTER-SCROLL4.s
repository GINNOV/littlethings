
 SECTION LOWMEM,CODE_C				Force Code To Chip RAM
 OPT C-						Case Independant


*****************************************************************************
* EXECUTE SEQUENCE				    			    *
*****************************************************************************

	MOVEM.L A0-A6/D0-D7,-(A7)		Save all Registers
	MOVE.L  A7,Stackpoint			Save Pointer
	JSR 	Kill_OS
	JSR 	SetUp
	JSR	Mt_Init				Initialise music
	JSR 	Main
	JSR	Mt_End				End Music
	JSR 	Help_OS
	MOVE.L  Stackpoint,A7			Restore Pointer
	MOVEM.L (A7)+,A0-A6/D0-D7		Restore Registers
	RTS

*****************************************************************************
* KILL OS				            			    *
*****************************************************************************

Kill_OS	MOVE.L	 $4,A6
	CLR.L    D0
	LEA	 GFXlib(PC),A1
	JSR	 -552(A6)		     	Open GFX Lib
	MOVE.L   D0,GFXBase    
	JSR	 -132(A6)		     	LVO_Forbid
	MOVE.W	 $DFF002,DMAsave		Save DMA
	MOVE.W	 $DFF01C,INTensave		Save Interupt Enable
	MOVE.W   $DFF01E,INTrqsave		Save Interupt Request
Wt	BTST	 #0,$DFF004			Test MSB of VPOS
	BNE.S	 Wt
Wtt	CMPI.B	 #55,$DFF006			Wait Line 310
	BNE.S	 wtt				(stops Spurious Sprite Data)
	MOVE.W   #$7FFF,$DFF09A   	     	Disable	Interupts
	MOVE.W   #$7FFF,$DFF096   		Disable DMA
	MOVE.L   #Copperlist,$DFF080		Replace Copper 
	MOVE.W   $DFF088,D0			Strobe Copper
	MOVE.W   #%1000001111100000,$DFF096	Copper/Bitplane/Blit/Sprite
	rts


loop:
	move.w	$dff094,$dff180	; = background
	move.w	$dff088,$dff182	; = foreground
   	btst	#$a,$dff016	; = test for right mouse button
   	bne	loop		
   	moveq	#0,d0
   	rts


	 
 
*****************************************************************************
* SET UP ROUTINES							    *
*****************************************************************************

SetUp	MOVE.L	 #Planes,A0			Bpl Pointer In Copper
	MOVE.L   #Picture,D0			Picture Block
	MOVE.L	 D0,Offset			Save Screen Start Address
	ADD.L	 #(230*46)-1,Offset		Pointer for Scroller
PlLp   	MOVE.W   D0,6(A0)			Load Low Word
	SWAP     D0				Swap Words
	MOVE.W   D0,2(A0)			Load High Word
	MOVE.L	 #Sprite,D0			Address of Stars
	LEA  	 Sp_Ptr,A0  			pointers in Coperlist
        MOVE.W   D0,6(A0)			Load high word
	SWAP 	 D0				swap words
	MOVE.W   D0,2(A0)			Load low words
        MOVE.L   #Sprite_Empty,D0		Empty Sprite
	LEA  	 Sp_Ptr,A0			Pointers in copper
	ADD.L    #8,A0				Point Past Sprite0
	MOVE.L   #6,D1				Loop Value
Sp_Lp	MOVE.W   D0,6(A0) 			Load Blank Sprites Loop
	SWAP     D0
	MOVE.W   D0,2(A0)
	SWAP     D0
	ADD.L	 #8,A0				Next pointer in Copper
	DBF      D1,Sp_Lp			Loop
	RTS

*****************************************************************************
* MAIN					    				    *
*****************************************************************************

Main	
	move.w	mt_aud1temp,d0
	move.w	d0,bar1
	
	move.w	mt_aud1temp,d0
	move.w	d0,bass1
	
	move.w	mt_aud2temp,d0
	move.w	d0,bar2
	
	move.w	mt_aud2temp,d0
	move.w	d0,bass2
	
	move.w	mt_aud3temp,d0
	move.w	d0,bar3

	move.w	mt_aud3temp,d0
	move.w	d0,bass3

	move.w	mt_aud4temp,d0
	move.w	d0,bar4

	move.w	mt_aud4temp,d0
	move.w	d0,bass4
	
	move.w	mt_aud1temp,d0
	move.w	d0,bat1
	
	move.w	mt_aud2temp,d0
	move.w	d0,bat2
	
	move.w	mt_aud3temp,d0
	move.w	d0,bat3
	
	move.w	mt_aud4temp,d0
	move.w	d0,bat4

	CMPI.B	#255,$DFF006			Wait For line 255
	BNE	Main				
;	MOVE.W	#$00A,$DFF180			This is how to measure
	JSR	Stars
	JSR	Mt_Music
	JSR	Scroller
;	MOVE.W	#$000,$DFF180			Raster Time!!
	BTST   	#6,$BFE001			Test Mouse
	BNE  	Main
 	beq	loop
 	RTS	 

*****************************************************************************
*				BLIITER 				    *
*****************************************************************************

Scroller
	BTST	#$0A,$DFF016			Test Right Mouse 
	BNE.S	Nxt				If Not Equal Carry on
	RTS					Else Pause!
Nxt	MOVE.L  #$C9F00000,$DFF040		A=D,12 bits Shift
	MOVE.L  #$00000000,$DFF064		Mod
	MOVE.L	#$FFFFFFFF,$DFF044		Masks
	MOVE.L	Offset,$DFF050		        Source
	MOVE.L	Offset,A1			
	SUBQ.L	#1,A1				Subtract 16 Pxls
	MOVE.L	A1,$DFF054			Destination
	MOVE.W	#23+64*16,$DFF058		BLTSIZE
WtB	BTST    #14,$DFF002			Wait for Blit to End 
	BNE.S   WtB
	SUBQ.B	#$1,Delay			Need New Character?
	BEQ.S	GetChar				If Zero Branch
	RTS					Else Return
GetChar MOVE.B  #$4,Delay			New Char Delay
	ADD.L	#$1,TextPos			Next Scroller Character
	MOVE.L	#Checker,A0			Valid Chars
	MOVE.L	#Text,A1			Start of Text
	MOVE.L	TextPos,D2			Move Text Pos,D2
	MOVE.L	#0,D0				Clear for char byte
	MOVE.L	#0,D1				Clear for Char Count
	MOVE.B	(A1,D2),D0			Get Character
	BGT.S	Ch_Lp				If Not Zero,Not End
	MOVE.L	#$0000,TextPos			If Zero Wrap Text
Ch_Lp	CMP.B	(A0)+,D0			Buffer to Checker
	BEQ.S	Match				Branch If Char Found
	ADDQ.B	#1,D1				Add to Char Count
	CMPI.B	#53,D1				All Chars checked?
	BNE.S	Ch_Lp				If Not,loop
	MOVE.B	#36,D1				Invalid Char = space 
Match	MOVE.L	D1,D0				Save Char number
	DIVU	#20,D1				No.Chars per row in font
	MOVE.L	D1,D2				Save Row to D2
	MULU	#640,D1				40bytesx16pxls (1 line)
	MULU	#20,D2				Row no. x no. Chars
	SUB.L	D2,D0				Calc Char Horiz Pos
	MULU	#2,D0				2bytes x Horiz Pos
	ADD.L	D1,D0				Add Vert+Horiz Pos
Blit	MOVE.W  #$09F0,$DFF040			A = D Miniterm
	MOVE.L	Offset,A1			Scroller pos on screen
	MOVE.L	#Font,A0			Font
	ADD.L	D0,A0				Add CharPos
	MOVE.L  A0,$DFF050			A
	ADD.L   #44,A1				Display in Modulo border
	MOVE.L	A1,$DFF054			D
	MOVE.W  #0038,$DFF064			BLTAMOD
	MOVE.W	#0044,$DFF066			BLTDMOD
	MOVE.W  #1+64*15,$DFF058		BLISIZE
WtB1	BTST    #14,$DFF002			
	BNE.S   WtB1
	RTS

****************************************************************************
*				STARS					   *
****************************************************************************

Stars   MOVE.L	#SpriteE-Sprite,D2	Length (N) of Star data block
	DIVU	#(8*3),D2		No.Layers (3)
	MOVE.L	#Sprite,A0		Address of stars
Ch	CMPI.B	#$DF,1(A0)		Reached far right of screen?
	BNE.S   Mv			No,branch
	MOVE.B	#$38,1(A0)		Yes,reset to far left 
Mv	ADDQ.B  #$1,1(A0)		1st layer speed
	ADDQ.B	#$2,9(A0)		2nd layer speed
	ADDQ.B	#$3,17(A0)		3rd layer speed
	ADD.L	#24,A0			Next 3 stars
	SUB.W	#1,D2			Loop N times
	BNE.S	Ch
	RTS				Cool Routine Huh?

****************************************************************************
* 			  REPLAY ROUTINE V2.4				   *
****************************************************************************

mt_init lea	mt_data,a0
	add.l	#$03b8,a0
	moveq	#$7f,d0
	moveq	#0,d1
mt_init1
	move.l	d1,d2
	subq.w	#1,d0
mt_init2
	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	mt_init1
	dbf	d0,mt_init2
	addq.b	#1,d2
mt_init3
	lea	mt_data,a0
	lea	mt_sample1(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$438,d2
	add.l	a0,d2
	moveq	#$1e,d0
mt_init4
	move.l	d2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,d2
	add.l	#$1e,a0
	dbf	d0,mt_init4
	lea	mt_sample1(PC),a0
	moveq	#0,d0
mt_clear
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
mt_end	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts
mt_music
	addq.w	#1,mt_counter
mt_cool cmp.w	#6,mt_counter
	bne.s	mt_notsix
	clr.w	mt_counter
	bra	mt_rout2
mt_notsix
	lea	mt_aud1temp(PC),a6
	cmpi.w	#0,(a6)
;	beq.s	levm1
;	move.w	#$000E,Ch1			
levm1	tst.b	3(a6)
	beq.s	mt_arp1
	lea	$dff0a0,a5		
	bsr.s	mt_arprout
mt_arp1 lea	mt_aud2temp(PC),a6
	cmpi.w	#0,(a6)
;	beq.s	levm2
;	move.w	#$000C,Ch2			
levm2	tst.b	3(a6)
	beq.s	mt_arp2
	lea	$dff0b0,a5
	bsr.s	mt_arprout
mt_arp2 lea	mt_aud3temp(PC),a6
	cmpi.w	#0,(a6)
;	beq.s	levm3
;	move.w	#$000A,Ch3			
levm3	tst.b	3(a6)
	beq.s	mt_arp3
	lea	$dff0c0,a5
	bsr.s	mt_arprout
mt_arp3 lea	mt_aud4temp(PC),a6
	cmpi.w	#0,(a6)
;	beq.s	levm4
;	move.w	#$0008,Ch4			
levm4	tst.b	3(a6)
	beq.s	mt_arp4
	lea	$dff0d0,a5
	bra.s	mt_arprout
mt_arp4 rts
mt_arprout
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
mt_portup
	moveq	#0,d0
	move.b	3(a6),d0
	sub.w	d0,22(a6)
	cmp.w	#$71,22(a6)
	bpl.s	mt_ok1
	move.w	#$71,22(a6)
mt_ok1	move.w	22(a6),6(a5)
	rts
mt_portdwn
	moveq	#0,d0
	move.b	3(a6),d0
	add.w	d0,22(a6)
	cmp.w	#$538,22(a6)
	bmi.s	mt_ok2
	move.w	#$538,22(a6)
mt_ok2	move.w	22(a6),6(a5)
	rts
mt_volslide
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldwn
	add.w	d0,18(a6)
	cmp.w	#64,18(a6)
	bmi.s	mt_ok3
	move.w	#64,18(a6)
mt_ok3	move.w	18(a6),8(a5)
	rts
mt_voldwn
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	sub.w	d0,18(a6)
	bpl.s	mt_ok4
	clr.w	18(a6)
mt_ok4	move.w	18(a6),8(a5)
	rts
mt_arpegrt
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
mt_loop2
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_cont
mt_loop3
	moveq	#$00,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	bra.s	mt_cont
mt_loop4
	move.w	16(a6),d2
	bra.s	mt_endpart
mt_cont
	add.w	d0,d0
	moveq	#0,d1
	move.w	16(a6),d1
	lea	mt_arpeggio(PC),a0
mt_loop5
	move.w	(a0,d0),d2
	cmp.w	(a0),d1
	beq.s	mt_endpart
	addq.l	#2,a0
	bra.s	mt_loop5
mt_endpart
	move.w	d2,6(a5)
	rts
mt_rout2
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
mt_rls	dbf	d0,mt_rls
	move.w	#$8000,d0
	or.w	mt_dmacon,d0
	move.w	d0,$dff096
	lea	mt_aud4temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice3
	move.l	10(a6),$dff0d0
	move.w	#1,$dff0d4
mt_voice3
	lea	mt_aud3temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice2
	move.l	10(a6),$dff0c0
	move.w	#1,$dff0c4
mt_voice2
	lea	mt_aud2temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice1
	move.l	10(a6),$dff0b0
	move.w	#1,$dff0b4
mt_voice1
	lea	mt_aud1temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice0
	move.l	10(a6),$dff0a0
	move.w	#1,$dff0a4
mt_voice0
	move.l	mt_partnote(PC),d0
	add.l	#$10,d0
	move.l	d0,mt_partnote
	cmp.l	#$400,d0
	bne.s	mt_stop
mt_higher
	clr.l	mt_partnote
	addq.l	#1,mt_partnrplay
	moveq	#0,d0
	move.w	mt_maxpart(PC),d0
	move.l	mt_partnrplay(PC),d1
	cmp.l	d0,d1
	bne.s	mt_stop
	clr.l	mt_partnrplay
mt_stop tst.w	mt_status
	beq.s	mt_stop2
	clr.w	mt_status
	bra.s	mt_higher
mt_stop2
	rts
mt_playit
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
mt_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
mt_nosamplechange
	tst.w	(a6)
	beq.s	mt_retrout
	move.w	(a6),16(a6)
	move.w	20(a6),$dff096
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	(a6),6(a5)
	move.w	20(a6),d0
	or.w	d0,mt_dmacon
mt_retrout
	tst.w	(a6)
	beq.s	mt_nonewper
	move.w	(a6),22(a6)
mt_nonewper
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
mt_posjmp
	not.w	mt_status
	moveq	#0,d0
	move.b	3(a6),d0
	subq.b	#1,d0
	move.l	d0,mt_partnrplay
	rts
mt_setvol
	move.b	3(a6),8(a5)
	rts
mt_break
	not.w	mt_status
	rts
mt_setfil
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#1,d0
	rol.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts
mt_setspeed
	move.b	3(a6),d0
	and.b	#$0f,d0
	beq.s	mt_back
	clr.w	mt_counter
	move.b	d0,mt_cool+3
mt_back rts

mt_aud1temp
	dcb.w	10,0
	dc.w	1
	dcb.w	2,0
mt_aud2temp
	dcb.w	10,0
	dc.w	2
	dcb.w	2,0
mt_aud3temp
	dcb.w	10,0
	dc.w	4
	dcb.w	2,0
mt_aud4temp
	dcb.w	10,0
	dc.w	8
	dcb.w	2,0


mt_partnote	dc.l	0
mt_partnrplay	dc.l	0
mt_counter	dc.w	0
mt_partpoint	dc.l	0
mt_samples	dc.l	0
mt_sample1	dcb.l	31,0
mt_maxpart	dc.w	0
mt_dmacon	dc.w	0
mt_status	dc.w	0

mt_arpeggio
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000
	
****************************************************************************
*				STAR POS				   *
****************************************************************************
 Even

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
SpriteE	dc.w 	$0000,$0000

*****************************************************************************
* RESTORE OS				    				    *
*****************************************************************************

Help_OS	MOVE.W  INTensave,D7
	BSET    #$F,D7				Set Write Bit
	MOVE.W  D7,$DFF09A			Restore INTen
	MOVE.W  INTrqsave,D7
	BSET    #$F,D7
	MOVE.W  D7,$DFF09C			Restore INTrq
	MOVE.W  DMAsave,D7
	BSET    #$F,D7
	MOVE.W  D7,$DFF096	  		Restore DMA
	MOVE.L  GFXbase,A0
	MOVE.L  $26(A0),$DFF080			Find/Replace System Copper
	MOVE.L  $4,A6
	JSR     -138(A6)			LVO_Permit
	RTS 
 
*****************************************************************************
*			        COPPER				    	    *
*****************************************************************************

Copperlist


	DC.L $01080002,$010A0002,$01001200,$01020000	Mod / Con 0/1		
	DC.L $00920030,$009400D8,$008E1A64,$009039D1	Display/Data Fetch		
Planes	DC.L $00E00000,$00E20000


Col     	DC.L $01800000,$01820fff,$01860f00,$01880000
	


	DC.L $01040000					Video Priority
Sp_Ptr	DC.L $01200000,$01220000	 		Sprite Pointers
	DC.L $01240000,$01260000	
	DC.L $01280000,$012A0000	
	DC.L $012C0000,$012E0000	
	DC.L $01300000,$01320000	
	DC.L $01340000,$01360000	
	DC.L $01380000,$013A0000	
	DC.L $013C0000,$013E0000	
Sp_Col	DC.L $01A20999					COLOR 17
	DC.L $01A40BBB					COLOR 18
	DC.L $01A80000					COLOR 19
	DC.W $2301,$FFFE,$180
BAR1	DC.W $0
	DC.W $2b01,$FFFE,$180,$0
	
	DC.W $3001,$FFFE,$180
BAR2	DC.W $0
	DC.W $3801,$FFFE,$180,$0
	
	DC.W $3d01,$FFFE,$180
BAR4	DC.W $0
	DC.W $4501,$FFFE,$180,$0
	
	DC.W $4a01,$FFFE,$180
BAR3	DC.W $0
	DC.W $5201,$FFFE,$180,$0
	
	DC.W $5701,$FFFE,$180
BASS1	DC.W $0
	DC.W $5f01,$FFFE,$180,$0
	
	DC.W $6401,$FFFE,$180
BASS2	DC.W $0
	DC.W $6c01,$FFFE,$180,$0
	
	DC.W $7101,$FFFE,$180
BASS4	DC.W $0
	DC.W $7901,$FFFE,$180,$0
	
	DC.W $7e01,$FFFE,$180
BASS3	DC.W $0
	DC.W $8601,$FFFE,$180,$0

	
	DC.W $8b01,$FFFE,$180
BAT1	DC.W $0
	DC.W $9301,$FFFE,$180,$0
	
	DC.W $9801,$FFFE,$180
BAT2	DC.W $0
	DC.W $a001,$FFFE,$180,$0
	
	DC.W $a501,$FFFE,$180
BAT4	DC.W $0
	DC.W $ad01,$FFFE,$180,$0
	
	DC.W $b201,$FFFE,$180
BAT3	DC.W $0
	DC.W $ba01,$FFFE,$180,$0
	
	dc.w $ff09,$fffe,$ffdd,$fffe
	dc.w $0001,$fffe,$180,$0000
	DC.L $FFFFFFFE

*****************************************************************************
* LABELS,INCLUDES							    *
*****************************************************************************

GFXlib			DC.B "graphics.library"
Stackpoint		DC.L 0
GFXbase			DC.L 0
INTrqsave		DC.W 0
INTensave		DC.W 0
DMAsave			DC.W 0
Offset			DC.L    0
Delay			DC.B 	$12
TextPos			DC.L	0
Font			IncBin  "club7:bitmaps/font.bmp"
			Even	
Checker			DC.B    "ABCDEFGHIJKLMNOPQRSTUVWXY"
			DC.B	"Z0123456789 ?.,[]`:;-+/%*()!"
			;[] means speech marks

 SECTION  LOWMEM,DATA_C					

Picture			DCB.B (290*46),0
Mt_Data			IncBin "club7:modules/mod.music"
Sprite_Empty		DCB.B	10,0

*****************************************************************************
*				SCROLL TEXT				    *
*****************************************************************************
 Even

Text
	DC.B " HELLO THERE,   MARK HOW WOULD I GO ABOUT PUTTING A BIGGER FONT INTO THIS INTRO ?"
	DC.B " I DONT LIKE TO BOTHER YOU WITH THIS PROBLEM BUT I DON`T KNOW MUCH ABOUT THE BLITTER AND MY MATE HAS BEEN TO"
	DC.B " BUSY TO DO ANYTHING WITH IT YET, CHEERS. ( BY THE WAY THIS LOOKS BETTER IN THE DARK.)"
	DC.B "                                              "

