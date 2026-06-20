* 28.asm    Demonstrate TLstring, TLtrim      Version 0.01    8.6.97

; This program prints a message to a custom window, using TLstring. You
; should follow this carefully, noting the use of an embedded IntuiText
; structure by TLTrim, which TLstring calls. (See Intuition/Intuition.i)
; Change "include 'Front.i'"  (below) to  "include 'Tandem.i'" to step
; thru the TL routines.

; You will notice that if you resize a window over its text, the resized-
; over text blanks out. I will explain "refreshing" in a future program,
; which overcomes this problem. tandem.library opens "smart refresh" windows
; which re-display (refresh) themselves automatically if one dumps another
; window on top of them. But only "super bitmap" windows refresh themselves
; if they are resized. Super bitmap windows are rarely used since they are
; slow and waste memory.

; This program does not call TLscreen, to it shares the default public
; screen (i.e. generally the workbench).

; You will note in the program below that you do not need to close
; windows or other things created by tandem.library calls. Front.i calls
; TLWclose when you exit from Program, which automatically releases
; all resources used by tandem.library calls. This makes programming
; more convenient.


 include 'Front.i'       ;*** change to 'Tandem.i' to step thru TL's ***


strings: dc.b 0
st_1: dc.b 'Demonstrate TLstring & TLtrim',0 ;1
 dc.b 'Hello, Intuition',0 ;2
 dc.b '28.asm failed: Out of memory',0 ;3
 dc.b '(I don''t refresh - resize the window & see what I mean.)',0 ;4
 dc.b 'Click the window close gadget when finished.',0 ;5
 ds.w 0


* open window & print message; close & exit when close gadget clicked
Program:
 TLwindow #0,#20,#10,#80,#50,#500,#150,#0,#st_1 ;open window 0
 beq Pr_bad

 TLstring #2,#4,#2         ;show string 2 at (4,2)
 TLstring #4,#4,#16        ;show string 4 at (4,16)
 TLstring #5,#4,#30        ;show string 5 at (4,30)

Pr_wait:
 TLkeyboard                ;get any input
 cmp.b #$93,d0             ;close gadget?
 bne Pr_wait               ;no, keep waiting
 bra.s Pr_quit             ;return ok  (Front0.i closes everything)

Pr_bad:
 TLerror                   ;TLerror sends error reports to the monitor
 TLbad #3                  ;"TLbad #3" makes the monitor wait for
                           ;  acknowledge before closing, with
Pr_quit:
 rts
