/////////////////////////////////////////////////////////////
// Flash Plugin and Player
// Copyright (C) 1998,1999 Olivier Debon
// 
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
// 
///////////////////////////////////////////////////////////////
#ifndef _SHAPE_H_
#define _SHAPE_H_

#include "character.h"
#include "bitmap.h"
#ifdef DUMP
#include "bitstream.h"
#endif

enum FillType {
	f_Solid          = 0x00,
	f_LinearGradient = 0x10,
	f_RadialGradient = 0x12,
	f_TiledBitmap    = 0x40,
	f_clippedBitmap  = 0x41
};

struct FillStyleDef {
	FillType	 type;	// See enum FillType

	// Solid
	Color		 color;

	// Gradient
	Gradient	 gradient;

	// Bitmap
	Bitmap		*bitmap;
	SwfPix		*pix;
	long		 xOffset,yOffset;

	// Gradient or Bitmap
	Matrix		 matrix;
};

struct LineStyleDef {
	long		 width;
	Color		 color;
};

enum ShapeRecordType {
	shapeNonEdge,
	shapeCurve,
	shapeLine
};

enum ShapeFlags {
	flagsMoveTo	   = 0x01,
	flagsFill0	   = 0x02,
	flagsFill1	   = 0x04,
	flagsLine	   = 0x08,
	flagsNewStyles	   = 0x10,
	flagsEndShape 	   = 0x80
};

struct ShapeRecord {
	ShapeRecordType  type;

	// Non Edge
	ShapeFlags	 flags;
	long		 x,y;	// Moveto
	long		 fillStyle0;
	long		 fillStyle1;
	long		 lineStyle;
	FillStyleDef	*newFillStyles; // Array
	long		 nbNewFillStyles;
	LineStyleDef	*newLineStyles; // Array
	long		 nbNewLineStyles;

	// Curve Edge
	long		 ctrlX, ctrlY;
	long		 anchorX, anchorY;

	// Straight Line
	long		 dX,dY;

	struct ShapeRecord *next;
};

enum ShapeAction {
	ShapeDraw,
	ShapeGetRegion
};

struct SPoint {
	long		 x,y;
	long		 X,Y;
	FillStyleDef	*f0;
	FillStyleDef	*f1;
	LineStyleDef	*l;
	int		 curve;

	struct SPoint 	*next;

	SPoint(long x, long y, FillStyleDef *f0, FillStyleDef *f1, LineStyleDef *l)	//Constructor
	{
		this->x = x;
		this->y = y;
		this->f0 = f0;
		this->f1 = f1;
		this->l = l;
		curve = 0;
		next = 0;
	};
};

struct Segment {
	long		 ymin, x1;
	long		 ymax, x2;
	FillStyleDef	*fs[2];	// 0 is left 1 is right
	int		 aa;
	long		 dX;
	long		 X;

	struct Segment *next;
	struct Segment *nextValid;
};

struct Path {
	SPoint		*path;
	FillStyleDef	*fillStyles;	// Array
	long		 nbFillStyles;
	LineStyleDef	*lineStyles;	// Array
	long		 nbLineStyles;
};

class Shape : public Character {
	int		 defLevel; // 1,2 or 3
	FillStyleDef	*fillStyles;	// Array
	long		 nbFillStyles;
	LineStyleDef	*lineStyles;	// Array
	long		 nbLineStyles;
	ShapeRecord	*shapeRecords;
	Rect		 boundary;
	Path		*path;
	long		 nbPath;
	FillStyleDef	 defaultFillStyle;
	LineStyleDef	 defaultLineStyle;

	Matrix		 lastMat;

protected:
	void	 drawLines(GraphicDevice *gd, Matrix *matrix, Cxform *cxform, long, long);
	void	 buildSegmentList(Segment **segs, int height, long &n, Matrix *matrix, int update, int reverse);
	Segment *progressSegments(Segment *, long);
	Segment *newSegments(Segment *, Segment *);

public:
	Shape(long id = 0 , int level = 1);
	~Shape();

	void	 setBoundingBox(Rect rect);
	void	 setFillStyleDefs(FillStyleDef *defs,long n);
	void	 setLineStyleDefs(LineStyleDef *defs,long n);
	void	 addShapeRecord(ShapeRecord  *sr);
	int	 execute(GraphicDevice *gd, Matrix *matrix, Cxform *cxform);
	void	 getRegion(GraphicDevice *gd, Matrix *matrix, unsigned char id);
	void	 doShape(GraphicDevice *gd, Matrix *matrix, Cxform *cxform, ShapeAction shapeAction, unsigned char id);
	void	 buildShape();
	Rect	 getBoundingBox();

#ifdef DUMP
	void	 dump(BitStream *bs);
	void	 dumpShapeRecords(BitStream *bs, int alpha);
	void	 dumpFillStyles(BitStream *bs, FillStyleDef *defs, long n, int alpha);
	void	 dumpLineStyles(BitStream *bs, LineStyleDef *defs, long n, int alpha);
	void	 checkBitmaps(BitStream *bs);
#endif
};

#endif /* _SHAPE_H_ */
