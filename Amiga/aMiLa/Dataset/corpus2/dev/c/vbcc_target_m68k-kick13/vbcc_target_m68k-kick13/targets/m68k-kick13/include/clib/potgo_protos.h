#ifndef CLIB_POTGO_PROTOS_H
#define CLIB_POTGO_PROTOS_H


/*
**	$VER: potgo_protos.h 34.106 (21.05.2022)
**
**	C prototypes.
**
**	Copyright © 2022 
**	All Rights Reserved
*/

#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif

UWORD AllocPotBits(ULONG bits);
VOID FreePotBits(ULONG bits);
VOID WritePotgo(ULONG word, ULONG mask);

#endif	/*  CLIB_POTGO_PROTOS_H  */
