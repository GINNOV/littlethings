#include <stdio.h>
#define long long long
#define WriteLong(a) printf(" %lld", (a) )
#define WriteLine() printf("\n" )
#define ReadLong(a) if (fscanf(stdin, "%lld", &(a)) != 1) (a) = 0;

void main() {

   long a[2];
   
   struct joe{
      long a;
      long b;
   } bob;
   
	
   
   ReadLong(a[0]);
   ReadLong(a[1]);
   WriteLong(a[0]);
   WriteLong(a[1]);
   WriteLong(a[0]+a[1]);
   WriteLine();
   
   ReadLong(bob.a);
   ReadLong(bob.b);
   WriteLong(bob.a);
   WriteLong(bob.b);
   WriteLong(bob.a+bob.b);
   WriteLine();
   
}

   
