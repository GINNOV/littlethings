////////////////////////////////////////////////////////////
// Flash Plugin and Player
// Copyright (C) 1998 Olivier Debon
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
#include <string.h>
#include <assert.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <X11/cursorfont.h>

static char *rcsid = "$Id: graphic.cc,v 1.9 1999/02/14 22:04:22 olivier Exp $";

#include "character.h"
#include "graphic.h"
#include "displaylist.h"

#include "sqrt.h"

#define PRINT 0

static char cmp8[256];	// 8bit colormap

static long
allocColor15(Color color)
{
	return (color.red >> 3)<<10 | (color.green>>3)<<5 | (color.blue>>3);
}

static long
allocColor16_646(Color color)
{
	return (color.red >> 2)<<10 | (color.green>>4)<<6 | (color.blue>>2);
}

static long
allocColor16_565(Color color)
{
	return (color.red >> 3)<<11 | (color.green>>2)<<5 | (color.blue>>3);
}

static long
allocColor24_32(Color color)
{
	return (color.red)<<16 | (color.green)<<8 | color.blue;
}

static long
allocColor8(Color color)
{
	return cmp8[(color.red>>6)<<4 | (color.green>>6)<<2 | (color.blue>>6)];
}

// Try to build a 4x4x4 colormap cube
static void
makeCmp8(Display *dpy, Colormap cmap)
{
	XColor color;
	XColor colors[256];
	long r,g,b;
	int c;

	for(c=0; c < 256; c++) colors[c].pixel = c;
	XQueryColors(dpy,cmap,colors,256);

	for (r=0; r < 4 ; r++) {
		for (g=0; g < 4 ; g++) {
			for (b=0; b < 4 ; b++) {
				color.flags = DoRed|DoGreen|DoBlue;
				color.pad = 0;
				color.red = r<<14;
				color.green = g<<14;
				color.blue = b<<14;
				if (XAllocColor(dpy,cmap,&color)) {
					cmp8[(r<<4)|(g<<2)|b] = color.pixel;
				} else {
					// Look to the first 'matching' color
					for (c = 0; c < 256; c++) {
						if (
							(color.red == (colors[c].red & 0xc000))
							&&
							(color.green == (colors[c].green & 0xc000))
							&&
							(color.blue == (colors[c].blue & 0xc000))
						) {
							cmp8[(r<<4)|(g<<2)|b] = colors[c].pixel;
							break;
						}
					}
					/*
					if (c == 256)
						printf("Can't alloc color %d/%d/%d\n", r,g,b);
					*/
				}
			}
		}
	}
}

// Public

GraphicDevice::GraphicDevice(Display *d, Window w)
{
	XWindowAttributes wattr;
	XPixmapFormatValues *pf;
	Visual *visual;
	int nItems;
	int n;
	struct shmid_ds buf;

	dpy = d;
	target = w;

	// Get Window dimension
	XGetWindowAttributes(dpy, target, &wattr);

	// Get first visual, don't care about others, really !
	visual = wattr.visual;

#if PRINT
	printf("BitmapPad  = %d\n", BitmapPad(dpy));
	printf("BitmapUnit = %d\n", BitmapUnit(dpy));
	printf("Depth      = %d\n", DefaultDepth(dpy,DefaultScreen(dpy)));
	printf("RedMask    = %x\n", visual->red_mask);
	printf("GreenMask  = %x\n", visual->green_mask);
	printf("BlueMask   = %x\n", visual->blue_mask);
	printf("Bits/RGB   = %d\n", visual->bits_per_rgb);
#endif

	redMask = visual->red_mask;
	greenMask = visual->green_mask;
	blueMask = visual->blue_mask;

	// Get screen info

	for(pf=XListPixmapFormats(dpy, &n); n--; pf++) {
		if (pf->depth == DefaultDepth(dpy, DefaultScreen(dpy))) {
			bpp = pf->bits_per_pixel/8;
			pad = pf->scanline_pad/8;
		}
#if PRINT
		printf("----------------\n");
		printf("Depth          = %d\n", pf->depth);
		printf("Bits Per Pixel = %d\n", pf->bits_per_pixel);
		printf("Scanline Pad   = %d\n", pf->scanline_pad);
#endif
	}

	gc = DefaultGC(dpy, DefaultScreen(dpy));

	targetWidth = wattr.width;
	targetHeight = wattr.height;

#if PRINT
	printf("Target Width  = %d\n", targetWidth);
	printf("Target Height = %d\n", targetHeight);
#endif

	zoom = 20;
	movieWidth = targetWidth;
	movieHeight = targetHeight;

	if (bpp) {
		bpl = (targetWidth*bpp + pad-1)/pad*pad;
	} else {
		bpl = (targetWidth/8 + pad-1)/pad*pad;
	}

	switch (bpp) {
		case 1:
			makeCmp8(dpy, wattr.colormap);
			allocColor = allocColor8;
			redMask = 0xe0;
			greenMask = 0x18;
			blueMask = 0x07;
			break;
		case 2:
			if (DefaultDepth(dpy, DefaultScreen(dpy)) == 16) {
				allocColor = allocColor16_565;
			} else
			if (DefaultDepth(dpy, DefaultScreen(dpy)) == 15) {
				allocColor = allocColor15;
			}
			break;
		case 3:
		case 4:
			allocColor = allocColor24_32;
			break;
	}

	XSelectInput(dpy, target, ExposureMask|ButtonReleaseMask|ButtonPressMask|PointerMotionMask);

	// Prepare data for Direct Graphics
	segInfo.readOnly = False;
	segInfo.shmid = shmget (IPC_PRIVATE,targetHeight*bpl,IPC_CREAT|0777);
	if (segInfo.shmid <0) {
		perror("shmget");
		fprintf(stderr,"Size = %d x %d\n", targetWidth, targetHeight);
	}
	segInfo.shmaddr = (char*)shmat (segInfo.shmid, 0, 0);
	if ((long)segInfo.shmaddr == -1) {
		perror("shmat");
	}
	XShmAttach(dpy, &segInfo);
#ifdef linux
	// Warning : this does NOT work properly on Solaris
	// Special Linux shm behaviour is used here
	// When number of attached clients falls down to zero
	// the shm is removed. This is convenient when it crashes.
	if (shmctl(segInfo.shmid, IPC_RMID, &buf) < 0) {
		perror("shmctl");
	}
#endif
	XSync(dpy, False);

	canvasBuffer = (char*)segInfo.shmaddr;

	canvas = XShmCreatePixmap(dpy,target,segInfo.shmaddr,&segInfo,targetWidth,targetHeight,DefaultDepth(dpy, DefaultScreen(dpy)));
	XSync(dpy, False);

	buttonCursor = XCreateFontCursor(dpy, XC_hand2);
	XFlush(dpy);

	handCursorActive = 0;

	hitTest = (unsigned char *)malloc(targetWidth*targetHeight);
	resetHitTest();

	adjust = new Matrix;

	foregroundColor.red = 0;
	foregroundColor.green = 0;
	foregroundColor.blue = 0;

	backgroundColor.red = 0;
	backgroundColor.green = 0;
	backgroundColor.blue = 0;

	showMore = 0;
}

GraphicDevice::~GraphicDevice()
{
	XShmDetach(dpy, &segInfo);
	XSync(dpy,False);
	XFreePixmap(dpy, canvas);
	shmdt(segInfo.shmaddr);

#ifndef linux
	struct shmid_ds buf;
	if (shmctl(segInfo.shmid, IPC_RMID, &buf) < 0) {
		perror("shmctl");
	}
#endif

	free(hitTest);

	if (adjust) {
		delete adjust;
	}
}

///////////// PLATFORM INDEPENDENT
void
GraphicDevice::resetHitTest()
{
	long id;

	for(id=0;id<256; id++)
	{
		hitTestLookUp[id] = 0;
	}
	memset(hitTest,0,targetWidth*targetHeight);
	setHandCursor(0);
}

///////////// PLATFORM INDEPENDENT
void
GraphicDevice::clearHitTest(long tagId)
{
	long id;

	for (id=1; id<256; id++)
	{
		if (tagId == hitTestLookUp[id]) {
			long n;

			hitTestLookUp[id] = 0;

			// Clear every ref to h in hitTest
			for(n=0; n < targetWidth*targetHeight; n++)
			{
				if (hitTest[n] == id) hitTest[n] = 0;
			}
			break;
		}
	}
}

///////////// PLATFORM INDEPENDENT
unsigned char
GraphicDevice::registerHitTest(long tagId)
{
	long id;
	long reg=0;

	for (id=1; id<256; id++)
	{
		// If already registred give up
		if (hitTestLookUp[id] == tagId) return 0;
		// Remember a free id
		if (reg == 0 && hitTestLookUp[id] == 0) reg = id;
	}
	// If id found then register
	if (reg) {
		hitTestLookUp[reg] = tagId;
	}
	return reg;
}

///////////// PLATFORM INDEPENDENT
long
GraphicDevice::checkHitTest(long tagId, long x, long y)
{
	long id;
	
	if (x<0 || x >= targetWidth || y < 0 || y >= targetHeight) return 0;

	for (id=1; id<256; id++)
	{
		if (hitTestLookUp[id] == tagId) {
			if (hitTest[x+y*targetWidth] == id) {
				return 1;
			}
		}
	}
	return 0;
}

///////////// PLATFORM INDEPENDENT
Color *
GraphicDevice::getColormap(Color *old, long n, Cxform *cxform)
{
	Color *newCmp;

	newCmp = new Color[n];

	if (cxform) {
		for(long i = 0; i < n; i++)
		{
			newCmp[i] = cxform->getColor(old[i]);
			newCmp[i].pixel = allocColor(newCmp[i]);
		}
	} else {
		for(long i = 0; i < n; i++)
		{
			newCmp[i].pixel = allocColor(old[i]);
		}
	}

	return newCmp;
}

///////////// PLATFORM INDEPENDENT
SwfPix *
GraphicDevice::createSwfPix(long width, long height)
{
	SwfPix *pix;

	pix = new SwfPix;

	pix->width = width;
	pix->height = height;

	pix->data = (char*)malloc(width*height*bpp);

	pix->bpl = width*bpp;

	return pix;
}

///////////// PLATFORM INDEPENDENT
void
GraphicDevice::destroySwfPix(SwfPix *pix)
{
	free(pix->data);
	delete pix;
}

///////////// PLATFORM INDEPENDENT
long
GraphicDevice::getHeight()
{
	return targetHeight;
}

///////////// PLATFORM INDEPENDENT
long
GraphicDevice::getWidth()
{
	return targetWidth;
}

///////////// PLATFORM INDEPENDENT
Color
GraphicDevice::getForegroundColor()
{
	return foregroundColor;
}

void
GraphicDevice::setForegroundColor(Color color)
{
	foregroundColor = color;
	XSetForeground(dpy,gc,allocColor(color));
}

///////////// PLATFORM INDEPENDENT
Color
GraphicDevice::getBackgroundColor()
{
	return backgroundColor;
}

///////////// PLATFORM INDEPENDENT
void
GraphicDevice::setBackgroundColor(Color color)
{
	backgroundColor = color;
}

///////////// PLATFORM INDEPENDENT
void
GraphicDevice::setMovieDimension(long width, long height)
{
	float xAdjust, yAdjust;

	movieWidth = width;
	movieHeight = height;

	xAdjust = (float)targetWidth*zoom/(float)width;
	yAdjust = (float)targetHeight*zoom/(float)height;

	if (xAdjust < yAdjust) {
		adjust->a = xAdjust;
		adjust->d = xAdjust;
	} else {
		adjust->a = yAdjust;
		adjust->d = yAdjust;
	}
}

///////////// PLATFORM INDEPENDENT
void
GraphicDevice::setMovieZoom(int z)
{
	z *= 20;
	if (z <= 0 || z > 100) return;
	zoom = z;
	setMovieDimension(movieWidth,movieHeight);
	resetHitTest();
}

///////////// PLATFORM INDEPENDENT
void
GraphicDevice::setMovieOffset(long x, long y)
{
	adjust->tx = -zoom*x;
	adjust->ty = -zoom*y;
	resetHitTest();
}

void
GraphicDevice::setHandCursor(int active)
{
	 if (active && !handCursorActive) {
		XDefineCursor(dpy, target, buttonCursor);
		handCursorActive = 1;
	 } 
	 if (!active && handCursorActive) {
		XUndefineCursor(dpy, target);
		handCursorActive = 0;
	 }
}

///////////// PLATFORM INDEPENDENT
void
GraphicDevice::clearCanvas()
{
	unsigned long 	 pixel;
	char 		*line;
	long	 	 h, w;

	pixel = allocColor(backgroundColor);
	line = canvasBuffer;

	if (bpp == 2) {
		short *point;

		for (h=0; h < targetHeight; h++) {
			w = targetWidth;
			for(point = (short*)line; w-- ; point++) {
				*point = (short)pixel;
			}
			line += bpl;
		}
	} else
	if (bpp == 4) {
		long *point;

		for (h=0; h < targetHeight; h++) {
			w = targetWidth;
			for(point = (long*)line; w-- ; point++) {
				*point = (long)pixel;
			}
			line += bpl;
		}
	} else
	if (bpp == 1) {
		char *point;

		for (h=0; h < targetHeight; h++) {
			w = targetWidth;
			for(point = (char*)line; w-- ; point++) {
				*point = (char)pixel;
			}
			line += bpl;
		}
	}
}

void
GraphicDevice::displayCanvas()
{
	XSetFunction(dpy,gc,GXcopy);
	XCopyArea(dpy,canvas,target,gc,0,0,targetWidth,targetHeight,0,0);
	XFlush(dpy);
}

///////////// PLATFORM INDEPENDENT
long
GraphicDevice::clip(long &y, long &start, long &end)
{
	if (y<0) return 1;
	if (y>(targetHeight-1)) return 1;
	if (end < start) {
		long tmp;
		tmp = end;
		end = start;
		start = tmp;
	}
	if (end < 0) return 1;
	if (start < 0) start = 0;
	else
	if (start > (targetWidth-1)*20) return 1;
	if (end > (targetWidth-1)*20) end = (targetWidth-1)*20;
	return 0;
}

// Mix two colors, this is anti-aliasing this is just
// color balancing. Weight is between 0 and 20 (inclusive)
// Closer to 0 means closer to c1, and, closer to 20 means
// closer to c2.

///////////// PLATFORM INDEPENDENT
unsigned long
GraphicDevice::mix(unsigned long c1, unsigned long c2, int weight)
{
	long r1,r2,r;
	long g1,g2,g;
	long b1,b2,b;

	r1 = c1 & redMask;
	r2 = c2 & redMask;
	g1 = c1 & greenMask;
	g2 = c2 & greenMask;
	b1 = c1 & blueMask;
	b2 = c2 & blueMask;

	r = ((r2*weight + r1 * (20-weight))/20) & redMask;
	g = ((g2*weight + g1 * (20-weight))/20) & greenMask;
	b = ((b2*weight + b1 * (20-weight))/20) & blueMask;

	return (r|g|b);
}

#define aaCore(TYPE) { \
		TYPE *line;	\
		TYPE *point;	\
	\
		line = (TYPE *)(canvasBuffer + bpl*y);	\
		point = &line[start/20];	\
		*point = (TYPE)mix(pixel, *point, start%20);	\
	\
		if (start/20 == end/20) return;	\
	\
		point = &line[end/20];	\
		*point = (TYPE)mix(*point, pixel, end%20);	\
}

///////////// PLATFORM INDEPENDENT
void
GraphicDevice::aa(long pixel, long y, long start, long end)
{
	if (bpp == 2) {
		aaCore(unsigned short);
	} else
	if (bpp == 4) {
		aaCore(unsigned long);
	}
}

#define fillLineSolid(TYPE) { 			\
	TYPE *line;				\
	TYPE *point;				\
						\
	line = (TYPE *)(canvasBuffer + bpl*y);	\
	point = &line[start];			\
	n = end-start;				\
	while (n--) {				\
		*point = (TYPE)pixel;		\
		point++;			\
	}					\
}

///////////// PLATFORM INDEPENDENT
void
GraphicDevice::fillLine(long pixel, long y, long start, long end, int doAa)
{
	register long   n;

	if (clip(y,start,end)) return;

	if (doAa) {
		aa(pixel,y,start,end);

		start /= 20;
		end /= 20;

		start++;
		if (end <= start) return;
	} else {
		start /= 20;
		end /= 20;
	}

	if (bpp == 2) {
		fillLineSolid(unsigned short);
	} else
	if (bpp == 4) {
		fillLineSolid(unsigned long);
	} else
	if (bpp == 1) {
		fillLineSolid(unsigned char);
	}
}

///////////// PLATFORM INDEPENDENT
void
GraphicDevice::fillLine(SwfPix *pix, long xOffset, long yOffset, long y, long start, long end)
{
	char *lineDest, *lineSrc;

	if (pix == 0) return;
	if (y-yOffset < 0) return;
	if (y-yOffset >= pix->height) return;
	if (clip(y,start,end)) return;

	start /= 20;
	end /= 20;

	lineDest = canvasBuffer + bpl*y;
	lineDest += start*bpp;

	if (end-start >= pix->width) {
		end = start+pix->width-1;
	}

	lineSrc = pix->data + pix->bpl*(y-yOffset);
	if (start-xOffset < 0) return;
	lineSrc += (start-xOffset)*bpp;

	memcpy(lineDest,lineSrc,bpp*(end-start));
}

#define fillLineLinearGradient(TYPE) { 			\
	TYPE *line;					\
	TYPE *point;					\
							\
	line = (TYPE *)(canvasBuffer + bpl*y);		\
	point = &line[start];				\
							\
	while (n--) {					\
		*point = (TYPE)grad->ramp[r>>16].pixel;	\
		point++;				\
		r += dr;				\
	}						\
}

///////////// PLATFORM INDEPENDENT
void
GraphicDevice::fillLine(Gradient *grad, long y, long start, long end)
{
	long rampStart, rampEnd;
	long dr,r;
	register long   n;

	if (clip(y,start,end)) return;

	start /= 20;
	end /= 20;

	n = end-start;

	rampStart = (grad->imat.getX(start*20-grad->xOffset,y*20-grad->yOffset)+16384)/128;
	rampEnd   = (grad->imat.getX(end*20-grad->xOffset,y*20-grad->yOffset)+16384)/128;

	if (rampStart < 0) {
		rampStart = 0;
	} else
	if (rampStart > 255) {
		rampStart = 255;
	}

	if (rampEnd < 0) {
		rampEnd = 0;
	} else
	if (rampEnd > 255) {
		rampEnd = 255;
	}

	dr = ((rampEnd-rampStart)<<16)/(n+1);
	r = rampStart<<16;

	if (bpp == 2) {
		fillLineLinearGradient(unsigned short);
	} else
	if (bpp == 4) {
		fillLineLinearGradient(unsigned long);
	} else
	if (bpp == 1) {
		fillLineLinearGradient(unsigned char);
	}
}

#define fillLineRadialGradient(TYPE) { 					\
	TYPE *line;							\
	TYPE *point;							\
									\
	line = (TYPE *)(canvasBuffer + bpl*y);				\
	point = &line[start];						\
									\
	while (n--) {							\
		dist2 = ((X>>16)*(X>>16))+((Y>>16)*(Y>>16));		\
		if (dist2 > 65536) {					\
			r = 255;					\
		} else {						\
			r= SQRT[((X>>16)*(X>>16))+((Y>>16)*(Y>>16))];	\
		}							\
		*point = (TYPE)grad->ramp[r].pixel;			\
		point++;						\
		X += dx;						\
		Y += dy;						\
	}								\
}

///////////// PLATFORM INDEPENDENT
void
GraphicDevice::fillLineRG(Gradient *grad, long y, long start, long end)
{
	long rampStartx, rampEndx, rampStarty, rampEndy;
	long X,dx,r,Y,dy;
	long dist2;
	register long   n;

	if (clip(y,start,end)) return;

	start /= 20;
	end /= 20;

	n = end-start;

	rampStartx = (grad->imat.getX(start*20-grad->xOffset,y*20-grad->yOffset))/64;
	rampStarty = (grad->imat.getY(start*20-grad->xOffset,y*20-grad->yOffset))/64;
	rampEndx   = (grad->imat.getX(end*20-grad->xOffset,y*20-grad->yOffset))/64;
	rampEndy   = (grad->imat.getY(end*20-grad->xOffset,y*20-grad->yOffset))/64;

	dx = ((rampEndx-rampStartx)<<16)/(n+1);
	X = rampStartx<<16;
	dy = ((rampEndy-rampStarty)<<16)/(n+1);
	Y = rampStarty<<16;

	if (bpp == 2) {
		fillLineRadialGradient(unsigned short);
	} else
	if (bpp == 4) {
		fillLineRadialGradient(unsigned long);
	} else
	if (bpp == 1) {
		fillLineRadialGradient(unsigned char);
	}
}

///////////// PLATFORM INDEPENDENT
void
GraphicDevice::fillHitTestLine(unsigned char id, long y, long start, long end)
{
	unsigned char *ptr;
	long n;

	if (clip(y,start,end)) return;

	start /= 20;
	end /= 20;

	ptr = &hitTest[y*targetWidth + start];

	n = end-start;
	while (n--) {
		*ptr = id;
		ptr++;
	}
}

void
GraphicDevice::drawLine(long x1, long y1, long x2, long y2, long width)
{
	static long w = -1;

	if (w != width) {
		XSetLineAttributes(dpy, gc, ZOOM(width, 20), LineSolid, CapRound, JoinRound);
		w = width;
	}
	XDrawLine(dpy,canvas,gc,ZOOM(x1,20),ZOOM(y1,20),ZOOM(x2,20),ZOOM(y2,20));
}

void
GraphicDevice::synchronize()
{
	XSync(dpy,False);
}
