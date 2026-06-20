#ifndef APP_RectObject_H
#define APP_RectObject_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/graphics/RectObject.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include <exec/types.h>


/******************************************************************************
      » RectObject class «

   Simply a storage for a rectangular object's dimensions.
   The rectangle is specified through the upper left and lower right edge
   of the rect. The left and upper coordinate is NEVER greater than the right
   and lower coordinate, although coordinates may be NEGATIVE!

   Setting additional border values establishes inner dimensions that are
   diminished by the respective border wide. If the outer box becomes too
   small to hold the borders, borders are set to zero until the box is
   expanded again with a setRect() method.

   RectObject class SHOULD ALWAYS BE INHERITED VIRTUALLY to make sure that
   complex classes that indirectly inherit several RectObjects work on the
   same dimensions.

 *******************************************************************************/
typedef LONG XYVAL;  // for graphics x/y coordinates (may be negative)
typedef UWORD WHVAL;  // for graphics width/height values (can never be negative)

class GBorder;
class RectObject
{
   friend class GBorder;
   public:
      // The public user has read access only to the dimensions,

      // read outer dimensions (maximum for inner dimensions)
      XYVAL left() { return MinX; }
      XYVAL right() { return MaxX; }
      XYVAL top() { return MinY; }
      XYVAL bottom() { return MaxY; }
      WHVAL width() { if (right()>left()) return right()-left()+1; else return 0;}
      WHVAL height() { if (bottom()>top()) return bottom()-top()+1; else return 0;}

      // read inner dimensions (diminished by borders)
      // NOTE: The inner dimensions can become the outer dimensions although
      // the borders are non-zero when the box becomes too small for borders!!
      XYVAL iLeft();
      XYVAL iTop();
      XYVAL iRight();
      XYVAL iBottom();
      WHVAL iWidth();
      WHVAL iHeight();

      // read border dimensions (do not calculate the inner box from the
      // outer box + border dimensions! Instead use iTop(),iLeft() etc.!
      WHVAL leftB() { return leftBorder; }
      WHVAL topB() { return topBorder; }
      WHVAL rightB() { return rightBorder; }
      WHVAL bottomB() { return bottomBorder; }

      // fill in graphic dimensions
      void setRect(XYVAL minx,XYVAL miny,XYVAL maxx,XYVAL maxy);

      // use left upper corner and width/height
      void setRectWH(XYVAL minx,XYVAL miny,WHVAL widthX,WHVAL heightY)
      { setRect(minx,miny,minx+widthX-1,miny+heightY-1); }

      // NOTE: new borders dimensions demand a new 'adjustChilds()' run
      // for 'this' GraphicObject!
      void setBorders(UBYTE lb,UBYTE tb,UBYTE rb,UBYTE bb); //INLINE FUNCTION

   protected:
      RectObject();
      RectObject(XYVAL minx,XYVAL miny,XYVAL maxx,XYVAL maxy);
      virtual ~RectObject();

   private:
      XYVAL    MinX,MinY,MaxX,MaxY;
      UBYTE    leftBorder,topBorder,rightBorder,bottomBorder;
};


void inline RectObject::setBorders(UBYTE lb,UBYTE tb,UBYTE rb,UBYTE bb)
{
   leftBorder = lb;
   topBorder = tb;
   rightBorder = rb;
   bottomBorder = bb;
};

#endif   /* RectObject.h */
