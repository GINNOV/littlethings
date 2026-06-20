#include <sge.h>

enum sgeKey {
	sgeUpKey=SDLK_UP,
	sgeDownKey=SDLK_DOWN,
	sgeLeftKey=SDLK_LEFT,
	sgeRightKey=SDLK_RIGHT,
	sgeStartKey=SDLK_RETURN,
	sgeSelectKey=SDLK_BACKSPACE,
	sgeFireKey=SDLK_SPACE,
	sgeL1Key=SDLK_COMMA,
	sgeR1Key=SDLK_PERIOD,
	sgeAKey=SDLK_v,
	sgeBKey=SDLK_b,
	sgeXKey=SDLK_n,
	sgeYKey=SDLK_m,
	sgeVolUpKey=SDLK_PLUS,
	sgeVolDownKey=SDLK_MINUS
};

enum sgeJoy {
	sgeUpJoy=VK_UP,
	sgeDownJoy=VK_DOWN,
	sgeLeftJoy=VK_LEFT,
	sgeRightJoy=VK_RIGHT,
	sgeStartJoy=VK_START,
	sgeSelectJoy=VK_SELECT,
	sgeFireJoy=VK_TAT,
	sgeL1Joy=VK_FL,
	sgeR1Joy=VK_FR,
	sgeAJoy=VK_FA,
	sgeBJoy=VK_FB,
	sgeXJoy=VK_FX,
	sgeYJoy=VK_FY,
	sgeVolUpJoy=VK_VOL_UP,
	sgeVolDownJoy=VK_VOL_DOWN
};

static int sgeKeyCheck(SDL_Event *e, enum sgeKey key, enum sgeJoy joy, int type) {
	if (
			(e->type==SDL_KEYUP) ||
			(e->type==SDL_JOYBUTTONUP) ||
			(e->type==SDL_KEYDOWN) ||
			(e->type==SDL_JOYBUTTONDOWN)
	) {
		if (
				((type==PRESSED) && (e->type==SDL_KEYDOWN) && (e->key.keysym.sym==key)) ||
				((type==PRESSED) && (e->type==SDL_JOYBUTTONDOWN) && (e->jbutton.button==joy))
		) {
			return 1;
		}
		if (
				((type==RELEASED) && (e->type==SDL_KEYUP) && (e->key.keysym.sym==key)) ||
				((type==RELEASED) && (e->type==SDL_JOYBUTTONUP) && (e->jbutton.button==joy))
		) {
			return 1;
		}
	}
	return 0;
}

int sgeKeyUp(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeUpKey, sgeUpJoy, type);
}

int sgeKeyDown(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeDownKey, sgeDownJoy, type);
}

int sgeKeyLeft(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeLeftKey, sgeLeftJoy, type);
}

int sgeKeyRight(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeRightKey, sgeRightJoy, type);
}

int sgeKeyStart(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeStartKey, sgeStartJoy, type);
}

int sgeKeySelect(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeSelectKey, sgeSelectJoy, type);
}

int sgeKeyFire(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeFireKey, sgeFireJoy, type);
}

int sgeKeyL1(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeL1Key, sgeL1Joy, type);
}

int sgeKeyR1(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeR1Key, sgeR1Joy, type);
}

int sgeKeyA(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeAKey, sgeAJoy, type);
}

int sgeKeyB(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeBKey, sgeBJoy, type);
}

int sgeKeyX(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeXKey, sgeXJoy, type);
}

int sgeKeyY(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeYKey, sgeYJoy, type);
}

int sgeKeyVolUp(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeVolUpKey, sgeVolUpJoy, type);
}

int sgeKeyVolDown(SDL_Event *e, int type) {
	return sgeKeyCheck(e, sgeVolDownKey, sgeVolDownJoy, type);
}

void sgeClearEvents() {
	SDL_Event dummy;
	while (SDL_PollEvent(&dummy)) {}
}

static void state_check(SGEEVENTSTATEINPUT *input, SDL_Event *event, enum sgeKey key, enum sgeJoy joy)
{
	if ((event->type==SDL_KEYDOWN && event->key.keysym.sym==key) || (event->type==SDL_JOYBUTTONDOWN && event->jbutton.button==joy)) {
		input->held = 1;
		input->pressed =1;
	}
	if ((event->type==SDL_KEYUP && event->key.keysym.sym==key) || (event->type==SDL_JOYBUTTONUP && event->jbutton.button==joy)) {
		input->held = 0;
		input->released = 1;
	}
}

void sgeEventApply(SGEEVENTSTATE *state, SDL_Event *event)
{
	switch (event->type) {
		case SDL_KEYDOWN:
		case SDL_KEYUP:
		case SDL_JOYBUTTONUP:
		case SDL_JOYBUTTONDOWN:
			state_check(&state->up, event, sgeUpKey, sgeUpJoy);
			state_check(&state->down, event, sgeDownKey, sgeDownJoy);
			state_check(&state->left, event, sgeLeftKey, sgeLeftJoy);
			state_check(&state->right, event, sgeRightKey, sgeRightJoy);
			state_check(&state->start, event, sgeStartKey, sgeStartJoy);
			state_check(&state->select, event, sgeSelectKey, sgeSelectJoy);
			state_check(&state->fire, event, sgeFireKey, sgeFireJoy);
			state_check(&state->l1, event, sgeL1Key, sgeL1Joy);
			state_check(&state->r1, event, sgeR1Key, sgeR1Joy);
			state_check(&state->a, event, sgeAKey, sgeAJoy);
			state_check(&state->b, event, sgeBKey, sgeBJoy);
			state_check(&state->x, event, sgeXKey, sgeXJoy);
			state_check(&state->y, event, sgeYKey, sgeYJoy);
			state_check(&state->volUp, event, sgeVolUpKey, sgeVolUpJoy);
			state_check(&state->volDown, event, sgeVolDownKey, sgeVolDownJoy);
	}
}

void sgeEventResetInputs(SGEEVENTSTATE *state)
{
	state->up.pressed = state->up.released = 0;
	state->down.pressed = state->down.released = 0;
	state->left.pressed = state->left.released = 0;
	state->right.pressed = state->right.released = 0;
	state->start.pressed = state->start.released = 0;
	state->select.pressed = state->select.released = 0;
	state->fire.pressed = state->fire.released = 0;
	state->l1.pressed = state->l1.released = 0;
	state->r1.pressed = state->r1.released = 0;
	state->a.pressed = state->a.released = 0;
	state->b.pressed = state->b.released = 0;
	state->x.pressed = state->x.released = 0;
	state->y.pressed = state->y.released = 0;
	state->volUp.pressed = state->volUp.released = 0;
	state->volDown.pressed = state->volDown.released = 0;
}

