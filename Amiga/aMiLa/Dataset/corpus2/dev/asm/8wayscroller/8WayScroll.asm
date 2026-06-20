;******************************************************************
;******************************************************************
;***								***
;***	8-Way-Tile-Scroller					***
;***								***
;***    $VER: 8-Way-Tile-Scroller V1.04 (14.06.93)		***
;***								***
;***								***
;***	Coding: Gonzo, Green Rabbits Inc.  (no scene-group)	***
;***								***
;***	Contact me via EMail: hollosi@fm11ap01.tu-graz.ac.at	***
;***				(only until 1.7.1993)		***
;***	or via snail mail:  Arno Hollosi			***
;***			    Oberndorf 313			***
;***			    A-6322 Kirchbichl			***
;***			    AUSTRIA				***
;***								***
;***	All rights reserved.					***
;***	You are allowed to use this source for your personel	***
;***	purposes. Any commercial usage without the written	***
;***	permission of the author is prohibited.			***
;***	Using this routine in any commercial product is		***
;***	forbidden. PD and FreeWare authors may use it in	***
;***	their products, if they mention me in the credits.	***
;***								***
;***								***
;***	You use this source at your own risk. Never will I be	***
;***	liable for any damage caused by using this source;	***
;***	dircet or indirect.					***
;***								***
;***	Copying this source is allowed, if all files are	***
;***	provided AND were not modified before.			***
;***								***
;******************************************************************
;******************************************************************



;------------------------------------------------
;------------------- Offsets --------------------
;------------------------------------------------

;exec.library

ExecBase	equ 4
OpenLibrary	equ -408
CloseLibrary	equ -414
AllocMem	equ -198
FreeMem		equ -210
Disable		equ -120
Enable		equ -126

;graphics.library

OwnBlitter	equ -456
DisownBlitter	equ -462
LoadView	equ -222
WaitTOF		equ -270

ActiView	equ 34
copinit		equ 38



;------------------------------------------------
;----------------- Register ---------------------
;------------------------------------------------


dmacon   equ  $96
dmaconr  equ  $02

cia_a    equ  $bfe001	;Mouse-Register

bltcon0  equ  $40	;BlitterRegister
bltcon1  equ  $42
bltafwm  equ  $44
bltcpth  equ  $48
bltbpth  equ  $4c
bltapth  equ  $50
bltdpth  equ  $54
bltsize  equ  $58
bltcmod  equ  $60
bltbmod  equ  $62
bltamod  equ  $64
bltdmod  equ  $66




;------------------------------------------------
;-------------------  Makros  -------------------
;------------------------------------------------


LIBF:	macro			;libbase, funcoffset
	move.l	\1,a6
	jsr	\2(a6)
	endm

oplib:  macro			;oplib name,base,error
	lea	\1(pc),a1
	LIBF	ExecBase,OpenLibrary
	move.l	d0,\2
	beq	\3
	endm

cllib:  macro			;cllib base
	move.l	\1(pc),a1
	LIBF	ExecBase,CloseLibrary
	endm


getmem: macro			;base, size, requirements, error
	move.l	#\2,d0
	move.l	#\3,d1
	LIBF	ExecBase,AllocMem
	move.l	d0,\1
	beq	\4
	endm


freeit:	macro			;base, size
	move.l	\1(pc),a1
	move.l	#\2,d0
	LIBF	ExecBase,FreeMem
	endm


wait_blitter:  macro
waitbl\@:
	btst	#6,dmaconr(a6)		;Wait for our mighty friend
				;BBUSY is the 6th bit of upper byte !!!
	bne.s	waitbl\@
	endm



;------------------------------------------------
;---------------- other defines  ----------------
;------------------------------------------------


TILES_NUM	equ 32			;4 Rows a 20 Tiles
TILES_MODULO	equ TILES_NUM*2
TILES_SIZE	equ TILES_NUM*5*16*2

SCR_WDTH	equ 18
SCR_HGHT	equ 12

SCR_WRDX	equ (SCR_WDTH+4)*2	;4 extra words
SCR_LINES	equ (SCR_HGHT+3)*16	;3*16 extra lines

LEV_XSIZE	equ 100
LEV_YSIZE	equ 100
LEVEL_SIZE	equ LEV_XSIZE*LEV_YSIZE*2

		;ATTENTION!!
		;LEVEL_SIZE must be <$8000 because of relative
		;addressing-modes used in some routines

PLNE_SIZE	equ SCR_WRDX*SCR_LINES*5+(LEV_XSIZE*2)

FASTMEM		equ $01		;MEMF_PUBLIC, because we don't
				;want GIGAMEM to swap our stuff
CHIPMEM		equ $03





;------------------------------------------------
;-------------------  Start  --------------------
;------------------------------------------------


	SECTION scroller_code,CODE

run:
	oplib	gfxname,gfxbase,error1

	getmem	LEVEL_ADR,LEVEL_SIZE,FASTMEM,error2
	getmem	PLNE_ADR,PLNE_SIZE,CHIPMEM,error3
	getmem	COPPER_ADR,cop_length,CHIPMEM,error4

	move.l	gfxbase(pc),a6
	move.l	ActiView(a6),oldview	;we've to remember this one

	move.l	#0,a1			;no View
	jsr	LoadView(a6)
	jsr	WaitTOF(a6)
	jsr	WaitTOF(a6)		;interlace frame

	LIBF	gfxbase,OwnBlitter
	LIBF	ExecBase,Disable	;OS says good bye

	bsr	init_all

	bsr	main			;Just do it !!

	bsr	del_all

	LIBF	ExecBase,Enable	;wake OS
	LIBF	gfxbase,DisownBlitter


	move.l	gfxbase(pc),a6		;restore old view
	move.l	oldview(pc),a1
	jsr	LoadView(a6)
	move.l	copinit(a6),$dff080	;push it into life


error5:	freeit	COPPER_ADR,cop_length	;free all memory
error4:	freeit	PLNE_ADR,PLNE_SIZE
error3:	freeit	LEVEL_ADR,LEVEL_SIZE
error2:	cllib	gfxbase
error1:
	moveq	#0,d0			;don't return an error
	rts
;--------------------------------------





;------------------------------------------------
;-------------- Sub Programms  ------------------
;------------------------------------------------



init_all:
	move.l	#$dff000,a6		;never change a6 !!
	move	dmaconr(a6),savedma	;don't forget this

	move	#$7fff,dmacon(a6)	;all DMA off
	mulu	d0,d0			;wait a little bit
	move	#$8740,dmacon(a6)	;Bitplane,no Copper, Blitter
					;Blitterpri, no sprites
					;no sound, no disk  !!!

	move.l	#-1,bltafwm(a6)	;no blitter mask

	bsr	initvar
	bsr	init_level
	bsr	print_lev
	bsr	init_origcopper
	bsr	initcopper
	rts
;------------------------------------------------

del_all:
	move	#$7fff,dmacon(a6)
	move	savedma(pc),d0
	or	#$8000,d0
	move	d0,dmacon(a6)		;restore old DMACon
	rts
;------------------------------------------------

initvar:
	lea	tile_tab(pc),a0
	lea	scroll_tiles,a1		;Init Tile-Addresses
	moveq	#TILES_NUM-1,d0
init1:	move.l	a1,(a0)+
	lea	2(a1),a1
	dbra	d0,init1

	move.l	PLNE_ADR(pc),a0
	lea	16*5*SCR_WRDX(a0),a0	;don't display left and upper strip
	lea	planes(pc),a1
	moveq	#5-1,d0
init7:	move.l	a0,20(a1)
	move.l	a0,(a1)+
	lea	SCR_WRDX(a0),a0
	dbra	d0,init7

	rts
;-----------------------------------------------

init_origcopper:
	lea	origcopper,a0

	lea	plane_list(a0),a1	;Init-PlanePointer
	lea	plane_list2+4(a0),a2	;+4 because of WAIT-command
	lea	planes(pc),a3
	moveq	#5-1,d0
iocp1:	move	(a3),2(a1)
	move	(a3)+,2(a2)
	move	(a3),6(a1)
	move	(a3)+,6(a2)
	lea	8(a1),a1
	lea	8(a2),a2
	dbra	d0,iocp1

	rts
;-----------------------------------------------

initcopper:
	;Copper was already disabled

	move	#$0038,$092(a6)		;DDFSTRT
	move	#$00c8,$094(a6)		;DDFSTOP
	move	#$3e91,$08e(a6)		;DIWSTRT  Width: 288 Pixel
	move	#$00b1,$090(a6)		;DIWSTOP

	lea	screen_colors,a0
	lea	$180(a6),a1		;initialise colors 0-31
	moveq	#32-1,d0
incp1:	move	(a0)+,(a1)+
	dbra	d0,incp1

	move.l	COPPER_ADR(pc),a0	;Copy Copperlists
	lea	origcopper,a1
	moveq	#cop_length/4-1,d0
incp3:	move.l	(a1)+,(a0)+
	dbra	d0,incp3

	move.l	COPPER_ADR(pc),$80(a6)	;COP1LC
	move	#$0000,$88(a6)
	move	#$8080,dmacon(a6)	;Copper on
	rts
;------------------------------------------------

init_level:
	move.l	LEVEL_ADR(pc),a0
	moveq	#LEV_YSIZE/2-1,d0
inlev1:	moveq	#LEV_XSIZE/2-1,d1
inlev2:	move	$006(a6),d2		;Vertical Screen-position
	and	#$1f,d2
	lsl	#2,d2
	move	d2,LEV_XSIZE*2(a0)	;2*2 block
	move	d2,(a0)+
	move	d2,LEV_XSIZE*2(a0)
	move	d2,(a0)+
	dbra	d1,inlev2
	lea	LEV_XSIZE*2(a0),a0
	dbra	d0,inlev1
	rts
;------------------------------------------------

print_lev:
	move.l	PLNE_ADR(pc),a0		;Prints Level (first time)
	lea	16*5*SCR_WRDX+2(a0),a0	;don't blit left and upper strip
	move.l	LEVEL_ADR(pc),a1

	lea	tile_tab(pc),a4

	wait_blitter
	move	#TILES_NUM*2-2,bltamod(a6)
	move	#SCR_WRDX-2,bltdmod(a6)
	move.l	#$09f00000,bltcon0(a6)	;D = A

	moveq	#SCR_HGHT+2-1,d6
prlev2:	moveq	#SCR_WDTH+3-1,d7	;X-Loop
prlev1:	move	(a1)+,d0
	move.l	(a4,d0.w),d0		;and Address

	wait_blitter
	move.l	a0,bltdpth(a6)		;Blit Block
	move.l	d0,bltapth(a6)
	move	#$1401,bltsize(a6)	;16H*5P + 1W

	lea	2(a0),a0
	dbra	d7,prlev1
	lea	(SCR_WRDX*(16*4+15)+2)(a0),a0
	lea	(LEV_XSIZE-SCR_WDTH-3)*2(a1),a1
	dbra	d6,prlev2
	rts
;-----------------------------------------------

SPEED	equ 2	;maximum: 2

get_joy:
	moveq	#0,d0
	moveq	#0,d1

	move	$00c(a6),d7	;JOY1DAT

	btst	#1,d7
	beq.s	gjoynr
	moveq	#SPEED,d0	;right
gjoynr:	btst	#9,d7
	beq.s	gjoynl
	moveq	#-SPEED,d0	;left
gjoynl:	move	d7,d6
	lsr	#1,d6
	eor	d7,d6
	btst	#0,d6
	beq.s	gjoynd
	moveq	#SPEED,d1	;down
gjoynd:	btst	#8,d6
	beq.s	gjoynu
	moveq	#-SPEED,d1	;up
gjoynu:	btst	#7,cia_a
	bne.s	gjoynf
	add	d0,d0		;fire
	add	d1,d1
gjoynf:
;---------------

	move	current_x(pc),d2
	move	current_y(pc),d3
	move	d2,old_x		;remember 'em
	move	d3,old_y
	add	d0,d2			;add speed to position
	add	d1,d3

	tst	d2			;is X-position in range ??
	bpl.s	xpos1
	moveq	#0,d2
xpos1:	cmp	#(LEV_XSIZE-SCR_WDTH)*16,d2
	ble.s	xtiny
	move	#(LEV_XSIZE-SCR_WDTH)*16,d2
xtiny:	move	d2,current_x

	tst	d3			;is Y-position in range ??
	bpl.s	ypos1
	moveq	#0,d3
ypos1:	cmp	#(LEV_YSIZE-SCR_HGHT)*16,d3
	ble.s	ytiny
	move	#(LEV_YSIZE-SCR_HGHT)*16,d3
ytiny:	move	d3,current_y

	rts
;-----------------------------------------------

scroll:
;Scrolls Screen, if necessary

	move	current_x(pc),d2
	move	current_y(pc),d3

	movem	d2/d3,-(a7)		;Let the copper do his work
	bsr	copper_scroll		; = hardware-scrolling
	movem	(a7)+,d0/d1

	move	old_x(pc),d2
	move	old_y(pc),d3
	sub	d2,d0			;real speed in pixels
	sub	d3,d1
	bsr 	blitter_scroll		;nothing happens without him
	rts
;------------------------------------------------

copper_scroll:
		;d2 = current_x, d3 = current_y

	add	#16,d2		;don't display leftest strip
	add	#16,d3		;don't display upperst strip

	move.l	COPPER_ADR(pc),a2
	lea	shift_tab(pc),a3

	move	d2,d0			;X-Direction
	and	#$0f,d2			;pixel-offset in d2
	add	d2,d2			;Calc Shift-Value
	move	(a3,d2.w),d2
	move	d2,scrl_val+2(a2)	;store it
	subq	#1,d0			;X-Word-Pos
	and	#$fff0,d0
	asr	#3,d0
	ext.l	d0			;X-offset
	move.l	PLNE_ADR(pc),d1
	add.l	d1,d0			;d0 = PLNE_ADR + X_Offset
					;     (no Y-Offset)
	move.l	d0,d5			;remember this value

	ext.l	d3			;Y-Direction
	divu	#(SCR_HGHT+3)*16,d3
	swap	d3			;height modulo buffer_height!
	move	d3,d7			;remember this value
	muls	#SCR_WRDX*5,d3		;5 planes
	add.l	d3,d0			;d0 = PLNE_ADR+X_Offset+Y_Offset

	sub	#3*16,d7		;Calc Y-Position of CopperWrap
	bmi.s	nosecy
	moveq	#-2,d6			;$fe is end of display
	sub.b	d7,d6
	bra.s	secy
nosecy:	move	#$fe,d6
secy:	move.b	d6,plane_list2(a2)	;and store it

	lea	planes(pc),a1
	moveq	#SCR_WRDX,d1
	moveq	#5-1,d3
ch_poi:	move.l	d5,20(a1)		;change Bitplane-pointers
	move.l	d0,(a1)+
	add.l	d1,d0
	add.l	d1,d5
	dbra	d3,ch_poi

	lea	plane_list+2(a2),a0	;copy'em into copperlist
	lea	plane_list2+6(a2),a2	;+6 because of WAIT-command
	lea	planes(pc),a1
	moveq	#5-1,d0
ch_lst:	move	20(a1),(a2)
	move	22(a1),4(a2)
	move	(a1)+,(a0)
	move	(a1)+,4(a0)
	lea	8(a2),a2
	lea	8(a0),a0
	dbra	d0,ch_lst
	rts

shift_tab:	dc.w $00,$ff,$ee,$dd,$cc,$bb,$aa,$99
		dc.w $88,$77,$66,$55,$44,$33,$22,$11
;------------------------------------------------

bltxmc:  macro		; d0 = SpeedX, d2 = old_X

	move	d2,d5
	add	d0,d2
	and	#$fff0,d2		;d2 = new column
	and	#$fff0,d5		;d5 = old column
	cmp	d5,d2
	beq.s	noblpx\@		;equal -> nothing new to do

	moveq	#\1*2,d6
	asr	#3,d2
	add	d2,d6			;d6 = which column will be used

	IFEQ (\1-(-1))
	  bmi.s	noblpx\@		;negative column ???
	ENDIF

	IFEQ (\1-(SCR_WDTH+1))
	  cmp	#LEV_XSIZE*2,d6		;after last visible column ??
	  bge.s	noblpx\@
	ENDIF

	move	d6,d5
	addq	#2,d5			;MemPos = Level_ColPos + 2

	lea	blt_valx(pc),a0		;init this new blit
	movem	d5/d6,(a0)
	move	#4*2,blt_cntx		;blit in 4 steps
noblpx\@:
	endm
;---------------

bltymc:  macro		;d1=SpeedY, d2=old_X, d3=old_Y

	move	d3,d5
	add	d1,d3
	and	#$fff0,d3		;d3 = new line
	and	#$fff0,d5		;d5 = old line
	cmp	d5,d3
	beq.s	nobly\@			;equal -> nothing new to blit

	moveq	#\1*2,d4
	asr	#3,d3
	add	d3,d4			;d4 = which line will be used

	IFEQ (\1-(-1))
	  bmi.s	nobly\@			;negative column ??
	ENDIF

	IFEQ (\1-(SCR_HGHT+1))
	  cmp	#LEV_YSIZE*2,d4		;after last visible line ??
	  bge.s	nobly\@

	  add	#(SCR_HGHT+2)*2,d3	;bottom of screen
	ENDIF

	ext.l	d3
	divu	#(SCR_HGHT+3)*2,d3
	swap	d3			;line modulo buffer_height

	lea	blt_valy+2(pc),a0
	lsr	#3,d2
	and.b	#$fe,d2			;get offset in byte
	move	d2,(a0)+		;d2 = X-Offset
	movem	d3/d4,(a0)		;d3 = where to blit in buffer
					;d4 = line in LEVEL_DAT
	move	#4*2,blt_cnty
	lea	blt_fldy(pc),a0		;store Line in field
	move	d4,(a0,d3.w)
nobly\@:
	endm
;---------------

blitter_scroll:
	;d0/d1  SpeedX/Y in Pixel   d2/d3 old_X/Y

bltx:	move	d2,-(a7)
	tst	d0
	beq.s	blty			;no speed in X-direction
	bmi.s	negx
	bltxmc	(SCR_WDTH+1)		;X-speed positive
	bra.s	blty
negx:	bltxmc	-1			;X-speed negative

blty:	move	(a7)+,d2
	tst	d1
	beq	blt_done		;no speed in Y-direction
	bmi.s	negy
	bltymc	(SCR_HGHT+1)		;Y-speed positive
	bra.s	blt_done
negy:	bltymc	-1			;Y-speed negative


blt_done:
	tst	blt_cntx		;any work to do ???
	beq.s	blt_nx
	subq	#2,blt_cntx
	bsr	blit_x			;Work for X-Direction
blt_nx:
	tst	blt_cnty		;any work to do ??
	beq.s	blt_ny
	subq	#2,blt_cnty
	bsr	blit_y			;Work for Y-Direction
blt_ny:
	rts


blt_tabx:	dc.w 0,4,8,12		;Y-POS to start blitting
		dc.w 4,4,4,3		;amount to blit
blt_valx:	dc.w 0,0		;colmemory, colnumber
blt_cntx:	dc.w 0

blt_fldy:	dc.w 0,0,2,4,6,8,10,12,14,16,18,20,22,24,26
blt_cnty:	dc.w 0

blt_taby:	dc.w 15,10,5,0		;X-POS to start blitting
		dc.w  6,5,5,5		;amount to blit

blt_valy:	dc.w 0,0,0,0	;X-off (Long), linememory, linenumber
;------------------------------------------------

blit_x:
	lea	blt_valx(pc),a0
	moveq	#0,d2
	movem	(a0),d2/d4		;d2 = Column in Memory
					;d4 = which column
	move	blt_cntx(pc),d5		;d5 = phase number of blit

	move.l	LEVEL_ADR(pc),a0
	lea	blt_tabx(pc),a1
	lea	tile_tab(pc),a2
	lea	blt_fldy(pc),a3

	move	(a1,d5.w),d6		;Y-Position of Blocks
	move	d6,d0
	mulu	#16*5*SCR_WRDX,d6	;in bytes
	add.l	d2,d6			;d2 = X-offset
	move.l	PLNE_ADR(pc),a4
	add.l	d6,a4			;StartBlitPos on Screen
	add	d0,d0

	move	4*2(a1,d5.w),d7		;Number of Blocks to blit

	wait_blitter
	move	#TILES_NUM*2-2,bltamod(a6)
	move	#SCR_WRDX-2,bltdmod(a6)
	move.l	#$09f00000,bltcon0(a6)	;D = A, noshift
	bra.s	subxd7
blxlop:
	move	(a3,d0.w),d1		;Y-Pos in Level
	mulu	#LEV_XSIZE,d1
	add	d4,d1			;d4 = column to blit
	move	(a0,d1.w),d1		;get LEVEL_DATA
	move.l	(a2,d1.w),d1		;and address of tile

	wait_blitter
	move.l	a4,bltdpth(a6)		;Blit Block
	move.l	d1,bltapth(a6)
	move	#$1401,bltsize(a6)	;16H + 1W

	lea	16*5*SCR_WRDX(a4),a4
	addq	#2,d0			;blit into next line
subxd7:	dbra	d7,blxlop
	rts
;------------------------------------------------

blit_y:
	lea	blt_valy(pc),a0
	move.l	(a0)+,d2		;d2 = X-Offset
	movem	(a0),d3/d4	;d3 = Line in Memory   d4 = which Line
	move	blt_cnty(pc),d5		;d5 = Pixelpos

	move.l	LEVEL_ADR(pc),a0
	lea	-2(a0),a0		;to correct X-Offset
	lea	blt_taby(pc),a1
	lea	tile_tab(pc),a2

	move	(a1,d5.w),d0		;X-Position of Blocks
	add	d0,d0
	ext.l	d0

	move	d3,d6
	mulu	#16*5*SCR_WRDX/2,d6
	move.l	PLNE_ADR(pc),a4
	add.l	d2,a4
	add.l	d6,a4			;StartBlitPos on Screen
	add.l	d0,a4

	move	4*2(a1,d5.w),d7		;Number of Blocks to blit

	mulu	#LEV_XSIZE,d4		;d4 = Y-Offset in LEVEL_DAT

	wait_blitter
	move	#TILES_NUM*2-2,bltamod(a6)
	move	#SCR_WRDX-2,bltdmod(a6)
	move.l	#$09f00000,bltcon0(a6)	;D = A
	bra.s	subyd7

blylop:	move	d4,d1
	move	d2,d6
	add	d0,d6
	bmi.s	blynxt			;no negative X-column please
	cmp	#LEV_XSIZE*2,d6
	bgt.s	blynxt			;no greater X-column please
	add	d6,d1
	move	(a0,d1.w),d1
	move.l	(a2,d1.w),d1		;Adr of Tile

	wait_blitter
	move.l	a4,bltdpth(a6)		;Blit Block
	move.l	d1,bltapth(a6)
	move	#$1401,bltsize(a6)	;16H + 1W

blynxt:	lea	2(a4),a4
	addq	#2,d0
subyd7:	dbra	d7,blylop
	rts
;------------------------------------------------


main:
	move.l	4(a6),d0		;never thought I'd need TWO of 'em
	and.l	#$1ff00,d0		;BUT this is very important on
	cmp.l	#$0f000,d0		;faster machines
	bne.s	main			;otherwise we'll recognize
waitraster:				;the same line several times
	move.l	4(a6),d0
	and.l	#$1ff00,d0
	cmp.l	#$10100,d0
	bne.s	waitraster

	bsr	get_joy			;reads Joystick, calcs current_pos

	move.l	4(a6),old		;*** to get time in rasterlines
	move	#$555,$180(a6)		;***

	bsr	scroll

	move	#$000,$180(a6)		;*** to get time in rasterlines
	move.l	4(a6),d0		;***
	sub.l	old(pc),d0		;***
	cmp.l	big(pc),d0		;***
	blo.s	mouse			;***
	move.l	d0,big			;***

mouse:	btst	#6,cia_a		;Mouse ??
	bne.s	main

	move.l	big(pc),d0		;*** beautify messured time
	lsr.l	#8,d0			;***
	and	#$1ff,d0		;***
	addq	#$001,d0		;***
	move.l	d0,big			;***

	rts

old:	dc.l 0
big:	dc.l 0
;------------------------------------------------





;------------------------------------------------
;-------------------  Datas  --------------------
;------------------------------------------------


version:	dc.b "$VER: 8-Way-Tile-Scroller V1.00 (10.05.93)",0
  even

savedma:	dc.w 0		;System-Datas
gfxbase:	dc.l 0
oldview:	dc.l 0

gfxname:	dc.b "graphics.library",0
  even
;------------------------------------------------

LEVEL_ADR:	dc.l 0
PLNE_ADR:	dc.l 0
COPPER_ADR:	dc.l 0

planes:		ds.l 5			;Planes with Y-Offset
					;>> plane_list
		ds.l 5			;Planes without Y-Off
					;>> plane_list2


;----------------- Level-Datas ------------------


tile_tab:	ds.l TILES_NUM		;Addresses of Tiles

current_x:	dc.w 0
current_y:	dc.w 0
old_x:		dc.w 0
old_y:		dc.w 0

;------------------------------------------------

	SECTION scroller_data,DATA


origcopper:
		dc.w $180,$000

off_plane:	dc.w $e0,0000,$e2,0000	;Bitplanes
		dc.w $e4,0000,$e6,0000
		dc.w $e8,0000,$ea,0000
		dc.w $ec,0000,$ee,0000
		dc.w $f0,0000,$f2,0000
		dc.w $108,6+(4*SCR_WRDX),$10a,6+(4*SCR_WRDX)	;Modulo
;BPLMODS must be changed by hand, if you modify SCR_WRDX

		dc.w $100,$5200

off_scrl:	dc.w $102,$00

off_plane2:	dc.w $fe01,$fffe
		dc.w $e0,0000,$e2,0000	;Bitplanes
		dc.w $e4,0000,$e6,0000
		dc.w $e8,0000,$ea,0000
		dc.w $ec,0000,$ee,0000
		dc.w $f0,0000,$f2,0000
		dc.w $180,$003		;Colors

		dc.w $fe01,$fffe
		dc.w $100,$0200		;end of screen

		dc.w $ffff,$fffe		;End
		dc.w $ffff,$fffe		;End
coppend:

plane_list	equ off_plane-origcopper
plane_list2	equ off_plane2-origcopper
scrl_val	equ off_scrl-origcopper
cop_length	equ coppend-origcopper


screen_colors:
	dc.w $000,$AAA,$E00,$A00,$D80,$FE0,$8F0,$080
	dc.w $0B6,$0DD,$0AF,$07C,$00F,$70F,$C0E,$C08
	dc.w $620,$E52,$A52,$FCA,$333,$444,$555,$666
	dc.w $777,$888,$999,$AAA,$CCC,$DDD,$EEE,$FFF

;------------------------------------------------

	SECTION scroller_tiles,DATA_C

scroll_tiles:
	IncBin "Scroll_tiles.raw"


