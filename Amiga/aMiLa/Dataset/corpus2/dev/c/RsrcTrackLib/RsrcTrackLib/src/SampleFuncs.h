/*
**      $VER: SampleFuncs.h 37.0 (20.07.98)
**
**      Functions protos for ressourcetracking.library
**
**      (C) Copyright 1998 Patrick BURNAND
**      All Rights Reserved.
**
**      Original code for the example.library done by Andreas R. Kleinert.
**      See Clib37x.lha on Aminet !
*/

#include "compiler.h"

extern ULONG __saveds ASM rt_AddManager  ( register __d1 ULONG recNum GNUCREG(d1) );
extern void  __saveds ASM rt_RemManager  ( void );

extern ULONG __saveds ASM rt_FindNumUsed ( void );
extern void __saveds ASM rt_SetMarker   ( void );
extern void __saveds ASM rt_UnsetMarker ( void );
extern void __saveds ASM rt_SetCustomF0 ( register __d1 APTR func GNUCREG(d1) );
extern void __saveds ASM rt_SetCustomF1 ( register __d1 APTR func GNUCREG(d1), register __d2 ULONG arg1 GNUCREG(d2) );
extern void __saveds ASM rt_SetCustomF2 ( register __d1 APTR func GNUCREG(d1), register __d2 ULONG arg1 GNUCREG(d2), register __d3 ULONG arg2 GNUCREG(d3) );

extern APTR  __saveds ASM rt_AllocMem    ( register __d1 ULONG byteSize GNUCREG(d1), register __d2 ULONG requirements GNUCREG(d2) );
extern BYTE  __saveds ASM rt_AllocSignal ( register __d1 ULONG signalNum GNUCREG(d1) );
extern struct Library __saveds ASM *rt_OpenLibrary ( register __d1 UBYTE *libName GNUCREG(d1), register __d2 ULONG version GNUCREG(d2) );
extern void  __saveds ASM rt_AddSemaphore ( register __d1 struct SignalSemaphore *sigSem GNUCREG(d1) );
extern void  __saveds ASM rt_Forbid ( void );
extern ULONG __saveds ASM rt_AllocTrap ( register __d1 ULONG trapNum GNUCREG(d1) );
extern struct MsgPort __saveds ASM *rt_CreateMsgPort ( void );
extern void  __saveds ASM rt_AddPort ( register __d1 struct MsgPort *port GNUCREG(d1) );


