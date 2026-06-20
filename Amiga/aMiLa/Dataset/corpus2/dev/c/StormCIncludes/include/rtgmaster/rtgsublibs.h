/*
**     $VER: rtgsublibs.h 1.008 (29 Jul 1997)
*/

#ifndef RTGSUBLIBS_H
#define RTGSUBLIBS_H TRUE

#ifndef UTILITY_TAGITEM_H
#include "utility/tagitem.h"
#endif

#ifndef EXEC_TYPES_H
#include "exec/types.h"
#endif

#ifndef EXEC_NODES_H
#include "exec/nodes.h"
#endif

// The TagItem ID's (ti_Tag values) for OpenRtgScreen()

// Information like width, height, screenmode to use, depth and overscan
// information is located in the ScreenReq structure which must be passed
// to OpenRtgScreen().  The RtgScreenModeReq() function creates these
// ScreenReq structures for you.

#define rtg_Dummy TAG_USER

#define rtg_Buffers (rtg_Dummy + 0x01)

// [1] You can use this tag to specify the number
// of screen buffers for your screen.  Setting this
// to 2 or 3 will allow you to do Double or Triple
// buffering.  Valid values are 1, 2 or 3.

#define rtg_Interleaved (rtg_Dummy + 0x02)

// [FALSE] Specifying TRUE will cause bitmaps to
// be allocated interleaved.  OpenRtgScreen will
// fail if bitplanes cannot be allocated that way
// unlike Intuition/OpenScreenTagList().

#define rtg_Draggable (rtg_Dummy + 0x03)

// [TRUE] Specifying FALSE will make the screen
// non-draggable.  Do not use without good reason!

#define rtg_Exclusive (rtg_Dummy + 0x04)

// [FALSE] Allows screens which won't share the
// display with other screens.  Use sparingly!

// #define rtg_ChunkySupport (rtg_Dummy + 0x05)
//
// [0] This LONG is used to indicate which
// Chunky modes this application supports.  A
// set bit means the mode is supported:

// ;    ;
// ;    ;    | Pixels  | Pixel|Color| Pixel
// ;    ; Bit|represent| size |space| layout
// ;    ;------------------------------------------------------------------
// ;    ;  0  TrueColor  LONG   RGB   %00000000 rrrrrrrr gggggggg bbbbbbbb  ARGB32
// ;    ;  1  TrueColor 3 BYTE  RGB   %rrrrrrrr gggggggg bbbbbbbb           RGB24
// ;    ;  2  TrueColor  WORD   RGB   %rrrrrggg gggbbbbb                    RGB16
// ;    ;  3  TrueColor  WORD   RGB   %0rrrrrgg gggbbbbb                    RGB15
// ;    ;  4  TrueColor  LONG   BGR   %00000000 bbbbbbbb gggggggg rrrrrrrr  ABGR32
// ;    ;  5  TrueColor 3 BYTE  BGR   %bbbbbbbb gggggggg rrrrrrrr           BGR24
// ;    ;  6  TrueColor  WORD   BGR   %bbbbbggg gggrrrrr                    BGR16
// ;    ;  7  TrueColor  WORD   BGR   %0bbbbbgg gggrrrrr                    BGR15
// ;    ;  8  TrueColor  LONG   RGB   %rrrrrrrr gggggggg bbbbbbbb 00000000  RGBA32
// ;    ;  9  ColorMap   BYTE   -     -                                     LUT8
// ;    ; 10  Graffiti   BYTE   -     - (Graffiti style chunky, very special)
// ;    ; 11  TrueColor  WORD   RGB   %gggbbbbb 0rrrrrgg                    RGB15PC
// ;    ; 12  TrueColor  WORD   BGR   %gggrrrrr 0bbbbbgg                    BGR15PC
// ;    ; 13  TrueColor  WORD   RGB   %gggbbbbb rrrrrggg                    RGB16PC
// ;    ; 14  TrueColor  WORD   BGR   %gggrrrrr bbbbbggg                    BGR16PC
// ;    ; 15  TrueColor  LONG   BGR   %bbbbbbbb gggggggg rrrrrrrr 00000000  BGRA32
//;
//    ; This table is by no means complete.  There are probably more modes
//    ; available on common Amiga graphic cards, but I have no information
//    ; on them yet.  If you know about such modes please contact me.
//
//    ; Setting this LONG to zero means your application doesn't support
//    ; any Chunky orientated display modes.
//
//    #define rtg_PlanarSupport (rtg_Dummy + 0x06)
//                            ;[0] This LONG is used to indicate which
//                            ;Planar modes this application supports.  A
//                            ;set bit means the mode is supported:
//    ; Bit 0: Indicates it supports 1 bitplane non-interleaved
//    ; Bit 1: Indicates it supports 2 bitplanes non-interleaved
//    ; (...)
//    ; Bit 7: Indicates it supports 8 bitplanes non-interleaved
//
//    ; Bit 16: Indicates it supports 1 bitplane interleaved
//    ; Bit 17: Indicates it supports 2 bitplanes interleaved
//    ; (...)
//    ; Bit 23: Indicates it supports 8 bitplanes interleaved
//
//    ; Bit 15: Indicates it supports EHB mode (6 bitplanes) non-interleaved
//    ; Bit 31: Indicates it supports EHB mode (6 bitplanes) interleaved
//
//    ; Note that all planar modes are color-mapped.  Bits 8-14 and 24-30
//    ; are unused for now, but could be used later to support planar modes
//    ; with even higher number of bitplanes.
//
//    ; Setting this LONG to zero means your application doesn't support
//    ; any Planar orientated display modes.


#define ARGB32 1L
#define RGB24  2L
#define RGB16  4L
#define RGB15  8L
#define ABGR32 16L
#define BGR24  32L
#define BGR16  64L
#define BGR15  128L
#define RGBA32 256L
#define LUT8   512L
#define GRAFFITI 1024L
#define RGB15PC  2048L
#define BGR15PC  4096L
#define RGB16PC  8192L
#define BGR16PC  16384L
#define BGRA32   32768L
#define Planar1  1L
#define Planar2  2L
#define Planar3  4L
#define Planar4  8L
#define Planar5  16L
#define Planar6  32L
#define Planar7  64L
#define Planar8  128L
#define Planar1I 1<<16L
#define Planar2I 1<<17L
#define Planar3I 1<<18L
#define Planar4I 1<<19L
#define Planar5I 1<<20L
#define Planar6I 1<<21L
#define Planar7I 1<<22L
#define Planar8I 1<<23L
#define PlanarEHB 1<<15L
#define PlanarEHBI 1<<31L

#define rtg_ZBuffer (rtg_Dummy + 0x07)

// Allocate a Z-Buffer. Only works with sublibraries that implement the rtgmaster 3D Extensions.

#define rtg_Use3D (rtg_Dummy + 0x08)

// Use the 3D Chips. (You can only do conventional Double/Triple-Buffering, if you do NOT use
// them. If you use them, the Extra Buffers are used by the 3D Chips)

#define rtg_Workbench (rtg_Dummy + 0x09)

// Open a Window on the Workbench, instead of a Screen. This Tag takes the Colorformat
// to use with CopyRtgBlit() as Parameter

// End of OpenRtgScreenTagList() enumeration ***

// This structure is private and for the internal use of RtgMaster.library
// and its sub-libraries ONLY.  This structure will change in the future.

#define rtg_MouseMove (rtg_Dummy+ 0x0A)

// RtgGetMsg also returns IDCMP_MOUSEMOVE messages

#define rtg_DeltaMove (rtg_Dummy+ 0x0B)

// RtgGetMsg also returns IDCMP_MOUSEMOVE messages, and it returns Delta-Values,
// not absolute values.

#define rtg_PubScreenName (rtg_Dummy+ 0x0C)

// Open a Window on a Public Screen with the provided Public Screen Name.
// Note: This does not work with all Sublibraries. Some simply ignore this
// (For example EGS...)

#define rtg_ChangeColors (rtg_Dummy+ 0x0D)

// If set, in case of a Workbench Window the Colors are REALLY changed. If
// Not set, only ObtainBestPens is done... normally not setting it is the
// best choice. If that gives you not nice looking colors, you might try
// to set it...

struct RtgDimensionInfo
{
    ULONG Width;
    ULONG Height;
};

// This structure is private and for the internal use of RtgMaster.library
// and its sub-libraries ONLY.  This structure will change in the future.

struct ScreenMode
{
    struct MinNode ScrNode;

    // ln_Succ and ln_Pred from ListNode structure

    STRPTR Name;
    STRPTR Description;

    // Description of the graphics board this mode
    // requires.  For example: "Standard Amiga Chipset".
    // Description should not be longer than 31
    // characters including terminating NULL-byte.  This
    // pointer might be zero so watch out.

    ULONG GraphicsBoard;

    // The graphics board this mode requires

    ULONG ModeID;

    // ModeID (depends on sm_GraphicsBoard)

    BYTE Reserved[8];

    // 8 bytes reserved space for use of the sub-library
    // who creates this ScreenMode structure.  This is
    // PRIVATE to the sub-library!

    ULONG MinWidth;

    // minimum width in pixels

    ULONG MaxWidth;

    // maximum width in pixels

    ULONG MinHeight;

    // Minimum height in pixels

    ULONG MaxHeight;

    // Maximum height in pixels

    struct RtgDimensionInfo Default;

    // Standard width and height of this ScreenMode

    struct RtgDimensionInfo TextOverscan;

    // Settable via preferences

    struct RtgDimensionInfo StandardOverscan;

    // Settable via preferences

    struct RtgDimensionInfo MaxOverscan;

    // Maximum width and height (without the
    // need for AutoScrolling).  Hardware
    // dependant.

    ULONG ChunkySupport;

    // This LONG is used to indicate which Chunky
    // modes this ScreenMode supports.  A set bit
    // means the mode is available.  See the
    // rtg_ChunkySupport tag for more information.
    // Note that the same ScreenMode may never
    // use two different layouts (for example BGR
    // and RGB)

    ULONG PlanarSupport;

    // This LONG is used to indicate which Planar
    // modes this ScreenMode supports.  A set bit
    // means the mode is available.  See the
    // rtg_PlanarSupport tag for more information.
    // Note that the same ScreenMode may never
    // use both interleaved and non-interleaved
    // layouts.

    ULONG PixelAspect;

    // For a PAL 320x256 screen you have to write
    // this value here:  sm_PixelAspect =
    // (320/4)/(256/3) * 65536
    //
    // This tells the relation between the height and
    // the width of a single pixel on 4:3 screen.  For
    // a 640x480 screen this value is 1*65536.

    ULONG VertScan;

    // Vertical scan rate of this screenmode
    // (in Hz)

    ULONG HorScan;

    // Horizontal scan rate of this screenmode
    // (in Hz)

    ULONG PixelClock;

    // Pixelclock rate (in Hz)

    ULONG VertBlank;

    // Vertical blank rate of this screenmode
    // (in Hz)  (How often the VBlank interupt
    // is triggered)

    ULONG Buffers;

    // The number of buffers this ScreenMode can
    // can handle.  This should always be atleast
    // 1, 2 if the Screen can do double-buffering
    // and 3 if it can do triple-buffering.

    UWORD BitsRed;

    // The number of bits per gun for Red

    UWORD BitsGreen;

    // The number of bits per gun for Green

    UWORD BitsBlue;

    // The number of bits per gun for Blue
};

// The TagItem ID's (ti_Tag values) for GetRtgScreenData()

// These tags are used to return data to the user about the RtgScreen
// structure in a future compatible way.

#define grd_Dummy TAG_USER

#define grd_Width (grd_Dummy + 0x01)

// Gets you the Width in pixels of the screen

#define grd_Height (grd_Dummy + 0x02)

// Gets you the Height in pixels of the screen

#define grd_PixelLayout (grd_Dummy + 0x03)

// Gets you the pixellayout of the screen, see
// defines below.  This also tells you whether
// the screen is Chunky or Planar

#define grd_ColorSpace (grd_Dummy + 0x04)

// Gets you the colorspace of the screen, see
// defines below

#define grd_Depth (grd_Dummy + 0x05)

// The number of colors LOG 2.  For Planar modes
// this also tells you the number of bitplanes.
// Don't rely on this number except to get the
// number of colors for Chunky modes.

#define grd_PlaneSize (grd_Dummy + 0x06)

// Tells you the number of bytes to skip to get
// to the next (bit)plane.  You can use this to
// find the start addresses of the other (bit)planes
// in Planar and in (BytePlane) Chunky modes

#define grd_BytesPerRow (grd_Dummy + 0x07)

// The number of bytes taken up by a row.  This
// refers to one (bit/byte)plane only for modes
// working with planes.

#define grd_MouseX (grd_Dummy + 0x08)

// Finds out the Mouse X position

#define grd_MouseY (grd_Dummy + 0x09)

// Finds out the Mouse Y position

// The TagItem ID's (ti_Tag values) for GetGfxCardData()

// These tags are used to return data to the user about the graphics card
// which the RtgScreen uses.

#define grd_BusSystem (grd_Dummy + 0x0A)

#define grd_3DChipset (grd_Dummy + 0x0B)

#define grd_Bitmap (grd_Dummy + 0x0C)

#define grd_ScrollVPort (grd_Dummy + 0x0D)

#define grd_Screen (grd_Dummy + 0x0E)

#define grd_Window (grd_Dummy + 0x0F)

// For usage with the rtgmaster 3D Extensions, will be ignored from sublibraries
// that do not support the 3D Extensions.

#define grd_Z3 1 // Zorro III Bus
#define grd_Z2 2 // Zorro II Bus
#define grd_Custom 3 // Custom Chipset
#define grd_RGBPort 4 // Board connected to RGB Port
#define grd_GVP 5 // GVP "special" Bus of GVP Turbo Board (EGS110 GFX Board)
#define grd_DDirect 6 // DraCo Direct Bus
#define grd_Ateo 7 // Ateo Bus
#define grd_PCI 8 // PCI

// defines for grd_PixelLayout

#define grd_PLANAR     0 // Non interleaved planar layout [X bitplanes/pixel]
#define grd_PLANARI    1 // Interleaved planar layout     [X bitplanes/pixel]
#define grd_CHUNKY     2 // 8-bit Chunky layout           [BYTE/pixel]
#define grd_HICOL15    3 // 15-bit Chunky layout          [WORD/pixel]
#define grd_HICOL16    4 // 16-bit Chunky layout          [WORD/pixel]
#define grd_TRUECOL24  5 // 24-bit Chunky layout          [3 BYTES/pixel]
#define grd_TRUECOL24P 6 // 24-bit Chunky layout          [3 BYTEPLANES/pixel]
#define grd_TRUECOL32  7 // 24-bit Chunky layout          [LONG/pixel]
#define grd_GRAFFITI   8 // 8-bit Graffiti-type Chunky layout (very special...)
#define grd_TRUECOL32B 9

// defines for grd_ColorSpace

#define grd_Palette 0 // Mode uses a Color Look-Up Table (CLUT)
#define grd_RGB     1 // Standard RGB color space
#define grd_BGR     2 // high-endian RGB color space, BGR
#define grd_RGBPC   3 // RGB with lowbyte and highbyte swapped
#define grd_BGRPC   4 // BGR with lowbyte and highbyte swapped

// End of GetRtgScreenData() enumeration ***


// Information about the RtgScreenModeReq tags:
//
// Each tag specified for the RtgScreenModeReq() function limits in some
// way the number of ScreenModes available to the user.  Sometimes this
// means a screenmode is completely ommited, and sometimes this means
// certain screenmodes can only be used if the user selects them to
// be wide enough.  So for example, a ScreenMode which supports screens
// of 300 to 400 pixels in width, could be filtered out completely by
// setting smr_MinWidth to 401.  But if the smr_MinWidth is set to for
// example 320 then the user is allowed to select a width of 320-400
// pixels (for this ScreenMode, and if the smr_MaxWidth allows this).
// If smr_MinWidth is 200 pixels then the ScreenMode is the limiting
// factor which means the user can't select ScreenModes smaller than
// 300 pixels.
//
// The PlanarSupport and ChunkySupport tags determine which ScreenModes
// are available to the user depending on their layout and number of
// colors.
// This structure is private and for the internal use of RtgMaster.library
// and its sub-libraries ONLY.  This structure will change in the future.

struct ScreenReq
{
    struct ScreenMode *ScreenMode;

    // Ptr to ScreenMode structure

    ULONG Width;

    // Must be within Tag specified limits

    ULONG Height;

    // The width and height which the user selected

    UWORD Depth;

    // Number of colors log2 which the user selected
    UWORD Overscan;

    // 0 = No Overscan.  See defines below.

    UBYTE Flags; // For the meaning of the bits see below
};

struct ScreenReqList
{
 struct MinNode SRNode;
 struct ScreenReq *req;
};

// Bits set in ScreenMode.Flags

#define sq_EHB          (1 << 0)   // EHB selected (sq_Depth = 6)
#define sq_CHUNKYMODE   (1 << 1)   // Chunky Mode selected
#define sq_DEFAULTX     (1 << 2)   // Default Width selected
#define sq_DEFAULTY     (1 << 3)   // Default Height selected
#define sq_WORKBENCH    (1 << 4)   // User wants to use Workbench Window

// defines for Overscan

#define sq_NOOVERSCAN       0
#define sq_TEXTOVERSCAN     1 // User settable, should be entirely visible
#define sq_STANDARDOVERSCAN 2 // Standard overscan (just past edges)
#define sq_MAXOVERSCAN      3 // Maximum overscan (as much as possible)

// This structure is private and for the internal use of RtgMaster.library
// and its sub-libraries ONLY.  This structure will change in the future.

struct RtgScreen
{
    ULONG LibBase;
    UWORD LibVersion;
    UWORD Pad1;
    ULONG GraphicsBoard;
    BYTE  Reserved[20];
    ULONG MouseX;
    ULONG MouseY;
    APTR  c2pcode;
    APTR  c2pdata;
    ULONG c2pcurr;
    BYTE  c2pname[30];
};

#endif

