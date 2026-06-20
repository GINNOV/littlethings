#include "amiga.h"
#include "devices.h"
#include "timers.h"

struct timeinfo *_alloc_timer(void)
{
  struct timeinfo *timer = AllocMem(sizeof(struct timeinfo), 0);

  if (!timer) return 0;
  timer->sent = FALSE;
  timer->io = (struct timerequest *)
    _device_open("timer.device", UNIT_VBLANK, 0L, 0L, 0, sizeof(struct timerequest));
  if (!timer->io)
    {
      FreeMem(timer, sizeof(struct timeinfo));
      return 0;
    }
  return timer;
}

void _free_timer(struct timeinfo *timer)
{
  if (timer)
    {
      _timer_abort(timer);
      _device_close(timer->io);
      FreeMem(timer, sizeof(struct timeinfo));
    }
}

void _timer_abort(struct timeinfo *timer)
{
  if (timer->sent)
    {
      AbortIO(timer->io);
      WaitIO(timer->io);
      /* Clear timer io signal */
      /*SetSignal(0, timer_sig(timer));*/
      timer->sent = FALSE;
    }
}

ULONG _timer_sig(struct timeinfo *timer)
{
  return 1UL << timer->io->tr_node.io_Message.mn_ReplyPort->mp_SigBit;
}

void _timer_start(struct timeinfo *timer, int secs, int micros)
/* _timer_start(timer, 0) stops a timer */
{
  _timer_abort(timer);
  if (secs || micros)
    {
      timer->io->tr_time.tv_secs = secs;
      timer->io->tr_time.tv_micro = micros;
      timer->io->tr_node.io_Command = TR_ADDREQUEST;
      SendIO(timer->io);
      timer->sent = TRUE;
    }
}

int _timer_expired(struct timeinfo *timer)
/* A non-started timer is defined to not have expired */
{
  if (timer->sent && CheckIO(timer->io))
    {
      WaitIO(timer->io);
      timer->sent = FALSE;
      return TRUE;
    }
  return FALSE;
}
