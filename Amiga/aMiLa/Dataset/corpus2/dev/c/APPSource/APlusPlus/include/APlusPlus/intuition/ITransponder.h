#ifndef ITransponder_H
#define ITransponder_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/ITransponder.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include <APlusPlus/environment/APPObject.h>
#include <APlusPlus/environment/TypeInfo.h>
#include <APlusPlus/utility/AttrList.h>


/******************************************************************************************
         » ITransponder class «  virtual base class

   interposes between two (or even more) IntuiObjects exchanging messages about their
   state represented by their attribute tags. In fact there is exactly one IntuiObject
   which sends messages about its tags changed and one IntuiObject receiving these
   notifications.
   This class provides you with the ability to filter and work on these messages as you
   like. This is achieved through the sender method being virtual.

   The IntuiObject you have your ITransponder attached to now calls 'sendNotification'
   on each change of one of its attributes with the list of these class specific attribute
   tags that have changed.
   There you may map attributes to class specific attributes of the receiving IntuiObject,
   or you may spread notifications to several other IntuiObjects.

   The reason why 'sendNotification' has not been implemented as virtual method to the
   IntuiObject itself is that a seperate object avoides the need of deriving the IntuiObject
   itself, and one ITransponder can interpose between several IntuiObjects.

 ******************************************************************************************/
class IntuiObject;
class ITransponder
{
   friend class IntuiObject;  // needs access to sendNotification()
   public:
      // set the IntuiObject that is to receive notifications
      void setReceiver(IntuiObject* newReceiver);

      static ITransponder* confirm(ITransponder* itp)
         { return itp; }

      // runtime type inquiry support
      static const Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   protected:           // you must derive for overloading sendNotification()
      IntuiObject* receiver1;    // IntuiObject which will be noticed on each 'sendNotification'
      ITransponder(IntuiObject* iob=NULL) { receiver1 = iob; }

      virtual void sendNotification(AttrList& )=0;  // notify


};

class MapITP : public ITransponder
{
   public:
      MapITP(IntuiObject *receiver,AttrList&);
      virtual ~MapITP() {}

   private:
      AttrList mapAttrlist;
      void sendNotification(AttrList& );
};


/******************************************************************************************
   example of a specialized ITransponder:

   class Prop2Canvas : public ITransponder
   {
      public:
         virtual void sendNotification(TAGLIST)
         {
            mapTags( taglist,
                     PGA_Top  , CV_HorizTop,
                     PGA_Total, CV_HorzTotal,
                     TAG_END
                  );
            if (receiver1) receiver1->setAttributes(taglist);
         }
   };
 ******************************************************************************************/
#endif
