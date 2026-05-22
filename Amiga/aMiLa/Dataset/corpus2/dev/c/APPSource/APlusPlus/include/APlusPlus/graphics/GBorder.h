#ifndef APP_GBorder_H
#define APP_GBorder_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/graphics/GBorder.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

#include <exec/types.h>
#include <APlusPlus/graphics/FontC.h>


/******************************************************************************************
      » GBorder class «    virtual base class

   The GBorder class enhances GraphicObjects with border drawings at the edges of the
   RectObject box in a resource efficient and compatible way. The GraphicObject already
   considers borders. The GBorder has to tell how wide the left and right and how high
   the top and bottom border is. The GraphicObject reserves that place and the GBorder
   has to make its drawings when being called.

 ******************************************************************************************/
class GraphicObject;
class GWindow;

class GBorder
{
   public:
      virtual ~GBorder();

      virtual void makeBorder(GraphicObject *graphicObj)=0;
      /** Fill in border dimensions into the given GraphicObject.
       ** Use RectObject::setBorders(leftBorder,topBorder,rightBorder,bottomBorder)
       **/
      virtual void drawBorder(GraphicObject *graphicObj,GWindow *homeWindow);
      /** is being called when borders have to be redrawed. Use the RectObject dimensions and
       ** the GWindow rastport (and visualInfo).
       ** Make sure not to draw outside the border area!
       ** Always call GBorder::drawBorder() (respectively the direct base class' drawBorder())
       ** first before drawing anything yourself.
       **/

      // allow type checking for tag data values
      static GBorder* confirm(GBorder* obj)
         { return obj; }

};

/******************************************************************************
    A Border drawn with DrawBevelBox(). Each object can become a recessed or
    raised bevel border (to resemble a pushed or released buttons).

 ******************************************************************************/
class BevelBox : public GBorder
{
   public:
      BevelBox();
      virtual void makeBorder(GraphicObject* graphicObj);
      virtual void drawBorder(GraphicObject* graphicObj,GWindow* homeWindow);
};

class LineBorder : public GBorder
{
   public:
      virtual void makeBorder(GraphicObject* graphicObj);
      virtual void drawBorder(GraphicObject* graphicObj,GWindow* homeWindow);
};

/******************************************************************************
    A border with a 3D 'ditch' around the object and an optional title.
    The title can be specified individually to each GraphicObject in the
    GraphicObject Attribute Taglist. But the font can only be set for one
    Border object on the Border constructor taglist.
 ******************************************************************************/
class NeXTBorder : public GBorder
{
   public:
      NeXTBorder(UBYTE* titleFontName = NULL,UBYTE titleFontSize = 0);
      // if titleFontName is NULL a default font is choosen. Look at FontC class for details.

      virtual void makeBorder(GraphicObject* graphicObj);
      virtual void drawBorder(GraphicObject* graphicObj,GWindow* homeWindow);

   private:
      FontC titleFont;
};

#define NORM_X(x) ((x)-homeWindow->iLeft())
#define NORM_Y(y) ((y)-homeWindow->iTop())
/* Since the border is drawn from the GraphicObject coordinates, which are relative
   to the window rastport, and since the border draws into a DrawArea, that is the
   window's DrawArea which has its 0,0 point under/besides the window border, the
   rastport coordinates need to be transformed to DrawArea coordinates.
*/


/* The following Attribute Tags specify certain properties of the
   GBorder classes. They are to be added to the framed object's
   Attribute Taglist.
*/

#define GOB_BorderTitle    (BDR_Dummy + 1)
#define BDR_BorderTitle    GOB_BorderTitle
   /* (UBYTE*). Some GBorder classes allow to title a framed object.
      The title tag is placed in the Attribute Taglist of the GraphicObject that
      is to be framed.
   */

#define GOB_BackgroundColor   (BDR_Dummy + 2)
   /* (ULONG). Fill the GraphicObject rectangle (including border areas) with this color
      before drawing borders.
   */

#define GOB_BevelRecessed     (BDR_Dummy + 3)
   /* (BOOL). Set to TRUE to get a recessed looking border (only with BevelBox class).
   */
#endif
