#ifndef _VBCCINLINE_GUIGFX_H
#define _VBCCINLINE_GUIGFX_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __MakePictureA(void *, APTR array, UWORD width, UWORD height, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define MakePictureA(array, width, height, tags) __MakePictureA(GuiGFXBase, (array), (width), (height), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __MakePicture(void *, APTR array, UWORD width, UWORD height, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define MakePicture(array, width, ...) __MakePicture(GuiGFXBase, (array), (width), __VA_ARGS__)
#endif

APTR __LoadPictureA(void *, STRPTR filename, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define LoadPictureA(filename, tags) __LoadPictureA(GuiGFXBase, (filename), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __LoadPicture(void *, STRPTR filename, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define LoadPicture(...) __LoadPicture(GuiGFXBase, __VA_ARGS__)
#endif

APTR __ReadPictureA(void *, struct RastPort * a0arg, struct ColorMap * colormap, UWORD x, UWORD y, UWORD width, UWORD height, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,40(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define ReadPictureA(a0arg, colormap, x, y, width, height, tags) __ReadPictureA(GuiGFXBase, (a0arg), (colormap), (x), (y), (width), (height), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __ReadPicture(void *, struct RastPort * a0arg, struct ColorMap * colormap, UWORD x, UWORD y, UWORD width, UWORD height, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define ReadPicture(a0arg, colormap, x, y, width, ...) __ReadPicture(GuiGFXBase, (a0arg), (colormap), (x), (y), (width), __VA_ARGS__)
#endif

APTR __ClonePictureA(void *, APTR pic, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define ClonePictureA(pic, tags) __ClonePictureA(GuiGFXBase, (pic), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __ClonePicture(void *, APTR pic, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define ClonePicture(...) __ClonePicture(GuiGFXBase, __VA_ARGS__)
#endif

void __DeletePicture(void *, APTR pic) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define DeletePicture(pic) __DeletePicture(GuiGFXBase, (pic))

APTR __AddPictureA(void *, APTR psm, APTR pic, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define AddPictureA(psm, pic, tags) __AddPictureA(GuiGFXBase, (psm), (pic), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __AddPicture(void *, APTR psm, APTR pic, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define AddPicture(psm, ...) __AddPicture(GuiGFXBase, (psm), __VA_ARGS__)
#endif

APTR __AddPaletteA(void *, APTR psm, APTR palette, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define AddPaletteA(psm, palette, tags) __AddPaletteA(GuiGFXBase, (psm), (palette), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __AddPalette(void *, APTR psm, APTR palette, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define AddPalette(psm, ...) __AddPalette(GuiGFXBase, (psm), __VA_ARGS__)
#endif

APTR __AddPixelArrayA(void *, APTR psm, APTR array, UWORD width, UWORD height, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define AddPixelArrayA(psm, array, width, height, tags) __AddPixelArrayA(GuiGFXBase, (psm), (array), (width), (height), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __AddPixelArray(void *, APTR psm, APTR array, UWORD width, UWORD height, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define AddPixelArray(psm, array, width, ...) __AddPixelArray(GuiGFXBase, (psm), (array), (width), __VA_ARGS__)
#endif

void __RemColorHandle(void *, APTR colorhandle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define RemColorHandle(colorhandle) __RemColorHandle(GuiGFXBase, (colorhandle))

APTR __CreatePenShareMapA(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define CreatePenShareMapA(tags) __CreatePenShareMapA(GuiGFXBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __CreatePenShareMap(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define CreatePenShareMap(...) __CreatePenShareMap(GuiGFXBase, __VA_ARGS__)
#endif

void __DeletePenShareMap(void *, APTR psm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define DeletePenShareMap(psm) __DeletePenShareMap(GuiGFXBase, (psm))

APTR __ObtainDrawHandleA(void *, APTR psm, struct RastPort * a1arg, struct ColorMap * cm, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define ObtainDrawHandleA(psm, a1arg, cm, tags) __ObtainDrawHandleA(GuiGFXBase, (psm), (a1arg), (cm), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __ObtainDrawHandle(void *, APTR psm, struct RastPort * a1arg, struct ColorMap * cm, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define ObtainDrawHandle(psm, a1arg, ...) __ObtainDrawHandle(GuiGFXBase, (psm), (a1arg), __VA_ARGS__)
#endif

void __ReleaseDrawHandle(void *, APTR drawhandle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define ReleaseDrawHandle(drawhandle) __ReleaseDrawHandle(GuiGFXBase, (drawhandle))

BOOL __DrawPictureA(void *, APTR drawhandle, APTR pic, UWORD x, UWORD y, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define DrawPictureA(drawhandle, pic, x, y, tags) __DrawPictureA(GuiGFXBase, (drawhandle), (pic), (x), (y), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __DrawPicture(void *, APTR drawhandle, APTR pic, UWORD x, UWORD y, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define DrawPicture(drawhandle, pic, x, ...) __DrawPicture(GuiGFXBase, (drawhandle), (pic), (x), __VA_ARGS__)
#endif

BOOL __MapPaletteA(void *, APTR drawhandle, APTR palette, UBYTE * pentab, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define MapPaletteA(drawhandle, palette, pentab, tags) __MapPaletteA(GuiGFXBase, (drawhandle), (palette), (pentab), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __MapPalette(void *, APTR drawhandle, APTR palette, UBYTE * pentab, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define MapPalette(drawhandle, palette, ...) __MapPalette(GuiGFXBase, (drawhandle), (palette), __VA_ARGS__)
#endif

LONG __MapPenA(void *, APTR drawhandle, ULONG rgb, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define MapPenA(drawhandle, rgb, tags) __MapPenA(GuiGFXBase, (drawhandle), (rgb), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __MapPen(void *, APTR drawhandle, ULONG rgb, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define MapPen(drawhandle, ...) __MapPen(GuiGFXBase, (drawhandle), __VA_ARGS__)
#endif

struct BitMap * __CreatePictureBitMapA(void *, APTR drawhandle, APTR pic, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define CreatePictureBitMapA(drawhandle, pic, tags) __CreatePictureBitMapA(GuiGFXBase, (drawhandle), (pic), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct BitMap * __linearvarargs __CreatePictureBitMap(void *, APTR drawhandle, APTR pic, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define CreatePictureBitMap(drawhandle, ...) __CreatePictureBitMap(GuiGFXBase, (drawhandle), __VA_ARGS__)
#endif

ULONG __DoPictureMethodA(void *, APTR pic, ULONG method, ULONG * arguments) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define DoPictureMethodA(pic, method, arguments) __DoPictureMethodA(GuiGFXBase, (pic), (method), (arguments))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __DoPictureMethod(void *, APTR pic, ULONG method, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define DoPictureMethod(pic, ...) __DoPictureMethod(GuiGFXBase, (pic), __VA_ARGS__)
#endif

ULONG __GetPictureAttrsA(void *, APTR pic, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define GetPictureAttrsA(pic, tags) __GetPictureAttrsA(GuiGFXBase, (pic), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __GetPictureAttrs(void *, APTR pic, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define GetPictureAttrs(...) __GetPictureAttrs(GuiGFXBase, __VA_ARGS__)
#endif

ULONG __LockPictureA(void *, APTR pic, ULONG mode, ULONG * args) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define LockPictureA(pic, mode, args) __LockPictureA(GuiGFXBase, (pic), (mode), (args))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __LockPicture(void *, APTR pic, ULONG mode, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define LockPicture(pic, ...) __LockPicture(GuiGFXBase, (pic), __VA_ARGS__)
#endif

void __UnLockPicture(void *, APTR pic, ULONG mode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define UnLockPicture(pic, mode) __UnLockPicture(GuiGFXBase, (pic), (mode))

BOOL __IsPictureA(void *, char * filename, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define IsPictureA(filename, tags) __IsPictureA(GuiGFXBase, (filename), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __IsPicture(void *, char * filename, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define IsPicture(...) __IsPicture(GuiGFXBase, __VA_ARGS__)
#endif

APTR __CreateDirectDrawHandleA(void *, APTR drawhandle, UWORD sw, UWORD sh, UWORD dw, UWORD dh, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,36(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define CreateDirectDrawHandleA(drawhandle, sw, sh, dw, dh, tags) __CreateDirectDrawHandleA(GuiGFXBase, (drawhandle), (sw), (sh), (dw), (dh), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __CreateDirectDrawHandle(void *, APTR drawhandle, UWORD sw, UWORD sh, UWORD dw, UWORD dh, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define CreateDirectDrawHandle(drawhandle, sw, sh, dw, ...) __CreateDirectDrawHandle(GuiGFXBase, (drawhandle), (sw), (sh), (dw), __VA_ARGS__)
#endif

void __DeleteDirectDrawHandle(void *, APTR ddh) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define DeleteDirectDrawHandle(ddh) __DeleteDirectDrawHandle(GuiGFXBase, (ddh))

BOOL __DirectDrawTrueColorA(void *, APTR ddh, ULONG * array, UWORD x, UWORD y, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define DirectDrawTrueColorA(ddh, array, x, y, tags) __DirectDrawTrueColorA(GuiGFXBase, (ddh), (array), (x), (y), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __DirectDrawTrueColor(void *, APTR ddh, ULONG * array, UWORD x, UWORD y, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define DirectDrawTrueColor(ddh, array, x, ...) __DirectDrawTrueColor(GuiGFXBase, (ddh), (array), (x), __VA_ARGS__)
#endif

BOOL __CreatePictureMaskA(void *, APTR pic, UBYTE * mask, UWORD maskwidth, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define CreatePictureMaskA(pic, mask, maskwidth, tags) __CreatePictureMaskA(GuiGFXBase, (pic), (mask), (maskwidth), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __CreatePictureMask(void *, APTR pic, UBYTE * mask, UWORD maskwidth, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define CreatePictureMask(pic, mask, ...) __CreatePictureMask(GuiGFXBase, (pic), (mask), __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_GUIGFX_H  */
