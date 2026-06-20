// INCLUDES ///////////////////////////////////////////////////////////////////

#include "textbox.h"
#include <cstring>
#include "game.h"


////////////////////////////////////////////////////////////////////////////////

namespace eversion {

u8 textbox::advTimeVal = 2;
const u32 textbox::defWinW=320, textbox::defWinH=112;
const u8 textbox::boxMovSpd=16, textbox::arrowAvdVal=6;

surface textbox::imgArrow;

// FUNCTIONS //////////////////////////////////////////////////////////////////

void textbox::update()
{
	static s32 advTime;
	static bool brwNL;
	static s32 arrowAdv;

	switch(state)
	{
	case dead:
		break;

	case write:
		{
			if(brwNL)
			{
				currentLine++;
				brwNL=false;
			}
			if(++advTime >= advTimeVal)
			{
				advTime=0;
				strPos++;

				static u16 lineR;

				if(*strPos == (char) '\r')
				{
					state=hold;
					showArrow=true;
					lineR=0;
				}
				else if(*strPos == (char) '\n')
				{
					currentLine++;
					lineR++;

					if(lineR >= maxLines)
					{
						currentLine--;
						brwNL=true;
						state=hold;
						showArrow=true;
						lineR=0;
					}
				}

			}

			if(*strPos=='\0')
			{
				state=hold;
				showArrow=true;
			}
		}//case write:
		break;

	case rise:
		{
			if(pos.y>mapwiny-defWinH)
				pos.y-=boxMovSpd;
			else
			{
				state=write;
				showCaption=true;
				showArrow=false;

				arrowAdv=0;
				advTime=0;
			}
		}
		break;

	case fall:
		{
			if(pos.y<mapwiny)
				pos.y+=boxMovSpd;
			else
			{
				state=dead;
				isVisible=false;
			}
		}
		break;

	case hold:
		{
			if(++arrowAdv >= arrowAvdVal)
			{
				arrowAdv=0;
				showArrow=!showArrow;
			}
		}
		break;
	}

	draw();
}

void textbox::draw()
{
	char c, *str;

	if(strPos)
	{
		c = *strPos;	//push c

		*strPos = '\0';
		str = caption;	//push caption
		s32 line = currentLine-maxLines+1;
		caption = lines[line>0?line:0];
	}

	if(isVisible)
	{
		window::draw();
		if(showArrow)
			imgArrow.draw(pos.x+size.x-imgArrow.getWidth()-4,pos.y+size.y-imgArrow.getHeight()-2);
	}

	if(strPos)
	{
		caption = str;	//pop caption
		*strPos = c;	//pop c
	}
}

void textbox::setCaption(char *str)
{
	window::setCaption(str,maxStrLen);

	char *p=caption;
	u16 line_count=1;

	do
	{
		if(*p=='\n')
		{
			line_count++;
		}
	} while(*++p);

	if(lines)
		delete [] lines;

	lines = new char*[line_count];
	lines[0]=p=caption;

	for(u16 i=1; i<line_count; i++)
	{
		while(*(++p) && (*p != '\n') )
			;
		lines[i]=++p;
	}
	strPos=window::caption;

	if(pos.y == mapwiny-defWinH)
	{
		state=write;
	}
	else
	{
		showCaption=false;
		state=rise;
	}

	currentLine=0;
	isVisible=true;
}

void textbox::kill()
{
	showArrow=false;

	if(*strPos)
		state=write;
	else
		state=fall;
}

void textbox::reset()
{
	strPos = window::caption;
	state = hold;
}

void textbox::init()
{
	lines=NULL;
	strPos=NULL;
	currentLine=0;
	state=dead;
	showArrow=false;

	window::resize(defWinW,defWinH);
	u32 fontW=16,fontH=16;
	maxStrLen=size.x/fontW-2;
	maxLines=(size.y+fontH)/(fontH*2)-1;
	window::move(0,eversion::mapwiny);
}

void textbox::free()
{
	if(lines)
		delete [] lines;

	init();
}

////////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////
