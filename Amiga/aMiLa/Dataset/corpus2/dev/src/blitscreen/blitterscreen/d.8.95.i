* STANDARD STARTUP include

* $VER: d.i (22.6.95) still bugs when os-blitting active....

* ---------------
clearcache MACRO
   movem.l d0-d7/a0-a6,-(sp)
   move.l 4,a6 : cmp.w #37,$14(a6) : bcs.s nokick2\@
   jsr -636(a6) ;CacheClearU()
nokick2\@:
   movem.l (sp)+,d0-d7/a0-a6
   ENDM
waitblt MACRO
   btst #6,$dff002 ;old blitters said to have bug...
waitblt\@:
   btst #6,$dff002
   bne waitblt\@
   ENDM
waitvbl MACRO
   move.w #$0020,$dff09c
waitvbl\@:
   btst #5,$dff01f
   beq waitvbl\@
   ENDM

waitrast MACRO
   cmp.b \1,0        ;U maybe used no # calling waitrast ? :)
   movem.l d0-d1/a0,-(sp)
   lea $dff004,a0
waitrast\@:
   move.l (a0),d0
   and.l #$1ff00,d0
   move.l (a0),d1
   move.l (a0),d1
   move.l (a0),d1
   move.l (a0),d1
   and.l #$1ff00,d1
   cmp.l d1,d0
   bne.s waitrast\@
   cmp.l \1,d0
   bne.s waitrast\@
   movem.l (sp)+,d0-d1/a0
   ENDM

clrstruct MACRO
structptr set 0
   ENDM
struct MACRO
\1 set structptr
structptr set structptr+\2
   ifeq \2
     WARNING! STRUCTLEN of \1 = 0!
   endc
   ENDM

fillb MACRO ;ADR NUM VAL ADD
   add.b \2,filldummy ;trick: only immed/reg adressing allowed
   movem.l d5/d6/d7/a6,-(sp)
   move.l \1,a6
   move.l \2,d7
   move.b \3,d5
   move.b \4,d6
fill\@: move.b d5,(a6)+
   add.l d6,d5
   sub.l #1,d7
   bne fill\@
   movem.l (sp)+,d5/d6/d7/a6
   ENDM
fillw MACRO
   add.b \2,filldummy
   movem.l d5/d6/d7/a6,-(sp)
   move.l \1,a6
   move.l \2,d7
   move.w \3,d5
   move.w \4,d6
fill\@: move.w d5,(a6)+
   add.l d6,d5
   sub.l #1,d7
   bne fill\@
   movem.l (sp)+,d5/d6/d7/a6
   ENDM
filll MACRO
   add.b \2,filldummy
   movem.l d5/d6/d7/a6,-(sp)
   move.l \1,a6
   move.l \2,d7
   move.l \3,d5
   move.l \4,d6
fill\@: move.l d5,(a6)+
   add.l d6,d5
   sub.l #1,d7
   bne fill\@
   movem.l (sp)+,d5/d6/d7/a6
   ENDM

   nop
   bra start
   rts ;for non-prec a68k-bug
start:

* MEM
   move.l #chip,d0
   cmp.l #chipend,d0
   bcs ret0
   move.l #fast,d0
   cmp.l #fastend,d0
   bcs ret0
;chip
   move.l 4,a6
   move.l #chip+65536,d0
   moveq #2,d1
   jsr -198(a6)
   move.l d0,chipmem0
   beq ret0 ;chipmem0 nur fürs system
   add.l #65536,d0
   and.l #$ffff0000,d0 ;64k border wg. slow copper
   move.l d0,chipmem
;fast
   move.l 4,a6
   move.l #fast+8192,d0 ;uhm 8k border for 040 caches :)
   moveq #0,d1
   jsr -198(a6)
   move.l d0,fastmem0
   beq ret1
   add.l #8192,d0
   and.l #-8192,d0
   move.l d0,fastmem

* LIBS
   move.l 4,a6
   lea intname,a1
   moveq #0,d0
   jsr -552(a6) ;openlib
   move.l d0,intuibase
   beq ret2

   lea grafname,a1
   moveq #0,d0
   jsr -552(a6)
   move.l d0,gfxbase
   beq ret3

* Own blitter before changing vecs or copl
   waitblt
   move.l gfxbase,a6
   jsr -456(a6) ;OWN Blitter

* INT: GETVBR
   moveq #0,d0
   move.l 4,a6
   btst #0,$129(a6) ;flags...
   beq.s storevbr
   lea getvbr0(pc),a5
   jsr -$1e(a6)  ;Supervisor()
   bra.s storevbr
getvbr0:
   dc.l $4e7a0801 ;movec vbr,d0
   rte
_vbr dc.l 0
storevbr:
   move.l d0,_vbr

* INT3 VECTOR
   move.l _vbr,a0
   move.l $6c(a0),oldv ;!­!­! Lev3 VBL / BLTINT

* RESET SCREEN-HARDWARE
   move.l gfxbase,a6
   move.l $22(a6),oldviev
   move.l #0,a1
   jsr -222(a6) ;Loadview (0)

   move.w #25-1,d7
nowaittof:
   waitvbl
   dbra d7,nowaittof

   move.w #$0020,$dff096
   move.w #$81c0,$dff096

* CALL ----------------
   bsr prg ;copl done by prg
* END -----------------
ret: ;from prg
* INTVEC
   move.w #$4000,$dff09a ;for the case still blt-ints running

   move.l _vbr,a0
   move.l oldv,$6c(a0) ;!­!­! INT

* RESTORE SYSTEM-Screen
   waitblt
   waitblt
   waitblt
   move.w #$07fc,$dff09c ;kill hardwarehack-requests
   move.w #$c000,$dff09a ;sys on for jsr's

   move.l gfxbase,a6
   jsr -462(a6) ;DISOWN Blitter
   move.l oldviev,a1
   jsr -222(a6) ;LoadView(prev gb_ActiView)

   move.w #$0080,$dff096
   move.l gfxbase,a0
   move.l $26(a0),$dff080   ;gb_copinit => CopPtr
***   move.l $32(a0),$dff084 ;copl2 (?)

   move.w #0,$dff088
   move.w #$81a0,$dff096

   move.l intuibase,a6
   jsr -390(a6) ;Rethinkdisplay
 
   move.l gfxbase,a1
   move.l 4,a6
   jsr -414(a6) ;closelib
ret3:
   move.l intuibase,a1
   move.l 4,a6
   jsr -414(a6) ;closelib
ret2:
   move.l fastmem0,a1
   move.l #fast+8192,d0
   move.l 4,a6
   jsr -210(a6)
ret1:
   move.l chipmem0,a1
   move.l #chip+65536,d0
   move.l 4,a6
   jsr -210(a6)
ret0:
   clr.l d0
   rts
* ---
d8 dc.l 0
d9 dc.l 0
d10 dc.l 0
d11 dc.l 0
d12 dc.l 0
d13 dc.l 0
d14 dc.l 0
d15 dc.l 0

oldv dc.l 0
oldviev dc.l 0

chipmem dc.l 0
chipmem0 dc.l 0
fastmem dc.l 0
fastmem0 dc.l 0

filldummy dc.l 0

gfxbase dc.l 0
intuibase dc.l 0

grafname dc.b 'graphics.library',0
intname dc.b 'intuition.library',0
   EVEN

* MAKECOP : $fffffffe,(a0)+ noch fällig !!!
* copl a0 scr a1 planeoffs d0
* COPLDATA a3! COPLLEN (ohne copl2puts) d1!
* still pokes in copl2 of d.s BTW

maksimplecop:
   movem.l d1,-(sp) ;!!

   move.l #copl2+2,a2
   move.w #8-1,d7
   move.l a1,d1
   ext.l d0 ;offs .w
maksimplecop0:
   swap d1
   move.w d1,(a2)
   addq.w #4,a2
   swap d1
   move.w d1,(a2)
   addq.w #4,a2
   add.l d0,d1
   dbra d7,maksimplecop0

***   move.l #copl,a2
   move.l a3,a2 ;NEW

***   move.l #coplend-copl-1,d7  OLD: len is header without copl2 now!
   movem.l (sp)+,d7 ;!! NEW
   subq.w #1,d7
maksimplecop1:
   move.b (a2)+,(a0)+
   dbra d7,maksimplecop1

; cp updated copl2
   lea copl2,a2
   move.l #4*2*8-1,d7
maksimplecop2:
   move.b (a2)+,(a0)+
   dbra d7,maksimplecop2
   rts

