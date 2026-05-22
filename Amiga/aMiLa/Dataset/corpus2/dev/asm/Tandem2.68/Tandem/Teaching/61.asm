* 61.asm  TLReqfont     version 0.01     8.6.99


 include 'Front.i'


strings: dc.b 0
st_1: dc.b 'Demonstrate TLReqfont',0 ;1
 dc.b 'You chose /',0 ;2
 dc.b 'You chose cancel',0 ;3
st_4: dc.b 'Times.font',0 ;4

 ds.w 0


* demonstrate TLReqfont
Program:
 TLwindow #0,#0,#0,#380,#120,#640,#256,#-1,#st_1 ;open window 0
 beq Pr_bad
 TLgetfont #st_4,#1,#24

 TLreqfont #0            ;show TLreqfont
 beq.s Pr_bad             ;go if error
 move.w d0,d1
 bmi.s Pr_canc            ;go if cancel
 TLstrbuf #2
 add.b d1,10(a4)
 TLreqchoose              ;report choice
 bra.s Pr_quit

Pr_canc:                  ;report cancelled
 TLreqinfo #3,#1
 bra.s Pr_quit

Pr_bad:                   ;report error
 TLerror
 TLreqchoose

Pr_quit:
 rts
