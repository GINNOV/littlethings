#ifndef _VBCCINLINE_WARP3D_H
#define _VBCCINLINE_WARP3D_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

W3D_Context    * __W3D_CreateContext(struct Library *, ULONG * error, struct TagItem * CCTags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-30\n"
	"\tblrl";
#define W3D_CreateContext(error, CCTags) __W3D_CreateContext(Warp3DBase, (error), (CCTags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
W3D_Context    * __linearvarargs __W3D_CreateContextTags(struct Library *, ULONG * error, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-30\n"
	"\tblrl";
#define W3D_CreateContextTags(error, ...) __W3D_CreateContextTags(Warp3DBase, (error), __VA_ARGS__)
#endif

void __W3D_DestroyContext(struct Library *, W3D_Context * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tblrl";
#define W3D_DestroyContext(context) __W3D_DestroyContext(Warp3DBase, (context))

ULONG __W3D_GetState(struct Library *, W3D_Context * context, ULONG state) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-42\n"
	"\tblrl";
#define W3D_GetState(context, state) __W3D_GetState(Warp3DBase, (context), (state))

ULONG __W3D_SetState(struct Library *, W3D_Context * context, ULONG state, ULONG action) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-48\n"
	"\tblrl";
#define W3D_SetState(context, state, action) __W3D_SetState(Warp3DBase, (context), (state), (action))

ULONG __W3D_CheckDriver(struct Library *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tli\t3,-54\n"
	"\tblrl";
#define W3D_CheckDriver() __W3D_CheckDriver(Warp3DBase)

ULONG __W3D_LockHardware(struct Library *, W3D_Context * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tblrl";
#define W3D_LockHardware(context) __W3D_LockHardware(Warp3DBase, (context))

void __W3D_UnLockHardware(struct Library *, W3D_Context * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-66\n"
	"\tblrl";
#define W3D_UnLockHardware(context) __W3D_UnLockHardware(Warp3DBase, (context))

void __W3D_WaitIdle(struct Library *, W3D_Context * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-72\n"
	"\tblrl";
#define W3D_WaitIdle(context) __W3D_WaitIdle(Warp3DBase, (context))

ULONG __W3D_CheckIdle(struct Library *, W3D_Context * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tblrl";
#define W3D_CheckIdle(context) __W3D_CheckIdle(Warp3DBase, (context))

ULONG __W3D_Query(struct Library *, W3D_Context * context, ULONG query, ULONG destfmt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-84\n"
	"\tblrl";
#define W3D_Query(context, query, destfmt) __W3D_Query(Warp3DBase, (context), (query), (destfmt))

ULONG __W3D_GetTexFmtInfo(struct Library *, W3D_Context * context, ULONG format, ULONG destfmt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-90\n"
	"\tblrl";
#define W3D_GetTexFmtInfo(context, format, destfmt) __W3D_GetTexFmtInfo(Warp3DBase, (context), (format), (destfmt))

W3D_Texture    * __W3D_AllocTexObj(struct Library *, W3D_Context * context, ULONG * error, struct TagItem * ATOTags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-96\n"
	"\tblrl";
#define W3D_AllocTexObj(context, error, ATOTags) __W3D_AllocTexObj(Warp3DBase, (context), (error), (ATOTags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
W3D_Texture    * __linearvarargs __W3D_AllocTexObjTags(struct Library *, W3D_Context * context, ULONG * error, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-96\n"
	"\tblrl";
#define W3D_AllocTexObjTags(context, error, ...) __W3D_AllocTexObjTags(Warp3DBase, (context), (error), __VA_ARGS__)
#endif

void __W3D_FreeTexObj(struct Library *, W3D_Context * context, W3D_Texture * texture) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-102\n"
	"\tblrl";
#define W3D_FreeTexObj(context, texture) __W3D_FreeTexObj(Warp3DBase, (context), (texture))

void __W3D_ReleaseTexture(struct Library *, W3D_Context * context, W3D_Texture * texture) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-108\n"
	"\tblrl";
#define W3D_ReleaseTexture(context, texture) __W3D_ReleaseTexture(Warp3DBase, (context), (texture))

void __W3D_FlushTextures(struct Library *, W3D_Context * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-114\n"
	"\tblrl";
#define W3D_FlushTextures(context) __W3D_FlushTextures(Warp3DBase, (context))

ULONG __W3D_SetFilter(struct Library *, W3D_Context * context, W3D_Texture * texture, ULONG min, ULONG mag) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-120\n"
	"\tblrl";
#define W3D_SetFilter(context, texture, min, mag) __W3D_SetFilter(Warp3DBase, (context), (texture), (min), (mag))

ULONG __W3D_SetTexEnv(struct Library *, W3D_Context * context, W3D_Texture * texture, ULONG envparam, W3D_Color * envcolor) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-126\n"
	"\tblrl";
#define W3D_SetTexEnv(context, texture, envparam, envcolor) __W3D_SetTexEnv(Warp3DBase, (context), (texture), (envparam), (envcolor))

ULONG __W3D_SetWrapMode(struct Library *, W3D_Context * context, W3D_Texture * texture, ULONG mode_s, ULONG mode_t, W3D_Color * bordercolor) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-132\n"
	"\tblrl";
#define W3D_SetWrapMode(context, texture, mode_s, mode_t, bordercolor) __W3D_SetWrapMode(Warp3DBase, (context), (texture), (mode_s), (mode_t), (bordercolor))

ULONG __W3D_UpdateTexImage(struct Library *, W3D_Context * context, W3D_Texture * texture, void * teximage, int level, ULONG * palette) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,44(2)\n"
	"\tli\t3,-138\n"
	"\tblrl";
#define W3D_UpdateTexImage(context, texture, teximage, level, palette) __W3D_UpdateTexImage(Warp3DBase, (context), (texture), (teximage), (level), (palette))

ULONG __W3D_UploadTexture(struct Library *, W3D_Context * context, W3D_Texture * texture) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-144\n"
	"\tblrl";
#define W3D_UploadTexture(context, texture) __W3D_UploadTexture(Warp3DBase, (context), (texture))

ULONG __W3D_DrawLine(struct Library *, W3D_Context * context, W3D_Line * line) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-150\n"
	"\tblrl";
#define W3D_DrawLine(context, line) __W3D_DrawLine(Warp3DBase, (context), (line))

ULONG __W3D_DrawPoint(struct Library *, W3D_Context * context, W3D_Point * point) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-156\n"
	"\tblrl";
#define W3D_DrawPoint(context, point) __W3D_DrawPoint(Warp3DBase, (context), (point))

ULONG __W3D_DrawTriangle(struct Library *, W3D_Context * context, W3D_Triangle * triangle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-162\n"
	"\tblrl";
#define W3D_DrawTriangle(context, triangle) __W3D_DrawTriangle(Warp3DBase, (context), (triangle))

ULONG __W3D_DrawTriFan(struct Library *, W3D_Context * context, W3D_Triangles * triangles) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-168\n"
	"\tblrl";
#define W3D_DrawTriFan(context, triangles) __W3D_DrawTriFan(Warp3DBase, (context), (triangles))

ULONG __W3D_DrawTriStrip(struct Library *, W3D_Context * context, W3D_Triangles * triangles) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-174\n"
	"\tblrl";
#define W3D_DrawTriStrip(context, triangles) __W3D_DrawTriStrip(Warp3DBase, (context), (triangles))

ULONG __W3D_SetAlphaMode(struct Library *, W3D_Context * context, ULONG mode, W3D_Float * refval) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-180\n"
	"\tblrl";
#define W3D_SetAlphaMode(context, mode, refval) __W3D_SetAlphaMode(Warp3DBase, (context), (mode), (refval))

ULONG __W3D_SetBlendMode(struct Library *, W3D_Context * context, ULONG srcfunc, ULONG dstfunc) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-186\n"
	"\tblrl";
#define W3D_SetBlendMode(context, srcfunc, dstfunc) __W3D_SetBlendMode(Warp3DBase, (context), (srcfunc), (dstfunc))

ULONG __W3D_SetDrawRegion(struct Library *, W3D_Context * context, struct BitMap * bm, int yoffset, W3D_Scissor * scissor) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-192\n"
	"\tblrl";
#define W3D_SetDrawRegion(context, bm, yoffset, scissor) __W3D_SetDrawRegion(Warp3DBase, (context), (bm), (yoffset), (scissor))

ULONG __W3D_SetFogParams(struct Library *, W3D_Context * context, W3D_Fog * fogparams, ULONG fogmode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-198\n"
	"\tblrl";
#define W3D_SetFogParams(context, fogparams, fogmode) __W3D_SetFogParams(Warp3DBase, (context), (fogparams), (fogmode))

ULONG __W3D_SetColorMask(struct Library *, W3D_Context * context, W3D_Bool red, W3D_Bool green, W3D_Bool blue, W3D_Bool alpha) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-204\n"
	"\tblrl";
#define W3D_SetColorMask(context, red, green, blue, alpha) __W3D_SetColorMask(Warp3DBase, (context), (red), (green), (blue), (alpha))

ULONG __W3D_SetStencilFunc(struct Library *, W3D_Context * context, ULONG func, ULONG refvalue, ULONG mask) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-210\n"
	"\tblrl";
#define W3D_SetStencilFunc(context, func, refvalue, mask) __W3D_SetStencilFunc(Warp3DBase, (context), (func), (refvalue), (mask))

ULONG __W3D_AllocZBuffer(struct Library *, W3D_Context * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-216\n"
	"\tblrl";
#define W3D_AllocZBuffer(context) __W3D_AllocZBuffer(Warp3DBase, (context))

ULONG __W3D_FreeZBuffer(struct Library *, W3D_Context * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-222\n"
	"\tblrl";
#define W3D_FreeZBuffer(context) __W3D_FreeZBuffer(Warp3DBase, (context))

ULONG __W3D_ClearZBuffer(struct Library *, W3D_Context * context, W3D_Double * clearvalue) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-228\n"
	"\tblrl";
#define W3D_ClearZBuffer(context, clearvalue) __W3D_ClearZBuffer(Warp3DBase, (context), (clearvalue))

ULONG __W3D_ReadZPixel(struct Library *, W3D_Context * context, ULONG x, ULONG y, W3D_Double * z) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-234\n"
	"\tblrl";
#define W3D_ReadZPixel(context, x, y, z) __W3D_ReadZPixel(Warp3DBase, (context), (x), (y), (z))

ULONG __W3D_ReadZSpan(struct Library *, W3D_Context * context, ULONG x, ULONG y, ULONG n, W3D_Double * z) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tli\t3,-240\n"
	"\tblrl";
#define W3D_ReadZSpan(context, x, y, n, z) __W3D_ReadZSpan(Warp3DBase, (context), (x), (y), (n), (z))

ULONG __W3D_SetZCompareMode(struct Library *, W3D_Context * context, ULONG mode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-246\n"
	"\tblrl";
#define W3D_SetZCompareMode(context, mode) __W3D_SetZCompareMode(Warp3DBase, (context), (mode))

ULONG __W3D_AllocStencilBuffer(struct Library *, W3D_Context * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-252\n"
	"\tblrl";
#define W3D_AllocStencilBuffer(context) __W3D_AllocStencilBuffer(Warp3DBase, (context))

ULONG __W3D_ClearStencilBuffer(struct Library *, W3D_Context * context, ULONG * clearval) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-258\n"
	"\tblrl";
#define W3D_ClearStencilBuffer(context, clearval) __W3D_ClearStencilBuffer(Warp3DBase, (context), (clearval))

ULONG __W3D_FillStencilBuffer(struct Library *, W3D_Context * context, ULONG x, ULONG y, ULONG width, ULONG height, ULONG depth, void * data) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,16(2)\n"
	"\tstw\t10,36(2)\n"
	"\tli\t3,-264\n"
	"\tblrl";
#define W3D_FillStencilBuffer(context, x, y, width, height, depth, data) __W3D_FillStencilBuffer(Warp3DBase, (context), (x), (y), (width), (height), (depth), (data))

ULONG __W3D_FreeStencilBuffer(struct Library *, W3D_Context * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-270\n"
	"\tblrl";
#define W3D_FreeStencilBuffer(context) __W3D_FreeStencilBuffer(Warp3DBase, (context))

ULONG __W3D_ReadStencilPixel(struct Library *, W3D_Context * context, ULONG x, ULONG y, ULONG * st) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-276\n"
	"\tblrl";
#define W3D_ReadStencilPixel(context, x, y, st) __W3D_ReadStencilPixel(Warp3DBase, (context), (x), (y), (st))

ULONG __W3D_ReadStencilSpan(struct Library *, W3D_Context * context, ULONG x, ULONG y, ULONG n, ULONG * st) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tli\t3,-282\n"
	"\tblrl";
#define W3D_ReadStencilSpan(context, x, y, n, st) __W3D_ReadStencilSpan(Warp3DBase, (context), (x), (y), (n), (st))

ULONG __W3D_SetLogicOp(struct Library *, W3D_Context * context, ULONG operation) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-288\n"
	"\tblrl";
#define W3D_SetLogicOp(context, operation) __W3D_SetLogicOp(Warp3DBase, (context), (operation))

ULONG __W3D_Hint(struct Library *, W3D_Context * context, ULONG mode, ULONG quality) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-294\n"
	"\tblrl";
#define W3D_Hint(context, mode, quality) __W3D_Hint(Warp3DBase, (context), (mode), (quality))

ULONG __W3D_SetDrawRegionWBM(struct Library *, W3D_Context * context, W3D_Bitmap * bitmap, W3D_Scissor * scissor) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-300\n"
	"\tblrl";
#define W3D_SetDrawRegionWBM(context, bitmap, scissor) __W3D_SetDrawRegionWBM(Warp3DBase, (context), (bitmap), (scissor))

ULONG __W3D_GetDriverState(struct Library *, W3D_Context * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-306\n"
	"\tblrl";
#define W3D_GetDriverState(context) __W3D_GetDriverState(Warp3DBase, (context))

ULONG __W3D_Flush(struct Library *, W3D_Context * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-312\n"
	"\tblrl";
#define W3D_Flush(context) __W3D_Flush(Warp3DBase, (context))

ULONG __W3D_SetPenMask(struct Library *, W3D_Context * context, ULONG pen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-318\n"
	"\tblrl";
#define W3D_SetPenMask(context, pen) __W3D_SetPenMask(Warp3DBase, (context), (pen))

ULONG __W3D_SetStencilOp(struct Library *, W3D_Context * context, ULONG sfail, ULONG dpfail, ULONG dppass) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-324\n"
	"\tblrl";
#define W3D_SetStencilOp(context, sfail, dpfail, dppass) __W3D_SetStencilOp(Warp3DBase, (context), (sfail), (dpfail), (dppass))

ULONG __W3D_SetWriteMask(struct Library *, W3D_Context * context, ULONG mask) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-330\n"
	"\tblrl";
#define W3D_SetWriteMask(context, mask) __W3D_SetWriteMask(Warp3DBase, (context), (mask))

ULONG __W3D_WriteStencilPixel(struct Library *, W3D_Context * context, ULONG x, ULONG y, ULONG st) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-336\n"
	"\tblrl";
#define W3D_WriteStencilPixel(context, x, y, st) __W3D_WriteStencilPixel(Warp3DBase, (context), (x), (y), (st))

ULONG __W3D_WriteStencilSpan(struct Library *, W3D_Context * context, ULONG x, ULONG y, ULONG n, ULONG * st, UBYTE * mask) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tstw\t9,40(2)\n"
	"\tli\t3,-342\n"
	"\tblrl";
#define W3D_WriteStencilSpan(context, x, y, n, st, mask) __W3D_WriteStencilSpan(Warp3DBase, (context), (x), (y), (n), (st), (mask))

void __W3D_WriteZPixel(struct Library *, W3D_Context * context, ULONG x, ULONG y, W3D_Double * z) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-348\n"
	"\tblrl";
#define W3D_WriteZPixel(context, x, y, z) __W3D_WriteZPixel(Warp3DBase, (context), (x), (y), (z))

void __W3D_WriteZSpan(struct Library *, W3D_Context * context, ULONG x, ULONG y, ULONG n, W3D_Double * z, UBYTE * maks) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tstw\t9,40(2)\n"
	"\tli\t3,-354\n"
	"\tblrl";
#define W3D_WriteZSpan(context, x, y, n, z, maks) __W3D_WriteZSpan(Warp3DBase, (context), (x), (y), (n), (z), (maks))

ULONG __W3D_SetCurrentColor(struct Library *, W3D_Context * context, W3D_Color * color) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-360\n"
	"\tblrl";
#define W3D_SetCurrentColor(context, color) __W3D_SetCurrentColor(Warp3DBase, (context), (color))

ULONG __W3D_SetCurrentPen(struct Library *, W3D_Context * context, ULONG pen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-366\n"
	"\tblrl";
#define W3D_SetCurrentPen(context, pen) __W3D_SetCurrentPen(Warp3DBase, (context), (pen))

ULONG __W3D_UpdateTexSubImage(struct Library *, W3D_Context * context, W3D_Texture * texture, void * teximage, ULONG lev, ULONG * palette, W3D_Scissor* scissor, ULONG srcbpr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,44(2)\n"
	"\tstw\t9,48(2)\n"
	"\tstw\t10,0(2)\n"
	"\tli\t3,-372\n"
	"\tblrl";
#define W3D_UpdateTexSubImage(context, texture, teximage, lev, palette, scissor, srcbpr) __W3D_UpdateTexSubImage(Warp3DBase, (context), (texture), (teximage), (lev), (palette), (scissor), (srcbpr))

ULONG __W3D_FreeAllTexObj(struct Library *, W3D_Context * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-378\n"
	"\tblrl";
#define W3D_FreeAllTexObj(context) __W3D_FreeAllTexObj(Warp3DBase, (context))

ULONG __W3D_GetDestFmt(struct Library *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tli\t3,-384\n"
	"\tblrl";
#define W3D_GetDestFmt() __W3D_GetDestFmt(Warp3DBase)

ULONG __W3D_DrawLineStrip(struct Library *, W3D_Context * context, W3D_Lines * lines) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-390\n"
	"\tblrl";
#define W3D_DrawLineStrip(context, lines) __W3D_DrawLineStrip(Warp3DBase, (context), (lines))

ULONG __W3D_DrawLineLoop(struct Library *, W3D_Context * context, W3D_Lines * lines) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-396\n"
	"\tblrl";
#define W3D_DrawLineLoop(context, lines) __W3D_DrawLineLoop(Warp3DBase, (context), (lines))

W3D_Driver ** __W3D_GetDrivers(struct Library *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tli\t3,-402\n"
	"\tblrl";
#define W3D_GetDrivers() __W3D_GetDrivers(Warp3DBase)

ULONG __W3D_QueryDriver(struct Library *, W3D_Driver* driver, ULONG query, ULONG destfmt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-408\n"
	"\tblrl";
#define W3D_QueryDriver(driver, query, destfmt) __W3D_QueryDriver(Warp3DBase, (driver), (query), (destfmt))

ULONG __W3D_GetDriverTexFmtInfo(struct Library *, W3D_Driver* driver, ULONG format, ULONG destfmt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-414\n"
	"\tblrl";
#define W3D_GetDriverTexFmtInfo(driver, format, destfmt) __W3D_GetDriverTexFmtInfo(Warp3DBase, (driver), (format), (destfmt))

ULONG __W3D_RequestMode(struct Library *, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-420\n"
	"\tblrl";
#define W3D_RequestMode(taglist) __W3D_RequestMode(Warp3DBase, (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __W3D_RequestModeTags(struct Library *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-420\n"
	"\tblrl";
#define W3D_RequestModeTags(...) __W3D_RequestModeTags(Warp3DBase, __VA_ARGS__)
#endif

void __W3D_SetScissor(struct Library *, W3D_Context * context, W3D_Scissor * scissor) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-426\n"
	"\tblrl";
#define W3D_SetScissor(context, scissor) __W3D_SetScissor(Warp3DBase, (context), (scissor))

void __W3D_FlushFrame(struct Library *, W3D_Context * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-432\n"
	"\tblrl";
#define W3D_FlushFrame(context) __W3D_FlushFrame(Warp3DBase, (context))

W3D_Driver * __W3D_TestMode(struct Library *, ULONG ModeID) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-438\n"
	"\tblrl";
#define W3D_TestMode(ModeID) __W3D_TestMode(Warp3DBase, (ModeID))

ULONG __W3D_SetChromaTestBounds(struct Library *, W3D_Context * context, W3D_Texture * texture, ULONG rgba_lower, ULONG rgba_upper, ULONG mode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tli\t3,-444\n"
	"\tblrl";
#define W3D_SetChromaTestBounds(context, texture, rgba_lower, rgba_upper, mode) __W3D_SetChromaTestBounds(Warp3DBase, (context), (texture), (rgba_lower), (rgba_upper), (mode))

ULONG __W3D_ClearDrawRegion(struct Library *, W3D_Context * context, ULONG color) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-450\n"
	"\tblrl";
#define W3D_ClearDrawRegion(context, color) __W3D_ClearDrawRegion(Warp3DBase, (context), (color))

ULONG __W3D_DrawTriangleV(struct Library *, W3D_Context * context, W3D_TriangleV * triangle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-456\n"
	"\tblrl";
#define W3D_DrawTriangleV(context, triangle) __W3D_DrawTriangleV(Warp3DBase, (context), (triangle))

ULONG __W3D_DrawTriFanV(struct Library *, W3D_Context * context, W3D_TrianglesV * triangles) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-462\n"
	"\tblrl";
#define W3D_DrawTriFanV(context, triangles) __W3D_DrawTriFanV(Warp3DBase, (context), (triangles))

ULONG __W3D_DrawTriStripV(struct Library *, W3D_Context * context, W3D_TrianglesV * triangles) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-468\n"
	"\tblrl";
#define W3D_DrawTriStripV(context, triangles) __W3D_DrawTriStripV(Warp3DBase, (context), (triangles))

W3D_ScreenMode * __W3D_GetScreenmodeList(struct Library *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tli\t3,-474\n"
	"\tblrl";
#define W3D_GetScreenmodeList() __W3D_GetScreenmodeList(Warp3DBase)

void __W3D_FreeScreenmodeList(struct Library *, W3D_ScreenMode * list) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-480\n"
	"\tblrl";
#define W3D_FreeScreenmodeList(list) __W3D_FreeScreenmodeList(Warp3DBase, (list))

ULONG __W3D_BestModeID(struct Library *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-486\n"
	"\tblrl";
#define W3D_BestModeID(tags) __W3D_BestModeID(Warp3DBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __W3D_BestModeIDTags(struct Library *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-486\n"
	"\tblrl";
#define W3D_BestModeIDTags(...) __W3D_BestModeIDTags(Warp3DBase, __VA_ARGS__)
#endif

ULONG __W3D_VertexPointer(struct Library *, W3D_Context* context, void * pointer, int stride, ULONG mode, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tli\t3,-492\n"
	"\tblrl";
#define W3D_VertexPointer(context, pointer, stride, mode, flags) __W3D_VertexPointer(Warp3DBase, (context), (pointer), (stride), (mode), (flags))

ULONG __W3D_TexCoordPointer(struct Library *, W3D_Context* context, void * pointer, int stride, int unit, int off_v, int off_w, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tli\t3,-498\n"
	"\tblrl";
#define W3D_TexCoordPointer(context, pointer, stride, unit, off_v, off_w, flags) __W3D_TexCoordPointer(Warp3DBase, (context), (pointer), (stride), (unit), (off_v), (off_w), (flags))

ULONG __W3D_ColorPointer(struct Library *, W3D_Context* context, void * pointer, int stride, ULONG format, ULONG mode, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tli\t3,-504\n"
	"\tblrl";
#define W3D_ColorPointer(context, pointer, stride, format, mode, flags) __W3D_ColorPointer(Warp3DBase, (context), (pointer), (stride), (format), (mode), (flags))

ULONG __W3D_BindTexture(struct Library *, W3D_Context* context, ULONG tmu, W3D_Texture * texture) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-510\n"
	"\tblrl";
#define W3D_BindTexture(context, tmu, texture) __W3D_BindTexture(Warp3DBase, (context), (tmu), (texture))

ULONG __W3D_DrawArray(struct Library *, W3D_Context* context, ULONG primitive, ULONG base, ULONG count) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-516\n"
	"\tblrl";
#define W3D_DrawArray(context, primitive, base, count) __W3D_DrawArray(Warp3DBase, (context), (primitive), (base), (count))

ULONG __W3D_DrawElements(struct Library *, W3D_Context* context, ULONG primitive, ULONG type, ULONG count, void * indices) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tli\t3,-522\n"
	"\tblrl";
#define W3D_DrawElements(context, primitive, type, count, indices) __W3D_DrawElements(Warp3DBase, (context), (primitive), (type), (count), (indices))

void __W3D_SetFrontFace(struct Library *, W3D_Context* context, ULONG direction) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-528\n"
	"\tblrl";
#define W3D_SetFrontFace(context, direction) __W3D_SetFrontFace(Warp3DBase, (context), (direction))

#endif /*  _VBCCINLINE_WARP3D_H  */
