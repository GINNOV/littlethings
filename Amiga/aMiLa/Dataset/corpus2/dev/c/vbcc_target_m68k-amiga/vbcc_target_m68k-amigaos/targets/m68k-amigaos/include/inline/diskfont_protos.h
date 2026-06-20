#ifndef _VBCCINLINE_DISKFONT_H
#define _VBCCINLINE_DISKFONT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

struct TextFont * __OpenDiskFont(__reg("a6") void *, __reg("a0") struct TextAttr * textAttr)="\tjsr\t-30(a6)";
#define OpenDiskFont(textAttr) __OpenDiskFont(DiskfontBase, (textAttr))

LONG __AvailFonts(__reg("a6") void *, __reg("a0") struct AvailFontsHeader * buffer, __reg("d0") LONG bufBytes, __reg("d1") ULONG flags)="\tjsr\t-36(a6)";
#define AvailFonts(buffer, bufBytes, flags) __AvailFonts(DiskfontBase, (buffer), (bufBytes), (flags))

struct FontContentsHeader * __NewFontContents(__reg("a6") void *, __reg("a0") void * fontsLock, __reg("a1") CONST_STRPTR fontName)="\tjsr\t-42(a6)";
#define NewFontContents(fontsLock, fontName) __NewFontContents(DiskfontBase, (void *)(fontsLock), (fontName))

VOID __DisposeFontContents(__reg("a6") void *, __reg("a1") struct FontContentsHeader * fontContentsHeader)="\tjsr\t-48(a6)";
#define DisposeFontContents(fontContentsHeader) __DisposeFontContents(DiskfontBase, (fontContentsHeader))

struct DiskFont * __NewScaledDiskFont(__reg("a6") void *, __reg("a0") struct TextFont * sourceFont, __reg("a1") struct TextAttr * destTextAttr)="\tjsr\t-54(a6)";
#define NewScaledDiskFont(sourceFont, destTextAttr) __NewScaledDiskFont(DiskfontBase, (sourceFont), (destTextAttr))

LONG __GetDiskFontCtrl(__reg("a6") void *, __reg("d0") LONG tagid)="\tjsr\t-60(a6)";
#define GetDiskFontCtrl(tagid) __GetDiskFontCtrl(DiskfontBase, (tagid))

VOID __SetDiskFontCtrlA(__reg("a6") void *, __reg("a0") CONST struct TagItem * taglist)="\tjsr\t-66(a6)";
#define SetDiskFontCtrlA(taglist) __SetDiskFontCtrlA(DiskfontBase, (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __SetDiskFontCtrl(__reg("a6") void *, Tag taglist, ...)="\tmove.l\ta0,-(a7)\n\tlea\t4(a7),a0\n\tjsr\t-66(a6)\n\tmovea.l\t(a7)+,a0";
#define SetDiskFontCtrl(...) __SetDiskFontCtrl(DiskfontBase, __VA_ARGS__)
#endif

LONG __EOpenEngine(__reg("a6") void *, __reg("a0") struct EGlyphEngine * EEngine)="\tjsr\t-72(a6)";
#define EOpenEngine(EEngine) __EOpenEngine(DiskfontBase, (EEngine))

VOID __ECloseEngine(__reg("a6") void *, __reg("a0") struct EGlyphEngine * EEngine)="\tjsr\t-78(a6)";
#define ECloseEngine(EEngine) __ECloseEngine(DiskfontBase, (EEngine))

ULONG __ESetInfoA(__reg("a6") void *, __reg("a0") struct EGlyphEngine * EEngine, __reg("a1") CONST struct TagItem * taglist)="\tjsr\t-84(a6)";
#define ESetInfoA(EEngine, taglist) __ESetInfoA(DiskfontBase, (EEngine), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __ESetInfo(__reg("a6") void *, __reg("a0") struct EGlyphEngine * EEngine, ...)="\tmove.l\ta1,-(a7)\n\tlea\t4(a7),a1\n\tjsr\t-84(a6)\n\tmovea.l\t(a7)+,a1";
#define ESetInfo(...) __ESetInfo(DiskfontBase, __VA_ARGS__)
#endif

ULONG __EObtainInfoA(__reg("a6") void *, __reg("a0") struct EGlyphEngine * EEngine, __reg("a1") CONST struct TagItem * taglist)="\tjsr\t-90(a6)";
#define EObtainInfoA(EEngine, taglist) __EObtainInfoA(DiskfontBase, (EEngine), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __EObtainInfo(__reg("a6") void *, __reg("a0") struct EGlyphEngine * EEngine, ...)="\tmove.l\ta1,-(a7)\n\tlea\t4(a7),a1\n\tjsr\t-90(a6)\n\tmovea.l\t(a7)+,a1";
#define EObtainInfo(...) __EObtainInfo(DiskfontBase, __VA_ARGS__)
#endif

ULONG __EReleaseInfoA(__reg("a6") void *, __reg("a0") struct EGlyphEngine * EEngine, __reg("a1") CONST struct TagItem * taglist)="\tjsr\t-96(a6)";
#define EReleaseInfoA(EEngine, taglist) __EReleaseInfoA(DiskfontBase, (EEngine), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __EReleaseInfo(__reg("a6") void *, __reg("a0") struct EGlyphEngine * EEngine, ...)="\tmove.l\ta1,-(a7)\n\tlea\t4(a7),a1\n\tjsr\t-96(a6)\n\tmovea.l\t(a7)+,a1";
#define EReleaseInfo(...) __EReleaseInfo(DiskfontBase, __VA_ARGS__)
#endif

struct OutlineFont * __OpenOutlineFont(__reg("a6") void *, __reg("a0") CONST_STRPTR name, __reg("a1") struct List * list, __reg("d0") ULONG flags)="\tjsr\t-102(a6)";
#define OpenOutlineFont(name, list, flags) __OpenOutlineFont(DiskfontBase, (name), (list), (flags))

VOID __CloseOutlineFont(__reg("a6") void *, __reg("a0") struct OutlineFont * olf, __reg("a1") struct List * list)="\tjsr\t-108(a6)";
#define CloseOutlineFont(olf, list) __CloseOutlineFont(DiskfontBase, (olf), (list))

LONG __WriteFontContents(__reg("a6") void *, __reg("a0") void * fontsLock, __reg("a1") CONST_STRPTR fontName, __reg("a2") CONST struct FontContentsHeader * fontContentsHeader)="\tjsr\t-114(a6)";
#define WriteFontContents(fontsLock, fontName, fontContentsHeader) __WriteFontContents(DiskfontBase, (void *)(fontsLock), (fontName), (fontContentsHeader))

LONG __WriteDiskFontHeaderA(__reg("a6") void *, __reg("a0") CONST struct TextFont * font, __reg("a1") CONST_STRPTR fileName, __reg("a2") CONST struct TagItem * tagList)="\tjsr\t-120(a6)";
#define WriteDiskFontHeaderA(font, fileName, tagList) __WriteDiskFontHeaderA(DiskfontBase, (font), (fileName), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __WriteDiskFontHeader(__reg("a6") void *, __reg("a0") CONST struct TextFont * font, __reg("a1") CONST_STRPTR fileName, ...)="\tmove.l\ta2,-(a7)\n\tlea\t4(a7),a2\n\tjsr\t-120(a6)\n\tmovea.l\t(a7)+,a2";
#define WriteDiskFontHeader(font, ...) __WriteDiskFontHeader(DiskfontBase, (font), __VA_ARGS__)
#endif

ULONG __ObtainCharsetInfo(__reg("a6") void *, __reg("d0") ULONG knownTag, __reg("d1") ULONG knownValue, __reg("d2") ULONG wantedTag)="\tjsr\t-126(a6)";
#define ObtainCharsetInfo(knownTag, knownValue, wantedTag) __ObtainCharsetInfo(DiskfontBase, (knownTag), (knownValue), (wantedTag))

#endif /*  _VBCCINLINE_DISKFONT_H  */
