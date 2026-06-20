#ifndef _INLINE_WARP3D_H
#define _INLINE_WARP3D_H

#ifndef WARP3D_BASE_NAME
#define WARP3D_BASE_NAME Warp3DBase
#endif

#define W3D_CreateContext(error, taglist) \
	((W3D_Context    * (*)(ULONG * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 30))(error, taglist, (struct Library *) WARP3D_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define W3D_CreateContextTags(error, tags...) \
	({ULONG _tags[] = {tags}; W3D_CreateContext((error), (Tag) _tags);})
#endif

#define W3D_DestroyContext(context) \
	((void (*)(W3D_Context * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 36))(context, (struct Library *) WARP3D_BASE_NAME)

#define W3D_GetState(context, state) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 42))(context, state, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetState(context, state, action) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 48))(context, state, action, (struct Library *) WARP3D_BASE_NAME)

#define W3D_CheckDriver() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 54))((struct Library *) WARP3D_BASE_NAME)

#define W3D_LockHardware(context) \
	((ULONG (*)(W3D_Context * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 60))(context, (struct Library *) WARP3D_BASE_NAME)

#define W3D_UnLockHardware(context) \
	((void (*)(W3D_Context * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 66))(context, (struct Library *) WARP3D_BASE_NAME)

#define W3D_WaitIdle(context) \
	((void (*)(W3D_Context * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 72))(context, (struct Library *) WARP3D_BASE_NAME)

#define W3D_CheckIdle(context) \
	((ULONG (*)(W3D_Context * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 78))(context, (struct Library *) WARP3D_BASE_NAME)

#define W3D_Query(context, query, destfmt) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 84))(context, query, destfmt, (struct Library *) WARP3D_BASE_NAME)

#define W3D_GetTexFmtInfo(context, format, destfmt) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 90))(context, format, destfmt, (struct Library *) WARP3D_BASE_NAME)

#define W3D_AllocTexObj(context, error, taglist) \
	((W3D_Texture    * (*)(W3D_Context * __asm("a0"), ULONG * __asm("a1"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 96))(context, error, taglist, (struct Library *) WARP3D_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define W3D_AllocTexObjTags(context, error, tags...) \
	({ULONG _tags[] = {tags}; W3D_AllocTexObj((context), (error), (Tag) _tags);})
#endif

#define W3D_FreeTexObj(context, texture) \
	((void (*)(W3D_Context * __asm("a0"), W3D_Texture * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 102))(context, texture, (struct Library *) WARP3D_BASE_NAME)

#define W3D_ReleaseTexture(context, texture) \
	((void (*)(W3D_Context * __asm("a0"), W3D_Texture * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 108))(context, texture, (struct Library *) WARP3D_BASE_NAME)

#define W3D_FlushTextures(context) \
	((void (*)(W3D_Context * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 114))(context, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetFilter(context, texture, min, mag) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Texture * __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 120))(context, texture, min, mag, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetTexEnv(context, texture, envparam, envcolor) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Texture * __asm("a1"), ULONG __asm("d1"), W3D_Color * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 126))(context, texture, envparam, envcolor, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetWrapMode(context, texture, mode__s, mode__t, bordercolor) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Texture * __asm("a1"), ULONG __asm("d0"), ULONG mode_t __asm("d1"), W3D_Color * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 132))(context, texture, mode__s, mode__t, bordercolor, (struct Library *) WARP3D_BASE_NAME)

#define W3D_UpdateTexImage(context, texture, teximage, level, palette) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Texture * __asm("a1"), void * __asm("a2"), int __asm("d1"), ULONG * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 138))(context, texture, teximage, level, palette, (struct Library *) WARP3D_BASE_NAME)

#define W3D_UploadTexture(context, texture) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Texture * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 144))(context, texture, (struct Library *) WARP3D_BASE_NAME)

#define W3D_DrawLine(context, line) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Line * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 150))(context, line, (struct Library *) WARP3D_BASE_NAME)

#define W3D_DrawPoint(context, point) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Point * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 156))(context, point, (struct Library *) WARP3D_BASE_NAME)

#define W3D_DrawTriangle(context, triangle) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Triangle * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 162))(context, triangle, (struct Library *) WARP3D_BASE_NAME)

#define W3D_DrawTriFan(context, triangles) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Triangles * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 168))(context, triangles, (struct Library *) WARP3D_BASE_NAME)

#define W3D_DrawTriStrip(context, triangles) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Triangles * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 174))(context, triangles, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetAlphaMode(context, mode, refval) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d1"), W3D_Float * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 180))(context, mode, refval, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetBlendMode(context, srcfunc, dstfunc) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 186))(context, srcfunc, dstfunc, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetDrawRegion(context, bm, yoffset, scissor) \
	((ULONG (*)(W3D_Context * __asm("a0"), struct BitMap * __asm("a1"), int __asm("d1"), W3D_Scissor * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 192))(context, bm, yoffset, scissor, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetFogParams(context, fogparams, fogmode) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Fog * __asm("a1"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 198))(context, fogparams, fogmode, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetColorMask(context, red, green, blue, alpha) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Bool __asm("d0"), W3D_Bool __asm("d1"), W3D_Bool __asm("d2"), W3D_Bool __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 204))(context, red, green, blue, alpha, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetStencilFunc(context, func, refvalue, mask) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 210))(context, func, refvalue, mask, (struct Library *) WARP3D_BASE_NAME)

#define W3D_AllocZBuffer(context) \
	((ULONG (*)(W3D_Context * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 216))(context, (struct Library *) WARP3D_BASE_NAME)

#define W3D_FreeZBuffer(context) \
	((ULONG (*)(W3D_Context * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 222))(context, (struct Library *) WARP3D_BASE_NAME)

#define W3D_ClearZBuffer(context, clearvalue) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Double * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 228))(context, clearvalue, (struct Library *) WARP3D_BASE_NAME)

#define W3D_ReadZPixel(context, x, y, z) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), W3D_Double * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 234))(context, x, y, z, (struct Library *) WARP3D_BASE_NAME)

#define W3D_ReadZSpan(context, x, y, n, z) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), W3D_Double __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 240))(context, x, y, n, z, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetZCompareMode(context, mode) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 246))(context, mode, (struct Library *) WARP3D_BASE_NAME)

#define W3D_AllocStencilBuffer(context) \
	((ULONG (*)(W3D_Context * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 252))(context, (struct Library *) WARP3D_BASE_NAME)

#define W3D_ClearStencilBuffer(context, clearval) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 258))(context, clearval, (struct Library *) WARP3D_BASE_NAME)

#define W3D_FillStencilBuffer(context, x, y, width, height, depth, data) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), void * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 264))(context, x, y, width, height, depth, data, (struct Library *) WARP3D_BASE_NAME)

#define W3D_FreeStencilBuffer(context) \
	((ULONG (*)(W3D_Context * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 270))(context, (struct Library *) WARP3D_BASE_NAME)

#define W3D_ReadStencilPixel(context, x, y, st) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 276))(context, x, y, st, (struct Library *) WARP3D_BASE_NAME)

#define W3D_ReadStencilSpan(context, x, y, n, st) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 282))(context, x, y, n, st, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetLogicOp(context, operation) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 288))(context, operation, (struct Library *) WARP3D_BASE_NAME)

#define W3D_Hint(context, mode, quality) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 294))(context, mode, quality, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetDrawRegionWBM(context, bitmap, scissor) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Bitmap * __asm("a1"), W3D_Scissor * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 300))(context, bitmap, scissor, (struct Library *) WARP3D_BASE_NAME)

#define W3D_GetDriverState(context) \
	((ULONG (*)(W3D_Context * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 306))(context, (struct Library *) WARP3D_BASE_NAME)

#define W3D_Flush(context) \
	((ULONG (*)(W3D_Context * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 312))(context, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetPenMask(context, pen) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 318))(context, pen, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetStencilOp(context, sfail, dpfail, dppass) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 324))(context, sfail, dpfail, dppass, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetWriteMask(context, mask) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 330))(context, mask, (struct Library *) WARP3D_BASE_NAME)

#define W3D_WriteStencilPixel(context, x, y, st) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 336))(context, x, y, st, (struct Library *) WARP3D_BASE_NAME)

#define W3D_WriteStencilSpan(context, x, y, n, st, mask) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("a1"), UBYTE __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 342))(context, x, y, n, st, mask, (struct Library *) WARP3D_BASE_NAME)

#define W3D_WriteZPixel(context, x, y, z) \
	((void (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), W3D_Double * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 348))(context, x, y, z, (struct Library *) WARP3D_BASE_NAME)

#define W3D_WriteZSpan(context, x, y, n, z, maks) \
	((void (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), W3D_Double __asm("a1"), UBYTE __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 354))(context, x, y, n, z, maks, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetCurrentColor(context, color) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Color * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 360))(context, color, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetCurrentPen(context, pen) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 366))(context, pen, (struct Library *) WARP3D_BASE_NAME)

#define W3D_UpdateTexSubImage(context, texture, teximage, lev, palette, scissor, srcbpr) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Texture * __asm("a1"), void * __asm("a2"), ULONG __asm("d1"), ULONG * __asm("a3"), W3D_Scissor* __asm("a4"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 372))(context, texture, teximage, lev, palette, scissor, srcbpr, (struct Library *) WARP3D_BASE_NAME)

#define W3D_FreeAllTexObj(context) \
	((ULONG (*)(W3D_Context * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 378))(context, (struct Library *) WARP3D_BASE_NAME)

#define W3D_GetDestFmt() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 384))((struct Library *) WARP3D_BASE_NAME)

#define W3D_DrawLineStrip(context, lines) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Lines * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 390))(context, lines, (struct Library *) WARP3D_BASE_NAME)

#define W3D_DrawLineLoop(context, lines) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Lines * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 396))(context, lines, (struct Library *) WARP3D_BASE_NAME)

#define W3D_GetDrivers() \
	((W3D_Driver ** (*)(struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 402))((struct Library *) WARP3D_BASE_NAME)

#define W3D_QueryDriver(driver, query, destfmt) \
	((ULONG (*)(W3D_Driver* __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 408))(driver, query, destfmt, (struct Library *) WARP3D_BASE_NAME)

#define W3D_GetDriverTexFmtInfo(driver, format, destfmt) \
	((ULONG (*)(W3D_Driver* __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 414))(driver, format, destfmt, (struct Library *) WARP3D_BASE_NAME)

#define W3D_RequestMode(taglist) \
	((ULONG (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 420))(taglist, (struct Library *) WARP3D_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define W3D_RequestModeTags(tags...) \
	({ULONG _tags[] = {tags}; W3D_RequestMode((Tag) _tags);})
#endif

#define W3D_SetScissor(context, scissor) \
	((void (*)(W3D_Context * __asm("a0"), W3D_Scissor * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 426))(context, scissor, (struct Library *) WARP3D_BASE_NAME)

#define W3D_FlushFrame(context) \
	((void (*)(W3D_Context * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 432))(context, (struct Library *) WARP3D_BASE_NAME)

#define W3D_TestMode(ModeID) \
	((W3D_Driver * (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 438))(ModeID, (struct Library *) WARP3D_BASE_NAME)

#define W3D_SetChromaTestBounds(context, texture, rgba_lower, rgba_upper, mode) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_Texture * __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 444))(context, texture, rgba_lower, rgba_upper, mode, (struct Library *) WARP3D_BASE_NAME)

#define W3D_ClearDrawRegion(context, color) \
	((ULONG (*)(W3D_Context * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 450))(context, color, (struct Library *) WARP3D_BASE_NAME)

#define W3D_DrawTriangleV(context, triangle) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_TriangleV * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 456))(context, triangle, (struct Library *) WARP3D_BASE_NAME)

#define W3D_DrawTriFanV(context, triangles) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_TrianglesV * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 462))(context, triangles, (struct Library *) WARP3D_BASE_NAME)

#define W3D_DrawTriStripV(context, triangles) \
	((ULONG (*)(W3D_Context * __asm("a0"), W3D_TrianglesV * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 468))(context, triangles, (struct Library *) WARP3D_BASE_NAME)

#define W3D_GetScreenmodeList() \
	((W3D_ScreenMode * (*)(struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 474))((struct Library *) WARP3D_BASE_NAME)

#define W3D_FreeScreenmodeList(list) \
	((void (*)(W3D_ScreenMode * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 480))(list, (struct Library *) WARP3D_BASE_NAME)

#define W3D_BestModeID(taglist) \
	((ULONG (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WARP3D_BASE_NAME) - 486))(taglist, (struct Library *) WARP3D_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define W3D_BestModeIDTags(tags...) \
	({ULONG _tags[] = {tags}; W3D_BestModeID((Tag) _tags);})
#endif

#endif /*  _INLINE_WARP3D_H  */
