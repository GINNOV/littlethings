#ifndef _INLINE_DISKFONT_H
#define _INLINE_DISKFONT_H

#ifndef DISKFONT_BASE_NAME
#define DISKFONT_BASE_NAME DiskfontBase
#endif

#define OpenDiskFont(textAttr) \
	((struct TextFont * (*)(struct TextAttr * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) DISKFONT_BASE_NAME) - 30))(textAttr, (struct Library *) DISKFONT_BASE_NAME)

#define AvailFonts(buffer, bufBytes, flags) \
	((LONG (*)(STRPTR __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) DISKFONT_BASE_NAME) - 36))(buffer, bufBytes, flags, (struct Library *) DISKFONT_BASE_NAME)

#define NewFontContents(fontsLock, fontName) \
	((struct FontContentsHeader * (*)(BPTR __asm("a0"), STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) DISKFONT_BASE_NAME) - 42))(fontsLock, fontName, (struct Library *) DISKFONT_BASE_NAME)

#define DisposeFontContents(fontContentsHeader) \
	((VOID (*)(struct FontContentsHeader * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) DISKFONT_BASE_NAME) - 48))(fontContentsHeader, (struct Library *) DISKFONT_BASE_NAME)

#define NewScaledDiskFont(sourceFont, destTextAttr) \
	((struct DiskFont * (*)(struct TextFont * __asm("a0"), struct TextAttr * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) DISKFONT_BASE_NAME) - 54))(sourceFont, destTextAttr, (struct Library *) DISKFONT_BASE_NAME)

#define GetDiskFontCtrl(tagid) \
        ((LONG (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) DISKFONT_BASE_NAME) - 60))(tagid, (struct Library *) DISKFONT_BASE_NAME)

#define SetDiskFontCtrlA(tags) \
        ((VOID (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) DISKFONT_BASE_NAME) - 66))(tags, (struct Library *) DISKFONT_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetDiskFontCtrl(tags...) \
        ({ULONG _tags[] = {tags}; SetDiskFontCtrl(() _tags);})
#endif

#endif /*  _INLINE_DISKFONT_H  */
