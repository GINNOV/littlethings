* teaching/63.asm   Scrollers II, View Rastport    Version 0.01    8.6.99


 include 'Front.i'


port: ds.l 1               ;area to hold rastport
bmap: ds.l 1               ;area to hold bitmap

rwid: dc.l 1024            ;width of rastport
rhgt: dc.l 1024            ;height of rastport

rpxp: dc.l 0               ;region of rastport to be viewed
rpyp: dc.l 0
rpwd: dc.l 1024
rpht: dc.l 1024

wdxp: ds.l 1               ;region of window where rastport is shown
wdyp: ds.l 1
wdwd: ds.l 1
wdht: ds.l 1


* text strings
strings: dc.b 0
st_1: dc.b 'View a rastport by using window scrollers',0 ;1
 dc.b 'I have made a rastport, & filled it with ellipses.',0 ;2
 dc.b 'After you click "OK" on this requester, use the window scrollers',0
 dc.b 'to view the rastport. Also, resize, zoom & move the window.',0 ;4
 dc.b 'Finally, click the window to quit.',0 ;5
 dc.b 'Error: out of public memory',0 ;6

 ds.w 0


* control program execution
Program:
 TLwindow #-1
 beq Pr_quit

 TLwindow #0,#0,#0,#320,#100,#640,xxp_Height(a4),#-1,#st_1
 beq Pr_quit

 bsr Make                  ;draw ellipses on rastport
 beq Pr_quit               ;go if out of mem
 TLreqinfo #2,#4,#0        ;instructions

Pr_resz:                   ;here if window resized
 TLwupdate

 move.l xxp_AcWind(a4),a5  ;set sliders to top left
 move.l xxp_scrl(a5),a3
 moveq #0,d0
 move.w xxp_PWidth(a5),d0
 clr.l xxp_hztp(a3)
 move.l d0,xxp_hzvs(a3)
 move.l #1024,xxp_hztt(a3)
 move.w xxp_PHeight(a5),d0
 clr.l xxp_vttp(a3)
 move.l d0,xxp_vtvs(a3)
 move.l #1024,xxp_vttt(a3)
 TLwscroll set

Pr_blit:                   ;here for next blit
 move.l xxp_gfxb(a4),a6
 move.l port,a0
 move.l xxp_hztp(a3),d0
 move.l xxp_vttp(a3),d1
 move.l xxp_AcWind(a4),a5
 move.l xxp_WPort(a5),a1
 moveq #0,d2
 move.w xxp_LeftEdge(a5),d2
 moveq #0,d3
 move.w xxp_TopEdge(a5),d3
 moveq #0,d4
 move.w xxp_PWidth(a5),d4
 moveq #0,d5
 move.w xxp_PHeight(a5),d5
 move.w #$C0,d6
 TLwcheck                  ;go if window resized
 bne Pr_resz
 jsr _LVOClipBlit(a6)

Pr_wait:                   ;wait for response
 TLkeyboard
 cmp.b #$98,d0
 beq Pr_blit               ;update window if scroller
 TLwcheck
 bne Pr_resz               ;go if resized
 cmp.b #$93,d0
 beq.s Pr_quit             ;quit if close window
 cmp.b #$80,d0
 bne Pr_wait               ;continue until clicked

Pr_quit:                   ;quit, with error report if any
 TLerror
 rts


* make the rastport
Make:
 TLbusy
 clr.l xxp_errn(a4)        ;no error so far

 TLpublic #rp_SIZEOF       ;memory for rastport
 move.l d0,port
 beq Mk_bad1

 move.l xxp_gfxb(a4),a6    ;init rastport
 move.l d0,a1
 jsr _LVOInitRastPort(a6)

 TLpublic #bm_SIZEOF       ;memory for bitmap struct
 move.l d0,bmap
 beq Mk_bad1

 move.l d0,a0              ;init bitmap (only 1 plane)
 moveq #1,d0
 move.l rwid,d1
 move.l rhgt,d2
 jsr _LVOInitBitMap(a6)

 move.l bmap,a0            ;point rastport to bitmap
 move.l port,a1
 move.l a0,rp_BitMap(a1)

 TLchip #128*1024          ;memory for bitplane  (bytes per row 1024/8=128)
 move.l d0,bm_Planes(a0)
 beq Mk_bad2

 move.l d0,a1
 move.l #128*1024,d0
 moveq #1,d1
 jsr _LVOBltClear(a6)

 moveq #64,d0              ;draw ellipses:   D0 = x centre
 moveq #8,d2               ;d2 = x radius
 bset #31,d0               ;flag solid
 move.l port,a0            ;a0 = rastport
 moveq #0,d4               ;use all of rastport
 moveq #0,d5
 move.l #1024,d6
 move.l #1024,d7
Mk_col:                    ;for each column
 moveq #32,d1              ;d1 = y centre
 bset #31,d1               ;flag use rastport
 moveq #2,d3               ;d3 = y radius
Mk_elps:
 TLellipse d0,d1,d2,d3,d5,d5,d6,d7,a0 ;draw ellipse
Mk_fwd:
 addq.w #2,d3              ;bump y radius
 add.w #64,d1              ;bump y centre
 cmp.w #1024,d1
 bcs Mk_elps               ;until column done
 addq.w #8,d2              ;bump d radius
 add.w #128,d0             ;bump x centre
 cmp.w #1024,d0
 bcs Mk_col                ;until all columns done

 bra.s Mk_done

Mk_bad1:                   ;bad 1 - out of public mem
 move.w #1,xxp_errn+2(a4)
 bra.s Mk_done

Mk_bad2:                   ;bad 2 - out of chip mem
 move.w #2,xxp_errn+2(a4)

Mk_done:
 TLunbusy
 tst.l xxp_errn(a4)
 eori.w #-1,CCR
 rts
