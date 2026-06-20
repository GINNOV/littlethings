/*
**	Prefs.c
**
**	Copyright (C) 1994,95 Bernardo Innocenti
**
**	Save and load preferences.
*/


#include <exec/memory.h>
#include <libraries/iffparse.h>
#include <libraries/asl.h>
#include <libraries/reqtools.h>
#include <prefs/prefhdr.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/iffparse_protos.h>
#include <clib/intuition_protos.h>
#include <clib/asl_protos.h>
#include <clib/reqtools_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/iffparse_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/asl_pragmas.h>
#include <pragmas/reqtools_pragmas.h>

#include "XModule.h"
#include "Gui.h"



#define PRHD_VERS 5	/* Current version of XModule's Preferences file */

#define ID_XMPR MAKE_ID('X','M','P','R')	/* XModule PRefs			*/
#define ID_XMFN MAKE_ID('X','M','F','N')	/* XModule FoNts			*/
#define ID_XMSC MAKE_ID('X','M','S','C')	/* XModule SCreen			*/
#define ID_XMWN MAKE_ID('X','M','W','N')	/* XModule WiNdow			*/
#define ID_XMFR MAKE_ID('X','M','F','R')	/* XModule File Requester	*/

/*
 *	XModule Preferences format:
 *
 *	FORM PREF	Standard preferences file format
 *	PRHD		Standard preferences chunk
 *	XMPR		XModulePRefs
 *	XMFN		XModuleFoNts
 *	XMSC		XModuleSCreen
 *	XMWN		XModuleWiNdow (appears several times, once per window)
 *	XMFR		XModuleFileRequester (appears several times, once per requester)
 *	EOF
 */

struct XMPrefs
{
	struct GuiSwitches		GuiSwitches;
	struct SaveSwitches		SaveSwitches;
	struct ClearSwitches	ClearSwitches;
	struct OptSwitches		OptSwitches;
	struct PattSwitches		PattSwitches;
};


struct XMWindow
{
	struct IBox	WindowSize,
				WindowZoom;
	BOOL		WindowOpen,
				WindowZoomed;
};

struct XMFonts
{
	/* The TextAttr->ta_Name field does not point
	 * to the font name!
	 */
	struct TextAttr	ScreenAttr,
					WindowAttr,
					ListAttr,
					EditorAttr;
	UBYTE			ScreenFontName[32],
					WindowFontName[32],
					ListFontName[32],
					EditorFontName[32];
};



struct XMFRPrefs
{
	struct IBox	FReqSize;
	UBYTE		Dir[PATHNAME_MAX],
				Pattern[PATHNAME_MAX];
};



/* Local function prototypes */

static LONG SaveXMWN (struct IFFHandle *iff, struct WinUserData *wud);
static LONG LoadXMWN (struct IFFHandle *iff, struct WinUserData *wud);
static LONG SaveXMFR (struct IFFHandle *iff, struct XMFileReq *xmfr);
static LONG LoadXMFR (struct IFFHandle *iff, struct XMFileReq *xmfr);



LONG LoadPrefs (const STRPTR filename)
{
	struct IFFHandle	*iff;
	struct ContextNode	*cn;
	LONG				 err;
	UWORD				 wcount = 0, frcount = 0;
	BOOL				 update_screen = FALSE;

	static LONG stopchunks[] =
	{
		ID_PREF, ID_PRHD,
		ID_PREF, ID_XMPR,
		ID_PREF, ID_XMFN,
		ID_PREF, ID_XMSC,
		ID_PREF, ID_XMWN,
		ID_PREF, ID_XMFR
	};


	if (!(iff = AllocIFF()))
		return ERROR_NO_FREE_STORE;

	if (!(iff->iff_Stream = (ULONG) Open (filename, MODE_OLDFILE)))
	{
		err = IoErr();
		goto error1;
	}

	InitIFFasDOS (iff);

	if (err = OpenIFF (iff, IFFF_READ))
		goto error2;

	if (err = StopChunks (iff, stopchunks, 6))
		goto error3;

	while (1)
	{
		if (err = ParseIFF (iff, IFFPARSE_SCAN))
		{
			if (err == IFFERR_EOC) continue;
			else
			{
				if (err == IFFERR_EOF) err = 0;
				break; /* Free resources & exit */
			}
		}

		if ((cn = CurrentChunk (iff)) && (cn->cn_Type == ID_PREF))
		{
			switch (cn->cn_ID)
			{
				case ID_PRHD:
				{
					struct PrefHeader prhd;

					if ((err = ReadChunkBytes (iff, &prhd, sizeof (prhd))) !=
						sizeof (prhd)) goto error3;

					if (prhd.ph_Version != PRHD_VERS)
					{
						ShowRequestArgs (MSG_BAD_PREFS_VERSION, 0, NULL);
						goto error3;
					}

					break;
				}

				case ID_XMPR:
				{
					struct XMPrefs xmpr;

					if ((err = ReadChunkBytes (iff, &xmpr, sizeof (xmpr))) !=
						sizeof (xmpr)) goto error3;

					memcpy (&GuiSwitches, &xmpr.GuiSwitches, sizeof (GuiSwitches));
					memcpy (&SaveSwitches, &xmpr.SaveSwitches, sizeof (SaveSwitches));
					memcpy (&ClearSwitches, &xmpr.ClearSwitches, sizeof (ClearSwitches));
					memcpy (&OptSwitches, &xmpr.OptSwitches, sizeof (OptSwitches));
					memcpy (&PattSwitches, &xmpr.PattSwitches, sizeof (OptSwitches));

					UpdateGuiSwitches ();
					UpdateInstrSwitches ();
					UpdateSaveSwitches ();
					UpdateClearSwitches ();
					UpdateOptSwitches ();
					UpdateSampleMenu ();
					UpdatePattPrefs ();

					break;
				}

				case ID_XMFN:
				{
					struct XMFonts xmfn;

					if ((err = ReadChunkBytes (iff, &xmfn, sizeof (xmfn))) !=
						sizeof (xmfn)) goto error3;

					xmfn.ScreenAttr.ta_Name	= xmfn.ScreenFontName;
					xmfn.WindowAttr.ta_Name	= xmfn.WindowFontName;
					xmfn.ListAttr.ta_Name	= xmfn.ListFontName;
					xmfn.EditorAttr.ta_Name	= xmfn.EditorFontName;

					if (CmpTextAttr (&xmfn.ScreenAttr, &ScreenAttr) ||
						CmpTextAttr (&xmfn.WindowAttr, &WindowAttr) ||
						CmpTextAttr (&xmfn.ListAttr,   &ListAttr)   ||
						CmpTextAttr (&xmfn.EditorAttr, &EditorAttr))
					{
						CopyTextAttr (&xmfn.ScreenAttr, &ScreenAttr);
						CopyTextAttr (&xmfn.WindowAttr, &WindowAttr);
						CopyTextAttr (&xmfn.ListAttr,   &ListAttr);
						CopyTextAttr (&xmfn.EditorAttr, &EditorAttr);
						update_screen = TRUE;
					}

					break;
				}

				case ID_XMSC:
				{
					struct ScrInfo newscrinfo;

					if ((err = ReadChunkBytes (iff, &newscrinfo, sizeof (newscrinfo))) !=
						sizeof (newscrinfo)) goto error3;

					if (memcmp (&ScrInfo, &newscrinfo, sizeof (ScrInfo)))
					{
						if (Scr)
						{
							CloseDownScreen();
							update_screen = TRUE;
						}

						memcpy (&ScrInfo, &newscrinfo, sizeof (ScrInfo));
					}

					break;
				}

				case ID_XMWN:
					if (Wuds[wcount].Wud)
					{
						if (err = LoadXMWN (iff, Wuds[wcount].Wud))
							goto error3;
						wcount++;
					}
					break;

				case ID_XMFR:
					if (frcount < FREQ_COUNT)
					{
						if (err = LoadXMFR (iff, &FileReqs[frcount]))
							goto error3;
						frcount++;
					}
					break;

				default:
					break;
			}
		}
	}

error3:
	CloseIFF (iff);
error2:
	Close (iff->iff_Stream);
error1:
	FreeIFF (iff);

	if (Scr)
	{
		if (update_screen)
			err = SetupScreen();
		else ReopenWindows();
	}

	return err;
}



LONG SavePrefs (const STRPTR filename)
{
	struct IFFHandle *iff;
	LONG err;

	if (!(iff = AllocIFF()))
		return ERROR_NO_FREE_STORE;

	if (!(iff->iff_Stream = (ULONG) Open (filename, MODE_NEWFILE)))
	{
		err = IoErr();
		goto error1;
	}

	InitIFFasDOS (iff);

	if (err = OpenIFF (iff, IFFF_WRITE))
		goto error2;


	/* Write PREF */

	if (err = PushChunk (iff, ID_PREF, ID_FORM, IFFSIZE_UNKNOWN))
		goto error3;

	/* Store PRHD chunk */
	{
		struct PrefHeader prhd = {PRHD_VERS, 0, 0};

		if (err = PushChunk (iff, 0, ID_PRHD, sizeof (struct PrefHeader)))
			goto error3;

		if ((err = WriteChunkBytes (iff, &prhd, sizeof (struct PrefHeader))) !=
			sizeof (struct PrefHeader))
			goto error3;

		if (err = PopChunk (iff))
			goto error3;
	}

	/* Store XMPR Chunk */
	{
		struct XMPrefs xmpr;

		memcpy (&xmpr.GuiSwitches, &GuiSwitches, sizeof (GuiSwitches));
		memcpy (&xmpr.SaveSwitches, &SaveSwitches, sizeof (SaveSwitches));
		memcpy (&xmpr.ClearSwitches, &ClearSwitches, sizeof (ClearSwitches));
		memcpy (&xmpr.OptSwitches, &OptSwitches, sizeof (OptSwitches));
		memcpy (&xmpr.PattSwitches, &PattSwitches, sizeof (PattSwitches));

		if (err = PushChunk (iff, 0, ID_XMPR, sizeof (xmpr)))
			goto error3;

		if ((err = WriteChunkBytes (iff, &xmpr, sizeof (xmpr))) !=
			sizeof (xmpr))
			goto error3;

		if (err = PopChunk (iff))
			goto error3;
	}


	/* Store XMFN chunk */
	{
		struct XMFonts xmfn;

		if (err = PushChunk (iff, 0, ID_XMFN, sizeof (xmfn)))
			goto error3;

		xmfn.ScreenAttr	= ScreenAttr;
		xmfn.WindowAttr = WindowAttr;
		xmfn.ListAttr	= ListAttr;
		xmfn.EditorAttr = EditorAttr;

		if (ScreenAttr.ta_Name)
			strncpy (xmfn.ScreenFontName,	ScreenAttr.ta_Name,	32);
		if (WindowAttr.ta_Name)
			strncpy (xmfn.WindowFontName,	WindowAttr.ta_Name,	32);
		if (ListAttr.ta_Name)
			strncpy (xmfn.ListFontName,		ListAttr.ta_Name,	32);
		if (EditorAttr.ta_Name)
			strncpy (xmfn.EditorFontName,	EditorAttr.ta_Name,	32);

		if ((err = WriteChunkBytes (iff, &xmfn, sizeof (xmfn))) !=
			sizeof (xmfn))
			goto error3;

		if (err = PopChunk (iff))
			goto error3;
	}

	/* Store XMSC Chunk */
	{
		if (err = PushChunk (iff, 0, ID_XMSC, sizeof (ScrInfo)))
			goto error3;

		if ((err = WriteChunkBytes (iff, &ScrInfo, sizeof (ScrInfo))) !=
			sizeof (ScrInfo))
			goto error3;

		if (err = PopChunk (iff))
			goto error3;
	}


	/* Store XMWN Chunks */
	{
		ULONG i;

		for (i = 0; Wuds[i].Wud; i++)
			if (err = SaveXMWN (iff, Wuds[i].Wud))
				goto error3;
	}


	/* Store XMFR Chunks */
	{
		ULONG i;

		for (i = 0; i < FREQ_COUNT; i++)
			SaveXMFR (iff, &FileReqs[i]);
	}

	err = PopChunk (iff);	/* Pop PREF */

error3:
	CloseIFF (iff);

error2:
	Close (iff->iff_Stream);

error1:
	FreeIFF (iff);

	return err;
}



static LONG LoadXMWN (struct IFFHandle *iff, struct WinUserData *wud)
{
	LONG err;
	struct XMWindow xmwn;
	struct Window *win = wud->Win;

	if ((err = ReadChunkBytes (iff, &xmwn, sizeof (xmwn))) != sizeof (xmwn))
		return err;

	if (!wud->Win)
		wud->WUDFlags |= xmwn.WindowOpen ? WUDF_REOPENME : 0;	/* Open this window later.	*/
	else if (!xmwn.WindowOpen)
		wud->CloseWin();	/* Close this window now.	*/


//	memcpy (&wud->WindowSize, &xmwn.WindowSize, sizeof (struct IBox));
//	memcpy (&wud->WindowZoom, &xmwn.WindowZoom, sizeof (struct IBox));

	wud->WindowSize.Left	= xmwn.WindowSize.Left;
	wud->WindowSize.Top		= xmwn.WindowSize.Top;
	wud->WindowZoom.Left	= xmwn.WindowSize.Left;
	wud->WindowZoom.Top		= xmwn.WindowZoom.Top;

	if (wud->Flags & WFLG_SIZEGADGET)
	{
		wud->WindowSize.Width	= xmwn.WindowSize.Width;
		wud->WindowSize.Height	= xmwn.WindowSize.Height;
		wud->WindowZoom.Left	= xmwn.WindowSize.Width;
		wud->WindowZoom.Height	= xmwn.WindowZoom.Height;
	}

	if (win)
	{
		if (xmwn.WindowZoomed)
		{
			if (!(win->Flags & WFLG_ZOOMED)) ZipWindow (win);
			ChangeWindowBox (win, wud->WindowZoom.Left, wud->WindowZoom.Top,
				win->Width, win->Height);
		}
		else
		{
			if (win->Flags & WFLG_ZOOMED) ZipWindow (win);
			ChangeWindowBox (win, wud->WindowSize.Left, wud->WindowSize.Top,
				win->Width, win->Height);
		}
	}

	return RETURN_OK;
}



static LONG SaveXMWN (struct IFFHandle *iff, struct WinUserData *wud)
{
	LONG err;
	struct XMWindow xmwn;
	struct Window *win = wud->Win;

	if (err = PushChunk (iff, 0, ID_XMWN, sizeof (xmwn)))
		return err;

	memcpy (&xmwn.WindowSize, &wud->WindowSize, sizeof (struct IBox));
	memcpy (&xmwn.WindowZoom, &wud->WindowZoom, sizeof (struct IBox));

	if (win)
	{
		if (win->Flags == WFLG_ZOOMED)
		{
			memcpy (&xmwn.WindowZoom, &win->LeftEdge, sizeof (struct IBox));
			xmwn.WindowZoom.Width	-= win->BorderLeft + win->BorderRight;
			xmwn.WindowZoom.Height	-= win->BorderTop + win->BorderBottom;
		}
		else
		{
			memcpy (&xmwn.WindowSize, &win->LeftEdge, sizeof (struct IBox));
			xmwn.WindowSize.Width -= win->BorderLeft + win->BorderRight;
			xmwn.WindowSize.Height -= win->BorderTop + win->BorderBottom;
		}
	}

	xmwn.WindowOpen = win ? TRUE : FALSE;
	xmwn.WindowZoomed = win ? (win->Flags & WFLG_ZOOMED) : FALSE;

	if ((err = WriteChunkBytes (iff, &xmwn, sizeof (xmwn))) != sizeof (xmwn))
		return err;

	if (err = PopChunk (iff))
		return err;

	return RETURN_OK;
}



static LONG LoadXMFR (struct IFFHandle *iff, struct XMFileReq *xmfr)
{
	LONG err;
	struct XMFRPrefs xmfrp;

	if (!ReqToolsBase && !AslBase)
		SetupRequesters();

	if (!xmfr->FReq) return RETURN_FAIL;

	if ((err = ReadChunkBytes (iff, &xmfrp, sizeof (xmfrp))) != sizeof (xmfrp))
		return err;

	if (ReqToolsBase)
	{
		rtChangeReqAttr (xmfr->FReq,
			RT_TopOffset,	xmfrp.FReqSize.Top,
			RT_LeftOffset,	xmfrp.FReqSize.Left,
			RTFI_Height,	xmfrp.FReqSize.Height,
			/* Width not available in ReqTools */
			RTFI_Dir,		xmfrp.Dir,
			RTFI_MatchPat,	xmfrp.Pattern,
			TAG_DONE);
	}
	else if (AslBase)
	{
		struct FileRequester *fr;

		if (!(fr = AllocAslRequestTags (ASL_FileRequest,
			(xmfr->Title == -1) ? TAG_IGNORE : ASLFR_TitleText, (xmfr->Title == -1) ? NULL : STR(xmfr->Title),
			ASLFR_Flags1,			xmfr->Flags | FRF_PRIVATEIDCMP,
			ASLFR_Flags2,			FRF_REJECTICONS,
			ASLFR_InitialLeftEdge,	xmfrp.FReqSize.Left,
			ASLFR_InitialTopEdge,	xmfrp.FReqSize.Top,
			ASLFR_InitialWidth,		xmfrp.FReqSize.Width,
			ASLFR_InitialHeight,	xmfrp.FReqSize.Height,
			ASLFR_InitialDrawer,	xmfrp.Dir,
			ASLFR_InitialPattern,	xmfrp.Pattern,
			TAG_DONE)))
			return RETURN_FAIL;

		FreeAslRequest (xmfr->FReq);
		xmfr->FReq = fr;
	}

	return RETURN_OK;
}



static LONG SaveXMFR (struct IFFHandle *iff, struct XMFileReq *xmfr)
{
	LONG err;
	struct XMFRPrefs xmfrp = { 0 };

	if (err = PushChunk (iff, 0, ID_XMFR, sizeof (xmfrp)))
		return err;

	if (xmfr->FReq)
	{
		if (AslBase)
		{
			struct FileRequester *fr = (struct FileRequester *)xmfr->FReq;

			xmfrp.FReqSize.Left		= fr->fr_LeftEdge;
			xmfrp.FReqSize.Top		= fr->fr_TopEdge;
			xmfrp.FReqSize.Width	= fr->fr_Width;
			xmfrp.FReqSize.Height	= fr->fr_Height;
			strncpy (xmfrp.Dir, fr->fr_Drawer, PATHNAME_MAX);
			strncpy (xmfrp.Pattern, fr->fr_Pattern, PATHNAME_MAX);
		}
		else if (ReqToolsBase)
		{
			struct rtFileRequester *fr = (struct rtFileRequester *)xmfr->FReq;

			xmfrp.FReqSize.Left		= fr->LeftOffset;
			xmfrp.FReqSize.Top		= fr->TopOffset;
			xmfrp.FReqSize.Width	= 0;	/* Width not available in ReqTools */
			xmfrp.FReqSize.Height	= fr->ReqHeight;
			strncpy (xmfrp.Dir, fr->Dir, PATHNAME_MAX);
			strncpy (xmfrp.Pattern, fr->MatchPat, PATHNAME_MAX);
		}
	}

	if ((err = WriteChunkBytes (iff, &xmfrp, sizeof (xmfrp))) != sizeof (xmfrp))
		return err;

	if (err = PopChunk (iff)) /* Pop XMFR */
		return err;

	return RETURN_OK;
}
