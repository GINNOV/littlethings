#include <exec/types.h>
#include <exec/memory.h>
#include <exec/io.h>
#include <exec/ports.h>

void DeleteExtIO(ioExt)
struct IORequest *ioExt;
{
    ioExt->io_Message.mn_Node.ln_Type = -1;
    ioExt->io_Message.mn_ReplyPort = (struct MsgPort *) -1;
    ioExt->io_Device = (struct Device *) -1;

    FreeMem (ioExt, (ULONG)ioExt->io_Message.mn_Length);
}

