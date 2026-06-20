#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %d", x);



int main() {

   int a,b,i;

   a=3;
   b=5;
   
   WriteLong(a);
   WriteLong(++a);
   WriteLong(a);
   WriteLine();
   
   WriteLong(b);
   WriteLong(b++);
   WriteLong(b);
   WriteLine();
   
   for(i=0;i<5;i++) {
      WriteLong(i);
   }

   WriteLine();
	
   
   return 0;
   
}
