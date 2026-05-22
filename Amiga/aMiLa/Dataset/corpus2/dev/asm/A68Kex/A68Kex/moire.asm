*
* This is a remake of moire on AmigaLibDisk9
*
************************************************************************
* Moire.c -- Yet another graphics dazzler for the Amiga.  This one draws
*            Moire Patterns in Black and White - they tend to look better
*            that way.  Uses a borderless backdrop window to make life
*            easier, and so we get the whole screen if we want it.
*
*            Copyright (c) 1985 by Scott Ballantyne
*            (I.E. Ok to give away for nothing )
************************************************************************
*
* This implementation was written by
* E. Lenz
* Johann-Fichte-Strasse 11
* 8 Munich 40
* Germany
*

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
_LVOSetMenuStrip    equ -$108
_LVOShowTitle       equ -$11a
_LVOViewPortAddress equ -$12c

***** graphics ******

_LVOMove            equ -$f0
_LVODraw            equ -$f6
_LVOSetRGB4         equ -$120
_LVORectFill        equ -$132
_LVOSetAPen         equ -$156
_LVOSetDrMd         equ -$162

wd_RPort         equ $32
wd_UserPort      equ $56
pr_MsgPort       equ $5c
pr_CLI           equ $ac
ThisTask         equ $114

JAM1         set 0
ERASE        set 0
SHOW         set 1
CUSTOMSCREEN set $f
MAXX         set 640
MAXY         set 200
MENUPICK     set $100
BACKDROP     set $100
BORDERLESS   set $800
ACTIVATE     set $1000
HIRES        set $8000

       XREF    Random

       movea.l _AbsExecBase,a6   test if WB or CLI
       movea.l ThisTask(a6),a0
       moveq   #0,d0
       tst.l   pr_CLI(a0)
       bne.s   isCLI

       lea     pr_MsgPort(a0),a0     for WB get WB Message
       jsr     _LVOWaitPort(a6)
       jsr     _LVOGetMsg(a6)

isCLI  move.l  d0,-(a7)

       lea     GfxName(pc),a1   Open graphics.library
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

       lea     ns(pc),a0              open screen
       movea.l a2,a6
       jsr     _LVOOpenScreen(a6)
       move.l  d0,nws
       beq.s   Gexit

       lea     nw(pc),a0              open window
       jsr     _LVOOpenWindow(a6)
       movea.l d0,a3
       tst.l   d0
Gexit  beq     exit

       movea.l d0,a0
       movea.l wd_RPort(a0),a5
       jsr     _LVOViewPortAddress(a6)

       move.l  d0,-(a7)
       movea.l d0,a0
       movea.l a4,a6
       moveq   #0,d0
       moveq   #0,d1
       moveq   #0,d2
       moveq   #0,d3
       jsr     _LVOSetRGB4(a6)

       movea.l (a7)+,a0
       moveq   #1,d0
       moveq   #$f,d1
       moveq   #$f,d2
       moveq   #$f,d3
       jsr     _LVOSetRGB4(a6)

; Set menu

       movea.l a2,a6
       movea.l a3,a0           which window
       lea     Menu1(pc),a1    which menu
       jsr     _LVOSetMenuStrip(a6)

       movea.l a4,a6
       movea.l a5,a1
       moveq   #JAM1,d0
       jsr     _LVOSetDrMd(a6)

       bsr     moire

loop   movea.l _AbsExecBase,a6

       movea.l a3,a0
       movea.l wd_UserPort(a0),a0
       jsr     _LVOGetMsg(a6)
       tst.l   d0
       beq.s   loop           ;No message

       movea.l d0,a1
       move.l  $14(a1),d7       Message in a7
       jsr     _LVOReplyMsg(a6) Always reply

; Choice from menu

       movea.l a3,a0
       movea.l $5e(a0),a0   Load Window.MessageKey
       move.w  $18(a0),d0   Load message code
       move.w  d0,d1
       andi.w  #$f,d1
       bne.s   loop

       andi.w  #$f0,d0      Menu 1
       bne.s   menu12       Submenu 1
       bsr     moire
sedraw bra.s   loop

menu12 cmpi.w  #$20,d0      Submenu 2
       bne.s   menu13
       moveq   #0,d0
       bra.s   show

menu13 cmpi.w  #$40,d0      Submenu 3
       bne     exit
       moveq   #1,d0
show   movea.l a2,a6
       lea     nws(pc),a0
       move.l  (a0),a0
       jsr     _LVOShowTitle(a6)
       bra.s   loop

exit   movea.l a2,a6           close window
       move.l  a3,d0
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

NoBenh move.l  a2,d1           close intuition library
       beq.s   noInt
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noInt  move.l  a4,d1               close graphics library
       beq.s   noGfx
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noGfx  moveq   #0,d0                no error
       rts

moire  movea.l a4,a6
       movea.l a5,a1
       moveq   #ERASE,d0
       jsr     _LVOSetAPen(a6)
       movea.l a5,a1
       moveq   #0,d0
       moveq   #0,d1
       move.l  #MAXX,d2
       move.l  #MAXY,d3
       jsr     _LVORectFill(a6)
       move.l  #MAXY,d0
       jsr     Random
       move.l  d0,d5         y1
       move.l  #MAXX,d0
       jsr     Random
       move.l  d0,d4         x1
       moveq   #0,d3         y0
       move.l  #MAXX-1,d6    x2
       move.l  #MAXY,d7      y2
loopx  moveq   #SHOW,d1      mode
       move.l  d6,d2         x0
       bsr     doline
       subq.l  #1,d6
       moveq   #ERASE,d1
       move.l  d6,d2
       bsr     doline
       dbra    d6,loopx
       move.l  #MAXY-1,d7
       move.l  #MAXX,d6
       moveq   #0,d2
loopy  moveq   #SHOW,d1
       move.l  d7,d3
       bsr     doline
       subq.l  #1,d7
       moveq   #ERASE,d1
       move.l  d7,d3
       bsr     doline
       dbra    d7,loopy
       rts

doline movea.l a5,a1
       move.l  d1,d0
       jsr     _LVOSetAPen(a6)
       movea.l a5,a1
       move.l  d2,d0
       move.l  d3,d1
       jsr     _LVOMove(a6)
       movea.l a5,a1
       move.l  d4,d0
       move.l  d5,d1
       jsr     _LVODraw(a6)
       movea.l a5,a1
       move.l  d6,d0
       move.l  d7,d1
       jsr     _LVODraw(a6)
       rts

GfxName     dc.b 'graphics.library',0
IntName     dc.b 'intuition.library',0
            even

title1      dc.b 'Moire Patterns',0
            even

**** screen definition ****

ns          dc.w  0,0
            dc.w  MAXX,MAXY,1
            dc.b  0,1
            dc.w  HIRES
            dc.w  CUSTOMSCREEN
            dc.l  0
            dc.l  title1
            dc.l  0
            dc.l  0

***** Window definition *****

nw          dc.w 0,0           ;Position left,top
            dc.w MAXX,MAXY     ;Size width,height
            dc.b 0,1           ;Colors detail-,block pen
            dc.l MENUPICK      ;IDCMP-Flags
            dc.l BORDERLESS+BACKDROP+ACTIVATE  ;Window flags
            dc.l 0             ;^Gadget
            dc.l 0             ;^Menu check
            dc.l 0             ;^Window name
nws         dc.l 0             ;^Screen structure,
            dc.l 0             ;^BitMap
            dc.w 0             ;MinWidth
            dc.w 0             ;MinHeight
            dc.w 0             ;MaxWidth
            dc.w 0,CUSTOMSCREEN ;MaxHeight,Screen type

**** menu definition ****

Menu1       dc.l 0           Next menu
            dc.w 0,0         Position left edge,top edge
            dc.w 100,20      Dimensions width,height
            dc.w 1           Menu enabled
            dc.l mtext1      Text for menu header
            dc.l item11      ^First in chain
            dc.l 0,0         Internal

mtext1      dc.b 'Actions',0
            even

item11      dc.l item12      next in chained list
            dc.w 0,0         Position left edge,top edge
            dc.w 120,10      Dimensions width,height
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

item11txt   dc.b 'New Moire',0
            even

item12      dc.l item13      next in chained list
            dc.w 0,10        Position left edge,top edge
            dc.w 120,10      Dimensions width,height
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

item12txt   dc.b 'Hide Title Bar',0
            even

item13      dc.l item14      next in chained list
            dc.w 0,20        Position left edge,top edge
            dc.w 120,10      Dimensions width,height
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

item13txt   dc.b 'Show Title Bar',0

item14      dc.l 0           next in chained list
            dc.w 0,30        Position left edge,top edge
            dc.w 120,10      Dimensions width,height
            dc.w $52         itemtext+highcomp+itemenabled
            dc.l 0           Mutual exclude
            dc.l I14txt      Pointer to intuition text
            dc.l 0
            dc.b 0,0
            dc.l 0
            dc.w 0


I14txt      dc.b 0           Front pen  (blue)
            dc.b 1           Back pen   (white)
            dc.b 0,0         Draw mode
            dc.w 0           Left edge
            dc.w 0           Top edge
            dc.l 0           Text font
            dc.l item14txt   Pointer to text
            dc.l 0           Next text

item14txt   dc.b 'Quit!',0

            even
            end

