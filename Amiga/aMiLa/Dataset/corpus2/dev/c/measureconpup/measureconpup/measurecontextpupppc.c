/* MeasureContextPUP
 * by Álmos Rajnai (Rachy/BiøHazard)
 * on 28.12.1999
 *
 *  mailto: racs@fs2.bdtf.hu
 *
 * measurecontextwosppc.c
 * This part is the PowerPC core code.
 * It does nothing, just waits for the killing message
 *   and returns to the caller.
 *
 * Partly based on msg2PPC.c example from phase5 PowerUP package examples.
 *
 * See .build file for compiling!
 *
 */

#include <powerup/ppclib/interface.h>
#include <powerup/ppclib/message.h>
#include <powerup/ppclib/tasks.h>
#include <powerup/gcclib/powerup_protos.h>

struct PPCmessage
{
 LONG type;
 LONG regD0;
 LONG regD1;
 LONG regA0;
 LONG regA1;
};

enum { PPCmsg_normal=0, PPCmsg_kill };

int main(void)
{
 void *PPCPort;
 void *M68kMsg;
 struct PPCmessage *Body;
 BOOL keepin=TRUE;

 if (PPCPort=(void*) PPCGetTaskAttr(PPCTASKTAG_MSGPORT))
 {
   while (keepin)
   {
      PPCWaitPort(PPCPort);

      if (M68kMsg=PPCGetMessage(PPCPort))
      {
        Body=(struct PPCmessage *)PPCGetMessageAttr(M68kMsg, PPCMSGTAG_DATA);
        keepin=(Body->type!=PPCmsg_kill);

	PPCCacheFlushAll();

        PPCReplyMessage(M68kMsg);
      }
    }

  }

  return 0;
}

