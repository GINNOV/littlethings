#ifndef APP_DrawArea_H
#define APP_DrawArea_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/graphics/DrawArea.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


extern "C" {
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>
#include <graphics/clip.h>
#include <graphics/regions.h>
}
#include <APlusPlus/graphics/RectObject.h>


class GWindow;
class FontC;
/******************************************************************************************
      » DrawArea class «     Access to Graphics RastPort and Layer.

   The DrawArea class provides all Graphics draw routines and is attached to one already
   existing GWindow. Furthermore, it enhances rastport drawing with Layers clipping.
   The result is that a DrawArea object is rather a clipped draw area within a specified
   rastport than that rastport itself.
   There may be several DrawArea objects created to one single existing RastPort.
   The ClipRegion gets it dimension for the clipping area from the incorporated RectObject.
   Additional clipping can be achieved with the ClipRegion methods: modify the inherited
   ClipRegion and then call setStdClip() to activate your special clipping.
 ******************************************************************************************/

class DrawArea : virtual public RectObject
{
   public:
      DrawArea(GWindow* homeWindow=NULL);
      /** Sometimes the GWindow is not available when the DrawArea object has to be initialised.
       ** Therefore setGWindow(GWindow*) may be used. Note that you MUST supply a GWindow before
       ** using any of the draw methods below.
       **/
      virtual ~DrawArea();

      struct RastPort*  rp() { return rastPort; }
      struct Layer*     layer() { return rp()->Layer; }
      struct Region*    region() { return regionPtr; }

      void adjustStdClip();   // adjust the clipping to the present values of the RectObject
      void setStdClip();      // installs standard clipping on the boundaries of the RectObject
      void resetStdClip();    // reinstall previous clip region

      #define RECTANGLE  XYVAL MinX,XYVAL MinY,XYVAL MaxX,XYVAL MaxY
      // use the following methods to create your own clipping areas
      void andRectRegion(RECTANGLE);
      void orRectRegion(RECTANGLE);
      void xorRectRegion(RECTANGLE);
      void clearRectRegion(RECTANGLE);

      void clearRegion();

      // drawmode and colors
      void setAPen(UBYTE);    // foreground pen
      void setBPen(UBYTE);    // background pen
      void setOPen(BYTE pen) { SetOPen(rp(),pen); }  // area outline pen
      void setDrMd(UBYTE);    // set drawmode
      void setDrPt(UWORD p) { SetDrPt(rp(),p); }

      /** draw routines according to the graphics library, coords become relative to the
       ** RectObject's upper, left edge.
       **/
      void draw(XYVAL x,XYVAL y);
      // draw a GadTools bevel box
      void drawBevelBox(XYVAL xmin,XYVAL ymin,WHVAL width,WHVAL height,BOOL recessed);
      void drawEllipse(XYVAL x,XYVAL y,WHVAL hr,WHVAL vr);

      void move(XYVAL x,XYVAL y);
      void moveTx(XYVAL x,XYVAL y);
      // places graphic cursor to upper left edge of text render box for subsequent text() calls.
      // considers baseline of the current font set with setFont()

      // give a table of RectObject-relative coordinates
      void polyDraw(LONG count,WORD* polyTable);

      void rectFill(XYVAL xmin,XYVAL ymin,XYVAL xmax,XYVAL ymax);
      void scrollRaster(LONG dx,LONG dy,XYVAL xmin,XYVAL ymin,XYVAL xmax,XYVAL ymax);

      // set the font to use in subsequent text() calls
      void setFont(FontC& font);
      // if you leave out textLength the string will be measured by the method.
      void text(UBYTE* textString,UWORD textLength=0);

   protected:
      void setGWindow(GWindow* homeWindow);

      void setRectangle(RECTANGLE,struct Rectangle& rect);
      BOOL isValid() { return (regionPtr!=NULL && gWindowPtr!=NULL); }
      GWindow* gwindow() { return gWindowPtr; }

   private:
      GWindow* gWindowPtr;
      struct RastPort* rastPort;
      struct Region* regionPtr;
      struct Region* oldRegion;
      BOOL ownClippingInstalled;

      void removeClip();
      void insertClip();
};

// compute RectObject relative coords into rastport absolute coords.
#define abs_X(x) (iLeft()+(x))
#define abs_Y(y) (iTop()+(y))

#endif
