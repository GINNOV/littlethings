/*
 * Copyright (c) 1992 Commodore-Amiga, Inc.
 * 
 * This example is provided in electronic form by Commodore-Amiga, Inc. for 
 * use with the "Amiga ROM Kernel Reference Manual: Devices", 3rd Edition, 
 * published by Addison-Wesley (ISBN 0-201-56775-X).
 * 
 * The "Amiga ROM Kernel Reference Manual: Devices" contains additional 
 * information on the correct usage of the techniques and operating system 
 * functions presented in these examples.  The source and executable code 
 * of these examples may only be distributed in free electronic form, via 
 * bulletin board or as part of a fully non-commercial and freely 
 * redistributable diskette.  Both the source and executable code (including 
 * comments) must be included, without modification, in any copy.  This 
 * example may not be published in printed form or distributed with any
 * commercial product.  However, the programming techniques and support
 * routines set forth in these examples may be used in the development
 * of original executable software products for Commodore Amiga computers.
 * 
 * All other rights reserved.
 * 
 * This example is provided "as-is" and is subject to change; no
 * warranties are made.  All use is at your own risk. No liability or
 * responsibility is assumed.
 *
 *****************************************************************************
 *
 *
 * Timer_Arithmetic.c
 *
 * Example of timer device arithmetic functions
 *
 * Compile with SAS C 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <devices/timer.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/timer_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }     /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

struct Library *TimerBase;  /* setup the interface variable (must be global) */

void main(int argc,char **argv)
{
struct timeval     *time1, *time2, *time3;
struct timerequest *tr;
LONG               error,result;
/*------------------------------------*/
/* Get some memory for our structures */
/*------------------------------------*/
time1=(struct timeval *)AllocMem(sizeof(struct timeval),
                               MEMF_PUBLIC | MEMF_CLEAR);
time2=(struct timeval *)AllocMem(sizeof(struct timeval),
                               MEMF_PUBLIC | MEMF_CLEAR);
time3=(struct timeval *)AllocMem(sizeof(struct timeval),
                               MEMF_PUBLIC | MEMF_CLEAR);
tr=(struct timerequest *)AllocMem(sizeof(struct timerequest),
                               MEMF_PUBLIC | MEMF_CLEAR);
/* Make sure we got the memory */
if(!time1 | !time2 | !time3 | !tr) goto cleanexit;
/*---------------------------------------------------------------------------*/
/* Set up values to test time arithmetic with.  In a real application these  */
/* values might be filled in via the GET_SYSTIME command of the timer device */
/*---------------------------------------------------------------------------*/
time1->tv_secs = 3;   time1->tv_micro = 0;           /* 3.0 seconds */
time2->tv_secs = 2;   time2->tv_micro = 500000;      /* 2.5 seconds */
time3->tv_secs = 1;   time3->tv_micro = 900000;      /* 1.9 seconds */

printf("Time1 is %ld.%ld\n" , time1->tv_secs,time1->tv_micro);
printf("Time2 is %ld.%ld\n" , time2->tv_secs,time2->tv_micro);
printf("Time3 is %ld.%ld\n\n",time3->tv_secs,time3->tv_micro);
/*-------------------------------*/
/* Open the MICROHZ timer device */
/*-------------------------------*/
error = OpenDevice(TIMERNAME,UNIT_MICROHZ,(struct IORequest *) tr, 0L);
if(error) goto cleanexit;

/* Set up to use the special time arithmetic functions */
TimerBase = (struct Library *)tr->tr_node.io_Device;
/*--------------------------------------------------------------------------*/
/* Now that TimerBase is initialized, it is permissible to call the         */
/* time-comparison or time-arithmetic routines.  Result of this example     */
/* is -1 which means the first parameter has greater time value than second */
/* parameter +1 means the second parameter is bigger; 0 means equal.        */
/*--------------------------------------------------------------------------*/
result = CmpTime( time1, time2 );
printf("Time1 and Time2 compare = %ld\n",result);

/* Add time2 to time1, result in time1 */
AddTime( time1, time2);
printf("Time1 + Time2 = %ld.%ld\n",time1->tv_secs,time1->tv_micro);

/* Subtract time3 from time2, result in time2 */
SubTime( time2, time3);
printf("Time2 - Time3 = %ld.%ld\n",time2->tv_secs,time2->tv_micro);
/*------------------------------------*/
/* Free system resources that we used */
/*------------------------------------*/
cleanexit:
  if (time1)
      FreeMem(time1,sizeof(struct timeval));
  if (time2)
      FreeMem(time2,sizeof(struct timeval));
  if (time3)
      FreeMem(time3,sizeof(struct timeval));
  if (!error)
      CloseDevice((struct IORequest *) tr);
  if (tr)
      FreeMem(tr,sizeof(struct timerequest));
}
