*******************************************
* One of the simplest strange attractors  *
* is the Lorenz attractor:                *
* E. N. Lorenz, Deterministic Nonperiodic *
* Flow, Journal of Atmospheric Science,   *
* 20, 130, (1963)                         *
*                                         *
* The model consists of the differential  *
* equations:                              *
*                                         *
* x' = -s*x + s*y                         *
* y' = r*x - y - x*z                      *
* z' = x*y - b*z                          *
*                                         *
* with:  s = 10  r = 28  b = 8/3          *
*                                         *
* This implementation was written by      *
* E. Lenz                                 *
* Johann-Fichte-Strasse 11                *
* 8 Munich 40                             *
* Germany                                 *
*                                         *
*******************************************

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

_LVOCloseScreen     equ -$42
_LVOCloseWindow     equ -$48
_LVOOpenScreen      equ -$c6
_LVOOpenWindow      equ -$cc
_LVOViewPortAddress equ -$12c

***** graphics ******

_LVOLoadRGB4        equ -$c0
_LVOMove            equ -$f0
_LVODraw            equ -$f6
_LVOSetAPen         equ -$156

****** mathffp ******

_LVOSPFix           equ -$1e
_LVOSPAdd           equ -$42
_LVOSPSub           equ -$48
_LVOSPMul           equ -$4e
_LVOSPDiv           equ -$54

wd_RPort         equ $32
wd_UserPort      equ $56
pr_MsgPort       equ $5c
pr_CLI           equ $ac
ThisTask         equ $114
VBlankFrequency  equ $212

dt       equ $83126f37    ;0.001
one      equ $80000041    ;1
three    equ $c0000042    ;3
fif      equ $f0000044    ;15

       movea.l _AbsExecBase,a6   test if WB or CLI
       movea.l ThisTask(a6),a0
       moveq   #0,d0
       tst.l   pr_CLI(a0)
       bne.s   isCLI

       lea     pr_MsgPort(a0),a0     for WB get WB Message
       jsr     _LVOWaitPort(a6)
       jsr     _LVOGetMsg(a6)

isCLI  move.l  d0,-(a7)

       cmpi.b  #60,VBlankFrequency(a6) test if PAL or NTSC
       beq.s   isNTSC
       move.w  #256,ns+6        Patch the programme
       move.w  #256,nw+6        for PAL at run time
       move.w  #$7810,NTSC1
       move.w  #120,NTSC2+2

isNTSC lea     GfxName(pc),a1   Open graphics.library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       movea.l d0,a4
       tst.l   d0
       beq.s   Gexit

       lea     IntName(pc),a1         open intuition library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       movea.l d0,a2
       tst.l   d0
       beq.s   Gexit

       lea     FfpName(pc),a1         open mathffp library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       movea.l d0,a3
       tst.l   d0
       beq.s   Gexit

       lea     ns(pc),a0              open screen
       movea.l a2,a6
       jsr     _LVOOpenScreen(a6)
       move.l  d0,nws
       beq.s   Gexit

       lea     nw(pc),a0              open window
       jsr     _LVOOpenWindow(a6)
       move.l  d0,window
Gexit  beq     exit

       movea.l d0,a0
       movea.l wd_RPort(a0),a5
       jsr     _LVOViewPortAddress(a6)

       movea.l d0,a0
       lea     ColourTable(pc),a1
       moveq   #16,d0
       movea.l a4,a6
       jsr     _LVOLoadRGB4(a6)

       move.l  #300,d0         draw axis
       moveq   #0,d1
       movea.l a5,a1
       jsr     _LVOMove(a6)

       moveq   #15,d6
NTSC1  moveq   #12,d4
       move.l  d4,d5
colour move.l  d6,d0
       movea.l a5,a1
       jsr     _LVOSetAPen(a6)
       move.l  #300,d0
       move.l  d5,d1
       movea.l a5,a1
       jsr     _LVODraw(a6)
       add.l   d4,d5
       dbra    d6,colour

       moveq   #20,d3

loop   movea.l _AbsExecBase,a6

       movea.l window(pc),a0
       movea.l wd_UserPort(a0),a0
       jsr     _LVOGetMsg(a6)
       tst.l   d0
       beq.s   Main           ;No message

       movea.l d0,a1
       move.l  $14(a1),d7       Message in a7
       jsr     _LVOReplyMsg(a6) Always reply
       movea.l a2,a6

       cmpi.l  #$200,d7     Close window
       beq     exit


Main   movea.l a3,a6       Calculate next point

       move.l  y(pc),d0
       move.l  x(pc),d1
       jsr     _LVOSPSub(a6)
       move.l  #dt,d1
       jsr     _LVOSPMul(a6)
       move.l  s(pc),d1
       jsr     _LVOSPMul(a6)
       move.l  x(pc),d1
       jsr     _LVOSPAdd(a6)
       move.l  d0,x1           ;x1 = x + s*dt*(y-x)

       move.l  #one,d0
       move.l  #dt,d1
       jsr     _LVOSPSub(a6)
       move.l  y(pc),d1
       jsr     _LVOSPMul(a6)
       move.l  d0,d7
       move.l  r(pc),d0
       move.l  z(pc),d1
       jsr     _LVOSPSub(a6)
       move.l  x(pc),d1
       jsr     _LVOSPMul(a6)
       move.l  #dt,d1
       jsr     _LVOSPMul(a6)
       move.l  d7,d1
       jsr     _LVOSPAdd(a6)
       move.l  d0,y1          ;y1 = (1 - dt)*y + dt*x*(r - z)

       move.l  b(pc),d0
       move.l  #dt,d1
       jsr     _LVOSPMul(a6)
       move.l  d0,d1
       move.l  #one,d0
       jsr     _LVOSPSub(a6)
       move.l  z(pc),d1
       jsr     _LVOSPMul(a6)
       move.l  d0,d7
       move.l  #dt,d0
       move.l  x(pc),d1
       jsr     _LVOSPMul(a6)
       move.l  y(pc),d1
       jsr     _LVOSPMul(a6)
       move.l  d7,d1
       jsr     _LVOSPAdd(a6)  ;z1 = (1 - b*dt)*z + dt*x*y

       move.l  d0,z           ;z = z1
       jsr     _LVOSPFix(a6)
       move.l  d0,zi
       lsr     #1,d0
       move.l  d0,d4
       and.l   #$f,d4
       cmp.l   #1,d4
       bgt.s   cont
       add.l   #14,d4

cont   move.l  y1(pc),d0
       move.l  d0,y            ;y = y1
       move.l  #three,d1
       jsr     _LVOSPMul(a6)
       jsr     _LVOSPFix(a6)
NTSC2  add.w   #100,d0
       move.l  d0,yi

       move.l  x1(pc),d0
       move.l  d0,x            ;x = x1
       move.l  #fif,d1
       jsr     _LVOSPMul(a6)
       jsr     _LVOSPFix(a6)
       add.w   #300,d0
       move.l  d0,xi

       movea.l a4,a6
       movea.l a5,a1
       move.l  d4,d0
       jsr     _LVOSetAPen(a6)

       move.l  xi(pc),d0
       move.l  yi(pc),d1
       movea.l a5,a1
       jsr     _LVOMove(a6)

       move.l  xi(pc),d0
       move.l  yi(pc),d1
       movea.l a5,a1
       jsr     _LVODraw(a6)

       bra     loop

exit   movea.l a2,a6           close window
       move.l  window(pc),d0
       beq.s   noWin
       movea.l d0,a0
       jsr     _LVOCloseWindow(a6)

noWin  move.l  nws(pc),d0         close screen
       beq.s   noScr
       movea.l d0,a0
       jsr     _LVOCloseScreen(a6)

noScr  movea.l _AbsExecBase,a6
       move.l  (a7)+,d0
       beq.s   NoBenh
       jsr     _LVOForbid(a6)       reply to WB
       movea.l d0,a1
       jsr     _LVOReplyMsg(a6)
       jsr     _LVOPermit(a6)

NoBenh move.l  a3,d1           close mathffp library
       beq.s   noFfp
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noFfp  move.l  a2,d1           close intuition library
       beq.s   noInt
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noInt  move.l  a4,d1               close graphics library
       beq.s   noGfx
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noGfx  moveq   #0,d0                no error
       rts

;                white  blue
ColourTable dc.w $0000,$000f,$002d,$004b
            dc.w $0069,$0087,$00a5,$00c3
;                 green
            dc.w $00f0,$02d0,$04b0,$0690
            dc.w $0870,$0a50,$0c30,$0f00
;                                   red

x           dc.l $80000044    ;10
y           dc.l $c0000043    ;28
z           dc.l $d0000045    ;8/3
s           dc.l $a0000044    ;8
r           dc.l $e0000045    ;6
b           dc.l $aaaaab42    ;26

x1          dc.l 0
y1          dc.l 0
xi          dc.l 0
yi          dc.l 0
zi          dc.l 0

FfpName     dc.b 'mathffp.library',0
GfxName     dc.b 'graphics.library',0
IntName     dc.b 'intuition.library',0
            even

window      dc.l 0

title1      dc.b 'Screen',0
            cnop 0,2

**** screen definition ****

ns          dc.w  0,0
            dc.w  640,199,4
            dc.b  0,1
            dc.w  $8000
            dc.w  $f
            dc.l  0
            dc.l  title1
            dc.l  0
            dc.l  0

title2      dc.b  'The Lorenz attractor',0,0

***** Window definition *****

nw          dc.w 0,0           ;Position left,top
            dc.w 640,199       ;Size width,height
            dc.b 0,1           ;Colors detail-,block pen
            dc.l $344          ;IDCMP-Flags
            dc.l $144f         ;Window flags
            dc.l 0             ;^Gadget
            dc.l 0             ;^Menu check
            dc.l title2        ;^Window name
nws         dc.l 0             ;^Screen structure,
            dc.l 0             ;^BitMap
            dc.w 10            ;MinWidth
            dc.w 10            ;MinHeight
            dc.w -1            ;MaxWidth
            dc.w -1,$f         ;MaxHeight,Screen type

            end

