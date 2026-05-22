/*
 * Change history
 * $Log:	fpu_opcodes.c,v $
 * Revision 3.0  93/09/24  17:53:57  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.1  93/07/18  22:55:54  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.0  93/07/01  11:53:57  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.6  93/06/16  20:27:22  Martin_Apel
 * Minor mod.: Removed #ifdef FPU_VERSION and #ifdef MACHINE68020
 * 
 * Revision 1.5  93/06/03  20:27:05  Martin_Apel
 * 
 * 
 */

#include <exec/types.h>
#include <stdio.h>
#include "defs.h"

static char rcsid [] = "$Id: fpu_opcodes.c,v 3.0 93/09/24 17:53:57 Martin_Apel Exp $";

struct opcode_entry fpu_opcode_table [] =
{
{ std_fpu  , "FMOVE"  ,       0, 0,   0 },        /* 000 0000 */
{ std_fpu  , "FINT"   , SNG_ALL, 0,   0 },        /* 000 0001 */
{ std_fpu  , "FSINH"  , SNG_ALL, 0,   0 },        /* 000 0010 */
{ std_fpu  , "FINTRZ" , SNG_ALL, 0,   0 },        /* 000 0011 */
{ std_fpu  , "FSQRT"  , SNG_ALL, 0,   0 },        /* 000 0100 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 000 0101 */
{ std_fpu  , "FLOGNP1", SNG_ALL, 0,   0 },        /* 000 0110 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 000 0111 */
{ std_fpu  , "FETOXM1", SNG_ALL, 0,   0 },        /* 000 1000 */
{ std_fpu  , "FTANH"  , SNG_ALL, 0,   0 },        /* 000 1001 */
{ std_fpu  , "FATAN"  , SNG_ALL, 0,   0 },        /* 000 1010 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 000 1011 */
{ std_fpu  , "FASIN"  , SNG_ALL, 0,   0 },        /* 000 1100 */
{ std_fpu  , "FATANH" , SNG_ALL, 0,   0 },        /* 000 1101 */
{ std_fpu  , "FSIN"   , SNG_ALL, 0,   0 },        /* 000 1110 */
{ std_fpu  , "FTAN"   , SNG_ALL, 0,   0 },        /* 000 1111 */
{ std_fpu  , "FETOX"  , SNG_ALL, 0,   0 },        /* 001 0000 */
{ std_fpu  , "FTWOTOX", SNG_ALL, 0,   0 },        /* 001 0001 */
{ std_fpu  , "FTENTOX", SNG_ALL, 0,   0 },        /* 001 0010 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 001 0011 */
{ std_fpu  , "FLOGN"  , SNG_ALL, 0,   0 },        /* 001 0100 */
{ std_fpu  , "FLOG10" , SNG_ALL, 0,   0 },        /* 001 0101 */
{ std_fpu  , "FLOG2"  , SNG_ALL, 0,   0 },        /* 001 0110 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 001 0111 */
{ std_fpu  , "FABS"   , SNG_ALL, 0,   0 },        /* 001 1000 */
{ std_fpu  , "FCOSH"  , SNG_ALL, 0,   0 },        /* 001 1001 */
{ std_fpu  , "FNEG"   , SNG_ALL, 0,   0 },        /* 001 1010 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 001 1011 */
{ std_fpu  , "FACOS"  , SNG_ALL, 0,   0 },        /* 001 1100 */
{ std_fpu  , "FCOS"   , SNG_ALL, 0,   0 },        /* 001 1101 */
{ std_fpu  , "FGETEXP", SNG_ALL, 0,   0 },        /* 001 1110 */
{ std_fpu  , "FGETMAN", SNG_ALL, 0,   0 },        /* 001 1111 */
{ std_fpu  , "FDIV"   ,       0, 0,   0 },        /* 010 0000 */
{ std_fpu  , "FMOD"   ,       0, 0,   0 },        /* 010 0001 */
{ std_fpu  , "FADD"   ,       0, 0,   0 },        /* 010 0010 */
{ std_fpu  , "FMUL"   ,       0, 0,   0 },        /* 010 0011 */
{ std_fpu  , "FSGLDIV",       0, 0,   0 },        /* 010 0100 */
{ std_fpu  , "FREM"   ,       0, 0,   0 },        /* 010 0101 */
{ std_fpu  , "FSCALE" ,       0, 0,   0 },        /* 010 0110 */
{ std_fpu  , "FSGLMUL",       0, 0,   0 },        /* 010 0111 */
{ std_fpu  , "FSUB"   ,       0, 0,   0 },        /* 010 1000 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 010 1001 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 010 1010 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 010 1011 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 010 1100 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 010 1101 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 010 1110 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 010 1111 */
{ fsincos  , "FSINCOS",       0, 0,   0 },        /* 011 0000 */
{ fsincos  , "FSINCOS",       1, 0,   0 },        /* 011 0001 */
{ fsincos  , "FSINCOS",       2, 0,   0 },        /* 011 0010 */
{ fsincos  , "FSINCOS",       3, 0,   0 },        /* 011 0011 */
{ fsincos  , "FSINCOS",       4, 0,   0 },        /* 011 0100 */
{ fsincos  , "FSINCOS",       0, 0,   0 },        /* 011 0101 */
{ fsincos  , "FSINCOS",       6, 0,   0 },        /* 011 0110 */
{ fsincos  , "FSINCOS",       7, 0,   0 },        /* 011 0111 */
{ std_fpu  , "FCMP"   ,       0, 0,   0 },        /* 011 1000 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 011 1001 */
{ std_fpu  , "FTST"   , SNG_ALL, 0,   0 },        /* 011 1010 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 011 1011 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 011 1100 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 011 1101 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 011 1110 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 011 1111 */

{ std_fpu  , "FSMOVE" ,       0, 0,   0 },        /* 100 0000 */
{ std_fpu  , "FSSQRT" , SNG_ALL, 0,   0 },        /* 100 0001 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 100 0010 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 100 0011 */
{ std_fpu  , "FDMOVE" ,       0, 0,   0 },        /* 100 0100 */
{ std_fpu  , "FDSQRT" , SNG_ALL, 0,   0 },        /* 100 0101 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 100 0110 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 100 0111 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 100 1000 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 100 1001 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 100 1010 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 100 1011 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 100 1100 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 100 1101 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 100 1110 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 100 1111 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 101 0000 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 101 0001 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 101 0010 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 101 0011 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 101 0100 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 101 0101 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 101 0110 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 101 0111 */
{ std_fpu  , "FSABS"  , SNG_ALL, 0,   0 },        /* 101 1000 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 101 1001 */
{ std_fpu  , "FSNEG"  , SNG_ALL, 0,   0 },        /* 101 1010 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 101 1011 */
{ std_fpu  , "FDABS"  , SNG_ALL, 0,   0 },        /* 101 1100 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 101 1101 */
{ std_fpu  , "FDNEG"  , SNG_ALL, 0,   0 },        /* 101 1110 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 101 1111 */
{ std_fpu  , "FSDIV"  ,       0, 0,   0 },        /* 110 0000 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 110 0001 */
{ std_fpu  , "FSADD"  ,       0, 0,   0 },        /* 110 0010 */
{ std_fpu  , "FSMUL"  ,       0, 0,   0 },        /* 110 0011 */
{ std_fpu  , "FDDIV"  ,       0, 0,   0 },        /* 110 0100 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 110 0101 */
{ std_fpu  , "FDADD"  ,       0, 0,   0 },        /* 110 0110 */
{ std_fpu  , "FDMUL"  ,       0, 0,   0 },        /* 110 0111 */
{ std_fpu  , "FSSUB"  ,       0, 0,   0 },        /* 110 1000 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 110 1001 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 110 1010 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 110 1011 */
{ std_fpu  , "FDSUB"  ,       0, 0,   0 },        /* 110 1100 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 110 1101 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 110 1110 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 110 1111 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 0000 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 0001 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 0010 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 0011 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 0100 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 0101 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 0110 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 0111 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 1000 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 1001 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 1010 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 1011 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 1100 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 1101 */
{ illegal  ,  0       ,       0, 0,   0 },        /* 111 1110 */
{ illegal  ,  0       ,       0, 0,   0 }         /* 111 1111 */

};

char *xfer_size [] = { ".L",
                       ".S",
                       ".X",
                       ".P",
                       ".W",
                       ".D",
                       ".B",
                       ".P",  };

short sizes [] = { ACC_LONG   | ACC_DATA,
                   ACC_LONG   | ACC_DATA,
                   ACC_EXTEND | ACC_DATA,
                   ACC_EXTEND | ACC_DATA,
                   ACC_WORD   | ACC_DATA,
                   ACC_DOUBLE | ACC_DATA,
                   ACC_BYTE   | ACC_DATA,
                   ACC_EXTEND | ACC_DATA };

char *fpu_conditions [] = {
  "F",
  "EQ",
  "OGT",
  "OGE",
  "OLT",
  "OLE",
  "OGL",
  "OR",
  "UN",        /* 8 */
  "UEQ",
  "UGT",
  "UGE",
  "ULT",
  "ULE",
  "NE",
  "T",
  "SF",        /* 16 */
  "SEQ",
  "GT",
  "GE",
  "LT",
  "LE",
  "GL",
  "GLE",
  "NGLE",      /* 24 */
  "NGL",
  "NLE",
  "NLT",
  "NGE",
  "NGT",
  "SNE",
  "ST"
};
