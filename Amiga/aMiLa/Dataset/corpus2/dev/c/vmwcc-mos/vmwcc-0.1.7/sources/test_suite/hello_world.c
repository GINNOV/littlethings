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
     /* B */
   ascii[66][0]=9902;
   ascii[66][1]=101;
   ascii[66][2]=9902;
   ascii[66][3]=101;
   ascii[66][4]=9902;
     /* C */
   ascii[67][0]=2;
   ascii[67][1]=9901;
   ascii[67][2]=9901;
   ascii[67][3]=9901;
   ascii[67][4]=2;
     /* D */
   ascii[68][0]=9902;
   ascii[68][1]=101;
   ascii[68][2]=101;
   ascii[68][3]=101;
   ascii[68][4]=9902;
     /* E */
   ascii[69][0]=2;
   ascii[69][1]=9901;
   ascii[69][2]=2;
   ascii[69][3]=9901;
   ascii[69][4]=2;
     /* F */
   ascii[70][0]=2;
   ascii[70][1]=9901;
   ascii[70][2]=2;
   ascii[70][3]=9901;
   ascii[70][4]=9901;
     /* G */
   ascii[71][0]=3;
   ascii[71][1]=9902;
   ascii[71][2]=101;
   ascii[71][3]=101;
   ascii[71][4]=3;
     /* H */
   ascii[72][0]= 101;
   ascii[72][1]= 101;
   ascii[72][2]= 3;
   ascii[72][3]= 101;
   ascii[72][4]= 101;
     /* I */
   ascii[73][0]=1;
   ascii[73][1]=1;
   ascii[73][2]=1;
   ascii[73][3]=1;
   ascii[73][4]=1;
     /* J */
   ascii[74][0]=199;
   ascii[74][1]=199;
   ascii[74][2]=199;
   ascii[74][3]=199;
   ascii[74][4]=2;
     /* K */
   ascii[75][0]=101;
   ascii[75][1]=101;
   ascii[75][2]=9902;
   ascii[75][3]=101;
   ascii[75][4]=101;
     /* L */
   ascii[76][0]=9901;
   ascii[76][1]=9901;
   ascii[76][2]=9901;
   ascii[76][3]=9901;
   ascii[76][4]=2;
     /* M */
   ascii[77][0]=5;
   ascii[77][1]=10101;
   ascii[77][2]=10101;
   ascii[77][3]=10101;
   ascii[77][4]=10101;
     /* N */
   ascii[78][0]=103;
   ascii[78][1]=10101;
   ascii[78][2]=10101;
   ascii[78][3]=10101;
   ascii[78][4]=301;
     /* O */
   ascii[79][0]=3;
   ascii[79][1]=101;
   ascii[79][2]=101;
   ascii[79][3]=101;
   ascii[79][4]=3;
     /* P */
   ascii[80][0]= 2;
   ascii[80][1]= 2;
   ascii[80][2]= 2;
   ascii[80][3]= 9901;
   ascii[80][4]= 9901;
     /* Q */
   ascii[81][0]= 4;
   ascii[81][1]= 19901;
   ascii[81][2]= 19901;
   ascii[81][3]= 201;
   ascii[81][4]= 4;
     /* R */
   ascii[82][0]= 4;
   ascii[82][1]= 19901;
   ascii[82][2]= 4;
   ascii[82][3]= 990101;
   ascii[82][4]= 19901;
     /* S */
   ascii[83][0]= 2;
   ascii[83][1]= 9901;
   ascii[83][2]= 2;
   ascii[83][3]= 199;
   ascii[83][4]= 2;
     /* T */
   ascii[84][0]= 3;
   ascii[84][1]= 990199;
   ascii[84][2]= 990199;
   ascii[84][3]= 990199;
   ascii[84][4]= 990199;
     /* U */
   ascii[85][0]= 101;
   ascii[85][1]= 101;
   ascii[85][2]= 101;
   ascii[85][3]= 101;
   ascii[85][4]= 3;
     /* V */
   ascii[86][0]= 101;
   ascii[86][1]= 101;
   ascii[86][2]= 101;
   ascii[86][3]= 101;
   ascii[86][4]= 9902;
     /* W */
   ascii[87][0]= 10101;
   ascii[87][1]= 10101;
   ascii[87][2]= 10101;
   ascii[87][3]= 10101;
   ascii[87][4]= 5;
     /* X */
   ascii[88][0]= 101;
   ascii[88][1]= 101;
   ascii[88][2]= 990199;
   ascii[88][3]= 101;
   ascii[88][4]= 101;
     /* Y */
   ascii[89][0]= 101;
   ascii[89][1]= 101;
   ascii[89][2]= 3;
   ascii[89][3]= 990199;
   ascii[89][4]= 990199;
     /* Z */
   ascii[90][0]= 2;
   ascii[90][1]= 199;
   ascii[90][2]= 2;
   ascii[90][3]= 9901;
   ascii[90][4]= 2;

     /* 0 */
   ascii[48][0]= 3;
   ascii[48][1]= 101;
   ascii[48][2]= 101;
   ascii[48][3]= 101;
   ascii[48][4]= 3;
     /* 1 */
   ascii[49][0]= 1;
   ascii[49][1]= 1;
   ascii[49][2]= 1;
   ascii[49][3]= 1;
   ascii[49][4]= 1;
     /* 2 */
   ascii[50][0]= 2;
   ascii[50][1]= 199;
   ascii[50][2]= 2;
   ascii[50][3]= 9901;
   ascii[50][4]= 2;
     /* 3 */
   ascii[51][0]= 2;
   ascii[51][1]= 199;
   ascii[51][2]= 2;
   ascii[51][3]= 199;
   ascii[51][4]= 2;
     /* 4 */
   ascii[52][0]= 2;
   ascii[52][1]= 2;
   ascii[52][2]= 2;
   ascii[52][3]= 199;
   ascii[52][4]= 199;
     /* 5 */
   ascii[53][0]= 2;
   ascii[53][1]= 9901;
   ascii[53][2]= 2;
   ascii[53][3]= 199;
   ascii[53][4]= 2;
     /* 6 */
   ascii[54][0]= 2;
   ascii[54][1]= 9901;
   ascii[54][2]= 2;
   ascii[54][3]= 2;
   ascii[54][4]= 2;
     /* 7 */
   ascii[55][0]= 2;
   ascii[55][1]= 199;
   ascii[55][2]= 199;
   ascii[55][3]= 199;
   ascii[55][4]= 199;
     /* 8 */
   ascii[56][0]= 3;
   ascii[56][1]= 101;
   ascii[56][2]= 3;
   ascii[56][3]= 101;
   ascii[56][4]= 3;
     /* 9 */
   ascii[57][0]= 2;
   ascii[57][1]= 2;
   ascii[57][2]= 2;
   ascii[57][3]= 199;
   ascii[57][4]= 2;

     /* ! */
   ascii[33][0]= 1;
   ascii[33][1]= 1;
   ascii[33][2]= 1;
   ascii[33][3]= 99;
   ascii[33][4]= 1;
     
     /* . */
   ascii[46][0]= 99;
   ascii[46][1]= 99;
   ascii[46][2]= 99;
   ascii[46][3]= 99;
   ascii[46][4]= 1;

    /* , */
   ascii[44][0]= 99;
   ascii[44][1]= 99;
   ascii[44][2]= 99;
   ascii[44][3]= 1;
   ascii[44][4]= 1;

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

/*         WriteLong(temp_long);
         WriteLong(message[count]);
         WriteLong(line);
         WriteLine();
*/
         while(temp_long!=0) {
              
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
  message[0]=72;
  message[1]=69;
  message[2]=76;
  message[3]=76;
  message[4]=79;
  message[5]=0;

  printMessage();

    /* WORLD! */
  message[0]=87;
  message[1]=79;
  message[2]=82;
  message[3]=76;
  message[4]=68;
  message[5]=33;
  message[6]=0;

  printMessage();

  WriteLine();

}
