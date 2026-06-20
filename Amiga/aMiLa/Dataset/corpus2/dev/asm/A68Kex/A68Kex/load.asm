***************************************
*  LOAD from disk                     *
*                                     *
* written by E. Lenz                  *
*            Johann-Fichte-Strasse 11 *
*            8 Munich 40              *
*            Germany                  *
*                                     *
***************************************

    XDEF load,file


********LOAD SECTOR ABSOLUTE***********
;  INPUT
; d0 Pointer to disk buffer
; d1 Sector number
; d2 Unit number
; a0 Pointer to sector number in ASCII
;

*****EXEC**************

_AbsExecBase     equ 4
_LVOAllocMem     equ -$c6
_LVOAddPort      equ -$162
_LVORemPort      equ -$168
_LVOCloseLibrary equ -$19e
_LVOOpenDevice   equ -$1bc
_LVOCloseDevice  equ -$1c2
_LVODoIo         equ -$1c8
_LVOOpenLibrary  equ -$228

*******DOS******

_LVOOpen        equ -$1e
_LVOClose       equ -$24
_LVORead        equ -$2a
_LVOWrite       equ -$30
_LVOOutput      equ -$3c
_LVOLock        equ -$54
_LVOUnLock      equ -$5a
_LVOExamine     equ -$66
_LVOLoadSeg     equ -$96
_LVOUnLoadSeg   equ -$9c

ThisTask        equ $114

load      move.l  a0,-(a7)
          move.w  d1,-(a7)
          move.l  d2,-(a7)
          movea.l d0,a5
          movea.l _AbsExecBase,a6
          move.l  ThisTask(a6),reply+$10

          lea     reply(pc),a1          add reply port
          jsr     _LVOAddPort(a6)

          move.l  (a7)+,d0              unit number
          moveq   #0,d1                 flags
          lea     trddevice(pc),a0      device name
          lea     diskio(pc),a1         iorequest
          jsr     _LVOOpenDevice(a6)
          tst.l   d0
          bne     error

          lea     diskio(pc),a1
          move.l  #reply,$e(a1)
          move.w  #2,$1c(a1)   command read
          move.l  a5,d0
          addi.l  #$10,d0
          move.l  d0,$28(a1)
          move.l  #$400,$24(a1)
          moveq   #0,d0        trackdisk offset sector number * 512
          move.w  (a7)+,d0
          mulu    #512,d0
          move.l  d0,$2c(a1)
          jsr     _LVODoIo(a6)    get sectors

          lea     diskio(pc),a1
          move.w  #9,$1c(a1)      command motor off
          clr.l   $24(a1)
          jsr     _LVODoIo(a6)

          lea     reply(pc),a1
          jsr     _LVORemPort(a6)  remove reply port

          lea     diskio(pc),a1
          jsr     _LVOCloseDevice(a6)

          movea.l a5,a1           write SECTOR
          lea     Sector(pc),a0
          moveq   #3,d0
loop1     move.l  (a0)+,(a1)+
          dbra    d0,loop1

          movea.l a5,a1           write sector number
          adda.l  #7,a1
          movea.l (a7)+,a0
loop2     move.b  (a0)+,d0
          cmpi.b  #$a,d0
          beq.s   next
          move.b  d0,(a1)+
          bra.s   loop2

next      movea.l a5,a1           write *******
          adda.l  #$410,a1
          lea     SecNum(pc),a0
          moveq   #3,d0

loop3     move.l  (a0)+,(a1)+
          dbra    d0,loop3
          bra.s   fin
error     move.w  (a7)+,d0
          movea.l (a7)+,a0
          suba.l  a0,a0
fin       rts

*********************
* Load file
*
* IN:
* a0 Pointer to null terminated filename
*
* OUT:
* d7 <> 0 if error
* a3 Pointer to begin of file
*
*********************

file      move.l  a0,-(a7)

          suba.l  a5,a5
          suba.l  a4,a4
          moveq   #10,d7

          movea.l _AbsExecBase,a6  load dos.library
          lea     DosName(pc),a1
          moveq   #0,d0
          jsr     _LVOOpenLibrary(a6)
          movea.l d0,a6
          tst.l   d0
          beq.s   err

************************************
*
* try to load the file as a program
*
************************************

          move.l  (a7),d1
          jsr     _LVOLoadSeg(a6)
          tst.l   d0
          beq.s   text
          move.l  d0,d1
          add.l   d0,d0
          add.l   d0,d0
          addq.l  #4,d0
          movea.l d0,a3
          jsr     _LVOUnLoadSeg(a6)
          move.l  (a7)+,d1
          moveq   #0,d7
          bra.s   nounlock

************************************
*
* now try to load the file as text
*
************************************


text      move.l  (a7),d1          get lock
          moveq   #-2,d2
          jsr     _LVOLock(a6)
          move.l  d0,d1
          movea.l d0,a5
          beq.s   err

          suba.l  #$104,a7
          move.l  a7,d2
          jsr     _LVOExamine(a6)
          tst.l   d0
          beq.s   err

          move.l  $7c(a7),d0
          adda.l  #$104,a7
          move.l  d0,d5
          beq.s   err

          move.l  a6,-(a7)
          moveq   #0,d1            Any type of memory
          movea.l _AbsExecBase,a6
          jsr     _LVOAllocMem(a6)
          movea.l (a7)+,a6
          movea.l d0,a3
          beq.s   err

          move.l  (a7),d1
          move.l  #$3ed,d2
          jsr     _LVOOpen(a6)
          movea.l d0,a4
          move.l  d0,d1
          beq.s   err

          move.l  a3,d2
          move.l  d5,d3
          jsr     _LVORead(a6)
          cmp.l   d0,d3
          bne.s   err

          moveq   #0,d7
          bra.s   errend

err       moveq   #1,d7

errend    move.l  (a7)+,d0
          move.l  a4,d1
          beq.s   noclose
          jsr     _LVOClose(a6)

noclose   move.l  a5,d1
          beq.s   nounlock
          jsr     _LVOUnLock(a6)

nounlock  movea.l a6,a1             Close dos.library
          beq.s   nolib
          move.l  _AbsExecBase,a6
          jsr     _LVOCloseLibrary(a6)
nolib     rts

DosName   dc.b 'dos.library',0
trddevice dc.b 'trackdisk.device',0
          even
diskio    dc.l 0             +0  successor
          dc.l 0             +4  predecessor
          dc.b 0,0           +8  type,priority
          dc.l 0             +a  pointer to device name
          dc.l 0             +e  reply port
          dc.w reply-diskio  +12 node length
          dc.l 0             +14 io-device
          dc.l 0             +18 io-unit
          dc.w 0             +1c io-command
          dc.b 0,0           +1e flags,error
          dc.l 0             +20 actual no of bytes
          dc.l 0             +24 requested no of bytes
          dc.l 0             +28 pointer to buffer
          dc.l 0             +2c offset
reply     dc.l 0,0,0,0,0,0,0,0


Sector    dc.b 'SECTOR *'
SecNum    dc.b '****************'
          end

