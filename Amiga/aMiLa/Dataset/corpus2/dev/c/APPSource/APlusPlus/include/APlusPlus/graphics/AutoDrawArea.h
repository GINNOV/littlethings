#ifndef APP_AutoDrawArea_H
#define APP_AutoDrawArea_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/graphics/AutoDrawArea.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include <APlusPlus/intuition/StdGadget.h>
#include <APlusPlus/graphics/DrawArea.h>


/******************************************************************************************
         » AutoDrawArea class «   virtual base class

   Base class for rectangular graphical output. Combines a clipped drawing area with a
   rectangular boolean gadget so that mouse actions can be noticed.
   The redrawing after window resizing is done automatically. The user only has to
   define a 'drawSelf' callback where he can make his drawings which are clipped to
   the DrawArea rectangle.

 ******************************************************************************************/
class AutoDrawArea : public StdGadget, public DrawArea
{
   public:
      AutoDrawArea(GOB_OWNER, AttrList& attrs);
      ~AutoDrawArea();

      virtual void drawSelf()=0;      // draw routine (called from redrawSelf or explicitly)
      /** overload this method to define your special draw class.
       **/
      void callback(const IntuiMessageC* imsg);
      /** overload this callback to receive mouse actions within the DrawArea
       ** rectangle.
       ** Call AutoDrawArea::callback(msg) first in your callback!
       ** MouseX,MouseY then will contain view-relative values.
       **/

      ULONG setAttributes(AttrList& attrs);
      ULONG getAttribute(Tag,ULONG&);
      void setBGFillPen(ULONG pen) { bgFillPen = pen; }

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   protected:
      APTR redrawSelf(GWindow* home,ULONG& returnType);   // inherited from GraphicObject
      void clear();

   private:
      ULONG bgFillPen;
};

// error codes

#define AUTODRAWAREA_HAS_NO_GWINDOW_ROOT  (IOTYPE_AUTODRAWAREA+1)

#endif
