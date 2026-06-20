* 52.asm  demonstrate TLGetilbm     version 0.01     2.3.98


 include 'Front.i'


strings: dc.b 0
st_1: dc.b 'Demonstrate TLgetilbm',0 ;1
 dc.b 'Filename of ILBM IFF file',0 ;2
 ds.w 0


fil: ds.b 34               ;ilbm fil, dir
dir: ds.b 130
bmhd: ds.l 1               ;buffer for bmhd data
bmap: ds.l 1               ;bitmap created by TLgetilbm call
rprt: ds.l 1               ;rastport used to hold bmap for ClipBlit


*>>>> demonstrate  TLGetilbm
Program:
 TLwindow #-1
 TLwindow #0,#0,#0,#640,xxp_Height(a4),#640,xxp_Height(a4),#0,#st_1
 beq Pr_bad
 TLpublic #790
 move.l d0,bmhd            ;mem for bmhd
 beq Pr_bad
 TLpublic #rp_SIZEOF
 move.l d0,rprt            ;mem for rport
 beq Pr_bad
 clr.b fil                 ;init fil,dir
 clr.b dir

Pr_cyc:                    ;view next picture
 TLreqcls
 TLaslfile #fil,#dir,#2,ld ;get filename of ilbm
 beq Pr_bad                ;bad if can't

 TLgetilbm #2,bmhd         ;load ilbm into bmap
 beq Pr_bad                ;bad if can't
 move.l a0,bmap            ;save bmap address

 bsr Blit                  ;blit the ilbm from the bitmap to the window
 TLfreebmap bmap           ;free the bitmap

 TLkeyboard                ;wait for acknowledge
 cmp.b #$93,d0
 bne Pr_cyc                ;recycle unless close window
 bra.s Pr_done

Pr_bad:                    ;report error if bad
 TLerror
 TLreqchoose

Pr_done:                   ;quit
 rts


*>>>> blit the ilbm from bmap to window 0
Blit:
 move.l xxp_gfxb(a4),a6    ;initialise rastport
 move.l rprt,a1
 jsr _LVOInitRastPort(a6)
 move.l rprt,a0            ;a0 = rprt
 move.l bmap,a2            ;a2 = bmap, attach to rport
 move.l a2,rp_BitMap(a0)

 move.l xxp_AcWind(a4),a5  ;a1 = window's rastport
 move.l xxp_WPort(a5),a1

 moveq #0,d0               ;from 0,0 to top left
 moveq #0,d1
 moveq #0,d2
 move.w xxp_LeftEdge(a5),d2
 moveq #0,d3
 move.w xxp_TopEdge(a5),d3

 moveq #0,d4               ;greater of bmap width, window width to d4
 move.w (a2),d4
 lsl.w #3,d4
 cmp.w xxp_PWidth(a5),d4
 bcs.s Bl_xlim
 move.w xxp_PWidth(a5),d4
Bl_xlim:

 moveq #0,d5               ;greater of bmap height, window height to d5
 move.w 2(a2),d5
 cmp.w xxp_PHeight(a5),d5
 bcs.s Bl_ylim
 move.w xxp_PHeight(a5),d5 ;trim to fit window
Bl_ylim:

 move.l #$C0,d6            ;minterm: $C0=vanilla
 jsr _LVOClipBlit(a6)      ;do the blit
 rts
