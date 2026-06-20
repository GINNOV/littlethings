* 66.asm     TLslimon      0.01    8.6.99)


 include 'Front.i'


; *** Important!!! ***
;
; If assembling this program for demonstration/77, make the
; address of  Logo.iff  to be  /Logo.iff  in string 12


; See the remarks on 65.asm, which are also pertinent to this program


vert: ds.l 1                ;xxp_tops cache for vert,horz sliders
horz: ds.l 1

logo: ds.l 1                ;pointer to bitmap where Logo.iff stored


strings: dc.b 0
st_1: dc.b  'TLSlimon demonstration',0 ;1
 dc.b 'Out of chip ram',0 ;2
 dc.b 'totl 298',0 ;3
 dc.b 'strs 64',0 ;4
 dc.b 'tops',0 ;5
 dc.b 'Horz',0 ;6
 dc.b 'Vert',0 ;7
 dc.b 'totl 149',0 ;8
 dc.b 'strs 48',0 ;9
 dc.b 'Error: can''t find/load Tandem/Logo.iff',0 ;10
 dc.b 'Use the sliders to move the logo around...',0 ;11
 dc.b 'Logo.iff',0 ;12

 ds.w 0


Program:
 TLwindow #0,#0,#0,#200,#100,#640,#256,#0,#st_1
 beq Pr_bad1

 TLstrbuf #12
 move.l a4,a1
 add.w #20,a1
 TLgetilbm #2,a1
 beq Pr_bad2
 move.l a0,logo

 clr.l vert                ;init vert,horz
 clr.l horz

Pr_draw:
 bsr Logo                  ;update the window, display the logo

 move.l xxp_AcWind(a4),a5
 move.w #$0200,xxp_FrontPen(a5)
 TLstring #11,#20,#6
 subq.b #1,xxp_FrontPen(a5)

 TLreqbev #20,#20,#320,#161     ;outline bev: scrolling area 22-319 X 21-169

 TLreqarea #320,#170,#18,#10,#3 ;draw icon at bottom right
 TLreqbev #320,#170,#20,#11
 TLpict #11,#326,#171

 TLstring #6,#400,#20      ;print horz data: totl, strs, tops stub
 TLstring #3,#448,#20
 TLstring #4,#448,#28
 TLstring #5,#448,#36

 TLstring #7,#400,#52      ;print vert data:  totl, strs, tops stub
 TLstring #8,#448,#52
 TLstring #9,#448,#60
 TLstring #5,#448,#68

 move.l #20,xxp_slix(a4)   ;draw horz slider
 move.l #170,xxp_sliy(a4)
 move.l #300,xxp_sliw(a4)
 move.l #11,xxp_slih(a4)
 move.l #298,xxp_totl(a4)
 move.l #64,xxp_strs(a4)
 move.l horz,xxp_tops(a4)
 TLslider xxp_AcWind(a4),a5

 move.l #320,xxp_slix(a4)  ;draw vert slider
 move.l #20,xxp_sliy(a4)
 move.l #20,xxp_sliw(a4)
 move.l #150,xxp_slih(a4)
 move.l #149,xxp_totl(a4)
 move.l #48,xxp_strs(a4)
 move.l vert,xxp_tops(a4)
 clr.l xxp_hook(a4)
 TLslider xxp_AcWind(a4),a5

 bsr Htops                 ;print horz tops value
 bsr Vtops                 ;print vert tops value

Pr_wait:                   ;* wait for keyboard input
 TLwcheck
 bne Pr_draw               ;go redraw all if window resized

 TLkeyboard
 cmp.b #$93,d0             ;quit if close window
 beq Pr_quit
 cmp.b #$1B,d0             ;quit if Esc
 beq Pr_quit

 cmp.b #$80,d0             ;ignore keyboard input unless lmb click
 bne Pr_wait

 move.l horz,xxp_tops(a4)  ;monitor horz slider
 move.l #20,xxp_slix(a4)
 move.l #170,xxp_sliy(a4)
 move.l #300,xxp_sliw(a4)
 move.l #11,xxp_slih(a4)
 move.l #298,xxp_totl(a4)
 move.l #64,xxp_strs(a4)
 move.l #Hhook,xxp_hook(a4)
 TLslimon d1,d2,d3
 beq.s Pr_vert             ;go if horz slider inactive
 move.l xxp_tops(a4),horz  ;else update horz
 bra Pr_wait               ;& get next keyboard input

Pr_vert:
 move.l vert,xxp_tops(a4)  ;monitor vert slider
 move.l #320,xxp_slix(a4)
 move.l #20,xxp_sliy(a4)
 move.l #20,xxp_sliw(a4)
 move.l #150,xxp_slih(a4)
 move.l #149,xxp_totl(a4)
 move.l #48,xxp_strs(a4)
 move.l #Vhook,xxp_hook(a4)
 TLslimon d1,d2,d3
 beq Pr_wait               ;go if vert slider inactive
 move.l xxp_tops(a4),vert  ;else update vert
 bra Pr_wait               ;& get keyboard input

Pr_bad1:                   ;report out of mem if bad
 TLbad #2
 bra.s Pr_quit

Pr_bad2:
 TLbad #10

Pr_quit:                   ;exit from Program
 tst.l logo
 beq.s Pr_exit
 TLfreebmap logo           ;free logo memory
Pr_exit:
 rts


* hook for horizontal slider
Hhook:
 bsr Htops
 bsr Hlogo
 rts


* show horz tops
Htops:
 move.l #'    ',(a4)
 TLhexasc xxp_tops(a4),a4
 clr.b 3(a4)
 TLtrim #488,#36
 rts


* hook for vertical slider
Vhook:
 bsr Vtops
 bsr Vlogo
 rts


* move the logo horizontally
Hlogo:
 move.l xxp_gfxb(a4),a6
 move.l xxp_AcWind(a4),a5

 move.l xxp_WPort(a5),a1
 moveq #3,d0
 jsr _LVOSetBPen(a6)

 move.l xxp_WPort(a5),a1
 moveq #22,d2
 moveq #21,d3
 move.l #319,d4
 cmp.w xxp_PWidth(a5),d4
 ble.s Hl_vtrm
 move.w xxp_PWidth(a5),d4
Hl_vtrm:
 move.l #169,d5
 cmp.w xxp_PHeight(a5),d5
 ble.s Hl_redi
 move.w xxp_PHeight(a5),d5
Hl_redi:
 move.l horz,d0
 sub.l xxp_tops(a4),d0
 move.l xxp_tops(a4),horz
 moveq #0,d1
 add.w xxp_LeftEdge(a5),d2
 add.w xxp_TopEdge(a5),d3
 add.w xxp_LeftEdge(a5),d4
 add.w xxp_TopEdge(a5),d5
 TLwcheck
 bne.s Hl_quit
 jsr _LVOScrollRaster(a6)
Hl_quit:
 rts


* move the logo vetically
Vlogo:
 move.l xxp_gfxb(a4),a6
 move.l xxp_AcWind(a4),a5

 move.l xxp_WPort(a5),a1
 moveq #3,d0
 jsr _LVOSetBPen(a6)

 move.l xxp_WPort(a5),a1
 moveq #22,d2
 moveq #21,d3
 move.l #319,d4
 cmp.w xxp_PWidth(a5),d4
 ble.s Vl_vtrm
 move.w xxp_PWidth(a5),d4
Vl_vtrm:
 move.l #169,d5
 cmp.w xxp_PHeight(a5),d5
 ble.s Vl_redi
 move.w xxp_PHeight(a5),d5
Vl_redi:
 moveq #0,d0
 move.l vert,d1
 sub.l xxp_tops(a4),d1
 move.l xxp_tops(a4),vert
 add.w xxp_LeftEdge(a5),d2
 add.w xxp_TopEdge(a5),d3
 add.w xxp_LeftEdge(a5),d4
 add.w xxp_TopEdge(a5),d5
 TLwcheck
 bne.s Vl_quit
 jsr _LVOScrollRaster(a6)
Vl_quit:
 rts


* show vert tops
Vtops:
 move.l #'    ',(a4)
 TLhexasc xxp_tops(a4),a4
 clr.b 3(a4)
 TLtrim #488,#68
 rts


* draw logo on the window (calls Wupdate)
; caution: the minumum size of the window must allow logo to fit at topleft

Logo:
 TLwupdate
 TLreqarea #22,#21,#298,#149,#3 ;fill scrolling area with pen 3
 move.l xxp_AcWind(a4),a5  ;a5 = currently active window

 move.w xxp_PWidth(a5),d0  ;move horz if it doesn't fit on the window
 sub.w #22,d0
 sub.w #64,d0
 cmp.w horz+2,d0
 bcc.s Lo_vert
 move.w d0,horz+2

Lo_vert:                   ;move vert if it doesn't fit on the window
 move.w xxp_PHeight(a5),d0
 sub.w #21,d0
 sub.w #48,d0
 cmp.w vert+2,d0
 bcc.s Lo_redi
 move.w d0,vert+2

Lo_redi:                   ;ready the blit
 move.l logo,a0
 move.l xxp_WPort(a5),a1
 move.l xxp_gfxb(a4),a6
 moveq #0,d0
 moveq #0,d1
 moveq #22,d2
 add.w horz+2,d2
 add.w xxp_LeftEdge(a5),d2
 moveq #21,d3
 add.w vert+2,d3
 add.w xxp_TopEdge(a5),d3
 moveq #64,d4
 moveq #48,d5
 move.w #$C0,d6

 TLwcheck                  ;recyle if window resized
 bne Logo

 jsr _LVOBltBitMapRastPort(a6) ;go the blit
 rts
