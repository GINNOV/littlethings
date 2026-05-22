#include "amiga.h"
#include "files.h"
#include "signals.h"
#include "timers.h"
#include <string.h>
#include <sys/time.h>
#include <amiga/ioctl.h>

int
select(int nfds, fd_set *rfds, fd_set *wfds, fd_set *efds, struct timeval *to)
{
    int i, j, fdcount, err = 0;
    int poll = to && to->tv_sec == 0 && to->tv_usec == 0;
    ULONG eventmask, sigs;
    int *rd, *wr, *ex, *ck;
    struct fileinfo **fi = calloc(5*nfds, sizeof(struct fileinfo *));

    if (!fi) {
	errno = ENOMEM;
	return -1;
    }
    rd = (int *)(fi + nfds);
    wr = rd + nfds;
    ex = wr + nfds;
    ck = ex + nfds;

    for (i = 0, j = 0; i < nfds; i++) {
	__chkabort();

	if (rfds && FD_ISSET(i, rfds)) {
	    rd[j] = i;
	    ck[j] |= 1;
	}
	if (wfds && FD_ISSET(i, wfds)) {
	    wr[j] = i;
	    ck[j] |= 2;
	}
	if (efds && FD_ISSET(i, efds)) {
	    ex[j] = i;
	    ck[j] |= 4;
	}

	if (ck[j]) {
	    fi[j] = _find_fd(i);

	    if (!fi[j]) {
		free(fi);
		return -1;
	    }
	    if (((ck[j] & 1) && !(fi[j]->flags & FI_READ)) ||
		    ((ck[j] & 2) && !(fi[j]->flags & FI_WRITE))) {
		errno = EACCES;
		free(fi);
		return -1;
	    }
	    j++;
	}
    }

    if (to)
	_timer_start(_odd_timer, to->tv_sec, to->tv_usec);
    else
	_timer_abort(_odd_timer);

    fdcount = 0;

    do {
	eventmask = 0;
	for (i = 0; i < j; i++)
	    eventmask |= fi[i]->select_start(fi[i]->userinfo,
		    ck[i] & 1, ck[i] & 2, ck[i] & 4);

	if (eventmask == -1 || poll)	/* Don't wait */
	    sigs = _check_signals(0);
	else				/* Wait */
	    sigs = _wait_signals(_odd_sig | eventmask);

	for (i = 0; i < j; i++) {
	    int r = ck[i] & 1, w = ck[i] & 2, e = ck[i] & 4;

	    if (fi[i]->select_poll(fi[i]->userinfo, &r, &w, &e) < 0)
		err = 1;
	    if (!err) {
		if (!r && rfds)
		    FD_CLR(rd[i], rfds);
		if (!w && wfds)
		    FD_CLR(wr[i], wfds);
		if (!e && efds)
		    FD_CLR(ex[i], efds);
		if (r || w || e)
		    fdcount++;
	    }
	}
	_handle_signals(sigs);
    } while (fdcount == 0 && !_timer_expired(_odd_timer) && !poll && !err);

    free(fi);

    if (err)
	return -1;

    return fdcount;
}
