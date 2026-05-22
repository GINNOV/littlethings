* 35.asm   TLReqchoose        version 0.01   8.6.99


 include 'Front.i'        ;*** change to Tandem.i to step thru TL's ***


; TLReqchoose puts up a requester to allow the user to select from
; several choices. The idea is to put a series of strings: a header,
; and at least 1 choice, in strings, and set D0 to the no. of the 1st
; string, and then let D1 be the number of choices. The requester is
; adjusted to accommodate the operative font size.

; The user chooses by clicking a button, or pressing the function key
; on the button. Note also that the user can press Help, as I set up
; help in xxp_Help. This can be cleared when finished with.

; All tandem.library requesters have built-in help, but you can over-ride
; that by using xxp_Help, as above. You can also arrange fo a "Guide"
; button that opens a specified Amiga.guide at a specified node if clicked.

; Alternately in TLReqchoose you can set D1 to 0, when D0 is ignored, and
; the requester simply asks the user to acknowledge whatever is in buffer.
; Both types are demonstrated below. (In the MACRO, simply omit parameters).

; The user chooses by clicking a button, or pressing a function key. The
; choice (1+) is returned in D0. If Reqchoose fails (because the requester
; is too big) then it returns D0=0.

; You cannot call TLKeyboard or the TL routines that use windows or fonts,
; unless you first call TLWindow (or TLReqchoose/Info/input - not show).
; That is, everything gets initialised by opening a window. The requesters
; are in fact windows, so they initialise things is called.


strings: dc.b 0
st_1: dc.b 'Demonstrate TLreqchoose',0 ;1
 dc.b 'Choose from these buttons:',0 ;2
 dc.b 'This is a button!',0 ;3
 dc.b 'And this is another!',0 ;4
 dc.b 'And yet a third!',0 ;5
 dc.b '(A last choice)',0 ;6
st_7: dc.b 'Times.font',0 ;7
 dc.b 'You chose '
st_8: dc.b '.',0 ;8
 dc.b 'Error - requester won''t fit or out of memory',0 ;9
 dc.b 'Error: Can''t load Times/24 font',0 ;10
 dc.b 'Here is some help:',0 ;11
 dc.b 'Click one of the boxes to choose',0 ;12
 dc.b 'Or, press the Function key in the box',0 ;13

 ds.w 0

* program to test TLReqchoose
Program:
 TLwindow0                 ;open a window
 beq.s Pr_quit             ;go if can't
 bsr Test                  ;do test of Reqchoose
 TLwclose                  ;close window & screen

Pr_quit:
 rts


* test Reqchoose
Test:
 move.w #12,xxp_Help(a4)   ;set up help - 2 lines from string 12
 move.w #2,xxp_Help+2(a4)
 TLgetfont #st_7,#1,#24    ;put times/24 in font #1
 TLnewfont #1,#1,#1        ;font=1 1=Bold 1=req window
 beq Te_bad1               ;go if can't load Times/24
 TLreqchoose #2,#4         ;header=string 2, 4 choices
 beq Te_bad2               ;go if ok
 clr.l xxp_Help(a4)        ;clear help (now obsolete)
 add.b #'0',d0             ;poke choice (in ASCII) into string 8
 move.b d0,st_8
 moveq #8,d0               ;string 8 if ok
 bra.s Te_rep

Te_bad1:
 moveq #10,d0              ;string 10 if can't load font
 bra.s Te_rep

Te_bad2:
 moveq #9,d0               ;string 9 if font won't fit / out of mem

Te_rep:
 TLstrbuf d0               ;string (8-10) to buffer
 TLreqchoose #0,#0         ;put up requester to acknowledge buffer contents
 rts
