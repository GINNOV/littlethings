/*
*-----------------------------------------------------------------------------
*       file:   cparser.c
*       desc:   simple command parser
*       by:     patrick ko
*       date:   22 aug 91 v0.1
*       revi:   26 feb 92 v0.2; response file feature
*       revi:   27 may 92 v0.3; fix the multiple response file bug
*-----------------------------------------------------------------------------
*/
#include <stdio.h>
#include <stdlib.h>

#ifdef __TURBOC__
#include <mem.h>
#include <ctype.h>
#endif

#include "cparser.h"

#define CP_START        1
#define CP_GETCMDLINE   2
#define CP_GETRSPLINE   3
#define CP_CMDSEARCH    4
#define CP_RETURN       5

CMDTBL  cmdtbl[] =
        {
        {CMD_DIMINPUT,          "-i="},
        {CMD_DIMOUTPUT,         "-o="},
        {CMD_DIMHIDDENY,        "-hh="},
        {CMD_DIMHIDDEN,         "-h="},
        {CMD_TRAINFILE,         "-ftrain="},
        {CMD_TOTALPATT,         "-samp="},
        {CMD_DUMPIN,            "-fdumpin="},
        {CMD_DUMPFILE,          "-fdump="},
        {CMD_RECOGFILE,         "-frecog="},
        {CMD_OUTFILE,           "-fout="},
        {CMD_TRAINERR,          "-err="},
        {CMD_TOLER,             "-torerr="},
        {CMD_REPORT,            "-r="},
        {CMD_TDUMP,             "-tdump="},
        {CMD_TIMER,             "-t"},
        {CMD_WPOS,              "-w+="},
        {CMD_WNEG,              "-w-="},
        {CMD_COMMENT,           "//"}
        };

static int      cmdtblsize = 0;
static int      cmdargc = 0;
static int      cmdcnt = 0;
static char     **cmdargv;


int cmdsearch( str, rest )
char    *str;
char    *rest;
{
        int     i, l;
        
        for (i=0; i<cmdtblsize; i++)
                {
                l = strlen( cmdtbl[i].cmdstr );
                if (!memcmp(str, cmdtbl[i].cmdstr, l))
                        {
                        strcpy( rest, str + l );
                        return (cmdtbl[i].cmdno);
                        }
                }
        strcpy( rest, str );
        return (CMD_NULL);
}

int cmdinit( argc, argv )
int     argc;
char    **argv;
{
        cmdtblsize = sizeof(cmdtbl) / sizeof(cmdtbl[0]);
        cmdargc = argc;
        cmdargv = argv;
}


/*
*------------------------------------------------------------------------------
*       funct:  cmdget
*       desct:  get a command either from command line or response file
*       given:  rest = rest of the command line string
*               e.g. if a command is "-example=" and in the command line
*               we have "-example=32787" then rest will contain "32787".
*       retrn:  the command token specified in cparser.h (you defined)
*
*       state table:
*
*               START  GETCMD  GETRSP  SEARCH  RETURN
*       START   x      fsp=0   fsp!=0  x       x
*       GETCMD  x      x       @       not @   no cmd 
*       GETRSP  no cmd x       x       cmd     x
*       SEARCH  x      x       x       x       result
*       RETURN  x      x       x       x       x
*------------------------------------------------------------------------------
*/
int cmdget( rest )
char    *rest;
{
        int     i, j;
        int     state, result;
        char    cmdstr[129], *rspname;
        static FILE *frsp;

        state = CP_START;
        result = -1;
        *cmdstr = 0;

        while (1)
                {
                switch (state)
                {
                case CP_START:
                if (frsp == NULL)
                        state = CP_GETCMDLINE;
                else
                        state = CP_GETRSPLINE;
                break;

                case CP_GETCMDLINE:
                if ((cmdcnt >= cmdargc - 1))
                        {
                        state = CP_RETURN;
                        result = -1;
                        }
                else
                        {
                        /* test for response file */
                        rspname = *(cmdargv + cmdcnt + 1);
                        cmdcnt++;
                        if (*rspname == '@')
                        {
                        rspname++;
                                if ((frsp = fopen(rspname, "r")) == NULL)
                                {
                                fprintf(stderr, "rsp file open fails\n");
                                exit (1);
                                }
                                else
                                state = CP_GETRSPLINE;
                                }
                        else
                        {
                                strcpy( cmdstr, *(cmdargv + cmdcnt) );
                                state = CP_CMDSEARCH;   
                        }
                        }
                break;

                case CP_GETRSPLINE:
                for (;!strlen(cmdstr) && !feof(frsp);)
                        {
                        fgets(cmdstr, 128, frsp);
                        for (i=j=0; i<strlen(cmdstr); i++)
                                {
                                if (!isspace(cmdstr[i]))
                                        {
                                        cmdstr[j++] = cmdstr[i];
                                        }
                                }
                        cmdstr[j] = 0;
                        }
                if (feof(frsp))
                        {
                        fclose(frsp);
                        frsp = NULL;
                        }
                if (strlen(cmdstr))
                        state = CP_CMDSEARCH;
                else 
                        state = CP_START;
                break;
        
                case CP_CMDSEARCH:
                result = cmdsearch( cmdstr, rest );
                state = CP_RETURN;
                break;

                case CP_RETURN:
                return (result);
                }
                }
}
