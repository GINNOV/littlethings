/*
 *  video_morphos.cpp - Video/graphics emulation, MorphOS specific stuff
 *
 *  Basilisk II (C) 1997-2001 Christian Bauer
 *                  2005-2006 Ilkka Lehtoranta
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <intuition/intuition.h>
#include <graphics/rastport.h>
#include <graphics/gfx.h>
#include <cybergraphx/cgxvideo.h>
#include <cybergraphx/cybergraphics.h>
#include <dos/dostags.h>
#include <devices/timer.h>
#include <libraries/iffparse.h>

#include <proto/alib.h>
#include <proto/cgxvideo.h>
#include <proto/cybergraphics.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/muimaster.h>

#include "sysdeps.h"
#include "cpu_emulation.h"
#include "main.h"
#include "adb.h"
#include "prefs.h"
#include "user_strings.h"
#include "video.h"

#define DEBUG 0
#include "debug.h"
#include "guithread.h"
#include "mui.h"

#define USE_OVERLAY 0

// Global variables
static bool is_classic, is_fullscreen, is_8bitgfx, is_real8bit;
static int display_width, display_height;
static ULONG palette[256];
#if USE_OVERLAY
static UWORD palette_ov[256];
#endif

struct Screen *MainScreen;
ULONG quitflag = 0;

extern struct MUI_CustomClass	*CL_Display;
extern Object *app;

// MorphOS -> Mac raw keycode translation table
// Pause/Break is mapped to Power
// PrtSrc/SysRq is mapped to Menu
// Wheel Up/Down is Cursor Up/Down

static const uint8 keycode2mac[0x80] =
{
	0x0a, 0x12, 0x13, 0x14, 0x15, 0x17, 0x16, 0x1a,	//   `   1   2   3   4   5   6   7
	0x1c, 0x19, 0x1d, 0x1b, 0x18, 0x2a, 0xff, 0x52,	//   8   9   0   -   =   \ inv   0
	0x0c, 0x0d, 0x0e, 0x0f, 0x11, 0x10, 0x20, 0x22,	//   Q   W   E   R   T   Y   U   I
	0x1f, 0x23, 0x21, 0x1e, 0xff, 0x53, 0x54, 0x55,	//   O   P   [   ] inv   1   2   3
	0x00, 0x01, 0x02, 0x03, 0x05, 0x04, 0x26, 0x28,	//   A   S   D   F   G   H   J   K
	0x25, 0x29, 0x27, 0x2a, 0xff, 0x56, 0x57, 0x58,	//   L   ;   '   # inv   4   5   6
	0x32, 0x06, 0x07, 0x08, 0x09, 0x0b, 0x2d, 0x2e,	//   <   Z   X   C   V   B   N   M
	0x2b, 0x2f, 0x2c, 0xff, 0x41, 0x59, 0x5b, 0x5c,	//   ,   .   / inv   .   7   8   9
	0x31, 0x33, 0x30, 0x4c, 0x24, 0x35, 0x75, 0x72,	// SPC BSP TAB ENT RET ESC DEL INS
	0x74, 0x79, 0x4e, 0x67, 0x3e, 0x3d, 0x3c, 0x3b,	// PUP PDN   - F11 CUP CDN CRT CLF
	0x7a, 0x78, 0x63, 0x76, 0x60, 0x61, 0x62, 0x64,	//  F1  F2  F3  F4  F5  F6  F7  F8
	0x65, 0x6d, 0x47, 0x51, 0x4b, 0x43, 0x45, 0x72,	//  F9 F10   (   )   /   *   + HLP
	0x38, 0x38, 0x39, 0x36, 0x3a, 0x3a, 0x37, 0x37,	// SHL SHR CAP CTL ALL ALR AML AMR
	0xff, 0xff, 0xff, 0xff, 0x32, 0xff, 0x7f, 0x6f,	// inv inv inv inv MNU inv POW F12
	0x73, 0x77, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,	// HOM END inv inv inv inv inv inv
	0xff, 0xff, 0x3e, 0x3d, 0xff, 0xff, 0xff, 0xff	// inv inv CUP CDN inv inv inv inv
};


/**********************************************************************
	Display class
**********************************************************************/

static ULONG mNew(struct IClass *cl, Object *obj, Msg msg)
{
	obj = (Object *)DoSuperMethodA(cl, obj, msg);

	if (obj)
	{
		struct Display_Data *data = (struct Display_Data *)INST_DATA(cl, obj);
		ULONG	error	= 1;

		data->current_pointer	= (UWORD *)-1;
		data->width		= display_width;
		data->height	= display_height;

		data->frameskip = PrefsFindInt32("frameskip") + 1;

		if (data->frameskip > 10)
			data->frameskip = 10;

		if (is_classic)
		{
			// classic display size is 512 * 342

			data->pixelarray = AllocTaskPooled((512 * (342 + 2)) / 8);

			if (data->pixelarray)
			{
				VideoMonitor.bytes_per_row		= 512 / 8;
			}
		}
		else
		{
			struct Screen *screen;
			ULONG	pixfmt, bpr;

			screen	= MainScreen;
			pixfmt	= 0;

			if (screen)
			{
				pixfmt	= GetCyberMapAttr(screen->RastPort.BitMap, CYBRMATTR_PIXFMT);
			}

			if (is_8bitgfx)
			{
				if (screen && pixfmt == PIXFMT_LUT8)
				{
					data->drawmode	= DRAW_CHUNKYPIX;
					is_real8bit	= true;
				}
				else
				{
					data->drawmode	= DRAW_LUT_8BIT;			// WriteLUTPixelArray()
				}
			}
			else
			{
				data->drawmode	= DRAW_PIXELARRAY;		// WritePixelArray()
			}

			bpr = ((data->width * (data->drawmode == DRAW_LUT_8BIT ? 1 : 4)) + 32) & ~0x1f;

			VideoMonitor.bytes_per_row	= bpr;
			data->bytes_per_row = bpr;
			data->pix_array_size = bpr * (data->height + 2);
			data->pixelarray	= AllocMemAligned(data->pix_array_size, MEMF_CLEAR, 32, 0);
		}

		VideoMonitor.mac_frame_base	= (uint32)Host2MacAddr((uint8 *)data->pixelarray);

		data->timerport	= CreateMsgPort();
		data->timer_io		= (struct timerequest *)CreateIORequest(data->timerport, sizeof(struct timerequest));

		if (data->timer_io)
		{
			if (OpenDevice("timer.device", UNIT_VBLANK, (struct IORequest *)data->timer_io, 0) == 0)
			{
				data->ihnode.ihn_Object		= obj;
				data->ihnode.ihn_Signals	= 1 << data->timerport->mp_SigBit;
				data->ihnode.ihn_Method		= MM_Display_Update;
				data->ehnode.ehn_Object		= obj;
				data->ehnode.ehn_Class		= cl;
				data->ehnode.ehn_Events		= IDCMP_MOUSEBUTTONS | IDCMP_MOUSEMOVE | IDCMP_RAWKEY;
				data->timer_ok	= 1;
				error	= 0;
			}
		}

		if (error || !data->pixelarray)
		{
			CoerceMethod(cl, obj, OM_DISPOSE);
			obj = NULL;
		}
	}

	return (ULONG)obj;
}

static VOID mDispose(struct Display_Data *data)
{
	if (data->pixelarray)
	{
		FreeMem(data->pixelarray, data->pix_array_size);
	}

	if (data->timer_ok)
	{
		CloseDevice((struct IORequest *)data->timer_io);
	}

	DeleteIORequest(data->timer_io);
	DeleteMsgPort(data->timerport);

}

static ULONG mAskMinMax(struct IClass *cl, Object *obj, Msg msg, struct Display_Data *data)
{
	struct MUI_MinMax *mmm;

	DoSuperMethodA(cl, obj, msg);

	mmm = ((struct MUIP_AskMinMax *)msg)->MinMaxInfo;

	mmm->MinWidth	= data->width;
	mmm->MinHeight	= data->height;
	mmm->DefWidth	= data->width;
	mmm->DefHeight	= data->height;
	#if USE_OVERLAY
	mmm->MaxWidth	= !is_fullscreen ? MUI_MAXMAX : data->width;
	mmm->MaxHeight	= !is_fullscreen ? MUI_MAXMAX : data->height;
	#else
	mmm->MaxWidth	= data->width;
	mmm->MaxHeight	= data->height;
	#endif

	return 0;
}

static VOID StartTimer(struct Display_Data *data)
{
	data->timer_io->tr_node.io_Command	= TR_ADDREQUEST;
	data->timer_io->tr_time.tv_secs		= 0;
	data->timer_io->tr_time.tv_micro		= 16667 * data->frameskip;
	SendIO((struct IORequest *)data->timer_io);
}

static ULONG mShow(struct IClass *cl, Object *obj, Msg msg, struct Display_Data *data)
{
	ULONG	rc = DoSuperMethodA(cl, obj, msg);

	if (rc)
	{
		#if USE_OVERLAY
		ULONG	mwidth, mheight;

		mwidth	= _mwidth(obj);
		mheight	= _mheight(obj);
		#endif

		if (MainScreen)
		{
			STATIC CONST UWORD ptr[] = { 0, 0, 0, 0 };
			SetPointer(_window(obj), (UWORD *)&ptr, 0, 0, 0, 0);	// Hide mouse pointer
		}
		#if USE_OVERLAY
		else if (data->drawmode == DRAW_LUT_8BIT)
		{
			struct Screen *screen = _screen(obj);

			data->VLayer	= CreateVLayerHandleTags(screen,
				VOA_SrcType, SRCFMT_RGB16,
				VOA_SrcWidth, data->width > mwidth ? mwidth : data->width,
				VOA_SrcHeight, data->height > mheight ? mheight : data->height,
				VOA_UseColorKey, TRUE,
				VOA_UseBackfill, TRUE,
			TAG_DONE);

			if (data->VLayer)
			{
				struct Window	*window	= _window(obj);
				ULONG	mleft, mtop;

				data->parent	= (Object *)getv(obj, MUIA_Parent);

				mleft		= _mleft(obj);
				mtop		= _mtop(obj);

				if (AttachVLayerTags((struct VLayerHandle *)data->VLayer, window,
					VOA_TopIndent, mtop - window->BorderTop,
					VOA_LeftIndent, mleft - window->BorderLeft,
					VOA_RightIndent, 0,
					VOA_BottomIndent, 0,
				TAG_DONE))
				{
					DeleteVLayerHandle((struct VLayerHandle *)data->VLayer);
					data->VLayer	= NULL;
				}
			}
		}
		#endif

		// Start 60Hz timer for window refresh
		DoMethod(_app(obj), MUIM_Application_AddInputHandler, &data->ihnode);
		DoMethod(_win(obj), MUIM_Window_AddEventHandler, &data->ehnode);
		StartTimer(data);
	}

	return rc;
}

static VOID mHide(Object *obj, struct Display_Data *data)
{
	#if USE_OVERLAY
	if (data->VLayer)
	{
		DetachVLayer((struct VLayerHandle *)data->VLayer);
		DeleteVLayerHandle((struct VLayerHandle *)data->VLayer);
		data->VLayer	= NULL;
	}
	#endif

	DoMethod(_app(obj), MUIM_Application_RemInputHandler, &data->ihnode);
	DoMethod(_win(obj), MUIM_Window_RemEventHandler, &data->ehnode);
	AbortIO((struct IORequest *)data->timer_io);
	WaitIO((struct IORequest *)data->timer_io);
}

static ULONG mHandleEvent(Object *obj, Msg msg, struct Display_Data *data)
{
	struct IntuiMessage *imsg = ((struct MUIP_HandleEvent *)msg)->imsg;
	ULONG	rc	= 0;

	if (imsg)
	{
		ULONG	code = imsg->Code;

		switch (imsg->Class)
		{
			case IDCMP_MOUSEMOVE:
			{
				struct Window *win = _window(obj);
				LONG	mx, my;

				rc	= MUI_EventHandlerRC_Eat;
				mx	= imsg->MouseX;
				my	= imsg->MouseY;

				ADBMouseMoved(mx - win->BorderLeft, my - win->BorderTop);

				if (mx < win->BorderLeft || my < win->BorderTop || mx >= (LONG)(win->Width - win->BorderRight) || my >= (LONG)(win->Height - win->BorderBottom))
				{
					if (data->current_pointer)
					{
						ClearPointer(win);
						data->current_pointer = NULL;
					}
				}
				else
				{
					if (data->current_pointer != data->null_pointer)
					{
						// Hide mouse pointer inside window
						SetPointer(win, data->null_pointer, 1, 16, 0, 0);
						data->current_pointer = data->null_pointer;
					}
				}
			}
			break;

			case IDCMP_MOUSEBUTTONS:
				if (code == SELECTDOWN)
					ADBMouseDown(0);
				else if (code == SELECTUP)
					ADBMouseUp(0);
				else if (code == MENUDOWN)
					ADBMouseDown(1);
				else if (code == MENUUP)
					ADBMouseUp(1);
				else if (code == MIDDLEDOWN)
					ADBMouseDown(2);
				else if (code == MIDDLEUP)
					ADBMouseUp(2);
				break;

			case IDCMP_RAWKEY:
			{
				ULONG	qualifier = imsg->Qualifier;

				if (qualifier & IEQUALIFIER_REPEAT)	// Keyboard repeat is done by MacOS
					break;
				if ((qualifier & (IEQUALIFIER_LALT | IEQUALIFIER_LSHIFT | IEQUALIFIER_CONTROL)) == (IEQUALIFIER_LALT | IEQUALIFIER_LSHIFT | IEQUALIFIER_CONTROL) && code == 0x5f)
				{
					SetInterruptFlag(INTFLAG_NMI);
					TriggerInterrupt();
					break;
				}

				if (code & IECODE_UP_PREFIX)
					ADBKeyUp(keycode2mac[code & 0x7f]);
				else
					ADBKeyDown(keycode2mac[code & 0x7f]);
			}
			break;
		}
	}

	return rc;
}

static ULONG mUpdate(Object *obj, struct Display_Data *data)
{
	if (GetMsg(data->timerport))
	{
		// restart timer after screen update

		MUI_Redraw(obj, MADF_DRAWOBJECT);
		StartTimer(data);
	}

	return 0;
}

/**********************************************************************
	mRender16
**********************************************************************/

#if USE_OVERLAY
static VOID mRender16(CONST UWORD *table, CONST UBYTE *chunky, UWORD *buf, ULONG offset, ULONG width, ULONG height)
{
	ULONG	i;

	for (i = 0; i < height; i++)
	{
		ULONG	j;
		UWORD	*tmp;

		tmp		= buf;

		for (j = 0; j < width; j++)
			*tmp++	= table[ chunky[ j ] ];

		chunky	+= width;
		buf		+= offset / 2;
	}
}
#endif

static ULONG mDraw(struct IClass *cl, Object *obj, Msg msg, struct Display_Data *data)
{
	struct RastPort	*rp;
	ULONG	mleft, mtop, mwidth, mheight, chunky = 1;

	DoSuperMethodA(cl, obj, msg);

	mleft		= _mleft(obj);
	mtop		= _mtop(obj);
	mwidth	= _mwidth(obj);
	mheight	= _mheight(obj);
	rp			= _rp(obj);

	switch (data->drawmode)
	{
		case DRAW_CLASSIC:
			BltTemplate((UBYTE *)data->pixelarray, 0, 512/8, rp, mleft, mtop, mwidth, mheight);
			break;

		case DRAW_LUT_8BIT:
			#if USE_OVERLAY
			if (data->VLayer)
			{
				ULONG	left, top;
				UWORD	*srcdata;

				left		= getv(data->parent, MUIA_Virtgroup_Left);
				top		= getv(data->parent, MUIA_Virtgroup_Left);
				srcdata	= (UWORD *)GetVLayerAttr((struct VLayerHandle *)data->VLayer, VOA_BaseAddress);
				mRender16((const UWORD *)&palette_ov, (CONST UBYTE *)data->pixelarray + left + top * data->width, srcdata, data->width * sizeof(UWORD), data->width > mwidth ? mwidth : data->width, data->height > mheight ? mheight : data->height);
				UnlockVLayer((struct VLayerHandle *)data->VLayer);
			}
			else
			#endif
			{
				WriteLUTPixelArray(data->pixelarray, 0, 0, data->bytes_per_row, rp, &palette, mleft, mtop, mwidth, mheight, CTABFMT_XRGB8);
			}
			break;

		case DRAW_PIXELARRAY:
			chunky = 0;
		case DRAW_CHUNKYPIX:
			WritePixelArray(data->pixelarray, 0, 0, data->bytes_per_row, rp, mleft, mtop, mwidth, mheight, chunky ? RECTFMT_LUT8 : RECTFMT_ARGB);
			break;
	}

	return 0;
}

static ULONG DisplayDispatcher(void)
{
	struct Display_Data *data;
	struct IClass	*cl;
	Object	*obj;
	Msg	msg;

	cl		= (struct IClass *)REG_A0;
	msg	= (Msg)REG_A1;
	obj	= (Object *)REG_A2;
	data	= (struct Display_Data *)INST_DATA(cl, obj);

	switch (msg->MethodID)
	{
		case OM_NEW					: return mNew				(cl, obj, msg);
		case OM_DISPOSE			:			mDispose			(data); break;
		case MUIM_AskMinMax		: return mAskMinMax		(cl, obj, msg, data);
		case MUIM_Show				: return mShow				(cl, obj, msg, data);
		case MUIM_HandleEvent	: return mHandleEvent	(obj, msg, data);
		case MUIM_Hide				:			mHide				(obj, data); break;
		case MUIM_Draw				: return mDraw				(cl, obj, msg, data);
		case MM_Display_Update	: return mUpdate			(obj, data);
	}

	return DoSuperMethodA(cl, obj, msg);
}

struct EmulLibEntry DisplayTrap = {TRAP_LIB, 0, (void (*)())&DisplayDispatcher };

/*
 *  Initialization
 */


bool VideoInit(bool classic)
{
	int width, height;

	is_classic 		= classic;
	is_fullscreen	= PrefsFindBool("fullscreen");
	is_8bitgfx		= PrefsFindBool("8bitgfx");

	width		= 512;  // classic display size
	height	= 342;

	if (!classic)
	{
		const char *mode_str;

		mode_str = PrefsFindString("screen");
		height	= 384;

		if (mode_str)
		{
			sscanf(mode_str, "win/%d/%d", &width, &height);
		}
	}

	if (is_fullscreen)
	{
		ULONG	modeid;

		modeid	= BestCModeIDTags(CYBRBIDTG_Depth, is_8bitgfx ? 8 : 32, CYBRBIDTG_NominalWidth, width, CYBRBIDTG_NominalHeight, height, TAG_DONE);
		width		= GetCyberIDAttr(CYBRIDATTR_WIDTH, modeid);
		height	= GetCyberIDAttr(CYBRIDATTR_HEIGHT, modeid);

		MainScreen	= OpenScreenTags(NULL,
				SA_DisplayID, modeid,
				SA_ShowTitle, FALSE,
				SA_Quiet, TRUE,
				SA_AutoScroll, TRUE,
				TAG_DONE
			);

		if (MainScreen == NULL)
		{
			is_fullscreen	= false;
		}
	}

	display_width	= width;
	display_height	= height;

	VideoMonitor.x		= width;
	VideoMonitor.y		= height;
	VideoMonitor.mode	= classic ? VMODE_1BIT : (is_8bitgfx ? VMODE_8BIT : VMODE_32BIT);

//	ADBSetRelMouseMode(is_fullscreen ? true : false);
	ADBSetRelMouseMode(false);

	return SendGUICmd(GUICMD_InitVideo);
}

bool RunVideo(void)
{
	static CONST struct TagItem ScreenTags[] =
	{
		{ MUIA_Window_Borderless , TRUE  },
		{ MUIA_Window_DepthGadget, FALSE },
		{ MUIA_Window_DragBar    , FALSE },
		{ MUIA_Window_SizeGadget , FALSE },
		{ MUIA_Window_LeftEdge   , 0     },
		{ MUIA_Window_TopEdge    , 0     },
		{ MUIA_Window_CloseGadget, FALSE },
		{ TAG_DONE               , 0     }
	};
	static CONST struct TagItem WinTags[] =
	{
		{ MUIA_Window_ID, MAKE_ID('M','A','I','N') },
		{ MUIA_Window_UseBottomBorderScroller, TRUE },
		{ MUIA_Window_UseRightBorderScroller, TRUE },
		{ TAG_DONE, 0 }
	};

	Object *win, *display;
	bool rc = false;

	display	= (Object *)NewObject(CL_Display->mcc_Class, NULL, MUIA_FillArea, FALSE, TAG_DONE);

	if (!is_fullscreen)
	{
		Object *temp;

		temp = ScrollgroupObject,
			MUIA_Scrollgroup_UseWinBorder, TRUE,
			MUIA_Scrollgroup_Contents, VirtgroupObject,
				Child, display,
			End,
		End;

		display	= temp;
	}

	win = WindowObject,
		is_fullscreen ? MUIA_Window_ScreenTitle : MUIA_Window_Title, (ULONG)GetString(STR_WINDOW_TITLE),
		is_fullscreen ? MUIA_Window_Width : TAG_IGNORE, display_width,
		is_fullscreen ? MUIA_Window_Height : TAG_IGNORE, display_height,
		is_fullscreen ? MUIA_Window_Screen : TAG_IGNORE, MainScreen,
		MUIA_Window_DisableKeys, 0xffffffff,
		WindowContents, VGroup,
			MUIA_InnerBottom, 0,
			MUIA_InnerLeft, 0,
			MUIA_InnerRight, 0,
			MUIA_InnerTop, 0,
			Child, display,
		End,
	TAG_MORE, is_fullscreen ? ScreenTags : WinTags);

	if (win)
	{
		DoMethod(app, OM_ADDMEMBER, win);
		DoMethod(win, MUIM_Notify, MUIA_Window_CloseRequest, TRUE, MUIV_Notify_Self, 3, MUIM_WriteLong, 1, &quitflag);
		SetAttrs(win, MUIA_Window_Open, TRUE, TAG_DONE);
		rc	= true;
	}

	return rc;
}


/*
 *  Deinitialization
 */

void VideoExit(void)
{
}


/*
 *  Set palette
 */

void video_set_palette(uint8 *pal)
{
	if (is_real8bit)
	{
		// We have 8bit custom screen
		// Convert palette to 32 bits
		ULONG table[2 + 256 * 3];
		table[0] = 256 << 16;
		table[256 * 3 + 1] = 0;

		for (int i = 0; i < 256; i++)
		{
			table[i*3+1] = pal[i*3] << 24;
			table[i*3+2] = pal[i*3+1] << 24;
			table[i*3+3] = pal[i*3+2] << 24;
		}

		// And load it
		LoadRGB32(&MainScreen->ViewPort, table);
	}

	for (int i = 0; i < 256; i++)
	{
		ULONG	r, g, b;

		r	= pal[i*3];
		g	= pal[i*3+1];
		b	= pal[i*3+2];

		palette[i]		= (r << 16) | (g << 8) | b;
		#if USE_OVERLAY
		palette_ov[i]	= ((b & 0xf8) << 5) | ((g & 0xe0) >> 5) | ((g & 0x1c) << 11) | (r & 0xf8);
		#endif
	}
}


/*
 *  Video message handling (not neccessary under MorphOS, handled by periodic_func())
 */

void VideoInterrupt(void)
{
	static int counter = 60 * 5;

	counter--;

	if (quitflag || counter <= 0)
	{
		counter = 60 * 5;

		if (quitflag || SetSignal(0, SIGBREAKF_CTRL_C) & SIGBREAKF_CTRL_C)
		{
			QuitEmulator();
		}
	}
}
