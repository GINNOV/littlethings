;This source-code is converted using PPC680x0, (c)2000 Coyote Flux
;Coded in 100% machine-language...!!! Amiga Rulez! PC Suxx!

;; In_Go Reassembler freemem: 12.11.1999 09:09:19
; In_Go Reassembler freemem: 12.11.1999 09:09:19
;MaxIntSgnd EQU $7FFFFFFF
MaxIntSgnd EQU $7FFFFFFF
;Optimize68020 EQU 0
Optimize68020 EQU 0
;

;	incdir	ppcinclude:
	incdir	ppcinclude:
;	include	powerpc/powerpc.i
	include	powerpc/powerpc.i
;

;	warpreq
	xref	_PowerPCBase
	xref	_SysBase
;	xref	_DOSBase
	xref	_LinkerDB

	executable
;	forceb
;

;SegmentBeginn0:
SegmentBeginn0:
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

;  movem.l D0/A0,-(A7)
  	stwu	r20,-4(r13)
	stwu	r3,-4(r13)
;  clr.l returnMsg
  	la	r31,returnMsg
	andi.	r30,r30,0
	stw	r30,0(r31)
;  suba.l A1,A1
  	subfco.	r21,r21,r21
;  movea.l $4.W,A6
  lw	r26,_SysBase
;FindTask SET -$126
FindTask SET -$126
;   jsr FindTask(A6)
   addis	r31,r0,FindTask>>16
	ori	r31,r31,FindTask&$ffff
	RUN680X0
;JL_0_14:
JL_0_14:
;  movea.l D0,A4
  	mr	r24,r3
;pr_CLI SET $AC
pr_CLI SET $AC
;  tst.l pr_CLI(A4)
  	lwz	r30,pr_CLI(r24)
	cmpi	0,0,r30,0
;   beq.b fromWorkbench
   beq	fromWorkbench
;  movem.l (A7)+,D0/A0
  	lwz	r3,0(r13)
	lwzu	r20,4(r13)
	addi	r13,r13,4
; bra.b end_startup
 b	end_startup
; 
 
;pr_MsgPort SET $5C
pr_MsgPort SET $5C
;fromWorkbench:
fromWorkbench:
;  lea pr_MsgPort(A4),A0
  	addi	r20,r24,pr_MsgPort
;  movea.l $4.W,A6
  lw	r26,_SysBase
;WaitPort SET -$180
WaitPort SET -$180
;   jsr WaitPort(A6)
   addis	r31,r0,WaitPort>>16
	ori	r31,r31,WaitPort&$ffff
	RUN680X0
;pr_MsgPort SET $5C
pr_MsgPort SET $5C
;  lea pr_MsgPort(A4),A0
  	addi	r20,r24,pr_MsgPort
;  movea.l $4.W,A6
  lw	r26,_SysBase
;GetMsg SET -$174
GetMsg SET -$174
;   jsr GetMsg(A6)
   addis	r31,r0,GetMsg>>16
	ori	r31,r31,GetMsg&$ffff
	RUN680X0
;  move.l D0,returnMsg
  	la	r31,returnMsg
	stw	r3,0(r31)
;  nop 
  ori	r0,r0,0
;  movem.l (A7)+,D0/A0
  	lwz	r3,0(r13)
	lwzu	r20,4(r13)
	addi	r13,r13,4
;end_startup:
end_startup:
;   bsr.b _main
   la	r29,.P_AAAAAAACL
	stwu	r29,-4(r13)
	b	_main
.P_AAAAAAACL
;  move.l D0,-(A7)
  	stwu	r3,-4(r13)
;  tst.l returnMsg
  	la	r31,returnMsg
	lwz	r30,0(r31)
	cmpi	0,0,r30,0
;   beq.b exitToDOS
   beq	exitToDOS
;  movea.l $4.W,A6
  lw	r26,_SysBase
;Forbid SET -$84
Forbid SET -$84
;   jsr Forbid(A6)
   addis	r31,r0,Forbid>>16
	ori	r31,r31,Forbid&$ffff
	RUN680X0
;  movea.l returnMsg(PC),A1
  la	r29,returnMsg
	lwz	r21,0(r29)
;  movea.l $4.W,A6
  lw	r26,_SysBase
;ReplyMsg SET -$17A
ReplyMsg SET -$17A
;   jsr ReplyMsg(A6)
   addis	r31,r0,ReplyMsg>>16
	ori	r31,r31,ReplyMsg&$ffff
	RUN680X0
;exitToDOS:
exitToDOS:
;  move.l (A7)+,D0
  lwz	r3,0(r13)
	addi	r13,r13,4
; lastrtS 
 mfctr	r0
	mtlr	r0
	popcr
	popgpr	r14-r31
	epilog
; 
 
;returnMsg:
returnMsg:
;  ds.l 1
  ds.l 1
;_main:
_main:
;  lea intname(PC),A1
  la	r21,intname
;  moveq.l #$00,D0
  andi.	r3,r0,0
;  movea.l $4.W,A6
  lw	r26,_SysBase
;OpenLibrary SET -$228
OpenLibrary SET -$228
;   jsr OpenLibrary(A6)
   addis	r31,r0,OpenLibrary>>16
	ori	r31,r31,OpenLibrary&$ffff
	RUN680X0
;  tst.l D0
  	cmpi	0,0,r3,0
;   beq.w goawayfast
   beq	goawayfast
;  move.l D0,_IntuitionBase
  	la	r31,_IntuitionBase
	stw	r3,0(r31)
;  lea grafname(PC),A1
  la	r21,grafname
;  moveq.l #$00,D0
  andi.	r3,r0,0
;  movea.l $4.W,A6
  lw	r26,_SysBase
;OpenLibrary SET -$228
OpenLibrary SET -$228
;   jsr OpenLibrary(A6)
   addis	r31,r0,OpenLibrary>>16
	ori	r31,r31,OpenLibrary&$ffff
	RUN680X0
;  tst.l D0
  	cmpi	0,0,r3,0
;   beq.w goawaycloseint
   beq	goawaycloseint
;  move.l D0,_GfxBase
  	la	r31,_GfxBase
	stw	r3,0(r31)
;  lea dosname(PC),A1
  la	r21,dosname
;  moveq.l #$00,D0
  andi.	r3,r0,0
;  movea.l $4.W,A6
  lw	r26,_SysBase
;OpenLibrary SET -$228
OpenLibrary SET -$228
;   jsr OpenLibrary(A6)
   addis	r31,r0,OpenLibrary>>16
	ori	r31,r31,OpenLibrary&$ffff
	RUN680X0
;  tst.l D0
  	cmpi	0,0,r3,0
;   beq.w goawayclosegraf
   beq	goawayclosegraf
;  move.l D0,_DOSBase
  	la	r31,_DOSBase
	stw	r3,0(r31)
;  lea windowdef(PC),A0
  la	r20,windowdef
;  movea.l _IntuitionBase,A6
  la	r29,_IntuitionBase
	lwz	r26,0(r29)
;OpenWindow SET -$CC
OpenWindow SET -$CC
;   jsr OpenWindow(A6)
   addis	r31,r0,OpenWindow>>16
	ori	r31,r31,OpenWindow&$ffff
	RUN680X0
;  tst.l D0
  	cmpi	0,0,r3,0
;   beq.w goawaycloseall
   beq	goawaycloseall
;  move.l D0,windowptr
  	la	r31,windowptr
	stw	r3,0(r31)
;  move.l #$FFFFFFFF,oldfreemem
  addis	r29,r0,$FFFFFFFF>>16
	ori	r29,r29,$FFFFFFFF&$ffff
	la	r31,oldfreemem
	stw	r29,0(r31)
;mainloop:
mainloop:
;  moveq.l #$01,D1
  addi	r4,r0,$01
;  movea.l $4.W,A6
  lw	r26,_SysBase
;AvailMem SET -$D8
AvailMem SET -$D8
;   jsr AvailMem(A6)
   addis	r31,r0,AvailMem>>16
	ori	r31,r31,AvailMem&$ffff
	RUN680X0
;  cmp.l oldfreemem,D0
  	la	r29,oldfreemem
	lwz	r29,0(r29)
	subfco	r31,r29,r3
	cmp	0,0,r3,r29
;   beq.w messagetest
   beq	messagetest
;  move.l D0,oldfreemem
  	la	r31,oldfreemem
	stw	r3,0(r31)
;  lea thestring(PC),A0
  la	r20,thestring
;   bsr.w hexconvert
   la	r29,.P_AAAAAAAGG
	stwu	r29,-4(r13)
	b	hexconvert
.P_AAAAAAAGG
;  lea thestring(PC),A0
  la	r20,thestring
;  moveq.l #$06,D0
  addi	r3,r0,$06
;convspaces:
convspaces:
;  cmpi.b #"0",(A0)
  	addi	r29,r0,"0"
	lbz	r30,0(r20)
	extsb	r29,r29
	extsb	r30,r30
	subfco	r31,r29,r30
	cmp	0,0,r30,r29
;   bne.b noconvspaces
   bne	noconvspaces
;  move.b #$20,(A0)+
  addi	r29,r0,$20
	stb	r29,0(r20)
	addi	r20,r20,1
;   dbf D0,convspaces
   extsh	r29,r3
	cmpi	2,0,r29,0
	beq	cr2,.P_AAAAAAAGN
	subi	r29,r29,1
	rlwimi	r3,r29,0,16,31
	b	convspaces
.P_AAAAAAAGN
	subi	r29,r29,1
	rlwimi	r3,r29,0,16,31
;noconvspaces:
noconvspaces:
;  moveq.l #$04,D0
  addi	r3,r0,$04
;  moveq.l #$14,D1
  addi	r4,r0,$14
;  movea.l windowptr(PC),A1
  la	r29,windowptr
	lwz	r21,0(r29)
;  movea.l $32(A1),A1
  lwz	r21,$32(r21)
;  movea.l _GfxBase,A6
  la	r29,_GfxBase
	lwz	r26,0(r29)
;Move SET -$F0
Move SET -$F0
;   jsr Move(A6)
   addis	r31,r0,Move>>16
	ori	r31,r31,Move&$ffff
	RUN680X0
;  movea.l windowptr(PC),A1
  la	r29,windowptr
	lwz	r21,0(r29)
;  movea.l $32(A1),A1
  lwz	r21,$32(r21)
;  lea thestring(PC),A0
  la	r20,thestring
;  moveq.l #$13,D0
  addi	r3,r0,$13
;  movea.l _GfxBase,A6
  la	r29,_GfxBase
	lwz	r26,0(r29)
;Text SET -$3C
Text SET -$3C
;   jsr Text(A6)
   addis	r31,r0,Text>>16
	ori	r31,r31,Text&$ffff
	RUN680X0
;messagetest:
messagetest:
;  movea.l windowptr(PC),A0
  la	r29,windowptr
	lwz	r20,0(r29)
;  movea.l $56(A0),A0
  lwz	r20,$56(r20)
;  movea.l $4.W,A6
  lw	r26,_SysBase
;GetMsg SET -$174
GetMsg SET -$174
;   jsr GetMsg(A6)
   addis	r31,r0,GetMsg>>16
	ori	r31,r31,GetMsg&$ffff
	RUN680X0
;  tst.l D0
  	cmpi	0,0,r3,0
;   beq.b nomessage
   beq	nomessage
;  movea.l D0,A1
  	mr	r21,r3
;  movea.l $4.W,A6
  lw	r26,_SysBase
;ReplyMsg SET -$17A
ReplyMsg SET -$17A
;   jsr ReplyMsg(A6)
   addis	r31,r0,ReplyMsg>>16
	ori	r31,r31,ReplyMsg&$ffff
	RUN680X0
; bra.b closewindow
 b	closewindow
; 
 
;nomessage:
nomessage:
;  move.l #$19,D1
  addi	r4,r0,$19
;  movea.l _DOSBase,A6
  la	r29,_DOSBase
	lwz	r26,0(r29)
;Delay SET -$C6
Delay SET -$C6
;   jsr Delay(A6)
   addis	r31,r0,Delay>>16
	ori	r31,r31,Delay&$ffff
	RUN680X0
; bra.w mainloop
 b	mainloop
; 
 
;closewindow:
closewindow:
;  movea.l windowptr(PC),A0
  la	r29,windowptr
	lwz	r20,0(r29)
;  movea.l _IntuitionBase,A6
  la	r29,_IntuitionBase
	lwz	r26,0(r29)
;CloseWindow SET -$48
CloseWindow SET -$48
;   jsr CloseWindow(A6)
   addis	r31,r0,CloseWindow>>16
	ori	r31,r31,CloseWindow&$ffff
	RUN680X0
;goawaycloseall:
goawaycloseall:
;  movea.l _DOSBase,A1
  la	r29,_DOSBase
	lwz	r21,0(r29)
;  movea.l $4.W,A6
  lw	r26,_SysBase
;CloseLibrary SET -$19E
CloseLibrary SET -$19E
;   jsr CloseLibrary(A6)
   addis	r31,r0,CloseLibrary>>16
	ori	r31,r31,CloseLibrary&$ffff
	RUN680X0
;goawayclosegraf:
goawayclosegraf:
;  movea.l _GfxBase,A1
  la	r29,_GfxBase
	lwz	r21,0(r29)
;  movea.l $4.W,A6
  lw	r26,_SysBase
;CloseLibrary SET -$19E
CloseLibrary SET -$19E
;   jsr CloseLibrary(A6)
   addis	r31,r0,CloseLibrary>>16
	ori	r31,r31,CloseLibrary&$ffff
	RUN680X0
;goawaycloseint:
goawaycloseint:
;  movea.l _IntuitionBase,A1
  la	r29,_IntuitionBase
	lwz	r21,0(r29)
;  movea.l $4.W,A6
  lw	r26,_SysBase
;CloseLibrary SET -$19E
CloseLibrary SET -$19E
;   jsr CloseLibrary(A6)
   addis	r31,r0,CloseLibrary>>16
	ori	r31,r31,CloseLibrary&$ffff
	RUN680X0
;goawayfast:
goawayfast:
;  moveq.l #$00,D0
  andi.	r3,r0,0
; rtS 
 lwz	r29,0(r13)
	addi	r13,r13,4
	mtlr	r29
	bclr	$14,0
; 
 
;hexconvert:
hexconvert:
;  moveq.l #$07,D1
  addi	r4,r0,$07
;hexclp:
hexclp:
;  rol.l #4,D0
  	
	rlwinm.	r3,r3,4,0,31
;  move.l D0,D2
  	mr	r5,r3
;  andi.b #$F,D0
  	rlwinm	r30,r3,0,24,31
	andi.	r30,r30,$F
	rlwimi	r3,r30,0,24,31
;  cmp.b #$9,D0
  	addi	r29,r0,$9
	extsb	r30,r3
	subfco	r31,r29,r30
	cmp	0,0,r30,r29
;   ble.b hexdig
   ble	hexdig
;  addq.b #7,D0
  	addi	r29,r0,7
	extsb	r30,r3
	addco.	r30,r30,r29
	rlwimi	r3,r30,0,24,31
;hexdig:
hexdig:
;  addi.b #"0",D0
  	addi	r29,r0,"0"
	extsb	r30,r3
	extsb	r29,r29
	addco.	r30,r30,r29
	rlwimi	r3,r30,0,24,31
;  move.b D0,(A0)+
  	stb	r3,0(r20)
	addi	r20,r20,1
;  move.l D2,D0
  	mr	r3,r5
;   dbf D1,hexclp
   extsh	r29,r4
	cmpi	2,0,r29,0
	beq	cr2,.P_AAAAAAALI
	subi	r29,r29,1
	rlwimi	r4,r29,0,16,31
	b	hexclp
.P_AAAAAAALI
	subi	r29,r29,1
	rlwimi	r4,r29,0,16,31
; rtS 
 lwz	r29,0(r13)
	addi	r13,r13,4
	mtlr	r29
	bclr	$14,0
; 
 
;windowdef:
windowdef:
;  dc.b $00,$32 ;.2
  dc.b $00,$32 ;.2
;  dc.b $00,$32,$00,$C8 ;.2..
  dc.b $00,$32,$00,$C8 ;.2..
;  dc.b $00,$19,$FF,$FF ;....
  dc.b $00,$19,$FF,$FF ;....
;  ds.w 1
  ds.w 1
;  dc.b $02,$00,$00,$00 ;....
  dc.b $02,$00,$00,$00 ;....
;  dc.b $10,$0E,$00,$00 ;....
  dc.b $10,$0E,$00,$00 ;....
;  ds.w 3
  ds.w 3
;  dc.l windowtitle
  dc.l windowtitle
;  ds.l 4
  ds.l 4
;  dc.b $00 ;.
  dc.b $00 ;.
;  dc.b $01 ;.
  dc.b $01 ;.
;intname:
intname:
;  dc.b "intuition.library",0
  dc.b "intuition.library",0
;grafname:
grafname:
;  dc.b "graphics.library",0
  dc.b "graphics.library",0
;dosname:
dosname:
;  dc.b "dos.library",0
  dc.b "dos.library",0
;windowtitle:
windowtitle:
;  dc.b " © HiSoft 1992 ",0
  dc.b " © HiSoft 1992 ",0
;thestring:
thestring:
;  dc.b "00000000 bytes free"
  dc.b "00000000 bytes free"
;_IntuitionBase:
_IntuitionBase:
;  ds.l 1
  ds.l 1
;_GfxBase:
_GfxBase:
;  ds.l 1
  ds.l 1
;_DOSBase:
_DOSBase:
;  ds.l 1
  ds.l 1
;windowptr:
windowptr:
;  ds.l 1
  ds.l 1
;oldfreemem:
oldfreemem:
;  ds.w 3
  ds.w 3
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
