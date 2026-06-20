/* 
   Extended Memory functions for C little endian version

   (C) 2014  Lorence Lombardo.

   Date commenced:- 19-Apr-2014
   Last modified:-  21-Apr-2014

   24bit stuff re-worked from "mem.c" for AROS x86

   Since I no longer have AROS installed this has been tested on
   gcc v3.2 on x86 Mandrake 9.0 linux.


   Suggested to compile with:-

   gcc mem_aros_x86.c -o mem_test86 

*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


// peek a byte

char peekb (long *addy) {
   char byt;
   memcpy (&byt, addy, 1);
   return byt;
}


// peek a word

short peekw (long *addy) {
   short wrd;
   memcpy (&wrd, addy, 2);
   return wrd;
}


// peek a long

long peekl (long *addy) {
   long lng;
   memcpy (&lng, addy, 4);
   return lng;
}


// unsigned 24 bit peek

long upeek24 (long *addy) {
   char buf[4];
   buf[3]=0;
   long lng;
   memcpy (&buf, addy, 3);
   memcpy (&lng, &buf, 4);
   return lng;
}


// signed 24 bit peek

long speek24 (long *addy) {
   char buf[4];
   buf[3]=0;
   memcpy (&buf, addy, 3);
   long lng;
   if (buf[2]<0) buf[3]=255;
   memcpy (&lng, &buf, 4);
   return lng;
}


// peek a long with an endian flip

long fpeekl (long *addy) {
   char buf[5];
   long lng;
   memcpy (&buf, addy, 4);
   buf[4]=buf[0];
   buf[0]=buf[3];
   buf[3]=buf[4];
   buf[4]=buf[1];
   buf[1]=buf[2];
   buf[2]=buf[4];
   memcpy (&lng, &buf, 4);
   return lng;
}


// peek a word with an endian flip

short fpeekw (long *addy) {
   char buf[3];
   short wrd;
   memcpy (&buf, addy, 2);
   buf[2]=buf[0];
   buf[0]=buf[1];
   buf[1]=buf[2];
   memcpy (&wrd, &buf, 2);
   return wrd;
}


// unsigned 24 bit peek with an endian flip

long ufpeek24 (long *addy) {
   char buf[4];
   long lng;
   memcpy (&buf, addy, 3);
   buf[3]=buf[2];
   buf[2]=buf[0];
   buf[0]=buf[3];
   buf[3]=0;
   memcpy (&lng, &buf, 4);
   return lng;
}


// signed 24 bit peek with an endian flip

long sfpeek24 (long *addy) {
   char buf[4];
   long lng;
   memcpy (&buf, addy, 3);
   buf[3]=buf[2];
   buf[2]=buf[0];
   buf[0]=buf[3];
   buf[3]=0;
   if (buf[2]<0) buf[3]=255;
   memcpy (&lng, &buf, 4);
   return lng;
}


// 24 bit poke

poke24 (long *addy, long num) {
   char buf[4];
   memcpy (&buf, &num, 4);
   memcpy (addy, &buf, 3);
}


// poke a long

pokel (long *addy, long num) {
   memcpy (addy, &num, 4);
}


// poke a word

pokew (long *addy, short num) {
   memcpy (addy, &num, 2);
}


// poke a byte

pokeb (long *addy, char num) {
   memcpy (addy, &num, 1);
}



//  functions test


int main () {

   printf("\n");

   char byt = -1;
   unsigned char uresb = peekb ((long*)&byt);
   printf("%u\n", uresb);
   char sresb = peekb ((long*)&byt);
   printf("%d\n", sresb);

   short wrd = -1;
   unsigned short uresw = peekw ((long*)&wrd);
   printf("%u\n", uresw);
   short sresw = peekw ((long*)&wrd);
   printf("%d\n", sresw);

   long lng = -1;
   unsigned long uresl = peekl ((long*)&lng);
   printf("%lu\n", uresl);
   long sresl = peekl ((long*)&lng);
   printf("%ld\n", sresl);

   lng=16777215;
   sresl = upeek24 ((long*)&lng);
   printf("%ld\n", sresl);
   sresl = speek24 ((long*)&lng);
   printf("%ld\n", sresl);

   char buf[5];
   buf[0]='A'; buf[1]='B'; buf[2]='C'; buf[3]='D'; buf[4]=0;
   sresl = fpeekl ((long*)&buf);
   memcpy (&buf, &sresl, 4);
   printf("%s\n", &buf);

   sresl = ufpeek24 ((long*)&buf);
   memcpy (&buf, &sresl, 4);
   printf("%s\n", &buf);

   buf[2]=0;
   wrd = fpeekw ((long*)&buf);
   memcpy (&buf, &wrd, 2);
   printf("%s\n", &buf);

   sresl = 9388607;
   memcpy (&buf, &sresl, 4);
   sresl = speek24((long*)&buf);  
   printf("%ld\n", sresl);
   sresl = sfpeek24((long*)&buf);
   memcpy (&buf, &sresl, 4);
   sresl = ufpeek24((long*)&buf);
   printf("%ld\n", sresl);

   buf[3]=0;
   poke24((long*)&buf, 16777215);
   printf("%s\n", &buf);

   pokel((long*)&buf, -1);
   printf("%s\n", &buf);

   buf[2]=0;
   pokew((long*)&buf, 16706);
   printf("%s\n", &buf);

   pokeb((long*)&buf, 67);
   printf("%c\n", buf[0]);

   printf("\n");

   return 0;
}
