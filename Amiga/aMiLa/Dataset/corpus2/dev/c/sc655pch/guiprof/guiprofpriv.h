/*-------------------------------------------------------------------*/
/* Copyright (c) 1993 by SAS Institute Inc., Cary NC                 */
/* All Rights Reserved                                               */
/*                                                                   */
/* SUPPORT:    walker - Doug Walker                                  */
/*-------------------------------------------------------------------*/
#define __USE_SYSBASE 1
#include <exec/types.h>
#include <dos/doshunks.h>
#include <time.h>

#define TIMERINTERVAL 5000   /* in milliseconds */

#if DODEBUG
#include <stdarg.h>
#include <stdio.h>
#define IFDEBUG(x) x
#define BUG(x) {if(dodebug) bug x ;}
void bug(char *fmt, ...);
extern int dodebug;
#define FUNCENTRY BUG((__FUNC__ ": entry\n"))
#else
#define IFDEBUG(x)
#define BUG(x)
#define FUNCENTRY
#endif

#include "memwatch.h"

#define SPROFPORT "SPROF_Profiler"

typedef unsigned long sptime;

struct SPDAT
{
   char *id;        // id of function (NULL for ignore)
   sptime clk;      // Clock at entry
   sptime subrs;    // Amount of time spent in subroutines
   sptime off;      // Amount of time under PROFILE_OFF
};
#define SIZSPDAT sizeof(struct SPDAT)

extern struct SPDAT *spdat;
extern int spcur, spmax;
extern int autoexit;
extern int broken;
extern int axis;
extern int sortby;
extern int fullnames;
extern char nullid[];
#define SPINCR 500

#define GPINAME(x) (fullnames ? (x)->fullname : (x)->name)

typedef struct SPROFMSG
{
   struct Message m;
   ULONG process;
   sptime clk;
   char *id;
   ULONG a7;
   ULONG flags;
} *SPM;

#define SIZSPM sizeof(struct SPROFMSG)

/* Values for the 'flags' field of SPROFMSG */
#define SPROF_INIT   0x00000001  // Initialize connection
#define SPROF_ENTRY  0x00000002  // Function entry
#define SPROF_EXIT   0x00000004  // Function exit
#define SPROF_TERM   0x00000008  // Terminate connection, program continues
#define SPROF_ABORT  0x00000010  // Abort program
#define SPROF_DENIED 0x00000020  // Connection refused

struct GPInfo
{
   char *id;       // Used for sorting while program is in mem
   char *name;     // Name of function
   char *fullname; // Name and location of function
   sptime time;    // Time excluding subroutines
   sptime tottime; // Time including subroutines
   USHORT count;    // Number of calls
   
   /* The following fields are used for creating the report while the */
   /* program is running.                                             */
   short rptindx;    // Index on screen of last report
   short rptnamelen; // Length in characters to which name should be trunc
   USHORT histlen;
   ULONG stkval;
   ULONG histval;
};

extern struct GPInfo **GPInfo;
extern int GPCur, GPMax;
#define SIZGPINFO sizeof(struct GPInfo)
#define GPINCR 256

int InitReport(void);
void Report(sptime now);
void DoTitle(char *);
char *FuncName(char *);
struct GPInfo *FindGPI(struct GPInfo ***GPInfo, char *id,
                       int *cur, int *tot);

/* Functions defined in timer.c */
long OpenTimer(void);
void _STDCloseTimer(void);
#define CloseTimer() _STDCloseTimer()
void PostTimerReq(long time);
void GetTimerPkt(long time, int wait);

extern int report_type;
#define RPT_PCT   0
#define RPT_ETIME 1
#define RPT_ITIME 2
#define RPT_CNT   3

#define MENU_HIST    0
#define MENU_OPT     1

#define HIST_PCT     1
#define HIST_ETIME   2
#define HIST_ITIME   3
#define HIST_CNT     4
#define HIST_QUIT    5

#define OPT_SORTNUM    1
#define OPT_SORTALPHA  2
#define OPT_AXIS       3
#define OPT_FULLNAME   4

#define SORTBY_NUM   1
#define SORTBY_ALPHA 2
