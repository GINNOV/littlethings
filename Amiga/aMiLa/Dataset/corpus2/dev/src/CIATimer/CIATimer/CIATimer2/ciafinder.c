/* TIMER - Amiga CIA Timer Control Software 0.1a

  originally by Paul Higginbottom, Public Domain

  hacked on by karl to produce a monotonically increasing microsecond
  clock, 12/30/88, Public Domain

  ciafinder is a companion program to ciatimer.  When ciatimer is running,
  it has a timer interrupt installed for a CIA timer, ciafinder will locate
  it and get the time.  ciafinder contains the code you need for your
  application to find the microsecond-resolution CIA timer time.

  cc +p ciafinder.c
  ln ciafinder.o -lcl32

*/

#include <exec/types.h>
#include <exec/tasks.h>
#include <functions.h>
#include <exec/interrupts.h>
#include <hardware/cia.h>
#include <hardware/custom.h>
#include <hardware/intbits.h>
#include <resources/cia.h>
#include <stdio.h>

#include "ciatimer.h"

#define MATCH 0

static struct Interrupt
   CIATimerInterrupt,
   *OldCIAInterrupt = (struct Interrupt *)-1;

static struct Library *CIAResource = NULL;

#define ciatlo ciaa.ciatalo
#define ciathi ciaa.ciatahi
#define ciacr ciaa.ciacra
#define CIAINTBIT CIAICRB_TA
#define CLEAR 0

void DummyCIAInterrupt()
{
}

struct CIA_Time *LocateCIATimerData()
{
	/* Open the CIA resource */
	if ((CIAResource = (struct Library *)OpenResource(CIAANAME)) == NULL)
	{
		fprintf(stderr,"timer couldn't open cia resource\n");
		return(NULL);
	}

	CIATimerInterrupt.is_Node.ln_Type = NT_INTERRUPT;
	CIATimerInterrupt.is_Node.ln_Pri = 127;
	CIATimerInterrupt.is_Code = DummyCIAInterrupt;
	CIATimerInterrupt.is_Node.ln_Name = "ciafinder dummy interrupt";

	/* install interrupt */
	if ((OldCIAInterrupt = AddICRVector(CIAResource,CIAINTBIT,&CIATimerInterrupt)) == NULL)
	{
		RemICRVector(CIAResource, CIAINTBIT, &CIATimerInterrupt);
		fprintf(stderr,"no CIA timer currently installed!\n");
		return(NULL);
	}

	if (strcmp(OldCIAInterrupt->is_Node.ln_Name,CIATIMER_INTERRUPT_NAME) != MATCH)
	{
		fprintf(stderr,"CIA interrupt routine is '%s' rather than '%s'\n",OldCIAInterrupt->is_Node.ln_Name,CIATIMER_INTERRUPT_NAME);
		return(NULL);
	}

	return((struct CIA_Time *)OldCIAInterrupt->is_Data);
}

/* return the elapsed real time in seconds and microseconds since the
 * cia timer interrupt handler was installed.
 *
 * ElapsedTime(&secs,&microsecs);
 *
 */
void ElapsedTime(tickdata_ptr,sec_ptr,usec_ptr)
struct CIA_Time *tickdata_ptr;
int *sec_ptr,*usec_ptr;
{
	register long seconds, microseconds;
	register long ciahi, cialo;

	Disable();
	ciahi = ciathi;
	cialo = ciatlo;
	seconds = tickdata_ptr->CIA_Seconds;
	microseconds = tickdata_ptr->CIA_Microseconds;
	Enable();
	/* total microseconds is CIA_BigTicks * 65536 + timerval * 1.397 */
	/* to multiply the timer ticks * 1.397, you can multiply by 1430
	 * and divide by 1024 (or shift right by 10, get it?) 
	 */
	ciahi = CIA_TIME_SLICE - ((ciahi << 8) + cialo);
	ciahi = ((ciahi * 1430) >> 10) & 0xffff;

	microseconds += ciahi;
	if (microseconds > 1000000)
	{
		microseconds -= 1000000;
		seconds++;
	}

	*sec_ptr = seconds;
	*usec_ptr = microseconds;
	return;
}

main()
{
	struct CIA_Time *CIA_CurrentTime_ptr;
	long secs, microsecs;

	CIA_CurrentTime_ptr = LocateCIATimerData();
	if (CIA_CurrentTime_ptr == NULL)
		exit(1);

	ElapsedTime(CIA_CurrentTime_ptr,&secs,&microsecs);

	printf("secs %d microsecs %d\n",secs,microsecs);
}
