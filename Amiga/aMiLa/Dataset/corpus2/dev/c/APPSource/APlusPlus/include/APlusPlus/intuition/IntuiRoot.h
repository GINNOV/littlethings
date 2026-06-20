#ifndef APP_IntuiRoot_H
#define APP_IntuiRoot_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/IntuiRoot.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

#include <APlusPlus/intuition/ScreenC.h>
#include <APlusPlus/intuition/IntuiObject.h>


void APPmain(int argc, char* argv[]);

class IntuiRoot : public ScreenC
{
   friend class IntuiObject;
   public:
      static BOOL APPinitialise(int argc, char *argv[]); // returns FALSE on failure
      static void APPexit();
      UWORD getIOBCount() { return iob_count; }
      static ScreenC *getRootScreen() { return (ScreenC*)APPIntuiRoot; }

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   private:
      UWORD iob_count;  // number of currently existing IntuiObjects
      static IntuiRoot *APPIntuiRoot;

      IntuiRoot();
      ~IntuiRoot();
};


#endif
