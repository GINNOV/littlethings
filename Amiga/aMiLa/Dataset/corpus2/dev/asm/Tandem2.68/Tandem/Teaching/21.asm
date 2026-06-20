* 21.asm    introduce IncAll.i    version 0.00   1.9.97

 bra Start                 ;go to cold start

 include 'IncAll.i'        ;get all Amiga OS3.1 FD's and .i's

intname: dc.b 'intuition.library',0
 ds.w 0
intbase: ds.l 1

Start:
 move.l _AbsExecBase,a6   ;open intuition.library
 lea intname,a1
 moveq #37,d0             ;at least release 2.04
 jsr _LVOOpenLibrary(a6)
 move.l d0,intbase
 beq.s Abort              ;go if can't open
 move.l intbase,a6
 sub.l a0,a0
 jsr _LVODisplayBeep(a6)  ;beep screens
 move.l a6,a1
 move.l _AbsExecBase,a6
 jsr _LVOCloseLibrary(a6) ;close intuition.library
 clr.l d0                 ;quit good
 rts
Abort:
 moveq #-1,d0             ;quit bad
 rts
