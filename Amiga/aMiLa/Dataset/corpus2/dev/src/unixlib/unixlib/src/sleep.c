#include "amiga.h"
#include "timers.h"
#include "signals.h"

int sleep(unsigned seconds)
{
  chkabort();
  _timer_start(_odd_timer, seconds, 0);

  while (!_timer_expired(_odd_timer)) _handle_signals(_wait_signals(_odd_sig));

  return 0;
}
