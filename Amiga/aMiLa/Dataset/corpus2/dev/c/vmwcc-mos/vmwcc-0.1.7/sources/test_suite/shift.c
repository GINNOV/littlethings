#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %d", x);

int main() {

   int i=0,j=0,k=20,l=1;
   
   i=3;
   j=1<<i;
   k=k>>2;
   l=2>>l;
   
   WriteLong(i);
   WriteLong(j);
   WriteLong(k);
   WriteLong(l);
   WriteLine();
   
   return 0;
}
