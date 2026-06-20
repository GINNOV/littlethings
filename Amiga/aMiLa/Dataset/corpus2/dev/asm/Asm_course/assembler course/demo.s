
; ok, here it is... a real demo, go ahead and mess around, but maybe
; first make a backup for safety...

; this demo consists of 4 parts:
; -	a picture on top of the screen, nothing happens with it
; -	a scroll (blitter was used to copy new chars on the screen
;		  and to scroll the whole thing)
; -	a starfield (using 1 sprite with more controlling words)
; -	replay routine (not own-made, can be found on each noise-
;	tracker disk)
; -	equalisers, needs some knowledge of the replayroutine, like
;	when a new note is played. (see near the bottom of source)

; the lines marked with * can be changed when you for example take
; another picture or font etc...
; you are however not completely free to change the values in
; whatever you want (don't take a picture height of 7000 lines for
; example coz the demo won't work as it should)

; HOW TO PUT EVERYTHING TOGETHER
;--------------------------------
;
; first change everything as you like it, and test it.
; assemble it, (a) and save the object (wo) (that's ALL!!!)
; if you want to use another picture, draw it with dpaint, save it
; use IFFconvert to save it as RAW colors BEFORE. It must be 320 wide
; note down the height coz you must fill it in into the source (see ***)

	section MYFIRSTDEMO,code_c		; force loading into CHIPMEM

main:	movem.l	a0-a6/d0-d7,-(a7)

	move.l	$4,a6
	lea	gfxname,a1
	jsr	-408(a6)		; open gfx library
	move.l	d0,gfxbase

	jsr	-132(a6)		; forbid interrupts

	bsr	fillcopper		;precalculation of some data
	bsr	calcfontdata		;
	jsr	mt_init			;init. of replayroutine

	move.w	$dff01c,d0		;save	INTENA
	move.w	$dff01e,d1		;	INTREQ
	move.w	$dff002,d2		;	DMACON

	move.w	#$7fff,$dff096			; clear DMACON
	move.w	#%1000001111100000,$dff096	; set needed DMA's

	move.l	#copperlist,$dff080	;install new copper
	clr.l	$dff088			;and start

	movem.l a0-a6/d0-d7,-(a7)

loop:	bsr	waitvblank		; wait for 'timing'
	bsr	scroll			; do scroll routine
	bsr	eq_down			; lower equalisers
	bsr	movestars		; do starroutine
	jsr	mt_music		; do replayroutine
	btst	#6,$bfe001		; check left ear
	bne.s	loop

	movem.l	(a7)+,a0-a6/d0-d7

	or.w	#$8000,d0		; set the 'set/clr' bit
	or.w	#$8000,d1
	or.w	#$8000,d2
	move.w	d2,$dff096		;restore values in regs
	move.w	d1,$dff09c		;
	move.w	d0,$dff09a		;

	jsr	mt_end			; end of replayroutine

	move.l	gfxbase,a1
	move.l	$26(a1),$dff080		;restore copperlist

	move.l	$4,a6
	jsr	-414(a6)		;close lib
	jsr	-138(a6)		;permit interrupts

	move.w	#$8100,$dff096		;turn on bitplane dma
					;(just to be sure)

	movem.l	(a7)+,a0-a6/d0-d7
	rts				;exit

*****************************************************************
*								*
*	All kinds of routines...				*
*								*
*****************************************************************

waitvblank:
	cmp.b	#$ff,$dff006
	bne.s	waitvblank
waitabitmore:
	cmp.b	#$20,$dff006
	bne.s	waitabitmore
	rts
;--------------------------------------------------------------
waitblitter:
	btst	#14,$2(a5)
	bne.s	waitblitter
	rts
;--------------------------------------------------------------
movestars:
	lea.l	star_speedtab,a0
	lea.l	stars,a1
	move.l	#c_numofstars-1,d0
mslp:	move.b	(a0)+,d1	; a0 contains speed for each star
	add.b	d1,1(a1)	; 1(a1) = bits H8-H1 of contr.words
	addq.l	#8,a1		; next set of controlling words
	dbf	d0,mslp
	rts
;--------------------------------------------------------------
eq_down:cmp.w	#$400,eq0+2
	beq.s	eq_d1
	sub.w	#$100,eq0+2
eq_d1:	cmp.w	#$400,eq1+2
	beq.s	eq_d2
	sub.w	#$100,eq1+2
eq_d2:	cmp.w	#$400,eq2+2
	beq.s	eq_d3
	sub.w	#$100,eq2+2
eq_d3:	cmp.w	#$400,eq3+2
	beq.s	eq_d4
	sub.w	#$100,eq3+2
eq_d4:	rts

*****************************************************************
*								*
*	scroll							*
*								*
*****************************************************************
scroll:
	tst.b	delay		; if delay is not 0, delay=delay-1
	beq.s	doscroll	; only if delay=0, a scroll is done
	subq.b	#1,delay
	bra	endscroll
doscroll:
	move.l	#$dff000,a5	; start of hardware regs in a5


	lea.l	s_pic,a0		; this routine scrolls the
	lea.l	s_pic-2,a1		; whole scrollpic by 4 bits
	move.l	#s_depth-1,d1		; using the barrelshifter
scrollraster:
	bsr	waitblitter
	move.l	a0,$50(a5)			; source address
	move.l	a1,$54(a5)			; destin.address
	move.w	#$ffff,$44(a5)			; Firstwordmask
	move.w	#$ffff,$46(a5)			; Lastwordmask
	clr.w	$42(a5)				; bltcon1
	clr.w	$64(a5)				; modulo source = 0
	clr.w	$66(a5)				; modulo destin = 0
	move.w	#%1100100111110000,$40(a5)	; bltcon0
	move.w	#s_blitsize,$58(a5)		; trigger/size

	add.l	#s_planesize,a0			; next plane src
	add.l	#s_planesize,a1			; next plane dst

	dbf	d1,scrollraster			; loop until d1= -1



	subq.b	#4,charpos	; now, char has scrolled 4 pixels
	tst.b	charpos		; time for new char ?
	bgt	endscroll	; no !

	move.l	#f_endchartab,d1    ; we'll need this value often
				    ; so let's put it in d1 (faster)
find_new_char:
	move.l	textptr,a2		; pointer to text
	move.b	(a2)+,d2		; take char (+increase)
	tst.b	(a2)			; next char = 0 ? 
	bne.s	newchgo
	move.l	#textrestart,a2		; then scroll restarts
newchgo:move.l	a2,textptr		; save new pos.textptr

	lea.l	f_chartab,a3		;this routine searches the 
	moveq.l	#-1,d0			;chartab for the startaddres
newchlp:addq.l	#1,d0			;of the char that we must
	move.b	(a3)+,d3		;put on screen. This is a 
	cmp.l	d1,a3			;silly routine that is not
	bgt.s	specialhandler		;very fast. I'll rewrite it
	cmp.b	d2,d3			;when I'm in a good mood.
	bne.s	newchlp			;
	move.b	#f_widthB*8,charpos	;
	asl.w	#2,d0			;
	add.l	#f_startaddr,d0		;
	move.l	d0,a0			;
	move.l	(a0),a0			;
endnewch:

	; the next bit will copy 1 char from the charpic onto the
	; scrollpic.  a0 is the address of the char (source) which
	; we managed to find using the previous routine.
	; a1 (destination) is the right side of the scrollpic.

	move.l	#s_depth-1,d1
	move.l	#s_pic+s_widthB-f_widthB,a1	;dest addr.
putch:	bsr	waitblitter
	move.l	a0,$50(a5)			; source a
	move.l	a1,$54(a5)			; destin.
	move.w	#$ffff,$44(a5)			; fwm
	move.w	#$ffff,$46(a5)			; lwm
	clr.w	$42(a5)				; con1
	move.w	#f_blitmoda,$64(a5)		; mod a
	move.w	#f_blitmodd,$66(a5)		; mod d
	move.w	#%0000100111110000,$40(a5)	; con0
	move.w	#f_blitsize,$58(a5)		; trigger/size

	add.l	#f_planesize,a0			;next pl.a
	add.l	#s_planesize,a1			;next pl.d
	dbf	d1,putch
endscroll:
	rts

specialhandler:
	cmp.b	#"P",d2
	bne.s	eff2
	move.b	#50,delay
eff2:					; here you can add your
					; own effects...
	bra	find_new_char

*****************************************************************
*								*
*	calculation of addresses and values for copperlist	*
*								*
*****************************************************************

fillcopper:
	movem.l	a0-a6/d0-d7,-(a7)

;installpicplanes:
	lea.l	p_planept,a0
	move.l	#p_pic,d0
	move.w	#$e0,d1
	move.l	#p_depth-1,d2
ipp:	move.w	d1,(a0)+
	addq.w	#2,d1
	swap	d0
	move.w	d0,(a0)+		; this routine fills the
	move.w	d1,(a0)+		; label p_planept with
	addq.w	#2,d1			; values like $00e0hhhh
	swap	d0			; $00e2llll etc... (bplpt)
	move.w	d0,(a0)+
	add.l	#p_planesize,d0
	dbf	d2,ipp

;instalpiccolors:
	lea.l	p_col,a0
	lea.l	p_colpt,a1
	move.w	#$180,d1
	move.l	#p_numofcol-1,d2	; fills copper with 
ipc:	move.w	d1,(a1)+		; $01800xxx,$01820xxx etc
	addq.w	#2,d1			; colors from picture
	move.w	(a0)+,(a1)+
	dbf	d2,ipc

;installscrollplanes:
	lea.l	s_planept,a0
	move.l	#s_pic,d0
	move.w	#$e0,d1			; fills the BPLxPTH & L
	move.l	#s_depth-1,d2		; for the scroll-pic
ifp:	move.w	d1,(a0)+
	addq.w	#2,d1
	swap	d0
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq.w	#2,d1
	swap	d0
	move.w	d0,(a0)+
	add.l	#s_planesize,d0
	dbf	d2,ifp

;install colored lines
	lea.l	c_line1,a0
	lea.l	c_line2,a1
	lea.l	c_coltab,a2		; fills c_line1 and c_line2
	move.l	#c_numofdivs-1,d0	; with $01800xxx to create
	move.l	#$01800000,d1		; the effect of a multi-
icl:	move.l	d1,d2			; colored line.
	move.w	(a2)+,d2
	move.l	d2,(a0)+
	move.l	d2,(a0)+
	move.l	d2,(a1)+
	move.l	d2,(a1)+
	dbf	d0,icl

;install SPRxPTH & SPRxPTH for sprite 1 (starfield)
	move.l	#stars,d0
	move.l	#$120,d1	; spr0ptH
	lea.l	spr1pt,a0

	move.w	d1,(a0)
	addq.w	#2,d1		; spr0ptL
	move.w	d1,4(a0)
	addq.w	#2,d1

	move.w	d0,6(a0)	; lowword
	swap	d0
	move.w	d0,2(a0)	; highword
	addq.l	#8,a0

;install SPRxPTH & L for 7 other sprites (not used)
	moveq.l	#6,d2
isp:	move.l	#zerosprite,d0
	move.w	d0,6(a0)	; lowword
	swap	d0
	move.w	d0,2(a0)	; highword

	move.w	d1,(a0)		; sprXptH
	addq.w	#2,d1
	move.w	d1,4(a0)	; sprXptL
	addq.w	#2,d1

	addq.l	#8,a0		; next set of SPRxPT
	dbf	d2,isp

;install sprite data (vpos & hpos) for each subsprite...
	lea.l	stars,a0
	lea.l	star_hpostab,a1
	clr.l	d0			; 1st line sprite = 0
					; (right after start lowerzone)
	move.l	#c_numofstars-1,d1
isd:	move.b	d0,(a0)+		; V7-V0
	move.b	(a1)+,(a0)+		; H8-H1
	addq.w	#1,d0
	move.b	d0,(a0)+		; L7-L0
	move.b	#6,(a0)+		; L8=1, V8=1
	addq.w	#1,d0
	addq.l	#4,a0
	dbf	d1,isd

;install color for each subsprite according to speed (slow=dark)
	lea.l	c_starblock,a0
	lea.l	star_speedtab,a1
	lea.l	colortab,a2
	clr.l	d0
	move.l	#c_numofstars-1,d1
ics:	move.b	d0,(a0)+		; these 4 lines create in 
	addq.b	#2,d0			; the copperlist a wait-
	move.b	#$0f,(a0)+		; instr.
	move.w	#$fffe,(a0)+		; 
	move.w	#$01a2,(a0)+		 ; color17 (sprite1col1)
	moveq.l	#0,d2
	move.b	(a1)+,d2		; check speed of current star
	asl.w	#1,d2	; speed * 2 = offset for colortab : example:
			; speed=1, offset=2 (=2nd word in tab)
			; speed=2, offset=4 (=3th word in tab)
	move.w	(a2,d2),(a0)+
	dbf	d1,ics

endfc:	movem.l	(a7)+,a0-a6/d0-d7
	rts

*****************************************************************
*								*
*	calculation of constants				*
*								*
*****************************************************************

calcfontdata:
	movem.l	a0-a6/d0-d7,-(a7)

;calc startaddr of each char in the pic

	lea.l	f_pic,a0
	lea.l	f_startaddr,a1
	move.l	#f_totheight,d2		; fills the f_startaddr-tab
	move.l	#f_widthW,d1		; with the startaddresses of
cca1:	move.l	#f_totwidthW,d0		; the different chars in the
cca2:	move.l	a0,(a1)+		; picture. This way, the 1st
	add.l	#f_widthB,a0		; value in this tab will be
	sub.l	d1,d0			; the addres where the shape
	cmp.l	#1,d0			; of the 1st char starts etc
	bgt.s	cca2			;(used in the silly routine)
nextrow:add.l	#[f_height-1]*f_totwidthB,a0
	sub.l	#f_height,d2
	bgt.s	cca1

endcfd:	movem.l	(a7)+,a0-a6/d0-d7
	rts

*****************************************************************
*								*
*	data							*
*								*
*****************************************************************

******************* sprite stuff  **********************

c_numofstars=	20

stars:		blk.l	2*c_numofstars,$00010000

; there are 2 longwords for each 'subsprite', the first longword
; contains the controlling words for the sprite, the second
; longword contains the shapedata. OUr sprites are only 1 line high.

zerosprite:	dc.l	0	; last 2 words zero to end spriteDMA

star_hpostab:
	dc.b	100,20,46,240,2,78,172,120,200,154,210,180,51,220
	dc.b	10,90,150,32,99,24,57,0,0,0,0,0,0,0,0,0,0
; contains starting position (horiz) for each star. 

star_speedtab:
	dc.b	1,2,1,2,3,3,1,3,2,2,1,2,3,1,2,2,1,2,3,2,1,3,2,1,2,1,3,1
	dc.b	0,0,0,0,0,0,0
; contains speed for each star. By adding this value to the current
; hor.position, the star will seem to move to the right with a 
; certain speed.

colortab:
	dc.w	$000,$444,$888,$aaa,$fff
; contains 5 words = colors for each speed


******************* font definitions **********************

f_depth=	2		; planes		*
f_height=	49		; height 1 char		*
f_totheight=	245		; height charpic	*
f_widthW=	2		; width 1 char WORDS	*
f_totwidthW=	288/16		; width charpic WORDS	*

f_widthB=	f_widthW*2
f_totwidthB=	f_totwidthW*2
f_planesize=	f_totwidthB*f_totheight
f_picsize=	f_planesize*f_depth
f_numofcol=	2^f_depth

f_pic:	incbin "df0:mp.288x245x2"		;	*

f_startaddr:	
	blk.l	[[f_totheight/f_height]+1]*[[f_totwidthW/f_widthW]+1],0

f_chartab:
	dc.b	"abcdefghijklmnopqrstuvwxyz.,!?:[]-0123456789 "
f_endchartab:
	dc.b	0
	even

f_blitsize=	64*f_height+f_widthW
f_blitmoda=	[f_totwidthB-f_widthB]

******************** scroll definitions ***********************

s_height=	51			;lines
s_width=	384			;bits
s_topline=	$f5			; < $ff !!			**

s_depth=	f_depth
s_widthB=	s_width/8
s_widthW=	s_width/16
s_planesize=	s_height*s_widthB
s_bottline=	s_topline+s_height-[2*f_height]
s_mod=		[s_widthB-40]

s_buff:		blk.b	4	; small bug : a bit of blitted part
				; of the scroll will land here
s_pic:		blk.b	[s_planesize*s_depth]

s_blitsize=	64*s_height+s_widthW
f_blitmodd=	[s_widthB-f_widthB]

************************* the logo *********************************

p_depth=	5			;		*  adjust these values
p_height=	190			;lines		*  if you drew another
p_width=	320			;bits		*  logo !! (width must
p_topline=	40			;		*  be 320!)

p_widthB=	p_width/8
p_widthW=	p_width/16
p_planesize=	p_height*p_widthB
p_numofcol=	2^p_depth
p_mod=		p_widthB-40

p_col:	incbin "df0:abyss.320x190x5"		;	*
p_pic=	p_col+p_numofcol*2

*********************** various stuff ******************************

delay:		dc.b	0		; counter to keep track on
					; delay for scroll (effect1)

charpos:	dc.b	f_widthW*16	; counter to keep track on
					; when to put a new char on
					; the screen. 

; capital 'P' will pause the scroller for a while...
; only use chars that are listed in the chartab...

text:	dc.b	"here we go..."		; this text will be shown only once...
textrestart:				; this part will be restarted each time
	dc.b	" amigafreaks in pretoria and surroundings now have their own"
	dc.b	" bulletin board system... call now for free downloading"
	dc.b	" (12)73-9069 PP   the abyss PP  sysops are midnight horror and"
	dc.b	" atlantic dolphin       low rates - hot stuff - for amiga "
	dc.b	"and pc !!    silly demo coded by cool-g long ago !          "

	dc.b	0		; add dc.b 0 at end of scrolltext !!
	even

textptr:	dc.l	text		; pointer to the position in
					; the scrolltext (don't change!)

gfxbase:	dc.l	0
gfxname:
	dc.b	"graphics.library",0
	even

c_numofdivs=	32

c_coltab:	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
		dc.w	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

********************************************************************

copperlist:	
		dc.l	$00960100	; turn off bitpl.DMA

spr1pt:		blk.l	8*2,0		; 8 sprites, each one with
					; SPRxPTH & SPRxPTL


p_colpt:	blk.l	p_numofcol,0		;room for pic colors
p_planept:	blk.l	p_depth*2,0		;and BPLxPT

		dc.l	$008e2921,$009029c1	;diw start/stop
		dc.l	$00920030,$009400c8	;ddf start/stop
		dc.l	$01020088		;bplcon1(smooth pos)

		dc.w	$0108,p_mod,$010a,p_mod	;BPLMOD even/odd
		dc.b	$01,$00,p_depth*16,$00	;BPLCON0 (#planes)

		dc.b	p_topline,$0f,$ff,$fe	;wait for topline
		dc.l	$00968100		;turn on bitpl.DMA

		dc.l	$600ffffe
eq0:		dc.l	$01800000
		dc.l	$680ffffe
		dc.l	$01800000

		dc.l	$700ffffe
eq1:		dc.l	$01800800
		dc.l	$780ffffe
		dc.l	$01800000

		dc.l	$800ffffe
eq2:		dc.l	$01800800
		dc.l	$880ffffe
		dc.l	$01800000

		dc.l	$900ffffe
eq3:		dc.l	$01800800
		dc.l	$980ffffe
		dc.l	$01800000


		dc.b	p_topline+p_height,$0f,$ff,$fe
						;wait for bottomline
		dc.l	$00960100		;turn off bitpl.dma

f_colpt:	dc.l	$01800000,$01820008	; scroll colors ***
		dc.l	$01840004,$0186044a
		
s_planept:	blk.l	s_depth*2,0		; scroll BPLxPT's

		dc.l	$01020000		;bplcon1
		dc.l	$00920030,$009400d0	;ddfstart/stop
		dc.w	$0108,s_mod-2,$010a,s_mod-2 ;BPLMOD
		dc.b	$01,$00,s_depth*16,$00	;BPLCON0

		dc.b	s_topline,$0f,$ff,$fe	;wait for topline
c_line1:	blk.l	2*c_numofdivs,0		;room for colored line

		dc.l	$01040000		;priority of sprites

		dc.b	s_topline+4,$0f,$ff,$fe
		dc.l	$00968100		;turn on bitplanes
		dc.l	$ffdffffe		;wait for lower zone

c_starblock:	blk.l	2*c_numofstars,0	;room for starcolors

		dc.b	s_topline+f_height+6-256,$0f,$ff,$fe
		dc.l	$00960100		;end of scrollpic
c_line2:	blk.l	2*c_numofdivs,0		;2nd colored line


		dc.l	$fffffffe		;end of copperlist1

; now follows the noisetracker replay-routine, which can be found
; on each disk with noisetracker. Simply build it into your own
; routine, and READY !!

mt_data:incbin "df0:mod.so what..."		;	****

;нннннннннннннннннннннннннннннннннннннн
;н   NoisetrackerV1.0 replayroutine   н
;н Mahoney & Kaktus - HALLONSOFT 1989 н
;нннннннннннннннннннннннннннннннннннннн

mt_init:movem.l	a0-a6/d0-d7,-(a7)
	lea	mt_data,a0
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
	movem.l	(a7)+,a0-a6/d0-d7
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
	tst.w	d0
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

; equaliser check. if the first word of mt_voiceX is not zero, a new
; note was played.

	lea.l	mt_voice1,a6
	tst.w	(a6)
	beq.s	mt_chk1
	lea.l	eq0,a6
	move.w	#$f00,2(a6)
mt_chk1:lea.l	mt_voice2,a6
	tst.w	(a6)
	beq.s	mt_chk2
	lea.l	eq1,a6
	move.w	#$f00,2(a6)
mt_chk2:lea.l	mt_voice3,a6
	tst.w	(a6)
	beq.s	mt_chk3
	lea.l	eq2,a6
	move.w	#$f00,2(a6)
mt_chk3:lea.l	mt_voice4,a6
	tst.w	(a6)
	beq.s	mt_chk4
	lea.l	eq3,a6
	move.w	#$f00,2(a6)
mt_chk4:

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
	moveq	#0,d0
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
