#ifndef _INLINE_LAYERS_H
#define _INLINE_LAYERS_H

#ifndef LAYERS_BASE_NAME
#define LAYERS_BASE_NAME LayersBase
#endif

#define InitLayers(li) \
	((VOID (*)(struct Layer_Info * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 30))(li, (struct Library *) LAYERS_BASE_NAME)

#define CreateUpfrontLayer(li, bm, x0, y0, x1, y1, flags, bm2) \
	((struct Layer * (*)(struct Layer_Info * __asm("a0"), struct BitMap * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), struct BitMap * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 36))(li, bm, x0, y0, x1, y1, flags, bm2, (struct Library *) LAYERS_BASE_NAME)

#define CreateBehindLayer(li, bm, x0, y0, x1, y1, flags, bm2) \
	((struct Layer * (*)(struct Layer_Info * __asm("a0"), struct BitMap * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), struct BitMap * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 42))(li, bm, x0, y0, x1, y1, flags, bm2, (struct Library *) LAYERS_BASE_NAME)

#define UpfrontLayer(dummy, layer) \
	((LONG (*)(LONG __asm("a0"), struct Layer * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 48))(dummy, layer, (struct Library *) LAYERS_BASE_NAME)

#define BehindLayer(dummy, layer) \
	((LONG (*)(LONG __asm("a0"), struct Layer * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 54))(dummy, layer, (struct Library *) LAYERS_BASE_NAME)

#define MoveLayer(dummy, layer, dx, dy) \
	((LONG (*)(LONG __asm("a0"), struct Layer * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 60))(dummy, layer, dx, dy, (struct Library *) LAYERS_BASE_NAME)

#define SizeLayer(dummy, layer, dx, dy) \
	((LONG (*)(LONG __asm("a0"), struct Layer * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 66))(dummy, layer, dx, dy, (struct Library *) LAYERS_BASE_NAME)

#define ScrollLayer(dummy, layer, dx, dy) \
	((VOID (*)(LONG __asm("a0"), struct Layer * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 72))(dummy, layer, dx, dy, (struct Library *) LAYERS_BASE_NAME)

#define BeginUpdate(l) \
	((LONG (*)(struct Layer * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 78))(l, (struct Library *) LAYERS_BASE_NAME)

#define EndUpdate(layer, flag) \
	((VOID (*)(struct Layer * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 84))(layer, flag, (struct Library *) LAYERS_BASE_NAME)

#define DeleteLayer(dummy, layer) \
	((LONG (*)(LONG __asm("a0"), struct Layer * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 90))(dummy, layer, (struct Library *) LAYERS_BASE_NAME)

#define LockLayer(dummy, layer) \
	((VOID (*)(LONG __asm("a0"), struct Layer * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 96))(dummy, layer, (struct Library *) LAYERS_BASE_NAME)

#define UnlockLayer(layer) \
	((VOID (*)(struct Layer * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 102))(layer, (struct Library *) LAYERS_BASE_NAME)

#define LockLayers(li) \
	((VOID (*)(struct Layer_Info * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 108))(li, (struct Library *) LAYERS_BASE_NAME)

#define UnlockLayers(li) \
	((VOID (*)(struct Layer_Info * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 114))(li, (struct Library *) LAYERS_BASE_NAME)

#define LockLayerInfo(li) \
	((VOID (*)(struct Layer_Info * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 120))(li, (struct Library *) LAYERS_BASE_NAME)

#define SwapBitsRastPortClipRect(rp, cr) \
	((VOID (*)(struct RastPort * __asm("a0"), struct ClipRect * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 126))(rp, cr, (struct Library *) LAYERS_BASE_NAME)

#define WhichLayer(li, x, y) \
	((struct Layer * (*)(struct Layer_Info * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 132))(li, x, y, (struct Library *) LAYERS_BASE_NAME)

#define UnlockLayerInfo(li) \
	((VOID (*)(struct Layer_Info * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 138))(li, (struct Library *) LAYERS_BASE_NAME)

#define NewLayerInfo() \
	((struct Layer_Info * (*)(struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 144))((struct Library *) LAYERS_BASE_NAME)

#define DisposeLayerInfo(li) \
	((VOID (*)(struct Layer_Info * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 150))(li, (struct Library *) LAYERS_BASE_NAME)

#define FattenLayerInfo(li) \
	((LONG (*)(struct Layer_Info * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 156))(li, (struct Library *) LAYERS_BASE_NAME)

#define ThinLayerInfo(li) \
	((VOID (*)(struct Layer_Info * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 162))(li, (struct Library *) LAYERS_BASE_NAME)

#define MoveLayerInFrontOf(layer_to_move, other_layer) \
	((LONG (*)(struct Layer * __asm("a0"), struct Layer * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 168))(layer_to_move, other_layer, (struct Library *) LAYERS_BASE_NAME)

#define InstallClipRegion(layer, region) \
	((struct Region * (*)(struct Layer * __asm("a0"), CONST struct Region * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 174))(layer, region, (struct Library *) LAYERS_BASE_NAME)

#define MoveSizeLayer(layer, dx, dy, dw, dh) \
	((LONG (*)(struct Layer * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 180))(layer, dx, dy, dw, dh, (struct Library *) LAYERS_BASE_NAME)

#define CreateUpfrontHookLayer(li, bm, x0, y0, x1, y1, flags, hook, bm2) \
	((struct Layer * (*)(struct Layer_Info * __asm("a0"), struct BitMap * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), struct Hook * __asm("a3"), struct BitMap * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 186))(li, bm, x0, y0, x1, y1, flags, hook, bm2, (struct Library *) LAYERS_BASE_NAME)

#define CreateBehindHookLayer(li, bm, x0, y0, x1, y1, flags, hook, bm2) \
	((struct Layer * (*)(struct Layer_Info * __asm("a0"), struct BitMap * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), struct Hook * __asm("a3"), struct BitMap * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 192))(li, bm, x0, y0, x1, y1, flags, hook, bm2, (struct Library *) LAYERS_BASE_NAME)

#define InstallLayerHook(layer, hook) \
	((struct Hook * (*)(struct Layer * __asm("a0"), struct Hook * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 198))(layer, hook, (struct Library *) LAYERS_BASE_NAME)

#define InstallLayerInfoHook(li, hook) \
	((struct Hook * (*)(struct Layer_Info * __asm("a0"), CONST struct Hook * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 204))(li, hook, (struct Library *) LAYERS_BASE_NAME)

#define SortLayerCR(layer, dx, dy) \
	((VOID (*)(struct Layer * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 210))(layer, dx, dy, (struct Library *) LAYERS_BASE_NAME)

#define DoHookClipRects(hook, rport, rect) \
	((VOID (*)(struct Hook * __asm("a0"), struct RastPort * __asm("a1"), CONST struct Rectangle * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) LAYERS_BASE_NAME) - 216))(hook, rport, rect, (struct Library *) LAYERS_BASE_NAME)

#endif /*  _INLINE_LAYERS_H  */
