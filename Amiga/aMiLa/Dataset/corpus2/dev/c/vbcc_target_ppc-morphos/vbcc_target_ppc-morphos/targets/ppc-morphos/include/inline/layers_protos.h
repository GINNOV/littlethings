#ifndef _VBCCINLINE_LAYERS_H
#define _VBCCINLINE_LAYERS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

VOID __InitLayers(void *, struct Layer_Info * li) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define InitLayers(li) __InitLayers(LayersBase, (li))

struct Layer * __CreateUpfrontLayer(void *, struct Layer_Info * li, struct BitMap * bm, LONG x0, LONG y0, LONG x1, LONG y1, LONG flags, struct BitMap * bm2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,40(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define CreateUpfrontLayer(li, bm, x0, y0, x1, y1, flags, bm2) __CreateUpfrontLayer(LayersBase, (li), (bm), (x0), (y0), (x1), (y1), (flags), (bm2))

struct Layer * __CreateBehindLayer(void *, struct Layer_Info * li, struct BitMap * bm, LONG x0, LONG y0, LONG x1, LONG y1, LONG flags, struct BitMap * bm2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,40(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define CreateBehindLayer(li, bm, x0, y0, x1, y1, flags, bm2) __CreateBehindLayer(LayersBase, (li), (bm), (x0), (y0), (x1), (y1), (flags), (bm2))

LONG __UpfrontLayer(void *, LONG dummy, struct Layer * layer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define UpfrontLayer(dummy, layer) __UpfrontLayer(LayersBase, (dummy), (layer))

LONG __BehindLayer(void *, LONG dummy, struct Layer * layer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define BehindLayer(dummy, layer) __BehindLayer(LayersBase, (dummy), (layer))

LONG __MoveLayer(void *, LONG dummy, struct Layer * layer, LONG dx, LONG dy) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define MoveLayer(dummy, layer, dx, dy) __MoveLayer(LayersBase, (dummy), (layer), (dx), (dy))

LONG __SizeLayer(void *, LONG dummy, struct Layer * layer, LONG dx, LONG dy) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define SizeLayer(dummy, layer, dx, dy) __SizeLayer(LayersBase, (dummy), (layer), (dx), (dy))

VOID __ScrollLayer(void *, LONG dummy, struct Layer * layer, LONG dx, LONG dy) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define ScrollLayer(dummy, layer, dx, dy) __ScrollLayer(LayersBase, (dummy), (layer), (dx), (dy))

LONG __BeginUpdate(void *, struct Layer * l) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define BeginUpdate(l) __BeginUpdate(LayersBase, (l))

VOID __EndUpdate(void *, struct Layer * layer, ULONG flag) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define EndUpdate(layer, flag) __EndUpdate(LayersBase, (layer), (flag))

LONG __DeleteLayer(void *, LONG dummy, struct Layer * layer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define DeleteLayer(dummy, layer) __DeleteLayer(LayersBase, (dummy), (layer))

VOID __LockLayer(void *, LONG dummy, struct Layer * layer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define LockLayer(dummy, layer) __LockLayer(LayersBase, (dummy), (layer))

VOID __UnlockLayer(void *, struct Layer * layer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define UnlockLayer(layer) __UnlockLayer(LayersBase, (layer))

VOID __LockLayers(void *, struct Layer_Info * li) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define LockLayers(li) __LockLayers(LayersBase, (li))

VOID __UnlockLayers(void *, struct Layer_Info * li) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define UnlockLayers(li) __UnlockLayers(LayersBase, (li))

VOID __LockLayerInfo(void *, struct Layer_Info * li) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define LockLayerInfo(li) __LockLayerInfo(LayersBase, (li))

VOID __SwapBitsRastPortClipRect(void *, struct RastPort * rp, struct ClipRect * cr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define SwapBitsRastPortClipRect(rp, cr) __SwapBitsRastPortClipRect(LayersBase, (rp), (cr))

struct Layer * __WhichLayer(void *, struct Layer_Info * li, LONG x, LONG y) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define WhichLayer(li, x, y) __WhichLayer(LayersBase, (li), (x), (y))

VOID __UnlockLayerInfo(void *, struct Layer_Info * li) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define UnlockLayerInfo(li) __UnlockLayerInfo(LayersBase, (li))

struct Layer_Info * __NewLayerInfo(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define NewLayerInfo() __NewLayerInfo(LayersBase)

VOID __DisposeLayerInfo(void *, struct Layer_Info * li) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define DisposeLayerInfo(li) __DisposeLayerInfo(LayersBase, (li))

LONG __FattenLayerInfo(void *, struct Layer_Info * li) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define FattenLayerInfo(li) __FattenLayerInfo(LayersBase, (li))

VOID __ThinLayerInfo(void *, struct Layer_Info * li) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define ThinLayerInfo(li) __ThinLayerInfo(LayersBase, (li))

LONG __MoveLayerInFrontOf(void *, struct Layer * layer_to_move, struct Layer * other_layer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define MoveLayerInFrontOf(layer_to_move, other_layer) __MoveLayerInFrontOf(LayersBase, (layer_to_move), (other_layer))

struct Region * __InstallClipRegion(void *, struct Layer * layer, CONST struct Region * region) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define InstallClipRegion(layer, region) __InstallClipRegion(LayersBase, (layer), (region))

LONG __MoveSizeLayer(void *, struct Layer * layer, LONG dx, LONG dy, LONG dw, LONG dh) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define MoveSizeLayer(layer, dx, dy, dw, dh) __MoveSizeLayer(LayersBase, (layer), (dx), (dy), (dw), (dh))

struct Layer * __CreateUpfrontHookLayer(void *, struct Layer_Info * li, struct BitMap * bm, LONG x0, LONG y0, LONG x1, LONG y1, LONG flags, struct Hook * hook, struct BitMap * bm2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,44(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,40(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define CreateUpfrontHookLayer(li, bm, x0, y0, x1, y1, flags, hook, bm2) __CreateUpfrontHookLayer(LayersBase, (li), (bm), (x0), (y0), (x1), (y1), (flags), (hook), (bm2))

struct Layer * __CreateBehindHookLayer(void *, struct Layer_Info * li, struct BitMap * bm, LONG x0, LONG y0, LONG x1, LONG y1, LONG flags, struct Hook * hook, struct BitMap * bm2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,44(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,40(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define CreateBehindHookLayer(li, bm, x0, y0, x1, y1, flags, hook, bm2) __CreateBehindHookLayer(LayersBase, (li), (bm), (x0), (y0), (x1), (y1), (flags), (hook), (bm2))

struct Hook * __InstallLayerHook(void *, struct Layer * layer, struct Hook * hook) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define InstallLayerHook(layer, hook) __InstallLayerHook(LayersBase, (layer), (hook))

struct Hook * __InstallLayerInfoHook(void *, struct Layer_Info * li, CONST struct Hook * hook) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define InstallLayerInfoHook(li, hook) __InstallLayerInfoHook(LayersBase, (li), (hook))

VOID __SortLayerCR(void *, struct Layer * layer, LONG dx, LONG dy) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define SortLayerCR(layer, dx, dy) __SortLayerCR(LayersBase, (layer), (dx), (dy))

VOID __DoHookClipRects(void *, struct Hook * hook, struct RastPort * rport, CONST struct Rectangle * rect) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define DoHookClipRects(hook, rport, rect) __DoHookClipRects(LayersBase, (hook), (rport), (rect))

struct Layer * __CreateUpfrontLayerTagList(void *, struct Layer_Info * li, struct BitMap * bm, LONG x0, LONG y0, LONG x1, LONG y1, LONG flags, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,40(2)\n"
	"\tli\t3,-234\n"
	"\tbctrl";
#define CreateUpfrontLayerTagList(li, bm, x0, y0, x1, y1, flags, taglist) __CreateUpfrontLayerTagList(LayersBase, (li), (bm), (x0), (y0), (x1), (y1), (flags), (taglist))

struct Layer * __CreateBehindLayerTagList(void *, struct Layer_Info * li, struct BitMap * bm, LONG x0, LONG y0, LONG x1, LONG y1, LONG flags, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,40(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define CreateBehindLayerTagList(li, bm, x0, y0, x1, y1, flags, taglist) __CreateBehindLayerTagList(LayersBase, (li), (bm), (x0), (y0), (x1), (y1), (flags), (taglist))

struct Layer * __WhichLayerBehindLayer(void *, struct Layer * l, LONG x, LONG y) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define WhichLayerBehindLayer(l, x, y) __WhichLayerBehindLayer(LayersBase, (l), (x), (y))

BOOL __IsLayerVisible(void *, struct Layer * l) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define IsLayerVisible(l) __IsLayerVisible(LayersBase, (l))

BOOL __RenderLayerInfoTagList(void *, struct Layer_Info * li, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-282\n"
	"\tbctrl";
#define RenderLayerInfoTagList(li, taglist) __RenderLayerInfoTagList(LayersBase, (li), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __RenderLayerInfoTags(void *, struct Layer_Info * li, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-282\n"
	"\tbctrl";
#define RenderLayerInfoTags(li, ...) __RenderLayerInfoTags(LayersBase, (li), __VA_ARGS__)
#endif

VOID __LockLayerUpdates(void *, struct Layer * l) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-288\n"
	"\tbctrl";
#define LockLayerUpdates(l) __LockLayerUpdates(LayersBase, (l))

VOID __UnlockLayerUpdates(void *, struct Layer * l) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-294\n"
	"\tbctrl";
#define UnlockLayerUpdates(l) __UnlockLayerUpdates(LayersBase, (l))

BOOL __IsVisibleInLayer(void *, struct Layer * l, LONG x0, LONG y0, LONG x1, LONG y1) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-300\n"
	"\tbctrl";
#define IsVisibleInLayer(l, x0, y0, x1, y1) __IsVisibleInLayer(LayersBase, (l), (x0), (y0), (x1), (y1))

BOOL __IsLayerHitable(void *, struct Layer * l) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-306\n"
	"\tbctrl";
#define IsLayerHitable(l) __IsLayerHitable(LayersBase, (l))

#endif /*  _VBCCINLINE_LAYERS_H  */
