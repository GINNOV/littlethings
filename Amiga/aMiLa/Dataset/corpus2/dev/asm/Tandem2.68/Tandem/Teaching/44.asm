* 44.asm  TLmultiline     version 0.01     8.6.99


 include 'Front.i'         ;*** change to 'Tandem.i' to step thru TL's ***


; TLmultiline is a very large and complex program. It allows the user to
; co-opt a window temporarily to display a set of lines, and perhaps to
; edit them. It is a full-blown text editor in its own right. TLmultiline
; also has its own Amiga.guide which the user of TMmultiline can peruse.
; The version of TLmultiline in release 1 of tandem.library is crippled, as
; it only edits plaintext, without character & line styling or graphics.

; TLmultiline when it takes over a window remembers its attributes, and
; restores those attributes to its host window when it exits. The program
; below demonstrates this.

; TLmultiline has extensive built-in online help.


strings: dc.b 0
 dc.b 'TLMultiline demonstration',0 ;1
 dc.b 'Done!!',0 ;2
st_3: dc.b 'a TLMultiline window!',0 ;3
 dc.b 'This window will become a TLmultiline window.',0 ;4
 dc.b 'TLmultiline is a built-in text editor.',0 ;5
 dc.b 'There is context sensitive help, via the',0 ;6
 dc.b '<Help> key, and it also has its own menu.',0 ;7

 ds.w 0


menu:
 TLnm 1,13
 TLnm 2,14
 TLnm 2,-1
 TLnm 2,15
 TLnm 4,0


* demonstrate TLMultiline
Program:
 TLwindow #0,#0,#0,#380,#120,#640,#256,#-1,#st_3 ;open window 0
 beq Pr_quit

 TLreqinfo #4,#4,#0        ;show preliminary info
 beq.s Pr_quit             ;quit if can't
 move.l xxp_AcWind(a4),a5       ;point to current window
 move.w #76,xxp_Mmxc(a5)        ;max 76 chrs/line    } override defaults
 move.l #1000000,xxp_Mmsz(a5)   ;mem size 1000000    } before calling

Pr_mult:
 TLmultiline #xxp_xmsty,#xxp_xesty ;* run TLMultiline (all styl forbidden)
 tst.l xxp_errn(a4)
 bne.s Pr_quit             ;quit if error
 cmp.b #$97,xxp_kybd+3(a4) ;redo if merely stopped because inactive window
 beq Pr_mult

Pr_quit:
 rts
