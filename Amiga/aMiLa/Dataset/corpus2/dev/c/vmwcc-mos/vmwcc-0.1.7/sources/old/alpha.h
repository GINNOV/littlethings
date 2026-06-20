/* p280 -- pseudo-ops */

/* RegistersR0 to R31 */
/* R31 = 0 */
/* Registers F0 to F31 */
/* F31 = 0 */

/* Memory Instruction Format */
/* Opcode 26 Ra 21 RB 16 Disp 0 */

/* Branch Instruction Format */
/* Opcode 26 Ra 21 Branch_disp 0 */

/* Operate Instruction Format */
/* Opcode 26 Ra 21 Rb 16 SBZ 13 0 12 Function 5 Rc 0 */
/* Opcode 26 Ra 21 LIT 13 1 12 Function 5 Rc 0 */

/* Floating Pointer Operate Instruction */
/* Opcode 26 Fa 21 Fb 16 Function 5 Fc 0 */

/* PAL Instruction Format */
/* Opcode 26 PALcode Func 0 */


     /* 61 */
LDA  0x08 /* Load Address  Ra = (rb)+sext(disp) */
LDAH 0x09 /* Load Address High Ra=(rb)+sext(disp*65536_*/

     /* 62 */
     /* (a)= (rb+sext(disp) */
LDBU 0x0a/* Load Zero Extended Byte */
LDL  0x28 /* Load Sign-extended Longword */
LDQ  0x29 /* Load Quadword */
LDWU 0x0c/* Load Zero-Extended Word */
  
      /* 64 */
LDQ_U 0x0b/* Load un-aligned quadword */

      /* 65 */  
LDL_L 0x2a /* Load locked */
LDQ_L 0x2b /* Load Locked */

      /* 68 */
      /* (a) -> { rb + sext(disp) } */
      /* Only if lock bit set */
STL_C 0x2e/* STore longword from reg to mem conditional */
STQ_C 0x2f/* Store quad " */
  
      /* 71 */
      /* (a) -> (rb+sext(disp)) */
STB   0x0e/* Store Byte */
STL   0x2c/* Store Long */
STQ   0x2d/* Store Quad */
STW   0x0d/* Store Word */
  
      /* 73 */
STQ_U 0x0f/* Store quad unaligned */
  
      /* 76 - Branch Format */
BEQ   0x39 /* Branch if reg equals zero */
BGE   0x3e /* Branch if reg >= 0 */
BGT   0x3f /* Branch if reg > 0  */
BLBC  0x38 /* Branch if register low bit clear */
BLBS  0x3c /* Branch if reg low bit set */
BLE   0x3b/* Branch if reg <=0 */
BLT   0x3a/* Branch if reg < 0 */
BNE   0x3d/* Branch if reg !=0 */
  
      /* 77 */
      /* PC -> Ra, pc+=4*sext(disp) */
BR    0x30 /* Unconditional branch */
BSR   0x34 /* Branch to Subroutine */
  
      /* 78 -- memory format*/
      /* PC->ra.  rb -> pc */
JMP   0x1a 0 /* Jump */
JSR   0x1a 1 /* Jump to subroutine */
RET   0x1a 2 /* Return from subroutine */
JSR_COROUTINE 0x1a 3/* Jump to subroutine return */
  
      /* 81 */
      /* rc <- ra+rb */
ADDL  0x10 00/* add longword */
  
      /* 82 */
      /* rc <- ra*4 + rb */
S4ADDL 0x10 02 /* Scaled Add by 4 */
S8ADDL 0x10 12 /* Scaled Add by 8 */
  
      /* 83 */
ADDQ  0x10 20/* Add Quadword */

      /* 84 */
S4ADDQ 0x10 22
S8ADDQ 0x10 32
  
      /* 85 */
      /* if RA (relation) RB then RC=1, else 0 */
CMPEQ 0x10 2d/* compare signed quadword equl */
CMPLE 0x10 6d /* less than or equal */
CMPLT 0x10 4d /* Less than */

      /* 86 */
CMPULE 0x10 3d /* Quadword less than or equal */
CMPULT 0x10 1d/* Less than */
  
      /* 87 */
      /* ra=r31.  ledaing zeros in rb -> rc */
CTLZ  0x1c 32/* Count Leading Zeros */
  
      /* 88 */
      /* ra=r31.  Number of ones in rb -> rc */
CTPOP  0x1c 30/* Count Population */
  
      /* 89 */
      /* ra=r31.  Trailing zeros in rc -> r0 */
CTTZ  0x1c 33 /* Count Trailing Zeros */
  
      /* 90 */
      /* ra *rb -> rc */
MULL  0x13 00/* Multiply Longword */
  
      /* 91 */
      /* ra*rb -> bottom 64 rc */
MULQ  0x13 20 /* multiply quad */
  
      /* 92 */
      /* ra*rb -> top 64 to rc */
UMULH 0x13 30 /* Unsigned multiply high */
  
      /* 93 */
      /* rc=ra-rb */
SUBL  0x10 09/* Longword subtract */
  
      /* 94 */
S4SUBL 0x10 0b/* scaled subtract */
S8SUBL 0x10 1b
  
     /* 95 */
SUBQ 0x10 29
  
     /* 96 */
S4SUBQ 0x10 2b
S8SUBQ 0x10 3b
  
    /* 98 */
AND 0x11 00/* rc = ra & rb  */
BIC 0x11 08 /* rc = ra & ^rb */
BIS 0x11 20 /* rc = ra | rb  */
EQV 0x11 48 /* rc = ra XOR ^rb */
ORNOT 0x11 28 /* tc= ra | ^rb */
XOR 0x11 40 /* rc = ra XOR rb */
  
/* (not can be had by ORNOT vs R31 */
  
  /* 99 */
  /* if CONDITION RA Rc=rb */
CMOVEQ  0x11 24
CMOVGE  0x11 46
CMOVGT 0x11 66
CMOVLBC 0x11 16
CMOVLBS 0x11 14
CMOVLE 0x11 64
CMOVLT 0x11 44
CMOVNE 0x11 26

  /* 101 */
  /* shifting with zeros propogated */
SLL 0x12 39/* Shift left Logical*/
SRL 0x12 34 /* Shift Right Logical */
  
  /* 102 */
    /* sign bit propogated */
SRA 0x12 3c/* shift right arithmatic */

    /* 105 */
CMPBGE 0x10 0f
EXTBL   0x12 06
  EXTWL 0x12 16
  EXTLL 0x12 26
  EXTQL 0x12 36
  EXTWH 0x12 5a
  EXTLH 0x12 6a
  EXTQH 0x12 7a
  INSBL 0x12 0b
  INSWL 0x12 1b
  INSLL 0x12 2b
  INSQL 0x12 3b
  INSWH 0x12 57
  INSLH 0x12 67
  INSQH 0x12 77
  MSKBL  0x12 02
  MSKWL  0x12 12
  MSKLL  0x12 22
  MSKQL  0x12 32
  MSKWH  0x12 52
  MSKLH  0x12 62
  MSKQH  0x12 72
  SEXTB  0x1c 00
  SEXTW  0x1c 01
  ZAP    0x12 30
  ZAPNOT 0x12 31

  
CALLSYS = 00.0083  
  
  /* Floating point 118 */
  
  /* Pseudo */
  UNOP = LDQ_U R31,0(Rx)
  NOP  = BIS R31,R31,R31
  FNOP = CPYS F31,F31,F31
  
  /* Clear a register */
  CLR = BIS R31,R31,Rx
  FCLR = CPYS F31,F31,Fx
  
  /* Load Literal */
  MOV #lit8,Ry == BIS R31, lit8, Ry
  
  /* for 32 bits */
  LDA Rdst, low(r31)
  LDAH Rdist, extra (Rdst)
      
  /* Move */
  MOV RX,RY = BIS RX,RX,RY
  FMOV FX,FY = CPYS FX,FX,FY
  
  /* Negate */
  NEGL Rx,Ry = SUBL R31,Rx,Ry
  NEGQ Rx,Ry = SUBQ R31,Rx,Ry
  
  /* NOT */
  NOT Rx,Ry = ORNOT R31, Rx, Ry
  
  
  /* OR */
  OR Rx,Ry,Rz = BIS Rx,Ry,Rz
  ANDNOT Rx,Ry,Rz = BIC Rx,Ry,Rz
  XORNOT Rx,Ry,Rz = EQV Rx,Ry,Rz
  
  /* Branch */
  BR target  == BR R31,target
  CLR Rx         BIS R31,r31,rx
  FABS           CPYS
  FCLR           CPYS
  FMOV           CPYS
  SEXTL    == ADDL R31,Rx, Ry
  
