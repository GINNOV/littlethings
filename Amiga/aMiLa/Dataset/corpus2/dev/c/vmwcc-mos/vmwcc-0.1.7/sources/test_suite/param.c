#include <stdio.h>
#define long long long
#define WriteLong(a) printf(" %lld", (a) )
#define WriteLine() printf("\n" )
#define ReadLong(a) if (fscanf(stdin, "%lld", &(a)) != 1) (a) = 0;



long sum;

void add (long n1,
	  long n2,
	  long n3,
	  long n4,
	  long n5,
	  long n6,
	  long n7,
	  long n8,
	  long n9)

{
   
   sum=n1+n2+n3+n4+n5+n6+n7+n8+n9;
}

void main() {

   long a0,a1,a2,a3;
   
   a0=1;
   a1=14;
   a2=15;
   a3=16;
   
   add(a0,a0+a0,3,4,5,a1,a2,a3,17);
   
   WriteLong(sum);
   WriteLine();
   
}

   
