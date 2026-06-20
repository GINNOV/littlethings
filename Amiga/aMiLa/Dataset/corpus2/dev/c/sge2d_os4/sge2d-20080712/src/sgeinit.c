#include <sge.h>

SDL_Joystick *defaultjoystick;

void sgeInit(int useAudio, int useJoystick) {
	time_t now;
	Uint32 flags=SDL_INIT_VIDEO|SDL_INIT_TIMER;
	if (useAudio) flags|=SDL_INIT_AUDIO;
#ifdef GP2X
	flags|=SDL_INIT_JOYSTICK; // force joystick on gp2x
	useJoystick=1;
#else
	if (useJoystick) flags|=SDL_INIT_JOYSTICK;
#endif

	if (SDL_Init (flags) < 0) {
		sgeBailOut("cannot initialize SDL: %s\n", SDL_GetError ());
	}
	atexit(sgeTerminate);

	if (useJoystick) {
		if (SDL_NumJoysticks() > 0) {
			defaultjoystick = SDL_JoystickOpen(0);
			if(!defaultjoystick) {
				fprintf (stderr, "cannot open joystick 0: %s\n", SDL_GetError ());
			}
		}
	}

	if (useAudio) {
		if (Mix_OpenAudio(sgeGetDefaultSampleRate(), MIX_DEFAULT_FORMAT, 2, 2048)==-1) {
			sgeBailOut("cannot initialize iibmixer: %s\n", Mix_GetError());
		}
	}

	time(&now);
	srand((unsigned int)now);
}

void sgeTerminate() {
	if (SDL_WasInit(SDL_INIT_AUDIO)) {
		Mix_HaltChannel(-1);
#if !defined(MORPHOS) && !defined(__amigaos4__)
		Mix_CloseAudio();
#endif
	}
	SDL_Quit();
#ifdef GP2X
	chdir("/usr/gp2x");
	execl("/usr/gp2x/gp2xmenu", "/usr/gp2x/gp2xmenu", NULL);
#endif
}

extern int run(int argc, char *argv[]);
int main(int argc, char *argv[]) {
	return run(argc, argv);
}
