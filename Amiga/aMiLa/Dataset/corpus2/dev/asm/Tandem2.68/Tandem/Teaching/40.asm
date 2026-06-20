* 40.asm    more TLreqinfo          version 0.01    8.6.99


 include 'Front.i'         ;*** change to 'Tandem.i' to step thru TL's ***


; This is like Teaching/39.asm, but it uses a set of custom buttons.

; If \3=3, then \2 must be 2+. The last string is 1 or more strings for
; button contents, separated by \ characters.


strings: dc.b 0
st_1: dc.b 'Test Reqinfo',0 ;1
 dc.b 'This is the first line of info,',0 ;2
 dc.b 'whereas this is the second line.',0 ;3
 dc.b '.... Finally, the *third* line!!',0 ;4
 dc.b 'Press <Help> for even more info!',0 ;5
 dc.b '1st\2nd\3rd',0 ;6
 dc.b 'Error: The requester won''t fit!!',0 ;7
 dc.b 'Error: Can''t open screen & window - out of chip memory',0 ;8
 dc.b 'Error: Can''t open the ASL font requester',0 ;9
 dc.b 'Error: Can''t load your selected font',0 ;10
 dc.b 'You selected 1st',0 ;11
 dc.b 'You selected 2nd',0 ;12
 dc.b 'You selected 3rd',0 ;13
 dc.b 'Here is some help!!',0 ;14
 dc.b 'The 3 lines of info are presented for',0 ;15
 dc.b 'your delectation. When you''ve done',0 ;16
 dc.b 'enjoying it, click one of the buttons',0 ;17
 dc.b 'at the bottom.',0 ;18
 dc.b 'Eat healthy meals, avoid illegal drugs.',0 ;19

 ds.w 0


* test Reqinfo
Program:                                  ;Note carefully how this program
 TLwindow #0,#0,#0,#200,#100,#640,#300,#0,#st_1 ;gives error reports.
 bne.s Pr_open                            ;If something goes wrong in the
 TLbad #8       ;quit if can't            ;warm-up. This is an important
 rts                                      ;aspect of user friendliness. Also
Pr_open:                                  ;Help is always available
 TLaslfont #1   ;select font 1
 bne.s Pr_ofont ;go if ok
 tst.l xxp_errn(a4)
 beq Pr_redi    ;if font selection cancelled, use default font
 TLbad #9       ;if Asl font request failed, return bad
 bra Pr_quit

Pr_ofont:
 TLnewfont #1,#2,#1 ;put font 1 bold in req
 TLnewfont #1,#0,#2 ;put font 1 plain in help
 bne.s Pr_redi
 TLbad #10      ;bad if can't
 bra.s Pr_quit

Pr_redi:
 bsr Test       ;Test TLReqinfo

Pr_quit:
 rts


* test TLReqinfo
Test:
 move.w #14,xxp_Help(a4)  ;help from line 14
 move.w #5,xxp_Help+2(a4) ;5 lines thereof
 clr.w xxp_ReqNull(a4)    ;first get requester dimensions
 TLreqinfo #2,#4,#3
 bne.s Te_ok
 TLbad #7                 ;bad if requester won't fit
 rts

Te_ok:
 move.l xxp_AcWind(a4),a5 ;a5=WSuite of window
 move.l xxp_Width(a4),d0  ;center the requester on screen
 sub.l xxp_reqw(a4),d0
 lsr.w #1,d0
 move.w d0,xxp_ReqLeft(a5)
 move.l xxp_Height(a4),d0
 sub.l xxp_reqh(a4),d0
 lsr.w #1,d0
 move.w d0,xxp_ReqTop(a5)
 TLreqinfo #2,#5,#3        ;now, put up requester for real
 add.w #10,d0              ;choice becomes 11/12/13
 move.w #19,xxp_Help(a4)   ;update help
 move.w #1,xxp_Help+2(a4)
 TLreqinfo d0              ;report choice (default /2,/3=#1,#1)
 rts

