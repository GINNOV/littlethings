#include <string.h>
#include <exec/memory.h>
#include <libraries/dosextens.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <workbench/startup.h>
#include <workbench/workbench.h>
#include <workbench/icon.h>
#include <proto/icon.h>
#include <dos/dostags.h>
#include <PowerUP/PPCLib/Interface.h>
#include <PowerUP/PPCLib/tasks.h>
#include <PowerUP/PPCLib/ppc.h>
#include <PowerUP/PPCLib/object.h>
#include <PowerUP/PPCDisslib/PPCDiss.h>
#include <PowerUP/pragmas/ppc_pragmas.h>
#include <PowerUP/clib/ppc_protos.h>
#include <PowerUP/pragmas/ppcdiss_pragmas.h>
#include <PowerUP/clib/ppcdiss_protos.h>

struct Library *PPCLibBase;
char *_ProgramName;
extern __near long _ElfEntry;
extern __far int _PPCEntry(void);
long _StackPtr;
long __curdir;
long __stack;
long __base;
long _ONEXIT;
struct WBStartup *_WBenchMsg;

__stdargs int __fpinit(void)
{
    return 0;
}

__stdargs void __fpterm(void)
{
}


void __saveds __main(char *cmdline)
{
  void *MyObject;
  long stacksize;
  struct Process *parent_process;
  struct CommandLineInterface *parent_cli;
  char *rdargs_line;
  int rdargs_length;
  ULONG	Result = -1;
  struct FileHandle *CurrentInput;
  ULONG OldBuffer;
  ULONG OldPosition;
  ULONG OldEnd;
  static struct TagItem	MyTags[14];
  extern __far long _ElfObject;


  parent_process = (void *)FindTask(NULL);
  parent_cli =  (void *) ((long)(parent_process->pr_CLI) << 2);
  stacksize = 0x10000;
  if (parent_cli)
      stacksize = parent_cli->cli_DefaultStack << 2;
  if (stacksize < 0x10000) stacksize = 0x10000;


  if ((PPCLibBase = OpenLibrary("ppc.library",0)) == NULL)
     _XCEXIT(20);


  rdargs_length = strlen(cmdline)+2;
  rdargs_line = PPCAllocMem(rdargs_length, MEMF_ANY);
  if (rdargs_line == NULL)
  {
      CloseLibrary((void *)PPCLibBase);
      _XCEXIT(20);
  }

  memcpy(rdargs_line, cmdline, rdargs_length-2);
  rdargs_line[rdargs_length-2] = '\n';
  rdargs_line[rdargs_length-1] = '\0';

  MyTags[0].ti_Tag = PPCELFLOADTAG_ELFADDRESS;
  MyTags[0].ti_Data = (long)&_ElfObject;
  MyTags[1].ti_Tag = PPCELFLOADTAG_ELFNAME;
  MyTags[1].ti_Data = (long)_ProgramName;
  MyTags[2].ti_Tag = TAG_DONE;

  CurrentInput		=(struct FileHandle*) BADDR(Input());
  if (CurrentInput)
  {
     OldBuffer		=	CurrentInput->fh_Buf;
     OldPosition		=	CurrentInput->fh_Pos;
     OldEnd		=	CurrentInput->fh_End;
  }
  
  if (MyObject=PPCLoadObjectTagList(MyTags))
  {
        static struct TagItem	MyTags[16];
        struct PPCObjectInfo MyInfo;

        MyInfo.Address   =        0;
        MyInfo.Name      =        "__Entry";
        MyTags[0].ti_Tag =        TAG_END;

        PPCGetObjectAttrs(MyObject,
                          &MyInfo,
                          MyTags);
        _ElfEntry = MyInfo.Address;


        MyTags[0].ti_Tag	=	PPCTASKTAG_STOPTASK;
        MyTags[0].ti_Data	=	FALSE;
        MyTags[1].ti_Tag	=	PPCTASKTAG_WAITFINISH;
        MyTags[1].ti_Data	=	TRUE;
        MyTags[2].ti_Tag	=	PPCTASKTAG_INPUTHANDLE;
        MyTags[2].ti_Data	=	(ULONG) Input();
        MyTags[3].ti_Tag	=	PPCTASKTAG_OUTPUTHANDLE;
        MyTags[3].ti_Data	=	(ULONG) Output();
        MyTags[4].ti_Tag	=	PPCTASKTAG_ARG1;
        MyTags[4].ti_Data	=	(ULONG) cmdline;
        MyTags[5].ti_Tag	=	PPCTASKTAG_STACKSIZE;
        MyTags[5].ti_Data	=	stacksize;
        MyTags[6].ti_Tag	=	NP_CloseInput;
        MyTags[6].ti_Data	=	FALSE;
        MyTags[7].ti_Tag	=	NP_CloseOutput;
        MyTags[7].ti_Data	=	FALSE;
        MyTags[8].ti_Tag	=	PPCTASKTAG_BREAKSIGNAL;
        MyTags[8].ti_Data	=	TRUE;
        MyTags[9].ti_Tag	=	NP_Arguments;
        MyTags[9].ti_Data	=	(ULONG)rdargs_line;
        MyTags[10].ti_Tag       =       NP_Name;
        MyTags[10].ti_Data      =       (ULONG)_ProgramName;
        MyTags[11].ti_Tag       =       NP_CommandName;
        MyTags[11].ti_Data      =       (ULONG)_ProgramName;
        MyTags[12].ti_Tag	=	PPCTASKTAG_ARG3;
        MyTags[12].ti_Data	=	(ULONG) __builtin_getreg(REG_A4);
        MyTags[13].ti_Tag	=	PPCTASKTAG_ARG4;
        MyTags[13].ti_Data	=	(ULONG) _PPCEntry;
        MyTags[14].ti_Tag	=	PPCTASKTAG_ARG2;
        MyTags[14].ti_Data	=	(ULONG) _WBenchMsg;

        MyTags[15].ti_Tag	=	TAG_END;

        Result=(ULONG) PPCCreateTask(MyObject,
                                     &MyTags[0]);
                                     

        if (CurrentInput)
        {
           UnGetC(Input(), -1);
           CurrentInput->fh_Buf	=	OldBuffer;
           CurrentInput->fh_Pos	=	OldPosition;
           if (CurrentInput->fh_End)
           {
               CurrentInput->fh_End	=	OldEnd;
           }
        }
        
        PPCUnLoadObject(MyObject);
  }
  else
  {
    if (Output())
    {
        Write(Output(), "Can't load '", 12);
        Write(Output(), _ProgramName, strlen(_ProgramName));
        Write(Output(), "'\n", 2);
    }
  }
  
  PPCFreeMem(rdargs_line, rdargs_length);
  CloseLibrary(PPCLibBase);
  CloseLibrary((void *)DOSBase);
  _XCEXIT((int)Result);
}
