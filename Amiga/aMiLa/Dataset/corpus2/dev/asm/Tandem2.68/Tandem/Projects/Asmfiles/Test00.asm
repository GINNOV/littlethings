* This program must NOT be run - it is for testing only.
* Before assembly, select Sundry, and set "change rel ext .L to .W" to "No"
* This is a quick all-over runthrough, subject to detailed testing

* test ADD/SUB/AND/OR/EOR

* test ADD,ADDA,ADDI     ;Devpac mc (except where Devpas's errors noted)
 add.w d3,d4             ;D843
 add.w a2,d5             ;DA4A
 add.w #$1234,d6         ;06461234
 add.w d1,$1234(a5)      ;D36D1234
 add.w d2,a3             ;D6C2
 addi.w #$1234,d6        ;06461234
 adda.w d2,a3            ;D6C2
 add.w #$1234,a3         ;D6FC1234
 adda.w #$1234,a3        ;D6FC1234
 add.w $1234(a5),a4      ;D8ED1234
 adda.w $1234(a5),a4     ;D8ED1234
 add.w #$1234,$4321(a4)  ;066C12344321
 addi.w #$1234,$4321(a4) ;066C12344321

* test SUB,SUBA,SUBI
 sub.w d3,d4             ;9843
 sub.w a2,d5             ;9A4A
 sub.w #$1234,d6         ;04461234
 sub.w d1,$1234(a5)      ;936D1234
 sub.w d2,a3             ;96C2
 subi.w #$1234,d6        ;04461234
 suba.w d2,a3            ;96C2
 sub.w #$1234,a3         ;96FC1234
 suba.w #$1234,a3        ;96FC1234
 sub.w $1234(a5),a4      ;98ED1234
 suba.w $1234(a5),a4     ;98ED1234
 sub.w #$1234,$4321(a4)  ;046C12344321
 subi.w #$1234,$4321(a4) ;046C12344321

* test AND,ANDI
 and.w d3,d4             ;C843
 and.w #$1234,d6         ;02461234
 and.w d1,$1234(a5)      ;C36D1234
 andi.w #$1234,d6        ;02461234
 and.w #$1234,$4321(a4)  ;026C12344321
 andi.w #$1234,$4321(a4) ;026C12344321
 and.w #$0012,CCR        ;023C0012
 andi.w #$0012,CCR       ;023C0012
 and.w #$1234,SR         ;027C1234
 andi.w #$1234,SR        ;027C1234

* test EOR,EORI
 eor.w d3,d4             ;B744
 eor.w d1,$1234(a5)      ;B36D1234
 eor.w #$1234,$4321(a4)  ;0A6C12344321
 eori.w #$1234,$4321(a4) ;0A6C12344321
 eor.w #$0012,CCR        ;0A3C0012
 eori.w #$0012,CCR       ;0A3C0012
 eor.w #$1234,SR         ;0A7C1234
 eori.w #$1234,SR        ;0A7C1234

* test OR,ORI
 or.w d3,d4              ;8843
 or.w #$1234,d6          ;00461234
 or.w d1,$1234(a5)       ;836D1234
 or.w #$1234,$4321(a4)   ;006C12344321
 ori.w #$1234,$4321(a4)  ;006C12344321
 or.w #$0012,CCR         ;003C0012
 ori.w #$0012,CCR        ;003C0012
 or.w #$1234,SR          ;007C1234
 ori.w #$1234,SR         ;007C1234

* test assembly of the syntax modes

* syntax 0
 nop                    ;4E71

* syntax 1
 abcd d4,d5             ;CB04
 sbcd -(a3),-(a2)       ;850B

* syntax 2 (branches to 3,4)
 add.b d1,(a4)          ;D314
 add.b (a4),d1          ;D214
 add.b d1,$64(a3)       ;D32B0064
 add.b $64(a3),d1       ;D22B0064
 add.b #$64,d1          ;06010064>ADDI
 add.b #$64,(a3)        ;06130064>ADDI
 add.b d3,d5            ;DA03
 add.l d3,a2            ;D5C3>ADDA
 add.l $23(a2,d4.l),a3  ;D7F24823>ADDA
 add.l d5,$64(a3)       ;DBAB0064

* syntax 3
 adda.l d3,a2           ;D5C3
 adda.l $23(a2,d4.l),a3 ;D7F24823

* syntax 4
 addi.b #$64,d1         ;06010064
 addi.b #$64,(a3)       ;06130064
 andi.w #$1234,10(a5)   ;026D1234000A
 ori.b #$67,(a6)        ;00160067
 eori.l #$12345678,D6   ;0A8612345678

* syntax 5
 addq.w #1,d0           ;5240
 addq.l #2,a7           ;548F

* syntax 6
 addx.l d0,d1           ;D380
 addx.w -(a0),-(a1)     ;D348

* syntax 7
 and.w #$FFBF,d0        ;0240FFBF
 and.l d0,$FF00         ;C1B8FF00/C1B90000FF00
 and.w #$1234,d5        ;02451234
 and.l #$12345678,-(a6) ;02A612345678
 and #$12,ccr           ;023C0012

* syntax 8
 andi #$12,ccr          ;023C0012

* syntax 9
 ori #$1234,sr          ;007C1234

* syntax 10
 asl.w #3,d4            ;E744
 asr.l #2,d7            ;E487
 ror.w d2,d3            ;E47B
 roxl.b d1,d5           ;E335
 asl 10(a3)             ;E1EB000A
 lsr 2(a4,a2.w)         ;E2F4A002

* syntax 11
Fred:
 nop                    ;4E71
 bra Fred               ;60FC
 bcc *+500              ;640001F2
 bcc.l *+70000          ;64FF0001116E  (See comments at start!!!)

* syntax 12
 bchg d0,d1             ;0141
 bchg #2,$FF00.L        ;087900020000FF00

* syntax 13
 bfchg (a4){10:12}      ;EAD4028C
 bfchg (a4){d2:12}      ;EAD4088C
 bfchg (a4){10:d3}      ;EAD402A3
 bfchg (a4){d2:d3}      ;EAD408A3

* syntax 14
 bkpt #4                ;484C

* syntax 15
 cas d3,d2,(a5)         ;0CD50083

* syntax 16
 cas2 d3:d3,d6:d7,(a4):(d3) ;0CFCC18331C3

* syntax 17
 chk.w (a4),d3          ;4794
 chk.l 3(a2),d5         ;4B2A0003

* syntax 18
 chk2.b -3(a5,d2.l),d2  ;00F5280028FD
 chk2.w (a3),d0         ;02D30800
 chk2.l 3(a0),a3        ;04E8B8000003

* syntax 19
 clr.b d2               ;4202
 clr.l 3(a2)            ;42AA0003

* syntax 20
 cmp.b 3(a5),d2         ;B42D0003
 cmp.w 3(a5),a2         ;B4ED0003
 cmp.l #$12345678,d2    ;B4BC12345678
 cmp.w #$1234,a3        ;B6FC1234
 cmp.l (a2)+,(a3)+      ;B78A

* syntax 21
 cmpi.w #$1234,d2       ;0C421234
 cmpi.b #$12,(a0)       ;0C100012
 cmpi.l #$123,3(a5)     ;0CAD000001230003

* syntax 22
 cmpm.b (a1)+,(a2)+     ;B509
 cmpm.l (a2)+,(a3)+     ;B78A

* syntax 23
 cmp2.b (a3),d4         ;00D34000
 cmp2.w 3(a4),a3        ;02ECB0000003

* syntax 24
 dbra D1,Fred           ;51C9FF7C
 dbge D7,*+20           ;5CCF0012

* syntax 25-28
 divs (a4),d5           ;8BD4
 divs.l (a4),d5         ;4C545805
 divs.l (a4),d5:d6      ;4C546C05
 divsl 2(a3),d2:d3      ;4C6B38020002
 divu.w (a2),d3         ;86D2
 divu.l (a2),d3         ;4C523003
 divu.l (a2),d3:d4      ;4C524403
 divul.l (a1),d7:d6     ;4C516007
 divul.l (a1),d7:d7     ;4C517007
 divu.l (a1),d3:d3      ;4C513403

* syntax 29
 eor.w d5,d6            ;BB46

* syntax 30
 exg d1,d2              ;C342
 exg d2,d1              ;C541
 exg d1,a2              ;C38A
 exg a1,d2              ;C589
 exg a1,a2              ;C34A/C549
 exg a2,a1              ;C549/C54A

* syntax 31
 ext.w d4               ;4884
 ext.l d5               ;48C5
 extb.l d6              ;49C6

* FPU binary operator
 ftwotox.b (a4),fp1      ;F2145891
 ftwotox.w (a4),fp2      ;F2145111
 ftwotox.l (a4),fp3      ;F2144191
 ftwotox.x (a4),fp4      ;F2144A11
 ftwotox.x fp2,fp3       ;F2000991
 ftwotox fp2,fp3         ;F2000991
 ftwotox.x fp2,fp2       ;F2000911
 ftwotox.x fp2           ;F2000911

* MOVE (& promotion to MOVEA)
 move.w a0,d0          ;3008
 move.b (a0),d0        ;1010
 move.l #$1000,$FF00.l ;23FC000010000000FF00
 move.l a0,-(a7)       ;2F08
 move.w #$FFFF,a0      ;307CFFFF>MOVEA
 move.l #$FFFF,a0      ;207C0000FFFF>MOVEA
 movea.w #$FFFF,a0     ;307CFFFF
 movea.l #$FFFF,a0     ;207C0000FFFF
 move.w #0,ccr         ;44FC0000
 move.w (a7)+,ccr      ;44DF
 move.w ccr,D0         ;42C0
 move.w ccr,-(a7)      ;42E7
 move.w sr,$FF00.l     ;40F90000FF00
 move.w sr,-(a7)       ;40E7
 move.w #$2700,sr      ;46FC2700
 move.w (a7)+,sr       ;46DF
 move.l usp,a0         ;4E68
 move.l a0,usp         ;4E60

* fmove
 fmove.b (a4),fp0 ;F2145800
 fmove.b (a4),fp7 ;F2145B80
 fmove.b fp0,(a4) ;F2147800
 fmove.b fp7,(a4) ;F2147B80
 fmove.x fp0,fp0  ;F2000000
 fmove.x fp0,fp7  ;F2000380
 fmove.x fp7,fp0  ;F2001C00
 fmove.x fp7,fp7  ;F2001F80
 fmove.w (a4),fp0 ;F2145000
 fmove.w fp0,(a4) ;F2147000
 fmove.l fp0,(a4) ;F2146000
 fmove.l fp0,(a4) ;F2146000
 fmove.s fp0,(a4) ;F2146400
 fmove.x fp0,(a4) ;F2146800
 fmove.d fp0,(a4) ;F2147400
 fmove.p fp0,(a4){D0}   ;F2147C00
 fmove.p fp0,(a4){D7}   ;F2147C70
 fmove.p fp0,(a4){#-64} ;F2146C40
 fmove.p fp0,(a4){#63}  ;F2146C3F
 fmove.x fp0,$1234(a5)  ;F22D68001234
 fmove.x $1234(a5),fp0  ;F22D48001234
 fmove.l (a4),fpcr      ;F2149000
 fmove.l (a4),fpsr      ;F2148800
 fmove.l (a4),fpiar     ;F2148400
 fmove.l fpcr,(a4)      ;F214B000
 fmove.l fpsr,(a4)      ;F214A800
 fmove.l fpiar,(a4)     ;F214A400
 fmove.x fp3,fp3        ;F2000D80
 fmove.p fp0,(a4){#-64} ;F2146C40
 fmove.p fp0,(a4){#63}  ;F2146C3F

* fmovem
 fmovem.l fpiar,-(a7)           ;F227A400
 fmovem.l (a7)+,fpiar           ;F21F8400
 fmovem.l fpiar/fpsr/fpcr,-(a7) ;F227BC00
 fmovem.l (a7)+,fpiar/fpsr/fpcr ;F21F9C00
 fmovem.x fp3,-(a7)             ;F227E008
 fmovem.x fp2/fp3,-(a7)         ;F227E00C
 fmovem.x fp1-fp3/fp4-fp5,-(a7) ;F227E03E
 fmovem.x (a7)+,fp3             ;F21FD010
 fmovem.x (a7)+,fp2/fp3         ;F21FD030
 fmovem.x (a7)+,fp1-fp3/fp4/fp5 ;F21FD07C
 fmovem.x d0,-(a3)              ;F223E800
 fmovem.x (a3)+,d7              ;F21BD870

* FPU unary opcode
 fabs.s d2,fp2   ;F2024518
 fabs.b (a5),fp1 ;F2155898
 fabs.w (a5),fp1 ;F2155098
 fabs.l (a5),fp1 ;F2154098
 fabs.s (a5),fp1 ;F2154498
 fabs.x (a5),fp1 ;F2154898
 fabs.p (a5),fp1 ;F2154C98
 fabs.d (a5),fp1 ;F2155498
 fabs.x fp2      ;F2000918
 fabs fp2,fp2    ;F2000918
 fabs.x fp0,fp1  ;F2000098
 fabs.x fp0,fp7  ;F2000398
 fabs.x fp7,fp0  ;F2001C18
 fabs.x fp7,fp6  ;F2001F18
 fabs.x $1234(a3),fp4 ;F22B4A181234
 facos.x (a5),fp3 ;F215499C
 fasin.x (a5),fp3 ;F215498C
 fatan.x (a5),fp3 ;F215498A
 fatanh.x (a5),fp3 ;F215498D
 fcos.x (a5),fp3  ;F215499D
 fcosh.x (a5),fp3 ;F2154999
 fetox.x (a5),fp3 ;F2154990
 fetoxm1.x (a5),fp3 ;F2154988
 fgetexp.x (a5),fp3 ;F215499E
 fgetman.x (a5),fp3 ;F215499F
 fint.x (a5),fp3    ;F2154981
 fintrz.x (a5),fp3  ;F2154983
 flog10.x (a5),fp3  ;F2154995
 flog2.x (a5),fp3   ;F2154996
 flogn.x (a5),fp3   ;F2154994
 flognp1.x (a5),fp3 ;F2154986(Devpac gives F2154985)
 fneg.x (a5),fp3    ;F215499A
 ftan.x (a5),fp3    ;F215498F
 ftanh.x (a5),fp3   ;F2154989
 ftentox.x (a5),fp3 ;F2154992
 ftwotox.x (a5),fp3 ;F2154991
 fsin.x (a5),fp3    ;F215498E
 fsinh.x (a5),fp3   ;F2154982
 fsqrt.x (a5),fp3   ;F2154984

* FPU binary opcodes
 fadd.s d2,fp2   ;F2024522
 fadd.b (a5),fp1 ;F21558A2
 fadd.w (a5),fp1 ;F21550A2
 fadd.l (a5),fp1 ;F21540A2
 fadd.s (a5),fp1 ;F21544A2
 fadd.x (a5),fp1 ;F21548A2
 fadd.p (a5),fp1 ;F2154CA2
 fadd.d (a5),fp1 ;F21554A2
 fadd.x fp2      ;F2000922
 fadd fp2,fp2    ;F2000922
 fadd.x fp0,fp1  ;F20000A2
 fadd.x fp0,fp7  ;F20003A2
 fadd.x fp7,fp0  ;F2001C22
 fadd.x fp7,fp6  ;F2001F22
 fadd.x $1234(a3),fp4 ;F22B4A221234
 fcmp.x (a3),fp5 ;F2134AB8
 fdiv.x (a3),fp5 ;F2134AA0
 fmod.x (a3),fp5 ;F2134AA1
 fmul.x (a3),fp5 ;F2134AA3
 frem.x (a3),fp5 ;F2134AA5
 fscale.x (a3),fp5 ;F2134AA6
 fsgldiv.x (a3),fp5 ;F2134AA4
 fsglmul.x (a3),fp5 ;F2134AA7
 fsub.x (a3),fp5 ;F2134AA8

* misc FPU instructions
 fsincos.w $1234(a5),fp1:fp2 ;F22D51311234
 fsincos fp3,fp1:fp2 ;F2000D31
 ftst.b $1234(a5)   ;F22D583A1234
 ftst.p $1234(a5)   ;F22D4C3A1234
 ftst.x fp7         ;F2001C3A
 fnop               ;F2800000
 frestore $1234(a5) ;F36D1234
 fsave $1234(a5)    ;F32D1234
 fbeq.w *+10        ;F2810008
 fbeq *+10          ;F2810008
 fbeq.l *+70000     ;F2C10001116E   (see comments at start!!!)
 fbf *+10           ;F2800008
 fbge *+10          ;F2930008
 fbgl *+10          ;F2960008
 fbgle *+10         ;F2970008
 fbgt *+10          ;F2920008
 fble *+10          ;F2950008
 fblt *+10          ;F2940008
 fbne *+10          ;F28E0008
 fbnge *+10         ;F29C0008
 fbngl *+10         ;F2990008
 fbngle *+10        ;F2980008
 fbngt *+10         ;F29D0008
 fbnle *+10         ;F29A0008
 fbnlt *+10         ;F29B0008
 fboge *+10         ;F2830008
 fbogl *+10         ;F2860008
 fbogt *+10         ;F2820008
 fbole *+10         ;F2850008
 fbolt *+10         ;F2840008
 fbor *+10          ;F2870008
 fbseq *+10         ;F2910008
 fbsf *+10          ;F2900008
 fbsne *+10         ;F29E0008
 fbst *+10          ;F29F0008
 fbt *+10           ;F28F0008
 fbueq *+10         ;F2890008
 fbuge *+10         ;F28B0008
 fbugt *+10         ;F28A0008
 fbule *+10         ;F28D0008
 fbult *+10         ;F28C0008
 fbun *+10          ;F2880008
 fdbeq d0,*+10      ;F24800010006
 fdbeq d7,*+10      ;F24F00010006
 fdbne d1,*+10      ;F249000E0006
 fdbgt d1,*+10      ;F24900120006
 fdbngt d1,*+10     ;F249001D0006
 fdbge d1,*+10      ;F24900130006
 fdbnge d1,*+10     ;F249001C0006
 fdblt d1,*+10      ;F24900140006
 fdbnlt d1,*+10     ;F249001B0006
 fdble d1,*+10      ;F24900150006
 fdbnle d1,*+10     ;F249001A0006
 fdbgl d1,*+10      ;F24900160006
 fdbngl d1,*+10     ;F24900190006
 fdbgle d1,*+10     ;F24900170006
 fdbngle d1,*+10    ;F24900180006
 fdbeq d1,*+10      ;F24900010006
 fdbne d1,*+10      ;F249000E0006
 fdbogt d1,*+10     ;F24900020006
 fdbule d1,*+10     ;F249000D0006
 fdboge d1,*+10     ;F24900030006
 fdbult d1,*+10     ;F249000C0006
 fdbolt d1,*+10     ;F24900040006
 fdbuge d1,*+10     ;F249000B0006
 fdbole d1,*+10     ;F24900050006
 fdbugt d1,*+10     ;F249000A0006
 fdbogl d1,*+10     ;F24900060006
 fdbueq d1,*+10     ;F24900090006
 fdbor d1,*+10      ;F24900070006
 fdbun d1,*+10      ;F24900080006
 fdbf d1,*+10       ;F24900000006
 fdbt d1,*+10       ;F249000F0006
 fdbsf d1,*+10      ;F24900100006
 fdbst d1,*+10      ;F249001F0006
 fdbseq d1,*+10     ;F24900110006
 fdbsne d1,*+10     ;F249001E0006
 fseq $1234(a5)     ;F26D00011234
 fsne $4321(a3)     ;F26B000E4321
 fsgt (a1)          ;F2510012
 fsngt (a1)         ;F251001D
 fsge (a1)          ;F2510013
 fsnge (a1)         ;F251001C
 fslt (a1)          ;F2510014
 fsnlt (a1)         ;F251001B
 fsle (a1)          ;F2510015
 fsnle (a1)         ;F251001A
 fsgl (a1)          ;F2510016
 fsngl (a1)         ;F2510019
 fsgle (a1)         ;F2510017
 fsngle (a1)        ;F2510018
 fseq (a1)          ;F2510001
 fsne (a1)          ;F251000E
 fsogt (a1)         ;F2510002
 fsule (a1)         ;F251000D
 fsoge (a1)         ;F2510003
 fsult (a1)         ;F251000C
 fsolt (a1)         ;F2510004
 fsuge (a1)         ;F251000B
 fsole (a1)         ;F2510005
 fsugt (a1)         ;F251000A
 fsogl (a1)         ;F2510006
 fsueq (a1)         ;F2510009
 fsor (a1)          ;F2510007
 fsun (a1)          ;F2510008
 fsf (a1)           ;F2510000
 fst (a1)           ;F251000F
 fssf (a1)          ;F2510010
 fsst (a1)          ;F251001F
 fseq (a1)          ;F2510001
 fsne (a1)          ;F251000E
 ftrapeq.w #$1234   ;F27A00011234
 ftrapne.l #$12345678 ;F27B000E12345678
 ftrapogt           ;F27C0002
 ftrapule           ;F27C000D
 ftrapoge           ;F27C0003
 ftrapult           ;F27C000C
 ftrapolt           ;F27C0004
 ftrapule           ;F27C000D
 ftrapole           ;F27C0005
 ftrapugt           ;F27C000A
 ftrapogl           ;F27C0006
 ftrapueq           ;F27C0009
 ftrapor            ;F27C0007
 ftrapun            ;F27C0008
 ftrapf             ;F27C0000
 ftrapt             ;F27C000F
 ftrapsf            ;F27C0010
 ftrapst            ;F27C001F
 ftrapseq           ;F27C0011
 ftrapsne           ;F27C001E
 fnop               ;F2800000
 frestore $1234(a5) ;F36D1234
 frestore (a3)+     ;F35B
 fsave -(a3)        ;F323
 ftst.b (a3)        ;F213583A
 ftst.p (a3)        ;F2134C3A
 ftst.l $1234(a7)   ;F22F403A1234
 ftst.x fp2         ;F200083A

* syntax 46
 nbcd $1234(a5)    ;482D1234
 tas $12(A1,A3.w)  ;4AF1B012

* syntax 47
 scc d0  ;54C0
 scs d1  ;55C1
 seq d2  ;57C2
 sf d3   ;51C3
 sge d4  ;5CC4
 sgt d5  ;5EC5
 shi d6  ;52C6
 sle d7  ;5FC7
 sls d0  ;53C0
 slt d1  ;5DC1
 smi d2  ;5BC2
 sne d3  ;56C3
 spl d4  ;5AC4
 st d5   ;50C5
 svc d6  ;58C6
 svs d7  ;59C7

* syntax 48
 lea $1234(a5),A3  ;47ED1234

* syntax 49
 link.w a2,#-20    ;4E52FFEC
 link.l a3,#-70000 ;480BFFFEEE90

* syntax 54
 movec a0,sfc  ;4E7B8000
 movec a7,dfc  ;4E7BF001
 movec d0,cacr ;4E7B0002
 movec d7,usp  ;4E7B7800
 movec a1,vbr  ;4E7B9801
 movec a2,caar ;4E7BA802
 movec d1,msp  ;4E7B1803
 movec d2,isp  ;4E7B2804
 movec sfc,a0  ;4E7A8000
 movec dfc,a7  ;4E7AF001
 movec cacr,d0 ;4E7A0002
 movec usp,d7  ;4E7A7800
 movec vbr,a1  ;4E7A9801
 movec caar,a2 ;4E7AA802
 movec msp,d1  ;4E7A1803
 movec isp,d2  ;4E7A2804

* syntax 55
 movem.w a0-a2/d1,-(a7) ;48A740E0
 movem.l a0,-(a7)       ;48E70080
 movem.l (a7)+,d3       ;4CDF0008
 movem.w (a7)+,d0-d7/a0-a6 ;4C9F7FFF

* syntax 56
 movep d3,4(a5)  ;078D0004
 movep 4(a5),d6  ;0D0D0004

* syntax 57
 moveq #$12,d0   ;7012
 moveq #$7F,d7   ;7E7F

* syntax 58
 moves.b a3,$1234(a5)    ;0E2DB8001234
 moves.w $1234(a5),a3    ;0E6DB0001234
 moves.l (a7)+,d1        ;0E9F1000
 moves.l d2,-(a7)        ;0EA72800

* syntax 59
 muls.w #$1234,D3        ;C7FC1234
 muls.l (a3),d4          ;4C134804
 muls.l (a4),d5:d6       ;4C146C05
 mulu.w $1234(a1),d2     ;C4E91234
 mulu.l d2,d3            ;4C023003
 mulu.l $4321(a1),d4:d5  ;4C2954044321

* syntax 60
 trapeq                  ;57FC
 trapeq.w #$1234         ;57FA1234
 trapeq.l #$12345678     ;57FB12345678

* syntax 61
 trap #15        ;4E4F
 trap #0         ;4E40

* syntax 62
 pack -(a3),-(a5),#0 ;8B4B0000
 pack d3,d4,#-1  ;8943FFFF

* syntax 63
 pea (a3)        ;4853
 pea $1234(a5)   ;486D1234
 jmp $1234(a5)     ;4EED1234
 jsr $12(A3,D4.L)  ;4EB34812

* syntax 64
 pflush #7,#7    ;F00030F7
 pflush #7,#0    ;F0003017
 pflush #0,#7    ;F00030F0
 pflush #0,#0    ;F0003010
 pflush d0,#7    ;F00030E8
 pflush d7,#7    ;F00030EF
 pflush sfc,#7   ;F00030E0
 pflush dfc,#7   ;F00030E1
 pflush d0,#7,(a3)      ;F01338E8
 pflush d0,#7,$1234(a3) ;F02B38E81234

* syntax 65
 pflusha         ;F0002400

* syntax 66
 ploadr #0,(a0)  ;F0102210
 ploadr #0,(a7)  ;F0172210
 ploadr #7,(a0)  ;F0102217
 ploadr d0,(a0)  ;F0102208
 ploadr d7,(a0)  ;F010220F
 ploadr sfc,(a0) ;F0102200
 ploadr dfc,(a0) ;F0102201
 ploadr #7,$1234(a0) ;F02822171234

* syntax 67
 ploadw #0,(a0)  ;F0102010
 ploadw #0,(a7)  ;F0172010
 ploadw #7,(a0)  ;F0102017
 ploadw d0,(a0)  ;F0102008
 ploadw d7,(a0)  ;F010200F
 ploadw dfc,(a0) ;F0102001
 ploadw #7,$1234(a0) ;F02820171234

* syntax 68
 pmove.d crp,(a0)    ;F0104E00
 pmove.d srp,(a0)    ;F0104A00
 pmove.l tc,(a0)     ;F0104200
 pmove.l tt0,(a0)    ;F0100A00
 pmove.l tt1,(a0)    ;F0100E00
 pmove.w mmusr,(a0)  ;F0106200
 pmove.d (a0),crp    ;F0104C00
 pmove.d (a0),srp    ;F0104800
 pmove.l (a0),tc     ;F0104000
 pmove.l (a0),tt0    ;F0100800
 pmove.l (a0),tt1    ;F0100C00
 pmove.w (a0),mmusr  ;F0106000

* syntax 69 (Devpac bug - allows PMOVEFD with MMUSR)
 pmovefd.d (a0),crp  ;F0104D00
 pmovefd.d (a0),srp  ;F0104900
 pmovefd.l (a0),tc   ;F0104100
 pmovefd.l (a0),tt0  ;F0100900
 pmovefd.l (a0),tt1  ;F0100D00

* syntax 70,71
 ptestr #0,(a5),#7   ;F0159E10
 ptestr #7,(a5),#7   ;F0159E17
 ptestr #0,(a5),#0   ;F0158210
 ptestr #7,(a5),#0   ;F0158217
 ptestr #7,$1234(a5),#0 ;F02D82171234
 ptestr #0,(a5),#7,a0 ;F0159F10
 ptestr #0,(a5),#7,a7 ;F0159FF0
 ptestw #0,(a5),#7   ;F0159C10
 ptestw #7,(a5),#0   ;F0158017
 ptestw #7,$1234(a5),#7       ;F02D9C171234
 ptestw #7,$1234(a5),#6,a0    ;F02D99171234
 ptestw #7,$43(a3,d1.l),#1,a6 ;F03385D71843

* syntax 72
 rtd #$1234                   ;4E741234
 stop #$4321                  ;4E724321

* syntax 73
 swap D3                      ;4843

* syntax 74
 tst.b D3                     ;4A03
 tst.w (a2)+                  ;4A5A
 tst.l $1234(a5)              ;4AAD1234

* syntax 75
 unlk A3                      ;4E5B

* miscellaneous pseudo ops

* test macro assembly

fred: macro    ;test \0 assembly
 move.\0 \1,\2 ;}should assemble
 move.l \1,\2  ;}same as each other
 endm

 fred.l $1234,$4321
 rts

free: macro    ;test \@ assembly
 moveq #20,d0
 moveq #0,d1
L\@:
 addq.w #1,d1
 dbra d0,L\@   ;s/be same as dbra d0,jim below
 nop
 endm
 free
 moveq #20,d0
 moveq #0,d1
jim:
 addq.w #1,d1
 dbra d0,jim
 rts

* test IFcc statements         Yes 0
 moveq #1,d0 ;                 Yes 1
 ifeq 0      ;#1               Yes
 moveq #2,d0 ;true 1 (level 1) Yes 2
 endc        ;#1               Yes
 ifne 0      ;#2               } should
 moveq #3,d0 ;false (level 1)  } not be
 endc        ;#2               } in mc
 moveq #4,d0 ;                 Yes 3
 ifne 1      ;#3>1             Yes
 moveq #5,d0 ;true 2 (level 1) Yes 4
 ifgt -1     ;#4>2             }
 moveq #6,d0 ;false (level 2)  } should
 ifeq 0      ;#5>3             } not be
 moveq #7,d0 ;false (level 3)  } in mc
 endc        ;#5>2             }
 endc        ;#4>1             }
 iflt -1     ;#6>2             Yes
 moveq #7,d0 ;true 3 (level 2) Yes 5
 endc        ;#6>1             Yes
 endc        ;#3>0             Yes
 moveq #8,d0 ;                 Yes 6
 rts         ;                 Yes 7

* test endcc with mexit
frex: macro
 moveq #0,d0
 ifne 0       ;#1>1  }should
 mexit        ;false }not be
 endc         ;#1>0  }in list
 moveq #1,d0
 ifeq 0       ;#2>1
 mexit        ;true
 endc         ;#2>0
 moveq #3,d0
 endm
 nop
 frex
 nop
 rts

* Test INCLUDE

 include 'incall.i'
 rts

* test DS and DC
 bra.s harry
 dc.b 'abcd'
frey:
 ds.b 1
 ds.w 0               ;(should normalise)
 dc.b 1,2,'abcd',3*4
 dc.w $1234,$4321     ;(should normalise)
 dc.l frey,harry,$12345678
harry:
 rts

* test EQUR
jack: equr d4
bill: equr a7
john: equr jack

 moveq #0,d4      ;} these 3
 moveq #0,jack    ;} s/be
 moveq #0,john    ;} same
 move.l d0,-(a7)    ;}  these 2
 move.l d0,-(bill)  ;}  s/be same

* test REG
hugh: reg d0-d1/a1-a3
jane: reg hugh

 movem.l d0-d1/a1-a3,-(a7) ;next 3 s/be same
 movem.l hugh,-(a7)
 movem.l jane,-(a7)
 movem.l (a7)+,d0-d1/a1-a3 ;next 3 s/be same
 movem.l (a7)+,hugh
 movem.l (a7)+,jane

joan: reg d1-jack/bill/a2-a3

 movem.l d1-d4/a7/a2-a3,-(a4) ;next 2 s/be same
 movem.l joan,-(a4)

* try local labels
bilp:
.bill:
12$: moveq #20,d0
 bra 12$
 bra .bill
frez:
.jack:
12$: moveq #20,d0
 bra 12$
 bra .jack

* test selection of .W/.L for addr mode 15,16
 nop
frew: equ $12345678
bilq: equ $1234
jacl:

 move.l $4,d0
 move.l frew,d0
 move.l bilq,d0
 move.l jacl,d0
 move.l $4.W,d0
 move.l $4.L,d0
 rts

* forward references in expressions
 move.l #frad,d0    ;203C12345678
 move.l #jpan,d0    ;203C00000014
 move.w #jock,d0    ;303C1234
 move.b #jill,d0    ;103C0012
jpan:
 rts                ;4E75

frad: equ $12345678
jock: equ $1234
jill: equ $12

* forward references in bra relative
 dbra d0,jpan    ;51C8FFFC
 bra jpan        ;60F8
 bra.s sue       ;6016
 bra.w sue       ;60000014
 bra.l sue       ;60FF00000010
 bsr.s sue       ;610A
 bsr sue         ;61000008
 dbra d0,sue     ;51C80004
 nop             ;4E71
sue:

* SET items in expressions with fwd refs
ken: set 1
 move.l #ken+jvhn,d0 ;203C00000004
ken: set 2
 move.l #ken+jvhn,d0 ;203C00000005
 nop                 ;4E71
jvhn: equ 3

* doll in expressions with fwd refs
 move.l #june-*,d0   ;203C00000008
 nop                 ;4E71
june:
