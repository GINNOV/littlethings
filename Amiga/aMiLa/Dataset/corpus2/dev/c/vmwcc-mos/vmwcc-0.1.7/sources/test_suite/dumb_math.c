#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


void main() {
   
   long index;
   
   index=5;
   
   WriteLong( -(0-index));
   WriteLine();   

}

   
