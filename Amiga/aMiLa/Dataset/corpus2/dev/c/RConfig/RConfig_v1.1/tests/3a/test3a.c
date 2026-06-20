/*
 * RConfig Validation Suite by Anthon Pang, Omni Communications Products
 *
 * Object Code: better stkchk (stack check)
 * Assigned Test # 3a
 * Requirements: Compile with -bs -bd -at; process result with "stkchker"
 *   Use small stack (less than 16K)
 * Desired Observation(s):
 *   Should abort before corrupting memory outside of stack space, but
 *   not easily verified.  (ie revise this test)
 */

#include <stdio.h>

#include "rlib.h"

void main() {
    char x[16384];

    x[0] = 'X';

    puts("Done.\n");

    exit(0);
}
