#include <exec/types.h>
#include <stdio.h>
#include <functions.h>
#include "link.h"

#define RTC printf("return to continue - ");fflush(stdout);\
getchar();

#define DOUBARG 19

main()
{
        LONG    retval;

        printf("here we go\n");
        libbase = (APTR) OpenLibrary("mylib.library", 0L);
        printf("openlib returns base: %lx\n", libbase);

        RTC;

        if (libbase)
        {
                /* test function GetDown()      */
                retval = GetDown();
                printf("called getdown, %ld returned\n", retval);
                RTC;

                /* test function Double()       */
                printf("double of %d = %ld\n", DOUBARG, Double((LONG)DOUBARG));
                RTC;

                /* test function Triple()       */
                printf("Here is three times %d: %ld\n",DOUBARG,
                        Triple((LONG)DOUBARG));
                RTC;

                printf("Here is 12+13: %ld\n",Add((LONG)12,(LONG)13));

                printf("Here is 1+2+3+4+5+6: %ld\n", Sum ( (LONG)1,
                        (LONG)2, (LONG)3, (LONG)4, (LONG)5, (LONG)6));

                CloseLibrary(libbase);
        }
}
