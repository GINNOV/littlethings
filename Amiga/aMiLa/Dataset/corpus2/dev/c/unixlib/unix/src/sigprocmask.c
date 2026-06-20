#include "amiga.h"
#include "signals.h"

/*
 * Manipulate signal mask.
 */

int
sigprocmask (int how, const sigset_t *mask, sigset_t *omask)
{
    int i, imask;

    __chkabort();

    if (omask)
    	*omask = _sig_mask;

    if (mask) {
    	switch (how) {
	    case SIG_BLOCK:
	    	_sig_mask |= *mask;
		break;
	    case SIG_UNBLOCK:
	    	_sig_mask &= ~*mask;
		break;
	    case SIG_SETMASK:
	    	_sig_mask = *mask;
		break;
	    default:
	    	errno = EINVAL;
		return -1;
	}
	/* Check all pending signals */
	for (i = 0, imask = 1; i < NSIG; i++, imask <<= 1)
	    if ((_sig_pending & imask) && !(_sig_mask & imask))
		_sig_dispatch(i);
    }

    return 0;
}
