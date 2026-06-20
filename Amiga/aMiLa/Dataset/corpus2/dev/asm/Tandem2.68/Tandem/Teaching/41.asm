* 41.asm     TLreqshow     version 0.01    8.6.99


 include 'Front.i'         ;*** change to 'Tandem.i' to step thru TL's ***


; This program demonstrates the use of TLreqshow, which allows the user to
; view a series of lines, while your program calculates their contents
; dynamically. It takes some programming skill to get the most from
; TLreqshow.


strings: dc.b 0
 dc.b 'Some strings for your delectation (n.b. press <Help> for info)',0 ;1
 dc.b 'String  ....',0 ;2
 dc.b 'You have seen a TLReqshow requester (sigh!)',0 ;3
 dc.b '(press <Help> for more help!)',0 ;4
 dc.b 'Alas! This wonderful TLReqshow demo is finished!',0 ;5
 dc.b '(Wasn''t it great!!! Applause! Applause!)',0 ;6

 ds.w 0


clikd: ds.l 1 ;line selected


* test program
Program:
 TLwindow #-1
 move.l #-1,clikd                ;flag no line is yet clicked
 TLreqshow #Hook,#1,#100,#17,#40,seek
 beq.s Pr_quit                   ;go if TLreqshow fails
 move.w #5,xxp_Help(a4)          ;help from line 5, 2 lines
 move.w #2,xxp_Help+2(a4)
 TLreqinfo #3,#2                 ;final message

Pr_quit:
 rts


* Act as hook for TLReqshow
Hook:
 tst.l d0             ;go if line clicked
 bmi.s Ho_clkd
 bsr Make             ;synthesize line d0, point a0 to it
 rts

Ho_clkd:
 cmp.l clikd,d0       ;line already highlighted?
 bne.s Ho_on          ;no, go
 move.l #-1,clikd
 moveq #1,d0          ;highlighting off
 rts

Ho_on:
 move.l d0,clikd      ;remember which line is being highlighted
 moveq #2,d0          ;turn highlighting on
 rts


* synthesize line d0
Make:
 TLstrbuf #2          ;string 2 to buffer
 move.l a4,a0
 addq.l #8,a0
 move.l #'    ',(a0)  ;blank num
 TLhexasc d0,a0       ;put num
 clr.b (a0)
 move.l a4,a0         ;point a0 to string as synthesized
 rts
