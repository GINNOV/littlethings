;This source-code is converted using PPC680x0, (c)2000 Coyote Flux
;Coded in 100% machine-language...!!! Amiga Rulez! PC Suxx!

;

;* file examples/freemem2.s - Workbench version
* file examples/freemem2.s - Workbench version
;

;* a sample Intuition program to display a window constantly showing
* a sample Intuition program to display a window constantly showing
;* the free memory figure, until it's closed
* the free memory figure, until it's closed
;

;* this source code (C) HiSoft 1992 All Rights Reserved
* this source code (C) HiSoft 1992 All Rights Reserved
;

;* both source and binary are FreeWare and may be distributed free of charge
* both source and binary are FreeWare and may be distributed free of charge
;* so long as copyright messages are not removed
* so long as copyright messages are not removed
;

;* revision history:
* revision history:
;* 7th June 86	written
* 7th June 86	written
;* 22nd Sept 86	changed includes
* 22nd Sept 86	changed includes
;* 18th Dec 86	uses easystart for workbench version
* 18th Dec 86	uses easystart for workbench version
;* 27th Feb 92	now includes pre-assembled header
* 27th Feb 92	now includes pre-assembled header
;

;* ensure case dependent and debug
* ensure case dependent and debug
;	opt	c+,d+
	
;

;	incdir	ppcinclude:
	incdir	ppcinclude:
;	include	powerpc/powerpc.i
	include	powerpc/powerpc.i
;	warpreq
	xref	_PowerPCBase
	xref	_SysBase
;	xref	_DOSBase
	xref	_LinkerDB

	executable
;	forceb
;

;

;* firstly get the required constants and macros
* firstly get the required constants and macros
;	include	intuition/intuition.i
	include	intuition/intuition.i
;	include	lvos/intuition_lib.i
	include	lvos/intuition_lib.i
;	include	lvos/exec_lib.i
	include	lvos/exec_lib.i
;	include	lvos/graphics_lib.i
	include	lvos/graphics_lib.i
;	include	exec/memory.i
	include	exec/memory.i
;	include	lvos/dos_lib.i
	include	lvos/dos_lib.i
;	include	libraries/dos.i
	include	libraries/dos.i
;

;* constant for frequency of re-display
* constant for frequency of re-display
;timeout	equ	25				in 50ths of a second
timeout	equ	25				in 50ths of a second
;

;* firstly open the intuition library
* firstly open the intuition library
;	prolog
	prolog
;	head
	
RUN680X0        MACRO
		pushgpr r11-r12/r14-r19/r27-r31
		subi    local,local,PP_SIZE
		stw     r3,PP_REGS(local)
		stw     r4,PP_REGS+1*4(local)
		stw     r5,PP_REGS+2*4(local)
		stw     r6,PP_REGS+3*4(local)
		stw     r7,PP_REGS+4*4(local)
		stw     r8,PP_REGS+5*4(local)
		stw     r9,PP_REGS+6*4(local)
		stw     r10,PP_REGS+7*4(local)
		stw     r20,PP_REGS+8*4(local)
		stw     r21,PP_REGS+9*4(local)
		stw     r22,PP_REGS+10*4(local)
		stw     r23,PP_REGS+11*4(local)
		stw     r24,PP_REGS+12*4(local)
		stw     r25,PP_REGS+13*4(local)
		stw     r26,PP_CODE(local)
		stw     r26,PP_REGS+14*4(local)
		stw     r31,PP_OFFSET(local)
		li      r3,0
		stw     r3,PP_FLAGS(local)
		stw     r3,PP_STACKPTR(local)
		stw     r3,PP_STACKSIZE(local)
		mr      r4,local
		lw      r3,_PowerPCBase
		lwz     r0,-300+2(r3)
		mtlr    r0
		blrl
		lwz     r3,PP_REGS(local)
		lwz     r4,PP_REGS+1*4(local)
		lwz     r5,PP_REGS+2*4(local)
		lwz     r6,PP_REGS+3*4(local)
		lwz     r7,PP_REGS+4*4(local)
		lwz     r8,PP_REGS+5*4(local)
		lwz     r9,PP_REGS+6*4(local)
		lwz     r10,PP_REGS+7*4(local)
		lwz     r20,PP_REGS+8*4(local)
		lwz     r21,PP_REGS+9*4(local)
		lwz     r22,PP_REGS+10*4(local)
		lwz     r23,PP_REGS+11*4(local)
		lwz     r24,PP_REGS+12*4(local)
		lwz     r25,PP_REGS+13*4(local)
		lwz     r26,PP_REGS+14*4(local)
		cmpi	0,0,r3,0
		addi    local,local,PP_SIZE
		popgpr  r11-r12/r14-r19/r27-r31
		ENDM
	mflr	r0
	mtctr	r0
	pushgpr	r14-r31
	pushcr

;

;	lea	intname(pc),a1
	la	r21,intname
;	moveq	#0,d0				dont care which version
	andi.	r3,r0,0
;	CALLEXEC OpenLibrary
	addi	r31,r0,_LVOOpenLibrary
	lw	r26,_SysBase
	RUN680X0
;	tst.l	d0
	cmpi	0,0,r3,0
;	beq	goawayfast			if didnt open
	beq	goawayfast			if didnt open
;

;	move.l	d0,_IntuitionBase		store lib pointer
	la	r31,_IntuitionBase
	stw	r3,0(r31)
;

;* and open the graphics library
* and open the graphics library
;	lea	grafname(pc),a1
	la	r21,grafname
;	moveq	#0,d0
	andi.	r3,r0,0
;	CALLEXEC OpenLibrary
	addi	r31,r0,_LVOOpenLibrary
	lw	r26,_SysBase
	RUN680X0
;	tst.l	d0
	cmpi	0,0,r3,0
;	beq	goawaycloseint
	beq	goawaycloseint
;	move.l	d0,_GfxBase
	la	r31,_GfxBase
	stw	r3,0(r31)
;

;* and open a DOS library
* and open a DOS library
;	lea	dosname(pc),a1
	la	r21,dosname
;	moveq	#0,d0
	andi.	r3,r0,0
;	CALLEXEC OpenLibrary
	addi	r31,r0,_LVOOpenLibrary
	lw	r26,_SysBase
	RUN680X0
;	tst.l	d0
	cmpi	0,0,r3,0
;	beq	goawayclosegraf
	beq	goawayclosegraf
;	move.l	d0,_DOSBase
	la	r31,_DOSBase
	stw	r3,0(r31)
;

;* open a window next
* open a window next
;	lea	windowdef(pc),a0
	la	r20,windowdef
;	CALLINT	OpenWindow
	addi	r31,r0,_LVOOpenWindow
	la	r26,_IntuitionBase
	lwz	r26,0(r26)
	RUN680X0
;	tst.l	d0
	cmpi	0,0,r3,0
;	beq	goawaycloseall			if no window
	beq	goawaycloseall			if no window
;	move.l	d0,windowptr			store the pointer
	la	r31,windowptr
	stw	r3,0(r31)
;

;	move.l	#-1,oldfreemem
	addi	r29,r0,-1
	la	r31,oldfreemem
	stw	r29,0(r31)
;

;* the main loop - display the figure, then wait, then loop
* the main loop - display the figure, then wait, then loop
;mainloop
mainloop
;	moveq	#0,d1
	andi.	r4,r0,0
;	CALLEXEC AvailMem			get the figure
	addi	r31,r0,_LVOAvailMem
	lw	r26,_SysBase
	RUN680X0
;

;* got free mem, see if changed since last time
* got free mem, see if changed since last time
;	cmp.l	oldfreemem,d0
	la	r29,oldfreemem
	lwz	r29,0(r29)
	subfco	r31,r29,r3
	cmp	0,0,r3,r29
;	beq	messagetest			dont print if the same
	beq	messagetest			dont print if the same
;

;	move.l	d0,oldfreemem
	la	r31,oldfreemem
	stw	r3,0(r31)
;

;* free memory in d0.l, so convert to a hex string
* free memory in d0.l, so convert to a hex string
;* converting to decimal is left as an exercise to the reader!
* converting to decimal is left as an exercise to the reader!
;

;	lea	thestring(pc),a0
	la	r20,thestring
;	bsr	hexconvert
	la	r29,.P_AAAAAAAFL
	stwu	r29,-4(r13)
	b	hexconvert
.P_AAAAAAAFL
;

;* replace leading zeros with spaces
* replace leading zeros with spaces
;	lea	thestring(pc),a0
	la	r20,thestring
;	moveq	#7-1,d0				max to do
	addi	r3,r0,7-1
;convspaces
convspaces
;	cmp.b	#'0',(a0)
	addi	r29,r0,'0'
	lbz	r30,0(r20)
	extsb	r29,r29
	extsb	r30,r30
	subfco	r31,r29,r30
	cmp	0,0,r30,r29
;	bne.s	noconvspaces
	bne	noconvspaces
;	move.b	#' ',(a0)+
	addi	r29,r0,' '
	stb	r29,0(r20)
	addi	r20,r20,1
;	dbf	d0,convspaces			convert them
	extsh	r29,r3
	cmpi	2,0,r29,0
	beq	cr2,.P_AAAAAAAGE
	subi	r29,r29,1
	rlwimi	r3,r29,0,16,31
	b	convspaces			convert them
.P_AAAAAAAGE
	subi	r29,r29,1
	rlwimi	r3,r29,0,16,31
;noconvspaces
noconvspaces
;

;* move the cursor to a suitable place
* move the cursor to a suitable place
;	moveq	#4,d0				x posn
	addi	r3,r0,4
;	moveq	#20,d1				y posn
	addi	r4,r0,20
;	move.l	windowptr(pc),a1
	la	r29,windowptr
	lwz	r21,0(r29)
;	move.l	wd_RPort(a1),a1			get rastport for window
	lwz	r21,wd_RPort(r21)
;	CALLGRAF Move
	addi	r31,r0,_LVOMove
	la	r26,_GfxBase
	lwz	r26,0(r26)
	RUN680X0
;

;* and print the string
* and print the string
;	move.l	windowptr(pc),a1
	la	r29,windowptr
	lwz	r21,0(r29)
;	move.l	wd_RPort(a1),a1
	lwz	r21,wd_RPort(r21)
;	lea	thestring(pc),a0		string
	la	r20,thestring
;	moveq	#thestringlen,d0		length
	addi	r3,r0,thestringlen
;	CALLGRAF Text
	addi	r31,r0,_LVOText
	la	r26,_GfxBase
	lwz	r26,0(r26)
	RUN680X0
;

;* now see if a message is waiting for me
* now see if a message is waiting for me
;messagetest
messagetest
;	move.l	windowptr(pc),a0
	la	r29,windowptr
	lwz	r20,0(r29)
;	move.l	wd_UserPort(a0),a0		windows message port
	lwz	r20,wd_UserPort(r20)
;	CALLEXEC GetMsg
	addi	r31,r0,_LVOGetMsg
	lw	r26,_SysBase
	RUN680X0
;	tst.l	d0
	cmpi	0,0,r3,0
;	beq.s	nomessage
	beq	nomessage
;* there was a message, which in our case must be CLOSEWINDOW,
* there was a message, which in our case must be CLOSEWINDOW,
;* so we should reply then go away
* so we should reply then go away
;	move.l	d0,a1
	mr	r21,r3
;	CALLEXEC ReplyMsg
	addi	r31,r0,_LVOReplyMsg
	lw	r26,_SysBase
	RUN680X0
;	bra.s	closewindow
	b	closewindow
;

;* no messages waiting, so suspend myself for a short while then
* no messages waiting, so suspend myself for a short while then
;* do it all agaun
* do it all agaun
;nomessage
nomessage
;	move.l	#timeout,d1
	addis	r4,r0,timeout>>16
	ori	r4,r4,timeout&$ffff
;	CALLDOS	Delay				wait a while
	addi	r31,r0,_LVODelay
	lw	r26,_DOSBase
	RUN680X0
;	bra	mainloop
	b	mainloop
;

;* close clicked so close the window
* close clicked so close the window
;closewindow
closewindow
;	move.l	windowptr(pc),a0
	la	r29,windowptr
	lwz	r20,0(r29)
;	CALLINT	CloseWindow
	addi	r31,r0,_LVOCloseWindow
	la	r26,_IntuitionBase
	lwz	r26,0(r26)
	RUN680X0
;

;* close all the libraries
* close all the libraries
;goawaycloseall
goawaycloseall
;	move.l	_DOSBase,a1
	la	r29,_DOSBase
	lwz	r21,0(r29)
;	CALLEXEC CloseLibrary
	addi	r31,r0,_LVOCloseLibrary
	lw	r26,_SysBase
	RUN680X0
;

;* close the graphics library
* close the graphics library
;goawayclosegraf
goawayclosegraf
;	move.l	_GfxBase,a1
	la	r29,_GfxBase
	lwz	r21,0(r29)
;	CALLEXEC CloseLibrary
	addi	r31,r0,_LVOCloseLibrary
	lw	r26,_SysBase
	RUN680X0
;

;* finished so close Intuition library
* finished so close Intuition library
;goawaycloseint
goawaycloseint
;	move.l	_IntuitionBase,a1
	la	r29,_IntuitionBase
	lwz	r21,0(r29)
;	CALLEXEC CloseLibrary
	addi	r31,r0,_LVOCloseLibrary
	lw	r26,_SysBase
	RUN680X0
;

;goawayfast
goawayfast
;	moveq	#0,d0
	andi.	r3,r0,0
;	lastrts
	mfctr	r0
	mtlr	r0
	popcr
	popgpr	r14-r31
	epilog
;

;* convert d0.l into a string at (a0) onwards in hex
* convert d0.l into a string at (a0) onwards in hex
;hexconvert
hexconvert
;	moveq	#8-1,d1			digit count
	addi	r4,r0,8-1
;hexclp	rol.l	#4,d0
hexclp	
	rlwinm.	r3,r3,4,0,31
;	move.l	d0,d2			save it
	mr	r5,r3
;	and.b	#$f,d0
	rlwinm	r30,r3,0,24,31
	andi.	r30,r30,$f
	rlwimi	r3,r30,0,24,31
;	cmp.b	#9,d0
	addi	r29,r0,9
	extsb	r30,r3
	subfco	r31,r29,r30
	cmp	0,0,r30,r29
;	ble.s	hexdig
	ble	hexdig
;	addq.b	#7,d0
	addi	r29,r0,7
	extsb	r30,r3
	addco.	r30,r30,r29
	rlwimi	r3,r30,0,24,31
;hexdig	add.b	#'0',d0
hexdig	addi	r29,r0,'0'
	extsb	r30,r3
	extsb	r29,r29
	addco.	r30,r30,r29
	rlwimi	r3,r30,0,24,31
;	move.b	d0,(a0)+		do a digit
	stb	r3,0(r20)
	addi	r20,r20,1
;	move.l	d2,d0			restore long
	mr	r3,r5
;	dbf	d1,hexclp		do all of the digits
	extsh	r29,r4
	cmpi	2,0,r29,0
	beq	cr2,.P_AAAAAAAKO
	subi	r29,r29,1
	rlwimi	r4,r29,0,16,31
	b	hexclp		do all of the digits
.P_AAAAAAAKO
	subi	r29,r29,1
	rlwimi	r4,r29,0,16,31
;	rts
	lwz	r29,0(r13)
	addi	r13,r13,4
	mtlr	r29
	bclr	$14,0
;

;

;* window definition here
* window definition here
;windowdef	dc.w	50,50			x posn, y posn
windowdef	dc.w	50,50			x posn, y posn
;	dc.w	200,25				width,height
	dc.w	200,25				width,height
;	dc.b	-1,-1				default pens
	dc.b	-1,-1				default pens
;	dc.l	CLOSEWINDOW			easy IDCMP flag
	dc.l	CLOSEWINDOW			easy IDCMP flag
;	dc.l	WINDOWDEPTH!WINDOWCLOSE!SMART_REFRESH!ACTIVATE!WINDOWDRAG
	dc.l	WINDOWDEPTH!WINDOWCLOSE!SMART_REFRESH!ACTIVATE!WINDOWDRAG
;	dc.l	0				no gadgets
	dc.l	0				no gadgets
;	dc.l	0				no checkmarks
	dc.l	0				no checkmarks
;	dc.l	windowtitle			title of window
	dc.l	windowtitle			title of window
;	dc.l	0				no screen
	dc.l	0				no screen
;	dc.l	0				no bitmap
	dc.l	0				no bitmap
;	dc.w	0,0,0,0				minimum, irrelevant as no sizing gadget
	dc.w	0,0,0,0				minimum, irrelevant as no sizing gadget
;	dc.w	WBENCHSCREEN			in workbench
	dc.w	WBENCHSCREEN			in workbench
;

;* strings here
* strings here
;intname		INTNAME				name of intuition lib
intname		dc.b	'intuition.library',0
;grafname	GRAFNAME			name of graphics library
grafname	dc.b	'graphics.library',0
;dosname		DOSNAME				name of dos library
dosname		dc.b	'dos.library',0
;

;windowtitle	dc.b	' ',$a9,' HiSoft 1992 ',0
windowtitle	dc.b	' ',$a9,' HiSoft 1992 ',0
;thestring	dc.b	'00000000 bytes free'
thestring	dc.b	'00000000 bytes free'
;thestringlen	equ	*-thestring
thestringlen	equ	*-thestring
;

;* variables here
* variables here
;_IntuitionBase	dc.l	0			for int library
_IntuitionBase	dc.l	0			for int library
;_GfxBase	dc.l	0			for graphics library
_GfxBase	dc.l	0			for graphics library
;_DOSBase	dc.l	0			for dos library
_DOSBase	dc.l	0			for dos library
;windowptr	dc.l	0			for window ptr
windowptr	dc.l	0			for window ptr
;oldfreemem	dc.l	0			for freemem
oldfreemem	dc.l	0			for freemem
;

;	tail
	align.q
fpio001	dc.d	0
fpio002	dc.d	0
fpio003	dc.d	0
fpio004	dc.d	0
fpio005	dc.d	0
fpio006	dc.d	0
fpio007	dc.d	0
fpio008	dc.d	0

fpCROM
	dc.b	$00,$00,$00,$01,$4e,$ba,$00,$34,$70,$00,$72,$00,$60,$20
	dc.b	$48,$e7,$00,$c0,$2f,$3c,$00,$00,$00,$02,$4e,$ba,$00,$20
	dc.b	$30,$3c,$7f,$f0,$48,$42,$80,$42,$48,$40,$42,$40,$72,$00
	dc.b	$53,$80,$53,$81,$4f,$ef,$00,$04,$4c,$df,$03,$00,$60,$be
	dc.b	$00,$00,$20,$2f,$00,$04,$29,$40,$26,$e0,$70,$02,$60,$00
	dc.b	$13,$f8,$4e,$71,$48,$e7,$3f,$40,$61,$00,$00,$08,$4c,$df
	dc.b	$02,$fc,$4e,$75,$3c,$3c,$80,$00,$3e,$3c,$7f,$f0,$48,$40
	dc.b	$48,$42,$38,$00,$c8,$46,$b9,$40,$cc,$42,$bd,$42,$bd,$44
	dc.b	$b0,$47,$6d,$00,$00,$70,$b0,$42,$6d,$00,$00,$2c,$0c,$80
	dc.b	$00,$00,$7f,$f0,$66,$00,$00,$08,$4a,$81,$67,$00,$00,$06
	dc.b	$4e,$fa,$fb,$ec,$b4,$47,$6d,$00,$00,$1e,$0c,$82,$00,$00
	dc.b	$7f,$f0,$66,$00,$00,$08,$4a,$83,$67,$00,$00,$0a,$20,$02
	dc.b	$22,$03,$4e,$fa,$fb,$ce,$4e,$fa,$fb,$ac,$4a,$82,$66,$00
	dc.b	$00,$2a,$4a,$83,$66,$00,$00,$24,$48,$e7,$c0,$c0,$48,$79
	dc.b	$00,$00,$00,$03,$4e,$ba,$ff,$70,$58,$4f,$4c,$df,$03,$03
	dc.b	$20,$3c,$00,$00,$7f,$f0,$b9,$40,$72,$00,$48,$40,$4e,$75
	dc.b	$4e,$fa,$fb,$6c,$b4,$47,$6d,$00,$00,$1e,$0c,$82,$00,$00
	dc.b	$7f,$f0,$66,$00,$00,$08,$4a,$83,$67,$00,$00,$0a,$20,$02
	dc.b	$22,$03,$4e,$fa,$fb,$7a,$4e,$fa,$fb,$0e,$3a,$00,$ca,$47
	dc.b	$66,$00,$00,$2a,$4a,$80,$66,$00,$00,$1c,$4a,$81,$66,$00
	dc.b	$00,$16,$4a,$82,$66,$00,$00,$0c,$4a,$83,$66,$00,$00,$06
	dc.b	$4e,$fa,$fb,$34,$4e,$fa,$fa,$e6,$4e,$ba,$fb,$76,$60,$00
	dc.b	$00,$08,$bb,$40,$0a,$40,$00,$10,$ce,$42,$66,$00,$00,$26
	dc.b	$4a,$82,$66,$00,$00,$0c,$4a,$83,$66,$00,$00,$06,$60,$00
	dc.b	$ff,$6e,$c1,$42,$c3,$43,$cb,$47,$4e,$ba,$fb,$4c,$c1,$42
	dc.b	$c3,$43,$cb,$47,$60,$00,$00,$08,$bf,$42,$0a,$42,$00,$10
	dc.b	$04,$47,$3f,$e0,$9a,$47,$68,$00,$00,$06,$4e,$fa,$fa,$c2
	dc.b	$48,$40,$2e,$01,$e9,$88,$e9,$89,$e9,$9f,$b3,$47,$bf,$40
	dc.b	$48,$42,$2e,$03,$7c,$0b,$ed,$aa,$ed,$ab,$ed,$bf,$b7,$47
	dc.b	$bf,$42,$48,$44,$38,$05,$22,$44,$48,$42,$80,$c2,$38,$00
	dc.b	$48,$41,$30,$01,$42,$41,$48,$42,$3a,$02,$ca,$c4,$48,$43
	dc.b	$3c,$03,$cc,$c4,$48,$43,$3e,$03,$ce,$c4,$48,$47,$de,$46
	dc.b	$48,$47,$42,$46,$48,$46,$dd,$85,$92,$87,$91,$86,$64,$00
	dc.b	$00,$08,$53,$44,$d2,$83,$d1,$82,$42,$43,$48,$44,$2c,$00
	dc.b	$48,$42,$80,$c2,$68,$00,$00,$18,$42,$44,$20,$06,$92,$83
	dc.b	$48,$42,$91,$82,$48,$40,$48,$41,$30,$01,$42,$41,$60,$00
	dc.b	$00,$2a,$38,$00,$48,$41,$30,$01
