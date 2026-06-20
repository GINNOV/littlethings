#ifndef APP_TimedMsgPort_H
#define APP_TimedMsgPort_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/exec/TimedMsgPort.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include <APlusPlus/exec/SignalResponder.h>
#include <APlusPlus/environment/APPObject.h>

class TimerC;
class MessageC;
/******************************************************************************************
      » TimedMsgPort class «   -  virtual base class

   A TimedMsgPort is a SignalResponder which waits for a MsgPort arrival signal, then
   gets each arrived messages and delivers it to the subclass via the virtual callback
   method.
   After having returned from the processing routine the message will be replied.
   Therefore the subclass must not hold a reference to the message or reply the message
   itself.

 ******************************************************************************************/
struct MsgEntry;
class TimedMsgPort : private SignalResponder
{
   public:
      TimedMsgPort(struct MsgPort *port,UWORD sendWindowSize=1);
      // add a MsgPortRSP to an already existing msg port.

      TimedMsgPort(const UBYTE *portName,BYTE portPri=0,UWORD sendWindowSize=1);
      // create a new msg port with a MsgPortRSP.

      virtual ~TimedMsgPort();

      BOOL sendMsgToPort(MessageC *message,struct MsgPort *destinationPort);
      BOOL sendMsgToPort(MessageC *message,const UBYTE *destinationName);
      // sends the message only if there was place in the sending window,
      // otherwise returns false.
      // 'destinationPort' may also be a 'TimedMsgPort'.
      // The message must not be deleted until it has been replied.


      operator struct MsgPort* () { return port; }

      // make APPObject public
      APPObject::Ok;
      APPObject::error;
      APPObject::ID;
      APPObject::status;
      APPObject::isClass;

      // runtime type inquiry support
      static const Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   protected:
      APPObject::setError;
      APPObject::setID;

      virtual void processMsg(MessageC *msg)=0;    // callback for incoming messages
      virtual void processReply(MessageC *msg)=0;  // callback for returning messages

   private:
      struct MsgPort *port;
      BOOL hasCreatedPort;    // true, if constructor 2 has created this msgport
      UWORD windowSize;       // number of messages that the sending window can hold

      class SendingWindow
      {
         private:
            struct MsgEntry *entryTable;
            UWORD entries;
            UWORD findIndex;
         public:
            SendingWindow(UWORD size);
            ~SendingWindow();
            TimerC *insert(MessageC *msgC);  // returns timeout timer if a free slot was found.
            BOOL remove(MessageC *msgC);     // TRUE if message was found.
            MessageC *timeout(MessageC *timerMsg);
            // returns the message timed out or NULL if it was no timerMsg.
      } sendWindow;

      void actionCallback();   // inherited from SignalResponder
};

// errors
#define MSGPORTRESPONDER_CREATEMSGPORT_FAILED (MSGRESPONDER_CLASS+1)

#endif   /* APP_TimedMsgPort_H */
