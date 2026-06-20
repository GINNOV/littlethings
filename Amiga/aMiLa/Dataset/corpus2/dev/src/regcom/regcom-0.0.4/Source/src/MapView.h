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

#ifndef MAPVIEW_H
#define MAPVIEW_H

#include "ScrollView.h"

class Surface;
class Rect;
class Map;
class Console;

#define MAPVIEW_MAXTILE 56
#define MAPVIEW_LAYERS 5
#define MAPVIEW_LOSLAYER 4

class MapView : public ScrollView
{
private:

	int m_zoom_level;

	int m_show_grid;

	Map* m_map;
	Console* m_console;

	unsigned char* m_data[MAPVIEW_LAYERS];

	int m_data_width;
	int m_data_height;

	int m_image_width;
	int m_image_height;

	Surface* m_tile[MAPVIEW_MAXTILE];

	int m_dragging;
	int m_drag_x0;
	int m_drag_y0;
	int m_drag_x1;
	int m_drag_y1;

	int m_debug_rects;

protected:

	void SetDataSize(int x, int y);

	void UnloadTiles();
	void LoadTiles();
	void LoadTile(int n, Surface* tiles, int x, int y);
	void LoadUnitTile(int n, Surface* tiles, int x, int y);
	void RefreshTile(int x, int y);

	void SetTileIndex(int x, int y, int z, int n);

	int GetTileIndex(int x, int y, int z);

	void DrawTile(int n, int x, int y, Surface* surface, Rect clip);
	void DrawLayer(int n, Rect rect, Surface* surface, int x, int y);

	void ClipMargins(Rect& rect, Surface* surface, int& x, int& y);

	virtual void DrawImage(Rect rect, Surface* surface, int x, int y);

	virtual void ViewportChanged();

	void ImageSizeChanged();

	virtual int GetImageWidth() { return m_image_width; }
	virtual int GetImageHeight() { return m_image_height; }

	void SetZoomLevel(int n);

public:

	MapView();
	virtual ~MapView();

	void SetMap(Map* map) { m_map = map; }
	void SetConsole(Console* console) { m_console = console; }

	void ScanMap();
	void ZoomIn();
	void ZoomOut();
	void ToggleGrid();

	void WarpToTile(Point point);
	
	Point TileFromPoint(Point point);

	virtual void OnMouseMove(Point point);
	virtual void OnMouseDown(int n, Point point);
	virtual void OnMouseUp(int n, Point point);

	void ClearLOS();
	void MarkLOS(int x0, int y0, int x1, int y1);
};

#endif
