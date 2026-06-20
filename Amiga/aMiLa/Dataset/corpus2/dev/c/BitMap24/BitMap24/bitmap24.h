#ifndef BITMAP24_H
#define BITMAP24_H
/* -------------------------------------------------------------------------- *\
   BITMAP24.H, 24 bit bitmap handling, including IFF24 saving; header file
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
#include <exec/types.h>
#include <dos/dos.h>

#include <math.h>

/* ------------------------------ Definitions ------------------------------- */
enum {
	BITMAP24_ERROR_NONE = 0,
	BITMAP24_ERROR_NOBITMAP,
	BITMAP24_ERROR_FILEOPEN,
	BITMAP24_ERROR_OUTOFBOUNDS,
	BITMAP24_ERROR_ALLOCFAILURE,
	BITMAP24_ERROR_FILEFORMAT,
	BITMAP24_ERROR_PARSE,
	BITMAP24_ERROR_PREPARSE
};

/* --------------------------------- Macros --------------------------------- */

/* -------------------------------- Typedefs -------------------------------- */
typedef struct {
	UBYTE r;
	UBYTE g;
	UBYTE b;
} Colour;

/* ------------------------------ Proto Types ------------------------------- */

/* -------------------------------- Structs --------------------------------- */

class BitMap24 {
	public:
		BitMap24();
		BitMap24(char *file);
		virtual ~BitMap24();

		int GetError();
		BOOL HasError();
		int ResetError();
		virtual char *GetErrorStr(int error);
		virtual char *GetErrorStr();

		UWORD GetWidth();
		UWORD GetHeight();
		UWORD GetRealWidth();
		UWORD GetRealHeight();

		virtual void GetColour(Colour *c,int x,int y);
		virtual UBYTE GetRed(int x,int y);
		virtual UBYTE GetGreen(int x,int y);
		virtual UBYTE GetBlue(int x,int y);
		virtual void SetColour(UBYTE r,UBYTE g,UBYTE b,int x,int y);
		virtual void SetColour(const Colour &c, int x,int y);

		inline UWORD GetWidthFast();
		inline UWORD GetHeightFast();
		inline UWORD GetRealWidthFast();
		inline UWORD GetRealHeightFast();

		virtual inline void GetColourFast(Colour *c,int x,int y);
		virtual inline UBYTE GetRedFast(int x,int y);
		virtual inline UBYTE GetGreenFast(int x,int y);
		virtual inline UBYTE GetBlueFast(int x,int y);
		virtual inline void SetColourFast(UBYTE r,UBYTE g,UBYTE b,int x,int y);
		virtual inline void SetColourFast(const Colour &c, int x,int y);

		virtual void WriteBitMap(char *file);
		virtual void ReadBitMap(char *file);

		virtual inline UBYTE *GetBitMap();

		virtual void SetSize(UWORD width,UWORD height);
		BOOL BoundsCheck(int x,int y);

	protected:
		void SetError(int error);

	private:
		void Constructor(UWORD width,UWORD height);
		inline UBYTE GatherBits(int row, int c, int b, int x);
		inline void WriteRun(struct IFFHandle *iff, int row, int c, int b, int runstart, int runend);
		inline void WriteDump(struct IFFHandle *iff, int row, int c, int b, int runstart, int runend);
		inline void FindRun(int row, int c, int b, int start, int *runstart, int *runlength);
		inline void SpreadBits(int row, int c, int b, int x, UBYTE v);
		struct IFFHandle *OpenIFFParse(char *file, ULONG chunk);
		void CloseIFFParse(struct IFFHandle *iff);
		inline void WriteChunkBytesCache(struct IFFHandle *iff, APTR data, LONG datasize);
		inline BOOL ReadChunkBytesCache(struct IFFHandle *iff, UBYTE *data, LONG datasize);
	private:
		Colour *bitmap;
		UWORD width,height;
		UWORD realwidth,realheight;
		int bytewidth;
		int error;
};


/* -------------------------------- Globals --------------------------------- */

/* ---------------------------------- Code ---------------------------------- */
inline UWORD BitMap24::GetWidthFast()
{
	return width;
}


inline UWORD BitMap24::GetHeightFast()
{
	return height;
}


inline UWORD BitMap24::GetRealWidthFast()
{
	return realwidth;
}


inline UWORD BitMap24::GetRealHeightFast()
{
	return realheight;
}


inline void BitMap24::GetColourFast(Colour *c,int x,int y)
{
	*c = bitmap[y*width+x];
}


inline UBYTE BitMap24::GetRedFast(int x,int y)
{
	return bitmap[y*width+x].r;
}


inline UBYTE BitMap24::GetGreenFast(int x,int y)
{
	return bitmap[y*width+x].g;
}


inline UBYTE BitMap24::GetBlueFast(int x,int y)
{
	return bitmap[y*width+x].b;
}


inline void BitMap24::SetColourFast(UBYTE r,UBYTE g,UBYTE b,int x,int y)
{
	Colour *bp;

	bp = &(bitmap[y*width+x]);
	bp->r = r;
	bp->g = g;
	bp->b = b;
}


inline void BitMap24::SetColourFast(const Colour &c,int x,int y)
{
	bitmap[y*width+x] = c;
}


inline UBYTE *BitMap24::GetBitMap()
{
	return (UBYTE *)bitmap;
}


#endif /* BITMAP24_H */
