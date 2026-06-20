#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


long bob[10];

void main() {

  long i;
   
  i=0;
  while(i<10) {
     bob[i]=i;
     i=i+1;
  }
   
  i=0;
  while(i<10) {
     WriteLong(bob[i]%3);
     i=i+1;
  }
   
	
   
  WriteLine();
}
