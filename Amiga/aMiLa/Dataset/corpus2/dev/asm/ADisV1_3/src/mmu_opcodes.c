/*
 * Change history
 * $Log:	mmu_opcodes.c,v $
 * Revision 3.0  93/09/24  17:54:10  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.2  93/07/18  22:56:14  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.1  93/07/08  20:47:50  Martin_Apel
 * Bug fix: Replaced illegal with pmove30
 * 
 * Revision 2.0  93/07/01  11:54:18  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.1  93/06/19  12:11:42  Martin_Apel
 * Initial revision
 * 
 */

#include <exec/types.h>
#include <stdio.h>
#include "defs.h"

static char rcsid [] = "$Id: mmu_opcodes.c,v 3.0 93/09/24 17:54:10 Martin_Apel Exp $";

/* Table for the bits 14 to 10 of the second word of mmu opcodes */

struct opcode_entry mmu_opcode_table [] =
{
{ illegal  , 0        ,       0, 0,   0 },        /* 0 0000 */
{ illegal  , 0        ,       0, 0,   0 },        /* 0 0001 */ 
{ pmove30  , "PMOVE"  ,     TT0, 0,   0 },        /* 0 0010 */ 
{ pmove30  , "PMOVE"  ,     TT1, 0,   0 },        /* 0 0011 */ 
{ illegal  , 0        ,       0, 0,   0 },        /* 0 0100 */ 
{ illegal  , 0        ,       0, 0,   0 },        /* 0 0101 */ 
{ illegal  , 0        ,       0, 0,   0 },        /* 0 0110 */ 
{ illegal  , 0        ,       0, 0,   0 },        /* 0 0111 */ 
{ pfl_or_ld, "PFLUSH" ,       0, 0,   0 },        /* 0 1000 */ 
{ pflush30 , "PFLUSH" ,       1, 0,   0 },        /* 0 1001 */ 
{ pflush30 , "PFLUSH" ,       2, 0,   0 },        /* 0 1010 */ 
{ pflush30 , "PFLUSH" ,       3, 0,   0 },        /* 0 1011 */ 
{ pflush30 , "PFLUSH" ,       4, 0,   0 },        /* 0 1100 */ 
{ pflush30 , "PFLUSH" ,       5, 0,   0 },        /* 0 1101 */ 
{ pflush30 , "PFLUSH" ,       6, 0,   0 },        /* 0 1110 */ 
{ pflush30 , "PFLUSH" ,       7, 0,   0 },        /* 0 1111 */ 
{ pmove30  , "PMOVE"  ,      TC, 0,   0 },        /* 1 0000 */ 
{ illegal  ,  0       ,       0, 0,   0 },        /* 1 0001 */ 
{ pmove30  , "PMOVE"  ,     SRP, 0,   0 },        /* 1 0010 */ 
{ pmove30  , "PMOVE"  ,     CRP, 0,   0 },        /* 1 0011 */ 
{ illegal  , 0        ,       0, 0,   0 },        /* 1 0100 */ 
{ illegal  , 0        ,       0, 0,   0 },        /* 1 0101 */ 
{ illegal  , 0        ,       0, 0,   0 },        /* 1 0110 */ 
{ illegal  , 0        ,       0, 0,   0 },        /* 1 0111 */ 
{ pmove30  , "PMOVE"  ,   MMUSR, 0,   0 },        /* 1 1000 */ 
{ illegal  , 0        ,       0, 0,   0 },        /* 1 1001 */ 
{ illegal  , 0        ,       0, 0,   0 },        /* 1 1010 */ 
{ illegal  , 0        ,       0, 0,   0 },        /* 1 1011 */ 
{ illegal  , 0        ,       0, 0,   0 },        /* 1 1100 */ 
{ illegal  , 0        ,       0, 0,   0 },        /* 1 1101 */ 
{ illegal  , 0        ,       0, 0,   0 },        /* 1 1110 */ 
{ illegal  , 0        ,       0, 0,   0 }         /* 1 1111 */ 
};