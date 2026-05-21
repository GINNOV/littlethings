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

#ifndef SDL_os4keyboard_h_
#define SDL_os4keyboard_h_

extern uint32 OS4_TranslateUnicode(SDL_VideoDevice *_this, uint16 code, uint32 qualifier, APTR iaddress);

extern bool OS4_SetClipboardText(SDL_VideoDevice *_this, const char *text);
extern char * OS4_GetClipboardText(SDL_VideoDevice *_this);
extern bool OS4_HasClipboardText(SDL_VideoDevice *_this);

extern void OS4_InitKeyboard(SDL_VideoDevice *_this);
extern void OS4_QuitKeyboard(SDL_VideoDevice *_this);

#endif /* SDL_os4keyboard_h_ */
