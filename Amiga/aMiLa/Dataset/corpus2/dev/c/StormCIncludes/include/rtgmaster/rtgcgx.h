/*
**     $VER: rtgCGX.h 1.001 (08 Mar 1997)
*/

#ifndef RTGCGX_H
#define RTGCGX_H TRUE

#ifndef RTGSUBLIBS_H
#include <rtgmaster/rtgsublibs.h>
#endif

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_PORTS_H
#include <exec/ports.h>
#endif

#ifndef GRAPHICS_VIEW_H
#include <graphics/view.h>
#endif

#include <intuition/intuition.h>

struct RtgBaseCGX
{
    struct Library CGXLibBase;
    UWORD  Pad1;
    ULONG  SegList;
    APTR   ExecBase;
    APTR   UtilityBase;
    APTR   DosBase;
    APTR   CGXBase;
    APTR   GfxBase;
    APTR   IntBase;
    ULONG  Flags;
    APTR   ExpansionBase;
    APTR   DiskFontBase;
    APTR   LinkerDB;
};

struct MyPort
{
    struct MsgPort *port;
    ULONG signal;
    WORD *MouseX;
    WORD *MouseY;
};

struct RtgScreenCGX
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
    UWORD  Height;
    ULONG  NumBuf;
    UWORD  Locks;
    ULONG  ModeID;
    struct BitMap *RealMapA;
    ULONG Tags[5];
    ULONG  OffA;
    ULONG  OffB;
    ULONG  OffC;
    struct Window *MyWindow;
    struct MyPort PortData;
    ULONG  BPR;
    struct DBufInfo *dbi;
    ULONG  SafeToWrite;
    ULONG  SafeToDisp;
    ULONG  Special;
    ULONG  SrcMode;
    APTR   tempras;
    APTR   tempbm;
    APTR   wbcolors;
    ULONG  colchanged;
    ULONG  ccol;
    APTR   colarray1;
    APTR   colarray2;
    int    DispBuf;
};


#endif

