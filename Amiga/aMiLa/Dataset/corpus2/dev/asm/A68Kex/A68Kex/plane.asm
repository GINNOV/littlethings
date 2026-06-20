************************************************************************
* This is the Red Baron of Germany. Snoopy's not around though.        *
*                                                                      *
* Seriously, this is a random walk on a three dimensional lattice.     *
* The random walk is preformed by the climbing sine.                   *
*                                                                      *
* This implementation was written by:                                  *
* E. Lenz                                                              *
* Johann-Fichte-Strasse 11                                             *
* 8 Munich 40                                                          *
* Germany                                                              *
*                                                                      *
************************************************************************

   XREF request

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

***** graphics ******

_LVOMove            equ -$f0
_LVODraw            equ -$f6
_LVORectFill        equ -$132
_LVOSetAPen         equ -$156

**** mathffp *****

_LVOSPFix       equ -$1e
_LVOSPFlt       equ -$24
_LVOSPAdd       equ -$42
_LVOSPSub       equ -$48
_LVOSPMul       equ -$4e

**** mathtrans ******

_LVOSPSin       equ -$24
_LVOSPCos       equ -$2a

pr_MsgPort       equ $5c
pr_CLI           equ $ac
ThisTask         equ $114
VBlankFrequency  equ $212

pi2   equ $c90fd943
fif   equ $bb8ef340  .6
dr    equ $80000040  .5

       code

       movea.l _AbsExecBase,a6   test if WB or CLI
       movea.l ThisTask(a6),a0
       tst.l   pr_CLI(a0)
       bne.s   isCLI

       lea     pr_MsgPort(a0),a0 for WB get WB Message
       jsr     _LVOWaitPort(a6)
       jsr     _LVOGetMsg(a6)
       move.l  d0,WBenchMsg

isCLI  cmpi.b  #60,VBlankFrequency(a6) check if PAL or NTSC
       beq.s   isNTSC
       move.w  #256,nw+6
       move.l  #100,ntsc+2

isNTSC lea     GfxName(pc),a1        open graphics library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,GfxBase
       beq.s   Gexit

       lea     FfpName(pc),a1        open mathffp library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,FfpBase
       beq.s   Gexit

       lea     MTrName(pc),a1        open mathtrans library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,MTrans
       bne.s   Tranok
       lea     MTrName(pc),a0   first line
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
Gexit  bra.s   exit

Tranok lea     IntName(pc),a1        open intuition library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,IntBase
       beq.s   Gexit

       lea     nw(pc),a0             open window
       movea.l IntBase,a6
       jsr     _LVOOpenWindow(a6)
       move.l  d0,window
       beq.s   Gexit


       movea.l d0,a0
       movea.l 50(a0),a5

next1  bsr     draw            draw aeroplane

       bsr.s   trycls
       cmpi.l  #$200,d7
       beq.s   exit

       bsr     walk
       bra.s   next1


exit   movea.l IntBase(pc),a6
       move.l  window(pc),d0        close window
       beq.s   noWin
       movea.l d0,a0
       jsr     _LVOCloseWindow(a6)

noWin  movea.l _AbsExecBase,a6
       move.l   WBenchMsg(pc),d7
       beq.s   NoBenh
       jsr     _LVOForbid(a6)       reply to WB
       movea.l d7,a1
       jsr     _LVOReplyMsg(a6)
       jsr     _LVOPermit(a6)

NoBenh move.l  IntBase(pc),d1       close intuition library
       beq.s   noInt
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noInt  move.l  MTrans(pc),d1        close mathtrans library
       beq.s   noTran
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noTran move.l  FfpBase(pc),d1       close mathffp library
       beq.s   noFfp
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noFfp  move.l  GfxBase(pc),d1       close graphics library
       beq.s   noGfx
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noGfx  moveq   #0,d0                no error
       rts

trycls movem.l d0-d6/a0-a6,-(a7)
       movea.l _AbsExecBase,a6
       moveq   #0,d7
       movea.l window(pc),a0
       movea.l $56(a0),a0    load Window.UserPort
       jsr     _LVOGetMsg(a6)
       tst.l   d0
       beq.s   noMsg1         No message

       movea.l d0,a1
       move.l  $14(a1),d7       Message in d7
       jsr     _LVOReplyMsg(a6) Always reply

noMsg1 movem.l (a7)+,d0-d6/a0-a6
noMsg  tst.l   d7
       rts

angle  move.l  d2,d0
       jsr     _LVOSPSin(a6)
       exg     d0,d2
       jsr     _LVOSPCos(a6)
       rts


draw   movea.l MTrans(pc),a6    calculate angles
       move.l  alpha(pc),d2
       bsr.s   angle
       move.l  d2,sa
       move.l  d0,ca
       move.l  beta(pc),d2
       bsr.s   angle
       move.l  d2,sb
       move.l  d0,cb
       move.l  gamma(pc),d2
       bsr.s   angle
       move.l  d2,sc
       move.l  d0,cc

       move.l  #170,d7
       lea     plane(pc),a2
       lea     buffer(pc),a3

dlop   move.w  (a2)+,d2
       ext.l   d2
       move.w  (a2)+,d3
       ext.l   d3
       move.w  (a2)+,d4
       ext.l   d4
       bsr.s   persp        perspective

ntsc   add.l   #80,d4
       add.l   #250,d3
       move.l  d4,(a3)+
       move.l  d3,(a3)+
       dbra    d7,dlop

       movea.l GfxBase(pc),a6  clear screen
       moveq   #0,d0
       movea.l a5,a1
       jsr     _LVOSetAPen(a6)

       movea.l a5,a1
       moveq   #0,d0
       moveq   #0,d1
       move.l  #640,d2
       move.l  #250,d3
       jsr     _LVORectFill(a6)

       moveq   #3,d0
       movea.l a5,a1
       jsr     _LVOSetAPen(a6)

       lea     plot(pc),a3
       lea     buffer(pc),a4
       move.l  #170,d7
       moveq   #1,d6

plop   move.l  (a4)+,d1
       move.l  (a4)+,d0
       movea.l a5,a1
       subq.b  #1,d6
       bne.s   nomove
       jsr     _LVOMove(a6)
       move.b  (a3)+,d6
       bra.s   next
nomove jsr     _LVODraw(a6)
next   dbra    d7,plop
       rts

persp  movem.l a2-a5,-(a7)
       movea.l FfpBase(pc),a6

       move.l  d2,d0
       jsr     _LVOSPFlt(a6)
       move.l  d0,d2
       move.l  d3,d0
       jsr     _LVOSPFlt(a6)
       move.l  d0,d3
       move.l  d4,d0
       jsr     _LVOSPFlt(a6)
       move.l  d0,d4

       move.l  sa(pc),d1
       jsr     _LVOSPMul(a6)
       move.l  d0,d5
       move.l  ca(pc),d0
       move.l  d3,d1
       jsr     _LVOSPMul(a6)
       move.l  d5,d1
       jsr     _LVOSPSub(a6)
       exg     d0,d3           y = ca*y - sa*z

       move.l  sa(pc),d1
       jsr     _LVOSPMul(a6)
       exg     d0,d4
       move.l  ca(pc),d1
       jsr     _LVOSPMul(a6)
       move.l  d4,d1
       jsr     _LVOSPAdd(a6)
       move.l  d0,d4          z = sa*y + ca*z

       move.l  sa(pc),d0
       move.l  d4,d1
       jsr     _LVOSPMul(a6)
       move.l  d0,d5
       move.l  cb(pc),d0
       move.l  d2,d1
       jsr     _LVOSPMul(a6)
       move.l  d5,d1
       jsr     _LVOSPSub(a6)
       exg     d0,d2          x = cb*x - sb*z

       move.l  sb(pc),d1
       jsr     _LVOSPMul(a6)
       move.l  d0,d5
       move.l  cb(pc),d0
       move.l  d4,d1
       jsr     _LVOSPMul(a6)
       move.l  d5,d1
       jsr     _LVOSPAdd(a6)
       move.l  d0,d4         z = sb*x + cb*z

       move.l  sc(pc),d0
       move.l  d3,d1
       jsr     _LVOSPMul(a6)
       move.l  d0,d5
       move.l  cc(pc),d0
       move.l  d2,d1
       jsr     _LVOSPMul(a6)
       move.l  d5,d1
       jsr     _LVOSPSub(a6)
       exg     d0,d2         x = cc*x - sc*y

       move.l  sc(pc),d1
       jsr     _LVOSPMul(a6)
       move.l  d0,d5
       move.l  cc(pc),d0
       move.l  d3,d1
       jsr     _LVOSPMul(a6)
       move.l  d5,d1
       jsr     _LVOSPAdd(a6)
       move.l  d0,d3         y = sc*x + cc*y

       move.l  d2,d0
       jsr     _LVOSPFix(a6)
       move.l  d0,d2
       move.l  d3,d0
       jsr     _LVOSPFix(a6)
       move.l  d0,d3
       move.l  d4,d0
       jsr     _LVOSPFix(a6)
       move.l  d0,d4

       movem.l (a7)+,a2-a5
       rts

csine  movea.l FfpBase(pc),a6
       move.l  #pi2,d1
       move.l  d2,d0
       jsr     _LVOSPMul(a6)
       movea.l MTrans(pc),a6
       jsr     _LVOSPSin(a6)
       movea.l FfpBase(pc),a6
       move.l  d7,d1
       jsr     _LVOSPMul(a6)
       move.l  d2,d1
       jsr     _LVOSPAdd(a6)
       rts


walk   move.l  #fif,d7
       move.l  alpha(pc),d2
       bsr.s   csine
       move.l  d0,alpha
       move.l  beta(pc),d2
       bsr.s   csine
       move.l  d0,beta
       move.l  gamma(pc),d2
       bsr.s   csine
       move.l  d0,gamma
       move.l  #dr,d2
       move.l  vx(pc),d3
       move.l  alpha(pc),d0
       bsr.s   step
       move.l  d0,vx
       move.l  vy(pc),d3
       move.l  beta(pc),d0
       bsr.s   step
       move.l  d0,vy
       move.l  vz(pc),d3
       move.l  gamma(pc),d0
       bsr.s   step
       move.l  d0,vz
       rts

step   movea.l MTrans(pc),a6
       jsr     _LVOSPCos(a6)
       movea.l FfpBase(pc),a6
       move.l  d2,d1
       jsr     _LVOSPMul(a6)
       move.l  d3,d1
       jsr     _LVOSPAdd(a6)
       rts

; angles

alpha  dc.l $c90fd942
beta   dc.l pi2
gamma  dc.l pi2

; cosines

ca     dc.l 0
cb     dc.l 0
cc     dc.l 0

; sines

sa     dc.l 0
sb     dc.l 0
sc     dc.l 0

; displacement

vx     dc.l $80000042
vy     dc.l $80000042
vz     dc.l $80000042

buffer ds.l 171*2

plot   dc.b 13,7,7,4,4,9,11,14,7,7,3,3
       dc.b 4,5,4,6,14,9,7,13,10,9
       even

; aeroplane coordinates

; upper wing

plane       dc.w 20,0,0
            dc.w 130,0,0
            dc.w 140,50,0
            dc.w 130,60,0
            dc.w -130,60,0
            dc.w -140,50,0
            dc.w -130,0,0
            dc.w -20,0,0
            dc.w -10,15,0
            dc.w 10,15,0
            dc.w 20,0,0
            dc.w 10,15,0
            dc.w -10,15,0

; lower right wing (from top)

            dc.w 10,60,-55
            dc.w 10,50,-55
            dc.w 10,-10,-55
            dc.w 100,-10,-55
            dc.w 110,40,-55
            dc.w 100,50,-55
            dc.w 10,50,-55

; lower left wing (from top)

            dc.w -10,50,-55
            dc.w -100,50,-55
            dc.w -110,40,-55
            dc.w -100,-10,-55
            dc.w -10,-10,-55
            dc.w -10,50,-55
            dc.w -10,60,-55

; the wing supports

            dc.w -82,10,0
            dc.w -80,0,-55
            dc.w -90,50,0
            dc.w -88,40,-55
            dc.w 82,10,0
            dc.w 80,0,-55
            dc.w 90,50,0
            dc.w 88,40,-55

; the nose of the plane

            dc.w 0,90,-35
            dc.w 0,80,-30
            dc.w -5,80,-35
            dc.w 0,80,-40
            dc.w 5,80,-35
            dc.w 0,90,-35
            dc.w 0,80,-40
            dc.w 5,80,-35
            dc.w 0,80,-30
            dc.w 0,-140,-45
            dc.w 15,-30,-45
            dc.w 15,60,-45
            dc.w 10,60,-55
            dc.w -10,60,-55
            dc.w -15,60,-45
            dc.w -15,60,-25
            dc.w 0,60,-15
            dc.w 15,60,-25
            dc.w 10,80,-25
            dc.w 0,60,-15
            dc.w 10,80,-25
            dc.w 15,60,-25
            dc.w 15,60,-45
            dc.w 10,80,-45
            dc.w -10,80,-45
            dc.w -10,60,-55
            dc.w -15,60,-45
            dc.w -10,80,-45
            dc.w -10,80,-25
            dc.w -15,60,-25
            dc.w -10,80,-25
            dc.w 10,80,-25
            dc.w 10,80,-45
            dc.w 10,60,-55

; wheels

            dc.w 35,60,-75
            dc.w 35,70,-80
            dc.w 35,70,-90
            dc.w 35,60,-95
            dc.w 35,50,-90
            dc.w 35,50,-80
            dc.w 35,60,-75
            dc.w -35,60,-75
            dc.w -35,70,-80
            dc.w -35,70,-90
            dc.w -35,60,-95
            dc.w -35,50,-90
            dc.w -35,50,-80
            dc.w -35,60,-75
            dc.w 10,-25,-20
            dc.w 0,-25,-15
            dc.w -10,-25,-20
            dc.w -10,60,-55
            dc.w -10,50,-55
            dc.w 10,60,-55


; the body of the plane

            dc.w 15,60,-25
            dc.w 15,-30,-25
            dc.w 0,-140,-35
            dc.w 5,-100,-35
            dc.w 15,60,-45
            dc.w 15,-30,-45
            dc.w 0,-140,-45
            dc.w -15,-30,-45
            dc.w -15,60,-45
            dc.w 10,-25,-20
            dc.w 0,-140,-35
            dc.w 0,-140,-45
            dc.w 10,-10,-55
            dc.w 15,-30,-45
            dc.w 0,-140,-45
            dc.w -10,-10,-55
            dc.w 0,-140,-45
            dc.w 0,-140,-35
            dc.w -5,-100,-35
            dc.w 5,-100,-35
            dc.w 60,-120,-35
            dc.w 60,-130,-35
            dc.w 60,-140,-35
            dc.w 50,-150,-35
            dc.w 20,-150,-35
            dc.w 2,-130,-35
            dc.w -2,-130,-35
            dc.w -20,-150,-35
            dc.w -50,-150,-35
            dc.w -60,-140,-35
            dc.w -60,-130,-35
            dc.w -60,-120,-35
            dc.w -5,-100,-35
            dc.w 0,-140,-35
            dc.w 0,-100,-30
            dc.w 0,-120,-5
            dc.w 0,-140,0
            dc.w 0,-140,-35
            dc.w 0,-140,-45
            dc.w 0,-155,-25
            dc.w 0,-155,-5
            dc.w 0,-140,0
            dc.w 0,-25,-15
            dc.w 0,-140,-35
            dc.w -15,-30,-25
            dc.w -15,60,-25
            dc.w -15,60,-45
            dc.w -15,-30,-45
            dc.w 0,-140,-45
            dc.w -10,85,5
            dc.w -30,85,-5
            dc.w -40,85,-25
            dc.w -40,85,-45
            dc.w -30,85,-65
            dc.w -10,85,-75
            dc.w 10,85,-75
            dc.w 30,85,-65
            dc.w 40,85,-45
            dc.w 40,85,-25
            dc.w 30,85,-5
            dc.w 10,85,5
            dc.w -10,85,5
            dc.w 10,60,-55
            dc.w 30,60,-85
            dc.w 10,30,-55
            dc.w 30,60,-85
            dc.w 40,60,-85
            dc.w -40,60,-85
            dc.w -30,60,-85
            dc.w -10,30,-55
            dc.w -30,60,-85
            dc.w -10,60,-55
            dc.w 0,60,-15
            dc.w 0,0,-15
            dc.w 15,-10,-20
            dc.w 15,-20,-20
            dc.w 10,-25,-20
            dc.w -10,-25,-20
            dc.w -15,-20,-20
            dc.w -15,-10,-20
            dc.w 0,0,-15


WBenchMsg   dc.l 0
MTrans      dc.l 0
FfpBase     dc.l 0
DosBase     dc.l 0
GfxBase     dc.l 0
IntBase     dc.l 0

window      dc.l 0

MTrName     dc.b 'mathtrans.library',0
FfpName     dc.b 'mathffp.library',0
DosName     dc.b 'dos.library',0
GfxName     dc.b 'graphics.library',0
IntName     dc.b 'intuition.library',0
            even

title       dc.b  'aeroplane',0
            even

; requester texts

notfnd      dc.b ' not found',0
hdtxt       dc.b ' Plane Request',0
OkTxt       dc.b ' OK',0
            even

***** Window definition *****

nw          dc.w 0,0         Position left,top
            dc.w 640,199     Size width,height
            dc.b 0,1         Colors detail-,block pen
            dc.l $200        IDCMP-Flags
            dc.l $144f       Window flags
            dc.l 0           ^Gadget
            dc.l 0           ^Menu check
            dc.l title       ^Window name
nws         dc.l 0           ^Screen structure,
            dc.l 0           ^BitMap
            dc.w 100         MinWidth
            dc.w 40          MinHeight
            dc.w -1          MaxWidth
            dc.w -1,1        MaxHeight,Screen type

            end

