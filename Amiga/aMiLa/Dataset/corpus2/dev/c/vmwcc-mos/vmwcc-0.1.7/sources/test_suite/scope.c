#include <stdio.h>
#define long long long
#define WriteLong(a) printf(" %lld", (a) )
#define WriteLine() printf("\n" )
#define ReadLong(a) if (fscanf(stdin, "%lld", &(a)) != 1) (a) = 0;



long a[100];

void outside() {

   long a[100];
   
   a[0]=100;
   a[1]=50;
   
   WriteLong(a[0]);
   WriteLong(a[1]);
   WriteLine();
}

   

void main() {

   a[0]=25;
   a[1]=15;
   
   outside();
   
   WriteLong(a[0]);
   WriteLong(a[1]);
   WriteLine();
   
}

   
