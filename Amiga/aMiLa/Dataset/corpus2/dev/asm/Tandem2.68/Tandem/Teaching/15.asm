* 15.asm   Beep the screen          version 0.00    1.9.97

 xref _AbsExecBase       ; There must be XREF's for _AbsExecBase, and
 xref _LVOOpenLibrary    ; all ROM Kernal libraries. The XREF's must
 xref _LVOCloseLibrary   ; prepend _LVO before the library names.
 xref _LVODisplayBeep

 move.l _AbsExecBase,a6  ;open intuition.library
 lea intname,a1
 moveq #37,d0            ;at least version 37 (i.e. release 2.04)
 jsr _LVOOpenLibrary(a6)
 move.l d0,intbase       ;D0 points to library base, or 0 if couldn't open
 beq.s Abort             ;go if couldn't open
 move.l intbase,a6
 sub.l a0,a0             ;a0=0 to beep all screens
 jsr _LVODisplayBeep(a6) ;beep screens
 move.l _AbsExecBase,a6  ;close intuition.library
 move.l intbase,a1
 jsr _LVOCloseLibrary(a6)
 clr.l d0                ;quit good
 rts
Abort:
 moveq #-1,d0            ;quit bad
 rts

intname: dc.b 'intuition.library',0
intbase: ds.l 1
