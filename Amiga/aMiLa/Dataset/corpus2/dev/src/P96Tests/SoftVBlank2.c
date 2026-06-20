#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/timer.h>
#include <proto/rtg.h>

#include	<stdio.h>
#include	<math.h>
#include <clib/alib_protos.h>
#include <devices/timer.h>

int Count=0;
BYTE signal;
struct MsgPort TimerMP;
struct Task *task;
struct Library *TimerBase;
struct timeval	before, after;

int __interrupt __saveds Code(void);

void main(void)
{
	struct timerequest *TimerIO;
	struct Interrupt Interrupt;
	ULONG error;
	
	task=FindTask(NULL);

	TimerMP.mp_Flags = PA_SOFTINT;
	TimerMP.mp_SoftInt = &Interrupt;
	NewList(&TimerMP.mp_MsgList);
	
	Interrupt.is_Data = NULL;
	Interrupt.is_Code = (void (*)())Code;
	Interrupt.is_Node.ln_Type = NT_INTERRUPT;
	Interrupt.is_Node.ln_Pri = 0;
	Interrupt.is_Node.ln_Name = "SoftVBlank";

	if((signal = AllocSignal(-1)) != -1){
		if(TimerIO = (struct timerequest *)CreateExtIO(&TimerMP,sizeof(struct timerequest))){
			/* Open the device once */

			if(!(error=OpenDevice(TIMERNAME, UNIT_MICROHZ, (struct IORequest *)TimerIO, 0L))){
				/* Set command to TR_ADDREQUEST */
				TimerBase = TimerIO->tr_node.io_Device;

				TimerIO->tr_node.io_Command = TR_ADDREQUEST;

				TimerIO->tr_time.tv_secs   = 0;
				TimerIO->tr_time.tv_micro  = 15000;
			
				printf("schicke Request\n");

				
				GetSysTime(&before);
				SendIO((struct IORequest *)TimerIO);

				printf("warte...\n");

				Wait(1L<<signal);

				SubTime(&after, &before);				
				printf("bekam Signal nach %ld Sekunden und %ld Micros\n",after.tv_secs,after.tv_micro);

				CloseDevice((struct IORequest *) TimerIO);
				
				printf("fertig.\n");
			}else{
				printf("\nError: Could not OpenDevice\n");
			}

			DeleteExtIO((struct IORequest *) TimerIO);
		}else{
			printf("Error: could not create IORequest\n");
		}
		
		FreeSignal(signal);
	}else{
		printf("Error: could not get Signal\n");
	}
}

int __interrupt __saveds Code(void)
{
	struct Message *TimerMSG;

	GetSysTime(&after);
	if(TimerMSG=GetMsg(&TimerMP)){
		Count ++;
	}
	
	Signal(task, 1L<<signal);
	
	return(0);
}
