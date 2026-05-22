#ifndef APP_TimerC_H
#define APP_TimerC_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/devices/TimerC.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

extern "C"
{
#include <devices/timer.h>
}
#include <APlusPlus/environment/APPObject.h>
#include <APlusPlus/environment/TypeInfo.h>


/******************************************************************************************
         » TimerC class «

   This class provides access to the timer device. Each TimerC object is dedicated to one
   message port where it sends its timerequest to.
   There are four units available with specific advantages (see RKM:Devices):
   UNIT_MICROHZ, UNIT_VBLANK, UNIT_ECLOCK, UNIT_WAITUNTIL and UNIT_WAITECLOCK.

 ******************************************************************************************/

class TimerC : public APPObject
{
   public:
      TimerC(UWORD unit,struct MsgPort *replyPort);    // create a timer object to a msgport.
      virtual ~TimerC();

      // new time setting becomes active for the next timer start.
      void set(ULONG secs=0,ULONG micros=0)
         { time.tv_secs = secs; time.tv_micro = micros; }
      void changeReplyPort(UWORD unit,struct MsgPort *newReplyPort);

      // activate timer: send to timer device, will be put into the
      // replyPort's message queue after set time elapsed
      // (for UNIT_MICROHZ, UNIT_VBLANK, UNIT_ECLOCK) or has been
      // reached (for UNIT_WAITUNTIL and UNIT_WAITECLOCK).

      BOOL start(ULONG secs = 0,ULONG micros = 0);
      // Start Timer in sending it. Only not already sent timer requests
      // can be started.
      // If the Timer could not be started, FALSE is returned.
      // If both parameters are 0 the old time setting is used.

      void abort();  // results in a safely aborted timer that can be reused. (safe for non-sent timers)
      BOOL reuse();  // prepare returned Timer for next start(). If returns FALSE force with abort().

      /** Incoming messages can be identified as TimerC objects by comparing the message address
       ** to the created TimerC objects:
       **   TimerC timerC;
       **   if (timerC.recognize(receivedMsg))  "timerC has returned"  else  "not timerC!"
       ** The class user is responsible for recognizing replied  TimerC IORequests.
       **/
      struct Message *getMessage()
         { return &timerIO.tr_node.io_Message; }
      BOOL recognize(struct Message *receivedMsg)
         { return (getMessage()==receivedMsg); }

      // runtime type inquiry support
      static const Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   private:
      struct timerequest timerIO;
      struct timeval time;
      BOOL sent;           // indicates wether the IORequest has been sent or not.

      BOOL create(UWORD unit,struct MsgPort *replyPort);
      void dispose();


};

//------------ errors ----------------------------------------------------------
#define TIMER_OPENDEVICE_FAILED     (TIMER_CLASS + 1)
#define TIMER_CREATEEXTIO_FAILED    (TIMER_CLASS + 2)

#endif   /* APP_TimerC_H */
