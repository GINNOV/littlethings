/* for SAS/C, Amiga (1999) */

extern unsigned int r250(void);
extern void r250_init(int seed);

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv)
{
 r250_init(1802);

 printf("result: %ld %ld %ld %ld %ld %ld\n", r250(), r250(), r250(), r250(), r250(), r250());
}
