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

#include <cybergraphx/cybergraphics.h>
#include <proto/cybergraphics.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
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

/* This structure describes a colour depth mapping, specifying the pixel format and */
/* the GFX_VTABLE to be used for a particular colour depth */

struct ColourMapping
{
	int         cm_Depth;         /* Colour depth (8, 15, 16, 24 or 32 bits) */
	GFX_VTABLE *cm_GfxVTable;     /* Graphics VTable to be used for drawing */
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
	APTR              vb_Lock;          /* ID of lock when the BitMap is locked into place */
	int					vb_LockCount;		/* # of times locked (can be 2 - one for read & one for write) */
	struct BitMap		*vb_BitMap;			/* Ptr to the BitMap in video memory */
	int                vb_BytesPerRow;
	int                vb_BaseAddress;
};

static int gWidth;						/* Width of the client area in pixels */
static int gHeight;						/* Height of the client area in pixels */
static int gFullScreen;					/* 1 to open screen in, or 0 for no screen */
static unsigned char *gOutBuffer;		/* Ptr to buffer used for drawing by Allegro */
static int gDirectDraw;
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

static int gDepth;                     /* Depth of the client area */
static unsigned int gPalette[256];     /* Palette used by Allegro 8 bit drawing modes */
struct AmiThread gGraphicsThread;		/* Thread used for display updates */
struct Window *gMainWindow;				/* Ptr to window on which to display output */

/* Tags used for opening the main window on the Workbench */

static struct TagItem gWorkbenchWindowTags[] =
{
	{ WA_Left, 0 } , { WA_Top, 0 }, { WA_InnerWidth, 0 }, { WA_InnerHeight, 0 },
	{ WA_Title, (ULONG) "Allegro 1.1" }, { WA_PubScreenName, (ULONG) "Workbench" },
	{ WA_Activate, TRUE }, { WA_CloseGadget, TRUE }, { WA_DepthGadget, TRUE }, { WA_DragBar, TRUE },
	{ WA_ReportMouse, TRUE }, { WA_RMBTrap, TRUE }, { WA_SimpleRefresh, TRUE },
	{ WA_IDCMP, ( IDCMP_CLOSEWINDOW | IDCMP_MOUSEBUTTONS | IDCMP_MOUSEMOVE | IDCMP_RAWKEY | IDCMP_REFRESHWINDOW) },
	{ TAG_DONE, TRUE }
};

/* Tags used for opening the main window on a custom screen */

static struct TagItem gCustomWindowTags[] =
{
	{ WA_Left, 0 }, { WA_Top, 0 }, { WA_Width, 0 }, { WA_Height, 0 },
	{ WA_Activate, TRUE }, { WA_Borderless, TRUE }, { WA_ReportMouse, TRUE }, { WA_RMBTrap, TRUE },
	{ WA_IDCMP, ( IDCMP_MOUSEBUTTONS | IDCMP_MOUSEMOVE | IDCMP_RAWKEY ) },
	{ WA_CustomScreen, 0 }, { TAG_DONE, TRUE }
};

/* All graphics modes that can be displayed by the Amiga port of Allegro are listed in */
/* this table */

static const struct ColourMapping gColourMappings[] =
{
	{  8, &__linear_vtable8 },
	{ 15, &__linear_vtable15 },
	{ 16, &__linear_vtable16 },
	{ 24, &__linear_vtable24 },
	{ 32, &__linear_vtable32 }
};

static unsigned char *video_read_write_bank(BITMAP *aBitmap, int aLine);
static void gfx_destroy_video_bitmap(struct BITMAP *aRetVal);

static const struct ColourMapping *convert_depth(int aDepth)
{
	int Index;
	const struct ColourMapping *RetVal;

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

static void draw()
{
	/* Only draw anything if an emulation bitmap is being used */

	if (gDirectDraw == 0)
	{
		int Width, Height, TopLine, BottomLine;

		/* Obtain the dirty area signal semaphore as this function is safe to be called from multiple threads */

		ObtainSemaphore(&gDirtyAreaSemaphore);

		/* Cache a copy of the current safe dirty area */

		TopLine = gSafeDirtyArea.da_TopLine;
		BottomLine = gSafeDirtyArea.da_BottomLine;

		if (BottomLine >= TopLine)
		{
			/* Reset the safe dirty area so that it won't get blitted again */

			gSafeDirtyArea.da_TopLine = (gHeight - 1);
			gSafeDirtyArea.da_BottomLine = 0;

			/* Now blit the BitMap onto the screen! */

			Height = (BottomLine - TopLine + 1);

			/* Height is calculated, so get width of bitmap to blit note that we use our globally */
			/* cached gWidth variable because some hacky demo software messes with the value in */
			/* gBitmap->w to perform graphical trickery */

			Width = gWidth;

			/* Now copy our BitMap onto the screen */

			switch (gDepth)
			{
				case 8:
					WriteLUTPixelArray(gOutBuffer, 0, TopLine, gWidth, gMainWindow->RPort, gPalette,
						gMainWindow->BorderLeft, gMainWindow->BorderTop + TopLine, Width, Height, CTABFMT_XRGB8);
					break;

				case 15:
				case 16:
					#warning byteswap this
					WritePixelArray(gOutBuffer, 0, TopLine, gWidth * 2, gMainWindow->RPort,
						gMainWindow->BorderLeft, gMainWindow->BorderTop + TopLine, Width, Height, RECTFMT_RAW);
					break;

				case 24:
					WritePixelArray(gOutBuffer, 0, TopLine, gWidth * 3, gMainWindow->RPort,
						gMainWindow->BorderLeft, gMainWindow->BorderTop + TopLine, Width, Height, RECTFMT_RGB);
					break;

				case 32:
					WritePixelArray(gOutBuffer, 0, TopLine, gWidth * 4, gMainWindow->RPort,
						gMainWindow->BorderLeft, gMainWindow->BorderTop + TopLine, Width, Height, RECTFMT_ARGB);
					break;
			}
		}

		/* And release the dirty area signal semaphore so that other threads can call us */

		ReleaseSemaphore(&gDirtyAreaSemaphore);
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
			SetWindowTitles(gMainWindow, (STRPTR)gMainWindowTitle, (STRPTR) -1);
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
	/* the main thread.  Start by opening the screen, if required, which is indicated by gFullScreen */
	/* set by gfx_init() */

	if (gFullScreen)
	{
		gMainScreen = OpenScreenTags(NULL, SA_Width, gWidth, SA_Height, gHeight, SA_Depth, gDepth, SA_Title, "Allegro", SA_ShowTitle, FALSE, SA_Quiet, TRUE, TAG_DONE);
	}

	/* Decide on what window taglist to use, depending on whether we are using our custom screen */
	/* or the Workbench screen.  Don't bother with any special handling for if the custom screen */
	/* couldn't be opened - just open on Workbench in that case */

	if (gMainScreen)
	{
		TagList = gCustomWindowTags;

		/* Setp the WA_CustomScreen tag data to point to the newly opened screen */

		gCustomWindowTags[CUSTOMSCREEN_TAG_IDCMP].ti_Data = (ULONG) gMainScreen;

		/* If we are running fullscreen, hide the hardware mouse pointer imagery */
		mouse_set_hardware_imagery(0, 0);
	}
	else
	{
		struct Screen *Screen;

		TagList = gWorkbenchWindowTags;

		/* Use the custom window title, if it has already been set.  Otherwise use a default.  Note */
		/* that custom window titles only work for Workbench windows */

// TODO: CAW - Should set this back to NULL?
		if (gMainWindowTitle)
		{
			gWorkbenchWindowTags[TAG_OFFSET_TITLE].ti_Data = (ULONG) gMainWindowTitle;
		}

		/* Lock the Workbench screen so that we can obtain its dimensions and centre */
		/* the window on it.  If this fails (extremely unlikely) then the window can just */
		/* sit at the top left of the Workbench screen */

		if ((Screen = LockPubScreen(NULL)) != NULL)
		{
			gWorkbenchWindowTags[TAG_OFFSET_LEFT].ti_Data = ((Screen->Width - gWidth) / 2);
			gWorkbenchWindowTags[TAG_OFFSET_TOP].ti_Data = ((Screen->Height - gHeight) / 2);

			UnlockPubScreen(NULL, Screen);
		}
	}

	/* Open the main window, using the appropriate taglist */

	if ((gMainWindow = OpenWindowTagList(NULL, TagList)) != NULL)
	{
		int is_direct = 1;

		/* Get the width and height of the client area */

		Width = gWidth;
		Height = gHeight;
		RetVal = 1;

		_rgb_r_shift_15 = 10;
		_rgb_g_shift_15 = 5;
		_rgb_b_shift_15 = 0;
		_rgb_r_shift_16 = 11;
		_rgb_g_shift_16 = 5;
		_rgb_b_shift_16 = 0;
		_rgb_r_shift_24 = 16;
		_rgb_g_shift_24 = 8;
		_rgb_b_shift_24 = 0;
		_rgb_a_shift_32 = 24;
		_rgb_r_shift_32 = 16;
		_rgb_g_shift_32 = 8;
		_rgb_b_shift_32 = 0;

		/* Screens that are in a different mode to that requested by the game will also need to be */
		/* emulated.  Windows that will have a BitMap that is not the same depth of the Workbench will */
		/* also need to be emulated and 8 bit screens or BitMaps are always emulated to avoid RGB CLUT */
		/* problems. */

		switch (GetCyberMapAttr(gMainWindow->RPort->BitMap, CYBRMATTR_PIXFMT))
		{
			case PIXFMT_RGB15PC:
			case PIXFMT_RGB16PC:
				is_direct = 0;
				break;

			case PIXFMT_BGR24:
				_rgb_b_shift_24 = 16;
				_rgb_g_shift_24 = 8;
				_rgb_r_shift_24 = 0;
				break;

			case PIXFMT_BGRA32:
				_rgb_b_shift_32 = 24;
				_rgb_g_shift_32 = 16;
				_rgb_r_shift_32 = 8;
				_rgb_a_shift_32 = 0;
				break;

			case PIXFMT_RGBA32:
				_rgb_r_shift_32 = 24;
				_rgb_g_shift_32 = 16;
				_rgb_b_shift_32 = 8;
				_rgb_a_shift_32 = 0;
				break;
		}

		if (GetBitMapAttr(gMainWindow->RPort->BitMap, BMA_DEPTH) != gDepth)
			is_direct = 0;

		gDirectDraw = is_direct;

		/* If an emulation bitmap is to be used, start the vertical retrace simulation */
		/* timer on which to draw it */

		if (is_direct == 0)
		{
			amithread_request_timeout(aAmiThread, REDRAW_TIMEOUT);
		}
	}

	/* If initialisation failed, free whatever resources have been allocated */

	if (!(RetVal))
	{
		if (gMainWindow)
		{
			CloseWindow(gMainWindow);
			gMainWindow = NULL;
		}

		if (gMainScreen)
		{
			CloseScreen(gMainScreen);
			gMainScreen = NULL;
		}
	}

	return(RetVal);
}

static void gfx_thread_func(struct AmiThread *aAmiThread)
{
	ULONG Index, Signal, ThreadSignal, TimerSignal, WindowSignal;
	struct IntuiMessage *IntuiMessage;

	/* Cache the signals on which we have to wait */

	ThreadSignal = (1 << aAmiThread->at_ThreadSignalBit);
	TimerSignal = (1 << aAmiThread->at_TimerMsgPort->mp_SigBit);
	WindowSignal = (1 << gMainWindow->UserPort->mp_SigBit);

	/* Loop around and process all signals until we are told to shut down! */

	for ( ; ; )
	{
		Signal = Wait(ThreadSignal | TimerSignal | WindowSignal);

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

			while ((IntuiMessage = (struct IntuiMessage *) GetMsg(gMainWindow->UserPort)) != NULL)
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

						ObtainSemaphore(&gDirtyAreaSemaphore);

						/* Mark the entire screen as dirty and redraw it */

						gSafeDirtyArea.da_TopLine = 0;
						gSafeDirtyArea.da_BottomLine = (gBitmap->h - 1);

						/* And release the dirty area signal semaphore so that other threads can access gSafeDirtyArea */

						ReleaseSemaphore(&gDirtyAreaSemaphore);

						/* And refresh the Allegro window on Workbench */

						draw();

						break;
					}
				}

				/* And reply to the message */

				ReplyMsg((struct Message *) IntuiMessage);
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

	CloseWindow(gMainWindow);
	gMainWindow = NULL;

	/* Close the main screen, but only if it was opened successfully */

	if (gMainScreen)
	{
		CloseScreen(gMainScreen);
		gMainScreen = NULL;
	}
}

static unsigned char *read_bank(BITMAP *aBitmap, int aLine)
{
	unsigned char *RetVal;

	/* If the target bitmap is on the screen itself or has been allocated in video memory for */
	/* flipping, call the video bitmap locking function which can handle both types */

	if ((aBitmap->id == BMP_ID_SYSTEM) || (aBitmap->id == BMP_ID_VIDEO))
	{
		/* Get a ptr to the VideoBitmap structure, stored in the user data part of the BITMAP structure */
		/* and find out whether the BitMap is locked into memory yet */

		struct VideoBitmap *VideoBitmap = aBitmap->extra;
		APTR Lock = VideoBitmap->vb_Lock;

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

		struct VideoBitmap *VideoBitmap = aBitmap->extra;
		APTR Lock = VideoBitmap->vb_Lock;

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
					UnLockBitMap(VideoBitmap->vb_Lock);
				}
				else
				{
					/* Otherwise if it is a screen memory bitmap then we need special checks.  If we are */
					/* accessing the screen directly, just unlock the screen bitmap */

					/* Otherwise if an emulation BitMap is being used but *not* an emulation buffer, */
					/* unlock it */

					if (gDirectDraw)
					{
						UnLockBitMap(VideoBitmap->vb_Lock);
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

				ReleaseSemaphore(&gDirtyAreaSemaphore);
			}
		}
	}
}

static unsigned char *video_read_write_bank(BITMAP *aBitmap, int aLine)
{
	int BytesPerPixel;
	unsigned char *RetVal = NULL;
	struct BitMap *BitMap;

	/* Get a ptr to the VideoBitmap structure, stored in the user data part of the BITMAP structure */

	struct VideoBitmap *VideoBitmap = aBitmap->extra;

	/* If the BitMap has already been locked into memory, calculate a ptr to the requested line */

	if (VideoBitmap->vb_Lock != 0)
	{
		/* If the bitmap is the screen and an emulation buffer is being used, return a ptr to */
		/* memory in that buffer */

		if (gDirectDraw == 0)
		{
			RetVal = aBitmap->line[aLine];
		}

		/* Otherwise return a ptr to the "real" BitMap */
		
		else
		{
			/* Calculate a ptr to the the start of the line requested, taking into account the position */
			/* of the BitMap on the screen in direct screen access mode */

			RetVal = (((unsigned char *) VideoBitmap->vb_BaseAddress) + (aLine * VideoBitmap->vb_BytesPerRow));
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

			if (gDirectDraw)
			{
				BitMap = gMainWindow->RPort->BitMap;
			}
		}

		/* Lock the dirty area signal semaphore for the duration of the BitMap access, so they rendering */
		/* thread cannot get at the BitMap */

		ObtainSemaphore(&gDirtyAreaSemaphore);

		/* If a BitMap was selected for locking, go ahead and lock it now */

		if (BitMap)
		{
			if ((VideoBitmap->vb_Lock = LockBitMapTags(BitMap,
				LBMI_BYTESPERPIX, &BytesPerPixel,
				LBMI_BYTESPERROW, &VideoBitmap->vb_BytesPerRow,
				LBMI_BASEADDRESS, &VideoBitmap->vb_BaseAddress, TAG_DONE)))
			{
				/* The Y position will be the top of the window + the height of the window border */
				/* and the X position will be the left of the window + the width of the window border */

				VideoBitmap->vb_BitMapOffset = (((gMainWindow->TopEdge + gMainWindow->BorderTop) * VideoBitmap->vb_BytesPerRow) +
					((gMainWindow->LeftEdge + gMainWindow->BorderLeft) * BytesPerPixel));

				/* Calculate a ptr to the the start of the line requested, taking into account the position */
				/* of the BitMap on the screen in direct screen access mode */

				RetVal = (((unsigned char *) VideoBitmap->vb_BaseAddress) + (aLine * VideoBitmap->vb_BytesPerRow));
				RetVal += VideoBitmap->vb_BitMapOffset;
			}
		}

		/* Otherwise just return a ptr to the emulation buffer */

		else
		{
			VideoBitmap->vb_Lock = (APTR)1;
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

			ReleaseSemaphore(&gDirtyAreaSemaphore);
		}
	}

	return(RetVal);
}

static BITMAP *gfx_init(int aWidth, int aHeight, int aVirtualWidth, int aVirtualHeight, int aDepth, int aFullScreen)
{
	int Index, Ok, Width, Height;
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
	#if !defined(__MORPHOS__)
	signal(SIGINT, SIG_IGN);
	#endif

	/* Indicate that it is safe to flip screens */

	gSafeToFlip = 1;
	gFullScreen = aFullScreen;

	/* See if there is a mode that matches the requested width, height and depth. This will */
	/* be used for creating the BitMap that will be used for getting the Allegro bitmap onto */
	/* the screen */

	if ((convert_depth(aDepth)) != NULL)
	{
		if (aFullScreen)
		{
			Width = aWidth;
			Height = aHeight;
		}

		{
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
						int gBPP = 1;

						/* Save details about the requested resolution and depth for l8r use */

						gWidth = aWidth;
						gHeight = aHeight;
						gDepth = aDepth;

						switch (aDepth)
						{
							case 8:
								gBPP = 1;
								break;

							case 15:
							case 16:
								gBPP = 2;
								break;

							case 24:
								gBPP = 3;
								break;

							case 32:
								gBPP = 4;
								break;
						}

						Width = aWidth;
						Height = aHeight;

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
						InitSemaphore(&gDirtyAreaSemaphore);

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
	if (gMainScreen)
	{
		int idx;

		for (idx = aFrom; idx <= aTo; idx++)
		{
			ULONG r = aRGB->r << 2, g = aRGB->g << 2, b = aRGB->b << 2;

			r |= r << 24 | r << 16 | r << 8;
			g |= g << 24 | g << 16 | g << 8;
			b |= b << 24 | b << 16 | b << 8;

			SetRGB32(&gMainScreen->ViewPort, idx, r, g, b);
			aRGB++;
		}
	}
	else
	{
		int idx;

		for (idx = aFrom; idx <= aTo; idx++)
		{
			gPalette[idx] = aRGB->r << 18 | aRGB->g << 10 | aRGB->b << 2;
			aRGB++;
		}

		/* Mark the entire screen as dirty and redraw it, to show the effects of the fade routine */

		gDirtyArea.da_TopLine = 0;
		gDirtyArea.da_BottomLine = (gBitmap->h - 1);
		unwrite_bank(gBitmap);
	}
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
			if ((gDBufInfo = AllocDBufInfo(&gMainScreen->ViewPort)) != NULL)
			{
				/* Create MsgPorts that can be used for checking when it is safe to draw to the just */
				/* flipped-out BitMap and when it is safe to perform the next page flip */

				gDBufInfo->dbi_SafeMessage.mn_ReplyPort	= gSafeMsgPort = CreateMsgPort();
				gDBufInfo->dbi_DispMessage.mn_ReplyPort	= gDispMsgPort = CreateMsgPort();
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
							if ((VideoBitmap->vb_BitMap = AllocBitMap(aWidth, aHeight, gDepth, BMF_DISPLAYABLE | BMF_MINPLANES, gMainWindow->RPort->BitMap)) != NULL)
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

								/* We will normally return a ptr to video memory when write_bank() is called. However, */
								/* it is possible for locking of the BitMap to fail, an client code assumes that the */
								/* write_bank() function cannot fail. In the case of locking failing, we will */
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

			FreeBitMap(VideoBitmap->vb_BitMap);

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
				while(GetMsg(gDispMsgPort)) { }

				DeleteMsgPort(gDispMsgPort);
				gDispMsgPort = NULL;
			}

			/* If the safe to draw message port was allocated, drain it of messages and free it */

			if (gSafeMsgPort)
			{
				while(GetMsg(gSafeMsgPort)) { }

				DeleteMsgPort(gSafeMsgPort);
				gSafeMsgPort = NULL;
			}

			/* And free the DBufInfo structure itself */

			FreeDBufInfo(gDBufInfo);
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
		while (!(GetMsg(gDispMsgPort)))
		{
			Wait(1 << gDispMsgPort->mp_SigBit);
		}
	}

	/* Flip the BitMap and indicate that it has been done */

	ChangeVPBitMap(&gMainScreen->ViewPort, VideoBitmap->vb_BitMap, gDBufInfo);
	gSafeToFlip	= 0;

	/* And wait until it is safe to draw to the old BitMap */

	while (!(GetMsg(gSafeMsgPort)))
	{
		Wait(1 << gSafeMsgPort->mp_SigBit);
	}

	/* Always return success */

	return(0);
}

GFX_DRIVER gfx_amiga_fullscreen =
{
/*                      id */ GFX_AMIGA_FULLSCREEN,
/*                    name */ empty_string,
/*                    desc */ empty_string,
/*              ascii_name */ "amigagfxfullscreen",
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
/*              ascii_name */ "amigagfxwindowed",
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
