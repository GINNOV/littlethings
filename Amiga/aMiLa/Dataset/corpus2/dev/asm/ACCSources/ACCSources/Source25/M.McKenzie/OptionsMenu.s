;							Martin Mckenzie
;							2 Wardie Road
;							Easterhouse
;							Glasgow
;							G33 4NP

; Options menu : Includes a 3 layer star-field, and function key checker.

	section	hardware,code		; Fast memory
	opt	c- d+
	include	source:include/hardware.i		; Hardware offset

	lea	$dff000,a5		; Hardware offset

base	equ	$790f			; Base screen address for shading
base2	equ	$950f
base3	equ	$b10f
logo	equ	$2b0f			; Address for shading logo

	move.l	4,a6			; Exec base
	lea	gfxname,a1
	moveq.l	#0,d0			; Any version
	jsr	-552(a6)		; Open library
	move.l	d0,gfxbase		; Save gfx base
	beq	error
	
	jsr	-132(a6)		; Forbid

*****************************************************************************
;			Set-Up The Bitplane Pointers
*****************************************************************************

	move.l	#Screen,d0		; Address of screen
	move.w	d0,bpl1+2		; Load bitplane pointers
	swap	d0
	move.w	d0,bph1+2
	swap	d0
	add.l	#256*40,d0		; Get to next bitplane
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2
	swap	d0
	add.l	#256*40,d0
	move.w	d0,bpl3+2
	swap	d0
	move.w	d0,bph3+2

*****************************************************************************
;			  Set-Up DMA
*****************************************************************************

	move.w	dmaconR(A5),dmasave	; Save DMA settings
	move.w	intenar(A5),intensave	; Save INT settings
	move.w	intreqr(A5),intrqsave	; Save INT settings

DMA
.Wait1	btst	#0,vposr(a5)		; Wait VBL
	bne	.Wait1
.Wait2	cmpi.b	#55,vhposr(a5)
	bne	.Wait2

;	move.w	#$7fff,intena(a5)
	move.w	#%1000001110100000,dmacon(A5)	; BPL+COP+SPR DMA ONLY!!!!

	jsr	SETUP_STARS		; SETUP STARS...
;	jsr	MT_INIT			; SETUP TRACKER...	

SET_UP_INT
	move.l	$6C.w,oldint+2
	move.l	$6C.w,level3save

	move.l	#NEWINT,$6C.w

	move.l	#Copperlist,cop1lch(a5)	; Insert new copper list
	move.w	#$0,copjmp1(a5)		; Run that copper list

;	move.w	#%1100000000100000,intena(a5)

	bra	main

*****************************************************************************
;			  Set-Up Int
*****************************************************************************

NEWINT	MOVEM.L	A0-A6/D0-D7,-(A7)
;	jsr	MT_MUSIC
	jsr	STARS
	MOVEM.L	(A7)+,A0-A6/D0-D7
;	move.w	#%0000000001110000,intreq(a5)
OLDINT	JMP	$0

	rte

*****************************************************************************
;			Main Branching Routine
*****************************************************************************
Main
	cmpi.b	#255,vhposr(a5)		; Wait VBL
	bne	Main

	move.b	$bfec01,d0		;Address to get fkey status
	not	d0			;Invert
	ror.b	#1,d0			
	cmpi.b	#$50,d0			;Is it F1?
	beq	F1
	cmpi.b	#$51,d0			;F2?
	beq	F2
	cmpi.b	#$52,d0			;F3?
	beq	F3

	btst	#6,$bfe001		; Mouse Wait
	bne	Main
	bra	CleanUp			; Clean-up system

*****************************************************************************
;			'F' key Routines
*****************************************************************************
; F1 and F2 do nothing (yet), but F3 is a toggle switch

F1	
	cmpi.b	#1,d5
	beq	F1On
	move.b	#1,d5
	bra	main
F1On	move.b	#0,d5
	bra	main

F2
	cmpi.b	#1,d6
	beq	F2On
	move.b	#1,d6
	bra	main
F2On	move.b	#0,d6
	bra	main

F3
	cmpi.b	#1,d7			;Which icon is showing now?
	beq	F3On
	move.b	#1,d7			;Set status (On or Off)
	move.l	#40*136,d4		;Screen pos to place
	move.l	#bob1,bob		;Bob to be writen to screen (on or off)
	bra	blitter			;And blit it
F3On	move.b	#0,d7			;Set status
	move.l	#40*136,d4		;Offset
	move.l	#bob2,bob		;Address of bob (off) in bob
	bra	blitter			;Blit

***************************************************************************
;			BLITTER
***************************************************************************
Blitter
	cmpi.b	#200,$dff006		;test VBL
	bne	blitter			
	lea	screen,a0		;Address of screen in a0
	add.l	d4,a0			;Add offset
	add.l	#12,a0			;blitting on left of screen
	move.l	bob,bltapth(a5)		;Source is bob
	move.l	a0,bltdpth(a5)		;Destination is screen
	move.w	#0,bltamod(a5)		;No A modulo
	move.w	#28,bltdmod(a5)		;D modulo
	move.w	#$ffff,bltafwm(a5)	;No mask
	move.w	#$ffff,bltalwm(a5)	;No mask
	move.w	#%0000100111110000,bltcon0(a5)
	move.w	#%10100000110,bltsize(a5)
	bra	pause			;Do a pause

Pause
	move.b	#140,d3			;140 pause wait
Ploop
	dbra	d3,ploop		;Delete pause counter
	bra	main			;And continue

*****************************************************************************
;			       Clean Up
*****************************************************************************
CleanUp
.Wait1	btst	#0,vposr(a5)		; Wait VBL
	bne	.Wait1
.Wait2	cmpi.b	#55,vhposr(a5)
	bne	.Wait2
;	jsr	MT_END

	move.l	level3save,$6c.w
	move.w	intensave,D7
	or.w	#$C000,D7
	move.w	D7,INTENA(A5)
	move.w	intrqsave,D7
	bset	#$F,D7
	move.w	D7,INTREQ(A5)

	move.w	dmasave,D7		; RESTORE THE DMA.
	bset	#$F,D7
	move.w	D7,dmacon(A5)

	move.l	gfxbase,a1		; A1=Address of gfx lib
	move.l	38(a1),cop1lch(a5)	; Load sys copper list
	move.w	#$0,copjmp1(a5)		; Run sys copper list
	move.l	4,a6			; Exec base
	move.l	gfxbase,a1
	jsr	-408(a6)		; Close library
	jsr	-138(a6)		; Permit
	moveq.l	#0,d0			; Keep CLI happy
error	rts				; Bye Bye

*****************************************************************************
;			Copper List
*****************************************************************************

	section	copper,data_c		; Chip data
Copperlist
	dc.w	diwstrt,$2c81		; window start	
	dc.w	diwstop,$2cc1		; window stop
	dc.w	ddfstrt,$38		; data fetch start
	dc.w	ddfstop,$d0		; data fect stop
	dc.w	bplcon0,%0011001000000000 ; 3 bitplanes
	dc.w	bplcon1,$0		; Clear scroll register
	dc.w	bplcon2,$0		; Clear priority register
	dc.w	bpl1mod,$0		; No modulo (odd)
	dc.w	bpl2mod,$0		; No modulo (even)
; Bitplane pointers
bph1	dc.w	bpl1pth,$0	
bpl1	dc.w	bpl1ptl,$0
bph2	dc.w	bpl2pth,$0
bpl2	dc.w	bpl2ptl,$0
bph3	dc.w	bpl3pth,$0
bpl3	dc.w	bpl3ptl,$0
; Colours
	dc.w	$180,$000,$182,$888,$184,$840,$186,$55f
	dc.w	$188,$f00,$18a,$f77,$18c,$ff5,$18e,$0cc

Sp_Ptr	DC.L $01200000,$01220000	Sprite0 PTH/L
	DC.L $01240000,$01260000	Sprite1 PTH/L
	DC.L $01280000,$012A0000	Sprite2 PTH/L
	DC.L $012C0000,$012E0000	Sprite3 PTH/L
	DC.L $01300000,$01320000	Sprite4 PTH/L
	DC.L $01340000,$01360000	Sprite5 PTH/L
	DC.L $01380000,$013A0000	Sprite6 PTH/L
	DC.L $013C0000,$013E0000	Sprite7 PTH/L
Sp_Col	DC.L $01A20999			COLOR 17
	DC.L $01A40BBB			COLOR 18
	DC.L $01A80000			COLOR 19

bars0	dc.w	(logo),$FFFE
	dc.w	color01,$0001
	dc.w	(logo+$0200),$FFFE
	dc.w	color01,$0002
	dc.w	(logo+$0400),$FFFE
	dc.w	color01,$0004
	dc.w	(logo+$0600),$FFFE
	dc.w	color01,$0006
	dc.w	(logo+$0800),$FFFE
	dc.w	color01,$0008
	dc.w	(logo+$0a00),$FFFE
	dc.w	color01,$000a
	dc.w	(logo+$0c00),$FFFE
	dc.w	color01,$000c
	dc.w	(logo+$0e00),$FFFE
	dc.w	color01,$000f
	dc.w	(logo+$1000),$FFFE
	dc.w	color01,$000c
	dc.w	(logo+$1200),$FFFE
	dc.w	color01,$000a
	dc.w	(logo+$1400),$FFFE
	dc.w	color01,$0008
	dc.w	(logo+$1600),$FFFE
	dc.w	color01,$0006
	dc.w	(logo+$1800),$FFFE
	dc.w	color01,$0004
	dc.w	(logo+$1a00),$FFFE
	dc.w	color01,$0002
	dc.w	(logo+$1c00),$FFFE		
	dc.w	color01,$0001
	dc.w	(logo+$1e00),$FFFE		
	dc.w	color01,$0888

bars	dc.w	(base),$FFFE
	dc.w	color01,$0111
	dc.w	(base+$0200),$FFFE
	dc.w	color01,$0222
	dc.w	(base+$0400),$FFFE
	dc.w	color01,$0444
	dc.w	(base+$0600),$FFFE
	dc.w	color01,$0666
	dc.w	(base+$0800),$FFFE
	dc.w	color01,$0888
	dc.w	(base+$0a00),$FFFE
	dc.w	color01,$0aaa
	dc.w	(base+$0c00),$FFFE
	dc.w	color01,$0ccc
	dc.w	(base+$0e00),$FFFE
	dc.w	color01,$0fff
	dc.w	(base+$1000),$FFFE
	dc.w	color01,$0ccc
	dc.w	(base+$1200),$FFFE
	dc.w	color01,$0aaa
	dc.w	(base+$1400),$FFFE
	dc.w	color01,$0888
	dc.w	(base+$1600),$FFFE
	dc.w	color01,$0666
	dc.w	(base+$1800),$FFFE
	dc.w	color01,$0444
	dc.w	(base+$1a00),$FFFE
	dc.w	color01,$0222
	dc.w	(base+$1c00),$FFFE		
	dc.w	color01,$0111
	dc.w	(base+$1e00),$FFFE		
	dc.w	color01,$0888

bars2	dc.w	(base2),$FFFE
	dc.w	color01,$0111
	dc.w	(base2+$0200),$FFFE
	dc.w	color01,$0222
	dc.w	(base2+$0400),$FFFE
	dc.w	color01,$0444
	dc.w	(base2+$0600),$FFFE
	dc.w	color01,$0666
	dc.w	(base2+$0800),$FFFE
	dc.w	color01,$0888
	dc.w	(base2+$0a00),$FFFE
	dc.w	color01,$0aaa
	dc.w	(base2+$0c00),$FFFE
	dc.w	color01,$0ccc
	dc.w	(base2+$0e00),$FFFE
	dc.w	color01,$0fff
	dc.w	(base2+$1000),$FFFE
	dc.w	color01,$0ccc
	dc.w	(base2+$1200),$FFFE
	dc.w	color01,$0aaa
	dc.w	(base2+$1400),$FFFE
	dc.w	color01,$0888
	dc.w	(base2+$1600),$FFFE
	dc.w	color01,$0666
	dc.w	(base2+$1800),$FFFE
	dc.w	color01,$0444
	dc.w	(base2+$1a00),$FFFE
	dc.w	color01,$0222
	dc.w	(base2+$1c00),$FFFE		
	dc.w	color01,$0111
	dc.w	(base2+$1e00),$FFFE		
	dc.w	color01,$0888

bars3	dc.w	(base3),$FFFE
	dc.w	color01,$0111
	dc.w	(base3+$0200),$FFFE
	dc.w	color01,$0222
	dc.w	(base3+$0400),$FFFE
	dc.w	color01,$0444
	dc.w	(base3+$0600),$FFFE
	dc.w	color01,$0666
	dc.w	(base3+$0800),$FFFE
	dc.w	color01,$0888
	dc.w	(base3+$0a00),$FFFE
	dc.w	color01,$0aaa
	dc.w	(base3+$0c00),$FFFE
	dc.w	color01,$0ccc
	dc.w	(base3+$0e00),$FFFE
	dc.w	color01,$0fff
	dc.w	(base3+$1000),$FFFE
	dc.w	color01,$0ccc
	dc.w	(base3+$1200),$FFFE
	dc.w	color01,$0aaa
	dc.w	(base3+$1400),$FFFE
	dc.w	color01,$0888
	dc.w	(base3+$1600),$FFFE
	dc.w	color01,$0666
	dc.w	(base3+$1800),$FFFE
	dc.w	color01,$0444
	dc.w	(base3+$1a00),$FFFE
	dc.w	color01,$0222
	dc.w	(base3+$1c00),$FFFE		
	dc.w	color01,$0111
	dc.w	(base3+$1e00),$FFFE		
	dc.w	color01,$0888

	dc.w	$ffff,$fffe		; Wait

*****************************************************************************
;			     Variables
*****************************************************************************
	section	variables,data	; Fast
gfxname	dc.b	'graphics.library',0
	even
gfxbase		dc.l	0		; Space for gfx base address
dmasave		dc.w	0
level3save	dc.l	0
intensave	dc.w	0
intrqsave	dc.w	0
Sprite_Empty    dcb.b 10,0
		even
bob		ds.l	1		; The bob lives at?

*************************
* Chip Data & Variables *
*************************
	section	gfxstuff,data_c
	even
screen	incbin	Source:M.McKenzie/bitmaps/op-screen1.raw	; Screen data
	even
bob2	incbin	Source:M.McKenzie/bitmaps/chars2.raw	; On
	even
bob1	incbin	Source:M.McKenzie/bitmaps/chars1.raw	; Off
	even
;mt_data incbin "source:modules/mod.music"
	even

****************************************************************************
*				STARS					   *
****************************************************************************

SETUP_STARS
	move.l	#Sprite,D0		Address of Stars
	LEA  	Sp_Ptr,A0  		pointers in Coperlist
        move.w  D0,6(A0)		Load high word
	swap 	D0			swap words
	move.w  D0,2(A0)		Load low words
        move.l  #Sprite_Empty,D0	Empty Sprite
	LEA  	Sp_Ptr,A0		Pointers in copper
	add.l   #8,A0			Point Past Sprite0
	move.l  #6,D1			Loop Value
Sp_Lp	move.w  D0,6(A0) 		Load Blank Sprites Loop
	swap    D0
	move.w  D0,2(A0)
	swap    D0
	add.l	#8,A0			Next pointer in Copper
	dbf     D1,Sp_Lp		Loop
	rts

Stars   move.l	#SpriteE-Sprite,D2	Length (N) of Star data block
	DIVU	#(8*3),D2		No.Layers (3)
	move.l	#Sprite,A0		Address of stars
Ch	CMPI.B	#$DF,1(A0)		Reached far right of screen?
	bne.s   Mv			No,branch
	move.b	#$38,1(A0)		Yes,reset to far left 
Mv	addq.b  #$1,1(A0)		1st layer speed
	addq.b	#$2,9(A0)		2nd layer speed
	addq.b	#$3,17(A0)		3rd layer speed
	add.l	#24,A0			Next 3 stars
	dbf.w	D2,Ch			Loop N times
	rts

****************************************************************************
*				STAR POS				   *
****************************************************************************
	section	starry,data_c

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

