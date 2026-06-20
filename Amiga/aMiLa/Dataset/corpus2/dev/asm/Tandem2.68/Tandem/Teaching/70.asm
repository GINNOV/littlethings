* 70.asm  Attach Guide     version 0.01     8.6.99


 include 'Front.i'


; The Help requester that comes up may also contain a "Guide" button that
; invokes an AmigaGuide to supplement the help you give. To do that:
;   1. set xxp_guid(a4) to point to the path of the guide
;      (if your program CD's to its progdir:, that can be the guide's
;       simple filename if it is in the Progdir:)
;   2. set xxp_node(a4) to point to the nodename (or 0 for contents)
;   3. set bit 7 of xxp_Help+2(a4)
;
; Thus, as well as setting xxp_Help with context sensitive help from time
; to time, you can at the same time set xxp_node(a4) to point to the
; relevent node name.


guid: dc.b 'Tandem.guide',0 ;path of AmigaGuide
node: dc.b 'help',0         ;node of Tandem.guide
 ds.w 0


strings: dc.b 0
 dc.b 'Error: out of memory',0 ;1
 dc.b 'This is just a dummy requester...',0 ;2
 dc.b 'The idea, is for you to press the <Help> key.',0 ;3
 dc.b 'When you do, Help will have 2 buttons:',0 ;4
 dc.b ' ',0 ;5
 dc.b '1. Guide - which should bring up the "help" node of Tandem.guide',0
 dc.b '2. OK - which should close the Help requester',0 ;7
 dc.b 'Data about Tandem/Teaching/70.asm',0 ;8
 dc.b ' ',0 ;9
 dc.b 'The program you are running is a demonstration of',0 ;10
 dc.b 'tandem.library''s ability to display online help. To find out',0 ;11
 dc.b 'more about how to attach context-sensitive online help, press',0 ;12
 dc.b 'the "Guide" key below, which should display the "help" node',0 ;13
 dc.b 'of Tandem.guide',0 ;14

 ds.w 0


* demonstrate context-sensitive online help
Program:
 TLwindow #-1
 beq Pr_bad

 move.w #8,xxp_Help(a4)     ;create context sensitive online help
 move.w #7,xxp_Help+2(a4)

 move.l #guid,xxp_guid(a4)  ;cause Help to offer Tandem.guide
 move.l #node,xxp_node(a4)
 bset #7,xxp_Help+2(a4)

 TLreqinfo #2,#6            ;put up requester with online help
 bra.s Pr_quit

Pr_bad:                     ;here if out of mem
 TLbad #1

Pr_quit:
 rts
