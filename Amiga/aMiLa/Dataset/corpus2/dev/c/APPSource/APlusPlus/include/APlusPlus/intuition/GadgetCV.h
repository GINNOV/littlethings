#ifndef APP_GadgetCV_H
#define APP_GadgetCV_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/GadgetCV.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


class GWindow;

extern "C" {
#include <intuition/intuition.h>
#include <libraries/gadtools.h>
}
#include <APlusPlus/graphics/GraphicObject.h>

class GWindow;
class IntuiMessageC;
/******************************************************************************************
         » GadgetCV class «   virtual base class

   defines all methods that must be implemented for every derived gadget class to work
   together with the GWindow class.
   A virtual callback method is assigned to receive IntuiMessage events sent to the gadget.

 ******************************************************************************************/

class GadgetCV : public GraphicObject
{
   friend class GWindow;
   friend class IntuiMessageC;
   public:
      virtual APTR redrawSelf(GWindow* homeWindow,ULONG& returnType);
      // inherited from GraphicObject

      /** called when window size has been changed after GraphicObject has been adjusted.
       ** The gadget/gadgetlist is removed from the window's gadgetlist when this method is called.
       ** The gadget structure shadowed by the GadgetCV object has to be returned, also the type
       ** of the gadget (Standart,Boopsi,GadTools).
       ** In case of a list of gadgets the gadgets must be linked together (do not forget
       ** the ending null in the last gadgets NextGadget entry!) and then returned
       ** to be linked to the window again.
       **/

      virtual void callback(const IntuiMessageC* imsg)=0;
      /** Here is your way of receiving events from 'this' gadget: overload callback method.
       ** In further derived classes your callback will have to call the callback of the direct
       ** base class of your Gadget class. Look at the description of this base class to know
       ** when to call and why. Never invoke callback directly.
       **/

      ULONG setAttributes(AttrList& attrs);
      ULONG getAttribute(Tag,ULONG&);

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   protected:
      GadgetCV(GraphicObject* owner,AttrList& attrs);

      struct Gadget* storeGadget(struct Gadget*);
      // store the created gadget address in GadgetCV.

      struct Gadget* gadgetPtr()
         { return (struct Gadget*)IObject(); }
      // the shadowed gadget or the first gadget in a list of gadgets is stored in gadgetPtr().

      struct Gadget* getGT_Context();  // give GadTools gadgets their context

      BOOL forceActiveGadget(const IntuiMessageC* imsg);
      // results in this gadget staying active after GADGETUP msg
      // _ONLY_ if msg was not caused by the user activating
      // another gadget (in that case it returns FALSE)!

      GWindow* getHomeWindow();
      // get GWindow that is direct or indirect owner of this gadget

   private:
      static GWindow* redrawSelfHomeWindow;

};

#endif
