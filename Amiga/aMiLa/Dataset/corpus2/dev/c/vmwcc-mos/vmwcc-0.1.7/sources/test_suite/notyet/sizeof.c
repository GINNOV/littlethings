#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %d", x);



int main() {

   int a[10];

   int krg;
   
   struct tbob {
      int a;
      char b;
   } bob;
   
   WriteLong( sizeof(krg));
   WriteLong( sizeof(int));
   WriteLong( sizeof(char));
   WriteLong( sizeof(long));
   WriteLong( sizeof(a));
   WriteLong( sizeof(bob));
   WriteLong( sizeof(bob.a));
   WriteLong( sizeof(struct tbob));

   WriteLine();

   return 0;
   
}
