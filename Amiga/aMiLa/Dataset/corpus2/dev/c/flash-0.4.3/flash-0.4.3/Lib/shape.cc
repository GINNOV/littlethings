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
//  Author : Olivier Debon  <odebon@club-internet.fr>
//

#include <stdio.h>
#include <stdlib.h>
#include "swf.h"
#include "shape.h"
#include "bitmap.h"
#include "graphic.h"

static char *rcsid = "$Id: shape.cc,v 1.27 1999/01/31 20:22:39 olivier Exp $";

#define PRINT 0

#define ABS(v) ((v) < 0 ? -(v) : (v))

static void bezierBuildPoints (  SPoint * &curPoint,
				 int subdivisions,
				 long a1X, long a1Y,
				 long cX, long cY,
				 long a2X, long a2Y);

static void freeSegments(Segment **segs, long n);

static void addSegment(Segment **segs, long height,
		       FillStyleDef *f0, FillStyleDef *f1,
		       long x1, long y1, long x2,long y2,
		       int aa);

static void renderScanLine(GraphicDevice *gd, long y, Segment *curSegs);

static void renderHitTestLine(GraphicDevice *gd, unsigned char id, long y, Segment *curSegs);

static void prepareStyles(GraphicDevice *gd, Matrix *matrix, Cxform *cxform, FillStyleDef *f, long n);

static void clearStyles(GraphicDevice *gd, FillStyleDef *f, long n);

// Constructor

Shape::Shape(long id, int level) : Character(ShapeType, id)
{
	defLevel = level;

	fillStyles = 0;
	nbFillStyles = 0;

	lineStyles = 0;
	nbLineStyles = 0;

	shapeRecords = 0;

	path = 0;
	nbPath = 0;

	defaultFillStyle.type = f_Solid;
	defaultFillStyle.color.red = 0;
	defaultFillStyle.color.green = 0;
	defaultFillStyle.color.blue = 0;

	defaultLineStyle.width = 0;

	// This is to force a first update
	lastMat.a = 0;
	lastMat.d = 0;
}

Shape::~Shape()
{
	ShapeRecord     *cur,*del;

	delete fillStyles;
	delete lineStyles;

	for(cur = shapeRecords; cur;)
	{
		del = cur;
		delete del->newFillStyles;
		delete del->newLineStyles;
		cur = cur->next;
		delete del;
	}

	if (path) {
		long n;
		SPoint *point,*del;

		for(n=0; n<nbPath; n++) {
			for(point = path[n].path; point; ) {
				del = point;
				point = point->next;
				delete del;
			}
		}
		delete path;
	}
}

void
Shape::setBoundingBox(Rect rect)
{
	boundary = rect;
}

Rect
Shape::getBoundingBox()
{
	return boundary;
}

void
Shape::setFillStyleDefs(FillStyleDef *defs,long n)
{
	fillStyles = defs;
	nbFillStyles = n;
}

void
Shape::setLineStyleDefs(LineStyleDef *defs,long n)
{
	lineStyles = defs;
	nbLineStyles = n;
}

void
Shape::addShapeRecord(ShapeRecord  *sr)
{
	static ShapeRecord *last;
	sr->next = 0;

	if (shapeRecords == 0) {
		shapeRecords = sr;
	} else {
		last->next = sr;
	}
	last = sr;
}

int
Shape::execute(GraphicDevice *gd, Matrix *matrix, Cxform *cxform)
{
	//printf("TagId = %d\n", getTagId()); //if (getTagId() != 11) return 0;

	if (cxform) {
		defaultFillStyle.color = cxform->getColor(gd->getForegroundColor());
	} else {
		defaultFillStyle.color = gd->getForegroundColor();
	}
	defaultFillStyle.color.pixel = gd->allocColor(defaultFillStyle.color);
	doShape(gd, matrix, cxform, ShapeDraw, 0);
	return 0;
}

void
Shape::getRegion(GraphicDevice *gd, Matrix *matrix, unsigned char id)
{
	doShape(gd, matrix,0, ShapeGetRegion, id);
}

static
SPoint *newPath(Path * &path, long &nbPath,
		LineStyleDef *curLineStyle, long curNbLineStyles,
		FillStyleDef *curFillStyle, long curNbFillStyles,
		LineStyleDef *l,
		FillStyleDef *f0,
		FillStyleDef *f1,
		long x, long y
		)
{
	SPoint *point;

	if (path == 0) {
		nbPath = 1;
		path = (Path *)malloc(sizeof(Path));
	} else {
		nbPath++;
		path = (Path *)realloc(path,nbPath*sizeof(Path));
	}

	path[nbPath-1].lineStyles = curLineStyle;
	path[nbPath-1].nbLineStyles = curNbLineStyles;
	path[nbPath-1].fillStyles = curFillStyle;
	path[nbPath-1].nbFillStyles = curNbFillStyles;

	point = new SPoint(x,y,f0,f1,l);

	path[nbPath-1].path = point;

	return point;
}

void
Shape::buildShape()
{
	LineStyleDef *curLineStyle;
	long curNbLineStyles;
	FillStyleDef *curFillStyle;
	long curNbFillStyles;
	LineStyleDef *l;
	FillStyleDef *f0;
	FillStyleDef *f1;
	ShapeRecord *sr;
	SPoint *curPoint;
	long lastX,lastY;

	curLineStyle = lineStyles;
	curNbLineStyles = nbLineStyles;
	curFillStyle = fillStyles;
	curNbFillStyles = nbFillStyles;
	l = 0;
	f0 = 0;
	f1 = 0;
	path = 0;
	nbPath = 0;
	curPoint = 0;
	lastX = 0;
	lastY = 0;

	for(sr = shapeRecords; sr; sr = sr->next)
	{
		switch (sr->type)
		{
			case shapeNonEdge:
				if (sr->flags & flagsNewStyles) {
					curFillStyle = sr->newFillStyles;
					curNbFillStyles = sr->nbNewFillStyles;
					curLineStyle = sr->newLineStyles;
					curNbLineStyles = sr->nbNewLineStyles;
				}
				if (sr->flags & flagsFill0) {
					if (sr->fillStyle0) {
						if (curFillStyle) {
							f0 = &curFillStyle[sr->fillStyle0-1];
						} else {
							f0 = &defaultFillStyle;
						}
					} else {
						f0 = 0;
					}
					if (curPoint) curPoint->f0 = f0;
				}
				if (sr->flags & flagsFill1) {
					if (sr->fillStyle1) {
						if (curFillStyle) {
							f1 = &curFillStyle[sr->fillStyle1-1];
						} else {
							f1 = &defaultFillStyle;
						}
					} else {
						f1 = 0;
					}
					if (curPoint) curPoint->f1 = f1;
				}
				if (sr->flags & flagsLine) {
					if (sr->lineStyle) {
						l = &curLineStyle[sr->lineStyle-1];
					} else {
						l = 0;
					}
					if (curPoint) curPoint->l = l;
				}
				if (sr->flags & flagsMoveTo) {

					curPoint = newPath(path, nbPath, curLineStyle, curNbLineStyles,
							   curFillStyle, curNbFillStyles,
							   l, f0, f1, sr->x, sr->y);

					lastX = sr->x;
					lastY = sr->y;

#if PRINT
					printf("---------\nX,Y    = %4d,%4d\n", sr->x/20, sr->y/20);
#endif
				}
				break;
			case shapeCurve:
				// Handle Bezier Curves !!!
				if (curPoint == 0) {
					curPoint = newPath(path, nbPath, curLineStyle, curNbLineStyles,
							   curFillStyle, curNbFillStyles,
							   l, f0, f1, 0, 0);
				}

				{
					long newX,newY,ctrlX,ctrlY;

					ctrlX = lastX+sr->ctrlX;
					ctrlY = lastY+sr->ctrlY;
					newX = ctrlX+sr->anchorX;
					newY = ctrlY+sr->anchorY;

					bezierBuildPoints(curPoint, 3,
							 lastX<<8,lastY<<8,
							 ctrlX<<8,ctrlY<<8,
							 newX<<8,newY<<8);

					lastX = newX;
					lastY = newY;

					// Add the last anchor
					curPoint->next = new SPoint(lastX, lastY, f0, f1, l);
					curPoint = curPoint->next;
#if PRINT
					printf("aX,aY  = %4d,%4d   %4d,%4d\n", lastX/20, lastY/20, ctrlX/20, ctrlY/20);
#endif
				}
				break;
			case shapeLine:
				if (curPoint == 0) {
					curPoint = newPath(path, nbPath, curLineStyle, curNbLineStyles,
							   curFillStyle, curNbFillStyles,
							   l, f0, f1, 0, 0);
				}

				lastX += sr->dX;
				lastY += sr->dY;

				curPoint->next = new SPoint(lastX, lastY, f0, f1, l);
				curPoint = curPoint->next;
#if PRINT
				printf(" X, Y  = %4d,%4d\n", lastX/20, lastY/20);
#endif
				break;
		}
	}
}

static void
freeSegments(Segment **segs, long n)
{
	long i;

	for(i=0; i < n; i++)
	{
		Segment *seg, *next;

		for(seg = segs[i]; seg; seg = next)
		{
			next = seg->next;
			free(seg);
		}
		segs[i] = 0;
	}
}

static void
addSegment(Segment **segs, long height, FillStyleDef *f0,  FillStyleDef *f1, long x1, long y1, long x2,long y2, int aa)
{
	Segment *seg;
	long Y20;

	seg = (Segment *)malloc(sizeof(struct Segment));
	seg->next = 0;
	seg->nextValid = 0;
	seg->aa = aa;

	if (y1 < y2) {
		seg->ymin = y1;
		seg->ymax = y2;
		seg->x1 = x1;
		seg->x2 = x2;
		seg->fs[0] = f1;
		seg->fs[1] = f0;
	} else {
		seg->ymin = y2;
		seg->ymax = y1;
		seg->x1 = x2;
		seg->x2 = x1;
		seg->fs[0] = f0;
		seg->fs[1] = f1;
	}
	seg->X = seg->x1 << 16;
	seg->dX = ((seg->x2 - seg->x1)<<16)/(seg->ymax-seg->ymin);

	if (seg->ymin >= height*20) {
		free(seg);
		return;
	}

	if (seg->ymin < 0) {
		seg->X += seg->dX * (-seg->ymin);
		seg->ymin = 0;
	}

	Y20 = (seg->ymin + 19)/20*20;
	if (Y20 > seg->ymax) {
		//printf("Elimine @ y = %d   ymin = %d, ymax = %d\n", Y20, seg->ymin, seg->ymax);
		free(seg);
		return;
	}
	seg->X += seg->dX * (Y20-seg->ymin);

	Y20 /= 20;

	if (segs[Y20] == 0) {
		segs[Y20] = seg;
	} else {
		Segment *s,*prev;

		prev = 0;
		for(s = segs[Y20]; s; prev = s, s = s->next) {
			if (s->X > seg->X) {
				if (prev) {
					prev->next = seg;
					seg->next = s;
				} else {
					seg->next = segs[Y20];
					segs[Y20] = seg;
				}
				break;
			}
		}
		if (s == 0) {
			prev->next = seg;
			seg->next = s;
		}
	}
}

static void
printSeg(Segment *seg)
{
	/*
	printf("Seg %08x : X = %5d, Ft = %d, Cl = %2x/%2x/%2x, Cr = %2x/%2x/%2x, x1=%5d, x2=%5d, ymin=%5d, ymax=%5d\n", seg,
		seg->X>>16,
		seg->right ? seg->right->type: -1,
		seg->left ? seg->left->color.red : -1,
		seg->left ? seg->left->color.green : -1,
		seg->left ? seg->left->color.blue : -1,
		seg->right ? seg->right->color.red : -1,
		seg->right ? seg->right->color.green : -1,
		seg->right ? seg->right->color.blue : -1,
		seg->x1, seg->x2, seg->ymin, seg->ymax);
	*/
}

static void
renderScanLine(GraphicDevice *gd, long y, Segment *curSegs)
{
	Segment *seg;
	long width;
	int fi = 1;

	width = gd->getWidth() * 20;

	if (curSegs && curSegs->fs[0] && curSegs->fs[1] == 0) {
		fi = 0;
	}
	for(seg = curSegs; seg && seg->nextValid; seg = seg->nextValid)
	{
		if (seg->nextValid->X <0) continue;
		if ((seg->X>>16) > width) break;
		if (seg->fs[fi]) {
			switch (seg->fs[fi]->type) {
				case f_Solid:
					gd->fillLine(seg->fs[fi]->color.pixel, y, seg->X>>16, seg->nextValid->X>>16, seg->aa);
					break;
				case f_TiledBitmap:
				case f_clippedBitmap:
					gd->fillLine(seg->fs[fi]->pix, seg->fs[fi]->xOffset, seg->fs[fi]->yOffset, y, seg->X>>16, seg->nextValid->X>>16);
					break;
				case f_LinearGradient:
					gd->fillLine(&seg->fs[fi]->gradient, y, seg->X>>16, seg->nextValid->X>>16);
					break;
				case f_RadialGradient:
					gd->fillLineRG(&seg->fs[fi]->gradient, y, seg->X>>16, seg->nextValid->X>>16);
					break;
			}
		}
	}
}

static void
renderHitTestLine(GraphicDevice *gd, unsigned char id, long y, Segment *curSegs)
{
	Segment *seg;

	for(seg = curSegs; seg && seg->nextValid; seg = seg->nextValid)
	{
		if (seg->fs[1]) {
			if (seg->nextValid->X >= seg->X) {
				gd->fillHitTestLine(id, y, seg->X>>16, seg->nextValid->X>>16);
			}
		}
	}
}

void
Shape::drawLines(GraphicDevice *gd, Matrix *matrix, Cxform *cxform, long pStart, long pEnd)
{
	SPoint *point;
	long n;
	long w = 20;
	LineStyleDef *ls;

	// Drawlines
	ls = 0;
	for(n=pStart; n <= pEnd && n < nbPath; n++) {
		for(point = path[n].path; point->next; point = point->next) {
			if (point->l != ls) {
				if (point->l) {
					if (cxform) {
						gd->setForegroundColor(cxform->getColor(point->l->color));
					} else {
						gd->setForegroundColor(point->l->color);
					}
					w = ABS((long)(matrix->a*point->l->width));
				}
				ls = point->l;
			}
			if (ls) {
				gd->drawLine(point->X,point->Y,point->next->X,point->next->Y,w);
			}
		}
	}
	gd->synchronize();
}

static void
prepareStyles(GraphicDevice *gd, Matrix *matrix, Cxform *cxform, FillStyleDef *f, long n)
{
	long fs;

	for(fs = 0; fs < n; fs++)
	{
		switch (f[fs].type)
		{
			case f_Solid:
				if (cxform) {
					f[fs].color.pixel = gd->allocColor(cxform->getColor(f[fs].color));
				} else {
					f[fs].color.pixel = gd->allocColor(f[fs].color);
				}
				break;
			case f_LinearGradient:
			case f_RadialGradient:
				{
					Matrix mat;
					int  n,r,l;
					long red, green, blue;
					long dRed, dGreen, dBlue;
					long min,max;

					mat = *(matrix) * f[fs].matrix;
					// Compute inverted matrix
					f[fs].gradient.imat = mat.invert();
					// Store translation vector
					f[fs].gradient.xOffset = f[fs].gradient.imat.tx;
					f[fs].gradient.yOffset = f[fs].gradient.imat.ty;
					// Reset translation in inverted matrix
					f[fs].gradient.imat.tx = 0;
					f[fs].gradient.imat.ty = 0;
					// Build a 256 color ramp
					f[fs].gradient.ramp = new Color[256];
					// Store min and max
					min = f[fs].gradient.ratio[0];
					max = f[fs].gradient.ratio[f[fs].gradient.nbGradients-1];
					for(r=0; r < f[fs].gradient.nbGradients-1; r++)
					{
						Color start,end;

						l = f[fs].gradient.ratio[r+1]-f[fs].gradient.ratio[r];
						if (l == 0) continue;

						if (cxform) {
							start = cxform->getColor(f[fs].gradient.color[r]);
							end   = cxform->getColor(f[fs].gradient.color[r+1]);
						} else {
							start = f[fs].gradient.color[r];
							end   = f[fs].gradient.color[r+1];
						}

						dRed   = end.red - start.red;
						dGreen = end.green - start.green;
						dBlue  = end.blue - start.blue;

						dRed   = (dRed<<16)/l;
						dGreen = (dGreen<<16)/l;
						dBlue  = (dBlue<<16)/l;

						red   = start.red <<16;
						green = start.green <<16;
						blue  = start.blue <<16;

						for (n=f[fs].gradient.ratio[r]; n<=f[fs].gradient.ratio[r+1]; n++) {
							f[fs].gradient.ramp[n].red = red>>16;
							f[fs].gradient.ramp[n].green = green>>16;
							f[fs].gradient.ramp[n].blue = blue>>16;

							f[fs].gradient.ramp[n].pixel = gd->allocColor(f[fs].gradient.ramp[n]);
							red += dRed;
							green += dGreen;
							blue += dBlue;
						}
					}
					for(n=0; n<min; n++) {
						f[fs].gradient.ramp[n].pixel = f[fs].gradient.ramp[min].pixel;
					}
					for(n=max; n<256; n++) {
						f[fs].gradient.ramp[n].pixel = f[fs].gradient.ramp[max].pixel;
					}
				}
				break;
			case f_TiledBitmap:
			case f_clippedBitmap:
				if (f[fs].bitmap) {
					Matrix mat;
					long xOffset, yOffset;

					mat = *(matrix) * f[fs].matrix;

					xOffset = mat.getX(0,0)/20;
					yOffset = mat.getY(0,0)/20;

					if (f[fs].pix) {
						gd->destroySwfPix(f[fs].pix);
					}
					f[fs].pix = f[fs].bitmap->getImage(gd, &mat, cxform);
					f[fs].xOffset = xOffset;
					f[fs].yOffset = yOffset;
				}
				break;
		}
	}
}

static void
clearStyles(GraphicDevice *gd, FillStyleDef *f, long n)
{
	long fs;

	for(fs = 0; fs < n; fs++)
	{
		switch (f[fs].type)
		{
			case f_Solid:
				break;
			case f_LinearGradient:
			case f_RadialGradient:
				if (f[fs].gradient.ramp) {
					delete f[fs].gradient.ramp;
				}
				break;
			case f_TiledBitmap:
			case f_clippedBitmap:
				if (f[fs].bitmap) {
					if (f[fs].pix) {
						gd->destroySwfPix(f[fs].pix);
						f[fs].pix = 0;
					}
				}
				break;
		}
	}
}

void
Shape::buildSegmentList(Segment **segs, int height, long &n, Matrix *mat, int update, int reverse)
{
	SPoint		*point;
	long		 x1,y1,x2,y2;

	if (update) {
		for(; n < nbPath; n++) {
			int first;
			long lastX,lastY;

			if (path[n].path->next == 0) {
				break;
			}

			first = 1;
			for(point = path[n].path; point->next; point = point->next) {
				if (first) {
					y1 = point->Y = mat->getY(point->x, point->y);
					x1 = point->X = mat->getX(point->x, point->y);
					first = 0;
				} else {
					y1 = lastY;
					x1 = lastX;
				}
				y2 = point->next->Y = mat->getY(point->next->x, point->next->y);
				x2 = point->next->X = mat->getX(point->next->x, point->next->y);
				lastX = x2;
				lastY = y2;
				if (y1 == y2) continue;
				if (!reverse) {
					addSegment(segs,height,point->f0, point->f1, x1,y1,x2,y2, point->l ? 0:1);
				} else {
					addSegment(segs,height,point->f1, point->f0, x1,y1,x2,y2, point->l ? 0:1);
				}
			}
		}
	} else {
		for(; n < nbPath; n++) {
			if (path[n].path->next == 0) {
				break;
			}

			for(point = path[n].path; point->next; point = point->next) {
				y1 = point->Y;
				x1 = point->X;
				y2 = point->next->Y;
				x2 = point->next->X;
				if (y1 == y2) continue;
				if (!reverse) {
					addSegment(segs,height,point->f0, point->f1, x1,y1,x2,y2, point->l ? 0:1);
				} else {
					addSegment(segs,height,point->f1, point->f0, x1,y1,x2,y2, point->l ? 0:1);
				}
			}
		}
	}
}

Segment *
Shape::progressSegments(Segment * curSegs, long y)
{
	Segment *seg,*prev;

	// Update current segments
	seg = curSegs;
	prev = 0;
	while(seg)
	{
		if (y*20 > seg->ymax) {
			// Remove this segment, no more valid
			if (prev) {
				prev->nextValid = seg->nextValid;
			} else {
				curSegs = seg->nextValid;
			}
			seg = seg->nextValid;
		} else {
			seg->X += seg->dX * 20;
			prev = seg;
			seg = seg->nextValid;
		}
	}
	return curSegs;
}

Segment *
Shape::newSegments(Segment *curSegs, Segment *newSegs)
{
	Segment *s,*seg,*prev;

	s = curSegs;
	prev = 0;

	// Check for new segments
	for (seg = newSegs; seg; seg=seg->next)
	{
		// Place it at the correct position according to X
		if (curSegs == 0) {
			curSegs = seg;
			seg->nextValid = 0;
		} else {
			for(; s; prev = s, s = s->nextValid)
			{
				if ( s->X > seg->X
				|| ( (s->X == seg->X)
				     && (
						(seg->x1 == s->x1 && seg->dX < s->dX)
						||
						(seg->x2 == s->x2 && seg->dX > s->dX)
					)
				   )
				) {
					// Insert before s
					if (prev) {
						seg->nextValid = s;
						prev->nextValid = seg;
					} else {
						seg->nextValid = curSegs;
						curSegs = seg;
					}
					break;
				}
			}
			// Append at the end
			if (s == 0) {
				prev->nextValid = seg;
				seg->nextValid = 0;
			}
		}

		s = seg;
	}

	return curSegs;
}

void
Shape::doShape(GraphicDevice *gd, Matrix *matrix, Cxform *cxform, ShapeAction shapeAction, unsigned char id)
{
	long	 n;
	long	 lastPath;
	long	 y;
	long	 height;
	Segment **segs;	// Array of segments
	Segment *curSegs;
	Matrix	 mat;
	int	 update;
	int	 reverse;

	mat = (*gd->adjust) * (*matrix);

	if (mat.a != lastMat.a
	||  mat.d != lastMat.d
	||  mat.b != lastMat.b
	||  mat.c != lastMat.c
	||  mat.tx != lastMat.tx
	||  mat.ty != lastMat.ty) {
		update = 1;
		lastMat = mat;
	} else {
		update = 0;
	}

	height = gd->getHeight();

	n = 0;
	lastPath = 0;
	reverse = (mat.a * mat.d) < 0;

	segs = (Segment **)calloc(height+1, sizeof(Segment *));

	while (n<nbPath) {

		if (shapeAction == ShapeDraw) {
			prepareStyles(gd, &mat, cxform, path[n].fillStyles, path[n].nbFillStyles);
		}

		buildSegmentList(segs, height, n, &mat, update, reverse);

		// Foreach scanline
		curSegs = 0;
		for(y=0; y < height; y++)
		{

			// Make X values progess and remove unuseful segments
			curSegs = progressSegments(curSegs, y);

			// Add the new segment starting at the y position.
			curSegs = newSegments(curSegs, segs[y]);

			// Render the scanline
			if (shapeAction == ShapeDraw) {
				renderScanLine(gd, y, curSegs);
				
				//printf("Id %d  - Y = %d\n", getTagId(), y);
				/*
				if (debug) {
				gd->displayCanvas();
				getchar();
				}
				*/
			} else {
				renderHitTestLine(gd, id, y, curSegs);
			}
		}

		freeSegments(segs,height);

		if (shapeAction == ShapeDraw) {
			drawLines(gd, &mat, cxform, lastPath, n-1);
			clearStyles(gd, path[lastPath].fillStyles, path[lastPath].nbFillStyles);
		}

		lastPath = n;

		n++;
	}
	free(segs);
}

// This is based on Divide and Conquer algorithm.

static void
bezierBuildPoints (  SPoint * &curPoint,
		     int subdivisions,
		     long a1X, long a1Y,
		     long cX, long cY,
		     long a2X, long a2Y)
{
	long c1X,c1Y;
	long c2X,c2Y;
	long X,Y;

	// Control point 1
	c1X = (a1X+cX)/2;
	c1Y = (a1Y+cY)/2;

	// Control point 2
	c2X = (a2X+cX)/2;
	c2Y = (a2Y+cY)/2;

	// New point
	X = (c1X+c2X)/2;
	Y = (c1Y+c2Y)/2;

	if (subdivisions == 1) {
		curPoint->next = new SPoint((X+(1<<7))>>8, (Y+(1<<7))>>8, curPoint->f0, curPoint->f1, curPoint->l);
		curPoint = curPoint->next;
	} else {
		bezierBuildPoints(curPoint, subdivisions-1, a1X, a1Y, c1X, c1Y, X, Y);
		bezierBuildPoints(curPoint, subdivisions-1, X, Y, c2X, c2Y, a2X, a2Y);
	}
}
