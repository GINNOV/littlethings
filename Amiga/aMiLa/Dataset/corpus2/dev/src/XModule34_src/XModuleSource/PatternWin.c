/*
**	PatternWin.c
**
**	Copyright (C) 1994,95 Bernardo Innocenti
**
**	Parts of the code have been inspired by ScrollerWindow 0.3 demo
**	Copyright © 1994 Christoph Feck, TowerSystems.
**
**	Pattern editor handling functions.
**
**
**	Diagram of objects interconnection:
**
**
**	           ScrollButtonClass objects
**	+----------+ +---------+ +----------+ +----------+
**	| UpButton | | DnButton| | SxButton | | DxButton |
**	+----------+ +---------+ +----------+ +----------+
**	 | GA_ID =   | GA_ID =    | GA_ID =    | GA_ID =
**	 | PATTA_Up  | PATTA_Down | PATTA_Left | PATTA_Right
**	 |           |            |            |
**	 |  +--------+            |            |
**	 |  |  +------------------+            |
**	 |  |  |  +----------------------------+
**	 |  |  |  |      propgclass  object                       icclass object
**	 |  |  |  |      +----------------+                     +----------------+
**	 |  |  |  |   +--|     HSlider    |<--------------------| Editor2HSlider |
**	 |  |  |  |   |  +----------------+  PATTA_LeftTrack =  +----------------+
**	 |  |  |  |   | PGA_Top =            PGA_Top                    ^
**	 |  |  |  |   | PATTA_TopLine        PATTA_DisplayTracks =      |
**	 |  |  |  |   |                      PGA_Visible                |
**	 |  |  |  |   |                   +-----------------------------+
**	 V  V  V  V   V                   |
**	+---------------+            ************
**	|  PattEditGad  |----------->*   Model  *----------------> IDCMPUPDATE
**	+---------------+            ************ PATTA_CursLine   to PatternWin
**	  ^                               |       PATTA_CursTrack
**	  | propgclass object             |
**	  | PGA_Top = PATTA_TopLine       V icclass object
**	+----------------+        +----------------+
**	|    VSlider     |<-------| Editor2VSlider | PATTA_TopLine      = PGA_Top
**	+----------------+        +----------------+ PATTA_DisplayLines = PGA_Visible
*/


#include <intuition/intuition.h>
#include <intuition/icclass.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>
#include <libraries/iffparse.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/layers_protos.h>
#include <clib/utility_protos.h>
#include <clib/dos_protos.h>
#include <clib/iffparse_protos.h>
#include <clib/diskfont_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/layers_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/iffparse_pragmas.h>
#include <pragmas/diskfont_pragmas.h>

#include "Gui.h"
#include "XModule.h"
#include "PattEditClass.h"
#include "CustomClasses.h"


/* Gadget IDs */
enum {
	GD_PattEdit,
	GD_UpButton,
	GD_DnButton,
	GD_SxButton,
	GD_DxButton,
	GD_VSlider,
	GD_HSlider,

	Pattern_CNT
};


/* Local function prototypes */

static struct Image		*NewImageObject	(ULONG which);
static struct Gadget	*CreatePattEdit	(Class *cl, struct NewGadget *ng);
static struct Gadget	*CreateUpButton	(Class *cl, struct NewGadget *ng);
static struct Gadget	*CreateDnButton	(Class *cl, struct NewGadget *ng);
static struct Gadget	*CreateSxButton	(Class *cl, struct NewGadget *ng);
static struct Gadget	*CreateDxButton	(Class *cl, struct NewGadget *ng);
static struct Gadget	*CreateVSlider	(Class *cl, struct NewGadget *ng);
static struct Gadget	*CreateHSlider	(Class *cl, struct NewGadget *ng);

static void HandlePatternIDCMP	(void);
static void PatternLoad			(STRPTR name);

static void PatternClicked		(void);
static void VSliderClicked		(void);

static void PatternMiOpen		(void);
static void PatternMiSave		(void);
static void PatternMiSaveAs		(void);
static void PatternMiSize		(void);
static void PatternMiMark		(void);
static void PatternMiCut		(void);
static void PatternMiCopy		(void);
static void PatternMiPaste		(void);
static void PatternMiErase		(void);
static void PatternMiUndo		(void);
static void PatternMiRedo		(void);
static void PatternMiSettings	(void);



/* Local data */

static struct Library	*PattEditBase		= NULL;
static Class			*ScrollButtonClass	= NULL;
static struct TextFont	*EditorTextFont		= NULL;
static Object			*Model				= NULL,
						*Editor2VSlider		= NULL,
						*Editor2HSlider		= NULL;
static WORD				 SizeWidth, SizeHeight;

static UBYTE WindowTitle[MAXSONGNAME+MAXPATTNAME+25];


struct PattSwitches PattSwitches =
{
	1,	2, 2,	/* TextPen,			LinesPen, TinyLinesPen	*/
	32,	4096,	/* MaxUndoLevels,	MaxUndoMem				*/
	0,			/* Flags									*/
	0,	1,		/* AdvanceTracks,	AdvanceLines			*/
	0,	0,		/* VScrollerPlace,	HScrollerPlace,			*/
	0,	0		/* ClipboardUnit,	BackDropWin				*/
};


static LONG MapVSlider2Editor[] =
{
	PGA_Top,				PATTA_TopLine,
	TAG_DONE
};

static LONG MapHSlider2Editor[] =
{
	PGA_Top,				PATTA_LeftTrack,
	TAG_DONE
};

static LONG MapEditor2VSlider[] =
{
	PATTA_TopLine,			PGA_Top,
	PATTA_DisplayLines,		PGA_Visible,
	TAG_DONE
};

static LONG MapEditor2HSlider[] =
{
	PATTA_LeftTrack,		PGA_Top,
	PATTA_DisplayTracks,	PGA_Visible,
	TAG_DONE
};

static LONG MapUp2Editor[] =
{
	GA_ID,		PATTA_Up,
	TAG_DONE
};

static LONG MapDn2Editor[] =
{
	GA_ID,		PATTA_Down,
	TAG_DONE
};

static LONG MapSx2Editor[] =
{
	GA_ID,		PATTA_Left,
	TAG_DONE
};

static LONG MapDx2Editor[] =
{
	GA_ID,		PATTA_Right,
	TAG_DONE
};



static struct Gadget *PatternGadgets[Pattern_CNT];

static struct NewMenu PatternNewMenu[] = {
	NM_TITLE, (STRPTR)"Project", NULL, 0, NULL, NULL,
	NM_ITEM, (STRPTR)"Open Pattern...", (STRPTR)"O", 0, 0L, (APTR)PatternMiOpen,
	NM_ITEM, (STRPTR)"SavePattern", (STRPTR)"S", 0, 0L, (APTR)PatternMiSave,
	NM_ITEM, (STRPTR)"Save Pattern As...", (STRPTR)"A", 0, 0L, (APTR)PatternMiSaveAs,
	NM_ITEM, (STRPTR)NM_BARLABEL, NULL, 0, 0L, NULL,
	NM_ITEM, (STRPTR)"Size Pattern...", NULL, 0, 0L, (APTR)PatternMiSize,
	NM_TITLE, (STRPTR)"Edit", NULL, 0, NULL, NULL,
	NM_ITEM, (STRPTR)"Mark", (STRPTR)"B", 0, 0L, (APTR)PatternMiMark,
	NM_ITEM, (STRPTR)"Cut", (STRPTR)"X", 0, 0L, (APTR)PatternMiCut,
	NM_ITEM, (STRPTR)"Copy", (STRPTR)"C", 0, 0L, (APTR)PatternMiCopy,
	NM_ITEM, (STRPTR)"Paste", (STRPTR)"V", 0, 0L, (APTR)PatternMiPaste,
	NM_ITEM, (STRPTR)"Erase", (STRPTR)"E", 0, 0L, (APTR)PatternMiErase,
	NM_ITEM, (STRPTR)NM_BARLABEL, NULL, 0, 0L, NULL,
	NM_ITEM, (STRPTR)"Undo", (STRPTR)"u", 0, 0L, (APTR)PatternMiUndo,
	NM_ITEM, (STRPTR)"Redo", (STRPTR)"r", 0, 0L, (APTR)PatternMiRedo,
	NM_TITLE, (STRPTR)"Settings", NULL, 0, NULL, NULL,
	NM_ITEM, (STRPTR)"Editor Settings...", (STRPTR)"P", 0, 0L, (APTR)PatternMiSettings,
	NM_END, NULL, NULL, 0, 0L, NULL };

static UWORD PatternGTypes[] =
{
	GENERIC_KIND,
	GENERIC_KIND,
	GENERIC_KIND,
	GENERIC_KIND,
	GENERIC_KIND,
	GENERIC_KIND,
	GENERIC_KIND
};

static struct NewGadget PatternNGad[] = {
	0, 0, 0, 0, NULL, NULL, GD_PattEdit, 0, NULL, (APTR)PatternClicked,
	0, 0, 0, 0, NULL, NULL, GD_UpButton, 0, NULL, (APTR)VSliderClicked,
	0, 0, 0, 0, NULL, NULL, GD_DnButton, 0, NULL, (APTR)VSliderClicked,
	0, 0, 0, 0, NULL, NULL, GD_SxButton, 0, NULL, (APTR)VSliderClicked,
	0, 0, 0, 0, NULL, NULL, GD_DxButton, 0, NULL, (APTR)VSliderClicked,
	0, 0, 0, 0, NULL, NULL, GD_VSlider,  0, NULL, (APTR)VSliderClicked,
	0, 0, 0, 0, NULL, NULL, GD_HSlider,  0, NULL, (APTR)VSliderClicked
};

static ULONG PatternGTags[] = {
	XMGAD_BoopsiClass, TRUE,	XMGAD_SetupFunc, (ULONG)CreatePattEdit, TAG_DONE,
	XMGAD_BoopsiClass, TRUE,	XMGAD_SetupFunc, (ULONG)CreateUpButton, TAG_DONE,
	XMGAD_BoopsiClass, TRUE,	XMGAD_SetupFunc, (ULONG)CreateDnButton, TAG_DONE,
	XMGAD_BoopsiClass, TRUE,	XMGAD_SetupFunc, (ULONG)CreateSxButton, TAG_DONE,
	XMGAD_BoopsiClass, TRUE,	XMGAD_SetupFunc, (ULONG)CreateDxButton, TAG_DONE,
	XMGAD_BoopsiClass, TRUE,	XMGAD_SetupFunc, (ULONG)CreateVSlider, TAG_DONE,
	XMGAD_BoopsiClass, TRUE,	XMGAD_SetupFunc, (ULONG)CreateHSlider, TAG_DONE
};

struct WinUserData PatternWUD =
{
	{ NULL, NULL },
	NULL,
	PatternGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	NULL,
	ClosePatternWindow,
	NULL,
	HandlePatternIDCMP,
	NULL,

	{ 0, 50, 400, 150 },
	PatternNewMenu,
	PatternGTypes,
	PatternNGad,
	PatternGTags,
	Pattern_CNT,
	WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_ACTIVATE|
		WFLG_SIZEGADGET|WFLG_SIZEBRIGHT|WFLG_SIZEBBOTTOM|WFLG_SIMPLE_REFRESH|WFLG_NOCAREREFRESH,
	IDCMP_MENUPICK|IDCMP_CLOSEWINDOW|IDCMP_ACTIVEWINDOW|IDCMP_INTUITICKS|IDCMP_IDCMPUPDATE,
	"Pattern Editor"
};



/* Creates a sysiclass object. */
static struct Image *NewImageObject (ULONG which)
{
	return ((struct Image *)NewObject (NULL, SYSICLASS,
		SYSIA_DrawInfo,	DrawInfo,
		SYSIA_Which,	which,
		SYSIA_Size,		Scr->Flags & SCREENHIRES ? SYSISIZE_MEDRES : SYSISIZE_LOWRES,
		TAG_DONE));

	/* NB: SYSISIZE_HIRES not yet supported. */
}



static struct Gadget *CreatePattEdit (Class *cl, struct NewGadget *ng)
{
	ULONG numcols = Scr->RastPort.BitMap->Depth;

	if (PattSwitches.TextPen >= numcols)
		PattSwitches.TextPen = 1;

	if (PattSwitches.LinesPen >= numcols)
		PattSwitches.LinesPen = 2;

	if (PattSwitches.TinyLinesPen >= numcols)
		PattSwitches.TinyLinesPen = 2;

	if (EditorTextFont = OpenDiskFont (&EditorAttr))
	{
		/* We do not initialize PATTA_Pattern right now because
		 * it is done later by UpdatePattern().
		 */
		return ((struct Gadget *)NewObject (NULL, PATTEDITCLASS,
			GA_ID,				ng->ng_GadgetID,
			GA_UserData,		ng->ng_UserData,
			GA_Left,			OffX,
			GA_Top,				OffY,
			GA_RelWidth,		- OffX - SizeWidth,
			GA_RelHeight,		- OffY - SizeHeight,

			PATTA_TextFont,		EditorTextFont,
			PATTA_AdvanceCurs,	(PattSwitches.AdvanceTracks << 16) | PattSwitches.AdvanceLines,
			PATTA_MaxUndoLevels, PattSwitches.MaxUndoLevels,
			PATTA_MaxUndoMem,	PattSwitches.MaxUndoMem,
			PATTA_Flags,		PattSwitches.Flags,
			PATTA_LinesPen,		PattSwitches.LinesPen,
			PATTA_TextPen,		PattSwitches.TextPen,
			PATTA_Flags,		PattSwitches.Flags,
			TAG_DONE));
	}

	return NULL;
}



static struct Gadget *CreateUpButton (Class *cl, struct NewGadget *ng)
{
	struct Gadget	*UpButton;
	struct Image	*UpImage;


	if (!(UpImage = NewImageObject (UPIMAGE)))
		return NULL;

	if (!(UpButton = (struct Gadget *)NewObject (ScrollButtonClass, NULL,
		GA_ID,				ng->ng_GadgetID,
		GA_UserData,		ng->ng_UserData,
		GA_RelBottom,		- (UpImage->Height * 2) - SizeHeight + 1,
		GA_RelRight,		-SizeWidth + 1,
		GA_RightBorder,		TRUE,
		/* No need for GA_Width/Height.  buttongclass is smart :) */
		GA_Image,			UpImage,
		ICA_TARGET,			PatternGadgets[GD_PattEdit],
		ICA_MAP,			MapUp2Editor,
		TAG_DONE)))
		DisposeObject (UpImage);

	return UpButton;
}



static struct Gadget *CreateDnButton (Class *cl, struct NewGadget *ng)
{
	struct Gadget	*DnButton;
	struct Image	*DnImage;


	if (!(DnImage = NewImageObject (DOWNIMAGE)))
		return NULL;

	if (!(DnButton = (struct Gadget *)NewObject (ScrollButtonClass, NULL,
		GA_ID,				ng->ng_GadgetID,
		GA_UserData,		ng->ng_UserData,
		GA_RelBottom,		-DnImage->Height - SizeHeight + 1,
		GA_RelRight,		-SizeWidth + 1,
		GA_RightBorder,		TRUE,
		/* No need for GA_Width/Height.  buttongclass is smart :) */
		GA_Image,			DnImage,
		ICA_TARGET,			PatternGadgets[GD_PattEdit],
		ICA_MAP,			MapDn2Editor,
		TAG_DONE)))
		DisposeObject (DnImage);

	return DnButton;
}



static struct Gadget *CreateSxButton (Class *cl, struct NewGadget *ng)
{
	struct Gadget	*SxButton;
	struct Image	*SxImage;


	if (!(SxImage = NewImageObject (LEFTIMAGE)))
		return NULL;

	if (!(SxButton = (struct Gadget *)NewObject (ScrollButtonClass, NULL,
		GA_ID,				ng->ng_GadgetID,
		GA_UserData,		ng->ng_UserData,
		GA_RelBottom,		- SxImage->Height + 1,
		GA_RelRight,		- SizeWidth - (SxImage->Width * 2) + 1,
		GA_BottomBorder,	TRUE,
		/* No need for GA_Width/Height.  buttongclass is smart :) */
		GA_Image,			SxImage,
		ICA_TARGET,			PatternGadgets[GD_PattEdit],
		ICA_MAP,			MapSx2Editor,
		TAG_DONE)))
		DisposeObject (SxImage);

	return SxButton;
}



static struct Gadget *CreateDxButton (Class *cl, struct NewGadget *ng)
{
	struct Gadget	*DxButton;
	struct Image	*DxImage;


	if (!(DxImage = NewImageObject (RIGHTIMAGE)))
		return NULL;

	if (!(DxButton = (struct Gadget *)NewObject (ScrollButtonClass, NULL,
		GA_ID,				ng->ng_GadgetID,
		GA_UserData,		ng->ng_UserData,
		GA_RelBottom,		- DxImage->Height + 1,
		GA_RelRight,		- SizeWidth - DxImage->Width + 1,
		GA_BottomBorder,	TRUE,
		/* No need for GA_Width/Height.  buttongclass is smart :) */
		GA_Image,			DxImage,
		ICA_TARGET,			PatternGadgets[GD_PattEdit],
		ICA_MAP,			MapDx2Editor,
		TAG_DONE)))
		DisposeObject (DxImage);

	return DxButton;
}



static struct Gadget *CreateVSlider (Class *cl, struct NewGadget *ng)
{
	/* Borderless sliders do only look right with newlook screens */

	return ((struct Gadget *)NewObject (NULL, PROPGCLASS,
		GA_ID,				ng->ng_GadgetID,
		GA_UserData,		ng->ng_UserData,
		GA_Top,				OffY + 1,
		GA_RelRight,		- SizeWidth + Scr->WBorRight + 1,
		GA_Width,			SizeWidth - (Scr->WBorRight * 2),
		GA_RelHeight,		- OffY - Scr->WBorBottom - SizeHeight
							- PatternGadgets[GD_UpButton]->Height
							- PatternGadgets[GD_DnButton]->Height,
		GA_RightBorder,		TRUE,

		PGA_NewLook,		TRUE,
		PGA_Borderless,		((DrawInfo->dri_Flags & DRIF_NEWLOOK) && DrawInfo->dri_Depth != 1),
//		PGA_Total,			0,
//		PGA_Visible,		0,

		ICA_TARGET,	PatternGadgets[GD_PattEdit],
		ICA_MAP,	MapVSlider2Editor,

		TAG_DONE));
}



static struct Gadget *CreateHSlider (Class *cl, struct NewGadget *ng)
{
	struct Gadget	*HSlider;

	if (!(HSlider = (struct Gadget *)NewObject (NULL, PROPGCLASS,
		GA_ID,				ng->ng_GadgetID,
		GA_UserData,		ng->ng_UserData,
		GA_Left,			OffX - 1,
		GA_RelBottom,		- SizeHeight + Scr->WBorBottom + 1,
		GA_RelWidth,		- OffX - SizeWidth
							- PatternGadgets[GD_DxButton]->Width
							- PatternGadgets[GD_SxButton]->Width,
		GA_Height,			SizeHeight - (Scr->WBorBottom * 2),
		GA_BottomBorder,	TRUE,

		PGA_NewLook,		TRUE,
		PGA_Borderless,		((DrawInfo->dri_Flags & DRIF_NEWLOOK) && DrawInfo->dri_Depth != 1),
		PGA_Freedom,		FREEHORIZ,

		ICA_TARGET,			PatternGadgets[GD_PattEdit],
		ICA_MAP,			MapHSlider2Editor,

		TAG_DONE)))
		return NULL;


	/* Create the Model */
	if (Model = NewObject (NULL, MODELCLASS,
		ICA_TARGET,		ICTARGET_IDCMP,
		TAG_DONE))
	{
		/* Connect Editor to Model */
		SetAttrs (PatternGadgets[GD_PattEdit],
			ICA_TARGET, Model,
			TAG_DONE);

		if (Editor2VSlider = NewObject (NULL, ICCLASS,
			ICA_TARGET,	PatternGadgets[GD_VSlider],
			ICA_MAP,	MapEditor2VSlider,
			TAG_DONE))
		{
			/* Connect Model to VSlider */
			if (DoMethod (Model, OM_ADDMEMBER, Editor2VSlider))
			{
				if (Editor2HSlider = NewObject (NULL, ICCLASS,
					ICA_TARGET,	HSlider,
					ICA_MAP,	MapEditor2HSlider,
					TAG_DONE))
				{
					/* Connect Model to HSlider */
					if (DoMethod (Model, OM_ADDMEMBER, Editor2HSlider))
						return HSlider;
					else
						DisposeObject (Editor2HSlider);
				}
			}
			else
				DisposeObject (Editor2VSlider);
		}
	}

	/* NOTE: The model will also dispose its members. */
	DisposeObject (Model); Model = NULL;
	Editor2VSlider = NULL; Editor2HSlider = NULL;
	DisposeObject (HSlider);
	return NULL;
}



/* NO-OP backfilling hook.  Since we are going to redraw the whole window
 * anyway, we can disable backfilling.  This avoids ugly flashing while
 * resizing or revealing the window.
 *
 * This function has not the __saveds attribute because it makes no
 * references to external data.
 */

static ULONG __asm BFHookFunc (void)
{
	return 1;	/* Do nothing */
}

static struct Hook BFHook =
{
	NULL, NULL,
	BFHookFunc,
};



LONG OpenPatternWindow (void)
{
	struct Window *win = NULL;
	struct Image *sizeimage;

	if (PatternWUD.Win)
	{
		WindowToFront (PatternWUD.Win);
		ActivateWindow (PatternWUD.Win);
		return RETURN_OK;
	}

	if (!PattEditBase)
		PattEditBase = MyOpenLibrary (PATTEDITNAME, PATTEDITVERS);

	if (!ScrollButtonClass)
		ScrollButtonClass = InitScrollButtonClass();

	if (PattEditBase && ScrollButtonClass)
	{
		/* Create a SIZEIMAGE to get the correct size
		 * and position for the slider and for the buttons.
		 */

		if (!(sizeimage = NewImageObject (SIZEIMAGE)))
			return ERROR_NO_FREE_STORE;

		SizeWidth	= sizeimage->Width;
		SizeHeight	= sizeimage->Height;

		DisposeObject (sizeimage);


		if (win = MyOpenWindow (&PatternWUD))
		{
			/* Limit window flashing by providing a no-op hook for window
			 * backfilling.
			 */
			InstallLayerHook (win->WLayer, Kick30 ? ((struct Hook *)LAYERS_NOBACKFILL) : &BFHook);

			UpdatePattern();

			/* Allow window resizing.  Minimum size is chosen so that at least
			 * one line is visible.
			 */
			WindowLimits (win,
				win->BorderLeft + win->BorderRight + EditorTextFont->tf_XSize * (TRACKWIDTH + 4),
				win->BorderTop + win->BorderBottom + EditorTextFont->tf_YSize * 2,
				-1, -1);
		}
	}

	if (!win)
		/* Clean up all resources allocated so far */
		ClosePatternWindow();

	return !win;
}



void ClosePatternWindow (void)
{
	MyCloseWindow (PatternWUD.Win);

	/* NOTE: The model will also dispose its members. */
	DisposeObject (Model);	Model = NULL;
	Editor2VSlider = NULL;
	Editor2HSlider = NULL;

	DisposeObject (PatternGadgets[GD_VSlider]);
	PatternGadgets[GD_VSlider] = NULL;
	DisposeObject (PatternGadgets[GD_HSlider]);
	PatternGadgets[GD_HSlider] = NULL;

	if (PatternGadgets[GD_UpButton])
	{
		DisposeObject (PatternGadgets[GD_UpButton]->GadgetRender);
		DisposeObject (PatternGadgets[GD_UpButton]);
		PatternGadgets[GD_UpButton] = NULL;
	}

	if (PatternGadgets[GD_DnButton])
	{
		DisposeObject (PatternGadgets[GD_DnButton]->GadgetRender);
		DisposeObject (PatternGadgets[GD_DnButton]);
		PatternGadgets[GD_DnButton] = NULL;
	}

	if (PatternGadgets[GD_SxButton])
	{
		DisposeObject (PatternGadgets[GD_SxButton]->GadgetRender);
		DisposeObject (PatternGadgets[GD_SxButton]);
		PatternGadgets[GD_SxButton] = NULL;
	}

	if (PatternGadgets[GD_DxButton])
	{
		DisposeObject (PatternGadgets[GD_DxButton]->GadgetRender);
		DisposeObject (PatternGadgets[GD_DxButton]);
		PatternGadgets[GD_DxButton] = NULL;
	}


	DisposeObject (PatternGadgets[GD_PattEdit]);
	PatternGadgets[GD_PattEdit] = NULL;

	if (EditorTextFont)
	{
		CloseFont (EditorTextFont);
		EditorTextFont = NULL;
	}

	if (ScrollButtonClass)
	{
		FreeScrollButtonClass (ScrollButtonClass);
		ScrollButtonClass = NULL;
	}

	if (PattEditBase)
	{
		CloseLibrary (PattEditBase);
		PattEditBase = NULL;
	}
}



static void HandlePatternIDCMP (void)
{
	struct Window *win = IntuiMsg.IDCMPWindow;

	switch (IntuiMsg.Class)
	{
		case IDCMP_IDCMPUPDATE:
		{
			UWORD line, track;
			UWORD tlen, twidth;
			struct RastPort *rp;
			struct TextFont *oldfont;
			UBYTE buf[16];

			if ((line = GetTagData (PATTA_CursLine, -1, IntuiMsg.IAddress)) != -1)
			{
				track	= GetTagData (PATTA_CursTrack, -1, IntuiMsg.IAddress);

				SPrintf (buf, "   %ld, %ld", track, line);

				tlen = strlen (buf);	/* Couldn't get it from SPrintf()!! */

				rp = win->RPort;
				oldfont = rp->Font;
				SetFont (rp, DrawInfo->dri_Font);

				twidth = TextLength (rp, buf, tlen);

				if (win->Flags & WFLG_WINDOWACTIVE)
				{
					if (Kick30)
						SetABPenDrMd (rp, DrawInfo->dri_Pens[FILLTEXTPEN],
							DrawInfo->dri_Pens[FILLPEN], JAM2);
					else
					{
						SetAPen (rp, DrawInfo->dri_Pens[FILLTEXTPEN]);
						SetBPen (rp, DrawInfo->dri_Pens[FILLPEN]);
						SetDrMd (rp, JAM2);
					}
				}
				else
				{
					if (Kick30)
						SetABPenDrMd (rp, DrawInfo->dri_Pens[TEXTPEN],
							DrawInfo->dri_Pens[BACKGROUNDPEN], JAM2);
					else
					{
						SetAPen (rp, DrawInfo->dri_Pens[TEXTPEN]);
						SetBPen (rp, DrawInfo->dri_Pens[BACKGROUNDPEN]);
						SetDrMd (rp, JAM2);
					}
				}

				Move (rp, win->Width - twidth - 60, rp->TxBaseline + 1);
				Text (rp, buf, tlen);

				SetFont (rp, oldfont);
			}
			break;
		}

		case IDCMP_INTUITICKS:
			if (!(PatternGadgets[GD_PattEdit]->Flags & GFLG_SELECTED))
				ActivateGadget (PatternGadgets[GD_PattEdit], win, NULL);
			break;

		default:
			break;
	}
}



void UpdatePattern (void)
{
	if (PatternWUD.Win)
	{
		struct Pattern *patt;

		if (songinfo)
		{
			patt = &songinfo->PattData[songinfo->CurrentPatt];

			SPrintf (WindowTitle, "%s/%03ld: %s  (%ld/%ld)",
				songinfo->SongName,
				songinfo->CurrentPatt,
				patt->PattName[0] ? patt->PattName : (UBYTE *)"", patt->Tracks, patt->Lines);
		}
		else
		{
			patt = NULL;
			strcpy (WindowTitle, "Pattern Editor");
		}

		SetWindowTitles (PatternWUD.Win, WindowTitle, NULL);

		SetGadgetAttrs (PatternGadgets[GD_PattEdit], PatternWUD.Win, NULL,
			PATTA_Pattern,		patt,
			PATTA_CurrentInst,	songinfo ? songinfo->CurrentInst : 0,
			TAG_DONE);

		SetGadgetAttrs (PatternGadgets[GD_VSlider], PatternWUD.Win, NULL,
			PGA_Total,			patt ? patt->Lines : 0,
			TAG_DONE);

		SetGadgetAttrs (PatternGadgets[GD_HSlider], PatternWUD.Win, NULL,
			PGA_Total,			patt ? patt->Tracks : 0,
			TAG_DONE);
	}

	UpdatePattSize();
}



void UpdateEditorInst (void)
{
	if (PatternWUD.Win && songinfo)
		SetGadgetAttrs (PatternGadgets[GD_PattEdit], PatternWUD.Win, NULL,
			PATTA_CurrentInst,	songinfo->CurrentInst,
			TAG_DONE);
}



static void PatternLoad (STRPTR name)
{
	struct IFFHandle *iff;
	LONG err;

	if (!songinfo) return;

	LockWindows();

	if (iff = AllocIFF())
	{
		if (iff->iff_Stream = (ULONG) Open (name, MODE_OLDFILE))
		{
			InitIFFasDOS (iff);

			if (!(err = OpenIFF (iff, IFFF_READ)))
			{
				GetPattern (iff, &songinfo->PattData[songinfo->CurrentPatt]);
				CloseIFF (iff);
			}

			Close (iff->iff_Stream);
		}
		else err = IoErr();

		FreeIFF (iff);
	}
	else err = ERROR_NO_FREE_STORE;


	UpdatePatternList(); // This will also update the Pattern Editor.
	UnlockWindows();

	LastErr = err;
}



/*******************/
/* Pattern Gadgets */
/*******************/

static void PatternClicked (void)
{
}

static void VSliderClicked (void)
{
}

/*****************/
/* Pattern Menus */
/*****************/

static void PatternMiOpen (void)
{
	if (!songinfo) return;

	StartFileRequest (FREQ_LOADPATT, PatternLoad);
}



static void PatternMiSave (void)
{
	struct IFFHandle	*iff;
	struct Pattern		*patt;
	LONG err;

	if (!songinfo) return;

	LockWindows();

	patt = &songinfo->PattData[songinfo->CurrentPatt];

	if (iff = AllocIFF())
	{
		if (iff->iff_Stream = (ULONG) Open (patt->PattName, MODE_NEWFILE))
		{
			InitIFFasDOS (iff);

			if (!(err = OpenIFF (iff, IFFF_WRITE)))
			{
				SavePattern (iff, patt);
				CloseIFF (iff);
			}

			Close (iff->iff_Stream);
		}
		else err = IoErr();

		FreeIFF (iff);
	}
	else err = ERROR_NO_FREE_STORE;

	UnlockWindows();

	LastErr = err;
}

static void PatternMiSaveAs (void)
{
}

static void PatternMiSize (void)
{
	OpenPattSizeWindow();
}

static void PatternMiMark (void)
{
	SetGadgetAttrs (PatternGadgets[GD_PattEdit], PatternWUD.Win, NULL,
		PATTA_MarkRegion,	-1,
		TAG_DONE);
}

static void PatternMiCut (void)
{
}

static void PatternMiCopy (void)
{
}

static void PatternMiPaste (void)
{
}

static void PatternMiErase (void)
{
}

static void PatternMiUndo (void)
{
	SetGadgetAttrs (PatternGadgets[GD_PattEdit], PatternWUD.Win, NULL,
		PATTA_UndoChange,	1,
		TAG_DONE);
}

static void PatternMiRedo (void)
{
	SetGadgetAttrs (PatternGadgets[GD_PattEdit], PatternWUD.Win, NULL,
		PATTA_UndoChange,	-1,
		TAG_DONE);
}

static void PatternMiSettings (void)
{
	OpenPattPrefsWindow();
}
