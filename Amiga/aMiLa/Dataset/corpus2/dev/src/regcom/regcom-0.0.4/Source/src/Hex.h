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

#ifndef HEX_H
#define HEX_H

class Hex
{
public:
	
	int empty;

	int hx,hy;

	double cx,cy;

	double px[6];
	double py[6];

public:

	Hex() { empty = 1; }

	Hex(int x, int y);

	Hex NeighborHex(int dir);
	int HexRange(Hex hex);

	void NextHexes(Hex h0, Hex h1,
		Hex prev1, Hex prev2, Hex& next1, Hex& next2);
	
	int IntersectsLine(double x0, double y0, double x1, double y1);

	int IsEmpty() const { return empty; }
	void SetEmpty() { empty = 1; }

	int operator==(const Hex& hex) const
		{ return (!IsEmpty()) && (!hex.IsEmpty()) && (hx == hex.hx) && (hy == hex.hy); }

	int operator!=(const Hex& hex) const
		{ return (IsEmpty()) || (hex.IsEmpty()) || (hx != hex.hx) || (hy != hex.hy); }
};

#endif
