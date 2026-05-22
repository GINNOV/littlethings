/* Test program for Flashsort1             *
 *                                         *
 * by Andreas R. Kleinert in 1998          *
 *                                         */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "flash.h"


#define NUMS  16
#define NUMS2 (NUMS/10+1)

int nums[NUMS] = { 12, 11, 13, 14, 15, 9, 8, 6, 7, 5, 1, 2, 3, 10, 4, 16 };


int main(int argc, char **argv)
{
 int i, ind[NUMS2];


 printf("\nImplementation of The FlashSort1 Algorithm\n"
        "\nas described by Karl-Dietrich Neubert"
        "\nin Dr. Dobb's Journal, February 1998\n"
        "\nadapted to ANSI C for research purposes"
        "\nby Andreas R. Kleinert in 1998\n\n");


 printf("\n Before:");

 for(i=0; i<NUMS; i++) printf(" %02ld, ", nums[i]);


 printf("\n Sorting...");
 flashsort(&nums[0], NUMS, &ind[0], NUMS2);


 printf("\b\n After: ");

 for(i=0; i<NUMS; i++) printf(" %02ld, ", nums[i]);


 printf("\n\n Done!\n");

 exit(0);
}
