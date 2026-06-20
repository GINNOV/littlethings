/* -------------------------------------------------------------------------- *\
   BITMAP24.CPP, 24 bit bitmap handling, including IFF24 saving
   Copyright (C) 1999  Jarno van der Linden
   jarno@kcbbs.gen.nz

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the
   Free Software Foundation, Inc., 59 Temple Place - Suite 330, Cambridge,
   MA 02139, USA.


   01 May 1999: Brought it all together in some sort of distributable form
\* -------------------------------------------------------------------------- */

/* -------------------------------- Includes -------------------------------- */
#include <dos/dos.h>
#include <libraries/iffparse.h>

#include <proto/dos.h>
#include <proto/iffparse.h>

#include <string.h>
#include <stdio.h>

#include "bitmap24.h"

/* ------------------------------ Definitions ------------------------------- */

/* --------------------------------- Macros --------------------------------- */
#define ID_ILBM	MAKE_ID('I','L','B','M')
#define ID_BMHD	MAKE_ID('B','M','H','D')
#define ID_BODY	MAKE_ID('B','O','D','Y')

/* -------------------------------- Typedefs -------------------------------- */
typedef UBYTE Masking;
#define mskNone	0
typedef UBYTE Compression;
#define cmpNone		0
#define cmpByteRun	1

typedef struct {
	UWORD w,h;
	WORD x,y;
	UBYTE nPlanes;
	Masking masking;
	Compression compression;
	UBYTE reserved1;
	UWORD transparentColor;
	UBYTE xAspect,yAspect;
	WORD pageWidth,pageHeight;
} BitMapHeader;


/* ------------------------------ Proto Types ------------------------------- */

/* -------------------------------- Structs --------------------------------- */

/* -------------------------------- Globals --------------------------------- */

/* ---------------------------------- Code ---------------------------------- */
BitMap24::BitMap24()
{
	Constructor(0,0);
}


BitMap24::BitMap24(char *filename)
{
	Constructor(0,0);
	if(!HasError())
		ReadBitMap(filename);
}


void BitMap24::Constructor(UWORD width_arg, UWORD height_arg)
{
	error = BITMAP24_ERROR_NONE;
	bitmap = NULL;

	if((width_arg != 0) && (height_arg != 0))
		SetSize(width_arg, height_arg);
}


BitMap24::~BitMap24()
{
	if(bitmap)
		delete[] bitmap;
	bitmap = NULL;
}


int BitMap24::GetError()
{
	return error;
}


BOOL BitMap24::HasError()
{
	return error != BITMAP24_ERROR_NONE;
}


int BitMap24::ResetError()
{
	int olderr;

	olderr = error;
	error = BITMAP24_ERROR_NONE;

	return olderr;
}


char *BitMap24::GetErrorStr(int err)
{
	switch(err)
	{
		case BITMAP24_ERROR_NONE:
			return "No error";
		case BITMAP24_ERROR_NOBITMAP:
			return "BitMap couldn't be allocated";
		case BITMAP24_ERROR_FILEOPEN:
			return "Error opening output file";
		case BITMAP24_ERROR_OUTOFBOUNDS:
			return "Out of bounds coordinate used";
		case BITMAP24_ERROR_ALLOCFAILURE:
			return "Memory allocation failure";
		case BITMAP24_ERROR_FILEFORMAT:
			return "File format not what expected";
		case BITMAP24_ERROR_PREPARSE:
			return "Setting up IFF parsing failed";
		case BITMAP24_ERROR_PARSE:
			return "Error during parsing";
	}

	return "Unknown error";
}


char *BitMap24::GetErrorStr()
{
	return GetErrorStr(error);
}


void BitMap24::SetSize(UWORD width_arg, UWORD height_arg)
{
	if(bitmap)
		delete[] bitmap;
	bitmap = NULL;

	realwidth = width = width_arg;
	realheight = height = height_arg;

	width += (16-(width & 15)) & 15;
	bytewidth = width >> 3;

	bitmap = new Colour[width*height];
	if(bitmap)
		memset(bitmap,0,width*height*sizeof(Colour));
	else
		error = BITMAP24_ERROR_NOBITMAP;
}


UWORD BitMap24::GetWidth()
{
	return GetWidthFast();
}


UWORD BitMap24::GetHeight()
{
	return GetHeightFast();
}


UWORD BitMap24::GetRealWidth()
{
	return GetRealWidthFast();
}


UWORD BitMap24::GetRealHeight()
{
	return GetRealHeightFast();
}


BOOL BitMap24::BoundsCheck(int x,int y)
{
	if((x < 0) || (x >= width) || (y < 0) || (y >= height))
	{
		error = BITMAP24_ERROR_OUTOFBOUNDS;
		return FALSE;
	}

	return TRUE;
}


void BitMap24::GetColour(Colour *c,int x,int y)
{
	if(BoundsCheck(x,y))
		GetColourFast(c,x,y);
}


UBYTE BitMap24::GetRed(int x,int y)
{
	if(BoundsCheck(x,y))
		return GetRedFast(x,y);

	return 0;
}


UBYTE BitMap24::GetGreen(int x,int y)
{
	if(BoundsCheck(x,y))
		return GetGreenFast(x,y);

	return 0;
}


UBYTE BitMap24::GetBlue(int x,int y)
{
	if(BoundsCheck(x,y))
		return GetBlueFast(x,y);

	return 0;
}


void BitMap24::SetColour(UBYTE r,UBYTE g,UBYTE b,int x,int y)
{
	if(BoundsCheck(x,y))
		SetColourFast(r,g,b,x,y);
}


void BitMap24::SetColour(const Colour &c,int x,int y)
{
	if(BoundsCheck(x,y))
		SetColourFast(c,x,y);
}


UBYTE BitMap24::GatherBits(int row, int c, int b, int x)
{
	UBYTE *bp;
	UBYTE v;

	x <<= 3;
	b = 1<<b;

	bp = ((UBYTE *)&bitmap[row*width+x]+c);

	v = (UBYTE)((*bp & b)!=0);
	bp+=3;
	v = (UBYTE)((v<<1) | ((*bp & b)!=0));
	bp+=3;
	v = (UBYTE)((v<<1) | ((*bp & b)!=0));
	bp+=3;
	v = (UBYTE)((v<<1) | ((*bp & b)!=0));
	bp+=3;
	v = (UBYTE)((v<<1) | ((*bp & b)!=0));
	bp+=3;
	v = (UBYTE)((v<<1) | ((*bp & b)!=0));
	bp+=3;
	v = (UBYTE)((v<<1) | ((*bp & b)!=0));
	bp+=3;
	v = (UBYTE)((v<<1) | ((*bp & b)!=0));

	return v;
}


void BitMap24::WriteChunkBytesCache(struct IFFHandle *iff, APTR data, LONG datasize)
{
#define CACHESIZE 8192
	static BYTE datacache[CACHESIZE];
	static LONG cachesize = 0;

	if(datasize == -1)
	{
		cachesize = 0;
	}
	else if(datasize == -2)
	{
		WriteChunkBytes(iff,datacache,cachesize);
		cachesize = 0;
	}
	else
	{
		if((cachesize + datasize) >= CACHESIZE)
		{
			WriteChunkBytes(iff,datacache,cachesize);
			WriteChunkBytes(iff,data,datasize);
			cachesize = 0;
		}
		else
		{
			memcpy(datacache+cachesize,data,datasize);
			cachesize += datasize;
		}
	}
#undef CACHESIZE
}


void BitMap24::WriteRun(struct IFFHandle *iff, int row, int c, int b, int runstart, int runend)
{
	int x,n;
	UBYTE v;
	UBYTE data;

	v = GatherBits(row,c,b,runstart);

	for(x=runstart; x<=runend; x+=128)
	{
		n = (runend-x+1);
		if(n > 128)
			n = 128;

		data = (UBYTE)(-(n-1));
		WriteChunkBytesCache(iff, &data, sizeof(data));
		WriteChunkBytesCache(iff, &v, sizeof(v));
	}
}


void BitMap24::WriteDump(struct IFFHandle *iff, int row, int c, int b, int runstart, int runend)
{
	int xx,x,n;
	UBYTE data;

	for(x=runstart; x<=runend; x+=128)
	{
		n = (runend-x+1);
		if(n > 128)
			n = 128;

		data = (UBYTE)(n-1);
		WriteChunkBytesCache(iff, &data, sizeof(data));
		for(xx=0; xx<n; xx++)
		{
			data = GatherBits(row,c,b,xx+x);
			WriteChunkBytesCache(iff, &data, sizeof(data));
		}
	}
}



void BitMap24::FindRun(int row, int c, int b, int start, int *runstart, int *runlength)
{
	int x;
	UBYTE vs,v;

	*runstart = x = start;
	v = GatherBits(row,c,b,x);

	while(*runstart < bytewidth)
	{
		vs = v;
		x++;
		while((x < bytewidth) && ((v = GatherBits(row,c,b,x)) == vs))
			x++;

		if((*runlength = x-*runstart) > 2)
			return;

		*runstart = x;
	}
}


void BitMap24::WriteBitMap(char *file)
{
	struct IFFHandle *iff;
	BitMapHeader bmheader;
	int y,c,b;
	int runstart,runlength,runend;

	bmheader.w = realwidth;
	bmheader.h = realheight;
	bmheader.x = 0;
	bmheader.y = 0;
	bmheader.nPlanes = 24;
	bmheader.masking = mskNone;
	bmheader.compression = cmpByteRun;
	bmheader.reserved1 = 0;
	bmheader.transparentColor = 0;
	bmheader.xAspect = 1;
	bmheader.yAspect = 1;
	bmheader.pageWidth = (WORD)realwidth;
	bmheader.pageHeight = (WORD)realheight;

	iff = AllocIFF();
	if(!iff)
	{
		error = BITMAP24_ERROR_ALLOCFAILURE;
		return;
	}

	iff->iff_Stream = Open(file,MODE_NEWFILE);
	if(!(iff->iff_Stream))
	{
		error = BITMAP24_ERROR_FILEOPEN;
		FreeIFF(iff);
		return;
	}

	InitIFFasDOS(iff);
	if(OpenIFF(iff,IFFF_WRITE))
	{
		error = BITMAP24_ERROR_FILEOPEN;
		Close(iff->iff_Stream);
		FreeIFF(iff);
		return;
	}

	PushChunk(iff, ID_ILBM, ID_FORM, IFFSIZE_UNKNOWN);

	PushChunk(iff, ID_ILBM, ID_BMHD, sizeof(BitMapHeader));
	WriteChunkBytes(iff,&bmheader,sizeof(bmheader));
	PopChunk(iff);

	PushChunk(iff, ID_ILBM, ID_BODY, IFFSIZE_UNKNOWN);
	WriteChunkBytesCache(iff,NULL,-1);
	for(y=0; y<height; y++)
	{
		for(c=0; c<3; c++)
		{
			for(b=0; b<8; b++)
			{
				runend = 0;

				while(runend < bytewidth)
				{
					FindRun(y,c,b, runend, &runstart, &runlength);
					WriteDump(iff, y,c,b, runend,runstart-1);
					runend = runstart+runlength;
					if(runstart < bytewidth)
						WriteRun(iff, y,c,b, runstart,runend-1);
				}
			}
		}
	}
	WriteChunkBytesCache(iff,NULL,-2);
	PopChunk(iff);

	PopChunk(iff);

	CloseIFF(iff);
	Close(iff->iff_Stream);
	FreeIFF(iff);
}


void BitMap24::SpreadBits(int row, int c, int b, int x, UBYTE v)
{
	UBYTE *bp;

	bp = ((UBYTE *)&bitmap[row*width+x]+c);
	*bp |= ((v & 128) != 0) << b;
	bp+=3;
	*bp |= ((v & 64) != 0) << b;
	bp+=3;
	*bp |= ((v & 32) != 0) << b;
	bp+=3;
	*bp |= ((v & 16) != 0) << b;
	bp+=3;
	*bp |= ((v & 8) != 0) << b;
	bp+=3;
	*bp |= ((v & 4) != 0) << b;
	bp+=3;
	*bp |= ((v & 2) != 0) << b;
	bp+=3;
	*bp |= ((v & 1) != 0) << b;
}


struct IFFHandle *BitMap24::OpenIFFParse(char *file, ULONG chunk)
{
	struct IFFHandle *iff;

	if(iff = AllocIFF())
	{
		if(iff->iff_Stream= Open(file,MODE_OLDFILE))
		{
			InitIFFasDOS(iff);
			if(!OpenIFF(iff,IFFF_READ))
			{
				if(!StopChunk(iff,ID_ILBM, chunk))
				{
					if(!ParseIFF(iff,IFFPARSE_SCAN))
					{
						return iff;
					}
					if(!error) error = BITMAP24_ERROR_PARSE;
				}
				if(!error) error = BITMAP24_ERROR_PREPARSE;
				CloseIFF(iff);
			}
			if(!error) error = BITMAP24_ERROR_FILEOPEN;
			Close(iff->iff_Stream);
		}
		if(!error) error = BITMAP24_ERROR_FILEOPEN;
		FreeIFF(iff);
	}
	if(!error) error = BITMAP24_ERROR_ALLOCFAILURE;

	return NULL;
}


void BitMap24::CloseIFFParse(struct IFFHandle *iff)
{
	if(iff)
	{
		CloseIFF(iff);
		if(iff->iff_Stream) Close(iff->iff_Stream);
		FreeIFF(iff);
	}
}


BOOL BitMap24::ReadChunkBytesCache(struct IFFHandle *iff, UBYTE *data, LONG datasize)
{
#define CACHESIZE 8192
	static BYTE datacache[CACHESIZE];
	static LONG cachesize = 0;

	if(datasize == -1)
	{
		cachesize = CACHESIZE;
		if(ReadChunkBytes(iff,datacache,CACHESIZE) < 0)
		{
			error = BITMAP24_ERROR_PARSE;
			return FALSE;
		}
	}
	else
	{
		if(datasize > cachesize)
		{
			memcpy(data,datacache+CACHESIZE-cachesize,cachesize);
			if(ReadChunkBytes(iff,data+cachesize,datasize-cachesize) < 0)
			{
				error = BITMAP24_ERROR_PARSE;
				return FALSE;
			}
			if(ReadChunkBytes(iff,datacache,CACHESIZE) < 0)
			{
				error = BITMAP24_ERROR_PARSE;
				return FALSE;
			}

			cachesize = CACHESIZE;
		}
		else
		{
			memcpy(data,datacache+CACHESIZE-cachesize,datasize);
			cachesize -= datasize;
		}
	}

	return TRUE;
#undef CACHESIZE
}


void BitMap24::ReadBitMap(char *file)
{
	struct IFFHandle *iff;
	BitMapHeader bmheader;
	Compression compression;

	iff = OpenIFFParse(file,ID_BMHD);
	if(!iff)
		return;

	if(1 != ReadChunkRecords(iff, &bmheader, sizeof(bmheader), 1))
	{
		error = BITMAP24_ERROR_FILEFORMAT;
		CloseIFFParse(iff);
		return;
	}

	if(bmheader.nPlanes != 24)
	{
		error = BITMAP24_ERROR_FILEFORMAT;
		CloseIFFParse(iff);
		return;
	}

	SetSize(bmheader.w, bmheader.h);
	if(HasError())
	{
		CloseIFFParse(iff);
		return;
	}

	compression = bmheader.compression;

	CloseIFFParse(iff);
	iff = OpenIFFParse(file,ID_BODY);
	if(!iff)
		return;

	if(!ReadChunkBytesCache(iff,NULL,-1))
	{
		CloseIFFParse(iff);
		return;
	}
	if(compression)
	{
		UBYTE bb[256], *bbp;
		BYTE n;

		for(int row=0; row<height; row++)
		{
			for(int c=0; c<3; c++)
			{
				for(int b=0; b<8; b++)
				{
					int x=0;
					while(x < width)
					{
						if(!ReadChunkBytesCache(iff, (UBYTE *)&n, 1))
						{
							CloseIFFParse(iff);
							return;
						}
						if(n >= 0)
						{
							if(!ReadChunkBytesCache(iff, bb, n+1))
							{
								CloseIFFParse(iff);
								return;
							}
							bbp = bb;
							for(BYTE xx=0; xx<=n; xx++)
							{
								SpreadBits(row,c,b,x,*bbp);
								bbp++;
								x+=8;
							}
						}
						else if(n > -128)
						{
							if(!ReadChunkBytesCache(iff, bb, 1))
							{
								CloseIFFParse(iff);
								return;
							}
							for(BYTE xx=0; xx<(1-n); xx++)
							{
								SpreadBits(row,c,b,x,*bb);
								x+=8;
							}
						}
						else
						{
							;
						}
					}
				}
			}
		}
	}

	CloseIFFParse(iff);
}


void BitMap24::SetError(int error_arg)
{
	error = error_arg;
}
