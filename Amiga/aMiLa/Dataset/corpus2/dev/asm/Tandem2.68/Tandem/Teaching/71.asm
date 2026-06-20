* 71.asm  TLpassword     version 0.01     8.6.99


 include 'Front.i'


strings: dc.b 0
 dc.b 'Cancelled',0 ;1
 dc.b 'Error: out of memory',0 ;2
 ds.w 0


; TLpassword puts up a little requester to get a password. You can adjust
; its position (with xxp_ReqTop & xxp_ReqLeft) to place itself on a
; window where it's required. This program does not encrypt the input
; internally, so it is a fairly naive sort of routine.


* demonstrate TLPassword
Program:
 TLwindow #-1              ;set up
 beq Pr_quit               ;bad if can't

 TLpassword #6             ;get password (6 characters maximum)
 beq.s Pr_bad2             ;go report if error
 cmp.b #$1B,d0
 bne.s Pr_rept             ;go report password if ok
 TLstrbuf #1
 bra.s Pr_rept             ;go report if cancel

Pr_bad1:                   ;error 1: out of mem (report in monitor)
 TLbad #2
 bra.s Pr_quit

Pr_bad2:                   ;error 2: TLpassword failed - error to buff
 TLerror

Pr_rept:                   ;report password / cancel / error
 TLreqchoose

Pr_quit:
 rts
