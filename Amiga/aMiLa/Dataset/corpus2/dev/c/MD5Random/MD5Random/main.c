/* test program by Andreas R. Kleinert in 2000 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int rnd(int low, int high);

#ifdef __PPC__
extern void load_seed(void);
extern void save_seed(void);
#else
extern void __stdargs load_seed(void);
extern void __stdargs save_seed(void);
#endif

int main(int argc, char **argv)
{
 load_seed();

 printf("\nRandom Number (0..65535): %ld\n\n", (long) rnd(0, 65535));

 save_seed();

 exit(0);
}
