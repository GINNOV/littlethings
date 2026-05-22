
*************** another small intro coded by Cool-G/SILENTS ***************

			* for internal use only !! *

; how to put it together:
;  start ASM1, take 200 Kb of CHIPmem (c/200)
;  first write the scrolltexts (see labels 'scrolltext:' and 'windowtext:')
;  then assemble it (Amiga/shift/a)
;  save the source if you want:   w <name>
;  save the object:  wo <name>
;  exit asm (menu or '!')
;  load TETRAPACKER
;  take memory from $40000 to $55000
;  load the <name> object file as 'reloc', locate it at $40000
;  and crunch it using offset $400
;  jump in address is ofcourse $40000
;  save it with NORMAL header
;  READY !!!

	lea.l	main(pc),a0
	move.l	a0,$80.w
	trap	#$0
	rts

main:	movem.l	d0-d7/a0-a6,-(a7)
	move.l	$4.w,a6
	lea	libname(pc),a1
	jsr	-408(a6)
	move.l	d0,a1
	move.l	$26(a1),oldcop
	jsr	-414(a6)
	
	movem.l	d0-d7/a0-a6,-(a7)
	jsr	mt_init
	movem.l	(a7)+,d0-d7/a0-a6

	bsr.w	fillcopper
	bsr.w	filldata
	
	lea.l	$dff000,a5
	move.w	$1c(a5),d0		;intenar
	move.w	$1e(a5),d1		;intreqr
	move.w	$02(a5),d2		;dmaconr
	move.w	#$7fff,$96(a5)
	move.w	#$82e0,$96(a5)
	move.w	#$7fff,$9a(a5)
	move.w	#$c020,$9a(a5)
	move.l	#copperlist1,$80(a5)
	clr.w	$88(a5)
	move.w	#$8000,d3
	or.w	d3,d0
	or.w	d3,d1
	or.w	d3,d2

	move.l	$6c.w,oldint
	lea.l	int(pc),a0
	move.l	a0,$6c.w

	movem.l d0-d7/a0-a6,-(a7)

loop:	btst	#6,$bfe001
	bne.s	loop

exit:	movem.l	(a7)+,d0-d7/a0-a6

	move.l	oldint,$6c.w

	move.l	oldcop(pc),$80(a5)
	move.w	d2,$96(a5)
	move.w	d1,$9c(a5)
	move.w	d0,$9a(a5)
	movem.l	(a7)+,d0-d7/a0-a6
	jsr	mt_end
	rte

libname:
	dc.b	"graphics.library",0
	even

oldcop:	dc.l	0
oldint:	dc.l	0

;---------------------------------
intdelay:	dc.b	5
plasmaswitch:	dc.b	0
		even
		
int:	jsr	mt_music

	lea.l	$dff000,a5
	btst	#10,$16(a5)			; check on RMB
	bne.s	.justgo
	sub.b	#1,intdelay
	bne.s	exitint

.justgo:move.b	#5,intdelay

	tst.b	plasmaswitch
	beq.s	.skip
	bsr	moveplasma
.skip:	bsr	showcredits
	bsr	puttextinwindow

	moveq	#0,d0
.wait:	move.b	$dff006,d0
	cmp.w	#$30,d0
	bgt.s	.wait

	bsr	movescrollsinus
	bsr	movescroll
	
exitint:lea.l	$dff000,a5
	move.w	#$0020,$9c(a5)			; disable interrupt
	rte

;---------------------------------
	
*****************************************************************
*								*
*	PLASMA ROUTINE by Cool-G				*
*								*
*****************************************************************
copperpointers:	dc.l	copperdata1,copperdata2
copperdata1:	dc.l	copperlist1,plasmafield2+8,$dff080,$dff088
copperdata2:	dc.l	copperlist2,plasmafield1+8,$dff084,$dff08a

lamedata:	dc.l	$01800000,plasmapattern,plasmapointers,sinuslist
		dc.w	2*sinuslistlength
plasmapointers:
globalDY:	dc.w	$2d8
indivDY:	dc.w	$188
globalDX:	dc.w	$366
indivDX:	dc.w	$80
		
moveplasma:
	lea.l	copperpointers(pc),a6		; switch double buffered
	move.l	(a6)+,a0			; copperlist
	move.l	(a6),a1
	move.l	a0,(a6)
	move.l	a1,-(a6)
	
	movem.l	(a0)+,d0/a1/a2/a3		; activate new copperlist
	move.l	d0,(a2)
	clr.w	(a3)

	lea.l	lamedata(pc),a5
	movem.l	(a5)+,d7/a0/a2/a6
	movem.w	(a5)+,d1/d2/d3/d4/d5
						; advance counters :
						
	addq.w	#8,d2				; global DY offset
	cmp.w	d1,d2
	blt.s	.ok1
	moveq	#0,d2
.ok1:	move.w	d2,(a2)+

	addq.w	#4,d3				; indiv DY global offset
	cmp.w	d1,d3
	blt.s	.ok2
	moveq	#0,d3
	add.b	#1,creditstrigger
.ok2:	move.w	d3,(a2)+

	addq.w	#6,d4				; global DX offset
	cmp.w	d1,d4
	blt.s	.ok3
	moveq	#0,d4
.ok3:	move.w	d4,(a2)+

	addq.w	#8,d5				; indiv DX global offset
	cmp.w	d1,d5
	blt.s	.ok4
	moveq	#0,d5
.ok4:	move.w	d5,(a2)

	add.w	(a6,d2.w),a0			; glb DY ptr
	lea.l	(a6,d3.w),a3			; ind DY ptr
	add.w	(a6,d4.w),a3			; glb DX ptr
	lea.l	(a6,d5.w),a5			; ind DX ptr

	moveq	#12,d2

	moveq	#16,d3				; indiv DY individual step
	moveq	#22,d4				; indiv DX individual step

	move.w	#Ysize-1,d6			; # rows
.yloop:	moveq	#Xsize-1,d5			; # cols

	move.l	a3,a6
	add.w	(a5),a6				; add indiv DX value (/row)
	add.w	d4,a5

.xloop:	move.w	(a6),d1  			; get indiv DY value (/column)
	add.w	d3,a6				; add indiv step DY
	move.w	(a0,d1.w),d7			; add indiv DY value
	move.l	d7,(a1)+			; put in copper with $0180
	dbf	d5,.xloop

	add.w	d2,a1				; adjust copperpos - next row
	tst.w	(a0)+				; linecounter up dummy
	dbf	d6,.yloop

	rts

;---------------------------------
sinusscrolldata:
	dc.w	6
	dc.l	endsinuslist2,sinuslist2,sinuslist2

movescrollsinus:
	lea.l	sinusscrolldata(pc),a0
	moveq	#0,d3
	move.w	(a0)+,d3			; global step sinustab
	movem.l	(a0)+,d0/d1/d2
	add.l	d3,d2
	cmp.l	d0,d2
	blt.s	.ok1
	move.l	d1,d2
.ok1:	and.b	#$fe,d2
	move.l	d2,-(a0)

	lea.l	sprite0+3(pc),a1
	lea.l	sprite1+3(pc),a2
	move.l	d2,a0
	moveq	#[spriteYsize/2]-1,d0
	moveq	#$fffffffe,d4
	moveq	#8,d5
	moveq	#1,d6
		
.loop:	move.l	(a0)+,d1

	move.b	d1,d2
	and.b	d6,d2
	and.b	d4,(a2)
	or.b	d2,(a2)
	asr	d6,d1
	move.b	d1,-2(a2)		; sprite 1 new hpos

	swap	d1
	
	move.b	d1,d2
	and.b	d6,d2
	and.b	d4,(a1)
	or.b	d2,(a1)
	asr	d6,d1
	move.b	d1,-2(a1)		; sprite 0 new hpos

	lea.l	8(a1),a1		; next position in spritelist0
	lea.l	8(a2),a2		; next position in spritelist1
	
	dbf	d0,.loop
exitscroll:
	rts
	
;---------------------------------
scrollentryptr:	dc.l	endscrolltemp
		dc.l	scrolltemp,emptysprite1+4,emptysprite+4
doubleheight:	dc.b	0
delay:		dc.b	0

movescroll:
	tst.b	delay
	beq.s	scrollraster
	subq.b	#1,delay
	bra.B	endscroll
scrollraster:
	lea.l	$dff000,a5
	lea.l	scrollentryptr(pc),a0
	movem.l	(a0)+,d0/a1/a2/a3
	tst.b	(a0)
	bne.s	double_on			; copy from scrollbuffer:
	move.l	(a1)+,(a3)			; copy+ 1 row in sprite 0
	bra.s	cont				
double_on:
	move.l	(a1),(a3)			; copy 1 row in sprite 0
cont:	move.l	(a1)+,(a2)			; copy 1 row in sprite 1

	cmp.l	d0,a1				; whole char copied ?
	blt.s	.ok
	bsr.B	getnewchar
	lea.l	scrolltemp,a1
.ok:	move.l	a1,scrollentryptr+4		; save new pos of char

	move.l	#$40004,d0
	moveq	#$ffffffff,d1
	move.w	#bltsize,d2
	lea.l	sprite0+12(pc),a0
	lea.l	sprite0+4(pc),a1
	
.wait:	btst	#14,$dff002
	bne.s	.wait

	move.l	a0,$50(a5)				; apt
	move.l	a1,$54(a5)				; dpt
	move.l	d0,$64(a5)				; amod / dmod
	move.l	d1,$44(a5)				; 1msk / lmsk
	move.w	#%0000100111110000,$40(a5)
	clr.w	$42(a5)
	move.w	d2,$58(a5)
	clr.l	emptysprite
	clr.l	emptysprite1
endscroll:
	rts

;------------------------------------------
getnewchar:
	move.l	#endlettertab,d1
	lea.l	scrolltextptr(pc),a1
	move.l	(a1),a2
	moveq	#0,d2
newchseek:
	move.b	(a2)+,d2
	cmp.b	#$ff,(a2)
	bne.s	rest
	lea.l	textrestart(pc),a2	; $ff restart scroll
rest:	move.l	a2,(a1)

	cmp.b	#1,d2
	bne.s	eff2
	move.b	#$80,delay		; 1 scroll delay
	bra.s	newchseek
eff2:	cmp.b	#2,d2
	bne.s	eff3
	not.b	doubleheight		; 2 toggle double height
	bra.s	newchseek
eff3:	cmp.b	#3,d2
	bne.s	eff4
	moveq	#0,d2
	move.b	(a2)+,d2		; 3 change sinusscroll global step
	move.w	d2,sinusscrolldata
	bra.s	newchseek
eff4:	cmp.b	#4,d2			; 4 plasma on (for introduction)
	bne.s	eff5
	move.b	#$ff,plasmaswitch
	bra.s	newchseek
eff5:	; more effects

	lea.l	letteraddr,a2
	asl.l	#2,d2
	add.l	d2,a2			; a2 points to the char-addresstab!
	moveq	#$ffffffff,d0		; get some data ready before waiting!
	lea.l	scrolltemp,a1
	moveq	#0,d1
		
.wait0:	btst	#14,$2(a5)
	bne.s	.wait0

putch:	move.l	(a2),$50(a5)		; copy the char in the scrollbuffer
	move.l	a1,$54(a5)
	move.l	d0,$44(a5)
	clr.w	$42(a5)
	move.l	d1,$64(a5)
	move.w	#%0000100111110000,$40(a5)
	move.w	#%0000010000000010,$58(a5)
	rts

;--------------------------------------
creditsdata:	dc.l	greycolortab
creditstrigger:	dc.b	1
		even
showcredits:
	lea.l	creditsdata(pc),a0
	moveq	#0,d0
	move.b	4(a0),d0		; check trigger
	cmp.b	#2,d0
	blt.s	exitcredits
	lea.l	creditcol1(pc),a2
	lea.l	creditcol2,a3
	cmp.b	#2,d0
	bne.s	nextcolor
initcredits:
	lea.l	greycolortab(pc),a1
	move.l	a1,(a0)
nextcolor:
	move.b	#3,4(a0)
	move.l	(a0),a1
	move.w	(a1),2(a2)		; put color in coppl1
	move.w	(a1)+,2(a3)		; put color in coppl2
	cmp.l	#endgreycolortab,a1
	blt.s	.ok
	clr.b	4(a0)
.ok:	move.l	a1,(a0)
exitcredits:
	rts
		
;----------------------------------------------	textpanel fillup
puttextinwindow:
	move.l	d0,-(a7)

	move.l	windowtextptr(pc),a0	; ptr textpos.
	lea.l	scherm+1126(pc),a1	; pos on dest.screen
	lea.l	letteraddr,a2		; ptrlist to chars
	lea.l	$dff000,a5		; base

	subq.b	#1,w_delay
	bne.w	endputtextinwindow
	move.b	w_speed(pc),w_delay

	addq.b	#1,w_mask		; next mask

	move.b	(a0)+,d0		; next char

	cmp.b	#RESTART,d0
	beq.w	w_restart
w_eff1:	cmp.b	#WSH,d0
	bne.s	w_eff2	
	move.b	d0,w_effect
w_eff2:
	cmp.b	#WSH,w_effect
	bne.s	.skip1
	moveq	#9,d0
	bra.s	.skip2
.skip1:	moveq	#28,d0
.skip2:	cmp.b	w_mask,d0
	beq.w	endline
	moveq	#0,d2
	move.b	w_mask(pc),d2		; nr of current mask
	asl.l	#2,d2			; make long (=offset in tab)

	moveq	#11,d1			; nr of chars on line
	move.w	#%0000010000000001,d7
	moveq	#$ffffffff,d4
	
putlineloop:
	lea.l	200*40(a1),a4		; 2nd plane
	moveq	#0,d0
	move.b	(a0)+,d0
	lea.l	masklist(pc),a3
	move.w	#%0000111110111000,d3
	cmp.b	#" ",d0
	bne.s	nospace
	lea.l	masklist2(pc),a3	; spaces have special treatment
	move.w	#%0000111111000010,d3
nospace:asl.l	#2,d0			; make long (=offset in tab)
	move.l	(a2,d0),d0
	move.l	(a3,d2),d5
	
.wait0:	btst	#14,$2(a5)
	bne.s	.wait0

	move.l	d0,$50(a5)			; a pth (font)
	move.l	a1,$54(a5)			; d pth (scherm)
	move.l	a1,$48(a5)			; c pth (background)
	move.l	d5,$4c(a5)			; b pth (mask)
	move.l	d4,$44(a5)			; fwm/lwm
	clr.w	$42(a5)				; con1
	move.w	#2,$64(a5)			; a mod
	clr.w	$62(a5)				; b mod
	move.w	#38,$60(a5)			; c mod
	move.w	#38,$66(a5)			; d mod
	move.w	d3,$40(a5)			; con 0
	move.w	d7,$58(a5)			; trig

	addq.l	#2,d0
	
.wait1:	btst	#14,$2(a5)
	bne.s	.wait1

	move.l	d0,$50(a5)			; a pth (font)
	move.l	a4,$54(a5)			; d pth (scherm)
	move.l	a4,$48(a5)			; c pth (background)
	move.l	d5,$4c(a5)			; b pth (mask)
	move.l	d4,$44(a5)			; fwm/lwm
	clr.w	$42(a5)				; con1
	move.w	#2,$64(a5)			; a mod
	clr.w	$62(a5)				; b mod
	move.w	#38,$60(a5)			; c mod
	move.w	#38,$66(a5)			; d mod
	move.w	d3,$40(a5)			; con 0
	move.w	d7,$58(a5)			; trig

	cmp.b	#WSH,w_effect
	beq.s	.skip3
	subq.l	#4,d2			; prev.mask for next char
.skip3:	lea.l	2(a1),a1		; next char pos : to right

	dbf	d1,putlineloop

	bra.s	endputtextinwindow

w_command:
	lea.l	1(a0),a0		; skip command char
	move.l	a0,windowtextptr
	bra.s	endputtextinwindow
w_restart:
	lea.l	windowtextrestart-12(pc),a0	; restart text
endline:add.l	#12,a0			; next line text
	clr.b	w_mask			; restart masks
	move.b	#80,w_delay		; wait a bit
	cmp.b	#WSH,w_effect
	bne.s	.skip4
	move.b	#40,w_delay
.skip4:	move.l	a0,windowtextptr
	clr.b	w_effect
endputtextinwindow:
	move.l	(a7)+,d0
	rts

*****************************************************************
*								*
*	Allerlei routines...					*
*								*
*****************************************************************

fillcopper:
	move.l	#credits,d0			; this might be slow code
	lea.l	creditsplpt1,a0			; but who cares ! only inits
	move.w	d0,6(a0)			; some datalists etc...
	swap	d0				; only executed at startup!
	move.w	d0,2(a0)

	lea.l	scherm(pc),a0		; init screen col's
	lea.l	plasmafield1+4+65*linesize(pc),a1
	move.w	#$180,d0
	moveq	#15,d1
.loop0:	move.w	d0,(a1)+
	addq.w	#2,d0
	move.w	(a0)+,(a1)
	lea.l	linesize-2(a1),a1
	dbf	d1,.loop0
	
	move.l	a0,d0			; init screen (bplpt's)
	moveq	#3,d1
	lea.l	schermpt1,a0
.loop1:	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	lea.l	8(a0),a0
	swap	d0
	add.l	#200*40,d0
	dbf	d1,.loop1

	move.l	#sprite0,d0		; init sprite 0
	lea.l	spritept1,a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#sprite1,d0		; init sprite 1
	move.w	d0,8+6(a0)
	swap	d0
	move.w	d0,8+2(a0)

	move.l	#emptysprite,d0		; init other sprites
	move.w	d0,16+6(a0)
	move.w	d0,24+6(a0)
	move.w	d0,32+6(a0)
	move.w	d0,40+6(a0)
	move.w	d0,48+6(a0)
	move.w	d0,56+6(a0)
	swap	d0
	move.w	d0,16+2(a0)
	move.w	d0,24+2(a0)
	move.w	d0,32+2(a0)
	move.w	d0,40+2(a0)
	move.w	d0,48+2(a0)
	move.w	d0,56+2(a0)
	
	lea.l	plasmafield1+4+14*linesize(pc),a0
	lea.l	extracopperdata(pc),a1
.loop:	move.l	(a1)+,d0
	tst.l	d0
	beq.s	.exit
	move.l	d0,(a0)
	lea.l	linesize(a0),a0
	bra.s	.loop
.exit:	lea.l	plasmafield1+4+61*linesize(pc),a0
.loop2:	move.l	(a1)+,d0
	tst.l	d0
	beq.s	.exit2
	move.l	d0,(a0)
	lea.l	linesize(a0),a0
	bra.s	.loop2
.exit2:
	move.w	#copsize-1,d0
	lea.l	copperlist1(pc),a0	; copy cop1 into cop2
	lea.l	copperlist2,a1
.sloop:	move.b	(a0)+,(a1)+
	dbf	d0,.sloop
	rts

;-------------------------------------------

filldata:
	lea.l	sinuslist,a1			; copy orig.sinuslist (byte)
	moveq	#5,d1				; 6 times into new sinuslist
.lp1:	lea.l	origsinuslist(pc),a0		; word sized
	move.w	#sinuslistlength-1,d0		; (saves whole lotta space!)
.lp0:	move.b	(a0)+,d2
	move.w	d2,(a1)+
	dbf	d0,.lp0
	dbf	d1,.lp1

	lea.l	sinuslist,a0
	lea.l	sinuslist2,a1
	move.l	#[2*sinuslistlength]-1,d0
.loop1:	move.l	(a0)+,d1			; copy sinuslist into 2nd list
	asr.w	#1,d1				; (for scroll) & tune it
	add.w	#103,d1
	move.w	d1,(a1)+
	dbf	d0,.loop1

	lea.l	sinuslist,a0
	lea.l	sinuslist2,a1
	move.l	#realsinuslistlength-1,d0
.loop2:	move.w	(a0),d1				; tune first sinuslist
	sub.w	#100,d1
	and.b	#$fe,d1				; make even!
	move.w	d1,(a0)+
	dbf	d0,.loop2

	lea.l	plasmapattern,a0
	lea.l	sinuslist+30,a1			; calculate nice looking 
	move.l	#sinuslistlength-1,d0		; colors for plasma
.loop3:	move.w	(a1)+,d1
	muls	#16,d1
	divs	#155,d1
	moveq	#$f,d2
	sub.w	d1,d2
	and.w	#$f,d2
	asl	#8,d2
	move.w	d2,(a0)+
	dbf	d0,.loop3

calcfontdata:
	moveq	#64,d1
	clr.l	d2
	lea.l	letteraddr,a1		; tab with ptrs (to be calc'ed)
cfdl:	lea.l	lettertab(pc),a3	; chars in font as they occur
	move.l	#fontpic-64,d0
newchlp:add.l	d1,d0			; d0 = pos in fontpic (1char = 64bytes)
	move.b	(a3)+,d3
	cmp.l	#endlettertab,a3
	bgt.s	nextch			; not found, skip
	cmp.b	d2,d3
	bne.s	newchlp
endnewch:
	move.l	d2,d3			
	asl.l	#2,d3			; make long (offset in tab)

	move.l	d0,(a1,d3)		; save address in tab
nextch:	addq.b	#1,d2			; next ascii
	cmp.w	#128,d2
	blt.s	cfdl
	rts

*****************************************************************
*								*
*	data							*
*								*
*****************************************************************
windowtext:
	dc.b	NOP," hey you... "
	dc.b	NOP,"            "
	dc.b	NOP,"            "
	dc.b	WSH,"            "
	dc.b	WSH,"            "
	dc.b	WSH,"you got it !"
	dc.b	WSH,"            "
windowtextrestart:
	dc.b	NOP," this intro "
	dc.b	NOP,"was coded by"
	dc.b	WSH,"            "
	dc.b	WSH,"   cool-g   "
	dc.b	WSH,"   cool-g   "
	dc.b	WSH,"            "
	dc.b	WSH,"    i am    "
	dc.b	WSH," your newest"
	dc.b	WSH,"  member !  "
	dc.b	WSH," i hope you "
	dc.b	WSH,"  will like "
	dc.b	WSH,"  my intros "
	dc.b	WSH,"            "
	dc.b	WSH,"  read the  "
	dc.b	WSH,"sinusscroll!"
	dc.b	NOP,"            "
	dc.b	NOP,"write me at:"
	dc.b	NOP,"eikenlaan 21"
	dc.b	NOP,"b3740 bilzen"
	dc.b	WSH,"            "
	dc.b	WSH,"            "
	dc.b	WSH," press  rmb "
	dc.b	WSH,"for slow-mo!"
	dc.b	WSH,"            "
	dc.b	RESTART
	even
		dc.l	mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9
masklist:	dc.l	mask8,mask7,mask6,mask5,mask4,mask3,mask2,mask1
		dc.l	mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1

		dc.l	mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1
masklist2:	dc.l	mask1,mask2,mask3,mask4,mask5,mask6,mask7,mask8
		dc.l	mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9

w_delay:		dc.b	8	; boring delayer
w_mask:			dc.b	0	; current mask windowtext
w_speed:		dc.b	2	; speed windowtext
w_effect:		dc.b	0	; current effect windowt

NOP = 0
WSH = 1
RESTART = $ff

windowpos:		dc.l	scherm+400	; pos in textwindow
windowtextptr:		dc.l	windowtext	; windowtext

mask1:	blk.w	16,%0000000000000000	; shapes of masks for 
mask2:	dc.w	   %1111111111111111	; textpanel
	blk.w	14,%1000000000000001
	dc.w	   %1111111111111111
mask3:	blk.w	2, %1111111111111111
	blk.w	12,%1100000000000011
	blk.w	2, %1111111111111111
mask4:	blk.w	3, %1111111111111111
	blk.w	10,%1110000000000111
	blk.w	3, %1111111111111111
mask5:	blk.w	4, %1111111111111111
	blk.w	8, %1111000000001111
	blk.w	4, %1111111111111111
mask6:	blk.w	5, %1111111111111111
	blk.w	6, %1111100000011111
	blk.w	5, %1111111111111111
mask7:	blk.w	6, %1111111111111111
	blk.w	4, %1111110000111111
	blk.w	6, %1111111111111111
mask8:	blk.w	7, %1111111111111111
	blk.w	2, %1111111001111111
	blk.w	7, %1111111111111111
mask9:	blk.w	16,%1111111111111111

credits:
 dc.w	%0000000000000000,%0011100111001110,%1100000000111000,%0000000000000000
 dc.w	%0000000001111110,%0110001101011010,%1100000001100001,%1111100000000000
 dc.w	%0000000000011110,%0110001101011010,%1100011101101001,%1110000000000000
 dc.w	%0000000000000000,%0111101111011110,%1111000001111000,%0000000000000000

;-------------------------------------------	
origsinuslist:         ; generated with sinusgen by Cool-G   100 - 255
	dc.b         100,100,100,100,100,100,100,100
	dc.b 100,100,100,100,100,100,100,100,101,101
	dc.b 101,101,101,101,101,102,102,102,102,102
	dc.b 103,103,103,103,104,104,104,104,105,105
	dc.b 105,106,106,106,106,107,107,107,108,108
	dc.b 109,109,109,110,110,110,111,111,112,112
	dc.b 113,113,113,114,114,115,115,116,116,117
	dc.b 117,118,118,119,119,120,120,121,121,122
	dc.b 122,123,123,124,125,125,126,126,127,127
	dc.b 128,129,129,130,131,131,132,132,133,134
	dc.b 134,135,136,136,137,138,138,139,140,140
	dc.b 141,142,142,143,144,144,145,146,147,147
	dc.b 148,149,149,150,151,152,152,153,154,155
	dc.b 155,156,157,158,158,159,160,161,161,162
	dc.b 163,164,164,165,166,167,167,168,169,170
	dc.b 171,171,172,173,174,174,175,176,177
	dc.b 177,178,179,179,180,181,182,182,183,184
	dc.b 185,186,186,187,188,189,189,190,191,192
	dc.b 192,193,194,195,195,196,197,198,198,199
	dc.b 200,201,201,202,203,204,204,205,206,206
	dc.b 207,208,209,209,210,211,211,212,213,213
	dc.b 214,215,216,216,217,218,218,219,219,220
	dc.b 221,221,222,223,223,224,225,225,226,226
	dc.b 227,228,228,229,229,230,230,231,232,232
	dc.b 233,233,234,234,235,235,236,236,237,237
	dc.b 238,238,239,239,240,240,240,241,241,242
	dc.b 242,243,243,243,244,244,245,245,245,246
	dc.b 246,246,247,247,247,248,248,248,249,249
	dc.b 249,250,250,250,250,251,251,251,251,251
	dc.b 252,252,252,252,252,253,253,253,253,253
	dc.b 253,254,254,254,254,254,254,254,254,254
	dc.b 254,254,254,254,254,254,254,254,254,254
	dc.b 254,254,254,254,254,254,254,254,254,254
	dc.b 254,254,254,254,253,253,253,253,253,253
	dc.b 252,252,252,252,252,251,251,251,251,251
	dc.b 250,250,250,250,249,249,249,248,248,248
	dc.b 247,247,247,246,246,246,245,245,245,244
	dc.b 244,244,243,243,242,242,241,241,241,240
	dc.b 240,239,239,238,238,237,237,236,236,235
	dc.b 235,234,234,233,233,232,232,231,230,230
	dc.b 229,229,228,228,227,226,226,225,225,224
	dc.b 223,223,222,221,221,220,220,219,218,218
	dc.b 217,216,216,215,214,214,213,212,212,211
	dc.b 210,209,209,208,207,207,206,205,204,204
	dc.b 203,202,201,201,200,199,199,198,197,196
	dc.b 196,195,194,193,193,192,191,190,189,189
	dc.b 188,187,186,186,185,184,183,183,182,181
	dc.b 180,179,179,178,177,176,176,175,174,173
	dc.b 172,172,171,170,169,169,168,167,166,166
	dc.b 165,164,163,162,162,161,160,159,159,158
	dc.b 157,156,156,155,154,153,153,152,151,151
	dc.b 150,149,148,148,147,146,146,145,144,143
	dc.b 143,142,141,141,140,139,139,138,137,137
	dc.b 136,135,135,134,133,133,132,131,131,130
	dc.b 130,129,128,128,127,127,126,125,125,124
	dc.b 124,123,123,122,121,121,120,120,119,119
	dc.b 118,118,117,117,116,116,115,115,114,114
	dc.b 114,113,113,112,112,111,111,111,110,110
	dc.b 109,109,109,108,108,108,107,107,107,106
	dc.b 106,106,105,105,105,105,104,104,104,103
	dc.b 103,103,103,103,102,102,102,102,102,101
	dc.b 101,101,101,101,101,101,100,100,100,100
	dc.b 100,100,100,100,100,100,100,100,100,100,100,100
endorigsinuslist:
	even
sinuslistlength=	endorigsinuslist-origsinuslist
;-----------------------------------------
spritetopline = $30+71+50
spriteYsize = 255-70-50
bltsize = spriteYsize<<6+2

Y SET spritetopline
sprite0:			REPT spriteYsize/2
YY set Y-[Y>>8<<8]
				dc.b	YY
				dc.b	99
YY set [Y+1]-[[Y+1]>>8<<8]
				dc.b	YY
				dc.b	Y>>8<<2+[Y+1]>>8<<1+1
				dc.w	0,0
Y SET Y+2
				ENDR
emptysprite:			dc.l	0,0

Y SET spritetopline+1
sprite1:			REPT spriteYsize/2
YY set Y-[Y>>8<<8]
				dc.b	YY
				dc.b	99
YY set [Y+1]-[[Y+1]>>8<<8]
				dc.b	YY
				dc.b	Y>>8<<2+[Y+1]>>8<<1+1
				dc.w	0,0
Y SET Y+2
				ENDR
emptysprite1:			dc.l	0,0
	
;-----------------------------------------
extracopperdata:	dc.l	$00968100,$01820aac,$0184088a,$01860668
			dc.l	$01020088,0,$01020000,0
			
copperlist1:		dc.l	$00960120
			dc.l	$01800000
			dc.l	$008e2931,$009036d1
			dc.l	$00920038,$009400d0
schermpt1:		dc.l	$00e00000,$00e20000
			dc.l	$00e40000,$00e60000
			dc.l	$00e80000,$00ea0000
			dc.l	$00ec0000,$00ee0000
			dc.l	$01004000,$01020000

spritept1:		dc.l	$01200000,$01220000
			dc.l	$01240000,$01260000
			dc.l	$01280000,$012a0000
			dc.l	$012c0000,$012e0000
			dc.l	$01300000,$01320000
			dc.l	$01340000,$01360000
			dc.l	$01380000,$013a0000
			dc.l	$013c0000,$013e0000

			dc.l	$100ffffe
			dc.l	$00968020

			dc.l	$01a20aac,$01a4088a,$01a60668
plasmafield1:

top = $20
Xsize =	8
Ysize = $c8
leftborder = $4f
linesize = 8+Xsize*4+4
fieldsize = linesize*Ysize

Y SET top
			REPT Ysize
X SET leftborder
			dc.b	y,x,$ff,$fe
			dc.l	$01800000	; 1 commd extra on each row
			blk.l	Xsize,$01800000
			dc.w	$0180,$0000
Y SET Y+1
			ENDR

endplasmafield1:
col1 set $aac
col2 set $88a
col3 set $668
y set $ff-14
			rept	6
y set y+1
col1 SET col1-$111
col2 SET col2-$111
col3 SET col3-$111
			dc.b	y,$0f,$ff,$fe
			dc.w	$01a2,col1,$01a4,col2,$01a6,col3
			endr
y set y+1
col1 SET col1-$111
			dc.b	y,$0f,$ff,$fe
			dc.w	$01a2,col1,$01a4,0000,$01a6,0000
			rept	3
y set y+1
col1 SET col1-$111
			dc.b	y,$0f,$ff,$fe
			dc.w	$01a2,col1
			endr
			dc.b	y+1,$0f,$ff,$fe
			dc.l	$01a20000
						
			dc.l	$00960120
creditsplpt1:		dc.l	$00e00000,$00e20000
			dc.l	$01800000
creditcol1:		dc.l	$01820000
			dc.l	$01001000,$00968100
			dc.l	$009200b8,$009400d0

lowerzone1:		dc.l	$ffdffffe,$00960120,$010ffffe
			dc.l	$00960120
			dc.l	$36dffffe,$00968100
			dc.l	$fffffffe		;end of copperlist1
endcop1:
copsize = endcop1-copperlist1
;-----------------------------------------
greycolortab:
col set 0
		rept $f
		dc.w	col
col set col+$111
		endr
		dc.w	$fff
		rept $e
		dc.w	col
col set col-$111
		endr
		dc.w	0
endgreycolortab:
		
fontpic:	incbin "df1:gfx/font.goonies"
		dc.l	0
		
lettertab:	dc.b	" !",34,"#$%^&()*+,-./0123456789:;<=>?@"
		dc.b	"abcdefghijklmnopqrstuvwxyz"
		dc.b	0
endlettertab:	even

scrolltextptr:	dc.l	scrolltext

; effects:	1:   wait
;		2:   toggle double height
;		3,x: set sinusspeed to x
;		4:   start plasmaroutine
;		$ff: restart scroll

scrolltext:
		dc.b	3,2,"                   you want some ",2,"plasma",2
		dc.b	" ??",3,6,"                    ",4,"     "
textrestart:
		dc.b	"        hi",3,2," there fans !!",3,6,"   my name is"
		dc.b	" cool-g, sometimes called geert coelmont..."
		dc.b	3,8," and i seem to be member of silents now !",3,2
		dc.b	"  i was former coder of ",2,"zylon",2," but i left"
		dc.b	" them because there was no a",3,10,"ction !!",3,6
		dc.b	"  then lyzanxia ",3,4,"contacted me ",3,2,"to ask"
		dc.b	" if i wanted to join ",2,"silents",2," and so here"
		dc.b	" i am... i hope we can have lotsa fun together ! ",3,8
		dc.b	" most things i have coded are crack-intros or"
		dc.b	" import intros,",3,0," you will"
		dc.b	" find ",3,2,"them somewhere ",3,8,"on the disk... "
		dc.b	" feel free to contact me for",3,6," source-exchanging"
		dc.b	" or anyhting else",3,2," !!        bye for now !"
		dc.b	" oh by the way, ",3,4,"i ripped the",3,6," logo "
		dc.b	"from another intro,",3,0," hope you don't mind !"
		dc.b	3,8,"         greetings from cool-g !                "
		dc.b	$ff
		even
	
scherm:		incbin	"df1:gfx/logo.320x200x4"
		blk.b	40*40,0

scrolltemp:	blk.w	16*2,0
endscrolltemp:

	SECTION SCREENS,BSS

sinuslist:		ds.w	sinuslistlength
endsinuslist:		ds.w	5*sinuslistlength
realendsinuslist:
realsinuslistlength= 6*sinuslistlength
sinuslist2:		ds.w	2*sinuslistlength	; scroll-sinuslist
endsinuslist2=		sinuslist2+[sinuslistlength*2]
plasmapattern:		ds.w	sinuslistlength	; here comes the colorpattern
endplasmapattern:
letteraddr:		ds.l	128		; the addresses of the font
copperlist2:		ds.b	copsize		; 2nd coplist (doubbuf)
plasmafield2=	plasmafield1-copperlist1+copperlist2
creditcol2=	creditcol1-copperlist1+copperlist2

	section module,code
	
mt_data:	incbin	"df1:modules/mod.3"


;нннннннннннннннннннннннннннннннннннннн
;н   NoisetrackerV1.0 replayroutine   н
;н Mahoney & Kaktus - HALLONSOFT 1989 н
;нннннннннннннннннннннннннннннннннннннн

mt_init:lea	mt_data,a0
	move.l	a0,a1
	add.l	#$3b8,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop:move.l	d1,d2
	subq.w	#1,d0
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$43c,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#$2,$bfe001
	move.b	#$6,mt_speed
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts

mt_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

mt_music:
	movem.l	d0-d4/a0-a3/a5-a6,-(a7)
	lea	mt_data,a0
	addq.b	#$1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.s	mt_nonew
	clr.b	mt_counter
	bra	mt_getnew

mt_nonew:
	lea	mt_voice1(pc),a6
	lea	$dff0a0,a5
	bsr	mt_checkcom
	lea	mt_voice2(pc),a6
	lea	$dff0b0,a5
	bsr	mt_checkcom
	lea	mt_voice3(pc),a6
	lea	$dff0c0,a5
	bsr	mt_checkcom
	lea	mt_voice4(pc),a6
	lea	$dff0d0,a5
	bsr	mt_checkcom
	bra	mt_endr

mt_arpeggio:
	moveq	#0,d0
	move.b	mt_counter,d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.s	mt_arp2
	cmp.w	#$2,d0
	beq.s	mt_arp1

	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1:moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.s	mt_arp3
mt_arp2:move.w	$10(a6),d2
	bra.s	mt_arp4
mt_arp3:asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	mt_periods(pc),a0
	moveq	#$24,d7
mt_arploop:
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts
mt_arp4:move.w	d2,$6(a5)
	rts

mt_getnew:
	lea	mt_data,a0
	move.l	a0,a3
	move.l	a0,a2
	add.l	#$c,a3
	add.l	#$3b8,a2
	add.l	#$43c,a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	$4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$4(a3,d4.l),d0
	add.w	$6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
	bra.s	mt_setregs
mt_noloop:
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
mt_setregs:
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	mt_checkcom2
	move.b	$2(a6),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.s	mt_setperiod
	bsr	mt_setmyport
	bra	mt_checkcom2
mt_setperiod:
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	move.w	$14(a6),d0
	move.w	d0,$dff096
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	move.w	$14(a6),d0
	or.w	d0,mt_dmacon
	bra	mt_checkcom2

mt_setdma:
	move.w	#$12c,d0
mt_wait:dbf	d0,mt_wait
	move.w	mt_dmacon,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.w	#$12c,d0
mt_wai2:dbf	d0,mt_wai2
	lea	$dff000,a5
	lea	mt_voice4(pc),a6
	move.l	$a(a6),$d0(a5)
	move.w	$e(a6),$d4(a5)
	lea	mt_voice3(pc),a6
	move.l	$a(a6),$c0(a5)
	move.w	$e(a6),$c4(a5)
	lea	mt_voice2(pc),a6
	move.l	$a(a6),$b0(a5)
	move.w	$e(a6),$b4(a5)
	lea	mt_voice1(pc),a6
	move.l	$a(a6),$a0(a5)
	move.w	$e(a6),$a4(a5)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_endr
mt_nex:	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	cmp.b	mt_data+$3b6,d1
	bne.s	mt_endr
	move.b	mt_data+$3b7,mt_songpos
mt_endr:tst.b	mt_break
	bne.s	mt_nex

	movem.l	(a7)+,d0-d4/a0-a3/a5-a6
	rts

mt_setmyport:
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rt
	move.b	#$1,$16(a6)
	rts
mt_clrport:
	clr.w	$18(a6)
mt_rt:	rts

mt_myport:
	move.b	$3(a6),d0
	beq.s	mt_myslide
	move.b	d0,$17(a6)
	clr.b	$3(a6)
mt_myslide:
	tst.w	$18(a6)
	beq.s	mt_rt
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	mt_mysub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
mt_myok:move.w	$10(a6),$6(a5)
	rts
mt_mysub:
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$6(a5)
	rts

mt_vib:	move.b	$3(a6),d0
	beq.s	mt_vi
	move.b	d0,$1a(a6)

mt_vi:	move.b	$1b(a6),d0
	lea	mt_sin(pc),a4
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.s	mt_vibmin
	add.w	d2,d0
	bra.s	mt_vib2
mt_vibmin:
	sub.w	d2,d0
mt_vib2:move.w	d0,$6(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

mt_nop:	move.w	$10(a6),$6(a5)
	rts

mt_checkcom:
	move.w	$2(a6),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	$2(a6),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpeggio
	cmp.b	#$1,d0
	beq.s	mt_portup
	cmp.b	#$2,d0
	beq	mt_portdown
	cmp.b	#$3,d0
	beq	mt_myport
	cmp.b	#$4,d0
	beq	mt_vib
	move.w	$10(a6),$6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_volslide:
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldown
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.s	mt_vol2
	move.w	#$40,$12(a6)
mt_vol2:move.w	$12(a6),$8(a5)
	rts

mt_voldown:
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.s	mt_vol3
	clr.w	$12(a6)
mt_vol3:move.w	$12(a6),$8(a5)
	rts

mt_portup:
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.s	mt_por2
	and.w	#$f000,$10(a6)
	or.w	#$71,$10(a6)
mt_por2:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_portdown:
	clr.w	d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$358,d0
	bmi.s	mt_por3
	and.w	#$f000,$10(a6)
	or.w	#$358,$10(a6)
mt_por3:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_checkcom2:
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_setfilt
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_posjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_setfilt:
	move.b	$3(a6),d0
	and.b	#$1,d0
	asl.b	#$1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts
mt_pattbreak:
	not.b	mt_break
	rts
mt_posjmp:
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts
mt_setvol:
	cmp.b	#$40,$3(a6)
	ble.s	mt_vol4
	move.b	#$40,$3(a6)
mt_vol4:move.b	$3(a6),$8(a5)
	rts
mt_setspeed:
	cmp.b	#$1f,$3(a6)
	ble.s	mt_sets
	move.b	#$1f,$3(a6)
mt_sets:move.b	$3(a6),d0
	beq.s	mt_rts2
	move.b	d0,mt_speed
	clr.b	mt_counter
mt_rts2:rts

mt_sin:
	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
	dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
	dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
	dc.w $007f,$0078,$0071,$0000,$0000

mt_speed:	dc.b	$6
mt_songpos:	dc.b	$0
mt_pattpos:	dc.w	$0
mt_counter:	dc.b	$0

mt_break:	dc.b	$0
mt_dmacon:	dc.w	$0
mt_samplestarts:blk.l	$1f,0
mt_voice1:	blk.w	10,0
		dc.w	$1
		blk.w	3,0
mt_voice2:	blk.w	10,0
		dc.w	$2
		blk.w	3,0
mt_voice3:	blk.w	10,0
		dc.w	$4
		blk.w	3,0
mt_voice4:	blk.w	10,0
		dc.w	$8
		blk.w	3,0
