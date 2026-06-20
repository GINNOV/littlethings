/******************************************************************************
 * Copyright (c) 1996 Netscape Communications. All rights reserved.
 ******************************************************************************/

/*
 *	Modifications for the Linux Flash Plugin
 *	by Olivier Debon <odebon@club-internet.fr>
 */

static char *rcsid = "$Id: plugin.c,v 1.10 1998/12/06 18:31:53 olivier Exp olivier $";

#include <stdio.h>
#include "npapi.h"

#include "flash.h"
#include <X11/Intrinsic.h>
#include <X11/IntrinsicP.h>
#include <X11/Core.h>
#include <X11/CoreP.h>

typedef struct _PluginInstance
{
	char		*flashData;
	long  		 size;
	long 		 nbChunks;
	long 		 gInitDone;
	Display 	*dpy;
	GC		 gc;
	Window 		 win;
	Widget 		 widget;
	XtIntervalId 	 timer;
	struct timeval 	 wd;
	long   		 attributes;
	FlashHandle 	 fh;
} PluginInstance;

static void updateTimer(PluginInstance* This);
static void flashEvent(Widget w, XtPointer client_data, XEvent *event, Boolean *dispatch);
static void flashWakeUp(XtPointer client_data, XtIntervalId *id);
static void getUrl( char * url, char *target, void *client_data);
static long parseAttributes(int16 n, char *argn[], char *argv[]);

#ifdef C6R5
// Ugly but it makes it work if it is compiled on
// a libc6 system and running with a libc5-netscape
int __sigsetjmp()
{
	return 0;
}
#endif

char*
NPP_GetMIMEDescription(void)
{
	return("application/x-shockwave-flash:swf:Flash Plugin;application/futuresplash:spl:Future Splash");
}

NPError
NPP_GetValue(void *future, NPPVariable variable, void *value)
{
	NPError err = NPERR_NO_ERROR;

	switch (variable) {
		case NPPVpluginNameString:
			*((char **)value) = PLUGIN_NAME;
			break;
		case NPPVpluginDescriptionString:
			*((char **)value) = "Flash file player " FLASH_VERSION_STRING
					    "<P>Shockwave is a trademark of <A HREF=\"http://www.macromedia.com\">Macromedia&reg;</A>"
					    "<P>Author : <A HREF=mailto:odebon@club-internet.fr>Olivier Debon </A>";
			break;
		default:
			err = NPERR_GENERIC_ERROR;
	}
	return err;
}

NPError
NPP_Initialize(void)
{
    freopen("/dev/tty","w",stdout);
    freopen("/dev/tty","w",stderr);
    return NPERR_NO_ERROR;
}


jref
NPP_GetJavaClass()
{
    return NULL;
}

void
NPP_Shutdown(void)
{
}


NPError 
NPP_New(NPMIMEType pluginType,
	NPP instance,
	uint16 mode,
	int16 argc,
	char* argn[],
	char* argv[],
	NPSavedData* saved)
{
        PluginInstance* This;

	if (instance == NULL)
		return NPERR_INVALID_INSTANCE_ERROR;
		
	instance->pdata = NPN_MemAlloc(sizeof(PluginInstance));
	
	This = (PluginInstance*) instance->pdata;

	if (This != NULL)
	{
		This->flashData = 0;
		This->size = 0;
		This->nbChunks = 0;
		This->fh = 0;
		This->gInitDone = 0;
		This->dpy = 0;
		This->win = 0;
		This->timer = 0;
		This->attributes = parseAttributes(argc, argn, argv);

		return NPERR_NO_ERROR;
	}
	else
		return NPERR_OUT_OF_MEMORY_ERROR;
}


NPError 
NPP_Destroy(NPP instance, NPSavedData** save)
{
	PluginInstance* This;

	if (instance == NULL)
		return NPERR_INVALID_INSTANCE_ERROR;

	This = (PluginInstance*) instance->pdata;

	if (This != NULL) {
		if (This->timer) {
			XtRemoveTimeOut(This->timer);
			This->timer = 0;
		}
		if (This->fh) {
			FlashClose(This->fh);
		}
		if (This->flashData) {
			free(This->flashData);
		}
		This->fh = 0;
		NPN_MemFree(instance->pdata);
		instance->pdata = NULL;
	}

	return NPERR_NO_ERROR;
}

static void
updateTimer(PluginInstance* This)
{
	XtAppContext ctxt;
	struct timeval now;
	long delay;

	if (This->timer) {
		XtRemoveTimeOut(This->timer);
	}

	gettimeofday(&now,0);
	delay = (This->wd.tv_sec-now.tv_sec)*1000 + (This->wd.tv_usec-now.tv_usec)/1000;

	//fprintf(stderr,"Wakeup in %d ms\n", delay);

	if (delay <0) {
		// OVERRUN !!!
		delay = 20;	// Leave 20 ms
	}
	ctxt = XtWidgetToApplicationContext(This->widget);
	This->timer = XtAppAddTimeOut(ctxt, delay,
			    (XtTimerCallbackProc) flashWakeUp,
			    (XtPointer) This);
}

static void
flashEvent(Widget w, XtPointer client_data, XEvent *event, Boolean *dispatch)
{
	PluginInstance* This;
	long cmd;
	long wakeUp;

	This = (PluginInstance*)client_data;

	if (This->fh) {
		cmd = FLASH_EVENT;
		wakeUp = FlashExec(This->fh, cmd, event, &This->wd);
		if (wakeUp) {
			updateTimer(This);
		}
	}
}

static void
flashWakeUp(XtPointer client_data, XtIntervalId *id)
{
	PluginInstance* This;
	long cmd;
	long wakeUp;

	This = (PluginInstance*)client_data;

	if (This->fh) {
		cmd = FLASH_WAKEUP;
		wakeUp = FlashExec(This->fh, cmd, 0, &This->wd);

		/* If have to wake up next time */
		if (wakeUp) {
			updateTimer(This);
		} else {
			if (This->timer) {
				XtRemoveTimeOut(This->timer);
			}
			This->timer = 0;
		}
	}
}

NPError 
NPP_SetWindow(NPP instance, NPWindow* window)
{
	PluginInstance* This;
	NPSetWindowCallbackStruct *ws;
	Window frame;
	XWindowAttributes xwa;

	if (instance == NULL)
		return NPERR_INVALID_INSTANCE_ERROR;

	if (window == NULL)
		return NPERR_NO_ERROR;

	This = (PluginInstance*) instance->pdata;

	This->win = (Window) window->window;
	ws = (NPSetWindowCallbackStruct *)window->ws_info;
	This->dpy = ws->display;
	This->gc = DefaultGC(This->dpy, DefaultScreen(This->dpy));
	This->widget = XtWindowToWidget(This->dpy,This->win);

	XGetWindowAttributes(This->dpy, This->win, &xwa);

	if (!This->gInitDone && This->fh) {
		FlashGraphicInit(This->fh, This->dpy, This->win);
		XtAddEventHandler(This->widget, FLASH_XEVENT_MASK,
				  True, (XtEventHandler) flashEvent, (XtPointer)This);
		This->gInitDone = 1;

		flashWakeUp((XtPointer)This, 0);
	}


	return NPERR_NO_ERROR;
}

NPError 
NPP_NewStream(NPP instance,
			  NPMIMEType type,
			  NPStream *stream, 
			  NPBool seekable,
			  uint16 *stype)
{
	NPByteRange range;
	PluginInstance* This;

	if (instance == NULL)
		return NPERR_INVALID_INSTANCE_ERROR;

	This = (PluginInstance*) instance->pdata;

	return NPERR_NO_ERROR;
}


#define BUFFERSIZE (16*1024)

int32 
NPP_WriteReady(NPP instance, NPStream *stream)
{
	PluginInstance* This;

	if (instance != NULL)
	{
		This = (PluginInstance*) instance->pdata;

		if (This->flashData == 0) {
			This->flashData = (char *) malloc(BUFFERSIZE);
			This->nbChunks++;
		} else {
			This->nbChunks++;
			This->flashData = (char *) realloc(This->flashData, This->nbChunks*BUFFERSIZE);
		}

	}
	return BUFFERSIZE;
}


int32 
NPP_Write(NPP instance, NPStream *stream, int32 offset, int32 len, void *buffer)
{
	PluginInstance* This;

	if (instance != NULL)
	{
		This = (PluginInstance*) instance->pdata;

		memcpy(&This->flashData[offset], buffer, len);
		This->size += len;

		if (This->dpy) {
			XSetFunction(This->dpy, This->gc, GXinvert);
			XDrawString(This->dpy, This->win,This->gc, 10, 20, "Downloading...", strlen ("Downloading..."));
			XFlush(This->dpy);
		}
	}

	return len;		/* The number of bytes accepted */
}

static void
getUrl( char * url, char *target, void *client_data)
{
	NPP instance;

	instance = (NPP)client_data;
	NPN_GetURL(instance, url, target );
}

NPError 
NPP_DestroyStream(NPP instance, NPStream *stream, NPError reason)
{
	PluginInstance* This;

	if (instance == NULL)
		return NPERR_INVALID_INSTANCE_ERROR;

	if (reason != NPERR_NO_ERROR)
		return NPERR_INVALID_INSTANCE_ERROR;

	This = (PluginInstance*) instance->pdata;

	This->fh = FlashParse(This->flashData, This->size);

	if (This->fh == 0) {
		return NPERR_INVALID_INSTANCE_ERROR;
	}

	FlashSettings(This->fh, This->attributes);

	FlashSetGetUrlMethod(This->fh, getUrl, (void*)instance);

	FlashSoundInit(This->fh, "/dev/dsp");

	if (!This->gInitDone && This->dpy) {
		FlashGraphicInit(This->fh, This->dpy, This->win);
		XtAddEventHandler(This->widget,
				  ExposureMask|ButtonPressMask|PointerMotionMask|ButtonReleaseMask,
				  True, (XtEventHandler) flashEvent, (XtPointer)This);
		This->gInitDone = 1;

		flashWakeUp((XtPointer)This, 0);
	}

	return NPERR_NO_ERROR;
}


void 
NPP_StreamAsFile(NPP instance, NPStream *stream, const char* fname)
{
	PluginInstance* This;
	if (instance != NULL)
		This = (PluginInstance*) instance->pdata;
}


void 
NPP_Print(NPP instance, NPPrint* printInfo)
{
	if(printInfo == NULL)
		return;

	if (instance != NULL) {
		PluginInstance* This = (PluginInstance*) instance->pdata;
	
		if (printInfo->mode == NP_FULL) {
		    /*
		     * PLUGIN DEVELOPERS:
		     *	If your plugin would like to take over
		     *	printing completely when it is in full-screen mode,
		     *	set printInfo->pluginPrinted to TRUE and print your
		     *	plugin as you see fit.  If your plugin wants Netscape
		     *	to handle printing in this case, set
		     *	printInfo->pluginPrinted to FALSE (the default) and
		     *	do nothing.  If you do want to handle printing
		     *	yourself, printOne is true if the print button
		     *	(as opposed to the print menu) was clicked.
		     *	On the Macintosh, platformPrint is a THPrint; on
		     *	Windows, platformPrint is a structure
		     *	(defined in npapi.h) containing the printer name, port,
		     *	etc.
		     */

			void* platformPrint =
				printInfo->print.fullPrint.platformPrint;
			NPBool printOne =
				printInfo->print.fullPrint.printOne;
			
			/* Do the default*/
			printInfo->print.fullPrint.pluginPrinted = FALSE;
		}
		else {	/* If not fullscreen, we must be embedded */
		    /*
		     * PLUGIN DEVELOPERS:
		     *	If your plugin is embedded, or is full-screen
		     *	but you returned false in pluginPrinted above, NPP_Print
		     *	will be called with mode == NP_EMBED.  The NPWindow
		     *	in the printInfo gives the location and dimensions of
		     *	the embedded plugin on the printed page.  On the
		     *	Macintosh, platformPrint is the printer port; on
		     *	Windows, platformPrint is the handle to the printing
		     *	device context.
		     */

			NPWindow* printWindow =
				&(printInfo->print.embedPrint.window);
			void* platformPrint =
				printInfo->print.embedPrint.platformPrint;
		}
	}
}

static
long parseAttributes(int16 n, char *argn[], char *argv[])
{
	int16 i;
	int c;
	long attributes;

	for(i=0; i<n; i++)
	{
		if (!strcasecmp(argn[i],"loop")) {
			if (!strcasecmp(argv[i],"true")) {
				attributes |= PLAYER_LOOP;
			}
		}
		if (!strcasecmp(argn[i],"menu")) {
			if (!strcasecmp(argv[i],"true")) {
				attributes |= PLAYER_MENU;
			}
		}
		if (!strcasecmp(argn[i],"quality")) {
			if (!strcasecmp(argv[i],"high")
			 || !strcasecmp(argv[i],"autohigh")) {
				attributes |= PLAYER_QUALITY;
			}
		}
	}
	return attributes;
}
