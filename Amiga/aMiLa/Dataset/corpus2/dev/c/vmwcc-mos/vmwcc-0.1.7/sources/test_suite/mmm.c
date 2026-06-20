#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


const long m = 4;
const long n = 3;

long m1[4][3], m2[3][4];
long m3[3][3];


void main()
{
  long i, j, k;

  i = 0;
  while (i < m) {
    j = 0;
    while (j < n) {
      m1[i][j] = i+j*2;
      WriteLong(i+j*2);
      j = j + 1;
    }
    WriteLine();
    i = i + 1;
  }

  i = 0;
  while (i < m) {
    j = 0;
    while (j < n) {
      m2[j][i] = m1[i][j];
      j = j + 1;
    }
    i = i + 1;
  }
  WriteLine();

  i = 0;
  while (i < n) {
    j = 0;
    while (j < m) {
      WriteLong(m2[i][j]);
      j = j + 1;
    }
    WriteLine();
    i = i + 1;
  }

  i = 0;
  while (i < n) {
    j = 0;
    while (j < n) {
      m3[i][j] = 0;
      j = j + 1;
    }
    i = i + 1;
  }
  WriteLine();

  i = 0;
  while (i < n) {
    j = 0;
    while (j < n) {
      k = 0;
      while (k < m) {
        m3[i][j] = m3[i][j] + (m1[k][j] * m2[i][k]);
        k = k + 1;
      }
      j = j + 1;
    }
    i = i + 1;
  }

  i = 0;
  while (i < n) {
    j = 0;
    while (j < n) {
      WriteLong(m3[i][j]);
      j = j + 1;
    }
    WriteLine();
    i = i + 1;
  }
  WriteLine();
}


/*
 expected output:
 0 2 4
 1 3 5
 2 4 6
 3 5 7

 0 1 2 3
 2 3 4 5
 4 5 6 7

 14 26 38
 26 54 82
 38 82 126
*/
