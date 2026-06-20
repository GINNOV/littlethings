
*  RealOut change real number to ASCII string
*
*  IN
*  d0 real number
*  d1 number of mantissa digits - 1
*  a0 pointer to begin of buffer
*  OUT
*  a0 pointer to end of buffer
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

_LVOSPFix        equ -$1e
_LVOSPFlt        equ -$24
_LVOSPCmp        equ -$2a
_LVOSPSub        equ -$48
_LVOSPMul        equ -$4e
_LVOSPDiv        equ -$54

one      equ  $80000041
ten      equ  $a0000044


         XDEF RealOut

RealOut  movem.l d4-d7/a1/a3/a6,-(a7)  save used registers
         movea.l a0,a3                 save input data
         move.l  d0,d7
         move.l  d1,d4
         move.l  #ten,d5
         moveq   #0,d6                 exponent = 0
         move.l  _AbsExecBase,a6
         lea     FfpName(pc),a1        open mathffp library
         moveq   #0,d0
         jsr     _LVOOpenLibrary(a6)
         movea.l d0,a6
         tst.l   d0
         beq     exit

; first step - get sign of number

         tst.l   d7           throw out zero
         beq.s   reduced

         tst.b   d7
         bpl.s   ispos
         move.b  #'-',(a3)+
         bclr    #7,d7         dirty _LVOSPAbs

; second step get exponent i.e. reduce to 1 <=     < 10

ispos    move.l  d7,d1
         move.l  #one,d0
         jsr     _LVOSPCmp(a6)
         tst.l   d0
         bmi.s   less           one > value?
         move.l  d7,d1
         move.l  d5,d0
         jsr     _LVOSPCmp(a6)
         tst.l   d0
         bmi.s   reduced        ten > value?

         move.l  d5,d1
         move.l  d7,d0
         jsr     _LVOSPDiv(a6)  divide by ten
         addq.l  #1,d6
gopos    move.l  d0,d7         
         bra.s   ispos

less     move.l  d5,d1
         move.l  d7,d0
         jsr     _LVOSPMul(a6)  multiply by ten
         subq.l  #1,d6
         bra.s   gopos

; 3rd step write mantissa

reduced  move.l  d7,d0
         bsr.s   numeral
         move.b  #'.',(a3)+
mant     jsr     _LVOSPFlt(a6)
         move.l  d0,d1
         move.l  d7,d0
         jsr     _LVOSPSub(a6)
         move.l  d5,d1
         jsr     _LVOSPMul(a6)
         move.l  d0,d7
         bsr.s   numeral
         dbra    d4,mant

; now write exponent

         move.b  #'E',(a3)+
         tst.b   d6
         bpl.s   none
         move.b  #'-',(a3)+
         neg.b   d6
none     cmp.b   #10,d6
         blt.s   nofirst
         moveq   #0,d1
flop     subi.b  #10,d6
         addq.b  #1,d1
         cmp.b   #10,d6
         bge.s   flop
         bsr.s   num1
nofirst  move.b  d6,d1
         bsr.s   num1
         clr.b   (a3)

exit     move.l  a6,d1
         beq.s   noFfp
         move.l  _AbsExecBase,a6      close mathffp library
         movea.l d1,a1
         jsr     _LVOCloseLibrary(a6)
noFfp    movea.l a3,a0
         movem.l (a7)+,d4-d7/a1/a3/a6
         rts

numeral  jsr     _LVOSPFix(a6)
         move.b  d0,d1
num1     addi.b  #'0',d1
         move.b  d1,(a3)+
         rts

FfpName  dc.b 'mathffp.library',0
         even
         end
