
top:	jmp	main		; don't touch this line

*****************************************************************
*								*
*	the SCROLL text...	see docs for comments		*
*								*
*****************************************************************

scrolltext:
;	here comes text that will be displayed only the 1st time...

textrestart:
;	this text will be repeated...

	dc.b	"      * zylon *      |"
	dc.b	"proudly presents a new small intro.                   "
	dc.b	"released 1/2/91 on the famous demopack by iceman/zylon...    "
	dc.b	"           * hot news *    |"
	dc.b	"zylon will delight the scene with 2 own boards: "
	dc.b	" muscle beach  and  damage inc.        "
	dc.b	"         stay awake, coz"
	dc.b	" the one and only I zylon megademo I |will see the light on the cebit'91 !!"
	dc.b	"   don't miss it...              contact zylon/afl  "
	dc.b	" write to:      pobox 47      |  4700 eupen/belgium |"
	dc.b	"(original suppliers wanted!)                             "

	dc.b	0		; the last line of the scrolltext !!
	even

*****************************************************************
*								*
*	the TEXTPANEL text...	see docs for comments		*
*								*
*****************************************************************

windowtext:
	dc.b	WAITSHORT,LOGO,WAIT,NEWPAGE
	dc.b	SKIPLINE
	dc.b	SKIPLINE
	dc.b	"zylon of alphaflight"
	dc.b	SKIPLINE
	dc.b	"      presents      "
	dc.b	SKIPLINE
	dc.b	"   a small intro    ",TEXT
	dc.b	WAITSHORT

	dc.b	NEWPAGE,SKIPLINE,SKIPLINE
	dc.b	WOOSH,"                    "
	dc.b	SKIPLINE
	dc.b	WOOSH,"                    "
	dc.b	SKIPLINE
	dc.b	WOOSH,"                    ",SPEED1

	dc.b	NEWPAGE,SKIPLINE,SKIPLINE
	dc.b	"   contact zylon !  "
	dc.b	"     write to...    ",SKIPLINE
	dc.b	"      pobox 47      "
	dc.b	"    b-4700 eupen    ",WAIT

	dc.b	LOGO,NEWPAGE
	dc.b	WOOSH,"                    "
	dc.b	WOOSH,"                    "
	dc.b	WOOSH,"                    "
	dc.b	WOOSH,"                    "
	dc.b	WOOSH,"                    "
	dc.b	WOOSH,"                    "
	dc.b	WOOSH,"                    "
	dc.b	WOOSH,"                    "
	dc.b	WOOSH,"                    ",TEXT

	dc.b	NEWPAGE
	dc.b	REVERSE,SKIPLINE,SPEED1
	dc.b	"coding:             ",SKIPLINE
	dc.b	"logo:               ",SKIPLINE,SKIPLINE
	dc.b	"music:              ",SPEED1

	dc.b	NEWPAGE
	dc.b	REVERSE,SKIPLINE,REVERSE,SPEED1
	dc.b	"coding:       cool-g",SKIPLINE,REVERSE
	dc.b	"logo:          gator",REVERSE
	dc.b	"            & cool-g",SKIPLINE,REVERSE
	dc.b	"music:        avatar",WAITSHORT,SPEED1

	dc.b	NEWPAGE,SKIPLINE
	dc.b	WOOSH,"                    ",SKIPLINE
	dc.b	WOOSH,"                    "
	dc.b	WOOSH,"                    ",SKIPLINE
	dc.b	WOOSH,"                    "

	dc.b	NEWPAGE,SKIPLINE,SKIPLINE,SPEED2
	dc.b	WOOSH,"      hey dude,     ",LINEUP,WAITSHORT
	dc.b	"read the sinusscroll",LINEUP,WAITSHORT
	dc.b	" coz this text ends ",LINEUP,WAITSHORT
	dc.b	WOOSH,"                    "

	dc.b	RESTART
	even

******** the modulename + length ********

>extern "df0:modules/mod.one step",mt_data
mod_length=20816

*****************************************************************
*								*
*	Here starts the program...				*
*	Don't change unless you know what you're doing !!	*
*								*
*****************************************************************

main:	movem.l	a0-a6/d0-d7,-(a7)
	move.l	$4,a6
	jsr	-132(a6)

	lea	libname(pc),a1
	jsr	-408(a6)		
	move.l	d0,gfxbase

	move.w	#3,l1_col

	bsr	calcfontdata
	bsr	fillcopper
	jsr	mt_init
	bsr	fillwindowplane
	bsr	fillscrollplane
	lea.l	fade_tempstore(pc),a1
	bsr	fillwindowcolors

	bsr	waitvblank
	move.w	#$8020,$dff096
	lea.l	zerohpos(pc),a0
	move.l	a0,$dff120
	move.w	#$0020,$dff096

	move.l	#copperlist,$dff080
	move.w	$dff002,d0
	move.w	#$7fff,$dff096
	move.w	#%1000011111000000,$dff096

	move.w	$dff01c,d1
	move.w	#$7fff,$dff09a
	move.w	#%1100000000100000,$dff09a

	move.l	$6c,oldint+2
	move.l	#int,$6c

click:
	btst	#6,$bfe001
	bne.s	click
	
	move.l	oldint+2(pc),$6c
	move.l	gfxbase(pc),a5
	move.l	$4,a6

	move.w	#$7fff,$dff096
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.w	#$8100,$dff096

	move.w	#$7fff,$dff09a
	or.w	#$8000,d1
	move.w	d1,$dff09a

	move.l	$26(a5),$dff080		
	move.l	a5,a1

	jsr	mt_end

	jsr	-414(a6)		
	jsr	-138(a6)
	jsr	-126(a6)

	move.w	#$8100,$dff096

	movem.l	(a7)+,a0-a6/d0-d7
	rts				


zerohpos:	dc.l	0
gfxbase:	dc.l	0
calccs:		dc.l	0
libname:	dc.b	"graphics.library",0
		even
****************************************************	interrupt

int:	movem.l a0-a6/d0-d7,-(a7)

	move.l	realcs(pc),d0
	move.l	calccs(pc),d1
	sub.l	d0,d1
	bne.s	endint

	jsr	mt_music	;--------------	music

	bsr	eq_down		;--------------	equaliser

	bsr	fillscrollplane
	eor.l	#s_width*256,scrollplaneptr

	bsr	sscroll		;--------------	sinusscroll

	bsr	puttextinwindow

	btst	#10,$dff016
	bne.s	endint
	move.w	#$fff,$dff180
	move.w	#$000,$dff180
endint:	movem.l	(a7)+,a0-a6/d0-d7

oldint:	jmp	$0

logodelay:	dc.w	0

windowstatus:	dc.b	TEXT
fadedelay:	dc.b	1
		even

****************************************************	routines

;----------------------------------------------	equaliser
eq_delay:	dc.b	0
		even

eq_down:not.b	eq_delay
	bne.s	eq_d4

	cmp.w	#$4,eq0+2
	beq.s	eq_d1
	sub.w	#$1,eq0+2
	sub.w	#$1,eq0_2+2
eq_d1:	cmp.w	#$4,eq1+2
	beq.s	eq_d2
	sub.w	#$1,eq1+2
	sub.w	#$1,eq1_2+2
eq_d2:	cmp.w	#$4,eq2+2
	beq.s	eq_d3
	sub.w	#$1,eq2+2
	sub.w	#$1,eq2_2+2
eq_d3:	cmp.w	#$4,eq3+2
	beq.s	eq_d4
	sub.w	#$1,eq3+2
	sub.w	#$1,eq3_2+2
eq_d4:	rts
;----------------------------------------------	sinusscroll
sscroll:
	movem.l a0-a6/d0-d7,-(a7)
	lea.l	$dff000,a5
	tst.b	delay
	beq.s	sscrollraster
	subq.b	#1,delay
	bra	endsscroll
sscrollraster:
	move.l	#scrolltemp+440,$50(a5)
	move.l	#scrolltemp+440-2,$54(a5)
	move.w	#$0fff,$44(a5)
	move.w	#$ffff,$46(a5)
	clr.w	$42(a5)
	clr.w	$64(a5)
	clr.w	$66(a5)
	move.w	#%1110100111110000,$40(a5)
	move.w	#%0000010001010110,$58(a5)

	subq.b	#2,scharpos
	bne	endsscroll
	move.b	sorigcharpos(pc),scharpos

	move.l	#sendlettertab,d1
	move.l	sscrollptr(pc),a2
	moveq.b	#0,d2
snewchseek:
	move.b	(a2)+,d2
	tst.b	(a2)
	bne.s	ssrest
	move.l	sscrollrestart(pc),a2	; restart scroll
ssrest:	move.l	a2,sscrollptr
	cmp.b	#"|",d2
	bne.s	eff2
	move.b	#$80,delay		; scroll delay
	bra.s	snewchseek
eff2:	asl.l	#2,d2
	lea.l	sletteraddr(pc),a2
	moveq.l	#-1,d0				
sputch:	move.l	(a2,d2),$50(a5)			
	move.l	#scrolltemp+440+42,$54(a5)
	move.w	d0,$44(a5)
	move.w	d0,$46(a5)
	clr.w	$42(a5)
	move.w	#188,$64(a5)
	move.w	#42,$66(a5)
	move.w	#%0000100111110000,$40(a5)
	move.w	#%0000010000000001,$58(a5)
endsscroll:
	move.l	#[s_width/2]-1,d0	; # words to sinus

	lea.l	sourceptr(pc),a1	; ptr to pos.in plainscroll
	move.l	#scrolltemp+2,(a1)	; re-install

	move.l	sinusptr(pc),a0		;
	addq.l	#8,a0			; sinusshape moves
	addq.l	#8,a0			;
	cmp.l	#endsinuslist,a0	;
	blt.s	sinusok			;
	sub.l	#2*sinuslistlength,a0	; restart shape
sinusok:move.l	a0,sinusptr		;

	move.w	#42,$64(a5)
	move.w	#38,$62(a5)
	move.w	#38,$66(a5)
	move.w	#$ffff,$46(a5)
	clr.w	$42(a5)

	move.l	scrollplaneptr(pc),a3	; doubbuf dest.start
	move.l	#440,d5			; extra buffer to clear (source)
	move.l	#400,d6			;			(dest)
	moveq.l	#0,d1

scopybit1:
	move.l	a3,a2
	move.l	#%1000000000000000,d3	; bitmask
	move.w	(a0),d1			; offset dest (sinus)
	addq.l	#2,a0
	sub.w	d6,d1			; some extra lines to clear
	add.l	d1,a2

	move.l	(a1),$50(a5)
	move.l	a2,$54(a5)
	move.w	d3,$44(a5)
	move.w	#%0000100111110000,$40(a5)
	move.w	#%0000100110000001,$58(a5)

	moveq.l	#14,d4			; 15 more bits to copy
	add.l	d5,(a1)			; skip extra lines for them
scopyotherbits:
	lsr.w	#1,d3			; next maskpattern
	move.l	a3,a2
	move.w	(a0),d1	
	addq.l	#2,a0
	add.l	d1,a2		

	move.l	(a1),$50(a5)
	move.l	a2,$4c(a5)
	move.l	a2,$54(a5)
	move.w	d3,$44(a5)
	move.w	#%0000110111111100,$40(a5)
	move.w	#%0000010000000001,$58(a5)

	dbf	d4,scopyotherbits

endcopybits:
	cmp.l	#endsinuslist,a0
	blt.s	sinusptrok2
	sub.l	#2*sinuslistlength,a0
sinusptrok2:
	addq.l	#2,a3			; next word in dest

	sub.l	d5,(a1)			; next word in sourcebuffer 
	addq.l	#2,(a1)			; again add extra lines

	dbf	d0,scopybit1

sinusfini:
	movem.l	(a7)+,a0-a6/d0-d7
	rts

sourceptr:	dc.l	scrolltemp+2


;----------------------------------------------	textpanel fillup
puttextinwindow:
	move.l	d0,-(a7)

	move.l	windowtextptr(pc),a0	; ptr textpos.
	lea.l	windowpos(pc),a1	; ptr pos on dest.screen
	lea.l	sletteraddr(pc),a2	; ptrlist to chars
	lea.l	$dff000,a5		; base

	move.b	fadecounter,d0
	tst.b	d0
	beq.s	nofade
	bsr	fade			; first handle fading
	bra	endputtextinwindow
nofade:	subq.b	#1,w_delay
	bne	endputtextinwindow
	move.b	w_speed(pc),w_delay

	addq.b	#1,w_mask		; next mask

	move.b	(a0),d0			; next char

w_eff1:	cmp.b	#SKIPLINE,d0		; check for effects
	bne.s	w_eff2
	sub.l	#19,a0
	bra	endline
w_eff2:	cmp.b	#SPEED2,d0
	bne.s	w_eff3
	move.b	#1,w_speed
	bra	w_command
w_eff3:	cmp.b	#SPEED1,d0
	bne.s	w_eff4
	move.b	#2,w_speed
	bra	w_command
w_eff4:	cmp.b	#WAIT,d0
	bne.s	w_eff5
	move.b	#200,w_delay
	bra	w_command
w_eff5:	cmp.b	#NEWPAGE,d0
	bne.s	w_eff6
	bra	w_newpage
w_eff6:	cmp.b	#RESTART,d0
	bne.s	w_eff7
	bra	w_restart
w_eff7:	cmp.b	#WOOSH,d0
	bne.s	w_eff8
	move.b	#2,w_speed
	move.b	#WOOSH,w_effect
	bra	w_command
w_eff8:	cmp.b	#REVERSE,d0
	bne.s	w_eff9
	move.b	#REVERSE,w_effect
	bra	w_command
w_eff9:	cmp.b	#LINEUP,d0
	bne.s	w_eff10
	sub.l	#[sfheight+1]*w_width,(a1)
	bra	w_command
w_eff10:cmp.b	#WAITSHORT,d0
	bne.s	w_eff11
	move.b	#50,w_delay
	bra	w_command
w_eff11:cmp.b	#LOGO,d0
	bne.s	w_eff12
	move.b	#4,fadecounter
	move.b	#LOGO,windowstatus
	bra	w_command
w_eff12:cmp.b	#TEXT,d0
	bne.s	w_eff13
	move.b	#4,fadecounter
	move.b	#TEXT,windowstatus
	bra	w_command
w_eff13:


	cmp.b	#WOOSH,w_effect
	bne.s	w_skip0
	cmp.b	#9,w_mask
	beq	endline
	bra.s	w_skip1
w_skip0:cmp.b	#28,w_mask		; all chars unmasked
	beq	endline
w_skip1:moveq.l	#0,d2
	move.b	w_mask(pc),d2		; nr of current mask
	asl.l	#2,d2			; make long (=offset in tab)

	moveq.l	#19,d1			; nr of chars on line

	move.l	a0,a4			; textptr temp.
	cmp.b	#REVERSE,w_effect
	bne.s	w_skip2
	add.l	#19,a4			; start at end of line  (text)
	add.l	#38,(a1)		;			(scrnpos)
w_skip2:

putlineloop:
	moveq.l	#0,d0
	move.b	(a4)+,d0
	cmp.b	#REVERSE,w_effect
	bne.s	w_skip3
	subq.l	#2,a4
w_skip3:
	lea.l	masklist(pc),a3
	move.w	#%0000111110111000,d3
	cmp.b	#" ",d0
	bne.s	nospace
	lea.l	masklist2(pc),a3	; spaces have special treatment
	move.w	#%0000111111000010,d3
nospace:asl.l	#2,d0			; make long (=offset in tab)

	move.l	(a2,d0),$50(a5)
	move.l	(a1),$54(a5)
	move.l	(a1),$48(a5)
	move.l	(a3,d2),$4c(a5)
	move.w	#$ffff,$44(a5)
	move.w	#$ffff,$46(a5)
	clr.w	$42(a5)
	move.w	#188,$64(a5)
	clr.w	$62(a5)
	move.w	#38,$60(a5)
	move.w	#38,$66(a5)
	move.w	d3,$40(a5)
	move.w	#%0000010000000001,$58(a5)

	cmp.b	#WOOSH,w_effect
	beq.s	w_skip4
	subq.l	#4,d2			; prev.mask for next char
w_skip4:				; unless WHOOSH (all chars same)

	addq.l	#2,(a1)			; next char pos : to right
	cmp.b	#REVERSE,w_effect
	bne.s	w_skip5
	subq.l	#4,(a1)			; or to left (reverse)
w_skip5:

	dbf	d1,putlineloop

	cmp.b	#REVERSE,w_effect
	beq.s	w_skip6
	sub.l	#20*2+2,(a1)		; back to start of line
w_skip6:addq.l	#2,(a1)			; or already there (reverse)
	bra.s	endputtextinwindow

w_command:
	addq.l	#1,a0			; skip command char
	bra.s	endputtextinwindow

endline:add.l	#[sfheight+1]*w_width,(a1)	; next line pos
	add.l	#20,a0			; next line text
	clr.b	w_effect		; stop effect
	clr.b	w_mask			; restart masks
	bra.s	endputtextinwindow

w_restart:
	lea.l	windowtext-1(pc),a0	; restart text
w_newpage:
	move.l	#window,(a1)		; restart pos
	addq.l	#1,a0			; skip command char
endputtextinwindow:
	move.l	a0,windowtextptr
	move.l	(a7)+,d0
	rts

		dc.l	mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9
masklist:	dc.l	mask8,mask7,mask6,mask5,mask4,mask3,mask2,mask1
		dc.l	mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1

		dc.l	mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1,mask1
masklist2:	dc.l	mask1,mask2,mask3,mask4,mask5,mask6,mask7,mask8
		dc.l	mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9,mask9

;----------------------------------------------	fade routine
fade:	move.l	a0,-(a7)
	subq.b	#1,fadedelay
	bne	f_exit
	move.b	#3,fadedelay
;------------------------------		fade select step
	cmp.b	#1,d0
	beq.s	f_towhite
	cmp.b	#2,d0
	beq	f_tonormal
	cmp.b	#4,d0
	beq	f_out
;------------------------------		fade in step 1
f_towhite:
	cmp.b	#TEXT,windowstatus	; select screen to initialise
	beq.s	f_startwindow		; (bplpt's)
f_startlogo:
	bsr	filllogo1plane
	move.w	#$0000,map2shift+2	; suppress mapshift for logo
	bra.s	f_skip1
f_startwindow:
	bsr	fillwindowplane
	move.w	#$0001,map2shift+2
f_skip1:
	move.l	fadepos(pc),a0
	move.w	(a0)+,d0
	tst.w	d0
	beq.s	f_whiteok
	move.l	a0,fadepos
	moveq.l	#7,d1
	lea.l	fade_tempstore(pc),a0
	move.l	a0,a1
f_twl:	move.w	d0,(a0)+
	dbf	d1,f_twl
	move.w	#$003,(a1)
	cmp.b	#TEXT,windowstatus
	bne.s	f_skip3
	move.w	#$003,8(a1)
f_skip3:bsr	fillwindowcolors
	bra	f_exit
f_whiteok:
	move.b	#2,fadecounter		; ready for next fade step
	bra	f_exit
;------------------------------		fade in step 2
f_tonormal:
	clr.b	fadecounter

	lea.l	screencols(pc),a0	; select colors to fade to
	cmp.b	#TEXT,windowstatus
	beq.s	f_tnwindow
	lea.l	l1_col,a0
f_tnwindow:

	lea.l	fade_tempstore(pc),a1
	move.l	a1,a2
	moveq.l	#7,d0
f_tnl:	move.w	(a0)+,d1
	move.w	(a2),d2

f_tnr:	move.w	d1,d3		; d1, d3 & a0   dest
	move.w	d2,d4		; d2, d4 & a2   work
	and.w	#$f00,d3	; d5 		new
	and.w	#$f00,d4
	cmp.w	d3,d4
	beq.s	f_tng
	sub.w	#$100,d4
	move.b	#2,fadecounter
f_tng:	move.w	d4,d5
	move.w	d1,d3
	move.w	d2,d4
	and.w	#$0f0,d3
	and.w	#$0f0,d4
	cmp.w	d3,d4
	beq.s	f_tnb
	sub.w	#$10,d4
	move.b	#2,fadecounter
f_tnb:	or.w	d4,d5
	move.w	d1,d3
	move.w	d2,d4
	and.w	#$00f,d3
	and.w	#$00f,d4
	cmp.w	d3,d4
	beq.s	f_tnend
	subq.w	#$1,d4
	move.b	#2,fadecounter
f_tnend:
	or.w	d4,d5
	move.w	d5,(a2)+
	dbf	d0,f_tnl
	bsr	fillwindowcolors
	bra	f_exit
;------------------------------		fade out
f_out:	move.b	#1,fadecounter

	lea.l	fade_tempstore(pc),a1
	move.l	a1,a2
	moveq.l	#7,d0
f_ol:	move.w	(a2),d2

f_or:	move.w	d2,d4		; d2, d4 & a2   work
	and.w	#$f00,d4	; d5 		new
	tst.w	d4		; dest = 0 (red & green) or 3 (blue)
	beq.s	f_og
	sub.w	#$100,d4
	move.b	#4,fadecounter
f_og:	move.w	d4,d5
	move.w	d2,d4
	and.w	#$0f0,d4
	tst.w	d4
	beq.s	f_ob
	sub.w	#$10,d4
	move.b	#4,fadecounter
f_ob:	or.w	d4,d5
	move.w	d2,d4
	and.w	#$00f,d4
	cmp.w	#$003,d4
	bgt.s	f_ob2
	beq.s	f_oend
f_ob1:	addq.w	#1,d4
	move.b	#4,fadecounter
	bra.s	f_oend
f_ob2:	subq.w	#1,d4
	move.b	#4,fadecounter
f_oend:	or.w	d4,d5
	move.w	d5,(a2)+
	dbf	d0,f_ol
	bsr	fillwindowcolors

	cmp.b	#1,fadecounter
	bne.s	f_exit

	move.l	#fadecols,fadepos

f_exit:	move.l	(a7)+,a0
	rts
;----------------------------------------------	calc startvalues
fillcopper:
calc_cs:lea.l	crds(pc),a0
	moveq	#0,d0
	moveq	#0,d1
ccsl:	add.l	d1,d0
	move.l	(a0)+,d1
	tst.l	d1
	bne.s	ccsl
	move.l	d0,calccs
clearsinusplane:
	lea.l	$70000,a0		; clear planes for sinusscroll
	move.l	#5120-1,d0		; (not within allocated mem!!)
cpl:	clr.l	(a0)+
	dbf	d0,cpl

fillcrdsplane:				; bplpt's for crds plane
	move.l	#crds,d1
	lea.l	crdspt,a1
	move.w	d1,6(a1)
	swap	d1
	move.w	d1,2(a1)

filleqplanes:				; bplpt's for 2 eq.planes
	move.l	#3,d0
	move.l	#eqpic,d1
	lea.l	eqpt,a1
	lea.l	eqpt2,a2
feql:	move.w	d1,6(a1)
	move.w	d1,6(a2)
	swap	d1
	move.w	d1,2(a1)
	move.w	d1,2(a2)
	swap	d1
	add.l	#40*7,d1
	addq.l	#8,a1
	addq.l	#8,a2
	dbf	d0,feql

tunesinuslist:				; get sinustab ready
	lea.l	sinuslist(pc),a0
	move.l	#realsinuslistlength-1,d0
tsl:	move.w	(a0),d1
	asr.w	#1,d1
	and.l	#$0000ffff,d1
	sub.w	#18,d1
	mulu	#s_width,d1
	move.w	d1,(a0)+
	dbf	d0,tsl
	rts
;----------------------------------------------	textpanel bplpt's (1&2)
fillwindowplane:
	move.l	#window,d1
	lea.l	windowpt,a1
	move.w	d1,6(a1)
	swap	d1
	move.w	d1,2(a1)
	swap	d1
	add.l	#40,d1
	move.w	d1,6+8(a1)
	swap	d1
	move.w	d1,2+8(a1)
	rts
;----------------------------------------------	logo bplpt's (1,2&3)
filllogo1plane:
	moveq.l	#2,d0
	move.l	#l1_pic,d1
	lea.l	windowpt,a1
fl1l:	move.w	d1,6(a1)
	swap	d1
	move.w	d1,2(a1)
	swap	d1
	add.l	#l1_planesize,d1
	addq.l	#8,a1
	dbf	d0,fl1l
	rts
;----------------------------------------------	scroll bplpt's (4&5)
fillscrollplane:
	move.l	scrollplaneptr(pc),d1
	lea.l	scrollpt,a1
	move.w	d1,6(a1)
	swap	d1
	move.w	d1,2(a1)
	swap	d1
	add.l	#40,d1
	move.w	d1,6+8(a1)
	swap	d1
	move.w	d1,2+8(a1)
	rts
;----------------------------------------------	put colors on screen
fillwindowcolors:
	movem.l	d0-d2/a2-a3,-(a7)
	lea.l	windowcolpt+2,a2
	lea.l	scrollcolpt+2,a3
	moveq.l	#7,d0
fwcl1:	move.w	(a1)+,d2	; a1 = source cols
	move.w	d2,(a2)
	addq.l	#4,a2

	move.w	d2,d3		; calc transparancy colors of scroll
	and.w	#$f00,d3	; (make darker)
	asr.w	#1,d3
	and.w	#$f00,d3
	move.w	d3,d4

	move.w	d2,d3
	and.w	#$0f0,d3
	asr.w	#1,d3
	and.w	#$0f0,d3
	or.w	d3,d4

	move.w	d2,d3
	and.w	#$00f,d3
	asr.w	#1,d3
	and.w	#$00f,d3
	or.w	d3,d4

	or.w	#$004,d4	; add bit blue
	move.w	d4,(a3)
	or.w	#$008,d4	; add more blue
	move.w	d4,8*4(a3)
	or.w	#$00f,d4	; add much blue
	move.w	d4,16*4(a3)

	addq.l	#4,a3

	dbf	d0,fwcl1

	movem.l	(a7)+,d0-d2/a2-a3
	rts
;----------------------------------------------	font addresses calc
calcfontdata:
	clr.l	d2			; from 0 to 128: ascii value
	lea.l	sletteraddr(pc),a1	; tab with ptrs (to be calc'ed)
cfdl:	lea.l	slettertab(pc),a3	; chars in font as they occur
	move.l	#sfontpic-2,d0
snewchlp:addq.l	#2,d0			; d0 = pos in fontpic
	move.b	(a3)+,d3
	cmp.l	#sendlettertab,a3
	bgt.s	snextch			; not found, skip
	cmp.b	d2,d3
	bne.s	snewchlp
sendnewch:
	move.l	d2,d3			
	asl.l	#2,d3			; make long (offset in tab)

	move.l	d0,(a1,d3)		; save address in tab
snextch:addq.b	#1,d2			; next ascii
	cmp.w	#128,d2
	blt.s	cfdl

	rts

sletteraddr:
	blk.l	128,0
;----------------------------------------------	vert.blank
waitvblank:	cmp.b	#$0,$dff006
		bne.s	waitvblank
		rts
;----------------------------------------------	extern files

fadecounter:		dc.b	0	; current fade action
sorigcharpos:		dc.b	16	; width chars scroll
scharpos:		dc.b	16	; plainscroll position char
delay:			dc.b	0	; boring delayer
w_delay:		dc.b	8	; boring delayer
w_mask:			dc.b	0	; current mask windowtext
w_speed:		dc.b	1	; speed windowtext
w_effect:		dc.b	0	; current effect windowtext

;--------------------------------------------	; pointer to:

scrollplaneptr:		dc.l	scroll1		; doubbuf sinusscroll
sinusptr:		dc.l	sinuslist	; sinuslist
sscrollptr:		dc.l	scrolltext	; scrolltext
sscrollrestart:		dc.l	textrestart	; textrestart
windowpos:		dc.l	window		; pos in textwindow
windowtextptr:		dc.l	windowtext	; windowtext
fadepos:		dc.l	fadecols	; current col (towhite)

;------------------------------------------------------

screencols:	dc.w	$003,$ccc,$666,$888,$003,$ccc,$666,$888
fadecols:	dc.w	$003,$114,$225,$336,$447,$558,$669,$77a
		dc.w	$88b,$99c,$aad,$bbe,$ccf,$ddf,$eef,$fff,0
realcs:		dc.w	$e549,$935e
fade_tempstore:	blk.w	8,$003

;------------------------------------------------------

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


; equaliser check. if the first word of mt_voiceX is not zero, a new
; note was played.

	lea.l	mt_voice1(pc),a6
	tst.w	(a6)
	beq.s	mt_chk1
	move.w	#$f,eq0+2
	move.w	#$f,eq0_2+2
mt_chk1:lea.l	mt_voice2(pc),a6
	tst.w	(a6)
	beq.s	mt_chk2
	move.w	#$f,eq1+2
	move.w	#$f,eq1_2+2
mt_chk2:lea.l	mt_voice3(pc),a6
	tst.w	(a6)
	beq.s	mt_chk3
	move.w	#$f,eq2+2
	move.w	#$f,eq2_2+2
mt_chk3:lea.l	mt_voice4(pc),a6
	tst.w	(a6)
	beq.s	mt_chk4
	move.w	#$f,eq3+2
	move.w	#$f,eq3_2+2
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

;------------------------------------------------------

>extern "df0:gfx/logo.320x168x3",l1_col
>extern "df0:gfx/font.paradox",sfontpic,sfontpicsize
>extern "df0:gfx/eq.40x7x4",eqpic

;------------------------------------------------------

crds:	dc.l	$79e7b00f,$c32cb018,$c32cb0db,$fbefbedf,$fbefbe1f
	dc.b	"Zylon Intro 100% written by Cool-G. Music by Avatar."
	dc.b	" Logo concept by Gator, redrawn by Cool-G. "
	dc.b	"ALL CONTENTS OF THIS INTRO ARE COPYRIGHT ZYLON 1991. "
	dc.b	"Rippers are kindly asked to fuck off. "
	dc.b	"This intro was originally made for the Computershop"
	dc.b	" in Turnhout ('PROMO DEMO'  Hi there Karel Adriaansen)"
	dc.b	" but after a while we decided to use it as a ZYLON intro."
	dc.b	" Interested coders should write to me (Cool-G) under:"
	dc.b	" Eikenlaan 21 - 3740 Bilzen - Belgium....    End of this"
	dc.b	" hidden message..."
slettertab:
	dc.b	" !",34,"#$%&'()*+,-./0123456789:;<=>? abcdefghijklmnopqrstuvwxyz"
	dc.b	"[\]^_`ABCDEFGHIJKLMNOPQRSTUVW   XYZ"
	dc.b	0
sendlettertab:
	even
;------------------------------------------------------
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

;------------------------------------------------------

copperlist:
		dc.l	$00960100
line11:		dc.b	l1tl-5,$0f,$ff,$fe
		dc.l	$01800004
line12:		dc.b	l1tl-4,$0f,$ff,$fe
		dc.l	$01800008
line13:		dc.b	l1tl-3,$0f,$ff,$fe
		dc.l	$0180000f
line14:		dc.b	l1tl-2,$0f,$ff,$fe
		dc.l	$01800008
line15:		dc.b	l1tl-1,$0f,$ff,$fe
		dc.l	$01800004
		dc.b	l1tl,$0f,$ff,$fe
		dc.l	$01800003
eqpt:		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.l	$01020000
eq0:		dc.l	$01820004
eq1:		dc.l	$01840004
		dc.l	$0186088a
eq2:		dc.l	$01880004
eq3:		dc.l	$01900004
		dc.l	$008e2931,$009029c1
		dc.l	$00920038,$009400d0
		dc.b	eqtl,$0f,$ff,$fe
		dc.l	$01004000,$00968100
		dc.b	eqtl+7,$0f,$ff,$fe
		dc.l	$00960100
		dc.l	$008e2931,$009029c1
		dc.l	$00920038,$009400d0
windowpt:	dc.l	$00e00000,$00e20000	; can be logo or 
		dc.l	$00e40000,$00e60000	; textpanel
		dc.l	$00e80000,$00ea0000	;
scrollpt:	dc.l	$00ec0000,$00ee0000
		dc.l	$00f00000,$00f20000
windowcolpt:	dc.l	$01800003,$01820ccc,$01840666,$01860888
		dc.l	$01880000,$018a0000,$018c0000,$018e0000
scrollcolpt:	dc.l	$01900004,$01920004,$01940004,$01960004
		dc.l	$01980004,$019a0004,$019c0004,$019e0004
		dc.l	$01a00008,$01a20008,$01a40008,$01a60008
		dc.l	$01a80008,$01aa0008,$01ac0008,$01ae0008
		dc.l	$01b0000f,$01b2000f,$01b4000f,$01b6000f
		dc.l	$01b8000f,$01ba000f,$01bc000f,$01be000f
map2shift:	dc.l	$01020001
numofplanes:	dc.l	$01005000
windowstart:	dc.b	wtl,$0f,$ff,$fe
		dc.l	$00968100
windowend:	dc.b	wbl,$0f,$ff,$fe
		dc.l	$00960100
lowerzone:	dc.l	$ffdffffe		; lowerzone - please check
eqpt2:		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.l	$01020000
eq0_2:		dc.l	$01820004
eq1_2:		dc.l	$01840004
		dc.l	$0186088a
eq2_2:		dc.l	$01880004
eq3_2:		dc.l	$01900004
		dc.l	$008e2931,$009029c1
		dc.l	$00920038,$009400d0
		dc.b	eq2tl,$0f,$ff,$fe
		dc.l	$01004000,$00968100
		dc.b	eq2tl+7,$0f,$ff,$fe
		dc.l	$00960100
line21:		dc.b	l2tl,$0f,$ff,$fe
		dc.l	$01800004
line22:		dc.b	l2tl+1,$0f,$ff,$fe
		dc.l	$01800008
line23:		dc.b	l2tl+2,$0f,$ff,$fe
		dc.l	$0180000f
line24:		dc.b	l2tl+3,$0f,$ff,$fe
		dc.l	$01800008
line25:		dc.b	l2tl+4,$0f,$ff,$fe
		dc.l	$01800004
		dc.b	l2tl+5,$0f,$ff,$fe
		dc.l	$01800000
		dc.l	$01001000
		dc.l	$009200c0
		dc.l	$009400c8
crdspt:		dc.l	$00e00000,$00e20000
		dc.b	crtl,$0f,$ff,$fe
		dc.l	$00968100,$01820333
		dc.b	crtl+1,$0f,$ff,$fe
		dc.l	$01820444
		dc.b	crtl+2,$0f,$ff,$fe
		dc.l	$01820555
		dc.b	crtl+3,$0f,$ff,$fe
		dc.l	$01820666
		dc.b	crtl+4,$0f,$ff,$fe
		dc.l	$01820777
		dc.b	crtl+5,$0f,$ff,$fe
		dc.l	$00960100
		dc.l	$360ffffe
		dc.w	$009c
		dc.w	%1000011110010000
		dc.l	$fffffffe		;end of copperlist

;------------------------------------------------------

sfdepth=		1
sfheight=		16
sfwidthW=		1
sftotwidthW=		1520/16
sftotheight=		16
sfwidthB=		sfwidthW*2
sftotwidthB=		sftotwidthW*2
sfontpicsize=		sftotwidthB*sftotheight*sfdepth

sinuslistlength=	[endsinuslist-sinuslist]/2
realsinuslistlength=	[realendsinuslist-sinuslist]/2

scroll1=		$70000
scroll2=		$72800
s_width=		40

l1_height=		168
l1_widthB=		40
l1_depth=		3
l1_planesize=		l1_widthB*l1_height
l1_picsize=		l1_planesize*l1_depth
l1_numofcol=		2^l1_depth

WAIT=			1	; pause for 2 second
RESTART=		2	; restart the text
SKIPLINE=		3	; don't print this line
SPEED2=			4	; turbo speed
SPEED1=			5	; normal speed
NEWPAGE=		6	; start a new page of text
WOOSH=			7	; put line in 1 time (no shifting)
REVERSE=		8	; start line at end & go to start
LINEUP=			9	; one line back
WAITSHORT=		10	; wait for 1 second
LOGO=			11	; fadeout text & display the logo
TEXT=			12	; fadeout logo & display the text

w_lines=		9
w_width=		40
w_height=		w_lines*[sfheight+2]
w_depth=		2

l1tl=			$43		; 1st line
eqtl=			l1tl+10		; 1st eq
wtl=			eqtl+7+10	; window top
wbl=			wtl+w_height-3	; w bott should be < $ff !
eq2tl=			wbl+5		; 2nd eq
l2tl=			eq2tl+10+7	; 2nd line
crtl=			l2tl+5+3	; crds

;------------------------------------------------------

scrolltemp:	blk.b	80*44,$00			; plain scroll
l1_col:		blk.w	l1_numofcol,0			; colors of logo
l1_pic:		blk.b	l1_picsize,0			; logo shape
sfontpic:	blk.b	sfontpicsize			; font shape
window:		blk.b	w_width*w_height*w_depth,0	; textpanel
eqpic:		blk.b	40*7*4,0			; equaliser
mt_data:	blk.b	mod_length+4,0			; nt module

;------------------------------------------------------
