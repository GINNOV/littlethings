************************************************************************
*                                                                      *
* These are simply Lissajous figures which you can create using an     *
* oscilloscope and two frequency generators.                           *
* The definition is:                                                   *
*                     x(t)=sin(u*t)                                    *
*                     y(t)=sin(v*t+p)                                  *
*                                                                      *
* u is the angular frequency in the x direction                        *
* v is the angular frequency in the y direction                        *
* p is the phase difference between x and y                            *
*                                                                      *
* This implementation was written by:                                  *
* E. Lenz                                                              *
* Johann-Fichte-Strasse 11                                             *
* 8 Munich 40                                                          *
* Germany                                                              *
*                                                                      *
************************************************************************

      XREF GetReal,RealOut,request

_AbsExecBase        equ 4

**** exec *****

_LVOForbid       equ -$84
_LVOPermit       equ -$8a
_LVOGetMsg       equ -$174
_LVOReplyMsg     equ -$17a
_LVOWaitPort     equ -$180
_LVOCloseLibrary equ -$19e
_LVOOpenLibrary  equ -$228

**** intuition ******

_LVOCloseWindow    equ -$48
_LVOOpenWindow     equ -$cc
_LVOSetMenuStrip   equ -$108

***** graphics ******

_LVOMove            equ -$f0
_LVODraw            equ -$f6
_LVORectFill        equ -$132
_LVOSetAPen         equ -$156

*** mathffp ***

_LVOSPFix  equ -$1e
_LVOSPAdd  equ -$42
_LVOSPMul  equ -$4e

*** mathtrans ***

_LVOSPSin equ -$24

wd_RPort         equ $32
wd_UserPort      equ $56
pr_MsgPort       equ $5c
pr_CLI           equ $ac
ThisTask         equ $114
VBlankFrequency  equ $212

hund3  equ $96000049  300
hund   equ $b4000047  90
hund1  equ $f0000047  120
dt     equ $a3d70b3a  0.01

       movea.l _AbsExecBase,a6   test if WB or CLI
       movea.l ThisTask(a6),a0
       tst.l   pr_CLI(a0)
       bne.s   isCLI

       lea     pr_MsgPort(a0),a0 for WB get WB Message
       jsr     _LVOWaitPort(a6)
       jsr     _LVOGetMsg(a6)
       move.l  d0,WBenchMsg

isCLI  cmpi.b  #60,VBlankFrequency(a6) test if PAL or NTSC
       beq.s   isNTSC
       move.w  #256,nw+6
       move.l  #hund1,NTSC+2

isNTSC lea     GfxName(pc),a1        open graphics library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,GfxBase
       beq.s   Gexit

       lea     IntName(pc),a1        open intuition library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,IntBase
       beq.s   Gexit

       lea     MathName(pc),a1       open mathffp library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,MathBase
       beq.s   Gexit

       lea     MtransName(pc),a1     open mathtrans library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,MtransBase
       bne.s   Trok
       lea     MtransName(pc),a0   first line
       movem.l a4-a5,-(a7)
       lea     notfnd(pc),a1     second line
       suba.l  a2,a2             no third line
       lea     hdtxt(pc),a3      header
       lea     OkTxt(pc),a4      gadget text
       suba.l  a5,a5             no 2nd gadget
       moveq   #0,d0
       moveq   #1,d1
       jsr     request
       movem.l (a7)+,a4-a5
Gexit  bra     exit

Trok   lea     nw(pc),a0             open window
       movea.l IntBase(pc),a6
       jsr     _LVOOpenWindow(a6)
       move.l  d0,window
       beq.s   Gexit


; Set menu

       movea.l d0,a0           which window
       lea     Menu1(pc),a1    which menu
       jsr     _LVOSetMenuStrip(a6)

       movea.l window(pc),a0
       movea.l wd_RPort(a0),a5

redraw movea.l GfxBase(pc),a6  clear screen
       moveq   #0,d0
       movea.l a5,a1
       jsr     _LVOSetAPen(a6)

       movea.l a5,a1
       moveq   #0,d0
       moveq   #0,d1
       move.l  #640,d2
       move.l  #250,d3
       jsr     _LVORectFill(a6)

       movea.l a5,a1
       moveq   #3,d0
       jsr     _LVOSetAPen(a6)

       clr.l   t

draw   bsr     print

wait   bsr     trycls
       beq.s   draw
       cmpi.l  #$200,d7
       beq.s   exit

       cmpi.l  #$100,d7
       bne.s   wait

; Choice from menu

       movea.l window(pc),a0
       movea.l $5e(a0),a0   Load Window.MessageKey
       move.w  $18(a0),d0   Load message code
       move.w  d0,d1
       andi.w  #$f,d1
       bne.s   draw

       andi.w  #$f0,d0      Menu 1
       bne.s   menu12       Submenu 1
       bsr     xfreq
sedraw bra.s   redraw

menu12 cmpi.w  #$20,d0      Submenu 2
       bne.s   menu13
       bsr     yfreq
       bra.s   redraw

menu13 cmpi.w  #$40,d0      Submenu 3
       bne.s   draw
       bsr     phase
       bra.s   sedraw

exit   movea.l IntBase(pc),a6
       move.l  window(pc),d0
       beq.s   noWin
       movea.l d0,a0
       jsr     _LVOCloseWindow(a6)    close window

noWin  movea.l _AbsExecBase,a6
       tst.l   WBenchMsg
       beq.s   NoBenh
       jsr     _LVOForbid(a6)       reply to WB
       movea.l WBenchMsg(pc),a1
       jsr     _LVOReplyMsg(a6)
       jsr     _LVOPermit(a6)

NoBenh move.l  MtransBase(pc),d1     close mathtrans library
       beq.s   noMtr
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noMtr  move.l  MathBase(pc),d1      close mathffp library
       beq.s   noMath
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noMath move.l  IntBase(pc),d1       close intuition library
       beq.s   noInt
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noInt  move.l  GfxBase(pc),d1       close graphics library
       beq.s   noGfx
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noGfx  moveq   #0,d0                no error
       rts

trycls movem.l d0-d6/a0-a6,-(a7)
       movea.l _AbsExecBase,a6
       moveq   #0,d7
       movea.l window(pc),a0
       movea.l wd_UserPort(a0),a0  load Window.UserPort
       jsr     _LVOGetMsg(a6)
       tst.l   d0
       beq.s   noMsg1         No message

       movea.l d0,a1
       move.l  $14(a1),d7       Message in d7

noMsg1 movem.l (a7)+,d0-d6/a0-a6
noMsg  tst.l   d7
       rts

print  movea.l MathBase(pc),a6
       movea.l MtransBase(pc),a4
       move.l  t(pc),d0
       move.l  #dt,d1
       jsr     _LVOSPAdd(a6)
       move.l  d0,t

       move.l  d0,d1
       move.l  u(pc),d0
       jsr     _LVOSPMul(a6)

       exg     a4,a6
       jsr     _LVOSPSin(a6)

       exg     a4,a6
       move.l  #hund3,d1
       jsr     _LVOSPMul(a6)
       move.l  #hund3,d1
       jsr     _LVOSPAdd(a6)
       jsr     _LVOSPFix(a6)
       move.l  d0,d7

       move.l  v(pc),d0
       move.l  t(pc),d1
       jsr     _LVOSPMul(a6)
       move.l  p(pc),d1
       jsr     _LVOSPAdd(a6)

       exg     a4,a6
       jsr     _LVOSPSin(a6)

       exg     a4,a6
NTSC   move.l  #hund,d5
       move.l  d5,d1
       jsr     _LVOSPMul(a6)
       move.l  d5,d1
       jsr     _LVOSPAdd(a6)
       jsr     _LVOSPFix(a6)
       move.l  d0,d6

       move.l  d0,d1
       move.l  d7,d0
       movea.l GfxBase(pc),a6
       movea.l a5,a1
       jsr     _LVOMove(a6)

       move.l  d6,d1
       move.l  d7,d0
       movea.l a5,a1
       jsr     _LVODraw(a6)
       rts


xfreq  bsr.s   uout
       lea     item11txt(pc),a0
       lea     tu(pc),a1
       lea     uval(pc),a2
       jsr     GetReal
       tst.l   d1
       bne.s   nogo
       move.l  d0,u
       rts

yfreq  bsr.s   vout
       lea     item12txt(pc),a0
       lea     tv(pc),a1
       lea     vval(pc),a2
       jsr     GetReal
       tst.l   d1
       bne.s   nogo
       move.l  d0,v
nogo   rts

phase  bsr.s   pout
       lea     item13txt(pc),a0
       lea     tp(pc),a1
       lea     pval(pc),a2
       jsr     GetReal
       tst.l   d1
       bne.s   nogo
       move.l  d0,p
       rts

uout   lea     uval(pc),a0
       move.l  u(pc),d0
       bra.s   outout

vout   lea     vval(pc),a0
       move.l  v(pc),d0
       bra.s   outout

pout   lea     pval(pc),a0
       move.l  p(pc),d0
outout moveq   #2,d1
       moveq   #9,d2
       movea.l a0,a1
remove move.b  #' ',(a1)+
       dbra    d2,remove
       jsr     RealOut
       moveq   #0,d0
       moveq   #1,d1
       rts

tu     dc.b  'X freq ='
uval   dc.b  '           ',$a
tv     dc.b  'Y freq ='
vval   dc.b  '           ',$a
tp     dc.b  'P phase='
pval   dc.b  '           ',$a

u      dc.l $80000041     1
v      dc.l $86666642     2.1
t      dc.l 0
p      dc.l 0

WBenchMsg   dc.l 0
MtransBase  dc.l 0
MathBase    dc.l 0
GfxBase     dc.l 0
IntBase     dc.l 0

window      dc.l 0

; requester texts

notfnd      dc.b ' not found',0
hdtxt       dc.b ' Lissajous Request',0
OkTxt       dc.b ' OK',0
            even

MtransName  dc.b 'mathtrans.library',0
MathName    dc.b 'mathffp.library',0
GfxName     dc.b 'graphics.library',0
IntName     dc.b 'intuition.library',0
            even

title       dc.b  'Lissajous figures',0
            even

***** Window definition *****

nw          dc.w 0,0         Position left,top
            dc.w 640,199     Size width,height
            dc.b 0,1         Colors detail-,block pen
            dc.l $340        IDCMP-Flags
            dc.l $140f       Window flags
            dc.l 0           ^Gadget
            dc.l 0           ^Menu check
            dc.l title       ^Window name
nws         dc.l 0           ^Screen structure,
            dc.l 0           ^BitMap
            dc.w 100         MinWidth
            dc.w 40          MinHeight
            dc.w -1          MaxWidth
            dc.w -1,1        MaxHeight,Screen type

**** menu definition ****

Menu1       dc.l 0           Next menu
            dc.w 50,0        Position left edge,top edge
            dc.w 100,20      Dimensions width,height
            dc.w 1           Menu enabled
            dc.l mtext1      Text for menu header
            dc.l item11      ^First in chain
            dc.l 0,0         Internal

mtext1      dc.b 'parameters',0
            even

item11      dc.l item12      next in chained list
            dc.w 0,0         Position left edge,top edge
            dc.w 170,10      Dimensions width,height
            dc.w $52         itemtext+highcomp+itemenabled
            dc.l 0           Mutual exclude
            dc.l I11txt      Pointer to intuition text
            dc.l 0
            dc.b 0,0
            dc.l 0
            dc.w 0


I11txt      dc.b 0           Front pen  (blue)
            dc.b 1           Back pen   (white)
            dc.b 0,0         Draw mode
            dc.w 0           Left edge
            dc.w 0           Top edge
            dc.l 0           Text font
            dc.l item11txt   Pointer to text
            dc.l 0           Next text

item11txt   dc.b 'u angular frequency x',0
            even

item12      dc.l item13      next in chained list
            dc.w 0,10        Position left edge,top edge
            dc.w 170,10      Dimensions width,height
            dc.w $52         itemtext+highcomp+itemenabled
            dc.l 0           Mutual exclude
            dc.l I12txt      Pointer to intuition text
            dc.l 0
            dc.b 0,0
            dc.l 0
            dc.w 0


I12txt      dc.b 0           Front pen  (blue)
            dc.b 1           Back pen   (white)
            dc.b 0,0         Draw mode
            dc.w 0           Left edge
            dc.w 0           Top edge
            dc.l 0           Text font
            dc.l item12txt   Pointer to text
            dc.l 0           Next text

item12txt   dc.b 'v angular frequency y',0
            even

item13      dc.l 0           next in chained list
            dc.w 0,20        Position left edge,top edge
            dc.w 170,10      Dimensions width,height
            dc.w $52         itemtext+highcomp+itemenabled
            dc.l 0           Mutual exclude
            dc.l I13txt      Pointer to intuition text
            dc.l 0
            dc.b 0,0
            dc.l 0
            dc.w 0


I13txt      dc.b 0           Front pen  (blue)
            dc.b 1           Back pen   (white)
            dc.b 0,0         Draw mode
            dc.w 0           Left edge
            dc.w 0           Top edge
            dc.l 0           Text font
            dc.l item13txt   Pointer to text
            dc.l 0           Next text

item13txt   dc.b 'p phase difference',0
            even

            end

