#include "amiga.h"
#include "signals.h"

long sigsetmask(long mask)
{
  int oldmask = _sig_mask, i, imask;

  chkabort();
  _sig_mask = mask;

  /* Check all pending signals */
  for (i = 0, imask = 1; i < NSIG; i++, imask <<= 1)
    if ((_sig_pending & imask) && !(_sig_mask & imask))
      _sig_dispatch(i);

  return oldmask;
}
