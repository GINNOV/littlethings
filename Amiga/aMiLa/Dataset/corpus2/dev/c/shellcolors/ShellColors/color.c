/*
**  Amiga Shell Colors and Text attributes
**  color.c
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 
#include "shellattrs.h"

void main()
{
    puts("\fAmigaShell Color-Test:");
    puts("======================\n");
    printf("%s", White);
    puts("This is a white-coloured Text");
    printf("%s", Black);
    puts("This is a black-coloured Text");
    printf("%s", Blue);
    puts("This is a blue-coloured Text\n"); 
    printf("%s", bgWhite);
    puts("Text on white Background      ");
    printf("%s", bgBlue);
    puts("Text on blue Background       ");
    printf("%s", bgInverse);
    puts("Text on inverse Background    ");
    printf("%s", bgDefault);
    puts("Text on default Background \n");
    
    printf("%s", Bold);
    puts("Some BOLD Text");
    printf("%s", Italic);
    puts("Some ITALIC Text");
    printf("%s", Underline);
    puts("Some UNDERLINED Text");
    printf("%s", UnderlineOFF);
    puts("Underline OFF\n");
    
    printf("%s", Reset);      
}
