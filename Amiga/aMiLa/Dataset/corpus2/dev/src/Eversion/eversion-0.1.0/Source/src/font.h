#ifndef EVERSION__FONT_H
#define EVERSION__FONT_H


// INCLUDES ///////////////////////////////////////////////////////////////////

#include "tileset.h"
#include "types.h"


////////////////////////////////////////////////////////////////////////////////

namespace eversion {

// CLASSES ////////////////////////////////////////////////////////////////////

// note: unicode font support?

class font
{
	enum radix { radix_default=0, radix_2=2, radix_8=8, radix_10=10, radix_16=16 };

private:
	tileset graphic;

	u8 first,last;	// the 1st and last char of the charset
	s32 x,y;		// position of text cursor (not in pixels, instead char_size)

	bool keepCursor;
	radix defaultRadix;

public:
	font() { first=last=0; keepCursor = true; defaultRadix = radix_10; }
	// if first omitted, starts at space, if last omitted, loads all charset
	bool load(char *graphicFile, s32 width, s32 height, u8 _first='\x20', u8 _last='\x7F'); // default interval: [32-127]

	void write(char chr, SDL_Surface *dst=NULL);
	//void write(u8 chr) { write((char)chr); }
	void write(char *str, SDL_Surface *dst=NULL);
	//void write(u8 *str) { write((char*)str); }
	void write(s32 value, radix _radix = radix_default, SDL_Surface *dst=NULL);
	//void write(float value);

	template<typename X>
	font& operator<<(X param)
	{ bool _keepCursor = keepCursor; keepCursor = false; write(param); keepCursor = _keepCursor; return *this; }

	// member access
	void gotoXY(s32 _x, s32 _y) { x=_x; y=_y; }
	void setX(s32 _x) { x=_x; }
	void setY(s32 _y) { y=_y; }
	s32  getX() { return x; }
	s32  getY() { return y; }
	u32 getWidth() { return graphic.getWidth(); }
	u32 getHeight() { return graphic.getHeight(); }

	void setRadix(radix r) { defaultRadix = r; }
	radix getRadix() { return defaultRadix; }
};


///////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////

#endif //EVERSION__FONT_H
