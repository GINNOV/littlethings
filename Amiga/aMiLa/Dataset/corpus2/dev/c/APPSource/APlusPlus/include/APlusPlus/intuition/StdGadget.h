#ifndef APP_StdGadget_H
#define APP_StdGadget_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/StdGadget.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include <APlusPlus/intuition/GadgetCV.h>


/******************************************************************************
         » StdGadget class «

   Encapsulation of all standard Intuition gadgets. Geometry is solely
   managed by the GraphicObject class.

 ******************************************************************************/

class StdGadget : public GadgetCV
{
   public:
      StdGadget(  GOB_OWNER,
                  UWORD flags,
                  UWORD activation,
                  UWORD gadgetType,
                  APTR gadgetRender,
                  APTR selectRender,
                  struct IntuiText* gadgetText,
                  LONG mutualExclude,
                  APTR specialInfo,
                  UWORD gadgetID,
                  AttrList& attrs);
      // specify the
      StdGadget(GOB_OWNER, AttrList& attrs);

      APTR redrawSelf(GWindow* homeWindow,ULONG& );

      ULONG setAttributes(AttrList& attrs);
      ULONG getAttribute(Tag tag,ULONG& dataStore);

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   private:
      struct Gadget gadget;
};

#define SGA_Dummy    (IOTYPE_STDGADGET+1)
#define SGA_Flags    (SGA_Dummy+1)
   //    GFLG_GADGHNONE);
#define SGA_Activation  (SGA_Dummy+1)
   // GACT_IMMEDIATE|GACT_RELVERIFY);
#define SGA_GadgetType  (SGA_Dummy+1)
   // GTYP_BOOLGADGET
#define SGA_GadgetRender   (SGA_Dummy+1)
   // NULL
#define SGA_SelectRender   (SGA_Dummy+1)
   // NULL
//GA_Text
   // NULL
#define SGA_MutualExclude  (SGA_Dummy+1)
   // 0
#define SGA_SpecialInfo    (SGA_Dummy+1)
   // NULL

#endif
