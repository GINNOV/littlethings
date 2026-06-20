* 20.asm    try out an include    version 0.00 1.9.97

 bra Start

*                        **** IMPORTANT ****
*
* The INCLUDE below assumes that Tandem is at the root of its device, e.g.
* in WORK:. If it is not, modify the path :Tandem/Teaching/20.i so
* 16.i will be found. (Later I will introduce TLprogdir to solve this
* problem)

 include ':Tandem/Teaching/20.i'     ;(includes subroutine Beep)

 xref _AbsExecBase
 xref _LVOOpenLibrary
 xref _LVOCloseLibrary

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
 bsr Beep                 ;beep screens
 move.l a6,a1
 move.l _AbsExecBase,a6
 jsr _LVOCloseLibrary(a6) ;close intuition.library
 clr.l d0                 ;quit good
 rts
Abort:
 moveq #-1,d0             ;quit bad
 rts
