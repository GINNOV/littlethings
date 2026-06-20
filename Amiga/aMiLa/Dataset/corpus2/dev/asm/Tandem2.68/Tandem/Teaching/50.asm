* 50.asm     TLreqcolor    version 0.01   8.6.99

 include 'Front.i'


; This program demonstrates the use of TLreqcolor to choose a colour/palette


strings: dc.b 0
 dc.b 'You selected  ',0 ;1
 dc.b 'Error: our of memory',0 ;2
 dc.b 'You selected cancel',0 ;3
 ds.w 0


* test program
Program:
 TLwindow #-1              ;set things up
 beq Pr_quit               ;quit if can't

 TLreqcolor #2             ;2=pen+palette+ld/sv
 subq.w #1,d0              ;d0 -> -1 if bad/cancel, or 0+ for pen chosen
 bmi.s Pr_bad2             ;go if bad/cancel

 TLstrbuf #1               ;string 1 to buff
 move.l a4,a0
 add.l #13,a0              ;point to after str 1 in buff
 TLhexasc d0,a0            ;put pen num selected
 clr.b (a0)                ;delimit
 bra.s Pr_rep              ;go report choice

Pr_bad1:                   ;here if TLwindow failes
 TLbad #2                  ;report error in monitor
 bra.s Pr_quit

Pr_bad2:                   ;here if TLreqcolor bad/cancel
 tst.l xxp_errn(a4)
 bne.s Pr_err              ;go if bad
 TLstrbuf #3               ;str 3 to buff
 bra.s Pr_rep              ;go report cancelled

Pr_err:                    ;here if TLreqcolor bad
 TLerror                   ;error report to buff

Pr_rep:                    ;report pen chosen / cancelled / error
 TLreqchoose

Pr_quit:
 rts
