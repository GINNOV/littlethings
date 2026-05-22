//**********************************************************************
//
//  REGCOM: Regimental Command
//  Copyright (C) 1997-2001 Randi J. Relander
//	<rjrelander@users.sourceforge.net>
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public
//  License along with this program; if not, write to the Free
//  Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
//  MA 02111-1307, USA.
//  
//**********************************************************************

#include "Fractal.h"

#include <stdlib.h>

//----------------------------------------------------------------------
// FUNCTION: Fractal::Fractal
//----------------------------------------------------------------------

Fractal::Fractal(int width, int height, int scale)
{
	m_size = 1;
	m_scale = scale;

	int base = width;

	if (height > base) base = height;

	base -= 1;
	
	while (base)
	{
		base /= 2;
		m_size *= 2;
	}

	m_data = new unsigned char[(m_size+1)*(m_size+1)];

	Generate();
}

//----------------------------------------------------------------------
// FUNCTION: Fractal::~Fractal
//----------------------------------------------------------------------

Fractal::~Fractal()
{
	delete [] m_data;
}

//----------------------------------------------------------------------
// FUNCTION: Fractal::GetData
//----------------------------------------------------------------------

int Fractal::GetData(int x, int y)
{
	return m_data[ x + (m_size+1) * y ];
}

//----------------------------------------------------------------------
// FUNCTION: Fractal::SetData
//----------------------------------------------------------------------

void Fractal::SetData(int x, int y, int z)
{
	m_data[ x + (m_size+1) * y ] = z;
}

//----------------------------------------------------------------------
// FUNCTION: Fractal::Pass
//----------------------------------------------------------------------

void Fractal::Pass(int xstep, int ystep, int step)
{
	int x,y,z;
	int z1,z2;
	
	int range = step * m_scale;
	int shift = (range/2);

	int dx = xstep * (step/2);
	int dy = ystep * (step/2);

	int delta1 = (m_size+1) * dy;
	int delta2 = (m_size+1) * step;

	unsigned char* data = m_data + delta1;

	for (y = dy; y <= m_size; y += step) 
	{
		for (x = dx; x <= m_size; x += step)
		{
			//------------------------------------------
			// select two points
			//------------------------------------------
			
			if (rand()%2)
			{
				z1 = data[x - dx - delta1];
				z2 = data[x + dx + delta1];
			}
			else
			{
				z1 = data[x + dx - delta1];
				z2 = data[x - dx + delta1];
			}

			//------------------------------------------
			// average and randomize
			//------------------------------------------
	
			z = (z1+z2)/2 + (rand()%range) - shift;
			
			if (z < 0) z = 0;
			if (z > 255) z = 255;
		
			data[x] = z;
		}

		data += delta2;
	}
}

//----------------------------------------------------------------------
// FUNCTION: Fractal::Generate
//----------------------------------------------------------------------

void Fractal::Generate()
{
	//------------------------------------------
	// seed the corners
	//------------------------------------------
	
	SetData(0,0,rand()%256);
	SetData(m_size,0,rand()%256);
	SetData(0,m_size,rand()%256);
	SetData(m_size,m_size,rand()%256);

	//------------------------------------------
	// generate fractal
	//------------------------------------------
	
	for (int step = m_size; step > 1; step /= 2)
	{
		Pass(1,0,step);
		Pass(0,1,step);
		Pass(1,1,step);
	}
}
