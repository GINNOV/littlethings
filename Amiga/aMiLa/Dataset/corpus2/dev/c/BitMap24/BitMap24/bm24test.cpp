/* -------------------------------------------------------------------------- *\
   BM24TEST.CPP, a program to demonstrate the BitMap24 class
   Copyright (C) 1999  Jarno van der Linden
   jarno@kcbbs.gen.nz

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


   01 May 1999: Project started
\* -------------------------------------------------------------------------- */

/* -------------------------------- Includes -------------------------------- */
#include <iostream.h>

#include <stdlib.h>

#include "bitmap24.h"
#include "zbitmap24.h"

/* ------------------------------ Definitions ------------------------------- */

/* --------------------------------- Macros --------------------------------- */

/* -------------------------------- Typedefs -------------------------------- */

/* ------------------------------ Proto Types ------------------------------- */

/* -------------------------------- Structs --------------------------------- */

/* -------------------------------- Globals --------------------------------- */

/* ---------------------------------- Code ---------------------------------- */

/*
 * A simple example of bitmap reading
 * The bitmap is read from the given filename
 * Just outputs some info about the bitmap
 *
 */
void ReadTest(char *filename)
{
	BitMap24 *inputbm;

	cout << "ReadTest" << endl;
	cout << "Reading bitmap, please wait (and wait, and wait,...)" << endl;

	inputbm = new BitMap24( filename );

	if( ! inputbm->HasError() )
	{
		cout << "Name: "          << filename                 << endl;
		cout << "BitMap Width: "  << inputbm->GetWidth()      << endl;
		cout << "BitMap Height: " << inputbm->GetHeight()     << endl;
		cout << "Image Width: "   << inputbm->GetRealWidth()  << endl;
		cout << "Image Height: "  << inputbm->GetRealHeight() << endl;
	}

	cout << "Error: " << inputbm->GetErrorStr() << endl << endl;

	delete inputbm;
}


/*
 * A simple example of bitmap reading and writing
 * A bitmap is read from the given filename
 * A new bitmap is created of half the size by
 * skipping every second column and row.
 * (This is not the way a scaling should be done)
 * The resulting bitmap is saved to T:bm24out.iff24
 *
 */
void WriteTest(char *infilename)
{
	BitMap24 inbm, outbm;
	int x,y;
	Colour inc;

	cout << "WriteTest" << endl;
	cout << "Reading bitmap, please wait (and wait, and wait,...)" << endl;

	inbm.ReadBitMap(infilename);
	if(inbm.HasError())
	{
		cout << "Error: " << inbm.GetErrorStr() << endl;
		return;
	}

	outbm.SetSize(inbm.GetWidth()/2,inbm.GetHeight()/2);

	cout << "Scaling..." << endl;

	for(y=0; y<outbm.GetHeightFast(); y++)
	{
		for(x=0; x<outbm.GetWidthFast(); x++)
		{
			inbm.GetColourFast(&inc, x*2,y*2);
			outbm.SetColourFast(inc,x,y);
		}
	}

	cout << "Writing..." << endl;

	outbm.WriteBitMap("T:bm24out.iff24");

	cout << "Error: " << outbm.GetErrorStr() << endl << endl;
}


/*
 * A simple example of using ZBitMap24
 * A small bitmap is filled, and written
 * to T:zbm24out.iff24
 *
 */
void ZTest(void)
{
	ZBitMap24 bm;
	int x,y;

	cout << "ZTest" << endl;

	bm.SetSize(40,60);			// Bitmap is 40 wide, 60 high
	bm.SetMaxZ(1.0);			// Indicate at least the largest
								// depth value we are going to write

	if(bm.HasError())
	{
		cout << "Error: " << bm.GetErrorStr() << endl;
		return;
	}

	cout << "Filling..." << endl;

	for(y=0; y<bm.GetHeightFast(); y++)
	{
		for(x=0; x<bm.GetWidthFast(); x++)
		{
			bm.SetColourFast(255,0,0,((double)x)/bm.GetWidthFast(),x,y);
			bm.SetColourFast(0,255,0,((double)y)/bm.GetHeightFast(),x,y);
			if(bm.CanDrawSet(x,y,0.5))			// Just to be different...
				((BitMap24)bm).SetColourFast(0,0,255,x,y);
		}
	}

	cout << "Writing..." << endl;

	bm.WriteBitMap("T:zbm24out.iff24");

	cout << "Error: " << bm.GetErrorStr() << endl;
}


int main( int argc, char *argv[] )
{
	ReadTest( argc == 2 ? argv[1] : "PROGDIR:Basket.iff24" );
	WriteTest( argc == 2 ? argv[1] : "PROGDIR:Basket.iff24" );
	ZTest();

	return EXIT_SUCCESS;
}
