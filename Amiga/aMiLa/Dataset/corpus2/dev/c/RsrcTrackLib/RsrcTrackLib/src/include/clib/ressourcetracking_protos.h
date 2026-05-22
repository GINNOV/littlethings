/*
**      $VER: ressourcetracking_protos.h 37.0 (20.07.98)
**
**      prototypes for ressourcetracking.library
**
**      (C) Copyright 1998 Patrick BURNAND
**      All Rights Reserved.
**
**      Original code for the example.library done by Andreas R. Kleinert.
**      See Clib37x.lha on Aminet !
*/

#ifndef CLIB_ressourcetracking_PROTOS_H
#define CLIB_ressourcetracking_PROTOS_H

#ifndef ressourcetracking_ressourcetracking_H
#include <ressourcetracking/ressourcetracking.h>
#endif /* ressourcetracking_ressourcetracking_H */

ULONG rt_AddManager  ( ULONG recNum );
void  rt_RemManager  ( void );
ULONG rt_FindNumUsed ( void );
void  rt_SetMarker   ( void );
void  rt_UnsetMarker ( void );
void  rt_SetCustomF0 ( APTR f );
void  rt_SetCustomF1 ( APTR f, ULONG arg1 );
void  rt_SetCustomF2 ( APTR f, ULONG arg1, ULONG arg2 );

APTR  rt_AllocMem    ( ULONG byteSize, ULONG requirements );
BYTE  rt_AllocSignal ( ULONG signalNum );
struct Library *rt_OpenLibrary ( UBYTE *libName, ULONG version );
void  rt_AddSemaphore ( struct SignalSemaphore *sigSem );
void  rt_Forbid ( void );
ULONG rt_AllocTrap ( ULONG trapNum );
struct MsgPort *rt_CreateMsgPort ( void );
void  rt_AddPort ( struct MsgPort *port );

#endif /* CLIB_ressourcetracking_PROTOS_H */
