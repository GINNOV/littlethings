#ifndef GT_String_H
#define GT_String_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/GT_Gadgets/GT_String.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include <APlusPlus/intuition/GT_Gadget.h>


/******************************************************************************************
         » GT_String class «

 ******************************************************************************************/

class GT_String : public GT_Gadget
{
   public:
      GT_String(GOB_OWNER,AttrList& attrs);

      APTR redrawSelf(GWindow *homeWindow,ULONG& returnType);

      virtual void callback(const IntuiMessageC* imsg);  // specialized callback action
      ULONG getAttribute(Tag tag,ULONG& dataStore);

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

};

//#define GTST_String   // defined in <libraries/gadtools.h>
/* (UBYTE*). Set/get the current string that is displayed in the String gadget.
   With getAttribute(GTST_String,data) you can read the current string at any time.
*/
#endif
