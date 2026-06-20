* 29.asm    TLReqarea,TLReqbev   version 0.01    2.10.98


; This program relies on placing boxes of particular sizes at particular
; places. You get better at positioning display elements with practice.
; Incidentally, most programmers think it's bad practice to put numbers
; in your actual program lines; rather it is better practice to use
; symbolic names, which are all given values in a series of EQU pseudo-ops
; at the start of your program. Also, most programmers use more "white
; space" (blank lines, spread out lines) in their programs than I do.

; You should read the docs in Tandem.guide for TLreqbev and TLreqarea
; carefully, as it relates to the program below. Notice also how
; TLReqarea & TLReqbev "clip" boxes & area which go past the printable
; area of the window. If you write on the window border it (or beyond it!)
; it looks terrible, and can crash the system.

; The below are examples of a new art form - making artistic combinations
; of bevelled boxes. Note that the plain rectangles have double width
; sides, which look better than single width.


 include 'Front.i'        ; *** change to 'Tandem.i to step thru TL's ***


strings: dc.b 0
st_1: dc.b 'Demonstrate TLReqarea & TLReqbev',0 ;1
 dc.b 'Error: out of chip memory',0 ;2
 dc.b 'A plain bevelled box   A recessed bevelled box   A plain rectangle',0
 dc.b 'A bevelled box with custom pens   A rectangle with custom pen',0 ;4
 dc.b 'A plain bevelled box filled with pen 3    40X1  1X15  2X15',0 ;5
 dc.b 'Clipped boxes',0 ;6
 dc.b 'Combinations (Art?) ... ',0 ;7

 ds.w 0


* test program
Program:
 TLwindow #0,#0,#0,#640,#200,#640,#200,#0,#st_1 ;open window 0
 bne.s Pr_cont
 TLbad #2                  ;report if can't open window
 rts

Pr_cont:
 TLstring #3,#6,#3                 ;top three boxes
 TLreqbev #66,#18,#40,#15          ;  plain
 TLreqbev #258,#18,#40,#15,rec     ;  recessed
 TLreqbev #450,#18,#40,#15,box     ;  rectangle

 TLstring #4,#6,#44                ;second row of boxes
 TLreqbev #106,#59,#40,#15,,,#3,#6 ;  bev, pens 5,6
 TLreqbev #366,#59,#40,#15,box,,#3 ;  rect, pen 3

 TLstring #5,#6,#85                ;third row
 TLreqarea #130,#100,#40,#15,#3    ;  fill with pen 3
 TLreqbev #130,#100,#40,#15        ;  plain bev
 TLreqbev #342,#100,#40,#1,box     ;  40X1
 TLreqbev #392,#100,#1,#15,box     ;  1X15
 TLreqbev #440,#100,#2,#15,box     ;  2X15

 move.l xxp_AcWind(a4),a5          ;clipped boxes
 moveq #0,d6
 moveq #0,d7
 move.w xxp_PWidth(a5),d6
 move.w xxp_PHeight(a5),d7
 sub.w #104,d6
 sub.w #40,d7
 TLstring #6,d6,d7
 add.w #84,d6
 add.w #12,d7
 TLreqbev d6,d7,#40,#15            ;clipped horz
 add.w #20,d7
 TLreqbev d6,d7,#40,#15            ;clipped both
 sub.w #46,d6
 TLreqbev d6,d7,#40,#15            ;clipped vert

 TLstring #7,#6,#126               ;fourth row
 TLreqbev #6,#136,#60,#30          ;  1st
 TLreqbev #7,#137,#58,#28
 TLreqbev #76,#136,#60,#30,rec     ;  2nd
 TLreqbev #77,#137,#58,#28,rec
 TLreqbev #146,#136,#60,#30        ;  3rd
 TLreqbev #148,#137,#56,#28,rec
 TLreqbev #216,#136,#60,#30,rec    ;  4th
 TLreqbev #218,#137,#56,#28
 TLreqarea #286,#136,#60,#20,#3    ;  5th
 TLreqbev #286,#136,#60,#20
 TLreqarea #292,#139,#48,#14
 TLreqbev #292,#139,#48,#14,rec
 TLreqarea #286,#161,#60,#20,#3    ;  6th
 TLreqbev #286,#161,#60,#20
 TLreqarea #292,#164,#48,#14
 TLreqbev #292,#164,#48,#14,rec
 TLreqbev #293,#165,#46,#12,rec
 TLreqarea #366,#141,#40,#20,#3    ;7th
 TLreqbev #366,#141,#40,#20
 TLreqarea #376,#146,#40,#20
 TLreqbev #376,#146,#40,#20
 TLreqbev #366,#141,#32,#16,box
 TLreqarea #356,#136,#40,#20
 TLreqbev #356,#136,#40,#20

 TLkeyboard                        ;wait for response
 rts
