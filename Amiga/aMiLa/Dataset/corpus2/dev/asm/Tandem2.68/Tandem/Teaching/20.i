* Teaching/16.i   (to demonstrate INCLUDE)

 xref _LVODisplayBeep

* beep the screen (intuition.library must already be in intbase)
Beep:
 move.l intbase,a6
 sub.l a0,a0             ;a0=0 to beep all screens
 jsr _LVODisplayBeep(a6) ;beep screens
 rts
