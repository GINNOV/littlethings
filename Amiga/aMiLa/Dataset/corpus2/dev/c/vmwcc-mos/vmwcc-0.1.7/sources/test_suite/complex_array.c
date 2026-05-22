#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


void main() {
   
  long a[10][10];
  long b[10];
  long i,j;

  struct pair {
     long a;
     long b;
  } data[10];
   
	
   
  i = 0;
  while (i < 10) {
    b[i] = i;
    i = i + 1;
  }
   
  i=4; 
   /* before */
   
/*
 12 mul i,40
 13 mul i,4
 14 add bbase FP
 15 add (13) (14)
 16 load (15)
 17 add (12) (16)
 18 add abase FP
 19 add (17) (18)
 20 stw 3, 0(19)
 * 
 */  
  a[i][b[i]]=3;
   /* after */
  j=5;
      
  WriteLong(a[i][b[i]]);
  data[j].a=7;

  a[i][b[i]]=j;
   
   
  WriteLong(a[i][b[i]]);
  WriteLine();
  WriteLong(data[j].a);
  WriteLine();
}
