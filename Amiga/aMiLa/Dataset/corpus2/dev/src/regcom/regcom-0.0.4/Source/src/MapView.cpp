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

#include "MapView.h"
#include "Surface.h"
#include "Map.h"
#include "Tile.h"
#include "Console.h"
#include "Point.h"
#include "Hex.h"

#include <stdlib.h>

#define ZOOM_LEVELS 3

typedef enum _TILEBASE
{
	TILEBASE_CLEAR			= 0,
	TILEBASE_WATER			= 8,
	TILEBASE_WOODS			= 16,
	TILEBASE_MARKERS		= 24,

	TILEBASE_UNIT1_BASE		= 32,
	TILEBASE_UNIT1_BODY		= 38,
	TILEBASE_UNIT2_BASE		= 44,
	TILEBASE_UNIT2_BODY		= 50

} TILEBASE;

typedef enum _TILECOUNT
{
	TILECOUNT_CLEAR			= 8,
	TILECOUNT_WATER			= 8,
	TILECOUNT_WOODS			= 8,
	TILECOUNT_MARKERS		= 8,

	TILECOUNT_UNIT1_BASE	= 6,
	TILECOUNT_UNIT1_BODY	= 6,
	TILECOUNT_UNIT2_BASE	= 6,
	TILECOUNT_UNIT2_BODY	= 6

} TILECOUNT;

typedef enum _TILEROW
{
	TILEROW_CLEAR			= 0,
	TILEROW_CLEARGRID		= 1,
	TILEROW_WATER			= 2,
	TILEROW_WATERGRID		= 3,
	TILEROW_WOODS			= 4,
	TILEROW_MARKERS			= 5,

	TILEROW_UNIT1_BASE		= 0,
	TILEROW_UNIT1_BODY		= 1,
	TILEROW_UNIT2_BASE		= 2,
	TILEROW_UNIT2_BODY		= 3

} TILEROW;

static struct
{
	const char* m_name;
	int m_width;
	int m_height;
	int m_deltax;
	int m_deltay;
	int m_shiftx;
	int m_shifty;

	const char* m_unit_name;
	int m_unit_width;
	int m_unit_height;

}
TileInfo[ZOOM_LEVELS] =
{
	{"Tile16.bmp",19,17,14,16,0, 8, "Unit24.bmp",18,24},
	{"Tile28.bmp",33,29,25,28,0,14, "Unit42.bmp",32,42},
	{"Tile48.bmp",57,49,44,48,0,24, "Unit72.bmp",56,72}
};

//----------------------------------------------------------------------
// FUNCTION: MapView::MapView
//----------------------------------------------------------------------

MapView::MapView()
{
	int n;
	
	m_zoom_level = 0;
	m_show_grid = false;

	m_map = NULL;
	m_console = NULL;

	for (n = 0; n < MAPVIEW_LAYERS; n++)
		m_data[n] = NULL;

	m_data_width = 0;
	m_data_height = 0;

	m_image_width = 0;
	m_image_height = 0;

	for (n = 0; n < MAPVIEW_MAXTILE; n++)
		m_tile[n] = NULL;

	m_dragging = 0;

	m_drag_x0 = 0;
	m_drag_y0 = 0;
	m_drag_x1 = 0;
	m_drag_y1 = 0;

	m_debug_rects = 0;

	LoadTiles();
}

//----------------------------------------------------------------------
// FUNCTION: MapView::~MapView
//----------------------------------------------------------------------

MapView::~MapView()
{
	SetDataSize(0,0);
	UnloadTiles();
}

//----------------------------------------------------------------------
// FUNCTION: MapView::UnloadTiles
//----------------------------------------------------------------------

void MapView::UnloadTiles()
{
	for (int n = 0; n < MAPVIEW_MAXTILE; n++)
	{
		if (m_tile[n]) delete m_tile[n];
		m_tile[n] = NULL;
	}
}

//----------------------------------------------------------------------
// FUNCTION: MapView::LoadTile
//----------------------------------------------------------------------

void MapView::LoadTile(int n, Surface* tiles, int x, int y)
{
	int w = TileInfo[m_zoom_level].m_width;
	int h = TileInfo[m_zoom_level].m_height;

	Rect src(x*w,y*h,w,h);

	if (m_tile[n]) delete m_tile[n];
	
	m_tile[n] = new Surface;
	
	m_tile[n]->Create(w,h);
	m_tile[n]->DisplayFormat();
	m_tile[n]->SetColorKey(255,0,255);
		
	tiles->Blit(m_tile[n],&src,0,0);
}

//----------------------------------------------------------------------
// FUNCTION: MapView::LoadUnitTile
//----------------------------------------------------------------------

void MapView::LoadUnitTile(int n, Surface* tiles, int x, int y)
{
	int w = TileInfo[m_zoom_level].m_unit_width;
	int h = TileInfo[m_zoom_level].m_unit_height;

	Rect src(x*w,y*h,w,h);

	if (m_tile[n]) delete m_tile[n];
	
	m_tile[n] = new Surface;
	
	m_tile[n]->Create(w,h);
	m_tile[n]->DisplayFormat();
	m_tile[n]->SetColorKey(255,0,255);
		
	tiles->Blit(m_tile[n],&src,0,0);
}

//----------------------------------------------------------------------
// FUNCTION: MapView::LoadTiles
//----------------------------------------------------------------------

void MapView::LoadTiles()
{
	int x,y;

	UnloadTiles();

	Surface tiles;
	
	tiles.Load(TileInfo[m_zoom_level].m_name);

	// load clear tiles

	if (m_show_grid)
		y = TILEROW_CLEARGRID;
	else y = TILEROW_CLEAR;
	
	for (x = 0; x < TILECOUNT_CLEAR; x++)
		LoadTile(TILEBASE_CLEAR+x,&tiles,x,y);

	// load water tiles

	if (m_show_grid)
		y = TILEROW_WATERGRID;
	else y = TILEROW_WATER;

	for (x = 0; x < TILECOUNT_WATER; x++)
		LoadTile(TILEBASE_WATER+x,&tiles,x,y);

	// load woods tiles

	y = TILEROW_WOODS;

	for (x = 0; x < TILECOUNT_WOODS; x++)
		LoadTile(TILEBASE_WOODS+x,&tiles,x,y);

	// load marker tiles

	y = TILEROW_MARKERS;

	for (x = 0; x < TILECOUNT_MARKERS; x++)
		LoadTile(TILEBASE_MARKERS+x,&tiles,x,y);

	// load unit tiles

	tiles.Load(TileInfo[m_zoom_level].m_unit_name);

	y = TILEROW_UNIT1_BASE;

	for (x = 0; x < TILECOUNT_UNIT1_BASE; x++)
		LoadUnitTile(TILEBASE_UNIT1_BASE+x,&tiles,x,y);

	y = TILEROW_UNIT1_BODY;

	for (x = 0; x < TILECOUNT_UNIT1_BODY; x++)
		LoadUnitTile(TILEBASE_UNIT1_BODY+x,&tiles,x,y);

	y = TILEROW_UNIT2_BASE;

	for (x = 0; x < TILECOUNT_UNIT2_BASE; x++)
		LoadUnitTile(TILEBASE_UNIT2_BASE+x,&tiles,x,y);

	y = TILEROW_UNIT2_BODY;

	for (x = 0; x < TILECOUNT_UNIT2_BODY; x++)
		LoadUnitTile(TILEBASE_UNIT2_BODY+x,&tiles,x,y);
}

//----------------------------------------------------------------------
// FUNCTION: MapView::SetZoomLevel
//----------------------------------------------------------------------

void MapView::SetZoomLevel(int n)
{
	if (n == m_zoom_level) return;
	if (n < 0) n = 0;
	if (n >= ZOOM_LEVELS) n = ZOOM_LEVELS-1;

	Point center = GetCenter();

	float w1 = (float)GetImageWidth();
	float h1 = (float)GetImageHeight();

	m_zoom_level = n;
	LoadTiles();
	ImageSizeChanged();

	float w2 = (float)GetImageWidth();
	float h2 = (float)GetImageHeight();

	center.x = (int)(center.x * w2 / w1 + 0.5);
	center.y = (int)(center.y * h2 / h1 + 0.5);

	SetCenter(center);

	Refresh();
}

//----------------------------------------------------------------------
// FUNCTION: MapView::ZoomIn
//----------------------------------------------------------------------

void MapView::ZoomIn()
{
	SetZoomLevel(m_zoom_level+1);
}

//----------------------------------------------------------------------
// FUNCTION: MapView::ZoomOut
//----------------------------------------------------------------------

void MapView::ZoomOut()
{
	SetZoomLevel(m_zoom_level-1);
}

//----------------------------------------------------------------------
// FUNCTION: MapView::GetTileIndex
//----------------------------------------------------------------------

int MapView::GetTileIndex(int x, int y, int z)
{
	if (m_data[z])
	{
		long index =
			x + y * m_data_width;
	
		return m_data[z][index];
	}
	else return 0;
}

//----------------------------------------------------------------------
// FUNCTION: MapView::DrawTile
//----------------------------------------------------------------------

void MapView::DrawTile(int n,
	int x, int y, Surface* surface, Rect clip)
{
	if (n >= MAPVIEW_MAXTILE) return;

	int tw = TileInfo[m_zoom_level].m_width;
	int th = TileInfo[m_zoom_level].m_height;

	int w = m_tile[n]->Width();
	int h = m_tile[n]->Height();

	Rect src(0, 0, w, h);

	Rect dst(x - (tw>>1), y + (th>>1) - h, w, h);

	if (dst.x + dst.w < clip.x) return;
	if (dst.y + dst.h < clip.y) return;

	if (dst.x >= clip.x + clip.w) return;
	if (dst.y >= clip.y + clip.h) return;

	if (dst.x < clip.x)
	{
		int delta = clip.x - dst.x;
		
		dst.x += delta;
		dst.w -= delta;
		src.x += delta;
		src.w -= delta;
	}

	if ((dst.x + dst.w) > (clip.x + clip.w))
	{
		int delta =	(dst.x + dst.w) - (clip.x + clip.w);
		
		dst.w -= delta;
		src.w -= delta;
	}

	if (dst.y < clip.y)
	{
		int delta = clip.y - dst.y;
		
		dst.y += delta;
		dst.h -= delta;
		src.y += delta;
		src.h -= delta;
	}

	if ((dst.y + dst.h) > (clip.y + clip.h))
	{
		int delta = (dst.y + dst.h) - (clip.y + clip.h);
		
		dst.h -= delta;
		src.h -= delta;
	}

	m_tile[n]->LowerBlit(surface,&src,dst.x,dst.y);
}

//----------------------------------------------------------------------
// FUNCTION: MapView::DrawLayer
//----------------------------------------------------------------------

void MapView::DrawLayer(int n,
	Rect rect, Surface* surface, int x, int y)
{
	int x1 = rect.x / TileInfo[m_zoom_level].m_deltax;
	int y1 = rect.y / TileInfo[m_zoom_level].m_deltay;
	
	int x2 = (rect.x + rect.w) / TileInfo[m_zoom_level].m_deltax + 1;
	int y2 = (rect.y + rect.h) / TileInfo[m_zoom_level].m_deltay + 1;

	Rect clip(x,y,rect.w,rect.h);

	for (int ty = y1; ty <= y2; ty++)
	{
		for (int tx = x1; tx <= x2; tx++)
		{
			int sx = tx * TileInfo[m_zoom_level].m_deltax - rect.x + x;
			int sy = ty * TileInfo[m_zoom_level].m_deltay - rect.y + y;

			if ((tx & 1) == 1)
				sy -= TileInfo[m_zoom_level].m_shifty;

			if ((ty & 1) == 1)
				sx -= TileInfo[m_zoom_level].m_shiftx;

			DrawTile(GetTileIndex(tx,ty,n),sx,sy,surface,clip);
		}
	}

	if (m_debug_rects)
	{
		Rect a(x,y,1,rect.h);
		Rect b(x,y,rect.w,1);
		Rect c(x+rect.w-1,y,1,rect.h);
		Rect d(x,y+rect.h-1,rect.w,1);

		surface->FillRect(&a,255,255,255);
		surface->FillRect(&b,255,255,255);
		surface->FillRect(&c,255,255,255);
		surface->FillRect(&d,255,255,255);
	}
}

//----------------------------------------------------------------------
// FUNCTION: MapView::ClipMargins
//----------------------------------------------------------------------

void MapView::ClipMargins(
	Rect& rect, Surface* surface, int& x, int& y)
{
	//------------------------------------------
	// left margin
	//------------------------------------------
	
	if (rect.x < 0)
	{
		int delta = -rect.x;
		Rect a(x,y,delta,rect.h);
		surface->FillRect(&a,0,0,0);
		rect.x += delta;
		rect.w -= delta;
		x += delta;
	}

	//------------------------------------------
	// right margin
	//------------------------------------------
	
	if (rect.x + rect.w > m_image_width)
	{
		int delta = (rect.x + rect.w) - m_image_width;
		Rect a(x+rect.w-delta,y,delta,rect.h);
		surface->FillRect(&a,0,0,0);
		rect.w -= delta;
	}

	//------------------------------------------
	// top margin
	//------------------------------------------
	
	if (rect.y < 0)
	{
		int delta = -rect.y;
		Rect a(x,y,rect.w,delta);
		surface->FillRect(&a,0,0,0);
		rect.y += delta;
		rect.h -= delta;
		y += delta;
	}

	//------------------------------------------
	// bottom margin
	//------------------------------------------
	
	if (rect.y + rect.h > m_image_height)
	{
		int delta = (rect.y + rect.h) - m_image_height;
		Rect a(x,y+rect.h-delta,rect.w,delta);
		surface->FillRect(&a,0,0,0);
		rect.h -= delta;
	}
}

//----------------------------------------------------------------------
// FUNCTION: MapView::DrawImage
//----------------------------------------------------------------------

void MapView::DrawImage(
	Rect rect, Surface* surface, int x, int y)
{
	ClipMargins(rect,surface,x,y);

	if ((rect.w <= 0) || (rect.h <= 0)) return;
	
	for (int n = 0; n < MAPVIEW_LAYERS; n++)
		DrawLayer(n,rect,surface,x,y);
}

//----------------------------------------------------------------------
// FUNCTION: MapView::SetDataSize
//----------------------------------------------------------------------

void MapView::SetDataSize(int x, int y)
{
	int n;

	//------------------------------------------
	// delete old data
	//------------------------------------------

	for (n = 0; n < MAPVIEW_LAYERS; n++)
		if (m_data[n]) delete [] m_data[n];

	if ((x <= 0) || (y <= 0))
	{
		for (n = 0; n < MAPVIEW_LAYERS; n++)
			m_data[n] = NULL;

		m_data_width = 0;
		m_data_height = 0;

		return;
	}

	//------------------------------------------
	// create new data
	//------------------------------------------

	long size = x * y;

	for (n = 0; n < MAPVIEW_LAYERS; n++)
		m_data[n] = new unsigned char[size];

	m_data_width = x;
	m_data_height = y;

	ImageSizeChanged();
}

//----------------------------------------------------------------------
// FUNCTION: MapView::ScanMap
//----------------------------------------------------------------------

void MapView::ScanMap()
{
	int n;

	SetDataSize(m_map->GetWidth(),m_map->GetHeight());

	unsigned char* base    = m_data[0];
	unsigned char* fringe  = m_data[1];
	unsigned char* object1 = m_data[2];
	unsigned char* object2 = m_data[3];

	long index = 0;

	for (int y = 0; y < m_data_height; y++)
	{
		for (int x = 0; x < m_data_width; x++)
		{
			for (n = 0; n < MAPVIEW_LAYERS; n++)
				m_data[n][index] = 255;

			Tile* tile = m_map->GetTile(x,y);
			
			//------------------------------------------
			// set base tile
			//------------------------------------------
			
			if (tile->IsWater())
			{
				int depth = tile->GetDepth() - 1;
				
				if (depth < 0) depth = 0;
				if (depth > 7) depth = 7;

				base[index] = 8 + depth;
			}
			else
			{
				int level = tile->GetLevel();
				
				if (level < 0) level = 0;
				if (level > 7) level = 7;

				base[index] = level;
			}
			
			//------------------------------------------
			// set fringe tile
			//------------------------------------------
			
			if (tile->IsWoods())
			{
				if (tile->IsHeavy())
					fringe[index] = 20 + rand()%4;
				else fringe[index] = 16 + rand()%4;
			}

			//------------------------------------------
			// set object tile
			//------------------------------------------
/*			
			if (!tile->IsWater())
			{
				switch (rand()%200)
				{
				case 0:
					{
						int n1 = rand()%6;
						int n2 = n1 + (rand()%3) - 1;
						if (n2 < 0) n2 += 6;
						if (n2 >= 6) n2 -= 6;
						object1[index] = TILEBASE_UNIT1_BASE + n1;
						object2[index] = TILEBASE_UNIT1_BODY + n2;
						break;
					}
				case 1:
					{
						int n1 = rand()%6;
						int n2 = n1 + (rand()%3) - 1;
						if (n2 < 0) n2 += 6;
						if (n2 >= 6) n2 -= 6;
						object1[index] = TILEBASE_UNIT2_BASE + n1;
						object2[index] = TILEBASE_UNIT2_BODY + n2;
						break;
					}
				}
			}
*/
			index++;
		}
	}

	Refresh();
}

//----------------------------------------------------------------------
// FUNCTION: MapView::ToggleGrid
//----------------------------------------------------------------------

void MapView::ToggleGrid()
{
	m_show_grid = !m_show_grid;
	LoadTiles();
	Refresh();
}

//----------------------------------------------------------------------
// FUNCTION: MapView::ImageSizeChanged
//----------------------------------------------------------------------

void MapView::ImageSizeChanged()
{
	m_image_width = (m_data_width-2) * TileInfo[m_zoom_level].m_deltax + 
		TileInfo[m_zoom_level].m_deltax;

	m_image_height = (m_data_height-2) * TileInfo[m_zoom_level].m_deltay + 
		(TileInfo[m_zoom_level].m_deltay >> 1);
}

//----------------------------------------------------------------------
// FUNCTION: MapView::ViewportChanged
//----------------------------------------------------------------------

void MapView::ViewportChanged()
{
	int x = (int)((float)GetViewport().x /
		(float)TileInfo[m_zoom_level].m_deltax + 0.5);
	
	int y = (int)((float)GetViewport().y /
		(float)TileInfo[m_zoom_level].m_deltay + 0.5);
	
	int w = (int)((float)GetViewport().w /
		(float)TileInfo[m_zoom_level].m_deltax + 0.5);

	int h = (int)((float)GetViewport().h /
		(float)TileInfo[m_zoom_level].m_deltay + 0.5);

	if (m_console)
		m_console->SetRadarCursor(Rect(x,y,w,h));
}

//----------------------------------------------------------------------
// FUNCTION: MapView::WarpToTile
//----------------------------------------------------------------------

void MapView::WarpToTile(Point point)
{
	point.x = point.x * TileInfo[m_zoom_level].m_deltax;
	point.y = point.y * TileInfo[m_zoom_level].m_deltay;

	SetCorner(point);

	ViewportChanged();
}

//----------------------------------------------------------------------
// FUNCTION: MapView::TileFromPoint
//----------------------------------------------------------------------

Point MapView::TileFromPoint(Point point)
{
	int x = GetViewport().x + point.x +
		TileInfo[m_zoom_level].m_deltax/2;
	
	int y = GetViewport().y + point.y +
		TileInfo[m_zoom_level].m_deltay;

	x /= TileInfo[m_zoom_level].m_deltax;

	if ((x&1)==0) y -= TileInfo[m_zoom_level].m_shifty;

	y /= TileInfo[m_zoom_level].m_deltay;

	return Point(x,y);
}

//----------------------------------------------------------------------
// FUNCTION: MapView::OnMouseMove
//----------------------------------------------------------------------

void MapView::OnMouseMove(Point point)
{
	Point tile = TileFromPoint(point);

	if (!m_dragging)
	{
		char buffer[16];
		sprintf(buffer,"Hex %03d.%03d",tile.x,tile.y);
		m_console->SetStatus(buffer);
	}
	else
	{
		if ((m_drag_x1 == tile.x) && (m_drag_y1 == tile.y))
			return;

		m_drag_x1 = tile.x;
		m_drag_y1 = tile.y;

		MarkLOS(m_drag_x0,m_drag_y0,m_drag_x1,m_drag_y1);

		Point p0 = m_map->ArrayToHex(Point(m_drag_x0,m_drag_y0));
		Point p1 = m_map->ArrayToHex(Point(m_drag_x1,m_drag_y1));

		Hex h0(p0.x,p0.y);
		Hex h1(p1.x,p1.y);

		char buffer[16];
		sprintf(buffer,"Range %03d",h0.HexRange(h1));
		m_console->SetStatus(buffer);
	}
}

//----------------------------------------------------------------------
// FUNCTION: MapView::OnMouseDown
//----------------------------------------------------------------------

void MapView::OnMouseDown(int n, Point point)
{
	if (n != 1) return;
	
	Point tile = TileFromPoint(point);

	m_dragging = 1;
	m_drag_x0 = tile.x;
	m_drag_y0 = tile.y;
	m_drag_x1 = tile.x;
	m_drag_y1 = tile.y;

	MarkLOS(m_drag_x0,m_drag_y0,m_drag_x1,m_drag_y1);

	Point a = ConvertToScreen(Point(1,1));
	Point b = ConvertToScreen(Point(Width()-2,Height()-2));

	CaptureMouse(Rect(a,b));
}

//----------------------------------------------------------------------
// FUNCTION: MapView::OnMouseUp
//----------------------------------------------------------------------

void MapView::OnMouseUp(int n, Point point)
{
	if (n != 1) return;
	
	m_dragging = 0;
	ClearLOS();
	ReleaseMouse();
}

//----------------------------------------------------------------------
// FUNCTION: MapView::RefreshTile
//----------------------------------------------------------------------

void MapView::RefreshTile(int x, int y)
{
	int sx = x * TileInfo[m_zoom_level].m_deltax;
	int sy = y * TileInfo[m_zoom_level].m_deltay;

	if ((x & 1) == 1)
		sy -= TileInfo[m_zoom_level].m_shifty;

	if ((y & 1) == 1)
		sx -= TileInfo[m_zoom_level].m_shiftx;

	x = sx - TileInfo[m_zoom_level].m_deltax;
	y = sy - TileInfo[m_zoom_level].m_deltay;
	
	int w = 2 * TileInfo[m_zoom_level].m_deltax;
	int h = 2 * TileInfo[m_zoom_level].m_deltay;

	Rect rect = Rect(x,y,w,h);

	UpdateRect(rect);
}

//----------------------------------------------------------------------
// FUNCTION: MapView::ClearLOS
//----------------------------------------------------------------------

void MapView::ClearLOS()
{
	long index = 0;

	for (int y = 0; y < m_data_height; y++)
	{
		for (int x = 0; x < m_data_width; x++)
		{
			if (m_data[MAPVIEW_LOSLAYER][index] != 255)
			{
				m_data[MAPVIEW_LOSLAYER][index] = 255;
				RefreshTile(x,y);
			}
			index++;
		}
	}
}

//----------------------------------------------------------------------
// FUNCTION: MapView::MarkLOS
//----------------------------------------------------------------------

void MapView::MarkLOS(int x0, int y0, int x1, int y1)
{
	Hex prev1,prev2;
	Hex next1,next2;
	Hex cur1,cur2;

	Point p0(x0,y0);
	Point p1(x1,y1);
	
	p0 = m_map->ArrayToHex(p0);
	p1 = m_map->ArrayToHex(p1);

	Hex h0(p0.x,p0.y);
	Hex h1(p1.x,p1.y);

	cur1 = h0;
	cur2.SetEmpty();

	prev1.SetEmpty();
	prev2.SetEmpty();
	
	while (1)
	{
		if (!cur1.IsEmpty())
		{
			Point p(cur1.hx,cur1.hy);
			p = m_map->HexToArray(p);
			m_data[MAPVIEW_LOSLAYER][p.x + p.y * m_data_width] = 254;
		}

		if (!cur2.IsEmpty())
		{
			Point p(cur2.hx,cur2.hy);
			p = m_map->HexToArray(p);
			m_data[MAPVIEW_LOSLAYER][p.x + p.y * m_data_width] = 254;
		}

		if (cur1 == h1) break;
		if (cur1.IsEmpty() && cur2.IsEmpty()) break;

		next1.SetEmpty();
		next2.SetEmpty();
		
		cur1.NextHexes(h0,h1,prev1,prev2,next1,next2);
		cur2.NextHexes(h0,h1,prev1,prev2,next1,next2);
		
		prev1 = cur1; prev2 = cur2;
		cur1 = next1; cur2 = next2;
	}

	long index = 0;

	for (int y = 0; y < m_data_height; y++)
	{
		for (int x = 0; x < m_data_width; x++)
		{
			if (m_data[MAPVIEW_LOSLAYER][index] != 255)
			{
				if (m_data[MAPVIEW_LOSLAYER][index] == 254)
					m_data[MAPVIEW_LOSLAYER][index] = 24;
				else m_data[MAPVIEW_LOSLAYER][index] = 255;

				RefreshTile(x,y);
			}
			index++;
		}
	}
}

