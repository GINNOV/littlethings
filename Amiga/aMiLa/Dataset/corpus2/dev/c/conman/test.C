#include <simple/inc.h>
#include <simple/intuition.h>

#include "conman.h"
#include "raw2vanilla.h"

struct Window *ProgW = NULL;
struct NewWindow ProgNW=
  {
  0,0,      //TL corner
  320,200,  //size
  0,1,      //pens
	IDCMP_REFRESHWINDOW |	IDCMP_NEWSIZE |	IDCMP_RAWKEY | IDCMP_CLOSEWINDOW | IDCMP_CHANGEWINDOW,
	WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_SIZEGADGET|WFLG_SIMPLE_REFRESH|WFLG_ACTIVATE ,
  NULL,     //FirstGadget
  NULL,     
  "Console Win",     //Title
  NULL,     //Screen
  NULL,     //BitMap
  100,20,  //min
  640,400,  //max
  WBENCHSCREEN
  };

struct Library * GfxBase = NULL;
struct Library * UtilityBase = NULL;

struct IntuitionBase *IntuitionBase = NULL;
struct ConInfo * ConInfo = NULL;

void InitAll(void);
void CleanUp(char *,int);
void MainLoop(void);

int main(int argc,char **argv)
{
InitAll();

MainLoop();

CleanUp(NULL,0);
}

void InitAll(void)
{
if ( (IntuitionBase=(struct IntuitionBase *)
 OpenLibrary("intuition.library",0)) == 0 )
  CleanUp("Can't open intuition library!",20);

if ( (UtilityBase = OpenLibrary("utility.library",0)) == NULL )
  CleanUp("Can't open utility library!",20);

if ( (GfxBase = OpenLibrary("graphics.library",0)) == NULL )
  CleanUp("Can't open graphics library!",20);

if ((ProgW=OpenWindow(&ProgNW))==NULL)
  CleanUp("Couldn't open window!",10);

if ( (ConInfo = InitCon(ProgW,TAG_DONE)) == NULL )
	CleanUp("Couldn't InitCon!",10);

AddCon(ConInfo,"The Console Has Arrived!");
AddCon(ConInfo,"Go to it:");
}

void CleanUp(char *mess ,int rc)
{
if (ConInfo) CloseCon(ConInfo);

if (ProgW) CloseWindow(ProgW);

if (mess) puts(mess);

if (IntuitionBase) CloseLibrary((struct Library *)IntuitionBase);
if (GfxBase) 			 CloseLibrary(GfxBase);
if (UtilityBase)   CloseLibrary(UtilityBase);

exit(rc);
}

void MainLoop(void)
{
struct IntuiMessage *Msg;
ULONG MsgClass;
ulong MsgCode;
ulong MsgQual;
char TheStr[1024];
bool AskingQuit = 0;

while(1)
  {
  WaitPort(ProgW->UserPort);
  while (Msg=(struct IntuiMessage *)GetMsg(ProgW->UserPort))
    {
    MsgClass = Msg->Class;
		MsgCode  = Msg->Code;
		MsgQual  = Msg->Qualifier & 0x00FF;
    ReplyMsg((struct Message *)Msg);
    
    switch (MsgClass)
      {
			case IDCMP_RAWKEY:
				if ( MsgCode == 68 )
					{
					GetCon(ConInfo,TheStr);
					puts(TheStr);
					}
				HandleCon(ConInfo,MsgCode,MsgQual);
				if ( AskingQuit )
					{
					if ( Raw2Vanilla(MsgCode,0) == 'y' || Raw2Vanilla(MsgCode,0) == '\n' || Raw2Vanilla(MsgCode,0) == 'q' )
						return;
					else
						AskingQuit = 0;
					AddCon(ConInfo," ");
					AddCon(ConInfo,"Ok, not quiting");
					}
				break;
			case IDCMP_CHANGEWINDOW:
			case IDCMP_NEWSIZE:
				ModifyCon(ConInfo,CON_ReadWin,ProgW,TAG_DONE);
			  RedrawCon(ConInfo);
				break;
			case IDCMP_REFRESHWINDOW:
				BeginRefresh(ProgW);
				RedrawCon(ConInfo);
				EndRefresh(ProgW,TRUE);
        break;
      case IDCMP_CLOSEWINDOW:
				AddCon(ConInfo,"Got quit request. Do it? (y/n)");
				AskingQuit = 1;
        break;
      default:
        break;
      }
    }
  }
}
