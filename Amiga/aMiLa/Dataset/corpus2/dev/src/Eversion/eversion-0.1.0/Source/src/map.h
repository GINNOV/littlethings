#ifndef EVERSION__MAP_H
#define EVERSION__MAP_H


// INCLUDES ///////////////////////////////////////////////////////////////////

#include <vector>

#include "layer.h"
#include "entity.h"
#include "common.h"
#include "tileset.h"


////////////////////////////////////////////////////////////////////////////////

namespace eversion {

// CLASSES ////////////////////////////////////////////////////////////////////

typedef u16 mapdata_t;

class map
{
protected:
	//layer<mapdata_t> *layerMap;		// layerMap[]: map data, obstruction, map events
	std::vector< layer<mapdata_t> > layerMap;
	layer<bool> layerObstruction;
	layer<bool> layerEvent;	// can be as same type with eventIndex, 0 means no-event...
	layer<bool> layerMov;
	u32 width,height,p_width,p_height;
	//u32 layerCount;

	surface flashTile;
	tileset thetileset;
	char tilesetFile[256];

	void create(u32 _width, u32 _height, size_t layerCount);

	void init() { tilesetFile[0]='\0'; p_width=p_height=width=height=/*layerCount=*/0; }

public:
	map()  { init(); }
	map(u32 width, u32 height, u32 _layerCount) { create(width, height,_layerCount); }
	~map() { free(); }

	void free()
	{ layerMap.clear(); init(); }

	mapdata_t get(u32 layer, u32 x, u32 y) { return layerMap[layer].get(x,y); }
	void set(u32 layer, u32 x, u32 y, mapdata_t value) { layerMap[layer].set(x,y,value); }

	bool thereObstruction(u32 x, u32 y) { return layerObstruction.get(x,y); }
	bool thereEvent(u32 x, u32 y) { return layerEvent.get(x,y); }

	void updateMovLayer(entity *focus);
	void setFlashAlpha(u8 alpha) { flashTile.setAlpha(alpha); }

	u32 getWidth() { return width; }
	u32 getHeight() { return height; }
	u32 getP_Width() { return p_width; }
	u32 getP_Height() { return p_height; }

	s32 getTileWidth() { return thetileset.getWidth(); }
	s32 getTileHeight() { return thetileset.getHeight(); }

	bool load(char *filename);
	//bool draw(point2D<u32> p, rect<u32> scene);
	bool draw(const point2D<s32> &p, const ::SDL_Rect &scene);

	void normalize(point2D<s32> &p);

};

///////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////

#endif //EVERSION__MAP_H
