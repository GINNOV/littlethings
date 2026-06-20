/* for SAS/C, Amiga (1999) */

extern void rstart (long i1, long i2);
extern long uni(void);
extern long vni(void);

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv)
{
 rstart(1802, 9373);

 printf("result: %ld %ld %ld %ld %ld %ld\n", uni(), uni(), uni(), uni(), uni(), uni());
}
