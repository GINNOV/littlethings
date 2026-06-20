* 55.asm  TLdata     version 0.01     8.6.99


 include 'Front.i'


strings: dc.b 0
 dc.b '     I''m a TLdata demonstration...',0 ;1
 dc.b 'I will wait on the screen for a few seconds.',0 ;2
 dc.b 'Then, I''ll disappear. So, parden me a few',0 ;3
 dc.b 'seconds while I contemplate the relationship',0 ;4
 dc.b 'between mind and matter.',0 ;5
 dc.b 'Error: out of memory',0 ;6

 ds.w 0

* demonstrate TLdata
Program:
 TLwindow #-1              ;set things up
 beq Pr_bad

 TLdata #2,#4              ;draw data window

 move.l xxp_dosb(a4),a6    ;delay 7 seconds
 move.l #7*50,d1
 jsr _LVODelay(a6)

 TLreqoff                  ;remove data window
 bra.s Pr_quit             ;quit ok

Pr_bad:                    ;here if out of mem
 TLbad #6

Pr_quit:
 rts
