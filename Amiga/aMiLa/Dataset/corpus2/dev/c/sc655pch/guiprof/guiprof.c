/*-------------------------------------------------------------------*/
/* Copyright (c) 1993 by SAS Institute Inc., Cary NC                 */
/* All Rights Reserved                                               */
/*                                                                   */
/* SUPPORT:    walker - Doug Walker                                  */
/*-------------------------------------------------------------------*/
#define __USE_SYSBASE 1

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <exec/ports.h>
#include <dos/dosextens.h>
#include <dos/dostags.h>
#include <exec/execbase.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <dos.h>
#include "guiprofpriv.h"

#define V37 (SysBase->LibNode.lib_Version > 36) 

char nullid[] = "";

int broken;
int axis;
int sortby = OPT_SORTNUM;

void __regargs __chkabort(void){}

#if DODEBUG
int dodebug;
#endif

int autoexit;

static const char __ver[] = "$VER: GUIPROF 6.55 " __AMIGADATE__;

struct MsgPort *port;

struct SPDAT *spdat;
int spcur, spmax;

struct GPInfo **GPInfo;
int GPCur;
int GPMax;
int verbose;
int fullnames;

char __stdiowin[] = "CON:0/0/639/199/";

unsigned long process;
static void spdoexit(SPM msg);

void _STDcleanup(void)
{
   if(port)
   {
      DeletePort(port);
      port = NULL;
   }
}

void usage(void)
{
   fprintf(stderr, "USAGE: guiprof [<guiprof arguments>] [<program> [<program arguments>]]\n");
   fprintf(stderr, "guiprof arguments:\n");
   fprintf(stderr, "       WAIT:      Wait for a program compiled with PROFILE to be run.\n");
   fprintf(stderr, "    VERBOSE:      Print detailed trace to stdout (VERY SLOW).\n");
   fprintf(stderr, "  FULLNAMES:      Print long version of function names\n");
   fprintf(stderr, "      FORCE:      Force reports even if it steals time from program.\n");
   fprintf(stderr, "       AXIS:      Print horizontal axis\n");
   fprintf(stderr, "   INTERVAL=time: Report interval, in milliseconds.  Default 250.\n");
   fprintf(stderr, "       SORT=type: Either ALPHA or NUM, for alphabetic or numeric sort.\n");
   fprintf(stderr, "     FORMAT=fmt:  Report format.  Format is one of\n"
                   "        PCT:   Percent of time spent in routine.\n"
                   "        ETIME: Milliseconds in routine, excluding subroutines.\n"
                   "        ITIME: Milliseconds in routine, including subroutines.\n"
                   "        COUNT: Number of times routine was called.\n"
          );
                   
   exit(20);
}

int main(int argc, char *argv[])
{
   SPM msg;
   int i, len;
   int keepon = 1;
   char *modname = NULL;
   char *cmd, *p;
   int wait = 0;
   int reporttime = 250; /* Every quarter-second */
   int doreport = 0;
   int forcereport = 0;
   long waitbits, timerbit, res;
   sptime now = 0;
   struct ExecBase *SysBase = *(struct ExecBase **)4;

   if(!V37)
   {
      fprintf(stderr, "This program requires AmigaDOS 2.0 or higher\n");
      /* If we were run from the 1.3 WorkBench, our stderr window will */
      /* close when we exit, so delay for 4 seconds.                   */
      if(argv == NULL) Delay(200);
      exit(20);
   }

   /* Parse workbench arguments */
   if(argc == 0)
   {
      /* See <dos.h> */
      argc = _WBArgc;
      argv = _WBArgv;
   }

   timerbit = waitbits = OpenTimer();

   if(waitbits == 0)
   {
      fprintf(stderr, "ERROR: Can't open timer.device\n");
      exit(20);
   }

   waitbits |= (SIGBREAKF_CTRL_C|SIGBREAKF_CTRL_F);

   /* We can't use ReadArgs because our parameters are positional. */
   /* We want arguments specified after the program name to be     */
   /* program arguments, and ReadArgs doesn't support this.        */
   if(argc)
   {
      while(argv[1])
      {
         if(!strcmp(argv[1], "?"))
            usage();
         else if(!stricmp(argv[1], "WAIT")) 
            wait = 1;
         else if(!stricmp(argv[1], "AXIS"))
            axis = 1;
         else if(!strnicmp(argv[1], "INTERVAL", 8))
         {
            if(argv[1][8] && argv[1][8] != '=')
               usage();

            if(argv[1][8] == '=')
            {
               if(stcd_i(argv[1]+9, &reporttime) <= 0)
                  usage();
            }
            else
            {
               if(argv[2] == NULL || stcd_i(argv[2], &reporttime) <= 0)
                  usage();
               argv++;
            }
         }
         else if(!stricmp(argv[1], "VERBOSE"))
         {
            verbose = 1;
         }
         else if(!stricmp(argv[1], "FULLNAMES"))
         {
            fullnames = 1;
         }
         else if(!stricmp(argv[1], "FORCE"))
         {
            /* Produce reports even at the expense of the program */
            /* being profiled.  If FORCE is not set, reports will */
            /* only be produced when the program is suspended.    */
            forcereport = 1;
         }
         else if(!strnicmp(argv[1], "SORT", 4))
         {
            if(argv[1][4] == 0)
            {
               argv++, argc--;
               p = argv[1];
            }
            else if(argv[1][4] == '=')
               p = argv[1]+5;
            else
               usage();
               
            if(!stricmp(p, "ALPHA"))
               sortby = OPT_SORTALPHA;
            else if(!stricmp(p, "NUM"))
               sortby = OPT_SORTNUM;
            else
               usage();
         }
         else if(!strnicmp(argv[1], "FORMAT", 6))
         {
            if(argv[1][6] == 0)
            {
               argv++, argc--;
               p = argv[1];
            }
            else if(argv[1][6] == '=')
               p = argv[1]+7;
            else
               usage();

            if(!stricmp(p, "PCT"))
            {
               report_type = RPT_PCT;
            }
            else if(!stricmp(p, "COUNT"))
            {
               report_type = RPT_CNT;
            }
            else if(!stricmp(p, "ITIME"))
            {
               report_type = RPT_ITIME;
            }
            else if(!stricmp(p, "ETIME"))
            {
               report_type = RPT_ETIME;
            }
         }
#if DODEBUG
         else if(!stricmp(argv[1], "DEBUG"))
         {
            dodebug=1;
         }
#endif
         else if(!stricmp(argv[1], "AUTOEXIT"))
         {
            autoexit = 1;
         }
         else
         {
            modname = argv[1];
            argv++;
            break; /* Args after this belong to program */
         }
 
         argv++;
      }
   }
   if(InitReport()) exit(20);

   if(!modname && !wait)
   {
      fprintf(stderr, "You must specify either WAIT or a program name\n");
      exit(99);
   }

   /* Check to make sure there isn't already another SPROF or GUIPROF */
   /* process running.  If there isn't, go ahead and allocate our     */
   /* MsgPort. Since it's possible that one would start up after the  */
   /* call to FindPort() but before the call to CreatePort(), we do   */
   /* the FindPort()/CreatePort() pair under Forbid().                */
   Forbid();
   if(FindPort(SPROFPORT))
   {
      Permit();
      fprintf(stderr, "Message port \"" SPROFPORT "\" already open\n");
      exit(99);
   }

   port = CreatePort(SPROFPORT, 0L);
   Permit();

   if(port == NULL)
   {
      fprintf(stderr, "Can't allocate message port \"" SPROFPORT "\"\n");
      exit(99);
   }

   waitbits |= (1<<port->mp_SigBit);

   if(wait)
   {
      printf("GUIPROF: Please run the program to be profiled now.\n");
   }
   else
   {
      BPTR fh1, fh2;

      for(i=1, len=strlen(modname) + 2; argv[i]; i++)
         len += strlen(argv[i]) + 1;

      if(!(cmd = malloc(len)))
      {
         fprintf(stderr, "Can't allocate %d bytes!\n", len);
         DeletePort(port);
         exit(20);
      }

      cmd[0] = 0;

      strcat(cmd, modname);
      for(i=1, len=strlen(cmd); argv[i]; i++)
      {
         cmd[len] = ' ';
         strcpy(cmd+len+1, argv[i]);
         len += strlen(argv[i]) + 1;
      }

      fh1 = Open("*", MODE_OLDFILE);
      fh2 = Open("*", MODE_OLDFILE);

      //printf("GUIPROF: Executing command \"%s\"\n", cmd);

      if(SystemTags(cmd,  SYS_Input, fh1,
                          SYS_Output, fh2, 
                          SYS_Asynch, -1,
                          SYS_UserShell, -1,
                          TAG_DONE))
      {
         invoke_error:
         fprintf(stderr, "Can't invoke command \"%s\"!\n", cmd);
         DeletePort(port);
         Close(fh1);
         Close(fh2);
         exit(20);
      }
      free(cmd);
   }
   //printf("GUIPROF: Waiting for process...\n");

   while(keepon)
   {
      res = SetSignal(0,SIGBREAKF_CTRL_C|SIGBREAKF_CTRL_F);
      if(broken || (res & SIGBREAKF_CTRL_C))
      {
         doctrlc:
         if(process)
         {
            //printf("GUIPROF: Sending CTRL-C to process...\n");
            Signal((struct Task *)process, SIGBREAKF_CTRL_C);
            broken = 0;
         }
         else
            break;
      }
      if(res & SIGBREAKF_CTRL_F)
      {
         doctrlf:
         BUG(("CTRL-F received, setting up for report\n"))
         if(forcereport)
            Report(now);
         else
            doreport = 1;
      }

      if(msg=(SPM)GetMsg(port))
      {
         switch(msg->flags)
         {
            case SPROF_INIT:
               if(process == NULL) 
               {
                  BUG(("Accepting SPROF_INIT message, process 0x%08lx\n", msg->process))
                  //printf("GUIPROF: Contacted process 0x%08lx\n", msg->process);
                  process = msg->process;
                  PostTimerReq(reporttime);
                  DoTitle("Running");
               }
               else
               {
                  BUG(("Rejecting SPROF_INIT message, process 0x%08lx\n", msg->process))
                  msg->flags = SPROF_DENIED;
               }
               break;

            case SPROF_ENTRY:
               if(verbose)
                  printf("GUIPROF: ENTRY timestamp %ld \"%s\"\n", msg->clk, 
                         msg->id ? msg->id : "PROFILE_OFF");
               if(spcur>=spmax)
               {
                  spmax += SPINCR;
                  spdat = realloc(spdat, spmax*SIZSPDAT);
                  if(!spdat)
                  {
                     keepon = 0;
                     break;
                  }
               }
               spdat[spcur].subrs = spdat[spcur].off = 0;
               spdat[spcur].clk   = now = msg->clk;
               spdat[spcur].id    = msg->id ? msg->id : nullid;
               spcur++;
               break;

            case SPROF_EXIT:
               if(verbose)
                  printf("GUIPROF: EXIT timestamp %ld \"%s\"\n", 
                          msg->clk, msg->id ? msg->id : "PROFILE_ON");
               if(msg->id == NULL) msg->id = nullid;
               spdoexit(msg);
               now = msg->clk;
               break;
            
            case SPROF_TERM:
            case SPROF_ABORT:
               BUG(("SPROF_TERM/SPROF_ABORT\n"))
               keepon = 0;
               doreport = 1;
               DoTitle("Complete");
               break;

            default:
               BUG(("Unknown message flags %d(0x%08lx\n", msg->flags, msg->flags))
               msg->flags = SPROF_ABORT;
               break;
         }

         if(doreport)
         {
            Report(now);
            doreport = 0;
         }

         ReplyMsg(msg);
      }
      else
      {
         if(!process && verbose) printf("Waiting for process...\n");
         res = Wait(waitbits);
         if(res & SIGBREAKF_CTRL_C) goto doctrlc;
         if(res & SIGBREAKF_CTRL_F) goto doctrlf;
         if(res & timerbit)
         {
            BUG(("Timeout, setting up for report\n"))
            if(forcereport)
               Report(now);
            else
               doreport = 1;
            GetTimerPkt(reporttime, 0);
         }
      }
   }

   Forbid();
   while(msg=(SPM)GetMsg(port))
   {
      msg->flags = SPROF_TERM;
      ReplyMsg(msg);
   }
   DeletePort(port);
   Permit();
   port = NULL;

   return(0);
}

static struct GPInfo *NewGPI(char *id)
{
   struct GPInfo *gpi;
   char *funcname;

   assert(id != NULL);
   
   funcname = FuncName(id);
   
   gpi = malloc(sizeof(struct GPInfo) + strlen(funcname) + strlen(id) + 2);
   if(!gpi)
   {
      fprintf(stderr, "Out of memory!\n");
      exit(20);
   }

   memset(gpi, 0, sizeof(*gpi));

   /* The copy of id here is only for sorting purposes.  We can't use    */
   /* the value pointed to after this insertion because the program may  */
   /* exit, but we can use the bit-pattern of the pointer as a unique    */
   /* key on which to sort.                                              */
   gpi->id = id;
   gpi->name = (char *)(gpi+1);
   strcpy(gpi->name, funcname);
   gpi->fullname = gpi->name + strlen(gpi->name) + 1;
   strcpy(gpi->fullname, id);

   return gpi;
}

/* Note: This function assumes GPInfo is sorted by id. */
struct GPInfo *FindGPI(struct GPInfo ***GPInfo_p, char *id,
                       int *cur, int *tot)
{
   int i;
   struct GPInfo **gpi;
   struct GPInfo **GPInfo = *GPInfo_p;

   for(i=0; i<*cur && GPInfo[i]->id < id ; i++);

   if(i<*cur && GPInfo[i]->id == id)
      return GPInfo[i];

   if(!tot) return NULL;

   /* Need to insert a new one right here */
   if(*cur >= *tot)
   {
      *tot += 100;
      if(!(gpi = malloc(*tot*sizeof(struct GPInfo *))))
      {
         fprintf(stderr, "Out of memory!\n");
         exit(20);
      }
      if(i) memcpy(gpi, GPInfo, i*sizeof(struct GPInfo *));
      gpi[i] = NewGPI(id);
      if(i<*cur) memcpy(gpi+i+1, GPInfo+i, (*cur-i)*sizeof(struct GPInfo *));
      if(GPInfo) free(GPInfo);
      GPInfo = *GPInfo_p = gpi;
      (*cur)++;
   }
   else
   {
      if(i < *cur)
         memmove(GPInfo+i+1, GPInfo+i, (*cur-i)*sizeof(struct GPInfo *));
      GPInfo[i] = NewGPI(id);
      (*cur)++;
   }
   return GPInfo[i];
}

static void spdoexit(SPM msg)
{
   sptime elapsed;
   struct GPInfo *gpi;

   if(spcur <= 0)
   {
      /* Should never happen */
      if(verbose) printf("GUIPROF: Call stack underflow! \"%s\"\n", msg->id);
      return;
   }

   /* Determine net elapsed time since function entry */
   /* NOT COUNTING any time spent in PROFILE_OFF      */
   spcur--;
   elapsed = msg->clk - spdat[spcur].clk;

   if(msg->id == nullid)
   {
      /* PROFILE_ON() seen */
      /* Adjust our parent's "off" time */
      spdat[spcur-1].off += elapsed;
      return;
   }

   /* Adjust our parent's "subroutine elapsed" field */
   spdat[spcur-1].subrs += elapsed - spdat[spcur].off;

   /* Adjust our parent's "off" field */
   spdat[spcur-1].off += spdat[spcur].off;

   /* Now we need to associate the elapsed time with the function */
   /* that is returning                                           */
   gpi = FindGPI(&GPInfo, msg->id, &GPCur, &GPMax);

   gpi->count++;
   gpi->time += elapsed - spdat[spcur].subrs - spdat[spcur].off;
   gpi->tottime += elapsed - spdat[spcur].off;

   return;
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
