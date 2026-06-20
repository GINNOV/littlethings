/*
**	SampleWin.c
**
**	Copyright (C) 1994,95 Bernardo Innocenti
**
**	Sample editor handling functions.
*/

#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>
#include <graphics/rpattr.h>
#include <graphics/gfxmacros.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/gadtools_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/graphics_pragmas.h>

#include "Gui.h"
#include "XModule.h"



/* Gadgets IDs */

enum {
	GD_SampScroll,
	GD_SampZoomIn,
	GD_SampRangeAll,
	GD_SampShowRange,
	GD_SampZoomOut,
	GD_SampClearRange,
	GD_SampShowAll,
	GD_SampSize,
	GD_SampPlayR,
	GD_SampPlayD,
	GD_SampPlayL,
	GD_SampPlayA,
	GD_DisplayStart,
	GD_DisplayEnd,
	GD_DisplayLen,
	GD_RangeStart,
	GD_RangeEnd,
	GD_RangeLen,
	GD_RepStart,
	GD_RepEnd,
	GD_RepLen,
	GD_SampBox,

	Sample_CNT
};


/* Sample rendering modes */

enum {
	SAMP_PIXEL,
	SAMP_LINE,
	SAMP_FILLED
};


/* Local functions prototypes */

void SampleRender			(void);
void UpdateSampGraph		(void);
static LONG SampBoxSetup	(struct Gadget *g);
static void HandleSampleIDCMP (void);
static void DrawRange		(void);
static void UpdateRange		(WORD newend);
static void UpdateRangeInfo	(void);

static void DrawPixelGraph (struct RastPort *rp, BYTE *samp,
	UWORD xmin, UWORD xmax, UWORD ycoord, UWORD height, UWORD step);
static void DrawLineGraph (struct RastPort *rp, BYTE *samp,
	UWORD xmin, UWORD xmax, UWORD ycoord, UWORD height, UWORD step);
static void DrawFilledGraph (struct RastPort *rp, BYTE *samp,
	UWORD xmin, UWORD xmax, UWORD ycoord, UWORD height, UWORD step);

static void SampScrollClicked (void);
static void SampZoomInClicked (void);
static void SampRangeAllClicked (void);
static void SampShowRangeClicked (void);
static void SampZoomOutClicked (void);
static void SampClearRangeClicked (void);
static void SampShowAllClicked (void);
static void SampPlayRClicked (void);
static void SampPlayDClicked (void);
static void SampPlayLClicked (void);
static void SampPlayAClicked (void);
static void DisplayStartClicked (void);
static void DisplayEndClicked (void);
static void DisplayLenClicked (void);
static void RangeStartClicked (void);
static void RangeEndClicked (void);
static void RangeLenClicked (void);
static void RepStartClicked (void);
static void RepLenClicked (void);
static void RepEndClicked (void);
static void SampBoxClicked (void);

static void SampleMiCut (void);
static void SampleMiCopy (void);
static void SampleMiPaste (void);
static void SampleMiPoints (void);
static void SampleMiLines (void);
static void SampleMiFilled (void);


static struct IBox SampBox;		/* Sample Box Coordinates */
static WORD		RangeStartX, RangeEndX, RangePole;
static WORD		LoopPole1, LoopPole2;
static LONG		DisplayStart, DisplayEnd;



static struct Gadget	*SampleGadgets[Sample_CNT];

struct NewMenu SampleNewMenu[] = {
	NM_TITLE, (STRPTR)"Edit", NULL, 0, NULL, NULL,
	NM_ITEM, (STRPTR)"Cut", (STRPTR)"X", 0, 0L, (APTR)SampleMiCut,
	NM_ITEM, (STRPTR)"Copy", (STRPTR)"C", 0, 0L, (APTR)SampleMiCopy,
	NM_ITEM, (STRPTR)"Paste", (STRPTR)"V", 0, 0L, (APTR)SampleMiPaste,
	NM_TITLE, (STRPTR)"Render", NULL, 0, NULL, NULL,
	NM_ITEM, (STRPTR)"Points", NULL, CHECKIT, 6L, (APTR)SampleMiPoints,
	NM_ITEM, (STRPTR)"Lines", NULL, CHECKIT|CHECKED, 5L, (APTR)SampleMiLines,
	NM_ITEM, (STRPTR)"Filled", NULL, CHECKIT, 3L, (APTR)SampleMiFilled,
	NM_END, NULL, NULL, 0, 0L, NULL
};

UWORD SampleGTypes[] = {
	SCROLLER_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	NUMBER_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	INTEGER_KIND,
	INTEGER_KIND,
	INTEGER_KIND,
	INTEGER_KIND,
	INTEGER_KIND,
	INTEGER_KIND,
	INTEGER_KIND,
	INTEGER_KIND,
	INTEGER_KIND,
	GENERIC_KIND
};

struct NewGadget SampleNGad[] = {
	4, 154, 623, 8, NULL, NULL, GD_SampScroll, 0, NULL, (APTR)SampScrollClicked,
	4, 1, 105, 12, (UBYTE *)"Zoom _In", NULL, GD_SampZoomIn, PLACETEXT_IN, NULL, (APTR)SampZoomInClicked,
	112, 1, 105, 12, (UBYTE *)"Range _All", NULL, GD_SampRangeAll, PLACETEXT_IN, NULL, (APTR)SampRangeAllClicked,
	112, 27, 105, 12, (UBYTE *)"Show Range", NULL, GD_SampShowRange, PLACETEXT_IN, NULL, (APTR)SampShowRangeClicked,
	4, 14, 105, 12, (UBYTE *)"Zoom _Out", NULL, GD_SampZoomOut, PLACETEXT_IN, NULL, (APTR)SampZoomOutClicked,
	112, 14, 105, 12, (UBYTE *)"_Clear Range", NULL, GD_SampClearRange, PLACETEXT_IN, NULL, (APTR)SampClearRangeClicked,
	4, 27, 105, 12, (UBYTE *)"Show All", NULL, GD_SampShowAll, PLACETEXT_IN, NULL, (APTR)SampShowAllClicked,
	112, 40, 105, 12, (UBYTE *)"Sample Size", NULL, GD_SampSize, PLACETEXT_LEFT, NULL, NULL,
	220, 27, 105, 12, (UBYTE *)"Play Range", NULL, GD_SampPlayR, PLACETEXT_IN, NULL, (APTR)SampPlayRClicked,
	220, 1, 105, 12, (UBYTE *)"Play Display", NULL, GD_SampPlayD, PLACETEXT_IN, NULL, (APTR)SampPlayDClicked,
	220, 40, 105, 12, (UBYTE *)"Loop Play", NULL, GD_SampPlayL, PLACETEXT_IN, NULL, (APTR)SampPlayLClicked,
	220, 14, 105, 12, (UBYTE *)"Play All", NULL, GD_SampPlayA, PLACETEXT_IN, NULL, (APTR)SampPlayAClicked,
	414, 11, 69, 13, (UBYTE *)"_Display", NULL, GD_DisplayStart, PLACETEXT_LEFT, NULL, (APTR)DisplayStartClicked,
	486, 11, 69, 13, NULL, NULL, GD_DisplayEnd, 0, NULL, (APTR)DisplayEndClicked,
	558, 11, 69, 13, NULL, NULL, GD_DisplayLen, 0, NULL, (APTR)DisplayLenClicked,
	414, 25, 69, 13, (UBYTE *)"_Range", NULL, GD_RangeStart, PLACETEXT_LEFT, NULL, (APTR)RangeStartClicked,
	486, 25, 69, 13, NULL, NULL, GD_RangeEnd, 0, NULL, (APTR)RangeEndClicked,
	558, 25, 69, 13, NULL, NULL, GD_RangeLen, 0, NULL, (APTR)RangeLenClicked,
	414, 39, 69, 13, (UBYTE *)"R_epeat", NULL, GD_RepStart, PLACETEXT_LEFT, NULL, (APTR)RepStartClicked,
	486, 39, 69, 13, NULL, NULL, GD_RepEnd, 0, NULL, (APTR)RepEndClicked,
	558, 39, 69, 13, NULL, NULL, GD_RepLen, 0, NULL, (APTR)RepLenClicked,
	0, 0, 0, 0, NULL, NULL, GD_SampBox, 0, NULL, (APTR)SampBoxClicked
};

ULONG SampleGTags[] = {
	PGA_Freedom, LORIENT_HORIZ, GA_RelVerify, TRUE, TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	GTNM_Border, TRUE, TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	GTIN_MaxChars, 6, TAG_DONE,
	GTIN_MaxChars, 6, TAG_DONE,
	GTIN_MaxChars, 6, TAG_DONE,
	GTIN_MaxChars, 6, TAG_DONE,
	GTIN_MaxChars, 6, TAG_DONE,
	GTIN_MaxChars, 6, TAG_DONE,
	GTIN_MaxChars, 6, TAG_DONE,
	GTIN_MaxChars, 6, TAG_DONE,
	GTIN_MaxChars, 6, TAG_DONE,
	XMGAD_SetupFunc, (ULONG)SampBoxSetup, TAG_DONE
};


struct IntuiText SampleIText[] = {
	1, 0, JAM1,445, 5, NULL, (UBYTE *)"Start", NULL,
	1, 0, JAM1,516, 5, NULL, (UBYTE *)"End", NULL,
	1, 0, JAM1,589, 5, NULL, (UBYTE *)"Length", NULL };

#define Sample_TNUM 3



struct WinUserData SampleWUD =
{
	{ NULL, NULL },
	NULL,
	SampleGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	SampleRender,
	CloseSampleWindow,
	NULL,
	HandleSampleIDCMP,
	NULL,

	{ 0, 11, 632, 164 },
	SampleNewMenu,
	SampleGTypes,
	SampleNGad,
	SampleGTags,
	Sample_CNT,
	WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_ACTIVATE,
	SCROLLERIDCMP|ARROWIDCMP|BUTTONIDCMP|INTEGERIDCMP|IDCMP_MENUPICK|IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_MOUSEMOVE,
	"Sample Editor"
};



void SampleRender (void)
{
	DrawBevelBox (SampleWUD.Win->RPort, SampBox.Left - 2, SampBox.Top - 1,
					SampBox.Width + 4, SampBox.Height + 2,
					GT_VisualInfo, VisualInfo,
					GTBB_Recessed, TRUE,
					TAG_DONE );

	RenderWindowTexts (&SampleWUD, SampleIText, Sample_TNUM);

	UpdateSampGraph();
	UpdateSampInfo();
}



LONG OpenSampleWindow (void)
{
	struct Window *win;

	DisplayStart = RangeStartX = RangeEndX = 0;

	if (songinfo)
		DisplayEnd = songinfo->Inst[songinfo->CurrentInst].Length - 1;
	else
		DisplayEnd = 0;

	if (DisplayEnd < 0) DisplayEnd = 0;
	LoopPole1 = LoopPole2 = 0;

	win = MyOpenWindow (&SampleWUD);

	UpdateSampleMenu();

	return (!win);
}



void CloseSampleWindow (void)
{
	MyCloseWindow (SampleWUD.Win);
}



static LONG SampBoxSetup (struct Gadget *g)
{
	SampBox.Left	= OffX + ComputeX (&SampleWUD, 4) + 2;
	SampBox.Top		= OffY + ComputeY (&SampleWUD, 53) + 1;
	SampBox.Width	= ComputeX (&SampleWUD, 622) - 4;
	SampBox.Height	= ComputeY (&SampleWUD, 100) - 2;

	g->LeftEdge = SampBox.Left;
	g->TopEdge = SampBox.Top;
	g->Width = SampBox.Width;
	g->Height = SampBox.Height;

	g->Flags		|= GFLG_GADGHNONE;
	g->Activation	|= GACT_IMMEDIATE | GACT_FOLLOWMOUSE | GACT_RELVERIFY;
	g->GadgetType	|= GTYP_BOOLGADGET;	/* Preserve GadTools special flags */

	return RETURN_OK;
}



static void HandleSampleIDCMP (void)
{
	WORD mousex; //, mousey;

	if (IntuiMsg.Class != IDCMP_MOUSEMOVE)
		return;

	mousex = IntuiMsg.MouseX - SampBox.Left;
//	mousey = IntuiMsg.MouseY - SampBox.Top;

	/* Clip mouse position */
	if (mousex < 0) mousex = 0;
//	if (mousey < 0) mousey = 0;
	if (mousex >= SampBox.Width) mousex = SampBox.Width - 1;
//	if (mousey >= SampBox.Height) mousey = SampBox.Height - 1;

	if (mousex == RangeEndX) /* Do not redraw until mouse position has changed */
		return;

	UpdateRange (mousex);
}


/********************/
/* Sample Functions */
/********************/

static void DrawPixelGraph (struct RastPort *rp, BYTE *samp,
	UWORD xmin, UWORD xmax, UWORD ycoord, UWORD height, UWORD step)
{
	ULONG i;
	UWORD x;

	for (i = 0, x = xmin ; x < xmax ; i += step, x++)
		WritePixel (rp, x, (samp[i]*height)/256 + ycoord);
}



static void DrawLineGraph (struct RastPort *rp, BYTE *samp,
	UWORD xmin, UWORD xmax, UWORD ycoord, UWORD height, UWORD step)
{
	ULONG i;
	UWORD x;

	Move (rp, xmin, ycoord);

	for (i = 0, x = xmin ; x < xmax ; i += step, x++)
		Draw (rp, x, (samp[i]*height)/256 + ycoord);
}



static void DrawFilledGraph (struct RastPort *rp, BYTE *samp,
	UWORD xmin, UWORD xmax, UWORD ycoord, UWORD height, UWORD step)
{
	UWORD x;
	ULONG i;

	for (i = 0, x = xmin ; x < xmax ; i += step, x++)
	{
		Move (rp, x, ycoord);
		Draw (rp, x, (samp[i]*height)/256 + ycoord);
	}
}



void UpdateSample (void)

/* You call this function when the selected instrument has changed. */
{
	if (!songinfo) return;

	DisplayStart = RangeStartX = RangeEndX = 0;
	DisplayEnd = songinfo->Inst[songinfo->CurrentInst].Length - 1;
	if (DisplayEnd < 0) DisplayEnd = 0;

	UpdateSampGraph();
	UpdateSampInfo();
}



void UpdateSampleMenu (void)
{
	if (SampleWUD.Win)
	{
		struct Menu *menu = SampleWUD.Win->MenuStrip;
		struct MenuItem *item = menu->NextMenu->FirstItem;

		ClearMenuStrip (SampleWUD.Win);


		/* Clear checkmarks */

		item->Flags &= ~CHECKED;
		item->NextItem->Flags &= ~CHECKED;
		item->NextItem->NextItem->Flags &= ~CHECKED;


		/* Set checkmark */

		switch (GuiSwitches.SampDrawMode)
		{
			case SAMP_PIXEL:
				item->Flags |= CHECKED;
				break;

			case SAMP_LINE:
				item->NextItem->Flags |= CHECKED;
				break;

			case SAMP_FILLED:
				item->NextItem->NextItem->Flags |= CHECKED;
				break;
		}

		ResetMenuStrip (SampleWUD.Win, menu);
	}
}



void UpdateSampInfo (void)
{
	LONG repend;
	struct Instrument *inst;

	if (!(SampleWUD.Win && songinfo)) return;

	inst = &songinfo->Inst[songinfo->CurrentInst];

	repend = inst->Repeat + inst->Replen - 1;
	if (repend < 0) repend = 0;

	SetGadgets (&SampleWUD,
		GD_RepStart,		inst->Repeat,
		GD_RepEnd,			repend,
		GD_RepLen,			inst->Replen,
		GD_SampSize,		inst->Length,
		GD_DisplayStart,	DisplayStart,
		GD_DisplayEnd,		DisplayEnd,
		GD_DisplayLen,		DisplayEnd ? (DisplayEnd - DisplayStart + 1) : 0,
		-1);

	/* Loop markers */
	{
		struct RastPort *rp = SampleWUD.Win->RPort;

		SetDrMd (rp, COMPLEMENT);
		SetDrPt (rp, 0xFF00);

		/* Delete previous loop */
		if (LoopPole1)
		{
			Move (rp, LoopPole1, SampBox.Top);
			Draw (rp, LoopPole1, SampBox.Top + SampBox.Height);
			LoopPole1 = 0;
		}
		if (LoopPole2)
		{
			Move (rp, LoopPole2, SampBox.Top);
			Draw (rp, LoopPole2, SampBox.Top + SampBox.Height);
			LoopPole2 = 0;
		}

		if (inst->Replen) /* Draw new loop */
		{
			if (DisplayStart <= inst->Repeat && inst->Repeat <= DisplayEnd)
			{
				LoopPole1 = SampBox.Left + ((SampBox.Width * (inst->Repeat - DisplayStart)) / (DisplayEnd - DisplayStart + 1));

				Move (rp, LoopPole1, SampBox.Top);
				Draw (rp, LoopPole1, SampBox.Top + SampBox.Height - 1);
			}

			if (DisplayStart <= repend && repend <= DisplayEnd+1)
			{
				LoopPole2 = SampBox.Left + ((SampBox.Width * (repend - DisplayStart)) / (DisplayEnd - DisplayStart + 1));

				Move (rp, LoopPole2, SampBox.Top);
				Draw (rp, LoopPole2, SampBox.Top + SampBox.Height - 1);
			}
		}

		SetDrPt (rp, 0xFFFF);
	}
}



static void UpdateRangeInfo (void)
{
	WORD	rs = DisplayStart + RangeStartX,
			re = DisplayStart + RangeEndX;

	if (!SampleWUD.Win) return;

	SetGadgets (&SampleWUD,
		GD_RangeStart,		rs,
		GD_RangeEnd,		re,
		GD_RangeLen,		abs(re - rs),
		-1);
}



void UpdateSampGraph (void)
{
	struct RastPort *rp;
	BYTE *samp;
	ULONG maxpen;
	UWORD step, xmin, xmax, height, ycoord;

	if (!(SampleWUD.Win && songinfo)) return;

	rp = SampleWUD.Win->RPort;
	samp = songinfo->Inst[songinfo->CurrentInst].SampleData;

	xmin	= SampBox.Left;
	xmax	= xmin + SampBox.Width;
	height	= SampBox.Height;
	ycoord	= SampBox.Top + height/2;
	step	= songinfo->Inst[songinfo->CurrentInst].Length / SampBox.Width;

	/* This helps with samples smaller than the graphic x size */
	if (step == 0) step = 1;

	/* Clear instrument rectangle */

	SetDrMd (rp, JAM1);
	SetAPen (rp, DrawInfo->dri_Pens[BACKGROUNDPEN]);
	RectFill (rp, SampBox.Left, SampBox.Top,
		SampBox.Left + SampBox.Width - 1, SampBox.Top + SampBox.Height - 1);
	LoopPole1 = LoopPole2 = 0;


	if (Kick30)	/* Optimized drawing with V39 */
	{
		GetRPAttrs (rp,
			RPTAG_MaxPen, &maxpen,
			TAG_DONE);
		SetMaxPen (rp, max(DrawInfo->dri_Pens[TEXTPEN], DrawInfo->dri_Pens[FILLPEN]));
	}

	/* Draw mid line */
	SetAPen (rp, DrawInfo->dri_Pens[TEXTPEN]);
	Move (rp, xmin, ycoord);
	Draw (rp, xmax-1, ycoord);

	/* Draw sample graphic */

	if (samp)
	{
		switch (GuiSwitches.SampDrawMode)
		{
			case SAMP_PIXEL:
				DrawPixelGraph (rp, samp, xmin, xmax, ycoord, height, step);
				break;

			case SAMP_LINE:
				DrawLineGraph (rp, samp, xmin, xmax, ycoord, height, step);
				break;

			case SAMP_FILLED:
				DrawFilledGraph (rp, samp, xmin, xmax, ycoord, height, step);
				break;
		}
	}

	DrawRange();	/* Redraw range */

	/* Restore MaxPen if appropriate */
	if (Kick30) SetMaxPen (rp, maxpen);
}



static void DrawRange (void)
{
	ULONG maxpen;
	WORD xmin, xmax;
	struct RastPort *rp = SampleWUD.Win->RPort;

	if (RangeStartX > RangeEndX)
	{
		xmin = RangeEndX;
		xmax = RangeStartX;
	}
	else
	{
		xmin = RangeStartX;
		xmax = RangeEndX;
	}

	/* Optimized drawing for V39 */

	if (Kick30)
	{
		GetRPAttrs (rp,
			RPTAG_MaxPen, &maxpen,
			TAG_DONE);
		SetMaxPen (rp, max(DrawInfo->dri_Pens[TEXTPEN], DrawInfo->dri_Pens[FILLPEN]));
	}

	SetDrMd (rp, COMPLEMENT);
	RectFill (rp, SampBox.Left + xmin, SampBox.Top,
		SampBox.Left + xmax, SampBox.Top + SampBox.Height - 1);

	/* Restore MaxPen if appropriate */
	if (Kick30) SetMaxPen (rp, maxpen);
}


static void UpdateRange (WORD newend)

/* Optimized range offset drawing */
{
	WORD pole = RangeStartX;	/* The fixed end of the range */

	RangeStartX = RangeEndX;
	RangeEndX = newend;

	if (RangeEndX < pole  && RangeStartX <= pole)		/* Range _left_ of pole */
	{
		if (RangeStartX > RangeEndX) RangeStartX--;		/* Grow	range	*/
		else if (RangeStartX < RangeEndX) RangeEndX--;	/* Reduce range	*/
		DrawRange();									/* Draw/clear offset area */

	}
	else if (RangeEndX > pole && RangeStartX >= pole)	/* Range _right_ of pole */
	{
		if (RangeStartX < RangeEndX) RangeStartX++;		/* Grow	range	*/
		else if (RangeStartX > RangeEndX) RangeEndX++;	/* Reduce range	*/
		DrawRange();									/* Draw/clear offset area */
	}
	else	/* Mouse has crossed the pole: it must be redrawn */
	{
		DrawRange();
		RangeStartX = RangeEndX = pole;
		DrawRange();
	}

	RangeStartX = pole;
	RangeEndX = newend;
	UpdateRangeInfo();
}



/******************/
/* Sample Gadgets */
/******************/

static void SampScrollClicked (void)
{
}



static void SampZoomInClicked (void)
{
}



static void SampRangeAllClicked (void)
{
	DrawRange();	/* Delete previous range */
	RangeStartX = 0;
	RangeEndX = SampBox.Width;
	DrawRange();
	UpdateRangeInfo();
}



static void SampShowRangeClicked (void)
{
}



static void SampZoomOutClicked (void)
{
}



static void SampClearRangeClicked (void)
{
	if (RangeStartX == RangeEndX) return;

	DrawRange();
	RangeStartX = RangeEndX = 0;
	DrawRange();
	UpdateRangeInfo();
}



static void SampShowAllClicked (void)
{
	DisplayStart = 0;
	if (songinfo)
		DisplayEnd = songinfo->Inst[songinfo->CurrentInst].Length - 1;
	else
		DisplayEnd = 0;
	UpdateSampGraph();
	UpdateSampInfo();
}



static void SampPlayRClicked (void)
{
}

static void SampPlayDClicked (void)
{
}

static void SampPlayLClicked (void)
{
}

static void SampPlayAClicked (void)
{
	struct Instrument *inst;

	if (!songinfo) return;

	inst = &songinfo->Inst[songinfo->CurrentInst];

	PlaySample (inst->SampleData, inst->Length, inst->Volume, 0x1AC);
}

static void DisplayStartClicked (void)
{
}

static void DisplayEndClicked (void)
{
}

static void DisplayLenClicked (void)
{
}

static void RangeStartClicked (void)
{
}

static void RangeEndClicked (void)
{
}

static void RangeLenClicked (void)
{
}



static void RepStartClicked (void)
{
	struct Instrument *inst;

	if (!songinfo) return;

	inst = &songinfo->Inst[songinfo->CurrentInst];

	inst->Repeat = GetNumber (SampleGadgets[GD_RepStart]);

	if (inst->Repeat & 1) inst->Repeat--;

	if (inst->Repeat >= inst->Length)
		inst->Repeat = inst->Length - 2;

	if (((LONG)inst->Repeat) < 0)
		inst->Repeat = 0;

	if (inst->Repeat + inst->Replen > inst->Length - 2)
		inst->Replen = inst->Length - inst->Repeat;

	if (((LONG)inst->Replen) < 0)
		inst->Replen = 0;

	UpdateSampInfo();
}



static void RepLenClicked (void)
{
	struct Instrument *inst;

	if (!songinfo) return;

	inst = &songinfo->Inst[songinfo->CurrentInst];

	inst->Replen = GetNumber (SampleGadgets[GD_RepLen]);

	if (inst->Replen & 1) inst->Replen++;

	if (inst->Replen + inst->Repeat >= inst->Length)
		inst->Replen = inst->Length - inst->Repeat;

	if (((LONG)inst->Replen) < 0)
		inst->Replen = 0;

	UpdateSampInfo();
}



static void RepEndClicked (void)
{
	struct Instrument *inst;

	if (!songinfo) return;

	inst = &songinfo->Inst[songinfo->CurrentInst];

	inst->Replen = GetNumber (SampleGadgets[GD_RepEnd]) - inst->Repeat;

	if (inst->Replen & 1) inst->Replen++;

	if (inst->Replen + inst->Repeat >= inst->Length)
		inst->Replen = inst->Length - inst->Repeat;

	if (((LONG)inst->Replen) < 0) inst->Replen = 0;

	UpdateSampInfo();
}



static void SampBoxClicked (void)
{
	if (IntuiMsg.Class == IDCMP_GADGETDOWN)
	{
		DrawRange(); /* Clear old range */
		RangePole = RangeStartX = RangeEndX = IntuiMsg.MouseX - SampBox.Left;
		DrawRange(); /* Draw pole */
		UpdateRangeInfo();

//		SetPointer (SampleWUD.Win, BlockPointer, 16, 16, -8, -7);
	}
//	else if (IntuiMsg.Class == IDCMP_GADGETUP)
//		ClearPointer (SampleWUD.Win);
}


/****************/
/* Sample Menus */
/****************/

static void SampleMiCut (void)
{
	/* routine when (sub)item "Cut" is selected. */
}

static void SampleMiCopy (void)
{
	/* routine when (sub)item "Copy" is selected. */
}

static void SampleMiPaste (void)
{
	/* routine when (sub)item "Paste" is selected. */
}

static void SampleMiPoints (void)
{
	GuiSwitches.SampDrawMode = SAMP_PIXEL;
	UpdateSampGraph();
}

static void SampleMiLines (void)
{
	GuiSwitches.SampDrawMode = SAMP_LINE;
	UpdateSampGraph();
}

static void SampleMiFilled (void)
{
	GuiSwitches.SampDrawMode = SAMP_FILLED;
	UpdateSampGraph();
}
