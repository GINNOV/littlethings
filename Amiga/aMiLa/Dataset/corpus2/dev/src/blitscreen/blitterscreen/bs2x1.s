* Standard beginner code

* $VER: d.s (7.5.95)

   SECTION DEMO

   INCLUDE d.8.95.i

* -----MEM definitions

***chip equ 100*1024

   clrstruct
*
   struct cop0,4096
   struct cop1,4096

   struct scr0,320*256
   struct scr1,320*256
   struct ch0,320*256
   struct ch1,320*256
   struct buf2,320*256*2
   struct sblbuf,320*256
   struct sprbuf,(312*8*2)*8
*
   struct chipend,1
chip equ chipend      
* - - - - - - -
***fast equ 100*1024
*
   clrstruct
*
   struct blist,40*1024 ;?
*
   struct fastend,1
fast equ fastend

*----Copperlistheader for blitterscreen, to be copied to chipmem (!)
copl:
     dc.l $01fc000f ;fmode=3  ;SPRfmode=3 ; 2x1: no SCANDOUBLE planes
     dc.l $00968100           ;plane dma on line 0
     dc.l $01000211,$01020000 ;LORES 8 planes, ECS on for bblank
     dc.l $0104003f           ;$104 sprite priority!
     dc.l $01060020           ;$1060020: bblank
     dc.l $010c0000           ;$10c: sprite-colorbank (!)
     dc.l $01080000,$010a0000 ;2x1: modulos 0
     dc.l $008e2881,$009028c1 ;display window
     dc.l $00920038,$009400a0 ;ddfstrt/stp values for 320pix-width-plane

* don't look at copl2, it's used by my startup-code...
* don't forget to put $fffffffe into your coplist after calling mk2xY!

copl2:
     dc.l $00e00000,$00e20000
     dc.l $00e40000,$00e60002
     dc.l $00e80000,$00ea0004
     dc.l $00ec0000,$00ee0006
     dc.l $00f00000,$00f20008
     dc.l $00f40000,$00f6000a
     dc.l $00f80000,$00fa000c
     dc.l $00fc0000,$00fe000e
coplend:
     dc.l $fffffffe

* ==============================
prg:
   include bltscr.h

** INTERRUPTs
   move.w #$0030,$dff09c
   move.l _vbr,a0 : lea $6c(a0),a0 : move.l #int3,(a0)
   move.w #$8060,$dff09a


* SCREEN
   move.l chipmem,a0 : add.l #cop0,a0
   move.l chipmem,a1 : add.l #scr0,a1
   jsr mkbltscr                         ;create coplist

   move.l chipmem,a0 : add.l #cop0,a0 : move.l a0,$dff080


   move.l chipmem,a0 : add.l #ch0,a0
   move.w #320*256/4-1,d7
clch:
   move.l #$ffffffff,(a0)+ : dbra d7,clch

   move.l chipmem,a0 : add.l #scr0,a0
   move.w #320*256/4-1,d7
clscr:
   move.l #$00000000,(a0)+ : dbra d7,clscr
***

   move.l fastmem,a6 : add.l #blist,a6    ;buffer for blitterlist

   move.l chipmem,a0 : add.l #ch0,a0      ;chunky buffer
   move.l chipmem,a1 : add.l #scr0,a1     ;planar screen; 4 planes (memwise)

   move.l chipmem,a2 : add.l #buf2,a2     ;pass-buffer
   move.l chipmem,a3 : add.l #sblbuf,a3   ;scramble-buffer

   move.l #160*256,d0                     ;nr of chunky pixels
   move.l #320*256/8,d1                   ;distance of the 4 planes

  movem.l d0-d7/a0-a6,-(sp)
   jsr sc2bs                 ;hehehe =:)) adios copperscreen...
  movem.l (sp)+,d0-d7/a0-a6

***
   move.l chipmem,a5 : add.l #ch0,a5
   lea scramble,a4

;actually #?c2bs tests for blitterqueue finished, too
;just to let you know the flag (all jobs done: flag=0)
loop:
   tst.w bltbsy : bne loop

   move.l timer,d0 : add.l #0,d0
wvbl:
   cmp.l timer,d0 : bge wvbl

*
   move.l fastmem,a6 : add.l #blist,a6    ;buffer for blitterlist
   move.l a6,bltpc         ;blitterqeue
   move.w #1,bltbsy        ;important!
   move.w #$8040,$dff09c   ;activate blit intreq, blitter starts now.
*

   move.b d4,(a5) : add.b #$1,d4

;this line if called c2bs
***   addq.w #1,a5 ;no scramble :)
;this line if called sc2bs
   add.w (a4)+,a5 : cmp.l #scrambleend,a4 : bne noadj : lea scramble,a4
noadj:

wait:
   move.w #0,$dff182
   btst #2,$dff016
   bne loop

prgrts:
   tst.w bltbsy : bne prgrts
   rts

scramble dc.w 4,-2,4,-5,4,-2,4,1 ; =@)
scrambleend:

*** COPPERLIST FOR BLITTERSCREEN
* a0: copscr
* a1: scr

mkbltscr:
   move.l a1,-(sp)     ;#^#

;stdheader
   move.l #copl,a3 : move.l #copl2-copl,d1

   move.l chipmem,a1
   add.l #scr0,a1
   move.l #320*256/8,d0
   jsr maksimplecop

   move.l (sp)+,a1     ;#^#

** 2xY
   move.l a1,d0   ;adr plane0

   move.l #$28,d2 ;ystart 
   move.l #128,d3 ;anz lines
   move.l #40*256,d4 ;planesize
   move.l #40,d5     ;linesize

   move.l chipmem,a2 : add.l #sprbuf,a2

   jsr mk2xY

** don't forget this! (feel free to add your own copper stuff)
   move.l #$fffffffe,(a0)+

   rts

   END

