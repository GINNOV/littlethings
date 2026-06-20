#include "amiga.h"
#include "files.h"
#include "fifofd.h"
#include "signals.h"
#include "timers.h"
#include <fcntl.h>

void _close_all(void)
{
  int fd, lfd = _last_fd();

  for (fd = 0; fd < lfd; fd++) close(fd);
}

void _exit(int rc)
{
  _close_all();
  _cleanup_fifo();
  _cleanup_signals();
  _free_timer(_odd_timer);
  XCEXIT(rc);
}
