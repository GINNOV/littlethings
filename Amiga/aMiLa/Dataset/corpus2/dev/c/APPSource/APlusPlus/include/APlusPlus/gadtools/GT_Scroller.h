#ifndef GT_Scroller_H
#define GT_Scroller_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/GT_Gadgets/GT_Scroller.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include <APlusPlus/intuition/GT_Gadget.h>


/******************************************************************************************
         » GT_Scroller class «

 ******************************************************************************************/

class GT_Scroller : public GT_Gadget
{
   public:
      GT_Scroller(GraphicObject *owner,AttrList& attrs);

      virtual void callback(const IntuiMessageC *imsg);  // specialized callback action

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

};
#endif
