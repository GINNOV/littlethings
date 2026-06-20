#include "amiga.h"
#include "signals.h"
#include <setjmp.h>

int setjmp(jmp_buf jb)
{
    jb[0] = _sig_mask;
    return _setjmp(jb + 1);
}

void longjmp(jmp_buf jb, int val)
{
    sigsetmask(jb[0]);
    _longjmp(jb + 1, val);
}
