/*
**	Requesters.c
**
**	Copyright (C) 1994,95 Bernardo Innocenti
**
**	Handle asyncronous file requester
*/

#include <libraries/asl.h>
#include <libraries/reqtools.h>
#include <dos/dostags.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>
#include <clib/asl_protos.h>
#include <clib/reqtools_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/asl_pragmas.h>
#include <pragmas/reqtools_pragmas.h>

#include "XModule.h"
#include "Gui.h"



/* Local function prototypes */
static LONG CheckOverwrite (UBYTE *path);



/* This structure is used for passing parameters to
 * the requester process and to get the result back.
 */
struct FileReqMsg
{
	struct Message		 ExecMsg;
	struct XMFileReq	*XMFReq;	/* XMFileReq structure to use		*/

	/* User call back function which does something with the file name.
	 * If the user picked multiple files, the user function will be called
	 * once on each selection.  The user function can tell which entry is
	 * being processed examining the <num> and <count> arguments.
	 */
	void			(*Func)(STRPTR file, ULONG num, ULONG count);
	APTR			Result;			/* Replied by FileRequester process	*/
	UBYTE	PathName[PATHNAME_MAX];	/* Replied by FileRequester process	*/
};



struct XMFileReq FileReqs[FREQ_COUNT] =
{
	{ NULL, MSG_SELECT_MODULES,			FRF_DOMULTISELECT | FRF_DOPATTERNS },
	{ NULL, MSG_SAVE_MODULE,			FRF_DOSAVEMODE | FRF_DOPATTERNS },
	{ NULL, MSG_SELECT_INSTRUMENTS, 	FRF_DOMULTISELECT | FRF_DOPATTERNS },
	{ NULL, MSG_SAVE_INSTRUMENT,		FRF_DOSAVEMODE | FRF_DOPATTERNS },
	{ NULL, MSG_SELECT_PATTERN, 		FRF_DOPATTERNS },
	{ NULL, MSG_SAVE_PATTERN,			FRF_DOSAVEMODE | FRF_DOPATTERNS },
	{ NULL, 0,							FRF_DOPATTERNS },
	{ NULL, 0,							FRF_DOSAVEMODE | FRF_DOPATTERNS },
};


APTR FontReq = NULL;


struct Process *FileReqTask = NULL;
struct MsgPort *FileReqPort = NULL;
ULONG FileReqSig;




/* This function is a process that puts out
 * an asyncronous ASL FileRequester.
 */
static void __saveds AslRequestProc (void)
{
	struct MsgPort		*prMsgPort = &(((struct Process *)FindTask (NULL))->pr_MsgPort);
	struct FileReqMsg	*frmsg;
	struct XMFileReq	*xmfr;

	/* Wait startup packet */
	WaitPort (prMsgPort);
	frmsg = (struct FileReqMsg *)GetMsg (prMsgPort);
	xmfr = frmsg->XMFReq;
	frmsg->Result = NULL;

	if (AslRequestTags (xmfr->FReq,
		ASLFR_Window,	ThisTask->pr_WindowPtr,
		TAG_DONE))
	{
		/* Build file path */
		strncpy (frmsg->PathName,
			((struct FileRequester *)xmfr->FReq)->fr_Drawer, PATHNAME_MAX);
		AddPart (frmsg->PathName,
			((struct FileRequester *)xmfr->FReq)->fr_File, PATHNAME_MAX);
		frmsg->Result = frmsg->PathName;
	}

	/* Signal that we are done.
	 * We forbid here to avoid beeing unloaded until exit.
	 */
	Forbid();
	ReplyMsg ((struct Message *)frmsg);
}



/* This function is a process that puts out
 * an asyncronous ReqTools FileRequester.
 */
static void __saveds RtRequestProc (void)
{
	struct MsgPort *prMsgPort = &(((struct Process *)FindTask(NULL))->pr_MsgPort);
	struct FileReqMsg *frmsg;
	struct XMFileReq *xmfr;
	ULONG flags = 0;
	UBYTE filename[PATHNAME_MAX];

	filename[0] = 0;

	/* Wait startup packet */
	WaitPort (prMsgPort);
	frmsg = (struct FileReqMsg *)GetMsg (prMsgPort);
	xmfr = frmsg->XMFReq;

	if (xmfr->Flags & FRF_DOSAVEMODE)		flags |= FREQF_SAVE;
	if (xmfr->Flags & FRF_DOPATTERNS)		flags |= FREQF_PATGAD;
	if (xmfr->Flags & FRF_DOMULTISELECT)	flags |= FREQF_MULTISELECT;

	if (!(frmsg->Result = rtFileRequest (xmfr->FReq, filename, STR(xmfr->Title),
		RT_ShareIDCMP,	FALSE,
		RT_Window,		ThisTask->pr_WindowPtr,
		RTFI_Flags,		flags,
		TAG_DONE)))
		goto error;

	/* Build file path */
	strncpy (frmsg->PathName, ((struct rtFileRequester *)xmfr->FReq)->Dir,
		PATHNAME_MAX);
	AddPart (frmsg->PathName, filename, PATHNAME_MAX);

	if (!(xmfr->Flags & FRF_DOMULTISELECT)) frmsg->Result = frmsg->PathName;

error:
	/* Signal that we are done.
	 * We forbid here to avoid beeing unloaded until exit.
	 */
	Forbid();
	ReplyMsg ((struct Message *)frmsg);
}



LONG StartFileRequest (ULONG freq, void (*func)(STRPTR file, ULONG num, ULONG count))

/* Spawns a process that opens a FileRequester.
 * Do not touch freq until the child process returns!
 *
 * INPUTS
 *	freq - Pointer to an ASL or ReqTools FileRequester
 *	func - Pointer to a function to call when FileRequester returns
 *
 * RETURN
 *
 *  err - 0 if OK, IOErr()-style error otherwise.
 */
{
	struct FileReqMsg *frmsg;

	/* Do not spawn more than one file requester process at a time */
	if (FileReqTask)
	{
		LastErr = ~0;
		return RETURN_FAIL;
	}

	if (!(frmsg = AllocMem (sizeof (struct FileReqMsg), MEMF_PUBLIC)))
		return ERROR_NO_FREE_STORE;

	if (!(FileReqTask = CreateNewProcTags (
		NP_Entry,		(ReqToolsBase ? RtRequestProc : AslRequestProc),
		NP_Name,		PRGNAME " FileRequester",
		NP_CopyVars,	FALSE,
		TAG_DONE)))
	{
		FreeMem (frmsg, sizeof (struct FileReqMsg));
		return ERROR_NO_FREE_STORE;
	}

	/* Now setup & send FReqMsg */
	frmsg->ExecMsg.mn_ReplyPort = FileReqPort;
	frmsg->XMFReq = &FileReqs[freq];
	frmsg->Func = func;
	PutMsg (&(FileReqTask->pr_MsgPort), (struct Message *)frmsg);

	return RETURN_OK;
}



void HandleFileRequest (void)
{
	struct FileReqMsg *frmsg;
	struct XMFileReq *xmfr;

	if (!(frmsg = (struct FileReqMsg *)GetMsg (FileReqPort)))
		return;

	xmfr = frmsg->XMFReq;

	FileReqTask = NULL;	/* The FileRequest Process is now gone. */

	if (frmsg->Result)
	{
		if (xmfr->Flags & FRF_DOMULTISELECT)
		{
			if (AslBase)
			{
				struct FileRequester *fr = xmfr->FReq;
				UBYTE Name[PATHNAME_MAX];
				LONG i;

				for (i = 0; i < fr->fr_NumArgs; i++)
				{
					if (NameFromLock (fr->fr_ArgList[i].wa_Lock, Name, PATHNAME_MAX))
						if (AddPart (Name, fr->fr_ArgList[i].wa_Name, PATHNAME_MAX))
							frmsg->Func (Name, i, fr->fr_NumArgs);
				}
			}
			else if (ReqToolsBase)
			{
				struct rtFileList *fl = (struct rtFileList *) frmsg->Result;
				UBYTE Name[PATHNAME_MAX];
				ULONG num_entries = 0, i = 0;

				while (fl)
				{
					fl = fl->Next;
					num_entries++;
				}

				while (fl)
				{
					strncpy (Name, ((struct rtFileRequester *)xmfr->FReq)->Dir, PATHNAME_MAX);
					AddPart (Name, fl->Name, PATHNAME_MAX);
					frmsg->Func (Name, i++, num_entries);
					fl = fl->Next;
				}

				rtFreeFileList (frmsg->Result);	/* Free multiselect buffer */
			}
		}
		else
			/* Call user hook */
			frmsg->Func (frmsg->Result, 0, 1);
	}

	FreeMem (frmsg, sizeof (struct FileReqMsg));	/* Free FileReqMsg */
}



STRPTR FileRequest (ULONG freq, STRPTR file)

/* Puts up a simple FileRequester to ask the user for a filename.
 * If the requester is in save mode, will optionally check for
 * overwrite and ask the user to confirm.
 */
{
	STRPTR retval = NULL;
	struct XMFileReq *xmfr = &FileReqs[freq];
	BOOL again;

	if (!xmfr->FReq) return NULL;

	LockWindows();

	do
	{
		again = FALSE;

		if (AslBase)
		{
			if (AslRequestTags (xmfr->FReq,
				ASLFR_Window,		ThisTask->pr_WindowPtr,
				ASLFR_InitialFile,	FilePart (file),
				TAG_DONE))
			{
				/* Build file path */
				strncpy (file, ((struct FileRequester *)xmfr->FReq)->fr_Drawer,
					PATHNAME_MAX);
				AddPart (file, ((struct FileRequester *)xmfr->FReq)->fr_File,
					PATHNAME_MAX);

				retval = file;
			}
		}
		else if (ReqToolsBase)
		{
			UBYTE filename[PATHNAME_MAX];
			ULONG flags = 0;

			strncpy (filename, FilePart (file), PATHNAME_MAX);

			if (xmfr->Flags & FRF_DOSAVEMODE)		flags |= FREQF_SAVE;
			if (xmfr->Flags & FRF_DOPATTERNS)		flags |= FREQF_PATGAD;
			if (xmfr->Flags & FRF_DOMULTISELECT)	flags |= FREQF_MULTISELECT;

			if (rtFileRequest (xmfr->FReq, filename, (xmfr->Title == -1) ? NULL : STR(xmfr->Title),
				RT_ShareIDCMP,	TRUE,
				RTFI_Flags,		flags,
				TAG_DONE))
			{
				/* Build file path */
				strncpy (file, ((struct rtFileRequester *)(xmfr->FReq))->Dir, PATHNAME_MAX);
				AddPart (file, filename, PATHNAME_MAX);

				retval = file;
			}
		}


		if (retval && (xmfr->Flags & FRF_DOSAVEMODE))
		{
			switch (CheckOverwrite (retval))
			{
				case 1:			/* Yes */
					break;

				case 2:			/* Choose Another */
					again = TRUE;
					break;

				default:		/* No */
					retval = NULL;
					break;
			}
		}

	} while (again);

	UnlockWindows();

	return retval;
}



static LONG CheckOverwrite (STRPTR path)

/* Checks if the given file already exists and
 * kindly asks the user if he knows what he's doing.
 *
 * RETURN
 *		0 - Abort
 *		1 - Continue
 *		2 - Open the requester again
 */
{
	if (GuiSwitches.AskOverwrite)
	{
		BPTR fh;

		if (fh = Open (path, MODE_OLDFILE))
		{
			Close (fh);

			return ShowRequest (MSG_FILE_EXISTS, MSG_OVERWRITE, FilePart (path));
		}
	}

	return 1;
}



LONG ShowRequestStr (STRPTR text, STRPTR gtext, APTR args)

/* Simple N-way requester function. Passing NULL as <gtext>
 * will put a single "Ok" button.  Will fall to a Printf()
 * when IntuitionBase is NULL.
 */
{
	LONG ret;


	if (!gtext) gtext = STR(MSG_OK);

	if (!ShowRequesters) return 1;

	LockWindows();

	if (ReqToolsBase)
	{
		ret = rtEZRequestTags (text, gtext, NULL, args,
			RTEZ_ReqTitle,	(ULONG)STR(MSG_XMODULE_REQUEST),
			RT_ShareIDCMP,	FALSE,
			TAG_DONE);
	}
	else if (IntuitionBase)
	{
		static struct EasyStruct es =
		{
			sizeof (struct EasyStruct),
			0,
			NULL,
			NULL,
			NULL
		};

		es.es_Title			= STR(MSG_XMODULE_REQUEST);
		es.es_TextFormat	= text;
		es.es_GadgetFormat	= gtext;
		ret = EasyRequestArgs (ThisTask->pr_WindowPtr, &es, NULL, args);
	}
	else
	{
		VPrintf (text, args);
		FPutC (StdOut, (LONG)'\n');
		ret = 1;
	}

	UnlockWindows();

	return ret;
}



LONG ShowRequestArgs (ULONG msg, ULONG gadgets, APTR args)

/* Localized interface to ShowRequestStr(). The <msg> and
 * <gadgets> arguments are any MSG_#? from Locale.h.
 */
{
	return ShowRequestStr (STR(msg), STR(gadgets), args);
}



LONG ShowRequest (ULONG msg, ULONG gadgets, ...)

/* Localized, Variable arguments stub for ShowRequestStr()
 * The <msg> and <gadgets> arguments are any MSG_#? from Locale.h.
 */
{
	return ShowRequestStr (STR(msg), STR(gadgets), (APTR)(((LONG *)(&gadgets))+1));
}



LONG ScrModeRequest (struct ScrInfo *scrinfo)

/* Let user choose a new screen mode and store mode attributes in the ScrInfo
 * structure.
 *
 * Returns: TRUE for success, FALSE for failure.
 */
{
	BOOL ChangeScreen = FALSE;

	if (AslBase && AslBase->lib_Version >= 38)	/* ASL */
	{
		struct ScreenModeRequester *ScrModeReq;
		struct List customsmlist;
		struct DisplayMode clonemode;


		/* Setup custom screen mode for Workbench cloning */

		memset (&clonemode, 0, sizeof (clonemode));

		clonemode.dm_Node.ln_Name = STR(MSG_CLONE_WB);
		clonemode.dm_DimensionInfo.Header.StructID = DTAG_DIMS;
		clonemode.dm_DimensionInfo.Header.DisplayID = 0xFFFFFFFF;
		clonemode.dm_DimensionInfo.Header.SkipID = TAG_SKIP;
		clonemode.dm_DimensionInfo.Header.Length = (sizeof (struct DimensionInfo) - sizeof (struct QueryHeader)) / 2;
		clonemode.dm_PropertyFlags = DIPF_IS_WB;

		NewList (&customsmlist);
		AddHead (&customsmlist, (struct Node *)&clonemode);


		if (ScrModeReq = AllocAslRequest (ASL_ScreenModeRequest, NULL))
		{
			LockWindows();

			if (AslRequestTags (ScrModeReq,
				ASLSM_Window,				ThisTask->pr_WindowPtr,
				ASLSM_DoWidth,				TRUE,
				ASLSM_DoHeight,				TRUE,
				ASLSM_DoDepth,				TRUE,
				ASLSM_DoOverscanType,		TRUE,
				ASLSM_DoAutoScroll,			TRUE,
				ASLSM_InitialDisplayID,		GetVPModeID (&Scr->ViewPort),
				ASLSM_InitialDisplayWidth,	Scr->Width,
				ASLSM_InitialDisplayHeight,	Scr->Height,
				ASLSM_InitialDisplayDepth,	DrawInfo->dri_Depth,
				ASLSM_InitialAutoScroll,	Scr->Flags & AUTOSCROLL,
				ASLSM_InitialOverscanType,	scrinfo->OverscanType,
				ASLSM_MinWidth,				640,
				ASLSM_MinHeight,			200,
				ASLSM_CustomSMList,			&customsmlist,
				TAG_DONE))
			{
				if (ScrModeReq->sm_DisplayID == 0xFFFFFFFF)
					scrinfo->DisplayID = 0;	/* Picked special clone WB mode */
				else
				{
					scrinfo->DisplayID = ScrModeReq->sm_DisplayID;
					scrinfo->Width = ScrModeReq->sm_DisplayWidth;
					scrinfo->Height = ScrModeReq->sm_DisplayHeight;
					scrinfo->Depth = ScrModeReq->sm_DisplayDepth;
					scrinfo->OverscanType = ScrModeReq->sm_OverscanType;
					scrinfo->AutoScroll = ScrModeReq->sm_AutoScroll;
				}
				ChangeScreen = TRUE;
			}

			FreeAslRequest (ScrModeReq);
			UnlockWindows();
		}
	}
	else	/* ReqTools */
	{
		struct rtScreenModeRequester *ScrModeReq;
		BOOL CloseReqTools = FALSE;

	 	if (!ReqToolsBase)
		{
			if (!(ReqToolsBase = OpenLibrary ("reqtools.library", 38)))
			{
				CantOpenLib ("reqtools.library", 38);
				return FALSE;
			}
			CloseReqTools = TRUE;
		}

		if (ScrModeReq = rtAllocRequestA (RT_SCREENMODEREQ, NULL))
		{
			LockWindows();

			if (rtScreenModeRequest (ScrModeReq, NULL,
				RTSC_Flags,		SCREQF_OVERSCANGAD | SCREQF_AUTOSCROLLGAD |
								SCREQF_SIZEGADS | SCREQF_DEPTHGAD | SCREQF_GUIMODES,
				RT_ShareIDCMP,	TRUE,
				TAG_DONE))
			{
				scrinfo->DisplayID = ScrModeReq->DisplayID;
				scrinfo->Width = ScrModeReq->DisplayWidth;
				scrinfo->Height = ScrModeReq->DisplayHeight;
				scrinfo->Depth = ScrModeReq->DisplayDepth;
				scrinfo->OverscanType = ScrModeReq->OverscanType;
				scrinfo->AutoScroll = ScrModeReq->AutoScroll;
				ChangeScreen = TRUE;
			}

			rtFreeRequest (ScrModeReq);
			UnlockWindows();
		}

		if (CloseReqTools)
			{ CloseLibrary (ReqToolsBase); ReqToolsBase = NULL; }
	}

	return ChangeScreen;
}



LONG FontRequest (struct TextAttr *ta, ULONG flags)

/* Requests a font to the user and copies the selected font to the
 * passed TextAttr structure.  The ta_Name field is allocated with
 * AllocVec() and the font name is copied to it.
 *
 * Returns: FALSE for failure, anything else for success.
 */
{
	struct TextAttr *result = NULL;

	LockWindows();

	if (AslBase)
	{
		if (AslRequestTags (FontReq,
			ASLFO_Window,	ThisTask->pr_WindowPtr,
			ASLFO_Flags,	FOF_DOSTYLE | flags,
			TAG_DONE))
				result = &((struct FontRequester *)FontReq)->fo_Attr;
	}
	else if (ReqToolsBase)
	{
		if (rtFontRequest (FontReq, NULL,
			RT_ShareIDCMP,	TRUE,
			RTFO_Flags,		FREQF_SCALE | FREQF_STYLE | ((flags & FOF_FIXEDWIDTHONLY) ? FREQF_FIXEDWIDTH : 0),
			TAG_DONE))
				result = &((struct rtFontRequester *)FontReq)->Attr;

	}

	if (result) CopyTextAttr (result, ta);

	UnlockWindows();

	return result != NULL;
}



void FreeFReq (void)
{
	ULONG i;

	/* Terminate async requester */
	if (FileReqTask)
	{
		while (!(SetSignal (0L, FileReqSig) & FileReqSig))
			ShowRequest (MSG_CLOSE_FILEREQUESTER, MSG_CONTINUE, NULL);

		FileReqTask = NULL;
	}

	if (FileReqPort)
	{
		struct FileReqMsg *frmsg = (struct FileReqMsg *) GetMsg (FileReqPort);

		if (frmsg)
		{
			if ((frmsg->XMFReq->Flags & FRF_DOMULTISELECT) && ReqToolsBase)
				rtFreeFileList (frmsg->Result);
			FreeMem (frmsg, sizeof (struct FileReqMsg));
		}

		DeleteMsgPort (FileReqPort);	FileReqPort = NULL;
		Signals &= ~FileReqSig;
	}

	if (AslBase)
	{
		for (i = 0; i < FREQ_COUNT; i++)
		{
			FreeAslRequest (FileReqs[i].FReq);
			FileReqs[i].FReq = NULL;
		}

		FreeAslRequest (FontReq);		FontReq = NULL;
		CloseLibrary (AslBase);			AslBase = NULL;
	}

	if (ReqToolsBase)
	{
		for (i = 0; i < FREQ_COUNT; i++)
		{
			rtFreeRequest (FileReqs[i].FReq);
			FileReqs[i].FReq = NULL;
		}

		rtFreeRequest (FontReq);		FontReq = NULL;
		CloseLibrary (ReqToolsBase);	ReqToolsBase = NULL;
	}
}



LONG SetupAsl (void)
{
	ULONG i;
	struct XMFileReq *xmfr;

	if (!AslBase)
	{
		if (!(AslBase = OpenLibrary ("asl.library", 37)))
		{
			CantOpenLib ("asl.library", 37);
			return RETURN_FAIL;
		}
	}

	for (i = 0; i < FREQ_COUNT; i++)
	{
		xmfr = &FileReqs[i];

		if (!(xmfr->FReq = AllocAslRequestTags (ASL_FileRequest,
			(xmfr->Title == -1) ? TAG_IGNORE : ASLFR_TitleText, (xmfr->Title == -1) ? NULL : STR(xmfr->Title),
			ASLFR_Flags1,		xmfr->Flags | FRF_PRIVATEIDCMP,
			ASLFR_Flags2,		FRF_REJECTICONS,
			TAG_DONE)))
		return RETURN_FAIL;

	}

	if (!(FontReq = AllocAslRequestTags (ASL_FontRequest,
		TAG_DONE)))
		return RETURN_FAIL;

	return RETURN_OK;
}



LONG SetupReqTools (void)
{
	ULONG i;

	if (!(ReqToolsBase = OpenLibrary ("reqtools.library", 38)))
	{
		CantOpenLib ("reqtools.library", 38);
		return RETURN_FAIL;
	}

	for (i = 0; i < FREQ_COUNT; i++)
		if (!(FileReqs[i].FReq = rtAllocRequestA (RT_FILEREQ, NULL)))
			return RETURN_FAIL;

	if (!(FontReq = rtAllocRequestA (RT_FONTREQ, NULL)))
		return RETURN_FAIL;

	return RETURN_OK;
}



LONG SetupRequesters (void)
{
	FreeFReq();

	if (!FileReqPort)	/* Create FileRequester reply port */
	{
		if (!(FileReqPort = CreateMsgPort ())) return ERROR_NO_FREE_STORE;
		FileReqSig = 1 << FileReqPort->mp_SigBit;
		Signals |= FileReqSig;
	}

	if (GuiSwitches.UseReqTools)
	{
		if (SetupReqTools())
		{
			GuiSwitches.UseReqTools = FALSE;
			return SetupAsl();
		}
	}
	else if (SetupAsl())
	{
		GuiSwitches.UseReqTools = TRUE;
		return SetupReqTools();
	}

	return 0;
}
