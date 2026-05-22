#ifndef GRAPHICS_GFX_H
#define GRAPHICS_GFX_H
/*
**    $VER: gfx.h 53.29 (10.8.2015)
**
**    general include file for application programs
**
**    Copyright (C) 1985-2005 Hyperion Entertainment VOF and Amiga, Inc.
**        All Rights Reserved
**
**    Copyright (c) 2010 Hyperion Entertainment CVBA.
**        All Rights Reserved.
*/

#ifndef   EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef   UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

/****************************************************************************/

#ifdef __cplusplus
#ifdef __USE_AMIGAOS_NAMESPACE__
namespace AmigaOS {
#endif
extern "C" {
#endif

#ifdef __GNUC__
   #ifdef __PPC__
    #pragma pack(2)
   #endif
#elif defined(__VBCC__)
   #pragma amiga-align
#endif

/****************************************************************************/

#define BITSET 0x8000
#define BITCLR 0

struct Rectangle
{
    int16 MinX;
    int16 MinY;
    int16 MaxX;
    int16 MaxY;
};

struct Rect32
{
    int32 MinX;
    int32 MinY;
    int32 MaxX;
    int32 MaxY;
};

typedef struct tPoint
{
    int16 x;
    int16 y;
} Point;

typedef uint8 *PLANEPTR;

struct BitMap
{
    uint16   BytesPerRow;
    uint16   Rows;
    uint8    Flags;
    uint8    Depth;
    uint16   pad;
    PLANEPTR Planes[8];
};

/* This macro is obsolete as of V39. AllocBitMap() should be used for allocating
   bitmap data, since it knows about the machine's particular alignment
   restrictions.
*/
#define RASSIZE(w,h) ((uint32)(h)*( ((uint32)(w)+15)>>3&0xFFFE))

/* flags for AllocBitMap, etc. */
#define BMB_CLEAR        0
#define BMB_DISPLAYABLE  1
#define BMB_INTERLEAVED  2
#define BMB_STANDARD     3
#define BMB_MINPLANES    4
/*
 * New V45 flags follow. If this bit combination is set,
 * the AllocBitMap() friends pointer points to a tag
 * list describing further data
 */
#define BMB_HIJACKED     7 /* must be clear                 */
#define BMB_RTGTAGS      8 /* must be one for tag extension */
#define BMB_RTGCHECK     9 /* must be one for tag extension */
#define BMB_FRIENDISTAG 10 /* must be one as well           */
#define BMB_INVALID     11 /* must be clear                 */
/*
 * Flags introduced in V51 of graphics.library
 */
#define BMB_LOCKED      12 /* private */

#define BMF_CLEAR       (1L<<BMB_CLEAR)
#define BMF_DISPLAYABLE (1L<<BMB_DISPLAYABLE)
#define BMF_INTERLEAVED (1L<<BMB_INTERLEAVED)
#define BMF_STANDARD    (1L<<BMB_STANDARD)
#define BMF_MINPLANES   (1L<<BMB_MINPLANES)
#define BMF_HIJACKED    (1L<<BMB_HIJACKED)    /* aka BMF_SPECIALFMT */
#define BMF_RTGTAGS     (1L<<BMB_RTGTAGS)
#define BMF_RTGCHECK    (1L<<BMB_RTGCHECK)
#define BMF_FRIENDISTAG (1L<<BMB_FRIENDISTAG)
#define BMF_INVALID     (1L<<BMB_INVALID)
#define BMF_LOCKED      (1L<<BMB_LOCKED)

#define BMF_CHECKMASK   (BMF_HIJACKED    | BMF_RTGTAGS | BMF_RTGCHECK | \
                         BMF_FRIENDISTAG | BMF_INVALID)
#define BMF_CHECKVALUE  (BMF_RTGTAGS | BMF_RTGCHECK | BMF_FRIENDISTAG)

#define BITMAPFLAGS_ARE_EXTENDED(a) ((a & BMF_CHECKMASK) == BMF_CHECKVALUE)

/* tags for AllocBitMap */
#define BMATags_Friend                     (TAG_USER+0)
        /*
         * Specify a friend-bitmap by tags
         * Default is no friend bitmap
         */
#define BMATags_Depth                      (TAG_USER+1)
        /*
         * depth of the bitmap. Default is the
         * depth parameter of AllocBitMap
         */
#define BMATags_PixelFormat                (TAG_USER+2)
        /*
         * bitmap data format (see enPixelFormat)
         */
#define BMATags_Clear                      (TAG_USER+3)
        /*
         * clear bitmap? Default is the BMF_CLEAR
         * flag specified value.
         */
#define BMATags_Displayable                (TAG_USER+4)
        /*
         * bitmap usable for hardware?
         * Default is the BMF_DISPLAYABLE flag.
         */
#define BMATags_Private1                   (TAG_USER+5)
        /* internal use only! */
#define BMATags_NoMemory                   (TAG_USER+6)
        /*
         * do not provide memory for the bitmap,
         * just allocate the structure
         * Default is false.
         */
#define BMATags_NoSprite                   (TAG_USER+7)
        /*
         * disallow generation of a sprite
         * default is sprite enabled.
         */
#define BMATags_Private2                   (TAG_USER+8)
        /* internal use only! */
#define BMATags_Private3                   (TAG_USER+9)
        /* internal use only! */
#define BMATags_ModeWidth                  (TAG_USER+10)
        /*
         * width of the display mode in pixels.
         * Default is the width of the displayID
         * in the monitor database.
         */
#define BMATags_ModeHeight                 (TAG_USER+11)
        /*
         * height of the display mode in pixels.
         * Default is the height of the displayID
         * in the monitor database.
         */
#define BMATags_RenderFunc                 (TAG_USER+12)
        /*
         * Private. Do not use in new code.
         */
#define BMATags_SaveFunc                   (TAG_USER+13)
        /*
         * Pivate. Do not use in new code.
         */
#define BMATags_UserData                   (TAG_USER+14)
        /*
         * Private. Do not use in new code.
         */
#define BMATags_Alignment                  (TAG_USER+15)
        /*
         * specify additional alignment (power of two)
         * for the bitmap rows. If this tag is set,
         * then bitplane rows are aligned to this
         * boundary. Otherwise, the native alignment
         * restriction is provided.
         */
#define BMATags_ConstantBytesPerRow        (TAG_USER+16)
        /*
         * set with the above to enforce alignment
         * for displayable screens
         */
#define BMATags_UserPrivate                (TAG_USER+17)
        /*
         * user bitmap which will never be in
         * video memory
         */
#define BMATags_Private4                   (TAG_USER+18)
        /* internal use only! */
#define BMATags_Private5                   (TAG_USER+19)
        /* internal use only! */
#define BMATags_Private6                   (TAG_USER+20)
        /* internal use only! */
#define BMATags_Private7                   (TAG_USER+21)
        /* internal use only! */
#define BMATags_DisplayID                  (TAG_USER + 0x32)
        /* a display ID from the monitor data base
         * the system tries then to extract all necessary information
         * to build a suitable bitmap
         * This is intentionally identical to intuition SA_DisplayID
         */
#define BMATags_BitmapInvisible            (TAG_USER + 0x37)
        /* if set to TRUE, the bitmap is not allocated on the graphics
         * board directly, but may remain in an off-hardware location
         * if the screen is invisible. This is intentionally
         * identically to SA_Behind. Default is FALSE
         */
#define BMATags_BitmapColors               (TAG_USER + 0x29)
        /* ti_Data is an array of struct ColorSpec,
         * terminated by ColorIndex = -1.  Specifies
         * initial screen palette colors.
         * This is intentionally identically to SA_Colors
         */
#define BMATags_BitmapColors32             (TAG_USER + 0x43)
        /* Tag to set the bitmaps's initial palette colors
         * at 32 bits-per-gun.  ti_Data is a pointer
         * to a table to be passed to the
         * graphics.library/LoadRGB32() function.
         * This format supports both runs of color
         * registers and sparse registers.  See the
         * autodoc for that function for full details.
         * Any color set here has precedence over
         * the same register set by ABMA_BitmapColors.
         * Intentionally identical to SA_Colors32
         */

/* The following are for GetBitMapAttr() */
#define BMA_HEIGHT        0
#define BMA_DEPTH         4
#define BMA_WIDTH         8
#define BMA_FLAGS         12
#define BMA_ISRTG         16  // (V54)
#define BMA_BYTESPERPIXEL 17  // (V54)
#define BMA_BITSPERPIXEL  18  // (V54)
#define BMA_PIXELFORMAT   19  // (V54)
#define BMA_ACTUALWIDTH   20  // (V54)

/* Supported pixel formats (V54) */
enum enPixelFormat
{
    PIXF_NONE      = 0,  // no valid RGB format (error condition)

    PIXF_CLUT      = 1,  // palette mode, set colors when opening screen using
                         // tags or use SetRGB32/LoadRGB32(...)

    PIXF_R8G8B8    = 2,  // TrueColor RGB (8 bit each)

    PIXF_B8G8R8    = 3,  // TrueColor BGR (8 bit each)

    PIXF_R5G6B5PC  = 4,  // HiColor16 (5 bit R, 6 bit G, 5 bit B),
                         // format: gggbbbbbrrrrrggg

    PIXF_R5G5B5PC  = 5,  // HiColor15 (5 bit each)
                         // format: gggbbbbb0rrrrrgg

    PIXF_A8R8G8B8  = 6,  // 4 Byte TrueColor ARGB (A unused alpha channel)

    PIXF_A8B8G8R8  = 7,  // 4 Byte TrueColor ABGR (A unused alpha channel)

    PIXF_R8G8B8A8  = 8,  // 4 Byte TrueColor RGBA (A unused alpha channel)

    PIXF_B8G8R8A8  = 9,  // 4 Byte TrueColor BGRA (A unused alpha channel)

    PIXF_R5G6B5    = 10, // HiColor16 (5 bit R, 6 bit G, 5 bit B)
                         // format: rrrrrggggggbbbbb

    PIXF_R5G5B5    = 11, // HiColor15 (5 bit each)
                         // format: 0rrrrrgggggbbbbb

    PIXF_B5G6R5PC  = 12, // HiColor16 (5 bit R, 6 bit G, 5 bit B)
                         // format: gggrrrrrbbbbbggg */

    PIXF_B5G5R5PC  = 13, // HiColor15 (5 bit each)
                         // format: gggrrrrr0bbbbbbgg

    PIXF_YUV422CGX = 14, // 2 Byte TrueColor YUV (CCIR recommendation CCIR601).
                         // Each two-pixel unit is stored as one longword
                         // containing luminance (Y) for each of the two pixels,
                         // and chrominance (U,V) for alternate pixels.
                         // The missing chrominance values are generated by
                         // interpolation. (Y0-U0-Y1-V0)

    PIXF_YUV411    = 15, // 1 Byte TrueColor ACCUPAK. Four adjacent pixels form
                         // a packet of 5 bits Y (luminance) each pixel and
                         // 6 bits U and V (chrominance) shared by the four
                         // pixels

    PIXF_YUV422PA  = 16, // 2 Byte TrueColor CCIR601 for use with YUV12 planar
                         // assist mode on Cirrus Logic base graphics chips.
                         // (Y0-Y1-V0-U0)

    PIXF_YUV422    = 17, // 2 Byte TrueColor YUV (CCIR recommendation CCIR601).
                         // Each two-pixel unit is stored as one longword
                         // containing luminance (Y) for each of the two pixels,
                         // and chrominance (U,V) for alternate pixels.
                         // The missing chrominance values are generated by
                         // interpolation. (Y1-U0-Y0-V0)

    PIXF_YUV422PC  = 18, // 2 Byte TrueColor CCIR601 byte swapped (V0-Y0-U0-Y1)

    PIXF_YUV420P   = 19, // 12 Bit TrueColor 3-plane YUV

    PIXF_YUV410P   = 20, // 9 Bit TrueColor 3-plane YUV

    PIXF_ALPHA8    = 21  // 8 bit alpha
};

typedef enum enPixelFormat PIX_FMT;


/* Tags for LockBitMapTagList() (V54) */
#define LBM_TagBase       (TAG_USER)

#define LBM_BaseAddress   (LBM_TagBase + 1)
#define LBM_BytesPerRow   (LBM_TagBase + 2)
#define LBM_PixelFormat   (LBM_TagBase + 3)
#define LBM_PlanarYUVInfo (LBM_TagBase + 4)
#define LBM_IsOnBoard     (LBM_TagBase + 5)


struct PlanarYUVInfo
{
	APTR YMemory;
	APTR UMemory;
	APTR VMemory;
	uint32 YBytesPerRow;
	uint32 UBytesPerRow;
	uint32 VBytesPerRow;
};


/****************************************************************************/

#ifdef __GNUC__
   #ifdef __PPC__
    #pragma pack()
   #endif
#elif defined(__VBCC__)
   #pragma default-align
#endif


#ifdef __cplusplus
}
#ifdef __USE_AMIGAOS_NAMESPACE__
}
#endif
#endif

/****************************************************************************/

#endif /* GRAPHICS_GFX_H */
