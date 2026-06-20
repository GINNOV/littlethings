#ifndef CRBLIB_TIMER_H
#define CRBLIB_TIMER_H

#include <crbinc/inc.h>
#include <time.h>

#ifndef CLOCKS_PER_SEC
#define CLOCKS_PER_SEC 10000000 /* unix */
#endif

#ifndef CLOCKS_PER_SECOND
#define CLOCKS_PER_SECOND CLOCKS_PER_SEC
#endif

#ifndef CLK_TCK
#define CLK_TCK CLOCKS_PER_SEC
#endif

extern ulong ClockSeconds(clock_t Clock);
extern ulong ClockMilliSeconds(clock_t Clock);
extern ulong NumPerSec(ulong Num,clock_t DiffClock);

#endif
