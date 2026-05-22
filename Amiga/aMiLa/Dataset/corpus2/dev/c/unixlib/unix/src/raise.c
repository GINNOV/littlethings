#include "amiga.h"
#include "signals.h"

int raise(int sig)
{
    if (sig < 0 || sig >= NSIG) {
	errno = EINVAL;
	return -1;
    }

    return(kill(getpid(), sig));
}
