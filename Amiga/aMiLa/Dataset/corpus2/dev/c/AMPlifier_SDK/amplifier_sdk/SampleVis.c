/*
** AMPlifier - example visualization plugin
**
** $VER: SampleVis.c  1999 Thorsten Hansen
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <graphics/gfxbase.h>
#include <wbstartup.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/intuition_protos.h>
#include <clib/utility_protos.h>
#include <clib/graphics_protos.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <libraries/amplifierplugin.h>
#include <clib/amplifierplugin_protos.h>
#include <pragma/amplifierplugin_lib.h>			// Maxon, StormC
//#include <pragmas/amplifierplugin_pragmas.h>	// SAS,...


#define VIS_WIDTH		256
#define VIS_HEIGHT	128


struct Library *UtilityBase = NULL;
struct Library *IntuitionBase = NULL;
struct Library *GfxBase = NULL;

struct Library *AMPlifierPluginBase = NULL;

BOOL OpenLibs()
{
	UtilityBase = OpenLibrary("utility.library", 39);
	IntuitionBase = OpenLibrary("intuition.library", 39);
	GfxBase = OpenLibrary("graphics.library", 39);

	return (ULONG) (UtilityBase && IntuitionBase && GfxBase);
}

void CloseLibs()
{
	if (UtilityBase)
		CloseLibrary(UtilityBase);
	if (IntuitionBase)
		CloseLibrary(IntuitionBase);
	if (GfxBase)
		CloseLibrary(GfxBase);
}

//*************************************

struct Hook renderhook = { NULL, NULL, NULL, NULL };
struct Window *win = NULL;
UBYTE buffer[VIS_WIDTH*VIS_HEIGHT];
UWORD max[2][128];
UBYTE color[64];


struct PluginCtrl * PI_AddModule(Tag tag1,...)
{
	return PI_AddModuleA((struct TagItem *) &tag1);
}

void Req(char *text, char *gadget)
{
    struct EasyStruct es =
    { sizeof(struct EasyStruct), 0 , "VisPlugin", text , gadget };
    EasyRequestArgs(NULL, &es, NULL, NULL);
}


BOOL PluginStart()
{
	BOOL result = FALSE;
	int i;

	win = OpenWindowTags(NULL,
		WA_Left, 50,
		WA_Top, 50,
		WA_InnerWidth, VIS_WIDTH,
		WA_InnerHeight, VIS_HEIGHT,
		WA_Title, "AMPlifier Sample Visualization",
		WA_ScreenTitle, "AMPlifier Sample Visualization  written by Thorsten Hansen",
		WA_DragBar, TRUE,
		WA_DepthGadget, TRUE,
		WA_CloseGadget, TRUE,
		WA_IDCMP, CLOSEWINDOW,
		TAG_END);
	if (win)
	{
		for (i = 0; i < 64; i++)
		{
			color[i] = ObtainBestPen(win->WScreen->ViewPort.ColorMap,
				0xdd000000,
				i * 0x4000000,
				0x00000000,
				TAG_END);
		}

		result = TRUE;
	}

	return result;
}

void PluginEnd()
{
	int i;

	if (win)
	{
		for (i = 0; i < 64; i++)
			ReleasePen(win->WScreen->ViewPort.ColorMap, color[i]);

		CloseWindow(win);
		win = NULL;
	}
}

/*
 * RenderFunc - called from AMPlifier with new pcm/spectrum data
 *
 * struct RenderData have the following data:
 *   Channels    - number of channels
 *   Waveform[2] - Arrays with pcm data (512 entrys with signed WORDs)
 *   Spectrum[2] - Arrays with spectrum data (256 entrys with a range 0-255)
 */
long RenderFunc(register __a0 struct Hook *hook, register __a2 struct PluginCtrl *pctrl, register __a1 struct RenderData *rd)
{
	struct RastPort *rp = win->RPort;
	int ch, x, y, yoffs, yoffs2, xoffs, c;
	int left = win->BorderLeft;
	int top = win->BorderTop;

	// clear buffer
	memset(buffer, 1, VIS_WIDTH*VIS_HEIGHT);

	// render oscilloscope
	yoffs = VIS_HEIGHT/4;
	for (ch = 0; ch < rd->Channels; ch++)
	{
		for (x = 0; x < 256; x++)
		{
			y = ((rd->waveform[ch][x<<1]>>10) + yoffs) << 8;
			buffer[x+y] = 2;
		}
		yoffs += VIS_HEIGHT/2;
	}

	// render spectrum analyzer
	xoffs = 0;
	for (ch = 0; ch < rd->Channels; ch++)
	{
		for (x = 0; x < 64; x++)
		{
			UWORD s;
			if (ch == 0)
				s = rd->spectrum[ch][(63 - x)<<2] >> 2;
			else
				s = rd->spectrum[ch][x<<2] >> 2;

			if (s >= max[ch][x])
				max[ch][x] = s;
			else if (max[ch][x] > 4)
				max[ch][x] -= 4;
			else
				max[ch][x] = 0;

			y = 64 - max[ch][x];
			yoffs = xoffs + (x<<1) + (y<<8);
			yoffs2 = xoffs + (x<<1) + ((127-y)<<8);
			c = 0;
			for (; y < 64; y++)
			{
				buffer[yoffs] = color[c];
//				buffer[yoffs+1] = color[c];
//				buffer[yoffs+2] = color[c];
				yoffs += VIS_WIDTH;
				buffer[yoffs2] = color[c];
//				buffer[yoffs2+1] = color[c];
//				buffer[yoffs2+2] = color[c];
				yoffs2 -= VIS_WIDTH;
				c++;
			}
		}
		xoffs += VIS_WIDTH/2;
	}

	WriteChunkyPixels(rp, left, top, left + VIS_WIDTH - 1, top + VIS_HEIGHT - 1, buffer, VIS_WIDTH);

	return 0;
}


BOOL HandleIEvents(struct Window *win)
{
	BOOL retval = FALSE;
   struct IntuiMessage *imsg;

   while (imsg = (struct IntuiMessage *) GetMsg(win->UserPort))
	{
		switch(imsg->Class)
		{
			case IDCMP_CLOSEWINDOW:
			{
				retval = TRUE;;
				break;
			}
		}

		ReplyMsg((Message *) imsg);
	}
	return retval;
}

void Run()
{
	BOOL quit = FALSE;
	ULONG gotsigs;
	ULONG sigmask = SIGBREAKF_CTRL_C;
	ULONG winsig = (1L << win->UserPort->mp_SigBit);
	sigmask |= winsig;

	while (!quit)
	{
		gotsigs = Wait(sigmask);

		if (gotsigs & SIGBREAKF_CTRL_C)
		{
			quit = TRUE;
		}
		if (gotsigs & winsig)
		{
			if (HandleIEvents(win))
				quit = TRUE;
		}
	}
}


void main(int argc, char *argv[])
{
	if (OpenLibs())
	{
		// This demo requires Amiga OS 3.1 (WriteChunkyPixels)
		if (GfxBase->lib_Version < 40)
		{
			Req("This plugin requires at least Amiga OS 3.1.", "Ok");
			CloseLibs();
			return;
		}

		// Try to open AMPlifiers plugin library
		AMPlifierPluginBase = OpenLibrary("amplifierplugin.library", 0);
		if (AMPlifierPluginBase)
		{
			// Setup plugin
			if (PluginStart())
			{
				struct PluginCtrl *pctrl;
				renderhook.h_Entry = (ULONG (*)()) &RenderFunc;

				// Connect plugin to AMPlifiers pluginlist
				// When AMPlifier quits it sends a signal to the given task.
				// The plugin must quit after receiving this signal.
				pctrl = PI_AddModule(
					PIA_Name, "SampleVis",
					PIA_QuitTask, FindTask(NULL),
					PIA_QuitMask, SIGBREAKF_CTRL_C,
					PIA_RenderHook, &renderhook,
					PIA_WaveformChannels, 2,
					PIA_SpectrumChannels, 2,
					TAG_END);
				if (pctrl)
				{
					// Event loop
					Run();

					// Remove plugin module from AMPlifier
					PI_RemModule(pctrl);
				}
				else
					Req("Add module failed.", "hmm...");

				// Free plugin resources
				PluginEnd();
			}

			// Finaly close AMPlifiers plugin library.
			// AMPlifier will not be able to quit until the library is closed.
			CloseLibrary(AMPlifierPluginBase);
		}
		else
			Req("Couldn't open AMPlifier plugin library!\nAMPlifier probably not running.", "Ok");

		CloseLibs();
	}
}

