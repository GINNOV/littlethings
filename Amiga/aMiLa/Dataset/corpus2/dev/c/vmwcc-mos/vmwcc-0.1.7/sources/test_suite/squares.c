#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", (long) x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


void khbb(long a, long b) {
   
   WriteLong(a);
   WriteLong(b);
}

   

void square(long value) {

   khbb(value,value*value);

   
}


void main() {
   
   long i;
   
   i=0;
   while(i<15) {
      square(i);
      WriteLine();
      i=i+1;
   }
}
