/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
#include <stdio.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <time.h>
#include <limits.h>
#include <proto/exec.h>
#include <proto/timer.h>
#include <proto/dos.h>
#include <string.h>
#include <dos.h>

/* #define TimerBase MyTimerBase */

static long DoProfile = 0; /* PROFILING IS OFF BY DEFAULT ! */
static struct Library *TimerBase = NULL;
static struct timerequest TimerIO;
static struct EClockVal baseline;
static long E_Freq;
static struct MsgPort *replyport;
static struct Task *process;
static int nummsgout;
static struct EClockVal t0;
static unsigned long overhead;

/* This is an autotermination function that will run when the program exits. */
/* it cleans up the externs that the profiling code uses.		     */
void CleanupProfile( void )
{
   static int skipme;

   if(!skipme)
   {
     skipme = 1;  // Already called, skip it
     if(TimerBase)
     {
       CloseDevice((struct IORequest *)&TimerIO);
       TimerBase = NULL;
     }
     printf( "Profile cleanup ok\n" ) ;
   }
}

/* This is an autoinitialization function that runs before the program starts. */
/* It checks to see if we will be profiling this time around and, if so, sets  */
/* up the global variables that will be required.			       */
void SetupProfile( void )
{
   memset(&TimerIO, 0, sizeof(TimerIO));

   if(! OpenDevice(TIMERNAME, UNIT_ECLOCK, (struct IORequest *)&TimerIO, 37L))
   {
     TimerBase = (struct Library *)TimerIO.tr_node.io_Device;
     E_Freq    = ReadEClock(&baseline) / 1000;
     printf( "Profile setup ok\n" ) ;
   }
}


static long TimeStamp(void)
{
   ReadEClock(&t0);

   /* For now, only use low four bytes. */
   return (long)(t0.ev_lo - baseline.ev_lo - overhead)/E_Freq;
}

void __asm _PROLOG(register __a0 char *id)
{
   if (id)
   {
     if(TimerBase && DoProfile) printf( "%6ld P %s\n" , TimeStamp() , id ) ;
   }
   else DoProfile = 0;
}

void __asm _EPILOG(register __a0 char *id)
{
   if (id)
   {
     if(TimerBase && DoProfile) printf( "%6ld E %s\n" , TimeStamp() , id ) ;
   }
   else DoProfile = 1;
}

