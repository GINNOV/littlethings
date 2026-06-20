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

struct Library *PPCLibBase, *SysBase;
struct DosLibrary *DOSBase;

__saveds __asm __main(register __a0 char *cmdline)
{
  void *MyObject;
  char *p;
  long stacksize;
  struct Process *parent_process;
  struct CommandLineInterface *parent_cli;
  char *rdargs_line;
  int rdargs_length;
  char *cmdname;
  int cmdlength;
  ULONG	Result = -1;
  struct FileHandle *CurrentInput;
  ULONG OldBuffer;
  ULONG OldPosition;
  ULONG OldEnd;

  
  SysBase = *(struct Library **)4;

  parent_process = (void *)FindTask(NULL);
  parent_cli =  (void *) ((long)(parent_process->pr_CLI) << 2);
  stacksize = 0x10000;
  if (parent_cli)
      stacksize = parent_cli->cli_DefaultStack << 2;
  if (stacksize < 0x10000) stacksize = 0x10000;


  if ((DOSBase = (void *)OpenLibrary("dos.library", 0)) == NULL)
      return 20;

  if ((PPCLibBase = OpenLibrary("ppc.library",0)) == NULL)
  {
      CloseLibrary((void *)DOSBase);
      return 20;      
  }
  
  
  /* strip off the /n the end */
  p = cmdline + strlen(cmdline);
  p--;
  if (*p == '\n') *p = 0;

  for (p = cmdline; *p && *p != ' '; p++)
  {
      if (*p == '"')
      {
          /* search for closing " */
          p++;
          while (*p && *p != '"') p++;
      }
  }
  
  
  cmdlength = (p - cmdline)+1;
  cmdname = PPCAllocMem(cmdlength, MEMF_ANY);
  if (cmdname == NULL)
  {
      CloseLibrary((void *)PPCLibBase);
      CloseLibrary((void *)DOSBase);
      return 20;
  }
  memcpy(cmdname, cmdline, cmdlength-1);
  cmdname[cmdlength-1] = 0;
  
  if (*p == ' ') p++;  /* p now points to the args */
  rdargs_length = strlen(p)+2;
  rdargs_line = PPCAllocMem(rdargs_length, MEMF_ANY);
  if (rdargs_line == NULL)
  {
      PPCFreeMem(cmdname, cmdlength);
      CloseLibrary((void *)PPCLibBase);
      CloseLibrary((void *)DOSBase);
      return 20;
  }
  memcpy(rdargs_line, p, rdargs_length-2);
  rdargs_line[rdargs_length-2] = '\n';
  rdargs_line[rdargs_length-1] = '\0';
  

  CurrentInput		=(struct FileHandle*) BADDR(Input());
  OldBuffer		=	CurrentInput->fh_Buf;
  OldPosition		=	CurrentInput->fh_Pos;
  OldEnd		=	CurrentInput->fh_End;

  
  if (MyObject=PPCLoadObject(cmdname))
  {
        static struct TagItem	MyTags[13];

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
        MyTags[10].ti_Data      =       (ULONG)cmdname;
        MyTags[11].ti_Tag       =       NP_CommandName;
        MyTags[11].ti_Data      =       (ULONG)cmdname;
        MyTags[12].ti_Tag	=	TAG_END;

        Result=(ULONG) PPCCreateTask(MyObject,
                                     &MyTags[0]);
      
        UnGetC(Input(), -1);
        CurrentInput->fh_Buf	=	OldBuffer;
        CurrentInput->fh_Pos	=	OldPosition;
        if (CurrentInput->fh_End)
        {
            CurrentInput->fh_End	=	OldEnd;
        }

                                     
        PPCUnLoadObject(MyObject);
  }
  else
  {
    if (Output())
    {
        Write(Output(), "Can't load '", 12);
        Write(Output(), cmdline, strlen(cmdline));
        Write(Output(), "'\n", 2);
    }
  }
  
  PPCFreeMem(rdargs_line, rdargs_length);
  PPCFreeMem(cmdname, cmdlength);
  CloseLibrary(PPCLibBase);
  CloseLibrary((void *)DOSBase);
  return (int)Result;
}
