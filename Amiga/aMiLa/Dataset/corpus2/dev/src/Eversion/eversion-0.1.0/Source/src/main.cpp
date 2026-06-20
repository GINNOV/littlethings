// INCLUDES ///////////////////////////////////////////////////////////////////

#include <fstream>
#include <cstdlib>
#include <cstdio>
#include <cstring>

#include "sdl.h"
#include "globals.h"
#include "main.h"
#include "types.h"
#include "imagestack.h"
#include "game.h"
#include "timer.h"
#include "window.h"

#ifdef HAVE_CONFIG_H
# define EVERSION__WIN_TITLE PACKAGE " " VERSION
#else
#define EVERSION__WIN_TITLE "(missing package info)"
#endif

////////////////////////////////////////////////////////////////////////////////

namespace eversion {

// GLOBALS ////////////////////////////////////////////////////////////////////

u8 *keyBuff;
::SDL_Surface *screen=NULL;

u32 frameRate = 20;
volatile u16 screenWidth=640, screenHeight=480,screenBitsPerPixel=0;
u16 mapwinx=320, mapwiny=288;

bool fullscreen=false, doublebuffer=true;
//bool win_restore=false;

const char* dataDir = "data/";

io_device::keyboard devKeyb;
io_device::mouse devMouse;

// FUNCTIONS //////////////////////////////////////////////////////////////////

int SDL_BlitSurface(SDL_Surface *src, SDL_Rect *srcrect, SDL_Surface *dst, SDL_Rect *dstrect)
{
	//filter blitting
	::SDL_Rect rc = game::instance()->getSceneRect();
	dstrect->x += rc.x;
	dstrect->y += rc.y;

	return ::SDL_BlitSurface(src, srcrect, dst?dst:screen, dstrect);
}

namespace {

inline void drawFunc()
{
	::SDL_Rect rc = game::instance()->getSceneRect();
	::SDL_FillRect(screen,&rc,~0);

	game::instance()->drawScene();

	if(doublebuffer)
		::SDL_Flip(screen);
	else
		::SDL_UpdateRects(screen, 1, &rc);
}

inline void eventFunc()
{
	static ::SDL_Event event;

	while( ::SDL_PollEvent( &event ) )
	{
		switch (event.type)
		{

			case SDL_ACTIVEEVENT:
			{
				if( event.active.state & SDL_APPACTIVE ) {
					if( event.active.gain )
					{
						//app activated
						//win_restore=true;
					}
					else
					{
						//app iconified
					}
				}
			}
			break;

			case SDL_MOUSEBUTTONDOWN:
			case SDL_MOUSEBUTTONUP:
			case SDL_MOUSEMOTION:
				devMouse.update();
			break;

			case SDL_KEYDOWN:
			case SDL_KEYUP:
				devKeyb.update();
			break;

			case SDL_QUIT:
			{
				game::instance()->endGame();
			}
			break;
		}

	}
}

inline void freeFunc()
{

}


inline const char* yesno(bool cond)
{
	return cond ? "yes" : "no";
}

inline void readVideoInfo(const SDL_VideoInfo* info)
{
	fprintf(stdout, "--begin video info block--\n");

	fprintf(stdout, "hw surface acceleration: %s\n", yesno(info->hw_available==1) );
	fprintf(stdout, "window manager: %s\n", yesno(info->wm_available==1) );
	fprintf(stdout, "accelerated blits (hw->hw): %s\n", yesno(info->blit_hw==1) );
	fprintf(stdout, "accelerated blits (hw w/ colorkey): %s\n", yesno(info->blit_hw_CC==1) );
	fprintf(stdout, "accelerated blits (hw w/ alpha): %s\n", yesno(info->blit_hw_A==1) );
	fprintf(stdout, "accelerated blits (sw->hw): %s\n", yesno(info->blit_sw==1) );
	fprintf(stdout, "accelerated blits (sw w/ colorkey): %s\n", yesno(info->blit_sw_CC==1) );
	fprintf(stdout, "accelerated blits (sw w/ alpha): %s\n", yesno(info->blit_sw_A==1) );
	fprintf(stdout, "accelerated color fill: %s\n", yesno(info->blit_fill==1) );
	fprintf(stdout, "available video memory: %dK\n", info->video_mem );

	fprintf(stdout, "--end video info block--\n");
}

}

////////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////

using namespace eversion;

int main(int argc, char *argv[])
{
	u32 flags = 0;
	bool autoDetect = false, showInfo=false;

#ifdef EVERSION__RELEASE
	flags |= SDL_INIT_NOPARACHUTE;
#endif

	//process command-line arguments
	for(int i = 1; i < argc; i++)
	{
		if( !strcmp(argv[i], "-f") )
		{
			fullscreen = true;
		}

		else if( !strcmp(argv[i], "-d") )
		{
			doublebuffer = true;
		}

		//enable hardware-support
		else if( !strcmp(argv[i], "-hw") )
			flags |= SDL_HWSURFACE | SDL_HWACCEL;
		else if( !strcmp(argv[i], "-hws") )
			flags |= SDL_HWSURFACE;
		else if( !strcmp(argv[i], "-hwa") )
			flags |= SDL_HWACCEL;
		else if( !strcmp(argv[i], "-auto") )
			autoDetect = true;
		else if( !strcmp(argv[i], "-info") )
			showInfo = true;

		//set resolution
		else if( !strcmp(argv[i], "-320x240") )
		{
			screenWidth=320;  screenHeight=240;
		}
		else if( !strcmp(argv[i], "-640x480") )
		{
			screenWidth=640;  screenHeight=480;
		}
		else if( !strcmp(argv[i], "-800x600") )
		{
			screenWidth=800;  screenHeight=600;
		}
		else if( !strcmp(argv[i], "-1024x768") )
		{
			screenWidth=1024;  screenHeight=768;
		}

		//set bits per pixel
		else if( !strcmp(argv[i], "-8") )
			screenBitsPerPixel = 8;
		else if( !strcmp(argv[i], "-16") )
			screenBitsPerPixel = 16;
		else if( !strcmp(argv[i], "-24") )
			screenBitsPerPixel = 24;
		else if( !strcmp(argv[i], "-32") )
			screenBitsPerPixel = 32;
		else
			fprintf(stderr, "main: unrecognized paramemter: \"%s\"\n", argv[i]);
	}

    if ( SDL_Init(SDL_INIT_VIDEO) < 0 )
	{
        fprintf(stderr, "main: failed to initialize SDL: %s\n", SDL_GetError());
        return 1;
    }

	const SDL_VideoInfo* vidInfo = SDL_GetVideoInfo();
	if(vidInfo == NULL)
	{
		fprintf(stderr, "main: failed to get videoinfo: %s\n", SDL_GetError());
		return 1;
	}
	else
	{
		if(showInfo)
			readVideoInfo(vidInfo);
	}

	atexit(::SDL_Quit);
	atexit(freeFunc);

	::SDL_Init(SDL_INIT_TIMER);

	//no bpp set in args
	if(screenBitsPerPixel == 0)
	{
//#ifdef EVERSION__DEBUG
		fprintf(stderr, "main: bpp not specified in command-line args, checking current video settings..\n");
//#endif
			screenBitsPerPixel = vidInfo->vfmt->BitsPerPixel;
//#ifdef EVERSION__DEBUG
			fprintf(stderr, "main: setting %dbpp\n", screenBitsPerPixel);
//#endif
	}

	if(doublebuffer)
		flags |= SDL_DOUBLEBUF;

	if(fullscreen)
		flags |= SDL_FULLSCREEN;
	else
	{
		screenWidth=mapwinx; screenHeight=mapwiny;
	}


	if( (screen = ::SDL_SetVideoMode(screenWidth, screenHeight, screenBitsPerPixel, flags)) == NULL )
	{
        fprintf(stderr, "main: failed to set %dx%d%d video mode: %s\n",
			screenWidth, screenHeight, screenBitsPerPixel, ::SDL_GetError());
		return 1;
	}

	::SDL_WM_SetCaption(EVERSION__WIN_TITLE, EVERSION__WIN_TITLE);
	::SDL_WM_SetIcon(image_stack::instance()->load("icon.png"), NULL);

	game::instance()->init();
	::SDL_Rect rc = game::instance()->getSceneRect();
	::SDL_SetClipRect(screen, &rc);

	timer t;

	while( game::instance()->isAlive() )
	{
		t.set(frameRate);

		eventFunc();
		drawFunc();

		game::instance()->update();

		while(t.get())	{} //keep looping until timer expires
	}

	if(screen)
		::SDL_FreeSurface(screen);

	return 0;
}
