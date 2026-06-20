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
//  Author : Olivier Debon  <odebon@club-internet.fr>
//  

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <setjmp.h>
#include "bitmap.h"
#include "graphic.h"

static char *rcsid = "$Id: bitmap.cc,v 1.11 1999/01/31 20:09:10 olivier Exp $";

static unsigned char *inputData;

extern "C" {
#include "Jpeg/jpeglib.h"
};

extern "C" {
#include "Zlib/zlib.h"
};

// Class variables

int Bitmap::haveTables = 0;

struct jpeg_decompress_struct Bitmap::jpegObject;

struct jpeg_source_mgr Bitmap::jpegSourceManager;

MyErrorHandler Bitmap::jpegErrorMgr;

Bitmap::Bitmap(long id, int level) : Character(BitmapType, id )
{
	pixels = 0;
	colormap = 0;
	nbColors = 0;
	defLevel = level;
}

Bitmap::~Bitmap()
{
	if (pixels) {
		free(pixels);
	}
	if (colormap)
	{
		free(colormap);
	}
}

static void errorExit(j_common_ptr info)
{
	(*info->err->output_message) (info);
	longjmp(((MyErrorHandler *)info->err)->setjmp_buffer, 1);
}

// Methods for Source data manager
static void initSource(struct jpeg_decompress_struct *cInfo)
{
	cInfo->src->bytes_in_buffer = 0;
}

static boolean fillInputBuffer(struct jpeg_decompress_struct *cInfo)
{
	cInfo->src->next_input_byte = inputData;
	cInfo->src->bytes_in_buffer = 1;
	inputData++;

	return 1;
}

static void skipInputData(struct jpeg_decompress_struct *cInfo, long count)
{
	cInfo->src->bytes_in_buffer = 0;
	inputData += count;
}

static boolean resyncToRestart(struct jpeg_decompress_struct *cInfo, int desired)
{
	return jpeg_resync_to_restart(cInfo, desired);
}

static void termSource(struct jpeg_decompress_struct *cInfo)
{
}

long Bitmap::getWidth()
{
	return width;
}

long Bitmap::getHeight()
{
	return height;
}

Color *
Bitmap::getColormap(long *n) {
       if (n) *n = nbColors;
       return colormap;
}

unsigned char *
Bitmap::getPixels()
{
       return pixels;
}

SwfPix *
Bitmap::getImage(GraphicDevice *gd, Matrix *mat, Cxform *cxform)
{
	float xFactor, yFactor;
	long w,h;
	long x,y;
	SwfPix *pix;
	unsigned char *p;
	unsigned char *cLine;
	long pixel;
	char *line;
	long incrLine;
	long n;
	long X,DX;
	Color *cmap;

	if (pixels == 0) return 0;

	xFactor = mat->a / 20.0;
	yFactor = mat->d / 20.0;

	// Not supported although it could be simple
	if (xFactor < 0 || yFactor < 0) return 0;

	w = (long)(xFactor * width);
	h = (long)(yFactor * height);

	cmap = gd->getColormap(colormap, nbColors, cxform);

	pix = gd->createSwfPix(w,h);

	line = pix->data;
	incrLine = pix->bpl;

	DX = (long)(65536.0/xFactor);

	if (gd->bpp == 2) {
		for(y=0; y < h; y++)
		{
			short *ptr;

			ptr = (short *)line;
			cLine = pixels+(long)(y/yFactor)*width;
			X = 0;
			for(x=0; x < w; x++)
			{
				p = cLine+(X>>16);
				X+=DX;
				*ptr = cmap[*p].pixel;
				ptr++;
			}
			line += incrLine;
		}
	} else
	if (gd->bpp == 4) {
		for(y=0; y < h; y++)
		{
			long *ptr;

			ptr = (long *)line;
			cLine = pixels+(long)(y/yFactor)*width;
			X = 0;
			for(x=0; x < w; x++)
			{
				p = cLine+(X>>16);
				X+=DX;
				*ptr = cmap[*p].pixel;
				ptr++;
			}
			line += incrLine;
		}
	} else
	if (gd->bpp == 1) {
		for(y=0; y < h; y++)
		{
			char *ptr;

			ptr = (char *)line;
			cLine = pixels+(long)(y/yFactor)*width;
			X = 0;
			for(x=0; x < w; x++)
			{
				p = cLine+(X>>16);
				X+=DX;
				*ptr = cmap[*p].pixel;
				ptr++;
			}
			line += incrLine;
		}
	}

	free(cmap);

	return pix;
}

// Read Tables and Compressed data to produce an image

int
Bitmap::buildFromJpegInterchangeData(unsigned char *stream)
{
	struct jpeg_decompress_struct cInfo;
	struct jpeg_source_mgr mySrcMgr;
	MyErrorHandler errorMgr;
	JSAMPARRAY buffer;
	unsigned char *ptrPix;
	int stride;
	long n;

	// Setup error handler
	cInfo.err = jpeg_std_error(&errorMgr.pub);
	errorMgr.pub.error_exit = errorExit;

	if (setjmp(errorMgr.setjmp_buffer)) {
		// JPEG data Error
		jpeg_destroy_decompress(&cInfo);
		return -1;
	}

	// Set current stream pointer to stream
	inputData = stream;

	// Here it's Ok

	jpeg_create_decompress(&cInfo);

	// Setup source manager structure
	mySrcMgr.init_source = initSource;
	mySrcMgr.fill_input_buffer = fillInputBuffer;
	mySrcMgr.skip_input_data = skipInputData;
	mySrcMgr.resync_to_restart = resyncToRestart;
	mySrcMgr.term_source = termSource;

	// Set default source manager
	cInfo.src = &mySrcMgr;

	jpeg_read_header(&cInfo, FALSE);

	jpeg_read_header(&cInfo, TRUE);
	cInfo.quantize_colors = TRUE;	// Create colormapped image

	jpeg_start_decompress(&cInfo);

	// Set objet dimensions
	height = cInfo.output_height;
	width = cInfo.output_width;
	pixels = (unsigned char *)malloc(height*width);
	ptrPix = pixels;

	stride = cInfo.output_width * cInfo.output_components;

	buffer = (*cInfo.mem->alloc_sarray) ((j_common_ptr) &cInfo, JPOOL_IMAGE, stride, 1);

	while (cInfo.output_scanline < cInfo.output_height) {

		jpeg_read_scanlines(&cInfo, buffer, 1);

		memcpy(ptrPix,buffer[0],stride);

		ptrPix+= stride;
	}

	colormap = new Color[cInfo.actual_number_of_colors];
	nbColors = cInfo.actual_number_of_colors;

	for(n=0; n < nbColors; n++)
	{
		colormap[n].red = cInfo.colormap[0][n];
		colormap[n].green = cInfo.colormap[1][n];
		colormap[n].blue = cInfo.colormap[2][n];
	}

	jpeg_finish_decompress(&cInfo);
	jpeg_destroy_decompress(&cInfo);

	return 0;
}

// Read JPEG image using pre-loaded Tables

int
Bitmap::buildFromJpegAbbreviatedData(unsigned char *stream)
{
	JSAMPROW buffer[1];
	unsigned char *ptrPix;
	int stride;
	long n;
	int status;

	// Set current stream pointer to stream
	inputData = stream;

	// Error handler
	if (setjmp(jpegErrorMgr.setjmp_buffer)) {
		// JPEG data Error
		jpeg_destroy_decompress(&jpegObject);
		return -1;
	}

	// Here it's ok

	jpeg_read_header(&jpegObject, TRUE);
	jpegObject.quantize_colors = TRUE;	// Create colormapped image

	jpeg_start_decompress(&jpegObject);

	// Set objet dimensions
	height = jpegObject.output_height;
	width = jpegObject.output_width;
	pixels = (unsigned char *)malloc(height*width);
	ptrPix = pixels;

	stride = jpegObject.output_width * jpegObject.output_components;

	buffer[0] = (JSAMPROW)malloc(stride);

	while (jpegObject.output_scanline < jpegObject.output_height) {

		status = jpeg_read_scanlines(&jpegObject, buffer, 1);

		memcpy(ptrPix,buffer[0],stride);

		ptrPix+= stride;
	}

	colormap = new Color[jpegObject.actual_number_of_colors];
	nbColors = jpegObject.actual_number_of_colors;

	for(n=0; n < nbColors; n++)
	{
		colormap[n].red = jpegObject.colormap[0][n];
		colormap[n].green = jpegObject.colormap[1][n];
		colormap[n].blue = jpegObject.colormap[2][n];
	}

	status = jpeg_finish_decompress(&jpegObject);

	return 0;
}

// Just init JPEG object and read JPEG Tables

int
Bitmap::readJpegTables(unsigned char *stream)
{
	if (haveTables) {
		//Error, it has already been initialized
		return -1;
	}

	// Setup error handler
	jpegObject.err = jpeg_std_error(&jpegErrorMgr.pub);
	jpegErrorMgr.pub.error_exit = errorExit;

	if (setjmp(jpegErrorMgr.setjmp_buffer)) {
		// JPEG data Error
		jpeg_destroy_decompress(&jpegObject);
		return -1;
	}

	// Set current stream pointer to stream
	inputData = stream;

	// Here it's Ok

	jpeg_create_decompress(&jpegObject);

	// Setup source manager structure
	jpegSourceManager.init_source = initSource;
	jpegSourceManager.fill_input_buffer = fillInputBuffer;
	jpegSourceManager.skip_input_data = skipInputData;
	jpegSourceManager.resync_to_restart = resyncToRestart;
	jpegSourceManager.term_source = termSource;

	// Set default source manager
	jpegObject.src = &jpegSourceManager;

	jpeg_read_header(&jpegObject, FALSE);

	return 0;
}

int Bitmap::buildFromZlibData(unsigned char *buffer, int width, int height, int format, int tableSize)
{
	z_stream	stream;
	int		status;
	unsigned char  *data;

	this->width = width;
	this->height = height;

	stream.next_in = buffer;
	stream.avail_in = 1;
	stream.zalloc = Z_NULL;
	stream.zfree = Z_NULL;

	tableSize++;

	// Uncompress Color Table
	if (format == 3) {
		unsigned char *colorTable;
		long n;

		// Ajust width for 32 bit padding
		width = (width+3)/4*4;
		this->width = width;

		depth = 1;
		colorTable = new unsigned char[tableSize*3];

		stream.next_out = colorTable;
		stream.avail_out = tableSize*3;

		inflateInit(&stream);

		while (1) {
			status = inflate(&stream, Z_SYNC_FLUSH);
			if (status == Z_STREAM_END) {
					break;
			}
			if (status != Z_OK) {
				printf("Zlib cmap error : %s\n", stream.msg);
				return 1;
			}
			stream.avail_in = 1;
			// Colormap if full
			if (stream.avail_out == 0) {
				break;
			}
		}

		nbColors = tableSize;

		colormap = (Color *)malloc(nbColors*sizeof(Color));

		for(n=0; n < nbColors; n++) {
			colormap[n].red = colorTable[n*3+0];
			colormap[n].green = colorTable[n*3+1];
			colormap[n].blue = colorTable[n*3+2];
		}

		delete colorTable;

	} else if (format == 4) {
		depth = 2;
	} else if (format == 5) {
		depth = 4;
	}

	data = new unsigned char[depth*width*height];

	stream.next_out = data;
	stream.avail_out = depth*width*height;

	if (format != 3) {
		status = inflateInit(&stream);
	}

	while (1) {
		status = inflate(&stream, Z_SYNC_FLUSH) ;
		if (status == Z_STREAM_END) {
				break;
		}
		if (status != Z_OK) {
			printf("Zlib data error : %s\n", stream.msg);
			return 1;
		}
		stream.avail_in = 1;
	}

	inflateEnd(&stream);

	pixels = (unsigned char *)malloc(height*width);

	if (format != 3) {
		int n,c;
		unsigned char r,g,b,a;
		unsigned char *ptr;

		nbColors = 0;
		colormap = (Color *)calloc(256,sizeof(Color));
		ptr = pixels;
		
		for(n=0; n < width*height*depth; n+=depth,ptr++) {
			switch (format) {
				case 4:
					break;
				case 5:
					a = data[n];
					// Reduce color dynamic range
					r = data[n+1]&0xe0;
					g = data[n+2]&0xe0;
					b = data[n+3]&0xe0;
					break;
			}
			for(c=0; c < nbColors; c++) {
				if (r == colormap[c].red
				&&  g == colormap[c].green
				&&  b == colormap[c].blue) {
					*ptr = c;
					break;
				}
			}
			if (c == nbColors) {
				if (nbColors == 256) continue;
				nbColors++;
				if (nbColors == 256) {
					//printf("Colormap entries exhausted. After %d scanned pixels\n", n/4);
				}
				colormap[c].alpha = a;
				colormap[c].red   = r;
				colormap[c].green = g;
				colormap[c].blue  = b;
				*ptr = c;
			}
		}
	} else {
		memcpy(pixels, data, width*height);
	}

	delete data;
	return 0;
}
