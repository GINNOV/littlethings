; In_Go Reassembler freemem: 12.11.1999 09:09:19
MaxIntSgnd EQU $7FFFFFFF
Optimize68020 EQU 0

	incdir	ppcinclude:
	include	powerpc/powerpc.i

	warpreq
	forceb

SegmentBeginn0:
	prolog
	head
  movem.l D0/A0,-(A7)
  clr.l returnMsg
  suba.l A1,A1
  movea.l $4.W,A6
FindTask SET -$126
   jsr FindTask(A6)
JL_0_14:
  movea.l D0,A4
pr_CLI SET $AC
  tst.l pr_CLI(A4)
   beq.b fromWorkbench
  movem.l (A7)+,D0/A0
 bra.b end_startup
 
pr_MsgPort SET $5C
fromWorkbench:
  lea pr_MsgPort(A4),A0
  movea.l $4.W,A6
WaitPort SET -$180
   jsr WaitPort(A6)
pr_MsgPort SET $5C
  lea pr_MsgPort(A4),A0
  movea.l $4.W,A6
GetMsg SET -$174
   jsr GetMsg(A6)
  move.l D0,returnMsg
  nop 
  movem.l (A7)+,D0/A0
end_startup:
   bsr.b _main
  move.l D0,-(A7)
  tst.l returnMsg
   beq.b exitToDOS
  movea.l $4.W,A6
Forbid SET -$84
   jsr Forbid(A6)
  movea.l returnMsg(PC),A1
  movea.l $4.W,A6
ReplyMsg SET -$17A
   jsr ReplyMsg(A6)
exitToDOS:
  move.l (A7)+,D0
 lastrtS 
 
returnMsg:
  ds.l 1
_main:
  lea intname(PC),A1
  moveq.l #$00,D0
  movea.l $4.W,A6
OpenLibrary SET -$228
   jsr OpenLibrary(A6)
  tst.l D0
   beq.w goawayfast
  move.l D0,_IntuitionBase
  lea grafname(PC),A1
  moveq.l #$00,D0
  movea.l $4.W,A6
OpenLibrary SET -$228
   jsr OpenLibrary(A6)
  tst.l D0
   beq.w goawaycloseint
  move.l D0,_GfxBase
  lea dosname(PC),A1
  moveq.l #$00,D0
  movea.l $4.W,A6
OpenLibrary SET -$228
   jsr OpenLibrary(A6)
  tst.l D0
   beq.w goawayclosegraf
  move.l D0,_DOSBase
  lea windowdef(PC),A0
  movea.l _IntuitionBase,A6
OpenWindow SET -$CC
   jsr OpenWindow(A6)
  tst.l D0
   beq.w goawaycloseall
  move.l D0,windowptr
  move.l #$FFFFFFFF,oldfreemem
mainloop:
  moveq.l #$01,D1
  movea.l $4.W,A6
AvailMem SET -$D8
   jsr AvailMem(A6)
  cmp.l oldfreemem,D0
   beq.w messagetest
  move.l D0,oldfreemem
  lea thestring(PC),A0
   bsr.w hexconvert
  lea thestring(PC),A0
  moveq.l #$06,D0
convspaces:
  cmpi.b #"0",(A0)
   bne.b noconvspaces
  move.b #$20,(A0)+
   dbf D0,convspaces
noconvspaces:
  moveq.l #$04,D0
  moveq.l #$14,D1
  movea.l windowptr(PC),A1
  movea.l $32(A1),A1
  movea.l _GfxBase,A6
Move SET -$F0
   jsr Move(A6)
  movea.l windowptr(PC),A1
  movea.l $32(A1),A1
  lea thestring(PC),A0
  moveq.l #$13,D0
  movea.l _GfxBase,A6
Text SET -$3C
   jsr Text(A6)
messagetest:
  movea.l windowptr(PC),A0
  movea.l $56(A0),A0
  movea.l $4.W,A6
GetMsg SET -$174
   jsr GetMsg(A6)
  tst.l D0
   beq.b nomessage
  movea.l D0,A1
  movea.l $4.W,A6
ReplyMsg SET -$17A
   jsr ReplyMsg(A6)
 bra.b closewindow
 
nomessage:
  move.l #$19,D1
  movea.l _DOSBase,A6
Delay SET -$C6
   jsr Delay(A6)
 bra.w mainloop
 
closewindow:
  movea.l windowptr(PC),A0
  movea.l _IntuitionBase,A6
CloseWindow SET -$48
   jsr CloseWindow(A6)
goawaycloseall:
  movea.l _DOSBase,A1
  movea.l $4.W,A6
CloseLibrary SET -$19E
   jsr CloseLibrary(A6)
goawayclosegraf:
  movea.l _GfxBase,A1
  movea.l $4.W,A6
CloseLibrary SET -$19E
   jsr CloseLibrary(A6)
goawaycloseint:
  movea.l _IntuitionBase,A1
  movea.l $4.W,A6
CloseLibrary SET -$19E
   jsr CloseLibrary(A6)
goawayfast:
  moveq.l #$00,D0
 rtS 
 
hexconvert:
  moveq.l #$07,D1
hexclp:
  rol.l #4,D0
  move.l D0,D2
  andi.b #$F,D0
  cmp.b #$9,D0
   ble.b hexdig
  addq.b #7,D0
hexdig:
  addi.b #"0",D0
  move.b D0,(A0)+
  move.l D2,D0
   dbf D1,hexclp
 rtS 
 
windowdef:
  dc.b $00,$32 ;.2
  dc.b $00,$32,$00,$C8 ;.2..
  dc.b $00,$19,$FF,$FF ;....
  ds.w 1
  dc.b $02,$00,$00,$00 ;....
  dc.b $10,$0E,$00,$00 ;....
  ds.w 3
  dc.l windowtitle
  ds.l 4
  dc.b $00 ;.
  dc.b $01 ;.
intname:
  dc.b "intuition.library",0
grafname:
  dc.b "graphics.library",0
dosname:
  dc.b "dos.library",0
windowtitle:
  dc.b " © HiSoft 1992 ",0
thestring:
  dc.b "00000000 bytes free"
_IntuitionBase:
  ds.l 1
_GfxBase:
  ds.l 1
_DOSBase:
  ds.l 1
windowptr:
  ds.l 1
oldfreemem:
  ds.w 3
	tail
