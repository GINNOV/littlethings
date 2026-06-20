/*
 * RConfig Validation Suite by Anthon Pang, Omni Communications Products
 *
 * Object Code: dynastack stkchk & setjmp interdependence test
 * Assigned Test # 5
 * Requirements: Compile with -bs -bd -at; process result with stkchker
 *   Use small stack (ie 8K); rsetjmp.h file
 * Desired Observation(s):
 *   Recursive loop chews up stack space, printing the contents (address value)
 *   of _stkbase; _stkbase changes as dynastack code builds extension stack
 *   during execution; unwinding stack at 65th iteration, longjmp should
 *   restore state & continue unwinding stack explicitly
 */

#ifndef __DYNASTACK_STKCHK
#define __DYNASTACK_STKCHK
#endif

#include <stdio.h>

#include "rlib.h"

jmp_buf myenv;

void proc(z)
int z;
{
    char y[127];
    extern long _stkbase;

    if (z == 100)
        return;
    else {
        /* recursion */
        printf("stackbase: %ld  iteration: %d\n",_stkbase,z);
        proc(z+1);

        if (z == 65) longjmp(myenv, 1);

        /* unwind stack */
        printf("stackbase: %ld  iteration: %d\n",_stkbase,z);
    }
}

void main() {
    char x[2048];

    x[0] = 'X';

    if (setjmp(myenv))
        printf("stackbase: %ld\nDone.\n",_stkbase);
    else
        proc(0);

    exit(0);
}
