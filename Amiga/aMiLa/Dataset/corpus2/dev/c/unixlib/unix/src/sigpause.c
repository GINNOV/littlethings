
#include "amiga.h"
#include "signals.h"

int sigpause(long mask)
{
    long oldmask = sigsetmask(mask);
    ULONG sigs;

    sigs = _check_signals(0);
    while (!_handle_signals(sigs))
	sigs = _wait_signals(0);

    sigsetmask(oldmask);

    errno = EINTR;
    return -1;
}
