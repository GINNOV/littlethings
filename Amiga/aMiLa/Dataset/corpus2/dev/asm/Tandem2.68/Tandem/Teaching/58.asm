* 58.asm     TLellipse I    version 0.01    8.6.99


 include 'Front.i'


strings: dc.b 0
st_1: dc.b 'For connaisseurs of ellipses!',0 ;1
 dc.b 'Error: out of chip memory',0 ;2
 dc.b 'An unclipped Ellipse        An Ellipse clipped 1 pixel all around',0
 dc.b 'A Hollow Ellipse            2 Hollow Ellipses, clipped 1 pixel, '
 dc.b 'lapped',0 ;4
 dc.b 'A bevelled ellipse...',0 ;5

 ds.w 0


* test program
Program:
 TLwindow #0,#0,#0,#640,#200,#640,#200,#0,#st_1 ;open window 0
 bne.s Pr_cont             ;go if ok
 TLbad #2                  ;report if can't open window
 rts

Pr_cont:
 TLstring #3,#2,#2
 move.l xxp_AcWind(a4),a5
 move.b #2,xxp_FrontPen(a5)
 TLellipse #100,#40,#90,#30,#0,#0,#640,#200,,solid    ;solid, untrimmed
 TLellipse #400,#40,#90,#30,#311,#11,#489,#69,,solid  ;solid, trimmed
 move.b #1,xxp_FrontPen(a5)
 TLstring #4,#2,#80
 move.b #2,xxp_FrontPen(a5)
 TLellipse #100,#120,#90,#30,#0,#0,#640,#200          ;outline, untrimmed
 TLellipse #400,#120,#90,#30,#311,#91,#489,#149       ;} outline, trimmed &
 TLellipse #401,#120,#90,#30,#312,#91,#490,#149       ;}           lapped
 TLkeyboard

 TLreqcls                                        ;do "bevelled" ellipse
 TLstring #5,#2,#2
 TLellipse #316,#90,#150,#75,#167,#16,#465,#164,,solid   ;white
 move.b #1,xxp_FrontPen(a5)
 TLellipse #324,#94,#150,#75,#175,#20,#474,#168,,solid   ;black
 move.b #3,xxp_FrontPen(a5)
 TLellipse #320,#92,#150,#75,#171,#18,#471,#166,,solid   ;blue
 TLkeyboard

 rts
