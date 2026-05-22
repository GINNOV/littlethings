* Teaching/51.asm      Requester hooks      0.01   8.6.99


; This program shows you how to use xxp_hook0,xxp_hook1 and xxp_hook2 to
; modify the appearance of requesters. This program puts a picture
; at the right of an otherwise minimal TLreqchoose requester.


 include 'Front.i'


strings: dc.b 0
 ds.w 0


* entry point
Program:
 TLwindow #-1              ;intialise everything (hooks get zapped)
 beq.s Pr_quit
 move.l #Hook0,xxp_hook0(a4) ;attach hook0
 move.l #Hook1,xxp_hook1(a4) ;attach hook1
 move.l #'OK! ',(a4)       ;text for requester
 clr.b 4(a4)
 TLreqchoose               ;put up minimal reqchoose requester

Pr_quit:
 rts


* make requester wider
Hook0:
 add.l #100,xxp_reqw(a4)   ;make requester 100 dots wider before drawing
 rts


* put bev on requester
Hook1:
 move.l xxp_reqw(a4),d0    ;draw a bev box at the rhs of the window
 sub.w #80,d0
 moveq #60,d2
 moveq #4,d1
 move.l xxp_reqh(a4),d3
 subq.l #8,d3
 TLreqbev d0,d1,d2,d3,rec

 add.w #26,d0              ;draw a tick in the bev
 subq.w #8,d3
 lsr.w #1,d3
 add.w d3,d1
 move.l d1,d2
 move.l d0,d1
 TLpict #10,d1,d2
 rts
