* 39.asm          TLreqinfo     version 0.01    8.6.99


 include 'Front.i'         ;*** change to 'Tandem.i' to step thru TL's ***


; This program tests the next of the requesters created by tandem.library,
; the TLreqinfo requester. This creates an information box, with an
; OK box, and an optional Cancel box, or a designer set of boxes. To
; use the TLreqinfo MACRO:
;
;  \1 = stringnum of header, followed by other strings for display
;  \2 = no. of strings to be displayed (1+)
;  \3 = 1:ok button 2:ok/canc buttons 3:designer boxes
;
; TLreqinfo returns choice in D0 (1+), or D0=0 if bad
;
; If \3=3, then \2 must be 2+. The last string is 1 or more strings for
; button contents, separated by \ characters.


strings: dc.b 0
st_1: dc.b 'Demonstrate TLreqinfo',0 ;1
 dc.b 'This is the first line of info,',0 ;2
 dc.b 'whereas this is the second line.',0 ;3
 dc.b 'Finally, the third line.',0 ;4
 dc.b 'You selected OK',0 ;5
 dc.b 'You selected Cancel',0 ;6
 dc.b 'Error: The requester won''t fit!!',0 ;7
 dc.b 'Error: Can''t open screen & window - out of chip memory',0 ;8
 dc.b 'Error: Can''t open the ASL font requester',0 ;9
 dc.b 'Error: Can''t load your selected font',0 ;10

 ds.w 0

* deomonstrate TLreqinfo
Program:                                  ;Note carefully how this program
 TLwindow0                                ;gives error reports to the
 bne.s Pr_open                            ;user if something goes wrong in
 TLbad #8       ;quit if can't            ;the warm-up. This is an important
 rts                                      ;aspect of user friendliness.

Pr_open:
 TLaslfont #1              ;select font 1
 bne.s Pr_ofont            ;go if ok
 tst.l xxp_errn(a4)
 beq Pr_redi               ;if font selection cancelled, use default font
 TLbad #9                  ;if Asl font request failed, return bad
 bra.s Pr_quit

Pr_ofont:
 TLnewfont #1,#0,#1        ;put font 1, plain in req font
 bne.s Pr_redi
 TLbad #10                 ;bad if can't
 bra.s Pr_quit

Pr_redi:
 bsr Test                  ;Test TLReqinfo

Pr_quit:
 TLwclose                  ;close screen, window & return
 rts

* test TLreqinfo
Test:
 clr.w xxp_ReqNull(a4)     ;first get requester dimensions
 TLreqinfo #2,#3,#2
 bne.s Te_ok
 TLbad #7                  ;bad if requester won't fit
 rts

Te_ok:
 move.l xxp_AcWind(a4),a5  ;a5 points to WSuite for window
 move.w xxp_PWidth(a5),d0  ;center the requester horizontally in window
 sub.w xxp_reqw+2(a4),d0
 bmi.s Te_vert             ;go if too wide
 lsr.w #1,d0
 move.w d0,xxp_ReqLeft(a5)

Te_vert:
 move.w xxp_PHeight(a5),d0 ;center the requester viertically in window
 sub.w xxp_reqh+2(a4),d0
 bmi.s Te_redi             ;go if too high
 lsr.w #1,d0
 move.w d0,xxp_ReqTop(a5)

Te_redi:
 TLreqinfo #2,#3,#2        ;now, put up requester for real
 addq.w #4,d0              ;choice becomes 5/6
 TLreqinfo d0              ;report choice (default /2,/3=#1,#1)
 rts
