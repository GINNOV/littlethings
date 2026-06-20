/* generating permutations lexicographic order */
/* Algorithm due to Dijkstra.
   C Implementation by Glenn C. Rhoads */

// Ported to CSubset from
// http://remus.rutgers.edu/~rhoads/Code/perm_lex.c

#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %ld", x);
#define ReadLong(a) if (fscanf(stdin, "%ld", &a) != 1) a = 0;

long n;
long i;
long j;
long r;
long s;
long temp;

void main() {
  long pi[13];

  n = 11;

  i = 0;
  while (i <= n) {
    pi[i] = i;
    i = i + 1;
  }

  i = 1;

    while (i <= n) {
      WriteLong(pi[i]);
      i = i + 1;
    }
    WriteLine();

  i=1;
   
  while (i != 0) {

    i = 1;
    while (i <= n) {
//      WriteLong(pi[i]);
      i = i + 1;
    }
//    WriteLine();

    i = n-1;
    while (pi[i] > pi[i+1]) {
      i = i - 1;
    }

    j = n;
    while (pi[i] > pi[j]) {
      j = j - 1;
    }

    temp = pi[i];
    pi[i] = pi[j];
    pi[j] = temp;

    r = n;
    s = i + 1;
    while (r > s) {
      temp = pi[r];
      pi[r] = pi[s];
      pi[s] = temp;
      r = r - 1;
      s = s + 1;
    }
  }

   i=1;
   while (i <= n) {
      WriteLong(pi[i]);
      i = i + 1;
    }
    WriteLine();
}
