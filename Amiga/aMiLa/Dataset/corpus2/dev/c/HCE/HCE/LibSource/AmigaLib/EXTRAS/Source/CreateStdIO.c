/* Modified by (J.P). */

#include <exec/types.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <exec/io.h>

struct IOStdReq *CreateStdIO (taskReplyPort)
struct MsgPort *taskReplyPort;
{
    struct IOStdReq *myStdReq;

    if (!taskReplyPort)
        return(NULL);

     myStdReq=(struct IOStdReq *)AllocMem ((ULONG)sizeof (struct IOStdReq),
                           (ULONG)MEMF_CLEAR | MEMF_PUBLIC);
        if (myStdReq) {
            myStdReq->io_Message.mn_Node.ln_Type = NT_MESSAGE;
            myStdReq->io_Message.mn_Node.ln_Pri = 0;
            myStdReq->io_Message.mn_ReplyPort = taskReplyPort;
            }

    return (myStdReq);
}

