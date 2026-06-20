#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", (long) x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


void A() {
   WriteLong(5);
}


void main() {
   A();
   WriteLong(7);
   WriteLine();
}
