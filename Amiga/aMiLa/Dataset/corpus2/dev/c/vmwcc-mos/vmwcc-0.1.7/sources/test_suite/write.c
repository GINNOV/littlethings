#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


void main() {

   long a,b;
 
   ReadLong(a);
   WriteLong(a);

   if (a>5) {
      b=7;
   }
   else {
     b=2;
   }

   WriteLong(b);
   WriteLine();
}
