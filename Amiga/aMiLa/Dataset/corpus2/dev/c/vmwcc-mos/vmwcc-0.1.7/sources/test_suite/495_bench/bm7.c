#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %ld", x);
#define ReadLong(a) if (fscanf(stdin, "%ld", &a) != 1) a = 0;
#define long unsigned long

const long origSeed = 5; // Change for different values.
const long NUMITEMS = 28;
long target;
long randRes;
long a[28];
long sum;
long success;

void rand() { // Modified from K&R p. 46.
  randRes = randRes * 1103515245 + 12345;
  randRes = randRes/65536 % 32768;
  if (randRes < 0) {
    randRes = 0 - randRes;
  }
}
void srand(long seed) {
  randRes = seed;
}
void SubsetSum(long offset, long sum) {
  long total;
  total = 0;
  while (offset < NUMITEMS) {
    if (a[offset] == sum) {
      success = 1;
    } else {
      if (a[offset] < sum) {
	SubsetSum(offset+1, sum-a[offset]);
      }
    }
    if (success == 1) {
      WriteLong(a[offset]);
      WriteLine();
      offset = NUMITEMS; // Exit condition
    }
    offset = offset+1;
  }
}

void main() {
  long c;
  // The following is just some trash to test loop invariant code motion.
  long k;
  long n; 
  long d;
  n = 8191;
  d = 127;
  c = 0;
  while (c < 90000000) {
    k = 5 + n*(n/d); // <-- Loop invariant.
    c = c + 1;
  } 
  c = 0;
  WriteLong(k);
  WriteLine();
  WriteLine();

  // Now we begin the subset sum problem.
  srand(k);
  rand();
  success = 0;
  target = randRes;
  WriteLong(target);
  WriteLine();
  WriteLine();

  while (c < NUMITEMS) { // Populate the array with random numbers.
    rand();
    a[c] = randRes % 100;
    WriteLong(a[c]);
    WriteLine();
    c = c+1;
  }
  WriteLine();
  SubsetSum(0, target);
  WriteLine(); // Whitespace.
  WriteLong(success);
  WriteLine();
}
