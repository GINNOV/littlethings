#include "amiga.h"
#include "signals.h"

void (*signal(int sig, void (*fn) (int))) (int)
{
    void (*oldfn) (int);

    __chkabort();
    if (sig >= 0 && sig < NSIG) {
	oldfn = _sig_handlers[sig];
	_sig_handlers[sig] = fn;
    } else
	oldfn = SIG_ERR;

    return oldfn;
}
