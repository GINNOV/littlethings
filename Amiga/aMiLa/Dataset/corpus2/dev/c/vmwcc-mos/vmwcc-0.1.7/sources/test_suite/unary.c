#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %d", x);

int main() {

   int i=0,x=5,j,k;
   int q=0xfffffff5;
   int y,z;
   
   y= ~x+~q;
   z= +~x * !i + -x;
   
   k=~~x;
   j=-+x;
   
   WriteLong(!i);
   WriteLong(!x);
   WriteLong(!!x);
   WriteLong(j);
   WriteLong(k);
   WriteLong(~q);
   WriteLong(y);
   WriteLong(z);
   WriteLine();
   
   return 0;
}
