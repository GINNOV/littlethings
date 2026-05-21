/*
  Simple DirectMedia Layer
  Copyright (C) 1997-2026 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/
#include "SDL_internal.h"

#if SDL_VIDEO_RENDER_AMIGAOS4 && !SDL_RENDER_DISABLED

#include "SDL_render_compositing.h"
#include "SDL_rc_texture.h"
#include "SDL_rc_draw.h"

#include "../SDL_sysrender.h"

#include "../../video/SDL_sysvideo.h"
#include "../../video/amigaos4/SDL_os4window.h"
#include "../../video/amigaos4/SDL_os4video.h"

#include <proto/graphics.h>
#include <proto/layers.h>
#include <intuition/intuition.h>

#include "../../main/amigaos4/SDL_os4debug.h"

/* AmigaOS4 (compositing) renderer implementation

TODO:

- SDL_BlendMode_Mod: is it impossible to accelerate?
- Blended line drawing could probably be optimized

NOTE:

- compositing is used for blended rectangles and texture blitting
- blended lines and points are drawn with the CPU as compositing doesn't support these primitives
    (could try small triangles to plot a point?)
- texture color modulation is implemented by CPU

*/

typedef struct {
    float x, y;
    float s, t, w;
} OS4_Vertex;

// Some of the drivers use stack to process data when doing compositing.
// Trying to render too many triangles will lock up.
#define MAX_QUADS 1000

static uint16 OS4_QuadIndices[6 * MAX_QUADS];

typedef struct {
    float srcAlpha;
    float destAlpha;
    uint32 flags;
} OS4_CompositingParams;

bool
OS4_IsColorModEnabled(SDL_Texture * texture)
{
    if (texture->color.r != 1.0f || texture->color.g != 1.0f || texture->color.b != 1.0f) {
        //dprintf("Color mod enabled (%f, %f, %f)\n", texture->color.r, texture->color.g, texture->color.b);
        return true;
    }

    return false;
}

struct BitMap *
OS4_AllocBitMap(SDL_Renderer * renderer, int width, int height, int depth, const char* const reason)
{
    dprintf("Allocating bitmap %d*%d*%d for %s\n", width, height, depth, reason);

    struct BitMap *bitmap = IGraphics->AllocBitMapTags(
        width,
        height,
        depth,
        BMATags_Displayable, TRUE,
        BMATags_PixelFormat, PIXF_A8R8G8B8,
        TAG_DONE);

    if (bitmap) {
        /* Fill with zeroes, similar to SW renderer surface creation */
        struct RastPort rp;
        IGraphics->InitRastPort(&rp);
        rp.BitMap = bitmap;

        IGraphics->RectFillColor(
            &rp,
            0,
            0,
            width - 1,
            height - 1,
            0x00000000); // graphics.lib v54!
    } else {
        dprintf("Failed to allocate bitmap\n");
    }

    return bitmap;
}

struct BitMap *
OS4_ActivateRenderer(SDL_Renderer * renderer)
{
    OS4_RenderData *data = (OS4_RenderData *) renderer->internal;

    if (!data->target) {
        data->target = data->bitmap;
    }

    if (!data->target && renderer->window) {
        int width = renderer->window->w;
        int height = renderer->window->h;
        int depth = 32;

        data->target = data->bitmap = OS4_AllocBitMap(renderer, width, height, depth, "renderer");
    }

    if (!data->solidcolor) {
        int width = 1;
        int height = 1;
        int depth = 32;

        data->solidcolor = OS4_AllocBitMap(renderer, width, height, depth, "solid color");
    }

    data->rastport.BitMap = data->target;

    return data->target;
}

static void
OS4_WindowEvent(SDL_Renderer * renderer, const SDL_WindowEvent *event)
{
    OS4_RenderData *data = (OS4_RenderData *) renderer->internal;

    dprintf("Called with event %d\n", event->type);

    if (event->type == SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED) {

        /* Next time ActivateRenderer() is called, new bitmap will be created */
        if (data->bitmap) {

            dprintf("Freeing renderer bitmap %p\n", data->bitmap);

            IGraphics->FreeBitMap(data->bitmap);
            data->bitmap = NULL;
            data->target = NULL;
        }
    }
}

static bool
OS4_GetBitMapSize(SDL_Renderer * renderer, struct BitMap * bitmap, int * w, int * h)
{
    if (bitmap) {
        if (w) {
            *w = IGraphics->GetBitMapAttr(bitmap, BMA_ACTUALWIDTH);
	        //dprintf("w=%d\n", *w);
        }
        if (h) {
            *h = IGraphics->GetBitMapAttr(bitmap, BMA_HEIGHT);
			//dprintf("h=%d\n", *h);
        }

        return true;
    } else {
        return SDL_SetError("NULL bitmap");
    }
}

static bool
OS4_GetOutputSize(SDL_Renderer * renderer, int *w, int *h)
{
    struct BitMap * bitmap = OS4_ActivateRenderer(renderer);

    if (!bitmap) {
        return SDL_SetError("OS4 renderer doesn't have an output bitmap");
    }

    return OS4_GetBitMapSize(renderer, bitmap, w, h);
}

/* Special function to set our 1 * 1 * 32 bitmap */
static bool
OS4_SetSolidColor(SDL_Renderer * renderer, Uint32 color)
{
    OS4_RenderData *data = (OS4_RenderData *) renderer->internal;

    if (data->solidcolor) {
        APTR baseaddress;

        APTR lock = IGraphics->LockBitMapTags(
            data->solidcolor,
            LBM_BaseAddress, &baseaddress,
            TAG_DONE);

        if (lock) {
            *(Uint32 *)baseaddress = color;

            IGraphics->UnlockBitMap(data->solidcolor);

            return true;
        } else {
            dprintf("Lock failed\n");
        }
    }

    return false;
}

static uint32
OS4_ConvertBlendMode(SDL_BlendMode mode)
{
    switch (mode) {
        case SDL_BLENDMODE_NONE:
            return COMPOSITE_Src;
        case SDL_BLENDMODE_BLEND:
            return COMPOSITE_Src_Over_Dest;
        case SDL_BLENDMODE_ADD:
            return COMPOSITE_Plus;
        case SDL_BLENDMODE_MOD:
            // This is not correct, but we can't do modulation at the moment
            return COMPOSITE_Src_Over_Dest;
        default:
            dprintf("Unknown blend mode %d\n", mode);
            return COMPOSITE_Src_Over_Dest;
    }
}

static uint32
OS4_GetCompositeFlags(SDL_BlendMode mode)
{
    uint32 flags = COMPFLAG_IgnoreDestAlpha | COMPFLAG_HardwareOnly;

    if (mode == SDL_BLENDMODE_NONE) {
        flags |= COMPFLAG_SrcAlphaOverride;
    }

    return flags;
}

static void
OS4_SetupCompositing(SDL_Texture * dst, OS4_CompositingParams * params, SDL_ScaleMode scaleMode, SDL_BlendMode blendMode, float alpha)
{
    params->flags = COMPFLAG_HardwareOnly;

    if (!dst) {
        params->flags |= COMPFLAG_IgnoreDestAlpha;
    }

    if (scaleMode != SDL_SCALEMODE_NEAREST) {
        params->flags |= COMPFLAG_SrcFilter;
    }

    if (blendMode == SDL_BLENDMODE_NONE) {
        if (!dst) {
            params->flags |= COMPFLAG_SrcAlphaOverride;
        }
        params->srcAlpha = 1.0f;
    } else {
        params->srcAlpha = alpha;
    }

    params->destAlpha = 1.0f;
}

static void
OS4_RotateVertices(OS4_Vertex vertices[4], const double angle, const SDL_FPoint * center)
{
    float rads = angle * M_PI / 180.0f;

    float sina = SDL_sinf(rads);
    float cosa = SDL_cosf(rads);

    for (int i = 0; i < 4; ++i) {
        float x = vertices[i].x - center->x;
        float y = vertices[i].y - center->y;

        vertices[i].x = x * cosa - y * sina + center->x;
        vertices[i].y = x * sina + y * cosa + center->y;
    }
}

static void
OS4_ScaleVertices(OS4_Vertex vertices[4], const float scale_x, const float scale_y)
{
     for (int i = 0; i < 4; i++) {
         vertices[i].x *= scale_x;
         vertices[i].y *= scale_y;
     }
}

static void
OS4_FillVertexData(OS4_Vertex vertices[4], const SDL_FRect * srcrect, const SDL_FRect * dstrect,
    const double angle, const SDL_FPoint * center, const SDL_FlipMode flip, float scale_x, float scale_y)
{
    /* Flip texture coordinates if needed */

    float left = srcrect->x;
    float right = left + srcrect->w;
    float top = srcrect->y;
    float bottom = top + srcrect->h;

    if (flip == SDL_FLIP_HORIZONTAL) {
        const float tmp = left;
        left = right;
        right = tmp;
    }

    if (flip == SDL_FLIP_VERTICAL) {
        const float tmp = bottom;
        bottom = top;
        top = tmp;
    }

    /*

    Plan is to draw quad with two triangles:

    v0-v3
    | \ |
    v1-v2

    */

    vertices[0].x = dstrect->x;
    vertices[0].y = dstrect->y;
    vertices[0].s = left;
    vertices[0].t = top;
    vertices[0].w = 1.0f;

    vertices[1].x = dstrect->x;
    vertices[1].y = dstrect->y + dstrect->h;
    vertices[1].s = left;
    vertices[1].t = bottom;
    vertices[1].w = 1.0f;

    vertices[2].x = dstrect->x + dstrect->w;
    vertices[2].y = dstrect->y + dstrect->h;
    vertices[2].s = right;
    vertices[2].t = bottom;
    vertices[2].w = 1.0f;

    vertices[3].x = dstrect->x + dstrect->w;
    vertices[3].y = dstrect->y;
    vertices[3].s = right;
    vertices[3].t = top;
    vertices[3].w = 1.0f;

    if (angle != 0.0) {
        OS4_RotateVertices(vertices, angle, center);
    }

    if (scale_x != 1.0f || scale_y != 1.0f) {
        OS4_ScaleVertices(vertices, scale_x, scale_y);
    }
}

static bool
OS4_RenderFillRects(SDL_Renderer * renderer, const SDL_FRect * rects, int count, SDL_BlendMode mode,
    Uint8 a, Uint8 r, Uint8 g, Uint8 b)
{
    OS4_RenderData *data = (OS4_RenderData *) renderer->internal;
    struct BitMap *bitmap = OS4_ActivateRenderer(renderer);
    bool status;

    //dprintf("Called for %d rects\n", count);
    //Sint32 s = SDL_GetTicks();

    if (!bitmap) {
        return false;
    }

    if (mode == SDL_BLENDMODE_NONE) {
        const Uint32 color = a << 24 | r << 16 | g << 8 | b;

        for (int i = 0; i < count; ++i) {
            //dprintf("rp %p, rect x %f, y %f, w %f, h %f\n", &data->rastport, rects[i].x, rects[i].y, rects[i].w, rects[i].h);
            SDL_Rect irect, tmp;
            irect.x = rects[i].x;
            irect.y = rects[i].y;
            irect.w = rects[i].w;
            irect.h = rects[i].h;

            if (!SDL_GetRectIntersection(&irect, &data->cliprect, &tmp)) {
                continue;
            }

            IGraphics->RectFillColor(
                &data->rastport,
                tmp.x,
                tmp.y,
                tmp.x + tmp.w - 1,
                tmp.y + tmp.h - 1,
                color); // graphics.lib v54!
        }

        status = true;
    } else {
        Uint32 colormod;

        if (!data->solidcolor) {
            return false;
        }

        colormod = a << 24 | r << 16 | g << 8 | b;

        // Color modulation is implemented through fill texture manipulation
        if (!OS4_SetSolidColor(renderer, colormod)) {
            return false;
        }

        /* TODO: batch */
        for (int i = 0; i < count; ++i) {
            const SDL_FRect srcrect = { 0.0f, 0.0f, 1.0f, 1.0f };

            OS4_Vertex vertices[4];

            uint32 ret_code;

            OS4_FillVertexData(vertices, &srcrect, &rects[i], 0.0, NULL, SDL_FLIP_NONE, 1.0f, 1.0f);

            ret_code = IGraphics->CompositeTags(
                OS4_ConvertBlendMode(mode),
                data->solidcolor,
                bitmap,
                COMPTAG_DestX,      data->cliprect.x,
                COMPTAG_DestY,      data->cliprect.y,
                COMPTAG_DestWidth,  data->cliprect.w,
                COMPTAG_DestHeight, data->cliprect.h,
                COMPTAG_Flags,      OS4_GetCompositeFlags(mode),
                COMPTAG_VertexArray, vertices,
                COMPTAG_VertexFormat, COMPVF_STW0_Present,
                COMPTAG_NumTriangles, 2,
                COMPTAG_IndexArray, OS4_QuadIndices,
                TAG_END);

            if (ret_code) {
                static Uint32 counter = 0;

                if ((counter++ % 100) == 0) {
                    dprintf("CompositeTags: %ld (fails: %u)\n", ret_code, counter);
                }
            }
        }

        status = true;
    }

    //dprintf("Took %d\n", SDL_GetTicks() - s);

    return status;
}

static bool
OS4_RenderCopyEx(SDL_Renderer * renderer, SDL_RenderCommand * cmd, const OS4_Vertex * vertices,
    size_t count, struct BitMap * dst)
{
    SDL_Texture * texture = cmd->data.draw.texture;
    const SDL_BlendMode mode = cmd->data.draw.blend;

    OS4_RenderData *data = (OS4_RenderData *) renderer->internal;
    OS4_TextureData *texturedata = (OS4_TextureData *) texture->internal;

    struct BitMap *src = OS4_IsColorModEnabled(texture) ?
        texturedata->finalbitmap : texturedata->bitmap;

    OS4_CompositingParams params;
    uint32 ret_code;

    if (!dst) {
        return false;
    }

    OS4_SetupCompositing(renderer->target, &params, texture->scaleMode, mode, cmd->data.draw.color.a);

    //dprintf("clip x %d, y %d, w %d, h %d\n", data->cliprect.x, data->cliprect.y, data->cliprect.w, data->cliprect.h);

    ret_code = IGraphics->CompositeTags(
        OS4_ConvertBlendMode(mode),
        src,
        dst,
        COMPTAG_SrcAlpha,   COMP_FLOAT_TO_FIX(params.srcAlpha),
        COMPTAG_DestAlpha,  COMP_FLOAT_TO_FIX(params.destAlpha),
        COMPTAG_DestX,      data->cliprect.x,
        COMPTAG_DestY,      data->cliprect.y,
        COMPTAG_DestWidth,  data->cliprect.w,
        COMPTAG_DestHeight, data->cliprect.h,
        COMPTAG_Flags,      params.flags,
        COMPTAG_VertexArray, vertices,
        COMPTAG_VertexFormat, COMPVF_STW0_Present,
        COMPTAG_NumTriangles, 2 * count,
        COMPTAG_IndexArray, OS4_QuadIndices,
        TAG_END);

    if (ret_code) {
        static Uint32 counter = 0;

        if ((counter++ % 100) == 0) {
            dprintf("CompositeTags: %lu (fails: %u)\n", ret_code, counter);
        }

        return SDL_SetError("CompositeTags failed");
    }

    return true;
}

static bool
OS4_RenderGeometry(SDL_Renderer * renderer, SDL_RenderCommand * cmd, const OS4_Vertex * vertices,
    struct BitMap * dst)
{
    SDL_Texture * texture = cmd->data.draw.texture;
    const SDL_BlendMode mode = cmd->data.draw.blend;

    OS4_RenderData *data = (OS4_RenderData *) renderer->internal;
    OS4_TextureData *texturedata = (OS4_TextureData *) texture->internal;

    OS4_CompositingParams params;
    uint32 ret_code;

    if (!dst) {
        return false;
    }

    OS4_SetupCompositing(renderer->target, &params, texture->scaleMode, mode, 1.0f);

    ret_code = IGraphics->CompositeTags(
        OS4_ConvertBlendMode(mode),
        texturedata->bitmap,
        dst,
        COMPTAG_SrcAlpha,   COMP_FLOAT_TO_FIX(params.srcAlpha),
        COMPTAG_DestAlpha,  COMP_FLOAT_TO_FIX(params.destAlpha),
        COMPTAG_DestX,      data->cliprect.x,
        COMPTAG_DestY,      data->cliprect.y,
        COMPTAG_DestWidth,  data->cliprect.w,
        COMPTAG_DestHeight, data->cliprect.h,
        COMPTAG_Flags,      params.flags,
        COMPTAG_VertexArray, vertices,
        COMPTAG_VertexFormat, COMPVF_STW0_Present,
        COMPTAG_NumTriangles, cmd->data.draw.count / 3,
        TAG_END);

    if (ret_code) {
        static Uint32 counter = 0;

        if ((counter++ % 100) == 0) {
            dprintf("CompositeTags: %lu (fails: %u)\n", ret_code, counter);
        }

        return SDL_SetError("CompositeTags failed");
    }


    return true;
}

static SDL_Surface*
OS4_RenderReadPixels(SDL_Renderer * renderer, const SDL_Rect * rect)
{
    OS4_RenderData *data = (OS4_RenderData *) renderer->internal;
    struct BitMap *bitmap = OS4_ActivateRenderer(renderer);

    //dprintf("Called\n");

    if (!bitmap) {
        SDL_SetError("Failed to activate renderer");
        return NULL;
    }

    SDL_Surface *surface = SDL_CreateSurface(rect->w, rect->h, SDL_PIXELFORMAT_ARGB8888);

    if (!surface) {
        SDL_SetError("Failed to create surface");
        return NULL;
    }

    IGraphics->ReadPixelArray(
        &data->rastport,
        rect->x,
        rect->y,
        surface->pixels,
        0,
        0,
        surface->pitch,
        PIXF_A8R8G8B8,
        rect->w,
        rect->h);

    return surface;
}

static int min(int a, int b)
{
    return (a < b) ? a : b;
}

static bool
OS4_RenderPresent(SDL_Renderer * renderer)
{
    SDL_Window *window = renderer->window;
    struct BitMap *source = OS4_ActivateRenderer(renderer);

    //dprintf("Called\n");
    //Uint32 s = SDL_GetTicks();

    if (window && source) {
        // TODO: should we take viewport into account?

        SDL_WindowData *windowdata = (SDL_WindowData *)window->internal;

        struct Window *syswin = windowdata->syswin;

        if (syswin) {
            int32 ret;
            int width;
            int height;

            OS4_RenderData *data = (OS4_RenderData *)renderer->internal;

            //dprintf("target %p\n", data->target);
            if (data->vsync) {
                IGraphics->WaitTOF();
            }

            ILayers->LockLayer(0, syswin->WLayer);

            width = min(window->w, syswin->Width - (syswin->BorderLeft + syswin->BorderRight));
            height = min(window->h, syswin->Height - (syswin->BorderTop + syswin->BorderBottom));

            ret = IGraphics->BltBitMapTags(
                BLITA_Source, source,
                BLITA_DestType, BLITT_RASTPORT,
                BLITA_Dest, syswin->RPort,
                BLITA_DestX, syswin->BorderLeft,
                BLITA_DestY, syswin->BorderTop,
                BLITA_Width, width,
                BLITA_Height, height,
                TAG_DONE);

            ILayers->UnlockLayer(syswin->WLayer);

            if (ret != -1) {
                dprintf("BltBitMapTags(): %ld\n", ret);
                return false;
            }
        }
    }
    //dprintf("Took %d\n", SDL_GetTicks() - s);

    return true;
}

static void
OS4_RenderClear(SDL_Renderer * renderer, Uint8 a, Uint8 r, Uint8 g, Uint8 b, struct BitMap * bitmap)
{
    OS4_RenderData *data = (OS4_RenderData *) renderer->internal;
    const Uint32 color = (a << 24) | (r << 16) | (g << 8) | b;

    int width = 0;
    int height = 0;

    OS4_GetBitMapSize(renderer, bitmap, &width, &height);

    //dprintf("Clear with color 0x%X rp %p, w %d, h %d\n", color, &data->rastport, width, height);

    IGraphics->RectFillColor(
        &data->rastport,
        0,
        0,
        width - 1,
        height - 1,
        color); // graphics.lib v54!
}

static void
OS4_DestroyRenderer(SDL_Renderer * renderer)
{
    OS4_RenderData *data = (OS4_RenderData *) renderer->internal;

    if (data->bitmap) {
        dprintf("Freeing renderer bitmap %p\n", data->bitmap);

        IGraphics->FreeBitMap(data->bitmap);
        data->bitmap = NULL;
    }

    if (data->solidcolor) {
        IGraphics->FreeBitMap(data->solidcolor);
        data->solidcolor = NULL;
    }

    SDL_free(data);
}

static bool
OS4_QueueNop(SDL_Renderer * renderer, SDL_RenderCommand *cmd)
{
    return true;
}

static bool
OS4_QueueDrawPoints(SDL_Renderer * renderer, SDL_RenderCommand *cmd, const SDL_FPoint * points, int count)
{
    SDL_Point *verts = (SDL_Point *) SDL_AllocateRenderVertices(renderer, count * sizeof(SDL_Point), 0, &cmd->data.draw.first);

    if (!verts) {
        return SDL_OutOfMemory();
    }

    cmd->data.draw.count = count;

    for (size_t i = 0; i < count; i++, verts++, points++) {
        verts->x = (int)points->x;
        verts->y = (int)points->y;
    }

    return true;
}

static bool
OS4_QueueDrawLines(SDL_Renderer * renderer, SDL_RenderCommand *cmd, const SDL_FPoint * points, int count)
{
    return OS4_QueueDrawPoints(renderer, cmd, points, count);
}

static bool
OS4_QueueFillRects(SDL_Renderer * renderer, SDL_RenderCommand *cmd, const SDL_FRect * rects, int count)
{
    SDL_FRect *verts = (SDL_FRect *) SDL_AllocateRenderVertices(renderer, count * sizeof(SDL_FRect), 0, &cmd->data.draw.first);

    if (!verts) {
        return false;
    }

    cmd->data.draw.count = count;

    for (size_t i = 0; i < count; i++, verts++, rects++) {
        verts->x = (int)rects->x;
        verts->y = (int)rects->y;
        verts->w = SDL_max((int)rects->w, 1);
        verts->h = SDL_max((int)rects->h, 1);
    }

    return true;
}

static bool
OS4_QueueCopyEx(SDL_Renderer * renderer, SDL_RenderCommand *cmd, SDL_Texture * texture,
               const SDL_FRect * srcrect, const SDL_FRect * dstrect,
               const double angle, const SDL_FPoint *center, const SDL_FlipMode flip, float scale_x, float scale_y)
{
    SDL_FPoint final_center;

    OS4_Vertex *verts = (OS4_Vertex *) SDL_AllocateRenderVertices(renderer,
        4 * sizeof(OS4_Vertex), 0, &cmd->data.draw.first);

    if (!verts) {
        return SDL_OutOfMemory();
    }
    //dprintf("SRC %d, %d, %d, %d, DST %f, %f, %f, %f\n", srcrect->x, srcrect->y, srcrect->w, srcrect->h, dstrect->x, dstrect->y, dstrect->w, dstrect->h);
    cmd->data.draw.count = 1;

    final_center.x = dstrect->x + center->x;
    final_center.y = dstrect->y + center->y;

    OS4_FillVertexData(verts, srcrect, dstrect, angle, &final_center, flip, scale_x, scale_y);

    return OS4_SetTextureColorMod(renderer, texture);
}

static bool
OS4_QueueCopy(SDL_Renderer * renderer, SDL_RenderCommand * cmd, SDL_Texture * texture,
    const SDL_FRect * srcrect, const SDL_FRect *dstrect)
{
    const SDL_FPoint center = { 0.0f, 0.0f };
    return OS4_QueueCopyEx(renderer, cmd, texture, srcrect, dstrect, 0.0, &center, SDL_FLIP_NONE, 1.0f, 1.0f);
}

static bool OS4_QueueGeometry(SDL_Renderer *renderer, SDL_RenderCommand *cmd, SDL_Texture *texture,
    const float *xy, int xy_stride, const SDL_FColor *color, int color_stride, const float *uv, int uv_stride,
    int num_vertices, const void *indices, int num_indices, int size_indices,
    float scale_x, float scale_y)
{
    int count = indices ? num_indices : num_vertices;
    OS4_Vertex *verts;

    /* CompositeTags vertex mode has various limitations */

    if (!texture) {
        static Uint32 counter = 0;
        if (counter++ < 10) {
            dprintf("Texture required for geometry\n");
        }
        return SDL_Unsupported();
    }

    if (color) {
        static Uint32 counter = 0;
        if (counter++ < 10) {
            dprintf("Per-vertex color modulation not supported\n");
        }
        //return SDL_Unsupported();
    }

    verts = (OS4_Vertex *) SDL_AllocateRenderVertices(renderer, count * sizeof(OS4_Vertex), 0, &cmd->data.draw.first);
    if (!verts) {
        return SDL_OutOfMemory();
    }

    cmd->data.draw.count = count;
    size_indices = indices ? size_indices : 0;

    for (int i = 0; i < count; i++) {
        int j;
        float *xy_;
        if (size_indices == 4) {
            j = ((const Uint32 *)indices)[i];
        } else if (size_indices == 2) {
            j = ((const Uint16 *)indices)[i];
        } else if (size_indices == 1) {
            j = ((const Uint8 *)indices)[i];
        } else {
            j = i;
        }

        xy_ = (float *)((char*)xy + j * xy_stride);

        verts->x = xy_[0] * scale_x;
        verts->y = xy_[1] * scale_y;

        float *uv_ = (float *)((char*)uv + j * uv_stride);
        verts->s = uv_[0] * texture->w;
        verts->t = uv_[1] * texture->h;
        verts->w = 1.0f;
        verts++;
    }

    return true;
}

static void
OS4_ResetClipRect(SDL_Renderer * renderer, struct BitMap * bitmap)
{
    // CompositeTags uses cliprect: with clipping disabled, maximize it

    OS4_RenderData *data = (OS4_RenderData *)renderer->internal;

    int width, height;

    OS4_GetBitMapSize(renderer, bitmap, &width, &height);

    data->cliprect.x = 0;
    data->cliprect.y = 0;
    data->cliprect.w = width;
    data->cliprect.h = height;
}

static bool
OS4_RunCommandQueue(SDL_Renderer * renderer, SDL_RenderCommand * cmd, void * vertices, size_t vertsize)
{
    OS4_RenderData *data = (OS4_RenderData *)renderer->internal;

    struct BitMap *bitmap = OS4_ActivateRenderer(renderer);

    if (!bitmap) {
        dprintf("NULL bitmap\n");
        return false;
    }

    while (cmd) {
        switch (cmd->command) {
            case SDL_RENDERCMD_SETDRAWCOLOR:
                // Nothing to do
                break;

            case SDL_RENDERCMD_SETVIEWPORT: {
                SDL_Rect *viewport = &data->viewport;
                if (SDL_memcmp(viewport, &cmd->data.viewport.rect, sizeof(SDL_Rect)) != 0) {
                    SDL_memcpy(viewport, &cmd->data.viewport.rect, sizeof(SDL_Rect));

                    //dprintf("viewport x %d, y %d, w %d, h %d\n", viewport->x, viewport->y, viewport->w, viewport->h);

                    if (!data->cliprect_enabled) {
                        OS4_ResetClipRect(renderer, bitmap);
                    }

                    SDL_GetRectIntersection(viewport, &data->cliprect, &data->cliprect);
                }
                break;
            }

            case SDL_RENDERCMD_SETCLIPRECT: {
                const SDL_Rect *rect = &cmd->data.cliprect.rect;
                if (data->cliprect_enabled != cmd->data.cliprect.enabled) {
                    data->cliprect_enabled = cmd->data.cliprect.enabled;

                    //dprintf("cliprect enabled %d\n", data->cliprect_enabled);
                }

                if (SDL_memcmp(&data->cliprect, rect, sizeof(SDL_Rect)) != 0) {
                    SDL_memcpy(&data->cliprect, rect, sizeof(SDL_Rect));

                    if (data->cliprect_enabled) {
                        data->cliprect.x += data->viewport.x;
                        data->cliprect.y += data->viewport.y;

                        //dprintf("cliprect x %d, y %d, w %d, h %d\n", data->cliprect.x, data->cliprect.y, data->cliprect.w, data->cliprect.h);
                    }
                }

                if (!data->cliprect_enabled) {
                    OS4_ResetClipRect(renderer, bitmap);
                }

                SDL_GetRectIntersection(&data->viewport, &data->cliprect, &data->cliprect);

                break;
            }

            case SDL_RENDERCMD_CLEAR: {
                const Uint8 r = cmd->data.color.color.r * 255.0f;
                const Uint8 g = cmd->data.color.color.g * 255.0f;
                const Uint8 b = cmd->data.color.color.b * 255.0f;
                const Uint8 a = cmd->data.color.color.a * 255.0f;
                OS4_RenderClear(renderer, a, r, g, b, bitmap);
                break;
            }

            case SDL_RENDERCMD_DRAW_POINTS: {
                const Uint8 r = cmd->data.draw.color.r * 255.0f;
                const Uint8 g = cmd->data.draw.color.g * 255.0f;
                const Uint8 b = cmd->data.draw.color.b * 255.0f;
                const Uint8 a = cmd->data.draw.color.a * 255.0f;
                const size_t count = cmd->data.draw.count;
                SDL_Point *verts = (SDL_Point *)(((Uint8 *) vertices) + cmd->data.draw.first);
                const SDL_BlendMode blend = cmd->data.draw.blend;

                /* Apply viewport */
                if (data->viewport.x || data->viewport.y) {
                    for (int i = 0; i < count; i++) {
                        verts[i].x += data->viewport.x;
                        verts[i].y += data->viewport.y;
                    }
                }

                OS4_RenderDrawPoints(renderer, verts, count, blend, a, r, g, b);
                break;
            }

            case SDL_RENDERCMD_DRAW_LINES: {
                const Uint8 r = cmd->data.draw.color.r * 255.0f;
                const Uint8 g = cmd->data.draw.color.g * 255.0f;
                const Uint8 b = cmd->data.draw.color.b * 255.0f;
                const Uint8 a = cmd->data.draw.color.a * 255.0f;
                const size_t count = cmd->data.draw.count;
                SDL_Point *verts = (SDL_Point *)(((Uint8 *) vertices) + cmd->data.draw.first);
                const SDL_BlendMode blend = cmd->data.draw.blend;

                /* Apply viewport */
                if (data->viewport.x || data->viewport.y) {
                    for (int i = 0; i < count; i++) {
                        verts[i].x += data->viewport.x;
                        verts[i].y += data->viewport.y;
                    }
                }

                OS4_RenderDrawLines(renderer, verts, count, blend, a, r, g, b);
                break;
            }

            case SDL_RENDERCMD_FILL_RECTS: {
                const Uint8 r = cmd->data.draw.color.r * 255.0f;
                const Uint8 g = cmd->data.draw.color.g * 255.0f;
                const Uint8 b = cmd->data.draw.color.b * 255.0f;
                const Uint8 a = cmd->data.draw.color.a * 255.0f;
                const size_t count = cmd->data.draw.count;
                SDL_FRect *verts = (SDL_FRect *)(((Uint8 *) vertices) + cmd->data.draw.first);
                const SDL_BlendMode blend = cmd->data.draw.blend;

                /* Apply viewport */
                if (data->viewport.x || data->viewport.y) {
                    for (int i = 0; i < count; i++) {
                        verts[i].x += data->viewport.x;
                        verts[i].y += data->viewport.y;
                    }
                }

                OS4_RenderFillRects(renderer, verts, count, blend, a, r, g, b);
                break;
            }

            case SDL_RENDERCMD_COPY: {
                OS4_Vertex *verts = (OS4_Vertex *)(((Uint8 *) vertices) + cmd->data.draw.first);
                SDL_Texture *thistexture = cmd->data.draw.texture;
                SDL_BlendMode thisblend = cmd->data.draw.blend;
                const SDL_RenderCommandType thiscmdtype = cmd->command;
                SDL_RenderCommand *finalcmd = cmd;
                SDL_RenderCommand *nextcmd = cmd->next;
                size_t count = cmd->data.draw.count;

                while (nextcmd) {
                    const SDL_RenderCommandType nextcmdtype = nextcmd->command;
                    if (nextcmdtype != thiscmdtype) {
                        break; /* can't go any further on this draw call, different render command up next. */
                    } else if (nextcmd->data.draw.texture != thistexture || nextcmd->data.draw.blend != thisblend) {
                        break; /* can't go any further on this draw call, different texture/blendmode copy up next. */
                    } else if (nextcmd->data.draw.color.a != cmd->data.draw.color.a ||
                               nextcmd->data.draw.color.r != cmd->data.draw.color.r ||
                               nextcmd->data.draw.color.g != cmd->data.draw.color.g ||
                               nextcmd->data.draw.color.b != cmd->data.draw.color.b) {
                        break; /* different color value */
                    } else if ((count + nextcmd->data.draw.count) > MAX_QUADS) {
                        //dprintf("Too much data %d\n", count);
                        break; /* too much data for one call */
                    } else {
                        finalcmd = nextcmd; /* we can combine copy operations here. Mark this one as the furthest okay command. */
                        count += nextcmd->data.draw.count;
                    }
                    nextcmd = nextcmd->next;
                }

                /* Apply viewport */
                if (data->viewport.x || data->viewport.y) {
                    for (int i = 0; i < count * 4; i++) {
                        verts[i].x += data->viewport.x;
                        verts[i].y += data->viewport.y;
                    }
                }

                OS4_RenderCopyEx(renderer, cmd, verts, count, bitmap);
                cmd = finalcmd;
                break;
            }

            case SDL_RENDERCMD_COPY_EX: {
                OS4_Vertex *verts = (OS4_Vertex *)(((Uint8 *) vertices) + cmd->data.draw.first);
                SDL_Texture *thistexture = cmd->data.draw.texture;
                SDL_BlendMode thisblend = cmd->data.draw.blend;
                const SDL_RenderCommandType thiscmdtype = cmd->command;
                SDL_RenderCommand *finalcmd = cmd;
                SDL_RenderCommand *nextcmd = cmd->next;
                size_t count = cmd->data.draw.count;

                while (nextcmd) {
                    const SDL_RenderCommandType nextcmdtype = nextcmd->command;
                    if (nextcmdtype != thiscmdtype) {
                        break; /* can't go any further on this draw call, different render command up next. */
                    } else if (nextcmd->data.draw.texture != thistexture || nextcmd->data.draw.blend != thisblend) {
                        break; /* can't go any further on this draw call, different texture/blendmode copy up next. */
                    } else if (nextcmd->data.draw.color.a != cmd->data.draw.color.a ||
                               nextcmd->data.draw.color.r != cmd->data.draw.color.r ||
                               nextcmd->data.draw.color.g != cmd->data.draw.color.g ||
                               nextcmd->data.draw.color.b != cmd->data.draw.color.b) {
                        break; /* different color value */
                    } else if ((count + nextcmd->data.draw.count) > MAX_QUADS) {
                        //dprintf("Too much data %d\n", count);
                        break; /* too much data for one call */
                    } else {
                        finalcmd = nextcmd; /* we can combine copy operations here. Mark this one as the furthest okay command. */
                        count += nextcmd->data.draw.count;
                    }
                    nextcmd = nextcmd->next;
                }

                /* Apply viewport */
                if (data->viewport.x || data->viewport.y) {
                    for (int i = 0; i < count * 4; i++) {
                        verts[i].x += data->viewport.x;
                        verts[i].y += data->viewport.y;
                    }
                }

                OS4_RenderCopyEx(renderer, cmd, verts, count, bitmap);
                cmd = finalcmd;
                break;
            }

            case SDL_RENDERCMD_GEOMETRY: {
                OS4_Vertex *verts = (OS4_Vertex *)(((Uint8 *) vertices) + cmd->data.draw.first);
                const size_t count = cmd->data.draw.count;

                /* Apply viewport */
                if (data->viewport.x || data->viewport.y) {
                    for (int i = 0; i < count; i++) {
                        verts[i].x += data->viewport.x;
                        verts[i].y += data->viewport.y;
                    }
                }

                OS4_RenderGeometry(renderer, cmd, verts, bitmap);
                break;
            }

            case SDL_RENDERCMD_NO_OP:
                break;
        }

        cmd = cmd->next;
    }

    return true;
}

static bool
OS4_SetVSync(SDL_Renderer * renderer, int vsync)
{
    OS4_RenderData *data = renderer->internal;

    dprintf("VSYNC %d\n", vsync);

    data->vsync = vsync;

    return true;
}

static void
OS4_InvalidateCachedState(SDL_Renderer *renderer)
{
    // TODO:
}

static void
OS4_PrecalculateIndices(void)
{
    for (int i = 0; i < MAX_QUADS; i++) {
        const int index = i * 6;
        const int vertex = i * 4;

        OS4_QuadIndices[index + 0] = vertex + 0;
        OS4_QuadIndices[index + 1] = vertex + 1;
        OS4_QuadIndices[index + 2] = vertex + 2;
        OS4_QuadIndices[index + 3] = vertex + 2;
        OS4_QuadIndices[index + 4] = vertex + 3;
        OS4_QuadIndices[index + 5] = vertex + 0;
    }
}

static bool
OS4_CreateRenderer(SDL_Renderer * renderer, SDL_Window * window, SDL_PropertiesID create_props)
{
    OS4_RenderData *data;

    dprintf("Creating renderer for '%s'\n", window->title);

    data = (OS4_RenderData *) SDL_calloc(1, sizeof(*data));
    if (!data) {
        OS4_DestroyRenderer(renderer);
        return SDL_OutOfMemory();
    }

    renderer->WindowEvent = OS4_WindowEvent;
    renderer->GetOutputSize = OS4_GetOutputSize;
    renderer->CreateTexture = OS4_CreateTexture;
    renderer->UpdateTexture = OS4_UpdateTexture;
    renderer->LockTexture = OS4_LockTexture;
    renderer->UnlockTexture = OS4_UnlockTexture;
    renderer->SetRenderTarget = OS4_SetRenderTarget;
    renderer->QueueSetViewport = OS4_QueueNop;
    renderer->QueueSetDrawColor = OS4_QueueNop;
    renderer->QueueDrawPoints = OS4_QueueDrawPoints;
    renderer->QueueDrawLines = OS4_QueueDrawLines;
    renderer->QueueFillRects = OS4_QueueFillRects;
    renderer->QueueCopy = OS4_QueueCopy;
    renderer->QueueCopyEx = OS4_QueueCopyEx;
    renderer->QueueGeometry = OS4_QueueGeometry;
    renderer->InvalidateCachedState = OS4_InvalidateCachedState;
    renderer->RunCommandQueue = OS4_RunCommandQueue;
    renderer->RenderReadPixels = OS4_RenderReadPixels;
    renderer->RenderPresent = OS4_RenderPresent;
    renderer->DestroyTexture = OS4_DestroyTexture;
    renderer->DestroyRenderer = OS4_DestroyRenderer;
    renderer->SetVSync = OS4_SetVSync;
    renderer->name = AMIGAOS4_RenderDriver.name;
    renderer->internal = data;

    SDL_AddSupportedTextureFormat(renderer, SDL_PIXELFORMAT_ARGB8888);

    IGraphics->InitRastPort(&data->rastport);

    data->vsync = SDL_GetNumberProperty(create_props, SDL_PROP_RENDERER_CREATE_PRESENT_VSYNC_NUMBER, 0);

    dprintf("VSYNC: %s\n", data->vsync ? "on" : "off");

    OS4_PrecalculateIndices();

    return true;
}

SDL_RenderDriver AMIGAOS4_RenderDriver = {
    OS4_CreateRenderer, "compositing"
};

#endif /* !SDL_RENDER_DISABLED */
