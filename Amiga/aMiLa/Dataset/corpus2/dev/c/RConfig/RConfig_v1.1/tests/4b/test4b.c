/*
 * RConfig Validation Suite by Anthon Pang, Omni Communications Products
 *
 * Object Code: risky alloca
 * Assigned Test # 4b
 * Requirements: rlib.h
 * Desired Observation(s): Prints address of block allocated
 */

#include <stdio.h>
#include "alloca.h"

void test(int t) {
    char *p;
    int x;

    /*
     *  risky alloca() takes as its only parameter the size of the block
     *    to allocate; it makes the bold assumption that register a5 is
     *    used in the current procedure for a local stack frame
     */

    p = (char*)alloca(t);

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
