#ifndef APP_Canvas_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/graphics/Canvas.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include <APlusPlus/graphics/AutoDrawArea.h>


/******************************************************************************************
      » Canvas class «  virtual base class

   The Canvas class expands the AutoDrawArea class to a virtual draw space that can easily
   be bigger than the dimensions of the AutoDrawArea. The AutoDrawArea acts as a view hole
   through which only a portion of the whole draw space is visible. This view can be moved
   over the draw space.
   All drawing goes into the virtual draw space and is clipped properly.
   The canvas is divided into GranularityX/Y units counting from 0 to CNV_Width/Height-1.

 ******************************************************************************************/
class Canvas : public AutoDrawArea
{
   public:
      Canvas(GOB_OWNER,AttrList& attrs);
      ~Canvas();

      void callback(const IntuiMessageC* imsg);
      /** overwrite with your own IDCMP event handler.
       ** Call Canvas::calback(msg) somewhere in your callback method.
       **/

      virtual void drawSelf()=0;
      /** overwrite here to make your own drawing
       ** The area which has to be redrawn is described by the view/visibleXY() values and should
       ** be regarded for efficiency reason. Although it is allowed to draw anywhere within the
       ** canvas since all drawing is clipped.
       **/

      ULONG setAttributes(AttrList& attrs);        // inherited from IntuiObject
      ULONG getAttribute(Tag tag,ULONG& dataStore);

      /** draw routines according to the graphics library; coords become relative to the
       ** Canvas draw space upper, left edge.
       **/
      void draw(XYVAL x,XYVAL y) { AutoDrawArea::draw(cx2ax(x),cy2ay(y)); }
      void drawEllipse(XYVAL x,XYVAL y,WHVAL hr,WHVAL vr)
      { AutoDrawArea::drawEllipse(cx2ax(x),cy2ay(y),hr,vr); }

      void move(XYVAL x,XYVAL y) { AutoDrawArea::move(cx2ax(x),cy2ay(y)); }
      void moveTx(XYVAL x,XYVAL y) { AutoDrawArea::moveTx(cx2ax(x),cy2ay(y)); }

      void rectFill(XYVAL xmin,XYVAL ymin,XYVAL xmax,XYVAL ymax)
      { AutoDrawArea::rectFill(cx2ax(xmin),cy2ay(ymin),cx2ax(xmax),cy2ay(ymax)); }

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   protected:
      APTR redrawSelf(GWindow *home,ULONG& returnType);   // inherited from GraphicObject

      XYVAL cx2ax(XYVAL x) { return x-xOffset; }   // convert canvas x coords to DrawArea x coords.
      XYVAL cy2ay(XYVAL y) { return y-yOffset; }   // convert canvas y coords to DrawArea y coords.

      UWORD granularityX() { return iGranularityX; }  // pixel per Granularity unit
      UWORD granularityY() { return iGranularityY; }
      UWORD viewX() { return iViewX; }    // offset of the view in Granularity units (0-..)
      UWORD viewY() { return iViewY; }
      UWORD visibleX() { return iVisibleX; }    // view extension in Granularity units
      UWORD visibleY() { return iVisibleY; }
      UWORD mouseX() { return iMouseX; }        // mouse position on the canvas in Granularity units
      UWORD mouseY() { return iMouseY; }

      BOOL scrollGratX() { return scrollGratingX; }
      BOOL scrollGratY() { return scrollGratingY; }

   private:
      XYVAL xOffset,yOffset;     // coords of the upper left corner of the visible canvas.
      UWORD heightG,widthG;      // width,height of the canvas in GranularityX/Y units
      UWORD iGranularityX,iGranularityY;  // multiply CNV_ViewX/Y value with granularity to get offset
      UWORD iViewX,iViewY;       // internal storage for CNV_ViewX/Y
      UWORD iVisibleX,iVisibleY; // view dimensions in Granularity units
      UWORD iMouseX,iMouseY;        // mouse position on the virtual canvas
      UBYTE scrollGratingX,scrollGratingY;

};

#define CNV_Dummy    (TAG_USER| (IOTYPE_CANVAS + 1))

#define CNV_ViewX    (CNV_Dummy + 1)
   /* (UWORD). Set the canvas pixel position of the left edge of the view in GranularityX steps.
      The minimum value is 0. The maximum value is the width of the draw space -1.
   */

#define CNV_ViewY    (CNV_Dummy + 2)
   /* (UWORD). Set the canvas pixel position of the top edge of the view in GranularityY steps.
      The minimum value is 0. The maximum value is the height of the draw space -1.
   */

#define CNV_GranularityX        (CNV_Dummy + 3)
   /* (UWORD). Specify granularity of the ViewX value. Default is 1 pixel.
   */

#define CNV_GranularityY        (CNV_Dummy + 4)
   /* (UWORD). Specify granularity of the ViewY value. Default is 1 pixel.
   */

#define CNV_Width    (CNV_Dummy + 5)
   /* (UWORD). Specify the width of the canvas in GranularityX units.
   */

#define CNV_Height   (CNV_Dummy + 6)
   /* (UWORD). Specify the height of the canvas in GranularityY units.
   */

#define CNV_VisibleX    (CNV_Dummy + 7)
#define CNV_VisibleY    (CNV_Dummy + 8)
   /* (UWORD). The CNV_Visible tags are READ ONLY. They represent the dimension of the
      canvas view in CNV_GranularityX/Y units. They can directly be transposed to get
      PGA_Visible tag data for a connected Proportional gadget or Slider.
   */

#define CNV_ScrollGratX    (CNV_Dummy + 9)
#define CNV_ScrollGratY    (CNV_Dummy + 10)
   /* (BOOL). The view can be scrolled in multiples of CNV_Granularity values only.
      This tag defines wether the right/bottom border that is left over when dividing
      the view into granularity units shall be included when scrolling (FALSE) or
      excluded (TRUE). The default is FALSE.
   */

#endif   /* Canvas.h */
