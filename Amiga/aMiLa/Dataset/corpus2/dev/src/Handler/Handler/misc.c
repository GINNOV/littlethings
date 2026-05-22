/* misc.c  - support routines - Phillip Lindsay (C) Commodore 1986  
 *  You may freely distribute this source and use it for Amiga Development -
 *  as long as the Copyright notice is left intact.
 *
 * 30-SEP-86
 */

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/ports.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>

#ifdef MANX
#include <functions.h>
#endif

/* returnpkt() - packet support routine 
 * here is the guy who sends the packet back to the sender...
 * 
 * (I modeled this just like the BCPL routine [so its a little redundant] )
 */
 
void returnpkt(packet,res1,res2)

struct DosPacket *packet;
ULONG  res1,res2;

{
 struct Message *mess;
 struct MsgPort *replyport;
 struct Process *myproc;
 
 packet->dp_Res1          = res1;
 packet->dp_Res2          = res2; 
 replyport                = packet->dp_Port;
 mess                     = packet->dp_Link;
 myproc                   = (struct Process *) FindTask(0L);
 packet->dp_Port          = &myproc->pr_MsgPort;
 mess->mn_Node.ln_Name    = (char *) packet;
 mess->mn_Node.ln_Succ    = NULL;
 mess->mn_Node.ln_Pred    = NULL;
 
 PutMsg(replyport,mess); 

}


/*
 * taskwait() ... Waits for a message to arrive at your port and 
 *   extracts the packet address which is returned to you.
 */

struct DosPacket *taskwait()
{
 struct Process *myproc;
 struct MsgPort *myport;
 struct Message *mymess;

 myproc = (struct Process *) FindTask(0L);
 myport = &myproc->pr_MsgPort;

 WaitPort(myport); /* wait for packet */
 mymess = (struct Message *) GetMsg(myport);

/* give them the pointer to the packet */
return((struct DosPacket *) mymess->mn_Node.ln_Name);
} 

/* end of misc.c */
