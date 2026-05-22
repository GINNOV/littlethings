#ifndef _INLINE_CYBERGRAPHICS_H
#define _INLINE_CYBERGRAPHICS_H

#ifndef CYBERGRAPHICS_BASE_NAME
#define CYBERGRAPHICS_BASE_NAME CyberGfxBase
#endif

#define IsCyberModeID(displayID) \
	((BOOL (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 54))(displayID, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#define BestCModeIDTagList(BestModeIDTags) \
	((ULONG (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 60))(BestModeIDTags, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define BestCModeIDTags(tags...) \
	({ULONG _tags[] = {tags}; BestCModeIDTagList((Tag) _tags);})
#endif

#define CModeRequestTagList(ModeRequest, ModeRequestTags) \
	((ULONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 66))(ModeRequest, ModeRequestTags, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define CModeRequestTags(ModeRequest, tags...) \
	({ULONG _tags[] = {tags}; CModeRequestTagList((ModeRequest), (Tag) _tags);})
#endif

#define AllocCModeListTagList(ModeListTags) \
	((struct List * (*)(struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 72))(ModeListTags, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AllocCModeListTags(tags...) \
	({ULONG _tags[] = {tags}; AllocCModeListTagList((Tag) _tags);})
#endif

#define FreeCModeList(ModeList) \
	((void (*)(struct List * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 78))(ModeList, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#define ScalePixelArray(srcRect, SrcW, SrcH, SrcMod, RastPort, DestX, DestY, DestW, DestH, SrcFormat) \
	((LONG (*)(APTR __asm("a0"), UWORD __asm("d0"), UWORD __asm("d1"), UWORD __asm("d2"), struct RastPort * __asm("a1"), UWORD __asm("d3"), UWORD __asm("d4"), UWORD __asm("d5"), UWORD __asm("d6"), UBYTE __asm("d7"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 90))(srcRect, SrcW, SrcH, SrcMod, RastPort, DestX, DestY, DestW, DestH, SrcFormat, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#define GetCyberMapAttr(CyberGfxBitmap, CyberAttrTag) \
	((ULONG (*)(struct BitMap * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 96))(CyberGfxBitmap, CyberAttrTag, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#define GetCyberIDAttr(CyberIDAttr, CyberDisplayModeID) \
	((ULONG (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 102))(CyberIDAttr, CyberDisplayModeID, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#define ReadRGBPixel(RastPort, x, y) \
	((ULONG (*)(struct RastPort * __asm("a1"), UWORD __asm("d0"), UWORD __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 108))(RastPort, x, y, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#define WriteRGBPixel(RastPort, x, y, argb) \
	((LONG (*)(struct RastPort * __asm("a1"), UWORD __asm("d0"), UWORD __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 114))(RastPort, x, y, argb, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#define ReadPixelArray(destRect, destX, destY, destMod, RastPort, SrcX, SrcY, SizeX, SizeY, DestFormat) \
	((ULONG (*)(APTR __asm("a0"), UWORD __asm("d0"), UWORD __asm("d1"), UWORD __asm("d2"), struct RastPort * __asm("a1"), UWORD __asm("d3"), UWORD __asm("d4"), UWORD __asm("d5"), UWORD __asm("d6"), UBYTE __asm("d7"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 120))(destRect, destX, destY, destMod, RastPort, SrcX, SrcY, SizeX, SizeY, DestFormat, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#define WritePixelArray(srcRect, SrcX, SrcY, SrcMod, RastPort, DestX, DestY, SizeX, SizeY, SrcFormat) \
	((ULONG (*)(APTR __asm("a0"), UWORD __asm("d0"), UWORD __asm("d1"), UWORD __asm("d2"), struct RastPort * __asm("a1"), UWORD __asm("d3"), UWORD __asm("d4"), UWORD __asm("d5"), UWORD __asm("d6"), UBYTE __asm("d7"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 126))(srcRect, SrcX, SrcY, SrcMod, RastPort, DestX, DestY, SizeX, SizeY, SrcFormat, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#define MovePixelArray(SrcX, SrcY, RastPort, DestX, DestY, SizeX, SizeY) \
	((ULONG (*)(UWORD __asm("d0"), UWORD __asm("d1"), struct RastPort * __asm("a1"), UWORD __asm("d2"), UWORD __asm("d3"), UWORD __asm("d4"), UWORD __asm("d5"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 132))(SrcX, SrcY, RastPort, DestX, DestY, SizeX, SizeY, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#define InvertPixelArray(RastPort, DestX, DestY, SizeX, SizeY) \
	((ULONG (*)(struct RastPort * __asm("a1"), UWORD __asm("d0"), UWORD __asm("d1"), UWORD __asm("d2"), UWORD __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 144))(RastPort, DestX, DestY, SizeX, SizeY, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#define FillPixelArray(RastPort, DestX, DestY, SizeX, SizeY, ARGB) \
	((ULONG (*)(struct RastPort * __asm("a1"), UWORD __asm("d0"), UWORD __asm("d1"), UWORD __asm("d2"), UWORD __asm("d3"), ULONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 150))(RastPort, DestX, DestY, SizeX, SizeY, ARGB, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#define DoCDrawMethodTagList(Hook, RastPort, TagList) \
	((void (*)(struct Hook * __asm("a0"), struct RastPort * __asm("a1"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 156))(Hook, RastPort, TagList, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define DoCDrawMethodTags(Hook, RastPort, tags...) \
	({ULONG _tags[] = {tags}; DoCDrawMethodTagList((Hook), (RastPort), (Tag) _tags);})
#endif

#define CVideoCtrlTagList(ViewPort, TagList) \
	((void (*)(struct ViewPort * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 162))(ViewPort, TagList, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define CVideoCtrlTags(ViewPort, tags...) \
	({ULONG _tags[] = {tags}; CVideoCtrlTagList((ViewPort), (Tag) _tags);})
#endif

#define LockBitMapTagList(BitMap, TagList) \
	((APTR (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 168))(BitMap, TagList, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define LockBitMapTags(BitMap, tags...) \
	({ULONG _tags[] = {tags}; LockBitMapTagList((BitMap), (Tag) _tags);})
#endif

#define UnLockBitMap(Handle) \
	((void (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 174))(Handle, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#define UnLockBitMapTagList(Handle, TagList) \
	((void (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 180))(Handle, TagList, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define UnLockBitMapTags(Handle, tags...) \
	({ULONG _tags[] = {tags}; UnLockBitMapTagList((Handle), (Tag) _tags);})
#endif

#define ExtractColor(RastPort, BitMap, Colour, SrcX, SrcY, Width, Height) \
	((ULONG (*)(struct RastPort * __asm("a0"), struct BitMap * __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 186))(RastPort, BitMap, Colour, SrcX, SrcY, Width, Height, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#define WriteLUTPixelArray(srcRect, SrcX, SrcY, SrcMod, RastPort, ColorTab, DestX, DestY, SizeX, SizeY, CTFormat) \
	((ULONG (*)(APTR __asm("a0"), UWORD __asm("d0"), UWORD __asm("d1"), UWORD __asm("d2"), struct RastPort * __asm("a1"), APTR __asm("a2"), UWORD __asm("d3"), UWORD __asm("d4"), UWORD __asm("d5"), UWORD __asm("d6"), UBYTE __asm("d7"), struct Library * __asm("a6"))) \
  (((char *) CYBERGRAPHICS_BASE_NAME) - 198))(srcRect, SrcX, SrcY, SrcMod, RastPort, ColorTab, DestX, DestY, SizeX, SizeY, CTFormat, (struct Library *) CYBERGRAPHICS_BASE_NAME)

#endif /*  _INLINE_CYBERGRAPHICS_H  */
