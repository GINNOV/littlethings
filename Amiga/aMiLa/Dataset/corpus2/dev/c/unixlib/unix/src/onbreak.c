#include "amiga.h"
#include "signals.h"

static int brk(void);
int (*_break_func)(void) = brk;

static int brk(void)
{
    void (*sigint_func)(int);

    sigint_func = _sig_handlers[SIGINT];

    switch ((int)sigint_func) {
	case (int)SIG_DFL:
	    return 1;
	case (int)SIG_IGN:
	    return 0;
	default:
	    sigint_func(SIGINT);
    }
    return 0;
}

int onbreak(int (*func)(void))
{
    if (func == NULL)
	_break_func = brk;
    else
	_break_func = func;
    return 0;	/* to be compatible with SAS/C onbreak() */
}
