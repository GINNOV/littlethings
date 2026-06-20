/* TIMER - Amiga CIA Timer Control Software 0.1a

  originally by Paul Higginbottom, Public Domain

  hacked on by Karl Lehenbauer to produce a monotonically increasing microsecond
  clock, 12/30/88, Public Domain

  further hacking by Karl to provide arbitrary tasks the ability to locate
  the CIA interrupt's time data, 1/5/88, Public Domain

  cc +p ciatimer.c
  ln ciatimer.o -lcl32

To start up the timer, execute ciatimer.  To kill it, control-C.  The task
doesn't do anything except wait for the control-C and clean up afterwards,
removing the interrupt.

ciafinder may then be used to locate the is_Data section of ciatimer's
interrupt, where ciatimer writes its time data.
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
#include <libraries/dos.h>

#include "ciatimer.h"

struct CIA_Time CIA_CurrentTime = {0, 0};

static struct Interrupt
   CIATimerInterrupt,
   *OldCIAInterrupt = (struct Interrupt *)-1;

static struct Library *CIAResource = NULL;

#define ciatlo ciaa.ciatalo
#define ciathi ciaa.ciatahi
#define ciacr ciaa.ciacra
#define CIAINTBIT CIAICRB_TA
#define CLEAR 0

void CIAInterrupt()
{
	CIA_CurrentTime.CIA_Microseconds += 65536;
	if (CIA_CurrentTime.CIA_Microseconds > 1000000)
	{
		CIA_CurrentTime.CIA_Seconds++;
		CIA_CurrentTime.CIA_Microseconds -= 1000000;
	}
}

/* start the timer, clear pending interrupts, and enable timer A
 * Interrupts */
StartCIATimer()
{
	ciacr &= ~(CIACRAF_RUNMODE);	/* set it to reload on overflow */
	ciacr |= (CIACRAF_LOAD | CIAICRF_TA);
	SetICR(CIAResource,CLEAR|CIAICRF_TA);
	AbleICR(CIAResource, CIAICRF_SETCLR | CIAICRF_TA);
}

void StopCIATimer()
{
	AbleICR(CIAResource, CLEAR | CIAICRF_TA);
	ciacr &= ~CIACRAF_START;
}

/* set period between timer increments */
void SetCIATimer(micros)
unsigned short micros;
{
	ciatlo = micros & 0xff;
	ciathi = micros >> 8;
}

/* stop the timer and remove its interrupt vector */
EndCIATimer()
{
	if (OldCIAInterrupt == NULL)
	{
		StopCIATimer();
		RemICRVector(CIAResource, CIAINTBIT, &CIATimerInterrupt);
	}
}

BOOL BeginCIATimer()
{
	/* Open the CIA resource */
	if ((CIAResource = (struct Library *)OpenResource(CIAANAME)) == NULL)
	{
		fprintf(stderr,"cia periodic timer startup couldn't open cia resource\n");
		return(0);
	}

	CIATimerInterrupt.is_Node.ln_Type = NT_INTERRUPT;
	CIATimerInterrupt.is_Node.ln_Pri = 127;
	CIATimerInterrupt.is_Node.ln_Name =  CIATIMER_INTERRUPT_NAME;
	CIATimerInterrupt.is_Code = CIAInterrupt;
	CIATimerInterrupt.is_Data = (APTR)&CIA_CurrentTime;

	/* install interrupt */
	if ((OldCIAInterrupt = AddICRVector(CIAResource,CIAINTBIT,&CIATimerInterrupt)) != NULL)
	{
		fprintf(stderr,"cia timer interrupt already in use by '%s'",OldCIAInterrupt->is_Node.ln_Name);
		EndCIATimer();
		return(0);
	}

	SetCIATimer(CIA_TIME_SLICE);

	StartCIATimer();
	return(TRUE);
}

main()
{
	if (BeginCIATimer())
	{
		Wait(SIGBREAKF_CTRL_C);
	}
	else 
		exit(1);

	EndCIATimer();
	exit(0);
}
