#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


const long n = 100;

long a[101];


void HeapSort()
{
  long c, x, i, j;
  long f;

  c = (n / 2) + 1;
  while (c != 1) {
    c = c-1;
    i = c;
    j = c*2;
    x = a[c];
    if (j < n) {
      if (a[j+1] > a[j]) {
        j = j + 1;
      }
    }
    f = 1;
    if (j > n) {
      f = 0;
    } else {
      if (x >= a[j]) {
        f = 0;
      }
    }
    while (f != 0) {
      a[i] = a[j];
      i = j;
      j = i*2;
      if (j < n) {
        if (a[j+1] > a[j]) {
          j = j + 1;
        }
      }
      f = 1;
      if (j > n) {
        f = 0;
      } else {
        if (x >= a[j]) {
          f = 0;
        }
      }
    }
    a[i] = x;
  }
  c = n;
  while (c != 1) {
    x = a[1];
    a[1] = a[c];
    a[c] = x;
    c = c-1;
    i = 1;
    j = 2;
    x = a[1];
    if (2 < c) {
      if (a[3] > a[2]) {
        j = j + 1;
      }
    }
    f = 1;
    if (j > c) {
      f = 0;
    } else {
      if (x >= a[j]) {
        f = 0;
      }
    }
    while (f != 0) {
      a[i] = a[j];
      i = j;
      j = i*2;
      if (j < c) {
        if (a[j+1] > a[j]) {
          j = j + 1;
        }
      }
      f = 1;
      if (j > c) {
        f = 0;
      } else {
        if (x >= a[j]) {
          f = 0;
        }
      }
    }
    a[i] = x;
  }
}


void main()
{
  long i;

  i = 1;
  while (i <= n) {
    a[i] = n-i;
    i = i + 1;
  }
  WriteLong(a[1]);
  WriteLong(a[n]);
  WriteLine();
  HeapSort();

  i = 2;
  while (i <= n) {
    if (a[i-1] > a[i]) {
      WriteLong(i);
    }
    i = i + 1;
  }

  WriteLong(a[1]);
  WriteLong(a[n]);
  WriteLine();
}


/*
 expected output:
 99 0
 0 99
*/
