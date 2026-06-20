;         ннннннннннннннннннннннннннннннннннннннннннннннннннн
;         н Trainer-Menu by NMI of The Special Brothers !!! н
;         ннннннннннннннннннннннннннннннннннннннннннннннннннн

copbeg=$bc09
trlines=40
yesno=25

>extern	"df1:sintab",sinustab,900
>extern	"df0:modules/mod.arcane",module

waitblt:macro
waitblt?0:
	btst	#14,$2(a6)
	bne.s	waitblt?0
	endm
run:
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	init_music
	lea	stardata(pc),a0
	move.l	a0,d0
	lea	starpt(pc),a0
	move.w	d0,4(a0)
	swap	d0
	move.w	d0,(a0)
	lea	$dff000,a6
	lea	$60000,a0
clrloop:
	clr.l	(a0)+
	cmp.l	#$78000,a0
	bmi.s	clrloop

	lea	$68000,a5
	lea	text(pc),a1
textloop:
	move.l	a5,a0
	tst.b	(a1)
	beq.s	nomoretext
	bmi.s	freeline
	moveq	#39,d5
	bsr	textrout
	bra.s	nofreeline
freeline:
	addq.l	#1,a1
nofreeline:
	add.l	#8*42,a5
	bra.s	textloop
nomoretext:
	lea	traintextadr(pc),a1
	move.l	a0,(a1)
	move.l	a0,a5
	lea	traintext(pc),a1
ttextloop:
	move.l	a5,a0
	tst.b	(a1)
	beq.s	tnomoretext
	bmi.s	freeline2
	moveq	#39,d5
	bsr	textrout
	bra.s	nofreeline2
freeline2:
	addq.l	#1,a1
nofreeline2:
	add.l	#8*42,a5
	bra.s	ttextloop
tnomoretext:
	lea	copperlist(pc),a0
	move.l	a0,$80(a6)
	clr.w	$88(a6)
	move.l	#0,$144(a6)
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$9c(a6)
	move.w	#$87e0,$96(a6)
wait:
	cmp.b	#234,$6(a6)
	bne.s	wait
	bsr	play
	lea	$dff000,a6
	bsr	vector_bobs
	bsr	logojump
	bsr	stars
	bsr	scroller
	bsr	checkmouse
	btst	#10,$16(a6)
	bne.s	textyes
	lea	rmouse(pc),a0
	addq.b	#1,(a0)
	cmp.b	#5,(a0)
	bne.s	textyes
	move.b	#0,(a0)

	move.w	stripe(pc),d0
	sub.w	#copbeg,d0
	lsr.w	#8,d0
	lsr.w	#3,d0
	move.w	d0,d1
	lea	traintab(pc),a3
	tst.b	(a3,d1.w)
	ble.s	textyes
	lea	trainword(pc),a1
	bchg	d1,(a1)
	move.l	traintextadr(pc),a0
	mulu	#8*42,d0
	add.l	d0,a0
	add.l	#yesno,a0
	btst	d1,(a1)
	beq.s	textno
	lea	yestext(pc),a1
	moveq	#4,d5
	bsr	textrout
	bra.s	textyes
textno:
	lea	notext(pc),a1
	moveq	#4,d5
	bsr	textrout
textyes:
	move.w	#copbeg,d0
	moveq	#trlines,d1
	lsl.w	#8,d1
	add.w	d1,d0
	cmp.w	stripe(pc),d0
	bne.L	wait
	btst	#6,$bfe001
	bne	wait
	move.w	#$f,$96(a6)
	move.l	4.w,a5
	move.l	(a5),a5
	move.l	(a5),a5
	move.l	38(a5),$80(a6)
	clr.w	$88(a6)
	move.w	#$7fff,$96(a6)
	move.w	#$83f0,$96(a6)
	move.w	#$7fff,$9a(a6)
	move.w	#$e02c,$9a(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	lea	$7ff30,a1
	lea	trainword(pc),a0
	btst	#0,(a0)
	beq.s	not0set
	move.l	#$33fc4e71,(a1)+	; move.w #nop,
	move.l	#$0000fa12,(a1)+	; $fa12
	move.l	#$33fc4e71,(a1)+
	move.l	#$0000fa14,(a1)+
	move.l	#$33fc4e71,(a1)+
	move.l	#$0000fa16,(a1)+
not0set:
	btst	#1,(a0)
	beq.s	not1set
	move.l	#$33fc4e71,(a1)+
	move.l	#$0000e75c,(a1)+
	move.l	#$33fc4e71,(a1)+
	move.l	#$0000e75e,(a1)+
	move.l	#$33fc4e71,(a1)+
	move.l	#$0000e760,(a1)+
	move.l	#$33fc4e71,(a1)+
	move.l	#$0000e762,(a1)+

	move.l	#$13fc0005,(a1)+
	move.l	#$0000e73a,(a1)+

	move.l	#$33fc4e71,(a1)+
	move.l	#$00010516,(a1)+
	move.l	#$33fc4e71,(a1)+
	move.l	#$00010518,(a1)+
	move.l	#$33fc4e71,(a1)+
	move.l	#$0001051a,(a1)+
not1set:
	move.l	#$4ef90000,(a1)+	; jmp
	move.w	#$b000,(a1)+		; $b000
	rts

; ннннннннн
; н Stars н
; ннннннннн
stars:
	lea	stardata+1(pc),a0
	moveq	#15,d1
	moveq	#1,d2
	moveq	#2,d3
	moveq	#3,d4
movestars:
	cmp.b	#$df,(a0)
	blo.s	nonewstar
	move.b	#$3c,(a0)
	bra.s	nostarmove
nonewstar:
	add.b	d2,(a0)
nostarmove:
	addq.l	#8,a0
	cmp.b	#$df,(a0)
	blo.s	nonewstar2
	move.b	#$3c,(a0)
	bra.s	nostarmove2
nonewstar2:
	add.b	d3,(a0)
nostarmove2:
	addq.l	#8,a0
	cmp.b	#$df,(a0)
	blo.s	nonewstar3
	move.b	#$3c,(a0)
	bra.s	nostarmove3
nonewstar3:
	add.b	d4,(a0)
nostarmove3:
	addq.l	#8,a0
	dbra	d1,movestars
	rts

; ннннннннннннн
; н Printtext н
; ннннннннннннн
textrout:
print:
	lea	font(pc),a2
	move.l	a0,a4
	moveq	#0,d0
	move.b	(a1)+,d0
	sub.b	#$20,d0
	lsl.w	#3,d0
	add.l	d0,a2
	moveq	#7,d7
copychar:
	move.b	(a2)+,(a4)
	add.w	#42,a4
	dbra	d7,copychar
	addq.l	#1,a0
	dbra	d5,print
	rts

; нннннннннннн
; н Scroller н
; нннннннннннн
scroller:
	lea	noscroll(pc),a5
	move.l	(a5),d0
	subq.l	#1,d0
	bmi.s	do_scrolling
	move.l	d0,(a5)
	bra.L	contvbl
do_scrolling:
	move.l	#0,(a5)
	lea	textctr(pc),a2
	tst.w	(a2)
	bne.L	no
	lea	textptr(pc),a3
	move.l	(a3),a0
	moveq	#0,d0
	move.b	(a0)+,d0
	lea	textend(pc),a4
	cmp.l	(a3),a4
	bne.s	noend
	lea	scrollmsg(pc),a0
	move.b	(a0)+,d0
noend:
	move.l	a0,(a3)
	sub.b	#$20,d0
	lsl.w	#3,d0
	lea	font(pc),a0
	add.l	d0,a0
	moveq	#7,d7
	clr.b	$68000+[180*42]+42
	lea	$68000+[180*42]+42+40,a1
cchar:
	move.b	(a0)+,(a1)
	add.w	#42,a1
	dbra	d7,cchar
	move.w	#4,(a2)
no:
	subq.w	#1,(a2)
endscroll:
	waitblt
	move.l	#$0,$64(a6)
	move.l	#$e9f00000,$40(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	#$68000+[180*42]+42,$50(a6)
	move.l	#$68000+[180*42]+40,$54(a6)
	move.w	#10*64+21,$58(a6)
contvbl:
	waitblt
	rts

; ннннннннн
; н Mouse н
; ннннннннн
checkmouse:
	lea	waitmouse(pc),a0
	subq.b	#1,(a0)
	bne.s	nothing
	move.b	#3,(a0)
	lea	lasty(pc),a2
	lea	mousey(pc),a3
	move.b	$a(a6),d0
	move.b	(a2),d1
	move.b	d0,(a2)
	sub.b	d1,d0
	beq.s	nothing
	bmi.s	subit
addit:
	cmp.w	#trlines,(a3)
	beq.s	nothing
	lea	addd(pc),a0
	addq.b	#1,(a0)
	cmp.b	#3,(a0)
	blt.s	nothing
	move.b	#0,(a0)
	addq.w	#8,(a3)
checktext:
	move.w	(a3),d0
	lsr.w	#3,d0
	lea	traintab(pc),a2
	tst.b	(a2,d0.w)
	bge.s	nothing
	addq.w	#8,(a3)
	bra.s	checktext
subit:
	tst.w	(a3)
	beq.s	nothing
	lea	subb(pc),a0
	addq.b	#1,(a0)
	cmp.b	#3,(a0)
	blt.s	nothing
	move.b	#0,(a0)
	subq.w	#8,(a3)
checktext2:
	move.w	(a3),d0
	lsr.w	#3,d0
	lea	traintab(pc),a2
	tst.b	(a2,d0.w)
	bge.s	nothing
	subq.w	#8,(a3)
	bra.s	checktext2
nothing:
	move.w	mousey(pc),d0
	bge.s	okdoit1
	move.w	#0,d0
okdoit1:
	cmp.w	#trlines,d0
	ble.s	okdoit2
	move.w	#trlines,d0
okdoit2:
	lsl.w	#8,d0
	add.w	#copbeg,d0
	lea	stripe(pc),a0
	move.w	d0,(a0)
	add.w	#$800,d0
	move.w	d0,16(a0)
	rts

; ннннннннннн
; н Jumping н
; ннннннннннн
logojump:
	lea	logoptr(pc),a0
	lea	logotab(pc),a1
	lea	logoend(pc),a2
	lea	logostart(pc),a3
	addq.l	#2,(a0)
	cmp.l	(a0),a2
	bne.s	notlogoend
	move.l	a1,(a0)
notlogoend:
	move.l	(a0),a0
	move.w	(a0),d0
	move.w	d0,(a3)
	add.w	#32,(a3)
	rts

;ннннннннннннннн
;н Vector-Bobs н
;ннннннннннннннн
vector_bobs:
;нннннннннннннннн
;н clear screen н
;нннннннннннннннн
	move.l	bitmap2(pc),d3
	addq.w	#8,d3
	waitblt
	move.l	#$fffefffe,$62(a6)
	move.l	d3,$54(a6)
	move.l	#$1000000,$40(a6)
	move.w	#16,$66(a6)
	move.w	#600*64+12,$58(a6)
;нннннннннннннннннннннннн
;н rotating and sorting н
;нннннннннннннннннннннннн
	lea	bobtabptr(pc),a1
	move.l	(a1),a4
	lea	delay(pc),a0
	lea	bobtabptr2(pc),a2
	lea	bobpatterns(pc),a3
	subq.w	#1,(a0)
	bne.s	nochange
	add.l	#24,(a1)
	move.l	(a1),a5
	cmp.l	#-1,(a5)
	bne.s	notendtab
	move.l	a3,(a1)
notendtab:
	move.l	(a1),a4
	move.w	14(a4),(a0)
	bra.s	change
nochange:
	move.l	(a1),a4
change:
	move.l	4(a4),(a2)		; coordtab2
	move.w	#360,d1
	lea	Angle_y(pc),a0
	move.w	(a0),d0
	add.w	10(a4),d0
	cmp.w	d1,d0
	blo.s	not360y
	sub.w	d1,d0
not360y:
	move.w	d0,(a0)
	lea	lowestz(pc),a0
	lea	lowestz2(pc),a1
	move.w	(a1),(a0)
	move.w	2(a1),2(a0)		; 2(a1)=highestz2 2(a0)=highestz
	lea	sinustab(pc),a4
	lea	cosinustab(pc),a5
	move.w	angle_y(pc),d0
	move.w	d0,d1
	add.w	d0,d0
	move.w	(a5,d0.w),d5		; cos(ay)
	add.w	d1,d1
	move.w	(a4,d1.w),d6		; sin(ay)
	move.l	bobtabptr(pc),a4
	move.l	(a4),a4
	lea	bobtabptr2(pc),a2
	lea	sortram(pc),a1
	lea	lowestz(pc),a0
rotloop:
	move.w	(a4)+,d0
	move.w	(a4)+,d1
	move.w	(a4)+,d2
rotate:
	move.w	d2,d4			; z
	move.w	d0,d3			; x
	muls	d5,d0			; x*cos(ay)
	muls	d6,d4			; z*sin(ay)
	add.l	d4,d0			; x*cos(ay)+z*sin(ay)
	add.l	d0,d0
	swap	d0
	muls	d6,d3			; x*sin(ay)
	muls	d5,d2			; z*cos(ay)
	sub.l	d3,d2			; z*cos(ay)-x*sin(ay)
	add.l	d2,d2
	swap	d2
;нннннннннннн
;н 3d to 2d н
;нннннннннннн
	moveq	#8,d3
	lsl.w	d3,d0			; x*256
	lsl.w	d3,d1			; y*256
	add.w	#280,d2
	ext.l	d0
	ext.l	d1
	ext.l	d2
	divs	d2,d0			; x/z
	divs	d2,d1			; y/z

	cmp.w	(a0),d2			; lowestz
	ble.s	higher
	move.w	d2,(a0)
higher:
	cmp.w	2(a0),d2		; 2(a5)=highest z
	bge.s	lower
	move.w	d2,2(a0)
lower:
	move.l	a1,a5
	lsl.w	#6,d2
	ext.l	d2			; d2*64
	add.l	d2,a5
	moveq	#0,d3
	move.w	(a5),d3
	addq.w	#1,(a5)+		; number+1
	add.w	d3,d3
	add.l	d3,a5
	move.l	(a2),d2			; bobtabptr2
	move.l	d2,a3
	move.w	d0,(a3)+		; x
	move.w	d1,(a3)			; y
	move.l	bobtabptr(pc),a3
	move.l	4(a3),a3		; coordtab2
	sub.l	a3,d2
	move.w	d2,(a5)+		; bob-number
	addq.l	#8,(a2)			; x=2 y=2 adr=4
	cmp.w	#$abcd,(a4)
	bne.S	rotloop
;ннннннннннннн
;н draw bobs н
;ннннннннннннн
	move.l	bobtabptr(pc),a3
	move.l	4(a3),(a5)		; coordtab2
	move.l	bitmap2(pc),d3
	lea	sortram(pc),a0
	move.l	a0,a3
	move.w	highestz(pc),d6
	ext.l	d6
	subq.w	#1,d6
	lsl.w	#6,d6
	add.l	d6,a3
	move.w	lowestz(pc),d6
	ext.l	d6
	addq.w	#1,d6
	lsl.w	#6,d6
	add.l	d6,a0
	move.l	a0,a4
	waitblt
	move.l	#$ffff0000,$44(a6)
getnext:
	sub.l	#64,a4
	cmp.l	a4,a3
	beq.L	allbobsdone
	move.l	a4,a0
	tst.w	(a0)
	beq.s	getnext
drawbob:
	move.w	(a0),d7			; number of bobs
	move.w	#0,(a0)+		; clear number
	subq.w	#1,d7
bobloop:
	move.w	(a0)+,d5
	move.l	bobtabptr(pc),a5
	move.w	18(a5),d4
	move.l	d3,a1
	move.l	4(a5),a5
	add.l	d5,a5
	move.w	(a5),d0			; x
	move.w	2(a5),d1		; y
	move.l	4(a5),a5
	add.w	12(a5),d0
	add.w	14(a5),d1
	add.w	logostart(pc),d1
	move.w	d0,d2
	lsr.w	#4,d0
	add.w	d0,d0
	and.w	#$f,d2
	mulu	d4,d1
	add.w	d1,d0
	add.w	d0,a1
	ror.w	#4,d2
	move.w	d2,$42(a6)
	or.w	#$0fca,d2
	move.w	d2,$40(a6)
	move.w	10(a5),$66(a6)
	move.w	10(a5),$60(a6)
	move.l	0(a5),$4c(a6)		; bob
	move.l	a1,$48(a6)
	move.l	a1,$54(a6)
	move.l	4(a5),$50(a6)		; mask
	move.w	8(a5),$58(a6)
	dbra	d7,bobloop
	bra.L	getnext
allbobsdone:
	lea	bitmap1(pc),a0		; swap screens
	lea	bitmap2(pc),a1
	move.l	(a1),a2
	move.l	(a0),(a1)
	move.l	a2,(a0)
	lea	bmadrs(pc),a0		; new bplptrs
	move.l	bitmap1(pc),d0
	swap	d0
	move.w	d0,(a0)
	move.w	d0,4(a0)
	move.w	d0,8(a0)
	lea	lowestz2(pc),a0
	lea	lowestz(pc),a1
	move.w	(a0),2(a0)		; 2(a0)=highestz2
	move.w	(a1),2(a1)		; 2(a1)=highestz
	rts

copperlist:
	dc.w	$00e4,$0006,$00e6,$802a,$00ec,$0006,$00ee,$8000

	dc.w	$00e2,$0000,$00ea,$0028,$00f2,$0050,$00e0
bmadrs:
	dc.w	$0006,$00e8,$0006,$00f0,$0006
	dc.w	$0182,$0fff,$0184,$0bdd,$0186,$09bb,$0188,$0699
	dc.w	$018a,$0477,$018c,$0255,$018e,$0133
	dc.w	$0108,$0050
	dc.w	$01a2,$0999,$01a4,$0666,$01a6,$0ccc
	dc.w	$0120
starpt:
	dc.w	$0000,$0122,$0000,$0124,$0000,$0126,$0000,$0128
	dc.w	$0000,$012a,$0000,$012c,$0000,$012e,$0000,$0130
	dc.w	$0000,$0132,$0000,$0134,$0000,$0136,$0000,$0138
	dc.w	$0000,$013a,$0000,$013c,$0000,$013e,$0000
	dc.w	$0192,$0633,$0194,$0b88,$0196,$0fdd
;	dc.w	$0192,$0336,$0194,$088b,$0196,$0ddf
;	dc.w	$0192,$0633,$0194,$0b88,$0196,$0fdd
	dc.w	$010a,$0002
	dc.w	$0100,$0200,$0102,$0000,$0104,$0040,$008e,$4481
	dc.w	$0090,$0cc1,$0092,$0038,$0094,$00d0
	dc.w	$3d09,$fffe,$0180,$0444
	dc.w	$3e09,$fffe,$0180,$0888
	dc.w	$3f09,$fffe,$0180,$0ccc
	dc.w	$4009,$fffe,$0180,$0fff
	dc.w	$4109,$fffe,$0180,$0ccc
	dc.w	$4209,$fffe,$0180,$0888
	dc.w	$4309,$fffe,$0180,$0444
	dc.w	$4409,$fffe,$0180,$0000
	dc.w	$0100,$5600
	dc.w	$a409,$fffe,$0192,$0530,$0194,$0a85,$0196,$0fda
stripe:
	dc.w	$bc09,$fffe,$0192,$0035,$0194,$058a,$0196,$0adf
	dc.w	$c409,$fffe,$0192,$0530,$0194,$0a85,$0196,$0fda
	dc.w	$f809,$fffe,$0192,$0633,$0194,$0b88,$0196,$0fdd
;	dc.w	$f809,$fffe,$0192,$0350,$0194,$08a5,$0196,$0dfa
	dc.w	$ffdf,$fffe
	dc.w	$0409,$fffe,$0192,$0035,$0194,$058a,$0196,$0adf
	dc.w	$0c09,$fffe,$0100,$0000,$0180,$0444
	dc.w	$0d09,$fffe,$0180,$0888
	dc.w	$0e09,$fffe,$0180,$0ccc
	dc.w	$0f09,$fffe,$0180,$0fff
	dc.w	$1009,$fffe,$0180,$0ccc
	dc.w	$1109,$fffe,$0180,$0888
	dc.w	$1209,$fffe,$0180,$0444
	dc.w	$1309,$fffe,$0180,$0000
	dc.w	$ffff,$fffe
lasty:
	dc.b	0
waitmouse:
	dc.b	8
subb:
	dc.b	0
addd:
	dc.b	0
rmouse:
	dc.b	0
	even
mousey:
	dc.w	0
scrollmsg:
	dc.b	"THE SPECIAL BROTHERS PROUDLY PRESENT : THE SWORD AND"
	DC.B	" THE ROSE ++ !!!! CRACKED BY ANGELS,IMPORTED TO LUXEM"
	DC.B	"BOURG BY XAVOX AND TRAINED BY NMI OF THE SPECIAL"
	DC.B	" BROTHERS. TO CONTACT US,WRITE TO : JOEL SCHROEDER"
	DC.B	"     P.O. BOX 206     L-3403 DUDELANGE     LUXEMBOURG."
	DC.B	" GFREETZ TO ALL CONTACTS & FRIENDS !!!! GOTTA GO NOW..."
	DC.B	" SEE YA SOON !!!!!!!                                "
textend:
	even
textptr:
	dc.l	scrollmsg
textctr:
	dc.w	0
noscroll:
	dc.l	0
stardata:
	dc.l	$4A6E4B00,$00008000,$4E894F00,$80000000
	dc.l	$52665300,$80008000,$56565700,$00008000
	dc.l	$5AD05B00,$80000000,$5E715F00,$80008000
	dc.l	$629D6300,$00008000,$66A86700,$80000000
	dc.l	$6AB46B00,$80008000,$6E616F00,$00008000
	dc.l	$72497300,$80000000,$76E97700,$80008000
	dc.l	$7AD77B00,$00008000,$7E7A7F00,$80000000
	dc.l	$821C8300,$80008000,$86A48700,$00008000
	dc.l	$8A548B00,$80000000,$8E6E8F00,$80008000
	dc.l	$92129300,$00008000,$965A9700,$80000000
	dc.l	$9A609B00,$80008000,$9E5F9F00,$00008000
	dc.l	$A29EA300,$80000000,$A65EA700,$80008000
	dc.l	$AAADAB00,$00008000,$AE5EAF00,$80000000
	dc.l	$B241B300,$80008000,$B69BB700,$00008000
	dc.l	$BAB2BB00,$80000000,$BE1ABF00,$80008000
	dc.l	$C2FAC300,$00008000,$C68BC700,$80000000
	dc.l	$CA6DCB00,$80008000,$CE0ECF00,$00008000
	dc.l	$D287D300,$80000000,$D617D700,$80008000
	dc.l	$DA1EDB00,$00008000,$DE6DDF00,$80000000
	dc.l	$E277E300,$80008000,$E6DEE700,$00008000
	dc.l	$EAB9EB00,$80000000,$EE71EF00,$80008000
	dc.l	$F2C4F300,$00008000,$f69Ff700,$80000000
	dc.l	$fA41fb00,$80008000,$fE54ff00,$00008000
	dc.l	$02C40306,$80000000,$06520706,$80008000
	dc.l	0
text:
	dc.b	-1
	dc.b	-1
	dc.b	"          THE SPECIAL BROTHERS          "
	DC.B	"         ----------------------         "
	dc.b	-1
	dc.b	-1
	DC.B	"            PROUDLY PRESENT:            "
	dc.b	-1
	dc.b	-1
	DC.B	"        THE SWORD AND THE ROSE++        "
	dc.b	"       --------------------------       "
	dc.b	-1
	dc.b	-1
	dc.b	-1
	dc.b	-1
	dc.b	0
traintext:
	dc.b	"          UNLIMITED LIVES (NO)          "
	dc.b	"          UNLIMITED KEYS  (NO)          "
	dc.b	-1
	dc.b	-1
	dc.b	-1
	dc.b	"               START GAME               "
	dc.b	-1
	dc.b	-1
	dc.b	-1
	dc.b	"                                     NMI"
	dc.b	0
	even
traintab:
	dc.b	1,1,-1,-1,-1,0,-1,-1,-1,-1
	even
notext:
	dc.b	" (NO)"
	even
yestext:
	dc.b	"(YES)"
	even
font:
dc $00,$00,$00,$00,$00,$00,$00,$00		; Space
dc $00,$18,$18,$18,$18,$18,$00,$18		; !
dc $00,$6c,$6c,$00,$00,$00,$00,$00		; "
dc $00,$36,$7f,$36,$36,$7f,$36,$00		; #
dc $00,$08,$3c,$68,$3c,$16,$7c,$10		; $
dc $00,$00,$66,$6c,$18,$36,$66,$00		; %
dc $00,$1c,$36,$1c,$3f,$66,$7b,$00		; &
dc $0c,$18,$30,$00,$00,$00,$00,$00		; '
dc $00,$03,$06,$0c,$0c,$0c,$06,$03		; (
dc $00,$60,$30,$18,$18,$18,$30,$60		; )
dc $00,$18,$42,$18,$7e,$18,$42,$18		; *
dc $00,$00,$1c,$1c,$7f,$1c,$1c,$00		; +
dc $00,$00,$00,$00,$00,$30,$30,$60		; ,
dc $00,$00,$00,$00,$7f,$00,$00,$00		; -
dc $00,$00,$00,$00,$00,$30,$30,$00		; .
dc $00,$00,$03,$06,$0c,$18,$30,$60		; /
dc $00,$00,$7f,$63,$63,$63,$7f,$00		; 0
dc $00,$00,$3c,$0c,$0c,$0c,$0c,$1e		; 1
dc $00,$00,$7f,$03,$7f,$70,$7f,$00		; 2
dc $00,$00,$7f,$03,$1f,$03,$7f,$00		; 3
dc $70,$70,$76,$76,$7f,$06,$06,$00		; 4
dc $00,$00,$7f,$70,$7e,$07,$7e,$00		; 5
dc $70,$70,$70,$70,$7f,$73,$7f,$00		; 6
dc $00,$00,$7f,$03,$03,$03,$03,$03		; 7
dc $00,$00,$7f,$73,$7f,$73,$7f,$00		; 8
dc $00,$00,$7f,$73,$7f,$03,$03,$03		; 9
dc $00,$00,$18,$18,$00,$18,$18,$00		; :
dc $00,$00,$18,$18,$00,$18,$18,$30		; ;
dc $00,$0c,$18,$30,$60,$30,$18,$0c		; <
dc $00,$00,$00,$3c,$00,$3c,$00,$00		; =
dc $00,$30,$18,$0c,$06,$0c,$18,$30		; >
dc $00,$00,$7f,$63,$0f,$0c,$00,$0c		; ?
dc $00,$00,$00,$00,$00,$00,$00,$00		; @
dc $00,$00,$ff,$03,$7f,$73,$73,$00		; A
dc $00,$00,$fe,$03,$7e,$73,$7e,$00		; B
dc $00,$00,$3f,$70,$70,$70,$3f,$00		; C
dc $00,$00,$fe,$03,$73,$73,$7e,$00		; D
dc $00,$00,$ff,$00,$7f,$70,$7f,$00		; E
dc $00,$00,$7f,$00,$7f,$60,$60,$00		; F
dc $00,$00,$3f,$70,$73,$73,$3f,$00		; G
dc $00,$00,$73,$73,$7f,$73,$73,$70		; H
dc $00,$00,$1c,$1c,$1c,$1c,$1c,$00		; I
dc $00,$00,$ff,$06,$06,$06,$7e,$00		; J
dc $00,$00,$73,$76,$7c,$76,$73,$00		; K
dc $00,$70,$70,$70,$70,$70,$7f,$00		; L
dc $00,$00,$63,$77,$7f,$6b,$63,$60		; M
dc $40,$60,$73,$7b,$7f,$77,$73,$01		; N
dc $00,$00,$fe,$03,$63,$63,$3e,$00		; O
dc $00,$00,$fe,$03,$7e,$70,$70,$00		; P
dc $00,$00,$3e,$63,$63,$6f,$3e,$03		; Q
dc $00,$00,$fe,$03,$7e,$66,$63,$00		; R
dc $00,$00,$0f,$1c,$1c,$1c,$f8,$00		; S
dc $00,$00,$ff,$1c,$1c,$1c,$1c,$00		; T
dc $00,$00,$73,$73,$73,$73,$3e,$00		; U
dc $00,$00,$73,$73,$73,$3e,$1c,$00		; V
dc $03,$03,$63,$6b,$7f,$77,$63,$00		; W
dc $00,$00,$73,$73,$3e,$73,$73,$00		; X
dc $00,$00,$73,$73,$7f,$1c,$1c,$1c		; Y
dc $00,$00,$ff,$0e,$1c,$38,$7f,$00		; Z
dc $00,$3c,$38,$38,$38,$38,$38,$3c		; [
dc $00,$00,$1f,$38,$fe,$70,$7f,$00		; г
dc $00,$3c,$1c,$1c,$1c,$1c,$1c,$3c		; ]
dc $00,$18,$3c,$7e,$18,$18,$18,$18		; ^
dc $00,$00,$10,$3f,$7f,$3f,$10,$00		; <-
traintextadr:
	dc.l	0
trainword:
	dc.w	0

lowestz:
	dc.w	0
highestz:
	dc.w	0
lowestz2:
	dc.w	150
highestz2:
	dc.w	350
Angle_y:
	dc.w	0
logostart:
	dc.w	0
bitmap1:
	dc.l	$60000
bitmap2:
	dc.l	$70000
sinustab:
	blk.b	180,0
cosinustab:
	blk.b	720,0
logoptr:
	dc.l	logotab
logotab:
	dc.w	$0,$0,$0,$0,$2,$3,$6,$8,$B,$F,$13,$17,$1B
	dc.w	$20,$26,$2B,$31,$37,$3D,$43,$49,$50,$49
	dc.w	$43,$3D,$37,$31,$2B,$26,$21,$1C,$17,$13
	dc.w	$F,$B,$8,$6,$3,$2,$1
logoend:
	dc.w	0
tsblogo:
	dc.w    0,-32,0
	dc.w    -16,-16,0
	dc.w    0,0,0
	dc.w    10,16,0
	dc.w    0,32,0
	dc.w    -16,32,0
	dc.w    16,-32,0
	dc.w    -32,32,0
	dc.w    32,-32,0
	dc.w    48,-32,0
	dc.w    64,-32,0
	dc.w    80,-16,0
	dc.w    64,0,0
	dc.w    80,16,0
	dc.w    64,32,0
	dc.w    48,32,0
	dc.w    32,32,0
	dc.w    32,16,0
	dc.w    32,0,0
	dc.w    32,-16,0
	dc.w    -16,-32,0
	dc.w    -32,-32,0
	dc.w    -48,-32,0
	dc.w    -64,-32,0
	dc.w    -80,-32,0
	dc.w    -48,-16,0
	dc.w    -48,0,0
	dc.w    -48,16,0
	dc.w    -48,32,0
	dc.w	$abcd
tsblogo2:
	dc.l	0,bob1,0,bob1,0,bob1,0,bob1,0,bob1,0,bob1
	dc.l	0,bob1,0,bob1,0,bob1,0,bob1,0,bob1,0,bob1
	dc.l	0,bob1,0,bob1,0,bob1,0,bob1,0,bob1,0,bob1
	dc.l	0,bob1,0,bob1,0,bob1,0,bob1,0,bob1,0,bob1
	dc.l	0,bob1,0,bob1,0,bob1,0,bob1,0,bob1

; coordinates-table.l,bob-table.l,ax-add.w,ay-add.w,az-add.w,delay.w
; bltsize.w,next line at bytes.w,bplcon0.w,modulo.w

bobpattern:
	dc.l	tsblogo,tsblogo2
	dc.w	0,0,0,1,0,0,0,0
bobpatterns:
	dc.l	tsblogo,tsblogo2
	dc.w	0,5,0,360,0,120,0,0
	dc.l	-1
bobtabptr:
	dc.l	bobpattern
bobtabptr2:
	dc.l	tsblogo2
delay:
	dc.w	1
; bobtabs : bobbitmap.l,bobmask.l,bltsize.w,modulo.w,xadd.w,yadd.w

bob1:
	dc.l	bob,mask
	dc.w	16*3*64+2,36,152,42
bob:
	dc.w	$07c0,$07c0,$07c0,$1870,$1fb0,$1ff0,$25a8,$33c8,$3ff8
	dc.w	$4e14,$61e4,$73fc,$5dd6,$43e2,$67fe,$bb96,$c7e2,$effe
	dc.w	$9795,$efe3,$ffff,$d71d,$efe3,$ffff,$ae2d,$ffc1,$ffff
	dc.w	$8871,$ff81,$ffff,$60ee,$5f06,$7ffa,$4fae,$400e,$7ff2
	dc.w	$21aa,$2006,$3ff6,$1fbc,$102c,$1fcc,$0ef0,$0cd0,$0f30
	dc.w	$03e0,$03e0,$03e0
mask:
	dc.w	$07c0,$07c0,$07c0,$1ff0,$1ff0,$1ff0,$3ff8,$3ff8,$3ff8
	dc.w	$7ffc,$7ffc,$7ffc,$7ffe,$7ffe,$7ffe,$fffe,$fffe,$fffe
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe
	dc.w	$3ffe,$3ffe,$3ffe,$1ffc,$1ffc,$1ffc,$0ff0,$0ff0,$0ff0
	dc.w	$03e0,$03e0,$03e0
*********************************************************
**  Amiga FUTURE COMPOSER  ╗╗ V1.4 лл  Replay routine  **
*********************************************************

;Doesn't work with V1.0 - V1.3 modules !!

END_MUSIC:
clr.w onoff
clr.l $dff0a6
clr.l $dff0b6
clr.l $dff0c6
clr.l $dff0d6
move.w #$000f,$dff096
bclr #1,$bfe001
rts

INIT_MUSIC:
move.w #1,onoff
bset #1,$bfe001
lea MODULE,a0
lea 180(a0),a1
move.l a1,SEQpoint
move.l a0,a1
add.l 8(a0),a1
move.l a1,PATpoint
move.l a0,a1
add.l 16(a0),a1
move.l a1,FRQpoint
move.l a0,a1
add.l 24(a0),a1
move.l a1,VOLpoint
move.l 4(a0),d0
divu #13,d0

lea 40(a0),a1
lea SOUNDINFO+4(pc),a2
moveq #10-1,d1
initloop:
move.w (a1)+,(a2)+
move.l (a1)+,(a2)+
adda.w #10,a2
dbf d1,initloop
move.l a0,d1
add.l 32(a0),d1
lea SOUNDINFO(pc),a3
move.l d1,(a3)+
moveq #9-1,d3
moveq #0,d2
initloop1:
move.w (a3),d2
add.l d2,d1
add.l d2,d1
addq.l #2,d1
adda.w #12,a3
move.l d1,(a3)+
dbf d3,initloop1

lea 100(a0),a1
lea SOUNDINFO+[10*16](pc),a2
move.l a0,a3
add.l 36(a0),a3

moveq #80-1,d1
moveq #0,d2
initloop2:
move.l a3,(a2)+
move.b (a1)+,d2
move.w d2,(a2)+
clr.w (a2)+
move.w d2,(a2)+
addq.w #6,a2
add.w d2,a3
add.w d2,a3
dbf d1,initloop2

move.l SEQpoint(pc),a0
moveq #0,d2
move.b 12(a0),d2		;Get replay speed
bne.s speedok
move.b #3,d2			;Set default speed
speedok:
move.w d2,respcnt		;Init repspeed counter
move.w d2,repspd
INIT2:
clr.w audtemp
move.w #$000f,$dff096		;Disable audio DMA
move.w #$0780,$dff09a		;Disable audio IRQ
moveq #0,d7
mulu #13,d0
moveq #4-1,d6			;Number of soundchannels-1
lea V1data(pc),a0		;Point to 1st voice data area
lea silent(pc),a1
lea Chandata(pc),a2
initloop3:
move.l a1,10(a0)
move.l a1,18(a0)
clr.w 4(a0)
move.w #$000d,6(a0)
clr.w 8(a0)
clr.l 14(a0)
move.b #$01,23(a0)
move.b #$01,24(a0)
clr.b 25(a0)
clr.l 26(a0)
clr.w 30(a0)
clr.l 38(a0)
clr.w 42(a0)
clr.l 44(a0)
clr.l 48(a0)
clr.w 56(a0)
moveq #$00,d3
move.w (a2)+,d1
move.w (a2),d3
divu #$0003,d3
moveq #0,d4
bset d3,d4
move.w d4,32(a0)
move.w (a2)+,d3
andi.l #$00ff,d3
andi.l #$00ff,d1
lea $dff0a0,a6
add.w d1,a6
move.l #$0000,(a6)
move.w #$0100,4(a6)
move.w #$0000,6(a6)
move.w #$0000,8(a6)
move.l a6,60(a0)
move.l SEQpoint(pc),(a0)
move.l SEQpoint(pc),52(a0)
add.l d0,52(a0)
add.l d3,52(a0)
add.l d7,(a0)
add.l d3,(a0)
move.l (a0),a3
move.b (a3),d1
andi.l #$00ff,d1
lsl.w #6,d1
move.l PATpoint(pc),a4
adda.w d1,a4
move.l a4,34(a0)
move.b 1(a3),44(a0)
move.b 2(a3),22(a0)
lea $4a(a0),a0		;Point to next voice's data area
dbf d6,initloop3
rts


PLAY:
lea audtemp(pc),a5
tst.w 8(a5)
bne.s music_on
rts
music_on:
subq.w #1,4(a5)			;Decrease replayspeed counter
bne.s nonewnote
move.w 6(a5),4(a5)		;Restore replayspeed counter
moveq #0,d5
moveq #6,d6
lea V1data(pc),a0		;Point to voice1 data area
bsr.L new_note
lea V2data(pc),a0		;Point to voice2 data area
bsr.L new_note
lea V3data(pc),a0		;Point to voice3 data area
bsr.L new_note
lea V4data(pc),a0		;Point to voice4 data area
bsr.L new_note
nonewnote:
clr.w (a5)
lea $dff000,a6
lea V1data(pc),a0
bsr.L effects
move.l d0,$a6(a6)
lea V2data(pc),a0
bsr.L effects
move.l d0,$b6(a6)
lea V3data(pc),a0
bsr.L effects
move.l d0,$c6(a6)
lea V4data(pc),a0
bsr.L effects
move.l d0,$d6(a6)
lea V1data(pc),a0
move.l 68+[0*74](a0),a1		;Get samplepointer
adda.w 64+[0*74](a0),a1		;add repeat_start
move.l 68+[1*74](a0),a2
adda.w 64+[1*74](a0),a2
move.l 68+[2*74](a0),a3
adda.w 64+[2*74](a0),a3
move.l 68+[3*74](a0),a4
adda.w 64+[3*74](a0),a4
move.w 66+[0*74](a0),d1		;Get repeat_length
move.w 66+[1*74](a0),d2
move.w 66+[2*74](a0),d3
move.w 66+[3*74](a0),d4
moveq #2,d0
moveq #0,d5
move.w (a5),d7
ori.w #$8000,d7			;Set/clr bit = 1
move.w d7,$dff096		;Enable audio DMA
chan1:
lea V1data+72(pc),a0
move.w (a0),d7
beq.s chan2
subq.w #1,(a0)
cmp.w d0,d7
bne.s chan2
move.w d5,(a0)
move.l a1,$a0(a6)		;Set samplestart
move.w d1,$a4(a6)		;Set samplelength
chan2:
lea V2data+72(pc),a0
move.w (a0),d7
beq.s chan3
subq.w #1,(a0)
cmp.w d0,d7
bne.s chan3
move.w d5,(a0)
move.l a2,$b0(a6)
move.w d2,$b4(a6)
chan3:
lea V3data+72(pc),a0
move.w (a0),d7
beq.s chan4
subq.w #1,(a0)
cmp.w d0,d7
bne.s chan4
move.w d5,(a0)
move.l a3,$c0(a6)
move.w d3,$c4(a6)
chan4:
lea V4data+72(pc),a0
move.w (a0),d7
beq.s endplay
subq.w #1,(a0)
cmp.w d0,d7
bne.s endplay
move.w d5,(a0)
move.l a4,$d0(a6)
move.w d4,$d4(a6)
endplay:
rts

NEW_NOTE:
move.l 34(a0),a1
adda.w 40(a0),a1
cmp.b #$49,(a1)		;Check "END" mark in pattern
beq.s patend
cmp.w #64,40(a0)		;Have all the notes been played?
bne.S samepat
patend:
move.w d5,40(a0)
move.l (a0),a2
adda.w 6(a0),a2		;Point to next sequence row
cmpa.l 52(a0),a2	;Is it the end?
bne.s notend
move.w d5,6(a0)		;yes!
move.l (a0),a2		;Point to first sequence
notend:
lea spdtemp(pc),a3
moveq #1,d1
addq.b #1,(a3)
cmpi.b #5,(a3)
bne.s nonewspd
move.b d1,(a3)
move.b 12(a2),d1	;Get new replay speed
beq.s nonewspd
move.w d1,2(a3)		;store in counter
move.w d1,4(a3)
nonewspd:
move.b (a2)+,d1		;Pattern to play
move.b (a2)+,44(a0)	;Transpose value
move.b (a2)+,22(a0)	;Soundtranspose value
lsl.w d6,d1
move.l PATpoint(pc),a1	;Get pattern pointer
add.w d1,a1
move.l a1,34(a0)
addi.w #$000d,6(a0)
samepat:
move.b 1(a1),d1		;Get info byte
move.b (a1)+,d0		;Get note
bne.s ww1
andi.w #%11000000,d1
beq.s noport
bra.s ww11
ww1:
move.w d5,56(a0)
ww11:
move.b d5,47(a0)
btst #7,d1
beq.s noport
move.b 2(a1),47(a0)	
noport:
andi.w #$007f,d0
beq.S nextnote
move.b d0,8(a0)
move.b (a1),d1
move.b d1,9(a0)
move.w 32(a0),d3
or.w d3,(a5)
move.w d3,$dff096
andi.w #$003f,d1	;Max 64 instruments
add.b 22(a0),d1		;add Soundtranspose
move.l VOLpoint(pc),a2
lsl.w d6,d1
adda.w d1,a2
move.w d5,16(a0)
move.b (a2),23(a0)
move.b (a2)+,24(a0)
moveq #0,d1
move.b (a2)+,d1
move.b (a2)+,27(a0)
move.b #$40,46(a0)
move.b (a2),28(a0)
move.b (a2)+,29(a0)
move.b (a2)+,30(a0)
move.l a2,10(a0)
move.l FRQpoint(pc),a2
lsl.w d6,d1
adda.w d1,a2
move.l a2,18(a0)
move.w d5,50(a0)
move.b d5,25(a0)
move.b d5,26(a0)
nextnote:
addq.w #2,40(a0)
rts

EFFECTS:
moveq #0,d7
testsustain:
tst.b 26(a0)		;Is sustain counter = 0
beq.s sustzero
subq.b #1,26(a0)	;if no, decrease counter
bra.L VOLUfx
sustzero:		;Next part of effect sequence
move.l 18(a0),a1	;can be executed now.
adda.w 50(a0),a1
testeffects:
cmpi.b #$e1,(a1)	;E1 = end of FREQseq sequence
beq.L VOLUfx
move.b (a1),d0
cmpi.b #$e0,d0		;E0 = loop to other part of sequence
bne.s testnewsound
move.b 1(a1),d1		;loop to start of sequence + 1(a1)
andi.w #$003f,d1
move.w d1,50(a0)
move.l 18(a0),a1
adda.w d1,a1
move.b (a1),d0
testnewsound:
cmpi.b #$e2,d0		;E2 = set waveform
bne.s testE4
move.w 32(a0),d1
or.w d1,(a5)
move.w d1,$dff096
moveq #0,d0
move.b 1(a1),d0
lea SOUNDINFO(pc),a4
lsl.w #4,d0
adda.w d0,a4
move.l 60(a0),a3
move.l (a4)+,d1
move.l d1,(a3)
move.l d1,68(a0)
move.w (a4)+,4(a3)
move.l (a4),64(a0)
move.w #$0003,72(a0)
move.w d7,16(a0)
move.b #$01,23(a0)
addq.w #2,50(a0)
bra.L transpose
testE4:
cmpi.b #$e4,d0
bne.s testE9
moveq #0,d0
move.b 1(a1),d0
lea SOUNDINFO(pc),a4
lsl.w #4,d0
adda.w d0,a4
move.l 60(a0),a3
move.l (a4)+,d1
move.l d1,(a3)
move.l d1,68(a0)
move.w (a4)+,4(a3)
move.l (a4),64(a0)
move.w #$0003,72(a0)
addq.w #2,50(a0)
bra.L transpose
testE9:
cmpi.b #$e9,d0
bne .Stestpatjmp
move.w 32(a0),d1
or.w d1,(a5)
move.w d1,$dff096
moveq #0,d0
move.b 1(a1),d0
lea SOUNDINFO(pc),a4
lsl.w #4,d0
adda.w d0,a4
move.l (a4),a2
cmpi.l #"SSMP",(a2)+
bne.s nossmp
lea 320(a2),a4
moveq #0,d1
move.b 2(a1),d1
lsl.w #4,d1
add.w d1,a2
add.l (a2),a4
move.l 60(a0),a3
move.l a4,(a3)
move.l 4(a2),4(a3)
move.l a4,68(a0)
move.l 6(a2),64(a0)
move.w d7,16(a0)
move.b #1,23(a0)
move.w #3,72(a0)
nossmp:
addq.w #3,50(a0)
bra.s transpose
testpatjmp:
cmpi.b #$e7,d0
bne.s testpitchbend
moveq #0,d0
move.b 1(a1),d0
lsl.w d6,d0
move.l FRQpoint(pc),a1
adda.w d0,a1
move.l a1,18(a0)
move.w d7,50(a0)
bra.L testeffects
testpitchbend:
cmpi.b #$ea,d0
bne.s testnewsustain
move.b 1(a1),4(a0)
move.b 2(a1),5(a0)
addq.w #3,50(a0)
bra.s transpose
testnewsustain:
cmpi.b #$e8,d0
bne.s testnewvib
move.b 1(a1),26(a0)
addq.w #2,50(a0)
bra.L testsustain
testnewvib:
cmpi.b #$e3,(a1)+
bne.s transpose
addq.w #3,50(a0)
move.b (a1)+,27(a0)
move.b (a1),28(a0)
transpose:
move.l 18(a0),a1
adda.w 50(a0),a1
move.b (a1),43(a0)
addq.w #1,50(a0)

VOLUfx:
tst.b 25(a0)
beq.s volsustzero
subq.b #1,25(a0)
bra.L calcperiod
volsustzero:
tst.b 15(a0)
bne.s do_VOLbend
subq.b #1,23(a0)
bne.s calcperiod
move.b 24(a0),23(a0)
volu_cmd:
move.l 10(a0),a1
adda.w 16(a0),a1
move.b (a1),d0
testvoluend:
cmpi.b #$e1,d0
beq.s calcperiod
cmpi.b #$ea,d0
bne.s testVOLsustain
move.b 1(a1),14(a0)
move.b 2(a1),15(a0)
addq.w #3,16(a0)
bra.s do_VOLbend
testVOLsustain:
cmpi.b #$e8,d0
bne.s testVOLloop
addq.w #2,16(a0)
move.b 1(a1),25(a0)
bra.s calcperiod
testVOLloop:
cmpi.b #$e0,d0
bne.s setvolume
move.b 1(a1),d0
andi.w #$003f,d0
subq.b #5,d0
move.w d0,16(a0)
bra.s volu_cmd
do_VOLbend:
not.b 38(a0)
beq.s calcperiod
subq.b #1,15(a0)
move.b 14(a0),d1
add.b d1,45(a0)
bpl.s calcperiod
moveq #0,d1
move.b d1,15(a0)
move.b d1,45(a0)
bra.s calcperiod
setvolume:
move.b (a1),45(a0)
addq.w #1,16(a0)
calcperiod:
move.b 43(a0),d0
bmi.s lockednote
add.b 8(a0),d0
add.b 44(a0),d0
lockednote:
moveq #$7f,d1
and.l d1,d0
lea PERIODS(pc),a1
add.w d0,d0
move.w d0,d1
adda.w d0,a1
move.w (a1),d0

move.b 46(a0),d7
tst.b 30(a0)		;Vibrato_delay = zero ?
beq.s vibrator
subq.b #1,30(a0)
bra.s novibrato
vibrator:
moveq #5,d2
move.b d1,d5
move.b 28(a0),d4
add.b d4,d4
move.b 29(a0),d1
tst.b d7
bpl.s vib1
btst #0,d7
bne.s vib4
vib1:
btst d2,d7
bne.s vib2
sub.b 27(a0),d1
bcc.s vib3
bset d2,d7
moveq #0,d1
bra.s vib3
vib2:
add.b 27(a0),d1
cmp.b d4,d1
bcs.s vib3
bclr d2,d7
move.b d4,d1
vib3:
move.b d1,29(a0)
vib4:
lsr.b #1,d4
sub.b d4,d1
bcc.s vib5
subi.w #$0100,d1
vib5:
addi.b #$a0,d5
bcs.s vib7
vib6:
add.w d1,d1
addi.b #$18,d5
bcc.s vib6
vib7:
add.w d1,d0
novibrato:
eori.b #$01,d7
move.b d7,46(a0)

; DO THE PORTAMENTO THING
not.b 39(a0)
beq.s pitchbend
moveq #0,d1
move.b 47(a0),d1	;get portavalue
beq.s pitchbend		;0=no portamento
cmpi.b #$1f,d1
bls.s portaup
portadown: 
andi.w #$1f,d1
neg.w d1
portaup:
sub.w d1,56(a0)
pitchbend:
not.b 42(a0)
beq.s addporta
tst.b 5(a0)
beq.s addporta
subq.b #1,5(a0)
moveq #0,d1
move.b 4(a0),d1
bpl.s pitchup
ext.w d1
pitchup:
sub.w d1,56(a0)
addporta:
add.w 56(a0),d0
cmpi.w #$0070,d0
bhi.s nn1
move.w #$0071,d0
nn1:
cmpi.w #$0d60,d0
bls.s nn2
move.w #$0d60,d0
nn2:
swap d0
move.b 45(a0),d0
rts



V1data:  blk.b 64,0	;Voice 1 data area
offset1: blk.b 02,0	;Is added to start of sound
ssize1:  blk.b 02,0	;Length of sound
start1:  blk.b 06,0	;Start of sound

V2data:  blk.b 64,0	;Voice 2 data area
offset2: blk.b 02,0
ssize2:  blk.b 02,0
start2:  blk.b 06,0

V3data:  blk.b 64,0	;Voice 3 data area
offset3: blk.b 02,0
ssize3:  blk.b 02,0
start3:  blk.b 06,0

V4data:  blk.b 64,0	;Voice 4 data area
offset4: blk.b 02,0
ssize4:  blk.b 02,0
start4:  blk.b 06,0

audtemp: dc.w 0		;DMACON
spdtemp: dc.w 0
respcnt: dc.w 0		;Replay speed counter 
repspd:  dc.w 0		;Replay speed counter temp
onoff:   dc.w 0		;Music on/off flag.

Chandata: dc.l $00000000,$00100003,$00200006,$00300009
SEQpoint: dc.l 0
PATpoint: dc.l 0
FRQpoint: dc.l 0
VOLpoint: dc.l 0


SILENT: dc.w $0100,$0000,$0000,$00e1

PERIODS:dc.w $06b0,$0650,$05f4,$05a0,$054c,$0500,$04b8,$0474
	dc.w $0434,$03f8,$03c0,$038a,$0358,$0328,$02fa,$02d0
	dc.w $02a6,$0280,$025c,$023a,$021a,$01fc,$01e0,$01c5
	dc.w $01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d
	dc.w $010d,$00fe,$00f0,$00e2,$00d6,$00ca,$00be,$00b4
	dc.w $00aa,$00a0,$0097,$008f,$0087,$007f,$0078,$0071
	dc.w $0071,$0071,$0071,$0071,$0071,$0071,$0071,$0071
	dc.w $0071,$0071,$0071,$0071,$0d60,$0ca0,$0be8,$0b40
	dc.w $0a98,$0a00,$0970,$08e8,$0868,$07f0,$0780,$0714
	dc.w $1ac0,$1940,$17d0,$1680,$1530,$1400,$12e0,$11d0
	dc.w $10d0,$0fe0,$0f00,$0e28,$06b0,$0650,$05f4,$05a0
	dc.w $054c,$0500,$04b8,$0474,$0434,$03f8,$03c0,$038a
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a
	dc.w $021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d,$0168
	dc.w $0153,$0140,$012e,$011d,$010d,$00fe,$00f0,$00e2
	dc.w $00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f
	dc.w $0087,$007f,$0078,$0071

SOUNDINFO:
;Start.l , Length.w , Repeat start.w , Repeat-length.w , blk.b 6,0 

blk.b 10*16,0	;Reserved for samples
blk.b 80*16,0	;Reserved for waveforms
sortram:
	blk.b	64*400,0
module:
	blk.b	24864,0
