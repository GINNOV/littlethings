/* Module for the voice mail browser window */

#ifndef BROWSE_C
#define BROWSE_C

#include <stdio.h>

#include <stdio.h>
#include <stdlib.h> 
#include <string.h>
#include <time.h>

#include <dos/dos.h>
#include <dos/dostags.h>
#include <dos/dosextens.h>
#include <dos/var.h>
#include <dos/exall.h>

#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <intuition/gadgetclass.h>
#include <intuition/screens.h>
#include <libraries/gadtools.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <exec/types.h>
#include <exec/tasks.h>
#include <exec/io.h>
#include <exec/libraries.h>
#include <libraries/dos.h>			/* contains RETURN_OK, RETURN_WARN #def's */
#include <libraries/gadtools.h>

#include <clib/alib_protos.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/diskfont_protos.h>

#include "amiphone.h"
#include "codec.h"
#include "messages.h"
#include "browse.h"

#define UNLESS(x) if(!(x))
#define HSPACE 10
#define VSPACE 6
#define BUTTONHEIGHT 16
#define BUTTONWIDTH(x) (10*strlen(x))
#define NUMBUTTONS 5

#define GAD_LISTVIEW	0
#define GAD_PLAY	1
#define GAD_STOP	2
#define GAD_KILL	3
#define GAD_SCAN	4
#define GAD_EXIT	5

#define LAST_ENABLED    2

/* private data */
static struct GfxBase * GfxBase       = NULL;
static struct Library * IntuitionBase = NULL;
static struct Library * GadToolsBase  = NULL;
static struct List    * FileList      = NULL;
static struct Window  * BrowseWindow  = NULL;
static struct Gadget  * glist         = NULL,
		      * listviewgad   = NULL,
		      * playbutton    = NULL,
		      * killbutton    = NULL,
                      * gad           = NULL;
static struct NewGadget ng;
static void           * vi            = NULL;
static int              windowleft    = -1,
                        windowtop     = -1,
                        windowheight  = 140,
                        windowwidth   = 555;
static ULONG            ulLastIndexClicked;
static char * szMessageDir;
static BOOL Not[2] = {TRUE,FALSE};

static struct TextAttr Topaz80 = { "topaz.font", 8, 0, 0, };
static struct Process * BrowserProcess = NULL; 
extern struct Screen * Scr;

/* private functions */
struct List * ReadFileList      (char * szDirectory);
struct Node * MakeNode          (char * szNewName, char * szNewComment);
void          FreeDoubleString  (char * DoubleString);
void          PrintDoubleString (char * DoubleString);
void          ClearFileList     (struct List * thislist);
void          PrintFileList     (struct List * list);
void 	      ListClicked       (int nIndex, struct MsgPort * ReplyPort);
void          PlayCurrentFile   (struct MsgPort * ReplyPort);
void          KillFile          (struct MsgPort * ReplyPort);     
void          AttachList        (BOOL BAttach);
void 	      EnableFileOps     (BOOL BEnable);
BOOL 	      DoIDCMP	        (struct IntuiMessage * defaultMessage, struct MsgPort * ReplyPort);
BOOL          AllocGadgets      (BOOL BAlloc, struct List * NameList);
BOOL          RemoveCurrentFile (void);
char *        GetCurrentFile    (char ** szOptSetCommentString);





BOOL AllocGadgets(BOOL BAlloc, struct List * NameList)
{
	int nStep;
	
	/* Make everything NULL, etc. */
	memset(&ng, '\0', sizeof(ng));
	
	if (BAlloc == TRUE)
	{
		UNLESS(vi = GetVisualInfo(Scr,TAG_END)) return(FALSE);
		gad = CreateContext(&glist);

		/* Allocate ListView */		
		ng.ng_TextAttr   = &Topaz80;
		ng.ng_VisualInfo = vi;
		ng.ng_LeftEdge   = HSPACE;
		ng.ng_TopEdge    = VSPACE + Scr->WBorTop+Scr->Font->ta_YSize;
		ng.ng_Width      = windowwidth-(HSPACE<<1);
		ng.ng_Height     = windowheight-ng.ng_TopEdge-(VSPACE*3)-BUTTONHEIGHT;
		ng.ng_GadgetID   = GAD_LISTVIEW;
		listviewgad = gad = CreateGadget(LISTVIEW_KIND, gad, &ng,
			GTLV_Labels,	NameList,  TAG_END);

		/* get spacing step for the buttons! */
		nStep = ng.ng_Width / NUMBUTTONS;
		
		/* Allocate Play button */
		ng.ng_TopEdge    += ng.ng_Height + (VSPACE/2);
		ng.ng_LeftEdge   += (nStep-BUTTONWIDTH("XXXX"))/2;	/* center! */
		ng.ng_Width      = BUTTONWIDTH("Play");
		ng.ng_Height     = BUTTONHEIGHT;
		ng.ng_GadgetText = "Play";
		ng.ng_GadgetID   = GAD_PLAY;
		playbutton = gad = CreateGadget(BUTTON_KIND, gad, &ng, GA_Disabled, TRUE, TAG_END);

		/* Allocate Stop button */
		ng.ng_LeftEdge  += nStep;
		ng.ng_Width      = BUTTONWIDTH("Stop");
		ng.ng_Height     = BUTTONHEIGHT;
		ng.ng_GadgetText = "Stop";
		ng.ng_GadgetID   = GAD_STOP;
		gad = CreateGadget(BUTTON_KIND, gad, &ng, TAG_END);

		/* Allocate Delete button */
		ng.ng_LeftEdge  += nStep;
		ng.ng_Width      = BUTTONWIDTH("Kill");
		ng.ng_Height     = BUTTONHEIGHT;
		ng.ng_GadgetText = "Kill";
		ng.ng_GadgetID   = GAD_KILL;
		killbutton = gad = CreateGadget(BUTTON_KIND, gad, &ng, GA_Disabled, TRUE, TAG_END);

		/* Allocate Scan button */
		ng.ng_LeftEdge  += nStep;
		ng.ng_Width      = BUTTONWIDTH("Scan");
		ng.ng_Height     = BUTTONHEIGHT;
		ng.ng_GadgetText = "Scan";
		ng.ng_GadgetID   = GAD_SCAN;
		gad = CreateGadget(BUTTON_KIND, gad, &ng, TAG_END);

		/* Allocate Exit button */
		ng.ng_LeftEdge  += nStep;
		ng.ng_Width      = BUTTONWIDTH("Exit");
		ng.ng_Height     = BUTTONHEIGHT;
		ng.ng_GadgetText = "Exit";
		ng.ng_GadgetID   = GAD_EXIT;
		gad = CreateGadget(BUTTON_KIND, gad, &ng, TAG_END);
	}
	else
	{
		if ((BrowseWindow)&&(glist)) RemoveGList(BrowseWindow, glist, -1);
		if (glist) {FreeGadgets(glist); glist = NULL;}

		/* Mark gadgets as free */
		playbutton = NULL;
		killbutton = NULL;
		gad = NULL;
		listviewgad = NULL;
		
		if (vi)    {FreeVisualInfo(vi); vi = NULL;}
	}	
	return(TRUE);
}


/* Read all the filenames in the directory into our list */
struct List * ReadFileList(char * szDirectory)
{
	BPTR MyLock = Lock(szDirectory, ACCESS_READ);
	BOOL BMore;
	struct ExAllControl * eac;
	struct ExAllData * ead;
	__aligned UBYTE EAData[sizeof(struct ExAllData)*30];
	struct List * FileList = NULL;
	struct Node * newnode;
	
	if (MyLock == 0) 
	{
		printf("ReadFileList: Lock of [%s] failed.\n",szDirectory); 
		return(NULL);
	}
	
	eac = AllocDosObject(DOS_EXALLCONTROL,NULL);
	if (eac == NULL)
	{
		printf("ReadFileList: AllocDosObject failed.\n");
		UnLock(MyLock);
		return(NULL);	
	}
	
	UNLESS(FileList = AllocMem(sizeof(struct List), MEMF_CLEAR))
	{
		printf("ReadFileList: Couldn't allocate FileList\n");
		FreeDosObject(DOS_EXALLCONTROL, eac);	
		UnLock(MyLock);
		return(NULL);
	}
	NewList(FileList);

	eac->eac_Entries = 30;
	eac->eac_MatchString = NULL;
	eac->eac_MatchFunc = NULL;	
	eac->eac_LastKey = 0;	/* very important! */

	do 
	{
		BMore = ExAll(MyLock, (struct ExAllData *) EAData, sizeof(EAData), ED_COMMENT, eac);
		if ((!BMore)&&(IoErr() != ERROR_NO_MORE_ENTRIES)) 
		{
			printf("ReadFileList: ExAll terminated abnormally.\n"); 
			break;
		}
		if (eac->eac_Entries == 0)
		{
			/* ExAll has no more entries? */
			continue;	/* more is *usually* zero */
		}
		
		ead = (struct ExAllData *) EAData;
		do {
			if (newnode = MakeNode(ead->ed_Name, ead->ed_Comment)) AddTail(FileList,newnode);
			ead = ead->ed_Next;
		} while (ead);
	} while (BMore);

	FreeDosObject(DOS_EXALLCONTROL, eac);	
	UnLock(MyLock);
	return(FileList);
}


/* Node will have a text entry that is two strings--first the displayable
   string, and then the filename "hidden" behind it. */
struct Node * MakeNode(char * szNewName, char * szNewNote)
{
	struct Node *newnode;
	char * szNodeName, * pcTemp = NULL;
	int nNameLength, nCommentLength;
	char szFileName[400];
	
	if (szNewName == NULL) return(NULL);

	nNameLength = strlen(szNewName);

	/* In case there is no file comment, just give the file name */
	if (szNewNote == NULL)
	{
		strcpy(szFileName,"  (");
		strncat(szFileName,szNewName,sizeof(szFileName)-3);
		strcat(szFileName,")");
		szNewNote = szFileName;
	}
	else
	{
		/* Hack to avoid this silly '?' at the beginning of comments! */
		if ((*szNewNote != 'N')&&(*szNewNote != ' ')) szNewNote++;
	}
	
	nCommentLength = strlen(szNewNote);
		
	/* And ANOTHER hack to avoid unterminated strings!  Aack! */
	if (nCommentLength > 63) nCommentLength = 63;
		
	/* Allocate fields for new node */
 	if ((newnode    = AllocMem(sizeof(struct Node), MEMF_CLEAR)) &&
	    (szNodeName = AllocMem(nNameLength+nCommentLength+2, MEMF_CLEAR)))
	{
		/* copy in the strings */
		Strncpy(szNodeName, szNewNote, nCommentLength+1);
		Strncpy(szNodeName+nCommentLength+1, szNewName, nNameLength+1);
				
		/* Fill out Node with a pointer to the string */
		newnode->ln_Name = szNodeName;
		
		/* return our new baby */
		return(newnode);
	}
	else
	{
		/* Free up any data we allocated */
		if (szNodeName) FreeMem(szNodeName, nNameLength+nCommentLength+2);
		if (newnode) FreeMem(newnode, sizeof(struct Node));
				
		/* fail */
		return(NULL);
	}
}



/* Frees the space of the two strings */
void FreeDoubleString(char * szDoubleString)
{
	int nLen;
	
	if (szDoubleString == NULL) return;
	
	nLen =  strlen(szDoubleString) + 1;
	nLen += strlen(szDoubleString + nLen + 1) + 1;
	FreeMem(szDoubleString, nLen);
}



void PrintDoubleString(char * szDoubleString)
{
	printf("file:    [%s]\n",szDoubleString+strlen(szDoubleString)+1);
	printf("comment: [%s]\n",szDoubleString);
}



void ClearFileList(struct List * thislist)
{
	struct Node *current;
			
	while (current = RemHead(thislist))
	{
		if (current->ln_Name != NULL) 
			FreeDoubleString(current->ln_Name);
		FreeMem(current,sizeof(struct Node));   
	}
	return;
}



void PrintFileList(struct List * list)
{
	struct Node * current = list->lh_Head;
	
	while (current->ln_Succ)
	{
		PrintDoubleString(current->ln_Name);
		current = current->ln_Succ;
	}
}

/* If non-NULL, szOptCommentString will return a pointer to the comment. */
/* The function returns a pointer to the filename */
char * GetCurrentFile(char ** szOptCommentString)
{
	struct Node * current = FileList->lh_Head;
	int i = ulLastIndexClicked;
	
	if (i >= 0)
	{
		while (current->ln_Succ)
		{
			if (szOptCommentString != NULL) *szOptCommentString = current->ln_Name;
			if (i == 0) return(current->ln_Name + strlen(current->ln_Name) + 1);
			current = current->ln_Succ;
			i--;
		}
	}
	return("[NULL]");
}

/* Removes the current file from the list */
BOOL RemoveCurrentFile(void)
{
	struct Node * current = FileList->lh_Head;
	int i = ulLastIndexClicked;
	
	if (i < 0) return(FALSE);
		
	AttachList(FALSE);
	
	while (current->ln_Succ)
	{
		if (i == 0) 	/* found the target */
		{
			Remove(current);	/* take from the list */
			FreeDoubleString(current->ln_Name);	/* free mem */
			FreeMem(current, sizeof(struct Node));
			AttachList(TRUE);		/* update list */
			ulLastIndexClicked = -1;	/* no more current file */
			EnableFileOps(FALSE);
			return(TRUE);
		}
		current = current->ln_Succ;
		i--;
	}
	AttachList(TRUE);	
	return(FALSE);
}

void AttachList(BOOL BAttach)
{
	if ((listviewgad == NULL)||(BrowseWindow == NULL)) return;
	
	if (BAttach == TRUE)
	      GT_SetGadgetAttrs((struct Gadget *)listviewgad, BrowseWindow, NULL, GTLV_Labels, FileList, TAG_END);
	else  GT_SetGadgetAttrs((struct Gadget *)listviewgad, BrowseWindow, NULL, GTLV_Labels, ~0, TAG_END);
}



void PlayCurrentFile(struct MsgPort * ReplyPort)
{
	char * szCommentString, * szFileName;
	static char szTemp[300];
	
	/* Don't ever launch two at once!  Stop the first one here and then try again */
	StopPlayer(ReplyPort);
	
	/* Get file name and comment string of current file */
	szFileName = GetCurrentFile(&szCommentString);

	Strncpy(szTemp,szMessageDir,sizeof(szTemp));
	UNLESS(AddPart(szTemp,szFileName,sizeof(szTemp))) return;
	
	/* Remove any "new" tag from file */
	if ((szCommentString != NULL)&&(*szCommentString == 'N'))
	{
		AttachList(FALSE);
		*szCommentString = ' ';	/* Remove the N, it's no longer new */
		SetComment(szTemp,szCommentString);
		AttachList(TRUE);
	}
	
	/* Put in a request to play the file */
	SendPlayerMessage(MESSAGE_CONTROLMAIN_PLAYFILE, szTemp, 0L, ReplyPort);
	
	Delay(15);	/* okay, so I suck.  Sigh... */
}



void StopPlayer(struct MsgPort * ReplyPort)
{
	SendPlayerMessage(MESSAGE_CONTROLMAIN_STOPPLAYING, NULL, 0L, ReplyPort);
}



void KillFile(struct MsgPort * ReplyPort)
{
	char szTemp[300];

	StopPlayer(ReplyPort);

	Strncpy(szTemp,szMessageDir,sizeof(szTemp));
	if (AddPart(szTemp,GetCurrentFile(NULL), sizeof(szTemp))) 
	{
		remove(szTemp);		/* from disk */
		RemoveCurrentFile();	/* from our display */
	}
		
}

/* Takes the appropriate action depending on what item was clicked. */
void ListClicked(int nIndex, struct MsgPort * ReplyPort)
{
	static time_t tLastTimeClicked;
	time_t tPreviousTimeClicked = tLastTimeClicked;
	
	tLastTimeClicked = time(NULL);
	EnableFileOps(TRUE);
		
	if ((nIndex == ulLastIndexClicked)&&
	   ((tLastTimeClicked - tPreviousTimeClicked) < 2))
		PlayCurrentFile(ReplyPort);
		
	ulLastIndexClicked = nIndex;
}


/* Enables/disables the "Play" and "Kill" buttons. */
void EnableFileOps(BOOL BEnable)
{
	static BOOL BLast = FALSE;
	
	if (BEnable == LAST_ENABLED) BEnable = BLast;
	
	GT_SetGadgetAttrs(playbutton, BrowseWindow, NULL, GA_Disabled, Not[BEnable]);
	GT_SetGadgetAttrs(killbutton, BrowseWindow, NULL, GA_Disabled, Not[BEnable]);

	BLast = BEnable;
}


/* Scans and/or rescans the file lists, and updates them. */
void ScanFiles(void)
{
	AttachList(FALSE);
	
	/* Get rid of the old list */
	if (FileList != NULL) 
	{
		ClearFileList(FileList);
		FreeMem(FileList, sizeof(struct List));
	}	
	
	/* And read in the new one */
	FileList = ReadFileList(szMessageDir);
	
	AttachList(TRUE);
}

/* Returns TRUE if program should exit */
BOOL DoIDCMP(struct IntuiMessage * defaultMessage, struct MsgPort * ReplyPort)
{
	struct IntuiMessage *message = NULL;
	ULONG class, code, qual; /* , ulItemCode; */
	/* struct MenuItem *mItem; */
	static LONG lCode;
	BOOL BProgramDone = FALSE;
	struct Gadget * gad;
	
	/* Get the first message from the queue, or use the one we already have */
	if (defaultMessage == NULL) message = (struct IntuiMessage *) GT_GetIMsg(BrowseWindow->UserPort);
			       else message = defaultMessage;

	/* Examine pending messages */	
	while (message != NULL)
	{
		class = message->Class;		/* extract needed info from message */
		code  = message->Code;
		qual  = message->Qualifier;
		gad   = (struct Gadget *) message->IAddress;

		/* tell Intuition we got the message */
		GT_ReplyIMsg(message);

		/* see what events occured, take correct action */
		switch(class)
		{	
			case IDCMP_GADGETUP:
				switch(gad->GadgetID)
				{
					case GAD_LISTVIEW: ListClicked(code,ReplyPort);   break;
					case GAD_PLAY:     PlayCurrentFile(ReplyPort);   break;
					case GAD_STOP:     StopPlayer(ReplyPort);        break;
					case GAD_KILL:     KillFile(ReplyPort); break;
					case GAD_SCAN:     ScanFiles();   	break;
					case GAD_EXIT:	   BProgramDone = TRUE; break;
				}
				break;

			case IDCMP_NEWSIZE:
				AllocGadgets(FALSE,NULL);
				EraseRect(BrowseWindow->RPort,BrowseWindow->BorderLeft, BrowseWindow->BorderTop,
					  BrowseWindow->Width - BrowseWindow->BorderRight - 1,
					  BrowseWindow->Height - BrowseWindow->BorderBottom - 1);
				RefreshWindowFrame(BrowseWindow);
				windowwidth  = BrowseWindow->Width;
				windowheight = BrowseWindow->Height;
				if (AllocGadgets(TRUE,FileList))
				{
					AddGList(BrowseWindow, glist, -1, -1, NULL);
					RefreshGList(glist, BrowseWindow, NULL, -1);
					GT_RefreshWindow(BrowseWindow, NULL);
				}
				EnableFileOps(LAST_ENABLED);
				break;
				
			case IDCMP_REFRESHWINDOW:
				GT_BeginRefresh(BrowseWindow);
				GT_EndRefresh(BrowseWindow, TRUE);
				break;
					
			case IDCMP_CLOSEWINDOW: 
				BProgramDone = TRUE;  
				break;
				
			case IDCMP_VANILLAKEY:
				break;
				
			default:        break;
		}
	
		/* Only do the one message if it's a custom message */
		if (defaultMessage != NULL) return(BProgramDone);

		/* Get next message from the queue */
		message = (struct IntuiMessage *)GT_GetIMsg(BrowseWindow->UserPort);
	}
	return(BProgramDone);
}


void StopBrowser(void)
{
	Signal((struct Task *)BrowserProcess,SIGBREAKF_CTRL_C);
}

void StartBrowser(char * szMessageDirArg)
{
	szMessageDir = szMessageDirArg;
	
	UNLESS(BrowserProcess = CreateNewProcTags(
		NP_Entry, 	BrowserMain, 
		NP_Name,  	"AmiPhone Message Browser",
		NP_Priority,	0, 
		NP_Output,	stdout,
		NP_CloseOutput, FALSE,
		NP_Cli,		TRUE,
		TAG_END))
		printf("Couldn't create browser task\n");
}


__geta4 void BrowserMain(void)
{	
	ULONG ulBrowseMask = SIGBREAKF_CTRL_C, ulSignals;
	struct MsgPort *BrowserReplyPort = CreatePort(0,0);
	
	ulLastIndexClicked = -1;
	
	UNLESS(BrowserReplyPort) goto Cleanup;	

	/* Tell main we're on */	
	SendPlayerMessage(MESSAGE_CONTROLMAIN_BROWSEROPEN, NULL, 0L, BrowserReplyPort);

	/* Open required libraries */
	UNLESS((GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",37))
	     &&(IntuitionBase = OpenLibrary("intuition.library",37))
	     &&(GadToolsBase = OpenLibrary("gadtools.library",37))) goto Cleanup;

	/* Populate the list */
	ScanFiles();
	UNLESS(FileList)
	{
		printf("Couldn't read list of files/notes\n");
		goto Cleanup;
	}

	UNLESS(AllocGadgets(TRUE,FileList))
	{
		printf("Couldn't allocate gadgets.\n");
		goto Cleanup;
	}

	
	/* center if necessary */
	if (windowleft < 0) windowleft = (Scr->Width-windowwidth)/2;
	if (windowtop  < 0) windowtop  = (Scr->Height-windowheight)/2; 
	
	/* Open up our window */
	UNLESS(BrowseWindow = OpenWindowTags( NULL,
		WA_Left,        windowleft,
        	WA_Top,         windowtop,
               	WA_Width,       windowwidth,
	        WA_Height,      windowheight,
	        WA_MinWidth,	260,
	        WA_MinHeight,	60+Scr->WBorTop+Scr->RastPort.TxHeight+1,
	        WA_MaxWidth,	-1,
	        WA_MaxHeight,	-1,
        	WA_PubScreen,   Scr,
	        WA_PubScreenFallBack, TRUE,
	        WA_IDCMP,       IDCMP_REFRESHWINDOW|IDCMP_CLOSEWINDOW|SLIDERIDCMP|IDCMP_NEWSIZE,
	        WA_Flags,       WFLG_SIZEBBOTTOM|WFLG_SMART_REFRESH|WFLG_ACTIVATE|
	        		/*WFLG_NEWLOOKMENUS|*/WFLG_CLOSEGADGET|WFLG_DRAGBAR|
	        		WFLG_DEPTHGADGET,
	        WA_Gadgets,	glist,
		WA_Title,       "AmiPhone Message Browser",
	       	WA_DepthGadget, TRUE,
	       	WA_CloseGadget, TRUE,
	       	WA_SizeGadget,  TRUE,
	       	WA_DragBar,	TRUE,
	       	WA_AutoAdjust,  TRUE,
	       	WA_Activate,    TRUE,
		TAG_DONE ))
	{
		printf("Couldn't open Browser window!\n");
		goto Cleanup;
	}
	GT_RefreshWindow(BrowseWindow, NULL);
	
	/* Wait on signal for the window */
	ulBrowseMask |= (1<<BrowseWindow->UserPort->mp_SigBit);
	
	/* The event loop */
	while(1)
	{
		ulSignals = Wait(ulBrowseMask);
		if (ulSignals & SIGBREAKF_CTRL_C) break;
		if ((ulSignals & (1<<BrowseWindow->UserPort->mp_SigBit))&&(DoIDCMP(NULL,BrowserReplyPort))) break;
	}		
	
Cleanup:
	if (BrowseWindow  != NULL) {CloseWindow(BrowseWindow); BrowseWindow = NULL;}
	AllocGadgets(FALSE,NULL);
	if (FileList != NULL) 
	{
		ClearFileList(FileList);
		FreeMem(FileList, sizeof(struct List));
		FileList = NULL;	/* Unset it for the next task? */
	}
	
	if (GadToolsBase  != NULL) {CloseLibrary(GadToolsBase); GadToolsBase = NULL;}
	if (IntuitionBase != NULL) {CloseLibrary(IntuitionBase); IntuitionBase = NULL;}
	if (GfxBase       != NULL) {CloseLibrary(GfxBase); GfxBase = NULL;}

	/* Tell main we're gone */	
	SendPlayerMessage(MESSAGE_CONTROLMAIN_BROWSERCLOSED, NULL, 0L, BrowserReplyPort);
	
	/* Cleanup any remaining messages and close the port */
	if (BrowserReplyPort) {RemovePortSafely(BrowserReplyPort); BrowserReplyPort = NULL;}
}

#endif
