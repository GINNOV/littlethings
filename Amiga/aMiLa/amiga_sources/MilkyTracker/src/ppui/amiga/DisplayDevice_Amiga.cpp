#include "DisplayDevice_Amiga.h"
#include "../../tracker/amiga/AmigaApplication.h"
#include "Graphics.h"
#include "PPMutex.h"

#include <intuition/intuitionbase.h>

#include <proto/Picasso96.h>
#include <proto/cybergraphics.h>

#include <clib/Picasso96_protos.h>

extern struct IntuitionBase * IntuitionBase;

DisplayDevice_Amiga::DisplayDevice_Amiga(AmigaApplication * app)
: app(app)
, screenMode(INVALID)
, unalignedOffScreenBuffer(NULL)
, alignedOffScreenBuffer(NULL)
{
    screen = app->getScreen();
    window = app->getWindow();
    rastPort = window->RPort;

    width = app->getWindowSize().width;
    size.width = width;

    height = app->getWindowSize().height;
    size.height = height;

    bpp = app->getBpp();
    pitch = width * bpp >> 3;

    useRTGFullscreen = app->isFullScreen();
    useRTGWindowed = !app->isFullScreen();
    useRTGMode = useRTGFullscreen || useRTGWindowed;

    useSAGADirectFB = app->isAMMX() && app->isSAGA() && useRTGFullscreen;
    useSAGAPiP = app->isAMMX() && app->isSAGA() && app->isV4() && useRTGWindowed;
    useSAGAMode = useSAGADirectFB || useSAGAPiP;

    // Prefer P96 over CGX
    rtgDriver = app->isP96() ? P96 : (app->isCGX() ? CGX : NONE);

    unalignedScreenBuffer[0] = NULL;
    unalignedScreenBuffer[1] = NULL;

    drawMutex = new PPMutex();
}

DisplayDevice_Amiga::~DisplayDevice_Amiga()
{
    if(useSAGAMode) {
        if(useSAGAPiP) {
            WRITE16(SAGA_PIP_PIXFMT,   0);
            WRITE16(SAGA_PIP_X0,       0);
            WRITE16(SAGA_PIP_Y0,       0);
            WRITE16(SAGA_PIP_X1,       0);
            WRITE16(SAGA_PIP_Y1,       0);
            WRITE16(SAGA_PIP_COLORKEY, 0);
            WRITE32(SAGA_PIP_BPLPTR,   0);

            V_FreeExpansionPort(V_PIP);
        }

        for(int i = 0; i < 2; i++)
            if(unalignedScreenBuffer[i])
                FreeMem(unalignedScreenBuffer[i], (pitch * height) + 16);
    } else if(useRTGMode) {
        if(unalignedOffScreenBuffer)
            FreeMem(unalignedOffScreenBuffer, (pitch * height) + 16);
    }

	delete currentGraphics;
    delete drawMutex;
}

void *
DisplayDevice_Amiga::allocMemAligned(pp_uint32 size, void ** aligned)
{
    void * b = (void *) AllocMem((pitch * height) + 16, MEMF_FAST | MEMF_CLEAR);
    if(!b)
        return NULL;

    // And align
    void * a = (void *) (((pp_uint32) b + 15) & ~ (pp_uint32) 0xf);
    memset(a, 0, pitch * height);
    *aligned = a;

    return b; // Return unaligned ptr to free later
}

bool
DisplayDevice_Amiga::init()
{
    screenMode = INVALID;

    // Detect display mode
    if(useRTGWindowed) {
        screenMode = bpp == 16 ? RTG_WINDOWED_16 : RTG_WINDOWED_8;

        if(useSAGAPiP) {
            void * allocator;

            if (allocator = V_AllocExpansionPort(V_PIP, (UBYTE *) "MilkyTracker")) {
                fprintf(stderr, "SAGA PiP already in use! (by: %s)\n", allocator);
                return false;
            }

            screenMode = bpp == 16 ? SAGA_PIP_16 : SAGA_PIP_8;
        }

        if(bpp == 16) {
            currentGraphics = new PPGraphics_16BIT(width, height, 0, NULL);
        } else {
            currentGraphics = new PPGraphics_8BIT(width, height, 0, NULL);
        }
	    currentGraphics->lock = true;
    } else if(useRTGFullscreen) {
        screenMode = bpp == 16 ? RTG_FULLSCREEN_16 : RTG_FULLSCREEN_8;

        if(useSAGADirectFB) {
            screenMode = bpp == 16 ? SAGA_DIRECT_16 : SAGA_DIRECT_8;
        }

        if(bpp == 16) {
            currentGraphics = new PPGraphics_16BIT(width, height, 0, NULL);
        } else {
            currentGraphics = new PPGraphics_8BIT(width, height, 0, NULL);
        }
	    currentGraphics->lock = true;
    }

    if(screenMode != INVALID) {
        if(useSAGAMode) {
            //
            // Partial double buffering in SAGA Modes
            // ======================================
            //
            // For SAGA modes, use two screen buffers which we flip on each vertical blank
            // - the active one which is currently shown, will never be changed by draw calls from
            //   GraphicsAbstract implementations because this would lead to noticeable
            //   screen corruptions
            // - the inactive one is always drawn to directly and *after* flipping we copy
            //   over the changed screen rects to the *new* inactive one
            //
            // Allocate screen buffers
            for(int i = 0; i < 2; i++) {
                void * b = allocMemAligned(pitch * height, &alignedScreenBuffer[i]);
                if(!b) {
                    fprintf(stderr, "Could not allocate enough memory for screen buffer %ld\n", i);
                    return false;
                }

                unalignedScreenBuffer[i] = b;
            }

            // Start to *blit into* DB page 0
            dbPage = 0;

            // And *display* DB page 1
            switch(screenMode) {
            case SAGA_PIP_8:
            case SAGA_PIP_16:
                WRITE16(SAGA_PIP_COLORKEY, 0);
                WRITE16(SAGA_PIP_PIXFMT, bpp == 16 ? SAGAF_RGB16 : SAGAF_CLUT);
                WRITE32(SAGA_PIP_BPLPTR, (ULONG) alignedScreenBuffer[1]);
                break;
            case SAGA_DIRECT_8:
            case SAGA_DIRECT_16:
                WRITE16(SAGA_PIP_PIXFMT, bpp == 16 ? SAGAF_RGB16 : SAGAF_CLUT);
                WRITE32(SAGA_VID_BPLPTR, (ULONG) alignedScreenBuffer[1]);
                break;
            }
        } else if(useRTGMode) {
            //
            // For RTG modes, use an offscreen buffer. RTG is doing the double-buffering
            // internally. We just have to use WritePixelArray to copy over the new
            // contents
            //
            void * b = allocMemAligned(pitch * height, &alignedOffScreenBuffer);
            if(!b) {
                fprintf(stderr, "Could not allocate enough memory for off-screen buffer %ld\n");
                return false;
            }
            unalignedOffScreenBuffer = b;
        }

        return true;
    }

    fprintf(stderr, "Requested display mode not supported!\n");
    return false;
}

PPGraphicsAbstract*
DisplayDevice_Amiga::open()
{
	if (!isEnabled())
		return NULL;

	if (currentGraphics->lock) {
		currentGraphics->lock = false;

        if(useSAGAMode)
            static_cast<PPGraphicsFrameBuffer*>(currentGraphics)->setBufferProperties(pitch, (pp_uint8 *) alignedScreenBuffer[dbPage]);
        else if(useRTGMode)
            static_cast<PPGraphicsFrameBuffer*>(currentGraphics)->setBufferProperties(pitch, (pp_uint8 *) alignedOffScreenBuffer);

		return currentGraphics;
	}

    return NULL;
}

void
DisplayDevice_Amiga::close()
{
	currentGraphics->lock = true;
}

void
DisplayDevice_Amiga::update()
{
	update(PPRect(0, 0, width, height));
}

void
DisplayDevice_Amiga::update(const PPRect &r)
{
	if(!isUpdateAllowed() || !isEnabled())
		return;

    drawMutex->lock();
    {
        drawCommands.push_back(r);
    }
    drawMutex->unlock();
}

void
DisplayDevice_Amiga::flush()
{
    drawMutex->lock();

    if(drawCommands.size() > 0) {

        if(useSAGAMode) {
            pp_uint8 * ps = (pp_uint8 *) alignedScreenBuffer[dbPage];

            // Display and flip
            switch(screenMode) {
            case SAGA_PIP_8:
            case SAGA_PIP_16:
                WRITE32(SAGA_PIP_BPLPTR, (ULONG) alignedScreenBuffer[dbPage]);
                break;
            case SAGA_DIRECT_8:
            case SAGA_DIRECT_16:
                WRITE32(SAGA_VID_BPLPTR, (ULONG) alignedScreenBuffer[dbPage]);
                break;
            }
            dbPage ^= 1;

            // Copy over changed screen rects
            pp_uint8 * pd = (pp_uint8 *) alignedScreenBuffer[dbPage];
            for(std::vector<PPRect>::iterator rect = drawCommands.begin(); rect != drawCommands.end(); ++rect) {
                pp_uint8 * s, * d;
                pp_uint32 rw = rect->width();
                pp_uint32 off = rect->y1 * width + rect->x1;
                pp_uint32 stride = width - rw;
                pp_uint32 pitch = rw;

				if(bpp == 16) {
                    s = (pp_uint8 *) ((pp_uint16 *) ps + off);
                    d = (pp_uint8 *) ((pp_uint16 *) pd + off);

					stride <<= 1;
					pitch <<= 1;
				} else {
                    s = (pp_uint8 *) (ps + off);
                    d = (pp_uint8 *) (pd + off);
                }

                CopyRect_68080(s, d, stride, stride, pitch, rect->height());
            }
        } else if(useRTGMode) {
            struct RenderInfo renderInfo;

            renderInfo.BytesPerRow = pitch;
            renderInfo.Memory = (pp_uint16 *) alignedOffScreenBuffer;
            renderInfo.pad = 0;
            renderInfo.RGBFormat = bpp == 16 ? RGBFB_R5G6B5 : RGBFB_CLUT;

            if(rtgDriver == P96) {
                p96WritePixelArray(&renderInfo, 0, 0, rastPort, window->BorderLeft, window->BorderTop, width, height);
            } else {
                WritePixelArray(&renderInfo, 0, 0, pitch, rastPort, window->BorderLeft, window->BorderTop, width, height, 0);
            }
            WaitBlit();
        }

        drawCommands.clear();
    }

    drawMutex->unlock();
}

void
DisplayDevice_Amiga::setPalette(PPColor * pppal)
{
	if(!currentGraphics->needsPalette())
		return;

	// Pass palette to graphics context
	currentGraphics->setPalette(pppal);

	// Pass palette to RTG Viewport
    if(useSAGAMode) {
        int i = 0;

        for(i = 0; i < 256; i++) {
            ULONG col = (i << 24) | (pppal[i].r << 16) | (pppal[i].g << 8) | pppal[i].b;
            if(useSAGAPiP)
                *((ULONG *)SAGA_VIDEO_CLUT_PIP) = col;
            else
                *((ULONG *)SAGA_VIDEO_CLUT_CHUNKY) = col;
        }
    } else if(useRTGMode) {
	    int i = 0, j = 0;

        palette[j++] = (256 << 16) | 0;
        for(i = 0; i < 256; i++) {
            palette[j++] = pppal[i].r << 24;
            palette[j++] = pppal[i].g << 24;
            palette[j++] = pppal[i].b << 24;
        }
        palette[j] = 0;

        LoadRGB32(&screen->ViewPort, (const ULONG *) palette);
    }
}

void
DisplayDevice_Amiga::setSize(const PPSize& size)
{
    if(useSAGAPiP) {
        ULONG x0 = 0, y0 = 0;
        ULONG x1 = 0, y1 = 0;

        if (screen == IntuitionBase->FirstScreen) {
            x0 = SAGA_PIP_DELTAX + window->LeftEdge + screen->LeftEdge + window->BorderLeft + 2;
            y0 = SAGA_PIP_DELTAY + window->TopEdge + screen->TopEdge + window->BorderTop;

            if ((x0 + width - 16 - 64) < screen->Width) {
                x1 = x0 + width;
                y1 = y0 + height;
            } else {
                x0 = 0;
                y0 = 0;
            }
        }

        WRITE16(SAGA_PIP_X0, x0);
        WRITE16(SAGA_PIP_Y0, y0);
        WRITE16(SAGA_PIP_X1, x1);
        WRITE16(SAGA_PIP_Y1, y1);
    }
}

void
DisplayDevice_Amiga::setTitle(const PPSystemString& title)
{
    app->setWindowTitle(title.getStrBuffer());
}

void
DisplayDevice_Amiga::setAlert(const PPSystemString& title)
{
    app->setScreenAlert(title.getStrBuffer());
}

bool
DisplayDevice_Amiga::goFullScreen(bool b)
{
    return false;
}

void
DisplayDevice_Amiga::shutDown()
{
    app->setRunning(false);
}

void
DisplayDevice_Amiga::signalWaitState(bool b, const PPColor& color)
{
    setMouseCursor(b ? MouseCursorTypeWait : MouseCursorTypeStandard);
}

void
DisplayDevice_Amiga::setMouseCursor(MouseCursorTypes type)
{
	currentCursorType = type;

	switch (type)
	{
    case MouseCursorTypeWait:
        SetWindowPointer(window,
            WA_BusyPointer , TRUE,
            WA_PointerDelay, TRUE,
            TAG_DONE);
        break;
    default:
    case MouseCursorTypeStandard:
    case MouseCursorTypeResizeLeft:
    case MouseCursorTypeResizeRight:
    case MouseCursorTypeHand:
        SetWindowPointer(window,
            WA_Pointer    , NULL,
            WA_BusyPointer, FALSE,
            TAG_DONE);
        break;
    }
}

PPSize
DisplayDevice_Amiga::getDisplayResolution() const
{
    return PPSize(width, height);
}
