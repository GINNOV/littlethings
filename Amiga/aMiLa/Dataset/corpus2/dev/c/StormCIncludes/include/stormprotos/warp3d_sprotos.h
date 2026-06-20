#ifndef STORMPROTOS_WARP3D_SPROTOS_H
#define STORMPROTOS_WARP3D_SPROTOS_H

#ifdef __PPC__

extern "AmigaLib" Warp3DPPCBase {

/************************** Context functions ***********************************/
W3D_Context    *W3D_CreateContext(ULONG *error, struct TagItem *CCTags) = -30;
void            W3D_DestroyContext(W3D_Context *context) = -36;
ULONG           W3D_GetState(W3D_Context *context, ULONG state) = -42;
ULONG           W3D_SetState(W3D_Context *context, ULONG state, ULONG action) = -48;
ULONG           W3D_Hint(W3D_Context *context, ULONG mode, ULONG quality) = -294;

/************************** Hardware/Driver functions ***************************/
ULONG           W3D_CheckDriver() = -54;
ULONG           W3D_LockHardware(W3D_Context *context) = -60;
void            W3D_UnLockHardware(W3D_Context *context) = -66;
void            W3D_WaitIdle(W3D_Context *context) = -72;
ULONG           W3D_CheckIdle(W3D_Context *context) = -78;
ULONG           W3D_Query(W3D_Context *context, ULONG query, ULONG destfmt) = -84;
ULONG           W3D_GetTexFmtInfo(W3D_Context*, ULONG texfmt, ULONG destfmt) = -90;
ULONG           W3D_GetDriverState(W3D_Context *context) = -306;
ULONG           W3D_GetDestFmt(void) = -384;
W3D_Driver **   W3D_GetDrivers(void) = -402;
ULONG           W3D_QueryDriver(W3D_Driver* driver, ULONG query, ULONG destfmt) = -408;
ULONG           W3D_GetDriverTexFmtInfo(W3D_Driver* driver, ULONG query, ULONG destfmt) = -414;
ULONG           W3D_RequestMode(struct TagItem *taglist) = -420;
W3D_Driver *    W3D_TestMode(ULONG ModeID) = -438;

/************************** Texture functions ***********************************/
W3D_Texture    *W3D_AllocTexObj(W3D_Context *context, ULONG *error,
                                        struct TagItem *ATOTags) = -96;
void            W3D_FreeTexObj(W3D_Context *context, W3D_Texture *texture) = -102;
void            W3D_ReleaseTexture(W3D_Context *context, W3D_Texture *texture) = -108;
void            W3D_FlushTextures(W3D_Context *context) = -114;
ULONG           W3D_SetFilter(W3D_Context *context, W3D_Texture *texture,
                                        ULONG MinFilter, ULONG MagFilter) = -120;
ULONG           W3D_SetTexEnv(W3D_Context *context, W3D_Texture *texture,
                                        ULONG envparam, W3D_Color *envcolor) = -126;
ULONG           W3D_SetWrapMode(W3D_Context *context, W3D_Texture *texture,
                                        ULONG mode_s, ULONG mode_t, W3D_Color *bordercolor) = -132;
ULONG           W3D_UpdateTexImage(W3D_Context *context, W3D_Texture *texture,
                                        void *teximage, int level, ULONG *palette) = -138;
ULONG           W3D_UpdateTexSubImage(W3D_Context *context, W3D_Texture *texture, void *teximage,
                    ULONG level, ULONG *palette, W3D_Scissor* scissor, ULONG srcbpr) = -372;
ULONG           W3D_UploadTexture(W3D_Context *context, W3D_Texture *texture) = -144;
ULONG           W3D_FreeAllTexObj(W3D_Context *context) = -378;
ULONG           W3D_SetChromaTestBounds(W3D_Context *context, W3D_Texture *texture,
                                                        ULONG rgba_lower, ULONG rgba_upper, ULONG mode) = -444;

/************************** Drawing functions ***********************************/
ULONG           W3D_DrawLine(W3D_Context *context, W3D_Line *line) = -150;
ULONG           W3D_DrawPoint(W3D_Context *context, W3D_Point *point) = -156;
ULONG           W3D_DrawTriangle(W3D_Context *context, W3D_Triangle *triangle) = -162;
ULONG           W3D_DrawTriFan(W3D_Context *context, W3D_Triangles *triangles) = -168;
ULONG           W3D_DrawTriStrip(W3D_Context *context, W3D_Triangles *triangles) = -174;
ULONG           W3D_Flush(W3D_Context *context) = -312;
ULONG           W3D_DrawLineStrip(W3D_Context *context, W3D_Lines *lines) = -390;
ULONG           W3D_DrawLineLoop(W3D_Context *context, W3D_Lines *lines) = -396;
ULONG           W3D_ClearDrawRegion(W3D_Context *context, ULONG color) = -450;

/************************** Effect functions ************************************/
ULONG           W3D_SetAlphaMode(W3D_Context *context, ULONG mode, W3D_Float *refval) = -180;
ULONG           W3D_SetBlendMode(W3D_Context *context, ULONG srcfunc, ULONG dstfunc) = -186;
ULONG           W3D_SetDrawRegion(W3D_Context *context, struct BitMap *bm,
                                        int yoffset, W3D_Scissor *scissor) = -192;
ULONG           W3D_SetDrawRegionWBM(W3D_Context *context, W3D_Bitmap *bm,
                                        W3D_Scissor *scissor) = -300;
ULONG           W3D_SetFogParams(W3D_Context *context, W3D_Fog *fogparams,
                                        ULONG fogmode) = -198;
ULONG           W3D_SetLogicOp(W3D_Context *context, ULONG operation) = -288;
ULONG           W3D_SetColorMask(W3D_Context *context, W3D_Bool red, W3D_Bool green,
                                        W3D_Bool blue, W3D_Bool alpha) = -204;
ULONG           W3D_SetPenMask(W3D_Context *context, ULONG pen) = -318;
ULONG           W3D_SetCurrentColor(W3D_Context *context, W3D_Color *color) = -360;
ULONG           W3D_SetCurrentPen(W3D_Context *context, ULONG pen) = -366;
void            W3D_SetScissor(W3D_Context *context, W3D_Scissor *scissor) = -426;
void            W3D_FlushFrame(W3D_Context *context) = -432;

/************************** ZBuffer functions ***********************************/
ULONG           W3D_AllocZBuffer(W3D_Context *context) = -216;
ULONG           W3D_FreeZBuffer(W3D_Context *context) = -222;
ULONG           W3D_ClearZBuffer(W3D_Context *context, W3D_Double *clearvalue) = -228;
ULONG           W3D_ReadZPixel(W3D_Context *context, ULONG x, ULONG y,
                                        W3D_Double *z) = -234;
ULONG           W3D_ReadZSpan(W3D_Context *context, ULONG x, ULONG y,
                                        ULONG n, W3D_Double z[]) = -240;
ULONG           W3D_SetZCompareMode(W3D_Context *context, ULONG mode) = -246;
ULONG           W3D_WriteZPixel(W3D_Context *context, ULONG x, ULONG y,
                                        W3D_Double *z) = -348;
ULONG           W3D_WriteZSpan(W3D_Context *context, ULONG x, ULONG y,
                                        ULONG n, W3D_Double z[], UBYTE mask[]) = -354;

/************************** StencilBuffer functions *****************************/
ULONG           W3D_AllocStencilBuffer(W3D_Context *context) = -252;
ULONG           W3D_ClearStencilBuffer(W3D_Context *context, ULONG *clearvalue) = -258;
ULONG           W3D_FillStencilBuffer(W3D_Context *context, ULONG x, ULONG y,
                                        ULONG width, ULONG height, ULONG depth,
                                        void *data) = -264;
ULONG           W3D_FreeStencilBuffer(W3D_Context *context) = -270;
ULONG           W3D_ReadStencilPixel(W3D_Context *context, ULONG x, ULONG y,
                                        ULONG *st) = -276;
ULONG           W3D_ReadStencilSpan(W3D_Context *context, ULONG x, ULONG y,
                                        ULONG n, ULONG st[]) = -282;
ULONG           W3D_SetStencilFunc( W3D_Context *context, ULONG func, ULONG refvalue,
                                        ULONG mask) = -210;
ULONG           W3D_SetStencilOp( W3D_Context *context, ULONG sfail, ULONG dpfail,
                                        ULONG dppass) = -324;
ULONG           W3D_SetWriteMask( W3D_Context *context, ULONG mask) = -330;
ULONG           W3D_WriteStencilPixel( W3D_Context *context, ULONG x, ULONG y, ULONG st) = -336;
ULONG           W3D_WriteStencilSpan( W3D_Context *context, ULONG x, ULONG y, ULONG n,
                                        ULONG st[], UBYTE mask[]) = -342;

/*************************** V3 Vector functions **********************************/
ULONG           W3D_DrawTriangleV(W3D_Context *context, W3D_TriangleV *triangle) = -456;
ULONG           W3D_DrawTriFanV(W3D_Context *context, W3D_TrianglesV *triangles) = -462;
ULONG           W3D_DrawTriStripV(W3D_Context *context, W3D_TrianglesV *triangles) = -468;

/*************************** V3 Screenmode functions ******************************/
W3D_ScreenMode *W3D_GetScreenmodeList(void) = -474;
void            W3D_FreeScreenmodeList(W3D_ScreenMode *list) = -480;
ULONG           W3D_BestModeID(struct TagItem *tags) = -486;

};

__inline W3D_Context    *W3D_CreateContextTags(ULONG *error, Tag tag1, ...)
{
        return W3D_CreateContext(error, (struct TagItem *)&tag1);
}

__inline W3D_Texture    *W3D_AllocTexObjTags(W3D_Context *context, ULONG *error,
                                         Tag tag1, ...)
{
        return W3D_AllocTexObj(context, error, (struct TagItem *)&tag1);
}
__inline ULONG          W3D_RequestModeTags(Tag tag1, ...)
{
        return W3D_RequestMode((struct TagItem *)&tag1);
}

#endif /* __PPC__ */

#endif /* STORMPROTOS_WARP3D_SPROTOS_H */
