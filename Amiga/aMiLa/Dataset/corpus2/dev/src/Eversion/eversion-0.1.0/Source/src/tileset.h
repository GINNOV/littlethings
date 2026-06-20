#ifndef EVERSION__TILESET_H
#define EVERSION__TILESET_H


// INCLUDES ///////////////////////////////////////////////////////////////////

#include "surface.h"

////////////////////////////////////////////////////////////////////////////////

namespace eversion {

// CLASSES ////////////////////////////////////////////////////////////////////

class tileset : public surface
{
protected:
	s32 count;			//count of tiles
	s32 width,height;	//dimensions of a tile

	virtual void init();
	virtual void free();

public:
	//ctor
	tileset() { init(); }
	tileset(char *filename, u32 width, u32 height, u32 count=0)	{ init(); load(filename,width,height,count); }
	//tileset(SDL_Surface *_image) { init(); image = _image; }
	//cctor
	//tileset(tileset& src) { src = *this; }
	//dtor
	virtual ~tileset() { free(); }

	void draw(s32 index, s32 x, s32 y, SDL_Surface *dst=NULL);
	void draw(s32 index, SDL_Rect rectDest, SDL_Surface *dst=NULL);

	virtual bool load(char *filename, s32 _width, s32 _height, s32 _count = 0);

	//get/setMember
	s32 getCount() { return count; }
	virtual s32 getWidth() { return width; }
	virtual s32 getHeight() { return height; }

};

///////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////

#endif //EVERSION__TILESET_H
