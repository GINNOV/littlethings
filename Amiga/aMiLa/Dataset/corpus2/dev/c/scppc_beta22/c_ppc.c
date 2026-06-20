int _start(char *);
extern struct WBStartup *_WBenchMsg;
_main(char *line, struct WBStartup *msg)
{
   if (line == 0L) _WBenchMsg = msg;
   return _start(line);
}

/***
*
*          Copyright © 1997 SAS Institute, Inc.
*
* name             __main - process command line, open files, and call main()
*
* synopsis         __main(line);
*                  char *line;     ptr to command line that caused execution
*
* description      This function performs the standard pre-processing for
*                  the main module of a C program.  It accepts a command
*                  line of the form
*
*                       pgmname arg1 arg2 ...
*
*                  and builds a list of pointers to each argument.  The first
*                  pointer is to the program name.  
*
***/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <setjmp.h>
#include <constructor.h>
#include <workbench/startup.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#include <exec/memory.h>
#include <powerup/gcclib/powerup_protos.h>
#include <proto/exec.h>
#include <proto/dos.h>

#define QUOTE       '"'
#define ESCAPE '*'
#define ESC '\x1b'
#define NL '\n'

#define isspace(c)      ((c == ' ')||(c == '\t') || (c == '\n'))

struct CTDT {
    long priority;
    int (*fp)(void);
};

static struct CTDT *sort_ctdt(struct CTDT **last);

static jmp_buf __exit_jmpbuf;
static int __exit_return;
struct DosLibrary *DOSBase;
struct ExecBase *SysBase;

struct WBStartup *_WBenchMsg;
char *_ProgramName = "";
int main(int, void *);
long __PPC_SHELL_START;   /* special symbol so P5 patch knows it's ok to load this */

BPTR __curdir;

static int argc;                   /* arg count */
static char **targv, **argv;       /* arg pointers */

int _start(char *line)
{
    char *argbuf;
    int ret;
    int i;
    struct CTDT *ctdt, *last_ctdt;

    SysBase = *(struct ExecBase **)4;
    DOSBase = (void *)OpenLibrary("dos.library",0);
    if (DOSBase == NULL) return 20;


    /* grab the current directory */
    __curdir = CurrentDir(0);
    CurrentDir(__curdir);

/***
*     First count the number of arguments
***/
   argbuf = line;

   if (line == NULL) argc = 0;
   else for (argc = 0; ; argc++)
   {
        while (isspace(*line))  line++;
        if (*line == '\0')      break;
        if (*line == QUOTE)
        {
            line++;
            while (*line != QUOTE && *line != 0)
            {
               if (*line == ESCAPE)
               {
                  line++;
                  if (*line == 0) break;
               }
               line++;
            }
            if (*line) line++;
        }
        else            /* non-quoted arg */
        {       
            while ((*line != '\0') && (!isspace(*line))) line++;
        }
   }

   if (argc)
   {
      argv = PPCAllocMem((argc+1) * sizeof(char *), MEMF_CLEAR);
      if (argv == NULL)
         return 20;
         
      /***
      *     Build argument pointer list
      ***/
      i = 0;
      line = argbuf;
      while (1)
      {
           while (isspace(*line))  line++;
           if (*line == '\0')      break;
           if (*line == QUOTE)
           {
               argbuf = argv[i++] = ++line;  /* ptr inside quoted string */
               while (*line != QUOTE && *line != 0)
               {
                  if (*line == ESCAPE)
                  {
                     line++;
                     switch (*line)
                     {
                        case '\0':
                           *argbuf = 0;
                           goto linedone;
                        case 'E':
                           *argbuf++ = ESC;
                           break;
                        case 'N':
                           *argbuf++ = NL;
                           break;
                        default:
                           *argbuf++ = *line;
                     }
                     line++;
                  }
                  else
                  {
                    *argbuf++ = *line++;
                  }
               }
               if (*line) line++;
               *argbuf++ = '\0'; /* terminate arg */
           }
           else            /* non-quoted arg */
           {       
               argv[i++] = line;
               while ((*line != '\0') && (!isspace(*line))) line++;
               if (*line == '\0')  break;
               else                *line++ = '\0';  /* terminate arg */
           }
      }  /* while */
      _ProgramName = argv[0];
   }
linedone:

    targv = (argc == 0) ? (char **) _WBenchMsg : (char **) &argv[0];


   /* LD merges all the contructors and destructors together in random */
   /* order. All destructors are negated, and then an unsigned sort  */
   /* is preformed, so the constructors come out first, followed by */
   /* the destructors in reverse order */
   ctdt = sort_ctdt(&last_ctdt);

   while (ctdt < last_ctdt && ctdt->priority >= 0)
   {
       if (ctdt->fp() != 0)
       {
           /* skip the remaining constructors */
           while (ctdt < last_ctdt && ctdt->priority >= 0)
              ctdt++;
           ret = 20;
           goto cleanup;
       }
       ctdt++;
   }




/***
*     Call user's main program
***/

/* We I get setjmp ported, I'll do a setjmp here, then */
/* have exit() do a longjmp back, and return            */
if ((ret = setjmp(__exit_jmpbuf)) == 0)
   {
       ret = main(argc, targv);                /* call main function */
       exit(ret); 
   }
else ret = __exit_return;


cleanup:

   
   /* call destructors here */
   while (ctdt < last_ctdt)
   {
      ctdt->fp();
      ctdt++;
   }

   if (argc && argv)
       PPCFreeMem(argv, (argc+1) * sizeof(char *));

   CloseLibrary((void *)DOSBase);

   return ret;
}


void _XCEXIT(long d0)
{
    /* this will longjmp back to main when longjmp is ready */
    __exit_return = d0;
    longjmp(__exit_jmpbuf, 1);
}



int _STI_0_dummy(void)
{
    /* dummy constructor there is something in the modules .ctdt section */
    return 0;
}

struct CTDT *get_last_ctdt(void);

static int comp_ctdt(struct CTDT *a, struct CTDT *b)
{
    if (a->priority == b->priority) return 0;
    if ((unsigned long)a->priority < (unsigned long) b->priority) return -1;
    return 1;    
}

static struct CTDT *sort_ctdt(struct CTDT **last)
{
    extern void *__builtin_getsectionaddr(int);
    struct CTDT *ctdt;
    struct CTDT *last_ctdt;
    
    ctdt = __builtin_getsectionaddr(4);  /* the ctdt section is pointed to by sym 4 */;

    last_ctdt = get_last_ctdt();         /* from end.o */
    
    qsort(ctdt, last_ctdt - ctdt, sizeof(*ctdt), comp_ctdt);
    
    *last = last_ctdt;
    
    return ctdt;
}
    
