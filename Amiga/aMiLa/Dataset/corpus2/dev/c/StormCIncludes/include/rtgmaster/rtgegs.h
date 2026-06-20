/*
**     $VER: rtgEGS.h 1.003 (08 Mar 1997)
*/

#ifndef RTGEGS_H
#define RTGEGS_H TRUE

#ifndef RTGSUBLIBS_H
#include "include:rtgmaster/rtgsublibs.h"
#endif

#ifndef EXEC_LIBRARIES_H
#include "exec/libraries.h"
#endif

#ifndef EXEC_TYPES_H
#include "exec/types.h"
#endif

struct RtgBaseEGS
{
    struct Library EGSLibBase;
    UWORD  Pad1;
    ULONG  SegList;
    APTR   ExecBase;
    APTR   UtilityBase;
    APTR   DosBase;
    APTR   EgsBase;
    APTR   EgsBlitBase;
    APTR   GFXBase;
    ULONG  Flags;
    APTR   EgsGfxBase;
    APTR   ExpansionBase;
};

struct MyPort
{
    struct MsgPort *port;
    ULONG signal;
    WORD *MouseX;
    WORD *MouseY;
};

struct RtgScreenEGS
{
    struct RtgScreen Header;
    APTR   MyScreen;
    ULONG  ActiveMap;
    APTR   MapA;
    APTR   MapB;
    APTR   MapC;
    APTR   FrontMap;
    ULONG  Bytes;
    ULONG  Width;
    ULONG  Type;
    ULONG  NumBuf;
    UWORD  Locks;
    APTR   RastPort1;
    APTR   RastPort2;
    APTR   RastPort3;
    UBYTE  Pointer[28];
    UBYTE  PointerA[256];
    UBYTE  PointerB[1024];
    UBYTE  PointerC[28];
    struct MyPort PortData;
};

#endif

