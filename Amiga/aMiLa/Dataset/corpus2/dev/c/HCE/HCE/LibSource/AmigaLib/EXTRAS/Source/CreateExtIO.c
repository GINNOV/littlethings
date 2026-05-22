#include <exec/types.h>
#include <exec/memory.h>
#include <exec/io.h>
#include <exec/ports.h>

struct IORequest *CreateExtIO(ioReplyPort, size)
struct MsgPort *ioReplyPort;
ULONG size;
{
    struct IORequest *ioReq;

    if (!ioReplyPort)
       return (NULL);

 ioReq = (struct IORequest *)AllocMem(size, (ULONG)MEMF_CLEAR|MEMF_PUBLIC);
        if (!ioReq)
            return(NULL);

            ioReq->io_Message.mn_Node.ln_Type = NT_MESSAGE;
            ioReq->io_Message.mn_Length = size;
            ioReq->io_Message.mn_ReplyPort = ioReplyPort;

    return (ioReq);
}
