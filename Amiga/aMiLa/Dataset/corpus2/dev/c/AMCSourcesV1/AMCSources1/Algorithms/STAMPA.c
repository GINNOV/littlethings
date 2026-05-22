#include <stdio.h>
#define NUM_TAB 4
	
		
main()
{
 int c;
 int i;
 int j = 0;
 while ((c = getchar()) != EOF)
   if( c == '\n') {
	  putchar(c);
	  j = 0;
	}
   else {
	  if( c != '\t') {
		 putchar(c);
		 j++;
	   }
	  else {
		 for (i = 0; i< NUM_TAB - j%NUM_TAB; i++) putchar(' ');
		 j = j+NUM_TAB-j%NUM_TAB;
	   }
	}
}
