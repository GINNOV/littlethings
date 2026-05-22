************************************************************************
* This is an implementation of a cellular automaton of the form:       *
*                                                                      *
*  (t+1)       (t)        (t)        (t)       (t)        (t)          *
* a     = A * a    + B * a    + C * a   + D * a    + E * a             *
*  i           i-2        i-1        i         i+1        i+2          *
*                                                                      *
* See e.g. Stephan Wolfram, Cellular automata as models of complexity, *
* Nature, Vol 311, 4 October 1984.                                     *
*                                                                      *
* This implementation was written by:                                  *
* E. Lenz                                                              *
* Johann-Fichte-Strasse 11                                             *
* 8 Munich 40                                                          *
* Germany                                                              *
*                                                                      *
************************************************************************

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
_LVOSetAPen         equ -$156

***** dos ******

_LVOOpen         equ -$1e
_LVOClose        equ -$24
_LVORead         equ -$2a
_LVOWrite        equ -$30

wd_RPort        equ $32
wd_UserPort     equ $56
pr_MsgPort      equ $5c
pr_CLI          equ $ac
ThisTask        equ $114
VBlankFrequency equ $212

       moveq   #0,d0
       movea.l _AbsExecBase,a6   test if WB or CLI
       movea.l ThisTask(a6),a0
       tst.l   pr_CLI(a0)
       bne.s   isCLI

       lea     pr_MsgPort(a0),a0  for WB get WB Message
       jsr     _LVOWaitPort(a6)
       jsr     _LVOGetMsg(a6)

isCLI  move.l  d0,-(a7)

       cmpi.b  #60,VBlankFrequency(a6) test if PAL or NTSC
       beq.s   isNTSC
       move.w  #256,nw+6

isNTSC lea     GfxName(pc),a1   Open graphics.library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,GfxBase
       beq.s   Gexit

       lea     DosName(pc),a1    open dos library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,DosBase
       beq.s   Gexit

       lea     IntName(pc),a1     open intuition library
       moveq   #0,d0
       jsr     _LVOOpenLibrary(a6)
       move.l  d0,IntBase
       beq.s   Gexit

       lea     nw(pc),a0          open window
       movea.l IntBase(pc),a6
       jsr     _LVOOpenWindow(a6)
       move.l  d0,window
Gexit  beq     exit


; Set menu

       movea.l d0,a0           which window
       lea     Menu1(pc),a1    which menu
       jsr     _LVOSetMenuStrip(a6)

       movea.l window(pc),a0
       movea.l wd_RPort(a0),a5

redraw bsr     fstline         initial configuration

draw   movea.l window(pc),a0
       move.l  d6,d0
       addi.l  #$10,d0
       cmp.w   $a(a0),d0
       bpl.s   wait

       bsr     next1
       lea     next,a3
       bsr     print
       bsr     next2
       lea     first,a3
       bsr     print

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
       bne.s   ismen2

       andi.w  #$f0,d0      Menu 1
       bne.s   menu12       Submenu 1
       moveq   #0,d6        y = 0
       bra.s   draw

menu12 cmpi.w  #$20,d0      Submenu 2
       bne.s   wait
       bra.s   redraw

ismen2 cmpi.w  #1,d1
       bne     wait
       andi.w  #$f0,d0      Menu 2
       bne.s   menu22
       bsr     paraA        Submenu 1
return movea.l window(pc),a0
       move.w  $a(a0),d6
       bra.s   wait
menu22 cmpi.w  #$20,d0
       bne.s   menu23
       bsr     paraB        Submenu 2
       bra.s   return
menu23 cmpi.w  #$40,d0
       bne.s   menu24
       bsr     paraC        Submenu 3
       bra.s   return
menu24 cmpi.w  #$60,d0
       bne.s   menu25
       bsr     paraD        Submenu 4
       bra.s   return
menu25 cmpi.w  #$80,d0
       bne     wait
       bsr     paraE        Submenu 5
       bra.s   return

exit   movea.l IntBase(pc),a6
       move.l  window(pc),d7
       beq.s   noWin
       movea.l d7,a0              close window
       jsr     _LVOCloseWindow(a6)

noWin  move.l  (a7)+,d7
       movea.l _AbsExecBase,a6
       tst.l   d7
       beq.s   NoBenh
       jsr     _LVOForbid(a6)       reply to WB
       movea.l d7,a1
       jsr     _LVOReplyMsg(a6)
       jsr     _LVOPermit(a6)

NoBenh move.l  IntBase(pc),d1       close intuition library
       beq.s   noInt
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noInt  move.l  GfxBase(pc),d1       close graphics library
       beq.s   noGfx
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noGfx  move.l  DosBase(pc),d1       close dos library
       beq.s   noDos
       movea.l d1,a1
       jsr     _LVOCloseLibrary(a6)

noDos  moveq   #0,d0                no error
       rts

trycls movem.l d0-d6/a0-a6,-(a7)
       movea.l _AbsExecBase,a6
       moveq   #0,d7
       movea.l window(pc),a0
       movea.l wd_UserPort(a0),a0    load Window.UserPort
       jsr     _LVOGetMsg(a6)
       tst.l   d0
       beq.s   noMsg1         No message

       movea.l d0,a1
       move.l  $14(a1),d7       Message in d7

noMsg1 movem.l (a7)+,d0-d6/a0-a6
noMsg  tst.l   d7
       rts

fstline moveq   #0,d0
        lea     first(pc),a3
        move.l  #320,d1
clear   move.l  d0,(a3)+
        dbra    d1,clear

        move.l  #$10001,first+640
        lea     first(pc),a3
        moveq   #0,d6

print   movea.l GfxBase(pc),a6
        moveq   #0,d0
        moveq   #0,d5         x
        move.l  d6,d1         y
        movea.l a5,a1
        jsr     _LVOMove(a6)

        move.l  #640,d7
prlop   move.w  (a3)+,d0
        andi.l  #3,d0
        movea.l a5,a1
        jsr     _LVOSetAPen(a6)

        move.l  d5,d0
        move.l  d6,d1
        movea.l a5,a1
        jsr     _LVODraw(a6)
        addq.l  #1,d5
        dbra    d7,prlop
        addi.l  #1,d6
        rts

next2   lea     next(pc),a3
        lea     first(pc),a2
        bra.s   gogo

next1   lea     first(pc),a3
        lea     next(pc),a2

gogo    move.l  #640,d2
nlop    moveq   #0,d0
        moveq   #0,d3
        move.w  -4(a3),d0
        move.w  A(pc),d3
        mulu    d0,d3
        move.w  -2(a3),d0
        move.w  B(pc),d1
        mulu    d0,d1
        add.l   d1,d3
        move.w  (a3),d0
        move.w  C(pc),d1
        mulu    d0,d1
        add.l   d1,d3
        move.w  2(a3),d0
        move.w  D(pc),d1
        mulu    d0,d1
        add.l   d1,d3
        move.w  4(a3),d0
        move.w  E(pc),d1
        mulu    d0,d1
        add.l   d1,d3
        and.l   #3,d3
        move.w  d3,(a2)+
        adda.l  #2,a3
        dbra    d2,nlop
        rts

; decimal  output

decout  lea     Buffer(pc),a0
        moveq   #0,d0
wrlop   andi.l  #$ffff,d4
        tst.l   d4
        beq.s   back
        divu    #10,d4
        swap    d4
        move.b  d4,(a0)+
        swap    d4
        addq.l  #1,d0
        bra.s   wrlop

back    tst.l   d0      zero is a special case
        bne.s   bakk
        addq.l  #1,d0
        clr.b   Buffer
bakk    movea.l d6,a0
        adda.l  #21,a0
        moveq   #6,d1
        subq.l  #1,d0
clr     cmp.l   d0,d1
        beq.s   endclr
        move.b  #' ',-(a0)
        subq.l  #1,d1
        bra.s   clr

endclr  lea     Buffer(pc),a1
rewlop  move.b  (a1)+,d1
        addi.b  #'0',d1
        move.b  d1,-(a0)
        dbra    d0,rewlop
        rts

; Console handler

ConWind bsr     decout
        movea.l DosBase(pc),a6
        move.l  d5,d1
        move.l  #$3ed,d2      Open for read + write
        jsr     _LVOOpen(a6)
        move.l  d0,d4
        beq.s   nogo

        move.l  d0,d1
        move.l  d6,d2
        move.l  d7,d3
        jsr     _LVOWrite(a6)

        move.l  d4,d1
        move.l  #Buffer,d2
        moveq   #60,d3
        jsr     _LVORead(a6)

        move.l  d4,d1
        jsr     _LVOClose(a6)

; Convert input to decimal

        moveq   #0,d0
        moveq   #0,d2
        lea     Buffer(pc),a0
        moveq   #0,d1

readbuf move.b  (a0)+,d0   Get next char
        cmpi.b  #$a,d0     End of input?
        beq.s   readend
        addq.l  #1,d2
        subi.b  #$30,d0    Convert to decimal
        blt.s   nogo       Error in input
        cmpi.b  #9,d0
        bgt.s   nogo
        mulu    #10,d1
        add.l   d0,d1
        bra.s   readbuf

nogo    moveq   #1,d0      Nogood
        rts
readend tst.l   d2
        beq.s   nogo       No input
        cmpi.l  #$ffff,d1  must be word size
        bhi.s   nogo
        moveq   #0,d0      Is ok
        rts

; *** parameter A ***

paraA   move.w  A(pc),d4
        move.l  #aname,d5
        move.l  #atext,d6
        moveq   #aend-atext,d7
        bsr     ConWind

        bne.s   noA
        move.w  d1,A
noA     rts

; *** parameter B ***

paraB   move.w  B(pc),d4
        move.l  #bname,d5
        move.l  #btext,d6
        moveq   #bend-btext,d7
        bsr     ConWind

        bne.s   noA
        move.w  d1,B
        rts

; *** parameter C ***

paraC   move.w  C(pc),d4
        move.l  #cname,d5
        move.l  #ctext,d6
        moveq   #cend-ctext,d7
        bsr     ConWind

        bne.s   noA
        move.w  d1,C
        rts

; *** parameter D ***

paraD   move.w  D(pc),d4
        move.l  #dname,d5
        move.l  #dtext,d6
        moveq   #dend-dtext,d7
        bsr     ConWind

        bne.s   noA
        move.w  d1,D
        rts

; *** parameter E ***

paraE   move.w  E(pc),d4
        move.l  #ename,d5
        move.l  #etext,d6
        moveq   #eend-etext,d7
        bsr     ConWind

        bne.s   noE
        move.w  d1,E
noE     rts

A           dc.w 0
B           dc.w 1
C           dc.w 0
D           dc.w 1
E           dc.w 0
            dc.w 0,0
first       ds.w 640
            dc.w 0,0
            dc.w 0,0
next        ds.w 640
            dc.w 0,0

DosBase     dc.l 0
GfxBase     dc.l 0
IntBase     dc.l 0

window      dc.l 0

aname       dc.b 'CON:100/100/200/100/parameter A',0
            even

atext       dc.b 'parameter A = '
aaddress    dc.b 'FFFFFF',$d,$a
aend        even

bname       dc.b 'CON:100/100/200/100/parameter B',0
            even

btext       dc.b 'parameter B = '
baddress    dc.b 'FFFFFF',$d,$a
bend        even

cname       dc.b 'CON:100/100/200/100/parameter C',0
            even

ctext       dc.b 'parameter C = '
caddress    dc.b 'FFFFFF',$d,$a
cend        even

dname       dc.b 'CON:100/100/200/100/parameter D',0
            even

dtext       dc.b 'parameter D = '
daddress    dc.b 'FFFFFF',$d,$a
dend        even

ename       dc.b 'CON:100/100/200/100/parameter E',0
            even

etext       dc.b 'parameter E = '
eaddress    dc.b 'FFFFFF',$d,$a
eend        even

DosName     dc.b 'dos.library',0
Buffer:
GfxName     dc.b 'graphics.library',0
IntName     dc.b 'intuition.library',0
            even

title       dc.b  'Cellula automata',0
            even

***** Window definition *****

nw          dc.w 0,0         Position left,top
            dc.w 640,199     Size width,height
            dc.b 0,1         Colors detail-,block pen
            dc.l $344        IDCMP-Flags
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

Menu1       dc.l Menu2       Next menu
            dc.w 50,0        Position left edge,top edge
            dc.w 80,20       Dimensions width,height
            dc.w 1           Menu enabled
            dc.l mtext1      Text for menu header
            dc.l item11      ^First in chain
            dc.l 0,0         Internal

mtext1      dc.b 'Redraw',0
            even

item11      dc.l item12      next in chained list
            dc.w 0,0         Position left edge,top edge
            dc.w 80,10       Dimensions width,height
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

item11txt   dc.b 'next page',0
            even

item12      dc.l 0           next in chained list
            dc.w 0,10        Position left edge,top edge
            dc.w 80,10       Dimensions width,height
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

item12txt   dc.b 'from start',0
            even


***** 2nd menu definition *****

Menu2       dc.l 0           Next menu
            dc.w 150,0       Position left edge,top edge
            dc.w 120,20      Dimensions width,height
            dc.w 1           Menu enabled
            dc.l mtext2      Text for menu header
            dc.l item21      ^First in chain
            dc.l 0,0         Internal

mtext2      dc.b 'change rule',0
            even


item21      dc.l item22      next in chained list
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

item21txt   dc.b 'parameter A',0
            even

item22      dc.l item23      next in chained list
            dc.w 0,10        Position left edge,top edge
            dc.w 120,10      Dimensions width,height
            dc.w $52         itemtext+highcomp+itemenabled
            dc.l 0           Mutual exclude
            dc.l I22txt      Pointer to intuition text
            dc.l 0
            dc.b 0,0
            dc.l 0
            dc.w 0


I22txt      dc.b 0           Front pen  (blue)
            dc.b 1           Back pen   (white)
            dc.b 0,0         Draw mode
            dc.w 0           Left edge
            dc.w 0           Top edge
            dc.l 0           Text font
            dc.l item22txt   Pointer to text
            dc.l 0           Next text

item22txt   dc.b 'parameter B',0
            even

item23      dc.l item24      next in chained list
            dc.w 0,20        Position left edge,top edge
            dc.w 120,10      Dimensions width,height
            dc.w $52         itemtext+highcomp+itemenabled
            dc.l 0           Mutual exclude
            dc.l I23txt      Pointer to intuition text
            dc.l 0
            dc.b 0,0
            dc.l 0
            dc.w 0


I23txt      dc.b 0           Front pen  (blue)
            dc.b 1           Back pen   (white)
            dc.b 0,0         Draw mode
            dc.w 0           Left edge
            dc.w 0           Top edge
            dc.l 0           Text font
            dc.l item23txt   Pointer to text
            dc.l 0           Next text

item23txt   dc.b 'parameter C',0
            even

item24      dc.l item25      next in chained list
            dc.w 0,30        Position left edge,top edge
            dc.w 120,10      Dimensions width,height
            dc.w $52         itemtext+highcomp+itemenabled
            dc.l 0           Mutual exclude
            dc.l I24txt      Pointer to intuition text
            dc.l 0
            dc.b 0,0
            dc.l 0
            dc.w 0


I24txt      dc.b 0           Front pen  (blue)
            dc.b 1           Back pen   (white)
            dc.b 0,0         Draw mode
            dc.w 0           Left edge
            dc.w 0           Top edge
            dc.l 0           Text font
            dc.l item24txt   Pointer to text
            dc.l 0           Next text

item24txt   dc.b 'parameter D',0
            even

item25      dc.l 0           next in chained list
            dc.w 0,40        Position left edge,top edge
            dc.w 120,10      Dimensions width,height
            dc.w $52         itemtext+highcomp+itemenabled
            dc.l 0           Mutual exclude
            dc.l I25txt      Pointer to intuition text
            dc.l 0
            dc.b 0,0
            dc.l 0
            dc.w 0


I25txt      dc.b 0           Front pen  (blue)
            dc.b 1           Back pen   (white)
            dc.b 0,0         Draw mode
            dc.w 0           Left edge
            dc.w 0           Top edge
            dc.l 0           Text font
            dc.l item25txt   Pointer to text
            dc.l 0           Next text

item25txt   dc.b 'parameter E',0
            even

            end

