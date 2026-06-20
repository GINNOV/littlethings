* Teaching/48.asm        version 0.00  16.9.97     datatypes

 include 'Front.i'

dbbase: ds.l 1
object: ds.l 1

strings: dc.b 0
st_1: dc.b 'Picture Window',0 ;1
 dc.b 'datatypes.library',0 ;2
st_3: dc.b 'WORK2:Art/ClipArt1/Comput2.iff',0 ;3
 dc.b 'Can''t open datatypes.library',0 ;4
 dc.b 'Can''t open window',0 ;5
 dc.b 'Can''t get object',0 ;6
 ds.w 0

Program:
 TLstrbuf #2
 move.l xxp_sysb(a4),a6
 move.l a4,a1
 moveq #37,d0
 jsr _LVOOpenLibrary(a6)
 move.l d0,dbbase
 beq Pr_bad
 TLwindow #0,#0,#0,#640,#200,#640,#200,#0,#st_1
 beq.s Pr_bad2
 bsr Picture
 beq Pr_bad3
Pr_quit:
 move.l xxp_sysb(a4),a6
 move.l dbbase,a1
 jsr _LVOCloseLibrary(a6)
 rts
Pr_bad:
 TLbad #4
 rts
Pr_bad2:
 TLbad #5
 bra Pr_quit
Pr_bad3:
 TLbad #6
 bra Pr_quit

* load a picture using datatypes
Picture:
 subq.l #4,a7              ;create object
 move.l a7,a0
 move.l #TAG_END,(a0)
 move.l dbbase,a6
 move.l #st_3,d0
 jsr _LVONewDTObjectA(a6)
 addq.l #4,a7
 move.l d0,object
 beq Pi_bad
 move.l xxp_AcWind(a4),a5  ;attach object
 move.l xxp_Window(a5),a0
 sub.l a1,a1
 move.l object,a2
 moveq #-1,d0
 jsr _LVOAddDTObject(a6)

 move.l xxp_intb(a4),a6
 move.l xxp_Window(a5),a1
 sub.l a2,a2
 move.l wd_FirstGadget(a1),a0
 moveq #-1,d0
 jsr _LVORefreshGList(a6)

 TLkeyboard                ;wait for response
 move.l xxp_Window(a5),a0  ;remove from window
 move.l object,a1
 move.l dbbase,a6
 jsr _LVORemoveDTObject(a6)
 move.l object,a0          ;dispose of object
 jsr _LVODisposeDTObject(a6)
 moveq #-1,d0
 rts
Pi_bad:
 moveq #0,d0            ;EQ if bad
 rts
