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
#ifndef _BITMAP_H_
#define _BITMAP_H_

#include <stdio.h>
#include <sys/types.h>
#include <setjmp.h>
extern "C" {
#include "Jpeg/jpeglib.h"
};
extern "C" {
#include "Zlib/zlib.h"
};
#include "swf.h"
#include "character.h"
#include "graphic.h"

struct MyErrorHandler {
	struct jpeg_error_mgr pub;
	jmp_buf setjmp_buffer;
};

class Bitmap : public Character {
	long		 width;
	long		 height;
	long		 depth;

	unsigned char 	*pixels;		// Array of Pixels
	Color		*colormap; 	// Array of color definitions
	long		 nbColors;

	int		 defLevel;

// Class Variables

	static int haveTables;
	static struct jpeg_decompress_struct jpegObject;
	static struct jpeg_source_mgr jpegSourceManager;
	static MyErrorHandler jpegErrorMgr;

public:
	Bitmap(long id, int level = 1);
	~Bitmap();

	// JPEG handling methods
	int	 buildFromJpegInterchangeData(unsigned char *stream);	// Complete
	int	 buildFromJpegAbbreviatedData(unsigned char *stream);	// Abbreviated

		// Class Method
	static int readJpegTables(unsigned char *stream);	// Tables Only

	// ZLIB handling methods
	int	 buildFromZlibData(unsigned char *buffer,
					int width, int height,
					int format, int tableSize);

	SwfPix		*getImage(GraphicDevice *, Matrix *, Cxform *);
	long		 getWidth();
	long		 getHeight();
	Color   	*getColormap(long *n);
	unsigned char 	*getPixels();
};

#endif /* _BITMAP_H_ */
