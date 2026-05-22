/* Program for testing the Random250.library from GNU C.
   By Alexander G. M. Smith, agmsmith@achilles.net, June 1996.
   Compiled with GNU C version 2.7.0, command line:
   gcc -v -noixemul -O2 Test.c
 */

#include <stdio.h>
#include <string.h>
#include <proto/exec.h>

#define Random250Name "random250.library"

void *Random250Base;


/* Returns 32 random bits using the R250 random number generator. */

__inline unsigned long Random250Long (void)
{
  register LONG _res  __asm("d0");
  register void *a6 __asm("a6") = Random250Base;
  __asm __volatile ("jsr a6@(-30)"
  : "=r" (_res)
  : "r" (a6)
  : "a0","a1","d0","d1", "memory");
  return _res;
}


/* Fills the given array with random 32 bit words.  The size of the
   array is in long words, so divide the number of bytes by four to get
   the size in long words. */

__inline void Random250Array (unsigned long ArrayLongWordSize,
unsigned long *ArrayPointer)
{
  register void *a6 __asm("a6") = Random250Base;
  register unsigned long d0 __asm("d0") = ArrayLongWordSize;
  register unsigned long *a0 __asm("a0") = ArrayPointer;
  __asm __volatile ("jsr a6@(-36)"
  : /* no output */
  : "r" (a6), "r" (a0), "r" (d0)
  : "a0","a1","d0","d1","memory");
}


#define NUMBEROFNUMBERS 6400
#define NUMBEROFBINS 16
#define BINSIZE (0x40000000 / (NUMBEROFBINS / 4)) /* Avoid overflow problems */
#define EXPECTEDCOUNT (NUMBEROFNUMBERS / NUMBEROFBINS)

#define TRUE 1
#define FALSE 0

int Bins [NUMBEROFBINS];


int main (int argc, char *argv[])
{
  int   Count;
  int   ErrorAmount;
  long  ErrorSquaredAmount;
  int   i;
  unsigned long *NumberArray;
  int   Success;
  int   TotalError;
  long  TotalErrorSquared;

  NumberArray = NULL;
  Success = TRUE;

  Random250Base = OpenLibrary (Random250Name, 0 /* version */);
  if (Random250Base == NULL)
  {
    Success = FALSE;
    printf ("Unable to open " Random250Name "\n");
  }

  if (Success)
  {
    NumberArray = (void *) malloc (NUMBEROFNUMBERS * sizeof (*NumberArray));
    if (NumberArray == NULL)
    {
      Success = FALSE;
      printf ("Ran out of memory for numbers array.\n");
    }
  }

  if (Success)
  {
    for (i = 1; i <= 10; i++)
      printf ("Random number %2d is %08lx\n", i, Random250Long ());

    printf ("Generating random numbers... ");
    Random250Array (NUMBEROFNUMBERS, NumberArray);
    printf ("Done.\n");

    for (i = 0; i < NUMBEROFBINS; i++)
      Bins [i] = 0;

    for (i = 0; i < NUMBEROFNUMBERS; i++)
      Bins [NumberArray [i] / BINSIZE]++;

    printf ("Each bin should have %d counts in it on the average.\n",
    EXPECTEDCOUNT);

    Count = 0;
    TotalError = 0;
    TotalErrorSquared = 0;
    for (i = 0; i < NUMBEROFBINS; i++)
    {
      Count += Bins [i];
      ErrorAmount = Bins [i] - EXPECTEDCOUNT;
      TotalError += ErrorAmount;
      ErrorSquaredAmount = ErrorAmount * ErrorAmount;
      TotalErrorSquared += ErrorSquaredAmount;

      printf ("Bin %3d count is %3d, error is %4d, error squared is %4ld\n",
      i, Bins [i], ErrorAmount, ErrorSquaredAmount);
    }

    printf ("Count of bins is %d of %d.\n", Count, NUMBEROFNUMBERS);
    printf ("Total error is %d.\n", TotalError);
    printf ("Total error squared is %ld.\n", TotalErrorSquared);
  }

  if (NumberArray != NULL)
    free (NumberArray);

  if (Random250Base != NULL)
    CloseLibrary (Random250Base);
}
