********************
* CREW 01 PRESENTS *
********************
*GlenzVectorroutine*
*		   *
* Greetz & thx to: *
* Vektor (zite)    *
* Teak (Alf)       *
* Price (Tfa)      *
* CFI (eclipse)    *
* THC (The hidden) *
* Hitrix (no group)*
* Solution inc.    *
********************

DMASET:		equ	%1000000111000000
;			 -----a-bcdefghij
;		a: 	Blitter Nasty
;		b: 	Bitplane DMA
;		c: 	Copper DMA
;		d: 	Blitter DMA
;		e: 	Sprite DMA
;		f: 	Disk DMA
;		g-j: 	Audio 3-0 DMA

OpenLibrary:	equ	-408
CloseLibrary:	equ	-414


**************************
* HARDWARE REGESTER LIST *
*			 *
*     BY -CREW ONE-	 *
**************************

CUSTOM:		EQU	$DFF000

BLTCON0:	EQU	$040
BLTCON1:	EQU	$042
BLTAFWM:	EQU	$044
BLTALWM:	EQU	$046
BLTCPTH:	EQU	$048
BLTCPTL:	EQU	$04A
BLTBPTH:	EQU	$04C
BLTBPTL:	EQU	$04E
BLTAPTH:	EQU	$050
BLTAPTL:	EQU	$052
BLTDPTH:	EQU	$054
BLTDPTL:	EQU	$056
BLTSIZE:	EQU	$058
BLTCMOD:	EQU	$060
BLTBMOD:	EQU	$062
BLTAMOD:	EQU	$064
BLTDMOD:	EQU	$066
BLTCDAT:	EQU	$070
BLTBDAT:	EQU	$072
BLTADAT:	EQU	$074
BLTDDAT:	EQU	$000

BPL1PTH:	EQU	$0E0
BPL1PTL:	EQU	$0E2
BPL2PTH:	EQU	$0E4
BPL2PTL:	EQU	$0E6
BPL3PTH:	EQU	$0E8
BPL3PTL:	EQU	$0EA
BPL4PTH:	EQU	$0EC
BPL4PTL:	EQU	$0EE
BPL5PTH:	EQU	$0F0
BPL5PTL:	EQU	$0F2
BPL6PTH:	EQU	$0F4
BPL6PTL:	EQU	$0F6
BPLCON0:	EQU	$100
BPLCON1:	EQU	$102
BPLCON2:	EQU	$104
BPL1MOD:	EQU	$108
BPL2MOD:	EQU	$10A

COPCON:		EQU	$02E
COP1LCH:	EQU	$080
COP1LCL:	EQU	$082
COP2LCH:	EQU	$084
COP2LCL:	EQU	$086
COPJMP1:	EQU	$088
COPJMP2:	EQU	$08A

DMACONR:	EQU	$002
DMACON:		EQU	$096
INTREQ:		EQU	$09C
INTENA:		EQU	$09A
INTENAR:	EQU	$01C
INTREQR:	EQU	$01E


VPOSR:		EQU	$004
VHPOSR:		EQU	$006
VPOSW:		EQU	$02A
VHPOSW:		EQU	$02C


	section	mycode,code
    
	bsr	Init1
	move.l	$80,a0
	move.l	a0,oldtrap
	lea	start_of_code,a0
	move.l	a0,$80
	trap	#0
	move.l	oldtrap,$80
	bsr	Restore2	
	rts


**********************
*    Main Loop	     *
**********************
start_of_code:
	bsr.w	init_2
	bsr.w	init2
	bsr.w	waitblit
	move.l	#rottab,rotpoint

wm2:
	bsr.w	do_vec
	bsr	sub_dats

	btst	#6,$bfe001
	bne.s	wm2
	
endit:
	bsr.w	restore1
	rte


**********************************
* ROUTINES FOR INITIAL PROCEDURE *
* AGA COMPATIBLE !!!!            *
**********************************

Init1:
        move.l  4.w,a6          	; get ExecBase
        lea     gfxname,a1      	; graphics name
        moveq   #0,d0           	; any version
        jsr     OpenLibrary(a6)
        tst.l   d0
        beq     End             	; failed to open? Then quit
        move.l  d0,gfxbase2
        move.l  d0,a6
        move.l  34(a6),wbview	; gb_ActiView = 32

        move.w  #0,a1          	 	; clears full long-word
        jsr     -$00de(a6)      	; Flush View to nothing
        jsr     -$010e(a6)        	; Wait once (WaitTOF)
        jsr     -$010e(a6)        	; Wait once (WaitTOF)
      
;	move.w  $dff07c,d0
;	cmp.b   #$f8,d0
;	bne.w   .notaga

        move.w  #0,$dff1fc      	; reset sprites (fix V39 bug)

;.notaga
        rts

Init2:
	lea	$dff000,a6
	move.w	$1c(a6),intena_save		;store old intena
	move.w	$2(a6),dmacon_save		;store old dmacon
	move.w	$10(a6),adkcon_save		;store old adkcon

	move.w	#$7fff,$9a(a6)			;clear interrupt enable

	jsr	vwait

	move.w	#$7fff,$96(a6)
	lea	copperlist,a0
	move.l	a0,$80(a6)
	move.w	#dmaset!$8200,$96(a6)		;dma kontrol data
	move.l	$6c.w,oldinter_save		;store old inter pointer
	lea	newirq,a0
	move.l	a0,$6c.w			;set interrupt pointer

	move.w	#$7fff,$9c(a6)			;clear request
	move.w	#$c020,$9a(a6)			;interrupt enable
	rts


Restore1:
	lea	$dff000,a6

	move.w	#$7fff,$9a(a6)			;disable interrupts

	jsr	vwait

	move.w	#$7fff,$96(a6)
	move.l	oldinter_save,$6c.w		;restore inter pointer
	move.w	dmacon_save,d0		;restore old dmacon
	or.w	#$8000,d0
	move.w	d0,$96(a6)		
	move.w	adkcon_save,d0		;restore old adkcon
	or.w	#$8000,d0
	move.w	d0,$9e(a6)
	move.w	intena_save,d0		;restore inter data
	or.w	#$c000,d0
	move.w	#$7fff,$9c(a6)
	move.w	d0,$9a(a6)

	rts

restore2:
        move.l  wbview,a1
        move.l  gfxbase2,a6
        jsr     -$00de(a6) ; Fix view

        move.l  38(a6),$dff080   ; Kick it into life
                                         ; copinit = 36
        move.l  a6,a1
        move.l  4.w,a6
        jsr     CloseLibrary(a6) 	; EVERYONE FORGETS THIS!!!!

End:    rts                           ; back to workbench/clc

**********************

newirq:
	btst.b	#5,$dff01f
	beq.s	noint
	movem.l	d0-d7/a0-a6,-(a7)		;put registers on stack
	lea	$dff000,a6
	move.w	#$4020,$9c(a6)			;clear interrupt request
	movem.l	(a7)+,d0-d7/a0-a6		;get registers from stack
noint:
	rte

oldirq:	jmp	$00000000

****************************************************

Do_vec:

	bsr.w	swapit

	move.l	rotco(PC),d0
	subq.l	#1,d0
	move.l	d0,rotco
	cmpi.l	#1,d0
	bne.s	rotver

newrot:
	move.l	rotpoint(PC),a0
	move.l	(a0)+,d1	
	cmpi.l	#999,d1
	bne.s	rotv2
	move.l	#rottab,rotpoint
	bra.s	newrot

rotv2:
	move.l	d1,rotco
	move.l	(a0)+,xa1
	move.l	(a0)+,ya1
	move.l	(a0)+,za1
	move.l	a0,rotpoint

rotver:
	move.l	xa1(PC),d0
	move.l	ya1(PC),d1
	move.l	za1(PC),d2

	add.l	d0,axisx
	cmpi.l	#359,axisx
	blt.s	xv
	sub.l	#359,axisx
xv:

	add.l	d1,axisy
	cmpi.l	#359,axisy
	blt.s	yv
	subi.l	#359,axisy
yv:
	add.l	d2,axisz
	cmpi.l	#359,axisz
	blt.s	zv
	subi.l	#359,axisz
zv:

	move.l	axisx(PC),d2
	move.l	axisy(PC),d1
	move.l	axisz(PC),d0
	bsr.w	setup_rotation_table

	lea	vectabel(PC),a4
	lea	temptabel(PC),a3
	Move.w	#$0222,$dff180
	lea	rotation_table,a1

next_vec:
	tst.w	(a4)+
	beq.s	end_vec

	move.w	(a4)+,d0
	move.w	(a4)+,d1
	move.w	(a4)+,d2

	bsr.w 	newxyz
		
verderz:
	addi.w	#160,d0
	addi.w	#128,d1

	move.w	d0,(a3)+
	move.w	d1,(a3)+
	move.w	d5,(a3)+

cont_vec:
	bra.s	next_vec

end_vec:
	Move.w	#$220,$dff180
	move.w	#999,(a3)+

	bsr.w	plot_line

end_points:
	Move.w	#$0000,$dff180
	bsr.w	vwait
	Move.w	#$0202,$dff180
	bsr.w	clrbit
	Move.w	#$0200,$dff180
	move.l	show(PC),d0
	move.w	d0,lo1
	swap	d0
	move.w	d0,hi1
	rts

Sub_Dats:
;	rts
	Lea	Vectabel(PC),a0

	cmpi.w	#9,10(a0)
	blt.s	reached

	subi.w	#-1,2(a0)
	subi.w	#-1,4(a0)

	subq.w	#1,10(a0)
	subi.w	#-1,12(a0)

	subi.w	#-1,18(a0)
	subq.w	#1,20(a0)
	rts

reached:
	clr.l	rottab+4
;	clr.l	xa1
	move.l	#20,axisx

	move.w	#-48,2(a0)
	move.w	#-48,4(a0)

	move.w	#47,10(a0)
	move.w	#-48,12(a0)

	move.w	#-48,18(a0)
	move.w	#47,20(a0)

	rts

**********

x1	=	0
y1	=	2
z1	=	4
x2	=	6
y2	=	8
z2	=	10
x3	=	12
y3	=	14
z3	=	16

xa	=	0
ya	=	2
za	=	4
xb	=	6
yb	=	8
zb	=	10

aant	=	15
as	=	4

Plot_Line:
	bsr	waitblit
	lea	data2,a5

	lea	temptabel,a0
	lea	addtab,a1

	Move.w	x2(a0),d0
	sub.w	x1(a0),d0

	Move.w	y2(a0),d1
	sub.w	y1(a0),d1

;	Move.w	z2(a0),d2
;	sub.w	z1(a0),d2

	asr.w	#as,d0			; xadd
	asr.w	#as,d1			; yadd
;	asr.w	#as,d2			; zadd

	Move.w	d0,xa(a1)
	Move.w	d1,ya(a1)
;	Move.w	d2,za(a1)

*
	Move.w	x3(a0),d0
	sub.w	x1(a0),d0

	Move.w	y3(a0),d1
	sub.w	y1(a0),d1

;	Move.w	z3(a0),d2
;	sub.w	z1(a0),d2

	asr.w	#as,d0			; xadd
	asr.w	#as,d1			; yadd
;	asr.w	#as,d2			; zadd

	Move.w	d0,xb(a1)
	Move.w	d1,yb(a1)
;	Move.w	d2,zb(a1)

	Move.l	#aant,d7

	Move.w	x1(a0),d0
	Move.w	y1(a0),d1
;	Move.w	z1(a0),d2
	Move.l	show(PC),a3
	lea	points_tab2,a4

aloop1:
	bsr.s	set_point

	add.w	xb(a1),d0
	add.w	yb(a1),d1
;	add.w	za(a1),d2

	dbf	d7,aloop1

	rts

set_point:
	Move.w	d0,tx
	Move.w	d1,ty
;	Move.w	d2,tz
	Move.l	d7,counter

* Set it

	Move.l	#aant,d7

bloop1:
	tst.b	(a5)+
	beq.s	noset
	bsr	set_act_point
noset:	
	move.w	#$0123,$dff180
	add.w	xa(a1),d0
	add.w	ya(a1),d1
;	add.w	zb(a1),d2

	dbf	d7,bloop1

	Move.w	tx,d0
	Move.w	ty,d1
;	Move.w	tz,d2
	Move.l	counter(PC),d7

	rts

set_act_point:
	Move.w	d0,d3
	Move.w	d1,d4

	Move.l	a3,a2
	tst.w	d2
	beq.s	zero

	Ext.l	d4
	Ext.l	d3

;	divs	d2,d3
;	divs	d2,d4

	asr.w	#8,d3
	asr.w	#8,d4

;	asr.w	#1,d3
;	asr.w	#1,d4

	addi.w	#160,d3
	addi.w	#128,d4

	add.w	d4,d4
	add.w	(a4,d4.w),a2

	Move.w	d3,d5
	not.w	d5
	
	lsr.w	#3,d3

	add.w	d3,a2

	bset	d5,(a2)
zero:
	rts



Swapit:
	move.l	bit(PC),d0
	cmpi.l	#1,d0
	beq.s	sw1
	move.l	#1,bit
	move.l	#piccie1,show
	move.l	#piccie2,kill
	bra.s	sw2
sw1:
	clr.l	bit
	move.l	#piccie2,show
	move.l	#piccie1,kill
sw2:
	rts
*****************************************************

waitblit:

	btst.b	#6,$dff002
	bne.s 	waitblit
	rts

*****************************************************
clrbit:
	move.l	#$dff000,a6
	bsr 	waitblit			
	move.l	#$01000000,bltcon0(a6)	
	Move.w	#12,bltdmod(a6)
	move.l	kill,d0
	add.l	#4+[44*20],d0
	Move.l	d0,bltdpth(a6)
	move.w	#[205*64]+16,bltsize(a6)
	rts
*****************************************************

vwait:
	move.b	$dff006,d5
	cmp.b	#$ff,d5
	bne.s	vwait
	rts

init_2:
	move.l 	bitplane1,d0		;bitplane 1 init
	move.w 	d0,lo1
	swap 	d0
	move.w	d0,hi1
 
	move.l 	copptr,a0		;copper
	move.l 	(a0),oldcop		;oude copperl naar..
	move.l  #copperlist,(a0)	;jaja


	moveq	#0,d1
	lea	Points_tab(PC),a0
	MOVE.W	#319,D0
cloop1:
	addq.l	#1,d1
	moveq	#0,d2
	moveq	#0,d3
	Move.l	d1,d2
	lsr.l	#3,D2		;divu	#8,d2
	Move.l	d2,d3
	Move.w	d2,(a0)+
	swap	d3
	neg.w	d3
	addq.l	#7,d3
	Move.w	d3,(a0)+
	DBRA	d0,cloop1

	Lea	Points_tab2(PC),a0
	moveq	#0,d1
	move.w	#255,d0
dloop2:
	addq.l	#1,d1
	Move.l	d1,d2
	mulu	#44,d2
	move.w	d2,(a0)+
	dbra	d0,dloop2
	rts

**********************************


Cos_A		=	0
Sin_A		=	2
Cos_B		=	4
Sin_B		=	6
Cos_G		=	8
Sin_G		=	10

Setup_rotation_table:				; d0/d1/d2 z/y/x as

	lea	sintab(PC),a3		;sin
	lea	180(a3),a4		;cos

	add.w	d0,d0			;alpha *2
	add.w	d1,d1			;beta *2
	add.w	d2,d2			;gamma *2

	lea	sin_cos_values(PC),a0
	move.w	(a4,d0.w),(a0)+		;cos alpha
	move.w	(a3,d0.w),(a0)+		;sin alpha

	move.w	(a4,d1.w),(a0)+		;cos beta
	move.w	(a3,d1.w),(a0)+		;sin beta

	move.w	(a4,d2.w),(a0)+		;cos gamma
	move.w	(a3,d2.w),(a0)+		;sin gamma


	Lea	Sin_Cos_Values(PC),a0
	lea	Rotation_table(PC),a1
	
	Move.w	Cos_B(a0),d0
	Muls	Cos_G(a0),d0
	add.l	d0,d0
	swap	d0
	Move.w	d0,(a1)+			; CosB*CosG


	Move.w	Sin_G(a0),d0
	neg.w	d0
	Muls	Cos_B(a0),d0
	Add.l	d0,d0
	Swap	d0
	Move.w	d0,(a1)+

	Move.w	Sin_B(a0),d0			
	neg.w	d0
	Move.w	d0,(a1)+			; -SinB*SinG

	Muls	Sin_a(a0),d0
	Add.l	d0,d0
	Swap	d0
	Move.w	d0,d3

	muls	Cos_g(a0),d0
	add.l	d0,d0
	swap	d0

	Move.w	Sin_g(a0),d1
	Muls	Cos_a(a0),d1
	add.l	d1,d1
	swap	d1
	Move.w	d1,d2
	add.w	d1,d0
	Move.w	d0,(a1)+			; SinG*CosA+CosG*SinB*-SinA

	Move.w	d3,d0
	Muls	sin_g(a0),d0
	add.l	d0,d0
	swap	d0

	Move.w	Cos_G(a0),d1
	Muls	cos_a(a0),d1
	add.l	d1,d1
	swap	d1			

	sub.w	d0,d1
	Move.w	d1,(a1)+			; CosG*CosA-SinG*-SinB*SinA

	Move.w	Sin_A(a0),d0
	neg.w	d0				; -SinA
	muls	Cos_B(a0),d0
	add.l	d0,d0
	swap	d0
	Move.w	d0,(a1)+			; -CosB*SinA
	
	Move.w	Cos_G(a0),d0
	muls	sin_B(a0),d0
	add.l	d0,d0
	swap	d0
	Muls	Cos_A(a0),d0
	add.l	d0,d0
	swap	d0

	Move.w	Sin_G(a0),d1
	Muls	Sin_A(a0),d1
	add.l	d1,d1
	swap	d1
	add.w	d1,d0
	Move.w	d0,(a1)+			; CosG*SinB*CosA+SinG*SinA

	Move.w	cos_G(a0),d0
	muls	sin_A(a0),d0
	add.l	d0,d0
	swap	d0

	Move.w	d2,d1				; SinG*CosA
	Muls	Sin_B(a0),d1
	add.l	d1,d1
	swap	d1

	Sub.w	d1,d0
	Move.w	d0,(a1)+			; CosG*SinA-SimG*SinB*CosA

	Move.w	cos_b(a0),d0
	Muls	Cos_a(a0),d0
	add.l	d0,d0
	swap	d0
	Move.w	d0,(a1)+

	rts


NewXYZ:						; d0-d2 = x-z
;	Lea	Rotation_Table,a2
	Move.l	a1,a2
	Move.l	a0,a5				; part1x

	Move.w	d0,d5			;x
	Move.w	d1,d6			;y
	Move.w	d2,d7			;z

	Muls	(a2)+,d0
	Muls	(a2)+,d1
	Muls	(a2)+,d2
	add.l	d2,d1
	add.l	d1,d0
	add.l	d0,d0
	swap	d0

	Move.w	d5,d1
	Move.w	d6,d2
	Move.w	d7,d3

	Muls	(a2)+,d1
	Muls	(a2)+,d2
	Muls	(a2)+,d3
	add.l	d3,d2
	add.l	d2,d1
	add.l	d1,d1
	swap	d1

	Muls	(a2)+,d5
	Muls	(a2)+,d6
	Muls	(a2)+,d7
	Add.l	d7,d6
	Add.l	d6,d5
	add.l	d5,d5
	swap	d5

Perspective:
	addi.w	#456,d5

	ext.l	d0
	ext.l	d1

	asl.w	#8,d0			;	<----- Asl rules !!!
	asl.w	#8,d1

	rts

Sin_cos_values:
	dcb.w	6,0
rotation_table:
	dcb.w	9,0

****************************************

; DATA

gfxname:	dc.b 'graphics.library',0,0
OldInter_save:	dc.l	0		; dito
OldCop1_save:	dc.l	0		; dito
OldCop2_save:	dc.l	0		; dito
INTENA_save:	dc.w	0		; dito
DMACON_save:	dc.w	0		; dito
ADKCON_save:	dc.w	0		; dito
wbview:		dc.l    0
gfxbase2:	dc.l    0
oldtrap:	dc.l	0

bitplane1:	dc.l	piccie1
bitplane2:	dc.l	piccie1+[10240]+[1024]
bitplane3:	dc.l	piccie1+[20480]+[2048]
bitplane4:	dc.l	piccie1+[20480+10240]+[1024+2048]
bitplane5:	dc.l	piccie1+[20480+20480]+[4096]

	even
copptr:		blk.l 1,0
oldcop:		blk.l 1,0
bit:		dc.l	0


xa1:		dc.l	8
ya1:		dc.l	0
za1:		dc.l	0
rotpoint:	dc.l	0
rotco:		dc.l	1


tx:		dc.l	0
ty:		dc.l	0
tz:		dc.l	0
counter:	dc.l	0

sinx:		dc.w	0
siny:		dc.w	0
sinz:		dc.w	0
cosx:		dc.w	0
cosy:		dc.w	0
cosz:		dc.w	0

Part1X:		dc.l	0
Part2X:		dc.l	0
Part3X:		dc.l	0

Part1Y:		dc.l	0
Part2Y:		dc.l	0
Part3Y:		dc.l	0

Part1Z:		dc.l	0
Part2Z:		dc.l	0
Part3Z:		dc.l	0

mul:		dc.w	0
count:		dc.l	0
vecpointer:	dc.l	0
axisx:		dc.l	20
axisy:		dc.l	0
axisz:		dc.l	0
show:		dc.l	0
kill:		dc.l	0

	even

vectabel:
	dc.w	1,-48,-48,0
	dc.w	1,47,-48,0
	dc.w	1,-48,47,0
	dc.w	0,0,0,0		; end

rottab:
	dc.l	350,7,0,0	; time - x - y - z   rotation    
;	dc.l	150,3,2,1
;	dc.l	140,4,2,0
;	dc.l	100,5,3,1
;	dc.l	110,4,4,1
;	dc.l	180,1,5,1
;	dc.l	170,0,4,4
;	dc.l	200,2,3,2
;	dc.l	190,1,3,0
;	dc.l	250,2,3,2
	dc.l	999,0,0

temptabel:
	blk.w	250,0



Sintab:
	dc.l	$0000023B,$047706B2,$08ED0B27,$0D610F99,$11D01406
	dc.l	$163A186C,$1A9C1CCB,$1EF72120,$2348256C,$278D29AC
	dc.l	$2BC72DDF,$2FF33203,$340F3618,$381C3A1C,$3C173E0E
	dc.l	$3FFF41EC,$43D445B6,$4793496A,$4B3C4D08,$4ECD508D
	dc.l	$524653F9,$55A6574B,$58EA5A82,$5C135D9C,$5F1F609A
	dc.l	$620D6379,$64DD6639,$678D68D9,$6A1D6B59,$6C8C6DB7
	dc.l	$6ED96FF3,$7104720C,$730B7401,$74EF75D3,$76AD777F
	dc.l	$78477906,$79BC7A68,$7B0A7BA3,$7C327CB8,$7D337DA5
	dc.l	$7E0E7E6C,$7EC17F0B,$7F4C7F83,$7FB07FD3,$7FEC7FFB
	dc.l	$7FFF7FFB,$7FEC7FD3,$7FB07F83,$7F4C7F0B,$7EC17E6C
	dc.l	$7E0E7DA5,$7D337CB8,$7C327BA3,$7B0A7A68,$79BC7906
	dc.l	$7847777F,$76AD75D3,$74EF7401,$730B720C,$71046FF3
	dc.l	$6ED96DB7,$6C8C6B59,$6A1D68D9,$678D6639,$64DD6379
	dc.l	$620D609A,$5F1F5D9C,$5C135A82,$58EA574B,$55A653F9
	dc.l	$5246508D,$4ECD4D08,$4B3C496A,$479345B6,$43D441EC
	dc.l	$40003E0E,$3C173A1C,$381C3618,$340F3203,$2FF32DDF
	dc.l	$2BC729AC,$278D256C,$23482120,$1EF71CCB,$1A9C186C
	dc.l	$163A1406,$11D00F99,$D610B27,$8ED06B2,$477023B
	dc.l	$FDC5,$FB89F94E,$F713F4D9,$F29FF067,$EE30EBFA
	dc.l	$E9C6E794,$E564E335,$E109DEE0,$DCB8DA94,$D873D654
	dc.l	$D439D221,$D00DCDFD,$CBF1C9E8,$C7E4C5E4,$C3E9C1F2
	dc.l	$C001BE14,$BC2CBA4A,$B86DB696,$B4C4B2F8,$B133AF73
	dc.l	$ADBAAC07,$AA5AA8B5,$A716A57E,$A3EDA264,$A0E19F66
	dc.l	$9DF39C87,$9B2399C7,$98739727,$95E394A7,$93749249
	dc.l	$9127900D,$8EFC8DF4,$8CF58BFF,$8B118A2D,$89538881
	dc.l	$87B986FA,$86448598,$84F6845D,$83CE8348,$82CD825B
	dc.l	$81F28194,$813F80F5,$80B4807D,$8050802D,$80148005
	dc.l	$80018005,$8014802D,$8050807D,$80B480F5,$813F8194
	dc.l	$81F2825B,$82CD8348,$83CE845D,$84F68598,$864486FA
	dc.l	$87B98881,$89538A2D,$8B118BFF,$8CF58DF4,$8EFC900D
	dc.l	$91279249,$937494A7,$95E39727,$987399C7,$9B239C87
	dc.l	$9DF39F66,$A0E1A264,$A3EDA57E,$A716A8B5,$AA5AAC07
	dc.l	$ADBAAF73,$B133B2F8,$B4C4B696,$B86DBA4A,$BC2CBE14
	dc.l	$C000C1F2,$C3E9C5E4,$C7E4C9E8,$CBF1CDFD,$D00DD221
	dc.l	$D439D654,$D873DA94,$DCB8DEE0,$E109E335,$E564E794
	dc.l	$E9C6EBFA,$EE30F067,$F29FF4D9,$F713F94E,$FB89FDC5
	dc.l	$23B,$47706B2,$8ED0B27,$D610F99,$11D01406
	dc.l	$163A186C,$1A9C1CCB,$1EF72120,$2348256C,$278D29AC
	dc.l	$2BC72DDF,$2FF33203,$340F3618,$381C3A1C,$3C173E0E
	dc.l	$3FFF41EC,$43D445B6,$4793496A,$4B3C4D08,$4ECD508D
	dc.l	$524653F9,$55A6574B,$58EA5A82,$5C135D9C,$5F1F609A
	dc.l	$620D6379,$64DD6639,$678D68D9,$6A1D6B59,$6C8C6DB7
	dc.l	$6ED96FF3,$7104720C,$730B7401,$74EF75D3,$76AD777F
	dc.l	$78477906,$79BC7A68,$7B0A7BA3,$7C327CB8,$7D337DA5
	dc.l	$7E0E7E6C,$7EC17F0B,$7F4C7F83,$7FB07FD3,$7FEC7FFB
	dc.w	$7FFF

points_tab:
	blk.l	320,0

points_tab2:
	blk.l	256,0
addtab:
	blk.w	20,0

data:		dc.b	0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
		dc.b	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0
		dc.b	0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0

		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1


data2:		dc.b	0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
		dc.b	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
		dc.b	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
		dc.b	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
		dc.b	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
		dc.b	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
		dc.b	0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		dc.b	0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0
		dc.b	0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0

		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1








		section	gfx,data_C

copperlist:
	dc.w	$0100,$1200
	dc.w 	$e0			;bitplane ptrs
hi1:	dc.w 	$0000
	dc.w	$e2
lo1:	dc.w 	$0000

;	dc.w 	$e4
;hi2:	dc.w 	$0000
;	dc.w 	$e6
;lo2:	dc.w 	$0000
;	dc.w 	$e8
;hi3:	dc.w 	$0000
;	dc.w	$ea
;lo3:	dc.w	$0000
;	dc.w 	$ec
;hi4:	dc.w 	$0000
;	dc.w	$ee
;lo4:	dc.w	$0000
;	dc.w 	$f0
;hi5:	dc.w 	$0000
;	dc.w	$f2
;lo5:	dc.w	$0000
	dc.w	$0104,%0000000000000000 ;bplcon2
	dc.w 	$0108,$0002		;bpl1mod
	dc.w	$010a,$0002		;bpl2mod
	dc.w 	$0092,$0030		;ddfstrt
	dc.w 	$0094,$00d0		;ddfstop

	dc.w 	$008e,$2471		;diwstrt
	dc.w	$0090,$24d1		;diwstop

;	dc.w	$0180,$0000
	dc.w	$0182,$0fff
	dc.w 	$ffff,$fffe		;end copper
	dc.w 	$ffff,$fffe		;end copper

		blk.b	44*256
piccie1:	blk.b [1*[44*256]],0
		blk.b	44*256,0

piccie2:	blk.b [1*[44*256]],0
		blk.b	44*256,0


