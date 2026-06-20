/* TIMER - Amiga CIA Timer Control Software

  originally by Paul Higginbottom, Public Domain, published in AmigaMail

  hacked on by Karl Lehenbauer to produce a monotonically increasing 
  microsecond clock, 12/30/88. All changes are Public Domain.

  cc +p ciatimer.c
  ln ciatimer.o -lcl32

	By providing a solid, high-accuracy realtime clock, this code
	provides a way for timer-releated code that needs to run at
	specific realtimes, like a SMUS player, MIDI sequencer, etc,
	to compensate for delays in their execution caused by interrupts,
	cycle stealing by the blitter, etc.

	What you do is keep track of when in realtime you next want to 
	run (by adding time intervals to a time returned by ElapsedTime
	when you start, then when you're ready to set up your timer.device
	MICROHZ delay timer, call ElapsedTime and calculate the difference 
	in seconds and microseconds as your arguments for your timer.device
	request.

	The routine ElapsedTime gets the time by getting the number of
	65536 microsecond ticks that the handler has seen and retrieving
	the 0-46911 number of 1.397 microsecond ticks from the CIA timer
	registers, scaling them to 1.000 microsecond ticks and returning
	the shifted-and-ored result.

	A couple routines at the bottom of the file that're commented out 
	are from my SMUS player and demonstrate how to perform the time 
	arithmetic as described above.

	Note that what we really want is an improved timer.device where a
	flag in the timer request could say  "schedule me at this microsecond-
	resolution time of day seconds and microseconds" instead of only
	"schedule me in this many seconds and microseconds."

	When the CIA interrupt handler is installed, other tasks need a
	way to get the count maintained by the timer routine, too.
	I was thinking maybe a library could be used and, by opening it,
	tasks could get to the address of the long word that the interrupt
	handler increments every time it runs.
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

long CIA_Seconds = 0;	
long CIA_Microseconds = 0;

/* timeslice is 46911 intervals.  Each interval is 1.397 microseconds,
 * this should correspond to a timing interval of 65536 microseconds */
#define CIA_TIME_SLICE ((unsigned short) 46911)

static struct Interrupt
   CIATimerInterrupt,
   *OldCIAInterrupt = (struct Interrupt *)-1;

static struct Library *CIAResource = NULL;

#define ciatlo ciaa.ciatalo
#define ciathi ciaa.ciatahi
#define ciacr ciaa.ciacra
#define CIAINTBIT CIAICRB_TA
#define CLEAR 0

panic(s)
char *s;
{
	fflush(stdout);
	fprintf(stderr,"panic: %s\n",s);
	fflush(stderr);
	EndCIATimer();
}

/* this is the actual interrupt routine.  since +p 32-bit model is used,
 * no special dinking around is necessary to get a C routine to run as
 * an interrupt.
 */
VOID CIAInterrupt()
{
	/* increment saved microseconds by number generated between CIA
	 * interrupts, and if we passed a million, increment seconds */
	CIA_Microseconds += 65536;
	if (CIA_Microseconds > 1000000)
	{
		CIA_Seconds++;
		CIA_Microseconds -= 1000000;
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
		panic("timer couldn't open cia resource");

	CIATimerInterrupt.is_Node.ln_Type = NT_INTERRUPT;
	CIATimerInterrupt.is_Node.ln_Pri = 127;
	CIATimerInterrupt.is_Code = CIAInterrupt;

	/* install interrupt */
	if ((OldCIAInterrupt = AddICRVector(CIAResource,CIAINTBIT,&CIATimerInterrupt)) != NULL)
		panic("cia timer interrupt already in use.");

	SetCIATimer(CIA_TIME_SLICE);

	StartCIATimer();
	return(TRUE);
}

/* return the elapsed real time in seconds and microseconds since the
 * cia timer interrupt handler was installed.
 *
 * ElapsedTime(&secs,&microsecs);
 *
 * with the chosen timeslice interval, every timer interrupt represents
 * 65536 microseconds, so the count of interrupts received can be shifted
 * and or'ed in.  The thing that needs scaling is the timer count we
 * read from the hardware registers.  It's range of 0 - 46911 1.397
 * microsecond ticks must be changed to a range of 0 - 65535 1.0 
 * microsecond ticks, which is done below
 *
 * note the code should really read the lo count register again after
 * reading the high one and comparing them to be sure it didn't wrap
 * in between reads
 *
 * interrupts are off during this to reduce the possibility of a problem
 * with the counter interrupt coming between the cia reads and the big tick
 * read, and because it's short it's no biggie, but again it should 
 * really do more
 */
void ElapsedTime(sec_ptr,usec_ptr)
int *sec_ptr,*usec_ptr;
{
	register long seconds, microseconds;
	register long ciahi, cialo;

	Disable();
	ciahi = ciathi;
	cialo = ciatlo;
	seconds = CIA_Seconds;
	microseconds = CIA_Microseconds;
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

/* this is a demo routine */
main()
{
	long secs, microsecs;

	printf("CIA Timer Demo\n\n");
	printf("Every time getchar() succeeds, I'll print seconds and microseconds\n");
	printf("elapsed since I installed a CIA timer interrupt handler.\n\n");
	printf("So hit return to get the message, control-backslash to exit.\n");
	printf("Type some chars and hit return to get it a bunch of times really fast.\n\n");

	printf("This demonstrates using a CIA timer in loop mode to derive\n");
	printf("a monotonically increasing microsecond-resolution clock.\n\n");

	BeginCIATimer();

	while (getchar() > 0)
	{
		ElapsedTime(&secs,&microsecs);
		printf("ET %d secs, %d microsecs\n",secs,microsecs);
	}

	EndCIATimer();
}

/*
long reference_seconds, reference_microseconds;

void set_wait_ticks(delay_ticks)
long delay_ticks;
{
	register long desired_seconds, desired_microseconds;
	long current_seconds,current_microseconds;

	timer_request->tr_node.io_Command = TR_ADDREQUEST;

	reference_microseconds += microseconds_per_tick * delay_ticks;

	while (reference_microseconds >= 1000000)
	{
		reference_microseconds -= 1000000;
		reference_seconds++;
	}

	ElapsedTime(&current_seconds,&current_microseconds);
	desired_seconds = reference_seconds - current_seconds;
	desired_microseconds = reference_microseconds - current_microseconds;

	if (desired_microseconds < 0)
	{
		desired_microseconds += 1000000;
		desired_seconds--;
	}

	if (desired_seconds >= 0)
	{
		timer_request->tr_time.tv_secs = desired_seconds;
		timer_request->tr_time.tv_micro = desired_microseconds;
	}
	else
	{
		timer_request->tr_time.tv_secs = 0;
		timer_request->tr_time.tv_micro = 1;
	}
	SendIO(timer_request);
}

SetReferenceTime()
{
	ElapsedTime(&reference_seconds,&reference_microseconds);
}

*/



