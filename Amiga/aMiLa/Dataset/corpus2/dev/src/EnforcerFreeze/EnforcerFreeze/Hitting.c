
/*

    just a little test proggie that produces as many
    enforcerhits as possible;

    it is stopped w/ CTL-C, or after 20000 hits

    (there would be much more hits in one quantum, if we
    disabled the counter and the Signalcheck, but how could
    we show then ?)

    on A3000/25 we get from 2000 up to 10000 hits in one
    Quantum (i.e. before EnforcerFreeze can freeze the Task)
*/

#include <dos/dosextens.h>
#include <proto/exec.h>
#include <proto/dos.h>

#include <stdlib.h>

#define MAXHITS 20000
void nop (void);


int main (int ac, char ** av)
{
    struct Process volatile *pr      = (APTR)FindTask(NULL);
    long	   volatile *nullptr = NULL;
    long   dummy   = 0;
    long   nhits   = MAXHITS;
    char  *arg	   = ac > 1 ? av[1] : "m";


    /* ---- this is for test purposes only - make sure we have a */
    /*	    pri lower than normal - other thasks wanna work, too */
    SetTaskPri(FindTask(NULL), -1);

    /* ---- now clear all signal bits */
    SetSignal(0,-1);

    /* ---- Enforce one task swap - we wanna have a new QUANTUM */
    /*	    (pr->pr_MsgPort.mp_SigBit is cleared within Delay)  */
    /*	    However, it seems, that this action has no effect:	*/
    /*	    the counts differ up to factor 4 (1-4 * 2500 hits)  */
    Delay(10);

    /* ---- Hitting Loop - does nothing but hitting until */
    /*	    we get a signal or have produced MAXHITS hits */
    switch (*arg) {
    case 's': /* single hit - count just loops after first hit */
	nhits = 0;
	dummy = *nullptr;
	while ((++nhits) && (!pr->pr_Task.tc_SigRecvd));
	nhits = MAXHITS - nhits;
	break;
    case 'm': /* multiple hits - each loop iteration one hit */
    default:
	do {
	    dummy |= *nullptr;
	    /* { int delay; for (delay = 0; delay < 40; ++delay) nop(); } /* delay - keep hitcount low */
	} while ((--nhits) && (!pr->pr_Task.tc_SigRecvd));
	break;
    } /* switch */

    /* ---- How many hits have we caused? */
    Printf ("%ld loop iterations since 1st hit\n", MAXHITS - nhits, dummy);

    return 0;
} /* main */

void nop (void) {
} /* nop */



#if 0
int main (int ac, char ** av)
    struct Process *pr = (APTR)FindTask(NULL);
    int i;
    STRPTR nullptr = NULL;
    STRPTR einsptr = (STRPTR)1L;

    /* ---- args */
    for (i = (ac > 1) ? atoi(av[1]) : 0; i >= 0; --i) {
	Delay (20);
	Printf ("taskpri == %ld\n", pr->pr_Task.tc_Node.ln_Pri);
	if (*nullptr)
	    break;
	if (*einsptr)
	    break;
	if (SetSignal(0,SIGBREAKF_CTRL_C))
	    break;
	//Delay(1);
	Printf ("taskpri == %ld\n", pr->pr_Task.tc_Node.ln_Pri);
	Delay(20);
    } /* for */
    Printf ("Terminating\n",0);
    return 0;
} /* main */
#endif


