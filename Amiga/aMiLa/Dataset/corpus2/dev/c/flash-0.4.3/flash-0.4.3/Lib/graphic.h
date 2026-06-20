/////////////////////////////////////////////////////////////
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
#ifndef _DISPLAY_H_
#define _DISPLAY_H_

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/extensions/XShm.h>

#include "swf.h"

struct SwfPix {
	char *data;
	long bpl;
	long width,height;
};

enum FlashEventType {
	FeNone,
	FeMouseMove,
	FeButtonPress,
	FeButtonRelease,
	FeRefresh
};

struct FlashEvent {
	FlashEventType	 type;
	int		 x,y;		// Mouse coordinates, relative to upper-left window corner
};

class GraphicDevice {
	// Platform dependent members
	Window			 target;	// Target window
	Cursor		 	 buttonCursor;	// Window cursor (a hand if over a button)
	Display			*dpy;		// X11 Display
	GC		 	 gc;		// X11 Graphic context
	Pixmap			 canvas;	// Graphic buffer
	XShmSegmentInfo		 segInfo;	// Shared memory information

	Color			 backgroundColor;
	Color			 foregroundColor;
	long		 	 handCursorActive;
	int			 targetWidth;
	int 			 targetHeight;
	int			 movieWidth;
	int			 movieHeight;
	int			 zoom;
	unsigned char		*hitTest;
	long			 hitTestLookUp[256];
	unsigned long		 redMask;
	unsigned long		 greenMask;
	unsigned long		 blueMask;

public:
	long			 showMore;	// Used for debugging

protected:
	long	 clip(long &y, long &start, long &end);
	void	 aa(long pixel, long y, long start, long end);
	unsigned long mix(unsigned long c1, unsigned long c2, int weight);

public:
	Matrix			*adjust;	// Matrix to fit window (shrink or expand)

	// For Direct Graphics
	char 			*canvasBuffer;	// A pointer to canvas'memory
	long			 bpl;	// Bytes per line
	long			 bpp;	// Bytes per pixel
	long			 pad;	// Scanline pad in byte

	GraphicDevice(Display *d, Window w);	// Platform dependent
	~GraphicDevice();

	void	 setBackgroundColor(Color);
	void	 setForegroundColor(Color);
	Color	 getBackgroundColor();
	Color	 getForegroundColor();
	void	 setMovieDimension(long width, long height);
	void	 setMovieZoom(int zoom);
	void	 setMovieOffset(long x, long y);
	void	 displayCanvas();
	void	 clearCanvas();
	long	 getWidth();
	long	 getHeight();
	SwfPix 	*createSwfPix(long width, long height);
	void	 destroySwfPix(SwfPix *pix);
	void	 setHandCursor(int active);
	long	 (*allocColor)(Color color);
	Color 	*getColormap(Color *old, long n, Cxform *cxform);
	void	 fillLine(long pixel, long y, long start, long end, int doAa = 0);
	void	 fillLine(SwfPix *pix, long xOffset, long yOffset, long y, long start, long end);
	void	 fillLine(Gradient *grad, long y, long start, long end);
	void	 fillLineRG(Gradient *grad, long y, long start, long end);
	void	 fillHitTestLine(unsigned char id, long y, long start, long end);
	void	 drawLine(long x1, long y1, long x2, long y2, long width);
	void	 synchronize();	// Force drawing of any pending requests

	// Hit test methods
	void		resetHitTest();
	unsigned char	registerHitTest(long tagId);
	void		clearHitTest(long tagId);
	long		checkHitTest(long tagId,long x, long y);
};

#endif /* _DISPLAY_H_ */
