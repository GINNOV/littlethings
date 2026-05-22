
/* Copyright (c) 1989-1994, Steve Krueger and Doug Walker, Raleigh, NC. */
/* All Rights Reserved.                                                 */

/* NOTE: Define the preprocessor symbol NOOLDDOS when compiling to */
/* save a little space if your program will never be run under     */
/* AmigaDOS 1.3 or earlier.                                        */

/* We need _USEOLDEXEC_ to ensure that the extern SysBase isn't used */
/* to access exec.library.  Since we're mucking about with our near  */
/* data register, we don't want to rely on near data to make exec    */
/* calls!                                                            */
#define _USEOLDEXEC_ 1

#include <exec/memory.h>
#include <exec/execbase.h>
#include <libraries/dosextens.h>
#include <dos/dostags.h>
#include <proto/exec.h>
#include <proto/dos.h>

#include <dos.h>
#include <string.h>

#include "amiproc.h"

extern struct ExecBase *SysBase;

// Functions defined in the SAS/C® library to run autoinitializer
// and autoterminater functions
void __stdargs __fpinit(void);
void __stdargs __fpterm(void);

// Data items defined in the SAS/C® library and possibly overridden
// by user code.  __stack gives the desired stack size, __priority
// gives the desired priority, and __procname gives the desired name
// for any new processes.
extern long __stack, __priority;
extern char *__procname;

extern char __far RESLEN;               /* size of init data   */
extern char __far RESBASE;              /* Base of global data */
extern char __far NEWDATAL;             /* size of global data */
extern const char __far LinkerDB;       /* Original A4 value   */
extern struct DosLibrary *DOSBase;
extern struct ExecBase *SysBase;
extern char *_ProgramName;
BPTR __curdir;

static struct DosLibrary *MyDOSBase;

#define DATAWORDS ((ULONG)&NEWDATAL)     /* magic to get right type of reloc */ 

static long _CloneData(void)
{
   ULONG *newa4;
   ULONG *origa4;
   ULONG *reloc;
   ULONG nrelocs;
   struct WBStartup *wbtmp = _WBenchMsg;
   char *pntmp = _ProgramName;
   BPTR cdtmp = __curdir;

   // Allocate the new data section
   newa4 = (ULONG *)AllocMem((ULONG)&RESLEN, MEMF_PUBLIC);
   if(newa4 == NULL) return NULL;

   // Get original A4 value
   // This points to the UNMODIFIED near global data section
   // allocated by the cres.o startup.  This line of code 
   // will also generate a linker warning; ignore it.
   origa4 = (ULONG *)((ULONG)&LinkerDB - (ULONG)&RESBASE);

   // Copy over initialized data
   memcpy(newa4, origa4, DATAWORDS*4);
   
   // Zero uninitialized data
   memset(newa4+DATAWORDS, 0, (((ULONG)&RESLEN)-DATAWORDS*4));

   // Perform relocations
   // The number of relocs is stashed immediately after the
   // initialized data in the original data section.  The
   // relocs themselves follow.
   origa4 += DATAWORDS;
   for(nrelocs = *origa4++; nrelocs>0; nrelocs--)
   {
      reloc = (ULONG *)((ULONG)newa4 + *origa4++);
      *reloc += (ULONG)newa4;
   }

   // If your code has >32k of near data, RESBASE will be 32k.
   // Otherwise, it will be 0.  The A4 pointer must point into
   // the middle of the data section if you have >32k of data
   // because the A4-relative addressing mode can handle +/-32k
   // of data, not 64k of positive data.
   newa4 += (ULONG)&RESBASE;
   putreg(REG_A4, (long)newa4);

   // Set up a couple of externs that the startup code normally
   // does for you...
   SysBase = *(struct ExecBase **)4;
   MyDOSBase = DOSBase = (struct DosLibrary *)OpenLibrary("dos.library", 0L);
   _WBenchMsg = wbtmp;       // Copied from old data section
   _ProgramName = pntmp;     // Copied from old data section
   __curdir = DupLock(cdtmp);// cdtmp copied from old data section

   return (long)newa4;
}

static void _FreeData(void)
{
   // Free the current directory lock
   UnLock(__curdir);

   // Close the local static copy of MyDOSBase
   CloseLibrary((struct Library *)MyDOSBase);
   
   // Free the new data section we allocated
   FreeMem((void *)getreg(REG_A4), (ULONG)&RESLEN);
}

struct FAKE_SegList {
   long space;
   long length;
   BPTR nextseg;
	short jmp;
	void (*func)(void);
};

struct AmiProcMsg {                     /* startup message sent to child */
        struct Message msg;
        int (*fp)(void *);              /* function we're going to call */
        void *global_data;              /* global data reg (A4)         */
        long return_code;               /* return code from process     */
        struct FAKE_SegList *seg;       /* pointer to fake seglist so   */
                                        /* can it can be free'd         */
        void *UserData;                 /* User-supplied data pointer   */
        };


static void process_starter(void)
{
   struct Process *proc;
   struct AmiProcMsg *mess;
   __regargs int (*fp)(void *, void *, void *);
         
   proc = (struct Process *)FindTask((char *)NULL);

   /* get the startup message */
   WaitPort(&proc->pr_MsgPort);
   mess = (struct AmiProcMsg *)GetMsg(&proc->pr_MsgPort);

   /* gather necessary info from message */
   fp = (__regargs int (*)(void *, void *, void *))mess->fp;

   /* replace this with the proper #asm for Aztec */
   putreg(REG_A4, (long)mess->global_data);
   
   /* Allocate a new data section */
   putreg(REG_A4, _CloneData());

   /* Run autoinitializers.  This has the effect of setting up    */
   /* the standard C and C++ libraries (including stdio), running */
   /* constructors for C++ externs and statics, and running user  */
   /* autoinit functions.                                         */
   __fpinit();

   /* Call the desired function */
   /* We pass the UserData parameter three times in order to satisfy */
   /* both PARM=REG and PARM=STACK function pointers.  Since we have */
   /* declared the local 'fp' to be regargs, the three parms will go */
   /* into A0, A1 and the stack.  If 'fp' points to a regargs func,  */
   /* it will get its parm from A0 and all is well.  If 'fp' points  */
   /* to a stdargs func, it will get its parameter from the stack and*/
   /* all is still well.                                             */
   mess->return_code = (*fp)(mess->UserData, mess->UserData, mess->UserData);

   /* Run autoterminators to clean up. */
   __fpterm();
   
   /* Free the recently-allocated data section */
   _FreeData();
   
   /* Forbid so the child can finish completely, before */
   /* the parent cleans up.                             */
   Forbid();

   /* Reply so process who spawned us knows we're done */   
   ReplyMsg((struct Message *)mess);

   /* We finish without Permit()ing, but it's OK since our task    */
   /* will end after the RTS, which will break the Forbid() anyway */
}


// AmiProc_Start - launch a new process with a specified function
// pointer as the entry point.
struct AmiProcMsg *AmiProc_Start(int (*fp)(void *), void *UserData)
{
   struct Process *process;
   struct MsgPort *child_port;
   struct AmiProcMsg *start_msg;
   BPTR in, out;
#ifndef NOOLDDOS
   struct FAKE_SegList *seg_ptr;
#endif
   int stack = (__stack > 4000 ? __stack : 4000);
   char *procname = (__procname ? __procname : "New Process");
   
   start_msg = (struct AmiProcMsg *)AllocMem(sizeof(struct AmiProcMsg), 
                                          MEMF_PUBLIC|MEMF_CLEAR);
   if (start_msg == NULL)
      return NULL;

#ifndef NOOLDDOS
   if(SysBase->LibNode.lib_Version > 36)
   {
      seg_ptr = NULL;  // We're not gonna use this, so null it
#endif

      if(!(in  = Open("*", MODE_OLDFILE))) in  = Open("NIL:", MODE_NEWFILE);
      if(!(out = Open("*", MODE_OLDFILE))) out = Open("NIL:", MODE_NEWFILE);

      /* Flush the data cache in case we're on a 68040 */
      CacheClearU();

      process =   CreateNewProcTags(NP_Entry,     process_starter,
                                    NP_StackSize,  stack,
                                    NP_Name,       procname,
                                    NP_Priority,   __priority,
                                    NP_Input,      in,
                                    NP_Output,     out,
                                    TAG_END);
      child_port = process ? &process->pr_MsgPort : NULL;
#ifndef NOOLDDOS
   }
   else
   {
      /* We're running under AmigaDOS 1.3 or earlier. */
      seg_ptr = (struct FAKE_SegList *)AllocMem(sizeof (*seg_ptr), MEMF_PUBLIC);
      if (seg_ptr == NULL) 
      {
         FreeMem(start_msg, sizeof(*start_msg));
         return NULL;
      }

      /* Fill in Fake SegList */
      seg_ptr->space = 0;
      seg_ptr->length = (sizeof(*seg_ptr) + 3) & ~3;
      seg_ptr->nextseg = NULL;
   
      /* Fill in JMP to function */
      seg_ptr->jmp = 0x4EF9;  /* JMP instruction */
      seg_ptr->func = process_starter;
   
      /* create the child process */   
      child_port = CreateProc(procname,
                              __priority,
                              (BPTR)((long)&seg_ptr->nextseg>>2),
                              stack);
   }
#endif

   if(child_port == NULL)
   {
      /* error, cleanup and abort */
#ifndef NOOLDDOS
      if(seg_ptr) FreeMem(seg_ptr, sizeof(*seg_ptr));
#endif
      FreeMem(start_msg, sizeof(*start_msg));
      return NULL;
   }
   
   /* Create the startup message */
   start_msg->msg.mn_Length = sizeof(struct AmiProcMsg) - sizeof(struct Message);
   start_msg->msg.mn_ReplyPort = CreatePort(0,0);
   start_msg->msg.mn_Node.ln_Type = NT_MESSAGE;
   
   /* replace this with the proper #asm for Aztec */
   start_msg->global_data = (void *)getreg(REG_A4);  /* save global data reg (A4) */

#ifndef NOOLDDOS
   start_msg->seg = seg_ptr;
#endif
   start_msg->fp = fp;                               /* Fill in function pointer */
   start_msg->UserData = UserData;   
   
   /* send startup message to child */
   PutMsg(child_port, (struct Message *)start_msg);
   
   return start_msg;
}

int AmiProc_Wait(struct AmiProcMsg *start_msg)
{
    struct AmiProcMsg *msg;
    int ret;
           
    /* Wait for child to reply, signifying that it is finished */
    while ((msg = (struct AmiProcMsg *)
                   WaitPort(start_msg->msg.mn_ReplyPort)) != start_msg) 
          ReplyMsg((struct Message *)msg);

    /* get return code */
    ret = msg->return_code;

    /* Free up remaining resources */
    DeletePort(start_msg->msg.mn_ReplyPort);
#ifndef NOOLDDOS
    if(start_msg->seg) 
       FreeMem((void *)start_msg->seg, sizeof(struct FAKE_SegList));
#endif
    FreeMem((void *)start_msg, sizeof(*start_msg));

    return(ret);
}

