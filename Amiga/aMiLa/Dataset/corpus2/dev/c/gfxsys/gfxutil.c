#include <simple/inc.h>
#include <simple/intuition.h>

extern struct Library * IntuitionBase;

void PreCloseSharedWindow (struct Window * Win)
{
struct IntuiMessage * Msg;
struct Node * Succ;

Forbid(); //turn off multitasking

//eat all messages for the window we're going to close:

Msg = (struct IntuiMessage *) (Win->UserPort->mp_MsgList.lh_Head);
while ( (Succ = Msg->ExecMessage.mn_Node.ln_Succ) )
	{
	if (Msg->IDCMPWindow == Win)
		{
		Remove((struct Node *)Msg);   //take it out of the list
		ReplyMsg((struct Message *)Msg);
		}
	Msg = (struct IntuiMessage *) Succ;
	}

Win->UserPort=NULL; //tell intuition not to free it
ModifyIDCMP(Win,0); //tell intuition to stop sending messages

Permit();
}

void CloseSharedWindow (struct Window * Win)
{
PreCloseSharedWindow(Win);

CloseWindow(Win);
}
