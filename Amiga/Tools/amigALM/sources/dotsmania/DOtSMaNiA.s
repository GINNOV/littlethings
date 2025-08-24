	section dotmania,code

	movem.l	d0-a6,-(a7)
	move.l	4.w,a6
	jsr	-132(a6)
	lea	$dff000,a5
	move.w	$1c(a5),d0
	or.w	#$c000,d0
	move.w	d0,IntEna
	move.w	2(a5),d0
	or.w	#$8000,d0
	move.w	d0,DMACon
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	$6c.w,OldIRQ
	move.l	#NewIRQ,$6c.w
	move.w	#$c020,$9a(a5)
	move.w	#$fff,$182(a5)	
	move.w	#$bbb,$184(a5)	
	move.w	#$fff,$186(a5)	
	move.w	#$777,$188(a5)	
	move.w	#$fff,$18a(a5)	
	move.w	#$bbb,$18c(a5)	
	move.w	#$fff,$18e(a5)	
	move.w	#$ddd,$192(a5)	
	move.w	#$999,$194(a5)	
	move.w	#$ddd,$196(a5)	
	move.w	#$555,$198(a5)	
	move.w	#$ddd,$19a(a5)	
	move.w	#$999,$19c(a5)	
	move.w	#$ddd,$19e(a5)	
	move.w	#$7fff,$96(a5)
	move	#%10000000000,$96(a5)
	move.l  #CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$87c0,$96(a5)
MousChk	btst	#6,$bfe001
	bne.b	MousChk
	lea	$dff000,a5
	move.w	#$0020,$9a(a5)
	move.w	#$0020,$9c(a5)
	move.l	OldIRQ(pc),$6c.w
	move.w	IntEna(pc),$9a(a5)
	move.l	4.w,a6
	move.l	$9c(a6),a1
	move.w	#$0080,$96(a5)
	move.l	38(a1),$80(a5)
	move.w	#$0000,$88(a5)
	move.w	DMACon(pc),$96(a5)
	jsr	-138(a6)
	moveq	#0,d0
	movem.l	(a7)+,d0-a6
	rts

;--------------------------------------;
	
Mousepause
	move.l	realscrn2,a0	;Reset Screen pointers while paused
	move.l	realscrn3,a1
	move.l	realscrn4,a2
	move.l	realscrn5,a3
	move.l	realscrn6,a4
	move.l	blitscrn,a6
	move.l	a0,$e0(a5)
	move.l	a1,$e4(a5)
	move.l	a2,$e8(a5)
	move.l	a3,$ec(a5)
	move.l	a4,$f0(a5)
	move.l	a6,$f4(a5)
	bra.w	endirq

NewIRQ	
	move.l	a7,storea7
	btst	#10,$16(a5)
	beq.b	mousepause
	tst	pausecount
	bne	pause

	move	#$0,$180(a5)
	move.l	logscrn,a0	;swap screen buffers around
	move.l	realscrn,a1
	move.l	realscrn2,a2
	move.l	realscrn3,a3
	move.l	realscrn4,a4
	move.l	realscrn5,a6
	move.l	realscrn6,a7
	move.l	a1,$e0(a5)
	move.l	a2,$e4(a5)
	move.l	a3,$e8(a5)
	move.l	a4,$ec(a5)
	move.l	a6,$f0(a5)
	move.l	a7,$f4(a5)
	move.l	a0,realscrn
	move.l	a1,realscrn2
	move.l	a2,realscrn3
	move.l	a3,realscrn4
	move.l	a4,realscrn5
	move.l	a6,realscrn6

	move.l	blitscrn,a0
	move.l	a7,blitscrn
	move.l	a0,logscrn
	
	move.l	a0,$54(a5)
	move.l	#$1000000,$40(a5)
	move.w	#211*64+20,$58(a5)

	move.l	script,a0
	move.l	(a0),a0
	jmp	(a0)

endirq
	move.l	storea7,a7	
	move.w	#$0020,$9c(a5)
	move	#$4,$180(a5)
	rte

pause
	move.l	realscrn2,a0	;Reset Screen pointers while paused
	move.l	realscrn3,a1
	move.l	realscrn4,a2
	move.l	realscrn5,a3
	move.l	realscrn6,a4
	move.l	blitscrn,a6
	move.l	a0,$e0(a5)
	move.l	a1,$e4(a5)
	move.l	a2,$e8(a5)
	move.l	a3,$ec(a5)
	move.l	a4,$f0(a5)
	move.l	a6,$f4(a5)

	cmp	#1,pausecount
	blt pskip1
	move.l	a0,$f4(a5)
pskip1
	cmp	#2,pausecount
	blt pskip2
	move.l	a0,$f0(a5)
pskip2
	cmp	#3,pausecount
	blt pskip3
	move.l	a0,$ec(a5)
pskip3
	cmp	#4,pausecount
	blt pskip4
	move.l	a0,$e8(a5)
pskip4
	cmp	#5,pausecount
	blt pskip5
	move.l	a0,$e4(a5)
pskip5

	addq	#1,pausecount
	cmp	#100,pausecount
	blt	endirq			;comment only for testing!
	clr	pausecount
	addq.l	#4,script
	bra.w	endirq

Stars
	move.l	realscrn,a0
	add.l	#110*40+20,a0
	lea	sphere,a1
	lea	multiply,a6

	move	count,d7
;	move	#488,d7	
	
	move	#160*8,d4
	move	#-160*8,d5
sloop
	move	(a1),d0
	move	2(a1),d1
	move	d0,d2
	move	d1,d3
	lsl	#4,d0
	lsl	#4,d1
	add	d2,d0
	add	d3,d1	
	asr	#4,d0
	asr	#4,d1

	cmp	d5,d0
	bge.s	sok1
	add	d4,d0
	bra.s	sok2
sok1
	cmp	d4,d0
	blt.s	sok2
	add	d5,d0
sok2
	cmp	d5,d1
	bge.s	sok3
	add	d4,d1
	bra.s	sok4
sok3
	cmp	d4,d1
	blt.s	sok4
	add	d5,d1
sok4
	move	d0,(a1)+
	move	d1,(a1)+
	asr	#3,d0
	asr	#3,d1
	add	d1,d1
	move	(a6,d1),d1
	move	d0,d2
	asr	#3,d0	
	not	d2
	add	d0,d1
	bset	d2,(a0,d1)
	not	d2
	neg	d1
	bset	d2,(a0,d1)
	dbra	d7,Sloop

	move	direction,d0
	add	d0,count
	tst	count
	ble.s	send
	cmp	#486,count
	ble	endirq
	clr	direction
	addq	#1,count2
	cmp	#50,count2
	blt	endirq
	move	#-1,direction
	bra	endirq
send
	addq.l	#4,script
	bra	endirq
	
explode
	move.l	realscrn,a0
	move.l	dlist,a1
	move.l	4(a1),a2
	move.l	(a1),a1
	move	#550,d7
	lea	multiply,a3
	move	count,d6	;use for speed, dont change d6!	

eloop	
	move	(a1)+,d0
	move	(a1)+,d1
	move	(a2)+,d2
	move	(a2)+,d3
	sub	d0,d2		;dx
	sub	d1,d3		;dy
	mulu	d6,d2		;multiply by count		
	mulu	d6,d3		;multiply by count	
	asr	#6,d2
	asr	#6,d3
	add	d0,d2		;newx
	add	d1,d3		;newy
	add	d3,d3		;multiply y by 40
	move	(a3,d3),d3
	move	d2,d4
	lsr	#3,d2
	not	d4
	add	d2,d3
	bset	d4,(a0,d3)
	dbra	d7,eloop
	addq	#1,count
	cmp	#64,count
	ble	endirq
eend	addq.l	#4,script
	addq.l	#4,dlist
	clr	count
	bra	endirq

FaceRotate
	move.l	realscrn,a0
	add.l	#110*40+20,a0
	lea 	sinus,a1
	move	offset,d0
	lea	(a1,d0),a4
	lea	multiply,a3
	lea	face,a2

;	move	offset,d7
	move	count2,d7
;	move	#195,d7
	move	ry,d5			;get angle to rotate
	move	rz,d1			;get angle to rotate
frotz
	move	(a4,d1.w),d0		;get cos value
	move	(a2)+,d4			;get x value
	muls	d0,d4	

	move	(a1,d1.w),d0		;get sin value
	move	(a2)+,d3		;get y value
	muls	d0,d3

	sub.l	d3,d4			;d4-> x cos(ø)-y sin(ø)	

	swap	d4
	add	d4,d4

froty	move	(a2)+,d3		;get z value
	move	d4,d2			;make a copy of x and z
	move	d3,d6	
	
	move	(a1,d5.w),d0		;get sin value
	muls	d0,d2
	muls	d0,d3

	move	(a4,d5.w),d0		;get cos value
	muls	d0,d4	
	muls	d0,d6

	sub.l	d3,d4			;d4-> x cos(ø)-y sin(ø)	
	add.l	d2,d6			;d5-> y cos(ø)+x sin(ø)
	swap	d4
	swap	d6

	add	d6,d6
	move	(a3,d6.w),d6	;Multiply y by 40

	move.w	d4,d3
	not.w	d3		;extract bit #

	asr.w	#3,d4		;get address in bytes
	add.w	d6,d4		;add x to y

	bset.b	d3,0(a0,d4.w)	;set the bit	
	bset.b	d3,20(a0,d4.w)	;set the bit	
	bset.b	d3,10(a0,d4.w)	;set the bit	
	bset.b	d3,30(a0,d4.w)	;set the bit	
	not	d3
	neg	d4
	bset.b	d3,0(a0,d4.w)	;set the bit	
	bset.b	d3,20(a0,d4.w)	;set the bit	
	bset.b	d3,10(a0,d4.w)	;set the bit	
	bset.b	d3,30(a0,d4.w)	;set the bit	
	dbra	d7,frotz	
	move	dz,d0		;change angles of rotation
	add	d0,rz	
	cmp	#720,rz
	blt.b	fyo
	clr	rz
fyo
	move	dy,d0
	add	d0,ry	
	cmp	#720,ry
	blt.b	fyo2
	clr	ry
fyo2
	addq	#2,count	
	cmp	#16,count
	blt.b	fyo4
	clr	count
	move	doffset,d0
	add	d0,offset	
	cmp	#180,offset
	blt.b	fyo3.5
	neg	doffset
fyo3.5
	cmp	#2,offset
	bgt.b	fyo4
	neg	doffset
fyo4

	move	direction,d0
	add	d0,count2
	tst	count2
	ble.s	fend
	cmp	#175,count2
	ble	endirq
	clr	direction
	addq	#1,count3
	cmp	#250,count3
	blt	endirq
	move	#-1,direction
	bra	endirq
fend
	addq.l	#4,script
	bra	endirq

sphererotate
	move.l	realscrn,a0
	add.l	#110*40+20,a0
	lea 	sinus,a1
	move	offset,d0
	lea	(a1,d0),a4
	lea	multiply,a3
	lea	sphere,a2

;	move	offset,d7
	move	count2,d7
;	move	#195,d7
	move	ry,d5			;get angle to rotate
	move	rz,d1			;get angle to rotate
sprotz
	move	(a4,d1.w),d0		;get cos value
	move	(a2)+,d4			;get x value
	muls	d0,d4	

	move	(a1,d1.w),d0		;get sin value
	move	(a2)+,d3		;get y value
	muls	d0,d3

	sub.l	d3,d4			;d4-> x cos(ø)-y sin(ø)	

	swap	d4
	add	d4,d4

sproty	move	(a2)+,d3		;get z value
	move	d4,d2			;make a copy of x and z
	move	d3,d6	
	
	move	(a1,d5.w),d0		;get sin value
	muls	d0,d2
	muls	d0,d3

	move	(a4,d5.w),d0		;get cos value
	muls	d0,d4	
	muls	d0,d6

	sub.l	d3,d4			;d4-> x cos(ø)-y sin(ø)	
	add.l	d2,d6			;d5-> y cos(ø)+x sin(ø)
	swap	d4
	swap	d6

	add	d6,d6
	move	(a3,d6.w),d6	;Multiply y by 40

	move.w	d4,d3
	not.w	d3		;extract bit #

	asr.w	#3,d4		;get address in bytes
	add.w	d6,d4		;add x to y

	bset.b	d3,0(a0,d4.w)	;set the bit	

	bset.b	d3,40(a0,d4.w)	;set the bit	
;	bset.b	d3,10(a0,d4.w)	;set the bit	
;	bset.b	d3,30(a0,d4.w)	;set the bit	
	not	d3
	neg	d4
	bset.b	d3,0(a0,d4.w)	;set the bit	
	bset.b	d3,40(a0,d4.w)	;set the bit	
;	bset.b	d3,10(a0,d4.w)	;set the bit	
;	bset.b	d3,30(a0,d4.w)	;set the bit	
	dbra	d7,sprotz	
	move	dz,d0		;change angles of rotation
	add	d0,rz	
	cmp	#720,rz
	blt.b	spyo
	clr	rz
spyo
	move	dy,d0
	add	d0,ry	
	cmp	#720,ry
	blt.b	spyo2
	clr	ry
spyo2
	addq	#2,count	
	cmp	#16,count
	blt.b	spyo4
	clr	count
	move	doffset,d0
	add	d0,offset	
	cmp	#180,offset
	blt.w	spyo3.5
	neg	doffset
spyo3.5
	cmp	#2,offset
	bgt.b	spyo4
	neg	doffset
spyo4

	move	direction,d0
	add	d0,count2
	tst	count2
	ble.s	spend
	cmp	#200,count2
	ble	endirq
	clr	direction
	addq	#1,count3
	cmp	#350,count3
	blt	endirq
	move	#-1,direction
	bra	endirq
spend
	addq.l	#4,script
	bra	endirq
	
reset
	clr	count
	clr	count2
	clr	count3
	clr	ry
	clr	rx
	clr	rz
	move	#1,direction
	move	#2,doffset
	move	#40,offset
	clr	ecount
	addq.l	#4,script
	bra	endirq
	
restart	lea	list,a0
	move.l	a0,script
	lea	Dots,a0
	move.l	a0,dlist
	bra	endirq


wave	
	cmp	#400,count
	bgt	wavereset	
		
	add	#1,count

	move.l	realscrn,a0

	lea	explcord,a1
	lea	expldir,a2
	lea	multiply,a3	

;	move	count,d7

	move	#500,d7
wloop
	move.l	(a1),d0
	move.l	4(a1),d1

	move.l	(a2)+,d2		
	add.l	d2,d0
	move.l	(a2),d2		
	add.l	d2,d1

;	add.l	#2^8,d2	;gravity

	move.l	d2,(a2)+

	move.l	d0,(a1)+
	move.l	d1,(a1)+

	swap	d0
	swap	d1
	tst	d1
	blt	waveloopend
	tst	d0
	blt	waveloopend
	cmp	#319,d0
	bgt	waveloopend
	cmp	#220,d1
	bgt	waveloopend

	move	d0,d2
	lsr	#3,d2

	add	d1,d1
	move	(a3,d1.w),d1	;d1 * 40

	add	d2,d1
	not	d0
	bset	d0,(a0,d1.w)
	
waveloopend	
	dbra	d7,wloop

waveend	bra	endirq
wavereset
	move	#1023,d7
	lea	explcord,a0
	lea	expldir,a1
	lea	expl,a2
wavewipe
	move.l	#160<<16,(a0)+
	move.l	#110<<16,(a0)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+

	dbra	d7,wavewipe
	clr	count

	bra	waveend









;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0

;--------------------------------------;

storea7		dc.l	0

blitscrn	dc.l	newblit
logscrn 	dc.l	newscrn
realscrn 	dc.l	newscrn2	
realscrn2 	dc.l	newscrn3	
realscrn3 	dc.l	newscrn4
realscrn4 	dc.l	newscrn5	
realscrn5 	dc.l	newscrn6	
realscrn6 	dc.l	newscrn7

direction	dc.w	1
count	dc.w	0
count2	dc.w	0
count3	dc.w	0
offset	dc.w	30
doffset	dc.w	2
ecount  dc.w	0
rx	dc.w	0
ry	dc.w	0
rz	dc.w	0
dx	dc.w	0
dy	dc.w	4
dz	dc.w	6

sinus
	DC.W	$0000,$023B,$0477,$06B2,$08ED,$0B27,$0D61,$0F99,$11D0,$1405
	DC.W	$1639,$186C,$1A9C,$1CCA,$1EF7,$2120,$2347,$256C,$278D,$29AB
	DC.W	$2BC6,$2DDE,$2FF2,$3203,$340F,$3617,$381C,$3A1B,$3C17,$3E0D
	DC.W	$3FFF,$41EC,$43D3,$45B6,$4793,$496A,$4B3B,$4D07,$4ECD,$508C
	DC.W	$5246,$53F9,$55A5,$574B,$58E9,$5A81,$5C12,$5D9C,$5F1E,$6099
	DC.W	$620C,$6378,$64DC,$6638,$678D,$68D9,$6A1D,$6B58,$6C8C,$6DB6
	DC.W	$6ED9,$6FF2,$7103,$720B,$730A,$7400,$74EE,$75D2,$76AD,$777E
	DC.W	$7846,$7905,$79BB,$7A67,$7B09,$7BA2,$7C31,$7CB7,$7D32,$7DA4
	DC.W	$7E0D,$7E6B,$7EC0,$7F0A,$7F4B,$7F82,$7FAF,$7FD2,$7FEB,$7FFA
	DC.W	$7FFF,$7FFA,$7FEB,$7FD2,$7FAF,$7F82,$7F4B,$7F0A,$7EC0,$7E6B
	DC.W	$7E0D,$7DA4,$7D32,$7CB7,$7C31,$7BA2,$7B09,$7A67,$79BB,$7905
	DC.W	$7846,$777E,$76AD,$75D2,$74EE,$7400,$730A,$720B,$7103,$6FF2
	DC.W	$6ED9,$6DB6,$6C8B,$6B58,$6A1D,$68D9,$678D,$6638,$64DC,$6378
	DC.W	$620C,$6099,$5F1E,$5D9C,$5C12,$5A81,$58E9,$574B,$55A5,$53F9
	DC.W	$5246,$508C,$4ECD,$4D07,$4B3B,$496A,$4793,$45B6,$43D3,$41EC
	DC.W	$3FFF,$3E0D,$3C17,$3A1B,$381C,$3618,$340F,$3203,$2FF2,$2DDE
	DC.W	$2BC7,$29AB,$278D,$256C,$2347,$2120,$1EF7,$1CCB,$1A9C,$186C
	DC.W	$163A,$1406,$11D0,$0F99,$0D61,$0B27,$08ED,$06B3,$0477,$023C
	DC.W	$0000,$FDC5,$FB89,$F94E,$F713,$F4D9,$F2A0,$F067,$EE30,$EBFB
	DC.W	$E9C7,$E794,$E564,$E336,$E10A,$DEE0,$DCB9,$DA95,$D873,$D655
	DC.W	$D43A,$D222,$D00E,$CDFE,$CBF1,$C9E9,$C7E5,$C5E5,$C3EA,$C1F3
	DC.W	$C001,$BE14,$BC2D,$BA4B,$B86E,$B696,$B4C5,$B2F9,$B133,$AF74
	DC.W	$ADBB,$AC08,$AA5B,$A8B6,$A717,$A57F,$A3EE,$A264,$A0E2,$9F67
	DC.W	$9DF4,$9C88,$9B24,$99C8,$9874,$9728,$95E4,$94A8,$9375,$924A
	DC.W	$9128,$900E,$8EFD,$8DF5,$8CF6,$8C00,$8B13,$8A2E,$8954,$8882
	DC.W	$87BA,$86FB,$8645,$8599,$84F7,$845E,$83CF,$8349,$82CE,$825C
	DC.W	$81F3,$8195,$8140,$80F6,$80B5,$807E,$8051,$802E,$8015,$8006
	DC.W	$8001,$8006,$8015,$802E,$8051,$807E,$80B5,$80F6,$8140,$8195
	DC.W	$81F3,$825B,$82CD,$8349,$83CF,$845E,$84F7,$8599,$8645,$86FB
	DC.W	$87B9,$8882,$8953,$8A2E,$8B12,$8BFF,$8CF5,$8DF5,$8EFD,$900E
	DC.W	$9127,$9249,$9374,$94A7,$95E3,$9727,$9873,$99C7,$9B23,$9C87
	DC.W	$9DF3,$9F67,$A0E1,$A264,$A3ED,$A57E,$A716,$A8B5,$AA5B,$AC07
	DC.W	$ADBA,$AF73,$B133,$B2F8,$B4C4,$B696,$B86D,$BA4A,$BC2C,$BE14
	DC.W	$C000,$C1F2,$C3E9,$C5E4,$C7E4,$C9E8,$CBF0,$CDFD,$D00D,$D221
	DC.W	$D439,$D654,$D872,$DA94,$DCB8,$DEDF,$E109,$E335,$E563,$E794
	DC.W	$E9C6,$EBFA,$EE30,$F066,$F29F,$F4D8,$F712,$F94D,$FB88,$FDC4
	DC.W	$0000,$023B,$0476,$06B2,$08EC,$0B27,$0D60,$0F98,$11CF,$1405
	DC.W	$1639,$186B,$1A9B,$1CCA,$1EF6,$211F,$2347,$256B,$278C,$29AB
	DC.W	$2BC6,$2DDD,$2FF1,$3202,$340E,$3617,$381B,$3A1B,$3C16,$3E0D
	DC.W	$3FFE,$41EB,$43D3,$45B5,$4792,$4969,$4B3B,$4D06,$4ECC,$508C
	DC.W	$5245,$53F8,$55A4,$574A,$58E9,$5A81,$5C11,$5D9B,$5F1E,$6098
	DC.W	$620C,$6378,$64DC,$6638,$678C,$68D8,$6A1C,$6B58,$6C8B,$6DB6
	DC.W	$6ED8,$6FF2,$7103,$720B,$730A,$7400,$74ED,$75D1,$76AC,$777E
	DC.W	$7846,$7905,$79BA,$7A66,$7B09,$7BA2,$7C31,$7CB6,$7D32,$7DA4
	DC.W	$7E0D,$7E6B,$7EBF,$7F0A,$7F4B,$7F82,$7FAF,$7FD2,$7FEB,$7FF9
	DC.W	$7FFF,$7FFA,$7FEB,$7FD2,$7FAF,$7F82,$7F4B,$7F0A,$7EC0,$7E6B
	DC.W	$7E0D,$7DA5,$7D33,$7CB7,$7C31,$7BA2,$7B09,$7A67,$79BB,$7906
	DC.W	$7847,$777F,$76AD,$75D2,$74EE,$7401,$730B,$720C,$7104,$6FF3
	DC.W	$6ED9,$6DB7,$6C8C,$6B59,$6A1D,$68D9,$678D,$6639,$64DD,$6379
	DC.W	$620D,$609A,$5F1F,$5D9D,$5C13,$5A82,$58EA,$574B,$55A6,$53F9
	DC.W	$5247,$508D,$4ECE,$4D08,$4B3C,$496B,$4794,$45B7,$43D4,$41ED
	DC.W	$4000,$3E0E,$3C18,$3A1D,$381D,$3619,$3410,$3204,$2FF3,$2DDF
	DC.W	$2BC8,$29AD,$278E,$256D,$2349,$2121,$1EF8,$1CCC,$1A9D,$186D
	DC.W	$163B,$1407,$11D1,$0F9A,$0D62,$0B29,$08EF,$06B4,$0478,$023D
	DC.W	$0001,$FDC6,$FB8A,$F94F,$F714,$F4DA,$F2A1,$F069,$EE32,$EBFC
	DC.W	$E9C8,$E796,$E565,$E337,$E10B,$DEE1,$DCBA,$DA96,$D874,$D656
	DC.W	$D43B,$D223,$D00F,$CDFF,$CBF2,$C9EA,$C7E6,$C5E6,$C3EB,$C1F4
	DC.W	$C002,$BE15,$BC2E,$BA4C,$B86F,$B697,$B4C6,$B2FA,$B134,$AF75
	DC.W	$ADBB,$AC09,$AA5C,$A8B7,$A718,$A580,$A3EF,$A265,$A0E3,$9F68
	DC.W	$9DF4,$9C89,$9B25,$99C9,$9874,$9728,$95E4,$94A9,$9375,$924A
	DC.W	$9128,$900F,$8EFE,$8DF6,$8CF6,$8C00,$8B13,$8A2F,$8954,$8882
	DC.W	$87BA,$86FB,$8646,$859A,$84F7,$845E,$83CF,$834A,$82CE,$825C
	DC.W	$81F4,$8195,$8141,$80F6,$80B5,$807E,$8051,$802E,$8016,$8007
	DC.W	$8001,$8006,$8015,$802E,$8051,$807E,$80B5,$80F6,$8140,$8195
	DC.W	$81F3,$825B,$82CD,$8349,$83CE,$845E,$84F6,$8599,$8645,$86FA
	DC.W	$87B9,$8881,$8953,$8A2E,$8B12,$8BFF,$8CF5,$8DF4,$8EFC,$900D
	DC.W	$9127,$9249,$9374,$94A7,$95E2,$9726,$9872,$99C7,$9B23,$9C87
	DC.W	$9DF2,$9F66,$A0E1,$A263,$A3ED,$A57D,$A715,$A8B4,$AA5A,$AC06
	DC.W	$ADB9,$AF72,$B132,$B2F7,$B4C3,$B695,$B86C,$BA49,$BC2B,$BE13
	DC.W	$BFFF,$C1F1,$C3E8,$C5E3,$C7E3,$C9E7,$CBEF,$CDFC,$D00C,$D220
	DC.W	$D438,$D653,$D871,$DA93,$DCB7,$DEDE,$E108,$E334,$E562,$E792
	DC.W	$E9C5,$EBF9,$EE2E,$F065,$F29E,$F4D7,$F711,$F94C,$FB87,$FDC3
	DC.W	$0000,$023B,$0477,$06B2,$08ED,$0B27,$0D61,$0F99,$11D0,$1405
	DC.W	$1639,$186C,$1A9C,$1CCA,$1EF7,$2120,$2347,$256C,$278D,$29AB
	DC.W	$2BC6,$2DDE,$2FF2,$3203,$340F,$3617,$381C,$3A1B,$3C17,$3E0D
	DC.W	$3FFF,$41EC,$43D3,$45B6,$4793,$496A,$4B3B,$4D07,$4ECD,$508C
	DC.W	$5246,$53F9,$55A5,$574B,$58E9,$5A81,$5C12,$5D9C,$5F1E,$6099
	DC.W	$620C,$6378,$64DC,$6638,$678D,$68D9,$6A1D,$6B58,$6C8C,$6DB6
	DC.W	$6ED9,$6FF2,$7103,$720B,$730A,$7400,$74EE,$75D2,$76AD,$777E
	DC.W	$7846,$7905,$79BB,$7A67,$7B09,$7BA2,$7C31,$7CB7,$7D32,$7DA4
	DC.W	$7E0D,$7E6B,$7EC0,$7F0A,$7F4B,$7F82,$7FAF,$7FD2,$7FEB,$7FFA
	DC.W	$7FFF,$7FFA,$7FEB,$7FD2,$7FAF,$7F82,$7F4B,$7F0A,$7EC0,$7E6B
	DC.W	$7E0D,$7DA4,$7D32,$7CB7,$7C31,$7BA2,$7B09,$7A67,$79BB,$7905
	DC.W	$7846,$777E,$76AD,$75D2,$74EE,$7400,$730A,$720B,$7103,$6FF2
	DC.W	$6ED9,$6DB6,$6C8B,$6B58,$6A1D,$68D9,$678D,$6638,$64DC,$6378
	DC.W	$620C,$6099,$5F1E,$5D9C,$5C12,$5A81,$58E9,$574B,$55A5,$53F9
	DC.W	$5246,$508C,$4ECD,$4D07,$4B3B,$496A,$4793,$45B6,$43D3,$41EC
	DC.W	$3FFF,$3E0D,$3C17,$3A1B,$381C,$3618,$340F,$3203,$2FF2,$2DDE
	DC.W	$2BC7,$29AB,$278D,$256C,$2347,$2120,$1EF7,$1CCB,$1A9C,$186C
	DC.W	$163A,$1406,$11D0,$0F99,$0D61,$0B27,$08ED,$06B3,$0477,$023C


pausecount	dc.w	0

script	dc.l	list
list
	dc.l	wave
;	dc.l	explode
;	dc.l	pause
;	dc.l 	explode
;	dc.l	explode
;	dc.l	pause
;	dc.l	explode
;	dc.l	pause
	dc.l	explode
	dc.l	reset
	dc.l	sphererotate
	dc.l	reset
	dc.l	stars
	dc.l	reset
	dc.l	facerotate
	dc.l	restart

Dlist	dc.l	Dots
Dots	dc.l	blank
	dc.l	dotsmania
	dc.l	Random
	dc.l	codedby
	dc.l	phaedrus
	dc.l	blank

blank	dcb.l	700,160<<16+128
dotsmania	incbin	"DH2:DotsMania/dotmania.dots"
codedby		incbin	"DH2:DotsMania/codedby.dots"
phaedrus	incbin	"DH2:DotsMania/phaedrus"
Random		incbin	"DH2:DotsMania/randomborder"


expl		incbin	"DH2:DotsMania/explosionrandom"	
expldir		incbin	"DH2:DotsMania/explosionrandom"	
explcord	
		rept	1024
		dc.l	160<<16,100<<16
		endr

face
	dc.w	50
	incbin	"DH2:DotsMania/face.dots"
sphere
	incbin	"DH2:DotsMania/dotsdata.tst"


l set -200
	rept 200 
	dc.w	l*40
l set l+1 
	endr
multiply
	rept 400
	dc.w	l*40
l set l+1
	endr

	section	f,data_c

CList	dc.w	$008e,$2c81,$0090,$30c1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0104,$0000,$0096,$0020
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$2c31,$fffe,$0100,$6400,$180,$90f
	dc.w	$2ce1,$fffe,$180,$0

	dc.w	$ff31,$fffe,$0100,$0000,$180,$90f,$ffe1,$fffe,$180,$000

	dc.w	$ffff,$fffe

		dcb.b	256*40
newblit		dcb.b	256*40,0
newscrn		dcb.b	256*40,0
newscrn2	dcb.b	256*40,0
newscrn3	dcb.b	256*40,0
newscrn4	dcb.b	256*40,0
newscrn5	dcb.b	256*40,0
newscrn6	dcb.b	256*40,0
newscrn7	dcb.b	256*40,0
