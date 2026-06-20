/*************************************************************************
 * (C) 1986 Commodore-Amiga
 * Example program to demonstrate finding the CON: window pointer
 * by Andy Finkel and Robert (Kodiak) Burns
 *
 * Use it any way you like, as long as the copyright notice is left on.
 *
 ************************************************************************/
#include	"exec/types.h"
#include	"exec/ports.h"
#include	"exec/io.h"
#include	"exec/memory.h"
#include	"devices/console.h"
#include	"devices/conunit.h"
#include	"libraries/dos.h"
#include	"libraries/dosextens.h"
#include	"intuition/intuitionbase.h"
#include	"workbench/startup.h"
#include	"workbench/workbench.h"

extern struct Library *OpenLibrary();
struct IntuitionBase *IntuitionBase = 0;

struct MsgPort iorp = {
    {0, 0, NT_MSGPORT, 0, 0}, 0,
    -1,				/* initialize signal to -1 */
    0,
				/* start with empty list */
    {&iorp.mp_MsgList.lh_Tail, 0, &iorp.mp_MsgList.lh_Head, 0, 0}
};
struct IOStdReq ior = {
    {{0, 0, 0, 0, 0}, &iorp, 0},
    0				/* device is zero */
};



cleanup(code)
{
    if (ior.io_Device != 0) {
	if (iorp.mp_SigBit != -1) {
	    FreeSignal(iorp.mp_SigBit);
	}
	CloseDevice(&ior);
    }
    CloseLibrary(IntuitionBase);
  
    exit(20);
}

main(argc, argv)
int argc;
char *argv[];
{
    struct MsgPort *con;
    UBYTE *s1, *s2;
    struct StandardPacket *packet;
    struct InfoData *id;
    short i;

    if ((IntuitionBase = OpenLibrary("intuition.library", 0)) == 0) {
	exit(20);
    }

    /* open the console device */
    if ((OpenDevice("console.device", -1, &ior, 0)) != 0) {
	cleanup(0);
	exit(30);
    }

    /* set up the message port in the I/O request */
    if ((iorp.mp_SigBit = AllocSignal(-1)) < 0) {
	cleanup(0);
	exit(35);
    }
    iorp.mp_SigTask = (struct Task *) FindTask((char *) NULL);


    /* try to find console associated with calling process */
    /* if started from CLI, than is 			   */
    if ((iorp.mp_SigTask->tc_Node.ln_Type == NT_PROCESS)&&(argc != 0)) {
	con = (struct MsgPort *) 
	    ((struct Process *) iorp.mp_SigTask) -> pr_ConsoleTask;
	if (con != 0) {
	    if ((packet = (struct StandardPacket *)
		    AllocMem(sizeof(*packet), MEMF_CLEAR))) {
		if ((id = (struct id *) AllocMem(sizeof(*id), MEMF_CLEAR))) {
		    /* this is the console handlers packet port */
		    packet->sp_Msg.mn_Node.ln_Name = &(packet->sp_Pkt);
		    packet->sp_Pkt.dp_Link = &(packet->sp_Msg);
		    packet->sp_Pkt.dp_Port = &iorp;
		    packet->sp_Pkt.dp_Type = ACTION_DISK_INFO;
		    packet->sp_Pkt.dp_Arg1 = ((ULONG) id) >> 2;
		    PutMsg(con, packet);
		    WaitPort(&iorp);
		    /* using the window directly here */
		    WindowToBack(id->id_VolumeNode);
		    WindowToFront(id->id_VolumeNode);
		    if ((id->id_InUse) && 
			(IntuitionBase->LibNode.lib_Version >= 33)) {

			/* new DOS: IOB for console.device */
			/* using the console directly here */
			ior.io_Unit =
				((struct IOStdReq *) id->id_InUse)->io_Unit;
			ior.io_Command = CMD_WRITE;
			ior.io_Data = "HELLO WORLD\n";
			ior.io_Length = 12;
			DoIO(&ior);
		    }
		    FreeMem(id, sizeof(*id));
		}
		FreeMem(packet, sizeof(*packet));
	    }
	}
    }
    ior.io_Unit = (struct Unit *) -1;
    cleanup(0);
}

