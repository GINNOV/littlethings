#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


void main() {

   long a,b,c;
   
   a=5;
   b=4;
   
   if (a>4) {
      if (b>3) {
         a=1;
      }
      else {
         a=14;
      }
   }
   else {
      b=7;
   }
   
   
   WriteLong(a);
   WriteLong(b);
   WriteLine();
}
