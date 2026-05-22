// INCLUDES ///////////////////////////////////////////////////////////////////

#include <cstdlib>

#include "font.h"
#include "macros.h"
#include "config.h"
#include "itoa.h"


////////////////////////////////////////////////////////////////////////////////

namespace eversion {

// FUNCTIONS //////////////////////////////////////////////////////////////////

bool font::load(char *graphicFile, s32 width, s32 height, u8 _first, u8 _last)
{
	if( graphic.load(graphicFile, width, height, _last ? (_last-_first) : 0) == true )
	{
		first = _first;
		last = _last ? _last : (graphic.getCount() + first);
	}
	else
	{
		fprintf(stderr,"font::load failure");
		return false;
	}

	return true;
}

void font::write(char chr, SDL_Surface *dst)
{
	// unsigned required for interval check

	if(static_cast<u8>(chr)>=first && static_cast<u8>(chr)<=last)
		graphic.draw((u32)(static_cast<u8>(chr)-first),getX(),getY(),dst);
#ifndef EVERSION__DEBUG
	else
		fprintf(stderr,"font::write - chr out of bounds (\'%c\' - %d",chr,chr);
#endif
}

void font::write(char *str, SDL_Surface *dst)
{
	char *ptr = str;

	s32 x = getX();
	s32 y = getY();


	while(*ptr)
	{
		//graphic.draw(x,y,(GLuint)(*ptr));
		if(*ptr == (char)'\n')	//1 line down; x=beginX
		{
			setX(x);
			setY(getY() + (s32)graphic.tileset::getHeight()*2);
		}
		else
		{
			write(*ptr,dst);
			setX(getX() + (s32)graphic.tileset::getWidth());	//advance 1 char wide
		}

		ptr++;
	}


	if(keepCursor)
	{
		setX(x);
		setY(y);
	}
}

void font::write(s32 value, radix r, SDL_Surface *dst)
{
	u32 count = 0;
	s32 _value = value;

	radix _r;

	if(r == radix_default)
		_r = defaultRadix;
	else
		_r = r;

	// calculate the buffer_size (count) needed for allocation ////////
	if(_r == radix_10)
		if(value < 0)
		{
			count++; // 1 char for neg symbol. only in decimal
			_value = -_value;
		}

#ifdef EVERSION__RADIX_NOTATIONS
	else if(_r == radix_8)
		count++; // leading 0, octal notation
	else if(_r == radix_16)
		count+=2; // leading 0x, hexadecimal notation
#endif //EVERSION__RADIX_NOTATIONS

	if(_r != radix_10)
		do count++; while(_value /= _r );
	else
		do count++; while(_value /= _r );
	///////////////////////////////////////////////////////////

	char* buffer = new char[count+1]; // 1 for null term

#ifdef EVERSION__RADIX_NOTATIONS
	if(_r == radix_8)
		*(buffer++) = '0';
	else if(_r == radix_16)
	{
		*(buffer++) = '0'; *(buffer++) = 'x';
	}
#endif //EVERSION__RADIX_NOTATIONS

	itoa(value,buffer,_r);

#ifdef EVERSION__RADIX_NOTATIONS
	if(_r == radix_8)
		buffer--;	// 1 byte, leading "0"
	else if(_r == radix_16)
		buffer-=2;	// 2 bytes, leading "0x"
#endif //EVERSION__RADIX_NOTATIONS

	write(buffer,dst);

	RELEASE_ARRAY(buffer);
}

///////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////
