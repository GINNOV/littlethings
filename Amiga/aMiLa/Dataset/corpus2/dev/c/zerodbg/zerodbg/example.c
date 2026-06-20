
//
// example.c
//

#include <stdio.h>

#include "debug.h"

const char *vers = "\0$VER: test 1.0 (01.05.2020) zerodbg test program";

int main(int argc, const char * argv[]) {
    debug("I see what you did there o_O!");
    log_info("standing still");

    return 0;
}