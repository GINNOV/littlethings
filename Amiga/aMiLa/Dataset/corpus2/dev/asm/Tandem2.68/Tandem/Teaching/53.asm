* 53.asm  demonstrate TLPutilbm     version 0.01     8.6.99


 include 'Front.i'


; TLPutilbm can save a region from any bitmap as an IFF file.
; This program saves the workbench screen image as an IFF file. The program
; saves the workbench screen image to a file named "RAM:Temp.iff". You
; can use Multiview, or a paint program, to load RAM:Temp.iff to check
; that this program worked ok.


strings: dc.b 0
 dc.b 'RAM:Temp.iff',0     ;1
 dc.b 'Saved - from the CLI, enter  Multiview RAM:Temp.iff  to view it',0 ;2
 dc.b '(Or, load, assemble & run 53.asm, and input RAM:Temp.iff)',0 ;3

 ds.w 0


* demonstrate  TLPutilbm
Program:
 TLwindow #-1              ;initilise everything
 beq Pr_quit

 TLstrbuf #1               ;filename to buffer
 move.l xxp_Screen(a4),a1  ;a1 = the workbench screen
 move.l sc_RastPort+rp_BitMap(a1),a0 ;a0 = the workbench screen's bitmap
 TLputilbm #0,#0,#100,#50,a0  ;save the screen (0,0)-(99,49) in RAM:Temp.iff
 beq.s Pr_bad              ;go if bad

 TLreqinfo #2,#2           ;tell user how to view it
 bra.s Pr_quit

Pr_bad:                    ;report error if bad
 TLerror
 TLreqchoose

Pr_quit:
 rts
