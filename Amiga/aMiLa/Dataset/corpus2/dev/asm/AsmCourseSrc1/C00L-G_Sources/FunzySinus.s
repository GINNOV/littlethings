
main:	movem.l	a0-a6/d0-d7,-(a7)
	move.l	$4,a6
	jsr	-132(a6)

	lea	libname,a1
	jsr	-408(a6)		
	move.l	d0,a5

	move.w	#$4e75,$7fffe
	bsr	tunesinuslist
	bsr	calcfontdata
	bsr	fillcopper

	move.l	#copperlist,$dff080	;cop1lcH/cop1lcL

	move.w	$dff002,d0
	or.w	#$8000,d0
	move.w	#$7fff,$dff096
	move.w	#%1000011111000000,$dff096

	move.w	$dff01c,d1
	or.w	#$8000,d1
	move.w	#$7fff,$dff09a
	move.w	#%1100000000100000,$dff09a

	move.l	$6c,oldint+2
	move.l	#int,$6c

	movem.l a0-a6/d0-d7,-(a7)	
	bsr	mainloop
	movem.l (a7)+,a0-a6/d0-d7
	
	move.l	oldint+2,$6c

	move.w	#$7fff,$dff096
	move.w	d0,$dff096

	move.w	#$7fff,$dff09a
	move.w	d1,$dff09a

	move.l	$26(a5),$dff080		
	move.l	a5,a1

	jsr	-414(a6)		
	jsr	-138(a6)
	jsr	-126(a6)

	move.w	#$8100,$dff096
	move.w	#$8100,$dff096

	movem.l	(a7)+,a0-a6/d0-d7
	rts				

;------------------
button:	dc.b	0
	even

mainloop:
	bsr	waitvblank

	btst	#6,$bfe001
	beq.s	endprog
	bra.s	mainloop
endprog:
	rts

;--------------------------------------------------------------
int:	movem.l a0-a6/d0-d7,-(a7)

	eor.l	#s_width*256,scrollplaneptr	; swap pages
	bsr	fillscrollplane

	bsr	mscroll

	btst	#10,$dff016
	bne.s	exit
	move.w	#$f00,$dff180
	move.w	#$000,$dff180

exit:	movem.l	(a7)+,a0-a6/d0-d7
oldint:	jmp	$0
;--------------------------------------------------------------


*****************************************************************
*								*
*	sinusscroll © Cool-G					*
*								*
*****************************************************************

mscroll:
	movem.l a0-a6/d0-d7,-(a7)
	lea.l	$dff000,a5
	tst.b	delay
	beq.s	mscrollraster
	subq.b	#1,delay
	bra	mendscroll
mscrollraster:
	move.l	#scrolltemp+440,$50(a5)		; a
	move.l	#scrolltemp+440-2,$54(a5)	; d
	move.w	#$00ff,$44(a5)			; msk1
	move.w	#$ffff,$46(a5)			; mskL
	clr.w	$42(a5)				; con1
	clr.w	$64(a5)				; mod a
	clr.w	$66(a5)				; mod d
	move.w	#%1110100111110000,$40(a5)	; con0
	move.w	#%0000010001010110,$58(a5)	; trigger

	subq.b	#2,mcharpos
	bne	mendscroll
	move.b	morigcharpos(pc),mcharpos

	move.l	#mendlettertab,d1
	move.l	mscrollptr(pc),a2
	moveq.b	#0,d2
mnewchseek:
	move.b	(a2)+,d2		; end of scroll reached
	tst.b	(a2)
	bne.s	msrest
	move.l	mscrollrestart(pc),a2
msrest:	move.l	a2,mscrollptr		; save new pos. scrollptr
	cmp.b	#"|",d2
	bne.s	eff2
	move.b	#$80,delay
	bra.s	mnewchseek
eff2:	asl.l	#2,d2
	lea.l	mletteraddr,a2
	moveq.l	#-1,d0				; mask=$ffff
mputch:	move.l	(a2,d2),$50(a5)			; a
	move.l	#scrolltemp+440+42,$54(a5)	; d
	move.w	d0,$44(a5)			; msk1
	move.w	d0,$46(a5)			; mskL
	clr.w	$42(a5)				; con1
	move.w	#188,$64(a5)			; mod a
	move.w	#42,$66(a5)			; mod d
	move.w	#%0000100111110000,$40(a5)	; con0
	move.w	#%0000010000000001,$58(a5)	; trigger
mendscroll:


	move.l	#[s_width/2]-1,d0	; # words to sinus

	lea.l	sourceptr(pc),a1	; source ptr
	move.l	#scrolltemp+2,(a1)	; re install

	move.l	sinusptr(pc),a0		;
	addq.l	#8,a0			;sinusshape moves
	addq.l	#6,a0			;
	cmp.l	#endsinuslist,a0	;
	blt.s	sinusok			;
	sub.l	#2*sinuslistlength,a0	; restart shape
sinusok:move.l	a0,sinusptr		;

	move.l	sinus2ptr(pc),a4	;
;	addq.l	#4,a4			;sinusshape moves
	addq.l	#8,a4			;sinusshape moves
;	addq.l	#2,a4			;sinusshape moves
	cmp.l	#endsinuslist2,a4	;
	blt.s	sinus2ok		;
	sub.l	#2*sinuslist2length,a4	; restart shape
sinus2ok:move.l	a4,sinus2ptr		;

	move.w	#42,$64(a5)			; mod a
	move.w	#38,$62(a5)			; mod b
	move.w	#38,$66(a5)			; mod d
	move.w	#$ffff,$46(a5)			; mskL
	clr.w	$42(a5)				; con1

	move.l	scrollplaneptr(pc),a3		; doubbuf dest.

	move.l	#440,d5				; buffer to clear
	move.l	#400,d6
	moveq.l	#0,d1				; sinusofset
	moveq.l	#0,d2				; sinus2ofset

mcopybit1:				; & empty prev.plane
	move.l	#%1000000000000000,d3

	move.w	(a0)+,d1	
	move.w	(a4)+,d2
	add.l	d2,d1
	sub.l	d6,d1
	lea.l	6(a4),a4

	lea.l	(a3,d1),a2

	move.l	(a1),$50(a5)			; a
	move.l	a2,$54(a5)			; d
	move.w	d3,$44(a5)			; msk1
	move.w	#%0000100111110000,$40(a5)	; con0
	move.w	#%0000100110000001,$58(a5)	; trigger


	moveq.l	#14,d4
	add.l	d5,(a1)			; move sourceptr (shorter)
mcopyotherbits:
	lsr.w	#1,d3

	move.w	(a0)+,d1	
	move.w	(a4)+,d2
	add.l	d2,d1
	lea.l	6(a4),a4

	lea.l	(a3,d1),a2

	move.l	(a1),$50(a5)			; a
	move.l	a2,$4c(a5)			; b
	move.l	a2,$54(a5)			; d
	move.w	d3,$44(a5)			; msk1

	move.w	#%0000110111111100,$40(a5)	; con0
	move.w	#%0000010000000001,$58(a5)	; trigger

	dbf	d4,mcopyotherbits

endcopybits:
	cmp.l	#endsinuslist,a0
	blt.s	sinusptrok2
	sub.l	#2*sinuslistlength,a0
sinusptrok2:
	cmp.l	#endsinuslist2,a4
	blt.s	sinus2ptrok2
	lea.l	-[2*sinuslist2length](a4),a4
sinus2ptrok2:

	lea.l	2(a3),a3			; next word in dest

	sub.l	d5,(a1)				; next word in
	addq.l	#2,(a1)				; sourcebuffer

	dbf	d0,mcopybit1

	movem.l	(a7)+,a0-a6/d0-d7
	rts

sourceptr:	dc.l	scrolltemp
;--------------------------------------------------------------
fillcopper:

fillscrollplane:
	move.l	scrollplaneptr(pc),d1
	move.w	d1,scrollpt+6
	swap	d1
	move.w	d1,scrollpt+2
	swap	d1
	add.l	#40,d1
	move.w	d1,scrollpt+6+8
	swap	d1
	move.w	d1,scrollpt+2+8
rts
;--------------------------------------------------------
tunesinuslist:
	lea.l	sinuslist(pc),a0
	move.l	#realsinuslistlength-1,d0
tsl:	move.w	(a0),d1
	asr.w	#1,d1
	sub.w	#$20,d1
	mulu	#s_width,d1
	move.w	d1,(a0)+
	dbf	d0,tsl
tunesinuslist2:
	lea.l	sinuslist2(pc),a0
	move.l	#realsinuslist2length-1,d0
tsl2:	move.w	(a0),d1
	asr.w	#2,d1
	sub.w	#$18,d1
	mulu	#s_width,d1
	move.w	d1,(a0)+
	dbf	d0,tsl2

clearplane:
	lea.l	$70000,a0
	move.l	#256*40*6/4,d0
cpl:	clr.l	(a0)+
	dbf	d0,cpl
	rts
;--------------------------------------------------------
calcfontdata:
	clr.l	d2
	lea.l	mletteraddr,a1
cfdl:	lea.l	mlettertab,a3
	move.l	#mfontpic-2,d0
mnewchlp:addq.l	#2,d0			;ofset in pic
	move.b	(a3)+,d3
	cmp.l	#mendlettertab,a3
	bgt	mnextch			; not found
	cmp.b	d2,d3			;letter gevonden in tab
	bne.s	mnewchlp
;a0 = ptr to shape of letter
mendnewch:
	move.l	d2,d3
	asl.l	#2,d3

	move.l	d0,(a1,d3)
mnextch:addq.b	#1,d2
	cmp.w	#128,d2
	blt.s	cfdl

	rts
;--------------------------------------------------------
waitvblank:	cmp.b	#$30,$dff006
		bne.s	waitvblank
		rts
waitsummore:	cmp.b	#$31,$dff006
		bne.s	waitsummore
		rts
;--------------------------------------------------------
copperlist:
		dc.l	$00960100
scrollpt:	dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
scrollcolpt:	dc.l	$01800000,$01820400
		dc.l	$01840833,$01860611
		dc.l	$008e2931,$009029c1	;diw
		dc.l	$00920030,$009400c8	;ddf
		dc.l	$01020089
		dc.l	$01002000

		dc.l	$500ffffe,$00968100

		dc.l	$e80ffffe,$00960100


		dc.w	$009c
		dc.w	%1000011110010000
		dc.l	$fffffffe		;end of copperlist

even

pic=	$75000

s_width=	40

scrollplaneptr:	dc.l	scroll1

scrolltemp:	blk.b	80*44,$00

scroll1=	$70000
scroll2=	$72800


sinusptr:	dc.l	sinuslist

sinuslist:         ; generated with sinusgen by Cool-G   100 - 255
dc.w 177,178,179,179,180,181,182,182,183,184
dc.w 185,186,186,187,188,189,189,190,191,192
dc.w 192,193,194,195,195,196,197,198,198,199
dc.w 200,201,201,202,203,204,204,205,206,206
dc.w 207,208,209,209,210,211,211,212,213,213
dc.w 214,215,216,216,217,218,218,219,219,220
dc.w 221,221,222,223,223,224,225,225,226,226
dc.w 227,228,228,229,229,230,230,231,232,232
dc.w 233,233,234,234,235,235,236,236,237,237
dc.w 238,238,239,239,240,240,240,241,241,242
dc.w 242,243,243,243,244,244,245,245,245,246
dc.w 246,246,247,247,247,248,248,248,249,249
dc.w 249,250,250,250,250,251,251,251,251,251
dc.w 252,252,252,252,252,253,253,253,253,253
dc.w 253,254,254,254,254,254,254,254,254,254
dc.w 254,254,254,254,254,254,254,254,254,254
dc.w 254,254,254,254,254,254,254,254,254,254
dc.w 254,254,254,254,253,253,253,253,253,253
dc.w 252,252,252,252,252,251,251,251,251,251
dc.w 250,250,250,250,249,249,249,248,248,248
dc.w 247,247,247,246,246,246,245,245,245,244
dc.w 244,244,243,243,242,242,241,241,241,240
dc.w 240,239,239,238,238,237,237,236,236,235
dc.w 235,234,234,233,233,232,232,231,230,230
dc.w 229,229,228,228,227,226,226,225,225,224
dc.w 223,223,222,221,221,220,220,219,218,218
dc.w 217,216,216,215,214,214,213,212,212,211
dc.w 210,209,209,208,207,207,206,205,204,204
dc.w 203,202,201,201,200,199,199,198,197,196
dc.w 196,195,194,193,193,192,191,190,189,189
dc.w 188,187,186,186,185,184,183,183,182,181
dc.w 180,179,179,178,177,176,176,175,174,173
dc.w 172,172,171,170,169,169,168,167,166,166
dc.w 165,164,163,162,162,161,160,159,159,158
dc.w 157,156,156,155,154,153,153,152,151,151
dc.w 150,149,148,148,147,146,146,145,144,143
dc.w 143,142,141,141,140,139,139,138,137,137
dc.w 136,135,135,134,133,133,132,131,131,130
dc.w 130,129,128,128,127,127,126,125,125,124
dc.w 124,123,123,122,121,121,120,120,119,119
dc.w 118,118,117,117,116,116,115,115,114,114
dc.w 114,113,113,112,112,111,111,111,110,110
dc.w 109,109,109,108,108,108,107,107,107,106
dc.w 106,106,105,105,105,105,104,104,104,103
dc.w 103,103,103,103,102,102,102,102,102,101
dc.w 101,101,101,101,101,101,100,100,100,100
dc.w 100,100,100,100,100,100,100,100,100,100
dc.w 100,100,100,100,100,100,100,100,100,100
dc.w 100,100,100,100,100,100,100,100,101,101
dc.w 101,101,101,101,101,102,102,102,102,102
dc.w 103,103,103,103,104,104,104,104,105,105
dc.w 105,106,106,106,106,107,107,107,108,108
dc.w 109,109,109,110,110,110,111,111,112,112
dc.w 113,113,113,114,114,115,115,116,116,117
dc.w 117,118,118,119,119,120,120,121,121,122
dc.w 122,123,123,124,125,125,126,126,127,127
dc.w 128,129,129,130,131,131,132,132,133,134
dc.w 134,135,136,136,137,138,138,139,140,140
dc.w 141,142,142,143,144,144,145,146,147,147
dc.w 148,149,149,150,151,152,152,153,154,155
dc.w 155,156,157,158,158,159,160,161,161,162
dc.w 163,164,164,165,166,167,167,168,169,170
dc.w 171,171,172,173,174,174,175,176,177,178
endsinuslist:
dc.w 177,178,179,179,180,181,182,182,183,184
dc.w 185,186,186,187,188,189,189,190,191,192
dc.w 192,193,194,195,195,196,197,198,198,199
dc.w 200,201,201,202,203,204,204,205,206,206
dc.w 207,208,209,209,210,211,211,212,213,213
dc.w 214,215,216,216,217,218,218,219,219,220
dc.w 221,221,222,223,223,224,225,225,226,226
realendsinuslist:

sinuslistlength=	[endsinuslist-sinuslist]/2
realsinuslistlength=	[realendsinuslist-sinuslist]/2

sinus2ptr:	dc.l	sinuslist2

sinuslist2:         ; generated with sinusgen by Cool-G
dc.w 177,178,179,179,180,181,182,182,183,184
dc.w 185,186,186,187,188,189,189,190,191,192
dc.w 192,193,194,195,195,196,197,198,198,199
dc.w 200,201,201,202,203,204,204,205,206,206
dc.w 207,208,209,209,210,211,211,212,213,213
dc.w 214,215,216,216,217,218,218,219,219,220
dc.w 221,221,222,223,223,224,225,225,226,226
dc.w 227,228,228,229,229,230,230,231,232,232
dc.w 233,233,234,234,235,235,236,236,237,237
dc.w 238,238,239,239,240,240,240,241,241,242
dc.w 242,243,243,243,244,244,245,245,245,246
dc.w 246,246,247,247,247,248,248,248,249,249
dc.w 249,250,250,250,250,251,251,251,251,251
dc.w 252,252,252,252,252,253,253,253,253,253
dc.w 253,254,254,254,254,254,254,254,254,254
dc.w 254,254,254,254,254,254,254,254,254,254
dc.w 254,254,254,254,254,254,254,254,254,254
dc.w 254,254,254,254,253,253,253,253,253,253
dc.w 252,252,252,252,252,251,251,251,251,251
dc.w 250,250,250,250,249,249,249,248,248,248
dc.w 247,247,247,246,246,246,245,245,245,244
dc.w 244,244,243,243,242,242,241,241,241,240
dc.w 240,239,239,238,238,237,237,236,236,235
dc.w 235,234,234,233,233,232,232,231,230,230
dc.w 229,229,228,228,227,226,226,225,225,224
dc.w 223,223,222,221,221,220,220,219,218,218
dc.w 217,216,216,215,214,214,213,212,212,211
dc.w 210,209,209,208,207,207,206,205,204,204
dc.w 203,202,201,201,200,199,199,198,197,196
dc.w 196,195,194,193,193,192,191,190,189,189
dc.w 188,187,186,186,185,184,183,183,182,181
dc.w 180,179,179,178,177,176,176,175,174,173
dc.w 172,172,171,170,169,169,168,167,166,166
dc.w 165,164,163,162,162,161,160,159,159,158
dc.w 157,156,156,155,154,153,153,152,151,151
dc.w 150,149,148,148,147,146,146,145,144,143
dc.w 143,142,141,141,140,139,139,138,137,137
dc.w 136,135,135,134,133,133,132,131,131,130
dc.w 130,129,128,128,127,127,126,125,125,124
dc.w 124,123,123,122,121,121,120,120,119,119
dc.w 118,118,117,117,116,116,115,115,114,114
dc.w 114,113,113,112,112,111,111,111,110,110
dc.w 109,109,109,108,108,108,107,107,107,106
dc.w 106,106,105,105,105,105,104,104,104,103
dc.w 103,103,103,103,102,102,102,102,102,101
dc.w 101,101,101,101,101,101,100,100,100,100
dc.w 100,100,100,100,100,100,100,100,100,100
dc.w 100,100,100,100,100,100,100,100,100,100
dc.w 100,100,100,100,100,100,100,100,101,101
dc.w 101,101,101,101,101,102,102,102,102,102
dc.w 103,103,103,103,104,104,104,104,105,105
dc.w 105,106,106,106,106,107,107,107,108,108
dc.w 109,109,109,110,110,110,111,111,112,112
dc.w 113,113,113,114,114,115,115,116,116,117
dc.w 117,118,118,119,119,120,120,121,121,122
dc.w 122,123,123,124,125,125,126,126,127,127
dc.w 128,129,129,130,131,131,132,132,133,134
dc.w 134,135,136,136,137,138,138,139,140,140
dc.w 141,142,142,143,144,144,145,146,147,147
dc.w 148,149,149,150,151,152,152,153,154,155
dc.w 155,156,157,158,158,159,160,161,161,162
dc.w 163,164,164,165,166,167,167,168,169,170
dc.w 171,171,172,173,174,174,175,176,177,178
endsinuslist2:
dc.w 177,178,179,179,180,181,182,182,183,184
dc.w 185,186,186,187,188,189,189,190,191,192
dc.w 192,193,194,195,195,196,197,198,198,199
dc.w 200,201,201,202,203,204,204,205,206,206
dc.w 207,208,209,209,210,211,211,212,213,213
dc.w 214,215,216,216,217,218,218,219,219,220
dc.w 221,221,222,223,223,224,225,225,226,226
realendsinuslist2:

sinuslist2length=	[endsinuslist2-sinuslist2]/2
realsinuslist2length=	[realendsinuslist2-sinuslist2]/2

morigcharpos:	dc.b	16		; =width chars miniscroll
mcharpos:	dc.b	16
delay:		dc.b	0
		even

mscrollptr:		dc.l	text
mscrollrestart:		dc.l	textrestart

text:
textrestart:	
dc.b	"       yeeaaaahhhh !!!  |   here is  * cool-g *"
dc.b	"  with (as you can see) a nice sinus-scroll, ofcourse *not*"
dc.b	" made with the redsector democreator. please note that this"
dc.b	" sinus is 1-pixel (smooth!) and it uses full 320 pixels width"
dc.b	"... press right mousebutton to see how much raster it needs."
dc.b	"  now, let's cut the crap. i read your message and i think"
dc.b	" i like it !  if yo want the best intros for your group, "
dc.b	"i'm your man !! ofcourse you don't want OO megalame OO democreator-"
dc.b	"intros, but only OO supercool OO original self-written intros !"
dc.b	" i personally * hate * democreator. i ask 500 to 1000 fr for"
dc.b	" a simple intro, and 1000 to 2000 fr for a good one. don't worry"
dc.b	" you get the source and everything, so you can put your own"
dc.b	" text, logo, music in it, and re-use it as much as you want."
dc.b	" if you want something particular, just ask it. i have also"
dc.b	" made some menus (for democompacts etc) just look on the disk"
dc.b	" !!  ok, maybe my demos are expensive, and other guys are cheaper, but watch out"
dc.b	" for democreator-demos, because when you release such a demo"
dc.b	" you will always be considered as lame by every group in the"
dc.b	" scene !!  my intros are 100 percent self-coded, so the result"
dc.b	" is better, and the price is higher.  i hope we can make a deal !!"
dc.b	" see you around dudes !!                                   "
dc.b	0
endtext:
even

mfdepth=	1		; planes
mfheight=	16		; hoogte letter
mfwidthW=	1		; breedte letter WORDS
mftotwidthW=	1520/16		; breedte fontpic WORDS
mftotheight=	16		; hoogte fontpic

mfwidthB=	mfwidthW*2
mftotwidthB=	mftotwidthW*2
mfontpicsize=	mftotwidthB*mftotheight*mfdepth
mfontpic:	blk.b	mfontpicsize

>extern "df0:fonts/font.paradox",mfontpic,mfontpicsize

mletteraddr:	
	blk.l	128,0

mlettertab:
	dc.b	" !",34,"#$%&'()*+,-./0123456789:;<=>?Yabcdefghijklmnopqrstuvwxyz"
	dc.b	"[\]^_` CDMBJT OP RKNSE"
	dc.b	0
mendlettertab:
	even

libname:
	dc.b	"graphics.library",0
	even

coloraddr:	dc.l	0
;---------------------------------------------------------------
