* Teaching/62.asm   Demonstrate Scrollers    0.01   8.6.99


 include 'Front.i'

; This program is useful, as it shows the IDCMP's that come in
; as you fiddle with the scrollers.


* text strings
strings: dc.b 0
st_1: dc.b 'Set up Window with Scrollers',0 ;1
 dc.b 'Out of Chip memory',0 ;2
 dc.b 'Message  IAddress Code Class    Qual MsX  MsY',0 ;3
 dc.b 'This program is about to open a window with scrollers.',0 ;4
 dc.b 'As you fiddle with the scrollers, resize the window, &c,',0 ;5
 dc.b 'you will see on the window the results of each call to',0 ;6
 dc.b 'TLwindow. This should help you to understand how to make',0 ;7
 dc.b 'your programs responsive to scrollers.',0 ;8

 ds.w 0


* set up window with scrollers
Program:
 TLwindow #-1              ;preliminary info
 TLreqinfo #4,#5

 TLwindow #0,#0,#0,#600,#180,#640,#200,#-1,#st_1 ;\8=-1 for scrollers
 bne.s Pr_cont

Pr_bad:
 TLbad #2
 bra Pr_quit

Pr_cont:
 move.l xxp_AcWind(a4),a5
 move.l xxp_scrl(a5),a3
 move.l #32,xxp_hztp(a3)
 move.l #64,xxp_hzvs(a3)
 move.l #256,xxp_hztt(a3)
 move.l #32,xxp_vttp(a3)
 move.l #64,xxp_vtvs(a3)
 move.l #256,xxp_vttt(a3)
 TLwscroll set

 TLstring #3,#0,#0
 moveq #0,d7               ;message count
 bsr Wait                  ;wait until close window

Pr_quit:
 nop
 nop
 rts


* wait for close window, show mousemoves
Wait:
 TLwcheck
 beq.s Wt_cu
 TLwupdate
Wt_cu:
 TLkeyboard                ;get response

 movem.l d0-d7/a0-a6,-(a7) ;scroll previous messages
 move.l xxp_gfxb(a4),a6
 move.l xxp_AcWind(a4),a5
 move.l xxp_Window(a5),a0
 move.l wd_RPort(a0),a1
 moveq #0,d2
 move.w xxp_LeftEdge(a5),d2
 move.l d2,d4
 add.w #479,d4
 moveq #0,d3
 move.w xxp_TopEdge(a5),d3
 addq.w #8,d3
 move.l d3,d5
 add.w #127,d5
 moveq #0,d0
 moveq #8,d1
 jsr _LVOScrollRaster(a6)
 movem.l (a7)+,d0-d7/a0-a6

 move.l xxp_mesg(a4),a1    ;collect message data    d0 = ascii / TL code
 move.l im_IAddress(a1),d5 ;d5 = IAdress            d3 = modified qualifier
 move.l im_Class(a1),d4    ;d4 = class              d1,d2 = mouse / scroller

 cmp.b #$93,d0             ;qui if close window
 beq Wt_done

 move.l a4,a0              ;show message content
 addq.l #1,d7
 TLhexasc16 d7,#8,a0       ;message count
 move.b #' ',(a0)+
 TLhexasc16 d5,#8,a0       ;IAddress
 move.b #' ',(a0)+
 TLhexasc16 d0,#4,a0       ;ascii / TL code
 move.b #' ',(a0)+
 TLhexasc16 d4,#8,a0       ;class (IDCMP)
 move.b #' ',(a0)+
 TLhexasc16 d3,#4,a0       ;qualifier
 move.b #' ',(a0)+

 TLhexasc16 d1,#4,a0       ;show mouse/scroller posn
 move.b #' ',(a0)+
 TLhexasc16 d2,#4,a0
 move.b #' ',(a0)+

 clr.b (a0)                ;show data
 TLtext #0,#120

 bra Wait                  ;go wait for next message

Wt_done:
 rts
