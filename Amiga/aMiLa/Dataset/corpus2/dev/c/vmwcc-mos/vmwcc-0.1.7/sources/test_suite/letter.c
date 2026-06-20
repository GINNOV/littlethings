#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


/* Hello World  for the C Subset Compiler       */
/* by Vince Weaver (vince@deater.net) AKA oc39  */
/* 24 October 2003                              */

/* Note.  If using alphabet in non-hello world   */
/* cases, some letters [j,s,t,x,y,z,2,3,4,5,7,9] */
/* cannot follow each other w/o corruption       */

long ascii[128][25];
long message[20];

void init_alphabet() {

     /* A */
   ascii[65][0]=3;
   ascii[65][1]=101;
   ascii[65][2]=3;
   ascii[65][3]=101;
   ascii[65][4]=101;
}



void printMessage() {

   long count,line,temp_long,multiplier,output;

   line=0;   
   output=0;
   multiplier=1;

   while(line<5) {
   
      count=0;
      while(message[count]!=0) {
      
         temp_long=ascii[message[count]][line];

  // temp_long=101;
/*         WriteLong(temp_long);
         WriteLong(message[count]);
         WriteLong(line);
         WriteLine();
*/
         while(temp_long!=0) {
            output=8;  
            if (temp_long%100==1) {
               output=8;
            }
            if (temp_long%100==2) {
               output=88;
            }
            if (temp_long%100==3) {
               output=888;
            }
            if (temp_long%100==4) {
               output=8888;
            }
            if (temp_long%100==5) {
               output=88888;
            }
            
	    if (temp_long%100==99) {
               multiplier=-1;
            }
            else {
               output=output*multiplier;
               WriteLong(output);
               multiplier=1;
            }

            temp_long=temp_long/100;

         }
      

         count=count+1;
      }
      line=line+1;
      WriteLine();
      multiplier=1;
   }
   WriteLine();
}

void main() {
   
  init_alphabet();

  WriteLine();

    /* HELLO */
  message[0]=65;
  message[1]=0;


  printMessage();

  WriteLine();

}
