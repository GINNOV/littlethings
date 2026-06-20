/*
 * _main.c
 * ~~~~~~~
 *   Copyright (C) 1986,1987 by Manx Software Systems, Inc.
 *   Copyright (C) 1992 by Anthon Pang, Omni Communications Products.
 *
 *   This is common startup code for both the CLI and the WorkBench.
 *   When called from the WorkBench, argc is 0 and argv points to a
 *   WBStartup type of structure.
 */

#include <fcntl.h>
#include <exec/alerts.h>
#include <exec/memory.h>
#include <libraries/dosextens.h>
#include <workbench/startup.h>
#include <stdlib.h>
#include <string.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <pragmas/dos_lib.h>
#include <pragmas/exec_lib.h>

/*
 * globals
 */
extern long _savsp, _stkbase;
extern int errno;
extern int Enable_Abort;
extern int _argc, _arg_len;
extern char **_argv, *_arg_lin;
extern struct WBStartup *WBenchMsg;
extern struct _dev *_devtab;
extern short _numdev;

#ifdef __DETACH_MAIN
extern long _stack, _priority, _BackGroundIO;
extern char *_procname;
extern BPTR _detach_curdir;
extern char *_detach_name;
#endif

/*
 * external functions
 */
extern void _cli_parse(struct Process *pp, long alen, char *aptr);
extern void _wb_parse(struct Process *pp, struct WBStartup *WBenchMsg);
extern int main(int argc, char **argv);
extern void (*_cln)(void);

/*
 * _main.c
 */
#ifdef __DETACH_MAIN
static void do_detach(long *alen, char **aptr);
#endif

void _main(long alen, char *aptr) {
    register struct Process *pp;

#ifdef __DETACH_MAIN
    do_detach(&alen, &aptr);
#endif

    if ((_devtab = AllocMem(_numdev*(long)sizeof(struct _dev),
          MEMF_CLEAR)) == 0) {
        Alert(AG_NoMemory);
#asm
        move.l  __savsp,sp      ;get back original stack pointer
        rts                     ;and exit
#endasm
    }

    _devtab[0].mode = O_RDONLY;
    _devtab[1].mode = _devtab[2].mode = O_WRONLY;

    _stkbase = _savsp - *((long *)_savsp+1) + 8;
    *(long *)_stkbase = 0x4d414e58L;

    pp = (struct Process *)FindTask(0L);

#ifdef __DETACH_MAIN
    if (alen) {
#else
    if (pp->pr_CLI) {
#endif
        _cli_parse(pp, alen, aptr);
        Enable_Abort = 1;
#ifndef __DETACH_MAIN
        _devtab[0].mode |= O_STDIO;     /* shouldn't close if CLI */
        _devtab[1].mode |= O_STDIO;
#endif
    } else {
        WaitPort(&pp->pr_MsgPort);
        WBenchMsg = (struct WBStartup *)GetMsg(&pp->pr_MsgPort);
        if (WBenchMsg->sm_ArgList) {
            CurrentDir(WBenchMsg->sm_ArgList->wa_Lock);
            _wb_parse(pp, WBenchMsg);
        }
        _argv = (char **)WBenchMsg;
    }
    _devtab[0].fd = Input();
    _devtab[1].fd = Output();
    if (pp->pr_ConsoleTask)
        _devtab[2].fd = Open((UBYTE *)"*", (long)MODE_OLDFILE);
    exit(main(_argc, _argv));
}

#ifdef __DETACH_MAIN
BPTR _Backstdout = 0;
static long _alen = 0;
static char *_aptr = 0;

static void do_detach(long *alen, char **aptr) {
    register struct Process *pp;
    register unsigned short c;
    register char *cp;
    register struct CommandLineInterface *cli;
    register long l;
    long *lp, *sav;
    struct MemList *mm;
    struct Library *savlib;

    pp = (struct Process *)FindTask(0L);
    if (pp->pr_CLI) {           /* first time through!! */
        CurrentDir(_detach_curdir = CurrentDir(0L));
        _detach_curdir = DupLock(_detach_curdir);

        cli = (struct CommandLineInterface *) ((long)pp->pr_CLI << 2);
        l = cli->cli_Module;
        if ((savlib = OpenLibrary((UBYTE *)DOSNAME, 33L)) == 0) {

            lp = (long *)*((long *)*((long *)*((long *)*((long *)
                                            _savsp+2)+1)-3)-3)+107;
            if (*lp != cli->cli_Module)
                exit(100);
        } else {
            CloseLibrary(savlib);
            lp = 0;
        }
        if (lp)
            *lp = 0;
        if (_stack == 0)
            _stack = cli->cli_DefaultStack * 4;
        if (_BackGroundIO)
            _Backstdout = (BPTR)Open((UBYTE *)"*", (long)MODE_OLDFILE);
        _alen = *alen;
        if ((_aptr = AllocMem(_alen, 0L)) == 0)
            goto cleanup;
        memmove(_aptr, *aptr, (size_t)_alen);
        cp = (char *)((long)cli->cli_CommandName << 2);
        if ((_detach_name = AllocMem((long)cp[0]+1, 0L)) == 0)
            goto cleanup;
        memmove(_detach_name, cp, (size_t)cp[0]+1);
#asm
        move.l  __savsp,-(sp)
#endasm
        if (CreateProc((UBYTE *)_procname, _priority, l, _stack)) {
            cli->cli_Module = 0;
            l = 0;
        } else {
cleanup:
            if (_aptr)
                FreeMem(_aptr, _alen);
            if (_detach_name)
                FreeMem(_detach_name, (long)cp[0]+1);
            l = 1001;
        }
        ;
#asm
        move.l  (sp)+,sp
        move.l  %%l,d0
        rts
#endasm
    } else if (_alen) { /* second time */
        lp = (long *)((long)pp->pr_SegList << 2);
        lp = (long *)(lp[3] << 2);
        sav = lp;
        c = 2;
        while (lp) {
            lp = (long *)(*lp << 2);
            c++;
        }
        mm = AllocMem((long)sizeof(struct MemList)+
                            (c-1)*sizeof(struct MemEntry), 0L);
        lp = sav;
        mm->ml_NumEntries = c;
        c = 0;
        while (lp) {
            mm->ml_me[c].me_Addr = (APTR)((unsigned long)(lp - 1));
            mm->ml_me[c].me_Length = lp[-1];
            lp = (long *)(*lp << 2);
            c++;
        }
        mm->ml_me[c].me_Addr = (APTR)_aptr;
        mm->ml_me[c++].me_Length = _alen;
        mm->ml_me[c].me_Addr = (APTR)_detach_name;
        mm->ml_me[c++].me_Length = _detach_name[0] + 1;

        AddTail(&pp->pr_Task.tc_MemEntry, &mm->ml_Node);

        CurrentDir(_detach_curdir);

        pp->pr_COS = _Backstdout;

        *alen = _alen;
        *aptr = _aptr;

        if (!_BackGroundIO)
            pp->pr_ConsoleTask = 0;
    }
}
#endif
