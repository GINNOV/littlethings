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

#include "Hex.h"

#define CROSS(x0,y0,x1,y1,x2,y2) ((x1-x0)*(y2-y0)-(x2-x0)*(y1-y0))

//----------------------------------------------------------------------
// CONSTRUCTOR: Hex::Hex
//----------------------------------------------------------------------
//
//  Description:
//
//    Creates a new hex.
//
//    Hexes are created with coordinate pairs that are laid out on a
//    grid as follows:
//
//        -x\__/  \__/  \__/  \__/+y  <-- 'hy' axis
//        __/-x\__/  \__/  \__/+y\__ 
//          \__/-x\__/  \__/+y\__/   
//        __/  \__/-x\__/+y\__/  \__ 
//          \__/  \__/00\__/  \__/   
//        __/  \__/-y\__/+x\__/  \__ 
//          \__/-y\__/  \__/+x\__/   
//        __/-y\__/  \__/  \__/+x\__ 
//        -y\  /  \  /  \  /  \  /+x  <-- 'hx' axis
//
//    The vertices are stored counter-clockwise as follows:
//
//          2---1
//         /     \ 
//        3       0
//         \     /
//          4---5
//
//    The center point of hex(0,0) is at cartesian coordinate (0,0).
//    The cartesian coordinate system is scaled such that all
//    centers and vertex coordinates lie on integral values to
//    eliminate precision loss during cross-product calculations.
//
//  Parameters:
//
//    x,y - Hex coordinates of the newly created hex.
//
//  Returns: N/A
//
//----------------------------------------------------------------------

Hex::Hex(int x, int y)
{
	// copy hex coordinate
	hx = x;
	hy = y;
	
	// calculate center point
	cx = (double)(hx + hy) * 3.0;
	cy = (double)(hy - hx) * 1.0;

	// calculate x-coordinates
	px[0] = cx + 2.0;
	px[1] = cx + 1.0;
	px[2] = cx - 1.0;
	px[3] = cx - 2.0;
	px[4] = cx - 1.0;
	px[5] = cx + 1.0;

	// calculate y-coordinates
	py[0] = cy;
	py[1] = cy + 1.0;
	py[2] = cy + 1.0;
	py[3] = cy;
	py[4] = cy - 1.0;
	py[5] = cy - 1.0;

	// flag hex as non-empty
	empty = 0;
}

//----------------------------------------------------------------------
// FUNCTION: Hex::IntersectsLine
//----------------------------------------------------------------------
//
//  Description:
//
//    Determines if a hex intersects a line by calculating cross
//    products between the original line and lines between (x0,y0)
//    and the vertices. The function returns zero if no vertex is
//    on the line and all vertecies are on one side of the line.
//    Otherwise the function returns non-zero.
//
//  Parameters:
//
//    x0,y0 - First coordinate.
//    x1,y1 - Second coordinate.
//
//  Returns:
//
//    Non-zero if the line intersects the hex.
//
//----------------------------------------------------------------------

int Hex::IntersectsLine(double x0, double y0, double x1, double y1)
{
	// calculate initial cross product
	double cross = CROSS(x0,y0,x1,y1,px[0],py[0]);

	if (cross > 0.0) // first cross product was positive
	{
		// check for negative cross product
		if (CROSS(x0,y0,x1,y1,px[1],py[1]) <= 0.0) return 1;
		if (CROSS(x0,y0,x1,y1,px[2],py[2]) <= 0.0) return 1;
		if (CROSS(x0,y0,x1,y1,px[3],py[3]) <= 0.0) return 1;
		if (CROSS(x0,y0,x1,y1,px[4],py[4]) <= 0.0) return 1;
		if (CROSS(x0,y0,x1,y1,px[5],py[5]) <= 0.0) return 1;

		// all cross producuts are positive
		return 0;
	}
	else if (cross < 0.0) // first cross product was negative
	{
		// check for positive cross product
		if (CROSS(x0,y0,x1,y1,px[1],py[1]) >= 0.0) return 1;
		if (CROSS(x0,y0,x1,y1,px[2],py[2]) >= 0.0) return 1;
		if (CROSS(x0,y0,x1,y1,px[3],py[3]) >= 0.0) return 1;
		if (CROSS(x0,y0,x1,y1,px[4],py[4]) >= 0.0) return 1;
		if (CROSS(x0,y0,x1,y1,px[5],py[5]) >= 0.0) return 1;

		// all cross producuts are positive
		return 0;
	}
	else return 1; // fist point was on the line
}

//----------------------------------------------------------------------
// FUNCTION: Hex::NeighborHex
//----------------------------------------------------------------------
//
//  Description:
//
//    Returns the neighboring hex in the given direction. Neighboring
//    hex directions are laid counter-clockwise as follows:
//
//            \__/          dir  pa  pb  dx  dy
//         \__/1 \__/
//        _/2 \__/0 \_       0    0   1   0  +1
//         \__/  \__/        1    1   2  -1  +1
//        _/3 \__/5 \_       2    2   3  -1   0
//         \__/4 \__/        3    3   4   0  -1
//         /  \__/  \        4    4   5  +1  -1
//            /  \           5    5   0  +1   0
//
//    Where 'dir' is the direction, 'pa' and 'pb' are the indexes
//    of the endpoints of the face seperating the hexes, and 'dx'
//    and 'dy' are the hex coordinate deltas.
//
//    Note that the index of the first endpoint of a face is equal
//    to the direction used to exit through that face.
//
//  Parameters:
//
//    dir - Direction as indicated in the table above.
//
//  Returns:
//
//    Hex representing the neighbor in the given direction.
//
//----------------------------------------------------------------------

Hex Hex::NeighborHex(int dir)
{
	int dx,dy;

	switch (dir % 6)
	{
	case 0: dx =  0; dy = +1; break;
	case 1: dx = -1; dy = +1; break;
	case 2: dx = -1; dy =  0; break;
	case 3: dx =  0; dy = -1; break;
	case 4: dx = +1; dy = -1; break;
	case 5: dx = +1; dy =  0; break;
	}

	return Hex(hx+dx,hy+dy);
}

//----------------------------------------------------------------------
// FUNCTION: Hex::HexRange
//----------------------------------------------------------------------
//
//  Description:
//
//    Calculates the range to another hex.
//
//  Parameters:
//
//    hex - Target hex for range calculations.
//
//  Returns:
//
//    Range in hexes to the given hex.
//
//----------------------------------------------------------------------

int Hex::HexRange(Hex hex)
{
	int dx = hex.hx - hx;
	int dy = hex.hy - hy;
	
	int sign_dx = 0;
	int sign_dy = 0;

	int abs_dx = 0;
	int abs_dy = 0;

	if (dx > 0) { sign_dx = +1; abs_dx = +dx; }
	if (dx < 0) { sign_dx = -1; abs_dx = -dx; }
	if (dy > 0) { sign_dy = +1; abs_dy = +dy; }
	if (dy < 0) { sign_dy = -1; abs_dy = -dy; }

	if (sign_dx != sign_dy)
		return (abs_dx > abs_dy) ? abs_dx : abs_dy;
	else return abs_dx + abs_dy;
}

//----------------------------------------------------------------------
// FUNCTION: Hex::NextHexes
//----------------------------------------------------------------------
//
//  Description:
//
//    Gets the next hex(es) touching the line connecting the centers
//    of hexes h0 and h1.
//
//  Parameters:
//
//    h0,h1       - Start and end hexes.
//    prev1,prev2 - Previous hexes.
//    next1,next2 - Storage for hex results.
//
//  Returns: N/A
//
//----------------------------------------------------------------------

void Hex::NextHexes(Hex h0, Hex h1,
	Hex prev1, Hex prev2, Hex& next1, Hex& next2)
{
	if (IsEmpty()) return;

	int range = HexRange(h1);
	if (range == 0) return;

	double x0 = h0.cx;
	double y0 = h0.cy;
	double x1 = h1.cx;
	double y1 = h1.cy;

	for (int i = 0; i < 6; i++)
	{
		Hex next = NeighborHex(i);

		if ((next.HexRange(h1) <= range) &&
			(next != next1) && (next != next2) &&
			(next != prev1) && (next != prev2))
		{
			double cross1,cross2;

			cross1 = CROSS(x0,y0,x1,y1,px[i],py[i]);
			cross2 = CROSS(x0,y0,x1,y1,px[(i+1)%6],py[(i+1)%6]);

			if (((cross1 >= 0.0) && (cross2 <= 0.0)) ||
				((cross1 <= 0.0) && (cross2 >= 0.0)))
			{
				if (next1.IsEmpty())
					next1 = next;
				else next2 = next;
			}
		}
	}
}
