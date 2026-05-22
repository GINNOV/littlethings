
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

	bsr	fillcopper
	bsr	filldata
	
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
	rte

libname:
	dc.b	"graphics.library",0
	even

oldcop:	dc.l	0
oldint:	dc.l	0

;---------------------------------

int:	lea.l	$dff000,a5
	btst	#10,$16(a5)			; check on RMB
	beq.w	exitint

	bsr	moveplasma
	bsr	showcredits

	lea.l	$dff000,a5
.wait:	cmp.b	#$ff,$6(a5)
	bne.s	.wait

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
copperdata1:	dc.l	copperlist1,plasmafield2+4,$dff080,$dff088
copperdata2:	dc.l	copperlist2,plasmafield1+4,$dff084,$dff08a

lamedata:	dc.l	$01800000,plasmapattern,plasmapointers,sinuslist
		dc.w	2*sinuslistlength
plasmapointers:
globalDY:	dc.w	0
indivDY:	dc.w	0
globalDX:	dc.w	100
indivDX:	dc.w	0
		
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
	move.b	#1,creditstrigger
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

	moveq	#8,d2

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
	dc.l	endsinuslist2,sinuslist2,sinuslist2

movescrollsinus:
	lea.l	sinusscrolldata(pc),a0
	movem.l	(a0)+,d0/d1/d2
	moveq	#10,d3				; global step sinustab
	add.l	d3,d2
	cmp.l	d0,d2
	blt.s	.ok1
	move.l	d1,d2
.ok1:	move.l	d2,-(a0)

	lea.l	sprite0+1(pc),a1
	lea.l	sprite1+1(pc),a2
	move.l	d2,a0
	moveq	#[spriteYsize/2]-1,d0
	moveq	#$fffffffe,d4
	moveq	#8,d5
	moveq	#1,d6
		
.loop:	move.l	(a0)+,d1

	move.b	d1,d2
	and.b	d6,d2
	and.b	d4,2(a2)
	or.b	d2,2(a2)
	asr	#1,d1
	move.b	d1,(a2)			; sprite 1 new hpos

	swap	d1

	move.b	d1,d2
	and.b	d6,d2
	and.b	d4,2(a1)
	or.b	d2,2(a1)
	asr	#1,d1
	move.b	d1,(a1)			; sprite 0 new hpos

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
	bra	endscroll
scrollraster:
	lea.l	$dff000,a5
	lea.l	scrollentryptr(pc),a0
	movem.l	(a0)+,d0/a1/a2/a3
	tst.b	(a0)
	bne.s	double_on			; copy from scrollbuffer:
	move.w	(a1)+,(a3)			; copy+ 1 row in sprite 0
	bra.s	cont				
double_on:
	move.w	(a1),(a3)			; copy 1 row in sprite 0
cont:	move.w	(a1)+,(a2)			; copy 1 row in sprite 1

	cmp.l	d0,a1				; whole char copied ?
	blt.s	.ok
	bsr	getnewchar
	lea.l	scrolltemp,a1
.ok:	move.l	a1,scrollentryptr+4		; save new pos of char

	moveq	#$6,d0
	moveq	#$ffffffff,d1
	move.w	#bltsize,d2
	lea.l	sprite0+12(pc),a0
	lea.l	sprite0+4(pc),a1
	
.wait:	btst	#14,$dff002
	bne.s	.wait

	move.l	a0,$50(a5)				; apt
	move.l	a1,$54(a5)				; dpt
	move.w	d0,$64(a5)				; amod
	move.w	d0,$66(a5)				; dmod
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
	tst.b	(a2)
	bne.s	rest
	lea.l	textrestart(pc),a2	; 0 restart scroll
rest:	move.l	a2,(a1)

	cmp.b	#"|",d2
	bne.s	eff2
	move.b	#$80,delay		; "|" scroll delay
	bra.s	newchseek
eff2:	cmp.b	#"\",d2
	bne.s	eff3
	not.b	doubleheight		; "\" toggle double height
	bra.s	newchseek
eff3:	; more effects

	lea.l	letteraddr,a2
	asl.l	#2,d2
	add.l	d2,a2			; a2 points to the char-addresstab!
	moveq	#$ffffffff,d0		; get some data ready before waiting!
	lea.l	scrolltemp,a1
	move.w	#188,d1
		
.wait0:	btst	#14,$2(a5)
	bne.s	.wait0

putch:	move.l	(a2),$50(a5)		; copy the char in the scrollbuffer
	move.l	a1,$54(a5)
	move.l	d0,$44(a5)
	clr.w	$42(a5)
	move.w	d1,$64(a5)
	clr.w	$66(a5)
	move.w	#%0000100111110000,$40(a5)
	move.w	#%0000010000000001,$58(a5)
	rts

;--------------------------------------
creditsdata:	dc.l	greycolortab
creditstrigger:	dc.b	0
		even
showcredits:
	lea.l	creditsdata(pc),a0
	moveq	#0,d0
	move.b	4(a0),d0		; check trigger
	beq.s	exitcredits
	lea.l	creditcol1(pc),a2
	lea.l	creditcol2(pc),a3
	cmp.b	#1,d0
	bne.s	nextcolor
initcredits:
	lea.l	greycolortab(pc),a1
	move.l	a1,(a0)
nextcolor:
	move.b	#2,4(a0)
	move.l	(a0),a1
	move.w	(a1),2(a2)		; put color in coppl1
	move.w	(a1)+,2(a3)		; put color in coppl2
	cmp.l	#endgreycolortab,a1
	blt.s	.ok
	clr.b	4(a0)
.ok:	move.l	a1,(a0)
exitcredits:
	rts
		
*****************************************************************
*								*
*	Allerlei routines...					*
*								*
*****************************************************************

fillcopper:
	move.l	#credits,d0			; this might be slow code
	lea.l	creditsplpt1,a0			; but who cares !
	lea.l	creditsplpt2,a1			; it's only to initialise
	move.w	d0,6(a0)			; some datalists etc...
	move.w	d0,6(a1)			; only executed at startup!
	swap	d0
	move.w	d0,2(a0)
	move.w	d0,2(a1)

	lea.l	scherm(pc),a0		; init screen col's
	lea.l	schermcolpt1(pc),a1
	lea.l	schermcolpt2(pc),a2
	move.w	#$180,d0
	moveq	#15,d1
.loop0:	move.w	d0,(a1)+
	move.w	d0,(a2)+
	addq.w	#2,d0
	move.w	(a0),(a1)+
	move.w	(a0)+,(a2)+
	dbf	d1,.loop0
	
	move.l	a0,d0			; init screen (bplpt's)
	moveq	#3,d1
	lea.l	schermpt1,a0
	lea.l	schermpt2,a1
.loop1:	move.w	d0,6(a0)
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a0)
	move.w	d0,2(a1)
	lea.l	8(a0),a0
	lea.l	8(a1),a1
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
	swap	d0
	move.w	d0,16+2(a0)
	move.w	d0,24+2(a0)

	moveq.l	#15,d0
	lea.l	spritept1,a0		; copy sprites into other copperlist
	lea.l	spritept2,a1
.sloop:	move.l	(a0)+,(a1)+
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
	move.l	#realsinuslistlength-1,d0
.loop:	move.w	(a0),d1				; copy sinuslist into 2nd list
	asr.w	#1,d1				; (for scroll) & tune it
	add.w	#103,d1
	move.w	d1,(a1)+
	move.w	(a0),d1				; tune first list
	sub.w	#100,d1
	and.b	#$fe,d1				; make even!
	move.w	d1,(a0)+
	dbf	d0,.loop

	lea.l	plasmapattern,a0
	lea.l	sinuslist+30,a1			; calculate nice looking 
	move.l	#sinuslistlength-1,d0		; colors for plasma
.loop3:	move.w	(a1)+,d1
	muls	#16,d1
	divs	#155,d1
	moveq	#$f,d2
	sub.w	d1,d2
	and.w	#$f,d2
	move.w	d2,(a0)+
	dbf	d0,.loop3

calcfontdata:
	clr.l	d2
	lea.l	letteraddr,a1		; tab with ptrs (to be calc'ed)
cfdl:	lea.l	lettertab(pc),a3	; chars in font as they occur
	move.l	#fontpic-2,d0
newchlp:addq.l	#2,d0			; d0 = pos in fontpic (1char = 2bytes)
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

credits:	dc.l	%00111001110011101100000000111000
		dc.l	%01100011010110101100000001100000
		dc.l	%01100011010110101100011101101000
		dc.l	%01111011110111101111000001111000

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
bltsize = spriteYsize<<6+1

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
copperlist1:		dc.l	$00960120
			dc.l	$01800000,$01820fff
			dc.l	$008e2931,$009036d1
			dc.l	$00920038,$009400d0
schermpt1:		dc.l	$00e00000,$00e20000
			dc.l	$00e40000,$00e60000
			dc.l	$00e80000,$00ea0000
			dc.l	$00ec0000,$00ee0000
			dc.l	$01004000,$01020000

schermcolpt1:		blk.l	16,0

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

			dc.l	$2f0ffffe
			dc.l	$00968100

Y set $30
Col set $2
			REPT $0a
			dc.b	y,$0f,$ff,$fe
			dc.w	$01a2,col
Col set Col+$111
Y set Y+1
			ENDR

plasmafield1:

top = $40
Xsize =	8
Ysize = $b3
leftborder = $53
linesize = 4+Xsize*4+4
fieldsize = linesize*Ysize

Y SET 0
			REPT Ysize
T SET Y
X SET leftborder
			dc.b	y+top,x,$ff,$fe
			blk.l	Xsize,$01800000
			dc.w	$0180,$0000
Y SET Y+1
			ENDR

endplasmafield1:
			REPT $0a
Col set Col-$111
			dc.b	y+top,$0f,$ff,$fe
			dc.w	$01a2,col
Y set Y+1
			ENDR
			dc.b	y+top,$0f,$ff,$fe
			dc.l	$00960120
creditsplpt1:		dc.l	$00e00000,$00e20000
			dc.l	$01800000
creditcol1:		dc.l	$01820000
			dc.l	$01001000,$00968100
			dc.l	$009200c0,$009400c8

lowerzone1:		dc.l	$ffdffffe,$010ffffe
			dc.l	$00960120
			dc.l	$36dffffe,$00968100
			dc.l	$fffffffe		;end of copperlist1

;-----------------------------------------
copperlist2:		dc.l	$00960120
			dc.l	$01800000,$01820fff
			dc.l	$008e2931,$009036d1
			dc.l	$00920038,$009400d0
schermpt2:		dc.l	$00e00000,$00e20000
			dc.l	$00e40000,$00e60000
			dc.l	$00e80000,$00ea0000
			dc.l	$00ec0000,$00ee0000
			dc.l	$01004000,$01020000

schermcolpt2:		blk.l	16,0

spritept2:		dc.l	$01200000,$01220000
			dc.l	$01240000,$01260000
			dc.l	$01280000,$012a0000
			dc.l	$012c0000,$012e0000
			dc.l	$01300000,$01320000
			dc.l	$01340000,$01360000
			dc.l	$01380000,$013a0000
			dc.l	$013c0000,$013e0000

			dc.l	$100ffffe
			dc.l	$00968020

			dc.l	$2f0ffffe
			dc.l	$00968100

Y set $30
Col set $2
			REPT $0a
			dc.b	y,$0f,$ff,$fe
			dc.w	$01a2,col
Col set Col+$111
Y set Y+1
			ENDR

plasmafield2:

Y SET 0
			REPT Ysize
T SET Y
X SET leftborder
			dc.b	y+top,x,$ff,$fe
			blk.l	Xsize,$01800000
			dc.w	$0180,$0000
Y SET Y+1
			ENDR

endplasmafield2:
			REPT $0a
Col set Col-$111
			dc.b	y+top,$0f,$ff,$fe
			dc.w	$01a2,col
Y set Y+1
			ENDR
			dc.b	y+top,$0f,$ff,$fe
			dc.l	$00960120
creditsplpt2:		dc.l	$00e00000,$00e20000
			dc.l	$01800000
creditcol2:		dc.l	$01820000
			dc.l	$01001000,$00968100
			dc.l	$009200c0,$009400c8

lowerzone2:		dc.l	$ffdffffe,$010ffffe
			dc.l	$00960120
			dc.l	$36dffffe,$00968100
			dc.l	$fffffffe		;end of copperlist1

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
		
fdepth=			1
fheight=		16
fwidthW=		1
ftotwidthW=		1520/16
ftotheight=		16
fwidthB=		fwidthW*2
ftotwidthB=		ftotwidthW*2
fontpicsize=		ftotwidthB*ftotheight*fdepth

fontpic:	incbin "rmd:font.paradox",fontpicsize		; the font

lettertab:
	dc.b	" !",34,"#$%&'()*+,-./0123456789:;<=>? abcdefghijklmnopqrstuvwxyz"
	dc.b	"[\]^_`ABCDEFGHIJKLMNOPQRSTUVW   XYZ"
	dc.b	0
endlettertab:
	even

scrolltextptr:	dc.l	scrolltext
scrolltext:
textrestart:
	dc.b	"\cool.g\ is proud to present his first plasma routine..."
	dc.b	" i hope ya all like it !!       ",0
	even
	
scherm:		incbin	"rmd:logo.320x200x4"	; the logo-screen
		blk.b	40*40,0

scrolltemp:		blk.w	16,0		; place for scrolled char
endscrolltemp:

	SECTION SCREENS,BSS_c

sinuslist:		ds.w	sinuslistlength
endsinuslist:		ds.w	5*sinuslistlength
realendsinuslist:
realsinuslistlength= 6*sinuslistlength
sinuslist2:		ds.w	2*sinuslistlength	; scroll-sinuslist
endsinuslist2=		sinuslist2+[sinuslistlength*2]
plasmapattern:		ds.w	sinuslistlength	; here comes the colorpattern
endplasmapattern:
letteraddr:		ds.l	128		; the addresses of the font
