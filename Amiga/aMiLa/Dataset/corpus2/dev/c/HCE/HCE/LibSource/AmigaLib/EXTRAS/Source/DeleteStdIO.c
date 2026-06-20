/* Modified by J.P. */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/io.h>

DeleteStdIO (myStdReq)
struct IOStdReq *myStdReq;
{
    myStdReq->io_Message.mn_Node.ln_Type = 0xFF;
    myStdReq->io_Device = (struct Device *) -1;
    myStdReq->io_Unit = (struct Unit *) -1;
    FreeMem (myStdReq, (ULONG)sizeof(struct IOStdReq));
}
