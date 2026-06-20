#ifndef _VBCCINLINE_POWERSDL_H
#define _VBCCINLINE_POWERSDL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

int __SDL_Init(struct Library *, Uint32 flags) =
	"\tlwz\t0,-28(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_Init(flags) __SDL_Init(PowerSDLBase, (flags))

void __SDL_Quit(struct Library *) =
	"\tlwz\t0,-34(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_Quit() __SDL_Quit(PowerSDLBase)

int __SDL_InitSubSystem(struct Library *, Uint32 flags) =
	"\tlwz\t0,-40(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_InitSubSystem(flags) __SDL_InitSubSystem(PowerSDLBase, (flags))

void __SDL_QuitSubSystem(struct Library *, Uint32 flags) =
	"\tlwz\t0,-46(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_QuitSubSystem(flags) __SDL_QuitSubSystem(PowerSDLBase, (flags))

Uint32 __SDL_WasInit(struct Library *, Uint32 flags) =
	"\tlwz\t0,-52(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_WasInit(flags) __SDL_WasInit(PowerSDLBase, (flags))

SDL_RWops  * __SDL_RWFromFile(struct Library *, CONST_STRPTR file, CONST_STRPTR mode) =
	"\tlwz\t0,-58(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_RWFromFile(file, mode) __SDL_RWFromFile(PowerSDLBase, (file), (mode))

SDL_RWops * __SDL_RWFromMem(struct Library *, void * mem, int size) =
	"\tlwz\t0,-70(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_RWFromMem(mem, size) __SDL_RWFromMem(PowerSDLBase, (mem), (size))

SDL_RWops * __SDL_AllocRW(struct Library *) =
	"\tlwz\t0,-76(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_AllocRW() __SDL_AllocRW(PowerSDLBase)

void __SDL_FreeRW(struct Library *, SDL_RWops * area) =
	"\tlwz\t0,-82(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_FreeRW(area) __SDL_FreeRW(PowerSDLBase, (area))

SDL_Surface * __SDL_LoadBMP_RW(struct Library *, SDL_RWops * src, int freesrc) =
	"\tlwz\t0,-88(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_LoadBMP_RW(src, freesrc) __SDL_LoadBMP_RW(PowerSDLBase, (src), (freesrc))

SDL_Surface * __SDL_DisplayFormat(struct Library *, SDL_Surface * surface) =
	"\tlwz\t0,-94(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_DisplayFormat(surface) __SDL_DisplayFormat(PowerSDLBase, (surface))

void __SDL_FreeSurface(struct Library *, SDL_Surface * surface) =
	"\tlwz\t0,-100(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_FreeSurface(surface) __SDL_FreeSurface(PowerSDLBase, (surface))

int __SDL_FillRect(struct Library *, SDL_Surface * dst, SDL_Rect * dstrect, Uint32 color) =
	"\tlwz\t0,-106(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_FillRect(dst, dstrect, color) __SDL_FillRect(PowerSDLBase, (dst), (dstrect), (color))

int __SDL_UpperBlit(struct Library *, SDL_Surface * src, SDL_Rect * srcrect, SDL_Surface * dst, SDL_Rect * dstrect) =
	"\tlwz\t0,-112(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_UpperBlit(src, srcrect, dst, dstrect) __SDL_UpperBlit(PowerSDLBase, (src), (srcrect), (dst), (dstrect))

int __SDL_Flip(struct Library *, SDL_Surface * screen) =
	"\tlwz\t0,-118(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_Flip(screen) __SDL_Flip(PowerSDLBase, (screen))

void __SDL_UpdateRects(struct Library *, SDL_Surface * screen, int numrects, SDL_Rect * rects) =
	"\tlwz\t0,-124(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_UpdateRects(screen, numrects, rects) __SDL_UpdateRects(PowerSDLBase, (screen), (numrects), (rects))

void __SDL_UpdateRect(struct Library *, SDL_Surface * screen, Sint32 x, Sint32 y, Uint32 w, Uint32 h) =
	"\tlwz\t0,-130(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_UpdateRect(screen, x, y, w, h) __SDL_UpdateRect(PowerSDLBase, (screen), (x), (y), (w), (h))

const SDL_VideoInfo * __SDL_GetVideoInfo(struct Library *) =
	"\tlwz\t0,-136(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetVideoInfo() __SDL_GetVideoInfo(PowerSDLBase)

SDL_Surface * __SDL_SetVideoMode(struct Library *, int width, int height, int bpp, Uint32 flags) =
	"\tlwz\t0,-142(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SetVideoMode(width, height, bpp, flags) __SDL_SetVideoMode(PowerSDLBase, (width), (height), (bpp), (flags))

Uint32 __SDL_MapRGB(struct Library *, SDL_PixelFormat * format, Uint8 r, Uint8 g, Uint8 b) =
	"\tlwz\t0,-148(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_MapRGB(format, r, g, b) __SDL_MapRGB(PowerSDLBase, (format), (r), (g), (b))

Uint32 __SDL_MapRGBA(struct Library *, SDL_PixelFormat * format, Uint8 r, Uint8 g, Uint8 b, Uint8 a) =
	"\tlwz\t0,-154(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_MapRGBA(format, r, g, b, a) __SDL_MapRGBA(PowerSDLBase, (format), (r), (g), (b), (a))

char * __SDL_VideoDriverName(struct Library *, char * namebuf, int maxlen) =
	"\tlwz\t0,-160(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_VideoDriverName(namebuf, maxlen) __SDL_VideoDriverName(PowerSDLBase, (namebuf), (maxlen))

SDL_Surface * __SDL_GetVideoSurface(struct Library *) =
	"\tlwz\t0,-166(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetVideoSurface() __SDL_GetVideoSurface(PowerSDLBase)

int __SDL_VideoModeOK(struct Library *, int width, int height, int bpp, Uint32 flags) =
	"\tlwz\t0,-172(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_VideoModeOK(width, height, bpp, flags) __SDL_VideoModeOK(PowerSDLBase, (width), (height), (bpp), (flags))

SDL_Rect ** __SDL_ListModes(struct Library *, SDL_PixelFormat * format, Uint32 flags) =
	"\tlwz\t0,-178(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_ListModes(format, flags) __SDL_ListModes(PowerSDLBase, (format), (flags))

int __SDL_SetGamma(struct Library *, float red, float green, float blue) =
	"\tlwz\t0,-184(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SetGamma(red, green, blue) __SDL_SetGamma(PowerSDLBase, (red), (green), (blue))

int __SDL_SetGammaRamp(struct Library *, const Uint16 * red, const Uint16 * green, const Uint16 * blue) =
	"\tlwz\t0,-190(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SetGammaRamp(red, green, blue) __SDL_SetGammaRamp(PowerSDLBase, (red), (green), (blue))

int __SDL_GetGammaRamp(struct Library *, Uint16 * red, Uint16 * green, Uint16 * blue) =
	"\tlwz\t0,-196(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetGammaRamp(red, green, blue) __SDL_GetGammaRamp(PowerSDLBase, (red), (green), (blue))

int __SDL_SetColors(struct Library *, SDL_Surface * surface, SDL_Color * colors, int firstcolor, int ncolors) =
	"\tlwz\t0,-202(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SetColors(surface, colors, firstcolor, ncolors) __SDL_SetColors(PowerSDLBase, (surface), (colors), (firstcolor), (ncolors))

int __SDL_SetPalette(struct Library *, SDL_Surface * surface, int flags, SDL_Color * colors, int firstcolor, int ncolors) =
	"\tlwz\t0,-208(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SetPalette(surface, flags, colors, firstcolor, ncolors) __SDL_SetPalette(PowerSDLBase, (surface), (flags), (colors), (firstcolor), (ncolors))

void __SDL_GetRGB(struct Library *, Uint32 pixel, SDL_PixelFormat * format, Uint8 * r, Uint8 * g, Uint8 * b) =
	"\tlwz\t0,-214(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetRGB(pixel, format, r, g, b) __SDL_GetRGB(PowerSDLBase, (pixel), (format), (r), (g), (b))

void __SDL_GetRGBA(struct Library *, Uint32 pixel, SDL_PixelFormat * format, Uint8 * r, Uint8 * g, Uint8 * b, Uint8 * a) =
	"\tlwz\t0,-220(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetRGBA(pixel, format, r, g, b, a) __SDL_GetRGBA(PowerSDLBase, (pixel), (format), (r), (g), (b), (a))

SDL_Surface * __SDL_CreateRGBSurface(struct Library *, Uint32 flags, int width, int height, int depth, Uint32 Rmask, Uint32 Gmask, Uint32 Bmask, Uint32 Amask) =
	"\tlwz\t0,-226(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CreateRGBSurface(flags, width, height, depth, Rmask, Gmask, Bmask, Amask) __SDL_CreateRGBSurface(PowerSDLBase, (flags), (width), (height), (depth), (Rmask), (Gmask), (Bmask), (Amask))

SDL_Surface * __SDL_CreateRGBSurfaceFrom(struct Library *, void * pixels, int width, int height, int depth, int pitch, Uint32 Rmask, Uint32 Gmask, Uint32 Bmask, Uint32 Amask) =
	"\tlwz\t0,-232(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CreateRGBSurfaceFrom(pixels, width, height, depth, pitch, Rmask, Gmask, Bmask, Amask) __SDL_CreateRGBSurfaceFrom(PowerSDLBase, (pixels), (width), (height), (depth), (pitch), (Rmask), (Gmask), (Bmask), (Amask))

int __SDL_LockSurface(struct Library *, SDL_Surface * surface) =
	"\tlwz\t0,-238(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_LockSurface(surface) __SDL_LockSurface(PowerSDLBase, (surface))

void __SDL_UnlockSurface(struct Library *, SDL_Surface * surface) =
	"\tlwz\t0,-244(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_UnlockSurface(surface) __SDL_UnlockSurface(PowerSDLBase, (surface))

int __SDL_SaveBMP_RW(struct Library *, SDL_Surface * surface, SDL_RWops * dst, int freedst) =
	"\tlwz\t0,-250(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SaveBMP_RW(surface, dst, freedst) __SDL_SaveBMP_RW(PowerSDLBase, (surface), (dst), (freedst))

int __SDL_SetColorKey(struct Library *, SDL_Surface * surface, Uint32 flag, Uint32 key) =
	"\tlwz\t0,-256(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SetColorKey(surface, flag, key) __SDL_SetColorKey(PowerSDLBase, (surface), (flag), (key))

int __SDL_SetAlpha(struct Library *, SDL_Surface * surface, Uint32 flag, Uint8 alpha) =
	"\tlwz\t0,-262(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SetAlpha(surface, flag, alpha) __SDL_SetAlpha(PowerSDLBase, (surface), (flag), (alpha))

SDL_bool __SDL_SetClipRect(struct Library *, SDL_Surface * surface, const SDL_Rect * rect) =
	"\tlwz\t0,-268(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SetClipRect(surface, rect) __SDL_SetClipRect(PowerSDLBase, (surface), (rect))

void __SDL_GetClipRect(struct Library *, SDL_Surface * surface, SDL_Rect * rect) =
	"\tlwz\t0,-274(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetClipRect(surface, rect) __SDL_GetClipRect(PowerSDLBase, (surface), (rect))

SDL_Surface * __SDL_ConvertSurface(struct Library *, SDL_Surface * src, SDL_PixelFormat * fmt, Uint32 flags) =
	"\tlwz\t0,-280(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_ConvertSurface(src, fmt, flags) __SDL_ConvertSurface(PowerSDLBase, (src), (fmt), (flags))

SDL_Surface * __SDL_DisplayFormatAlpha(struct Library *, SDL_Surface * surface) =
	"\tlwz\t0,-286(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_DisplayFormatAlpha(surface) __SDL_DisplayFormatAlpha(PowerSDLBase, (surface))

SDL_Overlay * __SDL_CreateYUVOverlay(struct Library *, int width, int height, Uint32 format, SDL_Surface * display) =
	"\tlwz\t0,-292(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CreateYUVOverlay(width, height, format, display) __SDL_CreateYUVOverlay(PowerSDLBase, (width), (height), (format), (display))

int __SDL_LockYUVOverlay(struct Library *, SDL_Overlay * overlay) =
	"\tlwz\t0,-298(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_LockYUVOverlay(overlay) __SDL_LockYUVOverlay(PowerSDLBase, (overlay))

void __SDL_UnlockYUVOverlay(struct Library *, SDL_Overlay * overlay) =
	"\tlwz\t0,-304(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_UnlockYUVOverlay(overlay) __SDL_UnlockYUVOverlay(PowerSDLBase, (overlay))

int __SDL_DisplayYUVOverlay(struct Library *, SDL_Overlay * overlay, SDL_Rect * dstrect) =
	"\tlwz\t0,-310(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_DisplayYUVOverlay(overlay, dstrect) __SDL_DisplayYUVOverlay(PowerSDLBase, (overlay), (dstrect))

void __SDL_FreeYUVOverlay(struct Library *, SDL_Overlay * overlay) =
	"\tlwz\t0,-316(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_FreeYUVOverlay(overlay) __SDL_FreeYUVOverlay(PowerSDLBase, (overlay))

int __SDL_GL_LoadLibrary(struct Library *, const char * path) =
	"\tlwz\t0,-322(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GL_LoadLibrary(path) __SDL_GL_LoadLibrary(PowerSDLBase, (path))

void * __SDL_GL_GetProcAddress(struct Library *, const char* proc) =
	"\tlwz\t0,-328(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GL_GetProcAddress(proc) __SDL_GL_GetProcAddress(PowerSDLBase, (proc))

int __SDL_GL_SetAttribute(struct Library *, SDL_GLattr attr, int value) =
	"\tlwz\t0,-334(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GL_SetAttribute(attr, value) __SDL_GL_SetAttribute(PowerSDLBase, (attr), (value))

int __SDL_GL_GetAttribute(struct Library *, SDL_GLattr attr, int* value) =
	"\tlwz\t0,-340(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GL_GetAttribute(attr, value) __SDL_GL_GetAttribute(PowerSDLBase, (attr), (value))

void __SDL_GL_SwapBuffers(struct Library *) =
	"\tlwz\t0,-346(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GL_SwapBuffers() __SDL_GL_SwapBuffers(PowerSDLBase)

void __SDL_GL_UpdateRects(struct Library *, int numrects, SDL_Rect* rects) =
	"\tlwz\t0,-352(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GL_UpdateRects(numrects, rects) __SDL_GL_UpdateRects(PowerSDLBase, (numrects), (rects))

void __SDL_GL_Lock(struct Library *) =
	"\tlwz\t0,-358(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GL_Lock() __SDL_GL_Lock(PowerSDLBase)

void __SDL_GL_Unlock(struct Library *) =
	"\tlwz\t0,-364(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GL_Unlock() __SDL_GL_Unlock(PowerSDLBase)

void __SDL_WM_SetCaption(struct Library *, const char * title, const char * icon) =
	"\tlwz\t0,-370(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_WM_SetCaption(title, icon) __SDL_WM_SetCaption(PowerSDLBase, (title), (icon))

void __SDL_WM_GetCaption(struct Library *, char ** title, char ** icon) =
	"\tlwz\t0,-376(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_WM_GetCaption(title, icon) __SDL_WM_GetCaption(PowerSDLBase, (title), (icon))

void __SDL_WM_SetIcon(struct Library *, SDL_Surface * icon, Uint8 * mask) =
	"\tlwz\t0,-382(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_WM_SetIcon(icon, mask) __SDL_WM_SetIcon(PowerSDLBase, (icon), (mask))

int __SDL_WM_IconifyWindow(struct Library *) =
	"\tlwz\t0,-388(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_WM_IconifyWindow() __SDL_WM_IconifyWindow(PowerSDLBase)

int __SDL_WM_ToggleFullScreen(struct Library *, SDL_Surface * surface) =
	"\tlwz\t0,-394(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_WM_ToggleFullScreen(surface) __SDL_WM_ToggleFullScreen(PowerSDLBase, (surface))

SDL_GrabMode __SDL_WM_GrabInput(struct Library *, SDL_GrabMode mode) =
	"\tlwz\t0,-400(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_WM_GrabInput(mode) __SDL_WM_GrabInput(PowerSDLBase, (mode))

Uint32 __SDL_GetTicks(struct Library *) =
	"\tlwz\t0,-406(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetTicks() __SDL_GetTicks(PowerSDLBase)

void __SDL_Delay(struct Library *, Uint32 ms) =
	"\tlwz\t0,-412(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_Delay(ms) __SDL_Delay(PowerSDLBase, (ms))

int __SDL_SetTimer(struct Library *, Uint32 interval, SDL_TimerCallback (callback)(unsigned long)) =
	"\tlwz\t0,-418(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SetTimer(interval, callback) __SDL_SetTimer(PowerSDLBase, (interval), (callback))

SDL_TimerID __SDL_AddTimer(struct Library *, Uint32 interval, SDL_NewTimerCallback (callback)(unsigned long,void *), void * param) =
	"\tlwz\t0,-424(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_AddTimer(interval, callback, param) __SDL_AddTimer(PowerSDLBase, (interval), (callback), (param))

SDL_bool __SDL_RemoveTimer(struct Library *, SDL_TimerID t) =
	"\tlwz\t0,-430(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_RemoveTimer(t) __SDL_RemoveTimer(PowerSDLBase, (t))

void __SDL_PumpEvents(struct Library *) =
	"\tlwz\t0,-436(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_PumpEvents() __SDL_PumpEvents(PowerSDLBase)

int __SDL_PollEvent(struct Library *, SDL_Event * event) =
	"\tlwz\t0,-442(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_PollEvent(event) __SDL_PollEvent(PowerSDLBase, (event))

int __SDL_WaitEvent(struct Library *, SDL_Event * event) =
	"\tlwz\t0,-448(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_WaitEvent(event) __SDL_WaitEvent(PowerSDLBase, (event))

int __SDL_PeepEvents(struct Library *, SDL_Event * events, int numevents, SDL_eventaction action, Uint32 mask) =
	"\tlwz\t0,-454(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_PeepEvents(events, numevents, action, mask) __SDL_PeepEvents(PowerSDLBase, (events), (numevents), (action), (mask))

int __SDL_PushEvent(struct Library *, SDL_Event * event) =
	"\tlwz\t0,-460(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_PushEvent(event) __SDL_PushEvent(PowerSDLBase, (event))

void __SDL_SetEventFilter(struct Library *, SDL_EventFilter filter) =
	"\tlwz\t0,-466(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SetEventFilter(filter) __SDL_SetEventFilter(PowerSDLBase, (filter))

SDL_EventFilter __SDL_GetEventFilter(struct Library *) =
	"\tlwz\t0,-472(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetEventFilter() __SDL_GetEventFilter(PowerSDLBase)

Uint8 __SDL_EventState(struct Library *, Uint8 type, int state) =
	"\tlwz\t0,-478(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_EventState(type, state) __SDL_EventState(PowerSDLBase, (type), (state))

int __SDL_NumJoysticks(struct Library *) =
	"\tlwz\t0,-484(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_NumJoysticks() __SDL_NumJoysticks(PowerSDLBase)

const char * __SDL_JoystickName(struct Library *, int device_index) =
	"\tlwz\t0,-490(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickName(device_index) __SDL_JoystickName(PowerSDLBase, (device_index))

SDL_Joystick * __SDL_JoystickOpen(struct Library *, int device_index) =
	"\tlwz\t0,-496(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickOpen(device_index) __SDL_JoystickOpen(PowerSDLBase, (device_index))

int __SDL_JoystickOpened(struct Library *, int device_index) =
	"\tlwz\t0,-502(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickOpened(device_index) __SDL_JoystickOpened(PowerSDLBase, (device_index))

int __SDL_JoystickIndex(struct Library *, SDL_Joystick * joystick) =
	"\tlwz\t0,-508(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickIndex(joystick) __SDL_JoystickIndex(PowerSDLBase, (joystick))

int __SDL_JoystickNumAxes(struct Library *, SDL_Joystick * joystick) =
	"\tlwz\t0,-514(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickNumAxes(joystick) __SDL_JoystickNumAxes(PowerSDLBase, (joystick))

int __SDL_JoystickNumBalls(struct Library *, SDL_Joystick * joystick) =
	"\tlwz\t0,-520(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickNumBalls(joystick) __SDL_JoystickNumBalls(PowerSDLBase, (joystick))

int __SDL_JoystickNumHats(struct Library *, SDL_Joystick * joystick) =
	"\tlwz\t0,-526(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickNumHats(joystick) __SDL_JoystickNumHats(PowerSDLBase, (joystick))

int __SDL_JoystickNumButtons(struct Library *, SDL_Joystick * joystick) =
	"\tlwz\t0,-532(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickNumButtons(joystick) __SDL_JoystickNumButtons(PowerSDLBase, (joystick))

void __SDL_JoystickUpdate(struct Library *) =
	"\tlwz\t0,-538(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickUpdate() __SDL_JoystickUpdate(PowerSDLBase)

int __SDL_JoystickEventState(struct Library *, int state) =
	"\tlwz\t0,-544(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickEventState(state) __SDL_JoystickEventState(PowerSDLBase, (state))

Sint16 __SDL_JoystickGetAxis(struct Library *, SDL_Joystick * joystick, int axis) =
	"\tlwz\t0,-550(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickGetAxis(joystick, axis) __SDL_JoystickGetAxis(PowerSDLBase, (joystick), (axis))

Uint8 __SDL_JoystickGetHat(struct Library *, SDL_Joystick * joystick, int hat) =
	"\tlwz\t0,-556(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickGetHat(joystick, hat) __SDL_JoystickGetHat(PowerSDLBase, (joystick), (hat))

int __SDL_JoystickGetBall(struct Library *, SDL_Joystick * joystick, int ball, int * dx, int * dy) =
	"\tlwz\t0,-562(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickGetBall(joystick, ball, dx, dy) __SDL_JoystickGetBall(PowerSDLBase, (joystick), (ball), (dx), (dy))

Uint8 __SDL_JoystickGetButton(struct Library *, SDL_Joystick * joystick, int button) =
	"\tlwz\t0,-568(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickGetButton(joystick, button) __SDL_JoystickGetButton(PowerSDLBase, (joystick), (button))

void __SDL_JoystickClose(struct Library *, SDL_Joystick * joystick) =
	"\tlwz\t0,-574(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_JoystickClose(joystick) __SDL_JoystickClose(PowerSDLBase, (joystick))

int __SDL_EnableUNICODE(struct Library *, int enable) =
	"\tlwz\t0,-580(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_EnableUNICODE(enable) __SDL_EnableUNICODE(PowerSDLBase, (enable))

int __SDL_EnableKeyRepeat(struct Library *, int delay, int interval) =
	"\tlwz\t0,-586(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_EnableKeyRepeat(delay, interval) __SDL_EnableKeyRepeat(PowerSDLBase, (delay), (interval))

Uint8 * __SDL_GetKeyState(struct Library *, int * numkeys) =
	"\tlwz\t0,-592(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetKeyState(numkeys) __SDL_GetKeyState(PowerSDLBase, (numkeys))

SDLMod __SDL_GetModState(struct Library *) =
	"\tlwz\t0,-598(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetModState() __SDL_GetModState(PowerSDLBase)

void __SDL_SetModState(struct Library *, SDLMod modstate) =
	"\tlwz\t0,-604(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SetModState(modstate) __SDL_SetModState(PowerSDLBase, (modstate))

char * __SDL_GetKeyName(struct Library *, SDLKey key) =
	"\tlwz\t0,-610(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetKeyName(key) __SDL_GetKeyName(PowerSDLBase, (key))

Uint8 __SDL_GetMouseState(struct Library *, int * x, int * y) =
	"\tlwz\t0,-616(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetMouseState(x, y) __SDL_GetMouseState(PowerSDLBase, (x), (y))

Uint8 __SDL_GetRelativeMouseState(struct Library *, int * x, int * y) =
	"\tlwz\t0,-622(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetRelativeMouseState(x, y) __SDL_GetRelativeMouseState(PowerSDLBase, (x), (y))

void __SDL_WarpMouse(struct Library *, Uint16 x, Uint16 y) =
	"\tlwz\t0,-628(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_WarpMouse(x, y) __SDL_WarpMouse(PowerSDLBase, (x), (y))

SDL_Cursor * __SDL_CreateCursor(struct Library *, Uint8 * data, Uint8 * mask, int w, int h, int hot_x, int hot_y) =
	"\tlwz\t0,-634(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CreateCursor(data, mask, w, h, hot_x, hot_y) __SDL_CreateCursor(PowerSDLBase, (data), (mask), (w), (h), (hot_x), (hot_y))

void __SDL_SetCursor(struct Library *, SDL_Cursor * cursor) =
	"\tlwz\t0,-640(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SetCursor(cursor) __SDL_SetCursor(PowerSDLBase, (cursor))

SDL_Cursor * __SDL_GetCursor(struct Library *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tli\t3,-648\n"
	"\tblrl";
#define SDL_GetCursor() __SDL_GetCursor(PowerSDLBase)

void __SDL_FreeCursor(struct Library *, SDL_Cursor * cursor) =
	"\tlwz\t0,-652(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_FreeCursor(cursor) __SDL_FreeCursor(PowerSDLBase, (cursor))

int __SDL_ShowCursor(struct Library *, int toggle) =
	"\tlwz\t0,-658(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_ShowCursor(toggle) __SDL_ShowCursor(PowerSDLBase, (toggle))

Uint8 __SDL_GetAppState(struct Library *) =
	"\tlwz\t0,-664(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetAppState() __SDL_GetAppState(PowerSDLBase)

void __SDL_SetErrorA(struct Library *, const char * fmt, unsigned long * arglist) =
	"\tlwz\t0,-670(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SetErrorA(fmt, arglist) __SDL_SetErrorA(PowerSDLBase, (fmt), (arglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __SDL_SetError(struct Library *, long, long, long, long, long, long, const char * fmt, ...) =
	"\tlwz\t0,-670(3)\n"
  "\tmr\t4,10\n"
	"\taddi\t5,1,8\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SetError(...) __SDL_SetError(PowerSDLBase,0,0,0,0,0,0,__VA_ARGS__)
#endif

char * __SDL_GetError(struct Library *) =
	"\tlwz\t0,-676(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetError() __SDL_GetError(PowerSDLBase)

void __SDL_ClearError(struct Library *) =
	"\tlwz\t0,-682(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_ClearError() __SDL_ClearError(PowerSDLBase)

int __SDL_AudioInit(struct Library *, const char * driver_name) =
	"\tlwz\t0,-688(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_AudioInit(driver_name) __SDL_AudioInit(PowerSDLBase, (driver_name))

void __SDL_AudioQuit(struct Library *) =
	"\tlwz\t0,-694(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_AudioQuit() __SDL_AudioQuit(PowerSDLBase)

char * __SDL_AudioDriverName(struct Library *, char * namebuf, int maxlen) =
	"\tlwz\t0,-700(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_AudioDriverName(namebuf, maxlen) __SDL_AudioDriverName(PowerSDLBase, (namebuf), (maxlen))

int __SDL_OpenAudio(struct Library *, SDL_AudioSpec * desired, SDL_AudioSpec * obtained) =
	"\tlwz\t0,-706(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_OpenAudio(desired, obtained) __SDL_OpenAudio(PowerSDLBase, (desired), (obtained))

SDL_audiostatus __SDL_GetAudioStatus(struct Library *) =
	"\tlwz\t0,-712(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetAudioStatus() __SDL_GetAudioStatus(PowerSDLBase)

void __SDL_PauseAudio(struct Library *, int pause_on) =
	"\tlwz\t0,-718(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_PauseAudio(pause_on) __SDL_PauseAudio(PowerSDLBase, (pause_on))

SDL_AudioSpec * __SDL_LoadWAV_RW(struct Library *, SDL_RWops * src, int freesrc, SDL_AudioSpec * spec, Uint8 ** audio_buf, Uint32 * audio_len) =
	"\tlwz\t0,-724(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_LoadWAV_RW(src, freesrc, spec, audio_buf, audio_len) __SDL_LoadWAV_RW(PowerSDLBase, (src), (freesrc), (spec), (audio_buf), (audio_len))

void __SDL_FreeWAV(struct Library *, Uint8 * audio_buf) =
	"\tlwz\t0,-730(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_FreeWAV(audio_buf) __SDL_FreeWAV(PowerSDLBase, (audio_buf))

int __SDL_BuildAudioCVT(struct Library *, SDL_AudioCVT * cvt, Uint16 src_format, Uint8 src_channels, int src_rate, Uint16 dst_format, Uint8 dst_channels, int dst_rate) =
	"\tlwz\t0,-736(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_BuildAudioCVT(cvt, src_format, src_channels, src_rate, dst_format, dst_channels, dst_rate) __SDL_BuildAudioCVT(PowerSDLBase, (cvt), (src_format), (src_channels), (src_rate), (dst_format), (dst_channels), (dst_rate))

int __SDL_ConvertAudio(struct Library *, SDL_AudioCVT * cvt) =
	"\tlwz\t0,-742(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_ConvertAudio(cvt) __SDL_ConvertAudio(PowerSDLBase, (cvt))

void __SDL_MixAudio(struct Library *, Uint8 * dst, const Uint8 * src, Uint32 len, int volume) =
	"\tlwz\t0,-748(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_MixAudio(dst, src, len, volume) __SDL_MixAudio(PowerSDLBase, (dst), (src), (len), (volume))

void __SDL_LockAudio(struct Library *) =
	"\tlwz\t0,-754(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_LockAudio() __SDL_LockAudio(PowerSDLBase)

void __SDL_UnlockAudio(struct Library *) =
	"\tlwz\t0,-760(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_UnlockAudio() __SDL_UnlockAudio(PowerSDLBase)

void __SDL_CloseAudio(struct Library *) =
	"\tlwz\t0,-766(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CloseAudio() __SDL_CloseAudio(PowerSDLBase)

SDL_Thread * __SDL_CreateThread(struct Library *, int (*fn)(void *), void * data) =
	"\tlwz\t0,-772(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CreateThread(fn, data) __SDL_CreateThread(PowerSDLBase, (fn), (data))

Uint32 __SDL_ThreadID(struct Library *) =
	"\tlwz\t0,-778(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_ThreadID() __SDL_ThreadID(PowerSDLBase)

Uint32 __SDL_GetThreadID(struct Library *, SDL_Thread * thread) =
	"\tlwz\t0,-784(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_GetThreadID(thread) __SDL_GetThreadID(PowerSDLBase, (thread))

void __SDL_WaitThread(struct Library *, SDL_Thread * thread, int * status) =
	"\tlwz\t0,-790(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_WaitThread(thread, status) __SDL_WaitThread(PowerSDLBase, (thread), (status))

void __SDL_KillThread(struct Library *, SDL_Thread * thread) =
	"\tlwz\t0,-796(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_KillThread(thread) __SDL_KillThread(PowerSDLBase, (thread))

const SDL_version * __SDL_Linked_Version(struct Library *) =
	"\tlwz\t0,-802(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_Linked_Version() __SDL_Linked_Version(PowerSDLBase)

int __SDL_SoftStretch(struct Library *, SDL_Surface * src, SDL_Rect * srcrect, SDL_Surface * dest, SDL_Rect * dstrect) =
	"\tlwz\t0,-808(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_SoftStretch(src, srcrect, dest, dstrect) __SDL_SoftStretch(PowerSDLBase, (src), (srcrect), (dest), (dstrect))

CONST_STRPTR __SDL_UNIX2AMIGA(struct Library *, CONST_STRPTR file) =
	"\tlwz\t0,-814(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_UNIX2AMIGA(file) __SDL_UNIX2AMIGA(PowerSDLBase, (file))

SDL_RWops * __SDL_AMIGA_RWFromFile(struct Library *, const char * file, const char * mode) =
	"\tlwz\t0,-820(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_AMIGA_RWFromFile(file, mode) __SDL_AMIGA_RWFromFile(PowerSDLBase, (file), (mode))

SDL_RWops  * __SDL_AMIGA_RWFromFP(struct Library *, BPTR fp, int autoclose) =
	"\tlwz\t0,-826(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_AMIGA_RWFromFP(fp, autoclose) __SDL_AMIGA_RWFromFP(PowerSDLBase, (fp), (autoclose))

int __SDL_CDNumDrives(struct Library *) =
	"\tlwz\t0,-832(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CDNumDrives() __SDL_CDNumDrives(PowerSDLBase)

char * __SDL_CDName(struct Library *, int drive) =
	"\tlwz\t0,-838(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CDName(drive) __SDL_CDName(PowerSDLBase, (drive))

SDL_CD * __SDL_CDOpen(struct Library *, int drive) =
	"\tlwz\t0,-844(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CDOpen(drive) __SDL_CDOpen(PowerSDLBase, (drive))

CDstatus __SDL_CDStatus(struct Library *, SDL_CD * cdrom) =
	"\tlwz\t0,-850(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CDStatus(cdrom) __SDL_CDStatus(PowerSDLBase, (cdrom))

int __SDL_CDPlay(struct Library *, SDL_CD * cdrom, int sframe, int length) =
	"\tlwz\t0,-856(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CDPlay(cdrom, sframe, length) __SDL_CDPlay(PowerSDLBase, (cdrom), (sframe), (length))

int __SDL_CDPause(struct Library *, SDL_CD * cdrom) =
	"\tlwz\t0,-862(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CDPause(cdrom) __SDL_CDPause(PowerSDLBase, (cdrom))

int __SDL_CDResume(struct Library *, SDL_CD * cdrom) =
	"\tlwz\t0,-868(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CDResume(cdrom) __SDL_CDResume(PowerSDLBase, (cdrom))

int __SDL_CDStop(struct Library *, SDL_CD * cdrom) =
	"\tlwz\t0,-874(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CDStop(cdrom) __SDL_CDStop(PowerSDLBase, (cdrom))

int __SDL_CDEject(struct Library *, SDL_CD * cdrom) =
	"\tlwz\t0,-880(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CDEject(cdrom) __SDL_CDEject(PowerSDLBase, (cdrom))

void __SDL_CDClose(struct Library *, SDL_CD * cdrom) =
	"\tlwz\t0,-886(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CDClose(cdrom) __SDL_CDClose(PowerSDLBase, (cdrom))

void * __SDL_CreateMutex(struct Library *) =
	"\tlwz\t0,-892(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_CreateMutex() __SDL_CreateMutex(PowerSDLBase)

void __SDL_DestroyMutex(struct Library *, void * mutex) =
	"\tlwz\t0,-898(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_DestroyMutex(mutex) __SDL_DestroyMutex(PowerSDLBase, (mutex))

int __SDL_mutexP(struct Library *, void * mutex) =
	"\tlwz\t0,-904(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_mutexP(mutex) __SDL_mutexP(PowerSDLBase, (mutex))

int __SDL_mutexV(struct Library *, void * mutex) =
	"\tlwz\t0,-910(3)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define SDL_mutexV(mutex) __SDL_mutexV(PowerSDLBase, (mutex))

#endif /*  _VBCCINLINE_POWERSDL_H  */
