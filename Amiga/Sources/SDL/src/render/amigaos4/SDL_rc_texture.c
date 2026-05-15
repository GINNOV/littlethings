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

#include <proto/graphics.h>

#include "../../main/amigaos4/SDL_os4debug.h"

static bool
OS4_IsBlendModeSupported(SDL_BlendMode mode)
{
    switch (mode) {
        case SDL_BLENDMODE_NONE:
        case SDL_BLENDMODE_BLEND:
        case SDL_BLENDMODE_ADD:
            //dprintf("Texture blend mode: %d\n", mode);
            return true;
        default:
            dprintf("Not supported blend mode %d\n", mode);
            return false;
    }
}

bool
OS4_CreateTexture(SDL_Renderer * renderer, SDL_Texture * texture, SDL_PropertiesID create_props)
{
    int bpp;
    Uint32 Rmask, Gmask, Bmask, Amask;
    OS4_TextureData *texturedata;

    if (texture->format != SDL_PIXELFORMAT_ARGB8888) {
        return SDL_SetError("Not supported texture format");
    }

    if (!SDL_GetMasksForPixelFormat
        (texture->format, &bpp, &Rmask, &Gmask, &Bmask, &Amask)) {
        return SDL_SetError("Unknown texture format");
    }

    //dprintf("Allocation VRAM bitmap %d*%d*%d for texture\n", texture->w, texture->h, bpp);

    texturedata = SDL_calloc(1, sizeof(*texturedata));
    if (!texturedata)
    {
        dprintf("Failed to allocate driver data\n");
        return SDL_OutOfMemory();
    }

    texturedata->bitmap = OS4_AllocBitMap(renderer, texture->w, texture->h, bpp, "texture");

    if (!texturedata->bitmap) {
        SDL_free(texturedata);
        return SDL_SetError("Failed to allocate bitmap");
    }

    /* Check texture parameters just for debug */
    //OS4_IsColorModEnabled(texture);
    OS4_IsBlendModeSupported(texture->blendMode);

    texture->internal = texturedata;

    return true;
}

static bool
OS4_ModulateRGB(SDL_Texture * texture, Uint8 * src, int pitch)
{
    bool result = false;

    OS4_TextureData *texturedata = (OS4_TextureData *) texture->internal;

    if (texturedata->finalbitmap) {
        APTR baseaddress;
        uint32 bytesperrow;

        APTR lock = IGraphics->LockBitMapTags(
            texturedata->finalbitmap,
            LBM_BaseAddress, &baseaddress,
            LBM_BytesPerRow, &bytesperrow,
            TAG_DONE);

        if (lock) {
            for (int y = 0; y < texture->h; y++) {
                Uint32 *readaddress = (Uint32 *)(src + y * pitch);
                Uint32 *writeaddress = (Uint32 *)(baseaddress + y * bytesperrow);

                for (int x = 0; x < texture->w; x++) {

                    Uint32 oldcolor = readaddress[x];
                    Uint32 newcolor = (oldcolor & 0xFF000000);

                    Uint8 r = (oldcolor & 0x00FF0000) >> 16;
                    Uint8 g = (oldcolor & 0x0000FF00) >> 8;
                    Uint8 b = (oldcolor & 0x000000FF);

                    newcolor |= (int)(r * texture->color.r) << 16;
                    newcolor |= (int)(g * texture->color.g) << 8;
                    newcolor |= (int)(b * texture->color.b);

                    writeaddress[x] = newcolor;
                }
            }

            IGraphics->UnlockBitMap(texturedata->finalbitmap);

            result = true;
        } else {
            dprintf("Lock failed\n");
        }
    }

    return result;
}

static bool
OS4_NeedRemodulation(SDL_Texture * texture)
{
    OS4_TextureData *texturedata = (OS4_TextureData *) texture->internal;

    if (texture->color.r != texturedata->r ||
        texture->color.g != texturedata->g ||
        texture->color.b != texturedata->b ||
        texturedata->finalbitmap == NULL) {

        return true;
    }

    return false;
}

bool
OS4_SetTextureColorMod(SDL_Renderer * renderer, SDL_Texture * texture)
{
    /* Modulate only when needed, it's CPU heavy */
    if (OS4_IsColorModEnabled(texture) && OS4_NeedRemodulation(texture)) {
        OS4_RenderData *data = (OS4_RenderData *) renderer->internal;
        OS4_TextureData *texturedata = (OS4_TextureData *) texture->internal;

        if (!texturedata->rambuf) {
            struct BitMap *oldRastPortBM;

            if (!(texturedata->rambuf = SDL_malloc(texture->w * texture->h * sizeof(Uint32)))) {
                dprintf("Failed to allocate ram buffer\n");
                return SDL_OutOfMemory();
            }

            /* Copy texture from VRAM to RAM buffer for faster color modulation. We also
            temporarily borrow rastport from renderer */
            oldRastPortBM = data->rastport.BitMap;

            data->rastport.BitMap = texturedata->bitmap;

            IGraphics->ReadPixelArray(
                &data->rastport,
                0,
                0,
                texturedata->rambuf,
                0,
                0,
                texture->w * sizeof(Uint32),
                PIXF_A8R8G8B8,
                texture->w,
                texture->h);

            data->rastport.BitMap = oldRastPortBM;
        }

        if (!texturedata->finalbitmap) {
            if (!(texturedata->finalbitmap = OS4_AllocBitMap(renderer, texture->w, texture->h, 32, "color modulation"))) {
                return SDL_OutOfMemory();
            }
        }

        if (!OS4_ModulateRGB(texture, texturedata->rambuf, texture->w * sizeof(Uint32))) {
            return SDL_SetError("RGB modulation failed");
        }

        /* Remember last values so that we can avoid re-modulation with same parameters */
        texturedata->r = texture->color.r;
        texturedata->g = texture->color.g;
        texturedata->b = texture->color.b;

        /* Workaround: color modulation cannot be batched due to texture manipulation */
        SDL_FlushRenderer(renderer);
    }

    return true;
}

bool
OS4_UpdateTexture(SDL_Renderer * renderer, SDL_Texture * texture,
                 const SDL_Rect * rect, const void *pixels, int pitch)
{
    OS4_TextureData *texturedata = (OS4_TextureData *) texture->internal;

    int32 ret = IGraphics->BltBitMapTags(
        BLITA_Source, pixels,
        BLITA_SrcType, BLITT_ARGB32,
        BLITA_SrcBytesPerRow, pitch,
        BLITA_Dest, texturedata->bitmap,
        BLITA_DestX, rect->x,
        BLITA_DestY, rect->y,
        BLITA_Width, rect->w,
        BLITA_Height, rect->h,
        TAG_DONE);

    if (ret != -1) {
        dprintf("BltBitMapTags(): %ld\n", ret);
        return SDL_SetError("BltBitMapTags failed");
    }

    if (OS4_IsColorModEnabled(texture)) {
        if (!texturedata->finalbitmap) {
            if (!(texturedata->finalbitmap = OS4_AllocBitMap(renderer, texture->w, texture->h, 32, "color modulation"))) {
                return SDL_OutOfMemory();
            }
        }

        // This can be really slow, if done per frame
        if (!OS4_ModulateRGB(texture, (Uint8 *)pixels, pitch)) {
            return SDL_SetError("RGB modulation failed");
        }
    }

    return true;
}

bool
OS4_LockTexture(SDL_Renderer * renderer, SDL_Texture * texture,
               const SDL_Rect * rect, void **pixels, int *pitch)
{
    OS4_TextureData *texturedata = (OS4_TextureData *) texture->internal;

    APTR baseaddress;
    uint32 bytesperrow;

    //dprintf("Called\n");

    texturedata->lock = IGraphics->LockBitMapTags(
        texturedata->bitmap,
        LBM_BaseAddress, &baseaddress,
        LBM_BytesPerRow, &bytesperrow,
        TAG_DONE);

    if (texturedata->lock) {
        *pixels =
             (void *) ((Uint8 *) baseaddress + rect->y * bytesperrow +
                  rect->x * 4);

        *pitch = bytesperrow;

        return true;
    }

    dprintf("Lock failed\n");
    return SDL_SetError("Lock failed");
}

void
OS4_UnlockTexture(SDL_Renderer * renderer, SDL_Texture * texture)
{
    OS4_TextureData *texturedata = (OS4_TextureData *) texture->internal;

    //dprintf("Called\n");

    if (texturedata->lock) {
        IGraphics->UnlockBitMap(texturedata->lock);
        texturedata->lock = NULL;
    }
}

bool
OS4_SetRenderTarget(SDL_Renderer * renderer, SDL_Texture * texture)
{
    OS4_RenderData *data = (OS4_RenderData *) renderer->internal;

    if (texture) {
        OS4_TextureData *texturedata = (OS4_TextureData *) texture->internal;
        data->target = texturedata->bitmap;

        //dprintf("Render target texture %p (bitmap %p)\n", texture, data->target);
    } else {
        data->target = data->bitmap;
        //dprintf("Render target window\n");
    }
    return true;
}

void
OS4_DestroyTexture(SDL_Renderer * renderer, SDL_Texture * texture)
{
    OS4_TextureData *texturedata = (OS4_TextureData *) texture->internal;

    if (texturedata) {
        if (texturedata->bitmap) {
            //dprintf("Freeing texture bitmap %p\n", texturedata->bitmap);

            IGraphics->FreeBitMap(texturedata->bitmap);
            texturedata->bitmap = NULL;
        }

        if (texturedata->finalbitmap) {
            IGraphics->FreeBitMap(texturedata->finalbitmap);
            texturedata->finalbitmap = NULL;
        }

        if (texturedata->rambuf) {
            SDL_free(texturedata->rambuf);
            texturedata->rambuf = NULL;
        }

        SDL_free(texturedata);
    }
}

#endif /* !SDL_RENDER_DISABLED */
