#include <stdio.h>
#include "phonemes.h"
#include "globals.h"

#include <stdlib.h>
#include <string.h>

char *__MWLogName = "CON:0/0/639/199/MemLib";

void main(int argc, char **argv)
{
    char buffer[128];
    char *input;
    
    struct globalPart glob;
    
    if (argc != 2)
    {
        printf("need one arg\n");
        exit(10);
    }
    
    input = argv[1];
    
    __SetLibGlobals(0,&glob);
        
    if (__InitLibGlobals(0))
    {
        printf("Error initialising\n");
        exit(10);
    }
    
    if (__UserLibInit(0))
    {
        __CleanupLibGlobals(0);
        printf("Error initialising\n");
        exit(10);
    }
    
    Translate(input, strlen(input), buffer, sizeof buffer);
    printf("%s\n", buffer);
    
    __UserLibCleanup(0);
    __CleanupLibGlobals(0);
}
