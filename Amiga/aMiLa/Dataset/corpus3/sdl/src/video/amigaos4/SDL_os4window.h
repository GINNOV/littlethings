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

#ifndef SDL_os4window_h_
#define SDL_os4window_h_

#include "intuition/classusr.h" /* Object */

#include "../SDL_sysvideo.h"

#define POINTER_GRAB_TIMEOUT        20  /* Number of ticks before pointer grab needs to be reactivated */

#define GID_ICONIFY 123

typedef struct HitTestInfo
{
    SDL_HitTestResult htr;
    SDL_Point point;
} HitTestInfo;

typedef enum EMenu {
    MID_Iconify = 1,
    MID_About,
    MID_LaunchPrefs,
    MID_Quit
} EMenu;

struct SDL_WindowData
{
    SDL_Window      * sdlwin;
    struct Window   * syswin;
    struct BitMap   * bitmap;
    struct AppWindow * appWin;
    struct AppIcon  * appIcon;
    Object          * menuObject;

    Uint32            pointerGrabTicks;

    void*           * glContext;
    struct BitMap   * glFrontBuffer;
    struct BitMap   * glBackBuffer;

    HitTestInfo       hti;

    struct Gadget   * gadget;
    struct Image    * image;

    BOOL              wasMaximized; /* Remember state when going to fullscreen mode, or back */
};

extern void OS4_GetWindowSize(struct Window * window, int * width, int * height);
extern void OS4_WaitForResize(SDL_Window * window, int * width, int * height);

extern bool OS4_CreateWindow(SDL_VideoDevice *this, SDL_Window * window, SDL_PropertiesID create_props);
extern void OS4_SetWindowTitle(SDL_VideoDevice *this, SDL_Window * window);
//extern void OS4_SetWindowIcon(SDL_VideoDevice *this, SDL_Window * window, SDL_Surface * icon);
extern void OS4_SetWindowBox(SDL_VideoDevice *this, SDL_Window * window, SDL_Rect * rect);
extern bool OS4_SetWindowPosition(SDL_VideoDevice *this, SDL_Window * window);
extern void OS4_SetWindowSize(SDL_VideoDevice *this, SDL_Window * window);
extern void OS4_ShowWindow(SDL_VideoDevice *this, SDL_Window * window);
extern void OS4_HideWindow(SDL_VideoDevice *this, SDL_Window * window);
extern void OS4_RaiseWindow(SDL_VideoDevice *this, SDL_Window * window);

extern void OS4_SetWindowMinMaxSize(SDL_VideoDevice *this, SDL_Window * window);

extern void OS4_MaximizeWindow(SDL_VideoDevice *this, SDL_Window * window);
extern void OS4_MinimizeWindow(SDL_VideoDevice *this, SDL_Window * window);
extern void OS4_RestoreWindow(SDL_VideoDevice *this, SDL_Window * window);

extern void OS4_SetWindowResizable(SDL_VideoDevice *this, SDL_Window * window, bool resizable);
extern void OS4_SetWindowAlwaysOnTop(SDL_VideoDevice *this, SDL_Window * window, bool on_top);

extern void OS4_SetWindowBordered(SDL_VideoDevice *this, SDL_Window * window, bool bordered);
extern SDL_FullscreenResult OS4_SetWindowFullscreen(SDL_VideoDevice *this, SDL_Window * window, SDL_VideoDisplay * display, SDL_FullscreenOp fullscreen);
//extern bool OS4_SetWindowGammaRamp(SDL_VideoDevice *this, SDL_Window * window, const Uint16 * ramp);
//extern bool OS4_GetWindowGammaRamp(SDL_VideoDevice *this, SDL_Window * window, Uint16 * ramp);

extern bool OS4_SetWindowGrabPrivate(SDL_VideoDevice *this, struct Window * w, bool activate);
extern bool OS4_SetWindowMouseGrab(SDL_VideoDevice *this, SDL_Window * window, bool grabbed);
//extern void OS4_SetWindowKeyboardGrab(SDL_VideoDevice *this, SDL_Window * window, bool grabbed);

extern void OS4_DestroyWindow(SDL_VideoDevice *this, SDL_Window * window);

//extern void OS4_OnWindowEnter(SDL_VideoDevice *this, SDL_Window * window);
extern bool OS4_FlashWindow(SDL_VideoDevice *this, SDL_Window * window, SDL_FlashOperation operation);

//extern void OS4_UpdateClipCursor(SDL_Window *window);

extern bool OS4_SetWindowHitTest(SDL_Window * window, bool enabled);

extern bool OS4_SetWindowOpacity(SDL_VideoDevice *this, SDL_Window * window, float opacity);
extern bool OS4_GetWindowBordersSize(SDL_VideoDevice *this, SDL_Window * window, int * top, int * left, int * bottom, int * right);

extern void OS4_IconifyWindow(SDL_VideoDevice *this, SDL_Window * window);
extern void OS4_UniconifyWindow(SDL_VideoDevice *this, SDL_Window * window);

#endif /* SDL_os4window_h_ */
