#include "amiga.h"
#include "signals.h"

void (*signal(int sig,void (*fn)(int)))(int)
{
  void (*oldfn)(int);

  chkabort();
  if (sig >= 0 && sig < NSIG)
    {
      oldfn = _sig_handlers[sig];
      _sig_handlers[sig] = fn;
    }
  else oldfn = 0;

  return oldfn;
}
