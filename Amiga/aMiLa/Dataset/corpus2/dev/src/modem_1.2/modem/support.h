/*
        This program is copyright 1990, 1993 Stephen Norris. 
        May be freely distributed provided this notice remains intact.
*/

#ifndef SUPPORT_H
#define SUPPORT_H

#include "console.h"

#define assert(x) if (!(x)){ printf("Assertion failed at %d in %s.\n",__LINE__,__FILE__); exit(20); }

#define MAX(a,b) a>b?a:b
#define MIN(a,b) a<b?a:b

#ifndef SUPPORT_C
extern char *NoMem;
#endif

void message(char *Text);

#define DEBUG 1

#endif
