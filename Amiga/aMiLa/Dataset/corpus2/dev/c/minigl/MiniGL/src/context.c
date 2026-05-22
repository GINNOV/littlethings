/*
 * $Id: context.c,v 1.1.1.1 2000/04/07 19:44:51 hfrieden Exp $
 *
 * $Date: 2000/04/07 19:44:51 $
 * $Revision: 1.1.1.1 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */


#include "sysinc.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static char rcsid[] = "$Id: context.c,v 1.1.1.1 2000/04/07 19:44:51 hfrieden Exp $";


extern void GLMatrixInit(GLcontext context);
GLboolean MGLInitContext(GLcontext context);

#ifndef __PPC__
extern struct IntuitionBase *IntuitionBase;
extern struct ExecBase *SysBase;
extern struct GfxBase *GfxBase;
extern struct DosLibrary *DOSBase;
#endif

GLcontext mini_CurrentContext;

#ifdef __PPC__
extern struct Library *Warp3DPPCBase;
#else
extern struct Library *Warp3DBase;
#endif

extern struct Library *CyberGfxBase;

extern void tex_FreeTextures(GLcontext context);
extern void TMA_Start(LockTimeHandle *handle);

#ifndef NLOGGING
int MGLDebugLevel;
#endif

// Default values for new context

/*
Surgeon: bumped newVertexBufferSizefrom 40 to 256 because of increased requirement for clipping space due to buffering
*/

static int newVertexBufferSize = 256;            // Default: 256 entries in vertex buffer
static int newMTBufferSize    = 4096;            // Default: 4096 verts storage-space

static int newTextureBufferSize = 2048;         // Default: 2048 texture objects
static int newNumberOfBuffers = 2;              // Default: Double buffering
static int newPixelDepth = 15;                  // Default: 15 bits per pixel
static GLboolean newWindowMode = GL_FALSE;      // Default: Use fullscreen instead of window
static GLboolean clw = GL_FALSE;                // Default: Keep workbench open
static GLboolean newNoMipMapping = GL_TRUE;     // Default: No mipmapping
static GLboolean newNoFallbackAlpha = GL_FALSE; // Default: Fall back to supported blend mode
static GLboolean newGuardBand = GL_FALSE;	  // Default: guardband clipping is off

static struct TagItem tags[7];

static UWORD *MousePointer = 0;

static GLboolean sys_MaybeOpenVidLibs(void)
{
#ifdef __PPC__
	if (!Warp3DPPCBase)
	{
		Warp3DPPCBase = OpenLibrary("Warp3DPPC.library", 2L);
		if (!Warp3DPPCBase)
		{
			printf("Error opening Warp3D library\n");
			return GL_FALSE;
		}
	}
#else
	if (!Warp3DBase)
	{
		Warp3DBase = OpenLibrary("Warp3D.library", 2L);
		if (!Warp3DBase)
		{
			printf("Error opening Warp3D library\n");
			return GL_FALSE;
		}
	}

#endif

	if (!CyberGfxBase)
	{
		CyberGfxBase = OpenLibrary("cybergraphics.library", 0L);
		if (!CyberGfxBase)
		{
			printf("Error opening cybergraphics.library\n");
			return GL_FALSE;
		}
	}

	return GL_TRUE;
}

static void vid_Pointer(struct Window *window)
{
	if (!MousePointer)
	{
#ifdef __PPC__
		MousePointer = AllocVecPPC(8, MEMF_CLEAR|MEMF_CHIP|MEMF_PUBLIC,0); //OF (8 instead of 12, MEMF_PUBLIC)
#else
		MousePointer = AllocVec(8, MEMF_CLEAR|MEMF_CHIP|MEMF_PUBLIC); //OF (idem)
#endif
	}

	if (window)         SetPointer(window, MousePointer, 0, 0, 0, 0); //OF (was 1, 16, 0, 0)
}

static void vid_DeletePointer(struct Window *window)
{
	if (window)         ClearPointer(window);
#ifdef __PPC__
	FreeVecPPC(MousePointer);
#else
	FreeVec(MousePointer);
#endif
	MousePointer = 0;
}

void GLScissor(GLcontext context, GLint x, GLint y, GLsizei width, GLsizei height)
{
	//LOG(1, glScissor, "%d %d %d %d",x,y,width,height);

	if(context->Scissor_State == GL_TRUE)
	{
		static W3D_Scissor scissor;

		scissor.left = x;
		scissor.top = context->w3dWindow->Height-y-height;
		scissor.width = width;
		scissor.height = height;

		W3D_SetScissor(context->w3dContext, &scissor);
 	}
	else
	{
		context->scissor.left = x;
		context->scissor.top = context->w3dWindow->Height-y-height;
		context->scissor.width = width;
		context->scissor.height = height;
	}
}

static void vid_CloseDisplay(GLcontext context)
{
	int i;

	if (context->w3dContext)
	{
		W3D_FreeZBuffer(context->w3dContext);
		tex_FreeTextures(context);
		W3D_DestroyContext(context->w3dContext);
		context->w3dContext = 0;
	}

#ifdef __PPC__
	if (Warp3DPPCBase) CloseLibrary(Warp3DPPCBase);
	Warp3DPPCBase = NULL;
#else
	if (Warp3DBase) CloseLibrary(Warp3DBase);
	Warp3DBase = NULL;
#endif

	Delay(25L);
	if (context->Buffers[0])
	{
		context->Buffers[0]->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = NULL;
		while (!ChangeScreenBuffer(context->w3dScreen, context->Buffers[0]));
	}

	for (i=0; i<context->NumBuffers; i++)
	{
		if (context->Buffers[i])
			FreeScreenBuffer(context->w3dScreen, context->Buffers[i]);
		context->Buffers[i] = NULL;
	}

	vid_DeletePointer(context->w3dWindow);
	if (context->w3dWindow) CloseWindow(context->w3dWindow);
	if (context->w3dScreen) CloseScreen(context->w3dScreen);

	if (clw == GL_TRUE) OpenWorkBench();
}

static GLboolean vid_ReopenDisplay(GLcontext context, int w, int h)
{
	ULONG ModeID, IDCMP;
	int i;
	struct TagItem BestModeTags[] =
	{
		{W3D_BMI_WIDTH,  0},
		{W3D_BMI_HEIGHT, 0},
		{W3D_BMI_DEPTH,  0},
		{TAG_DONE,       0}
	};

	struct TagItem OpenScrTags[] =
	{
		{SA_Height,      0},
		{SA_Width,       0},
		{SA_Depth,       8L},
		{SA_DisplayID,   0},
		{SA_ShowTitle,   FALSE},
		{SA_Draggable,   FALSE},
		{TAG_DONE,       0}
	};

	struct TagItem OpenWinTags[] =
	{
		WA_CustomScreen,        0,
		WA_Width,               0,
		WA_Height,              0,
		WA_Left,                0,
		WA_Top,                 0,
		WA_Title,               0,
		WA_Flags,               WFLG_ACTIVATE|WFLG_BORDERLESS|WFLG_BACKDROP|WFLG_REPORTMOUSE|WFLG_RMBTRAP,
		WA_IDCMP,               0,
		TAG_DONE,               0
	};

	if (!context)
	    return GL_FALSE;

	#ifndef NCGXDEBUG
	ULONG flag;

	if (GL_FALSE == sys_MaybeOpenVidLibs())
	{
		return GL_FALSE;
	}
	#endif

	if (context->Buffers[0])
	{
		context->Buffers[0]->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = NULL;
		while (!ChangeScreenBuffer(context->w3dScreen, context->Buffers[0]));
	}

	for (i=0; i<context->NumBuffers; i++)
	{
		if (context->Buffers[i])
			FreeScreenBuffer(context->w3dScreen, context->Buffers[i]);
		context->Buffers[i] = NULL;
	}

	IDCMP = context->w3dWindow->IDCMPFlags;

	if (context->w3dWindow) CloseWindow(context->w3dWindow); context->w3dWindow = NULL;
	if (context->w3dScreen) CloseScreen(context->w3dScreen); context->w3dScreen = NULL;

	BestModeTags[0].ti_Data = (ULONG)w;
	BestModeTags[1].ti_Data = (ULONG)h;
	BestModeTags[2].ti_Data = (ULONG)newPixelDepth;

	ModeID = W3D_BestModeID(BestModeTags);

	if (ModeID == INVALID_ID) return GL_FALSE;

	OpenScrTags[0].ti_Data = (ULONG)w;
	OpenScrTags[1].ti_Data = (ULONG)h;
	OpenScrTags[3].ti_Data = ModeID;

	context->w3dScreen = OpenScreenTagList(NULL, OpenScrTags);

	if (!context->w3dScreen)
	{
		printf("Failed to re-open screen\n");
		return GL_FALSE;
	}

	OpenWinTags[0].ti_Data = (ULONG)context->w3dScreen;
	OpenWinTags[1].ti_Data = (ULONG)context->w3dScreen->Width;
	OpenWinTags[2].ti_Data = (ULONG)context->w3dScreen->Height;
	OpenWinTags[7].ti_Data = IDCMP;

	context->w3dWindow = OpenWindowTagList(NULL, OpenWinTags);

	if (!context->w3dWindow)
	{
		printf("Failed to re-open window\n");
		goto Duh;
	}

	context->Buffers[0] = AllocScreenBuffer(context->w3dScreen, NULL, SB_SCREEN_BITMAP);

	if (!context->Buffers[0])
	{
		printf("Failed to allocate screen buffer\n");
		goto Duh;
	}

	#ifndef NCGXDEBUG
	flag = GetCyberMapAttr(context->Buffers[0]->sb_BitMap, CYBRMATTR_ISCYBERGFX);

	if (!flag)
		printf("Warning: No CyberGraphics bitmap in buffer 0\n");
	else
		printf("Info: Buffer 0 is a cybergraphics bitmap\n");
	#endif


	for (i=1; i<newNumberOfBuffers; i++)
	{
		context->Buffers[i] = AllocScreenBuffer(context->w3dScreen, NULL, 0);
		if (!context->Buffers[i]) goto Duh;

		#ifndef NCGXDEBUG
		flag = GetCyberMapAttr(context->Buffers[0]->sb_BitMap, CYBRMATTR_ISCYBERGFX);

		if (!flag)
			printf("Warning: No CyberGraphics bitmap in buffer %d\n", i);
		else
			printf("Info: Buffer %d is a cybergraphics bitmap\n", i);
		#endif
	}

	context->BufNr      = 1;                    // The drawing buffer
	SetRGB32(&(context->w3dScreen->ViewPort), 0, 0x7fffffff,0x7fffffff,0x7fffffff);

	for (i=0; i<context->NumBuffers; i++)
	{
		context->Buffers[i]->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = NULL;
		while (!ChangeScreenBuffer(context->w3dScreen, context->Buffers[i]));
		EraseRect(context->w3dWindow->RPort, context->w3dWindow->BorderLeft,
			context->w3dWindow->BorderTop,
			context->w3dWindow->Width-context->w3dWindow->BorderLeft-context->w3dWindow->BorderRight-1,
			context->w3dWindow->Height-context->w3dWindow->BorderTop-context->w3dWindow->BorderBottom-1);
	}
	context->Buffers[0]->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = NULL;

	while (!ChangeScreenBuffer(context->w3dScreen, context->Buffers[0]));


	GLScissor(context, 0, 0, w, h);

	W3D_SetDrawRegion(context->w3dContext, context->Buffers[1]->sb_BitMap,
		0, &(context->scissor));

	//surgeon:
	W3D_SetScissor(context->w3dContext, &(context->scissor));	

	W3D_FreeZBuffer(context->w3dContext);
	W3D_AllocZBuffer(context->w3dContext);

	vid_Pointer(context->w3dWindow);
					 
	return GL_TRUE;

Duh:
	printf("An error occured - closing down\n");
	vid_CloseDisplay(context);

	return GL_FALSE;
}

static GLboolean vid_OpenDisplay(GLcontext context, int pw, int ph, ULONG id)
{
	ULONG ModeID;
	ULONG CError;
	int i;
	ULONG result;
	#ifndef NCGXDEBUG
	ULONG flag;
	#endif
	int w = 0, h = 0;

	struct TagItem BestModeTags[] =
	{
		{W3D_BMI_WIDTH,  0},
		{W3D_BMI_HEIGHT, 0},
		{W3D_BMI_DEPTH,  0},
		{TAG_DONE,       0}
	};

	struct TagItem OpenScrTags[] =
	{
		{SA_Depth,       8L},
		{SA_DisplayID,   0},
		{SA_ShowTitle,   FALSE},
		{SA_Draggable,   FALSE},
		{TAG_DONE,      0}
	};

	struct TagItem OpenWinTags[] =
	{
		{WA_CustomScreen,        0},
		{WA_Width,               0},
		{WA_Height,              0},
		{WA_Left,                0},
		{WA_Top,                 0},
		{WA_Title,               0},
		{WA_Flags,               WFLG_ACTIVATE|WFLG_BORDERLESS|WFLG_BACKDROP|WFLG_REPORTMOUSE|WFLG_RMBTRAP},
		{TAG_DONE,               0}
	};

	if (!context)
	    return GL_FALSE;

	if (GL_FALSE == sys_MaybeOpenVidLibs())
		return GL_FALSE;

	if (id != MGL_SM_BESTMODE && id != MGL_SM_WINDOWMODE)
	{
		ModeID = id;
	}
	else
	{
		w = pw;
		h = ph;
		BestModeTags[0].ti_Data = (ULONG)w;
		BestModeTags[1].ti_Data = (ULONG)h;
		BestModeTags[2].ti_Data = (ULONG)newPixelDepth;

		ModeID = W3D_BestModeID(BestModeTags);
	}

	if (clw == GL_TRUE)
	    CloseWorkBench();

	if (ModeID == INVALID_ID)
	    return GL_FALSE;


	OpenScrTags[1].ti_Data = ModeID;

	context->w3dScreen = OpenScreenTagList(NULL, OpenScrTags);


	if (context->w3dScreen && id != MGL_SM_BESTMODE)
	{
		w = context->w3dScreen->Width;
		h = context->w3dScreen->Height;
	}

	if (!context->w3dScreen) return GL_FALSE;

	// We don't include IDCMP flags. The user can change this with
	// a call to ModifyIDCMP.

	OpenWinTags[0].ti_Data = (ULONG)context->w3dScreen;
	OpenWinTags[1].ti_Data = (ULONG)context->w3dScreen->Width;
	OpenWinTags[2].ti_Data = (ULONG)context->w3dScreen->Height;

	context->w3dWindow = OpenWindowTagList(NULL, OpenWinTags);

	if (!context->w3dWindow) goto Duh;

	context->Buffers[0] = AllocScreenBuffer(context->w3dScreen, NULL, SB_SCREEN_BITMAP);
	if (!context->Buffers[0])
	{
		printf("Error: Can't create screen buffer 0\n");
		goto Duh;
	}

	#ifndef NCGXDEBUG
	flag = GetCyberMapAttr(context->Buffers[0]->sb_BitMap, CYBRMATTR_ISCYBERGFX);

	if (!flag)
		printf("Warning: No CyberGraphics bitmap in buffer 0\n");
	else
		printf("Info: Buffer 0 is a cybergraphics bitmap\n");
	#endif


	for (i=1; i<newNumberOfBuffers; i++)
	{
		context->Buffers[i] = AllocScreenBuffer(context->w3dScreen, NULL, 0);
		if (!context->Buffers[i])
		{
			printf("Error: Can't create screen buffer %d\n", i);
			goto Duh;
		}
		#ifndef NCGXDEBUG
		flag = GetCyberMapAttr(context->Buffers[0]->sb_BitMap, CYBRMATTR_ISCYBERGFX);

		if (!flag)
			printf("Warning: No CyberGraphics bitmap in buffer %d\n", i);
		else
			printf("Info: Buffer 0 is a cybergraphics bitmap\n");
		#endif
	}

	context->BufNr      = 1;                    // The drawing buffer
	context->NumBuffers = newNumberOfBuffers;   // So we know the limit
	context->DoSync     = GL_TRUE;              // Enable sync'ing

	tags[0].ti_Tag      = W3D_CC_MODEID;
	tags[0].ti_Data     = ModeID;

	tags[1].ti_Tag      = W3D_CC_BITMAP;
	tags[1].ti_Data     = (ULONG)(context->Buffers[1]->sb_BitMap);

	tags[2].ti_Tag      = W3D_CC_DRIVERTYPE;
	tags[2].ti_Data     = W3D_DRIVER_BEST;

	tags[3].ti_Tag      = W3D_CC_FAST;
	tags[3].ti_Data     = FALSE;

	tags[4].ti_Tag      = W3D_CC_YOFFSET;
	tags[4].ti_Data     = 0;

	tags[5].ti_Tag      = W3D_CC_GLOBALTEXENV;
	tags[5].ti_Data     = TRUE;

	tags[6].ti_Tag      = TAG_DONE;

	context->w3dContext = W3D_CreateContext(&CError, tags);

	if (!context->w3dContext || CError != W3D_SUCCESS)
	{
		switch(CError)
		{
			case W3D_ILLEGALINPUT:
					printf("Illegal input to CreateContext function\n");
					break;
			case W3D_NOMEMORY:
					printf("Out of memory\n");
					break;
			case W3D_NODRIVER:
					printf("No suitable driver found\n");
					break;
			case W3D_UNSUPPORTEDFMT:
					printf("Supplied bitmap cannot be handled by Warp3D\n");
					break;
			case W3D_ILLEGALBITMAP:
					printf("Supplied bitmap not properly initialized\n");
					break;
			default:
					printf("An error has occured... gosh\n");
		}
		goto Duh;
	}

	/*
	** Set up a few initial states
	** We always enable scissoring and dithering, since it looks better
	** on 16 bit displays.
	** We also set shading to smooth (Gouraud).
	*/
	W3D_SetState(context->w3dContext, W3D_DITHERING,    W3D_ENABLE);
	W3D_SetState(context->w3dContext, W3D_SCISSOR,      W3D_ENABLE);
	W3D_SetState(context->w3dContext, W3D_GOURAUD,      W3D_ENABLE);
	W3D_SetState(context->w3dContext, W3D_PERSPECTIVE,  W3D_ENABLE);


	SetRGB32(&(context->w3dScreen->ViewPort), 0, 0x7fffffff,0x7fffffff,0x7fffffff);


	/*
	** Allocate the ZBuffer.
	*/
	result = W3D_AllocZBuffer(context->w3dContext);

	switch(result)
	{
		case W3D_NOGFXMEM:      printf("No ZBuffer: Memory shortage\n");            break;
		case W3D_NOZBUFFER:     printf("No ZBuffer: Operation not supported\n");    break;
		case W3D_NOTVISIBLE:    printf("No ZBuffer: Screen is not visible\n");      break;
	}


	W3D_SetState(context->w3dContext, W3D_ZBUFFER, W3D_DISABLE);
	W3D_SetState(context->w3dContext, W3D_ZBUFFERUPDATE, W3D_ENABLE);
	W3D_SetZCompareMode(context->w3dContext, W3D_Z_LESS);


	for (i=0; i<context->NumBuffers; i++)
	{
		context->Buffers[i]->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = NULL;
		while (!ChangeScreenBuffer(context->w3dScreen, context->Buffers[i]));
		EraseRect(context->w3dWindow->RPort, context->w3dWindow->BorderLeft,
			context->w3dWindow->BorderTop,
			context->w3dWindow->Width-context->w3dWindow->BorderLeft-context->w3dWindow->BorderRight-1,
			context->w3dWindow->Height-context->w3dWindow->BorderTop-context->w3dWindow->BorderBottom-1);
	}

	context->Buffers[0]->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = NULL;
	while (!ChangeScreenBuffer(context->w3dScreen, context->Buffers[0]));

	GLScissor(context, 0,0, w,h);

	//surgeon: added
	W3D_SetDrawRegion(context->w3dContext, context->Buffers[1]->sb_BitMap,
		0, &(context->scissor));

	W3D_SetScissor(context->w3dContext, &(context->scissor));	

	context->w3dLocked = GL_FALSE;

	/*
	** Select a texture format that needs no conversion
	*/
	//FIXME:Really do it. This is lame
	context->w3dFormat = W3D_R5G6B5;
	context->w3dAlphaFormat = W3D_A4R4G4B4;
	context->w3dBytesPerTexel = 2;

	vid_Pointer(context->w3dWindow); 
					 
	return GL_TRUE;

Duh:
	for (i=0; i<newNumberOfBuffers; i++)
	{
		if (context->Buffers[i])
		{
			FreeScreenBuffer(context->w3dScreen, context->Buffers[i]);
			context->Buffers[i] = NULL;
		}
	}

	if (context->w3dWindow)
	{
		CloseWindow(context->w3dWindow);
		context->w3dWindow = NULL;
	}

	if (context->w3dScreen)
	{
		CloseScreen(context->w3dScreen);
		context->w3dScreen = NULL;
	}

	return GL_FALSE;
}

static void vid_CloseWindow(GLcontext context)
{
	if (!context)
	    return;

	if (context->w3dContext)
	{
		W3D_FreeZBuffer(context->w3dContext);
		tex_FreeTextures(context);
		W3D_DestroyContext(context->w3dContext);
		context->w3dContext = 0;
	}

#ifdef __PPC__
	if (Warp3DPPCBase)          CloseLibrary(Warp3DPPCBase);
	Warp3DPPCBase = NULL;
#else
	if (Warp3DBase)             CloseLibrary(Warp3DBase);
	Warp3DBase = NULL;
#endif

	if (context->w3dWindow)     CloseWindow(context->w3dWindow);
	if (context->w3dScreen)     CloseScreen(context->w3dScreen);
	if (context->w3dBitMap)     FreeBitMap(context->w3dBitMap);
	if (context->w3dRastPort)   free(context->w3dRastPort);
}


static GLboolean vid_OpenWindow(GLcontext context, int w, int h)
{
	ULONG CError;
	ULONG result;

	struct TagItem OpenWinTags[] =
	{
		{WA_PubScreen,           0},
		{WA_InnerWidth,          0},
		{WA_InnerHeight,         0},
		{WA_Left,                30},
		{WA_Top,                 30},
		{WA_Title,               (ULONG)"MiniGL Display"},
		{WA_DragBar,             TRUE},
		{WA_DepthGadget,         TRUE},
		{WA_Flags,               WFLG_ACTIVATE|WFLG_REPORTMOUSE|WFLG_RMBTRAP},
		{TAG_DONE,               0}
	};

	if (!context)
	    return GL_FALSE;

	if (GL_FALSE == sys_MaybeOpenVidLibs())
	{
		return GL_FALSE;
	}

	context->w3dScreen = LockPubScreen(NULL);
	if (!context->w3dScreen) return GL_FALSE;

	// We don't include IDCMP flags. The user can change this with
	// a call to ModifyIDCMP.

	OpenWinTags[0].ti_Data = (ULONG)context->w3dScreen;
	OpenWinTags[1].ti_Data = (ULONG)w;
	OpenWinTags[2].ti_Data = (ULONG)h;

	context->w3dWindow = OpenWindowTagList(NULL, OpenWinTags);

	if (!context->w3dWindow) goto Duh;

	context->BufNr      = 0;                    // The drawing buffer
	context->NumBuffers = 0;                    // Indicates we're using a window
	context->DoSync     = GL_TRUE;              // Enable sync'ing

	context->w3dBitMap  = AllocBitMap(w,h,8,BMF_MINPLANES|BMF_DISPLAYABLE,
		context->w3dWindow->RPort->BitMap);
	if (!context->w3dBitMap) goto Duh;

	context->w3dRastPort = malloc(sizeof(struct RastPort));
	if (!context->w3dRastPort)
	{
		printf("Error: unable to allocate rastport memory\n");
		goto Duh;
	}

	InitRastPort(context->w3dRastPort);
	context->w3dRastPort->BitMap = context->w3dBitMap;

	tags[0].ti_Tag  = W3D_CC_BITMAP;
	tags[0].ti_Data = (ULONG)(context->w3dBitMap);

	tags[1].ti_Tag  = W3D_CC_DRIVERTYPE;
	tags[1].ti_Data = W3D_DRIVER_BEST;

	tags[2].ti_Tag  = W3D_CC_FAST;
	tags[2].ti_Data = FALSE;

	tags[3].ti_Tag  = W3D_CC_YOFFSET;
	tags[3].ti_Data = 0;

	tags[4].ti_Tag  = W3D_CC_GLOBALTEXENV;
	tags[4].ti_Data = TRUE;

	tags[5].ti_Tag  = TAG_DONE;

	context->w3dContext = W3D_CreateContext(&CError, tags);
	if (!context->w3dContext || CError != W3D_SUCCESS)
	{
		switch(CError)
		{
			case W3D_ILLEGALINPUT:
					printf("Illegal input to CreateContext function\n");
					break;
			case W3D_NOMEMORY:
					printf("Out of memory\n");
					break;
			case W3D_NODRIVER:
					printf("No suitable driver found\n");
					break;
			case W3D_UNSUPPORTEDFMT:
					printf("Supplied bitmap cannot be handled by Warp3D\n");
					break;
			case W3D_ILLEGALBITMAP:
					printf("Supplied bitmap not properly initialized\n");
					break;
			default:
					printf("An error has occured... gosh\n");
		}
		goto Duh;
	}
	/*
	** Set up a few initial states
	** We always enable scissoring and dithering, since it looks better
	** on 16 bit displays.
	** We also set shading to smooth (Gouraud).
	*/
	W3D_SetState(context->w3dContext, W3D_DITHERING,    W3D_ENABLE);
	W3D_SetState(context->w3dContext, W3D_SCISSOR,      W3D_ENABLE);
	W3D_SetState(context->w3dContext, W3D_GOURAUD,      W3D_ENABLE);
	W3D_SetState(context->w3dContext, W3D_PERSPECTIVE,  W3D_ENABLE);


	/*
	** Allocate the ZBuffer.
	*/
	result = W3D_AllocZBuffer(context->w3dContext);
	switch(result)
	{
		case W3D_NOGFXMEM:      printf("No ZBuffer: Memory shortage\n"); break;
		case W3D_NOZBUFFER:     printf("No ZBuffer: Operation not supported\n"); break;
		case W3D_NOTVISIBLE:    printf("No ZBuffer: Screen is not visible\n"); break;
	}

	W3D_SetState(context->w3dContext, W3D_ZBUFFER, W3D_DISABLE);
	W3D_SetState(context->w3dContext, W3D_ZBUFFERUPDATE, W3D_ENABLE);
	W3D_SetZCompareMode(context->w3dContext, W3D_Z_LESS);

	EraseRect(context->w3dWindow->RPort, context->w3dWindow->BorderLeft,
		context->w3dWindow->BorderTop,
		context->w3dWindow->Width-context->w3dWindow->BorderLeft-context->w3dWindow->BorderRight-1,
		context->w3dWindow->Height-context->w3dWindow->BorderTop-context->w3dWindow->BorderBottom-1);

	GLScissor(context, 0,0, w,h);

	context->w3dLocked = GL_FALSE;

	/*
	** Select a texture format that needs no conversion
	*/
	//FIXME:Really do it. This is lame
	context->w3dFormat = W3D_R5G6B5;
	context->w3dAlphaFormat = W3D_A4R4G4B4;
	context->w3dBytesPerTexel = 2;

	return GL_TRUE;

Duh:
	if (context->w3dWindow)
	{
		CloseWindow(context->w3dWindow);
		context->w3dWindow = NULL;
	}

	if (context->w3dScreen)
	{
		UnlockPubScreen(NULL, context->w3dScreen);
		context->w3dScreen = NULL;
	}

	if (context->w3dBitMap)
	{
		FreeBitMap(context->w3dBitMap);
	}

	if (context->w3dRastPort)
	{
		free(context->w3dRastPort);
	}

	return GL_FALSE;
}


void MGLResizeContext(GLcontext context, GLsizei width, GLsizei height)
{
	if (!context->w3dBitMap)
	{
		vid_ReopenDisplay(context, (int)width, (int)height);
		context->w3dChipID = context->w3dContext->CurrentChip;
	}
}

void *MGLGetWindowHandle(GLcontext context)
{
	return context->w3dWindow;
}

void mglChooseGuardBand(GLboolean flag)
{
	newGuardBand = flag;
}


void mglChooseVertexBufferSize(int size)
{
	newVertexBufferSize = size;
}

void mglChooseMtexBufferSize(int size)
{
	int align = size % 4; //bufferindex is 1/4 size

	newMTBufferSize = size;

	if(align)
	{
	  	newMTBufferSize += 4-align;
	}
}

void mglChooseTextureBufferSize(int size)
{
	newTextureBufferSize = size;
}

void mglChooseNumberOfBuffers(int number)
{
	newNumberOfBuffers = number;
}

void mglChoosePixelDepth(int depth)
{
	newPixelDepth = depth;
}

void mglProposeCloseDesktop(GLboolean closeme)
{
	clw = closeme;
}

void mglProhibitMipMapping(GLboolean flag)
{
	newNoMipMapping = flag;
}

void mglProhibitAlphaFallback(GLboolean flag)
{
	newNoFallbackAlpha = flag;
}

void mglChooseWindowMode(GLboolean flag)
{
	newWindowMode = flag;
}


void GLClearColor(GLcontext context, GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha)
{
	//LOG(2, glClearColor, "%f %f %f %f", red,green,blue,alpha);

	red *= 255.0;
	green *= 255.0;
	blue *= 255.0;
	alpha *= 255.0;

	context->ClearColor = ((GLubyte)(alpha)<<24)
						+ ((GLubyte)(red)<<16)
						+ ((GLubyte)(green)<<8)
						+ ((GLubyte)(blue));
}

void GLDepthMask(GLcontext context, GLboolean flag)
{
	//LOG(2, glDepthMask, "%d", flag);
	if (flag == GL_FALSE)
		W3D_SetState(context->w3dContext, W3D_ZBUFFERUPDATE, W3D_DISABLE);
	else
		W3D_SetState(context->w3dContext, W3D_ZBUFFERUPDATE, W3D_ENABLE);

	context->DepthMask = flag;
}

void GLDepthFunc(GLcontext context, GLenum func)
{
	ULONG wFunc = W3D_Z_LESS;
	//LOG(2, glDepthFunc, "%d", func);
	switch(func)
	{
		case GL_NEVER:      wFunc = W3D_Z_NEVER; break;
		case GL_LESS:       wFunc = W3D_Z_LESS; break;
		case GL_EQUAL:      wFunc = W3D_Z_EQUAL; break;
		case GL_LEQUAL:     wFunc = W3D_Z_LEQUAL; break;
		case GL_GREATER:    wFunc = W3D_Z_GREATER; break;
		case GL_NOTEQUAL:   wFunc = W3D_Z_NOTEQUAL; break;
		case GL_GEQUAL:     wFunc = W3D_Z_GEQUAL; break;
		case GL_ALWAYS:     wFunc = W3D_Z_ALWAYS; break;
		default:
			GLFlagError(context, 1, GL_INVALID_ENUM);
			break;
	}
	W3D_SetZCompareMode(context->w3dContext, wFunc);
}


void GLClearDepth(GLcontext context, GLclampd depth)
{
	//LOG(2, glClearDepth, "%f", depth);
	context->ClearDepth = (W3D_Double)depth;
}

void GLClear(GLcontext context, GLbitfield mask)
{
	//LOG(1, glClear, "%d", mask);
	if (context->w3dLocked == GL_FALSE)
		W3D_LockHardware(context->w3dContext);

	if (mask & GL_COLOR_BUFFER_BIT)
	{
		W3D_ClearDrawRegion(context->w3dContext, context->ClearColor);
	}


	if (mask & GL_DEPTH_BUFFER_BIT)
	{
		W3D_ClearZBuffer(context->w3dContext, &(context->ClearDepth));
	}


	if (context->w3dLocked == GL_FALSE)
		W3D_UnLockHardware(context->w3dContext);
}

void MGLLockMode(GLcontext context, GLenum lockMode)
{
#ifdef AUTOMATIC_LOCKING_ENABLE
	context->LockMode = lockMode;
#endif
}

GLboolean MGLLockBack(GLcontext context, MGLLockInfo *info)
{
	ULONG error;
	
	if (context->w3dLocked == GL_TRUE)
	{
		error = W3D_SUCCESS;
	}
	else
	{
		error = W3D_LockHardware(context->w3dContext);
	}

	if (error != W3D_SUCCESS)
	{
		return GL_FALSE;
	}
	else
	{
		context->w3dLocked = GL_TRUE;

#ifdef AUTOMATIC_LOCKING_ENABLE
//surgeon:	if(context->LockMode == MGL_LOCK_SMART)
                TMA_Start(&(context->LockTime));
#endif

		if (info)
		{
			info->width = context->w3dContext->width;
			info->height = context->w3dContext->height;
			info->depth = context->w3dContext->depth;
			info->pixel_format = context->w3dContext->format;
			info->base_address = context->w3dContext->drawmem;
			info->pitch = context->w3dContext->bprow;
		}
	}

	return GL_TRUE;
}

GLboolean MGLLockDisplay(GLcontext context)
{
	ULONG error;
	//LOG(1, mglLockDisplay, "");
#ifndef AUTOMATIC_LOCKING_ENABLE
	if (context->w3dLocked == GL_TRUE) return GL_TRUE;

	error = W3D_LockHardware(context->w3dContext);

	if (error == W3D_SUCCESS)
	{
		context->w3dLocked = GL_TRUE;
		return GL_TRUE;
	}
	else
	{
		switch(error)
		{
			case W3D_NOTVISIBLE: printf("[MGLLockDisplay] Bitmap not visible\n"); break;
			default: printf("[MGLLockDisplay] Error %d while locking\n", error); break;
		}
		return GL_FALSE;
	}
#else
	if (context->w3dLocked == GL_TRUE) return GL_TRUE; // nothing to do if we are already locked

	switch(context->LockMode)
	{
		case MGL_LOCK_MANUAL:
			error = W3D_LockHardware(context->w3dContext);
			if (error == W3D_SUCCESS)
			{
				context->w3dLocked = GL_TRUE;
				return GL_TRUE;
			}
			break;
		case MGL_LOCK_AUTOMATIC: // These modes do not require the lock right here.
		case MGL_LOCK_SMART:
			return GL_TRUE;
			break;
	}
	printf("[MGLLockDisplay] Unable to lock\n");
	return GL_FALSE;            // If we got here, there was an error
#endif
}

void MGLUnlockDisplay(GLcontext context)
{
	//LOG(1, mglUnlockDisplay, "");
#ifndef AUTOMATIC_LOCKING_ENABLE
	if (context->w3dLocked == GL_FALSE) return;
	W3D_UnLockHardware(context->w3dContext);
	context->w3dLocked = GL_FALSE;
#else
	if (context->w3dLocked == GL_FALSE) return;
	switch(context->LockMode)
	{
		case MGL_LOCK_AUTOMATIC:
			break;
		case MGL_LOCK_SMART:
		case MGL_LOCK_MANUAL:
			W3D_UnLockHardware(context->w3dContext);
			break;
	}
	context->w3dLocked = GL_FALSE;
#endif
}

void MGLEnableSync(GLcontext context, GLboolean enable)
{
	context->DoSync = enable;
}

void MGLSwitchDisplay(GLcontext context)
{
	int nowbuf = context->BufNr;

	MGLUnlockDisplay(context);
	
	if (!context->w3dBitMap) // Fullscreen mode
	{
		context->BufNr++;
		if (context->BufNr == context->NumBuffers)
			context->BufNr = 0;

		/*
		** At this place, nowbuf contains the buffer we where drawing to.
		** BufNr is the next drawing buffer.
		** We switch nowbof to the be the display buffer, and set
		** the draw region to the new BufNr
		*/

		// FIXME: This may cause a context switch orgy, maybe make it 68k
		// Make nowbuf current display
		context->Buffers[nowbuf]->sb_DBufInfo->dbi_SafeMessage.mn_ReplyPort = NULL;
		while (!ChangeScreenBuffer(context->w3dScreen, context->Buffers[nowbuf]));

		// Make BufNr the new draw area

		W3D_SetDrawRegion(context->w3dContext, context->Buffers[context->BufNr]->sb_BitMap,
			0, &(context->scissor));
	
		if (context->DoSync)
		{
			struct ViewPort *vp = &(context->w3dScreen->ViewPort);
			WaitBOVP(vp);
		}
	}
	else
	{   // Windowed mode
		ClipBlit(context->w3dRastPort,0,0,
			context->w3dWindow->RPort, context->w3dWindow->BorderLeft,
			context->w3dWindow->BorderTop,
			context->w3dWindow->Width-context->w3dWindow->BorderLeft-context->w3dWindow->BorderRight,
			context->w3dWindow->Height-context->w3dWindow->BorderTop-context->w3dWindow->BorderBottom,
			0xC0);
	}
}



//Multitexture buffer:

extern void FreeMtex();
extern GLboolean AllocMtex(int size);

GLboolean MGLInitContext(GLcontext context)
{
	int i;

	context->CurrentPrimitive   = GL_BASE;
	context->CurrentError       = GL_NO_ERROR;

/*
allocate w array that is large enough to cope with almost any texcoordstride - this array is used for all textured, unclipped primitives that go theough the vetexarray pipeline
*/
 
	context->WBuffer	    =
malloc(64*newVertexBufferSize);
	if (!context->WBuffer)
		return GL_FALSE;

	//this is for glArrayElement and for glDrawElements index-conversion:

	context->ElementIndex	    =
malloc(sizeof(UWORD)*(newVertexBufferSize));

	if (!context->ElementIndex)
		return GL_FALSE;

	context->VertexBuffer       = malloc(sizeof(MGLVertex)*newVertexBufferSize);
	if (!context->VertexBuffer)
		return GL_FALSE;

	context->NormalBuffer       = malloc(sizeof(MGLNormal)*newVertexBufferSize);
	if (!context->NormalBuffer)
		return GL_FALSE;

	context->VertexBufferSize   = (GLuint)newVertexBufferSize;
	context->VertexBufferPointer = 0;

	//GL_MGL_ARB_multitexture: draw.c
	if(!AllocMtex(newMTBufferSize))
		return GL_FALSE;


	context->NormalBufferPointer = 0;

	context->NormalBuffer[0].x = 0.f;
	context->NormalBuffer[0].y = 0.f;
	context->NormalBuffer[0].z = 0.f;


	context->TexBufferSize      = newTextureBufferSize;
	context->w3dTexBuffer       = malloc(sizeof(W3D_Texture *) * newTextureBufferSize);
	context->GeneratedTextures  = malloc(sizeof(GLubyte) * newTextureBufferSize);

	if (!context->w3dTexBuffer || !context->GeneratedTextures)
		return GL_FALSE;


	context->w3dTexMemory       = malloc(sizeof(GLubyte *) * newTextureBufferSize);
	if (!context->w3dTexMemory)
		return GL_FALSE;

    // Indicate unbound texture object(s):

	context->CurrentBinding  = 0;
	context->VirtualBinding  = 0;
	context->ArrayTexBound	 = GL_FALSE; //repeated by glEnd();

	context->ActiveTexture   = 0;
	context->VirtualTexUnits = 0;  //disable multitex

	for (i=0; i<newTextureBufferSize; i++)
	{
		context->w3dTexBuffer[i]	= NULL;
		context->w3dTexMemory[i]	= NULL;
		context->GeneratedTextures[i]   = 0;
	}

	context->CurrentTexS = context->CurrentTexT = 0.0;
	context->CurrentTexQ = 1.0;
	context->CurrentTexQValid = GL_FALSE;

	context->PackAlign = context->UnpackAlign = 4;

	context->AlphaTest_State    = GL_FALSE;
	context->Blend_State        = GL_FALSE;
	context->TextureGenS_State  = GL_FALSE;
	context->TextureGenT_State  = GL_FALSE;
	context->Fog_State          = GL_FALSE;
	context->Scissor_State      = GL_FALSE;
	context->CullFace_State     = GL_FALSE;
	context->DepthTest_State    = GL_FALSE;
	context->PointSmooth_State  = GL_FALSE;
	context->Dither_State       = GL_TRUE;
	context->ZOffset_State      = GL_FALSE;

	context->FogDirty           = GL_FALSE;
	context->FogStart           = 1.0;
	context->FogEnd             = 0.0;

	for (i=0; i<MAX_TEXUNIT; i++)
	{
	    context->Texture2D_State[i]	= GL_FALSE;
	    context->TexEnv[i]		= GL_MODULATE;
	}


	context->CurTexEnv = 0;

	context->MinFilter = GL_NEAREST;
	context->MagFilter = GL_NEAREST;
	context->WrapS     = GL_REPEAT;
	context->WrapT     = GL_REPEAT;

	context->w3dFog.fog_start   = 1.0;
	context->w3dFog.fog_end     = 0.1;
	context->w3dFog.fog_density = 1.0;
	context->w3dFog.fog_color.r = 0.0;
	context->w3dFog.fog_color.g = 0.0;
	context->w3dFog.fog_color.b = 0.0;
	context->FogRange           = 1.0;

	context->CurrentCullFace    = GL_BACK;
	context->CurrentFrontFace   = GL_CCW;
	context->CurrentCullSign    = 1;
//Surgeon begin
	context->CurrentColor.r = 1.0;
	context->CurrentColor.g = 1.0;
	context->CurrentColor.b = 1.0;
	context->CurrentColor.a = 1.0;
	context->UpdateCurrentColor = GL_TRUE;
//Surgeon end

	context->ShadeModel         = GL_SMOOTH;
	context->DepthMask          = GL_TRUE;

	context->ClearDepth         = 1.0;

#ifdef AUTOMATIC_LOCKING_ENABLE
	context->LockMode = MGL_LOCK_MANUAL;
#endif

	context->NoMipMapping = newNoMipMapping;
	context->NoFallbackAlpha = newNoFallbackAlpha;

	context->Idle = NULL;
	context->MouseHandler = NULL;
	context->SpecialHandler = NULL;
	context->KeyHandler = NULL;

	context->SrcAlpha = 0;
	context->DstAlpha = 0;
	context->AlphaFellBack = GL_FALSE;

	context->WOne_Hint = GL_FALSE;
	context->FixpointTrans_Hint = GL_FALSE; //Surgeon

	context->ZOffset = 0.0;

	context->PaletteData = malloc(4*256);
	context->PaletteSize = 0;
	context->PaletteFormat = 0;

/* Begin Joe Sera Sept 23 2000 */
	context->CurPolygonMode      = GL_FILL ;
	context->CurShadeModel       = GL_SMOOTH ;
	context->CurBlendSrc         = GL_ONE ;
	context->CurBlendDst         = GL_ZERO ;
	context->CurUnpackRowLength  = 0 ;
	context->CurUnpackSkipPixels = 0 ;
	context->CurUnpackSkipRows   = 0 ;
/* End Joe Sera Sept 23 2000 */

/* Begin Joe Sera Oct. 21, 2000 */
	context->CurWriteMask = GL_TRUE ;
	context->CurDepthTest = GL_FALSE ;
/* End Joe Sera Oct. 21, 2000 */

	/* Vertex array stuff */
	context->ClientState        = 0;

//Surgeon:
        context->VertexArrayPipeline  = GL_TRUE;

        context->ArrayPointer.colors = (UBYTE *)&context->VertexBuffer->v.color;
        context->ArrayPointer.colorstride = sizeof(MGLVertex);
        context->ArrayPointer.colormode = W3D_COLOR_FLOAT | W3D_CMODE_RGBA; //type and size

        context->ArrayPointer.texcoords = (UBYTE *)&context->VertexBuffer->v.u;
        context->ArrayPointer.texcoordstride = sizeof(MGLVertex);
        context->ArrayPointer.w_buffer = (UBYTE *)&context->VertexBuffer->v.w;
        context->ArrayPointer.w_off = -4;

        context->ArrayPointer.verts = (UBYTE *)&context->VertexBuffer->v.x;
        context->ArrayPointer.vertexstride = sizeof(MGLVertex);
        context->ArrayPointer.vertexmode = W3D_VERTEX_F_F_D;

        context->ArrayPointer.lockfirst = 0;
        context->ArrayPointer.locksize = 0;
        context->ArrayPointer.transformed = 0;
        context->ArrayPointer.state = 0; //pipeline state


	  // set Vertex Array texture to NULL:
        context->w3dContext->CurrentTex[0] = NULL;

	  // set constant elements of vertexpointers once and for all
        context->w3dContext->CPFlags = 0;
        context->w3dContext->VPFlags = 0;
        context->w3dContext->TPFlags[0] = W3D_TEXCOORD_NORMALIZED;
        context->w3dContext->TPVOffs[0] = 4;

//End surgeon	  

#if 0
	context->DrawElementsHook   = 0;
	context->DrawArraysHook     = 0;
#endif
	context->VertexArrayPipeline  = GL_TRUE;

	/* Area: All triangles smaller than this will not be drawn */
	//Surgeon: to prevent gaps, triangle-mesh areas are considered coherently

	context->MinTriArea         = 0.5f;

	context->CurrentPointSize     = 1.f;

	//We set all clipflags by default:

	context->ClipFlags = (MGL_CLIP_NEGW | MGL_CLIP_FRONT | MGL_CLIP_BACK | MGL_CLIP_RIGHT | MGL_CLIP_LEFT | MGL_CLIP_BOTTOM | MGL_CLIP_TOP);

	//The 3 first are 'must' clipflags.
	//The 4 last are set by glViewport, according to
	//state of guardband clipping

	context->GuardBand	    = newGuardBand;

	GLMatrixInit(context);

	return GL_TRUE;
}

void *MGLCreateContext(int offx, int offy, int w, int h)
{
	GLcontext context;

	context = malloc(sizeof(struct GLcontext_t));
	if (!context)
	{
//		printf("Error: Can't get %d bytes of memory for context\n", sizeof(struct GLcontext_t));
		printf("Error: Can't get %lu bytes of memory for context\n", sizeof(struct GLcontext_t)); //OF

		return NULL;
	}

	memset(context, 0,  sizeof(struct GLcontext_t));

	if (newWindowMode == GL_FALSE)
	{
		if (GL_FALSE == vid_OpenDisplay(context, w,h, MGL_SM_BESTMODE))
		{
			vid_CloseDisplay(context);
			free(context);
			printf("Error: opening of display failed\n");
			return NULL;
		}
	}
	else
	{
		if (GL_FALSE == vid_OpenWindow(context, w,h))
		{
			vid_CloseWindow(context);
			free(context);
			printf("Error: opening of display failed\n");
			return NULL;
		}
	}

	if (GL_FALSE == MGLInitContext(context))
	{
		printf("Error: initalisation of context failed\n");
		MGLDeleteContext(context);
		return NULL;
	}

	GLDepthRange(context, 0.0, 1.0);
	GLViewport(context, offx, offy, w, h);
	GLClearColor(context, 1.0, 1.0, 1.0, 1.0);

	// Hey, folks, I can do that because I know what I am doing.
	// You should never read fields from the W3D context that are not
	// marked as readable...
	context->w3dChipID = context->w3dContext->CurrentChip;

	return context;
}


void MGLDeleteContext(GLcontext context)
{
	GLint current,peak;

	if( !context ) return; //Olivier Fabre

	if (context->w3dBitMap) vid_CloseWindow(context);
	else                    vid_CloseDisplay(context);

	FreeMtex();

	if (context->NormalBuffer) free(context->NormalBuffer);

	if (context->WBuffer) free(context->WBuffer);

	if (context->ElementIndex) free(context->ElementIndex);

	if (context->VertexBuffer) free(context->VertexBuffer);

	if (context->w3dTexBuffer) free(context->w3dTexBuffer);

	if (context->GeneratedTextures) free (context->GeneratedTextures);

	MGLTexMemStat(context, &current, &peak);

	if (CyberGfxBase) CloseLibrary(CyberGfxBase);
	CyberGfxBase = NULL;

	free(context);
}

#define ED (flag == GL_TRUE?W3D_ENABLE:W3D_DISABLE)

extern void tex_SetEnv(GLcontext context, GLenum env);

void MGLSetState(GLcontext context, const GLenum cap, const GLboolean flag)//surgeon: const
{
	int active = context->ActiveTexture;

	//LOG(2, mglSetState, "(Enable/Disable) %d -> %d\n", cap, flag);

	switch(cap)
	{
		case GL_ALPHA_TEST:
			//surgeon: added state-check
			if(context->AlphaTest_State != flag)
			{
			context->AlphaTest_State = flag;
			W3D_SetState(context->w3dContext, W3D_ALPHATEST, ED);
			}
		break;
		case GL_BLEND:
			//surgeon: added state-check
			if(context->Blend_State != flag)
			{
			context->Blend_State = flag;
			W3D_SetState(context->w3dContext, W3D_BLENDING, ED);
			}
		break;
		case GL_TEXTURE_2D:

			if(active == 0 && context->Texture2D_State[0] != flag)
			{
			      W3D_SetState(context->w3dContext, W3D_TEXMAPPING, ED);
			}

			context->Texture2D_State[active] = flag;

		break;
		case GL_TEXTURE_GEN_S:
			context->TextureGenS_State = flag;
			break;
		case GL_TEXTURE_GEN_T:
			context->TextureGenT_State = flag;
			break;
		case GL_FOG:
			context->FogDirty = GL_TRUE;
			context->Fog_State = flag;
			W3D_SetState(context->w3dContext, W3D_FOGGING, ED);
			break;
		case GL_SCISSOR_TEST:
			context->Scissor_State = flag;
			if(flag == GL_FALSE) //restore
			W3D_SetScissor(context->w3dContext, &(context->scissor));
			break;
		case GL_CULL_FACE:
			context->CullFace_State = flag;

			break;
		case GL_DEPTH_WRITEMASK:
			context->CurWriteMask = flag ;
		break ;
		case GL_DEPTH_TEST:
			context->CurDepthTest = flag ;
			context->DepthTest_State = flag;

			W3D_SetState(context->w3dContext, W3D_ZBUFFER, ED);
			if (flag == GL_TRUE)
			{
				if (context->DepthMask)
					W3D_SetState(context->w3dContext, W3D_ZBUFFERUPDATE, W3D_ENABLE);
			}
			else
			{
				W3D_SetState(context->w3dContext, W3D_ZBUFFERUPDATE, W3D_DISABLE);
			}

			break;
		case GL_DITHER:
			context->Dither_State = flag;
			W3D_SetState(context->w3dContext, W3D_DITHERING, ED);
			break;
		case GL_POINT_SMOOTH:
			context->PointSmooth_State = flag;
			W3D_SetState(context->w3dContext, W3D_ANTI_POINT, ED);
			break;
		case MGL_PERSPECTIVE_MAPPING:
			W3D_SetState(context->w3dContext, W3D_PERSPECTIVE, ED);
			break;
		case MGL_Z_OFFSET:
			context->ZOffset_State = flag;
			break;
		case MGL_ARRAY_TRANSFORMATIONS:
			context->VertexArrayPipeline = flag;
			break;
		default:
			break;
	}
}
#undef ED

GLint mglGetSupportedScreenModes(MGLScreenModeCallback CallbackFn)
{
	W3D_ScreenMode *Modes = W3D_GetScreenmodeList();
	W3D_ScreenMode *Cursor;
	MGLScreenMode   sMode;
	GLboolean       retval;

	if (Modes == NULL)
	{
		return MGL_SM_BESTMODE;
	}

	Cursor = Modes;
	while (Cursor)
	{
		sMode.id        = (GLint)Cursor->ModeID;
		sMode.width     = (GLint)Cursor->Width;
		sMode.height    = (GLint)Cursor->Height;
		sMode.bit_depth = (GLint)Cursor->Depth;
		strncpy(sMode.mode_name, Cursor->DisplayName, MGL_MAX_MODE);
		retval = CallbackFn(&sMode);
		if (retval == GL_TRUE)
		{
			W3D_FreeScreenmodeList(Modes);
			return sMode.id;
		}
		Cursor = Cursor->Next;
	}
	W3D_FreeScreenmodeList(Modes);
	return MGL_SM_BESTMODE;
}

void *MGLCreateContextFromID(GLint id, GLint *width, GLint *height)
{
	GLint w,h;
	GLcontext context;

	context = malloc(sizeof(struct GLcontext_t));
	if (!context)
	{
//		printf("Error: Can't get %d bytes of memory for context\n", sizeof(struct GLcontext_t));
		printf("Error: Can't get %lu bytes of memory for context\n", sizeof(struct GLcontext_t)); //OF

		return NULL;
	}

	memset(context, 0, sizeof(struct GLcontext_t));

	if (id == MGL_SM_WINDOWMODE) newWindowMode = GL_TRUE;

	if (newWindowMode == GL_FALSE)
	{
		if (GL_FALSE == vid_OpenDisplay(context, -1,-1, (ULONG)id))
		{
			vid_CloseDisplay(context);
			free(context);
			printf("Error: opening of display failed\n");
			return NULL;
		}
	}
	else
	{
		// Use the other context creation function for Windowed mode.
		return NULL;
	}

	if (GL_FALSE == MGLInitContext(context))
	{
		printf("Error: initalisation of context failed\n");
		MGLDeleteContext(context);
		return NULL;
	}

	w = context->w3dScreen->Width;
	h = context->w3dScreen->Height;
	*width = w;
	*height = h;

	GLDepthRange(context, 0.0, 1.0);
	GLViewport(context, 0, 0, w, h);
	GLClearColor(context, 1.0, 1.0, 1.0, 1.0);

	// Hey, folks, I can do that because I know what I am doing.
	// You should never read fields from the W3D context that are not
	// marked as readable...
	context->w3dChipID = context->w3dContext->CurrentChip;

	return context;
}

void MGLMinTriArea(GLcontext context, GLfloat area)
{
	context->MinTriArea = area;
}
