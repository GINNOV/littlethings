/* -------------------------------------------------------------------------- *\
   BOGL.C
   Copyright © 1998/1999 by Jarno van der Linden
   jarno@kcbbs.gen.nz

   Blanker that uses AmigaMesaRTL programs for display

   This program is Freeware, and all usual Freeware rules apply.

   22 Nov 1998: Project started
   20 Dec 1998: Moved over to MadHouse
   05 Jan 1999: Wow! It actually seems to all work
\* -------------------------------------------------------------------------- */

/* -------------------------------- Includes -------------------------------- */
#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dostags.h>

#include <clib/madblankersupport_protos.h>
#include <pragmas/madblankersupport_pragmas.h>

#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/exec.h>
#include <proto/dos.h>

#include <gl/outputhandler.h>
#include "blank/blank.h"

#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include <string.h>

/* ------------------------------ Definitions ------------------------------- */
#define PROG_VKEY	1
#define PROG_MENU	2
#define PROG_INEV	3

/* --------------------------------- Macros --------------------------------- */

/* -------------------------------- Typedefs -------------------------------- */

/* ------------------------------ Proto Types ------------------------------- */

/* -------------------------------- Structs --------------------------------- */
struct Programme
{
	BYTE type;					// Type of entry (PROG_VKEY etc.)
	ULONG endtime;				// Very last time this entry is used
	LONG repeattime;			// Repetition interval
	ULONG nexttime;				// Next time this entry will be used
	UWORD code;					// IDCMP code this entry sends
	struct InputEvent *ie;		// Input event this entry sends
};


/* -------------------------------- Globals --------------------------------- */
static const char __ver[] = "$VER: BOGL 1.00 " __AMIGADATE__;

struct Library *madblankersupportbase = NULL;
struct Screen *scr = NULL;
struct Window *win = NULL;

char oldoh[256];				// The window output handler to use
struct Library *outputhandlerBase = NULL;
struct Process *program_proc = NULL;

char program_name[256] = "Mesa:demos/bounce";
char program_args[256] = "\n";
char program_dir[256] = "";
BPTR program_dirlock = 0;
ULONG program_displayid = 0;
ULONG program_depth = 0;

char list_name[256] = "sys:MadHouse/Blankers/BOGL/BOGL.programme";

struct MsgPort	*fakeport=NULL;	// Reply port for fake IntuiMessages
APTR fakepool;					// Memory pool for fake IntuiMessages

struct Programme programme[256];
int numprogramme = 0;

static const UWORD __chip pointerimage[] = {	0x0000, 0x0000,
												0x0000,	0x0000,
												0x0000,	0x0000,
												0x0000,	0x0000 };

/* ---------------------------------- Code ---------------------------------- */

int SetupBlankOutputHandler(struct Window *win)
{
	BOOL done;
	int t;

	outputhandlerBase = OpenLibrary("OutputHandlers/Blank",2);
	if(!outputhandlerBase)
		return(0);

	//
	// Check to see if Blank output handler is still busy
	// If so, wait for it to quit every second, for at
	// most 10 seconds
	//
	for(t=0; t<10; t++)
	{
		GetOutputHandlerAttr(BLANK_Done, (ULONG *)&done);
		if(done)
			break;
		Delay(50);
	}
	//
	// If the Blank output handler is still not finished
	// with a previous blanker, bail out
	//
	if(!done)
	{
		CloseLibrary(outputhandlerBase);
		outputhandlerBase = NULL;
		return(0);
	}

	//
	// Setup Blank output handler
	//
	GetVar("AmigaMesaRTL/window",oldoh,255,0);
	SetVar("AmigaMesaRTL/window","Blank",-1,GVF_LOCAL_ONLY);

	SetOutputHandlerAttrs(	BLANK_OldOH,	oldoh,
							OH_Output,		win,
							OH_OutputType,	"Window",
							TAG_END);

	return(1);
}


void DoneBlankOutputHandler(void)
{
	BOOL done;

	if(outputhandlerBase)
	{
		SetVar("AmigaMesaRTL/window",oldoh,-1,GVF_LOCAL_ONLY);

		//
		// Wait for Blank output handler to quit, i.e. for
		// the OGL program to release the library indicating
		// it's done.
		//
		for(;;)
		{
			GetOutputHandlerAttr(BLANK_Done, (ULONG *)&done);
			if(done)
				break;
			Delay(10);
		}
	}

	if(outputhandlerBase) CloseLibrary(outputhandlerBase);
	outputhandlerBase = NULL;
}


int LaunchProgram(char *name)
{
	BPTR program_seg;
	BPTR input,output;

	//
	// Load and launch a given program
	// - The program is created as a CLI process
	// - Input and output is set to NIL:
	// - If a current dir is set, it's locked and
	//   given to the program
	// - The program will show up as "BOGL Renderer"
	//

	program_seg = LoadSeg(name);
	if(program_seg)
	{
		input = Open("NIL:", MODE_OLDFILE);
		if(input)
		{
			output = Open("NIL:", MODE_OLDFILE);
			if(output)
			{
				if((program_dir[0] == '\0') || (program_dirlock = Lock(program_dir,ACCESS_READ)))
				{
					program_proc = CreateNewProcTags(	NP_Seglist,		program_seg,
														NP_Input,		input,
														NP_Output,		output,
														NP_Cli,			TRUE,
														NP_CommandName,	"BOGL Renderer",
														NP_Arguments,	program_args,
														TAG_SKIP,		(program_dir[0]=='\0') ? 1 : 0,
														NP_CurrentDir,	program_dirlock,
														TAG_END );
					if(program_proc)
					{
						return 1;
					}
					UnLock(program_dirlock);
				}

				Close(output);
			}
			Close(input);
		}
		UnLoadSeg(program_seg);
	}

	return 0;
}


void KillProgram(void)
{
	//
	// At present, to kill a program only a ^C
	// is signalled. This works for any program
	// using AmigaMesaRTL's GLUT library.
	//

	Signal((struct Task *)program_proc, SIGBREAKF_CTRL_C);
}


struct IntuiMessage *FakeIntuiMessage(struct Window *win, struct MsgPort *replyport, ULONG class, UWORD code)
{
	struct IntuiMessage *msg;

	//
	// Create a fake IntuiMessage
	// Very dodgy, as only Intuition knows how to
	// properly set up an IntuiMessage
	//

	msg = AllocPooled(fakepool,sizeof(struct IntuiMessage));
	if(!msg)
		return NULL;
	msg->ExecMessage.mn_Node.ln_Type = NT_MESSAGE;
	msg->ExecMessage.mn_Length = sizeof(struct IntuiMessage);
	msg->ExecMessage.mn_ReplyPort = replyport;
	msg->Class = class;
	msg->Code = code;
	msg->Qualifier = 0;
	msg->IAddress = NULL;
	msg->MouseX = 0;
	msg->MouseY = 0;
	CurrentTime(&(msg->Seconds),&(msg->Micros));
	msg->IDCMPWindow = win;
	msg->SpecialLink = NULL;
}


void SendFakeIntuiMessage(struct IntuiMessage *msg)
{
	struct MsgPort *winport;

	//
	// Sending a faked IntuiMessage to a window's
	// UserPort is very very dodgy
	//

	Forbid();
	winport = msg->IDCMPWindow->UserPort;
	if(winport) PutMsg(winport,(struct Message *)msg);
	Permit();
}


void SendFakeVKey(struct Window *win, UWORD key)
{
	struct IntuiMessage *msg;

	msg = FakeIntuiMessage(win, fakeport, IDCMP_VANILLAKEY, key);
	if(msg)
		SendFakeIntuiMessage(msg);
}


void SendFakeMenu(struct Window *win, UWORD menunum)
{
	struct IntuiMessage *msg;
	struct MenuItem *item;

	//
	// Note that no menupick chaining is done
	//

	item=ItemAddress(win->MenuStrip,menunum);
	msg = FakeIntuiMessage(win, fakeport, IDCMP_MENUPICK, menunum);
	if(msg)
	{
		item->NextSelect = MENUNULL;
		SendFakeIntuiMessage(msg);
	}
}


const ULONG ietoidcmp[] = {	0x0, IDCMP_RAWKEY, 0x0, 0x0, IDCMP_MOUSEMOVE, 0x0,
							IDCMP_INTUITICKS, IDCMP_GADGETDOWN, IDCMP_GADGETUP,
							0x0, IDCMP_MENUPICK, IDCMP_CLOSEWINDOW, IDCMP_NEWSIZE,
							IDCMP_REFRESHWINDOW, IDCMP_NEWPREFS, IDCMP_DISKREMOVED,
							IDCMP_DISKINSERTED, IDCMP_ACTIVEWINDOW, IDCMP_INACTIVEWINDOW,
							IDCMP_MOUSEMOVE, IDCMP_MENUHELP, IDCMP_CHANGEWINDOW	};

void SendFakeEvents(struct Window *win, struct InputEvent *ie)
{
	struct IntuiMessage *msg;

	//
	// Sends a list of InputEvents as IDCMP messages.
	// Only a very primitive translation is done,
	// just sufficient for rawkeys only really
	//

	for( ; ie ; ie=ie->ie_NextEvent )
	{
		msg = FakeIntuiMessage(win, fakeport, ietoidcmp[ie->ie_Class], ie->ie_Code);
		if(msg)
		{
			msg->Qualifier = ie->ie_Qualifier;
			msg->IAddress = &(ie->ie_EventAddress);
			SendFakeIntuiMessage(msg);
		}
		else
		{
			break;
		}
	}
}


void GuzzleFakeMsgs(void)
{
	struct IntuiMessage *msg;
	struct Node *succ;

	Forbid();
	msg = (struct IntuiMessage *)fakeport->mp_MsgList.lh_Head;
	while(succ = msg->ExecMessage.mn_Node.ln_Succ)
	{
		Remove((struct Node *)msg);
		FreePooled(fakepool, msg, sizeof(struct IntuiMessage));
		msg = (struct IntuiMessage *)succ;
	}
	Permit();
}


struct MsgPort *CreateFakePort(void)
{
	fakeport = CreateMsgPort();

	return fakeport;
}


void DeleteFakePort(void)
{
	if(fakeport)
	{
		GuzzleFakeMsgs();
		DeleteMsgPort(fakeport);
	}
	fakeport = NULL;
}


#define IsData(s,d0,d1,d2,d3)	(((s)[0] == (d0)) && ((s)[1] == (d1)) && ((s)[2] == (d2)) && ((s)[3] == (d3)))
#define IsPROG(s)	(IsData(s,'P','R','O','G'))
#define IsARGS(s)	(IsData(s,'A','R','G','S'))
#define IsVKEY(s)	(IsData(s,'V','K','E','Y'))
#define IsMENU(s)	(IsData(s,'M','E','N','U'))
#define IsCDIR(s)	(IsData(s,'C','D','I','R'))
#define IsSCRN(s)	(IsData(s,'S','C','R','N'))
#define IsINEV(s)	(IsData(s,'I','N','E','V'))

void ParseVKEY(char *buf)
{
	struct Programme *p;
	ULONG start,end,code;
	LONG repeat;
	char c;

	buf += 4;

	// VKEY <start> <repeat> <end> <code>
	if(4 == sscanf(buf,"%lu %ld %lu %lu",&start,&repeat,&end,&code))
	{
		;
	}
	else if(4 == sscanf(buf,"%lu %ld %lu '%c'",&start,&repeat,&end,&c))
	{
		code = c;
	}
	else
	{
		return;
	}

	p = &(programme[numprogramme++]);
	p->type = PROG_VKEY;
	p->nexttime = start;
	p->repeattime = repeat;
	p->endtime = end;
	p->code = code;
}


void ParseINEV(char *buf)
{
	ULONG start,repeat,end;
	char str[256];
	struct InputEvent *ie, *ie_next, *ie_prev;
	struct Programme *p;

	buf += 4;

	// INEV <start> <repeat> <end> <ie string>
	if(4 == sscanf(buf,"%lu %ld %lu %s",&start,&repeat,&end,str))
	{
		p = &(programme[numprogramme++]);

		ie = InvertString(str,NULL);

		// Reverse IE list
		ie_prev = NULL;
		while(ie)
		{
			ie_next = ie->ie_NextEvent;
			ie->ie_NextEvent = ie_prev;
			ie_prev = ie;
			ie = ie_next;
		}
		ie = ie_prev;

		p->type = PROG_INEV;
		p->nexttime = start;
		p->repeattime = repeat;
		p->endtime = end;
		p->ie = ie;
	}
}


void ParseMENU(char *buf)
{
	struct Programme *p;
	ULONG start,repeat,end,menu,item,sub;

	buf += 4;

	// MENU <start> <repeat> <end> <menu> <item> <sub>
	if(6 == sscanf(buf,"%lu %ld %lu %lu %lu %lu",&start,&repeat,&end,&menu,&item,&sub))
	{
		p = &(programme[numprogramme++]);
		p->type = PROG_MENU;
		p->nexttime = start;
		p->repeattime = repeat;
		p->endtime = end;
		p->code = FULLMENUNUM(menu, item, sub);
	}
}


void ParseSCRN(char *buf)
{
	ULONG displayid,depth;

	buf += 4;

	if(2 == sscanf(buf,"%lu %lu",&displayid,&depth))
	{
		program_displayid = displayid;
		program_depth = depth;
	}
}


void CopyDataEngine(char *dest, char *source, int m)
{
	source += 4;
	while((*source != '\0') && isspace(*source))
		source++;

	while( (*source != '\0') && (*source != '\n') )
		*dest++ = *source++;

	if(m == 1)
		*dest++ = '\n';

	*dest = '\0';
}

#define CopyData(d,s)	(CopyDataEngine((d),(s),0))
#define CopyDataNL(d,s)	(CopyDataEngine((d),(s),1))


void ParseEntry(BPTR list, char *buf)
{
	CopyData(program_name,buf);
	while( FGets(list, buf, 250) )
	{
		if(IsARGS(buf))
			CopyDataNL(program_args,buf);
		else if(IsVKEY(buf))
			ParseVKEY(buf);
		else if(IsMENU(buf))
			ParseMENU(buf);
		else if(IsCDIR(buf))
			CopyData(program_dir,buf);
		else if(IsSCRN(buf))
			ParseSCRN(buf);
		else if(IsINEV(buf))
			ParseINEV(buf);
		else if(buf[0] == ';')
			;
		else if(isspace(buf[0]))
			break;
		else
			;
	}
}


void PickProgram(void)
{
	BPTR list;
	char buf[256];
	int count;
	ULONG dummyul;
	extern __far ULONG RangeSeed;

	//
	// Counts the number of entries in the
	// programme (by counting PROG tags),
	// picks one at random, and parses that
	// entry
	//

	MBS_GetStringPrefs("program", list_name);

	list = Open(list_name, MODE_OLDFILE);
	if(list)
	{
		count = 0;
		while( FGets(list, buf, 250) )
		{
			if(IsPROG(buf))
				count++;
		}

		Seek(list, 0, OFFSET_BEGINNING);

		if(count > 0)
		{
			CurrentTime(&dummyul,&RangeSeed);
			count = RangeRand(count) + 1;

			while( (count > 0) && FGets(list, buf, 250) )
			{
				if(IsPROG(buf))
					count--;
			}

			if(count == 0)
			{
				ParseEntry(list,buf);
			}
		}
		Close(list);
	}
}


void CleanupProgramme(void)
{
	struct Programme *p;

	p = programme;
	for(; numprogramme>0; numprogramme--)
	{
		if(p->type == PROG_INEV)
			FreeIEvents(p->ie);
		p++;
	}
}


void CloseBlanker(void)
{
	if( program_proc ) KillProgram();
	program_proc = NULL;
	DoneBlankOutputHandler();
	if( win ) CloseWindow( win );
	win = NULL;
	if( scr ) CloseScreen( scr );
	scr = NULL;
	DeleteFakePort();
	DeletePool(fakepool);

	CleanupProgramme();
}


BOOL SetupBlanker(void)
{
	PickProgram();

	scr = OpenScreenTags(NULL,
			SA_Type,		CUSTOMSCREEN,
			SA_DisplayID,	program_depth > 0 ? program_displayid : MBS_GetScreenmodePrefs( 0 ),
			SA_Depth,		program_depth > 0 ? program_depth : MBS_GetScreendepthPrefs( 8 ),
			SA_Quiet,		TRUE,
			SA_SharePens,	TRUE,
			SA_Behind,		TRUE,
			TAG_END);

	if( !scr )
	{
		MBS_ErrorReport( "Couldn't open Screen!" );
		return FALSE;
	}

	SetRGB32( &scr->ViewPort, 0, 0,0,0 );

	win = OpenWindowTags(NULL,
			WA_CustomScreen,	scr,
			WA_AutoAdjust,		TRUE,
			WA_NoCareRefresh,	TRUE,
			WA_Borderless,		TRUE,
			WA_Activate,		FALSE,
			WA_IDCMP,			IDCMP_CHANGEWINDOW,		// Ensures we have an IDCMP port
			TAG_END);

	if( !win )
	{
		MBS_ErrorReport( "Couldn't open Window!");
		return FALSE;
	}

	SetPointer(win, pointerimage, 1, 16, 0, 0);

	if( !SetupBlankOutputHandler( win ) )
	{
		return FALSE;
	}

	if( !LaunchProgram(program_name) )
	{
		MBS_ErrorReport( "Couldn't launch OpenGL program" );
		return FALSE;
	}

	fakepool = CreatePool(MEMF_ANY | MEMF_CLEAR, sizeof(struct IntuiMessage),sizeof(struct IntuiMessage));
	if( !fakepool )
	{
		MBS_ErrorReport( "Couldn't create fake IntuiMessage memory pool" );
		return FALSE;
	}

	if( !CreateFakePort() )
	{
		MBS_ErrorReport( "Couldn't create fake IntuiMessage port" );
		return FALSE;
	}


	return TRUE;
}


void ProcessProgramme(struct Programme *p)
{
	switch(p->type)
	{
		case PROG_VKEY:
			SendFakeVKey(win,p->code);
			break;
		case PROG_MENU:
			SendFakeMenu(win,p->code);
			break;
		case PROG_INEV:
			SendFakeEvents(win,p->ie);
			break;
	}
}


void PlayProgramme(ULONG thistime, ULONG thisframe)
{
	int t;
	struct Programme *p;

	//
	// If the repeat time is negative,
	// use the frame count, otherwise
	// use the time
	//

	p = programme;
	for(t=0; t<numprogramme; t++,p++)
	{
		if(p->repeattime < 0)
		{
			if(p->endtime < thisframe)
				continue;

			if(p->nexttime <= thisframe)
			{
				ProcessProgramme(p);
				p->nexttime -= p->repeattime;
			}
		}
		else
		{
			if(p->endtime < thistime)
				continue;

			if(p->nexttime <= thistime)
			{
				ProcessProgramme(p);
				p->nexttime += p->repeattime;
			}
		}
	}
}


int main(void)
{
	ULONG starttime, lasttime, thistime;
	ULONG framecount,prevcount;

	madblankersupportbase = OpenLibrary(MADBLANKERSUPPORT_NAME,MADBLANKERSUPPORT_VMIN);
	if( !madblankersupportbase ) exit(20);

	//MBS_DebugMode();

	if( !MBS_GetBlankjob() ) {
		CloseLibrary( madblankersupportbase );
		exit(20);
	}

	framecount = prevcount = 0;

	if( SetupBlanker() )
	{
		while( !MBS_ContinueBlanking() )
		{
			prevcount = framecount;
			GetOutputHandlerAttr(BLANK_FrameCount, &framecount);
			if(framecount > 0)
			{
				if(prevcount == 0)
				{
					//
					// First frame we've caught.
					// Note that multiple frames may
					// have already been rendered before
					// we managed to get here.
					// (Very unlikely, but you never know...)
					// Ensure that we at least run the
					// initializers in the programme.
					//
					starttime = lasttime = thistime = (ULONG)time(NULL);
					ScreenToFront( scr );
					PlayProgramme(0, 0);
				}
				else
				{
					//
					// Only go through the programme if
					// the time or framecount changed
					//
					thistime = (ULONG)time(NULL);
					if(((thistime - lasttime) > 0) || (framecount != prevcount))
					{
						lasttime = thistime;
						PlayProgramme(thistime - starttime, framecount);
					}
					GuzzleFakeMsgs();
				}
			}
			Delay(10);
		}
		ScreenToBack( scr );
	}

	//
	// Quit before closing the blanker.
	// The program can take a few
	// seconds to terminate, which
	// leaves the user staring at a
	// blank screen for a while.
	// (The blank screen appears to be
	// generated by Madhouse, which I
	// can't do anything about).
	//
	MBS_Quit();

	CloseBlanker();

	CloseLibrary( madblankersupportbase );

	return(0);
}
