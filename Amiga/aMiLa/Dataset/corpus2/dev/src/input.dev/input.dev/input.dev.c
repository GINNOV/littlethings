/*
 *
 *	DISCLAIMER:
 *
 *	This program is provided as a service to the programmer
 *	community to demonstrate one or more features of the Amiga
 *	personal computer.  These code samples may be freely used
 *	for commercial or noncommercial purposes.
 * 
 * 	Commodore Electronics, Ltd ("Commodore") makes no
 *	warranties, either expressed or implied, with respect
 *	to the program described herein, its quality, performance,
 *	merchantability, or fitness for any particular purpose.
 *	This program is provided "as is" and the entire risk
 *	as to its quality and performance is with the user.
 *	Should the program prove defective following its
 *	purchase, the user (and not the creator of the program,
 *	Commodore, their distributors or their retailers)
 *	assumes the entire cost of all necessary damages.  In 
 *	no event will Commodore be liable for direct, indirect,
 *	incidental or consequential damages resulting from any
 *	defect in the program even if it has been advised of the 
 *	possibility of such damages.  Some laws do not allow
 *	the exclusion or limitation of implied warranties or
 *	liabilities for incidental or consequential damages,
 *	so the above limitation or exclusion may not apply.
 *
 */

/* sample program for adding an input handler to the input stream */

/* note that this program also uses the PrepareTimer and SetTimer
 * and DeleteTimer described in the timer device chapter.  (PrepareTimer
 * is also sometimes called CreateTimer).  Must be linked with 
 * handler.interface.asm (object) in order to run.
 *
 */

/* note also that compiling this program native on the Amiga requires
 * a separate compile for this program, a separate assembly for the
 * handler.interface.asm, and a separate alink phase.  Alink will
 * be used to tie together the object files produced by the separate
 * language phases.
 *
 * Author:  Rob Peck, 12/1/85
 */

#include <exec/types.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <exec/io.h>
#include <exec/tasks.h>
#include <exec/interrupts.h>
#include <devices/input.h>
#include <exec/devices.h>
#include <devices/inputevent.h>

#define F1KEYUP 0xD0
struct InputEvent copyevent;	/* local copy of the event */
				/* assumes never has a next.event attached */
struct MsgPort *inputDevPort;
struct IOStdReq *inputRequestBlock;
struct Interrupt handlerStuff;

struct InputEvent dummyEvent;

extern struct MsgPort *CreatePort();
extern struct IOStdReq *CreateStdIO();

struct MemEntry me[10];

	/* If we want the input handler itself to add anything to the
	 * input stream, we will have to keep track of any dynamically
	 * allocated memory so that we can later return it to the system.
	 * Other handlers can break any internal links the handler puts
	 * in before it passes the input events.
	 */

struct InputEvent 
*myhandler(ev, mydata)
	struct InputEvent *ev; 	/* and a pointer to a list of events */
	struct MemEntry *mydata[];  /* system will pass me a pointer to my 
				     * own data space.
				 */
{
	/* demo version of program simply reports input events as
	 * its sees them; passes them on unchanged.  Also, if there
	 * is a linked chain of input events, reports only the lead
	 * one in the chain, for simplicity.  
	 */
	if(ev->ie_Class == IECLASS_TIMER) 
	{
		return(ev);
	}
	/* don't try to print timer events!!! they come every 1/10th sec. */
 	else 
	{
		Forbid();  /* don't allow a mix of events to be reported */
       		copyevent.ie_Class = ev->ie_Class;
        	copyevent.ie_SubClass = ev->ie_SubClass;
        	copyevent.ie_Code =  ev->ie_Code;
        	copyevent.ie_Qualifier = ev->ie_Qualifier;
        	copyevent.ie_X = ev->ie_X;
        	copyevent.ie_Y = ev->ie_Y;
        	copyevent.ie_TimeStamp.tv_secs = ev->ie_TimeStamp.tv_secs;
        	copyevent.ie_TimeStamp.tv_micro = ev->ie_TimeStamp.tv_micro;
		Permit();
	}

	/* There will be lots and lots of events coming through here;
	 * rather than make the system slow down because something
	 * is busy printing the previous event, lets just print what
	 * we find is current, and if we miss a few, so be it.
	 *
	 * Normally this loop would "handle" the event or perhaps
	 * add a new one to the stream.  (At this level, the only
	 * events you should really be adding are mouse, rawkey or timer,
	 * because you are ahead of the intuition interpreter.)
	 * No printing is done in this loop (lets main() do it) because
	 * printf can't be done by anything less than a 'process'
	 */
	return(ev);	
	/* pass on the pointer to the event (most handlers would
	 * pass on a pointer to a changed or an unchanged stream)
	 * (we are simply reporting what is seen, not trying to
	 * modify it in any way) */
}



/* NOTICE:  THIS PROGRAM LINKS ITSELF INTO THE INPUT STREAM AHEAD OF 
 * INTUITION.  THEREFORE THE ONLY INPUT EVENTS THAT IT WILL SEE AT 
 * ALL ARE TIMER, KEYBOARD and GAMEPORT.  AS NOTED IN THE PROGRAM,
 * THE TIMER EVENTS ARE IGNORED DELIBERATELY */


extern struct Task *FindTask();
struct Task *mytask;
LONG mysignal;
extern HandlerInterface();

struct timerequest *mytimerRequest;

extern struct timerequest *PrepareTimer();
extern int WaitTimer();
extern int DeleteTimer();

main()
{
	SHORT error;
	ULONG oldseconds, oldmicro, oldclass;

	/* init dummy event, this is what we will feed to other handlers
	 * while this handler is active */
	
	dummyEvent.ie_Class = IECLASS_NULL; /* no event happened */
	dummyEvent.ie_NextEvent = NULL;	/* only this one in the chain */
	
	inputDevPort = CreatePort(0,0);		/* for input device */
	if(inputDevPort == NULL) exit(-1);	/* error during createport */
	inputRequestBlock = CreateStdIO(inputDevPort);     
	if(inputRequestBlock == 0) { DeletePort(inputDevPort); exit(-2); }
					/* error during createstdio */

	mytimerRequest = PrepareTimer();
	if(mytimerRequest == NULL) exit(-3);

	handlerStuff.is_Data = (APTR)&me[0];
			/* address of its data area */
	handlerStuff.is_Code = (VOID)HandlerInterface;
			/* address of entry point to handler */
	handlerStuff.is_Node.ln_Pri = 51;
			/* set the priority one step higher than
		 	 * Intution, so that our handler enters
			 * the chain ahead of Intuition.
			 */
	error = OpenDevice("input.device",0,inputRequestBlock,0);
	if(error == 0) printf("\nOpened the input device");

	inputRequestBlock->io_Command = IND_ADDHANDLER;
	inputRequestBlock->io_Data = (APTR)&handlerStuff;
		
	DoIO(inputRequestBlock);
	copyevent.ie_TimeStamp.tv_secs = 0;
	copyevent.ie_TimeStamp.tv_micro = 0;
	copyevent.ie_Class = 0;
	oldseconds = 0;
	oldmicro = 0;
	oldclass =0;

	for(;;)			/* FOREVER */
	{
	WaitForTimer(mytimerRequest, 0, 100000);	
			/* TRUE = wait; time = 1/10th second */

	/* note: while this task is asleep, it is very very likely that
	 * one or more events will indeed pass through the input handler.
	 * This task will only print a few of them, but won't intermix
	 * the pieces of the input event itself because of the Forbid()
	 * and Permit() (not allow task swapping when a data structure
	 * isn't internally consistent) 
	 */
	if(copyevent.ie_Class == IECLASS_RAWKEY && copyevent.ie_Code == F1KEYUP)
		break;				/* exit from forever */
	else
	   {
		Forbid();
		if(copyevent.ie_TimeStamp.tv_secs != oldseconds ||
			copyevent.ie_TimeStamp.tv_micro != oldmicro ||
			copyevent.ie_Class != oldclass )
		{
			oldseconds = copyevent.ie_TimeStamp.tv_secs;	
			oldmicro   = copyevent.ie_TimeStamp.tv_micro;	
			oldclass   = copyevent.ie_Class;
			showEvents(&copyevent);
		}
		Permit();
	   }
	}
	/* Although this task sleeps (main loop), the handler is independently
	 * called by the input device.
	 */

	/* For keystrokes that might be recognized by AmigaDOS, such as
 	 * alphabetic or numeric keys, you will notice that after the
	 * first such keystroke, AmigaDOS appears to lock out your task
	 * and accepts all legal keystrokes until you finally hit return.
	 * This is absolutely true.... when both you and AmigaDOS try to
	 * write into the same window, as is true if you run this program
	 * from the CLI, the first keystroke recognized by AmigaDOS locks
	 * the layer into which it is writing.  Any other task trying
	 * to write into this same layer is put to sleep.  This allows
	 * AmigaDOS to edit the input line and prevents other output to
	 * that same window from upsetting the input line appearance.
	 * In the same manner, while your task is sending a line of output,
	 * AmigaDOS can be put to sleep it too must output at that time.
	 *
	 * You can avoid this problem if you wish by opening up a separate
	 * window and a console device attached to that window, and output
	 * strings to that console.  If you click the selection button on
	 * this new window, then AmigaDOS won't see the input and your
	 * task will get to see all of the keystrokes.  The other alternative
	 * you can use, for demonstration sake, is to:
	 *
	 *	1.  Make the AmigaDOS window slightly smaller in the 
	 * 		vertical direction.  
	 *	2.  Then click in the Workbench screen area outside 
	 *		of any window. 
	 * 
	 * Now there is no console device (particularly not AmigaDOS's
	 * console) receiving the raw key stream and your task will report
	 * as many keystrokes as it can catch (while not sleeping, that
	 * is).
	 */
	
	/* remove the handler from the chain */
	inputRequestBlock->io_Command = IND_REMHANDLER;
	inputRequestBlock->io_Data = (APTR)&handlerStuff;
	DoIO(inputRequestBlock);

	/* close the input device */
	CloseDevice(inputRequestBlock);

	/* delete the IO request */
	DeleteStdIO(inputRequestBlock);

	/* free other system stuff */
	DeletePort(inputDevPort);
	DeleteTimer(mytimerRequest);
}					/* end of main */

int
showEvents(e)
struct InputEvent *e;
{
	printf("\n\nNew Input Event");
        printf("\nie_Class = %lx",e->ie_Class);
        printf("\nie_SubClass = %lx",e->ie_SubClass);
        printf("\nie_Code = %lx", e->ie_Code);
        printf("\nie_Qualifier = %lx",e->ie_Qualifier);
        printf("\nie_X = %ld", e->ie_X);
        printf("\nie_Y = %ld", e->ie_Y);
        printf("\nie_TimeStamp(seconds) = %lx", e->ie_TimeStamp.tv_secs);
        return(0);
}

