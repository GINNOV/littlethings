#ifndef APP_GraphicObject_H
#define APP_GraphicObject_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/graphics/GraphicObject.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

extern "C" {
#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
}
#include <APlusPlus/intuition/IntuiObject.h>
#include <APlusPlus/graphics/RectObject.h>


#define GOB_OWNER GraphicObject *gob_owner

class GWindow;
/******************************************************************************************
      » GraphicObject class «    virtual base class

   This class enhances the IntuiObject class to handle all objects within a GUI that have
   any kind of graphical dimensions (Windows, Gadgets etc.).
   GraphicObjects can incorporate other GraphicObjects which have a common GraphicObject
   as owner. These depending GraphicObjects are placed within their owner relative
   to the owners dimensions.
   A GraphicObject itself can be used to group several GraphicObject-derived objects.

 ******************************************************************************************/
class GraphicObject : public IntuiObject, virtual public RectObject
{
   public:
      virtual APTR redrawSelf(GWindow* home,ULONG& returnType);
         /** redrawSelf() is called each time the home window has changed size.
          ** To have the GraphicObjects redraw themselves after they have been
          ** adjusted to the new size (i.e. left(),top(),width() and height() are already set.)
          ** GadgetCV derived classes have to return their incorporated gadget
          ** structure/list to have it attached to the window.
          **/

      ULONG setAttributes(AttrList& attrs);
      ULONG getAttribute(Tag,ULONG&);

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }
  
      virtual void adjustChilds();  // adjust dimensions of the child GraphicObjects

   protected:
      GraphicObject(GOB_OWNER,AttrList& attrs);
      ~GraphicObject();
};


#define GOB_Spec_Dummy    (TAG_USER | GRAPHICOBJECT)

#define gob_edge     8
#define gob_reledge  4
#define gob_orient   2
#define gob_relative 1
#define gob_spec(edge,reledge,orient,relative) (gob_edge*edge+gob_reledge*reledge+gob_orient*orient+gob_relative*relative)

#define GOB_LeftFromLeftOfParent       (GOB_Spec_Dummy + gob_spec(0,0,0,0))
#define GOB_RightFromLeftOfParent      (GOB_Spec_Dummy + gob_spec(1,0,0,0))
#define GOB_TopFromTopOfParent         (GOB_Spec_Dummy + gob_spec(0,0,1,0))
#define GOB_BottomFromTopOfParent      (GOB_Spec_Dummy + gob_spec(1,0,1,0))

#define GOB_LeftFromRightOfParent      (GOB_Spec_Dummy + gob_spec(0,1,0,0))
#define GOB_RightFromRightOfParent     (GOB_Spec_Dummy + gob_spec(1,1,0,0))
#define GOB_TopFromBottomOfParent      (GOB_Spec_Dummy + gob_spec(0,1,1,0))
#define GOB_BottomFromBottomOfParent   (GOB_Spec_Dummy + gob_spec(1,1,1,0))

#define GOB_LeftFromLeftOfPred         (GOB_Spec_Dummy + gob_spec(0,0,0,1))
#define GOB_RightFromLeftOfPred        (GOB_Spec_Dummy + gob_spec(1,0,0,1))
#define GOB_TopFromTopOfPred           (GOB_Spec_Dummy + gob_spec(0,0,1,1))
#define GOB_BottomFromTopOfPred        (GOB_Spec_Dummy + gob_spec(1,0,1,1))

#define GOB_LeftFromRightOfPred        (GOB_Spec_Dummy + gob_spec(0,1,0,1))
#define GOB_RightFromRightOfPred       (GOB_Spec_Dummy + gob_spec(1,1,0,1))
#define GOB_TopFromBottomOfPred        (GOB_Spec_Dummy + gob_spec(0,1,1,1))
#define GOB_BottomFromBottomOfPred     (GOB_Spec_Dummy + gob_spec(1,1,1,1))

#define GOB_Dummy  (GOB_Spec_Dummy + 16)

#define GOB_Left        GOB_LeftFromLeftOfParent
#define GOB_Top         GOB_TopFromTopOfParent
#define GOB_Right       GOB_RightFromLeftOfParent
#define GOB_Bottom      GOB_BottomFromTopOfParent

#define GOB_Width       (GOB_Dummy + 1)
#define GOB_Height      (GOB_Dummy + 2)
/** GOB_Width and GOB_Height tags can be used to define a GraphicObject
 ** having constant dimensions. When using one of these tags only one
 ** additional edge needs to be specified while the opposite edge is
 ** placed in the given distance (width or height) to the one specified.
 **/

#define BDR_Dummy       (GOB_Dummy + 64)

//#define GOB_Percent(frac)  ( ( ((ULONG)0xffff)*frac ) )
/** GOB_Percent computes a fraction that relates the dimension of a GraphicObject to
 ** the same dimension of the owner. Proportional dimensions can be used with all GOB_ tags.
 ** They are recognized by their sign: negative values are considered percentual values while
 ** positive values are taken as absolute distances in pixel.
 ** For instance, set a gadget a third of the windows width and 2/3 of this width
 ** from the left egde:
 **
 **   GraphicObject(window, GOB_Left,GOB_Percent(2/3),GOB_Width,GOB_Percent(1/3)
 **
 ** Make sure that the denominator (here '2' of '2/3') is smaller than 65535 to prevent an
 ** integer overflow!
 **/

// Percent & Absolute do not work at the moment!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#define GOB_Absolute(related,value) ((XYVAL)value)
/*( ((LONG)(value)) > 0xffff ?          \
         ( ( ((ULONG)(related)) * ( ((LONG)(value))-0xffff ) ) / 0x0000ffff)  :  value )
*/
/** GOB_Absolute gives the absolute value of a GOB_Percent tag data.
 ** It determines if the value given is meant to be absolute or percentual. For percentual
 ** values, which have to be defined with GOB_Percent(), it computes the fraction of the related
 ** length and returns an absolute value.
 **/

#define GOB_Border      (GOB_Dummy + 3)
#define GOB_BorderObj(borderobj) GOB_Border,GBorder::confirm(borderobj)
   /* GOB_Border allows the class user to specify a Border object that draws some kind
    * of border around the GraphicObject. Use the GOB_BorderObj(Border* borderkind) macro
    * rather than the GOB_Border tag since the first assures type checking.
    */

#endif   /* GraphicObject.h */
