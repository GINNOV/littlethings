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

#include "Unit.h"
#include "Tile.h"
#include "Map.h"

#include <stdlib.h>

//----------------------------------------------------------------------
// FUNCTION: Unit::Unit
//----------------------------------------------------------------------

Unit::Unit()
{
	m_id = 0;
	m_map = NULL;
	m_xpos = 0;
	m_ypos = 0;
	m_next = NULL;
}

//----------------------------------------------------------------------
// FUNCTION: Unit::~Unit
//----------------------------------------------------------------------

Unit::~Unit()
{
}

//----------------------------------------------------------------------
// FUNCTION: Unit::PlaceOnMap
//----------------------------------------------------------------------

int Unit::PlaceOnMap(Map* map, int x, int y)
{
	if (!map) return -1;

	Tile* new_tile = map->GetTile(x,y);
	if (!new_tile) return -1;

	m_map = map;	

	m_xpos = x;
	m_ypos = y;

	new_tile->AddUnit(this);

	return 0;
}

//----------------------------------------------------------------------
// FUNCTION: Unit::RemoveFromMap
//----------------------------------------------------------------------

int Unit::RemoveFromMap()
{
	if (!m_map) return -1;

	Tile* old_tile = m_map->GetTile(m_xpos,m_ypos);
	if (!old_tile) return -1;

	old_tile->RemoveUnit(this);

	m_xpos = 0;
	m_ypos = 0;
	
	m_map = NULL;

	return 0;
}

//----------------------------------------------------------------------
// FUNCTION: Unit::MoveTo
//----------------------------------------------------------------------

int Unit::MoveTo(int x, int y)
{
	if (!m_map) return -1;

	Tile* old_tile = m_map->GetTile(m_xpos,m_ypos);
	if (!old_tile) return -1;

	Tile* new_tile = m_map->GetTile(x,y);
	if (!new_tile) return -1;

	old_tile->RemoveUnit(this);

	m_xpos = x;
	m_ypos = y;

	new_tile->AddUnit(this);

	return 0;
}
