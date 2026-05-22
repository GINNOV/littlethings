#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long

const long n = 10;
long g;
long a[10];


struct S {
  long f;
} s;

void Proc(long i)
{
  long x, y, z, w;
 
  x = n;
  y = g;
  z = a[i];
  w = s.f;
 
  g = x;
  a[2] = y;
  s.f = z;
}


void main()
{

  long i, j, k;
  long b[6];
  struct T {
    long h;
  } t;
 
  ReadLong(i);  
  ReadLong(j);
  
  if (j < i) {
    k = i;
    i = j;
    j = k;
  }

  while (i < j) {
    i = i + 1;
  }

  b[4] = i;
  t.h = j;
  Proc(j);
  WriteLong(i+j);

  WriteLine();
}
