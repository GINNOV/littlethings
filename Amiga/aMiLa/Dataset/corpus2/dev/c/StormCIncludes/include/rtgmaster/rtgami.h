/*
**     $VER: rtgAMI 1.005 (09 Oct 1997)
*/

#ifndef RTGAMI_H
#define RTGAMI_H TRUE

#ifndef RTGSUBLIBS_H
#include <include:rtgmaster/rtgsublibs.h>
#endif

#ifndef RTGMASTER_H
#include <include:rtgmaster/rtgmaster.h>
#endif

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef GRAPHICS_GFX_H
#include <graphics/gfx.h>
#endif

#ifndef GRAPHICS_RASTPORT_H
#include <graphics/rastport.h>
#endif

#ifndef GRAPHICS_VIEW_H
#include <graphics/view.h>
#endif

struct RtgBaseAMI
{
    struct Library LibBase;
    UWORD Pad1;
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
};

struct MyPort
{
    struct MsgPort *port;
    ULONG signal;
    WORD *MouseX;
    WORD *MouseY;
};


struct RtgScreenAMI
{
    struct RtgScreen Header;
    UWORD  Locks;
    struct Screen *ScreenHandle;
    ULONG  PlaneSize;
    ULONG  DispBuf;
    ULONG  ChipMem1;
    ULONG  ChipMem2;
    ULONG  ChipMem3;
    struct BitMap Bitmap1;
    struct BitMap Bitmap2;
    struct BitMap Bitmap3;
    ULONG  Flags;
    struct Rectangle MyRect;
    BYTE   Place[52];
    struct RastPort RastPort1;
    struct RastPort RastPort2;
    struct RastPort RastPort3;
    APTR   MyWindow;
    APTR   Pointer;
    struct MyPort  PortData;
    struct DBufInfo *dbufinfo;
    ULONG DispBuf1;
    ULONG DispBuf2;
    ULONG DispBuf3;
    ULONG SafeToWrite;
    ULONG SafeToDisp;
    ULONG SrcMode;
    APTR   tempras;
    APTR   tempbm;
    APTR   wbcolors;
    ULONG  Width;
    ULONG  Height;
    ULONG  colchanged;
    APTR   colarray1;
    APTR   ccol;
};

#endif

