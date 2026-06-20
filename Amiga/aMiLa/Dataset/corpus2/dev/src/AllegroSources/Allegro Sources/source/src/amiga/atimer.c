/*         ______   ___    ___
 *        /\  _  \ /\_ \  /\_ \
 *        \ \ \L\ \\//\ \ \//\ \      __     __   _ __   ___
 *         \ \  __ \ \ \ \  \ \ \   /'__`\ /'_ `\/\`'__\/ __`\
 *          \ \ \/\ \ \_\ \_ \_\ \_/\  __//\ \L\ \ \ \//\ \L\ \
 *           \ \_\ \_\/\____\/\____\ \____\ \____ \ \_\\ \____/
 *            \/_/\/_/\/____/\/____/\/____/\/___L\ \/_/ \/___/
 *                                           /\____/
 *                                           \_/__/
 *
 *      Amiga OS timer module.
 *
 *      By Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#include "allegro.h"
#include "allegro/internal/aintern.h"
#include <proto/dos.h>
#include <proto/exec.h>
#include "athread.h"
#include "agraphics.h"

static struct AmiThread gTimerThread;	/* Thread used for timer callbacks */
static struct timeval gInitialTime;		/* Marks the time Allegro was initialised, for al_current_time() */

/* readability typedefs */
typedef long msecs_t;
typedef long usecs_t;

/* forward declarations */
static usecs_t timer_thread_handle_tick(usecs_t interval);

static int timer_thread_init(struct AmiThread *aAmiThread);

static void timer_thread_func(struct AmiThread *aAmiThread);

struct AL_TIMER
{
   int started;
   usecs_t speed_usecs;
   long count;
   long counter;		/* counts down to zero=blastoff */
};

static int timer_init()
{
	/* Create a thread for handling acynchronous timer requests and return 0 if it was */
	/* created successfully, or 1 if it wasn't */

	return((amithread_create(&gTimerThread, timer_thread_init, timer_thread_func, NULL) != 0) ? 0 : 1);
}

static void timer_exit()
{
	amithread_destroy(&gTimerThread);
}



/* _al_unix_init_time:
 *  Called by the system driver to mark the beginning of time.
 */
void _al_unix_init_time(void)
{
   gettimeofday(&gInitialTime, NULL);
}



/* time_current_time:
 *  Return the current time, in milliseconds, since some arbitrary
 *  point in time.
 */
unsigned long time_current_time(void)
{
   struct timeval now;

   gettimeofday(&now, NULL);

   return ((now.tv_sec  - gInitialTime.tv_sec)  * 1000 +
		   (now.tv_usec - gInitialTime.tv_usec) / 1000);
}

static int timer_thread_init(struct AmiThread *aAmiThread)
{
	(void) aAmiThread;

	return(amithread_add_sender(&gGraphicsThread));
}

/* timer_thread_proc: [timer thread]
 *  The timer thread procedure itself.
 */
static void timer_thread_func(struct AmiThread *aAmiThread)
{
	usecs_t Interval;
	ULONG Signal, ThreadSignal, TimerSignal;
	struct timeval OldTime, NewTime;

	/* Determine the time at which the first timer request was made so we can determine the */
	/* real interval of the timer when it is called back, thus avoiding drift */

	gettimeofday(&OldTime, NULL);

	/* And request a timer callback after 1 MS, just to kickstart the timer processing.  Allegro's */
	/* tick counter will handle calculating how often to call the callback in the future */

	amithread_request_timeout(aAmiThread, 1000);

	ThreadSignal = (1 << aAmiThread->at_ThreadSignalBit);
	TimerSignal = (1 << aAmiThread->at_TimerMsgPort->mp_SigBit);

	for ( ; ; )
	{
		Signal = IExec->Wait(ThreadSignal | TimerSignal);

		if (Signal & ThreadSignal)
		{
			break;
		}

		if (Signal & TimerSignal)
		{
			/* Calculate actual time elapsed */

			gettimeofday(&NewTime, NULL);
			Interval = ((NewTime.tv_sec - OldTime.tv_sec) * 1000000 + (NewTime.tv_usec - OldTime.tv_usec));
			OldTime = NewTime;

			/* Handle a tick */

			Interval = timer_thread_handle_tick(Interval);
			amithread_request_timeout(aAmiThread, Interval);
		}
	}

	amithread_remove_sender(&gGraphicsThread);
}



/* timer_thread_handle_tick: [timer thread]
 *  Call handle_tick() method of every timer in active_timers, and
 *  returns the duration that the timer thread should try to sleep
 *  next time.
 */
static usecs_t timer_thread_handle_tick(usecs_t aInterval)
{
	return(_handle_timer_tick(aInterval));
}

TIMER_DRIVER timer_amiga =
{
/*                    id */ TIMER_AMIGA,
/*                  name */ empty_string,
/*                  desc */ empty_string,
/*            ascii_name */ "amigaostimer",
/*                  init */ timer_init,
/*                  exit */ timer_exit,
/*           install_int */ NULL,
/*            remove_int */ NULL,
/*     install_param_int */ NULL,
/*      remove_param_int */ NULL,
/*  can_simulate_retrace */ NULL,
/*      simulate_retrace */ NULL,
/*                  rest */ NULL
};

/* List of available drivers */

_DRIVER_INFO _timer_driver_list[] =
{
   {  TIMER_AMIGA,  &timer_amiga, TRUE },
   {  0,            NULL,         0    }
};
