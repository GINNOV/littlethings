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

#ifndef SDL_os4opengl_h_
#define SDL_os4opengl_h_

#include "SDL_os4window.h"

extern bool OS4_GL_LoadLibrary(SDL_VideoDevice *_this, const char *path);
extern SDL_FunctionPointer OS4_GL_GetProcAddress(SDL_VideoDevice *_this, const char *proc);
extern void OS4_GL_UnloadLibrary(SDL_VideoDevice *_this);
extern SDL_GLContext OS4_GL_CreateContext(SDL_VideoDevice *_this, SDL_Window * window);
extern bool OS4_GL_MakeCurrent(SDL_VideoDevice *_this, SDL_Window * window, SDL_GLContext context);
extern void OS4_GL_GetDrawableSize(SDL_VideoDevice *_this, SDL_Window * window, int *w, int *h);
extern bool OS4_GL_SetSwapInterval(SDL_VideoDevice *_this, int interval);
extern bool OS4_GL_GetSwapInterval(SDL_VideoDevice *_this, int* interval);
extern bool OS4_GL_SwapWindow(SDL_VideoDevice *_this, SDL_Window * window);
extern bool OS4_GL_DestroyContext(SDL_VideoDevice *_this, SDL_GLContext context);

/* Non-SDL functions */
extern bool OS4_GL_AllocateBuffers(SDL_VideoDevice *_this, int width, int height, int depth, SDL_WindowData * data);
extern void OS4_GL_FreeBuffers(SDL_VideoDevice *_this, SDL_WindowData * data);
extern bool OS4_GL_ResizeContext(SDL_VideoDevice *_this, SDL_Window * window);
extern void OS4_GL_UpdateWindowPointer(SDL_VideoDevice *_this, SDL_Window * window);

#endif /* SDL_os4opengl_h_ */
