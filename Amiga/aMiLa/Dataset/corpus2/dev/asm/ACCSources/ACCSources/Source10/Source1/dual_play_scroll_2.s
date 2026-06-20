							;BY BLAINE EVANS
							;1 ERITH WAY
							;PONTYBODKIN
							;NR MOLD
							;CLWYD
							;CH7 4TR
							;TEL O352-771673
;200*80 6 PLANE DUAL PLAYFIELD 1 PIXEL SCROLLER
;FOREGROUND AND BACKGROUND WILL SCROLL INDEPENDANTLY OF EACH OTHER
;TRY IT.TAKE OUT ON OF THE ROUTINES
	opt	c-,d+

	move.l	4.w,a6			;FIND EXEC BASE
	lea	gfxlib(pc),a1		;LOAD GRAPHICS LIBRARY IN A1
	moveq	#$00,d0			;VERSION 0
	jsr	-552(a6)		;OPEN LIBRARY
	move.l	d0,_gfxbase		;STORE D0 (GFX ADDRESS )
	beq	nolib_exit		;ELSE EXIT
	bsr	Foreground_addresses	;BRANCH TO FOREGROUND ADDRESSES
	bsr	clear_screen		;CLEAR SCREEN
	bsr	Background_addresses	;BRAMCH TO BACKGROUND ADDRESSES
	bsr	initalise
	move.l	_gfxbase,a0		;LOAD ADDRESS OF GRAPHICS LIB IN A0
	move.l	50(a0),oldcop		;STORE CURRENT COPPER,ETC TO RETRIEVE LATER
S
	move.l	#newcop,50(a0)		;POINT TO OUR COPPERLIST

wait					;WAIT LOOP

	cmp.b	#255,$dff006		;VERTICAL BLANKING GAP 
	bne.s	wait			;
;	move.w	#$fff,$180(a6)		;REMOVE TO MEASURE RASTER TIME
	bsr	scroll_Foreground
	bsr	delay			;
	bsr	scroll_Background
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
	swap	d0
	add.l	#200*80,d0		;ADD SCREEN SIZE TO START ADDRESS
	move.w	d0,Bpl2ptl		;BIT PLANE 2 LOW
	swap	d0
	move.w	d0,Bpl2pth		;BIT PLANE 2 HIGH
	swap	d0	
	add.l	#200*80,d0		;ADD SCREEN SIZE TO FIND BIT PLANE 4 START
	move.w	d0,Bpl4ptl		;BIT PLANE 4 LOW
	swap	d0
	move.w	d0,Bpl4pth		;BIT PLANE 4 HIGH
	swap	d0	 
	rts

Background_addresses			;BACKGROUND 
	move.l	#Background,d0		;START OF BACKGROUND DATA
	move.w	d0,Bpl1ptl		;BIT PLANE 1 LOW
	swap	d0
	move.w	d0,Bpl1pth		;BIT PLANE 1 HIGH
	swap	d0
	add.l	#200*80,d0		;SCREEN SIZE TO D0
	move.w	d0,Bpl3ptl		;BIT PLANE 3 LOW
	swap	d0
	move.w	d0,Bpl3pth		;BIT PLANE 3 HIGH
	swap	d0
	add.l	#200*80,d0		;ADD SCREEN SIZE TO D0
	move.w	d0,Bpl5ptl		;BIT PLANE 5 LOW
	swap	d0		
	move.w	d0,Bpl5pth		;BIT PLANE 5 HIGH
	swap	d0
	rts
clear_screen				;CLEAR FOREGROUND WITH 0'S
	move.l	#Foreground,a0
	move.l	#$0,d0			
cl_screen
	move.w	#12000-1,d1		;NO OF LONG WORDS -1
clear
	move.l	d0,(a0)+	
	dbf	d1,clear		;LOOP TILL 0
	rts
delay					;DELAY JUST TO SLOW THING DOWN 
	move.l	#$ff,d4			;A LITTLE 
del	dbf	d4,del
	rts

initalise				;VARIABLES
	lea	map,a4			;A4 CONTAINS DATA FOR FOREGFROUNDS 200*16 BLOCKS
	move.w	#$Ff,scroll		;LOAD SCROLL WITH 15 FOR BOTH FORE/BACKGROUNDS
	move.l	#Foreground,d0		;ADDRESS OF FOREGROUND TO STORE
	move.l	d0,blit_base_2		;SO BLOCKS CAN BE DRAWN ON
	add.w	#40,d0			;ADDRESS OF 2ND ADDRESS STORED
	move.l	d0,blit_base

	move.l	#Background,d0		;SAME FOR BACKGROUND
	move.l	d0,scroll_base_2	;2 ADDRESSS TO BLIT BLOCKS ONTO
	add.w	#40,d0
	move.l	d0,scroll_base

	lea	graphics,a0		;FOREGROUND GRAPHICS STORED
	move.l	a0,gra_base
	lea	graphics_2,a0		;BACKGROUND GRAPHICS STORED
	move.l	a0,gra_base_scroll
	clr.b	blit_count		;CLEAR SOME VARIABLES
	clr.b	count			
	clr.w	inc
	clr.b	count_2
	clr.w	inc_2
	clr.b	count_scroll2
	clr.b	blit_count_scroll
	lea	$dff000,a6		;LOAD A6 WITH CUSTOM BASE ADDRESS
	rts


scroll_Foreground		
	move.w	scroll,d0		;SCROLL VALUE IN D0
	and.w	#$0f,d0			;MASK OFF BACKGROUND VALUE
	cmp.w	#$0,d0			;IF 0 THEN RESET
	beq	reset			;ELSE 
	subi.w	#$01,scroll		;SUBTRACT 1 FROM VALUE
	rts
reset					;HAVE NOW SCROLLED 16 PIXELS
	add.w	#2,inc			;ADD #2 TO INCREMENT VALUE
	bsr	blitter			;BRANCH TO BLIT BLOCK
	bsr	blitter_2		;"                   "
	move.w	scroll,d0		;SCROLL VALUE IN D0
	move.w	d0,d3			;TRANSFER TO D3
	and.w	#$ff,d3			;MASK OUT BACKGROUND VALUE
	or.w	#$0f,d3			;OR D3 TO PUT 15 IN FOREGROUND VALUE
	or.w	d3,d0			;D3 BACK TO D0
	lea	scroll,a0		;LOAD SCROLL TO A0
	move.w	d0,(a0)			;MOVE RESETTED VALUE TO COPPERLIST
	add.b	#1,count		;ADD 1 TO COUNT
	cmp.b	#20,count		;WHEN 20 WORD SCROLLED
	beq	swap_planes		;BRANCH TO RESET PLANES TO START
	addi.w	#2,Bpl0ptl		;ELSE ADD #2 TO PALNE 0
	addi.w	#2,Bpl2ptl		;TO PLANE 2
	addi.w	#2,Bpl4ptl		;TO PLANE 4
	rts
swap_planes				;RESET VALUES IN COPPERLIST
	move.b	#0,count		;CLEAR	COUNT
	move.w	#0,inc			;CLEAR INCREMENTAL VALUE
	move.l	#Foreground,d0		;FOREGROUND ADDRESS
	move.w	d0,Bpl0ptl		;INSERT ADDRESSES
	swap	d0			;INTO COPPERLIST
	move.w	d0,Bpl0pth
	swap	d0
	add.l	#200*80,d0
	move.w	d0,Bpl2ptl
	swap	d0
	move.w	d0,Bpl2pth
	swap	d0
	add.l	#200*80,d0
	move.w	d0,Bpl4ptl
	swap	d0
	move.w	d0,Bpl4pth
	swap	d0

	rts
blitter					;BLIT 200*16 BLOCK 
	move.l	blit_base,a3		;ADDRESS OF DESIGNATION
	add.w	inc,a3			;PLUS INCREMNTAL VALUE.I.E.EVERY TIME 1 WORD
					;SCROLLED #2 TO ADDRESS
	move.l	gra_base,a0		;GRAPHICS IN A0
	move.l	#78,d0			;MODULA OF GRAPHICS
	move.l	#78,d1			;MODULA OF DESIGNATION
	move.l	#(200*64)+1,d3		;SIZE OF BLIT(200*1WORD)
	move.w	#$ffff,d6		;NO MASK
	move.w	#$ffff,d4		;NO MASK
	move.w	#2,d7			;NO OF PLANES -1
	lea	$dff000,a6		
	move.l	#$09f00000,d2		;A-D BLIT NO SHIFT

bb_loop
	bsr	stuff_blitter
	lea	200*80(a0),a0		;ADD PLANE SIZE	TO GRAPHICS 
	lea	200*80(a3),a3		;ADD PLANE SIZE TO DESIGNATION 
	dbra	d7,bb_loop		;LOOP TILL 0
	rts



blitter_2				;2ND BLIT IS EXACTLY 40 WORDS FORM 1ST
	move.l	blit_base_2,a3
	add.w	inc,a3		
	move.l	gra_base,a0
	move.l	#78,d0
	move.l	#78,d1
	move.l	#(200*64)+1,d3
	move.w	#$ffff,d6
	move.w	#$ffff,d4
	move.w	#2,d7
	lea	$dff000,a6
	move.l	#$09f00000,d2

bb_loop_2
	bsr	stuff_blitter
	lea	200*80(a0),a0
	lea	200*80(a3),a3
	dbra	d7,bb_loop_2
	lea	graphics,a0		;GRAPHICS ADDRESS
	move.w	(a4)+,d0		;NEXT VALUE OF MAP TO D0
	cmp.w	#$ff,d0			;IS IT #$FF(END MARKER)
	beq	map_reset		;YES BRANCH TO RESET
	asl.w	#1,d0			;SHIFT LEFT (SAME AS *2) 
	lea	(a0,d0.w),a0		;LOAD LOCATION OF NEXT BLOCK
	move.l	a0,gra_base		;STORE ADDRESS IN VARIABLE
	rts
map_reset			
	lea	miss_beg,a4		;SKIP FIRST FEW BLOCKS WHEN MAP RESET
	lea	graphics,a0		;
	move.w	(a4)+,d0		;NEXT BLOCK NUMBER
	asl.w	#1,d0			;*2
	lea	(a0,d0.w),a0		;LOCATION
	move.l	a0,gra_base		;STORED
	rts


	
stuff_blitter				;LOAD BLITTER WITH VALUES

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

scroll_Background				;BACKGROUND SCROLLED
	add.b	#1,skip_frame			;EVERY OTHER FRAME FOR PARALLEX
	cmp.b	#2,skip_frame			;EFFECT
	beq	yes_scroll_2			
	rts
yes_scroll_2	
	move.b	#0,skip_frame
	move.w	scroll,d0			;SCROLL VALUE 
	and.w	#$f0,d0				;MASK OUT FOREGROUND VALUE
	ror.w	#4,d0				;ROTATE RIGHT VALUE
	cmp.w	#$0,d0				;IS IT 0 
	beq	reset_scroll2			;YES BRANCH 
	sub.w	#$10,scroll			;ELSE SUBTRACT #1 FROM BACKGROUND VALUE
	rts
reset_scroll2
	add.w	#2,inc_2			;INCTREMNT VALUE FOE BACKGROUND
	bsr	blitter_scroll			;
	bsr	blitter_scroll_2		;
	move.w	scroll,d0			;SCROLL VALUE
	move.w	d0,d3				;TRANSFER TO D3								
	and.w	#$FF,d3				;MASK OUT FOREGROUND VALUE
	or.w	#$F0,d3				;RESET VALUE TO 15
	or.w	d3,d0				;BACK TO D0
	lea	scroll,a0			;SCROLL VALUE TO A0
	move.w	d0,(a0)				;NEW VALUE TO COPPERLIST
	add.b	#1,count_scroll2		;20 WORDS SCROLLED	
	cmp.b	#20,count_scroll2		;YES BRANCH
	beq	swap_planes_scroll2		;ELSE ADD #2 TO PLANE ADDRESSES
	addi.w	#2,Bpl1ptl
	addi.w	#2,Bpl3ptl
	addi.w	#2,Bpl5ptl
	rts
swap_planes_scroll2
	move.b	#0,count_scroll2		;CLEAR VARIABLE
	move.l	#Background,d0			;BACKGROUND ADDRESS 
	move.w	d0,Bpl1ptl			;RESET POINTERS IN 
	swap	d0				;COPPERLIST
	move.w	d0,Bpl1pth
	swap	d0
	add.l	#200*80,d0
	move.w	d0,Bpl3ptl
	swap	d0
	move.w	d0,Bpl3pth
	swap	d0
	add.l	#200*80,d0
	move.w	d0,Bpl5ptl
	swap	d0
	move.w	d0,Bpl5pth
	swap	d0
	move.w	#0,inc_2			;CLEAR INCREMENT_2
	rts
blitter_scroll
	move.l	scroll_base,a3			;ADDRESS OF BACKGROUND DESIGNATION
	add.w	inc_2,a3			;PLUS INCREMNTAL VALUE
	move.l	gra_base_scroll,a0		;BACKGROUND GRAPHICS
	move.l	#78,d0
	move.l	#78,d1
	move.l	#(200*64)+1,d3
	move.w	#$ffff,d6
	move.w	#$ffff,d4
	move.w	#2,d7
	lea	$dff000,a6
	move.l	#$09f00000,d2

bb_loop_scroll
	bsr	stuff_blitter
	lea	200*80(a0),a0
	lea	200*80(a3),a3
	dbra	d7,bb_loop_scroll
	rts

blitter_scroll_2			;40 WORDS ALONG FROM 1ST ADDRESS
	move.l	scroll_base_2,a3
	add.w	inc_2,a3
	move.l	gra_base_scroll,a0
	move.l	#78,d0
	move.l	#78,d1
	move.l	#(200*64)+1,d3
	move.w	#$ffff,d6
	move.w	#$ffff,d4
	move.w	#2,d7
	lea	$dff000,a6
	move.l	#$09f00000,d2

bb_loop_scroll2
	bsr	stuff_blitter
	lea	200*80(a0),a0
	lea	200*80(a3),a3
	dbra	d7,bb_loop_scroll2
	move.l	gra_base_scroll,a0		;GRAPHICS ADDRESS
	lea	2(a0),a0			;ADD #2 
	move.l	a0,gra_base_scroll		;NEXT BLOCKS ADDRESS
	add.b	#1,blit_count_scroll		;IS IT EQUAL TO 40
	cmp.b	#40,blit_count_scroll		;
	beq	blit_reset_scroll		;YES RESET BACKGROUND GRAPHICS
	rts					;ELSE RETURN
blit_reset_scroll
	lea	graphics_2,a0			;RESET BACK GRAPHICS
	move.l	a0,gra_base_scroll	
	move.b	#0,blit_count_scroll
	rts

gfxlib	dc.b	"graphics.library",0	
	even
_gfxbase	dc.l	0		;LONG WORD TO STORE GFX ADDRESS
oldcop		dc.l	0			;OLD COPPERLIST ADDRESS
blit_base	dc.l	0
blit_base_2	dc.l	0
scroll_base	dc.l	0
scroll_base_2	dc.l	0
gra_base	dc.l	0
gra_base_scroll	dc.l	0
inc		dc.w	0
inc_2		dc.w	0
count		dc.b	0
count_2		dc.b	0
count_scroll2		dc.b	0
blit_count	dc.b	0
blit_count_scroll	dc.b	0
skip_frame	dc.b	0
	even
	SECTION		chipmemory,data_c	


newcop
	dc.w	$0100,%0110011000000000		;6 PLANES DUAL PLAYFIELD MODE
	dc.w	$0102
scroll	dc.w	$0000			;	SCROLL VALUE
	dc.w	$0104,%0000000000000000		;NO PRIORITIES
	dc.w	$0108,$0024,$010a,$0024		;MODULAS
	dc.w	$0092,$0028,$0094,$00d0		;200*39 SCREEN
	dc.w	$008e,$3781,$0090,$ffb1		;VISIBLE AREA
						
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
	dc.w	$0120,$0000,$0122,$0000	
	dc.w	$0124,$0000,$0126,$0000
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

	dc.w	$0190,$0000,$0192,$0283	;COLORS PLAY 2
	dc.w	$0194,$08f4,$0196,$0095
	dc.w	$0198,$0243,$019a,$00ff
	dc.w	$019c,$0ff0,$019e,$0fa0

	dc.w	$01a0,$0d50,$01a2,$05C0		;SPRITE COLORS
	dc.w	$01a4,$0ff0,$01a6,$0dd4
	dc.w	$01a8,$0444,$01aa,$0880
	dc.w	$01ac,$006f,$01ae,$04ff
	dc.w	$01b0,$0DDD,$01b2,$00d6
	dc.w	$01b4,$0460,$01b6,$0D06
	dc.w	$01b8,$0f48,$01ba,$0ff4
	dc.w	$01bc,$000f,$01be,$0f0f

	dc.w	$ffff,$fffe			;END OF COPPERLIST
map
	dc.w	1,2,3,4,5,6,7,8,9,10,11,12
miss_beg	dc.w	13,14,15,16,17,18,19,20,21,22
	dc.w	23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39
	dc.w	10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28
	dc.w	29,30,31,32,33,34,35,36,37,38
	dc.w	$ff

Foreground
		dcb.b	(200*80)*1,$00
		dcb.b	(200*80)*1,$00
		dcb.b	(200*80)*1,$00

Background	incbin	source10:bitmaps1/Backgrounds


graphics	incbin	source10:bitmaps1/Foregrounds
graphics_2	incbin	source10:bitmaps1/Backgrounds
 

