* 43.asm   TLwpoll, TLwsub       0.01     8.6.99


 include 'Front.i'         ;*** change to 'Tandem.i' to step thru TL's ***


; This program shows how to have several windows at once. In practice, each
; window would have its own subroutine to do whatever that window does.
; A window will keep calling TLKeyboard. If it returns resize, then re-draw
; the window. It it returns close, then close the window. If it returns
; inactive window, exit from the window, and call TLWpoll to wait for a
; window to become active. All other inputs would be dealt with within
; the context of whatever that window is for. Each window can have its own
; help, can call requesters, or be used for TLmultiline. Each can make use
; of the fonts in FSuite. There can be up to 10 windows, numbered 0-9.

; You should study this program carefully - Amiga programming relies
; heavily on mastering the difficult art of managing a suit of windows.


open: ds.w 1               ;number of open windows
spen: dc.l -1              ;pens for screen


strings: dc.b 0
 dc.b 'Iteration '
st_1a: dc.b 'A: Window '
st_1b: dc.b '2 is active',0 ;1
 dc.b 'Error: out of memory',0 ;2
 dc.b 'Error: can''t open windows - out of mem',0 ;3
 dc.b 'Error: can''t open window 2 - out of mem',0 ;4
 dc.b 'move windows about, click them, size them, & close them',0 ;5
st_6: dc.b 'A Private Screen',0 ;6
st_7: dc.b 'Window 0',0 ;7
st_8: dc.b 'Window 1',0 ;8
st_9: dc.b 'Window 2',0 ;9

 ds.w 0


Program:
 move.b #'Z',st_1a         ;initialise string 1
 TLscreen #2,#st_6,#spen   ;open screen
 beq Pr_bad
 TLwindow #0,#20,#10,#50,#25,#350,#75,#0,#st_7 ;open window 0
 beq Pr_bad
 TLwindow #1,#30,#15,#50,#25,#350,#75,#0,#st_8 ;open window 1
 beq Pr_bad
 TLwindow #2,#40,#20,#50,#25,#350,#75,#0,#st_9 ;open window 2
 beq Pr_bad
 move.w #3,open            ;set number of open windows
 bra.s Pr_cont             ;(window 2 is active)

Pr_cycl:
 TLwpoll                   ;wait for a window to be active

Pr_cont:
 move.w xxp_Active(a4),d7  ;d7 is active window
 bsr Win0                  ;do this window until it becomes inactive
 tst.w open                ;any windows still open?
 bne Pr_cycl               ;yes, recycle
 rts                       ;exit ok

Pr_bad:
 TLbad #2                  ;report if out of mem
 rts


* window D7 is active
Win0:
 move.b d7,d0             ;put window num in string 1
 add.w #'0',d0
 move.b d0,st_1b
 addq.b #1,st_1a          ;bump A-Z in string 1
 cmp.b #'Z'+1,st_1a
 bne.s W0_draw
 move.b #'A',st_1a

W0_draw:
 TLwupdate                ;update window size
 TLstring #1,#10,#20      ;print string 1

W0_wait:
 TLkeyboard               ;wait at keyboard
 cmp.b #$96,d0            ;resized?
 beq Win0                 ;redraw if resized
 cmp.b #$93,d0            ;close?
 beq.s W0_close           ;close if close gadget
 cmp.b #$97,d0            ;inactive?
 bne W0_wait              ;keep waiting until inactive
 rts

W0_close:
 TLwsub d7                ;close window
 subq.w #1,open           ;dec no. of open windows
 rts
