* 57.asm     TLResize     version 0.01    8.6.99


 include 'Front.i'


strings: dc.b 0
st_1: dc.b 'TLResize demo',0 ;1
 dc.b 'Error: Out of chip memory',0 ;2
 dc.b 'Hello, world',0 ;3
 dc.b 'TLresize demo...',0 ;4
 dc.b ' ',0 ;5
 dc.b 'I am about to use TLresize to resize 2 of the 3 strings',0 ;6
 dc.b 'on the window.',0 ;7
 dc.b 'TLresize demo...',0 ;8
 dc.b ' ',0 ;9
 dc.b 'As you can see, the strings are now resized.',0 ;10
 dc.b '<- Narrower, taller',0 ;11
 dc.b '<- wider, shorter',0 ;12

 ds.w 0


* test program
Program:
 TLwindow #0,#0,#0,#640,#200,#640,#200,#0,#st_1 ;open window 0
 bne.s Pr_cont             ;go if ok
 TLbad #2                  ;report if can't open window
 rts

Pr_cont:
 TLstring #3,#0,#0         ;normal size at 0,0
 TLstring #3,#0,#12        ;again at 0,12 - will be resized
 TLstring #3,#0,#24        ;again at 0,24 - will be resized

 move.l xxp_AcWind(a4),a5  ;reposition requesters so they don't hide strings
 move.w #70,xxp_ReqTop(a5)
 TLreqinfo #4,#4           ;threaten to resize the strings

 TLresize #0,#12,#96,#8,#48,#12   ;resize the 2nd string
 TLresize #0,#24,#96,#8,#192,#6   ;resize the 3rd string

 TLstring #11,#220,#12
 TLstring #12,#220,#24
 TLreqinfo #8,#3           ;confess
 rts
