#include <stdio.h>
#define long long long
#define WriteLong(a) printf(" %lld", (a) )
#define WriteLine() printf("\n" )
#define ReadLong(a) if (fscanf(stdin, "%lld", &(a)) != 1) (a) = 0;



long a[10];
long b[65536];
long c[10];

void main() {

   a[5]=25;
   b[5]=15;
   c[5]=20;
      
   WriteLong(a[5]);
   WriteLong(b[5]);
   WriteLong(c[5]);
   WriteLine();
   
}

   
