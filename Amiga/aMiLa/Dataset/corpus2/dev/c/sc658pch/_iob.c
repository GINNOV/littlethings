#include <stdio.h>
#include <fcntl.h>
#include <ios1.h>
#include <string.h>
#include <stdlib.h>

#include <workbench/startup.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <exec/execbase.h>

#include "constructor.h"


extern char __stdiowin[];
extern char __stdiov37[];
extern struct WBStartup *_WBenchMsg;
extern struct ExecBase *SysBase;
extern FILE *__firstfile;
extern FILE *__stdinptr;
extern FILE *__stdoutptr;

/***
*
* The following array contains the control blocks used by the standard
* I/O functions. Any reference to it pulls in the constructor
*
***/

struct __iobuf __iob[3] = {
    { &__iob[1] },
    { &__iob[2] },
    {   NULL   }
};

static struct UFB  ufbs[3];
static void *save_ConsoleTask;

STDIO_CONSTRUCTOR(stdio_init)
{
    char *window;
    struct FileHandle *handle;
    struct Process *process;
    int x;

    __firstfile = stdin;
    __stdinptr = stdin;
    __stdoutptr = stdout;
    
    
    ufbs[0].ufbnxt = &ufbs[1];
    ufbs[1].ufbnxt = &ufbs[2];
    ufbs[2].ufbnxt = NULL;
    __ufbs = &ufbs[0];
    ufbs[0].ufbfn = NULL;
    ufbs[1].ufbfn = NULL;
    ufbs[2].ufbfn = NULL;
    ufbs[0].ufbflg = UFB_RA | O_RAW | UFB_NC;
    ufbs[1].ufbflg = UFB_WA | O_RAW | UFB_NC;
    ufbs[2].ufbflg = UFB_WA | O_RAW | UFB_NC | UFB_CLO;

    if (Output() == NULL) 
    {             /* running under workbench      */
        if (_WBenchMsg && _WBenchMsg->sm_ToolWindow)
            ufbs[0].ufbfh = Open(_WBenchMsg->sm_ToolWindow, MODE_NEWFILE);
        else
        {
           int len = 0;
           char *winname = NULL;
           char *p;
           
           len = strlen(__stdiowin);

           if (__stdiowin[len-1] == '/')
           {
               winname = "Output";
               if (_WBenchMsg) 
                  winname = _WBenchMsg->sm_ArgList->wa_Name; 
               
               len += strlen(winname);
           }

           if (SysBase->LibNode.lib_Version >= 36)
              len += strlen(__stdiov37);

           window = malloc(len);
           if (window == NULL) return 1; /* fail the autoinit */
           
           p = stpcpy(window, __stdiowin);
           if (winname)
              p = stpcpy(p, winname);

           if (SysBase->LibNode.lib_Version >= 36)
              p = stpcpy(p, __stdiov37);
           
           ufbs[0].ufbfh = Open(window, MODE_NEWFILE);
           free(window);
        }
        
        if (ufbs[0].ufbfh == NULL)
           ufbs[0].ufbfh = Open("NIL:", MODE_NEWFILE);
        
        ufbs[0].ufbflg |= UFB_CLO;
        handle = (struct FileHandle *) (ufbs[0].ufbfh << 2);
        process = (struct Process *) FindTask(0);
        save_ConsoleTask = process->pr_ConsoleTask;
        process->pr_ConsoleTask = (APTR) handle->fh_Type;
        if ((ufbs[1].ufbfh = Open("*", MODE_OLDFILE)) == NULL)
             ufbs[1].ufbfh = Open("NIL:", MODE_OLDFILE);
        ufbs[2].ufbfh = ufbs[1].ufbfh;
    } 
    else 
    {                     /* running under CLI            */
        ufbs[0].ufbfh = Input();
        ufbs[1].ufbfh = Output();
        if ((ufbs[2].ufbfh = Open("*", MODE_OLDFILE)) == NULL)
             ufbs[2].ufbfh = Open("NIL:", MODE_OLDFILE);
    }


    __nufbs += 3;


    x = (__fmode) ? 0 : _IOXLAT;
    stdin->_file = 0;
    stdin->_flag = _IOREAD | x;
    stdout->_file = 1;
    stdout->_flag = _IOWRT | _IOLBF | x;
    stderr->_file = 2;
    stderr->_flag = _IOWRT | _IOLBF | x;
    return 0; 

}


STDIO_DESSTRUCTOR(stdio_init)
{
   struct Process *process;

   process = (struct Process *) FindTask(0);
   process->pr_ConsoleTask = save_ConsoleTask;
}
    
