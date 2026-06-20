#ifndef _SGEINIT_H
#define _SGEINIT_H

extern SDL_Joystick *defaultjoystick;

void sgeInit(int useAudio, int useJoystick);
void sgeTerminate(void);

#endif
