* Quick test of all pseudo ops - subject to detailed testing.
* After assembly, sinle step once to relocate relocs in line labelled
*   ldc3, to see they relocate correctly

 rts

* not tested herein
*  incbin
*  ibytes
*  xdef  global public
*  xref

* addsym - not supported

* align
lalign1 align 8  ;should make rel addr 0008
lalign2 align 16 ;should make rel addr 0010
lalign3 dc.b 1   ;should make rel addr 0011
lalign4 align 2  ;should make rel addr 0012
lalign5 align 4  ;should make rel addr 0014
lalign6 align 4  ;should do nothing
lalign7 set lalign1 ;s/be rel 0008
lalign7 set lalign2 ;s/be rel 0010
lalign7 set lalign3 ;s/be rel 0011
lalign7 set lalign4 ;s/be rel 0012
lalign7 set lalign5 ;s/be rel 0014
lalign7 set lalign6 ;s/be rel 0014

* ascii
 ascii 'a','bc',''     ;61 6263 -
 ascii '''"''',"""'""" ;272227 222722
 ascii '','ab
 ds.w 0                ;align - prev 6162

* bdebugarg - not supported

* bitstream
 bitstream 10111101000111 ;BD1C
 bitstream '1',"0",1      ;A0
 ds.w 0                   ;align

* blk see DCB

* bopt - not supported

* bss - not supported

* cargs
 cargs #16,ca_1.w,ca_2,ca_3.b,ca_4.l,ca_sizeof
ca set ca_1      ;0010
ca set ca_2      ;0012
ca set ca_3      ;0014
ca set ca_4      ;0016 (not 0015)
ca set ca_sizeof ;001A

* clrfo clrrs clrso - see fo

* cmacro - Tandem treats same as MACRO
lcma1 cmacro
 rts
 endm
lcma2 camcro
 rts
 endm
 lcma1       ;4E75
 lcma2       ;4E75
 rts         ;4E75

* cnop
lcno0 cnop 0,16   ;makes rel 0010
 cnop 0,16   ;does nothing
lcno1 cnop 1,2 ;makes 0011
lcno2 cnop 2,4 ;makes 0012
lcno3 cnop 3,8 ;makes 0013
lcno4 cnop 2,8 ;makes 001A
lcno5 cnop 0,2 ;makes 001A
lcno set lcno0 ;0010
lcno set lcno1 ;0011
lcno set lcno2 ;0012
lcno set lcno3 ;0013
lcno set lcno4 ;001A
lcno set lcno5 ;001A

* code cseg - not supported

* cstring
 ascii 'a','bc',''     ;6100 626300 00
 ascii '''"''',"""'""" ;27222700 22272200
 ascii 'ab
 ds.w 0                ;align - prev 616200

* data - not supported

* db nb pb sb ub - treated as dc.b
* dl nl pl sl ul - treated as dc.l
* dw nw pw sw uw - treated as dc.w
 dc.l 0,-1,+1,1,$FF ;00FF0101FF
 ds.w 0   ;00 (normalises)
 db 0     ;00
 nb -1    ;FF
 pb +1    ;01
 sb 1     ;01
 ub 255   ;FF

ldb1 dw 0 ;000000 (normalises)
 nw -1    ;FFFF
 pw +1    ;0001
 sw 1     ;0001
 uw 65535 ;FFFF
 dl 0     ;00000000
 nl -1    ;FFFFFFFF
 pl +1    ;00000001
 sl 1     ;00000001
 ul $FFFFFFFF ;FFFFFFFF
ldb set ldb1  ;s/be even

* dc - n.b. check that ldc2 addrs reloc correctly after step
 dc.b 0,'a','''','"',"'","""",'a''b' ;306127 222722 612762
ldc1 dc.w 'AB','''''','B',$1234      ;4142 2727 4200 1234
 dc.l 'ABCD','abc'                   ;41424344 61626300
ldc3 dc.l ldc1,ldc2                  ;.....
ldc2
ldc set ldc1   ;s/be even (asmlist addr+1)

* dcb (and blk dsb)
 dcb.b 5,'A' ;AAAAA
ldcb1 dcb.w 0,'A' ;0000
 dcb.w 2,'AB
 dcb.l 1,'ABCD' ;41424344, prev 41424142
ldcb2 equ ldcb1 ;s/be even
 blk 5,'A' ;4141414141
 dsb 5,'A' ;4141414141

* debug - not supported

* doscmd - not supported

* ds - can also have dcb syntax if 2 addresses

 ds.b 0      ;-
 ds.b 1      ;00
lds1 ds.w 0  ;00 0000 (normalises)
 ds.w 1      ;0000
lds set lds1 ;s/be even

* dsb - see dcb

* dsbin - not supported

* dseg - not supported

* dstring - not supported

* else - not supported

* elseif - not supported

* end - remove ; here to check assembly ends here

; end

* endif same as endc

* endc - see ifc

* endm - see macro

* equ
lequ1 equ $12345678
 move.l #lequ1,d0
lequ2 equ *
 move.l #lequ2,d0

* equr
leqr1 equr d0
leqr2 equr leqr1
 tst d0
 tst leqr1
 tst leqr2

* even
 dc.b $80
leven1 even      ;should assemble a null
level2 even      ;should do nothing
leven3 equ leven1 ;s/be even
leven4 equ leven2 ;s/be same as lenev3

* exeobj - tandem always does
 exeobj

* fail see last line

* filecom - not supported

* fo clrfo foreset foset foval setfo
* rs clrrs rsreset rsset rsval setrs
* so clrso soreset soset soval setso
 foreset
lfo0 fo 1
 rsreset
lrs0 rs 1
 soreset
lso0 so 1
 clrfo
lfo6 fo 1
 clrrs
lrs6 rs 1
 clrso
lso6 so 1
 foval 16
lfo1 fo.w 1
lfo2 fo 1
lfo3 fo.l 1
lfo4 fo.b 3
lfo5 fo 1
 rsval 16
lrs1 rs.w 1
lrs2 rs 1
lrs3 rs.l 1
lrs4 rs.b 3
lrs5 rs 1
 soval 16
lso1 so.w 1
lso2 so 1
lso3 so.l 1
lso4 so.b 3
lso5 so 1
 foval 8
lfo7 fo 1
 soval 8
lso7 so 1
 rsval 8
lrs7 rs 1
lfo set lfo0 ;0000
lfo set lfo6 ;0000
lfo set lfo1 ;0010
lfo set lfo2 ;000E
lfo set lfo3 ;000A
lfo set lfo4 ;0006
lfo set lfo5 ;0002 (not 0003)
lrs set lrs0 ;0000
lrs set lrs6 ;0000
lrs set lrs1 ;0010
lrs set lrs2 ;0012
lrs set lrs3 ;0014
lrs set lrs4 ;0018
lrs set lrs5 ;001C (not 001B)
lso set lso0 ;0000
lso set lso6 ;0000
lso set lso1 ;0010
lso set lso2 ;0012
lso set lso3 ;0014
lso set lso4 ;0018
lso set lso5 ;001C (not 001B)

* format - Tandem ignores
 FORMAT

* global - see xdef

* ibytes - test separately

* idnt identify

* ifc ifd ifeq ifge ifgt ifle iflt ifmacrod ifmacrond ifnc icnd
* illegal

* incbin - test separately

* incdir
* include
* incpath

* istring - not supported

* linkobj - tandem always does
 linkobj

* list
* listfile
* llen
* macro
* mask2
* mexit
* mc68000 mc68010 mc68020 mc68030 mc68040 mc68060 mc68881 mc68882

* nb nl nw - see pb

* noformat - Tandem ignores
 NOFORMAT

* nol nolist
* noobj
* nopage
* objfile

* odd
lodd1 odd     ;should assemble a null
lodd2 odd    ;should do nothing
lodd3 ds.w 0 ;re-align
lodd4 equ lodd1 ;s/be rel addr shown beside lodd1+2
lodd5 equ lodd2 ;s/be same as lodd4
lodd6 equ *     ;s/be lodd4+1

* offset
* org
* output
* pad - not supported

* page

* pb pl pw - see db

* plen
* printx

* pstring
 ascii 'a','bc',''     ;0161 026263 00
 ascii '''"''',"""'""" ;03272227 03222722
 ascii 'ab
 ds.w 0                ;align - prev 036162

* public - see xdef

* pure

* quad
 dc.b -1
lquad1 quad      ;should make rel addr xxx0
lquad2 quad      ;should do nothing
lquad3 equ lquad1 ;s/be xxx0
lquad4 equ lquad2 ;s/be same as lquad3

* reg
* repeat rept
* rorg
* rs rsreset rsset rsval - see fo

* sb sl sw - see db

* section
* set
* setfo setrs setso - see fo
* smalldata
* so soreset soset soval - see fo
* spc
* sprintx
* super
* sym - not supported
* trashreg
* ttl

* ub ul uw - see db

* xdef global public - not tested herein

* xref - not tested herein





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

* test IFcc statements        Yes line 0
 moveq #1,d0 ;                Yes line 1
 ifeq 0      ;#1              Yes line 2
 moveq #2,d0 ;true 1 (level 1) Yes line 3
 endc        ;#1               Yes line 4
 ifne 0      ;#2               } should
 moveq #3,d0 ;false (level 1)  } not be
 endc        ;#2               } in mc
 moveq #4,d0 ;                 Yes line 5
 ifne 1      ;#3>1             Yes line 6
 moveq #5,d0 ;true 2 (level 1) Yes line 7
 ifgt -1     ;#4>2             }
 moveq #6,d0 ;false (level 2)  } should
 ifeq 0      ;#5>3             } not be
 moveq #7,d0 ;false (level 3)  } in mc
 endc        ;#5>2             }
 endc        ;#4>1             }
 iflt -1     ;#6>2             Yes line 8
 moveq #7,d0 ;true 3 (level 2) Yes line 9
 endc        ;#6>1             Yes line 10
 endc        ;#3>0             Yes line 11
 moveq #8,d0 ;                 Yes line 12
 rts         ;                 Yes line 13

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

 moveq #0,d4       ;7800
 moveq #0,jack     ;7800
 moveq #0,john     ;7800
 move.l d0,-(a7)   ;2F00
 move.l d0,-(bill) ;2F00

* test REG
hugh: reg d0-d1/a1-a3
jane: reg hugh

 movem.l d0-d1/a1-a3,-(a7) ;48E7C070
 movem.l hugh,-(a7)        ;48E7C070
 movem.l jane,-(a7)        ;47E7C070
 movem.l (a7)+,d0-d1/a1-a3 ;4CDF0E03
 movem.l (a7)+,hugh        ;4CDF0E03
 movem.l (a7)+,jane        ;4CDF0E03

joan: reg d1-jack/bill/a2-a3

 movem.l d1-d4/a7/a2-a3,-(a4) ;48E47831
 movem.l joan,-(a4)           ;48E47831

^^^^



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

 move.l $4,d0   ;20380004
 move.l frew,d0 ;203912345678
 move.l bilq,d0 ;20381234
 move.l jacl,d0 ;20390000091C
 move.l $4.W,d0 ;20380004
 move.l $4.L,d0 ;203900000004
 rts            ;4E75

 END

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
* try MACRO and IFcc

fred: macro    ;test synthetic labels
 moveq #20,d0
 moveq #0,d1
L\@:           ;assemble as L_000
 addq.w #1,d1
 dbra d0,L\@   ;s/be same as dbra d0,jim blow
 nop
 endm

 fred ;70147200524151C8FFFC4E71
 moveq #20,d0  ;7014
 moveq #0,d1   ;7200
jim:
 addq.w #1,d1  ;5241
 dbra d0,jim   ;51C8FFFC
 rts           ;4E75

* test IFcc statements
* only true1,true2 & true3 should assemble
 moveq #1,d0 ;7001
 ifeq 0      ;#1
 moveq #2,d0 ;true 1 (level 1) 7002
 endc        ;#1
 ifne 0      ;#2
 moveq #3,d0 ;false (level 1)
 endc        ;#2
 moveq #4,d0 ;7004
 ifne 1      ;#3>1
 moveq #5,d0 ;true 2 (level 1) 7005
 ifgt -1     ;#4>2
 moveq #6,d0 ;false (level 2)
 ifeq 0      ;#5>3
 moveq #7,d0 ;false (level 3)
 endc        ;#5>2
 endc        ;#4>1
 iflt -1     ;#6>2
 moveq #7,d0 ;true 3 (level 2) 7007
 endc        ;#6>1
 endc        ;#3>0
 moveq #8,d0 ;7008
 rts         ;4E75

* test ifcc with mexit
bill: macro
 moveq #0,d0
 ifne 0       ;#1>1
 mexit        ;false
 endc         ;#1>0
 moveq #1,d0
 ifeq 0       ;#2>1
 mexit        ;true
 endc         ;#2>0
 moveq #3,d0
 endm

 nop  ;4E71
 bill ;7000 7001
 nop  ;4E71
 rts  ;4E75

* test DS and DC
 bra.s harry ;602E
jack:
 dc.b 'abcd' ;61626364
 ds.b 1      ;00
 ds.w 0      ;00
 dc.b 1,2,'ab''d',3*4 ;0102616227640C
 dc.w $1234,$4321     ;12344321
 dc.l jack,harry,$12345678 ;32.l,60.l,12345678
 dcb.b 3,$AA ;AAAAAA
 dcb 2,$1234 ;0012341234
 dcb.l 2,$BADFACED ;BADFACEDBADFACED
harry:
 rts         ;4E75

* test local labels
boll:
.boll:
12$: moveq #20,d0 ;7014
 bra 12$   ;60FC
 bra .boll ;60FA
frad:
.jeck:
12$: moveq #20,d0 ;7014
 bra 12$   ;60FC
 bra .jeck ;60FA

* forward references in expressions
 move.l #ferd,d0    ;203C12345678
 move.l #joon,d0    ;203C000000AC
 move.w #juck,d0    ;303C1234
 move.b #jill,d0    ;103C0012
joon:
 rts                ;4E75
ferd: equ $12345678
juck: equ $1234
jill: equ $12

* forward references in bra relative
 dbra d0,joon    ;51C8FFFC
 bra joon        ;60F8
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
 move.l #ken+jon,d0 ;203C00000004
ken: set 2
 move.l #ken+jon,d0 ;203C00000005
 nop                ;4E71
jon: equ 3

* doll in expressions with fwd refs
 move.l #june-*,d0   ;203C00000008
 nop                 ;4E71
june:

* test \@ invocation

derf: macro
 move.l #'\@',d0
 endm

llib: macro
 move.l #'\@',d0
 derf
 move.l #'\@',d0
 endm

cazz: macro
 nop
 endm

 llib ;203C5F303032,3,2
 cazz ;4E71
 llib ;203C5F303034,5,4
 rts  ;4E75

* unsupported opcodes - all should return errors
 ADDSYM
 BDEBUG
 BOPT
 BSS
 CODE
 CSEG
 DEBUG
 DOSCMD
 DSBIN
 DSEG
 DSTRING
 ELSE
 ELSEIF
 FILECOM
 ISTRING
 PAD
 SYM

* remove ; here to premit END to appear - will zap FAIL hereafter
Endhere:
; END

* fail
 FAIL ; causes fatal error
