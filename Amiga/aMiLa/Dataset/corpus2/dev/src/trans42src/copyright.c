#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void main(int argc, char **argv)
{
    char buffer[512];
    char *q, *p = buffer;
    
    if (argc != 4)
    {
      usage:
        fprintf(stderr,"usage: copyright [ 020 | v37 | v33 ] <version> <date>\n");
        exit(10);
    }
    
    if (!strcmp(argv[1],"020")) q = " [68020]";
    else if (!strcmp(argv[1], "v33")) q = " [KS 1.3]";
    else if (!strcmp(argv[1], "v37")) q = "";
    else goto usage;
    
    sprintf(buffer, 
    "translator.library %s %s%s\n"
    "\n"
    "Copyright © 1995 Francesco Devitt\n"
    "(Internet: ffranc@comp.vuw.ac.nz)\n"
    "\n", argv[2], argv[3], q);
    
    for(;;)
    {
        char ch = *p++;
        char nc;
        
        nc = ch ^ (128+16);
        printf("%d, ", (unsigned char)nc);
        
        if (!ch) break;
    }
    printf("\n");
}
