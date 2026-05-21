/* Automatically generated header (sfdc 1.10)! Do not edit! */

#ifndef CLIB_VAMPIRE_PROTOS_H
#define CLIB_VAMPIRE_PROTOS_H

/*
**   $VER: vampire_protos.h $Id: vampire_protos.h 770 2017-08-31 19:47:43Z henrik $ $Id: vampire_protos.h 770 2017-08-31 19:47:43Z henrik $
**
**   C prototypes. For use with 32 bit integers only.
**
**   Copyright (c) 2001 Amiga, Inc.
**       All Rights Reserved
*/

#include <exec/types.h>

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

APTR V_AllocExpansionPort(ULONG unitNum, UBYTE *name);
VOID V_FreeExpansionPort(ULONG unitNum);
ULONG V_EnableAMMX(ULONG version);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* CLIB_VAMPIRE_PROTOS_H */
