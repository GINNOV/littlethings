* 16.asm     Introduction to MACRO's   version 0.00  1.9.97

 xref _AbsExecBase
 xref _LVOOPenLibrary
 xref _LVOCloseLibrary
 xref _LVODisplayBeep

* macro to open intuition library (EQ if bad)
intopen: macro
 move.l _AbsExecBase,a6
 lea intname,a1
 moveq #37,d0
 jsr _LVOOpenLibrary(a6)
 move.l d0,intbase
 endm

* macro top close intuition library
intclos: macro
 move.l _AbsExecBase,a6
 move.l intbase,a1
 jsr _LVOCloseLibrary(a6)
 endm

* macro to beep all screens
beep: macro
 move.l intbase,a6
 sub.l a0,a0
 jsr _LVODisplayBeep(a6)
 endm

* beep all screens
Program:
 intopen                 ;open intuition.library
 beq.s Abort             ;go if can't
 beep                    ;beep all screens
 intclos                 ;close intuition.library
 moveq #0,d0             ;quit good
 rts
Abort:
 moveq #-1,d0            ;quit bad
 rts

* data
intname: dc.b 'intuition.library',0
 ds.w 0
intbase: ds.l 1
