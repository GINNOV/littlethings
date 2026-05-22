* 36.asm      TLreqinput       version 0.01   8.6.99


 include 'Front.i'         ;*** change to 'Tandem.i' to step thru TL's ***


; TLreqinput puts up a requester to allow the user to type in a number or
; string. The initial form of the string (the "prompt") is put in xxp_buff.
; TLReqinput adjusts the requester size to allow for the operative font.

; The user edits the input box in the usual way. The user can then:
;   press <Return> or click <OK> to return the string as edited in the
;     buffer. Or, left Amiga with V
;   press <Esc> or click <Cancel> to indicate the desire to cancel.
;     Or, left Amiga with B

; The non-typeable keys operate normally, and also:
;   Shift/Del deletes all chrs right of the cursor.
;   Shift/Backspace  deletes all chrs left of the cursor.
;   Ctrl/q  is an "undo" key. It reverses the effect of the previous
;     keystroke (even if it was Ctrl/q).
;   Ctrl/n  is a "new" key. It restores the prompt to whatever it
;     was when the requester first appeared.
;   Ctrl/x  erases all characters.
; If the user clicks the input box, Reqinput places the cursor where
;   it was clicked, if possible.


strings: dc.b 0
st_1: dc.b 'Test TLReqinput',0 ;1
 dc.b 'This is a Reqinput requester',0 ;2
 dc.b 'Edit this string',0 ;3
 dc.b 'You chose to cancel',0 ;4
 dc.b 'Error: the Requester was too big, or out of mem',0 ;5
st_6: dc.b 'Times.font',0 ;6
 dc.b 'Error: can''t load Times/24 font',0 ;7
 dc.b 'Here is some help...',0 ;8
 dc.b 0 ;9
 dc.b '1. Brush your teeth regularly.',0 ;10
 dc.b '2. Have a clean handkerchief.',0 ;11
 dc.b 'Type your input string.',0 ;12
 dc.b 'Then:',0 ;13
 dc.b 'Press <Return> or click "OK"',0 ;14
 dc.b 'Or, press <Esc> or click "Cancel"',0 ;15

 ds.w 0


* program to demonstrate TLreqinput
Program:
 TLwindow #0,#0,#0,#300,#120,#640,#256,#0,#st_1
 beq.s Pr_quit             ;go if can't
 bsr Test                  ;do test of TLReqwindow

Pr_quit:
 rts


* test TLReqinput
Test:
 move.w #12,xxp_Help(a4)   ;help 4 lines from 12
 move.w #4,xxp_Help+2(a4)
 TLgetfont #st_6,#1,#24    ;font #1 = times/24
 TLnewfont #1,#0,#1        ;use font #1, type plain, req windows
 beq Te_bad1               ;go if can't open times/24

 TLstrbuf #3               ;prompt to buffer
 TLreqinput #2,str,#30     ;header=string 2, type string,max 30 chrs
 bne.s Te_ok               ;echo the input if ok
 tst.l xxp_errn(a4)
 beq.s Te_canc
 bra.s Te_bad

Te_ok:
 move.w #8,xxp_Help(a4)    ;ok - update help 4 lines from 8
 move.w #4,xxp_Help+2(a4)
 bra.s Te_rep              ;go report string as edited

Te_bad1:
 moveq #7,d0               ;bad 1: str 7
 bra.s Te_bad

Te_bad2:
 moveq #5,d0               ;bad 2: str 5
 bra.s Te_bad

Te_canc:
 moveq #4,d0               ;canc: str 4

Te_bad:
 TLstrbuf d0               ;put report in buff

Te_rep:
 TLnewfont #0,#0,#1        ;Topaz/8 to req windows
 TLreqchoose               ;report cancel/too big/can't load/ok
 rts
