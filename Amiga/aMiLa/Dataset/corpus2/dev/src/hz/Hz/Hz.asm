;
; Hz   An extremely simple PAL/NTSC
;      tool.  Designed for fast and
;      easy display changing for use
;      when developing PAL/NTSC
;      adjusting applications.
;
; An simple example for new assembly language programmers.
; Written by Christopher Jennings.
;
; Copyright © 1993 by Enchanted Blade Associates.
; All rights reserved.  Freely distributable without
; modifications.  Permission granted to use for
; commercial purposes or within commercial products,
; but please give credit for the author's work.
;

openlib  equ -552
closelib equ -414
output   equ -60
write    equ -48

nextletter              ; Extremely simplified "command line parsing"
   cmpi.b #'?',(a0)     ; Is it a '?'?
   beq.s  help
   cmpi.b #'p',(a0)     ; Is it a 'p'?
   beq.s  pal
   cmpi.b #'P',(a0)     ; Is it a 'P'?
   beq.s  pal
   cmpi.b #'n',(a0)     ; Is it an 'n'?
   beq.s  ntsc
   cmpi.b #'N',(a0)     ; Is it an 'N'?
   beq.s  ntsc
   cmpi.b #10,(a0)+     ; Is it an EOL? Move argument to next letter
   bne.s  nextletter
ntsc
   move.w #0,$dff1dc    ; Switch to NTSC
   moveq  #0,d0
   rts
pal
   move.w #32,$dff1dc   ; Switch to PAL
   moveq  #0,d0
   rts
help
   movem.l a6/d2-d3,-(sp) ; Save the non-scratch registers we use
   lea     dosname(pc),a1 ; Open any dos lib
   moveq   #0,d0
   movea.l 4,a6
   jsr     openlib(a6)
   tst.l   d0
   beq.s   nolib
   movea.l d0,a6          ; Switch to dos to get our handle
   jsr     output(a6)
   move.l  d0,d1
   beq.s   nohandle
   lea     usage(pc),a0   ; Address of length+message
   moveq   #0,d3          ; Clear upper 24 bits
   move.b  (a0)+,d3       ; Get length
   move.l  a0,d2          ; Get address
   jsr     write(a6)
nohandle
   movea.l a6,a1          ; Close dos lib
   movea.l 4,a6
   jsr     closelib(a6)
nolib
   movem.l (sp)+,a6/d2-d3 ; Restore registers
   moveq   #0,d0          ; Error-free exit
   rts

usage
      dc.b dosname-usage-1
      dc.b 10
      dc.b 'USAGE: Hz [N=NTSC|P=PAL|?]',10
      dc.b 'Default action is NTSC',10
      dc.b 10
dosname
      dc.b 'dos.library',0

; Yup. That's it.

