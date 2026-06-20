* 56.asm     TLreqshow with smart search    version 0.01    8.6.99


 include 'Front.i'


; This program demonstrates the use of TLReqshow, which allows the user to
; view a series of lines, while your program calculates their contents
; dynamically. It includes a smart search. Sometimes, as here, the calling
; program knows how to find strings quickly, which saves TLReqshow from
; looking through the strings one by one, a slow process if there are many
; strings. In such cases, use smart search.

; TLreqshow is a powerful requester, and though writing a hook is admittedly
; rather difficult, they can save you a lot of work. See, for example, the
; TLreqshow that comes up in TLMultiline when you request "Print" from the
; menu. TLreqshow there saves a lot of coding.


strings: dc.b 0
 dc.b 'Some strings for your delectation (n.b. press <Help> for info)',0 ;1
st_2: dc.b 'String   ',0 ;2
 dc.b 'You have seen a TLReqshow requester (sigh!)',0 ;3
 dc.b '(press <Help> for more help!)',0 ;4
 dc.b 'Alas! This wonderful TLReqshow demo is finished!',0 ;5
 dc.b '(Wasn''t it great!!! Applause! Applause!)',0 ;6
 dc.b 'This program (i.e. 56.asm) will put up a TLreqshow requester.',0 ;7
 dc.b ' ',0 ;8
 dc.b '56.asm is programmed to do "smart search". So when you press',0 ;9
 dc.b 'any of the "Seek" buttons on the TLReqshow, the search will be',0 ;10
 dc.b 'very fast.',0 ;11
 dc.b 'Error: out of mem',0 ;12

 ds.w 0

clikd: ds.l 1 ;line selected
maxi: ds.w 1  ;no. of lines

* test program
Program:
 TLwindow #-1              ;set things up
 beq Pr_bad1

 TLreqinfo #7,#5           ;preliminary info

 move.l #100000,maxi       ;set number of lines
 move.l #-1,clikd          ;flag no line is yet clicked
 TLreqshow #Hook,#1,maxi,#17,#0,smart
 beq.s Pr_bad2             ;go if TLreqshow fails

 move.w #5,xxp_Help(a4)    ;attach help
 move.w #2,xxp_Help+2(a4)
 TLreqinfo #3,#2           ;final message
 bra.s Pr_quit

Pr_bad1:                   ;here if TLwindow failed
 TLbad #12                 ;report to CLI
 bra.s Pr_quit

Pr_bad2:                   ;here if TLreqshow failed
 TLerror                   ;report cause of error
 TLreqchoose

Pr_quit:
 rts


* Act as hook for TLReqshow
Hook:
 tst.l d0                  ;go if line clicked
 bmi.s Ho_clkd
 bsr Make                  ;synthesize line d0, point a0 to it
 rts
Ho_clkd:
 btst #30,d0               ;go if smart search
 bne.s Ho_smrt
 cmp.l clikd,d0            ;line already highlighted?
 bne.s Ho_on               ;no, go
 move.l #-1,clikd
 moveq #1,d0               ;highlighting off
 rts
Ho_on:
 move.l d0,clikd           ;remember which line is being highlighted
 moveq #2,d0               ;turn highlighting on
 rts
Ho_smrt:
 and.l #$3FFFFFFF,d0       ;d0 = start from, d1 = 3/4/5 = fore/back/left
 bsr Smart                 ;do a smart search
 rts


* synthesize line d0
Make:
 TLstrbuf #2               ;string 2 to buffer
 move.l a4,a0
 addq.l #8,a0
 move.l #'    ',(a0)       ;blank num
 TLhexasc d0,a0            ;put num
 clr.b (a0)
 move.l a4,a0              ;point a0 to string as synthesized
 rts


* do a smart search   D0 = start from,  D1 = 3/4/5 = fore/back/left
Smart:
 move.l d0,d2              ;cache d0 in d2
 move.l a4,a0              ;point a5 to sought
 add.w #xxp_patt,a0
 move.b (a0),d3            ;d3 is the first chr of sought
 beq.s Sm_1                ;(match anything if null string - can't happen?)
 lea st_2,a1
Sm_st2:                    ;see if 1st chr in st_2
 tst.b (a1)
 beq.s Sm_num              ;no, assume all numbers
 cmp.b (a1)+,d3
 bne Sm_st2
 subq.l #1,a1              ;a1 is 1st chr of st_2 that matches sought
 cmp.b #' ',d3
 bne.s Sm_cmp              ;go if not blank
 cmp.b #' ',1(a0)
 beq.s Sm_cmp              ;ok if 2nd chr of sought also blank
 addq.l #1,a1              ;else, match w. 2nd blank of st_2
Sm_cmp:
 cmpm.b (a0)+,(a1)+        ;match each chr of sought w. st_2
 bne.s Sm_no               ;no if mismatch
 tst.b (a0)
 beq.s Sm_1                ;always matches if all match w. st_2
 cmp.b #'0',(a0)
 bcs Sm_cmp                ;stop matching with st_2 if 0-9 found
 cmp.b #'9'+1,(a0)
 bcc Sm_cmp
Sm_num:                    ;seek value of number at a0
 TLaschex a0               ;d0 = value
 tst.b (a0)                ;did all chrs get bypassed?
 bne.s Sm_no               ;no, garbage after number
 cmp.w #4,d1
 bcs.s Sm_fore             ;go if forward
 bne.s Sm_maxi             ;go if left
 cmp.l d2,d0
 bcc.s Sm_no               ;backward: no if d0 not backward
Sm_yes:
 rts
Sm_fore:
 cmp.l d0,d2               ;forward: no if d0 not forward
 bcc.s Sm_no
Sm_maxi:
 cmp.l maxi,d0             ;forward: no if d0 out of range
 bcs Sm_yes
Sm_no:
 moveq #-1,d0              ;d0 = -1 if unfound
 rts
Sm_1:                      ;here if always matches
 moveq #0,d0
 cmp.w #5,d1
 beq Sm_yes                ;string 0 if left
 move.l d2,d0
 addq.l #1,d0
 cmp.w #3,d1               ;string +1 if forward
 beq Sm_maxi
 subq.l #2,d0              ;string -1 if backward
 rts
