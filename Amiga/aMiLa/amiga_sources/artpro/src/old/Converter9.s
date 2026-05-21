******************************************************************************
*									     *
*		       Professioneller IFF-Converter			     *
*			    using my Macros				     *
*									     *
* Coding    :  Crazy Copper/DFT						     *
* Desing&GFX:  M.U.D.U./DFT						     *
*									     *
* Begin Work: 13.06.1993						     *
* Final Work: xx.xx.xxxx						     *
*									     *
******************************************************************************

		incdir	sources:macros/
		include	hardware.m
		include	hardware1.m
		include	vektor.m

OpenLib		= -408			;Exec.Library
CloseLib	= -414			;Exec.Library
FileRequest	= -84			;Req.Library
textrequest	= -174
lock		= -84
unlock		= -90
examine		= -102
open		= -30
close		= -36
read		= -42
write		= -48
allocmem	= -198
freemem		= -210
output		= -60
input		= -54
alert		= -90
loadseg		= -150
unloadseg	= -156

;--- SAVE SYSTEM ------------------------------------------------------------
begin:
		lea	daten,a5
		move.l	a5,a0
		move.w	#dataslen-1,d0
.clr		clr.b	(a0)+		;lösche Bss Section
		dbra	d0,.clr

		lea	bitplane1,a0
		move.w	#endplane-bitplane1-1,d0
.clr1		clr.b	(a0)+		;lösche Bss Section
		dbra	d0,.clr1

;--- Open Libs --------------------------------------------------------------

		move.l	$4.w,a6
		lea	reqname(pc),a1
		jsr	openlib(a6)
		move.l	d0,reqbase(a5)
		beq.w	noreq		;Keine Req.library gefunden
		lea	gfxname(pc),a1
		jsr	openlib(a6)
		move.l	d0,gfxbase(a5)
		lea	dosname(pc),a1
		jsr	openlib(a6)
		move.l	d0,dosbase(a5)
		
;--- Init Reqpuffer --------------------------------------------------------

		lea	dirname,a0
		move.l	a0,dir(a5)
		lea	filename,a0
		move.l	a0,file(a5)		
		lea	filepuffer,a0
		move.l	a0,pathname(a5)
		move.b	#20,flags+3(a5)
		move.w	#3,dirnamecolor(a5)
		move.w	#4,detailcolor(a5)
		move.w	#1,blockcolor(a5)
		move.w	#1,gadgettextcol(a5)
		move.w	#2,textmessagecol(a5)	
		move.w	#3,stringgadgetco(a5)
		move.w	#3,bboxbordercolor(a5)
		move.w	#3,gadgetboxcolor(a5)


		lea	loadfile,a0
		move.l	a0,windowtitle(a5)
		lea	version,a0
		add.l	a5,a0
		move.l	reqbase(a5),a6
		jsr	-84(a6)
		tst.l	d0
;		beq	nixgewaehlt


;		bra	old1

		bsr.w	loadiff

		move.l	gfxbase(a5),a1
		move.l	38(a1),oldcop(a5)		;Save Copper

		lea	$dff000,a6
		move.w	#$4000,$9a(a6)
		move.w	#$f,$96(a6)
		move.w	$dff07c,d0
		cmp.b	#$f8,d0		;Check AGA
		bne.s	.noaga
		moveq	#0,d0
		move.w	d0,$dff1fc
		move.w	d0,$dff106
.noaga:		bra.b	initplanes


noreq:		
		bra.w	fini	;Keine Req.library

gfxname:	dc.b	'graphics.library',0
dosname:	dc.b	'dos.library',0
reqname:	dc.b	'req.library',0
	even

;--- INIT PLANES ------------------------------------------------------------
initplanes:
		move.l	picmem(a5),d0

		initplane init+2,d0,4,336*280/8

;--- INIT COPPER ---

		move.w	#$a0,$96(a6)
		lea	copper,a0
		move.l	a0,$80(a6)
		move.w	#$83c0,$96(a6)

;--- INIT SPRITE ---		

		lea	sprinit,a0
		lea	spr1,a1
		exg	a1,d0
		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)

		move.w	#$8020,$96(a6)	;Sprite DMA einschalten


		move.w	xmouse(a5),d5
		move.w	ymouse(a5),d6
		bsr.w	drawl				

		bra.w	cut

;--------------------------------------------------------------------------
old:
		lea	$dff000,a6
		move.w	#$8020,$96(a6)
		move.l	oldcop(a5),$80(a6)
		move.w	d0,$88(a6)
		move.w	#$c000,$9a(a6)
old1:
		move.l	4.w,a6
		move.l	picmem(a5),a1
		move.l	memsize(a5),d0
		jsr	freemem(a6)
		move.l	loadbody(a5),a1
		move.l	bodylaenge(a5),d0
		jsr	freemem(a6)		

		move.l	gfxbase(a5),a1
		jsr	closelib(a6)		
		move.l	dosbase(a5),a1
		jsr	closelib(a6)
		move.l	reqbase(a5),a1
		jsr	closelib(a6)
fini:
		illegal
		moveq	#0,d0
		rts
;-------------------------------------------------------------------------
loadiff:
		lea	filepuffer,a0
;		add.l	a5,a0
		exg	a0,d1
		move.l	#1005,d2
		move.l	dosbase(a5),a6
		jsr	open(a6)		;Open File
		move.l	d0,filehandle(a5)		
;		beq	openerror
				
		lea	bytepuffer,a4
		bsr.w	readbyte
		cmp.l	#'FORM',(a4)		;Test IFF
		bne.w	notiff		
		bsr.w	readbyte
		bsr.w	readbyte
		cmp.l	#'ILBM',(a4)		;Test ob IFF-Pic
		bne.w	notiff
		bsr.w	readbyte
		cmp.l	#'BMHD',(a4)		;Test auf Bitmapheader
		bne.b	notiff
		bsr.w	readbyte		;Länge des BMHD überlesen
;		bsr	readbyte
		moveq	#20,d3
		bsr.w	readchunk		;Read Bitmapheader	

		lea	chunkpuffer,a0
		move.w	(a0),d0
		move.w	d0,breite(a5)
		move.w	2(a0),d0
		move.w	d0,hoehe(a5)

		move.b	8(a0),planes(a5)		
		move.b	9(a0),testbyte(a5)
		move.b	10(a0),crunchmode(a5)		

		move.w	12(a0),transcolor(a5)
		move.w	14(a0),verhaeltnis(a5)

		move.w	16(a0),xresolution(a5)	;Bildauflösung
		move.w	18(a0),yresolution(a5)


nextread
		bsr.b	readbyte
		lea	bytepuffer,a0
		cmp.l	#'DPPS',(a0)
		beq.w	dpps
		cmp.l	#'CMAP',(a0)
		beq.b	colortab		
		cmp.l	#'CAMG',(a0)
		beq.b	hamehb
		cmp.l	#'BODY',(a0)
		beq.w	loadpic
		bra.b	nextread


notiff:
		move.l	filehandle(a5),d1
		jsr	close(a6)
		lea	$dff000,a6
		rts


readbyte:
		move.l	filehandle(a5),d1
		lea	bytepuffer,a0
		exg	a0,d2
		moveq	#4,d3
		jmp	read(a6)
readchunk:
		move.l	filehandle(a5),d1
		lea	chunkpuffer,a0
		exg	a0,d2
		jmp	read(a6)
		
;--- Read the colortab ---------------------------------------------------
colortab:
		bsr.b	readbyte
		lea	bytepuffer,a0
		move.l	(a0),d3
		move.l	d3,d7
		divs	#3,d7
		bsr.b	readchunk
		subq.w	#1,d7
		lea	chunkpuffer,a0
		lea	farbtab+2,a1
nextcol:
		moveq	#0,d0
		moveq	#0,d1
		move.b	(a0)+,d1
		lsl.w	#4,d1
		move.b	(a0)+,d1		
		move.b	(a0)+,d0
		lsr.w	#4,d0
		or.w	d0,d1
		move.w	d1,(a1)
		addq.l	#4,a1
		dbra	d7,nextcol
		bra.w	nextread


;--- werte CAMG Chunk aus -----------------------------------------------
hamehb:
		bsr.b	readbyte
		lea	bytepuffer,a0
		move.l	(a0),d3
		bsr.b	readchunk
		lea	chunkpuffer,a0
		move.l	(a0),d0
		move.w	d0,viewmode(a5)		
		bra.w	nextread		

;--- DPPS überlesen ----
dpps:
		bsr.b	readbyte
		lea	bytepuffer,a0
		move.l	(a0),d3
		bsr.b	readchunk		
		bra.w	nextread

;--- BODY-Chunk einlesen (das ganze bild einlesen) ---
loadpic:
		bsr.w	readbyte
		lea	bytepuffer,a0
		move.l	(a0),d7
		move.l	d7,bodylaenge(a5)
		move.w	breite(a5),d0
		move.w	hoehe(a5),d1
		muls	d1,d0
		lsr.l	#3,d0
		moveq	#0,d3
		move.l	d0,oneplanesize(a5)
		move.b	planes(a5),d3
		muls	d3,d0
		move.l	d0,memsize(a5)
		move.l	#$10002,d1
		move.l	4.w,a6
		jsr	allocmem(a6)
		move.l	d0,picmem(a5)			
;		beq	memerror
		tst.b	crunchmode(a5)
	;	beq	loadnotcrunch

;--- Load Crunched Picdaten ---

		move.l	d7,d0
		move.l	#$10000,d1
		jsr	allocmem(a6)
		move.l	d0,loadbody(a5)
;		beq	memerror

		move.l	filehandle(a5),d1
		move.l	d0,d2
		move.l	d7,d3
		move.l	dosbase(a5),a6
		jsr	read(a6)
		
		move.w	breite(a5),d7
		lsr.l	#3,d7		;Breite in Byte
		move.l	d7,bytebreite(a5)
		move.l	picmem(a5),a1
		move.l	loadbody(a5),a0		
newline:
		move.l	a1,a2
		moveq	#0,d6
		move.b	planes(a5),d6
		subq.l	#1,d6
nextplane:		
		sub.l	a3,a3
loop:
		moveq	#0,d0
		move.b	(a0)+,d0
		bmi.b	packed
copy:
		addq.w	#1,a3
		move.b	(a0)+,(a2)+
		dbra	d0,copy
		cmp.w	a3,d7
		beq.b	newplane
		bra.b	loop	
packed:
		neg.b	d0
		move.b	(a0)+,d1
copy1:
		addq.w	#1,a3
		move.b	d1,(a2)+
		dbra	d0,copy1
		cmp.w	a3,d7
		bne.b	loop
newplane:
		add.l	oneplanesize(a5),a2
		dbra	d6,nextplane		
		add.l	bytebreite(a5),a1
		dbra	d5,newline		

		bra	notiff

;-------------------------------------------------------------------------
cut:
		bsr.w	checkm
		bsr.w	setspr
		btst	#6,$bfe001
		beq.b	drawgrid
		bsr.w	setline
		btst	#10,$dff016
		bne.b	cut
		bra.w	old

;--- Drawgrid ---
drawgrid:
		move.w	oldx(a5),d5
		move.w	oldy(a5),d6
		bsr.w	drawl		;lösche Fadenkreuz

		move.w	oldx(a5),xbox(a5)	;merke erste Koordinaten
		move.w	oldy(a5),ybox(a5)

		bsr.b	drawbox		;zeichne erste Box

waitmouse:		
		bsr.w	checkm
		bsr.w	setspr
		btst	#6,$bfe001
		bne.w	old
		bsr.b	drawbox
		bra.b	waitmouse


notnew:
		bra.w	old

;--- Zeichne CutGitter ---

drawbox:
		move.w	oldx(a5),d0
		move.w	xmouse(a5),d1
		cmp.w	d0,d1
		bne.b	.dr
		move.w	oldy(a5),d0
		move.w	ymouse(a5),d1
		cmp.w	d0,d1
		bne.b	.dr
		rts
.dr
		move.l	4(a6),d7
		and.l	#$fff00,d7
		cmp.l	#$13000,d7
		bne.b	drawbox

		move.w	xbox(a5),d0
		move.w	ybox(a5),d1
		move.w	oldx(a5),d2
		move.w	oldy(a5),d3
		sub.w	#$80,d0
		sub.w	#$29,d1
		sub.w	#$80,d2
		sub.w	#$29,d3
		move.w	d0,xboxreal(a5)
		move.w	d1,yboxreal(a5)
		move.w	d2,oldxreal(a5)
		move.w	d3,oldyreal(a5)
		move.w	xmouse(a5),d4
		sub.w	#$80,d4
		move.w	d4,xmousereal(a5)
		move.w	ymouse(a5),d5	
		sub.w	#$29,d5
		move.w	d5,ymousereal(a5)

		move.w	oldxreal(a5),d7
		move.w	xboxreal(a5),d6
		sub.w	d6,d7
		bge.b	.wei
		not.w	d7	;Differenz kleiner null
		addq.w	#1,d7
.wei:
		cmp.w	#0,d7
		beq.b	norast
		move.w	d7,boxsize(a5)
		lsr.w	#4,d7	;Wiviel Raster ?
		cmp.w	#0,d7
		beq.b	norast
		move.w	d7,d6
		lsl.w	#4,d7
		move.w	boxsize(a5),d5
		sub.w	d7,d5
		bne.b	sizeok
		subq.w	#1,d6
		cmp.w	#0,d6
		bhi.b	sizeok
		bra.b	norast
sizeok:
		move.w	oldrast(a5),d7	;Wiviel Raster müssen gelöscht werden
		cmp.w	#0,d7
		beq.b	noclr	 ;es müssen noch keine Raster gelöscht werden
		
		subq.w	#1,d7
		move.w	xboxreal(a5),d0
;.w		move.l	4(a6),d5
;		and.l	#$fff00,d5
;		cmp.l	#$13000,d5
;		bne	.w
nextrast:
		add.w	#16,d0
		move.w	yboxreal(a5),d1
		move.w	d0,d2
		move.w	oldyreal(a5),d3
		bsr.w	drawli		;lösche alte Raster
		dbra	d7,nextrast
noclr:
;.w		move.l	4(a6),d5
;		and.l	#$fff00,d5
;		cmp.l	#$13000,d5
;		bne	.w
		move.w	d6,newrast(a5)	;Anzahl raster merken
		subq.w	#1,d6
		move.w	xboxreal(a5),d0
nextrast1:
		add.w	#16,d0
		move.w	d0,d2
		move.w	ymousereal(a5),d3
		bsr.w	drawli
		dbra	d6,nextrast1
		move.w	newrast(a5),oldrast(a5)
norast:
		move.w	xmouse(a5),oldx(a5)
		move.w	ymouse(a5),oldy(a5)



		move.w	xboxreal(a5),d0
		move.w	yboxreal(a5),d1
		move.w	oldxreal(a5),d2
		move.w	oldyreal(a5),d3
		move.w	xmousereal(a5),d4
		move.w	ymousereal(a5),d5

		move.w	d1,d3
		bsr.w	drawli		;lösche alte line
		move.w	d4,d2
		bsr.w	drawli		;zeichen neue line		

		move.w	oldxreal(a5),d0
		move.w	d0,d2
		move.w	oldyreal(a5),d3
		bsr.w	drawli		;lösche alte y-line
		move.w	d4,d0
		move.w	d4,d2
		move.w	d5,d3		
		bsr.w	drawli		;zeichne neue y-line

		move.w	oldxreal(a5),d0
		move.w	oldyreal(a5),d1
		move.w	xboxreal(a5),d2
		move.w	d1,d3
		bsr.w	drawli
		move.w	d4,d0
		move.w	d5,d1
		move.w	d1,d3
		bsr.w	drawli

		move.w	d2,d0
		move.w	oldyreal(a5),d1
		move.w	yboxreal(a5),d3
		bsr.b	drawli
		move.w	d5,d1
		bsr.b	drawli		

;--- Zeichne Raster ---
		
		rts

;--- SETLINE ---
setline:
		move.w	xmouse(a5),d0
		move.w	ymouse(a5),d1
		move.w	oldx(a5),d2
		move.w	oldy(a5),d3
		sub.w	d2,d0
		bne.b	.draw
		sub.w	d3,d1
		bne.b	.draw
		rts		
.draw:
		move.l	4(a6),d7
		and.l	#$fff00,d7
		cmp.l	#$13000,d7
		bne.b	.draw

		move.w	oldx(a5),d5
		move.w	oldy(a5),d6
		bsr.b	drawl
		move.w	xmouse(a5),d5
		move.w	ymouse(a5),d6
		move.w	d5,oldx(a5)
		move.w	d6,oldy(a5)
		bra.w	drawl

drawl:
		sub.w	#$80,d5
		sub.w	#$29,d6
		bsr.w	lineinit
		move.l	d5,d0
		moveq	#0,d1
		move.l	d5,d2
		move.l	#255,d3
		bsr.b	drawli
		moveq	#0,d0
		move.l	d6,d1
		move.l	#319,d2
		move.l	d6,d3
		bra.w	drawli

drawli:
		movem.l	d0-d7/a0-a6,-(a7)
		lea	bitplane1,a0

; ============== Zeichne Linie mit Blitter (AMIGA 11/91) ====
line:
		cmp.w	d1,d3
		bgt.s	nohi
		exg	d0,d2
		exg	d1,d3
nohi:		
		move	d0,d4
		move	d1,d5
		mulu	#br,d5
		add	d5,a0
		lsr	#4,d4
		add	d4,d4
		lea	(a0,d4.w),a0
		sub.w	d0,d2
		sub.w	d1,d3
		moveq	#15,d5
		and.l	d5,d0
		ror.l	#4,d0
		move.w	#4,d0
		tst.w	d2
		bpl.b	l1
		addq	#1,d0
		neg.w	d2
l1:		cmp.w	d2,d3
		ble.b	l2
		exg	d2,d3
		subq.w	#4,d0
		add.w	d0,d0
l2:
		move.w	d3,d4
		sub.w	d2,d4
		add.w	d4,d4
		add.w	d4,d4
		add.w	d3,d3
		move.w	d3,d6
		sub.w	d2,d6
		bpl.b	l3
		or.w	#16,d0
l3:
		add.w	d3,d3
		add.w	d0,d0
		add.w	d0,d0
		addq.w	#1,d2
		lsl.w	#6,d2
		addq.w	#2,d2
		swap	d3
		move.w	d4,d3
		or.l	#$0b4a0001,d0


wbl2:		btst	#14,2(a6)
		bne.b	wbl2
		move.l	d3,$62(a6)
		move	d6,$52(a6)
		move.l	a0,$48(a6)
		move.l	a0,$54(a6)
		move.l	d0,$40(a6)
		move	d2,$58(a6)
		movem.l	(a7)+,d0-d7/a0-a6
		rts

; =================== Init Blitter ==========================
;line_init vor line_Befehlen
; d0/d1		x1/y2
; d2/d3		x2/y2
; a0		bitplane
; a6		aus line_init belassen
; d4-d6		Arbeitsregister

br = 40 	;breite der bitplane

lineinit:
wbl1:		btst	#14,2(a6)
		bne.b	wbl1
		move	#%1111111111111111,$72(a6)
		move.l	#-1,$44(a6)
		move	#br,$60(a6)
		move	#br,$66(a6)
		move	#$8000,$74(a6)
		rts


;--- CHECK MOUSE ---
checkm:
		move.w	$a(a6),d0
		move.w	d0,d1
		lsr	#8,d1
		sub.b	mold(a5),d1
		ext	d1
		add.w	d1,ymouse(a5)		
		sub.b	mold+1(a5),d0
		ext	d0
		add	d0,xmouse(a5)
		move.w	$a(a6),mold(a5)
		rts
		
;--- SET SPRITE d0=x d1=y ---
setspr:
		lea	spr1,a0
		move.w	xmouse(a5),d0
		move.w	ymouse(a5),d1
		cmp.w	#$80,d0
		bhs.b	.weit
		move.w	#$80,d0
		move.w	d0,xmouse(a5)
.weit:
		cmp.w	#$29,d1
		bhs.b	.weit1
		move.w	#$29,d1
		move.w	d1,ymouse(a5)
.weit1:
		cmp.w	#$1bf,d0
		blo.b	.weit2
		move.w	#$1bf,d0
		move.w	d0,xmouse(a5)
.weit2:
		cmp.w	#$128,d1
		blo.b	.weit3
		move.w	#$128,d1
		move.w	d1,ymouse(a5)
.weit3:
		subq.w	#7,d0		;Sprite offset
		subq.w	#7,d1
		moveq	#0,d3
		move.b	d1,(a0)		;Y erstes Byte
		btst	#8,d1		;y8
		beq.b	no
		or.w	#4,d3
no:
		add.l	#15,d1
		move.b	d1,2(a0)
		btst	#8,d1
		beq.b	noz
		or.w	#2,d3
noz:
		lsr	#1,d0
		bcc.b	nox0
		or.w	#1,d3
nox0:
		move.b	d0,1(a0)
		move.b	d3,3(a0)
		rts

;--- TABELLEN UND DATEN -----------------------------------------------------

plane1:		dc.l	bitplane1
plane2:		dc.l	bitplane2

loadfile:
		dc.b	'Load File',0
savefile:
		dc.b	'Save File',0

		section	daten,BSS

daten:

;--- System ---
gfxbase:	rs.l	1
dosbase:	rs.l	1
reqbase:	rs.l	1
filehandle:	rs.l	1
oldcop:		rs.l	1
picmem:		rs.l	1
memsize:	rs.l	1
loadbody:	rs.l	1
bodylaenge:	rs.l	1

;--- Intern ---
ymouse:		rs.w	1
xmouse:		rs.w	1
mold:		rs.w	1
xmousereal:	rs.w	1
ymousereal:	rs.w	1
oldx:		rs.w	1
oldy:		rs.w	1
oldxreal:	rs.w	1
oldyreal:	rs.w	1
xbox:		rs.w	1
ybox:		rs.w	1
xboxreal:	rs.w	1
yboxreal:	rs.w	1
boxsize:	rs.w	1
oldrast:	rs.w	1
newrast:	rs.w	1

;--- Picdaten ---
breite:		rs.w	1
hoehe:		rs.w	1
planes:		rs.b	1
testbyte:	rs.b	1
crunchmode:	rs.b	1
leer:		rs.b	1
transcolor:	rs.w	1
verhaeltnis:	rs.w	1
xresolution:	rs.w	1
yresolution:	rs.w	1
viewmode:	rs.w	1
bytebreite:	rs.l	1
oneplanesize:	rs.l	1

ReqPuffer:

Version		rs.w	1			;Version
windowtitle	rs.l	1			;Zeiger auf Titletext
Dir		rs.l	1			;Zeiger auf Dir
File		rs.l	1			;Zeiger auf File
Pathname	rs.l	1			;Zeiger auf Pathname
rp:
window		rs.l	1			;Zeiger Window
maxExtendedSe	rs.w	1			;MaxExtendetSelect
NumLines	rs.w	1			;Anzahl der Linien in Filerequester
NumColumss	rs.w	1			;Zeichenlänge ? in Filerequester
DevColumns	rs.w	1			;Zeichenlänge ? in Devicewindow
Flags		rs.l	1			;Flags

Dirnamecolor	rs.w	1			;Dirnamencolor
Filenamecolor	rs.w	1			;Filenamencolor
Devicenamecolr	rs.w	1			;Devicenamencolor
Fontnamecolor	rs.w	1			;Fontnamencolor
fontsizecolor	rs.w	1			;color 32 or some other colors

detailcolor	rs.w	1			;Detailcolor
blockcolor	rs.w	1			;Blockcolor

gadgettextcol	rs.w	1			;Color für 5 boolean gadgets
textmessagecol	rs.w	1			;Color für Top-Text
stringnamecol	rs.w	1			;Color für Wort-Schreiber
stringgadgetco	rs.w	1			;BorderGadgetsColor	Hidewindow
bboxbordercolor	rs.w	1			;BoxBorderColor-	Filewindow
gadgetboxcolor	rs.w	1			;Gadgetboxcolor-	OK-Gadget

Struct1		rs.b	36			;frq_rfu_stuf
Struct2:	rs.b	12			;frq_dirStateStamp

WindowleftEdge	rs.w	1			;linke Ecke des Requesters
WindowTopEdge	rs.w	1			;WindowTopEdge

FontYSize	rs.w	1			;Returnfeld FontYSize (Höhe)
Fontstyle	rs.w	1			;Schriftparameter (Kursiv,Fett)

ExtentedSelect	rs.l	1			;ExtendetSelect

Struct3:	rs.b	32			;frq_Hide,Wildlenght+2
Struct4:	rs.b	32			;frq_Show,Wildlenght+2

FilePufferPos	rs.w	1			;FilepufferPosition
FileDispPos	rs.w	1			;FileDispPosition
DirBufferPos	rs.w	1			;DirPufferposition
DirDispPos	rs.w	1			;DirDispPosition
HideBufferPos	rs.w	1			;HidePufferposition
HideDispPos	rs.w	1			;HideDispPos
ShowBufferPos	rs.w	1			;ShowBufferPos
ShowDispPos	rs.w	1			;ShowDispPos

Memory		rs.l	1			;Memoryadr für Directories
Memory2		rs.l	1			;Memory2adr für Hidden-Files
.Lock:		rs.l	1			;frq_lock

Struct5:	rs.b	132			;PrivaterDirPuffer,dsize+2

FileInfoBlock	rs.l	1			;FileInfoblockadr
NumEntries	rs.w	1			;NumEntries
NumHiddenEnt	rs.w	1			;NumHiddenEntries
FileStartnum	rs.w	1			;FilesStartnumber
Devicestartnum	rs.w	1			;DeviceStartnumber
	
dataslen:	rs.w	0
		ds.b	dataslen

Filepuffer:	ds.b	162
Dirname:	ds.b	30	
Filename:	ds.b	20

bytepuffer:	ds.b	4
chunkpuffer:	ds.b	50


		section	copper,data_c
copper:
		dc.w	$008e,$2981,$0090,$29c1
		dc.w	$0092,$0038,$0094,$00d0
		dc.w	$0108,$0002,$010a,$0002
		dc.w	$0104,$0010,$0102,$0000
		dc.w	$0100,$5200	
		dc.w	$120,0,$122,0,$124,0,$126,0,$128,0,$12a,0,$12c,0
		dc.w	$12e,0,$130,0,$132,0,$134,0,$136,0,$138,0,$13a,0
		dc.w	$13c,0,$13e,0

farbtab:
		dc.w 	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
		dc.w 	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
		dc.w 	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
		dc.w 	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
		dc.w 	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
		dc.w 	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
		dc.w 	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
		dc.w 	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000
		


init:
		dc.w	$e0,0,$e2,0
		dc.w	$e4,0,$e6,0
		dc.w	$e8,0,$ea,0
		dc.w	$ec,0,$ee,0
		dc.w	$f0,0,$f2,0
		
sprinit:	dc.w	$0120,0,$0122,0

		dc.l	-2	


spr1:		dc.w	$0000,$0000
		dc.w	$0100,$0000,$0100,$0100
		dc.w	$0100,$0000,$0100,$0100
		dc.w	$0100,$0000,$0000,$0000
		dc.w	$0000,$0000,$F83E,$5114
		dc.w	$0000,$0000,$0000,$0000
		dc.w	$0100,$0000,$0100,$0100
		dc.w	$0100,$0000,$0100,$0100
		dc.w	$0100,$0000
		dc.w	$0000,$0000

		section Planes,bss_c

bitplane1:	ds.b	320*256/8*3
bitplane2:	ds.b	320*256/8*3
endplane:
