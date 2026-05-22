/*         ______   ___    ___
 *        /\  _  \ /\_ \  /\_ \
 *        \ \ \L\ \\//\ \ \//\ \      __     __   _ __   ___
 *         \ \  __ \ \ \ \  \ \ \   /'__`\ /'_ `\/\`'__\/ __`\
 *          \ \ \/\ \ \_\ \_ \_\ \_/\  __//\ \L\ \ \ \//\ \L\ \
 *           \ \_\ \_\/\____\/\____\ \____\ \____ \ \_\\ \____/
 *            \/_/\/_/\/____/\/____/\/____/\/___L\ \/_/ \/___/
 *                                           /\____/
 *                                           \_/__/
 *
 *      Amiga OS graphics driver.
 *
 *      By Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#include "allegro.h"
#include "allegro/internal/aintern.h"
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/picasso96api.h>
#include <graphics/rpattr.h>
#include <string.h>
#include "athread.h"
#include "agraphics.h"
#include "akeyboard.h"
#include "amouse.h"

#define REDRAW_TIMEOUT (50 * 1000)

/* Offsets to various tag items in the window taglists */

#define TAG_OFFSET_LEFT 0
#define TAG_OFFSET_TOP 1
#define TAG_OFFSET_WIDTH 2
#define TAG_OFFSET_HEIGHT 3
#define TAG_OFFSET_TITLE 4
#define CUSTOMSCREEN_TAG_IDCMP 9

AL_VAR(GFX_DRIVER, gfx_amiga_fullscreen);
AL_VAR(GFX_DRIVER, gfx_amiga_windowed);

/* This structure describes a colour depth mapping, specifying the P96 graphics mode and */
/* the GFX_VTABLE to be used for a particular colour depth */

struct ColourMapping
{
	int			cm_Depth;			/* Colour depth (8, 15, 16, 24 or 32 bits) */
	RGBFTYPE	cm_Mapping;			/* Preferred (big endian) P96 mode representing colour depth */
	RGBFTYPE	cm_AltMapping;		/* Alternate (little endian) P96 mode representing colour depth */
	GFX_VTABLE	*cm_GfxVTable;		/* Graphics VTable to be used for drawing */
};

/* This structure describes the area of the screen that needs to be drawn by draw(). */
/* The area from da_TopLine to da_BottomLine inclusive will be drawn */

struct DirtyArea
{
	int			da_TopLine;			/* # of the top line that needs to be redrawn */
	int			da_BottomLine;		/* # of the bottom line that needs to be redrawn */
};

/* The structure is used for accessing the screen BitMap directly and gets stored in the BITMAP.extra */
/* field by the direct video access routines */

struct VideoBitmap
{
	void				*vb_SafetyBuffer;	/* Ptr to a safety buffer for failed locks */
	int					vb_BitMapOffset;	/* Offset in bytes to start of BitMap data, relative to parent window */
	LONG				vb_Lock;			/* ID of lock when the P96 BitMap is locked into place */
	int					vb_LockCount;		/* # of times locked (can be 2 - one for read & one for write) */
	struct BitMap		*vb_BitMap;			/* Ptr to the P96 BitMap in video memory */
	struct RenderInfo	vb_RenderInfo;		/* Structure containing rendering information from P96 */
};

static int gWidth;						/* Width of the client area in pixels */
static int gHeight;						/* Height of the client area in pixels */
static int gBPP;						/* # of bytes per pixel */
static int gBigEndian;					/* 1 if selected mode is big endian */
static int gLowRes;						/* 1 if faking a 320x200 or 320x240 screen on a 640x480 screen */
static unsigned char *gOutBuffer;		/* Ptr to buffer used for drawing by Allegro */
static ULONG gModeID;					/* ID to open screen in, or INVALID_ID for no screen */
static RGBFTYPE gRGBFType;				/* P96 mode to use for creating BitMap */
static struct BitMap *gBitMap;			/* Ptr to Amiga specific BitBap for rendering to the screen */
static BITMAP *gBitmap;					/* Ptr to bitmap used for drawing by Allegro (uses gOutBuffer) */
static GFX_VTABLE gGfxVTable;			/* VTable pointing to Amiga specific drawing routines */
static struct Screen *gMainScreen;		/* Ptr to screen (if any) on which to display output */
static void (*gCloseButtonCallback)();	/* Ptr to function to call when close window gadget is clicked */
static char *gMainWindowTitle;			/* Copy of the window title, if set, to keep it persistent */

/* Variables pertaining to the dirty area and its management */

static struct SignalSemaphore gDirtyAreaSemaphore;	/* Signal semaphore for protecting the dirty area */
static struct DirtyArea gDirtyArea;		/* Dirty area currently being drawn by Allegro */
static struct DirtyArea gSafeDirtyArea;	/* Dirty area being drawn by graphics thread.  This is a */
										/* copy of gDirtyArea that is safe to access withing it */
										/* being changed by Allegro on the main thread */

/* Variables pertaining to direct video memory access */

static int gNativeScreenMode;			/* 1 if a native screen mode is in use, else 0 if emulated */
static int gSafeToFlip;					/* 1 if it is safe to flip pages, else 0 */
static int gUseCount;					/* # of BitMaps currently allocated in video memory */
static struct DBufInfo *gDBufInfo;		/* Structure used by graphics.library for page flipping */
static struct MsgPort *gSafeMsgPort;	/* MsgPort that indicates when it is safe to access video memory */
static struct MsgPort *gDispMsgPort;	/* MsgPort that indicates when it is safe to flip pages */

/* Exported variables */

int gDepth;								/* Depth of the client area */
unsigned int gPalette[256];				/* Palette used by Allegro 8 bit drawing modes */
struct AmiThread gGraphicsThread;		/* Thread used for display updates */
struct Window *gMainWindow;				/* Ptr to window on which to display output */

/* Tags used for opening the main window on the Workbench */

static struct TagItem gWorkbenchWindowTags[] =
{
	{ WA_Left, 0 } , { WA_Top, 0 }, { WA_InnerWidth, 0 }, { WA_InnerHeight, 0 },
	{ WA_Title, (ULONG) "Allegro 1.1" }, { WA_PubScreenName, (ULONG) "Workbench" },
	{ WA_Activate, TRUE }, { WA_CloseGadget, TRUE }, { WA_DepthGadget, TRUE }, { WA_DragBar, TRUE },
	{ WA_ReportMouse, TRUE }, { WA_RMBTrap, TRUE }, { WA_SimpleRefresh, TRUE }, { WA_SizeGadget, TRUE },
	{ WA_IDCMP, ( IDCMP_CLOSEWINDOW | IDCMP_EXTENDEDMOUSE | IDCMP_MOUSEBUTTONS | IDCMP_MOUSEMOVE | IDCMP_RAWKEY | IDCMP_REFRESHWINDOW) },
	{ TAG_DONE, TRUE }
};

/* Tags used for opening the main window on a custom screen */

static struct TagItem gCustomWindowTags[] =
{
	{ WA_Left, 0 }, { WA_Top, 0 }, { WA_Width, 0 }, { WA_Height, 0 },
	{ WA_Activate, TRUE }, { WA_Borderless, TRUE }, { WA_ReportMouse, TRUE }, { WA_RMBTrap, TRUE },
	{ WA_IDCMP, ( IDCMP_EXTENDEDMOUSE | IDCMP_MOUSEBUTTONS | IDCMP_MOUSEMOVE | IDCMP_RAWKEY ) },
	{ WA_CustomScreen, 0 }, { TAG_DONE, TRUE }
};

/* All graphics modes that can be displayed by the Amiga port of Allegro are listed in */
/* this table */

static struct ColourMapping gColourMappings[] =
{
	{ 8, RGBFB_A8R8G8B8, RGBFB_A8B8G8R8, &__linear_vtable8 },
	{ 15, RGBFB_R5G5B5, RGBFB_B5G5R5PC, &__linear_vtable15 },
	{ 16, RGBFB_R5G6B5, RGBFB_B5G6R5PC, &__linear_vtable16 },
	{ 24, RGBFB_R8G8B8, RGBFB_B8G8R8, &__linear_vtable24 },
	{ 32, RGBFB_A8R8G8B8, RGBFB_A8B8G8R8, &__linear_vtable32 }
};

static unsigned char *video_read_write_bank(BITMAP *aBitmap, int aLine);
static void gfx_destroy_video_bitmap(struct BITMAP *aRetVal);

static struct ColourMapping *convert_depth(int aDepth)
{
	int Index;
	struct ColourMapping *RetVal;

	/* Assume failure */

	RetVal = NULL;

	/* Iterate through the array of colour mappings and find a mapping that matches the */
	/* bit depth passed in */

	for (Index = 0; Index < (int) (sizeof(gColourMappings) / sizeof(struct ColourMapping)); ++Index)
	{
		if (aDepth == gColourMappings[Index].cm_Depth)
		{
			/* Return a ptr to the colour mapping with which to draw */

			RetVal = &gColourMappings[Index];

			/* And initialise the GFX_VTABLE with a ptr to a generic VTable that is suitable */
			/*for writing to this screen mode */

			gGfxVTable = *gColourMappings[Index].cm_GfxVTable;

			break;
		}
	}

	return(RetVal);
}

static void copy_dirty_rect(BITMAP *aBitmap)
{
	int DestWidth, Width, Height, TopLine, BottomLine;
	LONG Lock;
	struct RenderInfo RenderInfo;

	/* Merge the area in main thread's dirty area into the safe dirty area, which could be */
	/* used at any time by the draw() routine.  It is done like this rather than just copying */
	/* the entire structure as copy_dirty_rect() could be called multiple times before draw() */
	/* gets called so we need to ensure that draw() copies the entire area made up by all of */
	/* the dirty areas represented by calls to this function */

	if (gDirtyArea.da_TopLine < gSafeDirtyArea.da_TopLine)
	{
		gSafeDirtyArea.da_TopLine = gDirtyArea.da_TopLine;
	}

	if (gDirtyArea.da_BottomLine > gSafeDirtyArea.da_BottomLine)
	{
		gSafeDirtyArea.da_BottomLine = gDirtyArea.da_BottomLine;
	}

	/* Cache a copy of the current dirty area */

	TopLine = gDirtyArea.da_TopLine;
	BottomLine = gDirtyArea.da_BottomLine;

	/* Reset the dirty area so that it won't get copied again */

	gDirtyArea.da_TopLine = (gHeight - 1);
	gDirtyArea.da_BottomLine = 0;

	/* Only update the screen if anything was actually rendered to Allegro's bitmap */

	if (BottomLine >= TopLine)
	{
		/* Lock the P96 BitMap and copy the Allegro bitmap into it */

		if ((Lock = IP96->p96LockBitMap(gBitMap, (UBYTE *) &RenderInfo, sizeof(RenderInfo))) != 0)
		{
			/* Cache some variables pertaining to the area to be copied.  Although we copy the */
			/* entire width of the bitmap, we only copy the # of lines that are dirty.  Note that */
			/* we use our globally cached gWidth variable because some hacky demo software */
			/* messes with the value in aBitmap->w to perform graphical trickery */

			DestWidth = RenderInfo.BytesPerRow;
			Width = gWidth;
			Height = (BottomLine - TopLine + 1);

			/* And call the appropriate function, blitting as-is, or doubling the size for emulated */
			/* lowres screens */

			if (gLowRes)
			{
				gfx_blit_low_res(aBitmap, &RenderInfo, TopLine, DestWidth, Width, Height);
			}
			else
			{
				gfx_blit_high_res(aBitmap, &RenderInfo, TopLine, DestWidth, Width, Height);
			}

			IP96->p96UnlockBitMap(gBitMap, Lock);
		}
	}
}

static void draw()
{
	int Width, Height, TopLine, BottomLine;

	/* Only draw anything if an emulation bitmap is being used */

	if (gBitMap)
	{
		/* Obtain the dirty area signal semaphore as this function is safe to be called from multiple threads */

		IExec->ObtainSemaphore(&gDirtyAreaSemaphore);

		/* Cache a copy of the current safe dirty area */

		TopLine = gSafeDirtyArea.da_TopLine;
		BottomLine = gSafeDirtyArea.da_BottomLine;

		if (BottomLine >= TopLine)
		{
			/* Reset the safe dirty area so that it won't get blitted again */

			gSafeDirtyArea.da_TopLine = (gHeight - 1);
			gSafeDirtyArea.da_BottomLine = 0;

			/* Now blit the P96 BitMap onto the screen! */

			Height = (BottomLine - TopLine + 1);

			/* Height is calculated, so get width of bitmap to blit note that we use our globally */
			/* cached gWidth variable because some hacky demo software messes with the value in */
			/* gBitmap->w to perform graphical trickery */

			Width = gWidth;

			/* If a loweres screen is being emulated, the copy_dirty_rect() function will have doubled */
			/* its size when copying it into the p96 BitMap, so we must blit twice as much to the */
			/* screen, and also from lower down the bitmap */

			if (gLowRes)
			{
				TopLine *= 2;
				Width *= 2;
				Height *= 2;
			}

			/* Now copy our BitMap onto the screen */

			IGraphics->BltBitMapRastPort(gBitMap, 0, TopLine, gMainWindow->RPort, gMainWindow->BorderLeft,
				(gMainWindow->BorderTop + TopLine), Width, Height, 0xc0);
		}

		/* And release the dirty area signal semaphore so that other threads can call us */

		IExec->ReleaseSemaphore(&gDirtyAreaSemaphore);
	}
}

void system_set_window_title(const char *aTitle)
{
	/* And free the main window's custom title, if already allocated */

	if (gMainWindowTitle)
	{
		_AL_FREE(gMainWindowTitle);
	}

	/* And now allocate a new one and copy the title into it */

	if ((gMainWindowTitle = _AL_MALLOC(strlen(aTitle) + 1)) != NULL)
	{
		strcpy(gMainWindowTitle, aTitle);

		/* If the main window has been opened, set it to the new title */

		if (gMainWindow)
		{
			IIntuition->SetWindowTitles(gMainWindow, gMainWindowTitle, (STRPTR) -1);
		}
	}
}

int system_set_close_button_callback(void (*aCloseButtonCallback)())
{
	gCloseButtonCallback = aCloseButtonCallback;

	return(0);
}

static int gfx_thread_init(struct AmiThread *aAmiThread)
{
	int RetVal, Width, Height;
	struct TagItem *TagList;

	/* Assume failure */

	RetVal = 0;

	/* Before we can wait on events we need a window to wait on.  This window must be opened in */
	/* this thread because its signal is process specific, meaning that it can't be opened in */
	/* the main thread.  Start by opening the screen, if required, which is indicated by a valid */
	/* ModeID being setup by gfx_init() */

	if (gModeID != INVALID_ID)
	{
		gMainScreen = IIntuition->OpenScreenTags(NULL, SA_DisplayID, gModeID, SA_Title, "Allegro", TAG_DONE);
	}

	/* Decide on what window taglist to use, depending on whether we are using our custom screen */
	/* or the Workbench screen.  Don't bother with any special handling for if the custom screen */
	/* couldn't be opened - just open on Workbench in that case */

	if (gMainScreen)
	{
		TagList = gCustomWindowTags;

		/* Setp the WA_CustomScreen tag data to point to the newly opened screen */

		gCustomWindowTags[CUSTOMSCREEN_TAG_IDCMP].ti_Data = (ULONG) gMainScreen;
	}
	else
	{
		TagList = gWorkbenchWindowTags;

		/* Use the custom window title, if it has already been set.  Otherwise use a default.  Note */
		/* that custom window titles only work for Workbench windows */

// TODO: CAW - Should set this back to NULL?
		if (gMainWindowTitle)
		{
			gWorkbenchWindowTags[TAG_OFFSET_TITLE].ti_Data = (ULONG) gMainWindowTitle;
		}
	}

	/* Open the main window, using the appropriate taglist */

	if ((gMainWindow = IIntuition->OpenWindowTagList(NULL, TagList)) != NULL)
	{
		/* If a lowres screen is being emulated then fill it with black so that it has an old */
		/* skool NTSC border at the bottom */

		if ((gLowRes) && (gMainScreen))
		{
			IGraphics->SetRPAttrs(gMainWindow->RPort, RPTAG_APenColor, 0xff000000, TAG_DONE);
			IGraphics->RectFill(gMainWindow->RPort, 0, 0, 639, 479);
		}

		/* Get the width and height of the client area */

		Width = gWidth;
		Height = gHeight;

		/* If lowres is being emulated, the copy_dirty_rect() function will double its size when */
		/* copying it into the p96 BitMap, so we must allocate a p96 BitMap twice as large */

		if (gLowRes)
		{
			Width *= 2;
			Height *= 2;
		}

		/* Screens that are lowres need to be emulated as P96 doesn't seem to support them any more. */
		/* Screens that are in a different mode to that requested by the game will also need to be */
		/* emulated.  Windows that will have a BitMap that is not the same depth of the Workbench will */
		/* also need to be emulated and 8 bit screens or BitMaps are always emulated to avoid RGB CLUT */
		/* problems. */

		if (((gMainScreen) && ((gDepth == 8) || (gLowRes) || (!(gNativeScreenMode)))) ||
			((!(gMainScreen)) && (gDepth != desktop_color_depth())))
		{

#ifdef DEBUGMODE

			IDOS->Printf("Emulated bitmap: Lowres = %ld, Depth = %ld, Worbench depth = %ld\n", gLowRes, gDepth, desktop_color_depth());

#endif /* DEBUGMODE */

			TRACE("amiga-gfx WARNING: Emulated bitmap: Lowres = %d, Depth = %d, Workbench depth = %d\n", gLowRes, gDepth, desktop_color_depth());

			/* Allocate the p96 BitMap of the required size to use for the emulation */

			if ((gBitMap = IP96->p96AllocBitMap(Width, Height, gDepth, 0, NULL, gRGBFType)) != NULL)
			{
				/* Indicate success */

				RetVal = 1;
			}
		}
		else
		{
			RetVal = 1;
		}

		/* Let Allegro know how it is to shift the colours into place for the various */
		/* drawing modes that we support, taking into account that big and little endian */
		/* modes are arranged differently */

		_rgb_r_shift_15 = 10;
		_rgb_g_shift_15 = 5;
		_rgb_b_shift_15 = 0;

		_rgb_r_shift_16 = 11;
		_rgb_g_shift_16 = 5;
		_rgb_b_shift_16 = 0;

		if (gBigEndian)
		{
			_rgb_r_shift_24 = 16;
			_rgb_g_shift_24 = 8;
			_rgb_b_shift_24 = 0;

			_rgb_a_shift_32 = 24;
			_rgb_r_shift_32 = 16;
			_rgb_g_shift_32 = 8;
			_rgb_b_shift_32 = 0;
		}
		else
		{
			_rgb_r_shift_24 = 0;
			_rgb_g_shift_24 = 8;
			_rgb_b_shift_24 = 16;

			_rgb_a_shift_32 = 24;
			_rgb_r_shift_32 = 0;
			_rgb_g_shift_32 = 8;
			_rgb_b_shift_32 = 16;
		}

		/* If an emulation bitmap is to be used, start the vertical retrace simulation */
		/* timer on which to draw it */

		if (gBitMap)
		{
			amithread_request_timeout(aAmiThread, REDRAW_TIMEOUT);
		}

		/* If we are running fullscreen, hide the hardware mouse pointer imagery */

		if (gMainScreen)
		{
			mouse_set_hardware_imagery(0, 0);
		}
	}

	/* If initialisation failed, free whatever resources have been allocated */

	if (!(RetVal))
	{
		if (gMainWindow)
		{
			IIntuition->CloseWindow(gMainWindow);
			gMainWindow = NULL;
		}

		if (gMainScreen)
		{
			IIntuition->CloseScreen(gMainScreen);
			gMainScreen = NULL;
		}
	}

	return(RetVal);
}

static void gfx_thread_func(struct AmiThread *aAmiThread)
{
	ULONG Index, Signal, ThreadSignal, TimerSignal, WindowSignal;
	struct IntuiMessage *IntuiMessage;
	struct IntuiWheelData *IntuiWheelData;

	/* Cache the signals on which we have to wait */

	ThreadSignal = (1 << aAmiThread->at_ThreadSignalBit);
	TimerSignal = (1 << aAmiThread->at_TimerMsgPort->mp_SigBit);
	WindowSignal = (1 << gMainWindow->UserPort->mp_SigBit);

	/* Loop around and process all signals until we are told to shut down! */

	for ( ; ; )
	{
		Signal = IExec->Wait(ThreadSignal | TimerSignal | WindowSignal);

		/* If the Thread signal has been signalled then process the incoming message */

		if (Signal & ThreadSignal)
		{
			/* Zero is always EM_Shutdown */

			if (aAmiThread->at_Message == 0)
			{
				break;
			}

			/* Otherwise process the class specific messages (in this case, there aren't any */
			/* but if they were, they would be in this else block */

			else
			{
				/* And signal that the message has been processed, as the main thread is waiting */
				/* on this.  Even unknown messages (which we shouldn't get anyway) are acknowledged */

				amithread_reply_message(aAmiThread);
			}
		}

		/* If the vertical retrace simulation timer has triggered, redraw the screen */

		if (Signal & TimerSignal)
		{
			draw();

			/* And request another simulation timer event */

			amithread_request_timeout(aAmiThread, REDRAW_TIMEOUT);
		}

		/* If the window has received some input then process it as appropriate */

		if (Signal & WindowSignal)
		{
			/* Loop around and process all messages until the message queue is empty */

			while ((IntuiMessage = (struct IntuiMessage *) IExec->GetMsg(gMainWindow->UserPort)) != NULL)
			{
				switch (IntuiMessage->Class)
				{
					case IDCMP_CLOSEWINDOW :
					{
						/* If a callback for the close button has been set, call it */

						if (gCloseButtonCallback)
						{
							gCloseButtonCallback();
						}

						break;
					}

					case IDCMP_EXTENDEDMOUSE :
					{
						IntuiWheelData = IntuiMessage->IAddress;
						mouse_handle_wheel(IntuiWheelData->WheelY);

						break;
					}

					case IDCMP_MOUSEBUTTONS :
					{
						mouse_handle_buttons(IntuiMessage->Code);

						break;
					}

					case IDCMP_MOUSEMOVE :
					{
						mouse_handle_move(IntuiMessage->MouseX, IntuiMessage->MouseY);

						break;
					}

					case IDCMP_RAWKEY :
					{
						keyboard_handle_key(IntuiMessage);

						break;
					}

					case IDCMP_REFRESHWINDOW :
					{
						/* Obtain the dirty area signal semaphore so gSafeDirtyArea can be accessed from multiple threads */

						IExec->ObtainSemaphore(&gDirtyAreaSemaphore);

						/* Mark the entire screen as dirty and redraw it */

						gSafeDirtyArea.da_TopLine = 0;
						gSafeDirtyArea.da_BottomLine = (gBitmap->h - 1);

						/* And release the dirty area signal semaphore so that other threads can access gSafeDirtyArea */

						IExec->ReleaseSemaphore(&gDirtyAreaSemaphore);

						/* And refresh the Allegro window on Workbench */

						draw();

						break;
					}
				}

				/* And reply to the message */

				IExec->ReplyMsg((struct Message *) IntuiMessage);
			}
		}
	}

	/* Because keyboard events come from a screen or window, there is a chance that if closing a */
	/* screen or window when a key is pressed will result in never receiving the key up event. */
	/* As a workaround for this, set all Allegro key states to unpressed */

	for (Index = KEY_A; Index < __allegro_KEY_MAX; ++Index)
	{
		key[Index] = 0;
	}

	/* The thread is shutting down so free whatever resources have been allocated */

	IP96->p96FreeBitMap(gBitMap);
	gBitMap = NULL;

	IIntuition->CloseWindow(gMainWindow);
	gMainWindow = NULL;

	/* Close the main screen, but only if it was opened successfully */

	if (gMainScreen)
	{
		IIntuition->CloseScreen(gMainScreen);
		gMainScreen = NULL;
	}
}

static unsigned char *read_bank(BITMAP *aBitmap, int aLine)
{
	unsigned char *RetVal;
	LONG Lock;
	struct VideoBitmap *VideoBitmap;

	/* If the target bitmap is on the screen itself or has been allocated in video memory for */
	/* flipping, call the video bitmap locking function which can handle both types */

	if ((aBitmap->id == BMP_ID_SYSTEM) || (aBitmap->id == BMP_ID_VIDEO))
	{
		/* Get a ptr to the VideoBitmap structure, stored in the user data part of the BITMAP structure */
		/* and find out whether the BitMap is locked into memory yet */

		VideoBitmap = aBitmap->extra;
		Lock = VideoBitmap->vb_Lock;

		/* Get the ptr to the line to be read */

		RetVal = video_read_write_bank(aBitmap, aLine);

		/* If it wasn't yet locked, but is now, increment the lock count for use by unwrite_bank() */

		if ((!(Lock)) && (VideoBitmap->vb_Lock))
		{
			++VideoBitmap->vb_LockCount;
		}
	}

	/* Otherwise its an internal bitmap allocated by Allegro in system memory so just return */
	/* a pointer to it and don't bother about locking */

	else
	{
		RetVal = aBitmap->line[aLine];
	}

	return(RetVal);
}

static unsigned char *write_bank(BITMAP *aBitmap, int aLine)
{
	unsigned char *RetVal;
	LONG Lock;
	struct VideoBitmap *VideoBitmap;

	/* See if the line being returned is within the dirty area and if not, expand the dirty */
	/* area to include it */

	// TODO: CAW - How does this fit into the signal semaphore?
	if (aLine < gDirtyArea.da_TopLine)
	{
		gDirtyArea.da_TopLine = aLine;
	}

	if (aLine > gDirtyArea.da_BottomLine)
	{
		gDirtyArea.da_BottomLine = aLine;
	}

	/* If the target bitmap is on the screen itself or has been allocated in video memory for */
	/* flipping, call the video bitmap locking function which can handle both types */

	if ((aBitmap->id == BMP_ID_SYSTEM) || (aBitmap->id == BMP_ID_VIDEO))
	{
		/* Get a ptr to the VideoBitmap structure, stored in the user data part of the BITMAP structure */
		/* and find out whether the BitMap is locked into memory yet */

		VideoBitmap = aBitmap->extra;
		Lock = VideoBitmap->vb_Lock;

		/* Get the ptr to the line to be written */

		RetVal = video_read_write_bank(aBitmap, aLine);

		/* If it wasn't yet locked, but is now, increment the lock count for use by unwrite_bank() */

		if ((!(Lock)) && (VideoBitmap->vb_Lock))
		{
			++VideoBitmap->vb_LockCount;
		}
	}

	/* Otherwise its an internal bitmap allocated by Allegro in system memory so just return */
	/* a pointer to it and don't bother about locking */

	else
	{
		RetVal = aBitmap->line[aLine];
	}

	return(RetVal);
}

static void unwrite_bank(BITMAP *aBitmap)
{
	struct VideoBitmap *VideoBitmap;

	/* The unwrite_bank() function is shared between the system memory bitmaps and the direct */
	/* video access routines, so check whether the bitmap is a system memory frame buffer */
	/* or a screen or video memory bitmap.  Nothing needs to be done for system memory bitmaps */

	if ((aBitmap->id == BMP_ID_SYSTEM) || (aBitmap->id == BMP_ID_VIDEO))
	{
		/* The generic Allegro BITMAP structure allows user data to be placed in BITMAP.extra. */
		/* In our case, we use it to store a ptr to our VideoBitmap structure, which contains */
		/* information about the screen BitMap being accessed */

		VideoBitmap = aBitmap->extra;

		/* Guard against being called when the bitmap is not already locked, as trying to unlock */
		/* an already unlocked BitMap will freeze the system */

		if (VideoBitmap->vb_Lock != 0)
		{
			/* Decrement the lock count and if this is the last lock, unlock the BitMap */

			if (--VideoBitmap->vb_LockCount == 0)
			{
				/* If this is a video memory bitmap, just go ahead and unlock it */

				if (aBitmap->id == BMP_ID_VIDEO)
				{
					IP96->p96UnlockBitMap(VideoBitmap->vb_BitMap, VideoBitmap->vb_Lock);
				}
				else
				{
					/* Otherwise if it is a screen memory bitmap then we need special checks.  If we are */
					/* accessing the screen directly, just unlock the screen bitmap */

					if (!(gBitMap))
					{
						IP96->p96UnlockBitMap(gMainWindow->RPort->BitMap, VideoBitmap->vb_Lock);
					}

					/* Otherwise if an emulation BitMap is being used but *not* an emulation buffer, */
					/* unlock it */

					else if ((!(gLowRes)) && (gDepth != 8))
					{
						IP96->p96UnlockBitMap(gBitMap, VideoBitmap->vb_Lock);
					}

					/* If an emulation buffer is being used, copy it into the emulation bitmap */

					if ((gBitMap) && ((gLowRes) || (gDepth == 8)))
					{
						copy_dirty_rect(aBitmap);
					}
					else
					{
						// TODO: CAW - Check + check use of work "BitMap"
						if (gDirtyArea.da_TopLine < gSafeDirtyArea.da_TopLine)
						{
							gSafeDirtyArea.da_TopLine = gDirtyArea.da_TopLine;
						}

						if (gDirtyArea.da_BottomLine > gSafeDirtyArea.da_BottomLine)
						{
							gSafeDirtyArea.da_BottomLine = gDirtyArea.da_BottomLine;
						}

						/* Reset the dirty area so that it won't get copied again */

						gDirtyArea.da_TopLine = (gHeight - 1);
						gDirtyArea.da_BottomLine = 0;
					}
				}

				/* Indicate that we are now unlocked */

				VideoBitmap->vb_Lock = 0;

				/* And unlock the dirty area signal semaphore, to allow the rendering thread to get to the */
				/* bitmap, if required */

				IExec->ReleaseSemaphore(&gDirtyAreaSemaphore);
			}
		}
	}
}

static unsigned char *video_read_write_bank(BITMAP *aBitmap, int aLine)
{
	int BytesPerPixel;
	unsigned char *RetVal;
	struct BitMap *BitMap;
	struct VideoBitmap *VideoBitmap;

	/* Get a ptr to the VideoBitmap structure, stored in the user data part of the BITMAP structure */

	VideoBitmap = aBitmap->extra;

	/* If the P96 BitMap has already been locked into memory, calculate a ptr to the requested line */

	if (VideoBitmap->vb_Lock != 0)
	{
		/* If the bitmap is the screen and an emulation buffer is being used, return a ptr to */
		/* memory in that buffer */

		if ((aBitmap->id == BMP_ID_SYSTEM) && (gBitMap) && ((gLowRes) || (gDepth == 8)))
		{
			RetVal = aBitmap->line[aLine];
		}

		/* Otherwise return a ptr to the "real" BitMap */
		
		else
		{
			/* Calculate a ptr to the the start of the line requested, taking into account the position */
			/* of the BitMap on the screen in direct screen access mode */

			RetVal = (((unsigned char *) VideoBitmap->vb_RenderInfo.Memory) + (aLine * VideoBitmap->vb_RenderInfo.BytesPerRow));
			RetVal += VideoBitmap->vb_BitMapOffset;
		}
	}

	/* Otherwise, try to lock it into memory and then calculate the ptr to the requested line */

	else
	{
		/* Assume that we won't be locking anything into memory */

		BitMap = NULL;

		/* If this is a video memory bitmap, just go ahead and unlock it */

		if (aBitmap->id == BMP_ID_VIDEO)
		{
			BitMap = VideoBitmap->vb_BitMap;
		}
		else
		{
			/* Otherwise if it is a screen memory bitmap then we need special checks.  If we are */
			/* accessing the screen directly, just lock the screen bitmap */

			if (!(gBitMap))
			{
				BitMap = gMainWindow->RPort->BitMap;
			}

			/* Otherwise if an emulation BitMap is being used but *not* an emulation buffer, */
			/* lock it */

			else if ((!(gLowRes)) && (gDepth != 8))
			{
				BitMap = gBitMap;
			}
		}

		/* Lock the dirty area signal semaphore for the duration of the BitMap access, so they rendering */
		/* thread cannot get at the BitMap */

		IExec->ObtainSemaphore(&gDirtyAreaSemaphore);

		/* If a BitMap was selected for locking, go ahead and lock it now */

		if (BitMap)
		{
			if ((VideoBitmap->vb_Lock = IP96->p96LockBitMap(BitMap, (UBYTE *) &VideoBitmap->vb_RenderInfo,
				sizeof(VideoBitmap->vb_RenderInfo))) != 0)
			{
				/* If we are using direct screen access, we must calculate the offset of the top left */
				/* hand corner of the BitMap on the screen */

				if (BitMap == gMainWindow->RPort->BitMap)
				{
					/* The Y position will be the top of the window + the height of the window border */
					/* and the X position will be the left of the window + the width of the window border */

					BytesPerPixel = IP96->p96GetBitMapAttr(BitMap, P96BMA_BYTESPERPIXEL);

					VideoBitmap->vb_BitMapOffset = (((gMainWindow->TopEdge + gMainWindow->BorderTop) * VideoBitmap->vb_RenderInfo.BytesPerRow) +
						((gMainWindow->LeftEdge + gMainWindow->BorderLeft) * BytesPerPixel));
				}
				else
				{
					VideoBitmap->vb_BitMapOffset = 0;
				}

				/* Calculate a ptr to the the start of the line requested, taking into account the position */
				/* of the BitMap on the screen in direct screen access mode */

				RetVal = (((unsigned char *) VideoBitmap->vb_RenderInfo.Memory) + (aLine * VideoBitmap->vb_RenderInfo.BytesPerRow));
				RetVal += VideoBitmap->vb_BitMapOffset;
			}
		}

		/* Otherwise just return a ptr to the emulation buffer */

		else
		{
			VideoBitmap->vb_Lock = 1;
			RetVal = aBitmap->line[aLine];
		}

		/* The BitMap could not be locked.  The calling code expects this routine not to fail and doing */
		/* so will probably cause a crash, so we will return a ptr to a phantom buffer.  In this case, */
		/* nothing will appear on the screen but this is better than crashing */

		if ((!VideoBitmap->vb_Lock))
		{
			RetVal = aBitmap->line[aLine];

			/* Unlock the dirty area signal semaphore as the next time this routine is called, it will attempt to */
			/* lock the BitMap again, given that it failed this time */

			IExec->ReleaseSemaphore(&gDirtyAreaSemaphore);
		}
	}

	return(RetVal);
}

static BITMAP *gfx_init(int aWidth, int aHeight, int aVirtualWidth, int aVirtualHeight, int aDepth, int aFullScreen)
{
	int Depth, Index, ModeWidth, ModeHeight, Ok, Width, Height;
	ULONG ModeID, P96Mode;
	struct ColourMapping *ColourMapping;
	struct Screen *Screen;
	struct VideoBitmap *VideoBitmap;
	BITMAP *RetVal;

	/* The virtual width and height variables are used for page flipping when using one large screen */
	/* buffer.  We don't support this as we support allocating multiple areas of video memory, so just */
	/* reference them here to avoid a warning */

	(void) aVirtualWidth;
	(void) aVirtualHeight;

	/* Assume failure */

	Ok = 0;
	RetVal = NULL;

	/* First off, disable ctrl-c checking */

	signal(SIGINT, SIG_IGN);

	/* Indicate that it is safe to flip screens */

	gSafeToFlip = 1;

	/* See if there is a P96 mode that matches the requested width, height and depth.  This */
	/* will be used for creating the P96 BitMap that will be used for getting the Allegro */
	/* bitmap onto the screen */

	if ((ColourMapping = convert_depth(aDepth)) != NULL)
	{
		//Depth = (aDepth == 8) ? desktop_color_depth() : aDepth;
		// TODO: CAW
		//if ((aFullScreen) && (aDepth == 8))
		if (aDepth == 8)
		{
			Depth = 32; // TODO: CAW - Was 16
		}
		else
		{
			Depth = aDepth;
		}

		/* Assume non full screen mode */

		gModeID = INVALID_ID;

		// TODO: CAW - Comment re: 32 bit screen
		/* If full screen mode has been requested, see if there is a screenmode that precisely */
		/* matches the requested width, height & depth.  If not then return failure.  Note that */
		/* a 32 bit bit screen is used for redering 8 bit Allegro bitmaps, to avoid having to */
		/* muck around with CLUT tables which make a mess of Workbench anyway */

		if (aFullScreen)
		{
			/* For lowres client areas (ie. 320x200 or 320x240) we cannot open a screen of the required */
			/* size under OS4, so we will open a larger screen and double the size of the client */
			/* bitmap when it is copied to that screen, thereby emulating a lowres screen.  Check */
			/* for this situation and set the width and heigh of the target screen appropriately */

			if ((aWidth == 320) && ((aHeight == 200) || (aHeight == 240)))
			{
				gLowRes = 1;
				Width = 640;
				Height = 480;
			}
			else
			{
				gLowRes = 0;
				Width = aWidth;
				Height = aHeight;
			}

			/* Get the best Mode ID for the required screen */

			gModeID = IP96->p96BestModeIDTags(P96BIDTAG_NominalWidth, Width, P96BIDTAG_NominalHeight, Height,
				P96BIDTAG_Depth, Depth, TAG_DONE);

			/* If we have a Mode ID but it may be larger than we requested so check this */

			if (gModeID != INVALID_ID)
			{
				/* Get the width & height of the requested mode, as well as the RGB format and */
				/* whether the screen is a Picasso 96 screen, for validity checking and to */
				/* determine the best pixel format to use */

				ModeWidth = IP96->p96GetModeIDAttr(gModeID, P96IDA_WIDTH);
				ModeHeight = IP96->p96GetModeIDAttr(gModeID, P96IDA_HEIGHT);
				gRGBFType = IP96->p96GetModeIDAttr(gModeID, P96IDA_RGBFORMAT);
				P96Mode = IP96->p96GetModeIDAttr(gModeID, P96IDA_ISP96);

				if (P96Mode)
				{
					if ((Width == ModeWidth) && (Height == ModeHeight))
					{
						Ok = gNativeScreenMode = 1;

						/* Ensure that the RGB mapping of the Mode ID is supported by our renderers */

						if (gRGBFType == ColourMapping->cm_Mapping)
						{
							gBigEndian = 1;
						}
						else if (gRGBFType == ColourMapping->cm_AltMapping)
						{
							gBigEndian = 0;
						}
						else
						{

#ifdef DEBUGMODE

							IDOS->Printf("Warning: Selected non native big endian %ld x %ld @ %ld for custom screen (format = %ld)\n",
								aWidth, aHeight, Depth, gRGBFType);

#endif /* DEBUGMODE */

							TRACE("amiga-gfx WARNING: Selected non native big endian %d x %d @ %d for custom screen (format = %d)\n",
								aWidth, aHeight, Depth, gRGBFType);

							gRGBFType = ColourMapping->cm_Mapping;
							gBigEndian = 1;

							/* Indicate that a non native screen mode is in use.  This is because direct screen access */
							/* cannot be used in this case */

							gNativeScreenMode = 0;
						}
					}
				}
				else
				{
					IDOS->Printf("Error: OCS/ECS/AGA screen modes are not supported\n");
				}
			}
		}
		else
		{
			/* Lock the Workbench screen so that we can obtain its dimensions and centre */
			/* the window on it.  If this fails (extremely unlikely) then the window can just */
			/* sit at the top left of the Workbench screen */

			if ((Screen = IIntuition->LockPubScreen(NULL)) != NULL)
			{
				gWorkbenchWindowTags[TAG_OFFSET_LEFT].ti_Data = ((Screen->Width - aWidth) / 2);
				gWorkbenchWindowTags[TAG_OFFSET_TOP].ti_Data = ((Screen->Height - aHeight) / 2);

				IIntuition->UnlockPubScreen(NULL, Screen);
			}

			/* Get the Mode ID of the Workbench screen, and the RGB format and whether the screen */
			/* is a Picasso 96 screen, for validity checking and to determine the best pixel format */
			/* to use */

			if ((ModeID = IGraphics->GetVPModeID(&Screen->ViewPort)) != INVALID_ID)
			{
				gRGBFType = IP96->p96GetModeIDAttr(ModeID, P96IDA_RGBFORMAT);
				P96Mode = IP96->p96GetModeIDAttr(ModeID, P96IDA_ISP96);

				if (P96Mode)
				{
					Ok = gNativeScreenMode = 1; // TODO: CAW

					/* Ensure that the RGB mapping of the Mode ID is supported by our renderers */

					if (gRGBFType == ColourMapping->cm_Mapping)
					{
						gBigEndian = 1;
					}
					else if (gRGBFType == ColourMapping->cm_AltMapping)
					{
						gBigEndian = 0;
					}
					else
					{

#ifdef DEBUGMODE

						IDOS->Printf("Warning: Selected non native big endian %ld x %ld @ %ld for Workbench (format = %ld)\n",
							aWidth, aHeight, Depth, gRGBFType);

#endif /* DEBUGMODE */

						TRACE("amiga-gfx WARNING: Selected non native big endian %d x %d @ %d for Workbench (format = %d)\n",
							aWidth, aHeight, Depth, gRGBFType);

						gRGBFType = ColourMapping->cm_Mapping;
						gBigEndian = 1;
					}
				}
				else
				{
					IDOS->Printf("Error: OCS/ECS/AGA screen modes are not supported\n");
				}
			}
		}

		/* Only continue if a valid screen mode has been found */

		if (Ok)
		{
			Ok = 0;

			/* Allocate an Allegro BITMAP structure and a buffer to hold the actual bitmap data */

			if ((gBitmap = RetVal = _AL_MALLOC(sizeof(BITMAP) + sizeof(char *) * aHeight)) != NULL)
			{
				memset(gBitmap, 0, sizeof(BITMAP));

				/* Allocate the Amiga OS specific variables required for BitMap access */

				if ((RetVal->extra = VideoBitmap = _AL_MALLOC(sizeof(struct VideoBitmap))) != NULL)
				{
					/* Set its contents to 0 in case anything below fails and we need to cleanup a partially */
					/* allocated structure */

					memset(VideoBitmap, 0, sizeof(struct VideoBitmap));

					if ((gOutBuffer = _AL_MALLOC(aWidth * aHeight * BYTES_PER_PIXEL(aDepth))) != NULL)
					{
						/* Save details about the requested resolution and depth for l8r use */

						gWidth = aWidth;
						gHeight = aHeight;
						gDepth = aDepth;
						gBPP = BYTES_PER_PIXEL(aDepth);

						/* For lowres client areas (ie. 320x200 or 320x240) we cannot open a screen of the required */
						/* size under OS4, so we will open a larger screen and double the size of the client */
						/* bitmap when it is copied to that screen, thereby emulating a lowres screen */

						if (gLowRes)
						{
							Width = 640;
							Height = 480;
						}
						else
						{
							Width = aWidth;
							Height = aHeight;
						}

						/* Initialise the dirty area to be initially empty.  Only if da_BottomLine >= */
						/* da_TopLine will anything be rendered */

						gDirtyArea.da_TopLine = gSafeDirtyArea.da_TopLine = (aHeight - 1);

						/* Update the taglists so that they open a window of the requested size */

						gWorkbenchWindowTags[TAG_OFFSET_WIDTH].ti_Data = gCustomWindowTags[TAG_OFFSET_WIDTH].ti_Data = Width;
						gWorkbenchWindowTags[TAG_OFFSET_HEIGHT].ti_Data = gCustomWindowTags[TAG_OFFSET_HEIGHT].ti_Data = Height;

						/* Most of the GFX_VTABLE entries used are the generic ones in Allegro.  The */
						/* only one we override is unwrite_bank */

						gGfxVTable.unwrite_bank = unwrite_bank;

						/* Initialise members of our GFX_DRIVER structures that can only be initialised */
						/* at runtime */

						gfx_amiga_fullscreen.w = gfx_amiga_windowed.w = aWidth;
						gfx_amiga_fullscreen.h = gfx_amiga_windowed.h = aHeight;
						gfx_amiga_fullscreen.vid_mem = gfx_amiga_windowed.vid_mem = (aWidth * aHeight * gBPP);

						/* Now initialise the rest of the BITMAP structure as appropriate */

						RetVal->w = RetVal->cr = aWidth;
						RetVal->h = RetVal->cb = aHeight;
						RetVal->clip = 1;
						RetVal->cl = RetVal->ct = 0;
						RetVal->vtable = &gGfxVTable;
						RetVal->read_bank = read_bank;
						RetVal->write_bank = write_bank;
						RetVal->dat = gOutBuffer;
						RetVal->id = BMP_ID_SYSTEM;
						RetVal->x_ofs = RetVal->y_ofs = 0;
						RetVal->seg = _video_ds();

						/* Initialise the array of pointers to the first pixel of each line in the */
						/* output buffer.  These will be returned by read_line() and write_line() */

						for (Index = 0; Index < aHeight; ++Index)
						{
							RetVal->line[Index] = (gOutBuffer + (Index * aWidth * gBPP));
						}

						// TODO: CAW
						IExec->InitSemaphore(&gDirtyAreaSemaphore);

						/* And create the graphics thread, which starts everything going! */

						// TODO: CAW - Failure checking for here and video bitmap creation
						Ok = amithread_create(&gGraphicsThread, gfx_thread_init, gfx_thread_func, NULL);
					}
				}
			}
		}
	}

	/* If the graphics system could not be initialised, free whatever was allocated.  This is */
	/* done here rather than in gfx_exit() as normally Allegro itself would free these buffers */
	/* rather than us */

	if (!(Ok))
	{
		/* Indicate that initialisation failed */

		RetVal = NULL;

		/* And free whatever buffers were allocated */

		// TODO: CAW - Where is this freed?
		if (gOutBuffer)
		{
			_AL_FREE(gOutBuffer);
			gOutBuffer = NULL;
		}

		if (gBitmap)
		{
			if (gBitmap->extra)
			{
				_AL_FREE(gBitmap->extra);
			}

			_AL_FREE(gBitmap);
			gBitmap = NULL;
		}
	}

	return(RetVal);
}

static BITMAP *init_fullscreen(int aWidth, int aHeight, int v_w, int v_h, int aDepth)
{
	return(gfx_init(aWidth, aHeight, v_w, v_h, aDepth, 1));
}

static BITMAP *init_windowed(int aWidth, int aHeight, int v_w, int v_h, int aDepth)
{
	return(gfx_init(aWidth, aHeight, v_w, v_h, aDepth, 0));
}

static void gfx_exit(struct BITMAP *aBitmap)
{
	(void) aBitmap;

	/* Destroy the graphics thread - amithread_destroy() will take care of signalling and */
	/* synchronisation so when it returns the thread has cleanly exited */

	amithread_destroy(&gGraphicsThread);

	/* And free the main window's custom title, if allocated */

	if (gMainWindowTitle)
	{
		_AL_FREE(gMainWindowTitle);
		gMainWindowTitle = NULL;
	}

	// TODO: CAW
	gOutBuffer = NULL;
}

static void gfx_vsync()
{
	// TODO: CAW - Use a signal from the drawing task
	rest(20);
}

// TODO: CAW - Get this working
static int gfx_set_mouse_sprite(struct BITMAP *aSprite, int aXFocus, int aYFocus)
{
	(void) aSprite;
	(void) aXFocus;
	(void) aYFocus;

	return(1);
}

static void gfx_set_palette(const struct RGB *aRGB, int aFrom, int aTo, int aRetraceSync)
{
	int Index;

	(void) aRetraceSync;

	/* This function is only called in 8 bit CLUT mode.  Iterate through the palette entries */
	/* passed in and save them for use by draw(), creating the 32 bit pixel value that will be */
	/* written for each palette entry, thereby speeding up draw().  Note that this function */
	/* takes the endianess into account when creating the palette entries */

	// TODO: CAW - These shifts are a bit odd
	if (gBigEndian)
	{
		for (Index = aFrom; Index <= aTo; ++Index)
		{
			gPalette[Index] = ((aRGB->r << 18) | (aRGB->g << 10) | (aRGB->b << 2));
			++aRGB;
		}
	}
	else
	{
		for (Index = aFrom; Index <= aTo; ++Index)
		{
			gPalette[Index] = ((aRGB->b << 18) | (aRGB->g << 10) | (aRGB->r << 2));
			++aRGB;
		}
	}

	/* Mark the entire screen as dirty and redraw it, to show the effects of the fade routine */

	gDirtyArea.da_TopLine = 0;
	gDirtyArea.da_BottomLine = (gBitmap->h - 1);
	unwrite_bank(gBitmap);
}

static struct BITMAP *gfx_create_video_bitmap(int aWidth, int aHeight)
{
	int Index, Ok;
	struct BITMAP *RetVal;
	struct VideoBitmap *VideoBitmap;

	/* Assume failure */

	Ok = 0;
	RetVal = NULL;

	if (gNativeScreenMode)
	{
		/* If the DBufInfo structure has not yet been allocated, allocate it now */

		if (!(gDBufInfo))
		{
			if ((gDBufInfo = IGraphics->AllocDBufInfo(&gMainScreen->ViewPort)) != NULL)
			{
				/* Create MsgPorts that can be used for checking when it is safe to draw to the just */
				/* flipped-out BitMap and when it is safe to perform the next page flip */

				gDBufInfo->dbi_SafeMessage.mn_ReplyPort	= gSafeMsgPort = IExec->CreateMsgPort();
				gDBufInfo->dbi_DispMessage.mn_ReplyPort	= gDispMsgPort = IExec->CreateMsgPort();
			}
		}

		/* Continue only if the DBufInfo structure and its message ports have been created successfully */

		if (gDBufInfo)
		{
			/* Indicate that we are using the DBufInfo structure.  gfx_destroy_video_bitmap() will take */
			/* care of decrementing this, even if the code below fails */

			++gUseCount;

			/* Only continue if both message ports were allocated ok */

			if ((gDispMsgPort) && (gSafeMsgPort))
			{
				/* Allocate an Allegro BITMAP structure */

				if ((RetVal = _AL_MALLOC(sizeof(BITMAP) + sizeof(char *) * aHeight)) != NULL)
				{
					memset(RetVal, 0, sizeof(BITMAP));

					/* Allocate the Amiga OS specific variables required for BitMap access */

					if ((RetVal->extra = VideoBitmap = _AL_MALLOC(sizeof(struct VideoBitmap))) != NULL)
					{
						/* Set its contents to 0 in case anything below fails and we need to cleanup a partially */
						/* allocated structure */

						memset(VideoBitmap, 0, sizeof(struct VideoBitmap));

						if ((VideoBitmap->vb_SafetyBuffer = _AL_MALLOC(aWidth * aHeight * BYTES_PER_PIXEL(gDepth))) != NULL)
						{
							if ((VideoBitmap->vb_BitMap = IP96->p96AllocBitMap(aWidth, aHeight, gDepth, 0, NULL, gRGBFType)) != NULL)
							{
								/* Indicate success */

								Ok = 1;

								/* Now initialise the rest of the BITMAP structure as appropriate */

								RetVal->w = RetVal->cr = aWidth;
								RetVal->h = RetVal->cb = aHeight;
								RetVal->clip = 1;
								RetVal->cl = RetVal->ct = 0;
								RetVal->vtable = &gGfxVTable;
								RetVal->write_bank = write_bank;
								RetVal->read_bank = read_bank;
								RetVal->dat = NULL;
								RetVal->id = BMP_ID_VIDEO;
								RetVal->x_ofs = RetVal->y_ofs = 0;
								RetVal->seg = _video_ds();

								/* We will normally return a ptr to video memory when write_bank() is called.  However, */
								/* it is possible for locking of the P96 BitMap to fail, an client code assumes that the */
								/* write_bank() function cannot fail.  In the case of P96 locking failing, we will */
								/* return a ptr to a "phantom bitmap" so that the client code will not crash.  The user */
								/* will not see anything being rendered, but this is better than a crash */

								for (Index = 0; Index < aHeight; ++Index)
								{
									RetVal->line[Index] = VideoBitmap->vb_SafetyBuffer;
								}
							}
						}
					}
				}
			}
		}

		/* If anything failed, free the bitmap and whatever of its helper variables were allocated */

		if (!(Ok))
		{
			gfx_destroy_video_bitmap(RetVal);
		}
	}

	return(RetVal);
}

static void gfx_destroy_video_bitmap(struct BITMAP *aBitmap)
{
	struct VideoBitmap *VideoBitmap;

	/* This function gets called from gfx_create_video_bitmap() on failure, which means that anything */
	/* can be NULL and needs to be checked */

	if (aBitmap)
	{
		if (aBitmap->dat)
		{
			_AL_FREE(aBitmap->dat);
		}

		/* Get a ptr to our VideoBitmap structure from the generic BITMAP structure, checking that */
		/* it was actually allocted */

		if ((VideoBitmap = aBitmap->extra) != NULL)
		{
			/* Free the ptrs to the various helper structures and buffers, if they have been allocated */

			if (VideoBitmap->vb_BitMap)
			{
				IP96->p96FreeBitMap(VideoBitmap->vb_BitMap);
			}

			if (VideoBitmap->vb_SafetyBuffer)
			{
				_AL_FREE(VideoBitmap->vb_SafetyBuffer);
			}

			_AL_FREE(VideoBitmap);
		}

		/* And free the generic BITMAP structure */

		_AL_FREE(aBitmap);
	}

	/* Ensure that the DBufInfo exists before trying to do anything with it.  Note that if we */
	/* free structures pertaining to page flipping here, then we set them to NULL as there is */
	/* nothing to stop client code from creating a new video bitmap */

	if (gDBufInfo)
	{
		/* Decrement the DBufInfo's use count and if zero, free it */

		if (--gUseCount == 0)
		{
			/* If the display message port was allocated, drain it of messages and free it */

			if (gDispMsgPort)
			{
				while(IExec->GetMsg(gDispMsgPort)) { }

				IExec->DeleteMsgPort(gDispMsgPort);
				gDispMsgPort = NULL;
			}

			/* If the safe to draw message port was allocated, drain it of messages and free it */

			if (gSafeMsgPort)
			{
				while(IExec->GetMsg(gSafeMsgPort)) { }

				IExec->DeleteMsgPort(gSafeMsgPort);
				gSafeMsgPort = NULL;
			}

			/* And free the DBufInfo structure itself */

			IGraphics->FreeDBufInfo(gDBufInfo);
			gDBufInfo = NULL;
		}
	}
}

static int gfx_show_video_bitmap(struct BITMAP *aBitmap)
{
	struct VideoBitmap *VideoBitmap;

	/* Get a ptr to our VideoBitmap structure from the generic BITMAP structure */
 
	VideoBitmap = aBitmap->extra;

	/* If a flip has already been done, wait until it is safe to do another one */

	if (!(gSafeToFlip))
	{
		while (!(IExec->GetMsg(gDispMsgPort)))
		{
			IExec->Wait(1 << gDispMsgPort->mp_SigBit);
		}
	}

	/* Flip the BitMap and indicate that it has been done */

	IGraphics->ChangeVPBitMap(&gMainScreen->ViewPort, VideoBitmap->vb_BitMap, gDBufInfo);
	gSafeToFlip	= 0;

	/* And wait until it is safe to draw to the old BitMap */

	while (!(IExec->GetMsg(gSafeMsgPort)))
	{
		IExec->Wait(1 << gSafeMsgPort->mp_SigBit);
	}

	/* Always return success */

	return(0);
}

GFX_DRIVER gfx_amiga_fullscreen =
{
/*                      id */ GFX_AMIGA_FULLSCREEN,
/*                    name */ empty_string,
/*                    desc */ empty_string,
/*              ascii_name */ "amigaosgfxfullscreen",
/*                    init */ init_fullscreen,
/*                    exit */ gfx_exit,
/*                  scroll */ NULL,
/*                   vsync */ gfx_vsync,
/*             set_palette */ gfx_set_palette,
/*          request_scroll */ NULL,
/*             poll_scroll */ NULL,
/*    enable_triple_buffer */ NULL,
/*     create_video_bitmap */ gfx_create_video_bitmap,
/*    destroy_video_bitmap */ gfx_destroy_video_bitmap,
/*       show_video_bitmap */ gfx_show_video_bitmap,
/*    request_video_bitmap */ NULL,
/*    create_system_bitmap */ NULL,
/*   destroy_system_bitmap */ gfx_destroy_video_bitmap,
/*        set_mouse_sprite */ gfx_set_mouse_sprite,
/*              show_mouse */ NULL,
/*              hide_mouse */ NULL,
/*              move_mouse */ NULL,
/*            drawing_mode */ NULL,
/*        save_video_state */ NULL,
/*     restore_video_state */ NULL,
/*        set_blender_mode */ NULL,
/*         fetch_mode_list */ NULL,
/*                       w */ 0,
/*                       h */ 0,
/*                  linear */ 1,
/*               bank_size */ 0,
/*               bank_gran */ 0,
/*                 vid_mem */ 0,
/*           vid_phys_base */ 0,
/*                windowed */ 0,
};

GFX_DRIVER gfx_amiga_windowed =
{
/*                      id */ GFX_AMIGA_WINDOWED,
/*                    name */ empty_string,
/*                    desc */ empty_string,
/*              ascii_name */ "amigaosgfxwindowed",
/*                    init */ init_windowed,
/*                    exit */ gfx_exit,
/*                  scroll */ NULL,
/*                   vsync */ gfx_vsync,
/*             set_palette */ gfx_set_palette,
/*          request_scroll */ NULL,
/*             poll_scroll */ NULL,
/*    enable_triple_buffer */ NULL,
/*     create_video_bitmap */ NULL,
/*    destroy_video_bitmap */ NULL,
/*       show_video_bitmap */ NULL,
/*    request_video_bitmap */ NULL,
/*    create_system_bitmap */ NULL,
/*   destroy_system_bitmap */ gfx_destroy_video_bitmap,
/*        set_mouse_sprite */ gfx_set_mouse_sprite,
/*              show_mouse */ NULL,
/*              hide_mouse */ NULL,
/*              move_mouse */ NULL,
/*            drawing_mode */ NULL,
/*        save_video_state */ NULL,
/*     restore_video_state */ NULL,
/*        set_blender_mode */ NULL,
/*         fetch_mode_list */ NULL,
/*                       w */ 0,
/*                       h */ 0,
/*                  linear */ 1,
/*               bank_size */ 0,
/*               bank_gran */ 0,
/*                 vid_mem */ 0,
/*           vid_phys_base */ 0,
/*                windowed */ 1,
};

/* List of available drivers */

_DRIVER_INFO _gfx_driver_list[] =
{
    {  GFX_AMIGA_FULLSCREEN, &gfx_amiga_fullscreen, 1 },
    {  GFX_AMIGA_WINDOWED,   &gfx_amiga_windowed,   1 },
    {  0,                    NULL,                  0 }
};
