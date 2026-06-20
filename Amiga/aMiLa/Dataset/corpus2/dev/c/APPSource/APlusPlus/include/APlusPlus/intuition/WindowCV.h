#ifndef APP_WindowCV_H
#define APP_WindowCV_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/WindowCV.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


extern "C" {
#include <intuition/intuition.h>
}
#include <APlusPlus/exec/SignalResponder.h>
#include <APlusPlus/graphics/GraphicObject.h>
#include <APlusPlus/environment/Dependencies.h>


class ScreenC;
class IntuiMessageC;
/******************************************************************************
      » IntuitionResponder class «

   The IntuitionResponder class is a specialized SignalResponder that awaits
   signals on its dedicated userport. It receives the incoming IDCMP messages
   of one userport that may be shared between several Intuition® windows and
   delivers them to their respective WindowCV object.

   The IntuitionResponder class is a supportive class for the WindowCV class
   and not designed to work with other classes.  DO NOT USE THIS CLASS!

 ******************************************************************************/
class WindowCV;
class IntuitionResponder : public Shared, private SignalResponder
{
   friend class WindowCV;       // needs access to msgInProcess
   private:
      struct MsgPort* userPort;           // window userport of one or more windows
      struct IntuiMessage* msgInProcess;  // holds the last received yet not replied message

      void actionCallback();              // inherited from SignalResponder


      IntuitionResponder(struct MsgPort* IPort);
      ~IntuitionResponder();

      struct MsgPort* getMsgPort() { return userPort; }
      WORD release(Window* );
};


/******************************************************************************
      » WindowCV class «   virtual base class
      » IntuitionResponder class «

   A WindowCV object stands for one single Intuition window and shares its
   lifetime.

   The WindowCV constructor opens the window (Check with obj.Ok() wether the
   window could successfully be opened!) and the destructor closes it.

   The IDCMP message passing is handled by a special MsgPort responder,
   the IntuitionResponder. One IntuitionResponder lives independent of a
   WindowCV object, but each WindowCV object refers to an IntuitionResponder
   who controls the window's user port. It is possible that several WindowCV
   objects, and thereby several Intuition windows, share an IntuitionResponder
   (== UserPort). This can be achieved by using the WCV_SharePortWithWindow tag
   which needs a WindowCV object as parameter.

 ******************************************************************************/

class WindowCV : public GraphicObject
{
   friend class IntuiMessageC;
   friend class IntuitionResponder;

   public:
      static void WaitSignal()
         { SignalResponder::WaitSignal(); } // wait for events

      // window methods
      ULONG setAttributes(AttrList& attrs);     // inherited from IntuiObject
      ULONG getAttribute(Tag,ULONG& dataStore);

      const STRPTR title()
         { return (const STRPTR)window()->Title; }
      // only for compatibility.
      // Use getAttribute() for WA_Title or WA_ScreenTitle instead.

      const struct Window* windowPtr()
         { return (const struct Window*)IObject(); }
      operator const struct Window* ()
         { return (const struct Window*)IObject(); }

      ScreenC* screenC(); // returns the ScreenC object the window is in.

      void modifyIDCMP(ULONG flags);
            // type checking for tag data values (see below)
      static LONG confirm(WindowCV* obj) { return (LONG)obj; }

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   protected:
      struct Window* window()    // read/write access to the encapsulated Intuition window
         { return (struct Window*)IObject(); }

      // create window
      WindowCV(IntuiObject* owner,AttrList& attrs);
      ~WindowCV();

      // message handler: must be filled with functionality by the derived classes
      virtual void handleIntuiMsg(const IntuiMessageC* imsg) = 0;

      // need to be called on changed window size
      void newsize(const IntuiMessageC*);

      IntuitionResponder* getIntuiResponder()
         { return window_rsp; }

   private:
      IntuitionResponder* window_rsp;     // msgport responder for the windows userport
      struct Window*& window_ref()
         { return (struct Window*&)IObject(); }
};

#define WCV_Dummy (TAG_USER | IOTYPE_WINDOWCV)

#define WCV_SharePortWithWindow  (WCV_Dummy+3)
#define WCV_SharePortWithWindowObj(window) WCV_SharePortWithWindow,WindowCV::confirm(window)
   /* let the window use the same user port as the window given in ti_Data. Prefer using
    * the WCV_SharePortWithWindowObj(WindowCV* window) macro which assures type checking.
    */

#define WINDOWCV_OPENWINDOW_FAILED (IOTYPE_WINDOWCV+1)

#endif
