* 47.asm    Set colours       version 0.00     1.9.97


 include 'Front.i'


; This program shows you how to change the colours of a screen.
; There is a requester (TLReqcolor - see 50.asm) which faciltiates
; choice of colours by the user.


strings: dc.b 0
st_1: dc.b 'Window 0',0 ;1
 dc.b 12,'Out of mem',0 ;2
 ds.w 0

table:
 dc.w 4                    ;no. of colours
 dc.w 0                    ;colours 0-3
 dc.l -1,0,0               ;colour 0               These are rather garish!
 dc.l 0,-1,0               ;colour 1
 dc.l 0,0,-1               ;colour 2
 dc.l $7FFFFFFF,$7FFFFFFF,$7FFFFFFF ;colour 3
 dc.l 0                    ;delimiter

Program:
 TLwindow0
 beq.s Pr_quit

 move.l xxp_gfxb(a4),a6
 move.l xxp_Screen(a4),a0
 add.l #sc_ViewPort,a0
 lea table,a1
 jsr _LVOLoadRGB32(a6)
 TLkeyboard
 rts

Pr_quit:
 TLbad #2
 rts
