#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %d", x);



int main() {

   int a,b;
   
   a=5;
   b=3;
   
   if (a) {
      WriteLong(33);
   }
   
   
   WriteLong( a<b);
   WriteLong( b>2);

   WriteLine();

   return 0;
   
}
