#include <sge.h>

Uint32 sgeGlobalFPS=0;

SGETIMER sgeAddTimer(int ms, void *function) {
	SGETIMER ret;
	if ((ret=SDL_AddTimer(ms, function, NULL))==NULL) {
		sgeBailOut("Error adding timer %s\n", "" );
	}
	return ret;
}

static Uint32 sgeRedrawTimer(Uint32 interval, void *param) {
	SDL_Event event;
	SDL_UserEvent uevent;

	uevent.type = SDL_USEREVENT;
	uevent.code = SGEREDRAW;
	uevent.data1 = NULL;
	uevent.data2 = NULL; 
	event.type = SDL_USEREVENT;
	event.user = uevent;
	SDL_PushEvent (&event);
	return interval;
}

SGETIMER sgeStartRedrawTimer(int fps) {
	sgeGlobalFPS=fps;
	return sgeAddTimer(1000/fps, sgeRedrawTimer);
}

void sgeStopRedrawTimer(SGETIMER sgetimer) {
	sgeRemoveTimer(sgetimer);
}

Uint32 sgeGetFPS() {
	return sgeGlobalFPS;
}

