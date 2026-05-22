
***********************
*
* Send up a requester and wait until clicked
*
* === not reentrant, not multitasking simultaneous usable ===
*
* This implementation was written by:
* E. Lenz
* Johann-Fichte-Strasse 11
* 8 Munich 40
* Germany
*
***********************

; INPUT
;
; a0 = pointer to requester text 1st line
; a1 = pointer to requester text 2nd line (0 = no 2nd or 3rd line)
; a2 = pointer to requester text 3rd line (0 = no 3rd line)
; a3 = pointer to requester header
; a4 = pointer to gadget 1 text
; a5 = pointer to gadget 2 text (0 = no gadget 2)
; d0 = pointer to screen
; d1 = type of screen

; INTERNAL
;
; d5 = Error flag
; a4 = IntuitionBase
; a5 = Window

; OUTPUT
;
; d0 = the number of the selected gadget
; 0 = error occured  1 = 1st gadget selected  2 = 2nd gadget selected

       XDEF request

; EXEC.library routines

_AbsExecBase       equ 4
_LVOWait           equ -$13e
_LVOGetMsg         equ -$174
_LVOReplyMsg       equ -$17a
_LVOWaitPort       equ -$180
_LVOCloseLibrary   equ -$19e
_LVOOpenLibrary    equ -$228

; INTUITION.library routines

_LVOCloseWindow    equ -$48
_LVOEndRequest     equ -$78
_LVOOpenWindow     equ -$cc
_LVORequest        equ -$f0
_LVOWindowToFront  equ -$138

wd_UserPort equ $56

request      move.l  d0,Wscreen
             move.w  d1,Stype
             move.l  a0,Rtxt    set texts
             move.l  a1,d0
             lea     R2text(pc),a0
             move.l  d0,R2txt
             bne.s   is2
             movea.l d0,a0
is2          move.l  a0,next1
             move.l  a2,d0
             lea     R3text(pc),a0
             move.l  d0,R3txt
             bne.s   is3
             movea.l d0,a0
is3          move.l  a0,next2
             move.l  a3,Wdname  set header
             move.l  a4,Gag1
             move.l  a5,d0
             lea     Rgadg2(pc),a0
             move.l  d0,Gag2
             bne.s   endhead
             movea.l d0,a0
endhead      move.l  a0,Rgadget

             suba.l  a5,a5
             movea.l _AbsExecBase,a6
             lea     IntuitionName(pc),a1 Open intuition.library
             moveq   #0,d0
             jsr     _LVOOpenLibrary(a6)
             movea.l d0,a4            Save intuition base address
             tst.l   d0
             beq.s   gexit

; Open window

             movea.l d0,a6         Base address = IntuitionBase
             lea     NewWindow(pc),a0
             jsr     _LVOOpenWindow(a6)
             movea.l d0,a5         Save pointer to window structure
             tst.l   d0
gexit        beq.s   exit

             lea     Request1(pc),a0   Send up requester
             movea.l a5,a1
             jsr     _LVORequest(a6)

             movea.l _AbsExecBase,a6

Reqwait      movea.l a5,a0
             jsr     _LVOWindowToFront(a6)

             movea.l a5,a0
             movea.l wd_UserPort(a0),a0  Load Window.UserPort
             move.b  $f(a0),d1           Load signal bit
             moveq   #1,d0
             lsl.l   d1,d0
             jsr     _LVOWait(a6)

             movea.l a5,a0
             movea.l wd_UserPort(a0),a0  Reload Window.UserPort
             jsr     _LVOGetMsg(a6)
             tst.l   d0
             beq.s   Reqwait       No message

             movea.l d0,a1
             move.l  $14(a1),d7       Message in a7
             jsr     _LVOReplyMsg(a6) Always reply

             movea.l a4,a6

             lea     Request1(pc),a0
             movea.l a5,a1
             jsr     _LVOEndRequest(a6)

             movea.l a5,a0            get gadget id
             movea.l $5e(a0),a0
             movea.l $1c(a0),a0
             move.w  $26(a0),d5

exit         move.l  a5,d0              Close window
             beq.s   No_Wind
             movea.l d0,a0
             jsr     _LVOCloseWindow(a6)


;Close library

No_Wind      movea.l _AbsExecBase,a6
             move.l  a4,d0            Close intuition lib
             beq.s   No_Intui
             movea.l d0,a1
             jsr     _LVOCloseLibrary(a6)

No_Intui     moveq   #0,d0
             move.w  d5,d0
             rts

IntuitionName dc.b 'intuition.library',0
              even

***** Window definition *****

NewWindow     dc.w 0,0           Position left,top
              dc.w 319,72        Size width,height
              dc.b 0,1           Colors detail-,block pen
              dc.l $40           IDCMP-Flags
              dc.l $1407         Window flags
              dc.l 0             ^Gadget
              dc.l 0             ^Menu check
Wdname        dc.l 0             ^Window name
Wscreen       dc.l 0             ^Screen structure,
              dc.l 0             ^BitMap
              dc.w 88            MinWidth
              dc.w 24            MinHeight
              dc.w 319           MaxWidth
              dc.w 72            MaxHeight
Stype         dc.w 1             Screen type


*** Requester definition ***

Request1      dc.l 0       Older request
              dc.w 0       Left edge
              dc.w 0       Top edge
              dc.w 303     Width
              dc.w 60      Height
              dc.w 0,0     Rel -left,-top
              dc.l Rgadget Gadget
              dc.l Rborder Requester border
              dc.l Rtext   Requester text
              dc.w 0       Flags
              dc.b 1,0     Backplane fill pen
              dc.l 0       Requester layer
              dc.l 0       Image bit map
              ds.l 8
              ds.l 1       Points back to window structure
              ds.l 8

Rborder       dc.w 0       Left edge
              dc.w 0       Top edge
              dc.b 0,2     Front pen,back pen
              dc.b 1,5     Draw mode,number of coord pairs
              dc.l RPairs  Vector coordinate pairs
              dc.l 0       Next border

RPairs        dc.w 2,1     Lines surrounding the requester
              dc.w 293,1
              dc.w 293,57
              dc.w 2,57
              dc.w 2,1

Rtext         dc.b 0       Front pen  (blue)
              dc.b 1       Back pen   (white)
              dc.b 0,0     Draw mode
              dc.w 10      Left edge
              dc.w 10      Top edge
              dc.l 0       Text font
Rtxt          ds.l 1       Pointer to text
next1         dc.l 0       Next text

R2text        dc.b 0       Front pen  (blue)
              dc.b 1       Back pen   (white)
              dc.b 0,0     Draw mode
              dc.w 10      Left edge
              dc.w 20      Top edge
              dc.l 0       Text font
R2txt         ds.l 1       Pointer to text
next2         dc.l 0       Next text

R3text        dc.b 0       Front pen  (blue)
              dc.b 1       Back pen   (white)
              dc.b 0,0     Draw mode
              dc.w 10      Left edge
              dc.w 30      Top edge
              dc.l 0       Text font
R3txt         dc.l 0       Pointer to text
              dc.l 0       Next text

Rgadget       dc.l 0        +0 Next gadget
              dc.w 10       +4 Left edge
              dc.w -20      +6 Top edge
              dc.w 50       +8 Width
              dc.w 14       +A Height
              dc.w 8        +C Flags
              dc.w 1        +E Activation
              dc.w 1        +10 Gadget type
              dc.l Rbord1   +12 Rendered as border or image
              dc.l 0        +16 Select render
              dc.l Gag1txt  +1A ^Gadget text
              dc.l 0        +1E Mutual exclude
              dc.l 0        +22 Special info
              dc.w 1        +26 Gadget ID
                           ;+28 User data

Rbord1        dc.w 0       Left edge
              dc.w 0       Top edge
              dc.b 3,0     Front pen,back pen
              dc.b 1,5     Draw mode,number of coord pairs
              dc.l RPairs1 Vector coordinate pairs
              dc.l Rbord2  Next border

RPairs1       dc.w 0,0     Lines which constitute the gadget
              dc.w 50,0
              dc.w 50,14
              dc.w 0,14
              dc.w 0,0

Rbord2        dc.w 0,0
              dc.b 0,0
              dc.b 1,5
              dc.l RPairs2
              dc.l 0

RPairs2       dc.w 2,2
              dc.w 48,2
              dc.w 48,12
              dc.w 2,12
              dc.w 2,2

Gag1txt       dc.b 0       Front pen  (blue)
              dc.b 1       Back pen   (white)
              dc.b 1,0     Draw mode
              dc.w 8       Left edge
              dc.w 4       Top edge
              dc.l 0       Text font
Gag1          dc.l 0       Pointer to text
              dc.l 0       Next text


Rgadg2        dc.l 0        +0 Next gadget
              dc.w -68      +4 Left edge
              dc.w -20      +6 Top edge
              dc.w 50       +8 Width
              dc.w 14       +A Height
              dc.w $18      +C Flags
              dc.w 1        +E Activation
              dc.w 1        +10 Gadget type
              dc.l Rbord21  +12 Rendered as border or image
              dc.l 0        +16 Select render
              dc.l Gag2txt  +1A ^Gadget text
              dc.l 0        +1E Mutual exclude
              dc.l 0        +22 Special info
              dc.w 2        +26 Gadget ID
                           ;+28 User data

Rbord21       dc.w 0       Left edge
              dc.w 0       Top edge
              dc.b 3,0     Front pen,back pen
              dc.b 1,5     Draw mode,number of coord pairs
              dc.l RPair21 Vector coordinate pairs
              dc.l Rbord22 Next border

RPair21       dc.w 0,0     Lines which constitute the gadget
              dc.w 50,0
              dc.w 50,14
              dc.w 0,14
              dc.w 0,0

Rbord22       dc.w 0,0
              dc.b 0,0
              dc.b 1,5
              dc.l RPair22
              dc.l 0

RPair22       dc.w 2,2
              dc.w 48,2
              dc.w 48,12
              dc.w 2,12
              dc.w 2,2

Gag2txt       dc.b 0       Front pen  (blue)
              dc.b 1       Back pen   (white)
              dc.b 1,0     Draw mode
              dc.w 8       Left edge
              dc.w 4       Top edge
              dc.l 0       Text font
Gag2          dc.l 0       Pointer to text
              dc.l 0       Next text

              end
