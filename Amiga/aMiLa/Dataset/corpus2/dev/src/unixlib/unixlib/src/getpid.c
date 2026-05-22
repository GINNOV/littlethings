#include "amiga.h"
#include "signals.h"
#include "processes.h"

int getpid(void)
{
  chkabort();
  return _our_pid;
}
