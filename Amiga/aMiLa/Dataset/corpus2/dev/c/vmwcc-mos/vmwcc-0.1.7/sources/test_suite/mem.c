#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


const long n = 1024*64;
long x, y;
long a[1024*64];
long b, c;


void Test()
{
  const long n = 1024*2;
  long x, y;
  long a[1024*2];
  long b, c;
  long i, j;

  x = 321;
  y = 322;
  b = 323;
  c = 324;

  i = 0;
  while (i < n) {
    a[i] = i;
    i = i + 1;
  }

  j = 0;
  i = 0;
  while (i < n) {
    j = j + a[i];
    i = i + 1;
  }

  WriteLong(j);
  WriteLong((n*(n-1))/2);
  WriteLine();
  WriteLong(x);
  WriteLong(y);
  WriteLong(b);
  WriteLong(c);
  WriteLine();
}


void main()
{
  long i, j;

  x = 21;
  y = 22;
  b = 23;
  c = 24;

  Test();

  i = 0;
  while (i < n) {
    a[i] = i;
    i = i + 1;
  }

  j = 0;
  i = 0;
  while (i < n) {
  
    j = j + a[i];
    i = i + 1;
  }
  WriteLine();

  WriteLong(j);
// too big for 32 bit
   //  WriteLong((n*(n-1))/2);
   WriteLong((10*(n-1))/2);

   
  WriteLine();
  WriteLong(x);
  WriteLong(y);
  WriteLong(b);
  WriteLong(c);
  WriteLine();
}


/*
 expected output:
 2096128 2096128
 321 322 323 324
 2147450880 2147450880
 21 22 23 24
*/
