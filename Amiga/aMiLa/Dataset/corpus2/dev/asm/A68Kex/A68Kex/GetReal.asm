*
* ENTRY: d0 pointer to screen structure
*        d1 screen type
*        a0 pointer to output text (one line)
*        a1 pointer to window title
*        a2 value to display
*
* Opens window , writes text
* inputs a real number and converts it to
* floating point format
*
* EXIT:
* If d1 = 0 all is well and the number is in d0
* If d1 <> 0 something went wrong
*
* written by E. Lenz
*            Johann-Fichte-Strasse 11
*            8 Munich 40
*            Germany

 XDEF GetReal
 XREF RealIn

_AbsExecBase     equ 4

***** exec ****

_LVOWait         equ -$13e
_LVOGetMsg       equ -$174
_LVOReplyMsg     equ -$17a
_LVOCloseLibrary equ -$19e
_LVOOpenLibrary  equ -$228

**** intuition *****

_LVOCloseWindow  equ -$48
_LVOEndRequest   equ -$78
_LVOOpenWindow   equ -$cc
_LVORequest      equ -$f0

wd_UserPort equ $56

GetReal      movem.l d2-d7/a3-a6,-(a7)
             move.l  d0,nws
             move.w  d1,stype
             move.l  a0,Rtxt
             move.l  a1,title
             lea     Buffer(pc),a0
             moveq   #0,d1
trans        move.b  (a2)+,d0
             move.b  d0,(a0)+
             addq.l  #1,d1
             cmpi.b  #$a,d0
             bne.s   trans
             move.w  d1,pos
             moveq   #1,d1
             move.l  _AbsExecBase,a6
             lea     IntName(pc),a1        Open intuition.library
             moveq   #0,d0
             jsr     _LVOOpenLibrary(a6)
             move.l  d0,d4
             beq.s   exit

             movea.l d0,a6
             movea.l d0,a5
             lea     nw(pc),a0              open window
             jsr     _LVOOpenWindow(a6)
             move.l  d0,window
Gexit        beq     exit

             movea.l d0,a4
             lea     Request1(pc),a0   Send up requester
             movea.l a4,a1
             jsr     _LVORequest(a6)

Reqwait      movea.l _AbsExecBase,a6
             movea.l a4,a0
             movea.l wd_UserPort(a0),a0  Load Window.UserPort
             move.b  $f(a0),d1           Load signal bit
             moveq   #1,d0
             lsl.l   d1,d0
             jsr     _LVOWait(a6)

             movea.l a4,a0
             movea.l wd_UserPort(a0),a0  Reload Window.UserPort
             jsr     _LVOGetMsg(a6)
             tst.l   d0
             beq.s   Reqwait       No message

             movea.l d0,a1
             move.l  $14(a1),d7       Message in a7
             jsr     _LVOReplyMsg(a6) Always reply

             movea.l a5,a6
             lea     Request1(pc),a0
             movea.l a4,a1
             jsr     _LVOEndRequest(a6)

             lea     Buffer(pc),a0
             jsr     RealIn

exit         movem.l d0-d1,-(a7)
             movea.l a5,a6           close window
             move.l  window(pc),d0
             beq.s   noWin
             movea.l d0,a0
             jsr     _LVOCloseWindow(a6)

noWin        movea.l _AbsExecBase,a6
             tst.l   d4
             beq.s   NoInt
             movea.l d4,a1        Close intuition lib
             jsr     _LVOCloseLibrary(a6)

NoInt        movem.l (a7)+,d0-d1
             movem.l (a7)+,d2-d7/a3-a6
             rts

window       ds.l 1
Buffer       ds.b 80

IntName      dc.b 'intuition.library',0
             even

***** Window definition *****

nw          dc.w 100,100     Position left,top
            dc.w 200,100     Size width,height
            dc.b 0,1         Colors detail-,block pen
            dc.l $344        IDCMP-Flags
            dc.l $140f       Window flags
            dc.l 0           ^Gadget
            dc.l 0           ^Menu check
title       dc.l 0           ^Window name
nws         dc.l 0           ^Screen structure,
            dc.l 0           ^BitMap
            dc.w 100         MinWidth
            dc.w 40          MinHeight
            dc.w -1          MaxWidth
            dc.w -1          MaxHeight
stype       dc.w 1           Screen type

*** Requester definition ***

Request1      dc.l 0       Older request
              dc.w 0       Left edge
              dc.w 0       Top edge
              dc.w 200     Width
              dc.w 100     Height
              dc.w 0,0     Rel -left,-top
              dc.l Rgadget Gadget
              dc.l 0       Requester border
              dc.l Rtext   Requester text
              dc.w 0       Flags
              dc.b 1,0     Backplane fill pen
              dc.l 0       Requester layer
              dc.l 0       Image bit map
              ds.l 8
              ds.l 1       Points back to window structure
              ds.l 8

Rtext         dc.b 0       Front pen  (blue)
              dc.b 1       Back pen   (white)
              dc.b 0,0     Draw mode
              dc.w 10      Left edge
              dc.w 10      Top edge
              dc.l 0       Text font
Rtxt          ds.l 1       Pointer to text
next1         dc.l 0       Next text

Rgadget       dc.l 0        +0 Next gadget
              dc.w 10       +4 Left edge
              dc.w -50      +6 Top edge
              dc.w 150      +8 Width
              dc.w 14       +A Height
              dc.w 8        +C Flags
              dc.w 1        +E Activation
              dc.w 4        +10 Gadget type
              dc.l 0        +12 Rendered as border or image
              dc.l 0        +16 Select render
              dc.l 0        +1A ^Gadget text
              dc.l 0        +1E Mutual exclude
              dc.l strinfo  +22 Special info
              dc.w 1        +26 Gadget ID
                            ;+28 User data

strinfo       dc.l Buffer  text buffer
              dc.l 0       undo buffer
pos           dc.w 0       cursor position
              dc.w 33      max no of char
              dc.w 0       pos of first char
              dc.w 0,0,0,0,0  intuition variables
              dc.l 0       RastPort of gadget
              dc.l 0       longint value
              dc.l 0       altkeymap
              end

