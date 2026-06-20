
; never use a4 !!! it contains the swicthreg-address

; switchregister contains following swicth-bits:

a_menu=		0	; lmb pressed in menu zone
a_finish=	1	; request to quit
a_keypressed=	2	; key (except shift/ctrl) was pressed
a_shiftpressed=	3	; shift was pressed
a_ctrlpressed=	4	; ctrl was pressed
a_getkey=	5	; keyboard-input supported
a_cursor=	6	; blinking step of cursor
a_keyfound=	7	; last pressed key recognised

a_solid=	0	; no linetracing is done (filled boxes)
a_workofset=	1	; workofset considered (edit only) at print
a_screen=	2	; lmb pressed in editor screen
a_screenoff=	3	; a_screen is not noticed (for help etc)
a_cutsolid=	4	; temp storage for solid while cutting

>extern "df0:fonts/dfd.752x6x1",f_pic+32,f_picsize

;-------------------------------------------------------------------

top:	movem.l	d0-d7/a0-a6,-(a7)

	lea.l	switchreg(pc),a4
	lea.l	$dff000,a5
	bsr	initprog
	bset	#a_getkey,(a4)

	movem.l	d0-d7/a0-a6,-(a7)

	bsr	mainscreen

	movem.l	(a7)+,d0-d7/a0-a6

	bsr	exitprog

	movem.l	(a7)+,d0-d7/a0-a6
	rts
;-------------------------------
initprog:
	move.l	$4,a6
	move.l	#libname,a1
	jsr	-408(a6)
	move.l	d0,gfxbase
	jsr	-132(a6)

	bsr	waitvblank
	bsr	initdata

	move.w	$1c(a5),d0
	move.w	$1e(a5),d1
	move.w	$2(a5),d2
	move.w	#$7fff,$96(a5)
	move.w	#%1000001111110000,$96(a5)
	move.w	#$7fff,$9a(a5)
	move.w	#%1100000000111000,$9a(a5)

	or.w	#$8000,d0
	or.w	#$8000,d1
	or.w	#$8000,d2

	move.l	$68,oldkeyint+2
	move.l	#mykeyboard,$68
	move.l	$6c,oldint+2
	move.l	#int,$6c

	move.l	#copperlist,$80(a5)	; start democopper
	clr.w	$88(a5)

	rts
;-------------------------------
exitprog:
	bsr	waitvblank
	move.w	d2,$96(a5)
	move.w	d1,$9c(a5)
	move.w	d0,$9a(a5)
	move.l	oldkeyint+2(pc),$68
	move.l	oldint+2(pc),$6c
	move.l	gfxbase(pc),a6
	move.l	$26(a6),$80(a5)
	clr.w	$88(a5)
	move.l	$4,a6
	move.l	gfxbase(pc),a1
	jsr	-414(a6)
	jsr	-138(a6)
	move.w	#$8100,$96(a5)
	rts
;--------------------------------------
waitvblank:
	tst.b	$6(a5)
	bne.s	waitvblank
waitsummore:
	cmp.b	#$50,$6(a5)
	bne.s	waitsummore
	rts
;-------------------------------
waitblitter:
	btst	#14,$2(a5)
	bne.s	waitblitter
	rts
;-------------------------------
mainscreen:
	move.b	#cs_height,c_y
	bsr	setupplane
	bsr	setupmainmenu
mainloop:
	bsr	waitvblank
	bsr	checkmenu

	tst.b	op_code+1		; submenu item selected ?
	beq.s	noop
	bsr	op_handler
noop:
	btst	#a_finish,(a4)
	bne.s	endmainloop
	btst	#a_getkey,(a4)
	beq.s	mainloop

	bsr	getkey
	btst	#a_getkey,(a4)
	beq.s	mainloop

	bsr	printline
	bsr	interpretkey
	bra.s	mainloop
endmainloop:
	rts
;-------------------------------
checkmenu:
	btst	#a_menu,(a4)
	beq.s	endchm
	bsr	menuhandler
	bclr	#a_menu,(a4)
endchm:	rts
;-------------------------------
getkey:	clr.l	d1
	move.b	curdelay(pc),d1
	bsr	putcursor
dlp:	btst	#a_keypressed,(a4)
	beq.s	nokeyrepeat
	tst.b	keydelay
	bne.s	notyetrepeat
	bra.s	endgetkey
nokeyrepeat:
	bsr	checkmenu
	btst	#a_getkey,(a4)
	beq.s	endgetkey
	move.b	origkeydelay(pc),keydelay
	btst	#a_finish,(a4)
	bne.s	endgetkey
notyetrepeat:
	subq.b	#1,keydelay
	tst.b	keybuff
	bne.s	keygotten
	bsr	waitvblank
	dbf	d1,dlp
	bra.s	getkey
keygotten:
	move.b	keybuff,lastkey
	clr.b	keybuff
endgetkey:
	bsr	waitvblank
	rts
;-------------------------------
interpretkey:
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	move.b	lastkey(pc),d0
	move.b	c_x(pc),d1
	move.b	c_y(pc),d2
	btst	#a_shiftpressed,(a4)
	bne.s	interpretshift
	btst	#a_ctrlpressed,(a4)
	bne.s	interpretctrl
	cmp.b	#$4c,d0
	beq	k_up
	cmp.b	#$4f,d0
	beq	k_left
	cmp.b	#$4e,d0
	beq	k_right
	cmp.b	#$4d,d0
	beq	k_down
	cmp.b	#$41,d0
	beq	k_bs
	cmp.b	#$44,d0
	beq	k_nl
	bra.s	interpretrest
interpretshift:
	move.l	#10,d3
	cmp.b	#$4c+$80,d0
	beq.s	k_uplp
	cmp.b	#$4d+$80,d0
	beq	k_dwnlp
	cmp.b	#$4f+$80,d0
	beq	k_lftlp
	cmp.b	#$4e+$80,d0
	beq	k_rtlp
	bra.s	interpretrest
interpretctrl:		
	cmp.b	#$4c,d0
	beq	k_top
	cmp.b	#$4d,d0
	beq	k_bott
	bra.s	interpretrest
interpretrest:
	bsr	convertrawkey
	btst	#a_keyfound,(a4)
	beq	k_rts
	bsr	addchartoline
	bra	k_right

k_up:	cmp.b	#0,d2
	beq.s	k_pup
	subq.b	#1,d2
	bra	k_rts
k_pup:	tst.b	workofset
	beq	k_rts
	bsr	scrollup
	bsr	printline
	bra	k_rts
k_uplp:	bsr	k_up
	dbf	d3,k_uplp
	bra	k_rts
k_top:	move.b	#cs_height-1,c_y
	clr.b	workofset
	bsr	setupplane
	moveq.l	#0,d2
	moveq.l	#0,d1
	bra	k_rts
k_down:	cmp.b	#cs_height-1,d2
	beq.s	k_pdown
	addq.b	#1,d2
	bra	k_rts
k_pdown:cmp.b	#cp_height-cs_height,workofset
	beq	k_rts
	bsr	scrolldown
	bsr	printline
	bra.s	k_rts
k_dwnlp:bsr	k_down
	dbf	d3,k_dwnlp
	bra.s	k_rts
k_bott:	move.b	#cp_height-cs_height,workofset
	move.b	#cs_height-1,c_y
	bsr	setupplane
	move.l	#cs_height-1,d2
	moveq.l	#0,d1
	bra.s	k_rts
k_left:	cmp.b	#0,d1
	beq.s	k_rts
	subq.b	#1,d1
	bra.s	k_rts
k_lftlp:bsr	k_left
	dbf	d3,k_lftlp
	bra.s	k_rts
k_right:cmp.b	#cs_width-1,d1
	beq.s	k_rts
	addq.b	#1,d1
	bra.s	k_rts
k_rtlp:	bsr	k_right
	dbf	d3,k_rtlp
	bra.s	k_rts
k_bs:	bsr.s	k_left
	move.b	#32,char
	bsr	addchartoline
	bra.s	k_rts
k_nl:	move.b	#0,d1
	bra	k_down
k_rts:	move.b	d1,c_x
	move.b	d2,c_y
	bsr	printline
	bclr	#a_cursor,(a4)
	rts
;-------------------------------
convertrawkey:				;d0 = raw key
	movem.l	d0/a0,-(a7)
	bset	#a_keyfound,(a4)
	lea.l	rawtab(pc),a0
	move.b	(a0,d0),char
	tst.b	char
	bne.s	endcvk
	bclr	#a_keyfound,(a4)
endcvk:	movem.l	(a7)+,d0/a0
	rts
;-------------------------------
addchartoline:
	movem.l	d0-d5/a0-a1,-(a7)
	tst.b	char
	beq.s	endadd
	lea.l	textbuffer(pc),a0
	moveq.l	#0,d0
	move.b	c_y(pc),d0
	add.b	workofset(pc),d0
	mulu	#[cs_width+4],d0
	add.l	d0,a0
	moveq.l	#0,d0
	move.b	c_x(pc),d0
	add.l	d0,a0
	moveq.l	#0,d1
	move.b	char(pc),d1
	btst	#a_solid,1(a4)
	bne.s	add_nomask
	cmp.b	#32,d1
	bne.s	add_nospace
	move.b	3(a0),d1
	bra.s	add_nomask
add_nospace:
	moveq.l	#0,d0
	move.b	3(a0),d0
	cmp.b	#32,d0
	beq.s	add_nomask
	bsr	domasker
	move.b	d2,d1
	tst.b	d2
	bne.s	add_nomask
	move.b	char(pc),d1
add_nomask:
	move.b	d1,3(a0)
endadd:	movem.l	(a7)+,d0-d5/a0-a1
	rts
;-------------------------------
domasker:			; d0 = oldchar    d1 = newchar
	movem.l	d3/a1,-(a7)
	lea.l	maskertab(pc),a1
	moveq.l	#0,d2
	moveq.l	#0,d3
	move.w	#maskertab_l,d3
dmlp:	cmp.b	(a1)+,d0
	bne.s	dmlpe1
	cmp.b	(a1)+,d1
	bne.s	dmlpe2
	move.b	(a1)+,d2
	bra.s	dmlend
dmlpe1:	addq.l	#1,a1
dmlpe2:	addq.l	#1,a1
dmlpe:	dbf	d3,dmlp
dmlend:	movem.l	(a7)+,d3/a1
	rts
maskertab:
	dc.b	    "KLRKMSKNSKORKUT"	; |
	dc.b	"LKR","LMQLNTLORLUQ"	; L
	dc.b	"MKSMLQ","MNSMOTMUQ"	; J
	dc.b	"NKSNLTNMS","NOPNUP"	; 7
	dc.b	"OKROLROMTONP","OUP"	; 
	dc.b	"UKTULQUMQUNPUOP"	; -

	dc.b	"ZKR","ZMQZNTZORZUQ"	; L
	dc.b	">KS>LQ",">NS>OT>UQ"	; J
	dc.b	"<KS<LT<MS","<OP<UP"	; 7
	dc.b	"=KR=LR=MT=NP","=UP"	; 

	dc.b	"KZRK>SK<SK=R"	; |
	dc.b	   "L>QL<TL=R"	; L
	dc.b	"MZQ","M<SM=T"	; J
	dc.b	"NZTN>S","N=P"	; 7
	dc.b	"OZRO>TO<P"	; 
	dc.b	"UZQU>QU<PU=P"	; -

	dc.b	   "Z>QZ<TZ=R"	; L
	dc.b	">ZQ","><S>=T"	; J
	dc.b	"<ZT<>S","<=P"	; 7
	dc.b	"=ZR=>T=<P"	; 

	dc.b	"PKTPLTPMTPNPPOPPUP"	; T
	dc.b	"QKTQLQQMQQNTQOTQUQ"	; T upsidedown
	dc.b	"RKRRLRRMTRNTRORRUT"	; t
	dc.b	"SKSSLTSMSSNSSOTSUT"	; t mirror
	dc.b	"TKTTLTTMTTNTTOTTUT"	; +

	dc.b	"PZTP>TP<PP=P"	; T
	dc.b	"QZQQ>QQ<TQ=T"	; T upsidedown
	dc.b	"RZRR>TR<TR=R"	; t
	dc.b	"SZTS>SS<SS=T"	; t mirror
	dc.b	"TZTT>TT<TT=T"	; +
endmaskertab:
	even
maskertab_l=	endmaskertab-maskertab-1

;-------------------------------
scrolldown:
	movem.l	d0-d1/a0-a1,-(a7)
	move.l	#s_pic+[s_widthB*[cs_menuheight+1]*f_height],a0	;src
	move.l	#s_pic+[s_widthB*cs_menuheight*f_height],a1	;dest
	clr.w	d0
	addq.b	#1,workofset
	move.w	#%0000100111110000,d1
	bra.s	scroll
scrollup:
	movem.l	d0-d1/a0-a1,-(a7)
	move.l	#s_pic+[[cs_height+cs_menuheight-1]*[s_widthB*f_height]]-1,a0 ;src
	move.l	#s_pic+[[cs_height+cs_menuheight]*[s_widthB*f_height]]-1,a1   ;dest
	subq.b	#1,workofset
	move.w	#%0000100111110000,d1
	move.w	#$0002,d0
	bra.s	scroll
clearplane:
	movem.l	d0-d1/a0-a1,-(a7)
	move.l	#s_pic+[s_widthB*cs_menuheight*f_height],a1	;dest
	moveq.l	#0,d0
	move.l	d0,a0
	move.w	#%0000100100000000,d1
scroll:
	bsr	waitblitter
	move.l	a0,$50(a5)		;pta
	move.l	a1,$54(a5)		;ptd
	move.w	#$ffff,$44(a5)		;msk1
	move.w	#$ffff,$46(a5)		;mskl
	move.w	d0,$42(a5)		;con1
	clr.w	$64(a5)			;moda
	clr.w	$66(a5)			;modd
	move.w	d1,$40(a5)		;con0
	move.w	#s_blitsize,$58(a5)	;size
	movem.l	(a7)+,d0-d1/a0-a1
	rts
;-------------------------------
printline:
	move.l	d0,-(a7)
	moveq.l	#0,d0
	move.b	c_y(pc),d0
	cmp.b	#cs_height-1,d0
	bgt.s	endprintline
	add.b	workofset(pc),d0
	mulu	#[cs_width+4],d0
	add.l	#textbuffer,d0
	move.l	d0,textptr
	bset	#a_workofset,1(a4)
	bsr	printtext
	bclr	#a_workofset,1(a4)
endprintline:
	move.l	(a7)+,d0
	rts
;-------------------------------
putcursor:
	movem.l	d0/a0,-(a7)
	bchg	#a_cursor,(a4)
	btst	#a_cursor,(a4)
	bne.s	cursoron
	bsr	printline
	bra.s	endputcur
cursoron:
	lea.l	cur1text(pc),a0
	moveq.l	#0,d0
	move.b	c_y(pc),d0
	add.b	#cs_menuheight,d0
	move.b	d0,1(a0)
	move.b	c_x(pc),2(a0)
	move.l	a0,textptr
	bsr	printtext
endputcur:
	movem.l	(a7)+,d0/a0
	rts
;-------------------------------
printtext:
	movem.l	d0-d4/a0-a3,-(a7)
	move.l	textptr(pc),a2
	moveq.l	#0,d2
	moveq.l	#0,d0
	bsr	waitblitter
lineloop:
	move.b	(a2)+,d2
	cmp.b	#$ff,d2
	beq	endtext
	tst.b	d2
	beq.s	changeline
	bra.s	putchar
changeline:
	moveq.l	#0,d1
	moveq.l	#0,d2

	move.b	(a2)+,d1
	move.b	d1,linepos
	btst	#a_workofset,1(a4)
	beq.s	noworkofset
	sub.b	workofset(pc),d1
noworkofset:
	mulu	#s_widthB*f_height,d1

	move.b	(a2)+,d2
	move.b	d2,colpos

	add.l	d2,d1
	add.l	#s_pic,d1
	move.l	d1,a1
	bra.s	lineloop

putchar:lea.l	f_pic(pc),a0
	add.l	d2,a0

	move.b	5*f_totwidthB(a0),5*s_widthB(a1)
	move.b	4*f_totwidthB(a0),4*s_widthB(a1)
	move.b	3*f_totwidthB(a0),3*s_widthB(a1)
	move.b	2*f_totwidthB(a0),2*s_widthB(a1)
	move.b	  f_totwidthB(a0),  s_widthB(a1)
	move.b	  (a0),		 (a1)+
nextchar:bra	lineloop
endtext:move.l	a2,textptr		; save new pos. textptr
	movem.l	(a7)+,d0-d4/a0-a3
	rts

linepos:	dc.b	0
colpos:		dc.b	0
;-------------------------------
int:	movem.l	d0-d7/a0-a6,-(a7)

	bclr	#a_screen,1(a4)
	bclr	#a_menu,(a4)
	move.l	mouseptr(pc),a0		; mouseptr - diff shape
	lea.l	m_coords(pc),a1

	move.b	$a(a5),2(a1)
	move.b	$b(a5),3(a1)

;y:
	move.b	2(a1),d0
	sub.b	(a1),d0
	move.b	2(a1),(a1)
	ext.w	d0
	add.w	4(a1),d0

	cmp.w	#$2d,d0
	bge.s	i_y1ok
	move.w	#$2d,d0
i_y1ok:	cmp.w	#$120,d0
	ble.s	i_y2ok
	move.w	#$120,d0
i_y2ok:
	bclr	#2,3(a0)		; def = clear
	btst	#8,d0
	beq.s	i_clearyhigh
	bset	#2,3(a0)		; set sometimes
i_clearyhigh:
	move.w	d0,4(a1)
	move.b	d0,(a0)
	add.w	#mptrheight,d0
	bclr	#1,3(a0)
	btst	#8,d0
	beq.s	i_cleary2high
	bset	#1,3(a0)
i_cleary2high:
	move.b	d0,2(a0)

;x:
	move.b	3(a1),d0
	sub.b	1(a1),d0
	move.b	3(a1),1(a1)
	ext.w	d0
	add.w	6(a1),d0
	cmp.w	#114,d0
	bge.s	i_x1ok
	move.w	#114,d0
i_x1ok:	cmp.w	#428,d0
	ble.s	i_x2ok
	move.w	#428,d0
i_x2ok:
	bclr	#0,3(a0)
	btst	#0,d0
	beq.s	i_clearxtoggle
	bset	#0,3(a0)
i_clearxtoggle:
	move.w	d0,6(a1)
	asr.w	#1,d0
	move.b	d0,1(a0)

	move.l	(a0),menumouse		; coords to all mouses
	move.l	(a0),screenmouse
	move.l	(a0),screenupmouse
	move.l	(a0),screendownmouse

	move.w	6(a1),d0	; position x cursor acc mouse
	sub.w	#114,d0
	asr.w	#2,d0
	move.b	d0,c_tempx

	moveq.l	#0,d0
	move.w	4(a1),d0	; position y cursor acc mouse
	sub.w	#$2b,d0
	divu	#f_height,d0
	sub.l	#cs_menuheight,d0
	cmp.w	#0,d0
	bgt.s	i_y3ok2
	beq.s	i_y3ok1
i_menuactivated:
	move.l	#menumouse,mouseptr
	add.l	#cs_menuheight,d0
	btst	#6,$bfe001
	bne	i_fini
	move.b	d0,menuy
	move.b	c_tempx(pc),menux
	clr.b	c_tempx
	clr.b	c_tempy
	bset	#a_menu,(a4)
	bra	i_fini
i_y3ok1:move.l	#screenupmouse,mouseptr
	btst	#6,$bfe001
	bne	i_fini
	btst	#a_screenoff,1(a4)
	bne.s	i_fini
	bset	#a_screen,1(a4)
	bsr	printline
	move.l	d0,d2
	bsr	k_up
	bra.s	i_y5ok
i_y3ok2:move.l	#screenmouse,mouseptr
	btst	#a_screenoff,1(a4)
	bne.s	i_fini
	cmp.w	#cs_height-1,d0
	blt.s	i_y4ok
	move.l	#screendownmouse,mouseptr
	btst	#6,$bfe001
	bne	i_fini
	move.w	#cs_height-1,d0
	move.l	d0,d2
	move.b	d0,c_tempy
	bsr	printline
	bsr	k_down
	bra.s	i_y5ok
i_y4ok:	btst	#6,$bfe001
	bne	i_fini
i_y5ok:	move.b	d0,c_tempy
	bset	#a_screen,1(a4)
	bsr	printline
	move.w	c_tempx(pc),c_x
	bsr	putcursor

i_fini:	bsr	setupsprites
	movem.l	(a7)+,d0-d7/a0-a6
oldint:	jmp	$0



m_coords:	dc.b	0	;0	py
		dc.b	0	;1	px
		dc.b	0	;2	 y
		dc.b	0	;3	 x
		dc.w	0	;4	ty
		dc.w	0	;6	tx

mouseptr:	dc.l	menumouse

menumouse:	dc.b	0			; y pos start
		dc.b	0			; x pos
		dc.b	0			; y pos end
		dc.b	0			; extend x & y
mptrdat:	dc.w	%0000000000000000,0
		dc.w	%0000000000000000,0
		dc.w	%0000000000000000,0
		dc.w	%0000000000000000,0
		dc.w	%0000000000000000,0
		dc.w	%0000000000000000,0
		dc.w	%0000000111111000,0
		dc.w	%0000000111110000,0
		dc.w	%0000000111110000,0
		dc.w	%0000000111111000,0
		dc.w	%0000000110111100,0
		dc.w	%0000000100011110,0
		dc.w	%0000000000001111,0
		dc.w	%0000000000000110,0
zerohpos:	dc.l	0
screenmouse:	dc.b	0			; y pos start
		dc.b	0			; x pos
		dc.b	0			; y pos end
		dc.b	0			; extend x & y
		dc.w	%0000000000000000,0
		dc.w	%0000000000000000,0
		dc.w	%0000001100000000,0
		dc.w	%0000001100000000,0
		dc.w	%0000001100000000,0
		dc.w	%0000001100000000,0
		dc.w	%0111110011111000,0
		dc.w	%0111110011111000,0
		dc.w	%0000001100000000,0
		dc.w	%0000001100000000,0
		dc.w	%0000001100000000,0
		dc.w	%0000001100000000,0
		dc.w	%0000000000000000,0
		dc.l	0
screenupmouse:	dc.b	0			; y pos start
		dc.b	0			; x pos
		dc.b	0			; y pos end
		dc.b	0			; extend x & y
		dc.w	%0000000000000010,0
		dc.w	%0000000000000111,0
		dc.w	%0000001100000010,0
		dc.w	%0000001100000010,0
		dc.w	%0000001100000010,0
		dc.w	%0000001100000000,0
		dc.w	%0111110011111000,0
		dc.w	%0111110011111000,0
		dc.w	%0000001100000000,0
		dc.w	%0000001100000000,0
		dc.w	%0000001100000000,0
		dc.w	%0000001100000000,0
		dc.w	%0000000000000000,0
		dc.l	0
screendownmouse:dc.b	0			; y pos start
		dc.b	0			; x pos
		dc.b	0			; y pos end
		dc.b	0			; extend x & y
		dc.w	%0000000000000000,0
		dc.w	%0000000000000000,0
		dc.w	%0000001100000000,0
		dc.w	%0000001100000000,0
		dc.w	%0000001100000000,0
		dc.w	%0000001100000000,0
		dc.w	%0111110011111000,0
		dc.w	%0111110011111000,0
		dc.w	%0000001100000000,0
		dc.w	%0000001100000010,0
		dc.w	%0000001100000010,0
		dc.w	%0000001100000111,0
		dc.w	%0000000000000010,0
		dc.l	0

mptrheight=[zerohpos-mptrdat]/4
;------------------------------------------------------------
mykeyboard:
	movem.l	d0-d7/a0-a6,-(a7)

	move.b	$bfec01,d0
	not.b	d0
	ror.b	#1,d0

	btst	#7,d0
	bne.s	mkb_up
mkb_dwn:and.b	#$7f,d0
	cmp.b	#$60,d0
	beq.s	mkb_shd
	cmp.b	#$61,d0
	beq.s	mkb_shd
	cmp.b	#$63,d0
	beq.s	mkb_ctrd
	bset	#a_keypressed,(a4)
	move.b	d0,keybuff
	move.b	d0,lastkey
	btst	#a_shiftpressed,(a4)
	beq	mkb_rts
	add.b	#$80,keybuff
	add.b	#$80,lastkey
	bra	mkb_rts
mkb_shd:bset	#a_shiftpressed,(a4)
	clr.b	keybuff
	bclr	#a_keypressed,(a4)
	bra.s	mkb_rts
mkb_ctrd:bset	#a_ctrlpressed,(a4)
	clr.b	keybuff
	bclr	#a_keypressed,(a4)
	bra.s	mkb_rts
mkb_up:	and.b	#$7f,d0
	cmp.b	#$60,d0
	beq.s	mkb_shu
	cmp.b	#$61,d0
	beq.s	mkb_shu
	cmp.b	#$63,d0
	beq.s	mkb_ctru
	clr.b	keybuff
	bclr	#a_keypressed,(a4)
	bra.s	mkb_rts
mkb_shu:bclr	#a_shiftpressed,(a4)
	clr.b	lastkey
	bclr	#a_keypressed,(a4)
	bra.s	mkb_rts
mkb_ctru:bclr	#a_ctrlpressed,(a4)
	clr.b	keybuff
	bclr	#a_keypressed,(a4)
	bra.s	mkb_rts
mkb_rts:movem.l	(a7)+,d0-d7/a0-a6
oldkeyint:
	jmp	$0
;-------------------------------
initdata:
	lea.l	planept,a1
	move.l	#s_pic,d1
	move.w	d1,6(a1)
	swap	d1
	move.w	d1,2(a1)
	bsr	setupsprites
filltextbuffer:
	lea.l	textbuffer,a0
	move.l	#cs_menuheight,d0
	move.l	#cp_height-1,d1
ftp:	clr.b	(a0)+
	move.b	d0,(a0)+
	clr.b	(a0)+
	move.l	#cs_width-1,d2
ftp2:	move.b	#" ",(a0)+
	dbf	d2,ftp2
	move.b	#$ff,(a0)+
	addq.b	#1,d0
	dbf	d1,ftp
	rts
;-------------------------------
setupsprites:
	movem.l	d0-d1/a1,-(a7)
	btst	#a_screenoff,1(a4)
	bne.s	endsus
	lea.l	spritept,a1
	move.l	mouseptr(pc),d0
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	move.l	#zerohpos,d0
	move.l	#6,d1
susp:	addq.l	#8,a1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	dbf	d1,susp
endsus:	movem.l	(a7)+,d0-d1/a1
	rts
;-------------------------------
setupplane:
	movem.l	d0-d1/a0,-(a7)
	moveq.l	#0,d0
	move.b	#cs_height-1,d0
	lea.l	c_y(pc),a0
	move.b	(a0),d1
sup:	move.b	d1,(a0)
	subq.b	#1,d1
	bsr	printline
	dbf	d0,sup
	movem.l	(a7)+,d0-d1/a0
	rts
;-------------------------------
clearmenu:
	move.l	#m_empty,textptr
	bsr	printtext
	rts
;-------------------------------
setupmainmenu:
	movem.l	d0/a0,-(a7)
	lea.l	m_mainlist(pc),a0
	move.l	a0,m_mainsubptr
	bra.s	dmloop
;-------------------------------
displaymenu:
	movem.l	d0/a0,-(a7)
	move.l	m_mainsubptr(pc),a0
dmloop:	move.l	(a0)+,d0
	tst.l	d0
	beq.s	enddm
	add.l	#14,d0			; 10 databytes per menuitem
	move.l	d0,textptr
	bsr	printtext
	bra.s	dmloop
enddm:	movem.l	(a7)+,d0/a0
	rts
;-------------------------------
menuhandler:
	move.b	menux(pc),d0
	move.b	menuy(pc),d1
	move.l	m_mainsubptr(pc),a0
	tst.l	(a0)
	beq.s	endmhnd
mhnd:	move.l	(a0)+,a1
	cmp.l	#0,a1
	beq.s	endmhnd
	cmp.b	(a1),d0
	blt.s	mhnd
	cmp.b	2(a1),d0
	bgt.s	mhnd
	cmp.b	1(a1),d1
	blt.s	mhnd
	cmp.b	3(a1),d1
	bgt.s	mhnd
	tst.b	4(a1)
	beq.s	setupsubmenu
	move.b	5(a1),op_code+1		; op-code low byte
	move.l	6(a1),a0
	move.l	10(a1),zd_ptr		; zonedata-address
	jsr	(a0)
endmhnd:rts
setupsubmenu:
	move.b	5(a1),op_code		; op-code high byte
	bsr	clearmenu
	move.l	a1,d0
	add.l	#14,d0
	move.l	d0,textptr
	bsr	printtext
	move.l	6(a1),m_mainsubptr
	bsr	displaymenu
	rts
;--------------------------------------
r_back3:
	move.l	#helplist,helpptr
	bsr	k_top
r_back2:bset	#a_getkey,(a4)
	bclr	#a_screenoff,1(a4)
r_dummyroutine:
r_back1:
	bsr	clearmenu
	bsr	setupmainmenu
	clr.b	op_status
	clr.w	op_code
	rts
;--------------------------------------
r_besure:move.l	#5,d0
r_bslp:	bclr	#a_menu,(a4)
	bsr	waitvblank
	dbf	d0,r_bslp
	rts
;--------------------------------------
r_quit:	bsr.s	r_besure
	bsr.s	r_besure
	bsr.s	r_besure
	btst	#a_menu,(a4)
	beq.s	r_noquit
	bset	#a_finish,(a4)
r_noquit:
	rts
;--------------------------------------
r_trsp:	bclr	#a_solid,1(a4)
	move.l	#m_trsp,m_mainlist
	bsr.s	r_besure
	bsr.s	r_back1
	rts
r_sold:	bset	#a_solid,1(a4)
	move.l	#m_sold,m_mainlist
	bsr.s	r_besure
	bsr.s	r_back1
	rts
;--------------------------------------
r_new:	bsr.s	r_besure
	bsr.s	r_besure
	bsr.s	r_besure
	btst	#a_menu,(a4)
	beq.s	r_nonew
	bsr	filltextbuffer
	clr.b	workofset
	bsr	k_top	
r_nonew:bra	r_back1
;--------------------------------------
r_help0:bset	#a_screenoff,1(a4)
	move.l	#m_helpextra,a1
	bsr	setupsubmenu
	bclr	#a_getkey,(a4)
	move.l	#helplist,helpptr
r_help1:bsr	clearplane
	move.l	helpptr(pc),a0
	move.l	(a0)+,textptr
	cmp.l	#0,(a0)
	bne.s	r_helpok
	move.l	#helplist,a0
r_helpok:move.l	a0,helpptr
	bsr	printtext
	bsr	r_besure
	rts
;-------------------------------------
r_change_type:
	move.l	linetypeptr,a0
	move.l	(a0)+,m_linesub
	cmp.l	#0,(a0)
	bne.s	r_chlok
	move.l	#linetypelist,a0
r_chlok:move.l	a0,linetypeptr
	bsr	displaymenu
	bsr	r_besure
	rts
;-------------------------------------
r_dottedon:
	move.l	#m_line3a,m_linesub+4
	bsr	r_besure
	bra	displaymenu
r_dottedoff:
	move.l	#m_line3b,m_linesub+4
	bsr	r_besure
	bra	displaymenu
;-------------------------------------
r_zone:	bsr	clearmenu
	move.l	#m_cancellist,m_mainsubptr
	bsr	displaymenu
	move.l	#t_zone,textptr
	bsr	printtext
	move.b	#$01,op_status
	bclr	#a_getkey,(a4)
	rts
;-------------------------------------
r_line:	clr.l	m_mainsubptr
	bsr	clearmenu
	move.l	#t_line,textptr
	bsr	printtext
	move.b	#$02,op_status
	bclr	#a_getkey,(a4)
	rts
;-------------------------------------
r_paste:bsr	clearmenu
	move.l	#m_cancellist,m_mainsubptr
	bsr	displaymenu
	move.l	#t_paste,textptr
	bsr	printtext
	move.b	#$01,op_status
	bclr	#a_getkey,(a4)
	rts
;------------------------------------------------------------
op_handler:
	lea.l	op_code(pc),a0
	cmp.b	#$01,(a0)			; boxes
	beq.s	op_zone

	cmp.w	#$0301,(a0)			; edit
	beq.s	op_zone
	cmp.w	#$0302,(a0)			; edit
	beq.s	op_zone
	cmp.w	#$0303,(a0)			; paste
	beq.s	op_paste
	rts
	
op_paste:btst	#a_screen,1(a4)
	beq.s	op_end
	lea.l	cursorpos(pc),a0
	move.l	10(a0),4(a0)
	lea.l	undobuffer1,a0
	lea.l	textbuffer(pc),a1
	bsr	z_copy
	bsr	z_redraw
	clr.b	op_status
	bsr	r_back2
	rts

op_zone:cmp.b	#$01,op_status
	beq.s	zone_1
	cmp.b	#$02,op_status
	beq.s	zone_2
	clr.b	op_status
op_end:	rts

zone_1:	btst	#a_screen,1(a4)
	beq.s	zone_end
	lea.l	cursorpos(pc),a0
	move.w	(a0),4(a0)
	move.b	#$02,op_status
	rts
zone_2:	btst	#6,$bfe001
	beq.s	zone_end
	lea.l	cursorpos(pc),a0
	move.w	(a0),8(a0)
	bsr	dominmax
	move.l	4(a0),10(a0)		; coords/size to undobuff
	move.w	4(a0),(a0)
	move.b	workofset,oldworkofset
	lea.l	textbuffer(pc),a0
	lea.l	undobuffer1,a1
	bsr	z_copy			; text to undobuff
	bsr	z_fill
	lea.l	cursorpos(pc),a0
	move.w	4(a0),(a0)
	bsr	z_redraw
	bsr	r_back2
	move.w	4(a0),(a0)
	bsr	putcursor
	clr.b	op_status
zone_end:rts
;-------------------------------------
z_fill:
	movem.l	d0-d3/a0-a2,-(a7)

	cmp.w	#$0301,op_code
	bne.s	z_fnocut
	btst	#a_solid,1(a4)
	bne.s	z_fnocut
	bset	#a_solid,1(a4)
	bset	#a_cutsolid,1(a4)
z_fnocut:
	move.l	zd_ptr(pc),a2
	lea.l	cursorpos(pc),a1
	lea.l	zonecoords,a0
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	move.b	1(a0),d0	; y1
	move.b	3(a0),d1	; dy
	move.b	0(a0),d2	; x1
z_topleft:
	moveq.l	#0,d3
	move.b	2(a0),d3	; dx
	move.b	d0,c_y
	move.b	d2,c_x
	move.b	(a2)+,char
	bsr	addchartoline
	subq.l	#2,d3
	move.b	(a2)+,char
	cmp.b	#3,d3
	blt.s	z_topright
z_topmiddle:
	addq.b	#1,c_x
	bsr	addchartoline
	dbf	d3,z_topmiddle
z_topright:
	addq.b	#1,c_x
	move.b	(a2)+,char
	bsr	addchartoline
	bsr	printline
	subq.b	#2,d1

	cmp.b	#3,c_dy
	blt.s	z_bottomleft
z_middleloop:
z_middleleft:
	moveq.l	#0,d3
	move.b	2(a0),d3	; dx
	addq.b	#1,c_y
	move.b	d2,c_x
	move.b	(a2)+,char
	bsr	addchartoline
	subq.b	#2,d3
	move.b	(a2)+,char
	cmp.b	#3,d3
	blt.s	z_middleright
z_middlemiddle:
	addq.b	#1,c_x			; middle middle
	bsr	addchartoline
	dbf	d3,z_middlemiddle
z_middleright:
	addq.b	#1,c_x			; middle right
	move.b	(a2)+,char
	bsr	addchartoline

	subq.l	#3,a2			; middleline again

	dbf	d1,z_middleloop
	bsr	printline

z_bottomleft:
	addq.l	#3,a2
	addq.b	#1,c_y
	moveq.l	#0,d3
	move.b	2(a0),d3		; dx
	move.b	d2,c_x
	move.b	(a2)+,char		; top left
	bsr	addchartoline
	subq.l	#2,d3
	move.b	(a2)+,char
	cmp.b	#3,d3
	blt.s	z_bottomright
z_bottommiddle:
	addq.b	#1,c_x			; top middle
	bsr	addchartoline
	dbf	d3,z_bottommiddle
z_bottomright:
	addq.b	#1,c_x			; top right
	move.b	(a2)+,char
	bsr	addchartoline
	bsr	printline

	btst	#a_cutsolid,1(a4)
	beq.s	z_fend
	bclr	#a_cutsolid,1(a4)
	bclr	#a_solid,1(a4)
z_fend:
	movem.l	(a7)+,d0-d3/a0-a2
	rts
;-------------------------------------
z_redraw:
	movem.l	d0-d1/a0,-(a7)
	lea.l	cursorpos(pc),a0
	moveq.l	#0,d0
	moveq.l	#0,d1
	move.b	1(a0),d0	; y
	move.b	7(a0),d1	; dy
;	addq.b	#2,d1
z_redr:	move.b	d0,c_y
	bsr	printline
	addq.b	#1,d0
	dbf	d1,z_redr
	movem.l	(a7)+,d0-d1/a0
	rts
;-------------------------------------
z_copy:			; a0 = source,  a1 = dest,
			; c_x1/y1 and c_dx/dy sizing

	movem.l	d0-d3/a0-a1,-(a7)

	move.w	c_x,c_tempx
	move.l	#cs_width+4,d5
	moveq.l	#0,d0
	move.b	c_y1(pc),d0
	add.b	oldworkofset,d0
	mulu	d5,d0
	moveq.l	#0,d1
	move.b	c_x1(pc),d1
	addq.b	#3,d1
	add.l	d1,d0
	add.l	d0,a0		; source

	moveq.l	#0,d0
	move.b	c_y(pc),d0
	add.b	workofset,d0
	mulu	d5,d0
	moveq.l	#0,d1
	move.b	c_x(pc),d1
	addq.b	#3,d1
	add.l	d1,d0
	add.l	d0,a1		; dest

	moveq.l	#0,d0
	move.b	c_dy(pc),d0		; height

	moveq.l	#0,d1
	move.b	c_dx,d1
	add.b	c_x,d1
	cmp.l	#cs_width+3,d1
	ble.s	z_copyok
	move.l	#cs_width,d1
	sub.b	c_x,d1
	move.b	d1,c_dx			; maximum width
z_copyok:
	moveq.l	#0,d4
	move.b	c_dx(pc),d4		; ok width
	subq.l	#1,d5
	sub.l	d4,d5			; modulo

	moveq.l	#0,d6
	move.b	c_dy(pc),d6

z_clp0:	moveq.l	#0,d3
	move.b	c_dx(pc),d3
	move.b	c_tempx(pc),c_x

z_clp1:	move.b	(a0)+,d1		; new
	move.b	(a1),d0			; old
	btst	#a_solid,1(a4)
	bne.s	z_cnomask
	cmp.b	#32,d0
	beq.s	z_cnomask
	cmp.b	#32,d1
	bne.s	z_cnospace
	move.b	d0,d1
z_cnospace:	
	bsr	domasker
	tst.b	d2
	beq.s	z_cnomask
	move.b	d2,d1
z_cnomask:
	move.b	d1,(a1)+
	cmp.b	#$ff,(a1)
	beq.s	z_cgo
	addq.b	#1,c_x
	dbf	d3,z_clp1
z_cgo:	add.l	d5,a0
	add.l	d5,a1
	addq.b	#1,c_y
	dbf	d6,z_clp0

	move.w	c_tempx,c_x
	movem.l	(a7)+,d0-d3/a0-a1
	rts
;------------------------------------------------------------

;------------------------------------------------------------
dominmax:
	movem.l	d0/a0,-(a7)
	lea.l	zonecoords(pc),a0
	move.b	(a0),d0
	cmp.b	4(a0),d0
	blt.s	dmmok1			; largest x
	move.b	4(a0),(a0)
	move.b	d0,4(a0)
dmmok1:	move.b	1(a0),d0
	cmp.b	5(a0),d0
	blt.s	dmmok2			; largest y
	move.b	5(a0),1(a0)
	move.b	d0,5(a0)
dmmok2:	move.b	4(a0),d0		; delta x and y
	sub.b	(a0),d0
;	subq.b	#1,d0
	move.b	d0,2(a0)
	move.b	5(a0),d0
	sub.b	1(a0),d0
;	subq.b	#1,d0
	move.b	d0,3(a0)
	movem.l	(a7)+,d0/a0
	rts




cursorpos:
c_x:		dc.b	0	; 0
c_y:		dc.b	0	; 1
c_tempx:	dc.b	0	; 2
c_tempy:	dc.b	0	; 3

zonecoords:
c_x1:		dc.b	0	; 0
c_y1:		dc.b	0	; 1
c_dx:		dc.b	0	; 2
c_dy:		dc.b	0	; 3
c_x2:		dc.b	0	; 4
c_y2:		dc.b	0	; 5

pastebuff_coords:
z_x1:		dc.b	0	; 0
z_y1:		dc.b	0	; 1
z_dx:		dc.b	0	; 4
z_dy:		dc.b	0	; 5

keybuff:	dc.b	0
lastkey:	dc.b	0
keydelay:	dc.b	0
origkeydelay:	dc.b	20
curdelay:	dc.b	15
char:		dc.b	0
workofset:	dc.b	0
oldworkofset:	dc.b	0

libname:	dc.b	"graphics.library",0
		even
gfxbase:	dc.l	0
textptr:	dc.l	0	; ptr to text (printtext:)
zd_ptr:		dc.l	0	; ptr to zone-data (shape of box)
switchreg:	dc.l	0	; contains control-bits


;------------------------------------------------------------
f_depth=	1		; planes
f_height=	6		; hoogte letter
f_totwidthB=	752/8		; breedte fontpic WORDS
f_totheight=	6		; hoogte fontpic
f_widthB=	1
f_picsize=	f_totwidthB*f_totheight*f_depth
	
f_pic:		blk.b	32,0
		blk.b	f_picsize

; shifted= +$80

rawtab:	dc.b	0,49,50,51,52,53,54,55,56,57,48,45,0,0,0,48,113,119,101,114,116,121
	dc.b	117,105,111,112,0,0,0,49,50,51,97,115,100,102,103,104,106,107,108
	dc.b	59,39,0,0,52,53,54,0,122,120,99,118,98,110,109,44,46,47,0,46,55,56,57
	dc.b	32,0,0,0,0,0,0,0,0,0,45,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
rsh:	dc.b	0,33,0,35,0,37,0,0,42,40,41,0,43,0,0,48,113,119,101,114,116,121
	dc.b	117,105,111,112,0,0,0,49,50,51,97,115,100,102,103,104,106,107,108
	dc.b	58,39,0,0,52,53,54,0,122,120,99,118,98,110,109,44,46,63,0,46,55,56,57
	dc.b	32,0,0,0,0,0,0,0,0,0,45,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
endrawtab:
	even
;--------------------------------------------------------------
s_widthB=	80
s_height=	256
s_pic:		blk.b	s_height*s_widthB,0
		even
;------------------------------------------------------------
cs_menuheight=	6
cs_height=	s_height/f_height-1-cs_menuheight
cs_width=	s_widthB-1
cp_height=	80
;------------------------------------------------------------
s_blitsize=	[[cs_height-1]*f_height]*64+[s_widthB/2]
;------------------------------------------------------------

copperlist:
spritept:	dc.l	$01200000,$01220000
		dc.l	$01240000,$01260000
		dc.l	$01280000,$012a0000
		dc.l	$012c0000,$012e0000
		dc.l	$01300000,$01320000
		dc.l	$01340000,$01360000
		dc.l	$01380000,$013a0000
		dc.l	$013c0000,$013e0000
		dc.l	$01a002f2
		dc.l	$01a202f2
		dc.l	$01a402f2
		dc.l	$00960100
		dc.l	$01800000
		dc.l	$018204a4
planept:	dc.l	$00e00000
		dc.l	$00e20000
		dc.l	$01009000
		dc.l	$01080000
		dc.l	$010a0000
		dc.l	$00920038
		dc.l	$009400d0
		dc.l	$320ffffe
		dc.l	$00968100
		dc.l	$ffdffffe
		dc.l	$320ffffe
		dc.l	$00960100
		dc.l	$fffffffe

cur1text:	dc.b	0,0,0,"*",$ff
cur2text:	dc.b	0,0,0," ",$ff
		even

; op-status reflects status of current action:
;	0 = no action selected
;	1 = 1st stage
;	2 = 2nd stage
;	...
;	$ff = action terminated (back to zero)
; op-code contains current action
;	0 = no action selected
;	1 = box
;	2 = line
;	...

op_code:	dc.w	0
op_status:	dc.b	0
		even

m_mainlist:	dc.l	m_trsp,m_box0,m_line0,m_proj0,m_edit0,m_help0,m_quit,0
m_boxsub:	dc.l	m_box1,m_box2,m_box3,m_box4,m_box5,m_box6,m_back1,0
m_linesub:	dc.l	m_line4a,m_line3a,m_line1,m_line2,m_back1,0
m_projsub:	dc.l	m_proj1,m_proj2,m_proj3,m_proj4,m_back1,0
m_editsub:	dc.l	m_edit1,m_edit2,m_edit3,m_back1,0
m_helpsub:	dc.l	m_help1,m_back3,0
m_cancellist:	dc.l	m_cancel,0

m_mainptr:	dc.l	0
m_mainsubptr:	dc.l	0
m_subptr:	dc.l	0

itemnumber:	dc.b	0	; number of item activated
menux:		dc.b	0	; xpos menucursor
menuy:		dc.b	0	; ypos menucursor
		even

helpptr:	dc.l	helplist
helplist:	dc.l	t_help1,t_help2,t_help3,0

linetypeptr:	dc.l	linetypelist
linetypelist:	dc.l	m_line4a,m_line4b,m_line4c,m_line4d,m_line4e,m_line4f,m_line4g,0


; menustructure:
;	dc.b	X1,Y1,X2,Y2,SUB,itemnumber
;	dc.l	addr.submenulist,addr zonedata
;
;   if sub==0, addr is the addres of the submenulist 2B displayed
;	       number contains op-code high byte
;   if sub!=0, addr is the addres of the subroutine 2B executed
;	       number contains op-code low byte
;   at zonedata are the various data for the operation 2b performed
;	like box shape, arrow data etc.

m_box0:		dc.b	1,0,11,2,0,1
		dc.l	m_boxsub,0
		dc.b	0,0,1, "OUUUUUUUUUN"
		dc.b	0,1,1, "K  boxes  K"
		dc.b	0,2,1, "LUUUUUUUUUM",$ff
		even
m_line0:	dc.b	12,0,22,2,0,2
		dc.l	m_linesub,0
		dc.b	0,0,12,"OUUUUUUUUUN"
		dc.b	0,1,12,"K  lines  K"
		dc.b	0,2,12,"LUUUUUUUUUM",$ff
		even
m_edit0:	dc.b	23,0,33,2,0,3
		dc.l	m_editsub,0
		dc.b	0,0,23,"OUUUUUUUUUN"
		dc.b	0,1,23,"K  edit   K"
		dc.b	0,2,23,"LUUUUUUUUUM",$ff
		even
m_proj0:	dc.b	34,0,44,2,0,0
		dc.l	m_projsub,0
		dc.b	0,0,34,"OUUUUUUUUUN"
		dc.b	0,1,34,"K project K"
		dc.b	0,2,34,"LUUUUUUUUUM",$ff
		even
m_trsp:		dc.b	45,0,55,2,1,0
		dc.l	r_sold,0
		dc.b	0,0,45,"OUUUUUUUUUN"
		dc.b	0,1,45,"K transp. K"
		dc.b	0,2,45,"LUUUUUUUUUM",$ff
		even
m_sold:		dc.b	45,0,55,2,1,0
		dc.l	r_trsp,0
		dc.b	0,0,45,"OUUUUUUUUUN"
		dc.b	0,1,45,"K  solid  K"
		dc.b	0,2,45,"LUUUUUUUUUM",$ff
		even
m_help0:	dc.b	56,0,66,2,1,0
		dc.l	r_help0,0
		dc.b	0,0,56,"OUUUUUUUUUN"
		dc.b	0,1,56,"K help !! K"
		dc.b	0,2,56,"LUUUUUUUUUM",$ff
		even
m_helpextra:	dc.b	56,0,66,2,0,0
		dc.l	m_helpsub,0
		dc.b	0,0,56,"OUUUUUUUUUN"
		dc.b	0,1,56,"K help !! K"
		dc.b	0,2,56,"LUUUUUUUUUM",$ff
		even
m_quit:		dc.b	67,0,77,2,1,0
		dc.l	r_quit,0
		dc.b	0,0,67,"OUUUUUUUUUN"
		dc.b	0,1,67,"K quit !! K"
		dc.b	0,2,67,"LUUUUUUUUUM"
		dc.b	0,4,2, "this is only a prerelease...  please check out the help-pages for more info",$ff
		even
m_back1:	dc.b	67,0,77,2,1,0
		dc.l	r_back1,0
		dc.b	0,0,67,"OUUUUUUUUUN"
		dc.b	0,1,67,"Kmain menuK"
		dc.b	0,2,67,"LUUUUUUUUUM",$ff
		even
m_back3:	dc.b	67,0,77,2,1,0
		dc.l	r_back3,0
		dc.b	0,0,67,"OUUUUUUUUUN"
		dc.b	0,1,67,"Kmain menuK"
		dc.b	0,2,67,"LUUUUUUUUUM",$ff
		even
m_cancel:	dc.b	68,0,77,2,1,$ff
		dc.l	r_back2,0
		dc.b	0,0,68,"OUUUUUUUUN"
		dc.b	0,1,68,"K cancel K"
		dc.b	0,2,68,"LUUUUUUUUM",$ff
		even
m_box1:		dc.b	1,3,11,5,1,1
		dc.l	r_zone,zd_box1
		dc.b	0,3,1, "OUUUUUUUUUN"
		dc.b	0,4,1, "K  plain  K"
		dc.b	0,5,1, "LUUUUUUUUUM",$ff
		even
zd_box1:	dc.b	"OUNK KLUM"
		even
m_box2:		dc.b	12,3,22,5,1,2
		dc.l	r_zone,zd_box2
		dc.b	0,3,12,"]UUUUUUUUU^"
		dc.b	0,4,12,"K storage K"
		dc.b	0,5,12,"`UUUUUUUUU_",$ff
		even
zd_box2:	dc.b	"]U^K K`U_"
		even
m_box3:		dc.b	23,3,33,5,1,3
		dc.l	r_zone,zd_box3
		dc.b	0,3,23,"]UUUUUUUU@ "
		dc.b	0,4,23,"K termin. D"
		dc.b	0,5,23,"`UUUUUUUU[ ",$ff
		even
zd_box3:	dc.b	"]U",0,"K",0,0,"`U",0
		even
m_box4:		dc.b	34,3,44,5,1,4
		dc.l	r_zone,zd_box4
		dc.b	0,3,34,"=UUUUUUUUU<"
		dc.b	0,4,34,"K process K"
		dc.b	0,5,34,"ZUUUUUUUUU>",$ff
		even
zd_box4:	dc.b	"=U<K KZU>"
		even
m_box5:		dc.b	45,3,55,5,1,5
		dc.l	r_zone,zd_box5
		dc.b	0,3,45,"OUUUUUUUUUN"
		dc.b	0,4,45,"K doc \UUUM"
		dc.b	0,5,45,"ZUUUU[",$ff
		even
zd_box5:	dc.b	"OUNK",0,"KZ",0,0
		even
m_box6:		dc.b	56,3,66,5,1,6
		dc.l	r_zone,zd_box6
		dc.b	0,3,56," A"
		dc.b	0,4,56,"C?D quest. "
		dc.b	0,5,56," B",$ff
		even
zd_box6:	dc.b	0,0,0,0,0,0,0,0,0
		even
m_line1:	dc.b	1,3,12,5,1,0
		dc.l	r_dummyroutine,0
		dc.b	0,3,1, "OUUUUUUUUUUN"
		dc.b	0,4,1, "K go ahead K"
		dc.b	0,5,1, "LUUUUUUUUUUM",$ff
		even
m_line2:	dc.b	13,3,27,5,1,0
		dc.l	r_change_type,0
		dc.b	0,3,13,"OUUUUUUUUUUUUUN"
		dc.b	0,4,13,"K change type K"
		dc.b	0,5,13,"LUUUUUUUUUUUUUM"
		dc.b	0,3,45," current type:",$ff
		even
m_line3a:	dc.b	28,3,44,6,1,0
		dc.l	r_dottedoff,0
		dc.b	0,3,28,"OUUUUUUUUUUUUUUUN"
		dc.b	0,4,28,"K switch dotted K"
		dc.b	0,5,28,"LUUUUUUUUUUUUUUUM"
		dc.b	0,5,45," dotted : on ",$ff
		even
m_line3b:	dc.b	28,3,44,6,1,0
		dc.l	r_dottedon,0
		dc.b	0,3,28,"OUUUUUUUUUUUUUUUN"
		dc.b	0,4,28,"K switch dotted K"
		dc.b	0,5,28,"LUUUUUUUUUUUUUUUM"
		dc.b	0,5,45," dotted : off",$ff
		even
m_line4a:	dc.b	0,0,0,0,1,0
		dc.l	r_dummyroutine,0
		dc.b	0,4,45," UUUUUUUUUUUU",$ff
		even
m_line4b:	dc.b	0,0,0,0,1,0
		dc.l	r_dummyroutine,0
		dc.b	0,4,45," XUUUUUUUUUUU",$ff
		even
m_line4c:	dc.b	0,0,0,0,1,0
		dc.l	r_dummyroutine,0
		dc.b	0,4,45," UUUUUUUUUUUW",$ff
		even
m_line4d:	dc.b	0,0,0,0,1,0
		dc.l	r_dummyroutine,0
		dc.b	0,4,45," XUUUUUUUUUUW",$ff
		even
m_line4e:	dc.b	0,0,0,0,1,0
		dc.l	r_dummyroutine,0
		dc.b	0,4,45," XUUUUUUUUUUV",$ff
		even
m_line4f:	dc.b	0,0,0,0,1,0
		dc.l	r_dummyroutine,0
		dc.b	0,4,45," YUUUUUUUUUUW",$ff
		even
m_line4g:	dc.b	0,0,0,0,1,0
		dc.l	r_dummyroutine,0
		dc.b	0,4,45," YUUUUUUUUUUV",$ff
		even

m_help1:	dc.b	1,3,15,5,1,0
		dc.l	r_help1,0
		dc.b	0,3,1, "OUUUUUUUUUUUUUN"
		dc.b	0,4,1, "K  more help  K"
		dc.b	0,5,1, "LUUUUUUUUUUUUUM",$ff
		even
m_proj1:	dc.b	1,3,11,5,1,0
		dc.l	r_new,0
		dc.b	0,3,1, "OUUUUUUUUUN"
		dc.b	0,4,1, "K   new   K"
		dc.b	0,5,1, "LUUUUUUUUUM",$ff
		even
m_proj2:	dc.b	12,3,22,5,1,0
		dc.l	r_dummyroutine,0
		dc.b	0,3,12,"OUUUUUUUUUN"
		dc.b	0,4,12,"K  load   K"
		dc.b	0,5,12,"LUUUUUUUUUM",$ff
		even
m_proj3:	dc.b	23,3,33,5,1,0
		dc.l	r_dummyroutine,0
		dc.b	0,3,23,"OUUUUUUUUUN"
		dc.b	0,4,23,"K  save   K"
		dc.b	0,5,23,"LUUUUUUUUUM",$ff
		even
m_proj4:	dc.b	34,3,44,5,1,0
		dc.l	r_dummyroutine,0
		dc.b	0,3,34,"OUUUUUUUUUN"
		dc.b	0,4,34,"K  print  K"
		dc.b	0,5,34,"LUUUUUUUUUM",$ff
		even
m_edit1:	dc.b	1,3,11,5,1,1
		dc.l	r_zone,zd_cut
		dc.b	0,3,1, "OUUUUUUUUUN"
		dc.b	0,4,1, "K   cut   K"
		dc.b	0,5,1, "LUUUUUUUUUM",$ff
		even
zd_cut:		dc.b	"         "
		even
m_edit2:	dc.b	12,3,22,5,1,2
		dc.l	r_zone,zd_copy
		dc.b	0,3,12,"OUUUUUUUUUN"
		dc.b	0,4,12,"K  copy   K"
		dc.b	0,5,12,"LUUUUUUUUUM",$ff
		even
zd_copy:	dc.b	0,0,0,0,0,0,0,0,0
		even
m_edit3:	dc.b	23,3,33,5,1,3
		dc.l	r_paste,0
		dc.b	0,3,23,"OUUUUUUUUUN"
		dc.b	0,4,23,"K  paste  K"
		dc.b	0,5,23,"LUUUUUUUUUM",$ff
		even

m_empty:dc.b	0,0,0
	blk.b	cs_width," "
	dc.b	0,1,0
	blk.b	cs_width," "
	dc.b	0,2,0
	blk.b	cs_width," "
	dc.b	0,3,0
	blk.b	cs_width," "
	dc.b	0,4,0
	blk.b	cs_width," "
	dc.b	0,5,0
	blk.b	cs_width," "
	dc.b	$ff
	even


buffersize=	[4+cs_width]*cp_height

textbuffer:	blk.b	buffersize,32
pastebuffer:	blk.b	buffersize,32
undobuffer1:	blk.b	buffersize,32
undobuffer2:	blk.b	buffersize,32

t_zone:	
	dc.b	0,2,0, "push left button at edge of zone,"
	dc.b	0,3,0, "then slide onto the opposite edge...",$ff
	even

t_line:
	dc.b	0,2,0, "please click on start of line..."
	dc.b	0,3,0, "then click on each edge..."
	dc.b	0,4,0, "finally click 'end' to finish...",$ff
	even

t_paste:
	dc.b	0,2,0, "copying paste-buffer to screen..."
	dc.b	0,3,0, "place cursor on desired position...",$ff

t_help1:
	dc.b	0,7 ,0,"                       =UUUUUUUUUUUUUUUUUUUUUUUUUUUUU<"
	dc.b	0,8,0, "                       K                             K"
	dc.b	0,9,0, "                       K   =UU P   =U< P P =UU OU<   K"
	dc.b	0,10,0,"                       K   RU  K   K K KKK RU  R@>   K"
	dc.b	0,11,0,"                       K   Q   QUU ZU> ZQ> LUU Q E   K"
	dc.b	0,12,0,"                       K                             K"
	dc.b	0,13,0,"                       ZUUUUUUW  demoversion  XUUUUUU>"
	dc.b	0,16,0,"                               coded by cool-g"
	dc.b	0,21,0,"         flower is a tool to create flowcharts and dataflow diagrams,"
	dc.b	0,22,0,"          it might be compared to 'flow', a well-known, similar tool"
	dc.b	0,23,0,"       for ibm-pc's.  flower however will be much better, that's why it"
	dc.b	0,24,0,"                            is called 'flow-er'..."
	dc.b	0,28,0,"                this is a demoversion made for uga software"
	dc.b	0,29,0,"                          UUUUUUUUUUU"

	dc.b	0,33,0,"                    write to:    cool-g"
	dc.b	0,34,0,"                                 eikenlaan 21"
	dc.b	0,35,0,"                                 3740 bilzen"
	dc.b	0,36,0,"                                 belgium"
	dc.b	0,40,0,"                                                  please turn the page..."
	dc.b	$ff

t_help2:
	dc.b	0,7 ,0,"                       =UUUUUUUUUUUUUUUUUUUUUUUUUUUUU<"
	dc.b	0,8,0, "                       K                             K"
	dc.b	0,9,0, "                       K   =UU P   =U< P P =UU OU<   K"
	dc.b	0,10,0,"                       K   RU  K   K K KKK RU  R@>   K"
	dc.b	0,11,0,"                       K   Q   QUU ZU> ZQ> LUU Q E   K"
	dc.b	0,12,0,"                       K                             K"
	dc.b	0,13,0,"                       ZUUUUUUW  demoversion  XUUUUUU>"
	dc.b	0,16,0,"                               coded by cool-g"
	dc.b	0,19,0,"               flower 100% features:"
	dc.b	0,20,0,"               UUUUUUUUUUUUUUUUUUUUU"
	dc.b	0,22,0,"                     - fully mouse-driven menus"
	dc.b	0,23,0,"                     - complete set of boxes and lines"
	dc.b	0,24,0,"                     - intelligent line tracer"
	dc.b	0,25,0,"                     - undo"
	dc.b	0,26,0,"                     - cut/copy/paste"
	dc.b	0,27,0,"                     - load/save"
	dc.b	0,28,0,"                     - on-line help"
	dc.b	0,29,0,"                     - character-based printing (mega speed)"
	dc.b	0,30,0,"                     - 100% assembler (giga speed)"
	dc.b	0,33,0,"               later releases might include:"
	dc.b	0,34,0,"               UUUUUUUUUUUUUUUUUUUUUUUUUUUUU"
	dc.b	0,36,0,"                     - object-oriented editing ('click on box to move')"
	dc.b	0,37,0,"                     - smart 'clean-up' and 're-route' routines"
	dc.b	0,38,0,"                     - sleep-function ('back to workbench')"
	dc.b	0,39,0,"                     - suggestions from interested users..."
	dc.b	0,40,0,"                                                                          "
	dc.b	$ff

t_help3:
	dc.b	0,16,0,"       some brief info"
	dc.b	0,17,0,"       UUUUUUUUUUUUUUU"
	dc.b	0,19,0,"           - use cursor keys or mouse to move across the editor window"
	dc.b	0,20,0,"             the editor window can be scrolled up/down"
	dc.b	0,21,0,"             (shift+cursorkeys to move faster, ctrl+up/down for top bottom)"
	dc.b	0,22,0,"           - use mouse to select actions in the menu-strip"
	dc.b	0,23,0,"           - 'quit' and 'new' need to be confirmed by holding down the lmb"
	dc.b	0,24,0,"           - boxes are drawn by 'sliding' the cursor with the mouse from"
	dc.b	0,25,0,"             one edge to the other"
	dc.b	0,26,0,"           - switch between solid and transparant to make paste-buffer and"
	dc.b	0,27,0,"             drawn boxes adjust to the background or not."
	dc.b	0,28,0,"           - lines, file handling, insert/replace and undo are not"
	dc.b	0,29,0,"             implemented yet because of a damned lack of time..."
	dc.b	0,30,0,"           - please send suggestions to the address mentionned earlier..."
	dc.b	$ff
