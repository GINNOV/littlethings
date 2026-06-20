* 46.asm    TLbusy  TLunbusy      version 0.0  1.9.97


; tandem.library has 2 routines for the busy pointer:
;
; TLbusy     implements the busy pointer (for this window only)
; TLunbusy   returns to the normal pointer
;
; If you examine the 2.04 method in Tandem.i, you'll see how to change
; the pointer to whaever you like.


 include 'Front.i'


strings: dc.b 0
st_1: dc.b 'Teaching/46.asm',0 ;1
 dc.b 'Click me to make me busy',0 ;1
 dc.b 'Click me to make me un-busy',0 ;2
 dc.b 'Click me to quit',0 ;3
 dc.b 'Busysetup failed - out of mem',0
 dc.b 'Can''t start - out of mem',0 ;5
 dc.b 'Teaching/45.asm',0 ;6

 ds.w 0


* control overall execution
Program:
 TLwindow0                 ;open standard window
 beq Pr_bad                ;bad if can't

 TLstring #2,#10,#5        ;wait for response
 TLkeyboard
 TLbusy                    ;busy pointer

 TLstring #3,#10,#18       ;wait for response
 TLkeyboard
 TLunbusy                  ;restore normal pointer

 TLstring #4,#10,#31       ;wait for final response
 TLkeyboard
 bra.s Pr_done             ;quit ok

Pr_bad:
 TLbad #6                  ;report if TLwindow failed
 rts

Pr_done:
 rts
