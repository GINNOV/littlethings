* 49.asm     TLreqshow II    version 0.01   8.6.99


 include 'Front.i'


; This program demonstrates the use of TLreqshow to view classified data
; with dynamic contents


strings: dc.b 0
 dc.b 'View subset 0',0 ;1
 dc.b 'Some Catalogued data (n.b. press <Help> for assistance)',0 ;2
 dc.b '** Click one of the lines below to select which subset **',0 ;3
 dc.b '** Click this line to return to the subset catalogue **',0 ;4
 dc.b 'Subset 0 String     ',0 ;5
 dc.b 'Error: out of memory',0 ;6

 ds.w 0


subset: ds.w 1                   ;subset selected (-1 if in catalogue list)


* test program
Program:
 TLwindow #-1
 move.w #-1,subset               ;flag no subset is yet selected
 TLreqshow #Hook,#2,#20,#20      ;hook=Hook title=2 lines=20 shown=20
 rts

Pr_bad:
 TLbad #6
 rts


* Act as hook for TLreqshow
Hook:
 tst.w subset         ;go if we are in one of the subsets
 bpl.s Ho_sub         ;(if sub=-1, we are still in the catalogue list)
 tst.l d0             ;go if a line clicked
 bmi.s Ho_clkd
 bne.s Ho_cat         ;go if d0>0
 TLstrbuf #3          ;line 0: send string 3
 move.l a4,a0
 rts

Ho_cat:
 cmp.w #5,d0          ;if D0>4, send blank line (lines 5-19 blank)
 bcc.s Ho_null
 TLstrbuf #1          ;send string 1
 add.b d0,12(a4)      ;poke subset num in last chr
 move.l a4,a0         ;a0=string to display
 rts

Ho_null:
 clr.b (a4)           ;send blank line
 move.l a4,a0
 rts

Ho_clkd:              ;catalogue list has been clicked
 bclr #31,d0          ;d0=line clicked
 tst.w d0
 beq.s Ho_clkn        ;if line 0 was clicked, do nothing
 cmp.w #5,d0
 bcc.s Ho_clkn        ;if (blank) line 5-19 clicked, do nothing
 move.w d0,subset     ;remember which subset clicked
 moveq #3,d0          ;return from click: request redraw in subset
 moveq #100,d1        ;each subset has 100 strings
 moveq #0,d3          ;new topline
 rts

Ho_clkn:              ;return from click: do nothing
 moveq #-1,d0
 rts

Ho_sub:               ;* we are in a subset
 tst.l d0
 bmi.s Ho_sclk        ;go if a subset line was clicked
 bne.s Ho_some        ;go if string > 0
 TLstrbuf #4
 move.l a4,a0         ;string 0: send string 4
 rts

Ho_some:
 TLstrbuf #5          ;string 5 to buffer
 move.w subset,d1
 add.b d1,7(a4)       ;poke subset num into string
 move.l a4,a0
 add.l #16,a0         ;point to item num in subset
 TLhexasc d0,a0       ;poke line num into string
 move.l a4,a0
 rts

Ho_sclk:              ;subset has been clicked
 tst.w d0
 bne Ho_clkn          ;do nothing unless 1st line clicked
 move.w #-1,subset
 moveq #3,d0          ;request redraw (back to catalogue window)
 moveq #20,d1         ;items=20
 moveq #0,d3          ;new topline
 rts
