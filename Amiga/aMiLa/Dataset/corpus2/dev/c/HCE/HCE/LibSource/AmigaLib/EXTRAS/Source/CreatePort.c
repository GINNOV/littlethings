#include <exec/types.h>
#include <exec/ports.h>
#include <exec/memory.h>

struct MsgPort *CreatePort (name, pri)
char *name;
LONG pri;
{
     int sigBit;
     struct MsgPort *port;

     if ((sigBit = AllocSignal(-1L)) == -1)
          return (NULL);

   port = (struct MsgPort *)
    AllocMem((ULONG)sizeof(struct MsgPort), (ULONG)MEMF_CLEAR|MEMF_PUBLIC);

     if (!port) {
          FreeSignal (sigBit);
          return(NULL);
          }

         port->mp_Node.ln_Name = name;
         port->mp_Node.ln_Pri = pri;
         port->mp_Node.ln_Type = NT_MSGPORT;
         port->mp_Flags = PA_SIGNAL;
         port->mp_SigBit = sigBit;
         port->mp_SigTask = (void *)FindTask (0L);
         if (name)
              AddPort (port);
         else
              NewList (&(port->mp_MsgList));

     return (port);
}
