****************************
* This is another one of   *
* those useless 'Boing'    *
* type things.             *
*                          *
* written by:              *
* E. Lenz                  *
* Johann-Fichte-Strasse 11 *
* 8 Munich 40              *
* Germany                  *
*                          *
****************************

_AbsExecBase      equ 4

**** exec *****

_LVOForbid       equ -$84
_LVOPermit       equ -$8a
_LVOAllocMem     equ -$c6
_LVOFreeMem      equ -$d2
_LVOGetMsg       equ -$174
_LVOReplyMsg     equ -$17a
_LVOWaitPort     equ -$180
_LVOCloseLibrary equ -$19e
_LVOOpenLibrary  equ -$228

**** Graphics ****

_LVOGetSprite    equ -$198
_LVOFreeSprite   equ -$19e
_LVOChangeSprite equ -$1a4

**** Dos ***

_LVODelay        equ -$c6

pr_MsgPort       equ $5c
pr_CLI           equ $ac
ThisTask         equ $114
VBlankFrequency  equ $212

      movea.l _AbsExecBase,a6     test if WB or CLI
      movea.l ThisTask(a6),a0
      moveq   #0,d0
      tst.l   pr_CLI(a0)
      bne.s   isCLI

      lea     pr_MsgPort(a0),a0   for WB get WB Message
      jsr     _LVOWaitPort(a6)
      jsr     _LVOGetMsg(a6)

isCLI move.l  d0,-(a7)

      cmpi.b  #60,VBlankFrequency(a6) test if PAL or NTSC
      beq.s   isNTS
      move.w  #242,tryy+2
      move.w  #242,triy+2

isNTS move.l  #Imend-SimpleSprite,d0
      moveq   #2,d1               chip memory
      jsr     _LVOAllocMem(a6)
      move.l  d0,sprite1
      beq.s   Gexit

      move.l  d0,d1
      add.l   #Site-SimpleSprite,d1
      move.l  d1,sprite2

      lea     SimpleSprite(pc),a0
      movea.l d0,a1
      move.l  #Imend-SimpleSprite-1,d0
trans move.b  (a0)+,(a1)+
      dbra    d0,trans

      lea     DosName(pc),a1      open dos library
      moveq   #0,d0
      jsr     _LVOOpenLibrary(a6)
      movea.l d0,a5
      tst.l   d0
      beq.s   Gexit

      lea     GfxName(pc),a1      open graphics library
      moveq   #0,d0
      jsr     _LVOOpenLibrary(a6)
      movea.l d0,a4
Gexit beq     exit

      movea.l d0,a6
      moveq   #-1,d0               set sprite Nr. 1
      movea.l sprite1(pc),a0
      jsr     _LVOGetSprite(a6)
      move.w  d0,No1

      moveq   #-1,d0               set sprite Nr. 2
      movea.l sprite2(pc),a0
      jsr     _LVOGetSprite(a6)
      move.w  d0,No2

      moveq   #8,d3
      moveq   #5,d4
      moveq   #-8,d5
      moveq   #6,d6

loop  movea.l a5,a6               wait a while
      moveq   #1,d1
      jsr     _LVODelay(a6)
      movea.l a4,a6
      suba.l  a0,a0               no ViewPort
      movea.l sprite1(pc),a1
      lea     Image-SimpleSprite(a1),a2
      add.w   d3,6(a1)            increment X-pos
      add.w   d4,8(a1)            increment Y-Pos
      jsr     _LVOChangeSprite(a6) set sprite

      suba.l  a0,a0               no ViewPort
      movea.l sprite2(pc),a1
      lea     Imag-Site(a1),a2    pointer to sprite data
      add.w   d5,6(a1)            increment X-pos
      add.w   d6,8(a1)            increment Y-Pos
      jsr     _LVOChangeSprite(a6) set sprite

      btst    #6,$bfe001          mouse clicked?
      beq.s   exit

      movea.l sprite1(pc),a1      check boundries
      cmpi.w  #300,6(a1)
      bge.s   negx
      tst.w   6(a1)
      bpl.s   tryy
negx  neg.w   d3
tryy  cmpi.w  #184,8(a1)
      bge.s   negy
      tst.w   8(a1)
      bpl.s   next
negy  neg.w   d4

next  movea.l sprite2(pc),a1
      cmpi.w  #300,6(a1)
      bge.s   notx
      tst.w   6(a1)
      bpl.s   triy
notx  neg.w   d5
triy  cmpi.w  #184,8(a1)
      bge.s   noty
      tst.w   8(a1)
      bpl.s   Glop
noty  neg.w   d6
Glop  bra     loop

exit  move.l  sprite1(pc),d0
      beq.s   nosp1
      movea.l _AbsExecBase,a6
      movea.l d0,a1
      move.l  #Imend-SimpleSprite,d0
      jsr     _LVOFreeMem(a6)

      movea.l a4,a6               remove sprite
      move.w  No1(pc),d0
      jsr     _LVOFreeSprite(a6)

nosp1 move.l  sprite2(pc),d0      remove sprite
      beq.s   nosp2
      move.w  No2(pc),d0
      jsr     _LVOFreeSprite(a6)

nosp2 movea.l _AbsExecBase,a6
      move.l  (a7)+,d0
      beq.s   NoBen
      jsr     _LVOForbid(a6)      reply to WB
      movea.l d0,a1
      jsr     _LVOReplyMsg(a6)
      jsr     _LVOPermit(a6)

NoBen move.l  a4,d1               close graphics library
      beq.s   noGfx
      movea.l d1,a1
      jsr     _LVOCloseLibrary(a6)

noGfx move.l  a5,d1
      beq.s   noDos
      movea.l d1,a1
      jsr     _LVOCloseLibrary(a6)

noDos moveq   #0,d0               no error
      rts


No1      dc.w 0
sprite1  dc.l 0
No2      dc.w 0
sprite2  dc.l 0

GfxName dc.b  'graphics.library',0
        even

DosName dc.b 'dos.library',0
        even

* SimpleSprite structures

SimpleSprite dc.w  0,0   pointer to image
      dc.w 16,0,0        height, X- aund Y-pos
      dc.w 0             sprite number

Image dc.l  0            sprite data
      dc.l  %00000111111000000000000000000000
      dc.l  %00011100001110000000000000000000
      dc.l  %00111100001111000000000000000000
      dc.l  %01111100001111100000000000000000
      dc.l  %01000011110000100000000000000000
      dc.l  %10000011110000010000000000000000
      dc.l  %10000011110000010000000000000000
      dc.l  %11111100001111110000000000000000
      dc.l  %11111100001111110000000000000000
      dc.l  %11111100001111110000000000000000
      dc.l  %10000011110000010000000000000000
      dc.l  %01000011110000100000000000000000
      dc.l  %01000011110000100000000000000000
      dc.l  %00111100001111100000000000000000
      dc.l  %00011100001110000000000000000000
      dc.l  %00000111111000000000000000000000
      dc.l  0

Site  dc.w  0,0        pointer to image
      dc.w 16,300,0    height, X- aund Y-pos
      dc.w 0           sprite number

Imag  dc.l  0            sprite data
      dc.l  %00000111111000000000011111100000
      dc.l  %00011100001110000001110000111000
      dc.l  %00111100001111000011110000111100
      dc.l  %01111100001111100111110000111110
      dc.l  %01000011110000100100001111000010
      dc.l  %10000011110000011000001111000001
      dc.l  %10000011110000011000001111000001
      dc.l  %11111100001111111111110000111111
      dc.l  %11111100001111111111110000111111
      dc.l  %11111100001111111111110000111111
      dc.l  %10000011110000011000001111000001
      dc.l  %01000011110000100100001111000010
      dc.l  %01000011110000100100001111000010
      dc.l  %00111100001111100011110000111110
      dc.l  %00011100001110000001110000111000
      dc.l  %00000111111000000000011111100000
      dc.l  0
Imend:
      end
