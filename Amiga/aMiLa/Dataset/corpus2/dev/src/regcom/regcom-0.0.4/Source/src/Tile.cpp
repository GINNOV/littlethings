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

#include "Tile.h"
#include "Unit.h"

#include <stdlib.h>
#include <assert.h>

//----------------------------------------------------------------------
// FUNCTION: Tile::Tile
//----------------------------------------------------------------------

Tile::Tile()
{
	m_level = 0;
	m_depth = 0;
	m_trees = 0;

	m_unit_list = NULL;
}

//----------------------------------------------------------------------
// FUNCTION: Tile::~Tile
//----------------------------------------------------------------------

Tile::~Tile()
{
}

//----------------------------------------------------------------------
// FUNCTION: Tile::AddUnit
//----------------------------------------------------------------------

int Tile::AddUnit(Unit* unit)
{
	if (!unit) return -1;

	if (!m_unit_list)
	{
		m_unit_list = unit;
		unit->m_next = NULL;
		return 0;
	}

	Unit* prev = m_unit_list;
	Unit* next = prev->m_next;

	while (next)
	{
		prev = next;
		next = next->m_next;
	}

	prev->m_next = unit;
	unit->m_next = NULL;

	return 0;
}

//----------------------------------------------------------------------
// FUNCTION: Tile::RemoveUnit
//----------------------------------------------------------------------

int Tile::RemoveUnit(Unit* unit)
{
	if (!unit) return -1;
	if (!m_unit_list) return -1;

	if (unit == m_unit_list)
	{
		m_unit_list = unit->m_next;
		unit->m_next = NULL;
		return 0;
	}

	Unit* prev = m_unit_list;
	Unit* next = prev->m_next;

	while (next)
	{
		if (unit == next)
		{
			prev->m_next = unit->m_next;
			unit->m_next = NULL;
			return 0;
		}

		prev = next;
		next = next->m_next;
	}

	return -1;
}

