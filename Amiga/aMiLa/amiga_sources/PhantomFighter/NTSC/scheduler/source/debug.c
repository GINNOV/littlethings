/****************************************************
 * Depribugging software for Phantom Fighter
 *
 */

#include <exec/types.h>
#include <exec/tasks.h>

#include "debug.h"

char *Debug_Stack[MAXDEBUG+1];
int Debug_SP=0;
APTR OldTrapCode;

extern void DPRINTF();
extern void dprintf();

/**************************************************
 * This is the new Guru !
 *
 */
struct Task *MyTask;

char DebugExitString[]="Debugger forced exit";

char debug_buffer[100];

void Debug_Routine(Except)
ULONG Except;
{
  int i;
  for(i=0;i<10;++i)
     dprintf("Frame %2d is %s\n",i,Debug_Stack[(Debug_SP-i)&MAXDEBUG]);
  Debug();
}

/*extern struct Task *FindTask();*/

void Install_Debugger()
{
#ifdef qwerty
  MyTask=FindTask(0L);
  OldTrapCode=MyTask->tc_TrapCode;
  MyTask->tc_TrapCode=(APTR)Debug_Routine;
  MyTask->tc_Node.ln_Name="Debugger Running";
  Debug_SP=-1;
  Set_Debug("Debug Stack Empty");
  dprintf("Debug Stack at %lx, DSP at %lx\n",&Debug_Stack,&Debug_SP);
#endif
}


char DebugBuffer[128];

void DPRINTF(p1,p2,p3,p4,p5,p6,p7,p8,p9)
char *p1,*p2,*p3,*p4,*p5,*p6,*p7,*p8,*p9;
{
   sprintf(DebugBuffer,p1,p2,p3,p4,p5,p6,p7,p8,p9);
   kprintf(DebugBuffer);
}

extern struct BitMap *LBM;
extern struct BitMap *bm_bottom;

void dprintf(p1,p2,p3,p4,p5,p6,p7,p8,p9)
char *p1,*p2,*p3,*p4,*p5,*p6,*p7,*p8,*p9;
{
   sprintf(DebugBuffer,p1,p2,p3,p4,p5,p6,p7,p8,p9);
   kprintf(DebugBuffer);
}
   
