#include <exec/types.h>
#include <dos/dos.h>
#include <proto/dos.h>
#include <proto/exec.h>

#include <errno.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <internal/vars.h>

extern struct timeinfo *_odd_timer;
extern ULONG _odd_sig;
extern struct Library *TimerBase;

int convert_oserr(int ioerr);
void _seterr(void);
void __regargs __chkabort(void);

#define ERROR do { _seterr(); return -1; } while(0)
#define AMIGA_UID 1
#define AMIGA_GID 0

int _make_protection(int mode);
int _make_mode(int protection);
void _fibstat(struct FileInfoBlock *fib, int isroot, struct stat *sbuf, long dev);
