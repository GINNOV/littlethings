/*      _main.c         Copyright (C) 1985  Lattice, Inc.       */

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

#define MAXARG 32              /* maximum command line arguments */
#define QUOTE  '"'
#define ESCAPE '*'
#define ESC '\027'
#define NL '\n'

#define isspace(c)      ((c == ' ')||(c == '\t') || (c == '\n'))

#ifndef TINY
extern int _fmode,_iomode;
extern int (*_ONBREAK)();
extern int CXBRK();
#endif

extern struct UFB _ufbs[];
static int argc;                       /* arg count */
static char **targv, *argv[MAXARG];     /* arg pointers */
static void badarg(char *program);

#define MAXWINDOW 40
extern struct WBStartup *WBenchMsg;
/**
*
* name         _main - process command line, open files, and call "main"
*
* synopsis     _main(line);
*              char *line;     ptr to command line that caused execution
*
* description   This function performs the standard pre-processing for
*               the main module of a C program.  It accepts a command
*               line of the form
*
*                       pgmname arg1 arg2 ...
*
*               and builds a list of pointers to each argument.  The first
*               pointer is to the program name.  For some environments, the
*               standard I/O files are also opened, using file names that
*               were set up by the OS interface module XCMAIN.
*
**/
void _main(line)
register char *line;
{
   register char **pargv;
   register int x;
   struct Process *process;
   struct FileHandle *handle;
   static char window[MAXWINDOW+18];
	char *argbuf;

/*
*
* Build argument pointer list
*
*/
   
   while (argc < MAXARG)
   {
        while (isspace(*line))  line++;
        if (*line == '\0')      break;
        pargv = &argv[argc++];
        if (*line == QUOTE)
        {
            argbuf = *pargv = ++line;  /* ptr inside quoted string */
    			while (*line != QUOTE)
				{
				   if (*line == ESCAPE)
					{
					      line++;
						switch (*line)
						{
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
		      line++;
		      *argbuf++ = '\0';	/* terminate arg */
        }
        else            /* non-quoted arg */
        {       
            *pargv = line;
            while ((*line != '\0') && (!isspace(*line))) line++;
            if (*line == '\0')  break;
            else                *line++ = '\0';  /* terminate arg */
        }
   }  /* while */
   targv = (argc == 0) ? (char **)WBenchMsg : (char **)&argv[0];


/*
*
* Open standard files
*
*/
#ifndef TINY

   if (argc == 0)          /* running under workbench      */
   {
        strcpy(window, "con:10/10/320/80/");
        strncat(window, WBenchMsg->sm_ArgList->wa_Name,MAXWINDOW);
        _ufbs[0].ufbfh = Open(window,MODE_NEWFILE);
        _ufbs[1].ufbfh = _ufbs[0].ufbfh;
        _ufbs[1].ufbflg = UFB_NC;
        _ufbs[2].ufbfh = _ufbs[0].ufbfh;
        _ufbs[2].ufbflg = UFB_NC;
        handle = (struct FileHandle *)(_ufbs[0].ufbfh << 2);
        process = (struct Process *)FindTask(0);
        process->pr_ConsoleTask = (APTR)handle->fh_Type;
        x = 0;
   }
   else                    /* running under CLI            */
   {
        _ufbs[0].ufbfh = Input();
        _ufbs[1].ufbfh = Output();
        _ufbs[2].ufbfh = Open("*", MODE_OLDFILE);
        x = UFB_NC;                     /* do not close CLI defaults    */
   }

   _ufbs[0].ufbflg |= UFB_RA | O_RAW | x;
   _ufbs[1].ufbflg |= UFB_WA | O_RAW | x;
   _ufbs[2].ufbflg |= UFB_RA | UFB_WA | O_RAW;

   x = (_fmode) ? 0 : _IOXLAT;
   stdin->_file = 0;
   stdin->_flag = _IOREAD | x;   
   stdout->_file = 1;
   stdout->_flag = _IOWRT | x;
   stderr->_file = 2;
   stderr->_flag = _IORW | x;

/*      establish control-c handler */

_ONBREAK = CXBRK;

#endif

/*
*
* Call user's main program
*
*/

   main(argc,targv);              /* call main function */
#ifndef TINY
   exit(0);
#else
_  exit(0);
#endif
}
