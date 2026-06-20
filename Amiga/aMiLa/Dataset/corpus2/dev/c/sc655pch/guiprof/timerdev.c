#include <proto/timer.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Library *TimerBase;
static struct timerequest TimerIO;
static long E_Freq;

int _STITimerDev(void)
{
   struct EClockVal x;
   if(OpenDevice(TIMERNAME, UNIT_ECLOCK, (struct IORequest *)&TimerIO, 0L))
   {
      return(-1);
   }
   TimerBase = (struct Library *)TimerIO.tr_node.io_Device;
   E_Freq = ReadEClock(&x)/1000;  /* Set up E_Freq */
}

void _STDTimerDev(void)
{
   if(TimerBase)
   {
      CloseDevice((struct IORequest *)&TimerIO);
      TimerBase = NULL;
   }
}

long TimeDiff(struct EClockVal *first, struct EClockVal *second)
{
   /* For now, only use low four bytes. */
   return (second->ev_lo - first->ev_lo)/E_Freq;
}

#if DO_TEST
int main(int argc, char *argv[])
{
   struct EClockVal time1, time2;
   int delay = 50;
   int i;
   long loopover;
   long timeover;

   if(argc > 1)
      stcd_i(argv[1], &delay);
   printf("Delay value is %ld\n", delay);

   ReadEClock(&time1);

   Delay(delay);

   ReadEClock(&time2);

   printf("Result is %ld milliseconds\n", TimeDiff(&time1, &time2));

   ReadEClock(&time1);

   for(i=0; i<100000; i++);

   ReadEClock(&time2);

   printf("Loop overhead is %ld\n", loopover=TimeDiff(&time1, &time2));

   ReadEClock(&time1);

   for(i=0; i<100000; i++)
   {
      ReadEClock(&time2);
      TimeDiff(&time1, &time2);
   }

   ReadEClock(&time2);
   timeover = TimeDiff(&time1, &time2);
   
   printf("Timer overhead is %ld/%f (%ld milliseconds more than loop)\n", timeover,
      (double)timeover/100000,
      timeover-loopover);

   return 0;
}
#endif
