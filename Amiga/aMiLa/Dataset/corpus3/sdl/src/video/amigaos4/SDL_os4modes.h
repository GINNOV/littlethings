/*
  Simple DirectMedia Layer
  Copyright (C) 1997-2026 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/
#include "SDL_internal.h"

#ifndef SDL_os4modes_h_
#define SDL_os4modes_h_

struct SDL_DisplayData
{
    struct Screen *			screen;
};

struct SDL_DisplayModeData
{
    ULONG					modeid;
    LONG					x;
    LONG					y;
};

extern bool OS4_InitModes(SDL_VideoDevice *_this);
extern bool OS4_GetDisplayBounds(SDL_VideoDevice *_this, SDL_VideoDisplay * display, SDL_Rect * rect);
extern bool OS4_GetDisplayModes(SDL_VideoDevice *_this, SDL_VideoDisplay * display);
extern bool OS4_SetDisplayMode(SDL_VideoDevice *_this, SDL_VideoDisplay * display, SDL_DisplayMode * mode);
extern void OS4_QuitModes(SDL_VideoDevice *_this);

extern void OS4_CloseScreen(SDL_VideoDevice *_this, struct Screen *screen);

#endif /* SDL_os4modes_h */
