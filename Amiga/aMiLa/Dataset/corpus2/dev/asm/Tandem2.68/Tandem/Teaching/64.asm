* 64.asm     TLellipse II    version 0.01    8.6.99


 include 'Front.i'


strings: dc.b 0
st_1: dc.b 'TLEllipse demo',0 ;1
 dc.b 'Error: out of chip memory',0 ;2
 dc.b 'I''m an ellipse!!',0 ;3
 dc.b 'This is version II of TLEllipse (Version I was Teaching/58.asm)',0 ;4
 dc.b 'Version I drew to a rastport, whereas Version II draws direct',0 ;5
 dc.b 'to a window. As this version draws, try resizing the window',0 ;6
 dc.b 'to see it stop and retry until such times as you stop resizing',0
 dc.b 'the window. Then, inspect the program to see how this works -',0 ;8
 dc.b 'TLellipse fails (returns EQ) if the window is resized before it',0 ;9
 dc.b 'finishes. (\9 of TLellipse is null, so uses the popped window)',0

 ds.w 0


* test TLellipse
Program:
 TLwindow #-1              ;set up
 TLreqinfo #4,#7           ;tell user what is happening
 TLwindow #0,#0,#0,#320,#100,#640,#200,#0,#st_1 ;open window 0
 bne.s Pr_cont             ;go if ok
 TLbad #2                  ;report if can't open window
 rts

Pr_cont:
 TLreqcls                  ;n.b. this includes a call to TLWupdate.
 move.l xxp_AcWind(a4),a5  ;a5 = window's xxp_wsuw
 move.l #320,d0
 moveq #100,d1             ;centre 320,100
 move.l d0,d2
 move.l d1,d3              ;radii 320,100
 moveq #0,d4               ;trim at current limit of window display area
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 move.w xxp_PWidth(a5),d6
 subq.w #1,d6
 move.w xxp_PHeight(a5),d7
 subq.w #1,d7

 move.b #2,xxp_FrontPen(a5)
 TLellipse #320,#100,#320,#100,d4,d5,d6,d7,,solid ;draw ellipse

 move.w #$0100,xxp_FrontPen(a5)
 TLstring #3,#260,#85      ;write message

Pr_wait:
 TLwcheck                  ;re-draw if window resized
 bne Pr_cont
 TLwslof

 TLkeyboard                ;wait for response & quit
 rts
