/*
 * RConfig Validation Suite by Anthon Pang, Omni Communications Products
 *
 * Object Code: safe alloca
 * Assigned Test # 4a
 * Requirements: alloca.h
 * Desired Observation(s): Prints address of block allocated
 */

#include <stdio.h>

#include "rlib.h"

void test(int t) {
    char *p;
    int x;

    /*
     *  safe alloca() takes as its first parameter the first stackbased
     *    parameter of the calling procedure, if any, in order to deduce
     *    the position of the return address; if there is no such parameter
     *    the programmer must use add a dummy variable to the procedure's
     *    declaration
     *
     *  the second parameter is the size of the block to allocate
     */

    p = (char*)alloca(t, t);

    if (p==NULL) {
        printf("Unable to alloca()\n");
        return;
    }
        
    printf("%ld\n", p);
}

main() {
    test(16384);
    puts("Done.\n");
}
