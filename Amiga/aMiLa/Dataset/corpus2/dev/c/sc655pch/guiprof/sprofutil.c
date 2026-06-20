/*-------------------------------------------------------------------*/
/* Copyright (c) 1992-1995 SAS Institute Inc., Cary NC               */
/*                                                                   */
/* SUPPORT:    walker - Doug Walker                                  */
/* SCRIPT:     sprof                                                 */
/*-------------------------------------------------------------------*/
/* CUT HERE */
#include <exec/types.h>
#include <exec/memory.h>
#include <time.h>
#include <limits.h>
#include <proto/exec.h>
#include <proto/timer.h>
#include <proto/dos.h>
#include <string.h>
#include <dos.h>

#include "sprofpriv.h"

#include "constructor.h"

#define TimerBase MyTimerBase

static struct Library *TimerBase;
static struct MsgPort *SprofPort;
static struct timerequest TimerIO;
static struct EClockVal baseline;
static long E_Freq;
static struct MsgPort *replyport;
static struct Task *process;
static int nummsgout;
static struct EClockVal t0;
static unsigned long overhead;


static int SendMsg(ULONG clkval, char *id, ULONG flags);
static long TimeStamp(void);
static void TimeRestart(void);

/* This is an autotermination function that will run when the program exits. */
/* it cleans up the externs that the profiling code uses.                    */
PROFILE_DESTRUCTOR(Sprof)
{
   SPM msg;
   static int skipme;
   FUNCENTRY

   if(skipme) return;

   skipme = 1;  // Already called, skip it

   if(TimerBase)
   {
      CloseDevice((struct IORequest *)&TimerIO);
      TimerBase = NULL;
   }

   if(SprofPort && replyport)
      SendMsg(0, 0, SPROF_TERM);

   SprofPort = NULL;

   if(replyport)
   {
      while(nummsgout > 0)
      {
         while(!(msg=(SPM)GetMsg(replyport)))
            WaitPort(replyport);
         nummsgout--;
         //BUG(("Freed msg 0x%08lx, new nummsgout=%d\n", msg, nummsgout));
         FreeMem(msg, SIZSPM);
      }
      DeletePort(replyport);
      replyport = NULL;
   }
}

/* This is an autoinitialization function that runs before the program starts. */
/* It checks to see if we will be profiling this time around and, if so, sets  */
/* up the global variables that will be required.                              */
PROFILE_CONSTRUCTOR(Sprof)
{
   SPM msg;
   FUNCENTRY

   if(!(SprofPort = FindPort(SPROFPORT)))
      return 0;

   memset(&TimerIO, 0, sizeof(TimerIO));

   if(OpenDevice(TIMERNAME, UNIT_ECLOCK, (struct IORequest *)&TimerIO, 37L))
      return(0);

   TimerBase = (struct Library *)TimerIO.tr_node.io_Device;

   if(!(replyport = CreatePort(0L, 0L)))
   {
      PROFILE_DESTRUCTOR_NAME(Sprof)();  // Does the necessary cleanup
      return -1;
   }

   process = FindTask(NULL);

   Forbid();
   if(!(SprofPort = FindPort(SPROFPORT)))
   {
      Permit();
      PROFILE_DESTRUCTOR_NAME(Sprof)();
      return 0;  // OK to run with no profiler
   }

   SendMsg(0, 0, SPROF_INIT);  // "Here we are!"

   Permit();

   while(!(msg = (SPM)GetMsg(replyport))) WaitPort(replyport);

   PutMsg(replyport, (struct Message *)msg);  // So we can reuse it later

   if(msg->flags == SPROF_DENIED || msg->flags == SPROF_TERM) // He doesn't want us
   {
      SprofPort = NULL;  // Make sure we don't try to contact profiler
      PROFILE_DESTRUCTOR_NAME(Sprof)();
      return 0;
   }

   /* This needs to go towards the end so the profiler startup */
   /* overhead doesn't count                                   */
   E_Freq = ReadEClock(&baseline) / 1000;

   return 0;
}


static long TimeStamp(void)
{
   ReadEClock(&t0);

   /* For now, only use low four bytes. */
   return (long)(t0.ev_lo - baseline.ev_lo - overhead)/E_Freq;
}

static void TimeRestart(void)
{
   struct EClockVal t;

   ReadEClock(&t);

   overhead += (t.ev_lo - t0.ev_lo);
}

void __asm _PROLOG(register __a0 char *id)
{
   long t1;
   if(!SprofPort) return;
   t1 = TimeStamp();
   if(!SendMsg(t1, id, SPROF_ENTRY))
      TimeRestart();
}

void __asm _EPILOG(register __a0 char *id)
{
   long ts;
   if(!SprofPort) return;
   ts = TimeStamp();
   if(!SendMsg(ts, id, SPROF_EXIT))
      TimeRestart();
}

static int SendMsg(ULONG clkval, char *id, ULONG flags)
{
   SPM msg;

   if(!(msg = (SPM)GetMsg(replyport)))
   {
      if(!(msg = (SPM)AllocMem(SIZSPM, MEMF_CLEAR)))
      {
         PROFILE_DESTRUCTOR_NAME(Sprof)();
         return -1;
      }
      msg->m.mn_ReplyPort = replyport;
      msg->process = (ULONG)process;
      nummsgout++;
      //BUG(("New msg = 0x%08lx\n", msg));
   }
   else
   {
      if(flags != SPROF_TERM && msg->flags == SPROF_TERM)
      {
         PutMsg(replyport, (struct Message *)msg);  // So it gets freed
         PROFILE_DESTRUCTOR_NAME(Sprof)();
         return -1;
      }
   }

   msg->clk = clkval;
   msg->id = id;
   msg->a7 = getreg(REG_A7);
   msg->flags = flags;
   PutMsg(SprofPort, (struct Message *)msg);
   WaitPort(replyport);
   return 0;
}
#if DODEBUG
void bug(char *fmt, ...)
{
   va_list arg;
   char buf[512];

   va_start(arg,fmt);
   vsprintf(buf, fmt, arg);
   va_end(arg);

   Write(Output(), buf, strlen(buf));
}
#endif

