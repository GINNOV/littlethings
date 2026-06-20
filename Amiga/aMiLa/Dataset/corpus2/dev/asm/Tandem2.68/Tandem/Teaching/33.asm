* 33.asm    Demonstrate TLtsize        version 0.01  8.6.99


 include 'Front.i'        ;*** change to 'Tandem.i to step thru TL's ***


; This program introduces TLTsize, which gets text size without actually
; printing it. This is useful for making your programs font sensitive.
; The program below allows for the window to be resized. This will be
; covered in a more rigorous fashion in later examples.


strings: dc.b 0
st_1: dc.b 'Test TLTsize',0 ;1
 dc.b 'This text is to appear at the bottom right',0 ;2
 dc.b 'This text is to be spread out',0 ;3
 dc.b '(Click the close window gadget)',0 ;4

 ds.w 0


* sample program
Program:
 TLwindow #0,#0,#0,#400,#150,#640,#200,#0,#st_1
 beq.s Pr_quit
 bsr Test                  ;do test of TLtsize,&c
Pr_quit:
 rts

* test TLTsize
Test:
 move.l xxp_AcWind(a4),a5  ;a5 = the currently popped window
 move.w #$0100,xxp_FrontPen(a5) ;pens 1,0

 TLreqcls                  ;clear window, call TLwupdate

 TLstrbuf #2               ;string 2 to buff
 TLtsize                   ;get string size

 moveq #0,d2               ;calculate rightmost posn printable
 move.w xxp_PWidth(a5),d2  ;(use D2 since TLwcheck changes D0)
 sub.l d4,d2               ;D2=rightmost printable
 moveq #0,d1               ;calculate botmost posn printable
 move.w xxp_PHeight(a5),d1
 sub.w d6,d1               ;D1=botmost posn printable

 TLtrim d2,d1              ;print the text at the bot right
 move.w #8,xxp_Tspc(a5)    ;set inter-chr spc to 8 (normally 0)
 TLstring #3,#10,#19       ;print string 3 at 10,19 (spread out)
 clr.w xxp_Tspc(a5)        ;inter-chr spc back to 0
 move.b #2,xxp_FrontPen(a5) ;colour 2 to highlight string 4
 TLstring #4,#4,#29        ;print string 4 at 4,29 (not spread out)

Te_wait:
 TLwcheck                  ;go redraw if window resized
 bne Test
 TLkeyboard                ;wait for close gadget
 cmp.w #$93,d0
 bne Te_wait
 rts
