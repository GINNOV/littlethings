/*
	This program is copyright 1990, 1993 Stephen Norris. 
	May be freely distributed provided this notice remains intact.
*/

#include "console.h"
#include "support.h"

/* Globals initialized by findWindow() */
struct ConUnit *conUnit=NULL;

char    Buffer[64];		/* Used for formatting control strings. */

BPTR    OutPut, InPut;

int     Width, Height;

void
conClose()
{
        if (conUnit != NULL)
                setRawCon(DOSFALSE);

	return;
}

int 
conInit()
{
	if (!findWindow())
		return FALSE;

	if (!IsInteractive(OutPut = Output()))
		return FALSE;

	InPut = Input();

	assert(conUnit!=NULL);

	setRawCon(DOSTRUE);

	Width = conUnit->cu_XMax + 1;
	Height = conUnit->cu_YMax + 1;

	return TRUE;
}

/* sendpkt code - A. Finkel, P. Lindsay, C. Scheppner  CBM */

LONG
setRawCon(LONG toggle)
{				/* DOSTRUE (-1L)  or  DOSFALSE (0L) */
	struct MsgPort *conid;
	struct Process *me;
	LONG    myargs[8], nargs, res1;

	me = (struct Process *) FindTask(NULL);
	conid = (struct MsgPort *) me->pr_ConsoleTask;

	myargs[0] = toggle;
	nargs = 1;
	res1 = (LONG) sendpkt(conid, ACTION_SCREEN_MODE, myargs, nargs);
	return (res1);
}


LONG
findWindow()
{				/* inits conWindow and conUnit (global vars) */
	struct InfoData *id;
	struct MsgPort *conid;
	struct Process *me;
	LONG    myargs[8], nargs, res1;

	/* Alloc to insure longword alignment */
	id = (struct InfoData *) AllocMem(sizeof(struct InfoData),
					  MEMF_PUBLIC | MEMF_CLEAR);
	if (!id)
		return (0);
	me = (struct Process *) FindTask(NULL);
	conid = (struct MsgPort *) me->pr_ConsoleTask;

	myargs[0] = ((ULONG) id) >> 2;
	nargs = 1;
	res1 = (LONG) sendpkt(conid, ACTION_DISK_INFO, myargs, nargs);
	conUnit = (struct ConUnit *)
		((struct IOStdReq *) id->id_InUse)->io_Unit;
	FreeMem(id, sizeof(struct InfoData));
	return (res1);
}

LONG
sendpkt(struct MsgPort * pid, LONG action, LONG args[], LONG nargs)
/* *pid - process indentifier ... (handlers message port ) */
/* action - packet type ... (what you want handler to do)   */
/* args a pointer to a argument list */
/* nargs number of arguments in list  */
{
	struct MsgPort *replyport;
	struct StandardPacket *packet;

	LONG    count, *pargs, res1;

	replyport = (struct MsgPort *) CreatePort(NULL, 0);
	if (!replyport)
		return (NULL);

	packet = (struct StandardPacket *)
		AllocMem((long) sizeof(struct StandardPacket), MEMF_PUBLIC | MEMF_CLEAR);
	if (!packet) {
		DeletePort(replyport);
		return (NULL);
	}
	packet->sp_Msg.mn_Node.ln_Name = (char *) &(packet->sp_Pkt);
	packet->sp_Pkt.dp_Link = &(packet->sp_Msg);
	packet->sp_Pkt.dp_Port = replyport;
	packet->sp_Pkt.dp_Type = action;

	/* copy the args into the packet */
	pargs = &(packet->sp_Pkt.dp_Arg1);	/* address of first argument */
	for (count = 0; count < nargs; count++)
		pargs[count] = args[count];

	PutMsg(pid, packet);	/* send packet */

	WaitPort(replyport);
	GetMsg(replyport);

	res1 = packet->sp_Pkt.dp_Res1;

	FreeMem(packet, (long) sizeof(struct StandardPacket));
	DeletePort(replyport);

	return (res1);
}
