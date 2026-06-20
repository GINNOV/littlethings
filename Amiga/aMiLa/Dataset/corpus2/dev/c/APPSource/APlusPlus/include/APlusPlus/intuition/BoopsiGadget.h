#ifndef APP_BoopsiGadget_H
#define APP_BoopsiGadget_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/BoopsiGadget.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

extern "C" {
#include <intuition/gadgetclass.h>
#include <intuition/classes.h>
#include <intuition/icclass.h>
#include <intuition/classusr.h>
}
#include <APlusPlus/intuition/GadgetCV.h>


/******************************************************************************************
         » BoopsiGadget class «

   identifies Boopsi gadgets with a GadgetCV object.
   The BoopsiGadget user MUST announce each attribute in the creation taglist that is
   likely to change due to user activity.
   Since the underlying BoopsiGadget is disposed and recreated each time the windowsize
   changes the IntuiObject creation taglist is applied for recreation, and all tags that
   are not explicitly set will adopt default values.

 ******************************************************************************************/
class BoopsiGadget : public GadgetCV
{
   public:
      // create Boopsi gadget from given Boopsi class name.
      BoopsiGadget(  GraphicObject* owner, UBYTE* pubClass, AttrList& attrs);

      // create Boopsi gagdet from private class pointer.
      BoopsiGadget(  GraphicObject* owner, Class* privClass, AttrList& attrs);

      ~BoopsiGadget();

      APTR redrawSelf(GWindow*,ULONG&);         // inherited from GraphicObject
      void callback(const IntuiMessageC* imsg); // inherited from GadgetCV

      // change gadget attributes
      ULONG setAttributes(AttrList& attrs);     // inherited from IntuiObject

      // read a specific attribute. Returns 0L if the object does not recognize the attribute.
      ULONG getAttribute(Tag ,ULONG& dataStore);

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }


   /** BOOPSI gadgets are object pointer to one Intuition gadget that represents the
    ** BOOPSI object and is linked to the window's gadget list.
    **/
   private:
      UBYTE*   publicClass;
      IClass*  privateClass;     // IClass is from Kick.3.0 includes !!

      void create(Class* ,UBYTE* , const AttrList& );

};

#define BOOPSIGADGET_NEWOBJECT_FAILED  (IOTYPE_BOOPSIGADGET+1)

#endif


