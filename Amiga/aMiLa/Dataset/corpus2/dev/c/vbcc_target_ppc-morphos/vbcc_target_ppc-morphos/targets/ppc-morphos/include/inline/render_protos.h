#ifndef _VBCCINLINE_RENDER_H
#define _VBCCINLINE_RENDER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __CreateRMHandlerA(void *, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define CreateRMHandlerA(taglist) __CreateRMHandlerA(RenderBase, (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __CreateRMHandler(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define CreateRMHandler(...) __CreateRMHandler(RenderBase, __VA_ARGS__)
#endif

void __DeleteRMHandler(void *, APTR rmh) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define DeleteRMHandler(rmh) __DeleteRMHandler(RenderBase, (rmh))

APTR __AllocRenderMem(void *, APTR rendermemhandler, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define AllocRenderMem(rendermemhandler, size) __AllocRenderMem(RenderBase, (rendermemhandler), (size))

void __FreeRenderMem(void *, APTR rendermemhandler, APTR mem, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define FreeRenderMem(rendermemhandler, mem, size) __FreeRenderMem(RenderBase, (rendermemhandler), (mem), (size))

APTR __AllocRenderVec(void *, APTR rendermemhandler, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define AllocRenderVec(rendermemhandler, size) __AllocRenderVec(RenderBase, (rendermemhandler), (size))

void __FreeRenderVec(void *, APTR mem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define FreeRenderVec(mem) __FreeRenderVec(RenderBase, (mem))

APTR __CreateHistogramA(void *, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define CreateHistogramA(taglist) __CreateHistogramA(RenderBase, (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __CreateHistogram(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define CreateHistogram(...) __CreateHistogram(RenderBase, __VA_ARGS__)
#endif

void __DeleteHistogram(void *, APTR histogram) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define DeleteHistogram(histogram) __DeleteHistogram(RenderBase, (histogram))

ULONG __QueryHistogram(void *, APTR histogram, Tag d0arg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define QueryHistogram(histogram, d0arg) __QueryHistogram(RenderBase, (histogram), (d0arg))

ULONG __AddRGB(void *, APTR histogram, ULONG RGB, ULONG count) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define AddRGB(histogram, RGB, count) __AddRGB(RenderBase, (histogram), (RGB), (count))

ULONG __AddRGBImageA(void *, APTR histogram, ULONG * rgb, UWORD width, UWORD height, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define AddRGBImageA(histogram, rgb, width, height, taglist) __AddRGBImageA(RenderBase, (histogram), (rgb), (width), (height), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __AddRGBImage(void *, APTR histogram, ULONG * rgb, UWORD width, UWORD height, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define AddRGBImage(histogram, rgb, width, height, ...) __AddRGBImage(RenderBase, (histogram), (rgb), (width), (height), __VA_ARGS__)
#endif

ULONG __AddChunkyImageA(void *, APTR histogram, UBYTE * chunky, UWORD width, UWORD height, APTR palette, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,44(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define AddChunkyImageA(histogram, chunky, width, height, palette, taglist) __AddChunkyImageA(RenderBase, (histogram), (chunky), (width), (height), (palette), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __AddChunkyImage(void *, APTR histogram, UBYTE * chunky, UWORD width, UWORD height, APTR palette, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define AddChunkyImage(histogram, chunky, width, height, palette, ...) __AddChunkyImage(RenderBase, (histogram), (chunky), (width), (height), (palette), __VA_ARGS__)
#endif

ULONG __ExtractPaletteA(void *, APTR histogram, ULONG * palette, UWORD numcolors, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define ExtractPaletteA(histogram, palette, numcolors, taglist) __ExtractPaletteA(RenderBase, (histogram), (palette), (numcolors), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __ExtractPalette(void *, APTR histogram, ULONG * palette, UWORD numcolors, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define ExtractPalette(histogram, palette, numcolors, ...) __ExtractPalette(RenderBase, (histogram), (palette), (numcolors), __VA_ARGS__)
#endif

ULONG __RenderA(void *, ULONG * rgb, UWORD width, UWORD height, UBYTE * chunky, APTR palette, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,44(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define RenderA(rgb, width, height, chunky, palette, taglist) __RenderA(RenderBase, (rgb), (width), (height), (chunky), (palette), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __Render(void *, ULONG * rgb, UWORD width, UWORD height, UBYTE * chunky, APTR palette, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define Render(rgb, width, height, chunky, palette, ...) __Render(RenderBase, (rgb), (width), (height), (chunky), (palette), __VA_ARGS__)
#endif

void __Planar2ChunkyA(void *, PLANEPTR * planetab, UWORD bytewidth, UWORD height, UWORD depth, UWORD bytesperrow, UBYTE * chunky, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,36(2)\n"
	"\tstw\t10,40(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define Planar2ChunkyA(planetab, bytewidth, height, depth, bytesperrow, chunky, taglist) __Planar2ChunkyA(RenderBase, (planetab), (bytewidth), (height), (depth), (bytesperrow), (chunky), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __Planar2Chunky(void *, PLANEPTR * planetab, UWORD bytewidth, UWORD height, UWORD depth, UWORD bytesperrow, UBYTE * chunky, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define Planar2Chunky(planetab, bytewidth, height, depth, bytesperrow, chunky, ...) __Planar2Chunky(RenderBase, (planetab), (bytewidth), (height), (depth), (bytesperrow), (chunky), __VA_ARGS__)
#endif

ULONG __Chunky2RGBA(void *, UBYTE * chunky, UWORD width, UWORD height, ULONG * rgb, APTR palette, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,44(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define Chunky2RGBA(chunky, width, height, rgb, palette, taglist) __Chunky2RGBA(RenderBase, (chunky), (width), (height), (rgb), (palette), (taglist))

void __Chunky2BitMapA(void *, UBYTE * chunky, UWORD sx, UWORD sy, UWORD width, UWORD height, struct BitMap * bitmap, UWORD dx, UWORD dy, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,36(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,40(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define Chunky2BitMapA(chunky, sx, sy, width, height, bitmap, dx, dy, taglist) __Chunky2BitMapA(RenderBase, (chunky), (sx), (sy), (width), (height), (bitmap), (dx), (dy), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __Chunky2BitMap(void *, UBYTE * chunky, UWORD sx, UWORD sy, UWORD width, UWORD height, struct BitMap * bitmap, UWORD dx, UWORD dy, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,36(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\taddi\t12,1,12\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define Chunky2BitMap(chunky, sx, sy, width, height, bitmap, dx, dy, ...) __Chunky2BitMap(RenderBase, (chunky), (sx), (sy), (width), (height), (bitmap), (dx), (dy), __VA_ARGS__)
#endif

APTR __CreateScaleEngineA(void *, UWORD sourcewidth, UWORD sourceheight, UWORD destwidth, UWORD destheight, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,12(2)\n"
	"\tstw\t8,36(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define CreateScaleEngineA(sourcewidth, sourceheight, destwidth, destheight, taglist) __CreateScaleEngineA(RenderBase, (sourcewidth), (sourceheight), (destwidth), (destheight), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __CreateScaleEngine(void *, UWORD sourcewidth, UWORD sourceheight, UWORD destwidth, UWORD destheight, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,12(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define CreateScaleEngine(sourcewidth, sourceheight, destwidth, destheight, ...) __CreateScaleEngine(RenderBase, (sourcewidth), (sourceheight), (destwidth), (destheight), __VA_ARGS__)
#endif

void __DeleteScaleEngine(void *, APTR engine) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define DeleteScaleEngine(engine) __DeleteScaleEngine(RenderBase, (engine))

ULONG __ScaleA(void *, APTR engine, APTR source, APTR dest, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define ScaleA(engine, source, dest, taglist) __ScaleA(RenderBase, (engine), (source), (dest), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __Scale(void *, APTR engine, APTR source, APTR dest, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define Scale(engine, source, dest, ...) __Scale(RenderBase, (engine), (source), (dest), __VA_ARGS__)
#endif

ULONG __ConvertChunkyA(void *, UBYTE * source, APTR oldpalette, UWORD width, UWORD height, UBYTE * dest, APTR newpalette, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,44(2)\n"
	"\tstw\t10,48(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define ConvertChunkyA(source, oldpalette, width, height, dest, newpalette, taglist) __ConvertChunkyA(RenderBase, (source), (oldpalette), (width), (height), (dest), (newpalette), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __ConvertChunky(void *, UBYTE * source, APTR oldpalette, UWORD width, UWORD height, UBYTE * dest, APTR newpalette, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,44(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,48(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define ConvertChunky(source, oldpalette, width, height, dest, newpalette, ...) __ConvertChunky(RenderBase, (source), (oldpalette), (width), (height), (dest), (newpalette), __VA_ARGS__)
#endif

void __CreatePenTableA(void *, UBYTE * chunky, APTR oldpalette, UWORD width, UWORD height, APTR newpalette, UBYTE * convtab, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,44(2)\n"
	"\tstw\t10,48(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define CreatePenTableA(chunky, oldpalette, width, height, newpalette, convtab, taglist) __CreatePenTableA(RenderBase, (chunky), (oldpalette), (width), (height), (newpalette), (convtab), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __CreatePenTable(void *, UBYTE * chunky, APTR oldpalette, UWORD width, UWORD height, APTR newpalette, UBYTE * convtab, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,44(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,48(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define CreatePenTable(chunky, oldpalette, width, height, newpalette, convtab, ...) __CreatePenTable(RenderBase, (chunky), (oldpalette), (width), (height), (newpalette), (convtab), __VA_ARGS__)
#endif

APTR __CreatePaletteA(void *, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define CreatePaletteA(taglist) __CreatePaletteA(RenderBase, (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __CreatePalette(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define CreatePalette(...) __CreatePalette(RenderBase, __VA_ARGS__)
#endif

void __DeletePalette(void *, APTR palette) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define DeletePalette(palette) __DeletePalette(RenderBase, (palette))

void __ImportPaletteA(void *, APTR palette, APTR coltab, UWORD numcols, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define ImportPaletteA(palette, coltab, numcols, taglist) __ImportPaletteA(RenderBase, (palette), (coltab), (numcols), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __ImportPalette(void *, APTR palette, APTR coltab, UWORD numcols, ...) =
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
#define ImportPalette(palette, coltab, numcols, ...) __ImportPalette(RenderBase, (palette), (coltab), (numcols), __VA_ARGS__)
#endif

void __ExportPaletteA(void *, APTR palette, APTR coltab, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define ExportPaletteA(palette, coltab, taglist) __ExportPaletteA(RenderBase, (palette), (coltab), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __ExportPalette(void *, APTR palette, APTR coltab, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define ExportPalette(palette, coltab, ...) __ExportPalette(RenderBase, (palette), (coltab), __VA_ARGS__)
#endif

ULONG __CountRGB(void *, APTR histogram, ULONG rgb) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define CountRGB(histogram, rgb) __CountRGB(RenderBase, (histogram), (rgb))

LONG __BestPen(void *, APTR palette, ULONG rgb) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define BestPen(palette, rgb) __BestPen(RenderBase, (palette), (rgb))

void __FlushPalette(void *, APTR palette) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define FlushPalette(palette) __FlushPalette(RenderBase, (palette))

ULONG __SortPaletteA(void *, APTR palette, ULONG mode, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define SortPaletteA(palette, mode, taglist) __SortPaletteA(RenderBase, (palette), (mode), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __SortPalette(void *, APTR palette, ULONG mode, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define SortPalette(palette, mode, ...) __SortPalette(RenderBase, (palette), (mode), __VA_ARGS__)
#endif

ULONG __AddHistogramA(void *, APTR histogram1, APTR histogram2, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define AddHistogramA(histogram1, histogram2, taglist) __AddHistogramA(RenderBase, (histogram1), (histogram2), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __AddHistogram(void *, APTR histogram1, APTR histogram2, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define AddHistogram(histogram1, histogram2, ...) __AddHistogram(RenderBase, (histogram1), (histogram2), __VA_ARGS__)
#endif

UWORD __ScaleOrdinate(void *, UWORD source, UWORD dest, UWORD ordinate) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define ScaleOrdinate(source, dest, ordinate) __ScaleOrdinate(RenderBase, (source), (dest), (ordinate))

APTR __CreateMapEngineA(void *, APTR palette, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define CreateMapEngineA(palette, taglist) __CreateMapEngineA(RenderBase, (palette), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __CreateMapEngine(void *, APTR palette, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define CreateMapEngine(palette, ...) __CreateMapEngine(RenderBase, (palette), __VA_ARGS__)
#endif

void __DeleteMapEngine(void *, APTR engine) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define DeleteMapEngine(engine) __DeleteMapEngine(RenderBase, (engine))

ULONG __MapRGBArrayA(void *, APTR engine, ULONG * rgb, UWORD width, UWORD height, UBYTE * chunky, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,44(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define MapRGBArrayA(engine, rgb, width, height, chunky, taglist) __MapRGBArrayA(RenderBase, (engine), (rgb), (width), (height), (chunky), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __MapRGBArray(void *, APTR engine, ULONG * rgb, UWORD width, UWORD height, UBYTE * chunky, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define MapRGBArray(engine, rgb, width, height, chunky, ...) __MapRGBArray(RenderBase, (engine), (rgb), (width), (height), (chunky), __VA_ARGS__)
#endif

LONG __RGBArrayDiversityA(void *, ULONG * rgb, UWORD width, UWORD height, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-264\n"
	"\tbctrl";
#define RGBArrayDiversityA(rgb, width, height, taglist) __RGBArrayDiversityA(RenderBase, (rgb), (width), (height), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __RGBArrayDiversity(void *, ULONG * rgb, UWORD width, UWORD height, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-264\n"
	"\tbctrl";
#define RGBArrayDiversity(rgb, width, height, ...) __RGBArrayDiversity(RenderBase, (rgb), (width), (height), __VA_ARGS__)
#endif

LONG __ChunkyArrayDiversityA(void *, UBYTE * chunky, APTR palette, UWORD width, UWORD height, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-270\n"
	"\tbctrl";
#define ChunkyArrayDiversityA(chunky, palette, width, height, taglist) __ChunkyArrayDiversityA(RenderBase, (chunky), (palette), (width), (height), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __ChunkyArrayDiversity(void *, UBYTE * chunky, APTR palette, UWORD width, UWORD height, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-270\n"
	"\tbctrl";
#define ChunkyArrayDiversity(chunky, palette, width, height, ...) __ChunkyArrayDiversity(RenderBase, (chunky), (palette), (width), (height), __VA_ARGS__)
#endif

ULONG __MapChunkyArrayA(void *, APTR engine, UBYTE * source, APTR palette, UWORD width, UWORD height, UBYTE * dest, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tstw\t9,44(2)\n"
	"\tstw\t10,48(2)\n"
	"\tli\t3,-276\n"
	"\tbctrl";
#define MapChunkyArrayA(engine, source, palette, width, height, dest, taglist) __MapChunkyArrayA(RenderBase, (engine), (source), (palette), (width), (height), (dest), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __MapChunkyArray(void *, APTR engine, UBYTE * source, APTR palette, UWORD width, UWORD height, UBYTE * dest, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tstw\t9,44(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,48(2)\n"
	"\tli\t3,-276\n"
	"\tbctrl";
#define MapChunkyArray(engine, source, palette, width, height, dest, ...) __MapChunkyArray(RenderBase, (engine), (source), (palette), (width), (height), (dest), __VA_ARGS__)
#endif

void __InsertAlphaChannelA(void *, UBYTE * maskarray, UWORD width, UWORD height, ULONG * rgbarray, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-282\n"
	"\tbctrl";
#define InsertAlphaChannelA(maskarray, width, height, rgbarray, taglist) __InsertAlphaChannelA(RenderBase, (maskarray), (width), (height), (rgbarray), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __InsertAlphaChannel(void *, UBYTE * maskarray, UWORD width, UWORD height, ULONG * rgbarray, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-282\n"
	"\tbctrl";
#define InsertAlphaChannel(maskarray, width, height, rgbarray, ...) __InsertAlphaChannel(RenderBase, (maskarray), (width), (height), (rgbarray), __VA_ARGS__)
#endif

void __ExtractAlphaChannelA(void *, ULONG * rgbarray, UWORD width, UWORD height, UBYTE * chunkyarray, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-288\n"
	"\tbctrl";
#define ExtractAlphaChannelA(rgbarray, width, height, chunkyarray, taglist) __ExtractAlphaChannelA(RenderBase, (rgbarray), (width), (height), (chunkyarray), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __ExtractAlphaChannel(void *, ULONG * rgbarray, UWORD width, UWORD height, UBYTE * chunkyarray, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-288\n"
	"\tbctrl";
#define ExtractAlphaChannel(rgbarray, width, height, chunkyarray, ...) __ExtractAlphaChannel(RenderBase, (rgbarray), (width), (height), (chunkyarray), __VA_ARGS__)
#endif

void __ApplyAlphaChannelA(void *, ULONG * sourcearray, UWORD width, UWORD height, ULONG * destarray, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-294\n"
	"\tbctrl";
#define ApplyAlphaChannelA(sourcearray, width, height, destarray, taglist) __ApplyAlphaChannelA(RenderBase, (sourcearray), (width), (height), (destarray), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __ApplyAlphaChannel(void *, ULONG * sourcearray, UWORD width, UWORD height, ULONG * destarray, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-294\n"
	"\tbctrl";
#define ApplyAlphaChannel(sourcearray, width, height, destarray, ...) __ApplyAlphaChannel(RenderBase, (sourcearray), (width), (height), (destarray), __VA_ARGS__)
#endif

void __MixRGBArrayA(void *, ULONG * sourcearray, UWORD width, UWORD height, ULONG * destarray, UWORD ratio, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,40(2)\n"
	"\tli\t3,-300\n"
	"\tbctrl";
#define MixRGBArrayA(sourcearray, width, height, destarray, ratio, taglist) __MixRGBArrayA(RenderBase, (sourcearray), (width), (height), (destarray), (ratio), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __MixRGBArray(void *, ULONG * sourcearray, UWORD width, UWORD height, ULONG * destarray, UWORD ratio, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,8(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-300\n"
	"\tbctrl";
#define MixRGBArray(sourcearray, width, height, destarray, ratio, ...) __MixRGBArray(RenderBase, (sourcearray), (width), (height), (destarray), (ratio), __VA_ARGS__)
#endif

APTR __AllocRenderVecClear(void *, APTR rendermemhandler, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-306\n"
	"\tbctrl";
#define AllocRenderVecClear(rendermemhandler, size) __AllocRenderVecClear(RenderBase, (rendermemhandler), (size))

void __CreateAlphaArrayA(void *, ULONG * rgbarray, UWORD width, UWORD height, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-312\n"
	"\tbctrl";
#define CreateAlphaArrayA(rgbarray, width, height, taglist) __CreateAlphaArrayA(RenderBase, (rgbarray), (width), (height), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __CreateAlphaArray(void *, ULONG * rgbarray, UWORD width, UWORD height, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-312\n"
	"\tbctrl";
#define CreateAlphaArray(rgbarray, width, height, ...) __CreateAlphaArray(RenderBase, (rgbarray), (width), (height), __VA_ARGS__)
#endif

void __MixAlphaChannelA(void *, ULONG * source1, ULONG * source2, UWORD width, UWORD height, ULONG * dest, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,44(2)\n"
	"\tli\t3,-318\n"
	"\tbctrl";
#define MixAlphaChannelA(source1, source2, width, height, dest, taglist) __MixAlphaChannelA(RenderBase, (source1), (source2), (width), (height), (dest), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __MixAlphaChannel(void *, ULONG * source1, ULONG * source2, UWORD width, UWORD height, ULONG * dest, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-318\n"
	"\tbctrl";
#define MixAlphaChannel(source1, source2, width, height, dest, ...) __MixAlphaChannel(RenderBase, (source1), (source2), (width), (height), (dest), __VA_ARGS__)
#endif

void __TintRGBArrayA(void *, ULONG * source, UWORD width, UWORD height, ULONG RGB, UWORD ratio, ULONG * dest, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,36(2)\n"
	"\tstw\t10,40(2)\n"
	"\tli\t3,-324\n"
	"\tbctrl";
#define TintRGBArrayA(source, width, height, RGB, ratio, dest, taglist) __TintRGBArrayA(RenderBase, (source), (width), (height), (RGB), (ratio), (dest), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __TintRGBArray(void *, ULONG * source, UWORD width, UWORD height, ULONG RGB, UWORD ratio, ULONG * dest, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-324\n"
	"\tbctrl";
#define TintRGBArray(source, width, height, RGB, ratio, dest, ...) __TintRGBArray(RenderBase, (source), (width), (height), (RGB), (ratio), (dest), __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_RENDER_H  */
