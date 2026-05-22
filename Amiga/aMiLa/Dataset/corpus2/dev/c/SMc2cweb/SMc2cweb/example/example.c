/* This file is part of the c2cweb package Version 1.4 */
/* written by Werner Lemberg (a7621gac@awiuni11.bitnet) 20-Aug-1994 */

/* GrÅ· Gott! */

/* this is an artificial example C-file to demonstrate how c2cweb works. Please
   note the insertions of @ and @@ `commands' into the C code. You should try
   the various switches to see how they influence the output */

/* Say

        c2cweb [options] example.h example.c

   to process this example. */


#include <stdio.h>
#include <stdlib.h>
#include "example.h"

/*@*/

#define MAX_ARRAY 123
#define test_function(a, b, c) (a+b+c)

int   dummy1; /* two dummy variables */
float dummy2;

/*@*/

/* Two stupid functions */

#ifdef HELLO
void say_hello(void);
#else
void say_goodbye(void);
#endif

/*@@*/


void main(void)
   {int i=10000;
    struct Test test;

    while(i--)
        test.array[i]=i;

#ifdef HELLO
    say_hello();
#else
    say_goodbye();
#endif
   }

/*@*/

union {
    float another_dummy1;
    int   another_dummy2;
} AnotherTest;

/*@*/

#ifdef HELLO
void say_hello(void)
   {printf("\nHello\n");

// look at the unbalanced braces!
// without insertion of /*}*/ right here c2cweb and CWEAVE would be confused
/*}*/
#else
void say_goodbye(void)
   {printf("\nGoodbye!\n");
#endif
   }
