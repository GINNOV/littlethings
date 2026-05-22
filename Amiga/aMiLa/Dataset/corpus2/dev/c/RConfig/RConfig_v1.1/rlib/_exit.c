/*
 * _exit.c
 * ~~~~~~~
 *   Copyright (C) 1986,1987 by Manx Software Systems, Inc.
 *   Copyright (C) 1992 by Anthon Pang, Omni Communications Products.
 *
 */

#include <fcntl.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <pragmas/dos_lib.h>
#include <pragmas/exec_lib.h>

/*
 * globals
 */
extern int _argc, _arg_len;
extern char **_argv, *_arg_lin;
extern struct WBStartup *WBenchMsg;
extern void *DOSBase, *MathBase, *MathTransBase;
extern void *MathIeeeDoubBasBase, *MathIeeeDoubTransBase;
extern BPTR _detach_curdir;
extern void *_oldtrap, **_trapaddr;

#ifdef __RESSTART_MAIN
long _H_size;
#endif

void (*_cln)(void);

void _exit(int code) {
    long ret = code;
    register int fd;

    if (_devtab) {
        for (fd = 0 ; fd < _numdev ; fd++)
            close(fd);
        FreeMem(_devtab, _numdev*(long)sizeof(struct _dev));
    }
    if (_cln)
        (*_cln)();

#ifdef __DETACH_MAIN
    if (_detach_curdir)             /* for DETACHed programs */
        UnLock(_detach_curdir);
#endif

    if (_trapaddr)                  /* clean up signal handling */
        *_trapaddr = _oldtrap;
    if (MathTransBase)
        CloseLibrary(MathTransBase);
    if (MathBase)
        CloseLibrary(MathBase);
    if (MathIeeeDoubBasBase)
        CloseLibrary(MathIeeeDoubBasBase);
    if (MathIeeeDoubTransBase)
        CloseLibrary(MathIeeeDoubTransBase);
    {
#asm
        mc68881
        movem.l a5/a6,-(sp)
        move.l  4,a6            ;get ExecBase
        btst.b  #4,$129(a6)     ;check for 68881 flag in AttnFlags
        beq     1$              ;skip if not
        lea     2$,a5
        jsr     -30(a6)         ;do it in supervisor mode
        bra     1$
2$
        clr.l   -(sp)
        frestore (sp)+          ;reset the ffp stuff
        rte                     ;and return
1$
        move.l  (sp)+,a5/a6
#endasm
    }
    if (WBenchMsg == 0) {
        if (_arg_lin) {
            FreeMem(_arg_lin, (long)_arg_len);
            FreeMem(_argv, (long)(_argc+1)*sizeof(*_argv));
        }
    }
    else {
        Forbid();
        ReplyMsg((struct Message *)WBenchMsg);
    }
    CloseLibrary(DOSBase);
    {
#ifdef __RESSTART_MAIN
#asm
        move.l  __savsp#,sp     ;get back original stack pointer
        move.l  %%ret,-(sp)     ;save return exit code
        lea     -32766(a4),a1
        move.l  __H_size#,d0
        move.l  $0004,a6
        jsr     -$00d2(a6)      ;FreeMem()
        move.l  (sp)+,d0
        rts
#endasm
#else
#asm
        move.l  %%ret,d0        ;pick up return exit code
        move.l  __savsp#,sp     ;get back original stack pointer
        rts                     ;and exit
#endasm
#endif
    }
}
