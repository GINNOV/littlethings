#ifndef _SGEGAMESTATE_H
#define _SGEGAMESTATE_H

struct _SGEGAMESTATE;

typedef struct {
	int quit;
	SGEEVENTSTATE event_state;
	struct _SGEGAMESTATE *current;
} SGEGAMESTATEMANAGER;

typedef struct _SGEGAMESTATE {
	SGEGAMESTATEMANAGER *manager;
	void *data;
	void (*onRedraw)(struct _SGEGAMESTATE *state);
	int (*onStateChange)(struct _SGEGAMESTATE *state, struct _SGEGAMESTATE* previous);
} SGEGAMESTATE;

SGEGAMESTATEMANAGER* sgeGameStateManagerNew(void);
int sgeGameStateManagerChange(SGEGAMESTATEMANAGER *, SGEGAMESTATE *);
void sgeGameStateManagerRun(SGEGAMESTATEMANAGER*, int);
void sgeGameStateManagerQuit(SGEGAMESTATEMANAGER*);

SGEGAMESTATE* sgeGameStateNew(void);

#endif
