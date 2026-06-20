
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
a_undo=		4	; undo possible if set
a_undokey=	5	; textinput is undone from 1st keystroke
a_line=		6	; line

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
	move.l	$4.w,a6

	move.l	#gfxname,a1
	jsr	-408(a6)
	move.l	d0,gfxbase

	move.l	#dosname,a1
	jsr	-408(a6)
	move.l	d0,dosbase

	bsr	waitvblank
	bsr	initdata

	move.w	$1c(a5),d0
	move.w	$1e(a5),d1
	move.w	$2(a5),d2
	move.w	#$7fff,$96(a5)
	move.w	#%1000001111110000,$96(a5)
	move.w	#$7fff,$9a(a5)
	move.w	#%1100000000101000,$9a(a5)

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
	move.l	$4.w,a6
	move.l	gfxbase(pc),a1
	jsr	-414(a6)
	move.l	dosbase(pc),a1
	jsr	-414(a6)
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
	clr.b	c_y
	bsr	setupplane
	bsr	setupmainmenu
mainloop:
	bsr	waitvblank
	bsr	checkmenu
	bsr	printcoords

	tst.b	op_code			; submenu item selected ?
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
	bra.w	interpretrest
interpretrest:
	bsr	convertrawkey
	btst	#a_keyfound,(a4)
	beq	k_rts
	bsr	testkeyundo
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
	bclr	#a_undokey,1(a4)
	bra	k_rts
k_top:	clr.b	c_y
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
	bra.L	k_rts
k_dwnlp:bsr	k_down
	dbf	d3,k_dwnlp
	bclr	#a_undokey,1(a4)
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
	bclr	#a_undokey,1(a4)
	bra.s	k_rts
k_right:cmp.b	#cs_width-1,d1
	beq.s	k_rts
	addq.b	#1,d1
	bra.s	k_rts
k_rtlp:	bsr	k_right
	dbf	d3,k_rtlp
	bclr	#a_undokey,1(a4)
	bra.s	k_rts
k_bs:	bsr.s	k_left
	move.b	#1,char
	bsr	testkeyundo
	bsr	addchartoline
	bra.s	k_rts
k_nl:	move.b	c_nlx(pc),d1
	bclr	#a_undokey,1(a4)
	bra	k_down
k_rts:	move.b	d1,c_x
	move.b	d2,c_y
	bsr	printline
	bclr	#a_cursor,(a4)
	rts
;-------------------------------
testkeyundo:
	btst	#a_undokey,1(a4)
	bne.s	k_noundo
	bsr	z_undosave		; at 1st keystroke save undo
	bset	#a_undokey,1(a4)
	move.b	c_x(pc),c_nlx
k_noundo:rts
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
	addq.l	#3,a0
	move.b	(a0),d0		; old char

	moveq.l	#0,d1
	move.b	char(pc),d1	; new char

	btst	#a_line,1(a4)
	beq.s	add_skip1
	cmp.b	#"K",d0
	bne.s	add_skip2
	cmp.b	#"U",d1
	bne.s	add_skip1
	bra.s	add_skip3
add_skip2:
	cmp.b	#"U",d0
	bne.s	add_skip1
	cmp.b	#"K",d1
	bne.s	add_skip1
add_skip3:
	move.b	#"}",d1
	bra.s	add_nomask
add_skip1:
	cmp.b	d0,d1
	beq.s	add_nomask	; same

	bsr	domasker
	move.b	d2,d1
	tst.b	d2
	bne.s	add_nomask
	move.b	char(pc),d1
add_nomask:
	move.b	d1,(a0)
endadd:	movem.l	(a7)+,d0-d5/a0-a1
	rts
;-------------------------------
domasker:			; d0 = oldchar    d1 = newchar
				;	d2 = masked char
	movem.l	d3/a1,-(a7)
	tst.b	d1
	beq.s	dm_allwaystransp	; special space 1
	cmp.b	#1,d1
	beq.s	dm_allwayssolid		; special space 2
	cmp.b	#32,d0
	beq.s	dm_nomask		; no mask needed

	btst	#a_solid,1(a4)
	bne.s	dm_nomask		; solid bit set

	cmp.b	#32,d1
	beq.s	dm_allwaystransp	; normal space masked

	lea.l	maskertab(pc),a1
	moveq	#0,d2
	moveq	#0,d3
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
	bra.s	dmlend
dm_allwayssolid:
	moveq	#32,d2
	bra.s	dmlend
dm_allwaystransp:
	move.b	d0,d2
	bra.s	dmlend
dm_nomask:
	move.b	d1,d2
dmlend:	movem.l	(a7)+,d3/a1
	rts
maskertab:
	;	  K  L  M  N  O  U  Z  >  <  =  P  Q  R  S


	dc.b	   "KLRKMSKNSKORKUTKZRK>SK<SK=RKPTKQTKRRKSSKTT"	;K
	dc.b	"LKR","LMQLNTLORLUQ","L>QL<TL=RLPTLQQLRRLSTLTT"	;L
	dc.b	"MKSMLQ","MNSMOTMUQMZQ","M<SM=TMPTMQQMRTMSSMTT"	;M
	dc.b	"NKSNLTNMS","NOPNUPNZTN>S","N=PNPPNQTNRTNSSNTT"	;N
	dc.b	"OKROLROMTONP","OUPOZRO>TO<P","OPPOQTORROSTOTT"	;O
	dc.b	"UKTULQUMQUNPUOP","UZQU>QU<PU=PUPPUQQURTUSTUTT"	;U
	dc.b	"ZKR","ZMQZNTZORZUQ","Z>QZ<TZ=RZPTZQQZRRZSTZTT"	;Z
	dc.b	">KS>LQ",">NS>OT>UQ>ZQ","><S>=T>PT>QQ>RT>SS>TT"	;>
	dc.b	"<KS<LT<MS","<OP<UP<ZT<>S","<=P<PP<QT<RT<SS<TT"	;<
	dc.b	"=KR=LR=MT=NP","=UP=ZR=>T=<P","=PP=QT=RR=ST=TT"	;=
	dc.b	"PKTPLTPMTPNPPOPPUPPZTP>TP<PP=P","PQTPRTPSTPTT"	;P
	dc.b	"QKTQLQQMQQNTQOTQUQQZQQ>QQ<TQ=TQPT","QRTQSTQTT"	;Q
	dc.b	"RKRRLRRMTRNTRORRUTRZRR>TR<TR=RRPTRQT","RSTRTT"	;R
	dc.b	"SKSSLTSMSSNSSOTSUTSZTS>SS<SS=TSPTSQTSRT","STT"	;S
	dc.b	"TKTTLTTMTTNTTOTTUTTZTT>TT<TT=TTPTTQTTRTTST"	;T

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
	cmp.b	#cp_height-1,d0
	bgt.s	endprintline
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
printcoords:
	moveq	#0,d0
	moveq	#0,d1
	lea.l	t_digits(pc),a0
	lea.l	cursorpos(pc),a1
	lea.l	t_coords(pc),a2
	move.b	(a1),d0
pclx:	cmp.b	#10,d0
	blt.s	pcxeenh
	addq.b	#1,d1
	sub.b	#10,d0
	bra.s	pclx
pcxeenh:move.b	(a0,d1),6(a2)
	move.b	(a0,d0),7(a2)
	move.b	1(a1),d0
	add.b	workofset,d0
	moveq	#0,d1
pcly:	cmp.b	#10,d0
	blt.s	pcyeenh
	addq.b	#1,d1
	sub.b	#10,d0
	bra.s	pcly
pcyeenh:move.b	(a0,d1),13(a2)
	move.b	(a0,d0),14(a2)
	move.l	a2,textptr
	bsr	printtext
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
int:	move.w	#$0008,$9a(a5)
	movem.l	d0-d7/a0-a6,-(a7)

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
	bne	i_fini
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
	bsr	printcoords

i_fini:	bsr	setupsprites

	movem.l	(a7)+,d0-d7/a0-a6
	move.w	#$8008,$9a(a5)
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
		dc.w	%0000000111111000,%0000000000000000
		dc.w	%0000000111110000,%0000001000000000
		dc.w	%0000000111110000,%0000001000000000
		dc.w	%0000000111111000,%0000001000000000
		dc.w	%0000000110111100,%0000001001000000
		dc.w	%0000000100011110,%0000001000100000
		dc.w	%0000000000001111,%0000001000010000
		dc.w	%0000000000000110,%0000000000001000
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
		dc.w	%0000000000000000,%0000001100000000
		dc.w	%0111100001111000,%0000010010000000
		dc.w	%0111100001111000,%0000010010000000
		dc.w	%0000000000000000,%0000001100000000
		dc.w	%0000001100000000,0
		dc.w	%0000001100000000,0
		dc.w	%0000001100000000,0
		dc.w	%0000000000000000,0
		dc.l	0
screenupmouse:	dc.b	0			; y pos start
		dc.b	0			; x pos
		dc.b	0			; y pos end
		dc.b	0			; extend x & y
		dc.w	%0000000000000000,%0000000000000000
		dc.w	%0000000000000000,%0000000000000010
		dc.w	%0000001100000000,%0000000000000111
		dc.w	%0000001100000000,%0000000000000010
		dc.w	%0000001100000000,%0000000000000010
		dc.w	%0000000000000000,%0000001100000000
		dc.w	%0111100001111000,%0000010010000000
		dc.w	%0111100001111000,%0000010010000000
		dc.w	%0000000000000000,%0000001100000000
		dc.w	%0000001100000000,%0000000000000000
		dc.w	%0000001100000000,%0000000000000000
		dc.w	%0000001100000000,%0000000000000000
		dc.w	%0000000000000000,%0000000000000000
		dc.l	0
screendownmouse:dc.b	0			; y pos start
		dc.b	0			; x pos
		dc.b	0			; y pos end
		dc.b	0			; extend x & y
		dc.w	%0000000000000000,%0000000000000000
		dc.w	%0000000000000000,%0000000000000000
		dc.w	%0000001100000000,%0000000000000000
		dc.w	%0000001100000000,%0000000000000000
		dc.w	%0000001100000000,%0000000000000000
		dc.w	%0000000000000000,%0000001100000000
		dc.w	%0111100001111000,%0000010010000000
		dc.w	%0111100001111000,%0000010010000000
		dc.w	%0000000000000000,%0000001100000000
		dc.w	%0000001100000000,%0000000000000010
		dc.w	%0000001100000000,%0000000000000010
		dc.w	%0000001100000000,%0000000000000111
		dc.w	%0000000000000000,%0000000000000010
		dc.l	0

mptrheight=[zerohpos-mptrdat]/4
;------------------------------------------------------------
mykeyboard:
	move.w	#$0020,$9a(a5)
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
	bra.w	mkb_rts
mkb_rts:movem.l	(a7)+,d0-d7/a0-a6
	move.w	#$8020,$9a(a5)
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
	bset	#a_screenoff,1(a4)
	moveq.l	#0,d0
	move.b	#cs_height-1,d0
	lea.l	c_y(pc),a0
	move.b	(a0),2(a0)	; save
	clr.b	(a0)
sup:	bsr	printline
	addq.b	#1,(a0)
	dbf	d0,sup
	move.b	2(a0),(a0)
	bclr	#a_screenoff,1(a4)
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
	move.l	#m_border,textptr
	bsr	printtext
	bra.s	dmloop
;-------------------------------
displaymenu:
	movem.l	d0/a0,-(a7)
	move.l	#m_border,textptr
	bsr	printtext
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
;	bsr	printtext
	move.l	6(a1),m_mainsubptr
	bsr	displaymenu
	bsr	r_besure
	rts
;--------------------------------------
r_back3:move.l	#mainhelplist,helpptr
	bsr	setupplane
r_back2:bset	#a_getkey,(a4)
	bclr	#a_screenoff,1(a4)
r_dummyroutine:
	bsr	r_besure
r_back1:
	bsr	clearmenu
	bsr	setupmainmenu
	clr.b	op_status
	clr.w	op_code
	bsr	printcoords
	rts
;--------------------------------------
r_besure:btst	#6,$bfe001
	beq.s	r_besure
	move.l	#8,d0
r_bsl:	bclr	#a_menu,(a4)
	bsr	waitvblank
	dbf	d0,r_bsl
	rts
;--------------------------------------
r_quit:	bsr.s	r_besure
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
r_new:	bsr	r_besure
	btst	#a_menu,(a4)
	beq.s	r_nonew
	bsr	z_undosave
	bsr	filltextbuffer
	clr.b	workofset
	bsr	k_top	
r_nonew:bra	r_back1
;--------------------------------------
r_mainhelp:
	move.l	#mainhelplist,helpptr
	bra.s	r_help1
r_boxhelp:
	move.l	#boxhelplist,helpptr
	bra.s	r_help1
r_linehelp:
	move.l	#linehelplist,helpptr
	bra.s	r_help1
r_edithelp:
	move.l	#edithelplist,helpptr
	bra.w	r_help1
r_help1:
	move.l	#m_helpextra,a1
	bsr	setupsubmenu
	bset	#a_screenoff,1(a4)
	bclr	#a_getkey,(a4)
	bsr	clearplane
	move.l	helpptr(pc),a0
	move.l	(a0)+,d0
	tst.l	d0
	bne.s	r_helpok
	move.l	(a0),a0
	move.l	(a0)+,d0
r_helpok:move.l	a0,helpptr
	move.l	d0,textptr
	bsr	printtext
	bsr	r_besure
	rts
;-------------------------------------
r_changetype_start:
	move.l	linestarttypeptr(pc),a0
	lea.l	m_typestart(pc),a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+	; a1 might not be even !
	cmp.w	#0,(a0)
	bne.s	r_chtsok
	move.l	#linestarttypelist,a0
r_chtsok:move.l	a0,linestarttypeptr
	bsr	displaymenu
	bsr	r_besure
	rts
;-------------------------------------
r_changetype_end:
	move.l	lineendtypeptr(pc),a0
	lea.l	m_typeend(pc),a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+	; a1 might not be even !
	cmp.w	#0,(a0)
	bne.s	r_chteok
	move.l	#lineendtypelist,a0
r_chteok:move.l	a0,lineendtypeptr
	bsr	displaymenu
	bsr	r_besure
	rts
;-------------------------------------
r_dottedon:
	move.l	#m_line3a,m_linesub
	bsr	r_besure
	bra	displaymenu
r_dottedoff:
	move.l	#m_line3b,m_linesub
	bsr	r_besure
	bra	displaymenu
;-------------------------------------
r_zone:	bsr	z_undosave
	bsr	clearmenu
	move.l	#m_cancellist,m_mainsubptr
	bsr	displaymenu
	move.l	#t_zone,textptr
	bsr	printtext
	move.b	#$01,op_status
	bclr	#a_getkey,(a4)
	rts
;-------------------------------------
r_paste:bsr	clearmenu
	bsr	z_undosave
	move.l	#m_cancellist,m_mainsubptr
	bsr	displaymenu
	move.l	#t_paste,textptr
	bsr	printtext
	move.b	#$01,op_status
	bclr	#a_getkey,(a4)
	rts
;------------------------------------------------------------
r_undo:	btst	#a_undo,1(a4)
	beq.s	r_endundo
	bsr	z_undotemp
	bsr	z_undosave
	bsr	z_undorestore
	bsr	r_besure
r_endundo:
	bra	r_back3	
;------------------------------------------------------------
r_startline:
	bsr	z_undosave
	bsr	clearmenu
	move.l	#m_linebusylist,m_mainsubptr
	bsr	displaymenu
	move.l	#t_line,textptr
	bsr	printtext
	move.b	#$01,op_status
	bclr	#a_getkey,(a4)
	bset	#a_line,1(a4)
	rts
;-------------------------------------
r_stopline:
	bclr	#a_line,1(a4)
	bsr	r_besure
	bra	r_back3
;-------------------------------------
r_loadstart:
	bsr	clearmenu
	move.l	#m_loadlist,m_mainsubptr
	bsr	displaymenu
	move.b	#$01,op_status
	bclr	#a_getkey,(a4)	
	bsr	r_besure
	rts
;-------------------------------------
r_savestart:
	bsr	clearmenu
	move.l	#m_savelist,m_mainsubptr
	bsr	displaymenu
	move.b	#$01,op_status
	bclr	#a_getkey,(a4)	
	bsr	r_besure
	rts
;-------------------------------------
r_selectfile:
r_file_up:
r_file_down:
r_load:
r_save:
	bsr	r_readdir
	bra	r_back3

;-------------------------------------
r_readdir:
	move.l	dosbase(pc),a6
	move.l	#path,d1
	moveq.l	#-2,d2
	jsr	-84(a6)		; lock
	tst.l	d0
	beq.s	dir_error
	move.l	d0,lock

	move.l	lock(pc),d1
	move.l	#fileinfo,d2
	jsr	-102(a6)	; examine diskname
	tst.l	d0
	beq.s	dir_error

dir_loop:
	move.l	lock(pc),d1
	move.l	#fileinfo,d2
	jsr	-108(a6)	; examine next
	tst.l	d0
	beq	dir_error
;	bsr	dir_savename
;	bsr	dir_printnames
;	bra.s	dir_loop
dir_error:
	rts

path:		dc.b	"df0:",0
		even
lock:		dc.l	0
fileinfo:	blk.l	260,0
;------------------------------------------------------------
;------------------------------------------------------------
;------------------------------------------------------------
op_handler:
	lea.l	op_code(pc),a0
	cmp.b	#$01,(a0)			; boxes
	beq	op_box
	cmp.b	#$02,(a0)			; line
	beq	op_line
	cmp.w	#$0301,(a0)			; edit
	beq	op_edit
	cmp.w	#$0302,(a0)			; edit
	beq	op_edit
	cmp.w	#$0303,(a0)			; paste
	beq	op_paste
	rts

op_box:	bsr	op_zone
	tst.b	op_status
	bne	op_end
	bsr	z_fill
	bsr	op_boxfinish
	bsr	setupplane
	bsr	r_back2
	rts

op_boxfinish:
	move.b	op_code+1(pc),d0
	cmp.b	#$03,d0
	beq.s	op_bfterminal
	cmp.b	#$05,d0
;	beq.s	op_bfdocument
	cmp.b	#$06,d0
;	beq.s	op_bfquestion
	rts
op_bfterminal:
	moveq	#0,d0
	moveq	#0,d1
	lea.l	cursorpos(pc),a0
	move.w	(a0),2(a0)	; save coords
	move.b	4(a0),d0	; c_x1
	add.b	6(a0),d0	; c_dx
	move.b	7(a0),d1	; c_dy
	asr	#1,d1		; c_dy/2
	sub.b	d1,d0		; d0 = x
	cmp.b	4(a0),d0
	bgt.s	op_bftok1
	move.b	4(a0),d0
	addq.b	#1,d0
op_bftok1:
	move.b	5(a0),d2	; d2 = y top
	move.b	d2,d3
	add.b	7(a0),d3	; d3 = y bottom

	move.b	4(a0),(a0)
	move.b	#85,char
op_bftl1:add.b	#1,(a0)
	move.b	d2,1(a0)
	bsr	addchartoline
	move.b	d3,1(a0)
	bsr	addchartoline
	cmp.b	(a0),d0
	bne.s	op_bftl1

	move.b	d0,(a0)
	move.b	d2,1(a0)
	move.b	#64,char
	bsr	addchartoline	; top right

	move.b	d3,1(a0)
	move.b	#91,char
	bsr	addchartoline	; bottom right

	tst.b	d1
	beq.s	op_bftskip0
	subq.b	#1,d1		; d1 = dbfcounter

op_bftl2:add.b	#1,(a0)
	addq.b	#1,d2
	subq.b	#1,d3

	move.b	d2,1(a0)
	move.b	#69,char
	bsr	addchartoline
	move.b	d3,1(a0)
	move.b	#70,char
	bsr	addchartoline

	dbf	d1,op_bftl2
op_bftskip0:
	cmp.b	d2,d3
	bne.s	op_bftskip1
	move.b	#68,char
	bsr	addchartoline
op_bftskip1:
	move.w	2(a0),(a0)	; save coords
	rts
;-------------------------------------
op_line:cmp.b	#$01,op_status		; start
	beq.s	op_line1
	cmp.b	#$02,op_status		; 1st piece
	beq.s	op_line2
;	cmp.b	#$03,op_status		; other pieces
	clr.w	op_code
op_lineend:
	rts

op_line1:
	btst	#a_screen,1(a4)
	beq.s	op_lineend
	lea.l	cursorpos(pc),a0
	move.w	(a0),16(a0)	; start
	move.b	workofset(pc),oldworkofset
	bsr	r_besure
	move.b	#$02,op_status
	bra.s	op_lineend
op_line2:
	btst	#a_screen,1(a4)
	beq.s	op_lineend
	lea.l	cursorpos(pc),a0
	move.b	oldworkofset(pc),d1
	sub.b	workofset(pc),d1
	add.b	d1,17(a0)
	move.b	workofset(pc),oldworkofset

	move.w	16(a0),14(a0)	; 1st to 2nd coord
	move.w	(a0),16(a0)	; 1st coord
	bsr	op_ldrawline
	bsr	r_besure
	bra.s	op_lineend
op_tryagain:
	bclr	#a_screen,1(a4)
	bra.s	op_lineend
;-------------------------------------
op_ldrawline:
	lea.l	cursorpos(pc),a0
	move.w	(a0),2(a0)
	move.w	14(a0),4(a0)
	move.w	16(a0),8(a0)
	bsr	dominmax
	move.b	6(a0),d0	; dx
	move.b	7(a0),d1	; dy
	cmp.b	d0,d1
	bgt.s	op_ldygdx
op_ldxgdy:
	move.b	15(a0),17(a0)	; presume horizontal line
	clr.b	7(a0)		; dy = 0
	clr.b	19(a0)		; dir_y=0
	move.b	17(a0),5(a0)	; y1 = y start
	move.b	17(a0),9(a0)	; y2 = y start
	move.b	#"U",char		; '-----'
	move.w	4(a0),(a0)
	move.b	8(a0),d0
	addq.b	#1,(a0)
op_lhl:	bsr	addchartoline
	addq.b	#1,(a0)
	cmp.b	(a0),d0
	bgt.s	op_lhl
	bra.s	op_lskip1
op_ldygdx:
	move.b	14(a0),16(a0)	; presume vertical line
	clr.b	6(a0)		; dx = 0
	clr.b	18(a0)		; dir_x=0
	move.b	16(a0),4(a0)	; x1 = x start
	move.b	16(a0),8(a0)	; x2 = x start
	move.b	#"K",char	; '|'
	move.w	4(a0),(a0)
	move.b	9(a0),d0
	addq.b	#1,1(a0)
op_lvl:	bsr	addchartoline
	addq.b	#1,1(a0)
	cmp.b	1(a0),d0
	bgt.s	op_lvl
op_lskip1:

	move.b	20(a0),21(a0)
op_lgetdirection:
	tst.b	18(a0)
	beq.s	op_lupdown
op_lleftright:
	cmp.b	#-1,18(a0)
	bne.s	op_lright
op_lleft:
	move.b	#4,20(a0)
	bra.s	op_lskip2
op_lright:
	move.b	#2,20(a0)
	bra.s	op_lskip2
op_lupdown:
	cmp.b	#-1,19(a0)
	beq.s	op_lup
op_ldown:
	move.b	#3,20(a0)
	bra.s	op_lskip2
op_lup:
	move.b	#1,20(a0)
op_lskip2:
	move.w	14(a0),(a0)	; get curpos ready
	move.b	20(a0),d0
	move.b	21(a0),d1
	bclr	#a_line,1(a4)
	lea.l	edgetab(pc),a1
op_ledgel:
	cmp.b	(a1)+,d0
	bne.s	op_leskip1
	cmp.b	(a1)+,d1
	bne.s	op_leskip2
	move.b	(a1)+,char
	bsr	addchartoline	; add edge
	bra.s	op_leskip3
op_leskip1:
	addq.l	#1,a1
op_leskip2:
	addq.l	#1,a1
	bra.s	op_ledgel
op_leskip3:
	move.w	2(a0),(a0)
	bset	#a_line,1(a4)
	bsr	setupplane
	rts

edgetab:	dc.b	1,1,"K",1,3,"K",3,3,"K",3,1,"K"
		dc.b	2,2,"U",2,4,"U",4,4,"U",4,2,"U"
		dc.b	1,2,"O",1,4,"N",2,3,"N",2,1,"M"
		dc.b	3,2,"L",3,4,"M",4,1,"L",4,3,"O",0
		even

;-------------------------------------
op_edit:bsr	op_zone
	tst.b	op_status
	bne.s	op_end
	lea.l	cursorpos(pc),a0
	move.l	4(a0),10(a0)		; coords/size to pastecoords
	bsr	z_edit
	bsr	waitblitter
	bsr	z_fill
	bsr	setupplane
	bsr	r_back2
	rts
;-------------------------------------
op_paste:btst	#a_screen,1(a4)
	beq.s	op_end
	bset	#a_screenoff,1(a4)
	lea.l	pastebuffer(pc),a0
	lea.l	textbuffer(pc),a1
	bsr	z_copy
	bsr	setupplane
	clr.b	op_status
	bclr	#a_screenoff,1(a4)
	bsr	r_back2
	rts
;-------------------------------------
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
	move.b	workofset(pc),oldworkofset
	move.b	#$02,op_status
	rts
zone_2:	btst	#6,$bfe001
	beq.s	zone_end
	lea.l	cursorpos(pc),a0
	move.w	(a0),8(a0)
	move.b	oldworkofset(pc),d1
	sub.b	workofset(pc),d1
	add.b	d1,5(a0)
	move.b	workofset(pc),oldworkofset
	bsr	dominmax
	clr.b	op_status
zone_end:rts
;-------------------------------------
z_fill:
	movem.l	d0-d3/a0-a2,-(a7)

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
	cmp.b	#2,d3
	blt.s	z_topright
z_topmiddle:
	addq.b	#1,c_x
	bsr	addchartoline
	dbf	d3,z_topmiddle
z_topright:
	addq.b	#1,c_x
	move.b	(a2)+,char
	bsr	addchartoline
	subq.b	#2,d1

	cmp.b	#2,c_dy
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
	cmp.b	#2,d3
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
	cmp.b	#2,d3
	blt.s	z_bottomright
z_bottommiddle:
	addq.b	#1,c_x			; top middle
	bsr	addchartoline
	dbf	d3,z_bottommiddle
z_bottomright:
	addq.b	#1,c_x			; top right
	move.b	(a2)+,char
	bsr	addchartoline
z_fend:	movem.l	(a7)+,d0-d3/a0-a2
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
			; z_x1/y1 and z_dx/dy sizing

	movem.l	d0-d3/a0-a2,-(a7)

	move.w	c_x,c_tempx		; save coords

	move.l	#cs_width+4,d5
	lea.l	cursorpos(pc),a2

	moveq.l	#0,d0
	move.b	11(a2),d0
	add.b	oldworkofset,d0
	mulu	d5,d0
	moveq.l	#0,d1
	move.b	10(a2),d1
	addq.b	#3,d1
	add.l	d1,d0
	add.l	d0,a0		; a0 = source

	moveq.l	#0,d0
	move.b	1(a2),d0
	add.b	workofset,d0
	mulu	d5,d0
	moveq.l	#0,d1
	move.b	(a2),d1
	addq.b	#3,d1
	add.l	d1,d0
	add.l	d0,a1		; a1 = dest

	moveq.l	#0,d6
	move.b	13(a2),d6	; d6 = height

	move.l	a0,d4
	move.l	a1,d5

z_clp0:	add.l	#cs_width+4,d4
	add.l	#cs_width+4,d5
	moveq	#0,d3
	move.b	12(a2),d3

z_clp1:	move.b	(a0)+,d1		; new
	move.b	(a1),d0			; old
	bsr	domasker
	tst.b	d2
	beq.s	z_cnomask
	move.b	d2,d1
z_cnomask:
	move.b	d1,(a1)+
	addq.b	#1,(a2)
	cmp.b	#cs_width,(a2)
	beq.s	z_cgo
	dbf	d3,z_clp1

z_cgo:	move.b	2(a2),c_x
	addq.b	#1,c_y
	move.l	d4,a0
	move.l	d5,a1
	dbf	d6,z_clp0

	move.w	2(a2),c_x
	movem.l	(a7)+,d0-d3/a0-a2
	rts
z_tempdx:	dc.b	0
		even
;------------------------------------------------------------
z_edit:	movem.l	d0-d1/a0-a1,-(a7)
	lea.l	textbuffer(pc),a0
	lea.l	pastebuffer(pc),a1
	bra.s	z_undo
z_undosave:		; copy buff to undo1
	movem.l	d0-d1/a0-a1,-(a7)
	lea.l	textbuffer,a0
	lea.l	undobuffer1,a1
	bset	#a_undo,1(a4)
	bclr	#a_undokey,1(a4)
	bra.s	z_undo
z_undotemp:
	movem.l	d0-d1/a0-a1,-(a7)
	lea.l	undobuffer1,a0
	lea.l	undobuffer2,a1
	bra.s	z_undo
z_undorestore:
	movem.l	d0-d1/a0-a1,-(a7)
	lea.l	undobuffer2,a0
	lea.l	textbuffer,a1
z_undo:	bsr	waitblitter
	move.l	a0,$50(a5)		;pta
	move.l	a1,$54(a5)		;ptd
	move.w	#$ffff,$44(a5)		;msk1
	move.w	#$ffff,$46(a5)		;mskl
	clr.w	$42(a5)			;con1
	clr.w	$64(a5)			;moda
	clr.w	$66(a5)			;modd
	move.w	#%0000100111110000,$40(a5);con0
	move.w	#buffblit,$58(a5)	;size
	bsr	waitblitter
	movem.l	(a7)+,d0-d1/a0-a1
	rts
;------------------------------------------------------------
;------------------------------------------------------------
dominmax:
	movem.l	d0/a0,-(a7)
	lea.l	cursorpos(pc),a0
	move.b	#-1,18(a0)	; left	; default dirs
	move.b	#-1,19(a0)	; up
	move.b	4(a0),d0
	cmp.b	8(a0),d0
	blt.s	dmmok1			; largest x
	move.b	#1,18(a0)	; right
	move.b	8(a0),4(a0)
	move.b	d0,8(a0)
dmmok1:	move.b	5(a0),d0
	cmp.b	9(a0),d0
	blt.s	dmmok2			; largest y
	move.b	#1,19(a0)	; down
	move.b	9(a0),5(a0)
	move.b	d0,9(a0)
dmmok2:	move.b	8(a0),d0
	sub.b	4(a0),d0
	tst.b	d0
	bne.s	dmmok3
	moveq	#1,d0
dmmok3:	move.b	d0,6(a0)		; delta x
	move.b	9(a0),d0
	sub.b	5(a0),d0
	tst.b	d0
	bne.s	dmmok4
	moveq	#1,d0
dmmok4:	move.b	d0,7(a0)		; delta y
	movem.l	(a7)+,d0/a0
	rts




cursorpos:
c_x:		dc.b	0	; 0
c_y:		dc.b	0	; 1
c_tempx:	dc.b	0	; 2
c_tempy:	dc.b	0	; 3

zonecoords:
c_x1:		dc.b	0	; 0 4
c_y1:		dc.b	0	; 1 5
c_dx:		dc.b	0	; 2 6
c_dy:		dc.b	0	; 3 7
c_x2:		dc.b	0	; 4 8
c_y2:		dc.b	0	; 5 9

pastebuff_coords:
z_x1:		dc.b	0	; 0 10
z_y1:		dc.b	0	; 1 11
z_dx:		dc.b	0	; 4 12
z_dy:		dc.b	0	; 5 13

line_coords:
l_x1:		dc.b	0	; 14	start + 1st coord
l_y1:		dc.b	0	; 15
l_x2:		dc.b	0	; 16	2nd coord + end
l_y2:		dc.b	0	; 17

directions:
dir_x:		dc.b	0	; 18
dir_y:		dc.b	0	; 19
dir_line:	dc.b	0	; 20
dir_pline:	dc.b	0	; 21

keybuff:	dc.b	0
lastkey:	dc.b	0
keydelay:	dc.b	0
origkeydelay:	dc.b	20
curdelay:	dc.b	15
char:		dc.b	0
workofset:	dc.b	0
oldworkofset:	dc.b	0
c_nlx:		dc.b	0	; xpos at newline

gfxname:	dc.b	"graphics.library",0
dosname:	dc.b	"dos.library",0
		even
gfxbase:	dc.l	0
dosbase:	dc.l	0
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
		incbin "df1:fonts/dfd.752x6x1"

; shifted= +$80

rawtab:	dc.b	0,49,50,51,52,53,54,55,56,57,48,45,0,0,0,48,113,119,101,114,116,121
	dc.b	117,105,111,112,0,0,0,49,50,51,97,115,100,102,103,104,106,107,108
	dc.b	59,39,0,0,52,53,54,0,122,120,99,118,98,110,109,44,46,47,0,46,55,56,57
	dc.b	1,0,0,0,0,0,0,0,0,0,45,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
rsh:	dc.b	0,33,0,35,0,37,0,0,42,40,41,0,43,0,0,48,113,119,101,114,116,121
	dc.b	117,105,111,112,0,0,0,49,50,51,97,115,100,102,103,104,106,107,108
	dc.b	58,39,0,0,52,53,54,0,122,120,99,118,98,110,109,44,46,63,0,46,55,56,57
	dc.b	1,0,0,0,0,0,0,0,0,0,45,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
endrawtab:
	even
;--------------------------------------------------------------
s_widthB=	80
s_height=	256
s_pic:		blk.b	s_height*s_widthB,0
		even
;------------------------------------------------------------
cs_menuheight=	8
cs_height=	s_height/f_height-1-cs_menuheight
cs_width=	s_widthB-1
cp_height=	80
;------------------------------------------------------------
s_blitsize=	[[cs_height-1]*f_height]*64+[s_widthB/2]
;------------------------------------------------------------

copperlist:
		dc.l	$00960100

spritept:	dc.l	$01200000,$01220000,$01240000,$01260000
		dc.l	$01280000,$012a0000,$012c0000,$012e0000
		dc.l	$01300000,$01320000,$01340000,$01360000
		dc.l	$01380000,$013a0000,$013c0000,$013e0000

sprcol:		dc.l	$01a004f4,$01a204f4,$01a40080

		dc.l	$01800000,$018204a4
planept:	dc.l	$00e00000,$00e20000

		dc.l	$01009000,$01080000,$010a0000

		dc.l	$00920038,$009400d0
		dc.l	$320ffffe,$00968100

		dc.l	$ffdffffe,$320ffffe,$00960100,$fffffffe

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

m_mainlist:	dc.l	m_trsp,m_box0,m_line0,m_proj0,m_edit0,m_mainhelp,m_undo,m_quit,0
m_boxsub:	dc.l	m_box1,m_box2,m_box3,m_box4,m_box5,m_box6,m_back1,m_boxhelp,0
m_linesub:	dc.l	m_line3b,m_line1,m_line2a,m_line2b,m_back1,m_linehelp,0
m_projsub:	dc.l	m_proj1,m_proj2,m_proj3,m_proj4,m_back1,0
m_editsub:	dc.l	m_edit1,m_edit2,m_edit3,m_back1,m_edithelp,0
m_helpsub:	dc.l	m_help1,m_back3,0
m_cancellist:	dc.l	m_cancel,0
m_linebusylist:	dc.l	m_cancel,m_stopline,0
m_loadlist:	dc.l	m_load,m_filereq1,m_filereq2,m_filereq3,m_cancel,0
m_savelist:	dc.l	m_save,m_filereq1,m_filereq2,m_filereq3,m_cancel,0

m_mainptr:	dc.l	0
m_mainsubptr:	dc.l	0
m_subptr:	dc.l	0

itemnumber:	dc.b	0	; number of item activated
menux:		dc.b	0	; xpos menucursor
menuy:		dc.b	0	; ypos menucursor
		even

helpptr:	dc.l	0
mainhelplist:	dc.l	t_help1,t_help2,t_help3,0,mainhelplist
boxhelplist:	dc.l	t_box1,0,boxhelplist
linehelplist:	dc.l	t_help1,0,linehelplist
edithelplist:	dc.l	t_edit1,0,edithelplist

linestarttypeptr:	dc.l	linestarttypelist
linestarttypelist:	dc.w	"UU","XU","X|","YU","Y|",0

lineendtypeptr:		dc.l	lineendtypelist
lineendtypelist:	dc.w	"UU","UW","|W","UV","|V",0


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

m_border:	dc.b	0,0,0,"O"
		blk.b	cs_width-2,"U"
		dc.b	"N"
		dc.b	0,1,0,"K",0,1,cs_width-1,"K"
		dc.b	0,2,0,"K",0,2,cs_width-1,"K"
		dc.b	0,3,0,"K",0,3,cs_width-1,"K"
		dc.b	0,4,0,"K",0,4,cs_width-1,"K"
		dc.b	0,5,0,"K",0,5,cs_width-1,"K"
		dc.b	0,6,0,"K",0,6,cs_width-1,"K"
		dc.b	0,7,0,"L"
		blk.b	cs_width-2,"U"
		dc.b	"M",$ff
		even
m_box0:		dc.b	1,1,11,3,0,1
		dc.l	m_boxsub,0
		dc.b	0,1,1, "OUUUUUUUUUN"
		dc.b	0,2,1, "K  boxes  K"
		dc.b	0,3,1, "LUUUUUUUUUM",$ff
		even
m_line0:	dc.b	12,1,22,3,0,2
		dc.l	m_linesub,0
		dc.b	0,1,12,"OUUUUUUUUUN"
		dc.b	0,2,12,"K  lines  K"
		dc.b	0,3,12,"LUUUUUUUUUM",$ff
		even
m_edit0:	dc.b	1,4,11,6,0,3
		dc.l	m_editsub,0
		dc.b	0,4,1,"OUUUUUUUUUN"
		dc.b	0,5,1,"K  edit   K"
		dc.b	0,6,1,"LUUUUUUUUUM",$ff
		even
m_proj0:	dc.b	12,4,22,6,0,4
		dc.l	m_projsub,0
		dc.b	0,4,12,"OUUUUUUUUUN"
		dc.b	0,5,12,"K project K"
		dc.b	0,6,12,"LUUUUUUUUUM",$ff
		even
m_trsp:		dc.b	23,4,33,6,1,0
		dc.l	r_sold,0
		dc.b	0,4,23,"OUUUUUUUUUN"
		dc.b	0,5,23,"K transp. K"
		dc.b	0,6,23,"LUUUUUUUUUM",$ff
		even
m_sold:		dc.b	23,4,33,6,1,0
		dc.l	r_trsp,0
		dc.b	0,4,23,"OUUUUUUUUUN"
		dc.b	0,5,23,"K  solid  K"
		dc.b	0,6,23,"LUUUUUUUUUM",$ff
		even
m_mainhelp:	dc.b	67,1,77,3,1,0
		dc.l	r_mainhelp,0
		dc.b	0,1,67,"OUUUUUUUUUN"
		dc.b	0,2,67,"K help !! K"
		dc.b	0,3,67,"LUUUUUUUUUM",$ff
		even
m_boxhelp:	dc.b	67,1,77,3,1,0
		dc.l	r_boxhelp,0
		dc.b	0,1,67,"OUUUUUUUUUN"
		dc.b	0,2,67,"K help !! K"
		dc.b	0,3,67,"LUUUUUUUUUM",$ff
		even
m_linehelp:	dc.b	67,1,77,3,1,0
		dc.l	r_linehelp,0
		dc.b	0,1,67,"OUUUUUUUUUN"
		dc.b	0,2,67,"K help !! K"
		dc.b	0,3,67,"LUUUUUUUUUM",$ff
		even
m_edithelp:	dc.b	67,1,77,3,1,0
		dc.l	r_edithelp,0
		dc.b	0,1,67,"OUUUUUUUUUN"
		dc.b	0,2,67,"K help !! K"
		dc.b	0,3,67,"LUUUUUUUUUM",$ff
		even
m_helpextra:	dc.b	67,1,77,3,0,0
		dc.l	m_helpsub,0
		dc.b	0,1,67,"OUUUUUUUUUN"
		dc.b	0,2,67,"K help !! K"
		dc.b	0,3,67,"LUUUUUUUUUM",$ff
		even
m_undo:		dc.b	23,1,33,3,1,0
		dc.l	r_undo,0
		dc.b	0,1,23,"OUUUUUUUUUN"
		dc.b	0,2,23,"K  ooops  K"
		dc.b	0,3,23,"LUUUUUUUUUM",$ff
		even
m_quit:		dc.b	67,4,77,6,1,0
		dc.l	r_quit,0
		dc.b	0,4,67,"OUUUUUUUUUN"
		dc.b	0,5,67,"K quit !! K"
		dc.b	0,6,67,"LUUUUUUUUUM",$ff
		even
m_back1:	dc.b	67,4,77,6,1,0
		dc.l	r_back1,0
		dc.b	0,4,67,"OUUUUUUUUUN"
		dc.b	0,5,67,"Kmain menuK"
		dc.b	0,6,67,"LUUUUUUUUUM",$ff
		even
m_back3:	dc.b	67,4,77,6,1,0
		dc.l	r_back3,0
		dc.b	0,4,67,"OUUUUUUUUUN"
		dc.b	0,5,67,"Kmain menuK"
		dc.b	0,6,67,"LUUUUUUUUUM",$ff
		even
m_cancel:	dc.b	68,4,77,6,1,$ff
		dc.l	r_undo,0
		dc.b	0,4,68,"OUUUUUUUUN"
		dc.b	0,5,68,"K cancel K"
		dc.b	0,6,68,"LUUUUUUUUM",$ff
		even
m_box1:		dc.b	1,1,11,3,1,1
		dc.l	r_zone,zd_box1
		dc.b	0,1,1, "OUUUUUUUUUN"
		dc.b	0,2,1, "K  plain  K"
		dc.b	0,3,1, "LUUUUUUUUUM",$ff
		even
zd_box1:	dc.b	"OUNK KLUM"
		even
m_box2:		dc.b	1,4,11,6,1,2
		dc.l	r_zone,zd_box2
		dc.b	0,4,1,"]UUUUUUUUU^"
		dc.b	0,5,1,"K storage K"
		dc.b	0,6,1,"`UUUUUUUUU_",$ff
		even
zd_box2:	dc.b	"]U^K K`U_"
		even
m_box3:		dc.b	12,1,22,3,1,3
		dc.l	r_zone,zd_box3
		dc.b	0,1,12,"]UUUUUUUU@ "
		dc.b	0,2,12,"K termin. D"
		dc.b	0,3,12,"`UUUUUUUU[ ",$ff
		even
zd_box3:	dc.b	"]  K  `  "
		even
m_box4:		dc.b	12,4,22,6,1,4
		dc.l	r_zone,zd_box4
		dc.b	0,4,12,"=UUUUUUUUU<"
		dc.b	0,5,12,"K process K"
		dc.b	0,6,12,"ZUUUUUUUUU>",$ff
		even
zd_box4:	dc.b	"=U<K KZU>"
		even
m_box5:		dc.b	30,1,40,3,1,5
		dc.l	r_zone,zd_box5
		dc.b	0,1,30,"OUUUUUUUUUN"
		dc.b	0,2,30,"K doc \UUUM"
		dc.b	0,3,30,"ZUUUU[",$ff
		even
zd_box5:	dc.b	"OUNK KZ  "
		even
m_box6:		dc.b	23,1,29,6,1,6
		dc.l	r_zone,zd_box6
		dc.b	0,1,23,"   A"
		dc.b	0,2,23,"  F E"
		dc.b	0,3,23," F ? E"
		dc.b	0,4,23," E   F"
		dc.b	0,5,23,"  E F"
		dc.b	0,6,23,"   B",$ff
		even
zd_box6:	dc.b	"         "
		even
m_line1:	dc.b	1,4,12,6,1,0
		dc.l	r_startline,0
		dc.b	0,4,1, "OUUUUUUUUUUN"
		dc.b	0,5,1, "K go ahead K"
		dc.b	0,6,1, "LUUUUUUUUUUM",$ff
		even
m_line2a:	dc.b	14,4,17,6,1,0
		dc.l	r_changetype_start,0
		dc.b	0,4,14,"current type:"
		dc.b	0,6,14
m_typestart:	dc.b	"UU",$ff
		even
m_line2b:	dc.b	23,4,26,6,1,0
		dc.l	r_changetype_end,0
		dc.b	0,6,25
m_typeend:	dc.b	"UU",$ff
		even
m_line3a:	dc.b	18,4,22,6,1,0
		dc.l	r_dottedoff,0
		dc.b	0,6,16,"U U U U U",$ff
		even
m_line3b:	dc.b	18,4,22,6,1,0
		dc.l	r_dottedon,0
		dc.b	0,6,16,"UUUUUUUUU",$ff
		even
m_stopline:	dc.b	68,1,77,3,1,$ff
		dc.l	r_stopline,0
		dc.b	0,1,68,"OUUUUUUUUN"
		dc.b	0,2,68,"K finito K"
		dc.b	0,3,68,"LUUUUUUUUM",$ff
		even

m_help1:	dc.b	1,4,15,6,1,0
		dc.l	r_help1,0
		dc.b	0,4,1, "OUUUUUUUUUUUUUN"
		dc.b	0,5,1, "K  more help  K"
		dc.b	0,6,1, "LUUUUUUUUUUUUUM",$ff
		even
m_proj1:	dc.b	1,4,11,6,1,1
		dc.l	r_new,0
		dc.b	0,4,1, "OUUUUUUUUUN"
		dc.b	0,5,1, "K   new   K"
		dc.b	0,6,1, "LUUUUUUUUUM",$ff
		even
m_proj2:	dc.b	12,4,22,6,1,2
		dc.l	r_loadstart,0
		dc.b	0,4,12,"OUUUUUUUUUN"
		dc.b	0,5,12,"K  load   K"
		dc.b	0,6,12,"LUUUUUUUUUM",$ff
		even
m_proj3:	dc.b	23,4,33,6,1,3
		dc.l	r_savestart,0
		dc.b	0,4,23,"OUUUUUUUUUN"
		dc.b	0,5,23,"K  save   K"
		dc.b	0,6,23,"LUUUUUUUUUM",$ff
		even
m_proj4:	dc.b	34,4,44,6,1,0
		dc.l	r_dummyroutine,0
		dc.b	0,4,34,"OUUUUUUUUUN"
		dc.b	0,5,34,"K  print  K"
		dc.b	0,6,34,"LUUUUUUUUUM",$ff
		even
m_edit1:	dc.b	1,4,11,6,1,1
		dc.l	r_zone,zd_cut
		dc.b	0,4,1, "OUUUUUUUUUN"
		dc.b	0,5,1, "K   cut   K"
		dc.b	0,6,1, "LUUUUUUUUUM",$ff
		even
zd_cut:		dc.b	1,1,1,1,1,1,1,1,1
		even
m_edit2:	dc.b	12,4,22,6,1,2
		dc.l	r_zone,zd_copy
		dc.b	0,4,12,"OUUUUUUUUUN"
		dc.b	0,5,12,"K  copy   K"
		dc.b	0,6,12,"LUUUUUUUUUM",$ff
		even
zd_copy:	dc.b	0,0,0,0,0,0,0,0,0
		even
m_edit3:	dc.b	23,4,33,6,1,3
		dc.l	r_paste,0
		dc.b	0,4,23,"OUUUUUUUUUN"
		dc.b	0,5,23,"K  paste  K"
		dc.b	0,6,23,"LUUUUUUUUUM",$ff
		even
m_save:		dc.b	68,1,77,3,1,1
		dc.l	r_save,0
		dc.b	0,1,68,"OUUUUUUUUN"
		dc.b	0,2,68,"K  save  K"
		dc.b	0,3,68,"LUUUUUUUUM"
		dc.b	0,3,38,"save'",$ff
		even
m_load:		dc.b	68,1,77,3,1,1
		dc.l	r_load,0
		dc.b	0,1,68,"OUUUUUUUUN"
		dc.b	0,2,68,"K  load  K"
		dc.b	0,3,68,"LUUUUUUUUM"
		dc.b	0,3,38,"load'",$ff
		even
m_filereq1:	dc.b	1,1,20,6,1,2
		dc.l	r_selectfile,0
		dc.b	0,3,21,"K K"
		dc.b	0,4,21,"K K"
		dc.b	0,2,26,"please select a filename,"
		dc.b	0,3,26,"then click '",$ff
		even
m_filereq2:	dc.b	21,0,23,2,1,0
		dc.l	r_file_up,0
		dc.b	0,0,21,"PUP"
		dc.b	0,1,21,"KHK"
		dc.b	0,2,21,"RUS",$ff
		even
m_filereq3:	dc.b	21,5,23,7,1,0
		dc.l	r_file_down,0
		dc.b	0,5,21,"RUS"
		dc.b	0,6,21,"KGK"
		dc.b	0,7,21,"QUQ",$ff

m_empty:dc.b	0,1,0
	blk.b	cs_width," "
	dc.b	0,2,0
	blk.b	cs_width," "
	dc.b	0,3,0
	blk.b	cs_width," "
	dc.b	0,4,0
	blk.b	cs_width," "
	dc.b	0,5,0
	blk.b	cs_width," "
	dc.b	0,6,0
	blk.b	cs_width," "
	dc.b	$ff
	even

t_digits:	dc.b	"0123456789"
t_coords:	dc.b	0,cs_height+cs_menuheight,0,"x:     y:   ",$ff

buffersize=	[4+cs_width]*cp_height
buffblit=	[cp_height*64]+[[4+cs_width]/2]

textbuffer:	blk.b	buffersize,32
pastebuffer:	blk.b	buffersize,0
undobuffer1:	blk.b	buffersize,32
undobuffer2:	blk.b	buffersize,32

t_zone:	
	dc.b	0,2,2, "push left button at edge of zone,"
	dc.b	0,3,2, "then slide onto the opposite edge...",$ff
	even

t_line:
	dc.b	0,2,2, "please click on start of line..."
	dc.b	0,3,2, "then click on each edge..."
	dc.b	0,4,2, "finally click 'end' to finish...",$ff
	even

t_paste:
	dc.b	0,2,2, "copying paste-buffer to screen..."
	dc.b	0,3,2, "place cursor on desired position...",$ff

t_help1:
	dc.b	0,08,0,"                       =UUUUUUUUUUUUUUUUUUUUUUUU"
	dc.b	0,09,0,"                       K                             K"
	dc.b	0,10,0,"                       K   =UU P   =U< P P =UU OU<   K"
	dc.b	0,11,0,"                       K   RU  K   K K KKK RU  R@>   K"
	dc.b	0,12,0,"                       K   Q   QUU ZU> ZQ> LUU Q E   K"
	dc.b	0,13,0,"                       K                             K"
	dc.b	0,14,0,"                       ZUUUUUUW  demoversion  XUUUUUU>"
	dc.b	0,17,0,"                               coded by cool-g"
	dc.b	0,22,0,"         flower is a tool to create flowcharts and dataflow diagrams,"
	dc.b	0,23,0,"          it might be compared to 'flow', a well-known, similar tool"
	dc.b	0,24,0,"       for ibm-pc's.  flower however will be much better, that's why it"
	dc.b	0,25,0,"                            is called 'flow-er'..."
	dc.b	0,29,0,"                this is a demoversion made for uga software"
	dc.b	0,30,0,"                          UUUUUUUUUUU"

	dc.b	0,34,0,"                    write to:    cool-g"
	dc.b	0,35,0,"                                 eikenlaan 21"
	dc.b	0,36,0,"                                 3740 bilzen"
	dc.b	0,37,0,"                                 belgium"
	dc.b	0,40,0,"                                                  please turn the page..."
	dc.b	$ff

t_help2:
	dc.b	0,08,0,"                       =UUUUUUUUUUUUUUUUUUUUUUUUUUUUU<"
	dc.b	0,09,0,"                       K                             K"
	dc.b	0,10,0,"                       K   =UU P   =U< P P =UU OU<   K"
	dc.b	0,11,0,"                       K   RU  K   K K KKK RU  R@>   K"
	dc.b	0,12,0,"                       K   Q   QUU ZU> ZQ> LUU Q E   K"
	dc.b	0,13,0,"                       K                             K"
	dc.b	0,14,0,"                       ZUUUUUUW  demoversion  XUUUUUU>"
	dc.b	0,17,0,"                               coded by cool-g"
	dc.b	0,20,0,"               flower 100% features:"
	dc.b	0,21,0,"               UUUUUUUUUUUUUUUUUUUUU"
	dc.b	0,23,0,"                     - fully mouse-driven menus"
	dc.b	0,24,0,"                     - complete set of boxes and lines"
	dc.b	0,25,0,"                     - intelligent line tracer"
	dc.b	0,26,0,"                     - undo"
	dc.b	0,27,0,"                     - cut/copy/paste"
	dc.b	0,28,0,"                     - load/save"
	dc.b	0,29,0,"                     - on-line help"
	dc.b	0,30,0,"                     - character-based printing (mega speed)"
	dc.b	0,31,0,"                     - 100% assembler (giga speed)"
	dc.b	0,34,0,"               later releases might include:"
	dc.b	0,35,0,"               UUUUUUUUUUUUUUUUUUUUUUUUUUUUU"
	dc.b	0,37,0,"                     - object-oriented editing ('click on box to move')"
	dc.b	0,38,0,"                     - smart 'clean-up' and 're-route' routines"
	dc.b	0,39,0,"                     - sleep-function ('back to workbench')"
	dc.b	0,40,0,"                     - suggestions from interested users...                       "
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
	dc.b	0,40,0,"                                                                   "
	dc.b	$ff

t_box1:
	dc.b	0,09,0,"     how to draw a box..."
	dc.b	0,10,0,"     UUUUUUUUUUUUUUUUUUUU"
	dc.b	0,12,0,"           - don't be silly & try it yourself !!",$ff

t_line1:
	dc.b	0,09,0,"     how to draw a line..."
	dc.b	0,10,0,"     UUUUUUUUUUUUUUUUUUUUU"
	dc.b	0,12,0,"           - don't be silly & try it yourself !!",$ff

t_edit1:
	dc.b	0,09,0,"     how to cut/copy/paste..."
	dc.b	0,10,0,"     UUUUUUUUUUUUUUUUUUUUUUUU"
	dc.b	0,12,0,"           - don't be silly & try it yourself !!",$ff


