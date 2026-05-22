#ifndef _SGECONTROL_H
#define _SGECONTROL_H

#define SGEREDRAW 0xf00

#define SGETIMER SDL_TimerID
#define sgeRemoveTimer(timer) SDL_RemoveTimer(timer)
#define sgeGameLoop(event,quitvar) while ((SDL_WaitEvent(&event)&&(!quit)))

#define sgeStartGame(function, fps) \
	SGETIMER t=sgeStartRedrawTimer(fps);\
	function();\
	sgeStopRedrawTimer(t);

SDL_TimerID sgeAddTimer(int ms, void *function);
SGETIMER sgeStartRedrawTimer(int fps);
void sgeStopRedrawTimer(SGETIMER sgetimer);
Uint32 sgeGetFPS(void);

#endif
