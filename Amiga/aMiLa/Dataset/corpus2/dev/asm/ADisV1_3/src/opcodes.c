/*
 * Change history
 * $Log:	opcodes.c,v $
 * Revision 3.0  93/09/24  17:54:19  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.2  93/07/18  22:56:30  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.1  93/07/08  20:49:58  Martin_Apel
 * Bug fix: Enabled addressing mode 0 for mmu30 instruction
 * 
 * Revision 2.0  93/07/01  11:54:33  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.13  93/07/01  11:43:07  Martin_Apel
 * Bug fix: TST.x Ax for 68020 enabled (Error in 68020 manual)
 * 
 * Revision 1.12  93/06/19  12:11:54  Martin_Apel
 * Major mod.: Added full 68030/040 support
 * 
 * Revision 1.11  93/06/16  20:29:10  Martin_Apel
 * Minor mod.: Removed #ifdef FPU_VERSION and #ifdef MACHINE68020
 * Minor mod.: Added variables for 68030 / 040 support
 * 
 * Revision 1.10  93/06/03  20:29:25  Martin_Apel
 * 
 * 
 */

#include <exec/types.h>
#include <stdio.h>
#include "defs.h"

static char rcsid [] = "$Id: opcodes.c,v 3.0 93/09/24 17:54:19 Martin_Apel Exp $";

struct opcode_entry opcode_table [] =
{

{ ori_b    , "ORI.B"   , ACC_BYTE, 0xfd, 0x03, 1024 }, /* 0000 0000 00 */
{ immediate, "ORI.W"   , ACC_WORD, 0xfd, 0x03, 1024 }, /* 0000 0000 01 */
{ immediate, "ORI.L"   , ACC_LONG, 0xfd, 0x03, 1026 }, /* 0000 0000 10 */
{ chkcmp2  , "C  2.B"  , ACC_BYTE, 0xe4, 0x0f, 1026 }, /* 0000 0000 11 */
{ bit_reg  , "BTST"    ,        0, 0xfd, 0x1f, 1037 }, /* 0000 0001 00 */
{ bit_reg  , "BCHG"    ,        0, 0xfd, 0x03, 1037 }, /* 0000 0001 01 */
{ bit_reg  , "BCLR"    ,        0, 0xfd, 0x03, 1037 }, /* 0000 0001 10 */
{ bit_reg  , "BSET"    ,        0, 0xfd, 0x03, 1037 }, /* 0000 0001 11 */
{ immediate, "ANDI.B"  , ACC_BYTE, 0xfd, 0x03, 1024 }, /* 0000 0010 00 */
{ immediate, "ANDI.W"  , ACC_WORD, 0xfd, 0x03, 1024 }, /* 0000 0010 01 */
{ immediate, "ANDI.L"  , ACC_LONG, 0xfd, 0x03, 1026 }, /* 0000 0010 10 */
{ chkcmp2  , "C  2.W"  , ACC_WORD, 0xe4, 0x0f, 1026 }, /* 0000 0010 11 */
{ bit_reg  , "BTST"    ,        1, 0xfd, 0x1f, 1037 }, /* 0000 0011 00 */
{ bit_reg  , "BCHG"    ,        1, 0xfd, 0x03, 1037 }, /* 0000 0011 01 */
{ bit_reg  , "BCLR"    ,        1, 0xfd, 0x03, 1037 }, /* 0000 0011 10 */
{ bit_reg  , "BSET"    ,        1, 0xfd, 0x03, 1037 }, /* 0000 0011 11 */
{ immediate, "SUBI.B"  , ACC_BYTE, 0xfd, 0x03, 1026 }, /* 0000 0100 00 */
{ immediate, "SUBI.W"  , ACC_WORD, 0xfd, 0x03, 1026 }, /* 0000 0100 01 */
{ immediate, "SUBI.L"  , ACC_LONG, 0xfd, 0x03, 1026 }, /* 0000 0100 10 */
{ chkcmp2  , "C  2.L"  , ACC_LONG, 0xe4, 0x0f, 1026 }, /* 0000 0100 11 */
{ bit_reg  , "BTST"    ,        2, 0xfd, 0x1f, 1037 }, /* 0000 0101 00 */
{ bit_reg  , "BCHG"    ,        2, 0xfd, 0x03, 1037 }, /* 0000 0101 01 */
{ bit_reg  , "BCLR"    ,        2, 0xfd, 0x03, 1037 }, /* 0000 0101 10 */
{ bit_reg  , "BSET"    ,        2, 0xfd, 0x03, 1037 }, /* 0000 0101 11 */
{ immediate, "ADDI.B"  , ACC_BYTE, 0xfd, 0x03, 1026 }, /* 0000 0110 00 */
{ immediate, "ADDI.W"  , ACC_WORD, 0xfd, 0x03, 1026 }, /* 0000 0110 01 */
{ immediate, "ADDI.L"  , ACC_LONG, 0xfd, 0x03, 1026 }, /* 0000 0110 10 */
{ immediate, "CALLM"   ,        0, 0xe4, 0x0f, 1027 }, /* 0000 0110 11 */
{ bit_reg  , "BTST"    ,        3, 0xfd, 0x1f, 1037 }, /* 0000 0111 00 */
{ bit_reg  , "BCHG"    ,        3, 0xfd, 0x03, 1037 }, /* 0000 0111 01 */
{ bit_reg  , "BCLR"    ,        3, 0xfd, 0x03, 1037 }, /* 0000 0111 10 */
{ bit_reg  , "BSET"    ,        3, 0xfd, 0x03, 1037 }, /* 0000 0111 11 */
{ bit_mem  , "BTST"    ,        0, 0xfd, 0x0f, 1026 }, /* 0000 1000 00 */
{ bit_mem  , "BCHG"    ,        0, 0xfd, 0x03, 1026 }, /* 0000 1000 01 */
{ bit_mem  , "BCLR"    ,        0, 0xfd, 0x03, 1026 }, /* 0000 1000 10 */
{ bit_mem  , "BSET"    ,        0, 0xfd, 0x03, 1026 }, /* 0000 1000 11 */
{ bit_reg  , "BTST"    ,        4, 0xfd, 0x1f, 1037 }, /* 0000 1001 00 */
{ bit_reg  , "BCHG"    ,        4, 0xfd, 0x03, 1037 }, /* 0000 1001 01 */
{ bit_reg  , "BCLR"    ,        4, 0xfd, 0x03, 1037 }, /* 0000 1001 10 */
{ bit_reg  , "BSET"    ,        4, 0xfd, 0x03, 1037 }, /* 0000 1001 11 */
{ immediate, "EORI.B"  , ACC_BYTE, 0xfd, 0x03, 1024 }, /* 0000 1010 00 */
{ immediate, "EORI.W"  , ACC_WORD, 0xfd, 0x03, 1024 }, /* 0000 1010 01 */
{ immediate, "EORI.L"  , ACC_LONG, 0xfd, 0x03, 1026 }, /* 0000 1010 10 */
{ cas      , "CAS.B"   , ACC_BYTE, 0xfc, 0x03, 1040 }, /* 0000 1010 11 */
{ bit_reg  , "BTST"    ,        5, 0xfd, 0x1f, 1037 }, /* 0000 1011 00 */
{ bit_reg  , "BCHG"    ,        5, 0xfd, 0x03, 1037 }, /* 0000 1011 01 */
{ bit_reg  , "BCLR"    ,        5, 0xfd, 0x03, 1037 }, /* 0000 1011 10 */
{ bit_reg  , "BSET"    ,        5, 0xfd, 0x03, 1037 }, /* 0000 1011 11 */
{ immediate, "CMPI.B"  , ACC_BYTE, 0xfd, 0x0f, 1026 }, /* 0000 1100 00 */
{ immediate, "CMPI.W"  , ACC_WORD, 0xfd, 0x0f, 1026 }, /* 0000 1100 01 */
{ immediate, "CMPI.L"  , ACC_LONG, 0xfd, 0x0f, 1026 }, /* 0000 1100 10 */
{ cas      , "CAS.W"   , ACC_WORD, 0xfc, 0x03, 1041 }, /* 0000 1100 11 */
{ bit_reg  , "BTST"    ,        6, 0xfd, 0x1f, 1037 }, /* 0000 1101 00 */
{ bit_reg  , "BCHG"    ,        6, 0xfd, 0x03, 1037 }, /* 0000 1101 01 */
{ bit_reg  , "BCLR"    ,        6, 0xfd, 0x03, 1037 }, /* 0000 1101 10 */
{ bit_reg  , "BSET"    ,        6, 0xfd, 0x03, 1037 }, /* 0000 1101 11 */
{ moves    , "MOVES.B" , ACC_BYTE, 0xfc, 0x03, 1026 }, /* 0000 1110 00 */
{ moves    , "MOVES.W" , ACC_WORD, 0xfc, 0x03, 1026 }, /* 0000 1110 01 */
{ moves    , "MOVES.L" , ACC_LONG, 0xfc, 0x03, 1026 }, /* 0000 1110 10 */
{ cas      , "CAS.L"   , ACC_LONG, 0xfc, 0x03, 1042 }, /* 0000 1110 11 */
{ bit_reg  , "BTST"    ,        7, 0xfd, 0x1f, 1037 }, /* 0000 1111 00 */
{ bit_reg  , "BCHG"    ,        7, 0xfd, 0x03, 1037 }, /* 0000 1111 01 */
{ bit_reg  , "BCLR"    ,        7, 0xfd, 0x03, 1037 }, /* 0000 1111 10 */
{ bit_reg  , "BSET"    ,        7, 0xfd, 0x03, 1037 }, /* 0000 1111 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0000 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0001 0000 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0000 10 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0000 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0001 00 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0001 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0001 10 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0001 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0010 00 */
{ illegal  , 0         ,        1, 0xff, 0xff, 1026 }, /* 0001 0010 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0010 10 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0010 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0011 00 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0011 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0011 10 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0011 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0100 00 */
{ illegal  , 0         ,        2, 0xff, 0xff, 1026 }, /* 0001 0100 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0100 10 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0100 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0101 00 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0101 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0101 10 */
{ illegal  , 0         ,        2, 0xff, 0xff, 1026 }, /* 0001 0101 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0110 00 */
{ illegal  , 0         ,        3, 0xff, 0xff, 1026 }, /* 0001 0110 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0110 10 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0110 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0111 00 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0111 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 0111 10 */
{ illegal  , 0         ,        3, 0xff, 0xff, 1026 }, /* 0001 0111 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1000 00 */
{ illegal  , 0         ,        4, 0xff, 0xff, 1026 }, /* 0001 1000 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1000 10 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1000 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1001 00 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1001 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1001 10 */
{ illegal  , 0         ,        4, 0xff, 0xff, 1026 }, /* 0001 1001 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1010 00 */
{ illegal  , 0         ,        5, 0xff, 0xff, 1026 }, /* 0001 1010 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1010 10 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1010 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1011 00 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1011 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1011 10 */
{ illegal  , 0         ,        5, 0xff, 0xff, 1026 }, /* 0001 1011 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1100 00 */
{ illegal  , 0         ,        6, 0xff, 0xff, 1026 }, /* 0001 1100 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1100 10 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1100 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1101 00 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1101 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1101 10 */
{ illegal  , 0         ,        6, 0xff, 0xff, 1026 }, /* 0001 1101 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1110 00 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 0001 1110 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1110 10 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1110 11 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1111 00 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1111 01 */
{ move     , "MOVE.B"  , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0001 1111 10 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 0001 1111 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0000 00 */
{ op_l     , "MOVEA.L" ,        8, 0xff, 0x1f, 1026 }, /* 0010 0000 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0000 10 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0000 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0001 00 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0001 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0001 10 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0001 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0010 00 */
{ op_l     , "MOVEA.L" ,        9, 0xff, 0x1f, 1026 }, /* 0010 0010 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0010 10 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0010 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0011 00 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0011 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0011 10 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0011 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0100 00 */
{ op_l     , "MOVEA.L" ,       10, 0xff, 0x1f, 1026 }, /* 0010 0100 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0100 10 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0100 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0101 00 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0101 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0101 10 */
{ illegal  , 0         ,        2, 0xff, 0xff, 1026 }, /* 0010 0101 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0110 00 */
{ op_l     , "MOVEA.L" ,       11, 0xff, 0x1f, 1026 }, /* 0010 0110 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0110 10 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0110 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0111 00 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0111 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 0111 10 */
{ illegal  , 0         ,        3, 0xff, 0xff, 1026 }, /* 0010 0111 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1000 00 */
{ op_l     , "MOVEA.L" ,       12, 0xff, 0x1f, 1026 }, /* 0010 1000 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1000 10 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1000 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1001 00 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1001 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1001 10 */
{ illegal  , 0         ,        4, 0xff, 0xff, 1026 }, /* 0010 1001 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1010 00 */
{ op_l     , "MOVEA.L" ,       13, 0xff, 0x1f, 1026 }, /* 0010 1010 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1010 10 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1010 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1011 00 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1011 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1011 10 */
{ illegal  , 0         ,        5, 0xff, 0xff, 1026 }, /* 0010 1011 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1100 00 */
{ op_l     , "MOVEA.L" ,       14, 0xff, 0x1f, 1026 }, /* 0010 1100 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1100 10 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1100 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1101 00 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1101 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1101 10 */
{ illegal  , 0         ,        6, 0xff, 0xff, 1026 }, /* 0010 1101 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1110 00 */
{ op_l     , "MOVEA.L" ,       15, 0xff, 0x1f, 1026 }, /* 0010 1110 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1110 10 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1110 11 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1111 00 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1111 01 */
{ move     , "MOVE.L"  , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0010 1111 10 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 0010 1111 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0000 00 */
{ op_w     , "MOVEA.W" ,        8, 0xff, 0x1f, 1026 }, /* 0011 0000 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0000 10 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0000 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0001 00 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0001 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0001 10 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0001 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0010 00 */
{ op_w     , "MOVEA.W" ,        9, 0xff, 0x1f, 1026 }, /* 0011 0010 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0010 10 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0010 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0011 00 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0011 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0011 10 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0011 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0100 00 */
{ op_w     , "MOVEA.W" ,       10, 0xff, 0x1f, 1026 }, /* 0011 0100 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0100 10 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0100 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0101 00 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0101 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0101 10 */
{ illegal  , 0         ,        2, 0xff, 0xff, 1026 }, /* 0011 0101 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0110 00 */
{ op_w     , "MOVEA.W" ,       11, 0xff, 0x1f, 1026 }, /* 0011 0110 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0110 10 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0110 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0111 00 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0111 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 0111 10 */
{ illegal  , 0         ,        3, 0xff, 0xff, 1026 }, /* 0011 0111 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1000 00 */
{ op_w     , "MOVEA.W" ,       12, 0xff, 0x1f, 1026 }, /* 0011 1000 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1000 10 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1000 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1001 00 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1001 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1001 10 */
{ illegal  , 0         ,        4, 0xff, 0xff, 1026 }, /* 0011 1001 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1010 00 */
{ op_w     , "MOVEA.W" ,       13, 0xff, 0x1f, 1026 }, /* 0011 1010 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1010 10 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1010 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1011 00 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1011 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1011 10 */
{ illegal  , 0         ,        5, 0xff, 0xff, 1026 }, /* 0011 1011 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1100 00 */
{ op_w     , "MOVEA.W" ,       14, 0xff, 0x1f, 1026 }, /* 0011 1100 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1100 10 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1100 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1101 00 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1101 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1101 10 */
{ illegal  , 0         ,        6, 0xff, 0xff, 1026 }, /* 0011 1101 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1110 00 */
{ op_w     , "MOVEA.W" ,       15, 0xff, 0x1f, 1026 }, /* 0011 1110 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1110 10 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1110 11 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1111 00 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1111 01 */
{ move     , "MOVE.W"  , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0011 1111 10 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 0011 1111 11 */
{ single_op, "NEGX.B"  , ACC_BYTE, 0xfd, 0x03, 1026 }, /* 0100 0000 00 */
{ single_op, "NEGX.W"  , ACC_WORD, 0xfd, 0x03, 1026 }, /* 0100 0000 01 */
{ single_op, "NEGX.L"  , ACC_LONG, 0xfd, 0x03, 1026 }, /* 0100 0000 10 */
{ movesrccr, "MOVE.W"  ,  FROM_SR, 0xfd, 0x03, 1026 }, /* 0100 0000 11 */
{ op_l     , "CHK.L"   ,        0, 0xfd, 0x1f, 1026 }, /* 0100 0001 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0100 0001 01 */
{ op_w     , "CHK.W"   ,        0, 0xfd, 0x1f, 1026 }, /* 0100 0001 10 */
{ op_l     , "LEA"     ,        8, 0xe4, 0x0f, 1026 }, /* 0100 0001 11 */
{ single_op, "CLR.B"   , ACC_BYTE, 0xfd, 0x03, 1026 }, /* 0100 0010 00 */
{ single_op, "CLR.W"   , ACC_WORD, 0xfd, 0x03, 1026 }, /* 0100 0010 01 */
{ single_op, "CLR.L"   , ACC_LONG, 0xfd, 0x03, 1026 }, /* 0100 0010 10 */
{ movesrccr, "MOVE.W"  , FROM_CCR, 0xfd, 0x03, 1026 }, /* 0100 0010 11 */
{ op_l     , "CHK.L"   ,        1, 0xfd, 0x1f, 1026 }, /* 0100 0011 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0100 0011 01 */
{ op_w     , "CHK.W"   ,        1, 0xfd, 0x1f, 1026 }, /* 0100 0011 10 */
{ op_l     , "LEA"     ,        9, 0xe4, 0x0f, 1026 }, /* 0100 0011 11 */
{ single_op, "NEG.B"   , ACC_BYTE, 0xfd, 0x03, 1026 }, /* 0100 0100 00 */
{ single_op, "NEG.W"   , ACC_WORD, 0xfd, 0x03, 1026 }, /* 0100 0100 01 */
{ single_op, "NEG.L"   , ACC_LONG, 0xfd, 0x03, 1026 }, /* 0100 0100 10 */
{ movesrccr, "MOVE.W"  ,   TO_CCR, 0xfd, 0x1f, 1026 }, /* 0100 0100 11 */
{ op_l     , "CHK.L"   ,        2, 0xfd, 0x1f, 1026 }, /* 0100 0101 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0100 0101 01 */
{ op_w     , "CHK.W"   ,        2, 0xfd, 0x1f, 1026 }, /* 0100 0101 10 */
{ op_l     , "LEA"     ,       10, 0xe4, 0x0f, 1026 }, /* 0100 0101 11 */
{ single_op, "NOT.B"   , ACC_BYTE, 0xfd, 0x03, 1026 }, /* 0100 0110 00 */
{ single_op, "NOT.W"   , ACC_WORD, 0xfd, 0x03, 1026 }, /* 0100 0110 01 */
{ single_op, "NOT.L"   , ACC_LONG, 0xfd, 0x03, 1026 }, /* 0100 0110 10 */
{ movesrccr, "MOVE.W"  ,    TO_SR, 0xfd, 0x1f, 1026 }, /* 0100 0110 11 */
{ op_l     , "CHK.L"   ,        3, 0xfd, 0x1f, 1026 }, /* 0100 0111 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0100 0111 01 */
{ op_w     , "CHK.W"   ,        3, 0xfd, 0x1f, 1026 }, /* 0100 0111 10 */
{ op_l     , "LEA"     ,       11, 0xe4, 0x0f, 1026 }, /* 0100 0111 11 */
{ single_op, "NBCD.B"  , ACC_BYTE, 0xfd, 0x03, 1055 }, /* 0100 1000 00 */
{ single_op, "PEA"     , ACC_LONG, 0xe4, 0x0f, 1029 }, /* 0100 1000 01 */
{ movem    , "MOVEM.W" ,      MEM, 0xf4, 0x03, 1030 }, /* 0100 1000 10 */
{ movem    , "MOVEM.L" ,      MEM, 0xf4, 0x03, 1050 }, /* 0100 1000 11 */
{ op_l     , "CHK.L"   ,        4, 0xfd, 0x1f, 1026 }, /* 0100 1001 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0100 1001 01 */
{ op_w     , "CHK.W"   ,        4, 0xfd, 0x1f, 1026 }, /* 0100 1001 10 */
{ op_l     , "LEA"     ,       12, 0xe4, 0x0f, 1051 }, /* 0100 1001 11 */
{ single_op, "TST.B"   , ACC_BYTE, 0xff, 0x1f, 1026 }, /* 0100 1010 00 */
{ single_op, "TST.W"   , ACC_WORD, 0xff, 0x1f, 1026 }, /* 0100 1010 01 */
{ single_op, "TST.L"   , ACC_LONG, 0xff, 0x1f, 1026 }, /* 0100 1010 10 */
{ single_op, "TAS"     , ACC_BYTE, 0xfd, 0x03, 1025 }, /* 0100 1010 11 */
{ op_l     , "CHK.L"   ,        5, 0xfd, 0x1f, 1026 }, /* 0100 1011 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0100 1011 01 */
{ op_w     , "CHK.W"   ,        5, 0xfd, 0x1f, 1026 }, /* 0100 1011 10 */
{ op_l     , "LEA"     ,       13, 0xe4, 0x0f, 1026 }, /* 0100 1011 11 */
{ muldivl  , "MUL "    ,        0, 0xfd, 0x1f, 1026 }, /* 0100 1100 00 */
{ muldivl  , "DIV "    ,        0, 0xfd, 0x1f, 1026 }, /* 0100 1100 01 */
{ movem    , "MOVEM.W" ,      REG, 0xec, 0x0f, 1026 }, /* 0100 1100 10 */
{ movem    , "MOVEM.L" ,      REG, 0xec, 0x0f, 1026 }, /* 0100 1100 11 */
{ op_l     , "CHK.L"   ,        6, 0xfd, 0x1f, 1026 }, /* 0100 1101 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0100 1101 01 */
{ op_w     , "CHK.W"   ,        6, 0xfd, 0x1f, 1026 }, /* 0100 1101 10 */
{ op_l     , "LEA"     ,       14, 0xe4, 0x0f, 1026 }, /* 0100 1101 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0100 1110 00 */
{ special  , 0         ,        0, 0xff, 0x0c, 1026 }, /* 0100 1110 01 */ 
{ single_op, "JSR",      ACC_CODE, 0xe4, 0x0f, 1026 }, /* 0100 1110 10 */
{ end_single_op, "JMP" , ACC_CODE, 0xe4, 0x0f, 1026 }, /* 0100 1110 11 */
{ op_l     , "CHK.L"   ,        7, 0xfd, 0x1f, 1026 }, /* 0100 1111 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0100 1111 01 */
{ op_w     , "CHK.W"   ,        7, 0xfd, 0x1f, 1026 }, /* 0100 1111 10 */
{ op_l     , "LEA"     ,       15, 0xe4, 0x0f, 1026 }, /* 0100 1111 11 */
{ quick    , "ADDQ.B"  ,        8, 0xff, 0x03, 1026 }, /* 0101 0000 00 */
{ quick    , "ADDQ.W"  ,        8, 0xff, 0x03, 1026 }, /* 0101 0000 01 */
{ quick    , "ADDQ.L"  ,        8, 0xff, 0x03, 1026 }, /* 0101 0000 10 */
{ dbranch  , "DBT"     ,        0, 0x02, 0xff, 1046 }, /* 0101 0000 11 */
{ quick    , "SUBQ.B"  ,        8, 0xff, 0x03, 1026 }, /* 0101 0001 00 */
{ quick    , "SUBQ.W"  ,        8, 0xff, 0x03, 1026 }, /* 0101 0001 01 */
{ quick    , "SUBQ.L"  ,        8, 0xff, 0x03, 1026 }, /* 0101 0001 10 */
{ dbranch  , "DBRA"    ,        0, 0x02, 0xff, 1046 }, /* 0101 0001 11 */
{ quick    , "ADDQ.B"  ,        1, 0xff, 0x03, 1026 }, /* 0101 0010 00 */
{ quick    , "ADDQ.W"  ,        1, 0xff, 0x03, 1026 }, /* 0101 0010 01 */
{ quick    , "ADDQ.L"  ,        1, 0xff, 0x03, 1026 }, /* 0101 0010 10 */
{ dbranch  , "DBHI"    ,        1, 0x02, 0xff, 1046 }, /* 0101 0010 11 */
{ quick    , "SUBQ.B"  ,        1, 0xff, 0x03, 1026 }, /* 0101 0011 00 */
{ quick    , "SUBQ.W"  ,        1, 0xff, 0x03, 1026 }, /* 0101 0011 01 */
{ quick    , "SUBQ.L"  ,        1, 0xff, 0x03, 1026 }, /* 0101 0011 10 */
{ dbranch  , "DBLS"    ,        1, 0x02, 0xff, 1046 }, /* 0101 0011 11 */
{ quick    , "ADDQ.B"  ,        2, 0xff, 0x03, 1026 }, /* 0101 0100 00 */
{ quick    , "ADDQ.W"  ,        2, 0xff, 0x03, 1026 }, /* 0101 0100 01 */
{ quick    , "ADDQ.L"  ,        2, 0xff, 0x03, 1026 }, /* 0101 0100 10 */
{ dbranch  , "DBCC"    ,        2, 0x02, 0xff, 1046 }, /* 0101 0100 11 */
{ quick    , "SUBQ.B"  ,        2, 0xff, 0x03, 1026 }, /* 0101 0101 00 */
{ quick    , "SUBQ.W"  ,        2, 0xff, 0x03, 1026 }, /* 0101 0101 01 */
{ quick    , "SUBQ.L"  ,        2, 0xff, 0x03, 1026 }, /* 0101 0101 10 */
{ dbranch  , "DBCS"    ,        2, 0x02, 0xff, 1046 }, /* 0101 0101 11 */
{ quick    , "ADDQ.B"  ,        3, 0xff, 0x03, 1026 }, /* 0101 0110 00 */
{ quick    , "ADDQ.W"  ,        3, 0xff, 0x03, 1026 }, /* 0101 0110 01 */
{ quick    , "ADDQ.L"  ,        3, 0xff, 0x03, 1026 }, /* 0101 0110 10 */
{ dbranch  , "DBNE"    ,        3, 0x02, 0xff, 1046 }, /* 0101 0110 11 */
{ quick    , "SUBQ.B"  ,        3, 0xff, 0x03, 1026 }, /* 0101 0111 00 */
{ quick    , "SUBQ.W"  ,        3, 0xff, 0x03, 1026 }, /* 0101 0111 01 */
{ quick    , "SUBQ.L"  ,        3, 0xff, 0x03, 1026 }, /* 0101 0111 10 */
{ dbranch  , "DBEQ"    ,        3, 0x02, 0xff, 1046 }, /* 0101 0111 11 */
{ quick    , "ADDQ.B"  ,        4, 0xff, 0x03, 1026 }, /* 0101 1000 00 */
{ quick    , "ADDQ.W"  ,        4, 0xff, 0x03, 1026 }, /* 0101 1000 01 */
{ quick    , "ADDQ.L"  ,        4, 0xff, 0x03, 1026 }, /* 0101 1000 10 */
{ dbranch  , "DBVC"    ,        4, 0x02, 0xff, 1046 }, /* 0101 1000 11 */
{ quick    , "SUBQ.B"  ,        4, 0xff, 0x03, 1026 }, /* 0101 1001 00 */
{ quick    , "SUBQ.W"  ,        4, 0xff, 0x03, 1026 }, /* 0101 1001 01 */
{ quick    , "SUBQ.L"  ,        4, 0xff, 0x03, 1026 }, /* 0101 1001 10 */
{ dbranch  , "DBVS"    ,        4, 0x02, 0xff, 1046 }, /* 0101 1001 11 */
{ quick    , "ADDQ.B"  ,        5, 0xff, 0x03, 1026 }, /* 0101 1010 00 */
{ quick    , "ADDQ.W"  ,        5, 0xff, 0x03, 1026 }, /* 0101 1010 01 */
{ quick    , "ADDQ.L"  ,        5, 0xff, 0x03, 1026 }, /* 0101 1010 10 */
{ dbranch  , "DBPL"    ,        5, 0x02, 0xff, 1046 }, /* 0101 1010 11 */
{ quick    , "SUBQ.B"  ,        5, 0xff, 0x03, 1026 }, /* 0101 1011 00 */
{ quick    , "SUBQ.W"  ,        5, 0xff, 0x03, 1026 }, /* 0101 1011 01 */
{ quick    , "SUBQ.L"  ,        5, 0xff, 0x03, 1026 }, /* 0101 1011 10 */
{ dbranch  , "DBMI"    ,        5, 0x02, 0xff, 1046 }, /* 0101 1011 11 */
{ quick    , "ADDQ.B"  ,        6, 0xff, 0x03, 1026 }, /* 0101 1100 00 */
{ quick    , "ADDQ.W"  ,        6, 0xff, 0x03, 1026 }, /* 0101 1100 01 */
{ quick    , "ADDQ.L"  ,        6, 0xff, 0x03, 1026 }, /* 0101 1100 10 */
{ dbranch  , "DBGE"    ,        6, 0x02, 0xff, 1046 }, /* 0101 1100 11 */
{ quick    , "SUBQ.B"  ,        6, 0xff, 0x03, 1026 }, /* 0101 1101 00 */
{ quick    , "SUBQ.W"  ,        6, 0xff, 0x03, 1026 }, /* 0101 1101 01 */
{ quick    , "SUBQ.L"  ,        6, 0xff, 0x03, 1026 }, /* 0101 1101 10 */
{ dbranch  , "DBLE"    ,        6, 0x02, 0xff, 1046 }, /* 0101 1101 11 */
{ quick    , "ADDQ.B"  ,        7, 0xff, 0x03, 1026 }, /* 0101 1110 00 */
{ quick    , "ADDQ.W"  ,        7, 0xff, 0x03, 1026 }, /* 0101 1110 01 */
{ quick    , "ADDQ.L"  ,        7, 0xff, 0x03, 1026 }, /* 0101 1110 10 */
{ dbranch  , "DBGT"    ,        7, 0x02, 0xff, 1046 }, /* 0101 1110 11 */
{ quick    , "SUBQ.B"  ,        7, 0xff, 0x03, 1026 }, /* 0101 1111 00 */
{ quick    , "SUBQ.W"  ,        7, 0xff, 0x03, 1026 }, /* 0101 1111 01 */
{ quick    , "SUBQ.L"  ,        7, 0xff, 0x03, 1026 }, /* 0101 1111 10 */
{ dbranch  , "DBLE"    ,        7, 0x02, 0xff, 1046 }, /* 0101 1111 11 */
{ branch   , "BRA"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0000 00 */
{ branch   , "BRA"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0000 01 */
{ branch   , "BRA"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0000 10 */
{ branch   , "BRA"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0000 11 */
{ branch   , "BSR"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0001 00 */
{ branch   , "BSR"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0001 01 */
{ branch   , "BSR"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0001 10 */
{ branch   , "BSR"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0001 11 */
{ branch   , "BHI"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0010 00 */
{ branch   , "BHI"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0010 01 */
{ branch   , "BHI"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0010 10 */
{ branch   , "BHI"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0010 11 */
{ branch   , "BLS"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0011 00 */
{ branch   , "BLS"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0011 01 */
{ branch   , "BLS"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0011 10 */
{ branch   , "BLS"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0011 11 */
{ branch   , "BCC"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0100 00 */
{ branch   , "BCC"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0100 01 */
{ branch   , "BCC"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0100 10 */
{ branch   , "BCC"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0100 11 */
{ branch   , "BCS"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0101 00 */
{ branch   , "BCS"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0101 01 */
{ branch   , "BCS"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0101 10 */
{ branch   , "BCS"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0101 11 */
{ branch   , "BNE"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0110 00 */
{ branch   , "BNE"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0110 01 */
{ branch   , "BNE"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0110 10 */
{ branch   , "BNE"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0110 11 */
{ branch   , "BEQ"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0111 00 */
{ branch   , "BEQ"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0111 01 */
{ branch   , "BEQ"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0111 10 */
{ branch   , "BEQ"     ,        0, 0xff, 0xff, 1026 }, /* 0110 0111 11 */
{ branch   , "BVC"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1000 00 */
{ branch   , "BVC"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1000 01 */
{ branch   , "BVC"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1000 10 */
{ branch   , "BVC"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1000 11 */
{ branch   , "BVS"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1001 00 */
{ branch   , "BVS"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1001 01 */
{ branch   , "BVS"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1001 10 */
{ branch   , "BVS"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1001 11 */
{ branch   , "BPL"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1010 00 */
{ branch   , "BPL"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1010 01 */
{ branch   , "BPL"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1010 10 */
{ branch   , "BPL"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1010 11 */
{ branch   , "BMI"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1011 00 */
{ branch   , "BMI"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1011 01 */
{ branch   , "BMI"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1011 10 */
{ branch   , "BMI"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1011 11 */
{ branch   , "BGE"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1100 00 */
{ branch   , "BGE"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1100 01 */
{ branch   , "BGE"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1100 10 */
{ branch   , "BGE"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1100 11 */
{ branch   , "BLT"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1101 00 */
{ branch   , "BLT"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1101 01 */
{ branch   , "BLT"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1101 10 */
{ branch   , "BLT"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1101 11 */
{ branch   , "BGT"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1110 00 */
{ branch   , "BGT"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1110 01 */
{ branch   , "BGT"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1110 10 */
{ branch   , "BGT"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1110 11 */
{ branch   , "BLE"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1111 00 */
{ branch   , "BLE"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1111 01 */
{ branch   , "BLE"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1111 10 */
{ branch   , "BLE"     ,        0, 0xff, 0xff, 1026 }, /* 0110 1111 11 */
{ moveq    , "MOVEQ"   ,        0, 0xff, 0xff, 1026 }, /* 0111 0000 00 */
{ moveq    , "MOVEQ"   ,        0, 0xff, 0xff, 1026 }, /* 0111 0000 01 */
{ moveq    , "MOVEQ"   ,        0, 0xff, 0xff, 1026 }, /* 0111 0000 10 */
{ moveq    , "MOVEQ"   ,        0, 0xff, 0xff, 1026 }, /* 0111 0000 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0001 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0001 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0001 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0001 11 */
{ moveq    , "MOVEQ"   ,        1, 0xff, 0xff, 1026 }, /* 0111 0010 00 */
{ moveq    , "MOVEQ"   ,        1, 0xff, 0xff, 1026 }, /* 0111 0010 01 */
{ moveq    , "MOVEQ"   ,        1, 0xff, 0xff, 1026 }, /* 0111 0010 10 */
{ moveq    , "MOVEQ"   ,        1, 0xff, 0xff, 1026 }, /* 0111 0010 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0011 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0011 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0011 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0011 11 */
{ moveq    , "MOVEQ"   ,        2, 0xff, 0xff, 1026 }, /* 0111 0100 00 */
{ moveq    , "MOVEQ"   ,        2, 0xff, 0xff, 1026 }, /* 0111 0100 01 */
{ moveq    , "MOVEQ"   ,        2, 0xff, 0xff, 1026 }, /* 0111 0100 10 */
{ moveq    , "MOVEQ"   ,        2, 0xff, 0xff, 1026 }, /* 0111 0100 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0101 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0101 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0101 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0101 11 */
{ moveq    , "MOVEQ"   ,        3, 0xff, 0xff, 1026 }, /* 0111 0110 00 */
{ moveq    , "MOVEQ"   ,        3, 0xff, 0xff, 1026 }, /* 0111 0110 01 */
{ moveq    , "MOVEQ"   ,        3, 0xff, 0xff, 1026 }, /* 0111 0110 10 */
{ moveq    , "MOVEQ"   ,        3, 0xff, 0xff, 1026 }, /* 0111 0110 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0111 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0111 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0111 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 0111 11 */
{ moveq    , "MOVEQ"   ,        4, 0xff, 0xff, 1026 }, /* 0111 1000 00 */
{ moveq    , "MOVEQ"   ,        4, 0xff, 0xff, 1026 }, /* 0111 1000 01 */
{ moveq    , "MOVEQ"   ,        4, 0xff, 0xff, 1026 }, /* 0111 1000 10 */
{ moveq    , "MOVEQ"   ,        4, 0xff, 0xff, 1026 }, /* 0111 1000 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1001 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1001 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1001 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1001 11 */
{ moveq    , "MOVEQ"   ,        5, 0xff, 0xff, 1026 }, /* 0111 1010 00 */
{ moveq    , "MOVEQ"   ,        5, 0xff, 0xff, 1026 }, /* 0111 1010 01 */
{ moveq    , "MOVEQ"   ,        5, 0xff, 0xff, 1026 }, /* 0111 1010 10 */
{ moveq    , "MOVEQ"   ,        5, 0xff, 0xff, 1026 }, /* 0111 1010 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1011 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1011 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1011 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1011 11 */
{ moveq    , "MOVEQ"   ,        6, 0xff, 0xff, 1026 }, /* 0111 1100 00 */
{ moveq    , "MOVEQ"   ,        6, 0xff, 0xff, 1026 }, /* 0111 1100 01 */
{ moveq    , "MOVEQ"   ,        6, 0xff, 0xff, 1026 }, /* 0111 1100 10 */
{ moveq    , "MOVEQ"   ,        6, 0xff, 0xff, 1026 }, /* 0111 1100 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1101 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1101 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1101 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1101 11 */
{ moveq    , "MOVEQ"   ,        7, 0xff, 0xff, 1026 }, /* 0111 1110 00 */
{ moveq    , "MOVEQ"   ,        7, 0xff, 0xff, 1026 }, /* 0111 1110 01 */
{ moveq    , "MOVEQ"   ,        7, 0xff, 0xff, 1026 }, /* 0111 1110 10 */
{ moveq    , "MOVEQ"   ,        7, 0xff, 0xff, 1026 }, /* 0111 1110 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1111 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1111 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1111 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 0111 1111 11 */
{ dual_op  , "OR.B"    ,        0, 0xfd, 0x1f, 1026 }, /* 1000 0000 00 */
{ dual_op  , "OR.W"    ,        0, 0xfd, 0x1f, 1026 }, /* 1000 0000 01 */
{ dual_op  , "OR.L"    ,        0, 0xfd, 0x1f, 1026 }, /* 1000 0000 10 */
{ op_w     , "DIVU.W"  ,        0, 0xfd, 0x1f, 1026 }, /* 1000 0000 11 */
{ dual_op  , "OR.B"    ,        0, 0xfc, 0x03, 1031 }, /* 1000 0001 00 */
{ dual_op  , "OR.W"    ,        0, 0xfc, 0x03, 1032 }, /* 1000 0001 01 */
{ dual_op  , "OR.L"    ,        0, 0xfc, 0x03, 1028 }, /* 1000 0001 10 */
{ op_w     , "DIVS.W"  ,        0, 0xfd, 0x1f, 1026 }, /* 1000 0001 11 */
{ dual_op  , "OR.B"    ,        1, 0xfd, 0x1f, 1026 }, /* 1000 0010 00 */
{ dual_op  , "OR.W"    ,        1, 0xfd, 0x1f, 1026 }, /* 1000 0010 01 */
{ dual_op  , "OR.L"    ,        1, 0xfd, 0x1f, 1026 }, /* 1000 0010 10 */
{ op_w     , "DIVU.W"  ,        1, 0xfd, 0x1f, 1026 }, /* 1000 0010 11 */
{ dual_op  , "OR.B"    ,        1, 0xfc, 0x03, 1031 }, /* 1000 0011 00 */
{ dual_op  , "OR.W"    ,        1, 0xfc, 0x03, 1032 }, /* 1000 0011 01 */
{ dual_op  , "OR.L"    ,        1, 0xfc, 0x03, 1028 }, /* 1000 0011 10 */
{ op_w     , "DIVS.W"  ,        1, 0xfd, 0x1f, 1026 }, /* 1000 0011 11 */
{ dual_op  , "OR.B"    ,        2, 0xfd, 0x1f, 1026 }, /* 1000 0100 00 */
{ dual_op  , "OR.W"    ,        2, 0xfd, 0x1f, 1026 }, /* 1000 0100 01 */
{ dual_op  , "OR.L"    ,        2, 0xfd, 0x1f, 1026 }, /* 1000 0100 10 */
{ op_w     , "DIVU.W"  ,        2, 0xfd, 0x1f, 1026 }, /* 1000 0100 11 */
{ dual_op  , "OR.B"    ,        2, 0xfc, 0x03, 1031 }, /* 1000 0101 00 */
{ dual_op  , "OR.W"    ,        2, 0xfc, 0x03, 1032 }, /* 1000 0101 01 */
{ dual_op  , "OR.L"    ,        2, 0xfc, 0x03, 1028 }, /* 1000 0101 10 */
{ op_w     , "DIVS.W"  ,        2, 0xfd, 0x1f, 1026 }, /* 1000 0101 11 */
{ dual_op  , "OR.B"    ,        3, 0xfd, 0x1f, 1026 }, /* 1000 0110 00 */
{ dual_op  , "OR.W"    ,        3, 0xfd, 0x1f, 1026 }, /* 1000 0110 01 */
{ dual_op  , "OR.L"    ,        3, 0xfd, 0x1f, 1026 }, /* 1000 0110 10 */
{ op_w     , "DIVU.W"  ,        3, 0xfd, 0x1f, 1026 }, /* 1000 0110 11 */
{ dual_op  , "OR.B"    ,        3, 0xfc, 0x03, 1031 }, /* 1000 0111 00 */
{ dual_op  , "OR.W"    ,        3, 0xfc, 0x03, 1032 }, /* 1000 0111 01 */
{ dual_op  , "OR.L"    ,        3, 0xfc, 0x03, 1028 }, /* 1000 0111 10 */
{ op_w     , "DIVS.W"  ,        3, 0xfd, 0x1f, 1026 }, /* 1000 0111 11 */
{ dual_op  , "OR.B"    ,        4, 0xfd, 0x1f, 1026 }, /* 1000 1000 00 */
{ dual_op  , "OR.W"    ,        4, 0xfd, 0x1f, 1026 }, /* 1000 1000 01 */
{ dual_op  , "OR.L"    ,        4, 0xfd, 0x1f, 1026 }, /* 1000 1000 10 */
{ op_w     , "DIVU.W"  ,        4, 0xfd, 0x1f, 1026 }, /* 1000 1000 11 */
{ dual_op  , "OR.B"    ,        4, 0xfc, 0x03, 1031 }, /* 1000 1001 00 */
{ dual_op  , "OR.W"    ,        4, 0xfc, 0x03, 1032 }, /* 1000 1001 01 */
{ dual_op  , "OR.L"    ,        4, 0xfc, 0x03, 1028 }, /* 1000 1001 10 */
{ op_w     , "DIVS.W"  ,        4, 0xfd, 0x1f, 1026 }, /* 1000 1001 11 */
{ dual_op  , "OR.B"    ,        5, 0xfd, 0x1f, 1026 }, /* 1000 1010 00 */
{ dual_op  , "OR.W"    ,        5, 0xfd, 0x1f, 1026 }, /* 1000 1010 01 */
{ dual_op  , "OR.L"    ,        5, 0xfd, 0x1f, 1026 }, /* 1000 1010 10 */
{ op_w     , "DIVU.W"  ,        5, 0xfd, 0x1f, 1026 }, /* 1000 1010 11 */
{ dual_op  , "OR.B"    ,        5, 0xfc, 0x03, 1031 }, /* 1000 1011 00 */
{ dual_op  , "OR.W"    ,        5, 0xfc, 0x03, 1032 }, /* 1000 1011 01 */
{ dual_op  , "OR.L"    ,        5, 0xfc, 0x03, 1028 }, /* 1000 1011 10 */
{ op_w     , "DIVS.W"  ,        5, 0xfd, 0x1f, 1026 }, /* 1000 1011 11 */
{ dual_op  , "OR.B"    ,        6, 0xfd, 0x1f, 1026 }, /* 1000 1100 00 */
{ dual_op  , "OR.W"    ,        6, 0xfd, 0x1f, 1026 }, /* 1000 1100 01 */
{ dual_op  , "OR.L"    ,        6, 0xfd, 0x1f, 1026 }, /* 1000 1100 10 */
{ op_w     , "DIVU.W"  ,        6, 0xfd, 0x1f, 1026 }, /* 1000 1100 11 */
{ dual_op  , "OR.B"    ,        6, 0xfc, 0x03, 1031 }, /* 1000 1101 00 */
{ dual_op  , "OR.W"    ,        6, 0xfc, 0x03, 1032 }, /* 1000 1101 01 */
{ dual_op  , "OR.L"    ,        6, 0xfc, 0x03, 1028 }, /* 1000 1101 10 */
{ op_w     , "DIVS.W"  ,        6, 0xfd, 0x1f, 1026 }, /* 1000 1101 11 */
{ dual_op  , "OR.B"    ,        7, 0xfd, 0x1f, 1026 }, /* 1000 1110 00 */
{ dual_op  , "OR.W"    ,        7, 0xfd, 0x1f, 1026 }, /* 1000 1110 01 */
{ dual_op  , "OR.L"    ,        7, 0xfd, 0x1f, 1026 }, /* 1000 1110 10 */
{ op_w     , "DIVU.W"  ,        7, 0xfd, 0x1f, 1026 }, /* 1000 1110 11 */
{ dual_op  , "OR.B"    ,        7, 0xfc, 0x03, 1031 }, /* 1000 1111 00 */
{ dual_op  , "OR.W"    ,        7, 0xfc, 0x03, 1032 }, /* 1000 1111 01 */
{ dual_op  , "OR.L"    ,        7, 0xfc, 0x03, 1028 }, /* 1000 1111 10 */
{ op_w     , "DIVS.W"  ,        7, 0xfd, 0x1f, 1026 }, /* 1000 1111 11 */
{ dual_op  , "SUB.B"   ,        0, 0xff, 0x1f, 1026 }, /* 1001 0000 00 */
{ dual_op  , "SUB.W"   ,        0, 0xff, 0x1f, 1026 }, /* 1001 0000 01 */
{ dual_op  , "SUB.L"   ,        0, 0xff, 0x1f, 1026 }, /* 1001 0000 10 */
{ op_w     , "SUBA.W"  ,        8, 0xff, 0x1f, 1026 }, /* 1001 0000 11 */
{ dual_op  , "SUB.B"   ,        0, 0xfc, 0x03, 1052 }, /* 1001 0001 00 */
{ dual_op  , "SUB.W"   ,        0, 0xfc, 0x03, 1053 }, /* 1001 0001 01 */
{ dual_op  , "SUB.L"   ,        0, 0xfc, 0x03, 1054 }, /* 1001 0001 10 */
{ op_l     , "SUBA.L"  ,        8, 0xff, 0x1f, 1026 }, /* 1001 0001 11 */
{ dual_op  , "SUB.B"   ,        1, 0xff, 0x1f, 1026 }, /* 1001 0010 00 */
{ dual_op  , "SUB.W"   ,        1, 0xff, 0x1f, 1026 }, /* 1001 0010 01 */
{ dual_op  , "SUB.L"   ,        1, 0xff, 0x1f, 1026 }, /* 1001 0010 10 */
{ op_w     , "SUBA.W"  ,        9, 0xff, 0x1f, 1026 }, /* 1001 0010 11 */
{ dual_op  , "SUB.B"   ,        1, 0xfc, 0x03, 1052 }, /* 1001 0011 00 */
{ dual_op  , "SUB.W"   ,        1, 0xfc, 0x03, 1053 }, /* 1001 0011 01 */
{ dual_op  , "SUB.L"   ,        1, 0xfc, 0x03, 1054 }, /* 1001 0011 10 */
{ op_l     , "SUBA.L"  ,        9, 0xff, 0x1f, 1026 }, /* 1001 0011 11 */
{ dual_op  , "SUB.B"   ,        2, 0xff, 0x1f, 1026 }, /* 1001 0100 00 */
{ dual_op  , "SUB.W"   ,        2, 0xff, 0x1f, 1026 }, /* 1001 0100 01 */
{ dual_op  , "SUB.L"   ,        2, 0xff, 0x1f, 1026 }, /* 1001 0100 10 */
{ op_w     , "SUBA.W"  ,       10, 0xff, 0x1f, 1026 }, /* 1001 0100 11 */
{ dual_op  , "SUB.B"   ,        2, 0xfc, 0x03, 1052 }, /* 1001 0101 00 */
{ dual_op  , "SUB.W"   ,        2, 0xfc, 0x03, 1053 }, /* 1001 0101 01 */
{ dual_op  , "SUB.L"   ,        2, 0xfc, 0x03, 1054 }, /* 1001 0101 10 */
{ op_l     , "SUBA.L"  ,       10, 0xff, 0x1f, 1026 }, /* 1001 0101 11 */
{ dual_op  , "SUB.B"   ,        3, 0xff, 0x1f, 1026 }, /* 1001 0110 00 */
{ dual_op  , "SUB.W"   ,        3, 0xff, 0x1f, 1026 }, /* 1001 0110 01 */
{ dual_op  , "SUB.L"   ,        3, 0xff, 0x1f, 1026 }, /* 1001 0110 10 */
{ op_w     , "SUBA.W"  ,       11, 0xff, 0x1f, 1026 }, /* 1001 0110 11 */
{ dual_op  , "SUB.B"   ,        3, 0xfc, 0x03, 1052 }, /* 1001 0111 00 */
{ dual_op  , "SUB.W"   ,        3, 0xfc, 0x03, 1053 }, /* 1001 0111 01 */
{ dual_op  , "SUB.L"   ,        3, 0xfc, 0x03, 1054 }, /* 1001 0111 10 */
{ op_l     , "SUBA.L"  ,       11, 0xff, 0x1f, 1026 }, /* 1001 0111 11 */
{ dual_op  , "SUB.B"   ,        4, 0xff, 0x1f, 1026 }, /* 1001 1000 00 */
{ dual_op  , "SUB.W"   ,        4, 0xff, 0x1f, 1026 }, /* 1001 1000 01 */
{ dual_op  , "SUB.L"   ,        4, 0xff, 0x1f, 1026 }, /* 1001 1000 10 */
{ op_w     , "SUBA.W"  ,       12, 0xff, 0x1f, 1026 }, /* 1001 1000 11 */
{ dual_op  , "SUB.B"   ,        4, 0xfc, 0x03, 1052 }, /* 1001 1001 00 */
{ dual_op  , "SUB.W"   ,        4, 0xfc, 0x03, 1053 }, /* 1001 1001 01 */
{ dual_op  , "SUB.L"   ,        4, 0xfc, 0x03, 1054 }, /* 1001 1001 10 */
{ op_l     , "SUBA.L"  ,       12, 0xff, 0x1f, 1026 }, /* 1001 1001 11 */
{ dual_op  , "SUB.B"   ,        5, 0xff, 0x1f, 1026 }, /* 1001 1010 00 */
{ dual_op  , "SUB.W"   ,        5, 0xff, 0x1f, 1026 }, /* 1001 1010 01 */
{ dual_op  , "SUB.L"   ,        5, 0xff, 0x1f, 1026 }, /* 1001 1010 10 */
{ op_w     , "SUBA.W"  ,       13, 0xff, 0x1f, 1026 }, /* 1001 1010 11 */
{ dual_op  , "SUB.B"   ,        5, 0xfc, 0x03, 1052 }, /* 1001 1011 00 */
{ dual_op  , "SUB.W"   ,        5, 0xfc, 0x03, 1053 }, /* 1001 1011 01 */
{ dual_op  , "SUB.L"   ,        5, 0xfc, 0x03, 1054 }, /* 1001 1011 10 */
{ op_l     , "SUBA.L"  ,       13, 0xff, 0x1f, 1026 }, /* 1001 1011 11 */
{ dual_op  , "SUB.B"   ,        6, 0xff, 0x1f, 1026 }, /* 1001 1100 00 */
{ dual_op  , "SUB.W"   ,        6, 0xff, 0x1f, 1026 }, /* 1001 1100 01 */
{ dual_op  , "SUB.L"   ,        6, 0xff, 0x1f, 1026 }, /* 1001 1100 10 */
{ op_w     , "SUBA.W"  ,       14, 0xff, 0x1f, 1026 }, /* 1001 1100 11 */
{ dual_op  , "SUB.B"   ,        6, 0xfc, 0x03, 1052 }, /* 1001 1101 00 */
{ dual_op  , "SUB.W"   ,        6, 0xfc, 0x03, 1053 }, /* 1001 1101 01 */
{ dual_op  , "SUB.L"   ,        6, 0xfc, 0x03, 1054 }, /* 1001 1101 10 */
{ op_l     , "SUBA.L"  ,       14, 0xff, 0x1f, 1026 }, /* 1001 1101 11 */
{ dual_op  , "SUB.B"   ,        7, 0xff, 0x1f, 1026 }, /* 1001 1110 00 */
{ dual_op  , "SUB.W"   ,        7, 0xff, 0x1f, 1026 }, /* 1001 1110 01 */
{ dual_op  , "SUB.L"   ,        7, 0xff, 0x1f, 1026 }, /* 1001 1110 10 */
{ op_w     , "SUBA.W"  ,       15, 0xff, 0x1f, 1026 }, /* 1001 1110 11 */
{ dual_op  , "SUB.B"   ,        7, 0xfc, 0x03, 1052 }, /* 1001 1111 00 */
{ dual_op  , "SUB.W"   ,        7, 0xfc, 0x03, 1053 }, /* 1001 1111 01 */
{ dual_op  , "SUB.L"   ,        7, 0xfc, 0x03, 1054 }, /* 1001 1111 10 */
{ op_l     , "SUBA.L"  ,       15, 0xff, 0x1f, 1026 }, /* 1001 1111 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0000 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0000 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0000 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0000 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0001 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0001 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0001 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0001 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0010 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0010 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0010 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0010 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0011 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0011 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0011 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0011 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0100 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0100 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0100 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0100 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0101 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0101 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0101 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0101 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0110 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0110 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0110 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0110 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0111 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0111 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0111 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 0111 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1000 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1000 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1000 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1000 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1001 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1001 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1001 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1001 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1010 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1010 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1010 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1010 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1011 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1011 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1011 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1011 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1100 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1100 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1100 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1100 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1101 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1101 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1101 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1101 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1110 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1110 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1110 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1110 11 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1111 00 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1111 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1111 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1010 1111 11 */
{ dual_op  , "CMP.B"   ,        0, 0xff, 0x1f, 1026 }, /* 1011 0000 00 */
{ dual_op  , "CMP.W"   ,        0, 0xff, 0x1f, 1026 }, /* 1011 0000 01 */
{ dual_op  , "CMP.L"   ,        0, 0xff, 0x1f, 1026 }, /* 1011 0000 10 */
{ op_w     , "CMPA.W"  ,        8, 0xff, 0x1f, 1026 }, /* 1011 0000 11 */
{ dual_op  , "EOR.B"   ,        0, 0xfd, 0x03, 1034 }, /* 1011 0001 00 */
{ dual_op  , "EOR.W"   ,        0, 0xfd, 0x03, 1043 }, /* 1011 0001 01 */
{ dual_op  , "EOR.L"   ,        0, 0xfd, 0x03, 1044 }, /* 1011 0001 10 */
{ op_l     , "CMPA.L"  ,        8, 0xff, 0x1f, 1026 }, /* 1011 0001 11 */
{ dual_op  , "CMP.B"   ,        1, 0xff, 0x1f, 1026 }, /* 1011 0010 00 */
{ dual_op  , "CMP.W"   ,        1, 0xff, 0x1f, 1026 }, /* 1011 0010 01 */
{ dual_op  , "CMP.L"   ,        1, 0xff, 0x1f, 1026 }, /* 1011 0010 10 */
{ op_w     , "CMPA.W"  ,        9, 0xff, 0x1f, 1026 }, /* 1011 0010 11 */
{ dual_op  , "EOR.B"   ,        1, 0xfd, 0x03, 1034 }, /* 1011 0011 00 */
{ dual_op  , "EOR.W"   ,        1, 0xfd, 0x03, 1043 }, /* 1011 0011 01 */
{ dual_op  , "EOR.L"   ,        1, 0xfd, 0x03, 1044 }, /* 1011 0011 10 */
{ op_l     , "CMPA.L"  ,        9, 0xff, 0x1f, 1026 }, /* 1011 0011 11 */
{ dual_op  , "CMP.B"   ,        2, 0xff, 0x1f, 1026 }, /* 1011 0100 00 */
{ dual_op  , "CMP.W"   ,        2, 0xff, 0x1f, 1026 }, /* 1011 0100 01 */
{ dual_op  , "CMP.L"   ,        2, 0xff, 0x1f, 1026 }, /* 1011 0100 10 */
{ op_w     , "CMPA.W"  ,       10, 0xff, 0x1f, 1026 }, /* 1011 0100 11 */
{ dual_op  , "EOR.B"   ,        2, 0xfd, 0x03, 1034 }, /* 1011 0101 00 */
{ dual_op  , "EOR.W"   ,        2, 0xfd, 0x03, 1043 }, /* 1011 0101 01 */
{ dual_op  , "EOR.L"   ,        2, 0xfd, 0x03, 1044 }, /* 1011 0101 10 */
{ op_l     , "CMPA.L"  ,       10, 0xff, 0x1f, 1026 }, /* 1011 0101 11 */
{ dual_op  , "CMP.B"   ,        3, 0xff, 0x1f, 1026 }, /* 1011 0110 00 */
{ dual_op  , "CMP.W"   ,        3, 0xff, 0x1f, 1026 }, /* 1011 0110 01 */
{ dual_op  , "CMP.L"   ,        3, 0xff, 0x1f, 1026 }, /* 1011 0110 10 */
{ op_w     , "CMPA.W"  ,       11, 0xff, 0x1f, 1026 }, /* 1011 0110 11 */
{ dual_op  , "EOR.B"   ,        3, 0xfd, 0x03, 1034 }, /* 1011 0111 00 */
{ dual_op  , "EOR.W"   ,        3, 0xfd, 0x03, 1043 }, /* 1011 0111 01 */
{ dual_op  , "EOR.L"   ,        3, 0xfd, 0x03, 1044 }, /* 1011 0111 10 */
{ op_l     , "CMPA.L"  ,       11, 0xff, 0x1f, 1026 }, /* 1011 0111 11 */
{ dual_op  , "CMP.B"   ,        4, 0xff, 0x1f, 1026 }, /* 1011 1000 00 */
{ dual_op  , "CMP.W"   ,        4, 0xff, 0x1f, 1026 }, /* 1011 1000 01 */
{ dual_op  , "CMP.L"   ,        4, 0xff, 0x1f, 1026 }, /* 1011 1000 10 */
{ op_w     , "CMPA.W"  ,       12, 0xff, 0x1f, 1026 }, /* 1011 1000 11 */
{ dual_op  , "EOR.B"   ,        4, 0xfd, 0x03, 1034 }, /* 1011 1001 00 */
{ dual_op  , "EOR.W"   ,        4, 0xfd, 0x03, 1043 }, /* 1011 1001 01 */
{ dual_op  , "EOR.L"   ,        4, 0xfd, 0x03, 1044 }, /* 1011 1001 10 */
{ op_l     , "CMPA.L"  ,       12, 0xff, 0x1f, 1026 }, /* 1011 1001 11 */
{ dual_op  , "CMP.B"   ,        5, 0xff, 0x1f, 1026 }, /* 1011 1010 00 */
{ dual_op  , "CMP.W"   ,        5, 0xff, 0x1f, 1026 }, /* 1011 1010 01 */
{ dual_op  , "CMP.L"   ,        5, 0xff, 0x1f, 1026 }, /* 1011 1010 10 */
{ op_w     , "CMPA.W"  ,       13, 0xff, 0x1f, 1026 }, /* 1011 1010 11 */
{ dual_op  , "EOR.B"   ,        5, 0xfd, 0x03, 1034 }, /* 1011 1011 00 */
{ dual_op  , "EOR.W"   ,        5, 0xfd, 0x03, 1043 }, /* 1011 1011 01 */
{ dual_op  , "EOR.L"   ,        5, 0xfd, 0x03, 1044 }, /* 1011 1011 10 */
{ op_l     , "CMPA.L"  ,       13, 0xff, 0x1f, 1026 }, /* 1011 1011 11 */
{ dual_op  , "CMP.B"   ,        6, 0xff, 0x1f, 1026 }, /* 1011 1100 00 */
{ dual_op  , "CMP.W"   ,        6, 0xff, 0x1f, 1026 }, /* 1011 1100 01 */
{ dual_op  , "CMP.L"   ,        6, 0xff, 0x1f, 1026 }, /* 1011 1100 10 */
{ op_w     , "CMPA.W"  ,       14, 0xff, 0x1f, 1026 }, /* 1011 1100 11 */
{ dual_op  , "EOR.B"   ,        6, 0xfd, 0x03, 1034 }, /* 1011 1101 00 */
{ dual_op  , "EOR.W"   ,        6, 0xfd, 0x03, 1043 }, /* 1011 1101 01 */
{ dual_op  , "EOR.L"   ,        6, 0xfd, 0x03, 1044 }, /* 1011 1101 10 */
{ op_l     , "CMPA.L"  ,       14, 0xff, 0x1f, 1026 }, /* 1011 1101 11 */
{ dual_op  , "CMP.B"   ,        7, 0xff, 0x1f, 1026 }, /* 1011 1110 00 */
{ dual_op  , "CMP.W"   ,        7, 0xff, 0x1f, 1026 }, /* 1011 1110 01 */
{ dual_op  , "CMP.L"   ,        7, 0xff, 0x1f, 1026 }, /* 1011 1110 10 */
{ op_w     , "CMPA.W"  ,       15, 0xff, 0x1f, 1026 }, /* 1011 1110 11 */
{ dual_op  , "EOR.B"   ,        7, 0xfd, 0x03, 1034 }, /* 1011 1111 00 */
{ dual_op  , "EOR.W"   ,        7, 0xfd, 0x03, 1043 }, /* 1011 1111 01 */
{ dual_op  , "EOR.L"   ,        7, 0xfd, 0x03, 1044 }, /* 1011 1111 10 */
{ op_l     , "CMPA.L"  ,       15, 0xff, 0x1f, 1026 }, /* 1011 1111 11 */
{ dual_op  , "AND.B"   ,        0, 0xfd, 0x1f, 1026 }, /* 1100 0000 00 */
{ dual_op  , "AND.W"   ,        0, 0xfd, 0x1f, 1026 }, /* 1100 0000 01 */
{ dual_op  , "AND.L"   ,        0, 0xfd, 0x1f, 1026 }, /* 1100 0000 10 */
{ op_w     , "MULU.W"  ,        0, 0xfd, 0x1f, 1026 }, /* 1100 0000 11 */
{ dual_op  , "AND.B"   ,        0, 0xfc, 0x03, 1035 }, /* 1100 0001 00 */
{ dual_op  , "AND.W"   ,        0, 0xfc, 0x03, 1036 }, /* 1100 0001 01 */
{ dual_op  , "AND.L"   ,        0, 0xfc, 0x03, 1036 }, /* 1100 0001 10 */
{ op_w     , "MULS.W"  ,        0, 0xfd, 0x1f, 1026 }, /* 1100 0001 11 */
{ dual_op  , "AND.B"   ,        1, 0xfd, 0x1f, 1026 }, /* 1100 0010 00 */
{ dual_op  , "AND.W"   ,        1, 0xfd, 0x1f, 1026 }, /* 1100 0010 01 */
{ dual_op  , "AND.L"   ,        1, 0xfd, 0x1f, 1026 }, /* 1100 0010 10 */
{ op_w     , "MULU.W"  ,        1, 0xfd, 0x1f, 1026 }, /* 1100 0010 11 */
{ dual_op  , "AND.B"   ,        1, 0xfc, 0x03, 1035 }, /* 1100 0011 00 */
{ dual_op  , "AND.W"   ,        1, 0xfc, 0x03, 1036 }, /* 1100 0011 01 */
{ dual_op  , "AND.L"   ,        1, 0xfc, 0x03, 1036 }, /* 1100 0011 10 */
{ op_w     , "MULS.W"  ,        1, 0xfd, 0x1f, 1026 }, /* 1100 0011 11 */
{ dual_op  , "AND.B"   ,        2, 0xfd, 0x1f, 1026 }, /* 1100 0100 00 */
{ dual_op  , "AND.W"   ,        2, 0xfd, 0x1f, 1026 }, /* 1100 0100 01 */
{ dual_op  , "AND.L"   ,        2, 0xfd, 0x1f, 1026 }, /* 1100 0100 10 */
{ op_w     , "MULU.W"  ,        2, 0xfd, 0x1f, 1026 }, /* 1100 0100 11 */
{ dual_op  , "AND.B"   ,        2, 0xfc, 0x03, 1035 }, /* 1100 0101 00 */
{ dual_op  , "AND.W"   ,        2, 0xfc, 0x03, 1036 }, /* 1100 0101 01 */
{ dual_op  , "AND.L"   ,        2, 0xfc, 0x03, 1036 }, /* 1100 0101 10 */
{ op_w     , "MULS.W"  ,        2, 0xfd, 0x1f, 1026 }, /* 1100 0101 11 */
{ dual_op  , "AND.B"   ,        3, 0xfd, 0x1f, 1026 }, /* 1100 0110 00 */
{ dual_op  , "AND.W"   ,        3, 0xfd, 0x1f, 1026 }, /* 1100 0110 01 */
{ dual_op  , "AND.L"   ,        3, 0xfd, 0x1f, 1026 }, /* 1100 0110 10 */
{ op_w     , "MULU.W"  ,        3, 0xfd, 0x1f, 1026 }, /* 1100 0110 11 */
{ dual_op  , "AND.B"   ,        3, 0xfc, 0x03, 1035 }, /* 1100 0111 00 */
{ dual_op  , "AND.W"   ,        3, 0xfc, 0x03, 1036 }, /* 1100 0111 01 */
{ dual_op  , "AND.L"   ,        3, 0xfc, 0x03, 1036 }, /* 1100 0111 10 */
{ op_w     , "MULS.W"  ,        3, 0xfd, 0x1f, 1026 }, /* 1100 0111 11 */
{ dual_op  , "AND.B"   ,        4, 0xfd, 0x1f, 1026 }, /* 1100 1000 00 */
{ dual_op  , "AND.W"   ,        4, 0xfd, 0x1f, 1026 }, /* 1100 1000 01 */
{ dual_op  , "AND.L"   ,        4, 0xfd, 0x1f, 1026 }, /* 1100 1000 10 */
{ op_w     , "MULU.W"  ,        4, 0xfd, 0x1f, 1026 }, /* 1100 1000 11 */
{ dual_op  , "AND.B"   ,        4, 0xfc, 0x03, 1035 }, /* 1100 1001 00 */
{ dual_op  , "AND.W"   ,        4, 0xfc, 0x03, 1036 }, /* 1100 1001 01 */
{ dual_op  , "AND.L"   ,        4, 0xfc, 0x03, 1036 }, /* 1100 1001 10 */
{ op_w     , "MULS.W"  ,        4, 0xfd, 0x1f, 1026 }, /* 1100 1001 11 */
{ dual_op  , "AND.B"   ,        5, 0xfd, 0x1f, 1026 }, /* 1100 1010 00 */
{ dual_op  , "AND.W"   ,        5, 0xfd, 0x1f, 1026 }, /* 1100 1010 01 */
{ dual_op  , "AND.L"   ,        5, 0xfd, 0x1f, 1026 }, /* 1100 1010 10 */
{ op_w     , "MULU.W"  ,        5, 0xfd, 0x1f, 1026 }, /* 1100 1010 11 */
{ dual_op  , "AND.B"   ,        5, 0xfc, 0x03, 1035 }, /* 1100 1011 00 */
{ dual_op  , "AND.W"   ,        5, 0xfc, 0x03, 1036 }, /* 1100 1011 01 */
{ dual_op  , "AND.L"   ,        5, 0xfc, 0x03, 1036 }, /* 1100 1011 10 */
{ op_w     , "MULS.W"  ,        5, 0xfd, 0x1f, 1026 }, /* 1100 1011 11 */
{ dual_op  , "AND.B"   ,        6, 0xfd, 0x1f, 1026 }, /* 1100 1100 00 */
{ dual_op  , "AND.W"   ,        6, 0xfd, 0x1f, 1026 }, /* 1100 1100 01 */
{ dual_op  , "AND.L"   ,        6, 0xfd, 0x1f, 1026 }, /* 1100 1100 10 */
{ op_w     , "MULU.W"  ,        6, 0xfd, 0x1f, 1026 }, /* 1100 1100 11 */
{ dual_op  , "AND.B"   ,        6, 0xfc, 0x03, 1035 }, /* 1100 1101 00 */
{ dual_op  , "AND.W"   ,        6, 0xfc, 0x03, 1036 }, /* 1100 1101 01 */
{ dual_op  , "AND.L"   ,        6, 0xfc, 0x03, 1036 }, /* 1100 1101 10 */
{ op_w     , "MULS.W"  ,        6, 0xfd, 0x1f, 1026 }, /* 1100 1101 11 */
{ dual_op  , "AND.B"   ,        7, 0xfd, 0x1f, 1026 }, /* 1100 1110 00 */
{ dual_op  , "AND.W"   ,        7, 0xfd, 0x1f, 1026 }, /* 1100 1110 01 */
{ dual_op  , "AND.L"   ,        7, 0xfd, 0x1f, 1026 }, /* 1100 1110 10 */
{ op_w     , "MULU.W"  ,        7, 0xfd, 0x1f, 1026 }, /* 1100 1110 11 */
{ dual_op  , "AND.B"   ,        7, 0xfc, 0x03, 1035 }, /* 1100 1111 00 */
{ dual_op  , "AND.W"   ,        7, 0xfc, 0x03, 1036 }, /* 1100 1111 01 */
{ dual_op  , "AND.L"   ,        7, 0xfc, 0x03, 1036 }, /* 1100 1111 10 */
{ op_w     , "MULS.W"  ,        7, 0xfd, 0x1f, 1026 }, /* 1100 1111 11 */
{ dual_op  , "ADD.B"   ,        0, 0xff, 0x1f, 1026 }, /* 1101 0000 00 */
{ dual_op  , "ADD.W"   ,        0, 0xff, 0x1f, 1026 }, /* 1101 0000 01 */
{ dual_op  , "ADD.L"   ,        0, 0xff, 0x1f, 1026 }, /* 1101 0000 10 */
{ op_w     , "ADDA.W"  ,        8, 0xff, 0x1f, 1026 }, /* 1101 0000 11 */
{ dual_op  , "ADD.B"   ,        0, 0xfc, 0x03, 1033 }, /* 1101 0001 00 */
{ dual_op  , "ADD.W"   ,        0, 0xfc, 0x03, 1038 }, /* 1101 0001 01 */
{ dual_op  , "ADD.L"   ,        0, 0xfc, 0x03, 1039 }, /* 1101 0001 10 */
{ op_l     , "ADDA.L"  ,        8, 0xff, 0x1f, 1026 }, /* 1101 0001 11 */
{ dual_op  , "ADD.B"   ,        1, 0xff, 0x1f, 1026 }, /* 1101 0010 00 */
{ dual_op  , "ADD.W"   ,        1, 0xff, 0x1f, 1026 }, /* 1101 0010 01 */
{ dual_op  , "ADD.L"   ,        1, 0xff, 0x1f, 1026 }, /* 1101 0010 10 */
{ op_w     , "ADDA.W"  ,        9, 0xff, 0x1f, 1026 }, /* 1101 0010 11 */
{ dual_op  , "ADD.B"   ,        1, 0xfc, 0x03, 1033 }, /* 1101 0011 00 */
{ dual_op  , "ADD.W"   ,        1, 0xfc, 0x03, 1038 }, /* 1101 0011 01 */
{ dual_op  , "ADD.L"   ,        1, 0xfc, 0x03, 1039 }, /* 1101 0011 10 */
{ op_l     , "ADDA.L"  ,        9, 0xff, 0x1f, 1026 }, /* 1101 0011 11 */
{ dual_op  , "ADD.B"   ,        2, 0xff, 0x1f, 1026 }, /* 1101 0100 00 */
{ dual_op  , "ADD.W"   ,        2, 0xff, 0x1f, 1026 }, /* 1101 0100 01 */
{ dual_op  , "ADD.L"   ,        2, 0xff, 0x1f, 1026 }, /* 1101 0100 10 */
{ op_w     , "ADDA.W"  ,       10, 0xff, 0x1f, 1026 }, /* 1101 0100 11 */
{ dual_op  , "ADD.B"   ,        2, 0xfc, 0x03, 1033 }, /* 1101 0101 00 */
{ dual_op  , "ADD.W"   ,        2, 0xfc, 0x03, 1038 }, /* 1101 0101 01 */
{ dual_op  , "ADD.L"   ,        2, 0xfc, 0x03, 1039 }, /* 1101 0101 10 */
{ op_l     , "ADDA.L"  ,       10, 0xff, 0x1f, 1026 }, /* 1101 0101 11 */
{ dual_op  , "ADD.B"   ,        3, 0xff, 0x1f, 1026 }, /* 1101 0110 00 */
{ dual_op  , "ADD.W"   ,        3, 0xff, 0x1f, 1026 }, /* 1101 0110 01 */
{ dual_op  , "ADD.L"   ,        3, 0xff, 0x1f, 1026 }, /* 1101 0110 10 */
{ op_w     , "ADDA.W"  ,       11, 0xff, 0x1f, 1026 }, /* 1101 0110 11 */
{ dual_op  , "ADD.B"   ,        3, 0xfc, 0x03, 1033 }, /* 1101 0111 00 */
{ dual_op  , "ADD.W"   ,        3, 0xfc, 0x03, 1038 }, /* 1101 0111 01 */
{ dual_op  , "ADD.L"   ,        3, 0xfc, 0x03, 1039 }, /* 1101 0111 10 */
{ op_l     , "ADDA.L"  ,       11, 0xff, 0x1f, 1026 }, /* 1101 0111 11 */
{ dual_op  , "ADD.B"   ,        4, 0xff, 0x1f, 1026 }, /* 1101 1000 00 */
{ dual_op  , "ADD.W"   ,        4, 0xff, 0x1f, 1026 }, /* 1101 1000 01 */
{ dual_op  , "ADD.L"   ,        4, 0xff, 0x1f, 1026 }, /* 1101 1000 10 */
{ op_w     , "ADDA.W"  ,       12, 0xff, 0x1f, 1026 }, /* 1101 1000 11 */
{ dual_op  , "ADD.B"   ,        4, 0xfc, 0x03, 1033 }, /* 1101 1001 00 */
{ dual_op  , "ADD.W"   ,        4, 0xfc, 0x03, 1038 }, /* 1101 1001 01 */
{ dual_op  , "ADD.L"   ,        4, 0xfc, 0x03, 1039 }, /* 1101 1001 10 */
{ op_l     , "ADDA.L"  ,       12, 0xff, 0x1f, 1026 }, /* 1101 1001 11 */
{ dual_op  , "ADD.B"   ,        5, 0xff, 0x1f, 1026 }, /* 1101 1010 00 */
{ dual_op  , "ADD.W"   ,        5, 0xff, 0x1f, 1026 }, /* 1101 1010 01 */
{ dual_op  , "ADD.L"   ,        5, 0xff, 0x1f, 1026 }, /* 1101 1010 10 */
{ op_w     , "ADDA.W"  ,       13, 0xff, 0x1f, 1026 }, /* 1101 1010 11 */
{ dual_op  , "ADD.B"   ,        5, 0xfc, 0x03, 1033 }, /* 1101 1011 00 */
{ dual_op  , "ADD.W"   ,        5, 0xfc, 0x03, 1038 }, /* 1101 1011 01 */
{ dual_op  , "ADD.L"   ,        5, 0xfc, 0x03, 1039 }, /* 1101 1011 10 */
{ op_l     , "ADDA.L"  ,       13, 0xff, 0x1f, 1026 }, /* 1101 1011 11 */
{ dual_op  , "ADD.B"   ,        6, 0xff, 0x1f, 1026 }, /* 1101 1100 00 */
{ dual_op  , "ADD.W"   ,        6, 0xff, 0x1f, 1026 }, /* 1101 1100 01 */
{ dual_op  , "ADD.L"   ,        6, 0xff, 0x1f, 1026 }, /* 1101 1100 10 */
{ op_w     , "ADDA.W"  ,       14, 0xff, 0x1f, 1026 }, /* 1101 1100 11 */
{ dual_op  , "ADD.B"   ,        6, 0xfc, 0x03, 1033 }, /* 1101 1101 00 */
{ dual_op  , "ADD.W"   ,        6, 0xfc, 0x03, 1038 }, /* 1101 1101 01 */
{ dual_op  , "ADD.L"   ,        6, 0xfc, 0x03, 1039 }, /* 1101 1101 10 */
{ op_l     , "ADDA.L"  ,       14, 0xff, 0x1f, 1026 }, /* 1101 1101 11 */
{ dual_op  , "ADD.B"   ,        7, 0xff, 0x1f, 1026 }, /* 1101 1110 00 */
{ dual_op  , "ADD.W"   ,        7, 0xff, 0x1f, 1026 }, /* 1101 1110 01 */
{ dual_op  , "ADD.L"   ,        7, 0xff, 0x1f, 1026 }, /* 1101 1110 10 */
{ op_w     , "ADDA.W"  ,       15, 0xff, 0x1f, 1026 }, /* 1101 1110 11 */
{ dual_op  , "ADD.B"   ,        7, 0xfc, 0x03, 1033 }, /* 1101 1111 00 */
{ dual_op  , "ADD.W"   ,        7, 0xfc, 0x03, 1038 }, /* 1101 1111 01 */
{ dual_op  , "ADD.L"   ,        7, 0xfc, 0x03, 1039 }, /* 1101 1111 10 */
{ op_l     , "ADDA.L"  ,       15, 0xff, 0x1f, 1026 }, /* 1101 1111 11 */
{ shiftreg , "R.B"     ,        8, 0xff, 0xff, 1026 }, /* 1110 0000 00 */
{ shiftreg , "R.W"     ,        8, 0xff, 0xff, 1026 }, /* 1110 0000 01 */
{ shiftreg , "R.L"     ,        8, 0xff, 0xff, 1026 }, /* 1110 0000 10 */
{ single_op, "ASR.W"   , ACC_WORD, 0xfc, 0x03, 1026 }, /* 1110 0000 11 */
{ shiftreg , "L.B"     ,        8, 0xff, 0xff, 1026 }, /* 1110 0001 00 */
{ shiftreg , "L.W"     ,        8, 0xff, 0xff, 1026 }, /* 1110 0001 01 */
{ shiftreg , "L.L"     ,        8, 0xff, 0xff, 1026 }, /* 1110 0001 10 */
{ single_op, "ASL.W"   , ACC_WORD, 0xfc, 0x03, 1026 }, /* 1110 0001 11 */
{ shiftreg , "R.B"     ,        1, 0xff, 0xff, 1026 }, /* 1110 0010 00 */
{ shiftreg , "R.W"     ,        1, 0xff, 0xff, 1026 }, /* 1110 0010 01 */
{ shiftreg , "R.L"     ,        1, 0xff, 0xff, 1026 }, /* 1110 0010 10 */
{ single_op, "LSR.W"   , ACC_WORD, 0xfc, 0x03, 1026 }, /* 1110 0010 11 */
{ shiftreg , "L.B"     ,        1, 0xff, 0xff, 1026 }, /* 1110 0011 00 */
{ shiftreg , "L.W"     ,        1, 0xff, 0xff, 1026 }, /* 1110 0011 01 */
{ shiftreg , "L.L"     ,        1, 0xff, 0xff, 1026 }, /* 1110 0011 10 */
{ single_op, "LSL.W"   , ACC_WORD, 0xfc, 0x03, 1026 }, /* 1110 0011 11 */
{ shiftreg , "R.B"     ,        2, 0xff, 0xff, 1026 }, /* 1110 0100 00 */
{ shiftreg , "R.W"     ,        2, 0xff, 0xff, 1026 }, /* 1110 0100 01 */
{ shiftreg , "R.L"     ,        2, 0xff, 0xff, 1026 }, /* 1110 0100 10 */
{ single_op, "ROXR.W"  , ACC_WORD, 0xfc, 0x03, 1026 }, /* 1110 0100 11 */
{ shiftreg , "L.B"     ,        2, 0xff, 0xff, 1026 }, /* 1110 0101 00 */
{ shiftreg , "L.W"     ,        2, 0xff, 0xff, 1026 }, /* 1110 0101 01 */
{ shiftreg , "L.L"     ,        2, 0xff, 0xff, 1026 }, /* 1110 0101 10 */
{ single_op, "ROXL.W"  , ACC_WORD, 0xfc, 0x03, 1026 }, /* 1110 0101 11 */
{ shiftreg , "R.B"     ,        3, 0xff, 0xff, 1026 }, /* 1110 0110 00 */
{ shiftreg , "R.W"     ,        3, 0xff, 0xff, 1026 }, /* 1110 0110 01 */
{ shiftreg , "R.L"     ,        3, 0xff, 0xff, 1026 }, /* 1110 0110 10 */
{ single_op, "ROR.W"   , ACC_WORD, 0xfc, 0x03, 1026 }, /* 1110 0110 11 */
{ shiftreg , "L.B"     ,        3, 0xff, 0xff, 1026 }, /* 1110 0111 00 */
{ shiftreg , "L.W"     ,        3, 0xff, 0xff, 1026 }, /* 1110 0111 01 */
{ shiftreg , "L.L"     ,        3, 0xff, 0xff, 1026 }, /* 1110 0111 10 */
{ single_op, "ROL.W"   , ACC_WORD, 0xfc, 0x03, 1026 }, /* 1110 0111 11 */
{ shiftreg , "R.B"     ,        4, 0xff, 0xff, 1026 }, /* 1110 1000 00 */
{ shiftreg , "R.W"     ,        4, 0xff, 0xff, 1026 }, /* 1110 1000 01 */
{ shiftreg , "R.L"     ,        4, 0xff, 0xff, 1026 }, /* 1110 1000 10 */
{ bf_op    , "BFTST"   , SINGLEOP, 0xe5, 0x0f, 1026 }, /* 1110 1000 11 */
{ shiftreg , "L.B"     ,        4, 0xff, 0xff, 1026 }, /* 1110 1001 00 */
{ shiftreg , "L.W"     ,        4, 0xff, 0xff, 1026 }, /* 1110 1001 01 */
{ shiftreg , "L.L"     ,        4, 0xff, 0xff, 1026 }, /* 1110 1001 10 */
{ bf_op    , "BFEXTU"  , DATADEST, 0xe5, 0x0f, 1026 }, /* 1110 1001 11 */
{ shiftreg , "R.B"     ,        5, 0xff, 0xff, 1026 }, /* 1110 1010 00 */
{ shiftreg , "R.W"     ,        5, 0xff, 0xff, 1026 }, /* 1110 1010 01 */
{ shiftreg , "R.L"     ,        5, 0xff, 0xff, 1026 }, /* 1110 1010 10 */
{ bf_op    , "BFCHG"   , SINGLEOP, 0xe5, 0x03, 1026 }, /* 1110 1010 11 */
{ shiftreg , "L.B"     ,        5, 0xff, 0xff, 1026 }, /* 1110 1011 00 */
{ shiftreg , "L.W"     ,        5, 0xff, 0xff, 1026 }, /* 1110 1011 01 */
{ shiftreg , "L.L"     ,        5, 0xff, 0xff, 1026 }, /* 1110 1011 10 */
{ bf_op    , "BFEXTS"  , DATADEST, 0xe5, 0x0f, 1026 }, /* 1110 1011 11 */
{ shiftreg , "R.B"     ,        6, 0xff, 0xff, 1026 }, /* 1110 1100 00 */
{ shiftreg , "R.W"     ,        6, 0xff, 0xff, 1026 }, /* 1110 1100 01 */
{ shiftreg , "R.L"     ,        6, 0xff, 0xff, 1026 }, /* 1110 1100 10 */
{ bf_op    , "BFCLR"   , SINGLEOP, 0xe5, 0x03, 1026 }, /* 1110 1100 11 */
{ shiftreg , "L.B"     ,        6, 0xff, 0xff, 1026 }, /* 1110 1101 00 */
{ shiftreg , "L.W"     ,        6, 0xff, 0xff, 1026 }, /* 1110 1101 01 */
{ shiftreg , "L.L"     ,        6, 0xff, 0xff, 1026 }, /* 1110 1101 10 */
{ bf_op    , "BFFFO"   , DATADEST, 0xe5, 0x0f, 1026 }, /* 1110 1101 11 */
{ shiftreg , "R.B"     ,        7, 0xff, 0xff, 1026 }, /* 1110 1110 00 */
{ shiftreg , "R.W"     ,        7, 0xff, 0xff, 1026 }, /* 1110 1110 01 */
{ shiftreg , "R.L"     ,        7, 0xff, 0xff, 1026 }, /* 1110 1110 10 */
{ bf_op    , "BFSET"   , SINGLEOP, 0xe5, 0x03, 1026 }, /* 1110 1110 11 */
{ shiftreg , "L.B"     ,        7, 0xff, 0xff, 1026 }, /* 1110 1111 00 */
{ shiftreg , "L.W"     ,        7, 0xff, 0xff, 1026 }, /* 1110 1111 01 */
{ shiftreg , "L.L"     ,        7, 0xff, 0xff, 1026 }, /* 1110 1111 10 */
{ bf_op    , "BFINS"   ,  DATASRC, 0xe5, 0x03, 1026 }, /* 1110 1111 11 */

{ mmu30    , 0         ,        7, 0xe5, 0x03, 1026 }, /* 1111 0000 00 */   
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0000 01 */   
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0000 10 */   
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0000 11 */   
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0001 00 */   
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0001 01 */   
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0001 10 */   
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0001 11 */   
/* FPU opcode encodings */
{ fpu      , 0         ,        1, 0xff, 0xff, 1026 }, /* 1111 0010 00 */
{ fscc     , "FS"      ,        1, 0xfd, 0x03, 1047 }, /* 1111 0010 01 */
{ fbranch  , "FB"      , ACC_WORD, 0xff, 0x00, 1026 }, /* 1111 0010 10 */
{ fbranch  , "FB"      , ACC_LONG, 0xff, 0x00, 1026 }, /* 1111 0010 11 */
{ single_op, "FSAVE"   , ACC_LONG, 0xf4, 0x03, 1026 }, /* 1111 0011 00 */
{ single_op, "FRESTORE", ACC_LONG, 0xec, 0x0f, 1026 }, /* 1111 0011 01 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1111 0011 10 */
{ illegal  , 0         ,        0, 0xff, 0xff, 1026 }, /* 1111 0011 11 */

/* Opcodes for user-definable coprocessors */
{ cache    , 0         ,        0, 0xee, 0xff, 1026 }, /* 1111 0100 00 */
{ cache    , 0         ,        1, 0xee, 0xff, 1026 }, /* 1111 0100 01 */
{ cache    , 0         ,        2, 0xee, 0xff, 1026 }, /* 1111 0100 10 */
{ cache    , 0         ,        3, 0xee, 0xff, 1026 }, /* 1111 0100 11 */
{ pflush40 , "PFLUSH"  ,        0, 0x0f, 0xff, 1026 }, /* 1111 0101 00 */
{ ptest40  , "PTEST"   ,        7, 0x22, 0xff, 1026 }, /* 1111 0101 01 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0101 10 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0101 11 */
{ move16   , "MOVE16"  ,        7, 0x1f, 0xff, 1026 }, /* 1111 0110 00 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0110 01 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0110 10 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0110 11 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0111 00 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0111 01 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0111 10 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 0111 11 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1000 00 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1000 01 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1000 10 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1000 11 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1001 00 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1001 01 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1001 10 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1001 11 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1010 00 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1010 01 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1010 10 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1010 11 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1011 00 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1011 01 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1011 10 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1011 11 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1100 00 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1100 01 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1100 10 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1100 11 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1101 00 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1101 01 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1101 10 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1101 11 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1110 00 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1110 01 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1110 10 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1110 11 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1111 00 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1111 01 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1111 10 */
{ illegal  , 0         ,        7, 0xff, 0xff, 1026 }, /* 1111 1111 11 */

/* Here are the chained routines for handling doubly-defined opcodes */
{ srccr    , 0         ,        0, 0x80, 0x10, 1026 }, /* 1024 */
{ off_illegal,"ILLEGAL",        0, 0x80, 0x10, 1026 }, /* 1025 */
{ illegal  , 0         ,        0, 0xff, 0xff,    0 }, /* 1026 */
{ end_single_op, "RTM" ,NO_ACCESS, 0x03, 0x00, 1026 }, /* 1027 */
{ restrict , "UNPK"    ,   ADJUST, 0x03, 0x00, 1026 }, /* 1028 */
{ single_op, "SWAP"    , ACC_LONG, 0x01, 0x00, 1049 }, /* 1029 */
{ single_op, "EXT.W"   , ACC_WORD, 0x01, 0x00, 1026 }, /* 1030 */
{ restrict , "SBCD"    ,   NO_ADJ, 0x03, 0x00, 1026 }, /* 1031 */
{ restrict , "PACK"    ,   ADJUST, 0x03, 0x00, 1026 }, /* 1032 */
{ restrict , "ADDX.B"  ,   NO_ADJ, 0x03, 0x00, 1026 }, /* 1033 */
{ cmpm     , "CMPM.B"  ,        0, 0x02, 0xff, 1026 }, /* 1034 */
{ restrict , "ABCD.B"  ,   NO_ADJ, 0x03, 0x00, 1026 }, /* 1035 */
{ exg      , "EXG"     ,        0, 0x03, 0x00, 1026 }, /* 1036 */
{ movep    , "MOVEP"   ,        0, 0x02, 0x00, 1026 }, /* 1037 */
{ restrict , "ADDX.W"  ,   NO_ADJ, 0x03, 0x00, 1026 }, /* 1038 */
{ restrict , "ADDX.L"  ,   NO_ADJ, 0x03, 0x00, 1026 }, /* 1039 */
{ cas2     , "CAS2.B"  , ACC_BYTE, 0x80, 0x10, 1026 }, /* 1040 */
{ cas2     , "CAS2.W"  , ACC_WORD, 0x80, 0x10, 1026 }, /* 1041 */
{ cas2     , "CAS2.L"  , ACC_LONG, 0x80, 0x10, 1026 }, /* 1042 */
{ cmpm     , "CMPM.W"  ,        0, 0x02, 0xff, 1026 }, /* 1043 */
{ cmpm     , "CMPM.L"  ,        0, 0x02, 0xff, 1026 }, /* 1044 */

{ trapcc   , "TRAP"    ,        0, 0x80, 0x1c, 1026 }, /* 1045, TRAPcc */

{ scc      , "S"       ,        0, 0xfd, 0x03, 1045 }, /* 1046, Scc */

{ fdbranch , "FDB"    ,         0, 0x02, 0x00, 1048 }, /* 1047 */
{ ftrapcc  , "FTRAP"  ,         0, 0x80, 0x1c, 1026 }, /* 1048 */
{ bkpt     , "BKPT"    ,        0, 0x02, 0xff, 1026 }, /* 1049 */    
{ single_op, "EXT.L"   , ACC_LONG, 0x01, 0x00, 1026 }, /* 1050 */
{ single_op, "EXTB.L"  , ACC_LONG, 0x01, 0x00, 1026 }, /* 1051 */
{ restrict , "SUBX.B"  ,   NO_ADJ, 0x03, 0x00, 1026 }, /* 1052 */
{ restrict , "SUBX.W"  ,   NO_ADJ, 0x03, 0x00, 1026 }, /* 1053 */
{ restrict , "SUBX.L"  ,   NO_ADJ, 0x03, 0x00, 1026 }, /* 1054 */
{ link_l   , "LINK.L"  ,        0, 0x02, 0x00, 1026 }  /* 1055 */
};
