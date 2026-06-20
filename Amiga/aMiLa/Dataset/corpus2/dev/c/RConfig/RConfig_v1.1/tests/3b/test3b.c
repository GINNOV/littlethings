/*
 * RConfig Validation Suite by Anthon Pang, Omni Communications Products
 *
 * Object Code: better stkchk (dynastack)
 * Assigned Test # 3b
 * Requirements: Compile with -bs -bd -at; process result with stkchk.rexx
 *   Use small stack (ie 8K)
 * Desired Observation(s):
 *   Recursive loop chews up stack space, printing the contents (address value)
 *   of _stkbase; _stkbase changes as dynastack code builds extension stack
 *   during execution
 */

#include <stdio.h>

#include "rlib.h"

void proc(z)
int z;
{
    char y[127];
    extern long _stkbase;

    if (z >= 100)
        return;
    else {
        /* recursion */
        printf("stackbase: %ld  iteration: %d\n",_stkbase,z);
        proc(z+1);

        /* unwind stack */
        printf("stackbase: %ld  iteration: %d\n",_stkbase,z);
    }
}

void main() {
    char x[2048];

    x[0] = 'X';
    proc(0);

    puts("Done.\n");

    exit(0);
}
