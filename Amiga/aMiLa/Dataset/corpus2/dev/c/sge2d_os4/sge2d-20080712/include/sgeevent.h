#ifndef _SGEEVENT_H
#define _SGEEVENT_H

#define PRESSED 1
#define RELEASED 2

typedef struct {
	Uint32 held;
	Uint32 pressed;
	Uint32 released;
} SGEEVENTSTATEINPUT;

typedef struct {
	SGEEVENTSTATEINPUT up;
	SGEEVENTSTATEINPUT down;
	SGEEVENTSTATEINPUT right;
	SGEEVENTSTATEINPUT left;
	SGEEVENTSTATEINPUT start;
	SGEEVENTSTATEINPUT select;
	SGEEVENTSTATEINPUT fire;
	SGEEVENTSTATEINPUT l1;
	SGEEVENTSTATEINPUT r1;
	SGEEVENTSTATEINPUT a;
	SGEEVENTSTATEINPUT b;
	SGEEVENTSTATEINPUT x;
	SGEEVENTSTATEINPUT y;
	SGEEVENTSTATEINPUT volUp;
	SGEEVENTSTATEINPUT volDown;
} SGEEVENTSTATE;

int sgeKeyUp(SDL_Event *e, int type);
int sgeKeyDown(SDL_Event *e, int type);
int sgeKeyLeft(SDL_Event *e, int type);
int sgeKeyRight(SDL_Event *e, int type);
int sgeKeyStart(SDL_Event *e, int type);
int sgeKeySelect(SDL_Event *e, int type);
int sgeKeyFire(SDL_Event *e, int type);
int sgeKeyL1(SDL_Event *e, int type);
int sgeKeyR1(SDL_Event *e, int type);
int sgeKeyA(SDL_Event *e, int type);
int sgeKeyB(SDL_Event *e, int type);
int sgeKeyX(SDL_Event *e, int type);
int sgeKeyY(SDL_Event *e, int type);
int sgeKeyVolUp(SDL_Event *e, int type);
int sgeKeyVolDown(SDL_Event *e, int type);

void sgeClearEvents(void);
void sgeEventApply(SGEEVENTSTATE *state, SDL_Event *event);
void sgeEventResetInputs(SGEEVENTSTATE *state);

#endif
