#ifndef APP_GT_Boolean_H
#define APP_GT_Boolean_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/GT_Gadgets/GT_Boolean.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include <APlusPlus/intuition/GT_Gadget.h>


class GT_Boolean : public GT_Gadget
{
   public:
      GT_Boolean(GOB_OWNER,AttrList& attrs);

      void callback(const IntuiMessageC* imsg);
      
      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }
};

#endif
