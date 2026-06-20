/*
 * RConfig Validation Suite by Anthon Pang, Omni Communications Products
 *
 * Object Code: alloca & setjmp interdependence test
 * Assigned Test # 6
 * Requirements: alloca.h, rsetjmp.h
 * Desired Observation(s):
 *   Multiple alloca()'s; longjmp() should restore state, automatically
 *   free'ing alloca'd blocks
 */

#include <stdio.h>

#include "rlib.h"

jmp_buf myenv;

void proc2(int dummy)
{
    char *t;

    t = (char*)alloca(128);
    printf("%08lx\n", t);
    longjmp(myenv, 1);

    /* not reached */
    free(t); /* at least, it shouldn't be! */
}

void proc1(int dummy)
{
    char *y,*z;

    y = (char*)alloca(128);
    z = (char*)alloca(128);
    printf("%08lx %08lx ", y, z);
    proc2(1);
}

void main() {
    char x[2048];
    extern long _last_alloca_blk;

    x[0] = 'X';

    if (setjmp(myenv))
        puts("Done.\n");
    else {
        printf("Starting...%08lx\n", _last_alloca_blk);
        proc1(0);
    }

    exit(0);
}
