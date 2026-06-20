* 68.asm  TLprefs     version 0.01     8.6.99


 include 'Front.i'


; TLprefs puts up a requester with lots of built-in help &c to allow the
; user to set prefernces for the tandem.lubrary GUI. You can choose whether
; to also allow the user to change the colour palette. Note that Multiline
; has "GUI Preferences" in its Project menu, which calls TLprefs.


strings: dc.b 0
 dc.b 'Error: out of memory',0 ;1
 ds.w 0


* demonstrate TLprefs
Program:
 TLwindow #-1
 beq Pr_bad

 TLprefs                    ;or "TLprefs color" to allow palette select
 bra.s Pr_quit

Pr_bad:                     ;here if out of mem
 TLbad #1

Pr_quit:
 rts
