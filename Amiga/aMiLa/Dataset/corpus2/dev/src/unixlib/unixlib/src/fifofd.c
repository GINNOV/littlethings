#include "amiga.h"
#include "files.h"
#include "fifofd.h"
#include <time.h>

struct Library *_FifoBase;
int _fifo_sig = -1;
long _fifo_base;
long _fifo_offset;
int _fifo_ok;

void _init_fifo(void)
{
  _fifo_base = (int)_us ^ _startup_time * 65537;
  _fifo_offset = 0;
  _FifoBase = OpenLibrary("fifo.library", 0);
  _fifo_sig = AllocSignal(-1);
  _fifo_ok = _FifoBase != 0 && _fifo_sig >= 0;
}

void _cleanup_fifo(void)
{
  if (_fifo_sig >= 0) FreeSignal(_fifo_sig);
  if (_FifoBase) CloseLibrary(_FifoBase);
}
