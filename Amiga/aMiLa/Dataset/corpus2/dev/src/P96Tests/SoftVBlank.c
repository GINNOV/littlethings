#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/timer.h>
#include <proto/rtg.h>
#include <clib/alib_protos.h>

#include	<stdio.h>
#include	<math.h>

#include <devices/timer.h>

void main(void)
{
	struct timerequest *TimerIO[MaxNrOfBoards];
	struct MsgPort *TimerMP;
	struct Message *TimerMSG;
	struct RTGBase *RTGBase;

	ULONG error,x;

	if(RTGBase=(struct RTGBase *)OpenLibrary("picasso96/rtg.library",40)){
		if(TimerMP = CreatePort(0,0)){
			if(TimerIO[0] = (struct timerequest *)CreateExtIO(TimerMP,sizeof(struct timerequest))){
				/* Open the device once */

				if(!(error=OpenDevice(TIMERNAME, UNIT_MICROHZ, (struct IORequest *)TimerIO[0], 0L))){
					/* Set command to TR_ADDREQUEST */

					struct BoardInfo	*bi = RTGBase->Boards[0];
					struct ModeInfo	*mode = bi->ModeInfo;
					ULONG	micros;

					micros = 1000000*mode->HorTotal/mode->PixelClock*mode->VerTotal;
					if(mode->Flags & GMF_INTERLACE) micros>>=1;
					if(mode->Flags & GMF_DOUBLESCAN) micros<<=1;

					printf("Blank time: %ld micro seconds\n",micros);

					TimerIO[0]->tr_node.io_Command = TR_ADDREQUEST;

					TimerIO[0]->tr_time.tv_secs   = micros/1000000;
					TimerIO[0]->tr_time.tv_micro  = micros%1000000;

					while(!(*((UBYTE *)((ULONG)bi->RegisterBase+0x3da-0x8000)) & (1<<3)));

					SendIO((struct IORequest *)TimerIO[0]);

					WaitPort(TimerMP);

					TimerMSG=GetMsg(TimerMP);

					if(*((UBYTE *)((ULONG)bi->RegisterBase+0x3da-0x8000)) & (1<<3)){
						printf("Treffer!\n");
					}else{
						printf("Niete!\n");
					}

					CloseDevice((struct IORequest *) TimerIO[0]);
				}else{
					printf("\nError: Could not OpenDevice\n");
				}

				DeleteExtIO((struct IORequest *) TimerIO[0]);
			}else{
				printf("Error: could not create IORequest\n");
			}

			DeletePort(TimerMP);
		}else{
			printf("\nError: Could not CreatePort\n");
		}
	}else{
		printf("\nError: no rtg.library\n");
	}
}
