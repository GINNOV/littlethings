#ifndef APP_GWindow_H
#define APP_GWindow_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/GWindow.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include <APlusPlus/intuition/WindowCV.h>
#include <APlusPlus/graphics/DrawArea.h>
#include <APlusPlus/graphics/FontC.h>


class GadgetCV;
/******************************************************************************
      » GWindow class «

   This Window class combines all Intuition supported gadget types including
   BOOPSI and GadTools. All gadget types may be used together in one GWindow.
   Furthermore a DrawArea is provided for the inner window box.

 ******************************************************************************/

class GWindow : public WindowCV, public DrawArea
{
   friend class GadgetCV;
   public:
      GWindow(IntuiObject* owner,AttrList& attrs);
      ~GWindow();

      void refreshGList()        // redraw all gadgets
         { On_NEWSIZE(NULL); }

      const FontC& getScreenFont() // this is the Screen Text font from Preferences..
         { return screenFont; }
      const FontC& getDefaultFont() // and this the System Default font from Preferences
         { return defaultFont; }

      void setActiveGadget(GadgetCV* newActive);
      // force a certain Gadget to become the active one, that is the one that
      // receives all undirected IDCMP messages.
      // 'newActive' may be NULL to deactivate itself

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   protected:
      void handleIntuiMsg(const IntuiMessageC* imsg); // inherited from WindowCV

   private:
      GadgetCV* activeGadget;
         // the current gadget to get all IDCMP messages that have no IAddress.
      GadgetCV* defaultGadget;
      struct Gadget* firstUserGad;
         // holds the beginning of the list of user gadgets.
         // Remember: The first gadgets in a window's list after being opened are
         // the system gadgets!
      struct Gadget* GT_context; // context data for Gadtools.
      struct Gadget* GT_last;    // tail of the linked list of GadTools gadgets during the ON_NEWSIZE proc.
      FontC screenFont;
      FontC defaultFont;

      // IDCMP callbacks
      void On_GADGETDOWN(const IntuiMessageC*);
      void On_GADGETUP(const IntuiMessageC*);
      void On_SIZEVERIFY(const IntuiMessageC*);
      void On_NEWSIZE(const IntuiMessageC*);
      void On_REFRESHWINDOW(const IntuiMessageC*);
};
#endif
