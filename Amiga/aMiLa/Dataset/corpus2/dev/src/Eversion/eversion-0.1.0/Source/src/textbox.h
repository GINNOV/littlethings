#ifndef EVERSION__TEXTBOX_H
 #define EVERSION__TEXTBOX_H


// INCLUDES ///////////////////////////////////////////////////////////////////

#include "window.h"

////////////////////////////////////////////////////////////////////////////////

namespace eversion {

// CLASSES ////////////////////////////////////////////////////////////////////

//Draws a SFFC textbox
class textbox : private window
{
public:
	typedef enum { dead, write, hold, rise, fall } textboxState_t;

protected:
	static u8 advTimeVal;
	static const u32 defWinW, defWinH;
	static const u8 boxMovSpd,arrowAvdVal;

	static surface imgArrow;

	char *strPos;
	char **lines;
	u16 maxStrLen, maxLines, currentLine;
	textboxState_t state;
	bool showArrow;

	virtual void reset();
	virtual void draw();

public:


	textbox() { init(); if(!imgArrow.hasImage()) imgArrow.load("arrow.png"); }
	~textbox() { free(); }

	virtual void init();
	virtual void free();

	u8 getTextRate() { return advTimeVal; }
	void setTextRate(u8 rate) { advTimeVal = rate; }

	void update();	//process text&draw
	void kill();

	bool moreText() { return *strPos != 0; }

	textboxState_t getState() { return state; }

	virtual void setCaption(char *str);
};


////////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////

#endif //EVERSION__TEXTBOX_H
