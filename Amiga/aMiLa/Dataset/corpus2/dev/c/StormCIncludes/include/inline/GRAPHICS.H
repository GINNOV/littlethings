#ifndef _INLINE_GRAPHICS_H
#define _INLINE_GRAPHICS_H

#ifndef GRAPHICS_BASE_NAME
#define GRAPHICS_BASE_NAME GfxBase
#endif

#define BltBitMap(srcBitMap, xSrc, ySrc, destBitMap, xDest, yDest, xSize, ySize, minterm, mask, tempA) \
	((LONG (*)(CONST struct BitMap * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct BitMap * __asm("a1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), LONG __asm("d5"), ULONG __asm("d6"), ULONG __asm("d7"), PLANEPTR __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 30))(srcBitMap, xSrc, ySrc, destBitMap, xDest, yDest, xSize, ySize, minterm, mask, tempA, (struct Library *) GRAPHICS_BASE_NAME)

#define BltTemplate(source, xSrc, srcMod, destRP, xDest, yDest, xSize, ySize) \
	((VOID (*)(CONST PLANEPTR __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct RastPort * __asm("a1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), LONG __asm("d5"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 36))(source, xSrc, srcMod, destRP, xDest, yDest, xSize, ySize, (struct Library *) GRAPHICS_BASE_NAME)

#define ClearEOL(rp) \
	((VOID (*)(struct RastPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 42))(rp, (struct Library *) GRAPHICS_BASE_NAME)

#define ClearScreen(rp) \
	((VOID (*)(struct RastPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 48))(rp, (struct Library *) GRAPHICS_BASE_NAME)

#define TextLength(rp, string, count) \
	((WORD (*)(struct RastPort * __asm("a1"), CONST_STRPTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 54))(rp, string, count, (struct Library *) GRAPHICS_BASE_NAME)

#define Text(rp, string, count) \
	((LONG (*)(struct RastPort * __asm("a1"), CONST_STRPTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 60))(rp, string, count, (struct Library *) GRAPHICS_BASE_NAME)

#define SetFont(rp, textFont) \
	((LONG (*)(struct RastPort * __asm("a1"), CONST struct TextFont * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 66))(rp, textFont, (struct Library *) GRAPHICS_BASE_NAME)

#define OpenFont(textAttr) \
	((struct TextFont * (*)(struct TextAttr * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 72))(textAttr, (struct Library *) GRAPHICS_BASE_NAME)

#define CloseFont(textFont) \
	((VOID (*)(struct TextFont * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 78))(textFont, (struct Library *) GRAPHICS_BASE_NAME)

#define AskSoftStyle(rp) \
	((ULONG (*)(struct RastPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 84))(rp, (struct Library *) GRAPHICS_BASE_NAME)

#define SetSoftStyle(rp, style, enable) \
	((ULONG (*)(struct RastPort * __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 90))(rp, style, enable, (struct Library *) GRAPHICS_BASE_NAME)

#define AddBob(bob, rp) \
	((VOID (*)(struct Bob * __asm("a0"), struct RastPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 96))(bob, rp, (struct Library *) GRAPHICS_BASE_NAME)

#define AddVSprite(vSprite, rp) \
	((VOID (*)(struct VSprite * __asm("a0"), struct RastPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 102))(vSprite, rp, (struct Library *) GRAPHICS_BASE_NAME)

#define DoCollision(rp) \
	((VOID (*)(struct RastPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 108))(rp, (struct Library *) GRAPHICS_BASE_NAME)

#define DrawGList(rp, vp) \
	((VOID (*)(struct RastPort * __asm("a1"), struct ViewPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 114))(rp, vp, (struct Library *) GRAPHICS_BASE_NAME)

#define InitGels(head, tail, gelsInfo) \
	((VOID (*)(struct VSprite * __asm("a0"), struct VSprite * __asm("a1"), struct GelsInfo * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 120))(head, tail, gelsInfo, (struct Library *) GRAPHICS_BASE_NAME)

#define InitMasks(vSprite) \
	((VOID (*)(struct VSprite * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 126))(vSprite, (struct Library *) GRAPHICS_BASE_NAME)

#define RemIBob(bob, rp, vp) \
	((VOID (*)(struct Bob * __asm("a0"), struct RastPort * __asm("a1"), struct ViewPort * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 132))(bob, rp, vp, (struct Library *) GRAPHICS_BASE_NAME)

#define RemVSprite(vSprite) \
	((VOID (*)(struct VSprite * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 138))(vSprite, (struct Library *) GRAPHICS_BASE_NAME)

#define SetCollision(num, routine, gelsInfo) \
	((VOID (*)(ULONG __asm("d0"), VOID (*)(struct VSprite *gelA, struct VSprite *gelB) __asm("a0"), struct GelsInfo * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 144))(num, routine, gelsInfo, (struct Library *) GRAPHICS_BASE_NAME)

#define SortGList(rp) \
	((VOID (*)(struct RastPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 150))(rp, (struct Library *) GRAPHICS_BASE_NAME)

#define AddAnimOb(anOb, anKey, rp) \
	((VOID (*)(struct AnimOb * __asm("a0"), struct AnimOb ** __asm("a1"), struct RastPort * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 156))(anOb, anKey, rp, (struct Library *) GRAPHICS_BASE_NAME)

#define Animate(anKey, rp) \
	((VOID (*)(struct AnimOb ** __asm("a0"), struct RastPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 162))(anKey, rp, (struct Library *) GRAPHICS_BASE_NAME)

#define GetGBuffers(anOb, rp, flag) \
	((BOOL (*)(struct AnimOb * __asm("a0"), struct RastPort * __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 168))(anOb, rp, flag, (struct Library *) GRAPHICS_BASE_NAME)

#define InitGMasks(anOb) \
	((VOID (*)(struct AnimOb * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 174))(anOb, (struct Library *) GRAPHICS_BASE_NAME)

#define DrawEllipse(rp, xCenter, yCenter, a, b) \
	((VOID (*)(struct RastPort * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 180))(rp, xCenter, yCenter, a, b, (struct Library *) GRAPHICS_BASE_NAME)

#define AreaEllipse(rp, xCenter, yCenter, a, b) \
	((LONG (*)(struct RastPort * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 186))(rp, xCenter, yCenter, a, b, (struct Library *) GRAPHICS_BASE_NAME)

#define LoadRGB4(vp, colors, count) \
	((VOID (*)(struct ViewPort * __asm("a0"), CONST UWORD * __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 192))(vp, colors, count, (struct Library *) GRAPHICS_BASE_NAME)

#define InitRastPort(rp) \
	((VOID (*)(struct RastPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 198))(rp, (struct Library *) GRAPHICS_BASE_NAME)

#define InitVPort(vp) \
	((VOID (*)(struct ViewPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 204))(vp, (struct Library *) GRAPHICS_BASE_NAME)

#define MrgCop(view) \
	((ULONG (*)(struct View * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 210))(view, (struct Library *) GRAPHICS_BASE_NAME)

#define MakeVPort(view, vp) \
	((ULONG (*)(struct View * __asm("a0"), struct ViewPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 216))(view, vp, (struct Library *) GRAPHICS_BASE_NAME)

#define LoadView(view) \
	((VOID (*)(struct View * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 222))(view, (struct Library *) GRAPHICS_BASE_NAME)

#define WaitBlit() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 228))((struct Library *) GRAPHICS_BASE_NAME)

#define SetRast(rp, pen) \
	((VOID (*)(struct RastPort * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 234))(rp, pen, (struct Library *) GRAPHICS_BASE_NAME)

#define Move(rp, x, y) \
	((VOID (*)(struct RastPort * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 240))(rp, x, y, (struct Library *) GRAPHICS_BASE_NAME)

#define Draw(rp, x, y) \
	((VOID (*)(struct RastPort * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 246))(rp, x, y, (struct Library *) GRAPHICS_BASE_NAME)

#define AreaMove(rp, x, y) \
	((LONG (*)(struct RastPort * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 252))(rp, x, y, (struct Library *) GRAPHICS_BASE_NAME)

#define AreaDraw(rp, x, y) \
	((LONG (*)(struct RastPort * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 258))(rp, x, y, (struct Library *) GRAPHICS_BASE_NAME)

#define AreaEnd(rp) \
	((LONG (*)(struct RastPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 264))(rp, (struct Library *) GRAPHICS_BASE_NAME)

#define WaitTOF() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 270))((struct Library *) GRAPHICS_BASE_NAME)

#define QBlit(blit) \
	((VOID (*)(struct bltnode * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 276))(blit, (struct Library *) GRAPHICS_BASE_NAME)

#define InitArea(areaInfo, vectorBuffer, maxVectors) \
	((VOID (*)(struct AreaInfo * __asm("a0"), APTR __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 282))(areaInfo, vectorBuffer, maxVectors, (struct Library *) GRAPHICS_BASE_NAME)

#define SetRGB4(vp, index, red, green, blue) \
	((VOID (*)(struct ViewPort * __asm("a0"), LONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 288))(vp, index, red, green, blue, (struct Library *) GRAPHICS_BASE_NAME)

#define QBSBlit(blit) \
	((VOID (*)(struct bltnode * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 294))(blit, (struct Library *) GRAPHICS_BASE_NAME)

#define BltClear(memBlock, byteCount, flags) \
	((VOID (*)(PLANEPTR __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 300))(memBlock, byteCount, flags, (struct Library *) GRAPHICS_BASE_NAME)

#define RectFill(rp, xMin, yMin, xMax, yMax) \
	((VOID (*)(struct RastPort * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 306))(rp, xMin, yMin, xMax, yMax, (struct Library *) GRAPHICS_BASE_NAME)

#define BltPattern(rp, mask, xMin, yMin, xMax, yMax, maskBPR) \
	((VOID (*)(struct RastPort * __asm("a1"), CONST PLANEPTR __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), ULONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 312))(rp, mask, xMin, yMin, xMax, yMax, maskBPR, (struct Library *) GRAPHICS_BASE_NAME)

#define ReadPixel(rp, x, y) \
	((ULONG (*)(struct RastPort * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 318))(rp, x, y, (struct Library *) GRAPHICS_BASE_NAME)

#define WritePixel(rp, x, y) \
	((LONG (*)(struct RastPort * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 324))(rp, x, y, (struct Library *) GRAPHICS_BASE_NAME)

#define Flood(rp, mode, x, y) \
	((BOOL (*)(struct RastPort * __asm("a1"), ULONG __asm("d2"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 330))(rp, mode, x, y, (struct Library *) GRAPHICS_BASE_NAME)

#define PolyDraw(rp, count, polyTable) \
	((VOID (*)(struct RastPort * __asm("a1"), LONG __asm("d0"), CONST WORD * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 336))(rp, count, polyTable, (struct Library *) GRAPHICS_BASE_NAME)

#define SetAPen(rp, pen) \
	((VOID (*)(struct RastPort * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 342))(rp, pen, (struct Library *) GRAPHICS_BASE_NAME)

#define SetBPen(rp, pen) \
	((VOID (*)(struct RastPort * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 348))(rp, pen, (struct Library *) GRAPHICS_BASE_NAME)

#define SetDrMd(rp, drawMode) \
	((VOID (*)(struct RastPort * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 354))(rp, drawMode, (struct Library *) GRAPHICS_BASE_NAME)

#define InitView(view) \
	((VOID (*)(struct View * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 360))(view, (struct Library *) GRAPHICS_BASE_NAME)

#define CBump(copList) \
	((VOID (*)(struct UCopList * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 366))(copList, (struct Library *) GRAPHICS_BASE_NAME)

#define CMove(copList, destination, data) \
	((VOID (*)(struct UCopList * __asm("a1"), APTR __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 372))(copList, destination, data, (struct Library *) GRAPHICS_BASE_NAME)

#define CWait(copList, v, h) \
	((VOID (*)(struct UCopList * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 378))(copList, v, h, (struct Library *) GRAPHICS_BASE_NAME)

#define VBeamPos() \
	((LONG (*)(struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 384))((struct Library *) GRAPHICS_BASE_NAME)

#define InitBitMap(bitMap, depth, width, height) \
	((VOID (*)(struct BitMap * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 390))(bitMap, depth, width, height, (struct Library *) GRAPHICS_BASE_NAME)

#define ScrollRaster(rp, dx, dy, xMin, yMin, xMax, yMax) \
	((VOID (*)(struct RastPort * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), LONG __asm("d5"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 396))(rp, dx, dy, xMin, yMin, xMax, yMax, (struct Library *) GRAPHICS_BASE_NAME)

#define WaitBOVP(vp) \
	((VOID (*)(struct ViewPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 402))(vp, (struct Library *) GRAPHICS_BASE_NAME)

#define GetSprite(sprite, num) \
	((WORD (*)(struct SimpleSprite * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 408))(sprite, num, (struct Library *) GRAPHICS_BASE_NAME)

#define FreeSprite(num) \
	((VOID (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 414))(num, (struct Library *) GRAPHICS_BASE_NAME)

#define ChangeSprite(vp, sprite, newData) \
	((VOID (*)(struct ViewPort * __asm("a0"), struct SimpleSprite * __asm("a1"), UWORD * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 420))(vp, sprite, newData, (struct Library *) GRAPHICS_BASE_NAME)

#define MoveSprite(vp, sprite, x, y) \
	((VOID (*)(struct ViewPort * __asm("a0"), struct SimpleSprite * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 426))(vp, sprite, x, y, (struct Library *) GRAPHICS_BASE_NAME)

#define LockLayerRom(layer) \
	((VOID (*)(struct Layer * __asm("a5"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 432))(layer, (struct Library *) GRAPHICS_BASE_NAME)

#define UnlockLayerRom(layer) \
	((VOID (*)(struct Layer * __asm("a5"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 438))(layer, (struct Library *) GRAPHICS_BASE_NAME)

#define SyncSBitMap(layer) \
	((VOID (*)(struct Layer * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 444))(layer, (struct Library *) GRAPHICS_BASE_NAME)

#define CopySBitMap(layer) \
	((VOID (*)(struct Layer * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 450))(layer, (struct Library *) GRAPHICS_BASE_NAME)

#define OwnBlitter() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 456))((struct Library *) GRAPHICS_BASE_NAME)

#define DisownBlitter() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 462))((struct Library *) GRAPHICS_BASE_NAME)

#define InitTmpRas(tmpRas, buffer, size) \
	((struct TmpRas * (*)(struct TmpRas * __asm("a0"), PLANEPTR __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 468))(tmpRas, buffer, size, (struct Library *) GRAPHICS_BASE_NAME)

#define AskFont(rp, textAttr) \
	((VOID (*)(struct RastPort * __asm("a1"), struct TextAttr * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 474))(rp, textAttr, (struct Library *) GRAPHICS_BASE_NAME)

#define AddFont(textFont) \
	((VOID (*)(struct TextFont * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 480))(textFont, (struct Library *) GRAPHICS_BASE_NAME)

#define RemFont(textFont) \
	((VOID (*)(struct TextFont * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 486))(textFont, (struct Library *) GRAPHICS_BASE_NAME)

#define AllocRaster(width, height) \
	((PLANEPTR (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 492))(width, height, (struct Library *) GRAPHICS_BASE_NAME)

#define FreeRaster(p, width, height) \
	((VOID (*)(PLANEPTR __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 498))(p, width, height, (struct Library *) GRAPHICS_BASE_NAME)

#define AndRectRegion(region, rectangle) \
	((VOID (*)(struct Region * __asm("a0"), CONST struct Rectangle * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 504))(region, rectangle, (struct Library *) GRAPHICS_BASE_NAME)

#define OrRectRegion(region, rectangle) \
	((BOOL (*)(struct Region * __asm("a0"), CONST struct Rectangle * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 510))(region, rectangle, (struct Library *) GRAPHICS_BASE_NAME)

#define NewRegion() \
	((struct Region * (*)(struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 516))((struct Library *) GRAPHICS_BASE_NAME)

#define ClearRectRegion(region, rectangle) \
	((BOOL (*)(struct Region * __asm("a0"), CONST struct Rectangle * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 522))(region, rectangle, (struct Library *) GRAPHICS_BASE_NAME)

#define ClearRegion(region) \
	((VOID (*)(struct Region * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 528))(region, (struct Library *) GRAPHICS_BASE_NAME)

#define DisposeRegion(region) \
	((VOID (*)(struct Region * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 534))(region, (struct Library *) GRAPHICS_BASE_NAME)

#define FreeVPortCopLists(vp) \
	((VOID (*)(struct ViewPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 540))(vp, (struct Library *) GRAPHICS_BASE_NAME)

#define FreeCopList(copList) \
	((VOID (*)(struct CopList * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 546))(copList, (struct Library *) GRAPHICS_BASE_NAME)

#define ClipBlit(srcRP, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm) \
	((VOID (*)(struct RastPort * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct RastPort * __asm("a1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), LONG __asm("d5"), ULONG __asm("d6"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 552))(srcRP, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm, (struct Library *) GRAPHICS_BASE_NAME)

#define XorRectRegion(region, rectangle) \
	((BOOL (*)(struct Region * __asm("a0"), CONST struct Rectangle * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 558))(region, rectangle, (struct Library *) GRAPHICS_BASE_NAME)

#define FreeCprList(cprList) \
	((VOID (*)(struct cprlist * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 564))(cprList, (struct Library *) GRAPHICS_BASE_NAME)

#define GetColorMap(entries) \
	((struct ColorMap * (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 570))(entries, (struct Library *) GRAPHICS_BASE_NAME)

#define FreeColorMap(colorMap) \
	((VOID (*)(struct ColorMap * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 576))(colorMap, (struct Library *) GRAPHICS_BASE_NAME)

#define GetRGB4(colorMap, entry) \
	((ULONG (*)(struct ColorMap * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 582))(colorMap, entry, (struct Library *) GRAPHICS_BASE_NAME)

#define ScrollVPort(vp) \
	((VOID (*)(struct ViewPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 588))(vp, (struct Library *) GRAPHICS_BASE_NAME)

#define UCopperListInit(uCopList, n) \
	((struct CopList * (*)(struct UCopList * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 594))(uCopList, n, (struct Library *) GRAPHICS_BASE_NAME)

#define FreeGBuffers(anOb, rp, flag) \
	((VOID (*)(struct AnimOb * __asm("a0"), struct RastPort * __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 600))(anOb, rp, flag, (struct Library *) GRAPHICS_BASE_NAME)

#define BltBitMapRastPort(srcBitMap, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm) \
	((VOID (*)(CONST struct BitMap * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct RastPort * __asm("a1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), LONG __asm("d5"), ULONG __asm("d6"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 606))(srcBitMap, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm, (struct Library *) GRAPHICS_BASE_NAME)

#define OrRegionRegion(srcRegion, destRegion) \
	((BOOL (*)(CONST struct Region * __asm("a0"), struct Region * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 612))(srcRegion, destRegion, (struct Library *) GRAPHICS_BASE_NAME)

#define XorRegionRegion(srcRegion, destRegion) \
	((BOOL (*)(CONST struct Region * __asm("a0"), struct Region * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 618))(srcRegion, destRegion, (struct Library *) GRAPHICS_BASE_NAME)

#define AndRegionRegion(srcRegion, destRegion) \
	((BOOL (*)(CONST struct Region * __asm("a0"), struct Region * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 624))(srcRegion, destRegion, (struct Library *) GRAPHICS_BASE_NAME)

#define SetRGB4CM(colorMap, index, red, green, blue) \
	((VOID (*)(struct ColorMap * __asm("a0"), LONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 630))(colorMap, index, red, green, blue, (struct Library *) GRAPHICS_BASE_NAME)

#define BltMaskBitMapRastPort(srcBitMap, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm, bltMask) \
	((VOID (*)(CONST struct BitMap * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct RastPort * __asm("a1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), LONG __asm("d5"), ULONG __asm("d6"), CONST PLANEPTR __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 636))(srcBitMap, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm, bltMask, (struct Library *) GRAPHICS_BASE_NAME)

#define AttemptLockLayerRom(layer) \
	((BOOL (*)(struct Layer * __asm("a5"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 654))(layer, (struct Library *) GRAPHICS_BASE_NAME)

#define GfxNew(gfxNodeType) \
	((APTR (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 660))(gfxNodeType, (struct Library *) GRAPHICS_BASE_NAME)

#define GfxFree(gfxNodePtr) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 666))(gfxNodePtr, (struct Library *) GRAPHICS_BASE_NAME)

#define GfxAssociate(associateNode, gfxNodePtr) \
	((VOID (*)(CONST APTR __asm("a0"), APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 672))(associateNode, gfxNodePtr, (struct Library *) GRAPHICS_BASE_NAME)

#define BitMapScale(bitScaleArgs) \
	((VOID (*)(struct BitScaleArgs * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 678))(bitScaleArgs, (struct Library *) GRAPHICS_BASE_NAME)

#define ScalerDiv(factor, numerator, denominator) \
	((UWORD (*)(ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 684))(factor, numerator, denominator, (struct Library *) GRAPHICS_BASE_NAME)

#define TextExtent(rp, string, count, textExtent) \
	((WORD (*)(struct RastPort * __asm("a1"), CONST_STRPTR __asm("a0"), LONG __asm("d0"), struct TextExtent * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 690))(rp, string, count, textExtent, (struct Library *) GRAPHICS_BASE_NAME)

#define TextFit(rp, string, strLen, textExtent, constrainingExtent, strDirection, constrainingBitWidth, constrainingBitHeight) \
	((ULONG (*)(struct RastPort * __asm("a1"), CONST_STRPTR __asm("a0"), ULONG __asm("d0"), CONST struct TextExtent * __asm("a2"), CONST struct TextExtent * __asm("a3"), LONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 696))(rp, string, strLen, textExtent, constrainingExtent, strDirection, constrainingBitWidth, constrainingBitHeight, (struct Library *) GRAPHICS_BASE_NAME)

#define GfxLookUp(associateNode) \
	((APTR (*)(CONST APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 702))(associateNode, (struct Library *) GRAPHICS_BASE_NAME)

#define VideoControl(colorMap, tagarray) \
	((BOOL (*)(struct ColorMap * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 708))(colorMap, tagarray, (struct Library *) GRAPHICS_BASE_NAME)

#define OpenMonitor(monitorName, displayID) \
	((struct MonitorSpec * (*)(CONST_STRPTR __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 714))(monitorName, displayID, (struct Library *) GRAPHICS_BASE_NAME)

#define CloseMonitor(monitorSpec) \
	((BOOL (*)(struct MonitorSpec * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 720))(monitorSpec, (struct Library *) GRAPHICS_BASE_NAME)

#define FindDisplayInfo(displayID) \
	((DisplayInfoHandle (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 726))(displayID, (struct Library *) GRAPHICS_BASE_NAME)

#define NextDisplayInfo(displayID) \
	((ULONG (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 732))(displayID, (struct Library *) GRAPHICS_BASE_NAME)

#define GetDisplayInfoData(handle, buf, size, tagID, displayID) \
	((ULONG (*)(CONST DisplayInfoHandle __asm("a0"), APTR __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 756))(handle, buf, size, tagID, displayID, (struct Library *) GRAPHICS_BASE_NAME)

#define FontExtent(font, fontExtent) \
	((VOID (*)(CONST struct TextFont * __asm("a0"), struct TextExtent * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 762))(font, fontExtent, (struct Library *) GRAPHICS_BASE_NAME)

#define ReadPixelLine8(rp, xstart, ystart, width, array, tempRP) \
	((LONG (*)(struct RastPort * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), UBYTE * __asm("a2"), struct RastPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 768))(rp, xstart, ystart, width, array, tempRP, (struct Library *) GRAPHICS_BASE_NAME)

#define WritePixelLine8(rp, xstart, ystart, width, array, tempRP) \
	((LONG (*)(struct RastPort * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), UBYTE * __asm("a2"), struct RastPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 774))(rp, xstart, ystart, width, array, tempRP, (struct Library *) GRAPHICS_BASE_NAME)

#define ReadPixelArray8(rp, xstart, ystart, xstop, ystop, array, temprp) \
	((LONG (*)(struct RastPort * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), UBYTE * __asm("a2"), struct RastPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 780))(rp, xstart, ystart, xstop, ystop, array, temprp, (struct Library *) GRAPHICS_BASE_NAME)

#define WritePixelArray8(rp, xstart, ystart, xstop, ystop, array, temprp) \
	((LONG (*)(struct RastPort * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), UBYTE * __asm("a2"), struct RastPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 786))(rp, xstart, ystart, xstop, ystop, array, temprp, (struct Library *) GRAPHICS_BASE_NAME)

#define GetVPModeID(vp) \
	((LONG (*)(CONST struct ViewPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 792))(vp, (struct Library *) GRAPHICS_BASE_NAME)

#define ModeNotAvailable(modeID) \
	((LONG (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 798))(modeID, (struct Library *) GRAPHICS_BASE_NAME)

#define EraseRect(rp, xMin, yMin, xMax, yMax) \
	((VOID (*)(struct RastPort * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 810))(rp, xMin, yMin, xMax, yMax, (struct Library *) GRAPHICS_BASE_NAME)

#define ExtendFont(font, fontTags) \
	((ULONG (*)(struct TextFont * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 816))(font, fontTags, (struct Library *) GRAPHICS_BASE_NAME)

#define StripFont(font) \
	((VOID (*)(struct TextFont * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 822))(font, (struct Library *) GRAPHICS_BASE_NAME)

#define CalcIVG(v, vp) \
	((UWORD (*)(struct View * __asm("a0"), struct ViewPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 828))(v, vp, (struct Library *) GRAPHICS_BASE_NAME)

#define AttachPalExtra(cm, vp) \
	((LONG (*)(struct ColorMap * __asm("a0"), struct ViewPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 834))(cm, vp, (struct Library *) GRAPHICS_BASE_NAME)

#define ObtainBestPenA(cm, r, g, b, tags) \
	((LONG (*)(struct ColorMap * __asm("a0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 840))(cm, r, g, b, tags, (struct Library *) GRAPHICS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define ObtainBestPen(cm, r, g, b, tags...) \
	({ULONG _tags[] = {tags}; ObtainBestPenA((cm), (r), (g), (b), (ULONG) _tags);})
#endif

#define SetRGB32(vp, n, r, g, b) \
	((VOID (*)(struct ViewPort * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 852))(vp, n, r, g, b, (struct Library *) GRAPHICS_BASE_NAME)

#define GetAPen(rp) \
	((ULONG (*)(struct RastPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 858))(rp, (struct Library *) GRAPHICS_BASE_NAME)

#define GetBPen(rp) \
	((ULONG (*)(struct RastPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 864))(rp, (struct Library *) GRAPHICS_BASE_NAME)

#define GetDrMd(rp) \
	((ULONG (*)(struct RastPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 870))(rp, (struct Library *) GRAPHICS_BASE_NAME)

#define GetOutlinePen(rp) \
	((ULONG (*)(struct RastPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 876))(rp, (struct Library *) GRAPHICS_BASE_NAME)

#define LoadRGB32(vp, table) \
	((VOID (*)(struct ViewPort * __asm("a0"), CONST ULONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 882))(vp, table, (struct Library *) GRAPHICS_BASE_NAME)

#define SetChipRev(want) \
	((ULONG (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 888))(want, (struct Library *) GRAPHICS_BASE_NAME)

#define SetABPenDrMd(rp, apen, bpen, drawmode) \
	((VOID (*)(struct RastPort * __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 894))(rp, apen, bpen, drawmode, (struct Library *) GRAPHICS_BASE_NAME)

#define GetRGB32(cm, firstcolor, ncolors, table) \
	((VOID (*)(CONST struct ColorMap * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 900))(cm, firstcolor, ncolors, table, (struct Library *) GRAPHICS_BASE_NAME)

#define AllocBitMap(sizex, sizey, depth, flags, friend_bitmap) \
	((struct BitMap * (*)(ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), CONST struct BitMap * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 918))(sizex, sizey, depth, flags, friend_bitmap, (struct Library *) GRAPHICS_BASE_NAME)

#define FreeBitMap(bm) \
	((VOID (*)(struct BitMap * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 924))(bm, (struct Library *) GRAPHICS_BASE_NAME)

#define GetExtSpriteA(ss, tags) \
	((LONG (*)(struct ExtSprite * __asm("a2"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 930))(ss, tags, (struct Library *) GRAPHICS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetExtSprite(ss, tags...) \
	({ULONG _tags[] = {tags}; GetExtSpriteA((ss), (ULONG) _tags);})
#endif

#define CoerceMode(vp, monitorid, flags) \
	((ULONG (*)(struct ViewPort * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 936))(vp, monitorid, flags, (struct Library *) GRAPHICS_BASE_NAME)

#define ChangeVPBitMap(vp, bm, db) \
	((VOID (*)(struct ViewPort * __asm("a0"), struct BitMap * __asm("a1"), struct DBufInfo * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 942))(vp, bm, db, (struct Library *) GRAPHICS_BASE_NAME)

#define ReleasePen(cm, n) \
	((VOID (*)(struct ColorMap * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 948))(cm, n, (struct Library *) GRAPHICS_BASE_NAME)

#define ObtainPen(cm, n, r, g, b, f) \
	((ULONG (*)(struct ColorMap * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), LONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 954))(cm, n, r, g, b, f, (struct Library *) GRAPHICS_BASE_NAME)

#define GetBitMapAttr(bm, attrnum) \
	((ULONG (*)(CONST struct BitMap * __asm("a0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 960))(bm, attrnum, (struct Library *) GRAPHICS_BASE_NAME)

#define AllocDBufInfo(vp) \
	((struct DBufInfo * (*)(struct ViewPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 966))(vp, (struct Library *) GRAPHICS_BASE_NAME)

#define FreeDBufInfo(dbi) \
	((VOID (*)(struct DBufInfo * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 972))(dbi, (struct Library *) GRAPHICS_BASE_NAME)

#define SetOutlinePen(rp, pen) \
	((ULONG (*)(struct RastPort * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 978))(rp, pen, (struct Library *) GRAPHICS_BASE_NAME)

#define SetWriteMask(rp, msk) \
	((ULONG (*)(struct RastPort * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 984))(rp, msk, (struct Library *) GRAPHICS_BASE_NAME)

#define SetMaxPen(rp, maxpen) \
	((VOID (*)(struct RastPort * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 990))(rp, maxpen, (struct Library *) GRAPHICS_BASE_NAME)

#define SetRGB32CM(cm, n, r, g, b) \
	((VOID (*)(struct ColorMap * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 996))(cm, n, r, g, b, (struct Library *) GRAPHICS_BASE_NAME)

#define ScrollRasterBF(rp, dx, dy, xMin, yMin, xMax, yMax) \
	((VOID (*)(struct RastPort * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), LONG __asm("d5"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 1002))(rp, dx, dy, xMin, yMin, xMax, yMax, (struct Library *) GRAPHICS_BASE_NAME)

#define FindColor(cm, r, g, b, maxcolor) \
	((LONG (*)(struct ColorMap * __asm("a3"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), LONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 1008))(cm, r, g, b, maxcolor, (struct Library *) GRAPHICS_BASE_NAME)

#define AllocSpriteDataA(bm, tags) \
	((struct ExtSprite * (*)(CONST struct BitMap * __asm("a2"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 1020))(bm, tags, (struct Library *) GRAPHICS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AllocSpriteData(bm, tags...) \
	({ULONG _tags[] = {tags}; AllocSpriteDataA((bm), (ULONG) _tags);})
#endif

#define ChangeExtSpriteA(vp, oldsprite, newsprite, tags) \
	((LONG (*)(struct ViewPort * __asm("a0"), struct ExtSprite * __asm("a1"), struct ExtSprite * __asm("a2"), CONST struct TagItem * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 1026))(vp, oldsprite, newsprite, tags, (struct Library *) GRAPHICS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define ChangeExtSprite(vp, oldsprite, newsprite, tags...) \
	({ULONG _tags[] = {tags}; ChangeExtSpriteA((vp), (oldsprite), (newsprite), (ULONG) _tags);})
#endif

#define FreeSpriteData(sp) \
	((VOID (*)(struct ExtSprite * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 1032))(sp, (struct Library *) GRAPHICS_BASE_NAME)

#define SetRPAttrsA(rp, tags) \
	((VOID (*)(struct RastPort * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 1038))(rp, tags, (struct Library *) GRAPHICS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetRPAttrs(rp, tags...) \
	({ULONG _tags[] = {tags}; SetRPAttrsA((rp), (ULONG) _tags);})
#endif

#define GetRPAttrsA(rp, tags) \
	((VOID (*)(CONST struct RastPort * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 1044))(rp, tags, (struct Library *) GRAPHICS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetRPAttrs(rp, tags...) \
	({ULONG _tags[] = {tags}; GetRPAttrsA((rp), (ULONG) _tags);})
#endif

#define BestModeIDA(tags) \
	((ULONG (*)(CONST struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 1050))(tags, (struct Library *) GRAPHICS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define BestModeID(tags...) \
	({ULONG _tags[] = {tags}; BestModeIDA((ULONG) _tags);})
#endif

#define WriteChunkyPixels(rp, xstart, ystart, xstop, ystop, array, bytesperrow) \
	((VOID (*)(struct RastPort * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), CONST UBYTE * __asm("a2"), LONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) GRAPHICS_BASE_NAME) - 1056))(rp, xstart, ystart, xstop, ystop, array, bytesperrow, (struct Library *) GRAPHICS_BASE_NAME)

#endif /*  _INLINE_GRAPHICS_H  */
