* 54.asm  TLprogress     version 0.01     8.6.99


 include 'Front.i'


prog: ds.l 1                ;keeps progress


strings: dc.b 0
st_1: dc.b 'TLProgress demonstration',0 ;1
 dc.b 'Error: out of chip memory',0 ;2
 dc.b 'Wait until I''m full',0 ;3
 dc.b 'Click to clear      ',0 ;4
 dc.b 'Click to quit       ',0 ;5

 ds.w 0


* demonstrate TLprogress
Program:
 TLwindow #0,#0,#0,#100,#100,#500,#200,#0,#st_1
 beq Pr_bad

 TLstring #3,#2,#1          ;print 'wait until full'

 move.l #10,xxp_prgd+4(a4)  ;thermometer ypos   (xpos set at Pr_wait+1,3)
 move.l #100,xxp_prgd+8(a4) ;            width
 move.l #10,xxp_prgd+12(a4) ;            height

 clr.l prog

Pr_wait:                    ;report progress
 move.l #20,xxp_prgd(a4)
 TLprogress prog,#50        ;draw thermometer without text

 move.l #130,xxp_prgd(a4)
 TLprogress prog,#50,txt    ;draw thermometer with text

 move.l #240,xxp_prgd(a4)
 TLprogress prog,#50,%      ;draw thermometer with %

 TLbusy

 moveq #4,d7                ;d7 = delay factor (make d7 bigger for slower)
 move.l xxp_gfxb(a4),a6
Pr_paus:
 jsr _LVOWaitTOF(a6)
 dbra d7,Pr_paus

 addq.l #1,prog             ;bump total while prog < 51
 cmpi.l #51,prog
 bne Pr_wait

 TLunbusy

 TLstring #4,#2,#1          ;wait for acknowledge & quit ok
 TLkeyboard
 bra.s Pr_quit

Pr_bad:                     ;here if out of mem
 TLbad #2

Pr_quit:
 rts
