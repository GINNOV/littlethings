/*
**	SongInfoWin.c
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	Handle Song Information panel.
*/

#include <exec/nodes.h>
#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>

#include "Gui.h"
#include "XModule.h"


/* Gadgets IDs */

enum
{
	GD_SongLength,
	GD_Patterns,
	GD_Tracks,
	GD_SongName,
	GD_SongList,
	GD_AuthorName,
	GD_Tempo,
	GD_Speed,
	GD_Restart,
	GD_NewSong,
	GD_OpenSong,
	GD_DelSong,
	GD_SaveSong,
	GD_TotalSize,
	GD_InstSize,

	SongInfo_CNT
};



static struct Gadget *SongInfoGadgets[SongInfo_CNT];

struct List SongList;

/* Local function Prototypes */

static void SongNameClicked (void);
static void SongListClicked (void);
static void AuthorNameClicked (void);
static void TempoClicked (void);
static void SpeedClicked (void);
static void RestartClicked (void);
static void NewSongClicked (void);
static void OpenSongClicked (void);
static void DelSongClicked (void);
static void SaveSongClicked (void);

static void SongInfoMiMergeSongs (void);
static void SongInfoMiJoinSongs (void);
static void SongInfoMiClearSong (void);


static UWORD SongInfoGTypes[] = {
	NUMBER_KIND,
	NUMBER_KIND,
	NUMBER_KIND,
	STRING_KIND,
	LISTVIEW_KIND,
	STRING_KIND,
	INTEGER_KIND,
	INTEGER_KIND,
	INTEGER_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	BUTTON_KIND,
	NUMBER_KIND,
	NUMBER_KIND
};



static struct NewMenu SongInfoNewMenu[] =
{
	NM_TITLE, (STRPTR)"Song", NULL, 0, NULL, NULL,
	NM_ITEM, (STRPTR)"Merge Songs", "M", 0, 0L, (APTR)SongInfoMiMergeSongs,
	NM_ITEM, (STRPTR)"Join Songs", "J", 0, 0L, (APTR)SongInfoMiJoinSongs,
	NM_ITEM, (STRPTR)NM_BARLABEL, NULL, 0, 0L, NULL,
	NM_ITEM, (STRPTR)"Clear...", "K", 0, 0L, (APTR)SongInfoMiClearSong,
	NM_END, NULL, NULL, 0, 0L, NULL
};

static struct NewGadget SongInfoNGad[] =
{
	237, 113, 45, 13, (UBYTE *)"Length", NULL, GD_SongLength, PLACETEXT_LEFT, NULL, NULL,
	237, 85, 45, 13, (UBYTE *)"Patterns", NULL, GD_Patterns, PLACETEXT_LEFT, NULL, NULL,
	237, 99, 45, 13, (UBYTE *)"Tracks", NULL, GD_Tracks, PLACETEXT_LEFT, NULL, NULL,
	97, 57, 185, 13, (UBYTE *)"Song _Name", NULL, GD_SongName, PLACETEXT_LEFT, NULL, (APTR)SongNameClicked,
	97, 1, 185, 56, NULL, NULL, GD_SongList, 0, NULL, (APTR)SongListClicked,
	97, 71, 185, 13, (UBYTE *)"_Author", NULL, GD_AuthorName, PLACETEXT_LEFT, NULL, (APTR)AuthorNameClicked,
	97, 85, 45, 13, (UBYTE *)"_Tempo", NULL, GD_Tempo, PLACETEXT_LEFT, NULL, (APTR)TempoClicked,
	97, 99, 45, 13, (UBYTE *)"S_peed", NULL, GD_Speed, PLACETEXT_LEFT, NULL, (APTR)SpeedClicked,
	97, 113, 45, 13, (UBYTE *)"_Restart", NULL, GD_Restart, PLACETEXT_LEFT, NULL, (APTR)RestartClicked,
	5, 1, 86, 12, (UBYTE *)"New", NULL, GD_NewSong, PLACETEXT_IN, NULL, (APTR)NewSongClicked,
	5, 27, 86, 12, (UBYTE *)"_Open...", NULL, GD_OpenSong, PLACETEXT_IN, NULL, (APTR)OpenSongClicked,
	5, 14, 86, 12, (UBYTE *)"Del", NULL, GD_DelSong, PLACETEXT_IN, NULL, (APTR)DelSongClicked,
	5, 40, 86, 12, (UBYTE *)"_Save", NULL, GD_SaveSong, PLACETEXT_IN, NULL, (APTR)SaveSongClicked,
	210, 127, 72, 11, (UBYTE *)"Total Module Size", NULL, GD_TotalSize, PLACETEXT_LEFT, NULL, NULL,
	210, 139, 72, 11, (UBYTE *)"Total Instruments Size", NULL, GD_InstSize, PLACETEXT_LEFT, NULL, NULL
};



static ULONG SongInfoGTags[] =
{
	GTNM_Border, TRUE, TAG_DONE,
	GTNM_Border, TRUE, TAG_DONE,
	GTNM_Border, TRUE, TAG_DONE,
	GTST_MaxChars, 31, TAG_DONE,
	GTLV_Labels, (ULONG)&SongList, GTLV_ShowSelected, NULL, TAG_DONE,
	GTST_MaxChars, 63, TAG_DONE,
	GTIN_MaxChars, 3, TAG_DONE,
	GTIN_MaxChars, 3, TAG_DONE,
	GTIN_MaxChars, 3, TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	TAG_DONE,
	GTNM_Border, TRUE, TAG_DONE,
	GTNM_Border, TRUE, TAG_DONE
};



struct WinUserData SongInfoWUD =
{
	{ NULL, NULL },
	NULL,
	SongInfoGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	NULL,
	CloseSongInfoWindow,
	ToolBoxDropIcon,
	NULL,
	NULL,

	{ 150, 16, 286, 152 },
	SongInfoNewMenu,
	SongInfoGTypes,
	SongInfoNGad,
	SongInfoGTags,
	SongInfo_CNT,
	WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET | WFLG_ACTIVATE,
	NUMBERIDCMP | STRINGIDCMP | LISTVIEWIDCMP | INTEGERIDCMP | BUTTONIDCMP | IDCMP_CLOSEWINDOW | IDCMP_REFRESHWINDOW | IDCMP_MENUPICK,
	"Song Information"
};




LONG OpenSongInfoWindow (void)
{
	LONG ret = !MyOpenWindow (&SongInfoWUD);

	UpdateSongInfo();

	return ret;
}



void CloseSongInfoWindow (void)
{
	MyCloseWindow (SongInfoWUD.Win);
}



/**********************/
/* SongInfo Functions */
/**********************/

void AddSongInfo (struct SongInfo *si)

/* Add the given song to the SongList */
{
	if (SongInfoWUD.Win)
		GT_SetGadgetAttrs (SongInfoGadgets[GD_SongList], SongInfoWUD.Win, NULL,
			GTLV_Labels, ~0,
			TAG_DONE);

	AddTail (&SongList, (struct Node *)si);
	si->Link.ln_Type = 1;	/* Remember to remove this node from the list. */

	if (SongInfoWUD.Win)
		GT_SetGadgetAttrs (SongInfoGadgets[GD_SongList], SongInfoWUD.Win, NULL,
			GTLV_Labels, &SongList,
			GTLV_Selected, 1000,
			GTLV_MakeVisible, 1000,
			TAG_DONE);

	songinfo = si;
	UpdateSongInfo();
}



void RemoveSongInfo (struct SongInfo *si)

/* Remove the given song from the SongList.
 * It is safe to call this function even if the song has not been
 * added to the SongList.  If the passed SongInfo is the active one,
 * another song will be selected.
 */
{
	if (!(si->Link.ln_Type)) return;

	if (SongInfoWUD.Win)
		GT_SetGadgetAttrs (SongInfoGadgets[GD_SongList], SongInfoWUD.Win, NULL,
			GTLV_Labels, ~0,
			TAG_DONE);

	Remove ((struct Node *)si);

	if (SongInfoWUD.Win)
		GT_SetGadgetAttrs (SongInfoGadgets[GD_SongList], SongInfoWUD.Win, NULL,
			GTLV_Labels, &SongList,
			GTLV_Selected, 1000,
			TAG_DONE);

	if (songinfo == si)
	{
		if (IsListEmpty (&SongList)) songinfo = NULL;
		else songinfo = (struct SongInfo *)SongList.lh_TailPred;

		UpdateSongInfo();
	}
}



void UpdateSongInfo (void)

/* Update information on the current song */
{
	// ULONG millisecs;

	if (SongInfoWUD.Win && songinfo)
	{
		struct SongInfo *tmp = (struct SongInfo *)SongList.lh_Head;
		ULONG songnum = 0;


		/* Find current song number */

		while (tmp != songinfo)
		{
			tmp = (struct SongInfo *)tmp->Link.ln_Succ;
			songnum++;
		}

		SetGadgets (&SongInfoWUD,
			GD_SongList,	songnum,
			GD_SongName,	songinfo->SongName,
			GD_AuthorName,	songinfo->Author,
			GD_Tempo,		songinfo->GlobalTempo,
			GD_Speed,		songinfo->GlobalSpeed,
			GD_SongLength,	songinfo->Length,
			GD_Patterns,	songinfo->NumPatterns,
			GD_Tracks,		songinfo->MaxTracks,
			GD_Restart,		songinfo->Restart,
			GD_TotalSize,	CalcSongSize (songinfo),
			GD_InstSize,	CalcInstSize (songinfo),
			-1);

		/* TODO */
		// millisecs = CalcSongTime (songinfo);
		// ShowMessage ("Song Time: %02ld:%02ld", millisecs / 60000, (millisecs / 1000) % 60);
	}

	UpdateInstrList();
	UpdatePatternList();
}



/********************/
/* SongInfo Gadgets */
/********************/


static void SongListClicked (void)
{
	WORD i;
	struct SongInfo *tmp = (struct SongInfo *)SongList.lh_Head;

	for (i = IntuiMsg.Code; i > 0 ; i--)
		tmp = (struct SongInfo *)tmp->Link.ln_Succ;

	if (tmp != songinfo)
	{
		songinfo = tmp;
		UpdateSongInfo();
	}
}



static void SongNameClicked (void)
{
	GT_SetGadgetAttrs (SongInfoGadgets[GD_SongList], SongInfoWUD.Win, NULL,
		GTLV_Labels, ~0,
		TAG_DONE);

	strcpy (songinfo->SongName, GetString (SongInfoGadgets[GD_SongName]));

	GT_SetGadgetAttrs (SongInfoGadgets[GD_SongList], SongInfoWUD.Win, NULL,
		GTLV_Labels, &SongList,
		TAG_DONE);
}



static void AuthorNameClicked (void)
{
	strcpy (songinfo->Author, GetString (SongInfoGadgets[GD_AuthorName]));
}



static void TempoClicked( void )
{
	LONG tempo = GetNumber (SongInfoGadgets[GD_Tempo]);

	if (tempo > 255) tempo = 255;
	if (tempo < 32) tempo = 32;

	songinfo->GlobalTempo = tempo;

	GT_SetGadgetAttrs (SongInfoGadgets[GD_Tempo], SongInfoWUD.Win, NULL,
		GTIN_Number, songinfo->GlobalTempo,
		TAG_DONE);
}



static void RestartClicked( void )
{
	LONG  restart = GetNumber (SongInfoGadgets[GD_Restart]);

	if (restart < 0) restart = 0;
	if (restart >= songinfo->Length)
		restart = songinfo->Length-1;

	songinfo->Restart = restart;

	GT_SetGadgetAttrs (SongInfoGadgets[GD_Restart], SongInfoWUD.Win, NULL,
		GTIN_Number, restart,
		TAG_DONE);
}



static void SpeedClicked (void)
{
	LONG speed = GetNumber (SongInfoGadgets[GD_Speed]);

	if (speed < 1) speed = 1;
	if (speed > 31) speed = 31;

	songinfo->GlobalSpeed = speed;

	GT_SetGadgetAttrs (SongInfoGadgets[GD_Speed], SongInfoWUD.Win, NULL,
		GTIN_Number, speed,
		TAG_DONE);
}



static void NewSongClicked (void)
{
	struct SongInfo *si;

	if (si = NewSong())
		AddSongInfo (si);
}


static void OpenSongClicked (void)
{
	StartFileRequest (FREQ_LOADMOD, ToolBoxOpenModule);
}


static void DelSongClicked (void)
{
	if (ShowRequestArgs (MSG_DISCARD_CURRENT_SONG, MSG_YES_OR_NO, NULL))
	{
		struct SongInfo *si;

		RemoveSongInfo (si = songinfo);
		FreeSongInfo (si);

		if (songinfo == NULL)
			NewSongClicked();
	}
}


static void SaveSongClicked (void)
{
	LockWindows();

	if (songinfo)
		LastErr = SaveModule (songinfo, songinfo->SongPath, SaveSwitches.SaveType);

	UnlockWindows();
}



/******************/
/* SongInfo Menus */
/******************/

static void SongInfoMiMergeSongs (void)
{
	struct SongInfo *si, *si2;

	if (!songinfo)
	{
		DisplayBeep (Scr);
		return;
	}

	LockWindows();

	si2 = (struct SongInfo *) songinfo->Link.ln_Succ;

	if (si2->Link.ln_Succ)
	{
		if (si = MergeSongs (songinfo, si2))
			AddSongInfo (si);
	}
	else ShowMessage (MSG_MERGE_REQUIRES_TWO_SONGS);

	UnlockWindows();
}



static void SongInfoMiJoinSongs (void)
{
	struct SongInfo *si, *si2;

	if (!songinfo)
	{
		DisplayBeep (Scr);
		return;
	}

	LockWindows();

	si2 = (struct SongInfo *) songinfo->Link.ln_Succ;

	if (si2->Link.ln_Succ)
	{
		if (si = JoinSongs (songinfo, si2))
			AddSongInfo (si);
	}
	else ShowMessage (MSG_JOIN_REQUIRES_TWO_SONGS);

	UnlockWindows();
}


static void SongInfoMiClearSong (void)
{
	OpenClearWindow();
}
