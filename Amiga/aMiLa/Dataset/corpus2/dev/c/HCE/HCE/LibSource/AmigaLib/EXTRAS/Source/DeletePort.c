#include <exec/types.h>
#include <exec/ports.h>
#include <exec/memory.h>

DeletePort (port)
struct MsgPort *port;
{
    if (port->mp_Node.ln_Name)
         RemPort (port);
    port->mp_SigTask = (void *) -1;
    port->mp_MsgList.lh_Head = (struct Node *) -1;
    FreeSignal(port->mp_SigBit);
    FreeMem (port, (ULONG)sizeof(struct MsgPort));
}

