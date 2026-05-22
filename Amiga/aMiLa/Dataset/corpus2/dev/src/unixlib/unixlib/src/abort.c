#include "amiga.h"
#include <signal.h>

extern void _close_all(void);

void abort(void)
{
  chkabort();
  _close_all();
  kill(getpid(), SIGIOT);
}
