#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


long x, y;

void main() {

  long i;
  long a[10]; 
  
  x = 21;
  y = 22;

  x=x+1;

  ReadLong(y);
   
  WriteLong(x);
  WriteLong(y);
  WriteLine();
   
  i=0;
   
  while(i<10) {
     a[i]=i;
     i=i+1;
  }
   
  i=0;
  while(i<10) {
     WriteLong(a[i]);
     i=i+1;
  }
  WriteLine();
	
   
}

