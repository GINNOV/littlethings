#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %ld", x);
#define ReadLong(a) if (fscanf(stdin, "%ld", &a) != 1) a = 0;

int main() {

   int i,j;
   
   for(i=0;i<5;i=i+1) {
      
      for(j=0;j<5;j=j+1) {
         WriteLong(i*j);
      }
      WriteLine();
   }
   WriteLine();
}
