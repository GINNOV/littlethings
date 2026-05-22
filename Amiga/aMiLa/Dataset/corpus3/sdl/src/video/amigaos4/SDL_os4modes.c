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

#if SDL_VIDEO_DRIVER_AMIGAOS4

#include <proto/graphics.h>
#include <proto/intuition.h>

#include "SDL_os4video.h"
#include "SDL_os4modes.h"

#include "../../main/amigaos4/SDL_os4debug.h"

static bool
OS4_GetDisplayMode(ULONG id, SDL_DisplayMode * mode)
{
    SDL_DisplayModeData *data;
    APTR handle;
    struct DimensionInfo diminfo;
    struct DisplayInfo dispinfo;

    handle = IGraphics->FindDisplayInfo(id);
    if (!handle) {
        dprintf("Failed to get display info handle\n");
        return false;
    }

    if (!IGraphics->GetDisplayInfoData(handle, (UBYTE *)&diminfo, sizeof(diminfo), DTAG_DIMS, 0)) {
        dprintf("Failed to get dimension info\n");
        return false;
    }

    if (!IGraphics->GetDisplayInfoData(handle, (UBYTE *)&dispinfo, sizeof(dispinfo), DTAG_DISP, 0)) {
        dprintf("Failed to get display info\n");
        return false;
    }

    data = (SDL_DisplayModeData *) SDL_malloc(sizeof(*data));
    if (!data) {
        dprintf("Failed to allocate memory\n");
        return false;
    }

    SDL_zero(*mode);
    data->modeid = id;
    data->x = diminfo.Nominal.MinX;
    data->y = diminfo.Nominal.MinY;

    mode->displayID = 1;
    mode->w = diminfo.Nominal.MaxX - diminfo.Nominal.MinX + 1;
    mode->h = diminfo.Nominal.MaxY - diminfo.Nominal.MinY + 1;
    mode->pixel_density = 1.0f;
    mode->refresh_rate = 60.0f; // grab DTAG_MNTR?
    mode->format = SDL_PIXELFORMAT_UNKNOWN;
    mode->refresh_rate_numerator = 0;
    mode->refresh_rate_denominator = 0;

    // We are only interested in RTG modes
    if (dispinfo.PropertyFlags & DIPF_IS_RTG) {
        dprintf("RTG mode 0x%lX (%lu): w %d, h %d, bits %u, pixel format %lu\n",
                id, id, mode->w, mode->h, diminfo.MaxDepth, dispinfo.PixelFormat);

        // TODO: could map PixelFormat to SDL_PIXELFORMAT directly
        switch (diminfo.MaxDepth) {
        case 32:
            mode->format = SDL_PIXELFORMAT_ARGB8888;
            break;
        case 24:
            mode->format = SDL_PIXELFORMAT_XRGB8888;
            break;
        case 16:
            mode->format = SDL_PIXELFORMAT_RGB565;
            break;
        case 15:
            mode->format = SDL_PIXELFORMAT_XRGB1555;
            break;
        case 8:
            mode->format = SDL_PIXELFORMAT_INDEX8;
            break;
        }
    }

    mode->internal = data;

    return true;
}

static bool
OS4_LockPubScreen(SDL_VideoDevice *_this)
{
    SDL_VideoData *data = (SDL_VideoData *) _this->internal;

    dprintf("Locking public screen\n");

    data->publicScreen = IIntuition->LockPubScreen(NULL);

    if (data->publicScreen) {
        dprintf("Public screen %p locked\n", data->publicScreen);
        return true;
    } else {
        dprintf("Failed to lock Workbench screen\n");
        return false;
    }
}

static void
OS4_UnlockPubScreen(SDL_VideoDevice *_this)
{
    SDL_VideoData *data = (SDL_VideoData *) _this->internal;

    if (data->publicScreen) {
        dprintf("Unlocking public screen %p\n", data->publicScreen);

        IIntuition->UnlockPubScreen(NULL, data->publicScreen);
        data->publicScreen = NULL;
    }
}

bool
OS4_InitModes(SDL_VideoDevice *_this)
{
    SDL_VideoData *data = (SDL_VideoData *) _this->internal;
    SDL_VideoDisplay display;
    static SDL_DisplayMode current_mode;
    SDL_DisplayData *displaydata;
    ULONG modeid = 0;

    dprintf("Called\n");

    displaydata = (SDL_DisplayData *) SDL_calloc(sizeof(*displaydata), 1);
    if (!displaydata) {
        return SDL_OutOfMemory();
    }

    if (!OS4_LockPubScreen(_this)) {
        SDL_free(displaydata);
        return SDL_SetError("No displays available");
    }

    IIntuition->GetScreenAttrs(data->publicScreen, SA_DisplayID, &modeid, TAG_DONE);
    if (!OS4_GetDisplayMode(modeid, &current_mode)) {
        dprintf("Failed to get display mode for 0x%lX (%lu)\n", modeid, modeid);
        SDL_free(displaydata);
        return SDL_SetError("Couldn't get display mode");
    }

    /* OS4 has no multi-monitor support */
    SDL_zero(display);
    display.id = 1;
    display.desktop_mode = current_mode;
    display.current_mode = &current_mode;
    display.internal = displaydata; // TODO: it's uninitialized!
    displaydata->screen = NULL;

    SDL_AddVideoDisplay(&display, false);

    return true;
}

bool
OS4_GetDisplayBounds(SDL_VideoDevice *_this, SDL_VideoDisplay * display, SDL_Rect * rect)
{
    SDL_DisplayModeData *data = (SDL_DisplayModeData *) display->current_mode->internal;

    rect->x = data->x;
    rect->y = data->y;
    rect->w = display->current_mode->w;
    rect->h = display->current_mode->h;

    dprintf("x %d, y %d, w %d, h %d\n", rect->x, rect->y, rect->w, rect->h);

    return true;
}

bool
OS4_GetDisplayModes(SDL_VideoDevice *_this, SDL_VideoDisplay * display)
{
    SDL_DisplayMode mode;
    ULONG id = INVALID_ID;

    dprintf("Called\n");

    while ((id = IGraphics->NextDisplayInfo(id)) != INVALID_ID) {
        if (OS4_GetDisplayMode(id, &mode)) {
            if (mode.format != SDL_PIXELFORMAT_UNKNOWN) {
                if (!SDL_AddFullscreenDisplayMode(display, &mode)) {
                    SDL_free(mode.internal);
                }
            } else {
                SDL_free(mode.internal);
            }
        } else {
            dprintf("Failed to get display mode for 0x%lX (%lu)\n", id, id);
            return false;
        }
    }
    return true;
}

void
OS4_CloseScreen(SDL_VideoDevice *_this, struct Screen * screen)
{
    if (screen) {
        SDL_VideoData *data = (SDL_VideoData *) _this->internal;

        if (screen != data->publicScreen) {
            dprintf("Closing screen %p\n", screen);

            if (IIntuition->CloseScreen(screen) == FALSE) {
                dprintf("Screen has open window(s), cannot close\n");
            } else {
                dprintf("Screen closed successfully\n");
            }
        } else {
            dprintf("Public screen, not closing\n");
        }

    } else {
        dprintf("NULL pointer\n");
    }
}

bool
OS4_SetDisplayMode(SDL_VideoDevice *_this, SDL_VideoDisplay * display, SDL_DisplayMode * mode)
{
    SDL_VideoData *driverdata = (SDL_VideoData *) _this->internal;
    SDL_DisplayData *displaydata = (SDL_DisplayData *) display->internal;
    SDL_DisplayModeData *data = (SDL_DisplayModeData *) mode->internal;
    ULONG openError = 0;
    const int bpp = SDL_BITSPERPIXEL(mode->format);

    displaydata->screen = IIntuition->OpenScreenTags(NULL,
        SA_Width,       mode->w,
        SA_Height,      mode->h,
        SA_Depth,       bpp,
        SA_DisplayID,   data->modeid,
        SA_Quiet,       TRUE,
        SA_Title,       driverdata->appName,
        SA_ShowTitle,   FALSE,
        SA_ErrorCode,   &openError,
        SA_LikeWorkbench, TRUE,
        SA_Compositing, FALSE,
        TAG_DONE);

    dprintf("Opened screen id 0x%lX (%lu): %d*%d*%d (address %p)\n",
        data->modeid, data->modeid, mode->w, mode->h, bpp, displaydata->screen);

    if (!displaydata->screen) {
        switch (openError) {
            case OSERR_NOMONITOR:
                SDL_SetError("Monitor for display mode not available");
                break;
            case OSERR_NOCHIPS:
                SDL_SetError("Newer custom chips required");
                break;
            case OSERR_NOMEM:
            case OSERR_NOCHIPMEM:
                SDL_OutOfMemory();
                break;
            case OSERR_PUBNOTUNIQUE:
                SDL_SetError("Public screen name not unique");
                break;
            case OSERR_UNKNOWNMODE:
            case OSERR_TOODEEP:
                SDL_SetError("Unknown display mode");
                break;
            case OSERR_ATTACHFAIL:
                SDL_SetError("Attachment failed");
                break;
            default:
                SDL_SetError("OpenScreen failed");
                break;
        }
        return false;
    }

    // Paint it black (it helps in cases where window doesn't fill the screen)
    // ...do we need a backfill hook?
    IGraphics->RectFillColor(&displaydata->screen->RastPort, 0, 0, mode->w - 1, mode->h - 1, 0xFF000000);

    return true;
}

void
OS4_QuitModes(SDL_VideoDevice *_this)
{
    dprintf("Called\n");

    OS4_UnlockPubScreen(_this);
}

#endif /* SDL_VIDEO_DRIVER_AMIGAOS4 */
