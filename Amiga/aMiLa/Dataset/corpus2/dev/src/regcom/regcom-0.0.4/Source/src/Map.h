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

#ifndef MAP_H
#define MAP_H

class Tile;
class Point;

class Map  
{
private:
	
	int m_width;
	int m_height;

	Tile* m_tile;

public:

	Map();
	virtual ~Map();
	
	void SetSize(int x, int y);

	int GetWidth() { return m_width; }
	int GetHeight() { return m_height; }
	
	void Clear();

	void FractalCreate(int maxlevel, int waterlevel);

	Tile* GetTile(int x, int y);

	Point ArrayToHex(Point p);
	Point HexToArray(Point p);

	int LineOfSight(int x0, int y0, int z0, int x1, int y1, int z1);
};

#endif
