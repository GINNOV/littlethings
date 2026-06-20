#ifndef EVERSION__LAYER_H
#define EVERSION__LAYER_H


// INCLUDES ///////////////////////////////////////////////////////////////////

#include <string.h>

#include "types.h"
#include "math.h"


////////////////////////////////////////////////////////////////////////////////

namespace eversion {

// CLASSES ////////////////////////////////////////////////////////////////////


template<class T>
class layer
{
protected:
	T *data;
	u32 width, height;
public:
	layer() { init(); }
	layer(u32 _width, u32 _height) { init(); create(_width,_height); }
	~layer() { free(); }

	void create(u32 _width, u32 _height)
	{ free(); width = _width; height = _height; data = new T[width*height]; clear(); }

	void init() { data = NULL; }
	void free() {  if(data) { delete [] data; data = NULL; } init(); }

	void clear(int c=0) { memset(data,c,sizeof(T)*width*height); }

	T get(u32 x, u32 y) { return data[ x+width*y ]; }
	void set(u32 x, u32 y, T value) { data[ x+width*y ] = value; }

	u32 getWidth() const { return width; }
	u32 getHeight() const { return height; }
};

///////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////

#endif //EVERSION__LAYER_H
