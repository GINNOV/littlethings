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
#include <proto/minigl.h>

#include <GL/gl.h>
//#include <mgl/gl.h>

#include "SDL_os4video.h"
#include "SDL_os4window.h"
#include "SDL_os4library.h"
#include "SDL_os4opengl.h"

#include "../../main/amigaos4/SDL_os4debug.h"

struct Library *MiniGLBase;
struct MiniGLIFace *IMiniGL;

/* The client program needs access to this context pointer
 * to be able to make GL calls. This presents no problems when
 * it is statically linked against libSDL, but when linked
 * against a shared library version this will require some
 * trickery.
 */
SDL_DECLSPEC struct GLContextIFace *mini_CurrentContext = 0;

void *AmiGetGLProc(const char *proc);

static void
OS4_GL_LogLibraryError()
{
    dprintf("No MiniGL library available\n");
    SDL_SetError("No MiniGL library available");
}

bool
OS4_GL_LoadLibrary(SDL_VideoDevice *_this, const char * path)
{
    dprintf("Called %d\n", _this->gl_config.driver_loaded);

    if (!MiniGLBase) {
        MiniGLBase = OS4_OpenLibrary("minigl.library", 2);

        if (!MiniGLBase) {
            dprintf("Failed to open minigl.library\n");
            return SDL_SetError("Failed to open minigl.library");
        }
    }

    if (!IMiniGL) {
        IMiniGL = (struct MiniGLIFace *) OS4_GetInterface(MiniGLBase);

        if (!IMiniGL) {
            dprintf("Failed to open MiniGL interace\n");
            return SDL_SetError("Failed to open MiniGL interface");
        }

        dprintf("MiniGL library opened\n");
    }

    return true;
}

SDL_FunctionPointer
OS4_GL_GetProcAddress(SDL_VideoDevice *_this, const char * proc)
{
    void *func = NULL;

    dprintf("Called for '%s' (current context %p)\n", proc, mini_CurrentContext);

    if (IMiniGL && mini_CurrentContext) {
        func = AmiGetGLProc(proc);
    }

    if (func == NULL) {
        dprintf("Failed to load '%s'\n", proc);
    }

    return func;
}

void
OS4_GL_UnloadLibrary(SDL_VideoDevice *_this)
{
    dprintf("Called %d\n", _this->gl_config.driver_loaded);

    OS4_DropInterface((void *) &IMiniGL);
    OS4_CloseLibrary(&MiniGLBase);
}

bool
OS4_GL_AllocateBuffers(SDL_VideoDevice *_this, int width, int height, int depth, SDL_WindowData * data)
{
    dprintf("Allocate double buffer bitmaps %d*%d*%d\n", width, height, depth);

    if (data->glFrontBuffer || data->glBackBuffer) {
        dprintf("Old front buffer pointer %p, back buffer pointer %p\n",
            data->glFrontBuffer, data->glBackBuffer);

        OS4_GL_FreeBuffers(_this, data);
    }

    if (!(data->glFrontBuffer = IGraphics->AllocBitMapTags(
                                    width,
                                    height,
                                    depth,
                                    BMATags_Displayable, TRUE,
                                    BMATags_Friend, data->syswin->RPort->BitMap,
                                    TAG_DONE))) {

        dprintf("Failed to allocate front buffer\n");
        return false;
    }

    if (!(data->glBackBuffer = IGraphics->AllocBitMapTags(
                                    width,
                                    height,
                                    depth,
                                    BMATags_Displayable, TRUE,
                                    BMATags_Friend, data->syswin->RPort->BitMap,
                                    TAG_DONE))) {

        dprintf("Failed to allocate back buffer\n");

        IGraphics->FreeBitMap(data->glFrontBuffer);
        data->glFrontBuffer = NULL;

        return false;
    }

#ifdef DEBUG
    uint32 srcFmt =
#endif
    IGraphics->GetBitMapAttr(data->glBackBuffer, BMA_PIXELFORMAT);

#ifdef DEBUG
    uint32 src2Fmt =
#endif
    IGraphics->GetBitMapAttr(data->glFrontBuffer, BMA_PIXELFORMAT);

#ifdef DEBUG
    uint32 dstFmt =
#endif
    IGraphics->GetBitMapAttr(data->syswin->RPort->BitMap, BMA_PIXELFORMAT);

    dprintf("SRC FMT %lu, SRC2 FMT %lu, DST FMT %lu\n", srcFmt, src2Fmt, dstFmt);

    return true;
}

void
OS4_GL_FreeBuffers(SDL_VideoDevice *_this, SDL_WindowData * data)
{
    dprintf("Called\n");

    if (data->glFrontBuffer) {
        IGraphics->FreeBitMap(data->glFrontBuffer);
        data->glFrontBuffer = NULL;
    }

    if (data->glBackBuffer) {
        IGraphics->FreeBitMap(data->glBackBuffer);
        data->glBackBuffer = NULL;
    }
}

SDL_GLContext
OS4_GL_CreateContext(SDL_VideoDevice *_this, SDL_Window * window)
{
    dprintf("Called\n");

    if (IMiniGL) {
        uint32 depth;

        SDL_WindowData * data = window->internal;

        if (data->glContext) {
            struct GLContextIFace *IGL = (struct GLContextIFace *)data->glContext;

            dprintf("Old context %p found, deleting\n", data->glContext);

            IGL->DeleteContext();

            data->glContext = NULL;
        }

        depth = IGraphics->GetBitMapAttr(data->syswin->RPort->BitMap, BMA_BITSPERPIXEL);

        if (!OS4_GL_AllocateBuffers(_this, window->w, window->h, depth, data)) {
            SDL_SetError("Failed to allocate MiniGL buffers");
            return NULL;
        }

        data->glContext = IMiniGL->CreateContextTags(
                        MGLCC_PrivateBuffers,   2,
                        MGLCC_FrontBuffer,      data->glFrontBuffer,
                        MGLCC_BackBuffer,       data->glBackBuffer,
                        MGLCC_Buffers,          2,
                        MGLCC_PixelDepth,       depth,
                        MGLCC_StencilBuffer,    TRUE,
                        MGLCC_VertexBufferSize, 1 << 17,
                        TAG_DONE);

        if (data->glContext) {

            dprintf("MiniGL context %p created for window '%s'\n",
                data->glContext, window->title);

            ((struct GLContextIFace *)data->glContext)->GLViewport(0, 0, window->w, window->h);
            mglMakeCurrent(data->glContext);
            mglLockMode(MGL_LOCK_SMART);

            return (SDL_GLContext)data->glContext;
        } else {
            dprintf("Failed to create MiniGL context for window '%s'\n", window->title);

            SDL_SetError("Failed to create MiniGL context");

            OS4_GL_FreeBuffers(_this, data);

            return NULL;
        }

    } else {
        OS4_GL_LogLibraryError();
        return NULL;
    }
}

bool
OS4_GL_MakeCurrent(SDL_VideoDevice *_this, SDL_Window * window, SDL_GLContext context)
{
    if (!window || !context) {
        dprintf("Called (window %p, context %p)\n", window, context);
    }

    if (IMiniGL) {
        mglMakeCurrent(context);
        return true;
    } else {
        OS4_GL_LogLibraryError();
    }

    return false;
}

void
OS4_GL_GetDrawableSize(SDL_VideoDevice *_this, SDL_Window * window, int * w, int * h)
{
    OS4_WaitForResize(window, w, h);
}

bool
OS4_GL_SetSwapInterval(SDL_VideoDevice *_this, int interval)
{
    SDL_VideoData *data = _this->internal;

    switch (interval) {
        case 0:
        case 1:
            data->vsyncEnabled = interval ? TRUE : FALSE;
            dprintf("VSYNC %d\n", interval);
            return true;
        default:
            dprintf("Unsupported interval %d\n", interval);
            return false;
    }
}

bool
OS4_GL_GetSwapInterval(SDL_VideoDevice *_this, int* interval)
{
    //dprintf("Called\n");

    SDL_VideoData *data = _this->internal;

    *interval = data->vsyncEnabled ? 1 : 0;

    return true;
}

bool
OS4_GL_SwapWindow(SDL_VideoDevice *_this, SDL_Window * window)
{
    //dprintf("Called\n");

    if (IMiniGL) {

        SDL_WindowData *data = window->internal;

        if (data->glContext) {
            SDL_VideoData *videodata = _this->internal;

            struct BitMap *temp;
            int w, h;
            GLint buf;

            int32 blitRet;

            mglUnlockDisplay();

            ((struct GLContextIFace *)data->glContext)->MGLWaitGL(); // TODO: still needed?

            OS4_GetWindowSize(data->syswin, &w, &h);

            if (videodata->vsyncEnabled) {
                IGraphics->WaitTOF();
            }

            glGetIntegerv(GL_DRAW_BUFFER, &buf);

            if (buf == GL_BACK || buf == GL_FRONT) {
                struct BitMap *from = (buf == GL_BACK) ? data->glBackBuffer : data->glFrontBuffer;

                BOOL ret = IGraphics->BltBitMapRastPort(from, 0, 0, data->syswin->RPort,
                    data->syswin->BorderLeft, data->syswin->BorderTop, w, h, 0xC0);

                if (!ret) {
                    dprintf("BltBitMapRastPort() failed\n");
                }
            }

            blitRet = IGraphics->BltBitMapTags(BLITA_Source,  data->glBackBuffer,
                                     BLITA_SrcType, BLITT_BITMAP,
                                     BLITA_SrcX,    0,
                                     BLITA_SrcY,    0,
                                     BLITA_Dest,    data->glFrontBuffer,
                                     BLITA_DestType,BLITT_BITMAP,
                                     BLITA_DestX,   0,
                                     BLITA_DestY,   0,
                                     BLITA_Width,   w,
                                     BLITA_Height,  h,
                                     BLITA_Minterm, 0xC0,
                                     TAG_DONE);

            if (blitRet == -1) {
                temp = data->glFrontBuffer;
                data->glFrontBuffer = data->glBackBuffer;
                data->glBackBuffer = temp;

                ((struct GLContextIFace *)data->glContext)->MGLUpdateContextTags(
                                    MGLCC_FrontBuffer,data->glFrontBuffer,
                                    MGLCC_BackBuffer, data->glBackBuffer,
                                    TAG_DONE);
                return true;
            } else {
                dprintf("BltBitMapTags() returned %ld\n", blitRet);
                return SDL_SetError("BltBitMapTags failed");
            }
        } else {
            dprintf("No MiniGL context\n");
        }
    } else {
        OS4_GL_LogLibraryError();
    }

    return false;
}

bool
OS4_GL_DestroyContext(SDL_VideoDevice *_this, SDL_GLContext context)
{
    dprintf("Called with context=%p\n", context);

    if (IMiniGL) {
        if (context) {
            SDL_Window *sdlwin;
            Uint32 deletions = 0;

            for (sdlwin = _this->windows; sdlwin; sdlwin = sdlwin->next) {
                SDL_WindowData *data = sdlwin->internal;

                if ((SDL_GLContext)data->glContext == context) {
                    struct GLContextIFace *IGL = (struct GLContextIFace *)context;

                    dprintf("Found MiniGL context, clearing window binding\n");

                    IGL->DeleteContext();

                    data->glContext = NULL;
                    deletions++;
                }
            }

            if (deletions == 0) {
                dprintf("MiniGL context doesn't seem to have window binding\n");
		return false;
            }
        } else {
            dprintf("No context to delete\n");
	    return false;
        }
    } else {
        OS4_GL_LogLibraryError();
	return false;
    }

    return true;
}

bool
OS4_GL_ResizeContext(SDL_VideoDevice *_this, SDL_Window * window)
{
    if (IMiniGL) {
        SDL_WindowData *data = window->internal;

        uint32 depth = IGraphics->GetBitMapAttr(data->syswin->RPort->BitMap, BMA_BITSPERPIXEL);

        if (OS4_GL_AllocateBuffers(_this, window->floating.w, window->floating.h, depth, data)) {
            dprintf("Resizing MiniGL context to %d*%d\n", window->floating.w, window->floating.h);

            ((struct GLContextIFace *)data->glContext)->MGLUpdateContextTags(
                            MGLCC_FrontBuffer, data->glFrontBuffer,
                            MGLCC_BackBuffer, data->glBackBuffer,
                            TAG_DONE);

            ((struct GLContextIFace *)data->glContext)->GLViewport(0, 0, window->floating.w, window->floating.h);

            return true;
        } else {
            dprintf("Failed to re-allocate MiniGL buffers\n");
            //SDL_Quit();
        }
    } else {
        OS4_GL_LogLibraryError();
    }

    return false;
}

void
OS4_GL_UpdateWindowPointer(SDL_VideoDevice *_this, SDL_Window * window)
{
    // Nothing to do for MiniGL
}

#endif /* SDL_VIDEO_DRIVER_AMIGAOS4 */
