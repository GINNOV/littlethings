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

#ifndef TILE_H
#define TILE_H

class Unit;

class Tile
{
private:
	
	signed char m_level;
	signed char m_depth;
	signed char m_trees;

	Unit* m_unit_list;

public:

	Tile();
	virtual ~Tile();

	void Clear()
	{
		m_level = 0;
		m_depth = 0;
		m_trees = 0;
	}

	void SetLevel(int level) { m_level = level; }
	void SetDepth(int depth) { m_depth = depth; }
	void SetTrees(int trees) { m_trees = trees; }

	bool IsClear() { return m_depth == 0; }
	bool IsWater() { return m_depth >= 1; }
	bool IsWoods() { return m_trees >= 1; }
	bool IsLight() { return m_trees == 1; }
	bool IsHeavy() { return m_trees == 2; }

	int GetLevel() { return m_level; }
	int GetDepth() { return m_depth; }
	int GetTrees() { return m_trees; }

	int AddUnit(Unit* unit);
	int RemoveUnit(Unit* unit);
};

#endif
