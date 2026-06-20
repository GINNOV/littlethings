#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


void main()
{
  long i,j;

  i=0;

  while(i<15) {
     j=0;
     while(j<15) {
        WriteLong(i*j);
        j=j+1;
     }
     WriteLine();
     i=i+1;
  }

}
