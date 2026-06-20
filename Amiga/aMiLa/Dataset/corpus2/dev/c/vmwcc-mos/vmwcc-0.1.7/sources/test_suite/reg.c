#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long

void main() {

   long a,b,c,d,e;

   ReadLong(a);
   ReadLong(b);
   c=a*b;
   d=a*7;
   e=c+d;
   WriteLong(e);
   WriteLine();

}
