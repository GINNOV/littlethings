#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %ld", x);
#define ReadLong(a) if (fscanf(stdin, "%ld", &a) != 1) a = 0;

int five() {
   
   int f;
   
   f=5;
   
   return f;
}

void bob() {
   
   return;
   
}

void three() {
   
   return 3;
}

int main() {

   long q,p;
   int x=0xa,y,z,f;
      
   y='A';
   q='\n';
   p='\031';

   z='A'+'B';
   
   f=five();
   z=five()+three();
   
   WriteLong(x);
   WriteLong(y);
   WriteLong(f);
   WriteLong(z);
   WriteLine();
   
   return 18;
   
   WriteLong(p);
   WriteLine();
}
