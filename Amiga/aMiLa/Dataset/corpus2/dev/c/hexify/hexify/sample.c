#include <stdlib.h>
#include <stdio.h>
#include "hexify.h"

const char *vers = "\0$VER: test 0.1 (01.05.2020) hexify sample program";
const char *copy = "Copyright (c) 2015 Jason Pepas";

int main(int argc, char **argv) {
    // pack a binary array
    unsigned char binary[4];
    binary[0] = 0xde;
    binary[1] = 0xad;
    binary[2] = 0xbe;
    binary[3] = 0xef;

    // convert it into a hex string
    char hex[8+1];
    hexify(binary, sizeof(binary), hex, sizeof(hex));

    // print the result
    printf("%s\n", hex);

    return 0;
}
