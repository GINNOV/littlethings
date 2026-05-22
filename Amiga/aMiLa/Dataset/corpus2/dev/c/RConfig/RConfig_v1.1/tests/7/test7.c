/*
 * RConfig Validation Suite by Anthon Pang, Omni Communications Products
 *
 * Object Code: dynastack stkchk, alloca & setjmp interdependence test
 * Assigned Test # 7
 * Requirements: Compile with -bs -bd -at; process result with stkchker
 *   Use small stack (ie 8K); alloca.h, rsetjmp.h
 * Desired Observation(s):
 *   Recursive loop chews up stack space, printing the contents (address value)
 *   of _stkbase; _stkbase changes as dynastack code builds extension stack
 *   during execution; unwinding stack at 65th iteration, longjmp should
 *   restore state & continue unwinding stack explicitly and free'ing alloca'd
 *   blocks
 */

#include <stdio.h>

#include "rlib.h"

jmp_buf myenv;

void proc(z)
int z;
{
    char y[127];
    char *x;
    extern long _stkbase;
    extern long _last_alloca_blk;

    if (z == 100)
        return;
    else {
        /* recursion */
        x = (char*)alloca(128);
        printf("alloca'd blk: %ld, last alloca'd blk: %ld\n", x, _last_alloca_blk);

        printf("stackbase: %ld  iteration: %d\n",_stkbase,z);
        proc(z+1);

        if (z == 65) longjmp(myenv, 1);

        /* unwind stack */
        printf("stackbase: %ld  iteration: %d\n",_stkbase,z);
    }
}

void main() {
    char x[2048];
    extern long _last_alloca_blk;

    x[0] = 'X';

    if (setjmp(myenv))
        printf("stackbase: %ld, _last_alloca_blk %ld\nDone.\n",
            _stkbase, _last_alloca_blk);
    else
        proc(0);

    exit(0);
}
