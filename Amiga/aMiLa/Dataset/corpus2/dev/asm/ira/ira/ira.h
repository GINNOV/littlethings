/*
 * ira.h
 *
 *      Author   : Tim Ruehsen, Crisi, Frank Wille, Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : ira.h
 *      Purpose  : Contains definitions for all IRA sources
 *      Copyright: (C)1993-1995 Tim Ruehsen
 *                 (C)2009-2025 Frank Wille, (C)2014-2019 Nicolas Bastien
 */

#ifndef IRA_H
#define IRA_H

#define VERSION     "2"
#define REVISION    "11"

#ifndef __AMIGADATE__
#define __AMIGADATE__ "("__DATE__")"
#endif

#define IDSTRING1   ("\nIRA V%s.%s "__AMIGADATE__"\n" \
                     "(c)1993-1995 Tim Ruehsen (SiliconSurfer/PHANTASM)\n" \
                     "(c)2009-2025 Frank Wille\n" \
                     "(c)2014-2019 Nicolas Bastien\n\n")
#define IDSTRING2   ("; IRA V%s.%s "__AMIGADATE__" (c)1993-1995 Tim Ruehsen\n" \
                     "; (c)2009-2025 Frank Wille, (c)2014-2019 Nicolas Bastien\n\n")

#define NT_LIBRARY  9
#define NT_DEVICE   3
#define NT_RESOURCE 8

#define FNSIZE 108

#define lmovmem(x,y,a) memmove(y,x,(a)*sizeof(int32_t))

#define ADR_OUTPUT        (1<<0)  /* Output addresses in the code area  */
#define KEEP_BINARY       (1<<1)  /* Keep binary-intermediate file      */
#define SHOW_RELOCINFO    (1<<2)  /* Show relocations information       */
#define KEEP_ZEROHUNKS    (1<<3)  /* Keep zero-Hunks in output          */
#define OLDSTYLE          (1<<4)  /* Use old style EA-formats           */
#define SPLITFILE         (1<<5)  /* Put sections into own files        */
#define BASEREG1          (1<<6)  /* Address proposals for d16(Ax)      */
#define BASEREG2          (1<<7)  /* Base-relative mode d16(Ax)         */
#define PREPROC           (1<<8)  /* To find data in code sections      */
#define CONFIG            (1<<9)  /* Config file should be included     */
#define ROMTAGatZERO      (1<<10) /* Don't assume a code entry at adr=0 */
#define ESCCODES          (1<<11) /* Use Escape code '\' in strings     */
#define FIXLABELS         (1<<12) /* Fix potential illegal labels       */

/* Addressing styles for IRA parameters handling */
#define CPU_ADDR_STYLE     0
#define OLD_ADDR_STYLE     1
#define NEW_ADDR_STYLE     2

/* Label styles */
#define LABSTYLE_ORIG      0  /* LAB_<index> */
#define LABSTYLE_ADDR      1  /* LAB_<hex-addr> */

/* CPU defines for cpuname[][8] and CPUTYPE */
#define NOCPU              0
#define M68000            (1<<0)
#define M68010            (1<<1)
#define M68020            (1<<2)
#define M68030            (1<<3)
#define M68040            (1<<4)
#define M68060            (1<<5)
#define M68851            (1<<6)
#define M68881            (1<<7)
#define M68882            (1<<8)

/* Extended CPU defines for easier reading */
#define M680x0            (M68000 | M68010 | M68020 | M68030 | M68040 | M68060)
#define M010UP            (M680x0 ^ M68000)
#define M020UP            (M010UP ^ M68010)
#define M030UP            (M020UP ^ M68020)
#define M040UP            (M030UP ^ M68030)
#define M060UP            (M040UP ^ M68040)

/* Coprocessors */
/* Memory Management */
#define MMU_INTERNAL    (M68030 | M68040 | M68060)
#define MMU_EXTERNAL     M68851
#define MMU             (MMU_INTERNAL | MMU_EXTERNAL)
/* Floating Point */
#define FPU_INTERNAL    (M68040 | M68060)
#define FPU_EXTERNAL    (M68881 | M68882)
#define FPU             (FPU_INTERNAL | FPU_EXTERNAL)

/* Source types */

/* bits 0 and 1 define the kind of file */
#define SOURCE_KIND_MASK        0x03
#define SOURCE_KIND_OBJECT      0x01
#define SOURCE_KIND_EXECUTABLE  0x02
#define SOURCE_KIND_BINARY      0x03

/* bits 8 and 9 define the "family" of file */
#define SOURCE_FAMILY_MASK      0x30
#define SOURCE_FAMILY_NONE      0x00 /* because binaries are just binaries, no matter anything else */
#define SOURCE_FAMILY_AMIGA     0x10
#define SOURCE_FAMILY_ATARI     0x20
#define SOURCE_FAMILY_ELF       0x30 /* (almost) Unix family */

#define M68K_BINARY             (SOURCE_FAMILY_NONE  | SOURCE_KIND_BINARY)
#define AMIGA_HUNK_EXECUTABLE   (SOURCE_FAMILY_AMIGA | SOURCE_KIND_EXECUTABLE)
#define AMIGA_HUNK_OBJECT       (SOURCE_FAMILY_AMIGA | SOURCE_KIND_OBJECT)
#define ATARI_EXECUTABLE        (SOURCE_FAMILY_ATARI | SOURCE_KIND_EXECUTABLE)
#define ELF_EXECUTABLE          (SOURCE_FAMILY_ELF   | SOURCE_KIND_EXECUTABLE)

#define SOURCE_FILE_DESCR(id)   (id == M68K_BINARY ? "Binary" : \
                                 id == AMIGA_HUNK_EXECUTABLE ? "Amiga executable" : \
                                 id == AMIGA_HUNK_OBJECT ? "Amiga object" : \
                                 id == ATARI_EXECUTABLE ? "Atari executable" : \
                                 id == ELF_EXECUTABLE ? "Elf executable" : \
                                 "Unknown")

#define OPC_NONE                   0
#define OPC_BITFIELD               1
#define OPC_ROTATE_SHIFT_MEMORY    2
#define OPC_ROTATE_SHIFT_REGISTER  3
#define OPC_RTE                    4
#define OPC_RTR                    5
#define OPC_RTS                    6
#define OPC_RTD                    7
#define OPC_DIVL                   8
#define OPC_MULL                   9
#define OPC_JMP                   10
#define OPC_JSR                   11
#define OPC_PEA                   12
#define OPC_MOVEM                 13
#define OPC_LEA                   14
#define OPC_TST                   15
#define OPC_PACK_UNPACK           16
#define OPC_MOVE                  17
#define OPC_MOVEAL                18
#define OPC_MOVES                 19
#define OPC_MOVE16                20
#define OPC_RTM                   21
#define OPC_CALLM                 22
#define OPC_C2                    23
#define OPC_CMPI                  24
#define OPC_BITOP                 25
#define OPC_DBcc                  26
#define OPC_Bcc                   27
#define OPC_PMMU                  28
#define OPC_PFLUSH040             29
#define OPC_PBcc                  30
#define OPC_PDBcc                 31
#define OPC_CACHE_SCOPE           32
#define OPC_PLPA                  33
#define OPC_LPSTOP                34
#define OPC_PScc                  35
#define OPC_PTRAPcc               36
#define OPC_PTEST040              37

/* OpCode.flags:
 * 0x0100 : the MMU condition code identifier has to be appended to the mnemonic.
 * 0x0080 : operand size is in bits [0:1] (0=.B,1=.W,2=.L) else use opsize from opcode
 * 0x0040 : operand size has to be appended to mnemonic
 * 0x0020 : one further word has to be saved before further processing.
 * 0x0010 : the condition code identifier has to be appended to the mnemonic. */
#define OPF_APPEND_PCC             0x0100
#define OPF_OPERAND_SIZE           0x0080
#define OPF_OPERAND_BYTE              OPF_OPERAND_SIZE | 0x0000
#define OPF_OPERAND_WORD              OPF_OPERAND_SIZE | 0x0001
#define OPF_OPERAND_LONG              OPF_OPERAND_SIZE | 0x0002
#define OPF_OPERAND_MASK              0x0003
#define OPF_APPEND_SIZE            0x0040
#define OPF_ONE_MORE_WORD          0x0020
#define OPF_APPEND_CC              0x0010
#define OPF_NO_FLAG                0x0000

/* Be careful ! This only valid for OpCode.sourceadr and OpCode.destadr
 * Bit 15    : 1 ==> the only possible addr.mode is in the lower byte
 * Bit 14-13 : Tell which register number to use (effective, alternate or extension).
 *                   00 ==> reg = ira->ea_register
 *                   01 ==> reg = ira->alt_register
 *                   10 ==> reg = ira->ext_register
 */

#define MODE_IN_LOWER_BYTE                  0x8000
#define MODE_IN_LOWER_BYTE_MASK             0x00ff
#define MODE_ALT_REGISTER                   0x2000
#define MODE_EXT_REGISTER                   0x4000
#define MODE_NONE                           0x0000
#define MODE_SPECIFIC                       0x0000 /* Same value as MODE_NONE and same behaviour. It only exists to get explicit declaration in constants.c and have more readable code */

/* First modes (up to 0x000b) stick to <ea> encoding: see comments in GetOpcode() */

/* Data Register Direct Mode
 *    assembler syntax:          Dn
 *    <ea> mode field:           000
 *    <ea> register field:       register number
 *    number of extension words: 0
 */
#define MODE_DREG_DIRECT                    0x0000

/* Address Register Direct Mode
 *    assembler syntax:          An
 *    <ea> mode field:           001
 *    <ea> register field:       register number
 *    number of extension words: 0
 */
#define MODE_AREG_DIRECT                    0x0001

/* Address Register Indirect Mode
 *    assembler syntax:          (An)
 *    <ea> mode field:           010
 *    <ea> register field:       register number
 *    number of extension words: 0
 */
#define MODE_AREG_INDIRECT                  0x0002

/* Address Register Indirect with Postincrement Mode
 *    assembler syntax:          (An)+
 *    <ea> mode field:           011
 *    <ea> register field:       register number
 *    number of extension words: 0
 */
#define MODE_AREG_INDIRECT_POST             0x0003

/* Address Register Indirect with Predecrement Mode
 *    assembler syntax:          -(An)
 *    <ea> mode field:           100
 *    <ea> register field:       register number
 *    number of extension words: 0
 */
#define MODE_AREG_INDIRECT_PRE              0x0004

/* Address Register Indirect with Displacement Mode
 *    assembler syntax:          (d16,An)
 *    <ea> mode field:           101
 *    <ea> register field:       register number
 *    number of extension words: 1
 */
#define MODE_AREG_INDIRECT_D16              0x0005

/* Address Register Indirect with Index (8-Bit Displacement) Mode
 *    assembler syntax:          (d8,An,Xn.SIZE*SCALE)
 *    <ea> mode field:           110
 *    <ea> register field:       register number
 *    number of extension words: 1
 *
 * OR
 *
 * Address Register Indirect with Index (Base Displacement) Mode
 *    assembler syntax:          (bd,An,Xn.SIZE*SCALE)
 *    <ea> mode field:           110
 *    <ea> register field:       register number
 *    number of extension words: 1, 2 or 3
 *
 * OR
 *
 * Memory Indirect Postindexed Mode
 *    assembler syntax:          ([bd,An],Xn.SIZE*SCALE,od)
 *    <ea> mode field:           110
 *    <ea> register field:       register number
 *    number of extension words: 1, 2, 3, 4, or 5
 *
 * OR
 *
 * Memory Indirect Preindexed Mode
 *    assembler syntax:          ([bd,An,Xn.SIZE*SCALE],od)
 *    <ea> mode field:           110
 *    <ea> register field:       register number
 *    number of extension words: 1, 2, 3, 4, or 5
 */
#define MODE_AREG_INDIRECT_INDEX            0x0006

/* Absolute Short Addressing Mode
 *    assembler syntax:          (xxx).W
 *    <ea> mode field:           111
 *    <ea> register field:       000
 *    number of extension words: 1
 */
#define MODE_ABSOLUTE_16                    0x0007

/* Absolute Long Addressing Mode
 *    assembler syntax:         (xxx).L
 *    <ea> mode field:           111
 *    <ea> register field:       001
 *    number of extension words: 2
 */
#define MODE_ABSOLUTE_32                    0x0008

/* Program Counter Indirect with Displacement Mode
 *    assembler syntax:          (d16,PC)
 *    <ea> mode field:           111
 *    <ea> register field:       010
 *    number of extension words: 1
 */
#define MODE_PC_RELATIVE                    0x0009

/* Program Counter Indirect with Index (8-bit Displacement) Mode
 *    assembler syntax:          (d8,PC,Xn.SIZE*SCALE)
 *    <ea> mode field:           111
 *    <ea> register field:       011
 *    number of extension words: 1
 *
 * OR
 *
 * Program Counter Indirect with Index (Base Displacement) Mode
 *    assembler syntax:          (bd,PC,Xn.SIZE*SCALE)
 *    <ea> mode field:           111
 *    <ea> register field:       011
 *    number of extension words: 1, 2 or 3
 *
 * OR
 *
 * Program Counter Memory Indirect Postindexed Mode
 *    assembler syntax:          ([bd,PC],Xn.SIZE*SCALE,od)
 *    <ea> mode field:           111
 *    <ea> register field:       011
 *    number of extension words: 1, 2, 3, 4, or 5
 *
 * OR
 *
 * Program Counter Memory Indirect Preindexed Mode
 *    assembler syntax:          ([bd,PC,Xn.SIZE*SCALE],od)
 *    <ea> mode field:           111
 *    <ea> register field:       011
 *    number of extension words: 1, 2, 3, 4, or 5
 */
#define MODE_PC_INDIRECT_INDEX              0x000a

/* Immediate Data
 *    assembler syntax:          #<xxx>
 *    <ea> mode field:           111
 *    <ea> register field:       100
 *    number of extension words: 1, 2, 4 OR 6 (except for packed decimal real operands)
 */
#define MODE_IMMEDIATE                      0x000b

#define EA_MASK                             0x0fff
#define EA_SELECTOR_BIT                     0x0800

#define D_DIR                               EA_SELECTOR_BIT >> MODE_DREG_DIRECT
#define A_DIR                               EA_SELECTOR_BIT >> MODE_AREG_DIRECT
#define A_IND                               EA_SELECTOR_BIT >> MODE_AREG_INDIRECT
#define A_IND_POST                          EA_SELECTOR_BIT >> MODE_AREG_INDIRECT_POST
#define A_IND_PRE                           EA_SELECTOR_BIT >> MODE_AREG_INDIRECT_PRE
#define A_IND_D16                           EA_SELECTOR_BIT >> MODE_AREG_INDIRECT_D16
#define A_IND_IDX                           EA_SELECTOR_BIT >> MODE_AREG_INDIRECT_INDEX
#define ABS16                               EA_SELECTOR_BIT >> MODE_ABSOLUTE_16
#define ABS32                               EA_SELECTOR_BIT >> MODE_ABSOLUTE_32
#define PC_REL                              EA_SELECTOR_BIT >> MODE_PC_RELATIVE
#define PC_IND                              EA_SELECTOR_BIT >> MODE_PC_INDIRECT_INDEX
#define IMMED                               EA_SELECTOR_BIT >> MODE_IMMEDIATE

/* Here start custom modes */
#define MODE_CCR                            0x000c
#define MODE_SR                             0x000d
#define MODE_USP                            0x000e
#define MODE_MOVEM                          0x000f
#define MODE_ADDQ_SUBQ                      0x0010
#define MODE_BKPT                           0x0011
#define MODE_DBcc                           0x0012
#define MODE_TRAP                           0x0013
#define MODE_MOVEQ                          0x0014
#define MODE_Bcc                            0x0015
#define MODE_SP_DISPLACE_W                  0x0016
#define MODE_BIT_MANIPULATION               0x0017 /* BTST,BCLR,... immediate & register, source operand only */
#define MODE_BITFIELD                       0x0018
#define MODE_RTM                            0x0019
#define MODE_CAS2                           0x001a /* CAS2 source & destination */
#define MODE_CAS                            0x001b /* CAS source */
#define MODE_MUL_DIV_LONG                   0x001c /* DIV & MUL .L, signed & unsigned */
#define MODE_SP_DISPLACE_L                  0x001d
#define MODE_CACHE_REG                      0x001e /* CINV and CPUSH cache registers */
#define MODE_MOVEC                          0x001f
#define MODE_MOVES                          0x0020
#define MODE_ROTATE_SHIFT                   0x0021 /* Register rotate and shift */
#define MODE_PBcc                           0x0022
#define MODE_PDBcc                          0x0023
#define MODE_FC                             0x0024
#define MODE_FC_MASK                        0x0025
#define MODE_PVALID                         0x0026
#define MODE_PREG_TT                        0x0027
#define MODE_PREG1                          0x0028
#define MODE_PREG2                          0x0029
#define MODE_PTEST                          0x002a

#define MODE_INVALID                        0x00ff /* mode for DC.W */

/* SEAOW */
/* Extension size */
#define EXTENSION_SIZE_MASK                 0x00c0
#define ALT_EXTENSION_SIZE_MASK             0x0600

/* <ea> fields */
#define EFFECTIVE_ADDRESS_MASK              0x003f
#define EA_MODE_FIELD_MASK                  0x0038
#define EA_REG_FIELD_MASK                   0x0007
#define EA_REG_FIELD_IS_NOT_REG_NUMBER      0x0038

#define ALT_REGISTER_MASK                   0x0e00
#define ALT_MODE_MASK                       0x01c0
#define ROTATE_SHIFT_COUNT_MASK             0x0e00

#define cc_MASK                             0x0f00
#define Pcc_MASK                            0x000f /* CC code is over 6 bits and its mask should be 0x3f but as far as only 4 lower bits are effective, it is safe to have a 0x0f mask as a control */

/* EXTENSION WORD */
/* Field D/A in extension word */
#define REGISTER_EXTENSION_TYPE             0x8000

/* Register mask in extension word */
#define REGISTER_EXTENSION_MASK             0x7000

/* Field dr in extension word */
#define DIRECTION_EXTENSION_MASK            0x0800

/* Field i/r in instruction word */
#define IMMEDIATE_OR_REGISTER_BIT           0x0020

/* bitfield's identifier in instruction word */
#define BITFIELD_IDENTIFIER_MASK            0x0700
#define BITFIELD_IDENTIFIER_TST             0
#define BITFIELD_IDENTIFIER_EXTU            1
#define BITFIELD_IDENTIFIER_CHG             2
#define BITFIELD_IDENTIFIER_EXTS            3
#define BITFIELD_IDENTIFIER_CLR             4
#define BITFIELD_IDENTIFIER_FFO             5
#define BITFIELD_IDENTIFIER_SET             6
#define BITFIELD_IDENTIFIER_INS             7

/* Field Dw in bitfield's extension word */
#define BITFIELD_DATA_WIDTH_BIT             0x0020

/* Field dr in MOVEC instruction */
#define MOVEC_DIRECTION_BIT                 0x0001

/* Control register masks in MOVEC */
#define MOVEC_CONTROL_REGISTER_MASK         0x0fff
#define MOVEC_CR_HIGHER_RANGE_BIT           0x0800

/* Illegal control register id mask in MOVEC */
#define ILLEGAL_CONTROL_REGISTER            0x07f0

/* MOVES extension word */
#define MOVES_EXTENSION_MASK                0x07ff

/* CAS extension word */
#define CAS_EXTENSION_MASK                  0xfe38
#define CAS_EXTENSION_DU                    0x01c0
#define CAS_EXTENSION_DC                    0x0007

/* PMMU stuff */
/* SEAOW                         |                   | mod | reg |
                                 |1 1 1 1 0 0 0 0 0 0|x x x|x x x|
   EXTRAs
      **EC030 not supported by IRA**
      pmove EC030 ACX reg        |     |preg |R|                 |
                                 |0 0 0|x x x|x|0 0 0 0 0 0 0 0 0|

      pmove 030 TT reg           |     |preg |R|F|               |
                                 |0 0 0|x x x|x|x|0 0 0 0 0 0 0 0|

      pload                      |           |R|       |   FC    |
                                 |0 0 1 0 0 0|x|0 0 0 0|x x x x x|

      pvalid (val)               |0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0|

      pvalid (main CPU)          |                         | reg |
                                 |0 0 1 0 1 1 0 0 0 0 0 0 0|x x x|

      pflush 030                 |     | mod |   |mask |   FC    |
                                 |0 0 1|x x x|0 0|x x x|x x x x x|

      pflush 851                 |     | mod | | mask  |   FC    |
                                 |0 0 1|x x x|0|x x x x|x x x x x|

      pmove 851                  |     |preg |R|                 |
                                 |0 1 0|x x x|x|0 0 0 0 0 0 0 0 0|

      pmove 030 (SRP, CRP, TCR)  |     |preg |R|F|               |
                                 |0 1 0|x x x|x|x|0 0 0 0 0 0 0 0|

      pmove 030 (MMU)            |           |R|                 |
                                 |0 1 1 0 0 0|x|0 0 0 0 0 0 0 0 0|

      **EC030 not supported by IRA**
      pmove EC030 (ACUSR)        |           |R|                 |
                                 |0 1 1 0 0 0|x|0 0 0 0 0 0 0 0 0|

      pmove 851 (PSR, PCSR)      |     |preg |R|                 |   preg: 000 = PSR / 001 = PCSR (from PCSR only!)
                                 |0 1 1|x x x|x|0 0 0 0 0 0 0 0 0|

      pmove 851 (BADx, BACx)     |     |preg |R|       | num |   |   preg: 100 = BAD / 101 = BAC
                                 |0 1 1|x x x|x|0 0 0 0|x x x|0 0|

      **EC030 not supported by IRA**
      ptest EC030                |           |R| | reg |    FC   |
                                 |1 0 0 0 0 0|x|0|x x x|x x x x x|

      ptest 030/851              |     |level|R|A| reg |    FC   |
                                 |1 0 0|x x x|x|x|x x x|x x x x x|

      pflushr                    |1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0|

* **************************

   SEAOW                         |                   | mod | reg |
      prestore                   |1 1 1 1 0 0 0 1 0 1|x x x|x x x|

   SEAOW                         |                   | mod | reg |
      psave                      |1 1 1 1 0 0 0 1 0 0|x x x|x x x|

*/
#define PMMU_MASK                           0xe000
#define PMMU_PMOVE_030_TT                   0x0000
#define PMMU_PLOAD_or_PVALID_or_PFLUSH      0x2000
#define PMMU_PMOVE_851_or_030_format1       0x4000
#define PMMU_PMOVE_851_or_030_format2       0x6000
#define PMMU_PTEST                          0x8000
#define PMMU_PFLUSHR                        0xa000

#define PLOAD_or_PVALID_or_PFLUSH_MODE_MASK 0x1c00
#define PMMU_RW_BIT_MASK                    0x0200
#define PMMU_FD_BIT_MASK                    0x0100

#define PMMU_PREG_MASK                      0x1c00
/* P register 030 TT */
#define PMMU_PREG_TT0                       0x0800
#define PMMU_PREG_TT1                       0x0c00
/* P register instruction format 1 */
#define PMMU_PREG_TC                        0x0000
#define PMMU_PREG_DRP                       0x0400
#define PMMU_PREG_SRP                       0x0800
#define PMMU_PREG_CRP                       0x0c00
#define PMMU_PREG_CAL                       0x1000
#define PMMU_PREG_VAL                       0x1400
#define PMMU_PREG_SCC                       0x1800
#define PMMU_PREG_AC                        0x1c00
/* P register instruction format 2 & 3 */
#define PMMU_PREG_PSR                       0x0000
#define PMMU_PREG_PCSR                      0x0400
#define PMMU_PREG_BAD                       0x1000
#define PMMU_PREG_BAC                       0x1400

#define PMMU_FC_MASK                        0x001f
#define PMMU_FC_SPEC_IMMED                  0x0010
#define PMMU_FC_SPEC_DREG                   0x0008
#define PMMU_FC_SPEC_FCREG_SFC              0x0000
#define PMMU_FC_SPEC_FCREG_DFC              0x0001

#define PMMU_FC_SPEC_IMMED_MASK             0x000f
#define PMMU_FC_SPEC_DREG_MASK              0x0007

/* PLOAD */
#define PLOAD_PSEUDO_MODE                   0x0000
#define PLOAD_EXTENSION_MASK                0xfde0
#define PLOAD_EXTENSION                     0x2000

/* PVALID */
#define PVALID_VAL_PSEUDO_MODE              0x0800
#define PVALID_An_PSEUDO_MODE               0x0c00
#define PVALID_AREG_MASK                    0x0007

/* PFLUSH */
#define PFLUSH030_EXTENSION_MASK            0xe300
#define PFLUSH851_EXTENSION_MASK            0xe200
#define PFLUSH_EXTENSION                    0x2000
#define PFLUSHR_EXTENSION                   0xa000

#define PFLUSH_MODE_ALL                     0x0400
#define PFLUSH_MODE_FC_ONLY                 0x1000
#define PFLUSH_MODE_FC_SHARE                0x1400
#define PFLUSH_MODE_FC_EA                   0x1800
#define PFLUSH_MODE_FC_EA_SHARE             0x1c00

#define PFLUSH_MASK030_MASK                 0x00e0
#define PFLUSH_MASK851_MASK                 0x01e0
#define PFLUSH_EXPECTED_FOR_MODE_ALL        0x0000

#define PFLUSH040_OPMODE_MASK               0x0018
#define PFLUSH040_OPMODE_PAGE_NOT_GLOBAL    0x0000
#define PFLUSH040_OPMODE_PAGE               0x0008
#define PFLUSH040_OPMODE_ALL_NOT_GLOBAL     0x0010
#define PFLUSH040_OPMODE_ALL                0x0018

/* PMOVE */
#define PMOVE030_TT_EXTENSION_MASK          0xe0ff
#define PMOVE030_TT_EXTENSION               0x0000

#define PMOVE030_format1_EXTENSION_MASK     0xe0ff
#define PMOVE030_format1_EXTENSION          0x4000
#define PMOVE030_format2_EXTENSION_MASK     0xfdff
#define PMOVE030_format2_EXTENSION          0x6000

#define PMOVE851_format1_EXTENSION_MASK     0xe1ff
#define PMOVE851_format1_EXTENSION          0x4000
#define PMOVE851_format2_EXTENSION_MASK     0xe1e3
#define PMOVE851_format2_EXTENSION          0x6000

#define PMOVE851_PREG_NUM_MASK              0x001c

/* PBcc & PDBcc */
#define PBcc_SIZE_BIT                       0x0040

/* PTEST */
#define PTEST_EXTENSION_MASK                0xe000
#define PTEST_EXTENSION                     0x8000
#define PTEST_LEVEL_MASK                    0x1c00
#define PTEST_A_BIT_MASK                    0x0100
#define PTEST_REG_MASK                      0x00e0

#define PTEST040_RW_BIT_MASK                0x0020

/* PTRAPcc */
#define PTRAPcc_OPMODE_MASK                 0x0007
#define PTRAPcc_OPMODE_WORD                 0x0002
#define PTRAPcc_OPMODE_LONG                 0x0003
#define PTRAPcc_OPMODE_NONE                 0x0004

/* Cache register in CINV and CPUSH
 * note: Cache scope "All" is missing because it is handled directly by instruction's array declaration. */
#define CACHE_REGISTER                      0x00c0
#define CACHE_SCOPE_MASK                    0x0018
#define CACHE_SCOPE_LINE                    0x0008
#define CACHE_SCOPE_PAGE                    0x0010

/* Field R/W in PLPA instruction */
#define PLPA_RW_BIT                         0x0040

/* MOVE16 */
#define MOVE16_EXTENSION                    0x8000

/* LPSTOP */
#define LPSTOP_EXTENSION                    0x01c0

/* FPU stuff */
/*
 **********************
   FABS
      seaow   |       |copID|     | mod | reg |      extras  | |R| |src  |dest |opmode       |
              |1 1 1 1|0 0 1|0 0 0|x x x|x x x|              |0|x|0|x x x|x x x|x x x x x x x|
 **********************
   Fxxx
      seaow   |       |copID|                 |      extras  |                               |
              |1 1 1 1|0 0 1|? ? ? ? ? ? ? ? ?|              |? ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?|
*/

/* To make 0x4e75 more readable */
#define RTS_CODE                            0x4e75

/* To make 0x4afc more readable */
#define ILLEGAL_CODE                        0x4afc


#define STDNAMELENGTH    256
#define ERRMSG_SIZE      200

typedef struct x_adr
{
   const char name[12];
   unsigned long adr;
   uint32_t system;  /* 0 means valid for all systems */
} x_adr_t;

typedef struct JMPTab_s
{
   int size;
   uint32_t start, end, base;
} JMPTab_t;

typedef struct OpCode_s
{
   uint8_t family;
   char opcode[8];
   uint16_t result;
   uint16_t mask;
   uint16_t sourceadr;
   uint16_t destadr;
   uint16_t flags;
   uint16_t cpuType;
} Opcode_t;

typedef struct OpCodeByNibble_s
{
   uint16_t start;
   uint16_t count;
} OpCodeByNibble_t;

typedef struct ControlRegister_s
{
   char name[6];
   uint16_t cpuflag;
} ControlRegister_t;

/* IRA's sub structures */

typedef struct Parameters_s
{
   uint32_t pFlags;
   uint32_t codeEntry;
   uint32_t textMethod;
   uint16_t cpuType;
   uint32_t prgStart;
   uint32_t prgLen;
   uint32_t prgEnd;
   uint32_t bitRange;
   uint32_t immedByte;
   uint32_t sourceType;
   uint16_t baseAbs;
   uint16_t baseReg;
   int labelStyle;
   int radix;
} Parameters_t;

typedef struct Reloc_s
{
   uint32_t relocMax;
   uint32_t *relocAdr;
   int32_t *relocOff;
   uint32_t *relocVal;
   uint32_t *relocMod;
} Reloc_t;

typedef struct Label_s
{
   uint32_t labelMax;
   uint32_t *labelAdr; /* uncorrected addresses for labels */
} Label_t;

typedef struct Symbol_s
{
   uint32_t symbolMax;
   uint32_t symbolCount;
   uint32_t *symbolValue;
   char **symbolName;
} Symbol_t;

typedef struct CodeArea_s
{
   /* Code areas detected */
   uint32_t codeAreaMax;
   uint32_t *codeArea1;
   uint32_t *codeArea2;

   /* Code areas specified in configuration file */
   uint32_t cnfCodeAreaMax;
   uint32_t *cnfCodeArea1;
   uint32_t *cnfCodeArea2;

   uint32_t codeAdrMax;
   uint32_t *codeAdr;

   uint32_t codeAreas;
   uint32_t codeAreaEnd;
   uint32_t cnfCodeAreas;
   uint32_t codeAdrs;

} CodeArea_t;

typedef struct BaseReg_s
{
   int16_t baseSection;
   int16_t baseOffset;
   uint32_t baseAddress;
} BaseReg_t;

typedef struct NoBase_s
{
   uint32_t noBaseMax;
   uint32_t *noBaseStart;
   uint32_t *noBaseEnd;

   uint32_t noBaseCount;
   uint32_t noBaseIndex;
   int32_t noBaseFlag;
} NoBase_t;

typedef struct NoPtr_s
{
   uint32_t noPtrMax;
   uint32_t *noPtrStart;
   uint32_t *noPtrEnd;

   uint32_t noPtrCount;
} NoPtr_t;

typedef struct Text_s
{
   uint32_t textMax;
   uint32_t *textStart;
   uint32_t *textEnd;

   uint32_t textCount;
   uint32_t textIndex;
} Text_t;

typedef struct Comment_s
{
   uint32_t commentAdr;
   char *commentText;
   struct Comment_s *next;
} Comment_t;

#define BANNER_TEMPLATE "; ------------------------------------------------------------------------------\n"
#define COMMENT_TEMPLATE "; %s\n"

typedef struct Equate_s
{
   uint32_t equateAdr;
   int32_t equateValue;
   int size;
   char *equateName;
   struct Equate_s *next;
} Equate_t;

typedef struct Extsym_s
{
   uint32_t extValue;
   char *extName;
   struct Extsym_s *next;
} Extsym_t;

#define EQUATE_TEMPLATE "%s\tEQU\t$%lX\n"

typedef struct JMP_s
{
   JMPTab_t *jmpTable;
   uint32_t jmpCount;
   uint32_t jmpMax;
   uint32_t jmpIndex;
} JMP_t;

typedef struct Filenames_s
{
   char *sourceName;
   char *targetName;
   char *configName;
   char *binaryName;
   char *labelName;
   char *tsName;
} Filenames_t;

typedef struct Files_s
{
   FILE *sourceFile;
   FILE *binaryFile;
   FILE *targetFile;
   FILE *labelFile;
} Files_t;

typedef struct ira_s
{
   Parameters_t params;
   Reloc_t reloc;
   Label_t label;

   /* Needed for symbol hunks and symbol from config file */
   Symbol_t symbols;

   /* Needed for finding data/code in code sections */
   CodeArea_t codeArea;

   /* needed for the -BASEREG option */
   BaseReg_t baseReg;

   /* No Base stuff */
   NoBase_t noBase;

   /* non-pointer area in binaries */
   NoPtr_t noPtr;

   /* TEXT directive */
   Text_t text;

   /* COMMENT directive */
   Comment_t *comments;
   Comment_t *lastComment;

   /* BANNER directive */
   Comment_t *banners;
   Comment_t *lastBanner;

   /* EQU directive */
   Equate_t *equates;
   Equate_t *lastEquate;

   /* EXTSYM directive */
   Extsym_t *extsyms;
   Extsym_t *lastExtsym;

   /* JMPtable */
   JMP_t jmp;

   Filenames_t filenames;
   Files_t files;

   /* OpCode management */
   OpCodeByNibble_t opCodeByNibble[16];
   int opCodeNumber;

   /* Misc values */
   uint32_t prgCount;

   /* unclassified ex-global variables */
   uint8_t symbolName[STDNAMELENGTH];
   uint16_t ea_register;
   uint16_t alt_register;
   uint16_t ext_register;
   uint16_t rotate_shift_count;
   uint16_t addressMode;
   uint16_t addressMode2;
   uint16_t extension;

   uint32_t displace;
   uint16_t seaow;
   uint16_t *buffer;
   uint16_t extra;
   int pass;
   uint16_t *DRelocBuffer;
   uint32_t *RelocBuffer;
   uint32_t RelocNumber;
   uint32_t lastHunk;
   uint32_t firstHunk;
   /*   corrected addresses for labels */
   uint32_t *LabelAdr2;
   uint32_t labcount;
   uint32_t *LabelNum;
   uint32_t *XRefList;
   uint32_t XRefCount;
   uint32_t p2labind;
   uint32_t LabX_len;
   uint32_t relocount;
   uint32_t nextreloc;
   uint16_t *hunksMemoryType;
   uint32_t *hunksMemoryAttrs;
   int32_t LabAdr;
   uint16_t LabAdrFlag;
   uint32_t labc1;
   uint32_t pc;
   uint32_t *labelbuf;
   uint32_t hunkCount;
   uint32_t modulcnt;
   uint32_t *hunksSize;
   uint32_t **hunksContent;
   uint32_t *hunksType;
   uint32_t *hunksOffs;
   uint8_t adrlen;
   char mnebuf[32];
   char dtabuf[96];
   char adrbuf[64];
} ira_t;

int AutoScan(ira_t *);
void CheckPhase(uint32_t);
int DoAdress1(ira_t *, uint16_t);
int DoAdress2(uint16_t);
void DPass0(ira_t *);
void DPass1(ira_t *);
void DPass2(ira_t *);
void DoSpecific(ira_t *, int);
void ExitPrg(const char *, ...);
void FormatError(void);
void InsertCodeAdr(ira_t *, uint32_t);
void InsertCodeArea(CodeArea_t *, uint32_t, uint32_t);
void InsertSymbol(char *, uint32_t);
int NewAdrModes2(uint16_t, uint16_t);
void Output(void);
int P1WriteReloc(ira_t *);
int P2WriteReloc(void);
void PrintAreas(CodeArea_t *);
void SectionToArea(ira_t *);
void SplitCodeAreas(ira_t *);
void SplitOutputFiles(Files_t *, Filenames_t *, uint32_t);
void WriteBaseDirective(FILE *);
void WriteBanner(uint32_t);
void WriteComment(uint32_t);
void WriteEquates(ira_t *);
void WriteExtsyms(ira_t *);
void WriteLabel1(uint32_t);
void WriteLabel2(uint32_t);
void WriteSection(ira_t *);

#endif /* IRA_H */
