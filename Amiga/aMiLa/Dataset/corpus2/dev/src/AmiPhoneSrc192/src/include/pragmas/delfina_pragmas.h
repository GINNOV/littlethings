
/*
 * include:amiga/pragmas/delfina_pragmas.h
 *
 *  MACHINE GENERATED WITH FDTOPRAGMA
 */

#ifndef DELFINA_PRAGMAS_H
#define DELFINA_PRAGMAS_H

extern struct Library *DelfinaBase;

#pragma libcall DelfinaBase Delf_Init 1e 00
#pragma libcall DelfinaBase Delf_Peek 24 0902
#pragma libcall DelfinaBase Delf_Poke 2a 10903
#pragma libcall DelfinaBase Delf_CopyMem 30 109804
#pragma libcall DelfinaBase Delf_AllocMem 36 1002
#pragma libcall DelfinaBase Delf_FreeMem 3c 0902
#pragma libcall DelfinaBase Delf_AvailMem 42 101
#pragma libcall DelfinaBase Delf_AddPrg 48 901
#pragma libcall DelfinaBase Delf_RemPrg 4e 901
#pragma libcall DelfinaBase Delf_Run 54 543210907
#pragma libcall DelfinaBase Delf_Cause 5a 001
#pragma libcall DelfinaBase Delf_AddIntServer 60 9002
#pragma libcall DelfinaBase Delf_RemIntServer 66 001
#pragma libcall DelfinaBase Delf_AllocAudio 6c 821004
#pragma libcall DelfinaBase Delf_FreeAudio 72 00
#pragma libcall DelfinaBase Delf_GetAttr 84 1002
#pragma libcall DelfinaBase Delf_SetAttrsA 8a 801

#endif

