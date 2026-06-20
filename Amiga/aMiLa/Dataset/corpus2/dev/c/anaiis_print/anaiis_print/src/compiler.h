/****************************************************************/
/* compiler.h                                                   */
/****************************************************************/
/*                                                              */
/* PANDORA                                                      */
/*                                                              */
/****************************************************************/
/*                                                              */
/* Modification history                                         */
/* ====================                                         */
/* 14-Feb-2008 Some register helper for SASC6.0                 */
/****************************************************************/
#ifndef ANAIIS_COMPILER_H_INCLUDED
#define ANAIIS_COMPILER_H_INCLUDED


#define SDS __saveds
#define ASM __asm

#define A0 register __a0
#define A1 register __a1
#define A2 register __a2
#define A3 register __a3
#define A4 register __a4
#define A5 register __a5
#define A6 register __a6

#define D0 register __d0
#define D1 register __d1
#define D2 register __d2
#define D3 register __d3
#define D4 register __d4
#define D5 register __d5
#define D6 register __d6
#define D7 register __d7

#endif
