#include <sge.h>
#include <assert.h>

SGEGAMESTATEMANAGER* sgeGameStateManagerNew(void)
{
	SGEGAMESTATEMANAGER *ret;
	sgeNew(ret, SGEGAMESTATEMANAGER);
	return ret;
}

SGEGAMESTATE* sgeGameStateNew(void)
{
	SGEGAMESTATE *ret;
	sgeNew(ret, SGEGAMESTATE);
	return ret;
}

void sgeGameStateManagerQuit(SGEGAMESTATEMANAGER *manager)
{
	manager->quit = 1;
}

int sgeGameStateManagerChange(SGEGAMESTATEMANAGER *manager, SGEGAMESTATE *next_state)
{
	if (manager->current && manager->current->onStateChange) {
		if (!manager->current->onStateChange(manager->current, next_state)) {
			return 0;
		}
	}
	manager->current = next_state;
	next_state->manager = manager;
	return 1;
}

void sgeGameStateManagerRun(SGEGAMESTATEMANAGER *manager, int fps)
{
	SDL_Event event;
	SGETIMER t;
	sgeClearEvents();
	t=sgeStartRedrawTimer(fps);

	assert(manager->current);
	manager->quit = 0;

	while (SDL_WaitEvent(&event) && !manager->quit) {
		switch (event.type) {
			case SDL_USEREVENT:
				if (event.user.code==SGEREDRAW && manager->current->onRedraw) {
					manager->current->onRedraw(manager->current);
				}
				sgeEventResetInputs(&manager->event_state);
				break;
			case SDL_KEYDOWN:
			case SDL_KEYUP:
			case SDL_JOYBUTTONUP:
			case SDL_JOYBUTTONDOWN:
				sgeEventApply(&manager->event_state, &event);
				break;
			case SDL_QUIT:
				manager->quit = 1;
				break;
		}
	}

	sgeStopRedrawTimer(t);
}
