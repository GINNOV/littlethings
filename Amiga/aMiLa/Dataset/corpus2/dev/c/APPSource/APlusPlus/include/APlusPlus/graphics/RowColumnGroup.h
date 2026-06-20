#ifndef APP_RowColumnGroup_H
#define APP_RowColumnGroup_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/graphics/RowColumnGroup.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include <APlusPlus/intuition/GadgetCV.h>


/******************************************************************************

      RowColumnGroup class

   This class introduces a new way of adjusting its childs to new dimensions.
   The childs are assumed to have a fixed size which they must initialise on
   creation. Each time the RowColumnGroup object's size changes its childs are
   spread over the RCG plane, positioned in rows and columns, from left to right
   and from top to bottom, starting with the first child and following their
   order in the dependency list.

 ******************************************************************************/

class RowColumnGroup : public GadgetCV
{
   public:
      RowColumnGroup(GOB_OWNER,AttrList& attrs);
      ~RowColumnGroup();

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }
      
      void callback(const IntuiMessageC* imsg);
      
   protected:
      void adjustChilds();    // implements new GOB_Tags
};

#define RCG_Dummy    (IOTYPE_GROUPGADGET+1)

#endif
