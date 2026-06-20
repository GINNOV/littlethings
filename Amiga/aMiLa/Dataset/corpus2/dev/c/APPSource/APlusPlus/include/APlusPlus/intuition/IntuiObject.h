#ifndef APP_IntuiObject_H
#define APP_IntuiObject_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/IntuiObject.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

extern "C" {
#include <intuition/intuition.h>
#include <utility/tagitem.h>
}
#include <APlusPlus/environment/APPObject.h>
#include <APlusPlus/intuition/Intui_TypeInfo.h>
#include <APlusPlus/exec/List.h>
#include <APlusPlus/utility/AttrList.h>
#include <APlusPlus/environment/MapArray.h>


class ITransponder;
/******************************************************************************************
      « IntuiObject class »    virtual base class

   base class for all graphical user interface classes. This class provides a mechanism
   to trace dependecies between the objects in an Intuition-based user interface.

   All IntuiObjects have one owner that is to be supplied with the constructor call and
   can have a list of dependent IntuiObjects themselves. That makes it easy to track all
   IntuiObjects within one application. So, only the base object has to be deleted to
   cause the deletion of its dependent objects.

   Furthermore, the position of an object within the dependency tree has an effect on
   some IntuiObject-derived objects (e.g. positioning within a window).
   For further details look at the description of the GraphicObject class.

   The implementation builds the dependency tree from MinListC lists: every object
   has its double-linked list of dependent objects.

   IntuiObject derived classes will get their specifications via an Attribute Tag list
   which is defined in the AttrList class.

   IntuiObjects can be declared to get the actual value for an attribute from an actual
   value of one attribute of another IntuiObject. This dependency can be declared by
   usage of setAttributes() or in the constructor's attribute list:

      objA = new GT_Scroller(...,AttrList(...,GTSC_Top,1,...),...);
      objB = new BoopsiGadget(...,AttrList(..,CONSTRAINT(PGA_Top,objA,GTSC_Top),...));

   objA's "GTSC_Top" initialises obj's "PGA_Top"
 ******************************************************************************************/
class IOBrowser;
class IntuiRoot;

class IntuiObject : public MinNodeC, private APPObject, public MinListC
{
   friend class IntuiRoot;
   friend class IOBrowser;
   public:
      virtual ~IntuiObject();                      // remove from the owner's list

      /** Note for the class implementor: YOU MUST CALL setAttributes() with the received taglist
       ** for your class' base class when you have sought information from the attributes.
       ** The attribute tags will be updated and notification will be triggered NOT BEFORE
       ** the taglist propagation arrives at IntuiObject::setAttributes().
       ** Your setAttributes() method MUST NOT alter the taglist IF you want the attribute
       ** values to be applied.
       ** The notification system is capable of inhibiting 'setAttributes()' loops.
       ** Note that the loop is broken not before the setAttributes() call reaches the
       ** IntuiObject base class! To prevent derived classes from getting the recursive
       ** setAttributes() call each class' setAttributes() method must check with
       ** 'BOOL notificationLoop()' and return immediately on TRUE return value.
       **/
      virtual ULONG setAttributes(AttrList& );
      // each IntuiObject may implement class specific action

      virtual ULONG getAttribute(Tag tagValue,ULONG& tagData);
      // accessing the attributes taglist for the class user.

      APTR object() { return iObject; }        // read only public version

      IntuiObject* findOwner() { return (IntuiObject*)findList(); }
      // find the owner of this object

      IntuiObject* findRootOfKind(const Type_info& class_info);
      // Get the first object searching upwards in the IntuiObjects tree
      // that is derived from the class described in 'class_info'
      // Use   class_type_id(T), 
      //       name_type_id(const char* class_name (="T") ),
      //       ptr_type_id(T* T_object)
      //       ref_type_id(T& T_reference))
      // macro 'findRootOfClass(T) return on success a pointer of type 'T'
      // to the found object, otherwise NULL.

      ULONG getIOType() { return ID()&0x0000ffff; }

      APPObject::Ok;       // check for validity
      APPObject::error;
      APPObject::status;

      static IntuiObject *confirm(IntuiObject *iob) { return iob; }

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   protected:
      // The type of the Intuition object addressed in iObject is stored in APPObject

      /** if no owner is given (owner == NULL) the object is attached to the base object.
       ** However, this might cause some classes not to work properly,
       ** (e.g. a gadget must have a window or something similar as its (maybe indirect) owner)
       ** others are most times only dependent of the base object (e.g. the window classes).
       **/
      IntuiObject(IntuiObject* iob,const AttrList& attrs);
      
      void applyDefaultAttrs(const AttrList& userAttrs, const AttrList& defaults);
      // within the constructor each class can define some default Attribute Tags
      // (belonging to the class itself or one of its base classes). The defaults
      // override those of the base classes but are overriden themselves from the
      // class user-specified Attributes (each constructors second argument, 'attrs').

      BOOL notificationLoop() { return setAttributesIsRecurrent; }
      // check within setAttributes() for a notification loop

      void setIOType(LONG type) { setID( ID() | type); }
      // imprint the class id after successful initialisation within the constructor

      APTR& IObject() { return iObject; } // get and fill in the iObject

      AttrList &intuiAttrs() { return attrList; }
      // access to the attribute taglist for the class implementor.

      void setAttrs(AttrList& attrs) { IntuiObject::setAttributes(attrs); }
      // alter attribute values including notification triggering

      APPObject::setError;
      // if the constructor fails an error code ought to be set instead of the class id

   private:
      APTR                  iObject;   // address of the shadowed Intuition object
      ITransponder*    iTransponder;   // notification interconnection
      AttrList             attrList;   // Taglist with create attributes
      BOOL setAttributesIsRecurrent;   // helps determine if there is a loop in the ITransponder dependenies
      MapArray               cTable;   // constraints table
      LONG reserved1;

      void processAttrs(AttrList& attrs);

      LONG newConstraint(Tag onChangedTag,IntuiObject* notifyThis,Tag mapToTag);
      // returns the actual value for the 'mapToTag' attribute of the 'notifyThis' IntuiObject
      void releaseObject(IntuiObject* obj);  // remove all notify dependencies to 'obj'
      void changedAttrs(AttrList& attrs);
};

class IOBrowser
{
   public:
      IOBrowser(IntuiObject* start);
      IntuiObject* getNext(const Type_info& class_info);

   private:
      #define IOBSTACKSIZE 50
      IntuiObject *stack[IOBSTACKSIZE];
      int   sp;

      void push(IntuiObject *iob)
      { if (sp<IOBSTACKSIZE) stack[sp++] = iob; else puterr("IOBrowser: stack overflow\n"); }

      IntuiObject *pop()
      { return sp<=0?NULL:stack[--sp]; }

};



#define OWNER_NULL   ((IntuiObject*)NULL)
#define OWNER_ROOT   OWNER_NULL
   /* Use for attaching IntuiObjects to the root. Note that this is incompatible with
      most GraphicObjects which need a WindowCV object.
   */

#define IOB_Dummy          (TAG_USER|0x10)


#define IOB_CnstSource     (IOB_Dummy+1)
#define IOB_CnstTag        (IOB_Dummy+2)
   /* Some tags for constraint definition. Do not use these but instead use the define below.
   */

#define CONSTRAINT(tag,sourceObj,sourceTag) IOB_CnstSource,IntuiObject::confirm(sourceObj),IOB_CnstTag,sourceTag,tag,0
   /* macro to define an attribute constraint between two IntuiObjects within an attribute tag list.
   */

#define IOB_ITransponder   (IOB_Dummy+3)
   /* Do not use this tag immediately.
   */
#define ITRANSPONDER(itp)  IOB_ITransponder,ITransponder::confirm(itp)
   /* macro to be used within an AttrList to attach an ITransponder
      object to the IntuiObject.
   */


//------------- errors ----------------
#define INTUIOBJECT_CONSTRAINTSOURCE_NO_IOB  (IOB_Dummy+1)


/*
 * Remember: the tag type bits 16-30 are reserved for system tag types!
 *
 * The IntuiObject derived classes (that are all classes which make up the Intuition
 * encapsulation of APlusPlus) are divided into base classes and their subclasses.
 * Base classes have one exclusively reserved bit within bit 5-15 set. That makes it
 * possible to distinguish them and recognize the object they shadow depending on
 * their inheritance relationship.
 * NOTE: At the moment the only class that relies on this runtime type checking is
 * the GWindow class. This type checking mechanism may change in the future.
 */

#define findRootOfClass(T) ((T*)findRootOfKind(class_type_id(T)))
// returns NULL if a root derived from class T could not be found
// otherwise returns a pointer of type 'T' to the found object.

#define IOCLASS(n)            (1L<<(15-n))
#define IOTYPE(m)             ((1L<<5)*(m))

#define GRAPHICOBJECT         (IOCLASS(1))

#define IOTYPE_SCREEN         (GRAPHICOBJECT+IOTYPE(1))

#define IOBASE_WINDOW         (IOCLASS(2)+GRAPHICOBJECT)

/*
 * All known Window class types
 */
#define IOTYPE_WINDOWCV       (IOBASE_WINDOW)
#define IOTYPE_GWINDOW        (IOBASE_WINDOW+IOTYPE(1))


#define IOBASE_GADGET         (IOCLASS(3)+GRAPHICOBJECT)
/*
 * Different types of gadgets
 */
#define IOTYPE_STDGADGET      (IOBASE_GADGET+IOTYPE(1))
#define IOTYPE_BOOPSIGADGET   (IOBASE_GADGET+IOTYPE(2))
#define IOTYPE_GTGADGET       (IOBASE_GADGET+IOTYPE(3))
#define IOTYPE_GROUPGADGET    (IOBASE_GADGET+IOTYPE(4))

#define IOBASE_DRAWAREA       (IOCLASS(4)+GRAPHICOBJECT)

#define IOTYPE_AUTODRAWAREA   (IOBASE_DRAWAREA+IOTYPE(1))
#define IOTYPE_CANVAS         (IOBASE_DRAWAREA+IOTYPE(2))
#define IOTYPE_TEXTVIEW       (IOBASE_DRAWAREA+IOTYPE(3))

//abbreviations for the parameter lists
#define OWNER  IntuiObject *owner
#define ITP    ITransponder *itp

#endif
