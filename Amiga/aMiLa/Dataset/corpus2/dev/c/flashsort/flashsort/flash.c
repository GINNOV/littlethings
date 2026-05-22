/* The FlashSort1 Algorithm                *
 *                                         *
 * as described by Karl-Dietrich Neubert   *
 * in Dr. Dobb's Journal, February 1998    *
 *                                         *
 * adapted to ANSI C for research purposes *
 * by Andreas R. Kleinert in 1998          *
 *                                         */

#include <stdlib.h>
#include <string.h>

#include "flash.h"

void flashsort(sort_type *array, int num, int *ind, int numind)
{
 int       nmax, nmove;
 int       i, j, k, c1;
 sort_type anmin, hold, flash;


 array--; /* we count  */
 ind--;   /* from 1..N */


 /* class formation */

 anmin = array[1];
 nmax  = 1;
 
 for(i=1; i<=num; i++)
  {
   if(array[i] < anmin)       anmin = array[i];
   if(array[i] > array[nmax]) nmax  = i;
  }

 if(anmin == array[nmax]) return;

 c1 = (numind - 1) / (array[nmax] - anmin);

 for(k=1; k<=numind; k++) ind[k] = 0;

 for(i=1; i<=num; i++)
  {
   k = 1 + c1 * (array[i] - anmin);
   ind[k]++;
  }

 for(k=2; k<=numind; k++) ind[k] += ind[k-1];

 hold         = array[nmax];
 array[nmax ] = array[1];
 array[1]     = hold;


 /* Permutation */

 nmove = 0;
 j     = 1;
 k     = numind;

 while(nmove < num - 1)
  {
   while(j > ind[k])
    {
     k = 1 + c1 * (array[++j] - anmin);
    }

   flash = array[j];

   while(j != ind[k] + 1)
    {
     k = 1 + c1 * (flash - anmin);
 
     hold          = array[ind[k]];
     array[ind[k]] = flash;
     flash         = hold;

     ind[k]--;
     nmove++;
    }
  }


 /* Straight Insertion */
  
 for(i=num-2; i >= 1; i--)
  {
   if(array[i+1] < array[i])
    {
     hold = array[j = i];

     while(array[j+1] < hold)
      {
       array[j] = array[j+1];
       j++;
      }

     array[j] = hold;
    }
  }
}
