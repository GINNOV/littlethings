#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %d", x);



char bob[13]="Hello World!";
int j=5;


int sub() {

   int j=4;
   int i;
   char bob[8]="Goodbye!";
   
   for(i=0;i<8;i++) {
      WriteLong(bob[i]);
   }
   
   WriteLong(j);
   
   WriteLine();

   return 1;
}

   

int main() {

   int i;
   
   WriteLong(j);
   
   for(i=0;i<13;i++) {
      WriteLong(bob[i]);
   }
   
   WriteLine();
	
	
   WriteLong(sub());
   WriteLine();

   bob[3]='V';
   for(i=0;i<13;i++) {
      WriteLong(bob[i]);
   }
   WriteLine();
   
   return 0;
   
}
