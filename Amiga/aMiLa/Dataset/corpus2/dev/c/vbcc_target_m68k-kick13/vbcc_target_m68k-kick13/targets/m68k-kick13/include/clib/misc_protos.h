#ifndef CLIB_MISC_PROTOS_H
#define CLIB_MISC_PROTOS_H


/*
**	$VER: misc_protos.h 34.106 (21.05.2022)
**
**	C prototypes.
**
**	Copyright © 2022 
**	All Rights Reserved
*/

#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif

UBYTE * AllocMiscResource(ULONG unitNum, const STRPTR name);
VOID FreeMiscResource(ULONG unitNum);

#endif	/*  CLIB_MISC_PROTOS_H  */
