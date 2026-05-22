#ifndef APP_GT_Gadget_H
#define APP_GT_Gadget_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/GT_Gadget.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

extern "C" {
#include <libraries/gadtools.h>
#include <intuition/gadgetclass.h>
}
#include <APlusPlus/intuition/GadgetCV.h>


/******************************************************************************************
         » GT_Gadget class «    virtual base class

   identifies all GadTools gadgets with a GadgetCV object.
   Notice that there must be a GWindow derived object upwards in the owner tree.
 ******************************************************************************************/

class GT_Gadget : public GadgetCV
{
   public:
      GT_Gadget(GraphicObject* owner,ULONG createKind,AttrList& attrs);
      ~GT_Gadget();

      APTR redrawSelf(GWindow* ,ULONG&);         // inherited from GraphicObject
      ULONG setAttributes(AttrList& attrs);              // inherited from IntuiObject
      ULONG getAttribute(Tag,ULONG& dataStore);

      void callback(const IntuiMessageC* imsg);  // inherited from GadgetCV

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   private:
      ULONG kind;
};


#define GTGADGET_Dummy           (IOTYPE_GTGADGET + 1)
#define GT_TextAttr              (GTGADGET_Dummy + 1)
#define GT_IDCMP                 (GTGADGET_Dummy + 2)
#define GT_Flags                 (GTGADGET_Dummy + 3)


#define GT_GADGET_CREATE_FAILED  (GTGADGET_Dummy + 1)
#define GT_GADGET_NO_CONTEXT     (GTGADGET_Dummy + 2)
#define GT_GADGET_NO_VISUALINFO  (GTGADGET_Dummy + 3)

#endif
