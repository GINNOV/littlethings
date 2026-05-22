/*
**     $VER: rtgmaster.h 1.012 (08 Mar 1997)
*/

#ifndef RTGMASTER_H
#define RTGMASTER_H TRUE

#ifndef UTILITY_TAGITEM_H
#include "utility/tagitem.h"
#endif

#ifndef EXEC_LIBRARIES_H
#include "exec/libraries.h"
#endif

#ifndef EXEC_TYPES_H
#include "exec/types.h"
#endif

#define smr_Dummy      TAG_USER
#define smr_MinWidth   (smr_Dummy + 0x01)

// [320] This tag sets the minimum width in
// pixels which the user is allowed to select

#define smr_MaxWidth   (smr_Dummy + 0x02)

// [2048] This tag sets the maximum width in
// pixels which the user is allowed to select

#define smr_MinHeight  (smr_Dummy + 0x03)

// [200] This tag sets the minimum height in
// pixels which the user is allowed to select

#define smr_MaxHeight  (smr_Dummy + 0x04)

// [2048] This tag sets the maximum height in
// pixels which the user is allowed to select

#define smr_PlanarRoundW (smr_Dummy + 0x05)

// [16] RtgScreenModeReq will round user inputed
// values for Width to nearest higher multiple
// of thig tag for Planar display modes

#define smr_PlanarRoundH (smr_Dummy + 0x06)

// [1] RtgScreenModeReq will round user inputed
// values for Height to nearest higher multiple
// of thig tag for Planar display modes

#define smr_ChunkyRoundW (smr_Dummy + 0x07)

// [1] RtgScreenModeReq will round user inputed
// values for Width to nearest higher multiple
// of thig tag for Chunky display modes

#define smr_ChunkyRoundH (smr_Dummy + 0x08)

// [1] RtgScreenModeReq will round user inputed
// values for Height to nearest higher multiple
#define smr_ProgramUsesC2P   (smr_Dummy + 0x0c)

// [TRUE] If the program doesn't use the c2p call you have
// to specify FALSE. In this case the c2p part of the
// window is hidden and the the current c2p module is not
// used when filtering the screen modes.

// of thig tag for Chunky display modes

#define smr_ChunkySupport (smr_Dummy + 0x09)

// [0] This LONG is used to indicate which
// Chunky modes the user is allowed to select.
// A set bit means the mode is selectable.
// See the rtg_ChunkySupport tag for more
// information.

#define smr_PlanarSupport (smr_Dummy + 0x0a)

// EITEM smr_PlanarSupport ;[0] This LONG is used to indicate which
// Planar modes the user is allowed to select.
// A set bit means the mode is selectable.
// See the rtg_PlanarSupport tag for more
// information.

#define smr_Buffers       (smr_Dummy + 0x0b)

// [1] Using this tag you're can specify
// the number of buffers your application needs.
// Usually this ranges from 1-3.  Specify
// it here to filter out ScreenModes which can't
// handle the number of buffers you require.

//*******
// Attention: The following initial values are overwritten
// by the saved preferences if a valid preferences file
// is found.

#define smr_InitialWidth    (smr_Dummy + 0x10)

// [320] Initial screen width
// The minimal/maximal selectable width is taken into account.

#define smr_InitialHeight   (smr_Dummy + 0x11)

// [200] Initial screen height
// The minimal/maximal selectable height is taken into account.

#define smr_InitialDepth    (smr_Dummy + 0x12)

// [8] Log2 number of colors

#define smr_InitialScreenMode (smr_Dummy + 0x13)

// [the first selectable screenmode]
// Ptr to a string describing the ScreenMode
// (this is essentially the string pointed to
// by sm_Name)

#define smr_InitialDefaultW   (smr_Dummy + 0x14)

// [TRUE] False if you don't want the Default
// width gadget active.

#define smr_InitialDefaultH   (smr_Dummy + 0x15)

// [TRUE] False if you don't want the Default
// height gadget active.

#define smr_PrefsFileName     (smr_Dummy + 0x16)

// ["RtgScreenMode.prefs"]
// Specifies the file where the selected screenmode loaded from
// and saved to. If you set this to NULL, the save gadget
// is disabled and no screenmode is loaded at the beginning.
// The window is certainly opened without pressing the shift
// key then.
// If a valid preferences file is found the "smr_Initial" tags
// are ignored. It makes not much sense to specify inital values
// without setting smr_PrefsFileName to NULL.

#define smr_ForceOpen         (smr_Dummy + 0x17)

// [FALSE] If false, the screenmode requester reads the screenmode
// from the file specified by smr_PrefsFileName and returns immediately.
// The requester opens only in case of an error when reading the preferences
// or when the user presses shift while the requester is called.
// If true, the requester opens in any case and lets the user select a
// new mode.

#define smr_TitleText         (smr_Dummy + 0x18)

// ["RTG Screenmode Requester"] (STRPTR)
// The title text of the window

#define smr_WindowLeftEdge   (smr_Dummy + 0x19)

// [-1 (= centered)] The left edge of the requester window
// The value -1 means that the window is centered horicontically.

#define smr_WindowTopEdge    (smr_Dummy + 0x1a)

// [-1 (= centered)] The top edge of the requester window
// The value -1 means that the window is centered vertically.

#define smr_Screen           (smr_Dummy + 0x1b)

// [Default Pubscreen] (struct Screen *)
// The (custom or public) screen on which the screenmode requester should
// be opened

#define smr_PubScreenName    (smr_Dummy + 0x1c)

// [NULL] (STRPTR)
// The name of the public screen on which the screenmode
// requester should be opened; if not found, the default
// pubscreen is used.

//----------------added on 27/10/97 by Wolfram---------------

#define smr_MinPixelAspect   (smr_Dummy + 0x1d)

// [0] Minimal pixel aspect, defined as
// (1 << 16) * pixel_height / pixel_width
// see also: smr_PixelAspect_Proportional, _Wide and _High

#define smr_MaxPixelAspect   (smr_Dummy + 0x1e)

// [ULONG_MAX] Maximal pixel aspect, defined as
// (1 << 16) * pixel_height / pixel_width

#define smr_Workbench (smr_Dummy + 0x1f)

// Offer Workbench Support

// End of RtgScreenModeReq() enumeration ***


//**********************************************************************
// Special values for smr_MinPixelAspect and smr_MaxPixelAspect:
//
// If you want to get only proportional screen modes with 20% variation,
// you can set for example:
//
// smr_MinPixelAspect, smr_PixelAspect_Proportional *  8 / 10,
// smr_MaxPixelAspect, smr_PixelAspect_Proportional * 12 / 10
//

#define smr_PixelAspect_Proportional (1 << 16)
#define smr_PixelAspect_Wide         (smr_PixelAspect_Proportional / 2)
#define smr_PixelAspect_Narrow       (smr_PixelAspect_Proportional * 2)


// Execpt for the rb_LibBase structure this structure is private and for
// the internal use of RtgMaster.library ONLY.  This structure will change
// in the future.


struct RDCMPData
{
    struct MsgPort *port;
    ULONG signal;
    WORD *MouseX;
    WORD *MouseY;
};

struct RTGMasterBase {
    struct Library base;
    WORD   Pad;
    ULONG  SegList;
    APTR   DosBase;
    APTR   ExecBase;
    APTR   GadToolsBase;
    APTR   GfxBase;
    APTR   IntBase;
    APTR   UtilityBase;
    BYTE   Track[8];
    struct RtgLibs *Libraries;
    APTR   FirstScreenMode;
    APTR   LinkerDB;
};

// This structure is private and for the internal use of RtgMaster.library
// ONLY.  This structure will change in the future.

struct RtgLibs {
    APTR  Next;
    ULONG ID;
    APTR  LibBase;
    APTR  SMList;
    APTR  LastSM;
    UWORD LibVersion;
};

struct RtgBobHandle
{
 ULONG BufSize;
 struct RtgScreen *RtgScreen;
 APTR RefreshBuffer;
 ULONG BPR;
 ULONG Width;
 ULONG Height;
 UWORD numsprites;
 UWORD maxnum;
 ULONG reserved;
};

#endif

