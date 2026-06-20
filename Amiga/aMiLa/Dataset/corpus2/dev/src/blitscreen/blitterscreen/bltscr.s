
*### BLITTERSCREEN:
*### 2x2 / 2x1 fullscreen, copperscreen obsolete! =:)

   xdef int3

   xdef bltbsy
   xdef bltpc

   xdef timer
   xdef timer2
   xdef oldtimer

   xdef customvbl

timer dc.l 0   ;sum vbl-timers...
timer2 dc.l 0
oldtimer dc.l 0

waitblt MACRO
   btst #6,$dff002 ;old blitters said to have bug...
waitblt\@:
   btst #6,$dff002
   bne waitblt\@
   ENDM
* -----------

show2 equ 0 ;equ 1 show rastertiming of blitterpasses

*** HARDWAREHACK INT HANDLER
int3:
   btst #6,$dff01f
   beq.s nobltint

bltint:
   move.w #$0040,$dff09c

   movem.l d0-d1/a5/a6,-(sp)
   move.l #$dff000,a5
   move.l bltpc(pc),a6

   IFNE show2
   move.w #$0ff,$dff180  ;blt reload
   ENDC
bltsetreg:
   move.l (a6)+,d0
   move.w d0,d1 : beq.s bltintend : swap d0
   move.w d0,0(a5,d1.w)

   cmp.w #$5e,d1 : beq.s bltstarted
   cmp.w #$58,d1 : bne.s bltsetreg
* ---
bltstarted:
   move.l a6,bltpc
   movem.l (sp)+,d0-d1/a5/a6

   IFNE show2
   move.w #$800,$dff180  ;blt works
   ENDC
   rte

bltintend:
   clr.w bltbsy
   movem.l (sp)+,d0-d1/a5/a6

   IFNE show2
   move.w #$000,$dff180 ;blt rdy
   ENDC
   rte

nobltint:
   btst #5,$dff01f
   bne.s vblint
   btst #4,$dff01f
   bne.s copint
* huh ?
   move.w #$3fff,$dff09c ;kill all requests to avoid(?) delirium
   rte

bltpc dc.l 0  ;pointer to blitterinstructions to be done
bltbsy dc.w 0 ;this is 0 if all blitter-passes are done

vblint:
   move.w #$0020,$dff09c
   movem.l d0-d7/a0-a6,-(sp)

   move.l customvbl,a0 : jsr (a0) ;CUSTOM ROUTINE HERE!

   add.l #1,timer : add.l #1,timer2

   move.w #$0020,$dff09c
   movem.l (sp)+,d0-d7/a0-a6
   rte

copint: ;theoretical you never get here...
   move.w #$0010,$dff09c
   rte

customvbl dc.l customvbl0
customvbl0:
   rts

*** 2xY: Make a special 2x2 or 2x1 screen ***

* NOTE: 2x2 or 2x1 depends on the modulo/doublescan-bit you chose
* in header coplist! Also make sure sprites are 64bit, highest
* pri, and chose the spritebank that got a dark color at offset 1
* (col 1,17,33....)

* IN: ALL BUFFERS IN CHIPMEM!!!

* spritebuffer: a2 (size: 312*4*2*8)
* Coplist: A0  Plane0 : D0.L

* Ystart: D2   number of lines (0-127): D3
* planesize: D4.L   linesize: D5

mfpoffs dc.l 0 ;not used by caller
mfloffs dc.l 0

mk2xY:
   xdef mk2xY

   jsr mspr ;gen cover-sprites in (a2)+ and copmoves in (a0)+

* PLANES
   movem.l d0-d7/a1-a6,-(sp) ;a0=(ptr)copl

   move.l d4,mfpoffs : ext.l d5 : move.l d5,mfloffs

* gen planeptr moves
   movem.l d3/d0,-(sp)
   move.w #$00e0,d3 : move.w #4-1,d7
mf256genhi:
   move.w d3,(a0)+ : addq.w #2,d3 : move.l d0,(a0)+  ;store hiwd ! -2(a0)
   move.w d3,-2(a0) : addq.w #2,d3 : move.w d0,(a0)+ ;store lowd
;every 2nd plane same data
   move.w d3,(a0)+ : addq.w #2,d3 : move.l d0,(a0)+  ;store hiwd ! -2(a0)
   move.w d3,-2(a0) : addq.w #2,d3 : move.w d0,(a0)+ ;store lowd

   add.l mfpoffs,d0
   dbra d7,mf256genhi
* end gen ptrs
   movem.l (sp)+,d3/d0

   and.l #$ff,d2 : sub.b #1,d2 : ror.l #8,d2   ;sub #1: prev line
   move.l #$00e1fffe,d4 : or.l d2,d4           ;WAS: 00df
*
   move.w d3,d5
   subq.w #1,d5
mf256yanz:
   move.l #$1020010,d7
   move.w #2-1,d6
mf256do2:
   move.l d4,(a0)+ : add.l #$01000000,d4  ;cwait
   move.l d7,(a0)+ : eor.l #$00000031,d7  ;horiz shift
                     ;             ^---- 3: 1 -> 2 -> 1 -> 2 ....
   dbra d6,mf256do2

   add.l mfloffs,d0
   dbra d5,mf256yanz

   movem.l (sp)+,d0-d7/a1-a6 ;a0=(ptr)copl
   rts

* Sprites that mask out doubleplane-data-rubbish

* sprbuf at a2 (COPLIST: FMODE=$F, $dff104=$003f!)
* copl at a0
* mksprites into sprbuf=(a2)+ and according coppermoves in (a0)+
mspr:
   xdef mspr

   movem.l d0-d7/a1-a6,-(sp) ;no a0! coz *copl

   move.l #$00968020,(a0)+ ;rehash sprites (for safety)

   lea mf2sprdat,a1

   move.l a2,d0
   add.l #15,d0
   and.l #$fffffff0,d0
   move.l d0,a2 ;align

   move.w #$0120,d1 ;spr0pth

   move.w #8-1,d7 ;sprcnt
mf2mkspr:
* cmoves for sprptr in copl

   move.l a2,d0
   move.w d1,(a0)+
   addq.w #2,d1 ;hiptr -> loptr
   swap d0
   move.w d0,(a0)+
   swap d0 ;hiwd
   move.w d1,(a0)+
   addq.w #2,d1 ;next sprptr
   move.w d0,(a0)+

* make sprbuf
   move.l (a1)+,(a2)+ ;ctl1
   move.l #0,(a2)+    ;dummy for 64bit fetchmode
   move.l (a1)+,(a2)+ ;ctl2
   move.l #0,(a2)+    ;dummy for 64bit fetchmode

   move.l (a1)+,d2
   move.l (a1)+,d3
   move.l d2,d4
   ror.l #1,d4
   move.l d3,d5
   ror.l #1,d5

   move.w #128-1,d6
mf2mksprdat:
   move.l d2,(a2)+
   move.l d2,(a2)+
   move.l d3,(a2)+
   move.l d3,(a2)+
;2nd line
   move.l d4,(a2)+
   move.l d4,(a2)+
   move.l d5,(a2)+
   move.l d5,(a2)+                ;2nd plane

   dbra d6,mf2mksprdat

   move.l #$0,(a2)+
   move.l #$0,(a2)+
   move.l #$0,(a2)+
   move.l #$0,(a2)+

   dbra d7,mf2mkspr

   movem.l (sp)+,d0-d7/a1-a6 ;ohne a0! weil *copl
   rts

* ctl 1, ctl 2, plane 0, plane 1 (to be lsr'd for 2nd line)
mf2sprdat:
   dc.l $28400000,$a7020000,$aaaaaaaa,$00000000
   dc.l $28600000,$a7020000,$aaaaaaaa,$00000000 ;1 & 2 nonattached, col 1 :)
   dc.l $28800000,$a7020000,$aaaaaaaa,$00000000
   dc.l $28800000,$a7820000,$00000000,$00000000
   dc.l $28a00000,$a7020000,$aaaaaaaa,$00000000
   dc.l $28a00000,$a7820000,$00000000,$00000000
   dc.l $28c00000,$a7020000,$aaaaaaaa,$00000000
   dc.l $28c00000,$a7820000,$00000000,$00000000

*** non-scrambled chunky-to-planar ***
* not really c2p (!), destination is special 2x2 or 2x1 screen
*
* IN: ALL BUFFERS IN CHIPMEM *except blitterlist (a6)*  !!!
*
*  a3: scramble-buffer at size of chunky buffer
*
* other regs identical to sc2bs ! they are:
*
*  a6: blitter-list buffer (size: less than 2k)
*  a0: chunky buffer  a1: screen  a2: pass-buffer (half size of chunky buffer)
*  d0.l: number of chunky pixels  d1.l: planeoffset

c2bs:
   xdef c2bs

   tst.w bltbsy : bne c2bs ;for the very unlikely case your mapping-
                           ;engine renders faster than blitterc2p ;)
                                                      
   move.l a6,bltpc ;handler starts at bltpc

   movem.l d0-d1/a0-a3,-(sp)
   move.l a3,a4 ;well....

*** init values

   move.l #$04000096,(a6)+
   move.l #$80400096,(a6)+

   move.l #$ffff0044,(a6)+
   move.l #$ffff0046,(a6)+

*** scrambling passes
;subpass 1
  lea (a0),a3
   move.l a3,(a6)+ : move.w #$004c,-2(a6) ;B
   move.w a3,(a6)+ : move.w #$004e,(a6)+
  lea 4(a0),a3
   move.l a3,(a6)+ : move.w #$0050,-2(a6) ;A
   move.w a3,(a6)+ : move.w #$0052,(a6)+
  lea (a4),a3
   move.l a3,(a6)+ : move.w #$0054,-2(a6) ;D
   move.w a3,(a6)+ : move.w #$0056,(a6)+

   move.l #$8de40040,(a6)+
   move.l #$00000042,(a6)+
   move.l #$00ff0070,(a6)+ ;cdat

   move.l #$00060064,(a6)+ : move.l #$00060062,(a6)+ ;a/b mod
   move.l #$00060066,(a6)+ ;d mod

   move.l d0,d6 : lsr.l #3,d6 ;1/4 of scr, words => /8
   move.w d6,(a6)+
   move.w #$5C,(a6)+       ;SIZV

   move.l #$0001005E,(a6)+ ;SIZH+start

;subpass2
  lea 2(a0),a3
   move.l a3,(a6)+ : move.w #$004c,-2(a6) ;B
   move.w a3,(a6)+ : move.w #$004e,(a6)+
  lea 6(a0),a3
   move.l a3,(a6)+ : move.w #$0050,-2(a6) ;A
   move.w a3,(a6)+ : move.w #$0052,(a6)+
  lea 2(a4),a3
   move.l a3,(a6)+ : move.w #$0054,-2(a6) ;D
   move.w a3,(a6)+ : move.w #$0056,(a6)+

   move.l #$8de40040,(a6)+
   move.l #$00000042,(a6)+
   move.l #$00ff0070,(a6)+ ;cdat

   move.l #$00060064,(a6)+ : move.l #$00060062,(a6)+ ;a/b mod
   move.l #$00060066,(a6)+ ;d mod

   move.l d0,d6 : lsr.l #3,d6 ;1/4 of scr, words => /8
   move.w d6,(a6)+
   move.w #$5C,(a6)+       ;SIZV

   move.l #$0001005E,(a6)+ ;SIZH+start

;subpass 3
  lea -4(a0,d0.l),a3
   move.l a3,(a6)+ : move.w #$004c,-2(a6) ;B
   move.w a3,(a6)+ : move.w #$004e,(a6)+
  lea -8(a0,d0.l),a3
   move.l a3,(a6)+ : move.w #$0050,-2(a6) ;A
   move.w a3,(a6)+ : move.w #$0052,(a6)+
  lea -4(a4,d0.l),a3
   move.l a3,(a6)+ : move.w #$0054,-2(a6) ;D
   move.w a3,(a6)+ : move.w #$0056,(a6)+

   move.l #$8de40040,(a6)+
   move.l #$00020042,(a6)+
   move.l #$ff000070,(a6)+ ;cdat

   move.l #$00060064,(a6)+ : move.l #$00060062,(a6)+ ;a/b mod
   move.l #$00060066,(a6)+ ;d mod

   move.l d0,d6 : lsr.l #3,d6 ;1/4 of scr, words => /8
   move.w d6,(a6)+
   move.w #$5C,(a6)+       ;SIZV

   move.l #$0001005E,(a6)+ ;SIZH+start

;subpass 4
  lea -2(a0,d0.l),a3
   move.l a3,(a6)+ : move.w #$004c,-2(a6) ;B
   move.w a3,(a6)+ : move.w #$004e,(a6)+
  lea -6(a0,d0.l),a3
   move.l a3,(a6)+ : move.w #$0050,-2(a6) ;A
   move.w a3,(a6)+ : move.w #$0052,(a6)+
  lea -2(a4,d0.l),a3
   move.l a3,(a6)+ : move.w #$0054,-2(a6) ;D
   move.w a3,(a6)+ : move.w #$0056,(a6)+

   move.l #$8de40040,(a6)+
   move.l #$00020042,(a6)+
   move.l #$ff000070,(a6)+ ;cdat

   move.l #$00060064,(a6)+ : move.l #$00060062,(a6)+ ;a/b mod
   move.l #$00060066,(a6)+ ;d mod

   move.l d0,d6 : lsr.l #3,d6 ;1/4 of scr, words => /8
   move.w d6,(a6)+
   move.w #$5C,(a6)+       ;SIZV

   move.l #$0001005E,(a6)+ ;SIZH+start


***
   movem.l (sp)+,d0-d1/a0-a3

   move.l a3,a0                  ;scrambled data is now there
   bra sc2bsenter

*** scrambled chunky-to-planar =:) ***

sc2bs:
   xdef sc2bs

   tst.w bltbsy : bne sc2bs

   move.l a6,bltpc

sc2bsenter:

* IN: IN: ALL BUFFERS IN CHIPMEM *except blitterlist (a6)*  !!!
*
*  a6: blitter-list buffer (size: less than 2k)
*  a0: chunky buffer  a1: screen  a2: pass-buffer (half size of chunky buffer)
*  d0.l: number of chunky pixels  d1.l: planeoffset

*** init values
   move.l #$04000096,(a6)+
   move.l #$80400096,(a6)+

   move.l #$ffff0044,(a6)+
   move.l #$ffff0046,(a6)+

;offsets to end of buffers for blitter DESCing
   move.l d0,d6                   ;len of chscr
   move.l d6,d5 : lsr.l #1,d5     ;len of buf2
   move.l d6,d4 : lsr.l #2,d4     ;len of 1 plane = 320*128/8, ok.

*** Pass 1, planes 7654

  lea (a0),a3
   move.l a3,(a6)+ : move.w #$004c,-2(a6) ;B
   move.w a3,(a6)+ : move.w #$004e,(a6)+
  lea 2(a0),a3
   move.l a3,(a6)+ : move.w #$0050,-2(a6) ;A
   move.w a3,(a6)+ : move.w #$0052,(a6)+

   move.l a2,(a6)+ : move.w #$0054,-2(a6) ;D
   move.w a2,(a6)+ : move.w #$0056,(a6)+

   move.l #$4de40040,(a6)+
   move.l #$00000042,(a6)+
   move.l #$0f0f0070,(a6)+ ;cdat

   move.l #$00020064,(a6)+ : move.l #$00020062,(a6)+ ;a/b mod
   move.l #$00000066,(a6)+ ;d mod

   move.w d4,(a6)+         ;d4: nr_pix/4 (words!)
   move.w #$5C,(a6)+       ;SIZV

   move.l #$0001005E,(a6)+ ;SIZH+start

*** Pass 2, planes 76

  lea (a2),a3
   move.l a3,(a6)+ : move.w #$004c,-2(a6) ;B
   move.w a3,(a6)+ : move.w #$004e,(a6)+
  lea 2(a2),a3
   move.l a3,(a6)+ : move.w #$0050,-2(a6) ;A
   move.w a3,(a6)+ : move.w #$0052,(a6)+
  lea (a1),a3
   add.w d1,a3 : add.w d1,a3 : add.w d1,a3   ;4th "doubleplane"
   move.l a3,(a6)+ : move.w #$0054,-2(a6) ;D
   move.w a3,(a6)+ : move.w #$0056,(a6)+

   move.l #$2de40040,(a6)+
   move.l #$00000042,(a6)+
   move.l #$33330070,(a6)+ ;cdat

   move.l #$00020064,(a6)+ : move.l #$00020062,(a6)+ ;a/b mod
   move.l #$00000066,(a6)+ ;d mod

   move.w d4,d0 : lsr.w #1,d0
   move.w d0,(a6)+         ;d4: nr_pix/8 (words!)
   move.w #$5C,(a6)+       ;SIZV

   move.l #$0001005E,(a6)+ ;SIZH+start

*** Pass 2, planes 54

  lea -2(a2,d5.l),a3
   move.l a3,(a6)+ : move.w #$004c,-2(a6) ;B
   move.w a3,(a6)+ : move.w #$004e,(a6)+
  lea -4(a2,d5.l),a3
   move.l a3,(a6)+ : move.w #$0050,-2(a6) ;A
   move.w a3,(a6)+ : move.w #$0052,(a6)+
  lea -2(a1,d4.l),a3
  add.w d1,a3 : add.w d1,a3   ;3rd "doubleplane"
   move.l a3,(a6)+ : move.w #$0054,-2(a6) ;D
   move.w a3,(a6)+ : move.w #$0056,(a6)+

   move.l #$2de40040,(a6)+
   move.l #$00020042,(a6)+                ;DESC
   move.l #$cccc0070,(a6)+ ;cdat

   move.l #$00020064,(a6)+ : move.l #$00020062,(a6)+ ;a/b mod
   move.l #$00000066,(a6)+ ;d mod

   move.w d4,d0 : lsr.w #1,d0
   move.w d0,(a6)+         ;d4: nr_pix/8 (words!)
   move.w #$5C,(a6)+       ;SIZV

   move.l #$0001005E,(a6)+ ;SIZH+start

*** Pass 1, planes 3210

  lea -2(a0,d6.l),a3
   move.l a3,(a6)+ : move.w #$004c,-2(a6) ;B
   move.w a3,(a6)+ : move.w #$004e,(a6)+
  lea -4(a0,d6.l),a3
   move.l a3,(a6)+ : move.w #$0050,-2(a6) ;A
   move.w a3,(a6)+ : move.w #$0052,(a6)+
  lea -2(a2,d5.l),a3
   move.l a3,(a6)+ : move.w #$0054,-2(a6) ;D
   move.w a3,(a6)+ : move.w #$0056,(a6)+

   move.l #$4de40040,(a6)+
   move.l #$00020042,(a6)+
   move.l #$f0f00070,(a6)+ ;cdat

   move.l #$00020064,(a6)+ : move.l #$00020062,(a6)+ ;a/b mod
   move.l #$00000066,(a6)+ ;d mod

   move.w d4,(a6)+         ;d4: nr_pix/4 (words!)
   move.w #$5C,(a6)+       ;SIZV

   move.l #$0001005E,(a6)+ ;SIZH+start

*** Pass 2, planes 32

  lea (a2),a3
   move.l a3,(a6)+ : move.w #$004c,-2(a6) ;B
   move.w a3,(a6)+ : move.w #$004e,(a6)+
  lea 2(a2),a3
   move.l a3,(a6)+ : move.w #$0050,-2(a6) ;A
   move.w a3,(a6)+ : move.w #$0052,(a6)+
  lea (a1),a3
   add.w d1,a3   ;2nd "doubleplane"
   move.l a3,(a6)+ : move.w #$0054,-2(a6) ;D
   move.w a3,(a6)+ : move.w #$0056,(a6)+

   move.l #$2de40040,(a6)+
   move.l #$00000042,(a6)+
   move.l #$33330070,(a6)+ ;cdat

   move.l #$00020064,(a6)+ : move.l #$00020062,(a6)+ ;a/b mod
   move.l #$00000066,(a6)+ ;d mod

   move.w d4,d0 : lsr.w #1,d0
   move.w d0,(a6)+         ;d4: nr_pix/8 (words!)
   move.w #$5C,(a6)+       ;SIZV

   move.l #$0001005E,(a6)+ ;SIZH+start

*** Pass 2, planes 10

  lea -2(a2,d5.l),a3
   move.l a3,(a6)+ : move.w #$004c,-2(a6) ;B
   move.w a3,(a6)+ : move.w #$004e,(a6)+
  lea -4(a2,d5.l),a3
   move.l a3,(a6)+ : move.w #$0050,-2(a6) ;A
   move.w a3,(a6)+ : move.w #$0052,(a6)+
  lea -2(a1,d4.l),a3
     ;1st "doubleplane"
   move.l a3,(a6)+ : move.w #$0054,-2(a6) ;D
   move.w a3,(a6)+ : move.w #$0056,(a6)+

   move.l #$2de40040,(a6)+
   move.l #$00020042,(a6)+                ;DESC
   move.l #$cccc0070,(a6)+ ;cdat

   move.l #$00020064,(a6)+ : move.l #$00020062,(a6)+ ;a/b mod
   move.l #$00000066,(a6)+ ;d mod

   move.w d4,d0 : lsr.w #1,d0
   move.w d0,(a6)+         ;d4: nr_pix/8 (words!)
   move.w #$5C,(a6)+       ;SIZV

   move.l #$0001005E,(a6)+ ;SIZH+start

*** end of initblit
   move.l #0,(a6)+

   move.w #1,bltbsy ;!!!
   waitblt
   move.w #$8040,$dff09c ;activate blit intreq
   rts


   END

