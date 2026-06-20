#ifndef _SGESCREEN_H
#define _SGESCREEN_H

SDL_Surface *screen;

void sgeOpenScreen(const char *title, int width, int height, int depth, int fullscreen);
void sgeCloseScreen(void);

void sgeHideMouse(void);
void sgeShowMouse(void);

#endif
