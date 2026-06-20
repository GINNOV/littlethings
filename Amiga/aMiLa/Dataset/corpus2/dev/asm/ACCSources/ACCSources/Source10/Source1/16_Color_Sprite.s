							;BY BLAINE EVANS
							;1 ERITH WAY
							;PONTYBODKIN
							;NR MOLD
							;CLWYD
							;CH7 4TR
							;TEL O352-771673

*THIS EXAMPLE SHOWS ALL 16 COLORS BETTER THAN THE BALLS EXAMPLE
*JUST CHANGE THE GRAPHICS FOR YOUR OWN 16 COLOR SPRITES

	opt	c-,d+

	move.l	4.w,a6			;FIND EXEC BASE
	lea	gfxlib(pc),a1		;LOAD GRAPHICS LIBRARY IN A1
	moveq	#$00,d0			;VERSION 0
	jsr	-552(a6)		;OPEN LIBRARY
	move.l	d0,_gfxbase		;STORE D0 (GFX ADDRESS )
	beq	nolib_exit		;ELSE EXIT
	bsr	Foreground_addresses	;BRANCH TO FOREGROUND ADDRESSES
	bsr	Sprite_addresses
	move.l	_gfxbase,a0		;LOAD ADDRESS OF GRAPHICS LIB IN A0
	move.l	50(a0),oldcop		;STORE CURRENT COPPER,ETC TO RETRIEVE LATER
S
	move.l	#newcop,50(a0)		;POINT TO OUR COPPERLIST

wait					;WAIT LOOP

	cmp.b	#255,$dff006		;VERTICAL BLANKING GAP 
	bne.s	wait			;
;	move.w	#$fff,$180(a6)		;REMOVE TO MEASURE RASTER TIME
	bsr	Sprite
;	move.w	#$000,$180(a6)		;REMOVE TO MEASURE RASTER TIME
	btst	#6,$bfe001		;QUIT LEFT MOUSE PRESSED
	bne.s	wait
ended					;ELSE LOOP TO WAIT
	move.l	_gfxbase,a0		;LOAD GRAPHICS LIB ADDRESS IN A0
	move.l	oldcop,50(a0)		;RESTORE OLD COPPER TO RETURN TO EDITTER
nomem_exit	
	move.l	4.w,a6			;FIND EXEC BASE
	move.l	_gfxbase,a1		;LOAD GRAPHICS BASE IN A1
	jsr	-414(a6)		;CLOSE LIBRARY
nolib_exit
	rts				;RETURN TO EDITER
Foreground_addresses				;START OF FOREGROUND DATA
	move.l	#Foreground,d0
	move.w	d0,Bpl0ptl		;LOW WORD IN BIT PLANE 0 LOW
	swap	d0				
	move.w	d0,Bpl0pth		;HIGH WORD IN BIT PLANE 0 HIGH
	rts
Sprite_addresses
	move.l	#Sprite0,d0		;SPRITE ADDRESS TO COPPERLIST
	move.w	d0,Spl0ptl
	swap	d0
	move.w	d0,Spl0pth
	swap	d0
	move.l	#Sprite1,d0
	move.w	d0,Spl1ptl
	swap	d0
	move.w	d0,Spl1pth
	swap	d0
	rts
Sprite					;MOVE ACROSS SCREEN
	lea	sprites,a0		;CONTROL WORDS
	move.l	#Sprite0,d0		;ADDRESS OF SPRITE 0
	move.w	d0,6(a0)		;WRITE TO COPPERLIST
	swap	d0
	move.w	d0,2(a0)
	swap	d0	
	move.l	#Sprite1,d0		;SAME FOR SPRITE 1
	lea	8(a0),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0	
	move.l	#Sprite0,a0		;A0=SPRITE0
	move.l	#Sprite1,a1		;A1=SPRITE1
	add.b	#1,1(a0)		;ADD #1 TO HORIZONTAL BYTE
	add.b	#1,1(a1)		;DITTO
	rts

gfxlib	dc.b	"graphics.library",0	
	even
_gfxbase	dc.l	0		;LONG WORD TO STORE GFX ADDRESS
oldcop		dc.l	0			;OLD COPPERLIST ADDRESS
	even
	SECTION		chipmemory,data_c	


newcop
	dc.w	$0100,%0001001000000000		;1 PLANE
	dc.w	$0102
scroll	dc.w	$0000			;	SCROLL VALUE
	dc.w	$0104,%0000000000000001		;PRIORITIES
	dc.w	$0108,$0000,$010a,$0000		;MODULAS
	dc.w	$0092,$0038,$0094,$00d0		;200*40 SCREEN
	dc.w	$008e,$3781,$0090,$ffc1		;VISIBLE AREA
						
planes
	dc.w	$00e0
Bpl0pth	dc.w	$0000
	dc.w	$00e2
Bpl0ptl	dc.w	$0000		
	dc.w	$00e4
Bpl1pth	dc.w	$0000
	dc.w	$00e6
Bpl1ptl	dc.w	$0000
	dc.w	$00e8
Bpl2pth	dc.w	$0000
	dc.w	$00ea
Bpl2ptl	dc.w	$0000
	dc.w	$00ec
Bpl3pth	dc.w	$0000
	dc.w	$00ee
Bpl3ptl	dc.w	$0000	
	dc.w	$00f0
Bpl4pth	dc.w	$0000
	dc.w	$00f2
Bpl4ptl	dc.w	$0000
	dc.w	$00f4
Bpl5pth	dc.w	$0000
	dc.w	$00f6
Bpl5ptl	dc.w	$0000

sprites						;SPRITES
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

	dc.w	$0180,$0000,$0182,$0fff		;COLORS PLAY 1
	dc.w	$0184,$0d00,$0186,$0f80
	dc.w	$0188,$0ff0,$018a,$00ff
	dc.w	$018c,$008f,$018e,$000f

	dc.w	$0190,$0000,$0192,$0283		;COLORS PLAY 2
	dc.w	$0194,$08f4,$0196,$0095
	dc.w	$0198,$0243,$019a,$00ff
	dc.w	$019c,$0ff0,$019e,$0fa0

	dc.w	$01a0,$0000,$01a2,$0fff		;SPRITE COLORS
	dc.w	$01a4,$0f00,$01a6,$0b00
	dc.w	$01a8,$0600,$01aa,$0F40
	dc.w	$01ac,$0F80,$01ae,$0Fa0
	dc.w	$01b0,$0Ff0,$01b2,$000f
	dc.w	$01b4,$004f,$01b6,$008f
	dc.w	$01b8,$00ff,$01ba,$00f0
	dc.w	$01bc,$0283,$01be,$0f0f

	dc.w	$ffff,$fffe			;END OF COPPERLIST

Foreground
		dcb.b	(200*40)*1,$00
*SPRITES 0 AND 1 ARE ATTACHED SO MUST FOLLOW SAME CO-ORDINATES
*SEE HARDWARE REF MANUAL FOR TECHNICAL DETAILS

Sprite0

	dc.w    $3090,$9800

	dc.w	$ffff,$0000,$8001,$7ffe,$8001,$7ffe,$8001,$7ffe
	dc.w	$8001,$7ffe,$8001,$7ffe,$8001,$7ffe,$ffff,$0000
	dc.w	$ffff,$7ffe,$ffff,$7ffe,$ffff,$7ffe,$ffff,$7ffe
	dc.w	$ffff,$7ffe,$ffff,$7ffe,$ffff,$0000,$8001,$0000
	dc.w	$8001,$0000,$8001,$0000,$8001,$0000,$8001,$0000
	dc.w	$8001,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$8001,$7ffe,$8001,$7ffe,$8001,$7ffe
	dc.w	$8001,$7ffe,$8001,$7ffe,$ffff,$0000,$ffff,$7ffe
	dc.w	$ffff,$7ffe,$ffff,$7ffe,$ffff,$7ffe,$ffff,$7ffe
	dc.w	$ffff,$7ffe,$ffff,$0000,$8001,$0000,$8001,$0000
	dc.w	$8001,$0000,$8001,$0000,$8001,$0000,$8001,$0000
	dc.w	$8001,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$8001,$7ffe,$8001,$7ffe,$8001,$7ffe
	dc.w	$8001,$7ffe,$8001,$7ffe,$8001,$7ffe,$ffff,$0000
	dc.w	$ffff,$7ffe,$ffff,$7ffe,$ffff,$7ffe,$ffff,$7ffe
	dc.w	$ffff,$7ffe,$ffff,$7ffe,$ffff,$0000,$8001,$0000
	dc.w	$8001,$0000,$8001,$0000,$8001,$0000,$8001,$0000
	dc.w	$8001,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$8001,$7ffe,$8001,$7ffe,$8001,$7ffe
	dc.w	$8001,$7ffe,$8001,$7ffe,$8001,$7ffe,$ffff,$0000
	dc.w	$ffff,$7ffe,$ffff,$7ffe,$ffff,$7ffe,$ffff,$7ffe
	dc.w	$ffff,$7ffe,$ffff,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$0000,$0000
Sprite1
	dc.w	$3090,$9880
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$7ffe,$0000
	dc.w	$7ffe,$0000,$7ffe,$0000,$7ffe,$0000,$7ffe,$0000
	dc.w	$7ffe,$0000,$0000,$0000,$7ffe,$0000,$7ffe,$0000
	dc.w	$7ffe,$0000,$7ffe,$0000,$7ffe,$0000,$7ffe,$0000
	dc.w	$0000,$0000,$7ffe,$0000,$7ffe,$0000,$7ffe,$0000
	dc.w	$7ffe,$0000,$7ffe,$0000,$0000,$0000,$7ffe,$0000
	dc.w	$7ffe,$0000,$7ffe,$0000,$7ffe,$0000,$7ffe,$0000
	dc.w	$7ffe,$0000,$0000,$0000,$0000,$7ffe,$0000,$7ffe
	dc.w	$0000,$7ffe,$0000,$7ffe,$0000,$7ffe,$0000,$7ffe
	dc.w	$0000,$7ffe,$0000,$0000,$0000,$7ffe,$0000,$7ffe
	dc.w	$0000,$7ffe,$0000,$7ffe,$0000,$7ffe,$0000,$7ffe
	dc.w	$0000,$0000,$0000,$7ffe,$0000,$7ffe,$0000,$7ffe
	dc.w	$0000,$7ffe,$0000,$7ffe,$0000,$7ffe,$0000,$0000
	dc.w	$0000,$7ffe,$0000,$7ffe,$0000,$7ffe,$0000,$7ffe
	dc.w	$0000,$7ffe,$0000,$7ffe,$0000,$0000,$7ffe,$7ffe
	dc.w	$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe
	dc.w	$7ffe,$7ffe,$0000,$0000,$7ffe,$7ffe,$7ffe,$7ffe
	dc.w	$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe
	dc.w	$0000,$0000,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe
	dc.w	$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$0000,$0000
	dc.w	$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe,$7ffe
	dc.w	$7ffe,$7ffe,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000



