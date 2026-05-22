* 30.asm     Demonstrate TLKeyboard     Version 0.01   8.6.99


 include 'Front.i'  ;*** change to 'Tandem.i' to step thru TL's ***


; I should stress again that it is a good idea to chnage the above to
; Tandem.i, which allows you to step thru tandem.library routines.
;
; If you have done so...
; When you are stepping Program, and you come to a TL call, e.g.
;
;   jsr _LVO\1
;
; then instead of single stepping it (which jumps right through it), put a
; breakpoint at the relevent TL routine. e.g. if you are in TLwindow, put
; the breakpoint at the start of TLWindow. If you have included Tandem.i,
; then when you run, the breakpoint will trap execution at the start of
; TLWindow. You can then step it through, and back to where is was called
; in Program. That is to say, Tandem.i forces calls to tandem.library to be
; diverted to itself, so you can step them through.

; This program demonstrates the use of TLKeyboard which which returns an
; ASCII value in D0, or dummy values for non-printable keys. It you are
; stepping through TLKeyboard, you should place your breakpoint within the
; sub-subroutine TLMget, just AFTER the BSR to TLMmess. This allows you to
; first type something into the window, before jumping back to Tandem.


strings: dc.b 0
 dc.b 'Press or click anything - Close window when finished',0 ;1
 dc.b 'D0 D1 D2 D3',0 ;2
st_3: dc.b '.. .. .. .. ',0 ;3
st_4: dc.b 'TLKeyboard demo',0 ;4
 dc.b 'Error: out of memory',0 ;5
 ds.w 0

* open screen & window; show Keyboard until Close Window clicked
Program:
 TLwindow #1,#0,#0,#200,#100,#400,#150,#0,#st_4 ;open window 1
 beq Pr_bad                           ;bad if out of chip ram
 TLstrbuf #2                          ;string 2 to buffer
 TLtext #10,#5                        ;print string 2 at 10,5

Pr_wait:
 TLkeyboard              ;get from keyboard - see TLKeyboard in tandem.guide
 cmp.b #$93,d0           ;($93 is my dummy code for IDCMP_CLOSEWINDOW)
 beq.s Pr_close          ;quit if Close Window clicked
 lea st_3,a0             ;poke the inputs (D0-D3) into string 3
 bsr Hex
 move.l d1,d0
 bsr Hex
 move.l d2,d0
 bsr Hex
 move.l d3,d0
 bsr Hex
 TLstrbuf #3             ;string 3 to buffer
 TLtext #10,#24          ;print string 3 at 10,24
 bra Pr_wait             ;wait for next input
Pr_close:
 rts                     ;return ok
Pr_bad:
 TLbad #5
 rts


* put ASCII (2 hex digits) for hex of D0.B in (A0)+
Hex:
 move.l d0,-(a7)
 lsr.l #4,d0
 bsr.s Hx_n
 move.l (a7)+,d0
 bsr.s Hx_n
 move.b #$20,(a0)+
 rts
Hx_n:
 and.b #15,d0
 add.b #'0',d0
 cmp.b #':',d0
 bcs.s Hx_p
 add.b #'A'-':',d0
Hx_p:
 move.b d0,(a0)+
 rts
