***************************************
* Disassemble one line module         *
* Version 1.3 31.8.89                 *
*                                     *
* written by E. Lenz                  *
*            Johann-Fichte-Strasse 11 *
*            8 Munich 40              *
*            Germany                  *
*                                     *
***************************************

     XDEF Disasm1

;Communication structure

SBegin   equ 0
SRelAddr equ 4
SMicro   equ 8
SOpCode  equ $a
SType1   equ $c
SLen1    equ $e
SAddr1   equ $10
SType2   equ $14
SLen2    equ $16
SAddr2   equ $18
STotal   equ $1c
SBuffer  equ $1e

*** INPUT ***
; a0 pointer to communication structure


*** ON STACK *****
;
; word 0
; 1st address                  (long) [d7]
; length of 1st address        (word) [d6]
; type of 1st address          (word) [d5]
; 2nd address                  (long) [d4]
; length of 2nd address        (word) [d3]
; type for 2nd address         (word) [d2]
; 0=no address
; qualifier                    (word) [d0]
; 0=.b 1=no qualifier  2=.w  4=.l 6=.s
; pointer to opcode text       (long) [a2]
; number of words to write - 1 (word) [d1]

; a3 displacement
; a5 second displacement for move <ea>,<ea>

**** ADDRESS TYPE ****
;
; 0 = no address
; 1 = Dn
; 2 = An
; 3 = (An)
; 4 = (An)+
; 5 = -(An)
; 6 = d(An)
; 7 = d(An,Rn)
; 8 = $xxxx
; 9 = $xxxx xxxx
; 10 = d(PC)
; 11 = d(PC,Rn)
; 12 = #$xxxx
; 13 = ccr
; 14 = sr
; 15 = sfc
; 16 = dfc
; 17 = usp
; 18 = vbr
; 19 movem stuff

Disasm1  movem.l d0-d7/a3-a6,-(a7)
         bclr    #0,SRelAddr+3(a0)  make sure everything's even
         bclr    #0,SBegin+3(a0)
         moveq   #-1,d0
         movea.l d0,a5          set second displacement to nothing
         addq.l  #1,d0
         movea.l SBegin(a0),a1  begin address
         move.l  (a1),d7        first long word
         move.w  (a1)+,d3       first word

         move.w  d3,d0
         lsr.w   #8,d0          Get first byte
         lsr.w   #2,d0          First half byte
         andi.w  #$3c,d0
         lea     Group(pc),a2
         move.l  0(a2,d0.w),a2
         jmp     (a2)           jump to it's group

cmpchk1  moveq   #0,d0
cmpchk   cmpi.w  #2,SMicro(a0)
         blt.s   what
         movem.l d0/d7,-(a7)
         bsr     DecAddr1
         movem.l (a7)+,d0/d4
         cmpi.w  #3,d5         no Dn,An
         blt.s   what
         beq.s   wok
         cmpi.w  #6,d5         no (An)+,-(An)
         blt.s   what
         cmpi.w  #12,d5        no #...
         beq.s   what
wok      moveq   #1,d1         two words
         moveq   #1,d2         assume Dn
         btst    #15,d4
         beq.s   issDn
         moveq   #2,d2         twas An
issDn    lea     TCmp2(pc),a2  assume cmp2
         btst    #11,d4
         beq.s   iscmp2
         lea     TChk2(pc),a2  twas chk2
iscmp2   move.w  d4,d3
         andi.w  #$7ff,d3
         bne.s   what
         ror.w   #8,d4
         ror.w   #4,d4
         andi.w  #7,d4
         bra     Rewrite
cmpchk2  moveq   #2,d0
         bra.s   cmpchk
cmpchk3  moveq   #4,d0
         bra.s   cmpchk
what     bra     Undef

Group0   btst    #8,d3
         bne     GBtst

         lea     TOri(pc),a2        'ori' opcode
         cmpi.w  #$3c,d3
         beq     Goccr

         cmpi.w  #$7c,d3
         beq     Gosr

         cmpi.w  #$bf,d3
         bls.s   Ggimm

         cmpi.w  #$ff,d3
         bls     cmpchk1

         lea     TAndi(pc),a2       'andi' opcode
         cmpi.w  #$23c,d3
         beq     Goccr

         cmpi.w  #$27c,d3
         beq     Gosr

         cmpi.w  #$2bf,d3
         bls.s   Ggimm

         cmpi.w  #$2ff,d3
         bls.s   cmpchk2

         lea     TSubi(pc),a2       'subi' opcode
         cmpi.w  #$4bf,d3
         bls.s   Ggimm

         cmpi.w  #$4ff,d3
         bls.s   cmpchk3

         lea     TAddi(pc),a2       'addi' opcode
         cmpi.w  #$6bf,d3
Ggimm    bls     Gimm

         cmpi.w  #$6ff,d3
         bgt.s   noMod
         cmpi.w  #2,SMicro(a0)
         blt.s   gnoi
         lea     TRtm(pc),a2        'rtm' opcode
         moveq   #1,d0          no qualifier
         cmpi.w  #$6cf,d3
         bgt.s   noRtm
         moveq   #0,d1          one word
         moveq   #0,d2          no 2nd address
         moveq   #1,d5          assume Dn
         move.w  d3,d7
         btst    #3,d7
         beq.s   wasDn
         moveq   #2,d5
wasDn    and.w   #7,d7
         bra     Rewr1
noRtm    lea     TCallm(pc),a2  'callm' opcode
         bsr     DecAddr2
         cmpi.w  #4,d3          no (An)+
         beq.s   gnoi
         cmpi.w  #5,d3          no -(An)
         beq.s   gnoi
         cmpi.w  #12,d3         no #...
         beq.s   gnoi
         moveq   #1,d1          two words
         moveq   #12,d5         type immediate
         moveq   #1,d6          byte
         bra.s   Ggrew
gnoi     bra     noi

noMod    cmpi.w  #$8ff,d3       bit operands with
         blt     GBtst          bit number immediate

         lea     TEori(pc),a2       'eori' opcode
         cmpi.w  #$a3c,d3
         bne.s   Eorsr
Goccr    move.w  d7,d3
         andi.w  #$ff00,d3
         bne.s   gnoi
         moveq   #1,d6          1st length byte
         moveq   #13,d2         2nd address ',ccr'
         bra.s   Gsr

Eorsr    cmpi.w  #$a7c,d3
         bne.s   GEori
Gosr     moveq   #2,d6          Word
         moveq   #14,d2         ',sr'
Gsr      moveq   #1,d0          no qualifier
         moveq   #1,d1          write two words
         moveq   #12,d5         type immediate
         bra.s   Ggrew

GEori    lea     TEori(pc),a2       'eori' opcode
         cmpi.w  #$aff,d3
         bls.s   Gimm

         cmpi.w  #$cff,d3
         bgt.s   GMoves
         lea     TCmpi(pc),a2       'cmpi' opcode
Gimm     bsr     Imdt
         cmpi.w  #2,d2
         beq.s   Gof
         cmpi.w  #9,d2
         bgt.s   Gof
Ggrew    bra     Rewrite

GMoves   tst.w   SMicro(a0)
         beq.s   Gof
         lea     TMoves(pc),a2      moves opcode
         move.w  d7,d0
         andi.w  #$7ff,d0
         bne.s   Gof
         move.w  d7,d6
         moveq   #1,d5       assume Dn
         btst    #15,d6
         beq.s   wasd
         moveq   #2,d5
wasd     lsr.w   #8,d7
         lsr.w   #4,d7
         andi.w  #7,d7
         moveq   #1,d1      two words
         bsr     Size
         bsr     DecAddr2
         cmpi.w  #3,d2
         bcs.s   Gof         no Dn or An as <ea>
         cmpi.w  #10,d2
         bcc.s   Gof         nothing higher than $...
         bchg    #11,d6
         btst    #11,d6
         bra.s   trys
Gof      bra.s   noi

GBtst    move.w  d3,d0
         andi.w  #$38,d0
         cmpi.w  #8,d0
         beq.s   GMovep
         move.w  d3,d0
         andi.w  #$c0,d0
         bne.s   GBchg
         lea     TBtst(pc),a2
         bra.s   GBit
GBchg    cmpi.w  #$40,d0
         bne.s   GBclr
         lea     TBchg(pc),a2
         bra.s   GBit
GBclr    cmpi.w  #$80,d0
         bne.s   GBset
         lea     TBclr(pc),a2
         bra.s   GBit
GBset    lea     TBset(pc),a2
GBit     bsr     Bit
GRew     bra     Rewrite
noi      bra     Undef

GMovep   lea     TMovep(pc),a2       movep
         moveq   #1,d1     two words
         moveq   #2,d0     assume .w
         btst    #6,d3
         beq.s   solong
         moveq   #4,d0
solong   moveq   #6,d5      d(An)
         move.w  d7,a3
         move.w  d3,d7
         andi.w  #7,d7
         moveq   #1,d2      data reg
         move.w  d3,d4
         lsr.w   #8,d4
         lsr.w   #1,d4
         andi.w  #7,d4
         btst    #7,d3
trys     beq.s   GRew
         bsr     Swapreg
         bra.s   GRew

Group1   moveq   #0,d0      byte
         bra.s   gotqual
Group2   moveq   #4,d0      long
         bra.s   gotqual
Group3   moveq   #2,d0      word
gotqual  move.w  d3,d1
         andi.w  #$1c0,d1   now get destination mode
         cmpi.w  #$40,d1
         beq.s   GMovea     movea command
         lea     TMove(pc),a2
         moveq   #-1,d1
         movea.l d1,a3
         addq.l  #1,d1
         move.w  d3,-(a7)
         bsr     DecAddr2
         bsr     Swapreg
         move.w  (a7)+,d3
         cmpa.l  #-1,a3
         beq.s   na3
         movea.l a3,a5
         suba.l  a3,a3
na3      lsr.w   #3,d3
         andi.w  #$1f8,d3
         move.w  d3,d4
         lsr.w   #6,d4
         andi.w  #7,d4
         or.w    d4,d3
         bsr     DecAddr2
         exg     a3,a5
         cmpi.w  #10,d2   check destination address
         bge.s   rub2
         tst.l   d0
         bne.s   gGrew
         cmpi.w  #2,d5    no move.b An,...
         bne.s   gGrew
rub2     bra     Undef

GMovea   lea     TMovea(pc),a2
         tst.w   d0       no byte qualifier
         beq.s   rub1
         bsr     Dnea
         moveq   #2,d2
gGrew    bra     Rewrite

Group4   btst    #8,d3
         bne     GLea

         cmpi.w  #$40ff,d3
         bgt.s   GMoveccr
         cmpi.w  #$40c0,d3
         blt.s   GNegx       move from status register
         moveq   #14,d5      sr,
         bra.s   Wmove

GNegx    lea     TNegx(pc),a2    'negx' opcode
GNeg     move.w  d3,d0
         andi.w  #$c0,d0     get size bits 7,6
         lsr.w   #5,d0
         move.w  d0,-(a7)
Gbcd     moveq   #0,d1
         bsr     DecAddr1
         move.w  (a7)+,d0
         cmpi.w  #2,d5
         beq.s   rub1
         cmpi.w  #10,d5
         bcc.s   rub1
         bra     Rewr1

GMoveccr cmpi.w  #$4200,d3
         blt.s   rub1
         cmpi.w  #$42ff,d3
         bgt.s   GMovtccr
         lea     TClr(pc),a2
         cmpi.w  #$42c0,d3
         blt.s   GNeg
         tst.w   SMicro(a0)  move from ccr
         beq.s   rub1
         moveq   #13,d5      ccr,
Wmove    moveq   #1,d0       no qualifier
         moveq   #0,d1       one word
         lea     TMove(pc),a2    'move' opcode
         bsr     DecAddr2
         bra.s   Rew1
rub1     bra     Undef

GMovtccr cmpi.w  #$4400,d3
         blt.s   rub1
         cmpi.w  #$44ff,d3
         bgt.s   GMovtsr
         lea     TNeg(pc),a2
         cmpi.w  #$44c0,d3
gGNeg    blt.s   GNeg
         moveq   #0,d1       move to ccr
         bsr     DecAddr1
         moveq   #13,d2
         bra.s   Movreg

GMovtsr  cmpi.w  #$4600,d3
         blt.s   rub1
         cmpi.w  #$46ff,d3
         bgt.s   GNbcd
         lea     TNot(pc),a2
         cmpi.w  #$46c0,d3
         blt.s   gGNeg
         moveq   #0,d1       one word
         bsr     DecAddr1
         moveq   #14,d2
Movreg   moveq   #1,d0            no qualifier
         lea     TMove(pc),a2     move to ccr
Rew1     bra     Rewrite

GNbcd    cmpi.w  #$4800,d3
grub1    blt.s   rub1
         cmpi.w  #$483f,d3
         bgt.s   GSwap
         lea     TNbcd(pc),a2
Gtobcd   moveq   #1,d0
         move.w  d0,-(a7)
         bra     Gbcd

GSwap    cmpi.w  #$4847,d3
         bgt.s   GBkpt
         lea     TSwap(pc),a2
         bra.s   Gtobcd

GBkpt    cmpi.w  #$484f,d3
         bgt.s   GPea
         cmpi.w  #2,SMicro(a0)      68020+
         blt.s   grub1
         lea     TBkpt(pc),a2       bkpt #n
         bra     VecWrt

GPea     cmpi.w  #$487f,d3
         bgt.s   GExt
         lea     TPea(pc),a2        'pea' opcode
         moveq   #1,d0          no qualifier
         bra.s   Godec

GExt     cmpi.w  #$49c7,d3
         bgt.s   GMovm
         move.w  d3,d0
         andi.w  #$38,d0    Bits 5 4 3 must be 000
         bne.s   GMovm
         move.w  d3,d0
         andi.w  #$1c0,d0   get qualifier
         lsr.w   #6,d0
         cmpi.w  #2,d0       .w
         beq.s   Qok
         cmpi.w  #3,d0       .l
         bne.s   Pot
         moveq   #4,d0
Qok      lea     TExtn(pc),a2
Godec    bra     dec1
Pot      cmpi.w  #7,d0
         bne.s   notis
         cmpi.w  #2,SMicro(a0)
         blt.s   notis
         moveq   #4,d0
         lea     TExtb(pc),a2
         bra.s   Godec

GMovm    cmpi.w  #$48ff,d3      movem reg_list,<ea>
         bgt.s   GIllegal
         lea     TMovem(pc),a2      'movem' op code
         moveq   #2,d0
         moveq   #1,d1
         btst    #6,d3
         beq.s   mwd
         moveq   #4,d0          qualifier
mwd      move.w  (a1)+,d7
         moveq   #19,d5         movem stuff type
         bsr     DecAddr2
         cmpi.w  #3,d2          no Dn,An
         blt.s   notis
         cmpi.w  #4,d2          no (An)+
         beq.s   notis
         cmpi.w  #5,d2          is it -(An)?
         bne.s   trypct
         movem.l d3-d5,-(a7)
         moveq   #15,d5
         moveq   #0,d4          reverse the register list
         moveq   #0,d3
mwd1     btst    d5,d7
         beq.s   noset
         bset    d4,d3
noset    addq.w  #1,d4
         subq.w  #1,d5
         bpl.s   mwd1
         move.w  d3,d7
         movem.l (a7)+,d3-d5
trypct   cmpi.w  #9,d2          no d(PC) etc
         bgt.s   notis
         tst.w   d7
         bne     Rewrite        Reg mask may not be zero
notis    bra     Undef

GIllegal cmpi.w  #$4a00,d3
         blt.s   notis
         cmpi.w  #$4afc,d3
         bne.s   GTst
         lea     TIllegal(pc),a2
         bra     OneByte

GTst     cmpi.w  #$4abf,d3
         bgt.s   GTas
         move.w  d3,d0
         andi.w  #$c0,d0
         lsr.w   #5,d0
         lea     TTst(pc),a2
dec1     bsr     DecAddr1
         cmpi.w  #2,d5        no An
         beq.s   notis
         bra.s   Rew12

GTas     cmpi.w  #$4aff,d3
         bgt.s   GMovem
         moveq   #1,d0       no qualifier
         lea     TTas(pc),a2
         bra.s   dec1

GMovem   cmpi.w  #$4c80,d3     movem <ea>,reg_list
         blt.s   notis
         cmpi.w  #$4cff,d3
         bgt.s   GTrap
         lea     TMovem(pc),a2
         moveq   #2,d0
         btst    #6,d3
         beq.s   mwwd
         moveq   #4,d0
mwwd     move.w  (a1)+,-(a7)
         bsr     DecAddr1
         addq.w  #1,d1
         moveq   #19,d2      movem stuff type
         move.w  (a7)+,d4
         cmpi.w  #3,d5       no Dn,An
         blt.s   notok
         cmpi.w  #5,d5       no -(An)
         beq.s   notok
         cmpi.w  #11,d5
         bgt.s   notok
         tst.w   d4
         beq.s   notok       Reg mask may not be zero
Rew2     bra     Rewrite
notok    bra     Undef

GTrap    cmpi.w  #$4e40,d3
         blt.s   notok
         cmpi.w  #$4e4f,d3
         bgt.s   GLink
         lea     TTrap(pc),a2
VecWrt   bsr     Vector
Rew12    bra     Rewr1

GLink    cmpi.w  #$4e58,d3
         bgt.s   GUnlk
         moveq   #1,d0
         moveq   #1,d1
         move.w  d7,d4
         move.w  d3,d7
         andi.w  #7,d7        register
         moveq   #1,d6
         moveq   #2,d5        An
         moveq   #12,d2       immediate data
         moveq   #3,d3        signed word
         lea     TLink(pc),a2
         bra.s   Rew2

GUnlk    cmpi.w  #$4e5f,d3
         bgt.s   GMovesp
         andi.w  #$ffef,d3
         moveq   #1,d0
         lea     TUnlk(pc),a2
         bsr     DecAddr1
         bra.s   Rew12

GMovesp  cmpi.w  #$4e6f,d3
         bgt.s   GReset
         lea     TMove(pc),a2
         moveq   #1,d0
         moveq   #0,d1
         andi.w  #$f,d3
         cmpi.w  #7,d3
         bgt.s   Fromusp
         moveq   #2,d5
         moveq   #1,d6
         move.w  d3,d7
         moveq   #17,d2
         bra.s   Rew2
Fromusp  move.w  d3,d4
         andi.w  #7,d4
         moveq   #2,d2
         moveq   #1,d3
         moveq   #17,d5
         bra     Rewrite


GReset   lea     TReset(pc),a2
         cmpi.w  #$4e70,d3
         beq.s   OneByte

         lea     TNop(pc),a2
         cmpi.w  #$4e71,d3
         beq.s   OneByte

         cmpi.w  #$4e72,d3    'stop' operand
         bne.s   SRte
         lea     TStop(pc),a2
Xstop    moveq   #1,d0        no qualifier
         moveq   #1,d1        2 words
         moveq   #0,d2        no second address
         moveq   #12,d5       immediate address
         moveq   #2,d6        word operand
         move.w  (a1)+,d7
         bra     Rew13

SRte     lea     TRte(pc),a2
         cmpi.w  #$4e73,d3
         beq.s   OneByte

         lea     TRtd(pc),a2
         cmpi.w  #$4e74,d3
         bne.s   SRts
         tst.w   SMicro(a0)   only 68010+
         bne.s   Xstop
         bra.s   Jmpf

SRts     lea     TRts(pc),a2
         cmpi.w  #$4e75,d3
         beq.s   OneByte

         lea     TTrapv(pc),a2
         cmpi.w  #$4e76,d3
         beq.s   OneByte

         cmpi.w  #$4e77,d3
         bne.s   GMovec
         lea     TRtr(pc),a2
OneByte  moveq   #0,d5          no operand
         moveq   #1,d0          no qualifier
         moveq   #0,d1          write one word
         bra     Rewr2
Jmpf     bra     Undef

GMovec   cmpi.w  #$4e7a,d3
         beq.s   ismovec
         cmpi.w  #$4e7b,d3
         bne.s   GJsr
ismovec  tst.w   SMicro(a0)
         beq.s   Jmpf
         move.w  d7,d0
         andi.w  #$7fe,d0
         bne.s   Jmpf
         lea     TMovec(pc),a2
         moveq   #1,d0          no qualifier
         moveq   #1,d1          two words
         moveq   #15,d2         assume sfc
         btst    #0,d7
         beq.s   noinc
         addq.w  #1,d2
noinc    btst    #11,d7
         beq.s   nocni
         addq.w  #2,d2
nocni    moveq   #1,d5          2nd address type An or Dn
         btst    #15,d7
         beq.s   noicn
         addq.w  #1,d5
noicn    lsr.w   #8,d7
         lsr.w   #4,d7
         andi.w  #7,d7
         btst    #0,d3
         beq.s   gnom
         bsr     Swapreg
gnom     bra     Rewrite

GJsr     cmpi.w  #$4e80,d3
Jjmpf    blt.s   Jmpf
         cmpi.w  #$4ebf,d3
         bgt.s   GJmp
         lea     TJsr(pc),a2
XJmp     moveq   #1,d0
         bsr     DecAddr1
         cmpi.w  #3,d5      jsr (An) is ok
         beq.s   Rew13
         cmpi.w  #6,d5      nothing below $XX(An)
         bcs.s   goodno
         cmpi.w  #12,d5     no #$XXXX
         beq.s   goodno
Rew13    bra     Rewr1
goodno   bra     Undef

GJmp     cmpi.w  #$4eff,d3
         bgt     Jmpf
         lea     TJmp(pc),a2
         bra     XJmp

GLea     move.w  d3,d0
         andi.w  #$fff8,d0
         cmpi.w  #$49c0,d0
         beq     GExt
         cmpi.w  #$4180,d3
         blt.s   Jjmpf
         btst    #6,d3
         beq.s   GChk
         lea     TLea(pc),a2
         moveq   #1,d0     no qualifier
         bsr     Dnea
         bsr     Check2
         moveq   #2,d2     lea ...,An
nomrel   bra     Rewrite

GChk     move.w  d3,-(a7)
         bsr     DecAddr1
         move.w  (a7)+,d4
         tst.l   d0
         bmi.s   NoChk
         cmpi.w  #2,d5
         beq.s   NoChk        no chk.x An,Dm
         move.w  d4,d0
         andi.w  #$e00,d4
         lsr.w   #8,d4
         lsr.w   #1,d4
         moveq   #1,d2
         andi.w  #$180,d0
         cmpi.w  #$180,d0      .w
         bne.s   Cmpl
         moveq   #2,d0
         lea     TChk(pc),a2
         bra.s   nomrel
NoChk    bra     Undef
Cmpl     cmpi.w  #$100,d0         .l only on 68020
         bne.s   NoChk
         cmpi.w  #2,SMicro(a0)
         bcs.s   NoChk
         moveq   #4,d0
noml     bra.s   nomrel

Group5   move.w  d3,d0
         andi.w  #$c0,d0
         cmpi.w  #$c0,d0
         beq.s   GDbcc
         lea     TSubq(pc),a2
         btst    #8,d3
         bne.s   GSubq
         lea     TAddq(pc),a2    addq
GSubq    move.w  d3,d7       subq
         andi.w  #$e00,d7
         lsr.w   #8,d7
         lsr.w   #1,d7
         bne.s   no8
         moveq   #8,d7
no8      moveq   #1,d6
         moveq   #12,d5
         lsr.w   #5,d0
         moveq   #0,d1
         bsr     DecAddr2
         cmpi.w  #10,d2    no #$... or higher
         bcc.s   gf
         tst.l   d0
         bne.s   noml
         cmpi.w  #2,d2     no addq.b #$X,An
         bne.s   noml
gf       bra.s   fff

GDbcc    move.w  d3,d0
         andi.w  #$38,d0
         cmpi.w  #8,d0
         bne.s   GScc
         move.w  d3,d0       dbcc
         lea     Branch(pc),a2
         andi.w  #$f00,d0
         lsr.w   #8,d0
         mulu    #5,d0
         cmpi.w  #5,d0
         bgt.s   Readd
         subq.l  #5,d0
Readd    adda.l  d0,a2
         moveq   #1,d1   no of words = 2
         moveq   #1,d0   no qualifier
         btst    #0,d7   displacement must be even
         bne.s   fff
         move.l  SRelAddr(a0),d4
         ext.l   d7
         add.l   d7,d4
         addq.l  #2,d4
         move.w  d3,d7
         andi.w  #7,d7
         moveq   #1,d5
         moveq   #8,d2
         moveq   #4,d3
         bra     Rewrite

GScc     cmpi.w  #$38,d0
         beq.s   fff
         lea     Setcc(pc),a2   scc
         moveq   #0,d0
         move.w  d3,d0
         andi.w  #$f00,d0
         lsr.w   #6,d0
         adda.l  d0,a2
         moveq   #1,d0
         bsr     DecAddr1
         cmpi.w  #8,d5
         beq.s   eadr
         cmpi.w  #9,d5
         bne.s   neadr
eadr     btst    #0,d7      Address must be even
         beq.s   neadr
fff      bra     Undef


Group6   moveq   #0,d0
         move.w  d3,d0
         lea     Branch(pc),a2
         andi.w  #$f00,d0
         lsr.w   #8,d0
         mulu    #5,d0
         addq.l  #1,d0
         add.l   d0,a2
         moveq   #0,d1   assume no of word = 1
         moveq   #1,d0   assume no qualifier
         moveq   #8,d5
         moveq   #4,d6
         move.l  d7,d4     displacement
         move.l  SRelAddr(a0),d7
         addq.l  #2,d7
         moveq   #0,d2
         tst.b   d3      8 bit displ 0 then 16 bit displ
         beq.s   Trywrd
         cmpi.b  #$ff,d3 8 bit displ ff then 32 bit displ
         beq.s   Trylng
         moveq   #6,d0   qualifier = .s
         andi.l  #$ff,d3
         ext.w   d3
         move.l  d3,d4
         bra.s   bext
Trywrd   moveq   #1,d1
         andi.l  #$ffff,d4
bext     ext.l   d4
         add.l   d4,d7
         bra.s   bccr
Trylng   cmpi.w  #2,SMicro(a0)  long offsets only
         blt.s   fff            for >= 68020
         moveq   #4,d0          qualifier = .l
         moveq   #2,d1          3 words
         move.l  2(a1),d4
         add.l   d4,d7
bccr     btst    #0,d7    branch address even
         bne.s   fff
neadr    bra     Rewr1

; MOVEQ

Group7   lea     TMoveq(pc),a2
         btst    #8,d3
         bne.s   fff
         move.w  d3,d7
         andi.w  #$ff,d7
         moveq   #12,d5
         moveq   #0,d6
         move.w  d3,d4
         andi.w  #$e00,d4
         lsr.w   #8,d4
         lsr.w   #1,d4
         moveq   #1,d2
         moveq   #1,d0
         moveq   #0,d1
         bra.s   Rew4

; OR group   8 7 6
;       OR   0 0 0
;            0 0 1   if bit 8 is 1 then  5 4 3
;            0 1 0                       0 0 0
;            1 0 0                       0 0 1
;            1 0 1                 are not allowed
;            1 1 0
;
;            8 7 6 5 4
;            0 1 1     divu
;            1 0 0 0 0 sbcd
;            1 0 1 0 0 pack (68020)
;            1 1 0 0 0 unpk (68020)
;            1 1 1     divs


Group8   move.w  d3,d0
         andi.w  #$1c0,d0
         cmpi.w  #$c0,d0    test if 876 = 011
         beq.s   GDivu
         cmpi.w  #$1c0,d0   test if 876 = 111
         beq.s   GDivs
         btst    #8,d3      test if bit 8 set
         beq.s   isor
         move.w  d3,d1
         andi.w  #$30,d1    test if 54 = 00
         beq.s   GSbcd
isor     move.w  d3,-(a7)   or command
         bsr     Size       qualifier
         lea     Tor(pc),a2
         bsr     DecAddr1
         movea.l d4,a4
         move.w  (a7)+,d4
         cmpi.w  #2,d5
         beq.s   nondef
         btst    #8,d4
         beq.s   nextG
         move.w  d4,d7
         move.l  a4,d4
         andi.w  #$e00,d7
         lsr.w   #8,d7
         lsr.w   #1,d7
         move.w  d5,d2
         moveq   #1,d5
Rew4     bra     Rewrite

GDivu    lea     TDivu(pc),a2
         bra.s   GDiv
GDivs    lea     TDivs(pc),a2
GDiv     move.w  d3,-(a7)
         bsr     DecAddr1
         moveq   #1,d0
         move.w  (a7)+,d4
         cmpi.w  #2,d5           no divy.x An,Dm
         beq.s   nondef
         cmpi.w  #12,d5          no divy.x ccr,Dn and higher
         bgt.s   nondef
nextG    andi.w  #$e00,d4
         lsr.w   #8,d4
         lsr.w   #1,d4
         moveq   #1,d2
         bra.s   Rew4
nondef   bra     Undef

GSbcd    cmpi.w  #$100,d0
         bne.s   GPack
         lea     TSbcd(pc),a2
         moveq   #1,d0
         bra     DnDm
GPack    cmpi.w  #2,SMicro(a0) if micro <2 undefined
         blt.s   nondef
         cmpi.w  #$140,d0
         bne.s   GUnpk
         lea     TPack(pc),a2
GUnpk    lea     TUnpk(pc),a2  >>>>> not implemented >>>>
         bra.s   nondef


Group9   move.w  d3,d0
         andi.w  #$c0,d0
         cmpi.w  #$c0,d0
         beq     GSuba
         btst    #8,d3
         beq.s   GSub
         move.w  d3,d0
         andi.w  #$30,d0
         bne.s   GSub
         lea     TSubx(pc),a2
         moveq   #0,d1
         move.w  d3,d7    subx
         andi.w  #7,d7
         move.w  d3,d4
         andi.w  #$e00,d4
         lsr.w   #8,d4
         lsr.w   #1,d4
         bsr     Size
         moveq   #1,d2
         moveq   #1,d5
         btst    #3,d3
         beq.s   GGR
         moveq   #5,d2
         moveq   #5,d5
GGR      bra     Rewrite

GSub     lea     TSub(pc),a2
         bsr     Size
         move.w  d3,-(a7)
         bsr     DecAddr1
         movea.l d4,a4
         move.w  (a7)+,d4
         btst    #8,d4
         bne.s   Slong
         andi.w  #$e00,d4       sub.x <ea>,Dn
         lsr.w   #8,d4
         lsr.w   #1,d4
         moveq   #1,d2
         cmpi.w  #2,d5          is it An?
         bne.s   GGR
         tst.l   d0             ok if not .b
         bne.s   GGR
defno    bra     Undef
Slong    move.w  d4,d7          sub.x Dn,<ea>
         move.l  a4,d4
         andi.w  #$e00,d7
         lsr.w   #8,d7
         lsr.w   #1,d7
         move.w  d5,d2
         moveq   #1,d5
         cmpi.w  #3,d2          no Dn or An
         bcs.s   defno
tsthi    cmpi.w  #10,d2         nothing above $...
         bcc.s   defno
         bra.s   GGR

GSuba    lea     TSuba(pc),a2
         moveq   #4,d0
         btst    #8,d3
         bne.s   Sublng
         moveq   #2,d0
Sublng   bsr     Dnea
         moveq   #2,d2
         bra.s   GGR


Groupb   move.w  d3,d0
         andi.w  #$c0,d0
         cmpi.w  #$c0,d0
         beq.s   GCmpa
         btst    #8,d3
         beq.s   GCmp
         move.w  d3,d0
         andi.w  #$38,d0
         cmpi.w  #8,d0
         beq.s   GCmpm
         lea     TEor(pc),a2
         bsr     Dneasize     eor
         exg     d4,d7
         exg     d5,d2
         cmpi.w  #2,d2
defnot   beq.s   defno
         bra.s   tsthi

GCmpa    lea     TCmpa(pc),a2     cmpa
         bra     XCmp

GCmp     lea     TCmp(pc),a2      cmp
         bsr     Dneasize
         tst.l   d0
         bne.s   Rew5
tstAn    cmpi.w  #2,d5            no cmp.b An,Dm
         beq.s   defnot
Rew5     bra     Rewrite

GCmpm    lea     TCmpm(pc),a2     cmpm
         ori.w   #$10,d3
         bsr     Dneasize
         moveq   #4,d2
         moveq   #4,d5
         bra.s   nofix

Groupc   move.w  d3,d0
         andi.w  #$1c0,d0
         cmpi.w  #$1c0,d0
         beq.s   GMuls
         cmpi.w  #$c0,d0
         beq.s   GMulu
         btst    #8,d3
         beq.s   GAnd
         move.w  d3,d0
         andi.w  #$38,d0
         beq.s   exgabcd
         cmpi.w  #8,d0
         beq.s   exgabcd
GAnd     lea     TAnd(pc),a2     and
         bsr     Xdneasize
         bra.s   tstAn

GMuls    lea     TMuls(pc),a2    muls
         bra.s   GMul

GMulu    lea     TMulu(pc),a2    mulu
GMul     moveq   #1,d0       no qualifier
         bsr     Dnea
         cmpi.w  #2,d5       no mul An,Dm
         beq     Undef
         bra.s   nofix


exgabcd  moveq   #1,d0       no qualifier
         move.w  d3,d1
         andi.w  #$c0,d1
         beq.s   GAbcd
         lea     TExg(pc),a2     exg
         move.w  d3,a4
         bsr     Dnea
         move.w  a4,d3
         and.w   #$f8,d3
         cmpi.w  #$48,d3
         bne.s   nofix
         moveq   #2,d2
nofix    bra     Rewrite

GAbcd    lea     TAbcd(pc),a2     abcd
DnDm     bsr     Dnea
         bra.s   fixan

; if bits 7,6 = 11 then its adda
; if bit 8 is 1 and bits 5,4 = 00 then its addx
; else its add

Groupd   move.w  d3,d0
         andi.w  #$c0,d0
         cmpi.w  #$c0,d0      bits 7,6=11
         beq.s   GAdda
         btst    #8,d3
         beq.s   GAdd         if bit 8=0 its add
         move.w  d3,d0
         andi.w  #$30,d0      now if bits 5,4<>00 its add
         bne.s   GAdd
         lea     TAddx(pc),a2     addx
         bsr     Dneasize
fixan    cmpi.w  #2,d5
         bne.s   nofix
         moveq   #5,d2        fix addressing mode
         moveq   #5,d5
         bra.s   nofix

GAdda    lea     TAdda(pc),a2     adda
XCmp     moveq   #2,d0
         btst    #8,d3
         beq.s   addword
         moveq   #4,d0
addword  bsr     Dnea
         moveq   #2,d2
         bra.s   nofix

GAdd     lea     TAdd(pc),a2     add
         bsr     Xdneasize
         bra.s   nofix

* logical group

Groupe   lea     TAsr(pc),a2
         btst    #8,d3
         beq.s   addrok
         addq.w  #5,a2
addrok   move.w  d3,d0
         andi.w  #$c0,d0
         cmpi.w  #$c0,d0
         bne.s   nomem
         move.w  d3,d0
         andi.w  #$600,d0
         lsr.w   #8,d0
         cmpi.w  #4,d0
         beq.s   nox
         addq.l  #1,a2
nox      mulu    #5,d0
         adda.w  d0,a2
         moveq   #1,d0
         bsr     DecAddr1
         cmpi.w  #3,d5        no Dn or An
         bcs.s   Undef
         cmpi.w  #10,d5       no #$... or higher
         bcc.s   Undef
         bra     Rewr1

nomem    move.w  d3,d0
         andi.w  #$18,d0
         lsr.w   #2,d0
         cmpi.w  #4,d0
         beq.s   noxx
         addq.l  #1,a2
noxx     mulu    #5,d0
         adda.w  d0,a2
         move.w  d3,d7
         andi.w  #$e00,d7
         lsr.w   #8,d7
         lsr.w   #1,d7
         moveq   #1,d5    data register
         btst    #5,d3
         bne.s   isdata
         moveq   #12,d5   immediate
         moveq   #1,d6
         tst.w   d7
         bne.s   isdata
         moveq   #8,d7
isdata   bsr     Size
         move.w  d3,d4
         andi.w  #7,d4
         moveq   #0,d1
         moveq   #1,d2
         bra.s   Rewrite


**** UNDEFINED INSTRUCTION *****

Undef    lea     nodef(pc),a2       non defined opcode
         moveq   #0,d2
         movea.l SBegin(a0),a1  1st address
         move.w  (a1),d7
         moveq   #0,d2          type of 2nd address
         moveq   #2,d6          1st length = 2
         moveq   #8,d5          1st type = absolute
         moveq   #2,d0          .w qualifier
         moveq   #0,d1          write one word
         bra.s   Rewr1

Rewrite  tst.l   d0
         bmi.s   Undef
         cmpi.w  #1,d0
         ble.s   rere
         cmpi.w  #8,d2
         beq.s   dotest
         cmpi.w  #9,d2
         bne.s   rere
dotest   btst    #0,d4          make sure there are no (long) word
         bne.s   Undef          operations on odd addresses
rere     move.w  #0,-(a7)       no 3rd address
         move.l  d4,-(a7)       2nd address
         move.l  d4,SAddr2(a0)
         move.w  d3,-(a7)       2nd length
         move.w  d3,SLen2(a0)
Rewr1    tst.l   d0
         bmi.s   Undef
         move.w  d2,-(a7)       2nd type
         move.w  d2,SType2(a0)
         move.l  d7,-(a7)       1st address
         move.l  d7,SAddr1(a0)
         move.w  d6,-(a7)       1st length
         move.w  d6,SLen1(a0)
Rewr2    move.w  d5,-(a7)       1st type
         move.w  d5,SType1(a0)
         move.w  d0,-(a7)       qualifier
         move.l  a2,-(a7)       opcode text
         move.w  d1,-(a7)       number of words

***** FILL BUFFER ****

WriteBuf move.l  a0,d1          get buffer start
         addi.w  #SBuffer,d1
         movea.l d1,a1
         move.l  d1,d7
         addi.w  #42,d7

         movea.l a1,a2          clear buffer
         move.l  #$20202020,d0
         moveq   #20,d1
clear    move.l  d0,(a2)+
         dbra    d1,clear

         move.l  SRelAddr(a0),d1  get relative address
         moveq   #1,d5
         bsr     address         write relative address
         addq.l  #1,a1           blank

         moveq   #0,d3
         move.w  (a7)+,d3

         movea.l SBegin(a0),a2

         move.l  d3,d1           correction to addresses
         addq.l  #1,d1
         lsl.l   #1,d1
         move.w  d1,STotal(a0)
         move.l  a2,d0
         add.l   d1,d0
         move.l  d0,SBegin(a0)
         move.l  SRelAddr(a0),d0
         add.l   d1,d0
         move.l  d0,SRelAddr(a0)


*** HEX BYTES ***

Bloop    move.w  (a2)+,d1        write hex header
         bsr     words
         addq.l  #1,a1
         dbra    d3,Bloop
         movea.l d7,a1


*** OPCODE ***

         movea.l (a7)+,a2
         move.l  a2,d0
         subi.l  #nodef,d0
         move.w  d0,SOpCode(a0)
         move.w  d0,d6
         moveq   #10,d0          Write op code
opcod    move.b  (a2)+,(a1)+
         dbeq    d0,opcod
         subq.l  #1,a1
         move.b  #$20,(a1)

*** QUALIFIER ***


         moveq   #0,d4
         move.w  (a7)+,d4
         cmpi.b  #1,d4         No qualifier?
         beq.s   Qualno
         lea     pointb(pc),a0     Write qualifier
         adda.w  d4,a0
         bsr     wrbuf
Qualno   addq.l  #1,a1


*** ADDRESS MODE ***

         moveq   #0,d0
         move.w  (a7)+,d0      type of address
         beq     endaddr       no address

NAddress moveq   #0,d5
         move.w  (a7)+,d4      get length
         move.l  (a7)+,d1      get address
         cmpi.w  #1,d0
         bne.s   nodreg        Address mode Dn
         lea     RegText(pc),a0
         bsr     Dreg
         bra.s   endad1

nodreg   cmpi.w  #2,d0
         bne.s   noareg        Address mode An
         bsr     Areg
         bra.s   endad1

noareg   cmpi.w  #3,d0
         beq.s   a_reg         Address mode (An)

         cmpi.w  #4,d0
         bne.s   no_aa_r       Address mode (An)+
         bsr     Aareg
         move.b  #'+',(a1)+
         bra.s   endad1

no_aa_r  cmpi.w  #5,d0         Address mode -(An)
         bne.s   no_ba_r
         move.b  #'-',(a1)+
         bra.s   a_reg

no_ba_r  cmpi.w  #6,d0         Address mode d(An)
         bne.s   no_da_r
         move.w  d1,d7
         move.w  a3,d1
         bsr     sword
         move.w  d7,d1
a_reg    bsr     Aareg
         bra.s   endad1

no_da_r  cmpi.w  #7,d0         Address mode d(An,Rn)
         bne.s   no_dar_r
         move.w  d1,d7
         move.w  a3,d1
         bsr     sbyte         Write byte
         move.b  #$28,(a1)+    Write "("
         move.w  d7,d1
         bsr     Areg          Write register
         bra     Xpc

no_dar_r cmpi.w  #12,d0
         bne.s   tryabs
         move.b  #'#',(a1)+
         subq.w  #4,d0         Change mode to absolute

tryabs   cmpi.w  #9,d0         8,9
         bgt.s   trydpc

         tst.w   d4            signed byte
         bne.s   trybyte
         bsr     sbyte
endad1   bra     endad2

trybyte  move.b  #'$',(a1)+
         cmpi.w  #1,d4
         bne.s   tryword       Byte absolute
         bsr     byte
         bra.s   endad1

tryword  cmpi.w  #2,d4
         bne.s   trysw         Word absolute
         tst.w   d6
         bne.s   noform
         bsr     format
         bra.s   endad1
noform   bsr     word
         bra.s   endad1

trysw    cmpi.w  #3,d4         signed word
         bne.s   trylw
         subq.l  #1,a1
         bsr     sword
         bra.s   endad1

trylw    cmpi.w  #4,d4
         bne.s   endad1
         bsr     long          Long word absolute
         bra.s   endad1

trydpc   cmpi.w  #10,d0
         bne.s   trypc         d(PC)
         cmpi.w  #4,d4
         beq.s   pclng
         move.w  a3,d1
         bsr     sword
         bra.s   pcsht
pclng    move.b  #'$',(a1)+
         bsr     long
pcsht    bsr     wrpc
         bra.s   endbra

trypc    cmpi.w  #11,d0
         bne.s   tryccr        d(PC,Rn)
         move.w  a3,d1
         bsr     sbyte
         bsr     wrpc
Xpc      move.b  #',',(a1)+
         move.w  a3,d1
         lsr.w   #8,d1
         lsr.w   #4,d1
         lea     RegText(pc),a0
         bsr     Dreg
         lea     pointw(pc),a0
         move.w  a3,d1
         andi.w  #$f00,d1
         beq.s   isword
         addq.l  #2,a0
isword   bsr     wrbuf
endbra   move.b  #')',(a1)+
         bra     endad2

tryccr   cmpi.w  #13,d0        to ccr
         bne.s   trysr
         lea     Tccr(pc),a0
         bra.s   wrbuf3

trysr    cmpi.w  #14,d0        to sr
         bne.s   tryusp
         lea     Tsr(pc),a0
         bsr     wrbuf
         bra.s   endad2

tryusp   cmpi.w  #18,d0        to sfc/dfc/usp/vbr
         bgt.s   smovem
         lea     Tsfc(pc),a0
         subi.w  #15,d0
         mulu    #3,d0
         ext.l   d0
         adda.l  d0,a0
wrbuf3   bsr     wr3
         bra.s   endad2

smovem   cmpi.w  #19,d0
         bne.s   endad2
         moveq   #0,d4
         move.w  d1,d5
         moveq   #0,d6        first loop flag
floop    btst    d4,d5        find first nonzero bit in d1
         bne.s   first
         addq.w  #1,d4
         cmpi.w  #16,d4
         bne.s   floop
         beq.s   endad2       no more nonzero bits
first    move.w  d4,d2        save first reg
         bra.s   mnext
lloop    btst    d4,d5
         beq.s   islast
mnext    addq.w  #1,d4
         cmpi.w  #16,d4
         bne.s   lloop
islast   tst.l   d6
         beq.s   ffst
         move.b  #'/',(a1)+
ffst     moveq   #1,d6
         lea     RegText(pc),a0
         move.w  d2,d1
         bsr.s   Dreg
         move.w  d4,d1
         subq.w  #1,d1
         cmp.w   d1,d2
         beq.s   lstlp
         move.b  #'-',(a1)+
         lea     RegText(pc),a0
         bsr.s   Dreg
lstlp    cmpi.w  #16,d4
         bne.s   floop


endad2   move.w  (a7)+,d0      next type
         beq.s   endaddr       no more
         move.b  #',',(a1)+
         cmpa.l  #-1,a5
         beq.s   MAD
         movea.l a5,a3
MAD      bra     NAddress      Second address

endaddr  movem.l (a7)+,d0-d7/a3-a6
         rts

; Write (An)

Aareg    move.b  #'(',(a1)+
         bsr.s   Areg
         move.b  #')',(a1)+
         rts

; Write An

Areg     lea     RegA(pc),a0
Dreg     lsl.w   #1,d1
         add.w   d1,a0
wrbuf    move.b  (a0)+,(a1)+
         move.b  (a0)+,(a1)+
         rts

; Write (PC

wrpc     lea    PCtext(pc),a0
wr3      move.b (a0)+,(a1)+
         bra.s  wrbuf


; Conversion to hex
; a1 buffer (incremented)
; d0 lost
; d1 binary to write (unchanged)
; d2 lost

sword    tst.w   d1
         bpl.s   sw1
         neg.w   d1
         move.b  #'-',(a1)+
sw1      move.b  #'$',(a1)+
         bra.s   word

sbyte    tst.b   d1
         bpl.s   sb1
         neg.b   d1
         move.b  #'-',(a1)+
sb1      move.b  #'$',(a1)+
         bra.s   byte

; Write long word

long     tst.l   d1
         beq.s   null
         cmpi.l  #9,d1
         bhi.s   llong
         subq.l  #1,a1
llong    move.l  d1,d0
         swap    d0
         lsr.w   #8,d0
         bsr.s   byte1          1st byte of long


; Write address

address  move.l  d1,d0
         swap    d0
         bsr.s   byte1          1st byte of address
         bra.s   words

; Write hex word

word     tst.w   d1
         beq.s   null
         cmpi.w  #9,d1
         bhi.s   words
         subq.l  #1,a1
words    move.w  d1,d0
         lsr.w   #8,d0
         bsr.s   byte1          1st byte of word
         bra.s   bight
byte     tst.b   d1
         beq.s   null
         cmpi.b  #9,d1
         bhi.s   bight
         subq.l  #1,a1
bight    move.w  d1,d0

; Convert byte to ASCII and write into buffer

byte1    move.b  d0,d2          save byte
         lsr.b   #4,d0          high half byte
         bsr.s   byte2
         move.b  d2,d0          restore byte

; Convert half byte to ASCII and write into buffer

byte2    andi.b  #$f,d0         take lower half byte
         bne.s   write
         tst.w   d5
         beq.s   nowrite
write    moveq   #1,d5
         addi.b  #'0',d0        convert to "0" - "9"
         cmpi.b  #$3a,d0        above "9"?
         blt.s   nocorr
         addq.b  #7,d0          convert to "A" - "F"
nocorr   move.b  d0,(a1)+       write into buffer
nowrite  rts

null     subq.l  #1,a1
         move.b  #'0',(a1)+
         rts

; write word or ASCII

format   cmpi.b  #'''',d1
         beq.s   word
         cmpi.b  #' ',d1
         blt.s   word
         cmpi.b  #$7e,d1
         bgt.s   word
         move.w  d1,d0
         lsr.w   #8,d0
         cmpi.b  #'''',d0
         beq.s   word
         cmpi.b  #' ',d0
         blt.s   word
         cmpi.b  #$7e,d0
         bgt.s   word
         subq.l  #1,a1
         move.b  #'''',(a1)+
         move.b  d0,(a1)+
         move.b  d1,(a1)+
         move.b  #'''',(a1)+
         rts


; Decode <ea>,Dn or Dn,<ea>

Xdneasize move.w  d3,d0
         andi.w  #$100,d0
         movea.w d0,a4
         bsr.s   Dneasize
         cmpa.w  #0,a4
         beq.s   noswap
Swapreg  exg     d2,d5
         exg     d3,d6
         exg     d4,d7
noswap   rts


; Decode Dn,<ea>

Dneasize bsr.s  Size
Dnea     move.w d3,-(a7)
         bsr    DecAddr1
         move.w (a7)+,d4
         andi.w #$e00,d4
         lsr.w  #8,d4
         lsr.w  #1,d4
         moveq  #1,d2
         rts

; Get size of operand

Size     move.w  d3,d0
         andi.w  #$c0,d0
         lsr.w   #5,d0
         cmpi.w  #6,d0
         beq     rubbish
         rts

; Get vector address

Vector   moveq   #1,d0
         moveq   #0,d1
         moveq   #0,d2
         moveq   #12,d5
         moveq   #1,d6
         andi.w  #7,d3
         move.w  d3,d7
         rts

; Decode address for bit operation

Bit      move.w  d3,d0
         andi.w  #$100,d0
         bne.s   Rdata
         move.w  d3,d0
         andi.w  #$e00,d0
         cmpi.w  #$800,d0
         bne.s   rubbish
         move.w  (a1)+,d7
         cmpi.w  #31,d7         data must be 0..31
         bhi.s   rubbish
         moveq   #1,d0          no qualifier
         moveq   #1,d1          two words
         moveq   #12,d5         immediate
         moveq   #1,d6          byte
         bra.s   EndBit

Rdata    moveq   #1,d0          no qualifier
         moveq   #0,d1          one word
         moveq   #1,d5          type Dn
         move.w  d3,d7
         lsr.w   #8,d7
         lsr.w   #1,d7
EndBit   bsr.s   DecAddr2
         cmpi.w  #2,d2
         beq.s   rubbish        no  ",An"
         cmpi.w  #9,d2
         bgt.s   rubbish
         rts

; Decode address for immediate opcode

Imdt     move.l  d3,d6
         andi.w  #$c0,d6
         lsr.w   #5,d6           length of 1st operand
         move.l  d6,d0           qualifier
         moveq   #12,d5          type of 1st operand
         moveq   #1,d1           number of words - 1
         cmpi.w  #6,d0
         beq.s   rubbish
         cmpi.w  #4,d0
         beq.s   longop
         move.w  (a1)+,d7
         tst.w   d0
         bne.s   nolong
         moveq   #1,d6           byte operand
         cmpi.w  #$ff,d7         check if high byte = 0
         bgt.s   rubbish
         bra.s   nolong
longop   move.l  (a1)+,d7
         moveq   #2,d1
nolong   bsr.s   DecAddr2
         cmpi.w  #2,d2
         beq.s   rubbish         no  ",An"
         rts

; DecAddr1 decode second address and make it first

DecAddr1 tst.l   d0
         bmi.s   rubbish
         moveq   #0,d1
         bsr.s   DecAddr2
         move.w  d2,d5
         move.w  d3,d6
         move.l  d4,d7
         moveq   #0,d2
         rts

; DecAddr2 decode |effective address| as second address
;                 |  mode  |register|
; mode                       reg if mode = 7
; 0 = Dn                     000 = $xxxx
; 1 = An                     001 = $xxxx xxxx
; 2 = (An)                   010 = d(PC)
; 3 = (An)+                  011 = d(PC,Rn)
; 4 = -(An)                  100 = #$xxxx
; 5 = d(An)                  101 - 111 reserved
; 6 = d(An,Rn)

rubbish  moveq   #-1,d0
         rts
DecAddr2 move.w  d3,d2           type of second operand
         andi.w  #$38,d2
         lsr.w   #3,d2
         addq.w  #1,d2           mode
         move.w  d3,d4           address of second operand
         andi.w  #7,d4           register number
         cmpi.w  #8,d2
         beq.s   second
         cmpi.w  #6,d2
         blt.s   nodisp
         bne.s   fix7
getsec   addq.l  #1,d1           increment no of words
         move.w  (a1)+,a3        displacement
         cmpi.w  #10,d2          is it d(pc)?
         bne.s   nodisp
         moveq   #4,d3            write long address
         move.w  a3,d4
         ext.l   d4
         add.l   SRelAddr(a0),d4  get relative address
         addq.l  #2,d4
nodisp   rts
fix7     bsr.s   getsec          for d(An,Rn)
         tst.l   d0
         beq.s   is.b
         move.w  a3,d2           if the qualifier is not .b the
         andi.w  #1,d2           displacement must be even
         bne.s   rubbish
is.b     move.w  a3,d2           d must be X0YZ
         andi.w  #$f00,d2               or X8YZ
         cmpi.w  #$800,d2
         beq.s   fixed
         tst.w   d2
         bne.s   rubbish
fixed    moveq   #7,d2
         rts
second   moveq   #2,d3           assume length of word
         move.w  d4,d2
         addq.w  #8,d2           get address type
         cmpi.w  #10,d2
         beq.s   getsec          d(PC)
         cmpi.w  #11,d2
         beq.s   getsec          d(PC,Rn)
         cmpi.w  #9,d2
         bne.s   secwrd
secl     addq.w  #2,d1
         moveq   #4,d3
         move.l  (a1)+,d4        $xxxx xxxx/ #$xxxx xxxx
         rts
secwrd   cmpi.w  #12,d2
         bgt.s   trash    reserved
         bne.s   sec2     the #... address is determined
         cmpi.w  #4,d0    by the qualifier of the command
         beq.s   secl
         tst.w   d0
         bne.s   sec2
         move.w  (a1),d4       test if really is byte
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*
* As far as I can tell this test is formally not correct,  *
* ie. eg. $000041EE is interpreted exactly the same as     *
* $000000EE namely    ori.b #-$12,d0    by the processor.  *
* I know of no assembler or complier which produces        *
* anything else for the redundant byte XX in $0000XXEE     *
* other than 00 or FF. For this reason I believe this test *
* helps to discriminate code from data.                    *
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*
         andi.w  #$ff00,d4
         beq.s   byteok
         cmpi.w  #$ff00,d4
         bne.s   trash
byteok   moveq   #1,d3
sec2     addq    #1,d1          $xxxx / #$xxxx / #$xx
         move.w  (a1)+,d4
         rts

**** CHECK IF ADDRESS VALID *****

; d2 <> 2, 12

Check1   cmpi.w  #2,d2
         beq.s   trash
         cmpi.w  #12,d2
ccc      bne.s   ok
trash    moveq   #-1,d0
ok       rts

; d5 <> 1, 2, 4, 5, 12

Check2   cmpi.w  #1,d5
         beq.s   trash
         cmpi.w  #2,d5
         beq.s   trash
         cmpi.w  #4,d5
         beq.s   trash
         cmpi.w  #5,d5
         beq.s   trash
         cmpi.w  #12,d5
         bra.s   ccc

Group    dc.l Group0,Group1,Group2,Group3,Group4,Group5,Group6
         dc.l Group7,Group8,Group9,Undef,Groupb,Groupc,Groupd
         dc.l Groupe,Undef

******* OP CODE TEXTS *******

nodef    dc.b 'dc',0
TAbcd    dc.b 'abcd',0
TAdd     dc.b 'add',0
TAdda    dc.b 'adda',0
TAddi    dc.b 'addi',0
TAddq    dc.b 'addq',0
TAddx    dc.b 'addx',0
TAnd     dc.b 'and',0
TAndi    dc.b 'andi',0
TBchg    dc.b 'bchg',0
TBclr    dc.b 'b'
TClr     dc.b 'clr',0
TBfchg   dc.b 'bfchg',0
TBfclr   dc.b 'bfclr',0
TBfexts  dc.b 'bfexts',0
TBfextu  dc.b 'bfextu',0
TBfffo   dc.b 'bfffo',0
TBfins   dc.b 'bfins',0
TBfset   dc.b 'bfset',0
TBftst   dc.b 'bfset',0
TBkpt    dc.b 'bkpt',0
TBset    dc.b 'bset',0
TBtst    dc.b 'b'
TTst     dc.b 'tst',0
TCallm   dc.b 'callm',0
TCas     dc.b 'cas',0
TCas2    dc.b 'cas2',0
TChk     dc.b 'chk',0
TChk2    dc.b 'chk2',0
TCmp     dc.b 'cmp',0
TCmpa    dc.b 'cmpa',0
TCmpi    dc.b 'cmpi',0
TCmpm    dc.b 'cmpm',0
TCmp2    dc.b 'cmp2',0
TDivs    dc.b 'divs',0
TDivsl   dc.b 'divsl',0
TDivu    dc.b 'divu',0
TDivul   dc.b 'divul',0
TEor     dc.b 'e'
Tor      dc.b 'or',0
TEori    dc.b 'e'
TOri     dc.b 'ori',0
TExg     dc.b 'exg',0
TExtn    dc.b 'ext',0
TExtb    dc.b 'extb',0
TIllegal dc.b 'illegal',0
TJmp     dc.b 'jmp',0
TJsr     dc.b 'jsr',0
TLea     dc.b 'lea',0
TLink    dc.b 'link',0
TMove    dc.b 'move',0
TMovea   dc.b 'movea',0
TMovec   dc.b 'movec',0
TMovem   dc.b 'movem',0
TMovep   dc.b 'movep',0
TMoveq   dc.b 'moveq',0
TMoves   dc.b 'moves',0
TMuls    dc.b 'muls',0
TMulu    dc.b 'mulu',0
TNbcd    dc.b 'nbcd',0
TNeg     dc.b 'neg',0
TNegx    dc.b 'negx',0
TNop     dc.b 'nop',0
TNot     dc.b 'not',0
TPack    dc.b 'pack',0
TPea     dc.b 'pea',0
TReset   dc.b 'reset',0
TRtd     dc.b 'rtd',0
TRte     dc.b 'rte',0
TRtm     dc.b 'rtm',0
TRtr     dc.b 'rtr',0
TRts     dc.b 'rts',0
TSbcd    dc.b 'sbcd',0
TStop    dc.b 'stop',0
TSub     dc.b 'sub',0
TSuba    dc.b 'suba',0
TSubi    dc.b 'subi',0
TSubq    dc.b 'subq',0
TSubx    dc.b 'subx',0
TSwap    dc.b 'swap',0
TTas     dc.b 'tas',0
TTrap    dc.b 'trap',0
TTrapv   dc.b 'trapv',0
TUnlk    dc.b 'unlk',0
TUnpk    dc.b 'unpk',0

*** BRANCH OPERANDS ***

         dc.b 'dbt ',0
Branch   dc.b 'dbra',0
         dc.b ' bsr',0
         dc.b 'dbhi',0
         dc.b 'dbls',0
         dc.b 'dbcc',0
         dc.b 'dbcs',0
         dc.b 'dbne',0
         dc.b 'dbeq',0
         dc.b 'dbvc',0
         dc.b 'dbvs',0
         dc.b 'dbpl',0
         dc.b 'dbmi',0
         dc.b 'dbge',0
         dc.b 'dblt',0
         dc.b 'dbgt',0
         dc.b 'dble',0
Setcc    dc.b ' st',0
         dc.b ' sf',0
         dc.b 'shi',0
         dc.b 'sls',0
         dc.b 'scc',0
         dc.b 'scs',0
         dc.b 'sne',0
         dc.b 'seq',0
         dc.b 'svc',0
         dc.b 'svs',0
         dc.b 'spl',0
         dc.b 'smi',0
         dc.b 'sge',0
         dc.b 'slt',0
         dc.b 'sgt',0
         dc.b 'sle',0

*** LOGICAL OPERANDS ***

TAsr     dc.b ' asr',0
         dc.b ' asl',0
         dc.b ' lsr',0
         dc.b ' lsl',0
         dc.b 'roxr',0
         dc.b 'roxl',0
         dc.b ' ror',0
         dc.b ' rol',0

******* QUALIFIERS ******

pointb   dc.b '.b'
pointw   dc.b '.w'
         dc.b '.l'
         dc.b '.s'

*** REGISTER TEXTS ***

RegText  dc.b 'd0d1d2d3d4d5d6d7'
RegA     dc.b 'a0a1a2a3a4a5a6a7'
Tccr     dc.b 'ccr'
Tsr      dc.b 'sr'
PCtext   dc.b '(pc'
Tsfc     dc.b 'sfc'
         dc.b 'dfc'
         dc.b 'usp'
         dc.b 'vbr'
         end
