#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


long i,j;

   struct zrp {
      long a[20];
   } oog;

struct blah {
   long a[20];
   struct zrp zoog;
   long cool;   
} eek;


struct blah jim[20];

	
void printi() {
   long i;
   
   i=5;
   WriteLong(i);
   WriteLine();
   
}

void printjim() {
   
   long i;
   long jim;
   
   i=0;
   jim=0;
   while(i<3) {
      jim=0;
      while(jim<3) {
	 //WriteLong(i);
	 //WriteLong(jim);
	 WriteLong(i*jim);
	 
	 jim=jim+1;
      }
      i=i+1;
   }
   printi();
   WriteLine();
}

  

void main() {
   
   long i;

   i=0;
   while(i<20) {
      jim[i].a[i]=2;
      jim[i].zoog.a[i]=4;
      jim[i].cool=i;
      i=i+1;
   }
   
   i=0;
   while(i<20) {
      WriteLong(jim[i].a[i]);
      WriteLong(jim[i].zoog.a[i]);
      WriteLong(jim[i].cool);
      i=i+1;
   }
   WriteLine();
	
   
   printi();
   WriteLine();
   printjim();
   WriteLine();
}

   
