#include <sge.h>

SDL_Surface *screen;

void sgeOpenScreen(const char *title, int width, int height, int depth, int fullscreen) {
	Uint32 flags=_DEFAULT_VIDEOMODE_FLAGS_;

	if (fullscreen) {
		flags|=SDL_FULLSCREEN;
	}

	screen=SDL_SetVideoMode(width, height, depth, flags);
	if (screen==NULL) {
		sgeBailOut("error opening screen: %s\n", SDL_GetError());
	}
	SDL_WM_SetCaption(title, NULL);
}

void sgeHideMouse() {
	SDL_ShowCursor(SDL_DISABLE);
}

void sgeShowMouse() {
	SDL_ShowCursor(SDL_ENABLE);
}

void sgeCloseScreen() {
}
