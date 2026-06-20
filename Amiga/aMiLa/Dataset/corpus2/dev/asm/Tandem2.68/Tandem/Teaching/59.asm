* 59.asm     TLgetarea and some bevs   version 0.01    8.6.99


 include 'Front.i'        ;*** replace by 'Tandem.i' to step thru TL's ***


strings: dc.b 0
st_1: dc.b 'TLgetarea demo + some bevs',0 ;1
 dc.b 'Error: out of chip memory',0 ;2
 dc.b 'Select any region on this window ....',0 ;3
 dc.b ' ',0 ;4
 dc.b '1. Move the mouse pointer to the top left of the region.',0 ;5
 dc.b '2. Press the left mouse button down.',0 ;6
 dc.b '3. Move the mouse pointer to the bottom right of the region.',0 ;7
 dc.b '4. Release the left mouse button.',0 ;8
 dc.b ' ',0 ;9
 dc.b 'The region you select will then be highlighted.',0 ;10
 dc.b '(Alternately, you can press Esc to cancel)',0 ;11
 dc.b 'You chose to cancel',0 ;12
 dc.b 'Chosen region highlighted',0 ;13

 ds.w 0


* test program
Program:
 TLwindow #0,#0,#0,#640,#200,#640,#200,#0,#st_1 ;open window 0
 bne.s Pr_cont             ;go if ok
 TLbad #2                  ;report if can't open window
 rts

Pr_cont:
 TLreqbev #20,#100,#70,#20      ;* do some bevs (just for novelty value)
 TLreqbev #120,#100,#70,#20,rec ;bev 2
 TLreqbev #218,#99,#74,#22      ;bev 3
 TLreqbev #220,#100,#70,#20,rec
 TLreqbev #318,#99,#74,#22,rec  ;bev 4
 TLreqbev #320,#100,#70,#20
 TLreqbev #419,#100,#72,#20     ;bev 5
 TLreqbev #420,#100,#70,#20
 TLreqbev #519,#100,#72,#20,rec ;bev 6
 TLreqbev #520,#100,#70,#20,rec
 TLreqbev #80,#135,#70,#20      ;bev 7
 TLreqbev #70,#130,#70,#20
 TLreqarea #72,#131,#66,#18
 TLreqbev #216,#128,#78,#24     ;bev 8
 TLreqbev #220,#130,#70,#20
 TLreqbev #316,#128,#78,#24     ;bev 9
 TLreqbev #320,#130,#70,#20,rec
 TLreqbev #416,#128,#78,#24,rec ;bev 10
 TLreqbev #420,#130,#70,#20,rec
 TLreqbev #516,#128,#78,#24,rec ;bev 11
 TLreqbev #520,#130,#70,#20
 moveq #3,d0               ;print instructions (string 3-10)
 moveq #8,d2
 moveq #8,d3

Pr_info:
 TLstring d0,#16,d2
 addq.w #1,d0
 addq.w #8,d2
 dbra d3,Pr_info
 move.l xxp_AcWind(a4),a5
 move.l xxp_Window(a5),a0
 move.w xxp_LeftEdge(a0),d0 ;set d0-d3 to limits of printable area
 move.w xxp_TopEdge(a0),d1
 move.w xxp_PWidth(a0),d2
 sub.w d0,d2
 subq.w #1,d2
 move.w xxp_PHeight(a0),d3
 sub.w d1,d3
 subq.w #1,d3

 TLgetarea d0,d1,d2,d3,a4  ;select in printable area
 beq.s Pr_canc             ;go if cancelled

 move.l xxp_gfxb(a4),a6    ;set window draw mode to complement
 move.l xxp_WPort(a5),a1
 moveq #RP_COMPLEMENT,d0
 jsr _LVOSetDrMd(a6)

 move.l (a4),d0            ;complement area selected
 move.l 4(a4),d1
 move.l 8(a4),d2
 sub.l d0,d2
 addq.l #1,d2
 move.l 12(a4),d3
 sub.l d1,d3
 addq.l #1,d3
 subq.w #4,d0              ;make rel to printable area
 sub.w #11,d1
 TLreqarea d0,d1,d2,d3
 TLreqinfo #13             ;highlighted: wait for acknowledge
 rts

Pr_canc:
 TLreqinfo #12             ;cancel: wait for acknowledge
 rts
