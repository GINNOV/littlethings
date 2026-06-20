/* MeasureContextWOS
 * by Álmos Rajnai (Rachy/BiøHazard)
 * on 21.11.1999
 *
 *  mailto: racs@fs2.bdtf.hu
 *
 * measurecontextwos.c
 * This part is the environment around the core code.
 * (Done in C of course... :^)
 * Partly based on Simple_Timer.c example from Commodore-Amiga, Inc.
 *
 * See .build file for compiling!
 *
 */

#include <exec/types.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <devices/timer.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/dos_protos.h>

#include <stdio.h>

struct Library *TimerBase;
struct Library *PowerPCBase;

extern void timer68k(__reg("d0") ULONG num);

struct timerequest *create_timer(ULONG unit)
{
 LONG error;
 struct MsgPort *timerport;
 struct timerequest *TimerIO;

 timerport=CreatePort(0,0);
 if (timerport==NULL) return(NULL);

 TimerIO = (struct timerequest *)
	CreateExtIO(timerport, sizeof(struct timerequest));
 if (TimerIO == NULL)
 {
	DeletePort(timerport);
	return(NULL);
 }

 if (OpenDevice(TIMERNAME, unit,(struct IORequest *) TimerIO, 0L))
 {
	delete_timer(TimerIO);
	return(NULL);
 }
 TimerBase=(struct Library *)TimerIO->tr_node.io_Device;

 return(TimerIO);
}

void delete_timer(struct timerequest *tr )
{
 struct MsgPort *tp;

 if (tr!=0)
 {
	tp=tr->tr_node.io_Message.mn_ReplyPort;

	if (tp!=0) DeletePort(tp);

	CloseDevice((struct IORequest *)tr);
	DeleteExtIO((struct IORequest *)tr);
 }
 TimerBase=NULL;

}

int main()
{
 struct timerequest *tr;
 struct timeval oldtimeval;
 struct timeval currenttimeval;
 LONG num;

 if ((PowerPCBase=OpenLibrary("powerpc.library",0))==NULL)
 {
	printf("Cannot open powerpc.library\n");
	return 0;
 }

 if ((tr=create_timer(UNIT_MICROHZ))==NULL)
 {
	printf("Cannot create timer\n");
	CloseLibrary(PowerPCBase);
	return 0;
 }

 printf("\nMeasuring context-switching on WarpOS\nBy Álmos Rajnai\n\n");
 do {
	printf("Number of context switches to be measured (max. 65535):");
	scanf("%ld",&num);
 } while ((num>65535)||(num<1));

 printf("Starting %ld context-switch...",num);

 tr->tr_node.io_Command=TR_GETSYSTIME;
 DoIO((struct IORequest *)tr);
 oldtimeval = tr->tr_time;

 /*** Starting context switches ***/

 timer68k(num);

 /*** End of context switches ***/

 DoIO((struct IORequest *)tr);
 currenttimeval=tr->tr_time;

 SubTime(&currenttimeval, &oldtimeval);
 printf("done! \nEllapsed: %ld sec %ld microsec, ",
	currenttimeval.tv_secs, currenttimeval.tv_micro);
 printf("~%ld microsec each.\n",
	(currenttimeval.tv_secs*1000000+currenttimeval.tv_micro)/num);

 delete_timer(tr);
 CloseLibrary(PowerPCBase);

 return 0;
}

/* Phew! Easy, isn't it? :D */

