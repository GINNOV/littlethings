#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long

const long n = 5;
long data[5];

void Quicksort(long l, long r)
{
  long i, j, x;
  i = l;
  j = r;
  x = data[(l+r)/2];
  while (i <= j) {
    while (data[i] < x) {i = i+1;}
    while (x < data[j]) {j = j-1;}
    if (i <= j) {
      x = data[i];
      data[i] = data[j];
      data[j] = x;
      i = i+1;
      j = j-1;
    }
  }
  if (l < j) {Quicksort(l, j);}
  if (i < r) {Quicksort(i, r);}
}

void main()
{
  data[0] = 3;
  data[1] = 1;
  data[2] = 2;
  data[3] = 4;
  data[4] = 1;

  Quicksort(0, 4);

  WriteLong(data[0]);
  WriteLong(data[1]);
  WriteLong(data[2]);
  WriteLong(data[3]);
  WriteLong(data[4]);
  WriteLine();
}


