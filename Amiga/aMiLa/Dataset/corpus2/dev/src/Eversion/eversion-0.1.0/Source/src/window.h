#ifndef EVERSION__WINDOW_H
 #define EVERSION__WINDOW_H


// INCLUDES ///////////////////////////////////////////////////////////////////

#include "surface.h"
#include "math.h"

////////////////////////////////////////////////////////////////////////////////

namespace eversion {

// CLASSES ////////////////////////////////////////////////////////////////////

//Draws a SFFC style window
class window
{
protected:
	static const u32 FC_WinColors[2][5];

	point2D<s32> pos;
	point2D<u32> size;
	surface image;
	char *caption;
	bool showCaption, isVisible;

	virtual void makeWin();

public:
	window() { init(); }
	window(s32 x, s32 y, u32 w, u32 h) { move(x,y); resize(w,h); }
	window(const point2D<u32> &_pos, const point2D<u32> &_size) { move(_pos); resize(_size); }
	virtual ~window() { free(); }

	virtual void init() { caption=NULL; isVisible=showCaption=true; }
	virtual void free() { setCaption(NULL); }

	virtual void draw();
	virtual void setCaption(char *str, u16 lineLen=0);

	void move(s32 x, s32 y) { pos.x=x; pos.y=y; }
	void move(const point2D<u32> &_pos) { pos=_pos; }

	void resize(u32 w, u32 h) { size.x=w; size.y=h; makeWin(); }
	void resize(const point2D<u32> &_size) { size=_size; makeWin(); }
};


////////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////

#endif //EVERSION__WINDOW_H
