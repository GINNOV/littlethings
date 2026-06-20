/*
 * RConfig Validation Suite by Anthon Pang, Omni Communications Products
 *
 * Object Code: resstart (residentable startup)
 * Assigned Test # 2
 * Requirements: Make program resident first and run two copies concurrently
 * Desired Observation(s):
 *   Small data model variables [from each instance] should be independent.
 */

#include <exec/types.h>
#include <dos/dos.h>
#include <clib/dos_protos.h>
#include <stdio.h>

#include "rlib.h"

/*
 * global
 */
long y;

void main() {
    y = 0L;

    printf("y = %ld\n",y);

    Delay(500); /* wait 10 seconds */

    y++; /* critical section */

    printf("y = %ld\n",y);

    exit(0);
}
