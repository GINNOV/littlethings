/* -------------------------------------------------------------------------- *\
   ZBITMAP24.CPP, a BitMap24 subclass which introduces simple Z-Buffering
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
#include <string.h>

#include "zbitmap24.h"

/* ------------------------------ Definitions ------------------------------- */

/* --------------------------------- Macros --------------------------------- */

/* -------------------------------- Typedefs -------------------------------- */

/* ------------------------------ Proto Types ------------------------------- */

/* -------------------------------- Structs --------------------------------- */

/* -------------------------------- Globals --------------------------------- */

/* ---------------------------------- Code ---------------------------------- */
ZBitMap24::ZBitMap24()
	: BitMap24()
{
	zbuffer = NULL;
}


ZBitMap24::~ZBitMap24()
{
	if(zbuffer)
		delete[] zbuffer;
	zbuffer = NULL;
}


char *ZBitMap24::GetErrorStr(int error)
{
	switch(error)
	{
		case ZBITMAP24_ERROR_NOZBUFFER:
			return("Z-Buffer couldn't be allocated\n");
	}

	return BitMap24::GetErrorStr(error);
}


char *ZBitMap24::GetErrorStr()
{
	return BitMap24::GetErrorStr();
}


void ZBitMap24::SetMaxZ(double maxz_arg)
{
	UWORD z;
	UWORD *zb;

	maxz = maxz_arg;
	if(maxz > 0.0)
		mul = 65535.0/log(maxz+1.0);
	else
		mul = 0.0;

	z = GetBufferZ(maxz);
	zb = zbuffer;
	for(int t=GetWidthFast()*GetHeightFast()-1; t>=0;t--)
		*(zb++) = z;
}


void ZBitMap24::SetColour(UBYTE r,UBYTE g,UBYTE b,double z,int x,int y)
{
	if(BoundsCheck(x,y))
		SetColourFast(r,g,b,z,x,y);
}


void ZBitMap24::SetColour(const Colour &c,double z,int x,int y)
{
	if(BoundsCheck(x,y))
		SetColourFast(c,z,x,y);
}


void ZBitMap24::SetSize(UWORD width_arg, UWORD height_arg)
{
	UWORD width,height;

	if(zbuffer)
		delete[] zbuffer;
	zbuffer = NULL;

	BitMap24::SetSize(width_arg,height_arg);

	width = GetWidthFast();
	height = GetHeightFast();

	zbuffer = new UWORD[width*height];
	if(zbuffer)
		SetMaxZ(1.0);
	else
		SetError(ZBITMAP24_ERROR_NOZBUFFER);
}
