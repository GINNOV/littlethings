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

#include <stdlib.h>

#include "Map.h"
#include "Tile.h"
#include "Fractal.h"
#include "Point.h"

#define FLOOR2(x) ( ((x)>=0) ? ((x)>>1) : (((x)-1)/2) )
#define CEIL2(x)  ( ((x)>=0) ? (((x)+1)>>1) : ((x)/2) )

//----------------------------------------------------------------------
// CONSTRUCTOR: Map::Map
//----------------------------------------------------------------------
//
//  Description:
//
//    Creates an empty map. Initializes all member variables.
//    The map is left in an empty state.
//
//  Parameters: N/A
//
//  Returns: N/A
//
//----------------------------------------------------------------------

Map::Map()
{
	// clear width and height
	m_width = 0;
	m_height = 0;
	
	// clear tile pointer
	m_tile = NULL;
}

//----------------------------------------------------------------------
// DESTRUCTOR: Map::~Map
//----------------------------------------------------------------------
//
//  Description:
//
//    Destroys the map. Frees any memory allocated for the tiles.
//
//  Parameters: N/A
//
//  Returns: N/A
//
//----------------------------------------------------------------------

Map::~Map()
{
	// delete old array of tiles
	if (m_tile) delete [] m_tile;
}

//----------------------------------------------------------------------
// FUNCTION: Map::SetSize
//----------------------------------------------------------------------
//
//  Description:
//
//    Sets the map size. Frees any memory allocated for old tiles
//    and allocates memory for new tiles. If the requested width
//    and height are not valid, the map is left in an empty state.
//
//  Parameters:
//
//    width  - New map width.
//    height - New map height.
//
//  Returns: N/A
//
//----------------------------------------------------------------------

void Map::SetSize(int width, int height)
{
	// delete old array of tiles
	if (m_tile) delete [] m_tile;

	// validate width and height
	if ((width <= 0) || (height <= 0))
	{
		// clear width and height
		m_width = 0;
		m_height = 0;
		
		// clear tile pointer
		m_tile = NULL;
	}
	else // valid width and height
	{
		// set new width and height
		m_width = width;
		m_height = height;

		// create new array of tiles
		m_tile = new Tile[width*height];

		// clear new tile array
		Clear();
	}
}

//----------------------------------------------------------------------
// FUNCTION: Map::Clear
//----------------------------------------------------------------------
//
//  Description:
//
//    Clears the map. Clears all tiles on the map.
//
//  Parameters: N/A
//
//  Returns: N/A
//
//----------------------------------------------------------------------

void Map::Clear()
{
	// loop through tiles
	for (int n = 0; n < m_width*m_height; n++)
	{
		// clear the tile
		m_tile[n].Clear();
	}
}

//----------------------------------------------------------------------
// FUNCTION: Map::FractalCreate
//----------------------------------------------------------------------
//
//  Description:
//
//    Creates a random map using two fractals. The first fractal is
//    used as a tile height map and the second fractal is used as a
//    tree density map.
//
//  Parameters:
//
//    range  - Maximum difference between highest and lowest tiles.
//             Allows creation of maps with different vertical scales.
//  
//    offset - Amount that tiles are shifted downward. Negative tile
//             levels are treated as water so this value controls the
//             water level on the map.
//
//  Returns: N/A
//
//----------------------------------------------------------------------

void Map::FractalCreate(int range, int offset)
{
	// create tile level fractal
	Fractal tile_level(m_width,m_height,4);
	
	// create tree density fractal
	Fractal tree_density(m_width,m_height,16);

	// calculate fractal height scaling
	double scale = range / 256.0;

	// grab copy of tile pointer
	Tile* tile = m_tile;
	
	// loop through map rows
	for (int y = 0; y < m_height; y++)
	{
		// loop through map columns
		for (int x = 0; x < m_width; x++)
		{
			// get tile level
			int level = (int)(tile_level.GetData(x,y) * scale) - offset;

			// set tile level
			tile->SetLevel(level);
			
			// check if this tile is under water
			if (level < 0)
			{
				// set water depth
				tile->SetDepth(-level);

				// water tiles have no trees
				tile->SetTrees(0);
			}
			else // must be a land tile
			{
				// set water depth negative (to prevent swamps)
				tile->SetDepth(-1);

				// get tree density
				int density = tree_density.GetData(x,y);
				
				// set trees accordingly
				if (density > 224) // heavy woods
					tile->SetTrees(2);
				else if (density > 128) // light woods
					tile->SetTrees(1);
				else tile->SetTrees(0); // clear tile
			}
			
			// advance to next tile
			tile++;
		}
	}
}

//----------------------------------------------------------------------
// FUNCTION: Map::GetTile
//----------------------------------------------------------------------
//
//  Description:
//
//    Gets a pointer to the tile at the specified array coodinate.
//
//  Parameters:
//
//    x,y - Coordinates of the tile.
//
//  Returns:
//
//    Pointer to the spcified tile.
//
//----------------------------------------------------------------------

Tile* Map::GetTile(int x, int y)
{
	return &m_tile[x+m_width*y];
}

//----------------------------------------------------------------------
// FUNCTION: Map::ArrayToHex
//----------------------------------------------------------------------
//
//  Description:
//
//    Converts a point from array to hex coordinates.
//
//  Parameters:
//
//    p - Point containing array coodinates.
//
//  Returns:
//
//    Point containing hex coordinates.
//
//----------------------------------------------------------------------

Point Map::ArrayToHex(Point p)
{
	int hx = p.y + FLOOR2(p.x);
	int hy = p.y - CEIL2(p.x);
	p.x = hx;
	p.y = -hy;
	return p;
}

//----------------------------------------------------------------------
// FUNCTION: Map::HexToArray
//----------------------------------------------------------------------
//
//  Description:
//
//    Converst a point from hex to array coordinates.
//
//  Parameters:
//
//    p - Point containing hex coodinates.
//
//  Returns:
//
//    Point containing array coordinates.
//
//----------------------------------------------------------------------

Point Map::HexToArray(Point p)
{
	int hx = p.x;
	int hy = -p.y;
	p.x = hx - hy;
	p.y = hy + CEIL2(hx-hy);
	return p;
}

//----------------------------------------------------------------------
// FUNCTION: Map::LineOfSight
//----------------------------------------------------------------------
//
//  Description:
//
//    Determines if line of sight exists between two coordinates.
//
//  Parameters:
//
//    x0,y0,z0 - First coordinate.
//    x1,y1,z1 - Second coordinate.
//
//  Returns:
//
//    Returns non-zero if there is line of sight.
//
//----------------------------------------------------------------------

int Map::LineOfSight(int x0, int y0, int z0, int x1, int y1, int z1)
{
	return 1;
}

