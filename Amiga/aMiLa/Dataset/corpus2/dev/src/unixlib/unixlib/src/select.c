#include "amiga.h"
#include "files.h"
#include "signals.h"
#include "timers.h"
#include <sys/time.h>

int select(int nfds, int *rfds, int *wfds, int *efds, struct timeval *timeout)
{
  int fdmask, i, fdcount;
  int poll = timeout && timeout->tv_sec == 0 && timeout->tv_usec == 0;
  ULONG eventmask, sigs;
  int orfds = rfds ? *rfds : 0, owfds = wfds ? *wfds : 0, oefds = efds ? *efds : 0;
  
  for (i = 0, fdmask = 1; i < nfds; i++, fdmask <<= 1)
    {
      int rd = orfds & fdmask, wr = owfds & fdmask;

  chkabort();
      if (rd || wr)
	{
	  struct fileinfo *fi = _find_fd(i);

	  if (!fi) return -1;
	  if (rd && !(fi->flags & FI_READ) || wr && !(fi->flags & FI_WRITE))
	    {
	      errno = EACCES;
	      return -1;
	    }
	}
    }

  if (timeout) _timer_start(_odd_timer, timeout->tv_sec, timeout->tv_usec);
  else _timer_abort(_odd_timer);
  fdcount = 0;
  do
    {
      eventmask = 0;
      for (i = 0, fdmask = 1; i < nfds; i++, fdmask <<= 1)
	{
	  int rd = orfds & fdmask, wr = owfds & fdmask;

	  if (rd || wr)
	    {
	      struct fileinfo *fi = _find_fd(i);

	      eventmask |= fi->select_start(fi->userinfo, rd, wr);
	    }
	}

      if (eventmask == -1 || poll) /* Don't wait */ sigs = _check_signals(0);
      else /* Wait*/ sigs = _wait_signals(_odd_sig | eventmask);

      for (i = 0, fdmask = 1; i < nfds; i++, fdmask <<= 1)
	{
	  int rd = orfds & fdmask, wr = owfds & fdmask;

	  if (rd || wr)
	    {
	      struct fileinfo *fi = _find_fd(i);

	      fi->select_poll(fi->userinfo, &rd, &wr);
	      if (!rd && rfds) *rfds &= ~fdmask;
	      if (!wr && wfds) *wfds &= ~fdmask;
	      if (rd || wr) fdcount++;
	    }
	}
      _handle_signals(sigs);
    }
  while (fdcount == 0 && !_timer_expired(_odd_timer) && !poll);

  return fdcount;
}
