************************************************************************
*                                                                      *
* These are prime number maps                                          *
*                                                                      *
* This implementation was written by:                                  *
* E. Lenz                                                              *
* Johann-Fichte-Strasse 11                                             *
* 8 Munich 40                                                          *
* Germany                                                              *
*                                                                      *
************************************************************************

; d0 Number counter
; d1
; d2 flag if prime
; d3 colour counter
; d4 x coordinate
; d5 y coordinate
; d6 pointer to buffer
; d7 menu stuff
; a0
; a1
; a2
; a3 GfxBase
; a4 pointer to buffer
; a5 rast port

_AbsExecBase        equ 4

**** exec *****

_LVOForbid       equ -$84
_LVOPermit       equ -$8a
_LVOAllocMem     equ -$c6
_LVOFreeMem      equ -$d2
_LVOGetMsg       equ -$174
_LVOReplyMsg     equ -$17a
_LVOWaitPort     equ -$180
_LVOCloseLibrary equ -$19e
_LVOOpenLibrary  equ -$228

**** intuition ******

_LVOCloseScreen    equ -$42
_LVOCloseWindow    equ -$48
_LVOOpenScreen     equ -$c6
_LVOOpenWindow     equ -$cc
_LVOSetMenuStrip   equ -$108

***** graphics ******

_LVOText           equ -$3c
_LVOLoadRGB4       equ -$c0
_LVOMove           equ -$f0
_LVODraw           equ -$f6
_LVORectFill       equ -$132
_LVOSetAPen        equ -$156
_LVOScrollRaster   equ -$18c

wd_Width         equ 8
wd_Height        equ $a
sc_ViewPort      equ $2c
wd_RPort         equ $32
wd_UserPort      equ $56
pr_MsgPort       equ $5c
pr_CLI           equ $ac
ThisTask         equ $114
VBlankFrequency  equ $212

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
       move.w  #256,ns+6

isNTSC move.l  #$6700,d0         allocate buffer
       move.l  #$30000,d1        largest + clear
       jsr     _LVOAllocMem(a6)
       move.l  d0,d6
       beq.s   Gexit

       lea     GfxName(pc),a1        open graphics library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       movea.l d0,a3
       tst.l   d0
       beq.s   Gexit

       lea     IntName(pc),a1        open intuition library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,IntBase
Gexit  beq     exit

       lea     ns(pc),a0              open screen
       movea.l d0,a6
       jsr     _LVOOpenScreen(a6)
       move.l  d0,screen
       beq.s   Gexit
       move.l  d0,nws
       move.l  d0,d2

       lea     nw(pc),a0             open window
       jsr     _LVOOpenWindow(a6)
       move.l  d0,window
       beq.s   Gexit

; Set menu

       movea.l d0,a0           which window
       lea     Menu1(pc),a1    which menu
       jsr     _LVOSetMenuStrip(a6)

       movea.l window(pc),a0
       movea.l wd_RPort(a0),a5

       movea.l d2,a0
       lea     sc_ViewPort(a0),a0

       lea     ColourTable(pc),a1
       moveq   #16,d0
       movea.l a3,a6
       jsr     _LVOLoadRGB4(a6)

** start off with the prime number 3 ***

rest   movea.l d6,a4
       moveq   #3,d0
       move.l  d0,(a4)+
       moveq   #1,d2
redraw movem.l d0/d2,-(a7)

       movea.l a3,a6  clear screen
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
       moveq   #1,d0
       jsr     _LVOSetAPen(a6)

       moveq   #0,d4       set x position to 0
       moveq   #0,d5
       moveq   #0,d3
       clr.w   fin

draw   tst.w   fin
       bne.s   wait
       movem.l (a7)+,d0/d2
       bsr     func
       movem.l d0/d2,-(a7)
       tst.l   d0
       beq.s   exit1

wait   bsr     trycls
       beq.s   draw
       cmpi.l  #$200,d7
       beq.s   exit1

       cmpi.l  #$100,d7
       bne.s   wait

; Choice from menu

       movea.l window(pc),a0
       movea.l $5e(a0),a0   Load Window.MessageKey
       move.w  $18(a0),d0   Load message code
       move.w  d0,d1
       andi.w  #$f,d1
       bne.s   ismen2

       andi.w  #$f0,d0      Menu 1
       bne.s   menu12       Submenu 1
       move.w  #ShowPr-addr,addr
Gdraw  movem.l (a7)+,d0/d2
       bra     rest

menu12 cmpi.w  #$20,d0      Submenu 2
       bne.s   menu13
       move.w  #print-addr,addr
       bra.s   Gdraw

menu13 cmpi.w  #$40,d0      Submenu 2
       bne.s   wait
       move.w  #diff-addr,addr
       bra.s   Gdraw


ismen2 cmpi.w  #1,d1
       bne.s   wait
       andi.w  #$f0,d0      Menu 2
       bne.s   wait
       movem.l (a7)+,d0/d2
       bra     redraw

exit1  movem.l (a7)+,d0/d2

exit   movea.l IntBase(pc),a6
       move.l  window(pc),d0
       beq.s   noWin
       movea.l d0,a0
       jsr     _LVOCloseWindow(a6)    close window

noWin  move.l  screen(pc),d0         close screen
       beq.s   noScr
       movea.l d0,a0
       jsr     _LVOCloseScreen(a6)

noScr  movea.l _AbsExecBase,a6
       tst.l   WBenchMsg
       beq.s   free
       jsr     _LVOForbid(a6)       reply to WB
       movea.l WBenchMsg(pc),a1
       jsr     _LVOReplyMsg(a6)
       jsr     _LVOPermit(a6)

free   tst.l   d6                free buffer
       beq.s   NoBenh
       movea.l d6,a1
       move.l  #$6700,d0
       jsr     _LVOFreeMem(a6)

NoBenh move.l  IntBase(pc),d1       close intuition library
       beq.s   noInt
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noInt  move.l  a3,d1                close graphics library
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

********************************************
*                                          *
* Write number in d0 as decimal to console *
*                                          *
********************************************


ShowPr movem.l d0-d3/a0-a1,-(a7)
       move.l  d0,-(a7)
       movea.l a3,a6

       addq.l  #8,d5
       move.l  d5,d0
       addq.l  #8,d0
       movea.l window(pc),a0
       cmp.w   wd_Height(a0),d0
       bcs.s   isok
       subq.l  #8,d5
       move.l  d5,-(a7)
       movea.l a5,a1
       moveq   #0,d0
       moveq   #8,d1
       moveq   #0,d2
       moveq   #0,d3
       moveq   #60,d4
       move.w  wd_Height(a0),d5
       jsr     _LVOScrollRaster(a6)
       move.l  (a7)+,d5

isok   moveq   #0,d0
       move.l  d5,d1
       movea.l a5,a1
       jsr     _LVOMove(a6)

       move.l  (a7)+,d0
       lea     Prime(pc),a1
       movea.l a1,a0
       move.l  #'0000',d1
       move.l  d1,(a1)+
       move.l  d1,(a1)+
       move.l  d1,(a1)+
       lea     Num(pc),a1
plop   move.l  (a1)+,d1
       addq.l  #1,a0
pnext  cmp.l   d1,d0
       bcs.s   plop
       sub.l   d1,d0
       addq.b  #1,(a0)
       tst.l   d0
       bne.s   pnext
       lea     Prime(pc),a0
       moveq   #11,d0
ptest  cmpi.b  #'0',(a0)
       bne.s   endp
       subq.l  #1,d0
       addq.l  #1,a0
       bra.s   ptest
endp   movea.l a5,a1
       jsr     _LVOText(a6)
       movem.l (a7)+,d0-d3/a0-a1
next   bsr.s   NextPr
       tst.l   d2
       beq.s   next
       rts

********************************
*
* advance one graphic point
*
********************************

advan  move.l  d0,-(a7)
       movea.l a3,a6
       move.l  d4,d0
       move.l  d5,d1
       movea.l a5,a1
       jsr     _LVOMove(a6)

       move.l  d3,d0
       movea.l a5,a1
       jsr     _LVOSetAPen(a6)

       move.l  d4,d0
       move.l  d5,d1
       movea.l a5,a1
       jsr     _LVODraw(a6)

       addq.l  #1,d4
       move.l  d4,d0
       addi.w  #20,d0
       move.l  window(pc),a0
       cmp.w   wd_Width(a0),d0
       bne.s   nolin
       moveq   #0,d4
       addq.l  #1,d5
       cmp.w   wd_Height(a0),d5
       bne.s   nolin
       move.w  #1,fin

nolin  move.l  (a7)+,d0
       rts

**********************************
*                                *
* print map of prime differences *
*                                *
**********************************

diff   bsr.s   advan

       moveq   #0,d3
knot   bsr.s   NextPr
       tst.l   d2
       bne.s   found
       addq.l  #1,d3
       bra.s   knot

found  rts

***********************
*                     *
* print map of primes *
*                     *
***********************

print  moveq   #3,d3
       tst.l   d2
       bne.s   isPrim
       moveq   #0,d3
isPrim bsr.s   advan

******************************************
*                                        *
* Calculate next prime number            *
*                                        *
******************************************

NextPr move.l  d6,a0
       addq.l  #2,d0
       bcs.s   eprim
nlop   move.l  (a0)+,d2
       beq.s   isPr
       move.l  d2,d1
       mulu    d2,d1
       cmp.l   d1,d0
       bcs.s   isPr
       bsr.s   mod
       tst.l   d2
       beq.s   nosave        no prime - try next number
       bra.s   nlop          try next divisor
isPr   move.l  d0,d1
       swap    d1
       tst.w   d1
       bne.s   nosave
       move.l  d0,(a4)+
nosave rts
eprim  moveq   #0,d0
       rts

**************************
*                        *
* return d0 mod d2 in d2 *
*                        *
**************************

mod    move.l  d0,-(a7)
       lea     pow(pc),a1
       moveq   #9,d1
mlop   move.l  d2,(a1)+
       add.l   d2,d2
       dbra    d1,mlop
mnext  move.l  -(a1),d1
       beq.s   mend
mwhat  cmp.l   d1,d0
       bcs.s   mnext
       sub.l   d1,d0
       beq.s   mend
       bra.s   mwhat
mend   move.l  d0,d2
       move.l  (a7)+,d0
       rts

func   dc.w    $6000
addr   dc.w    print-*

fin         ds.w 1
WBenchMsg   dc.l 0
DosBase     dc.l 0
IntBase     dc.l 0
window      dc.l 0
screen      dc.l 0

ColourTable dc.w $15a,$fff,$000,$e83
            dc.w $069,$087,$0a5,$0c3
            dc.w $0f0,$2d0,$4b0,$690
            dc.w $870,$a50,$c30,$f00

Num       dc.l 1000000000,100000000,10000000,1000000,100000,10000,1000,100,10,1
Prime     ds.b 12

          dc.l 0
pow       ds.l 1

DosName     dc.b 'dos.library',0
GfxName     dc.b 'graphics.library',0
IntName     dc.b 'intuition.library',0
            even

title1      dc.b 'Screen',0
            even

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

title       dc.b  'Prime evil & all that jazz',0
            even

***** Window definition *****

nw          dc.w 0,0           ;Position left,top
            dc.w 640,199       ;Size width,height
            dc.b 0,1           ;Colors detail-,block pen
            dc.l $344          ;IDCMP-Flags
            dc.l $144f         ;Window flags
            dc.l 0             ;^Gadget
            dc.l 0             ;^Menu check
            dc.l title         ;^Window name
nws         dc.l 0             ;^Screen structure,
            dc.l 0             ;^BitMap
            dc.w 10            ;MinWidth
            dc.w 10            ;MinHeight
            dc.w -1            ;MaxWidth
            dc.w -1,$f         ;MaxHeight,Screen type

**** menu definition ****

Menu1       dc.l Menu2       Next menu
            dc.w 50,0        Position left edge,top edge
            dc.w 100,20      Dimensions width,height
            dc.w 1           Menu enabled
            dc.l mtext1      Text for menu header
            dc.l item11      ^First in chain
            dc.l 0,0         Internal

mtext1      dc.b 'mode',0
            even

item11      dc.l item12      next in chained list
            dc.w 0,0         Position left edge,top edge
            dc.w 170,10      Dimensions width,height
            dc.w $53         itemtext+highcomp+itemenabled+checkit
            dc.l $e          Mutual exclude
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

item11txt   dc.b '   Numbers',0
            even

item12      dc.l item13      next in chained list
            dc.w 0,10        Position left edge,top edge
            dc.w 170,10      Dimensions width,height
            dc.w $153        itemtext+highcomp+itemenabled+checkit+checked
            dc.l $d          Mutual exclude
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

item12txt   dc.b '   Map',0
            even

item13      dc.l 0           next in chained list
            dc.w 0,20        Position left edge,top edge
            dc.w 170,10      Dimensions width,height
            dc.w $53         itemtext+highcomp+itemenabled+checkit
            dc.l $b          Mutual exclude
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

item13txt   dc.b '   Differences',0
            even

***** 2nd menu definition *****

Menu2       dc.l 0           Next menu
            dc.w 150,0       Position left edge,top edge
            dc.w 120,20      Dimensions width,height
            dc.w 1           Menu enabled
            dc.l mtext2      Text for menu header
            dc.l item21      ^First in chain
            dc.l 0,0         Internal

mtext2      dc.b 'redraw',0
            even


item21      dc.l 0           next in chained list
            dc.w 0,0         Position left edge,top edge
            dc.w 120,10      Dimensions width,height
            dc.w $52         itemtext+highcomp+itemenabled
            dc.l 0           Mutual exclude
            dc.l I21txt      Pointer to intuition text
            dc.l 0
            dc.b 0,0
            dc.l 0
            dc.w 0


I21txt      dc.b 0           Front pen  (blue)
            dc.b 1           Back pen   (white)
            dc.b 0,0         Draw mode
            dc.w 0           Left edge
            dc.w 0           Top edge
            dc.l 0           Text font
            dc.l item21txt   Pointer to text
            dc.l 0           Next text

item21txt   dc.b 'next page',0
            even

            end

