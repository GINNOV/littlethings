#ifndef APP_Dependencies_H
#define APP_Dependencies_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/environment/Dependencies.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

extern "C" {
#include <exec/types.h>
}

/******************************************************************************
      » Shared class «

   Objects that are accessed from various other objects that should span the 
   lifetime of their accessors can be tracked with the Shared class. The first 
   accessing object creates the Shared instance, other objects may participate 
   in the access and the last accessing object that releases its hold on the 
   Shared instance causes its destruction.

   REMEMBER: Shared objects may only be constructed dynamically via the 
             new operator!

 *******************************************************************************/
class Shared
{
   private:
      WORD participants;

   public:
      Shared() { participants = 1; }   // contruction implies an access permission.
      virtual ~Shared() { };     // must be virtual to be able to delete itself correctly.

      Shared *participate() { participants++; return this; }
      WORD release() { if (--participants <= 0) { delete this; return 0; } else return participants; }
};

#endif
