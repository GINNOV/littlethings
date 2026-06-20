#ifndef APP_IntuiMessageC_H
#define APP_IntuiMessageC_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/IntuiMessageC.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

extern "C" {
#include <intuition/intuition.h>
}
#include <APlusPlus/environment/TypeInfo.h>


/** The IDCMPClass defines a type for all IntuiMessage Classes that makes it impossible to
 **  give a false Class value as parameter where an IntuiMessage Class is requested.
 **/

enum IDCMPClass {
  CLASS_SIZEVERIFY      = IDCMP_SIZEVERIFY ,
  CLASS_NEWSIZE         = IDCMP_NEWSIZE ,
  CLASS_REFRESHWINDOW   = IDCMP_REFRESHWINDOW ,
  CLASS_MOUSEBUTTONS    = IDCMP_MOUSEBUTTONS,
  CLASS_MOUSEMOVE       = IDCMP_MOUSEMOVE ,
  CLASS_GADGETDOWN      = IDCMP_GADGETDOWN ,
  CLASS_GADGETUP        = IDCMP_GADGETUP ,
  CLASS_REQSET          = IDCMP_REQSET ,
  CLASS_MENUPICK        = IDCMP_MENUPICK ,
  CLASS_CLOSEWINDOW     = IDCMP_CLOSEWINDOW,
  CLASS_RAWKEY          = IDCMP_RAWKEY ,
  CLASS_REQVERIFY       = IDCMP_REQVERIFY ,
  CLASS_REQCLEAR        = IDCMP_REQCLEAR ,
  CLASS_MENUVERIFY      = IDCMP_MENUVERIFY  ,
  CLASS_NEWPREFS        = IDCMP_NEWPREFS ,
  CLASS_DISKINSERTED    = IDCMP_DISKINSERTED ,
  CLASS_DISKREMOVED     = IDCMP_DISKREMOVED  ,
  CLASS_WBENCHMESSAGE   = IDCMP_WBENCHMESSAGE ,
  CLASS_ACTIVEWINDOW    = IDCMP_ACTIVEWINDOW ,
  CLASS_INACTIVEWINDOW  = IDCMP_INACTIVEWINDOW  ,
  CLASS_DELTAMOVE       = IDCMP_DELTAMOVE ,
  CLASS_VANILLAKEY      = IDCMP_VANILLAKEY  ,
  CLASS_INTUITICKS      = IDCMP_INTUITICKS ,
  CLASS_IDCMPUPDATE     = IDCMP_IDCMPUPDATE  ,
  CLASS_MENUHELP        = IDCMP_MENUHELP  ,
  CLASS_CHANGEWINDOW    = IDCMP_CHANGEWINDOW  ,
  CLASS_LONELYMESSAGE   = IDCMP_LONELYMESSAGE
};

/******************************************************************************************
      » IntuiMessageC class «

   enhances the IntuiMessages structure with useful methods. The IntuiMessage is inherited
   publically, therefore access is permitted to all structure members, but not recommended.
   The provided methods should handle all necessary access in a safe manner.

 ******************************************************************************************/
class WindowCV;
class GadgetCV;
class GWindow;
class IntuiMessageC : public IntuiMessage
{
   friend class GWindow;
   public:
      IDCMPClass getClass() const { return (IDCMPClass)Class; }
      APTR getIAddress() const { return (APTR)IAddress; }

      BOOL isFakeMsg() const;
         // returns TRUE on GADGETUP/DOWN msg. that was created from GWindow class

      /* The following decode methods transfer Intuition objects into APlusPlus IntuiObjects.
      ** They may return NULL if it was not possible to gain the encapsulating object.
      */
      WindowCV* decodeWindowCV() const;   // get the message emanating window (safe on all messages)
      GadgetCV* decodeGadgetCV() const;   // get the sending GadgetCV object (also safe)

      // runtime type inquiry support
      static const Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   private:
      IntuiMessageC(IDCMPClass);
};
#endif
