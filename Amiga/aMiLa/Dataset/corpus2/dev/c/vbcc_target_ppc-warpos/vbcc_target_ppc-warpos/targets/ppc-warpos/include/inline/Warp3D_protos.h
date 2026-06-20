#ifndef _VBCCINLINE_WARP3D_H
#define _VBCCINLINE_WARP3D_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

W3D_Context    * __W3D_CreateContext(ULONG * error, struct TagItem * CCTags)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-28(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_CreateContext(error, CCTags) __W3D_CreateContext((error), (CCTags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
W3D_Context    * __W3D_CreateContextTags(ULONG * error, int dummy, Tag CCTags, ...)="\t.extern\t_Warp3DPPCBase\n\tstw\tr5,32(r1)\n\taddi\tr5,r1,32\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-28(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_CreateContextTags(error, ...) __W3D_CreateContextTags((error), 0, __VA_ARGS__)
#endif

void __W3D_DestroyContext(W3D_Context * context)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-34(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_DestroyContext(context) __W3D_DestroyContext((context))

ULONG __W3D_GetState(W3D_Context * context, ULONG state)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-40(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_GetState(context, state) __W3D_GetState((context), (state))

ULONG __W3D_SetState(W3D_Context * context, ULONG state, ULONG action)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-46(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetState(context, state, action) __W3D_SetState((context), (state), (action))

ULONG __W3D_CheckDriver()="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-52(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_CheckDriver() __W3D_CheckDriver()

ULONG __W3D_LockHardware(W3D_Context * context)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-58(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_LockHardware(context) __W3D_LockHardware((context))

void __W3D_UnLockHardware(W3D_Context * context)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-64(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_UnLockHardware(context) __W3D_UnLockHardware((context))

void __W3D_WaitIdle(W3D_Context * context)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-70(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_WaitIdle(context) __W3D_WaitIdle((context))

ULONG __W3D_CheckIdle(W3D_Context * context)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-76(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_CheckIdle(context) __W3D_CheckIdle((context))

ULONG __W3D_Query(W3D_Context * context, ULONG query, ULONG destfmt)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-82(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_Query(context, query, destfmt) __W3D_Query((context), (query), (destfmt))

ULONG __W3D_GetTexFmtInfo(W3D_Context * context, ULONG format, ULONG destfmt)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-88(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_GetTexFmtInfo(context, format, destfmt) __W3D_GetTexFmtInfo((context), (format), (destfmt))

W3D_Texture    * __W3D_AllocTexObj(W3D_Context * context, ULONG * error, struct TagItem * ATOTags)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-94(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_AllocTexObj(context, error, ATOTags) __W3D_AllocTexObj((context), (error), (ATOTags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
W3D_Texture    * __W3D_AllocTexObjTags(W3D_Context * context, ULONG * error, int dummy, Tag ATOTags, ...)="\t.extern\t_Warp3DPPCBase\n\tstw\tr6,36(r1)\n\taddi\tr6,r1,36\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-94(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_AllocTexObjTags(context, error, ...) __W3D_AllocTexObjTags((context), (error), 0, __VA_ARGS__)
#endif

void __W3D_FreeTexObj(W3D_Context * context, W3D_Texture * texture)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-100(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_FreeTexObj(context, texture) __W3D_FreeTexObj((context), (texture))

void __W3D_ReleaseTexture(W3D_Context * context, W3D_Texture * texture)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-106(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_ReleaseTexture(context, texture) __W3D_ReleaseTexture((context), (texture))

void __W3D_FlushTextures(W3D_Context * context)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-112(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_FlushTextures(context) __W3D_FlushTextures((context))

ULONG __W3D_SetFilter(W3D_Context * context, W3D_Texture * texture, ULONG min, ULONG mag)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-118(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetFilter(context, texture, min, mag) __W3D_SetFilter((context), (texture), (min), (mag))

ULONG __W3D_SetTexEnv(W3D_Context * context, W3D_Texture * texture, ULONG envparam, W3D_Color * envcolor)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-124(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetTexEnv(context, texture, envparam, envcolor) __W3D_SetTexEnv((context), (texture), (envparam), (envcolor))

ULONG __W3D_SetWrapMode(W3D_Context * context, W3D_Texture * texture, ULONG mode_s, ULONG mode_t, W3D_Color * bordercolor)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-130(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetWrapMode(context, texture, mode_s, mode_t, bordercolor) __W3D_SetWrapMode((context), (texture), (mode_s), (mode_t), (bordercolor))

ULONG __W3D_UpdateTexImage(W3D_Context * context, W3D_Texture * texture, void * teximage, int level, ULONG * palette)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-136(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_UpdateTexImage(context, texture, teximage, level, palette) __W3D_UpdateTexImage((context), (texture), (teximage), (level), (palette))

ULONG __W3D_UploadTexture(W3D_Context * context, W3D_Texture * texture)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-142(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_UploadTexture(context, texture) __W3D_UploadTexture((context), (texture))

ULONG __W3D_DrawLine(W3D_Context * context, W3D_Line * line)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-148(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_DrawLine(context, line) __W3D_DrawLine((context), (line))

ULONG __W3D_DrawPoint(W3D_Context * context, W3D_Point * point)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-154(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_DrawPoint(context, point) __W3D_DrawPoint((context), (point))

ULONG __W3D_DrawTriangle(W3D_Context * context, W3D_Triangle * triangle)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-160(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_DrawTriangle(context, triangle) __W3D_DrawTriangle((context), (triangle))

ULONG __W3D_DrawTriFan(W3D_Context * context, W3D_Triangles * triangles)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-166(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_DrawTriFan(context, triangles) __W3D_DrawTriFan((context), (triangles))

ULONG __W3D_DrawTriStrip(W3D_Context * context, W3D_Triangles * triangles)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-172(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_DrawTriStrip(context, triangles) __W3D_DrawTriStrip((context), (triangles))

ULONG __W3D_SetAlphaMode(W3D_Context * context, ULONG mode, W3D_Float * refval)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-178(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetAlphaMode(context, mode, refval) __W3D_SetAlphaMode((context), (mode), (refval))

ULONG __W3D_SetBlendMode(W3D_Context * context, ULONG srcfunc, ULONG dstfunc)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-184(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetBlendMode(context, srcfunc, dstfunc) __W3D_SetBlendMode((context), (srcfunc), (dstfunc))

ULONG __W3D_SetDrawRegion(W3D_Context * context, struct BitMap * bm, int yoffset, W3D_Scissor * scissor)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-190(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetDrawRegion(context, bm, yoffset, scissor) __W3D_SetDrawRegion((context), (bm), (yoffset), (scissor))

ULONG __W3D_SetFogParams(W3D_Context * context, W3D_Fog * fogparams, ULONG fogmode)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-196(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetFogParams(context, fogparams, fogmode) __W3D_SetFogParams((context), (fogparams), (fogmode))

ULONG __W3D_SetColorMask(W3D_Context * context, W3D_Bool red, W3D_Bool green, W3D_Bool blue, W3D_Bool alpha)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-202(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetColorMask(context, red, green, blue, alpha) __W3D_SetColorMask((context), (red), (green), (blue), (alpha))

ULONG __W3D_SetStencilFunc(W3D_Context * context, ULONG func, ULONG refvalue, ULONG mask)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-208(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetStencilFunc(context, func, refvalue, mask) __W3D_SetStencilFunc((context), (func), (refvalue), (mask))

ULONG __W3D_AllocZBuffer(W3D_Context * context)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-214(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_AllocZBuffer(context) __W3D_AllocZBuffer((context))

ULONG __W3D_FreeZBuffer(W3D_Context * context)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-220(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_FreeZBuffer(context) __W3D_FreeZBuffer((context))

ULONG __W3D_ClearZBuffer(W3D_Context * context, W3D_Double * clearvalue)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-226(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_ClearZBuffer(context, clearvalue) __W3D_ClearZBuffer((context), (clearvalue))

ULONG __W3D_ReadZPixel(W3D_Context * context, ULONG x, ULONG y, W3D_Double * z)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-232(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_ReadZPixel(context, x, y, z) __W3D_ReadZPixel((context), (x), (y), (z))

ULONG __W3D_ReadZSpan(W3D_Context * context, ULONG x, ULONG y, ULONG n, W3D_Double * z)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-238(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_ReadZSpan(context, x, y, n, z) __W3D_ReadZSpan((context), (x), (y), (n), (z))

ULONG __W3D_SetZCompareMode(W3D_Context * context, ULONG mode)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-244(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetZCompareMode(context, mode) __W3D_SetZCompareMode((context), (mode))

ULONG __W3D_AllocStencilBuffer(W3D_Context * context)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-250(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_AllocStencilBuffer(context) __W3D_AllocStencilBuffer((context))

ULONG __W3D_ClearStencilBuffer(W3D_Context * context, ULONG * clearval)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-256(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_ClearStencilBuffer(context, clearval) __W3D_ClearStencilBuffer((context), (clearval))

ULONG __W3D_FillStencilBuffer(W3D_Context * context, ULONG x, ULONG y, ULONG width, ULONG height, ULONG depth, void * data)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-262(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_FillStencilBuffer(context, x, y, width, height, depth, data) __W3D_FillStencilBuffer((context), (x), (y), (width), (height), (depth), (data))

ULONG __W3D_FreeStencilBuffer(W3D_Context * context)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-268(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_FreeStencilBuffer(context) __W3D_FreeStencilBuffer((context))

ULONG __W3D_ReadStencilPixel(W3D_Context * context, ULONG x, ULONG y, ULONG * st)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-274(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_ReadStencilPixel(context, x, y, st) __W3D_ReadStencilPixel((context), (x), (y), (st))

ULONG __W3D_ReadStencilSpan(W3D_Context * context, ULONG x, ULONG y, ULONG n, ULONG * st)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-280(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_ReadStencilSpan(context, x, y, n, st) __W3D_ReadStencilSpan((context), (x), (y), (n), (st))

ULONG __W3D_SetLogicOp(W3D_Context * context, ULONG operation)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-286(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetLogicOp(context, operation) __W3D_SetLogicOp((context), (operation))

ULONG __W3D_Hint(W3D_Context * context, ULONG mode, ULONG quality)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-292(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_Hint(context, mode, quality) __W3D_Hint((context), (mode), (quality))

ULONG __W3D_SetDrawRegionWBM(W3D_Context * context, W3D_Bitmap * bitmap, W3D_Scissor * scissor)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-298(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetDrawRegionWBM(context, bitmap, scissor) __W3D_SetDrawRegionWBM((context), (bitmap), (scissor))

ULONG __W3D_GetDriverState(W3D_Context * context)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-304(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_GetDriverState(context) __W3D_GetDriverState((context))

ULONG __W3D_Flush(W3D_Context * context)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-310(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_Flush(context) __W3D_Flush((context))

ULONG __W3D_SetPenMask(W3D_Context * context, ULONG pen)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-316(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetPenMask(context, pen) __W3D_SetPenMask((context), (pen))

ULONG __W3D_SetStencilOp(W3D_Context * context, ULONG sfail, ULONG dpfail, ULONG dppass)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-322(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetStencilOp(context, sfail, dpfail, dppass) __W3D_SetStencilOp((context), (sfail), (dpfail), (dppass))

ULONG __W3D_SetWriteMask(W3D_Context * context, ULONG mask)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-328(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetWriteMask(context, mask) __W3D_SetWriteMask((context), (mask))

ULONG __W3D_WriteStencilPixel(W3D_Context * context, ULONG x, ULONG y, ULONG st)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-334(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_WriteStencilPixel(context, x, y, st) __W3D_WriteStencilPixel((context), (x), (y), (st))

ULONG __W3D_WriteStencilSpan(W3D_Context * context, ULONG x, ULONG y, ULONG n, ULONG * st, UBYTE * mask)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-340(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_WriteStencilSpan(context, x, y, n, st, mask) __W3D_WriteStencilSpan((context), (x), (y), (n), (st), (mask))

void __W3D_WriteZPixel(W3D_Context * context, ULONG x, ULONG y, W3D_Double * z)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-346(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_WriteZPixel(context, x, y, z) __W3D_WriteZPixel((context), (x), (y), (z))

void __W3D_WriteZSpan(W3D_Context * context, ULONG x, ULONG y, ULONG n, W3D_Double * z, UBYTE * mask)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-352(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_WriteZSpan(context, x, y, n, z, mask) __W3D_WriteZSpan((context), (x), (y), (n), (z), (mask))

ULONG __W3D_SetCurrentColor(W3D_Context * context, W3D_Color * color)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-358(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetCurrentColor(context, color) __W3D_SetCurrentColor((context), (color))

ULONG __W3D_SetCurrentPen(W3D_Context * context, ULONG pen)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-364(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetCurrentPen(context, pen) __W3D_SetCurrentPen((context), (pen))

ULONG __W3D_UpdateTexSubImage(W3D_Context * context, W3D_Texture * texture, void * teximage, ULONG lev, ULONG * palette, W3D_Scissor* scissor, ULONG srcbpr)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-370(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_UpdateTexSubImage(context, texture, teximage, lev, palette, scissor, srcbpr) __W3D_UpdateTexSubImage((context), (texture), (teximage), (lev), (palette), (scissor), (srcbpr))

ULONG __W3D_FreeAllTexObj(W3D_Context * context)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-376(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_FreeAllTexObj(context) __W3D_FreeAllTexObj((context))

ULONG __W3D_GetDestFmt()="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-382(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_GetDestFmt() __W3D_GetDestFmt()

ULONG __W3D_DrawLineStrip(W3D_Context * context, W3D_Lines * lines)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-388(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_DrawLineStrip(context, lines) __W3D_DrawLineStrip((context), (lines))

ULONG __W3D_DrawLineLoop(W3D_Context * context, W3D_Lines * lines)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-394(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_DrawLineLoop(context, lines) __W3D_DrawLineLoop((context), (lines))

W3D_Driver ** __W3D_GetDrivers()="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-400(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_GetDrivers() __W3D_GetDrivers()

ULONG __W3D_QueryDriver(W3D_Driver* driver, ULONG query, ULONG destfmt)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-406(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_QueryDriver(driver, query, destfmt) __W3D_QueryDriver((driver), (query), (destfmt))

ULONG __W3D_GetDriverTexFmtInfo(W3D_Driver* driver, ULONG format, ULONG destfmt)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-412(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_GetDriverTexFmtInfo(driver, format, destfmt) __W3D_GetDriverTexFmtInfo((driver), (format), (destfmt))

ULONG __W3D_RequestMode(struct TagItem * taglist)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-418(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_RequestMode(taglist) __W3D_RequestMode((taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __W3D_RequestModeTags(int dummy, Tag taglist, ...)="\t.extern\t_Warp3DPPCBase\n\tstw\tr4,28(r1)\n\taddi\tr4,r1,28\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-418(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_RequestModeTags(...) __W3D_RequestModeTags(0, __VA_ARGS__)
#endif

void __W3D_SetScissor(W3D_Context * context, W3D_Scissor * scissor)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-424(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetScissor(context, scissor) __W3D_SetScissor((context), (scissor))

void __W3D_FlushFrame(W3D_Context * context)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-430(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_FlushFrame(context) __W3D_FlushFrame((context))

W3D_Driver * __W3D_TestMode(ULONG modeid)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-436(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_TestMode(modeid) __W3D_TestMode((modeid))

ULONG __W3D_SetChromaTestBounds(W3D_Context * context, W3D_Texture * texture, ULONG rgba_lower, ULONG rgba_upper, ULONG mode)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-442(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetChromaTestBounds(context, texture, rgba_lower, rgba_upper, mode) __W3D_SetChromaTestBounds((context), (texture), (rgba_lower), (rgba_upper), (mode))

ULONG __W3D_ClearDrawRegion(W3D_Context * context, ULONG color)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-448(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_ClearDrawRegion(context, color) __W3D_ClearDrawRegion((context), (color))

ULONG __W3D_DrawTriangleV(W3D_Context * context, W3D_TriangleV * triangle)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-454(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_DrawTriangleV(context, triangle) __W3D_DrawTriangleV((context), (triangle))

ULONG __W3D_DrawTriFanV(W3D_Context * context, W3D_TrianglesV * triangles)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-460(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_DrawTriFanV(context, triangles) __W3D_DrawTriFanV((context), (triangles))

ULONG __W3D_DrawTriStripV(W3D_Context * context, W3D_TrianglesV * triangles)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-466(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_DrawTriStripV(context, triangles) __W3D_DrawTriStripV((context), (triangles))

W3D_ScreenMode * __W3D_GetScreenmodeList()="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-472(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_GetScreenmodeList() __W3D_GetScreenmodeList()

void __W3D_FreeScreenmodeList(W3D_ScreenMode * list)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-478(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_FreeScreenmodeList(list) __W3D_FreeScreenmodeList((list))

ULONG __W3D_BestModeID(struct TagItem * tags)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-484(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_BestModeID(tags) __W3D_BestModeID((tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __W3D_BestModeIDTags(int dummy, Tag tags, ...)="\t.extern\t_Warp3DPPCBase\n\tstw\tr4,28(r1)\n\taddi\tr4,r1,28\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-484(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_BestModeIDTags(...) __W3D_BestModeIDTags(0, __VA_ARGS__)
#endif

ULONG __W3D_VertexPointer(W3D_Context* context, void * pointer, int stride, ULONG mode, ULONG flags)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-490(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_VertexPointer(context, pointer, stride, mode, flags) __W3D_VertexPointer((context), (pointer), (stride), (mode), (flags))

ULONG __W3D_TexCoordPointer(W3D_Context* context, void * pointer, int stride, int unit, int off_v, int off_w, ULONG flags)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-496(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_TexCoordPointer(context, pointer, stride, unit, off_v, off_w, flags) __W3D_TexCoordPointer((context), (pointer), (stride), (unit), (off_v), (off_w), (flags))

ULONG __W3D_ColorPointer(W3D_Context* context, void * pointer, int stride, ULONG format, ULONG mode, ULONG flags)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-502(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_ColorPointer(context, pointer, stride, format, mode, flags) __W3D_ColorPointer((context), (pointer), (stride), (format), (mode), (flags))

ULONG __W3D_BindTexture(W3D_Context* context, ULONG tmu, W3D_Texture * texture)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-508(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_BindTexture(context, tmu, texture) __W3D_BindTexture((context), (tmu), (texture))

ULONG __W3D_DrawArray(W3D_Context* context, ULONG primitive, ULONG base, ULONG count)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-514(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_DrawArray(context, primitive, base, count) __W3D_DrawArray((context), (primitive), (base), (count))

ULONG __W3D_DrawElements(W3D_Context* context, ULONG primitive, ULONG type, ULONG count, void * indices)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-520(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_DrawElements(context, primitive, type, count, indices) __W3D_DrawElements((context), (primitive), (type), (count), (indices))

void __W3D_SetFrontFace(W3D_Context* context, ULONG direction)="\t.extern\t_Warp3DPPCBase\n\tlwz\tr11,_Warp3DPPCBase(r2)\n\tlwz\tr0,-526(r11)\n\tmtlr\tr0\n\tblrl";
#define W3D_SetFrontFace(context, direction) __W3D_SetFrontFace((context), (direction))

#endif /*  _VBCCINLINE_WARP3D_H  */
