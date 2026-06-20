#ifndef ZBITMAP24_H
#define ZBITMAP24_H
/* -------------------------------------------------------------------------- *\
   ZBITMAP24.H, a BitMap24 subclass which introduces simple Z-Buffering, header file
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

#include "bitmap24.h"

/* ------------------------------ Definitions ------------------------------- */
enum {
	ZBITMAP24_ERROR_NOZBUFFER = 100
};

/* --------------------------------- Macros --------------------------------- */

/* -------------------------------- Typedefs -------------------------------- */

/* ------------------------------ Proto Types ------------------------------- */

/* -------------------------------- Structs --------------------------------- */
class ZBitMap24 : public BitMap24
{
	public:
		ZBitMap24();
		~ZBitMap24();

		char *GetErrorStr(int error);
		char *GetErrorStr();

		void SetMaxZ(double maxz);

		inline UWORD GetBufferZ(int x,int y);
		inline UWORD GetBufferZ(double z);

		void SetColour(UBYTE r,UBYTE g,UBYTE b,double z,int x,int y);
		void SetColour(const Colour &c, double z,int x,int y);

		virtual inline void SetColourFast(UBYTE r,UBYTE g,UBYTE b,double z,int x,int y);
		virtual inline void SetColourFast(const Colour &c,double z, int x,int y);

		inline BOOL CanDraw(int x,int y,double z);
		inline BOOL CanDrawSet(int x,int y,double z);

		virtual inline UWORD *GetZBuffer();

		virtual void SetSize(UWORD width,UWORD height);

	private:
		UWORD *zbuffer;
		double mul,maxz;
};


/* -------------------------------- Globals --------------------------------- */

/* ---------------------------------- Code ---------------------------------- */
inline UWORD ZBitMap24::GetBufferZ(int x,int y)
{
	return zbuffer[y*GetWidthFast()+x];
}


inline UWORD ZBitMap24::GetBufferZ(double z)
{
	return (UWORD)(mul * log(z+1.0));
}


inline void ZBitMap24::SetColourFast(UBYTE r,UBYTE g,UBYTE b,double z,int x,int y)
{
	UWORD zb,*zbp;

	zb = GetBufferZ(z);
	zbp = &(zbuffer[y*GetWidthFast()+x]);

	if(zb <= *zbp)
	{
		*zbp = zb;
		BitMap24::SetColourFast(r,g,b,x,y);
	}
}


inline void ZBitMap24::SetColourFast(const Colour &c,double z,int x,int y)
{
	UWORD zb,*zbp;

	zb = GetBufferZ(z);
	zbp = &(zbuffer[y*GetWidthFast()+x]);

	if(zb <= *zbp)
	{
		*zbp = zb;
		BitMap24::SetColourFast(c,x,y);
	}
}


inline BOOL ZBitMap24::CanDraw(int x,int y,double z)
{
	if(GetBufferZ(z) <= GetBufferZ(x,y))
		return TRUE;

	return FALSE;
}


inline BOOL ZBitMap24::CanDrawSet(int x,int y,double z)
{
	UWORD zb, *zbp;

	zb = GetBufferZ(z);
	zbp = &(zbuffer[y*GetWidthFast()+x]);

	if(zb <= *zbp)
	{
		*zbp = zb;
		return TRUE;
	}

	return FALSE;
}


inline UWORD *ZBitMap24::GetZBuffer()
{
	return zbuffer;
}

#endif /* ZBITMAP24_H */
