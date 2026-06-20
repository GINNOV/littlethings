/*
 *   GCC interfaces for cybergraphics.library.
 *   Use it for generating lib files or for direct inclusion.
 *   Based on the output of 'FD2Inline' (12/04/95)
 *
 *   Reinhard Haslbeck
 *   (haslbeck@informatik.tu-muenchen.de)
*/

#include <sys/cdefs.h>
#include <inline/stubs.h>

#include <stdarg.h>
#include <libraries/cybergraphics.h>
__BEGIN_DECLS

#ifndef BASE_EXT_DECL
#define BASE_EXT_DECL extern struct Library*  CyberGfxBase;
#endif
#ifndef BASE_PAR_DECL
#define BASE_PAR_DECL
#define BASE_PAR_DECL0 void
#endif
#ifndef BASE_NAME
#define BASE_NAME CyberGfxBase
#endif

static __inline struct List  *AllocCModeTagList( BASE_PAR_DECL struct TagItem *  ModeListTags )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register struct TagItem * a1 __asm("a1");

        a6 = BASE_NAME;
        a1 = ModeListTags;
        __asm __volatile ("jsr a6@(-0x48)"
        : "=r" (_res)
        : "r" (a6), "r" (a1)
        : "d0", "d1", "a0", "a1" );
        return (struct List *) _res;
}
#ifndef NO_INLINE_STDARG
#define AllocCModeListTags( tags...) \
  ({ struct TagItem _tags[] = { tags };  AllocCModeTagList( _tags ); })
#endif /* not NO_INLINE_STDARG */

static __inline ULONG BestCModeIDTagList( BASE_PAR_DECL struct TagItem *  BestModeIDTags )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register struct TagItem * a0 __asm("a0");

        a6 = BASE_NAME;
        a0 = BestModeIDTags;
        __asm __volatile ("jsr a6@(-0x3c)"
        : "=r" (_res)
        : "r" (a6), "r" (a0)
        : "d0", "d1", "a0", "a1" );
        return _res;
}
#ifndef NO_INLINE_STDARG
#define BestCModeIDTags( tags...) \
  ({ struct TagItem _tags[] = { tags }; BestCModeIDTagList ( _tags ); })
#endif /* not NO_INLINE_STDARG */
static __inline ULONG CModeRequestTagList( BASE_PAR_DECL APTR  ModeRequest, struct TagItem *  ModeRequestTags )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register APTR a0 __asm("a0");
        register struct TagItem * a1 __asm("a1");

        a6 = BASE_NAME;
        a0 = ModeRequest;
        a1 = ModeRequestTags;
        __asm __volatile ("jsr a6@(-0x42)"
        : "=r" (_res)
        : "r" (a6), "r" (a0), "r" (a1)
        : "d0", "d1", "a0", "a1" );
        return _res;
}
#ifndef NO_INLINE_STDARG
#define CModeRequestTags(a0, tags...) \
  ({ struct TagItem _tags[] = { tags }; CModeRequestTagList ((a0), _tags); })
#endif /* not NO_INLINE_STDARG */

static __inline void CVideoCtrlTagList( BASE_PAR_DECL struct ViewPort *  ViewPort, struct TagItem *  TagList )
{
        BASE_EXT_DECL
        register void *a6 __asm("a6");
        register struct ViewPort * a0 __asm("a0");
        register struct TagItem * a1 __asm("a1");

        a6 = BASE_NAME;
        a0 = ViewPort;
        a1 = TagList;
        __asm __volatile ("jsr a6@(-0xa2)"
        :
        : "r" (a6), "r" (a0), "r" (a1)
        : "d0", "d1", "a0", "a1" );
}
#ifndef NO_INLINE_STDARG
#define CVideoCtrlTags(a0, tags...) \
  ({ struct TagItem _tags[] = { tags }; CVideoCtrlTagList ((a0), _tags); })
#endif /* not NO_INLINE_STDARG */

static __inline void DoCDrawMethodTagList( BASE_PAR_DECL struct Hook *  Hook, struct RastPort *  RastPort, struct TagItem *  TagList )
{
        BASE_EXT_DECL
        register void *a6 __asm("a6");
        register struct Hook * a0 __asm("a0");
        register struct RastPort * a1 __asm("a1");
        register struct TagItem * a2 __asm("a2");

        a6 = BASE_NAME;
        a0 = Hook;
        a1 = RastPort;
        a2 = TagList;
        __asm __volatile ("jsr a6@(-0x9c)"
        :
        : "r" (a6), "r" (a0), "r" (a1), "r" (a2)
        : "d0", "d1", "a0", "a1", "a2" );
}
#ifndef NO_INLINE_STDARG
#define DoCDrawMethodTags(a0, a1, tags...) \
  ({ struct TagItem _tags[] = { tags }; DoCDrawMethodTagList ((a0), (a1), _tags); })
#endif /* not NO_INLINE_STDARG */

static __inline ULONG FillPixelArray( BASE_PAR_DECL struct RastPort *  RastPort, UWORD  DestX, UWORD  DestY, UWORD  SizeX, UWORD  SizeY, ULONG  ARGB )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register struct RastPort * a1 __asm("a1");
        register UWORD d0 __asm("d0");
        register UWORD d1 __asm("d1");
        register UWORD d2 __asm("d2");
        register UWORD d3 __asm("d3");
        register ULONG d4 __asm("d4");

        a6 = BASE_NAME;
        a1 = RastPort;
        d0 = DestX;
        d1 = DestY;
        d2 = SizeX;
        d3 = SizeY;
        d4 = ARGB;
        __asm __volatile ("jsr a6@(-0x96)"
        : "=r" (_res)
        : "r" (a6), "r" (a1), "r" (d0), "r" (d1), "r" (d2), "r" (d3), "r" (d4)
        : "d0", "d1", "a0", "a1", "d2", "d3", "d4" );
        return _res;
}
static __inline void FreeCModeList( BASE_PAR_DECL struct List *  ModeList )
{
        BASE_EXT_DECL
        register void *a6 __asm("a6");
        register struct List * a0 __asm("a0");

        a6 = BASE_NAME;
        a0 = ModeList;
        __asm __volatile ("jsr a6@(-0x4e)"
        :
        : "r" (a6), "r" (a0)
        : "d0", "d1", "a0", "a1" );
}
static __inline ULONG GetCyberIDAttr( BASE_PAR_DECL ULONG  CyberIDAttr, ULONG  CyberDisplayModeID )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register ULONG d0 __asm("d0");
        register ULONG d1 __asm("d1");

        a6 = BASE_NAME;
        d0 = CyberIDAttr;
        d1 = CyberDisplayModeID;
        __asm __volatile ("jsr a6@(-0x66)"
        : "=r" (_res)
        : "r" (a6), "r" (d0), "r" (d1)
        : "d0", "d1", "a0", "a1" );
        return _res;
}
static __inline ULONG GetCyberMapAttr( BASE_PAR_DECL struct BitMap *  CyberGfxBitmap, ULONG  CyberAttrTag )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register struct BitMap * a0 __asm("a0");
        register ULONG d0 __asm("d0");

        a6 = BASE_NAME;
        a0 = CyberGfxBitmap;
        d0 = CyberAttrTag;
        __asm __volatile ("jsr a6@(-0x60)"
        : "=r" (_res)
        : "r" (a6), "r" (a0), "r" (d0)
        : "d0", "d1", "a0", "a1" );
        return _res;
}
static __inline ULONG InvertPixelArray( BASE_PAR_DECL struct RastPort *  RastPort, UWORD  DestX, UWORD  DestY, UWORD  SizeX, UWORD  SizeY )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register struct RastPort * a1 __asm("a1");
        register UWORD d0 __asm("d0");
        register UWORD d1 __asm("d1");
        register UWORD d2 __asm("d2");
        register UWORD d3 __asm("d3");

        a6 = BASE_NAME;
        a1 = RastPort;
        d0 = DestX;
        d1 = DestY;
        d2 = SizeX;
        d3 = SizeY;
        __asm __volatile ("jsr a6@(-0x90)"
        : "=r" (_res)
        : "r" (a6), "r" (a1), "r" (d0), "r" (d1), "r" (d2), "r" (d3)
        : "d0", "d1", "a0", "a1", "d2", "d3" );
        return _res;
}
static __inline BOOL IsCyberModeID( BASE_PAR_DECL ULONG  displayID )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register ULONG d0 __asm("d0");

        a6 = BASE_NAME;
        d0 = displayID;
        __asm __volatile ("jsr a6@(-0x36)"
        : "=r" (_res)
        : "r" (a6), "r" (d0)
        : "d0", "d1", "a0", "a1" );
        return _res;
}
static __inline APTR LockBitMapTagList( BASE_PAR_DECL APTR  BitMap, struct TagItem *  TagList )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register APTR a0 __asm("a0");
        register struct TagItem * a1 __asm("a1");

        a6 = BASE_NAME;
        a0 = BitMap;
        a1 = TagList;
        __asm __volatile ("jsr a6@(-0xa8)"
        : "=r" (_res)
        : "r" (a6), "r" (a0), "r" (a1)
        : "d0", "d1", "a0", "a1" );
        return (APTR) _res;
}
#ifndef NO_INLINE_STDARG
#define LockBitMapTags(a0, tags...) \
  ({ struct TagItem _tags[] = { tags }; LockBitMapTagList ((a0), _tags); })
#endif /* not NO_INLINE_STDARG */

static __inline ULONG MovePixelArray( BASE_PAR_DECL UWORD  SrcX, UWORD  SrcY, struct RastPort *  RastPort, UWORD  DestX, UWORD  DestY, UWORD  SizeX, UWORD  SizeY )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register UWORD d0 __asm("d0");
        register UWORD d1 __asm("d1");
        register struct RastPort * a1 __asm("a1");
        register UWORD d2 __asm("d2");
        register UWORD d3 __asm("d3");
        register UWORD d4 __asm("d4");
        register UWORD d5 __asm("d5");

        a6 = BASE_NAME;
        d0 = SrcX;
        d1 = SrcY;
        a1 = RastPort;
        d2 = DestX;
        d3 = DestY;
        d4 = SizeX;
        d5 = SizeY;
        __asm __volatile ("jsr a6@(-0x84)"
        : "=r" (_res)
        : "r" (a6), "r" (d0), "r" (d1), "r" (a1), "r" (d2), "r" (d3), "r" (d4), "r" (d5)
        : "d0", "d1", "a0", "a1", "d2", "d3", "d4", "d5" );
        return _res;
}
static __inline ULONG ReadPixelArray( BASE_PAR_DECL APTR  destRect, UWORD  destX, UWORD  destY, UWORD  destMod, struct RastPort *  RastPort, UWORD  SrcX, UWORD  SrcY, UWORD  SizeX, UWORD  SizeY, UBYTE  DestFormat )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register APTR a0 __asm("a0");
        register UWORD d0 __asm("d0");
        register UWORD d1 __asm("d1");
        register UWORD d2 __asm("d2");
        register struct RastPort * a1 __asm("a1");
        register UWORD d3 __asm("d3");
        register UWORD d4 __asm("d4");
        register UWORD d5 __asm("d5");
        register UWORD d6 __asm("d6");
        register UBYTE d7 __asm("d7");

        a6 = BASE_NAME;
        a0 = destRect;
        d0 = destX;
        d1 = destY;
        d2 = destMod;
        a1 = RastPort;
        d3 = SrcX;
        d4 = SrcY;
        d5 = SizeX;
        d6 = SizeY;
        d7 = DestFormat;
        __asm __volatile ("jsr a6@(-0x78)"
        : "=r" (_res)
        : "r" (a6), "r" (a0), "r" (d0), "r" (d1), "r" (d2), "r" (a1), "r" (d3), "r" (d4), "r" (d5), "r" (d6), "r" (d7)
        : "d0", "d1", "a0", "a1", "d2", "d3", "d4", "d5", "d6", "d7" );
        return _res;
}
static __inline ULONG ReadRGBPixel( BASE_PAR_DECL struct RastPort *  RastPort, UWORD  x, UWORD  y )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register struct RastPort * a1 __asm("a1");
        register UWORD d0 __asm("d0");
        register UWORD d1 __asm("d1");

        a6 = BASE_NAME;
        a1 = RastPort;
        d0 = x;
        d1 = y;
        __asm __volatile ("jsr a6@(-0x6c)"
        : "=r" (_res)
        : "r" (a6), "r" (a1), "r" (d0), "r" (d1)
        : "d0", "d1", "a0", "a1" );
        return _res;
}
static __inline LONG ScalePixelArray( BASE_PAR_DECL APTR  srcRect, UWORD  SrcW, UWORD  SrcH, UWORD  SrcMod, struct RastPort *  RastPort, UWORD  DestX, UWORD  DestY, UWORD  DestW, UWORD  DestH, UBYTE  SrcFormat )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register APTR a0 __asm("a0");
        register UWORD d0 __asm("d0");
        register UWORD d1 __asm("d1");
        register UWORD d2 __asm("d2");
        register struct RastPort * a1 __asm("a1");
        register UWORD d3 __asm("d3");
        register UWORD d4 __asm("d4");
        register UWORD d5 __asm("d5");
        register UWORD d6 __asm("d6");
        register UBYTE d7 __asm("d7");

        a6 = BASE_NAME;
        a0 = srcRect;
        d0 = SrcW;
        d1 = SrcH;
        d2 = SrcMod;
        a1 = RastPort;
        d3 = DestX;
        d4 = DestY;
        d5 = DestW;
        d6 = DestH;
        d7 = SrcFormat;
        __asm __volatile ("jsr a6@(-0x5a)"
        : "=r" (_res)
        : "r" (a6), "r" (a0), "r" (d0), "r" (d1), "r" (d2), "r" (a1), "r" (d3), "r" (d4), "r" (d5), "r" (d6), "r" (d7)
        : "d0", "d1", "a0", "a1", "d2", "d3", "d4", "d5", "d6", "d7" );
        return _res;
}
static __inline void UnLockBitMap( BASE_PAR_DECL APTR  Handle )
{
        BASE_EXT_DECL
        register void *a6 __asm("a6");
        register APTR a0 __asm("a0");

        a6 = BASE_NAME;
        a0 = Handle;
        __asm __volatile ("jsr a6@(-0xae)"
        :
        : "r" (a6), "r" (a0)
        : "d0", "d1", "a0", "a1" );
}
static __inline ULONG WritePixelArray( BASE_PAR_DECL APTR  srcRect, UWORD  SrcX, UWORD  SrcY, UWORD  SrcMod, struct RastPort *  RastPort, UWORD  DestX, UWORD  DestY, UWORD  SizeX, UWORD  SizeY, UBYTE  SrcFormat )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register APTR a0 __asm("a0");
        register UWORD d0 __asm("d0");
        register UWORD d1 __asm("d1");
        register UWORD d2 __asm("d2");
        register struct RastPort * a1 __asm("a1");
        register UWORD d3 __asm("d3");
        register UWORD d4 __asm("d4");
        register UWORD d5 __asm("d5");
        register UWORD d6 __asm("d6");
        register UBYTE d7 __asm("d7");

        a6 = BASE_NAME;
        a0 = srcRect;
        d0 = SrcX;
        d1 = SrcY;
        d2 = SrcMod;
        a1 = RastPort;
        d3 = DestX;
        d4 = DestY;
        d5 = SizeX;
        d6 = SizeY;
        d7 = SrcFormat;
        __asm __volatile ("jsr a6@(-0x7e)"
        : "=r" (_res)
        : "r" (a6), "r" (a0), "r" (d0), "r" (d1), "r" (d2), "r" (a1), "r" (d3), "r" (d4), "r" (d5), "r" (d6), "r" (d7)
        : "d0", "d1", "a0", "a1", "d2", "d3", "d4", "d5", "d6", "d7" );
        return _res;
}
static __inline LONG WriteRGBPixel( BASE_PAR_DECL struct RastPort *  RastPort, UWORD  x, UWORD  y, ULONG  argb )
{
        BASE_EXT_DECL
        register _res __asm("d0");
        register void *a6 __asm("a6");
        register struct RastPort * a1 __asm("a1");
        register UWORD d0 __asm("d0");
        register UWORD d1 __asm("d1");
        register ULONG d2 __asm("d2");

        a6 = BASE_NAME;
        a1 = RastPort;
        d0 = x;
        d1 = y;
        d2 = argb;
        __asm __volatile ("jsr a6@(-0x72)"
        : "=r" (_res)
        : "r" (a6), "r" (a1), "r" (d0), "r" (d1), "r" (d2)
        : "d0", "d1", "a0", "a1", "d2" );
        return _res;
}

#undef BASE_EXT_DECL
#undef BASE_PAR_DECL
#undef BASE_PAR_DECL0
#undef BASE_NAME

__END_DECLS

