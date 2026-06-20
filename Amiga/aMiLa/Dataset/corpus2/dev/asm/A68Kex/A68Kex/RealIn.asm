*  RealIn change ASCII inputted real number
*  to numeric real
*
*  IN
*  a0 pointer to ASCII string
*  OUT
*  d0 real number
*  d1 ok flag
*  INTERNAL
*  d2 sign of number
*  d3 intermediate real
*  d4 sign of exponent
*  d5 value of exponent
*
* written by E. Lenz
*            Johann-Fichte-Strasse 11
*            8 Munich 40
*            Germany

***** exec *****

_AbsExecBase     equ 4
_LVOCloseLibrary equ -$19e
_LVOOpenLibrary  equ -$228

****** mathffp ******

_LVOSPFlt        equ -$24
_LVOSPNeg        equ -$3c
_LVOSPAdd        equ -$42
_LVOSPMul        equ -$4e

ten      equ  $a0000044
tenth    equ  $cccccd3d


         XDEF RealIn

RealIn   movem.l d2-d7/a1/a6,-(a7)     save used registers
         move.l  #ten,d6
         move.l  #tenth,d7
         move.l  a0,-(a7)              save pointer to ASCII
         move.l  _AbsExecBase,a6
         lea     FfpName,a1            open mathffp library
         moveq   #0,d0
         jsr     _LVOOpenLibrary(a6)
         move.l  (a7)+,a0
         tst.l   d0
         beq     bad
         movea.l d0,a6


         moveq   #0,d3             value zero
         moveq   #0,d2             sign of number
         moveq   #0,d4             sign of exponent
         moveq   #0,d5             value of exponent

         bsr.s   sign

*  1st step convert until decimal point, e or blank

First    cmpi.b  #'.',(a0)       test end of step condition
         beq.s   Point
         bsr.s   chke
         beq     Exp
         bsr.s   chkex
         beq     exit

         move.l  d6,d0         multiply result by 10
         move.l  d3,d1
         jsr     _LVOSPMul(a6)
         move.l  d0,d3

         bsr     chk09
         bpl     bad
         jsr     _LVOSPFlt(a6)
         move.l  d3,d1
         jsr     _LVOSPAdd(a6)
         move.l  d0,d3
         bra.s   First

; check if e or E

chke     cmpi.b  #'E',(a0)
         beq.s   ise
         cmpi.b  #'e',(a0)
ise      rts

; check end of input

chkex    cmpi.b  #' ',(a0)
         beq.s   isex
         cmpi.b  #$a,(a0)
isex     rts

; get sign

sign     cmpi.b  #'-',(a0)         get sign of number
         bne.s   notm
         move.b  (a0)+,d2
         bra.s   return
notm     cmpi.b  #'+',(a0)
         bne.s   return
         move.b  (a0)+,d0
return   rts

; step 2 convert decimal fraction

Point    move.b  (a0)+,d0      remove '.'
         move.l  d7,d1         d1 as value of position

Second   bsr.s   chke         test end of step 2 condition
         beq.s   Exp
         bsr.s   chkex
         beq.s   exit

         bsr.s   chk09
         bpl.s   bad
         move.l  d1,-(a7)
         jsr     _LVOSPFlt(a6)
         move.l  (a7),d1
         jsr     _LVOSPMul(a6)

         move.l  d3,d1           add the numeral
         jsr     _LVOSPAdd(a6)
         move.l  d0,d3
         move.l  (a7)+,d0

         move.l  d7,d1          decrement value of position
         jsr     _LVOSPMul(a6)
         move.l  d0,d1
         bra.s   Second

Exp      move.b  (a0)+,d0      get rid of 'e'
         exg     d2,d4
         bsr.s   sign
         exg     d2,d4         sign of exponent

         bsr.s   chk09         get exponent
         bpl.s   bad
         move.l  d0,d5
         bsr.s   chk09
         bpl.s   nosec
         moveq   #10,d1
         mulu    d1,d5
         add.l   d0,d5
nosec    tst.l   d5
         beq.s   exit
         move.l  d3,d0
         move.l  d6,d1
         subq.l  #1,d5
         tst.l   d4
         beq.s   plus
         move.l  d7,d1
plus     jsr     _LVOSPMul(a6)
         dbra    d5,plus
         move.l  d0,d3
         bra.s   exit

bad      moveq   #1,d1
         bra.s   noneg

; check if decimal

chk09    moveq   #0,d0
         move.b  (a0)+,d0
         subi.b  #'0',d0
         bmi.s   bad1
         cmpi.b  #$a,d0
         bge.s   bad1
         rts
bad1     moveq   #0,d0
         rts

exit     move.l  d3,d0
         tst.l   d2
         beq.s   non
         jsr     _LVOSPNeg(a6)
non      moveq   #0,d1

noneg    movem.l d0-d1,-(a7)
         move.l  a6,d1
         beq.s   noFfp
         move.l  _AbsExecBase,a6      close mathffp library
         movea.l d1,a1
         jsr     _LVOCloseLibrary(a6)
noFfp    movem.l (a7)+,d0-d1
         movem.l (a7)+,d2-d7/a1/a6
         rts

FfpName  dc.b 'mathffp.library',0
         even
         end
