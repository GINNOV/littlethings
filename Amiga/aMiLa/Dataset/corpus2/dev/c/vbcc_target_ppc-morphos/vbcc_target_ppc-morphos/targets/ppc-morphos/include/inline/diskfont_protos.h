#ifndef _VBCCINLINE_DISKFONT_H
#define _VBCCINLINE_DISKFONT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct TextFont * __OpenDiskFont(void *, struct TextAttr * textAttr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define OpenDiskFont(textAttr) __OpenDiskFont(DiskfontBase, (textAttr))

LONG __AvailFonts(void *, STRPTR buffer, LONG bufBytes, LONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AvailFonts(buffer, bufBytes, flags) __AvailFonts(DiskfontBase, (buffer), (bufBytes), (flags))

struct FontContentsHeader * __NewFontContents(void *, BPTR fontsLock, STRPTR fontName) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define NewFontContents(fontsLock, fontName) __NewFontContents(DiskfontBase, (fontsLock), (fontName))

VOID __DisposeFontContents(void *, struct FontContentsHeader * fontContentsHeader) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define DisposeFontContents(fontContentsHeader) __DisposeFontContents(DiskfontBase, (fontContentsHeader))

struct DiskFont * __NewScaledDiskFont(void *, struct TextFont * sourceFont, struct TextAttr * destTextAttr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define NewScaledDiskFont(sourceFont, destTextAttr) __NewScaledDiskFont(DiskfontBase, (sourceFont), (destTextAttr))

LONG __GetDiskFontCtrl(void *, LONG tagid) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define GetDiskFontCtrl(tagid) __GetDiskFontCtrl(DiskfontBase, (tagid))

VOID __SetDiskFontCtrlA(void *, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define SetDiskFontCtrlA(taglist) __SetDiskFontCtrlA(DiskfontBase, (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __SetDiskFontCtrl(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define SetDiskFontCtrl(...) __SetDiskFontCtrl(DiskfontBase, __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_DISKFONT_H  */
