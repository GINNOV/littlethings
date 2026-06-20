/* ciatimer.h - include file Amiga CIA Timer Control Software 0.1a

  CIA timer code originally by Paul Higginbottom, Public Domain

  this include file was written by Karl Lehenbauer, Public Domain

  cc +p ciatimer.c
  ln ciatimer.o -lcl32

  To start the timer, execute BeginCIATimer()

*/

struct CIA_Time
{
	long CIA_Seconds;
	long CIA_Microseconds;
};

/* timeslice is 46911 intervals.  Each interval is 1.397 microseconds,
 * this should correspond to a timing interval of 65536 microseconds */
#define CIA_TIME_SLICE ((unsigned short) 46911)

#define CIATIMER_INTERRUPT_NAME "CIA Periodic Timer"

