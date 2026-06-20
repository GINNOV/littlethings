#ifndef APP_MessageC_H
#define APP_MessageC_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/exec/MessageC.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


extern "C"
{
#include <exec/ports.h>
}


/******************************************************************************************
      » MessageC class «

   enhances the EXEC Message structure with some useful methods.
   Most times another EXEC structure that incorporates a 'struct Message' is interpreted
   as a MessageC object in casting it to MessageC. Therefore additional class members must
   not obtain memory since these will not be initialised when only a cast interpretes an
   'struct Message' incorporating EXEC structure.

 ******************************************************************************************/
enum MsgState  // message state returned by 'getMsgState()'
{
   MSG_FREE=1,         // message at your disposal
   MSG_SENT=2,         // message is in the destination msgport queue (NT_MESSAGE)
   MSG_IN_PROCESS=6,   // message is removed from the destination msgport queue (NT_MESSAGE). Note below.
   MSG_REPLIED=9       // message is in the sender msgport queue or already removed from (NT_REPLYMSG)
};
// Note that MSG_IN_PROCESS can only be recognized for messages sent between A++ MsgPort objects!
// A MSG_IN_PROCESS is also a MSG_SENT, as is a MSG_REPLIED also a MSG_FREE
// (==> getMsgState()&MSG_SENT == TRUE also for MSG_IN_PROCESS and
//      getMsgState()&MSG_FREE == TRUE also for MSG_REPLIED, but getMsgState()!=MSG_FREE


class TimedMsgPort;
class MessageC : public Message
{
   friend class TimedMsgPort;
   public:
      MessageC();    // initialise the message to state MSG_FREE
      ~MessageC();   // removes a queued message. Only delete MSG_FREE messages!

      MsgState getMsgState(); // determine the state of the message (see above).

      struct MsgPort *getReplyPort()
         { return mn_ReplyPort; }
      void setReplyPort(struct MsgPort *port);

      BOOL replyMsg();  // returns TRUE if reply was allowed i.e. message was no reply msg. at all

      operator struct Message* () { return (struct Message*)this; }

   protected:
      BOOL isRemoved();
      // states wether the msg is in a port msg queue or not. Do not use this, instead use getMsgState()

      void signRemoved();
      // afterwards 'isRemoved()' returns TRUE. Apply only after GetMsg().
};
#endif
