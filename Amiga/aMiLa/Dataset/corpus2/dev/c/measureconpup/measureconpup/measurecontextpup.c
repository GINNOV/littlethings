/* MeasureContextPUP
 * by Álmos Rajnai (Rachy/BiøHazard)
 * on 28.12.1999
 *
 *  mailto: racs@fs2.bdtf.hu
 *
 * measurecontextpup.c
 * This part is the environment around the core code.
 * (Done in C of course... :^)
 * Partly based on Simple_Timer.c example from Commodore-Amiga, Inc.
 *  and msg2.c example from phase5 PowerUP package examples.
 *
 * See .build file for compiling!
 *
 */

#include <exec/types.h>
#include <utility/tagitem.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <devices/timer.h>
#include <powerup/ppclib/tasks.h>

#include <proto/exec.h>
#include <clib/alib_protos.h>
#include <proto/dos.h>
#include <proto/ppc.h>

#include <stdio.h>

struct PPCmessage
{
 LONG type;
 LONG regD0;
 LONG regD1;
 LONG regA0;
 LONG regA1;
};

enum { PPCmsg_normal=0, PPCmsg_kill };

struct Library *TimerBase;
struct Library *PPCLibBase;
void *PPCPort;
void *M68kPort;
void *ReplyPort;
void *M68kMsg;
struct PPCmessage *Body;

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
 struct TagItem MyTags[10];
 void *StartupMsg;
 void *ElfObject;
 void *Task;

  printf("\nMeasuring context-switching on PowerUp\nBy Álmos Rajnai\n\n");

  if (PPCLibBase = OpenLibrary("ppc.library", 44))
  {
   if (ElfObject=PPCLoadObject("measurecontextpup.elf"))
   {
     MyTags[0].ti_Tag	=	TAG_DONE;
     if (ReplyPort = PPCCreatePort(MyTags))
     {
       if (M68kPort = PPCCreatePort(MyTags))
       {
         if (StartupMsg = PPCCreateMessage(ReplyPort, 0))
         {

           MyTags[0].ti_Tag = PPCTASKTAG_STARTUP_MSG;
           MyTags[0].ti_Data = (ULONG) StartupMsg;

           MyTags[1].ti_Tag = PPCTASKTAG_MSGPORT;
           MyTags[1].ti_Data = TRUE;

           MyTags[2].ti_Tag = PPCTASKTAG_STARTUP_MSGLENGTH;
           MyTags[2].ti_Data = 0;

           MyTags[3].ti_Tag = PPCTASKTAG_STARTUP_MSGDATA;
           MyTags[3].ti_Data = 0x123456;

           MyTags[4].ti_Tag = PPCTASKTAG_STARTUP_MSGID;
           MyTags[4].ti_Data = 0;

           MyTags[5].ti_Tag = TAG_DONE;

           if (Task = PPCCreateTask(ElfObject, MyTags))
           {

             MyTags[0].ti_Tag = PPCTASKINFOTAG_MSGPORT;
             MyTags[0].ti_Data = 0;

             MyTags[1].ti_Tag = TAG_DONE;

   /* VBCC inline seems a bit wrong on PPCGetTaskAttrs, it defined as
   PPCGetTaskInfo. Time to correct it, just like the others with Info
                       in the function names... */

             if (PPCPort=(void*) PPCGetTaskAttrs(Task,MyTags))
             {
               if (Body = PPCAllocVec(sizeof(struct PPCmessage), MEMF_PUBLIC))
               {
                 if (M68kMsg = PPCCreateMessage(ReplyPort, sizeof(struct PPCmessage)))
                 {
                   Body->type=PPCmsg_normal;

                   if ((tr=create_timer(UNIT_MICROHZ))!=NULL)
                   {

                   do {
                     printf("Number of context switches to be measured (max. 65535):");
                     scanf("%ld",&num);
                   } while ((num>65535)||(num<1));

                   printf("Starting %ld context-switches...",num);

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

                   }
                   else
                   {
                     printf("Cannot create timer\n");
                   }

                   Body->type=PPCmsg_kill;

                   PPCSendMessage(PPCPort,
                                  M68kMsg,
                                  Body,
                                  sizeof(struct PPCmessage),
                                  0x12345678);

                   for (;;)
                   {
                     PPCWaitPort(ReplyPort);
                     if (PPCGetMessage(ReplyPort) == StartupMsg)
                     {
                       break;
                     }
                   }

                   PPCDeleteMessage(M68kMsg);
                 }
                 else
                 {
                   Printf("Could not create message\n");
                 }
               }
               else
               {
                 Printf("Could not allocate memory for message body\n");
               }

               PPCFreeVec(Body); 
             }
             else
             {
               Printf("Could not find the PPCTask's msgport\n");
             }

           }
           else
           {
             Printf("Could not allocate Startup Data\n");
           }

             PPCDeleteMessage(StartupMsg);
         }
         else
         {
           Printf("Could not create Startup message\n");
         }

         PPCDeletePort(M68kPort);
       }
       else
       {
         Printf("Could not create m68k message port\n");
       }

       PPCDeletePort(ReplyPort);
     }

     PPCUnLoadObject(ElfObject);
   }
   else
   {
     Printf("Could not load the elfobject\n");
   }

   CloseLibrary(PPCLibBase);
  }
  else
  {
    Printf("Could not open ppc.library v44+\n");
  }

 return 0;
}

/* Phew! Easy, isn't it? Well, it IS NOT! WOS roxx... */

