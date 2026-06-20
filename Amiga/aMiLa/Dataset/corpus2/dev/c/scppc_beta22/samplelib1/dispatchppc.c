#define  _USEOLDEXEC_ 1
#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/memory.h>
#include <exec/resident.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <libraries/dos.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <string.h>
#include <dos/dostags.h>
#include <PowerUP/PPCLib/Interface.h>
#include <PowerUP/PPCLib/tasks.h>
#include <PowerUP/PPCLib/ppc.h>
#include <PowerUP/PPCLib/object.h>
#include <PowerUP/PPCLib/message.h>
#include <powerup/gcclib/powerup_protos.h>

#include "ppcdispatch.h"


void _DispatchFunction(void)
{
    void *PPCPort;
    void *PPCMsg;
    void *ReplyPort;
    void *msg;
    struct PPCDispatchMsg *DispatchMsg;
    long *ret;
    struct TagItem MyTags[10];
    struct StartupData *StartupData;
    
    StartupData	=(struct StartupData *) PPCGetTaskAttr(PPCTASKTAG_STARTUP_MSGDATA);

    if (ret = PPCAllocVec(sizeof(*ret), MEMF_ANY))
    {
      if (PPCPort=(void*) PPCGetTaskAttr(PPCTASKTAG_MSGPORT))
      {
        MyTags[0].ti_Tag = TAG_DONE;
        if (ReplyPort = PPCCreatePort(MyTags))
        {
            if (PPCMsg = PPCCreateMessage(ReplyPort, sizeof(*ret)))
            {
                __fpinit();
                while(1)
                {
                    while ((msg = PPCGetMessage(PPCPort)) == NULL)
                        PPCWaitPort(PPCPort);
            
                    DispatchMsg = (void *)PPCGetMessageAttr(msg, PPCMSGTAG_DATA);           
             
                    if (DispatchMsg->func == NULL)
                    {
                        /* signal to terminate */
                        __fpterm();
                        PPCReplyMessage(msg);
                        break;
                    }
            
                    *ret = DispatchMsg->func(DispatchMsg->r3, DispatchMsg->r4, DispatchMsg->r5,
                                     DispatchMsg->r6, DispatchMsg->r7, DispatchMsg->r8,
                                     DispatchMsg->r9, DispatchMsg->r10);
            
                    PPCReplyMessage(msg);
                    PPCSendMessage(StartupData->MsgPort,
                           PPCMsg,
                           ret,
                           sizeof(*ret),
                           0x87654321);
                    while (PPCGetMessage(ReplyPort) == NULL)
                        PPCWaitPort(ReplyPort);
                }
                PPCDeleteMessage(PPCMsg);
            }
            PPCDeletePort(ReplyPort);
        }
        PPCFreeVec(ret);
      }   
        
    }
}
