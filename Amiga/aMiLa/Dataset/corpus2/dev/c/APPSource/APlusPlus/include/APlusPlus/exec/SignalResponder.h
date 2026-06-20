#ifndef APP_SignalResponder_H
#define APP_SignalResponder_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/exec/SignalResponder.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include <APlusPlus/exec/PriorityList.h>
#include <APlusPlus/environment/APPObject.h>
#include <APlusPlus/environment/TypeInfo.h>


/******************************************************************************************
      » SignalResponder class «  virtual base class

   Each SignalResponder object is chained into a list of SignalResponder objects
   and waits for its individual signal bit to be set. The virtual method actionCallback()
   is called on the event of that signal being set.
 ******************************************************************************************/

class SignalResponder : private PriorityNode, public APPObject
{
   public:
      // set a SRSP to an already allocated signal.
      SignalResponder(UBYTE signal_nr,BYTE pri);

      // allocate a signal with this SRSP.
      SignalResponder(BYTE pri);
      virtual ~SignalResponder();

      static void WaitSignal();

      virtual void actionCallback() = 0;     // overwrite this with your own action

      void changeSignalBit(UBYTE signal_nr);

      // runtime type inquiry support
      static const Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   private:
      static class PriorityList sigRespChain;   // connects all SignalResponder objects
      // DON'T REMOVE THE class KEYWORD. SASC++ DOESN'T COMPREHEND!

      static ULONG waitSignalSet;         // signal mask for Wait()

      ULONG waitSignal;
      BOOL hasAllocatedSig;               // TRUE if 'this' has allocated a new signal
      UBYTE waitSigNr;                    // bit number of the signal 'this' catches

      void initSR(BYTE signal_nr,BYTE pri);
      BOOL applyNodeC(APTR any);   // listnode apply inherited from NodeC
};


#define SIGNALRESPONDER_ALLOCSIGNAL_FAILED (SIGRESPONDER_CLASS+1)
#endif
