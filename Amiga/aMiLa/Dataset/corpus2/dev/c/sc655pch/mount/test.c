#include <dos/dosextens.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include "mount.h"
#include <stdio.h>

int main(int argc, char *argv[])
{
   struct DeviceList *dl;
   struct MsgPort *port, *replyport;
   struct Message *msg;
   struct DosPacket *pkt;

   if(argc<2)
   {
      fprintf(stderr, "USAGE: %s <volumename>\n", argv[0] ? argv[0] : "");
      return(20);
   }
   if(port = CreatePort(0L, 0L))
   {
      if(dl = Mount(argv[1], port))
      {
         printf("Waiting for packets.  Hit CTRL-C to exit.\n");
         while(1)
         {
            while(msg = GetMsg(port))
            {
               pkt = (struct DosPacket *)msg->mn_Node.ln_Name;
               printf("DOS packet type %d received\n", pkt->dp_Type);

               /* Flush the packet back to its origin with an error */
               pkt->dp_Res1 = DOSFALSE;
               pkt->dp_Res2 = ERROR_ACTION_NOT_KNOWN;
               replyport = pkt->dp_Port;
               pkt->dp_Port = port;
               PutMsg(replyport, pkt->dp_Link);
            }
            if(Wait( (1<<port->mp_SigBit) | SIGBREAKF_CTRL_C) & SIGBREAKF_CTRL_C)
               break;
         }
         DisMount(dl);
      }
      else
         fprintf(stderr, "Can't mount volume \"%s\"\n", argv[1]);
      DeletePort(port);
   }
   else
      fprintf(stderr, "Can't create port\n");
   return 0;
}
