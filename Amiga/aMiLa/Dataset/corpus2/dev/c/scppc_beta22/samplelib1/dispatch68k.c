#define  _USEOLDEXEC_ 1
#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/memory.h>
#include <exec/resident.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <libraries/dos.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <string.h>
#include <dos/dostags.h>
#include <PowerUP/PPCLib/Interface.h>
#include <PowerUP/PPCLib/tasks.h>
#include <PowerUP/PPCLib/ppc.h>
#include <PowerUP/PPCLib/object.h>
#include <PowerUP/PPCLib/message.h>
#include <PowerUP/PPCDisslib/PPCDiss.h>
#include <PowerUP/pragmas/ppc_pragmas.h>
#include <PowerUP/clib/ppc_protos.h>
#include <PowerUP/pragmas/ppcdiss_pragmas.h>
#include <PowerUP/clib/ppcdiss_protos.h>

#define CallPPCFunction _CallPPCFunction
#include "ppcdispatch.h"
#undef CallPPCFunction

static void *ReplyPort;
static void *M68kPort;
static void *Task;
void *StartupMsg;
struct StartupData	*StartupData;

static struct PPCDispatchMsg *DispatchMsg;

struct MyLibrary {
        struct             Library ml_Lib;
        ULONG              ml_SegList;
        ULONG              ml_Flags;
        APTR               ml_ExecBase; /* pointer to exec base  */
#ifndef ONE_GLOBAL_SECTION
        long *             ml_relocs;   /* pointer to relocs.    */
        struct MyLibrary * ml_origbase; /* pointer to original library base  */
        long               ml_numjmps;
#endif
        void *             ml_MyObject; /* pointer to ELF Object */
        long               ml_ElfEntry; /* Entrypoint of Elf stub */

};


void *PPCPort;
struct Library *PPCLibBase;

int  __saveds __asm __libfpinit(register __a6 struct MyLibrary *libbase)
{
    static struct TagItem MyTags[17];
    struct DOSLibrary *DOSBase;

    DOSBase = (void *)OpenLibrary("dos.library", 0);
    if (DOSBase == NULL) return -1;

    if ((PPCLibBase = OpenLibrary("ppc.library", 0)) == NULL) 
    {
        CloseLibrary((void *)DOSBase);
        return -1;
    }

    MyTags[0].ti_Tag	=	TAG_DONE;
    if (ReplyPort = PPCCreatePort(MyTags))
    {
        if (M68kPort = PPCCreatePort(MyTags))
        {
            if (StartupMsg = PPCCreateMessage(ReplyPort, sizeof(struct StartupData)))
            {
                if (StartupData = PPCAllocVec(sizeof(struct StartupData), MEMF_ANY))
                {
                    
                    StartupData->MsgPort    = M68kPort;

                    MyTags[0].ti_Tag        =        PPCTASKTAG_ARG1;
                    MyTags[0].ti_Data       =        (ULONG) 0;

                    MyTags[1].ti_Tag        =        PPCTASKTAG_ARG2;
                    MyTags[1].ti_Data       =        (ULONG) _WBenchMsg;

                    MyTags[2].ti_Tag        =        PPCTASKTAG_ARG3;
                    MyTags[2].ti_Data       =        (ULONG) libbase;

                    MyTags[3].ti_Tag        =        PPCTASKTAG_ARG4;
                    MyTags[3].ti_Data       =        (ULONG) DispatchFunction;

                    MyTags[4].ti_Tag        =        PPCTASKTAG_STARTUP_MSG;
                    MyTags[4].ti_Data       =(ULONG) StartupMsg;

                    MyTags[5].ti_Tag        =        PPCTASKTAG_STARTUP_MSGDATA;
                    MyTags[5].ti_Data       =(ULONG) StartupData;
                
                    MyTags[6].ti_Tag        =        PPCTASKTAG_STARTUP_MSGLENGTH;
                    MyTags[6].ti_Data       =        sizeof(StartupData);

                    MyTags[7].ti_Tag        =        PPCTASKTAG_STARTUP_MSGID;
                    MyTags[7].ti_Data       =        0;

                    MyTags[8].ti_Tag        =        PPCTASKTAG_STACKSIZE;
                    MyTags[8].ti_Data       =        0x10000;

                    MyTags[9].ti_Tag        =        PPCTASKTAG_MSGPORT;
                    MyTags[9].ti_Data       =        TRUE;

                    MyTags[10].ti_Tag       =        PPCTASKTAG_INPUTHANDLE;
                    MyTags[10].ti_Data      =        (ULONG) Input();
                    
                    MyTags[11].ti_Tag       =        PPCTASKTAG_OUTPUTHANDLE;
                    MyTags[11].ti_Data      =        (ULONG) Output();

                    MyTags[12].ti_Tag       =        NP_CloseInput;
                    MyTags[12].ti_Data      =        FALSE;

                    MyTags[13].ti_Tag       =        NP_CloseOutput;
                    MyTags[13].ti_Data      =        FALSE;
 
                    MyTags[14].ti_Tag       =        PPCTASKTAG_BREAKSIGNAL;
                    MyTags[14].ti_Data      =        TRUE;

                    MyTags[15].ti_Tag       =        PPCTASKTAG_STOPTASK;
                    MyTags[15].ti_Data      =        FALSE;
                    
                    MyTags[16].ti_Tag       =        TAG_END;
    
                    if (Task = PPCCreateTask(libbase->ml_MyObject, &MyTags[0]))
                    {
Delay(1); /* seems to help a bit, but doesn't totally solve the problem */
          /* with V45.20 of ppc.library */
                        if (PPCPort=(void*) PPCGetTaskAttrsTags(Task,
                                                            PPCTASKINFOTAG_MSGPORT,0,
                                                            TAG_END))
                        {
                            CloseLibrary((void *)DOSBase);
                            return 0;  /* everything is set up */
                        }
                    }
                    PPCFreeVec(StartupData);
                }
                PPCDeleteMessage(StartupMsg);
            }
            PPCDeletePort(M68kPort);
        }
        PPCDeletePort(ReplyPort);
    }
    CloseLibrary(PPCLibBase);
    CloseLibrary((void *)DOSBase);

    return -1; /* failed */
}


__saveds long CallPPCFunction(long (*f)(...), long r3, long r4, long r5, long r6, 
                     long r7, long r8, long r9, long r10)
{
    long *ret;
    void *M68kMsg;
    struct PPCDispatchMsg *DispatchMsg;
    void *PPCMsg;
    long value;
    
    PPCMsg = PPCCreateMessage(ReplyPort, sizeof(*DispatchMsg));
    DispatchMsg = PPCAllocVec(sizeof(struct PPCDispatchMsg), MEMF_ANY);
    

    DispatchMsg->func = f;
    DispatchMsg->r3  = r3;
    DispatchMsg->r4  = r4;
    DispatchMsg->r5  = r5;
    DispatchMsg->r6  = r6;
    DispatchMsg->r7  = r7;
    DispatchMsg->r8  = r8;
    DispatchMsg->r9  = r9;
    DispatchMsg->r10 = r10;
    
    PPCSendMessage(PPCPort, PPCMsg, DispatchMsg,
                   sizeof(*DispatchMsg), 0x12345678);

    
    while(PPCGetMessage(ReplyPort) == NULL)
       PPCWaitPort(ReplyPort);


    PPCFreeVec(DispatchMsg);
    PPCDeleteMessage(PPCMsg);
    
    while ((M68kMsg = PPCGetMessage(M68kPort)) == NULL)
       PPCWaitPort(M68kPort);

    ret = (void *)PPCGetMessageAttr(M68kMsg, PPCMSGTAG_DATA);

    value = *ret;
    PPCReplyMessage(M68kMsg);
    return value;
  
}


#if 0

__saveds __asm void __UserLibTerm(register __a6 struct MyLibrary *libbase)
{
    DispatchMsg->func = NULL;
    
    PPCSendMessage(PPCPort, StartupMsg, DispatchMsg,
                   sizeof(*DispatchMsg), 0x12345678);

    
    PPCWaitPort(ReplyPort);

    PPCFreeVec(DispatchMsg);
    PPCDeleteMessage(StartupMsg);
    PPCDeletePort(M68kPort);
    PPCDeletePort(ReplyPort);

    CloseLibrary(PPCLibBase);
}

#endif


void __saveds __asm __libfpterm(register __a6 struct MyLibrary *libbase)
{
    struct PPCDispatchMsg *DispatchMsg;
    void *PPCMsg;
    
    PPCMsg = PPCCreateMessage(ReplyPort, sizeof(*DispatchMsg));
    DispatchMsg = PPCAllocVec(sizeof(struct PPCDispatchMsg), MEMF_ANY);
    
    DispatchMsg->func = NULL;
    
    PPCSendMessage(PPCPort, PPCMsg, DispatchMsg,
                   sizeof(*DispatchMsg), 0x12345678);

    while(PPCGetMessage(ReplyPort) != StartupMsg)
    {
        PPCWaitPort(ReplyPort);
    }
    

    PPCFreeVec(DispatchMsg);
    PPCDeleteMessage(PPCMsg);

    PPCDeleteMessage(StartupMsg);
    PPCFreeVec(StartupData);
    PPCDeletePort(M68kPort);
    PPCDeletePort(ReplyPort);

    CloseLibrary(PPCLibBase);

}


