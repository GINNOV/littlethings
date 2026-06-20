#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %ld", x);
#define ReadLong(a) if (fscanf(stdin, "%ld", &a) != 1) a = 0;

struct commons{
     long gcd;
     long lcm;
}results[10];

void GCDEuclid(long x, long y, long i)
{
  long gcd;
  long r;
  long cont;
  long tmp;
  
  cont = 1;
  gcd = 0;
  r = 0;

  //Take the absolute value of x and y
  tmp = -x;
  if (tmp > x) {  x = tmp; }
  tmp = -y;
  if (tmp > y) { y = tmp; }

  if(y > x) {
     tmp = y;
     x = y;
     y = tmp;
  }
 
  while(cont == 1) {
     if(y == 0) {
        gcd = x;
        cont = 0;
     }
     else {
       r = x % y;
       x = y;
       y = r;
     }
  }
  results[i].gcd = gcd;
}

void main() 
{
   struct pair {
      long a;
      long b;
   }data[10];
  
   long i,in,count;
   const long n = 10;
   
   count = 4000000;
   i = 0;
   //Initialization of the data
   while(i < n) {
      ReadLong(in);
      while(in == 0) {
         ReadLong(in);
      }
      data[i].a = in;
      ReadLong(in);
      while(in == 0) {
         ReadLong(in);
      }
      data[i].b = in;
      i = i + 1;
   }
   
   while(count > 0 ) {
      i = 0;
      while (i < n) {
        GCDEuclid(data[i].a,data[i].b,i);
        results[i].lcm = (data[i].a * data[i].b ) / results[i].gcd;
        i = i + 1;
      }
      count = count - 1;
   }
   
   i = 0;
   while (i < n) {    
      WriteLong(data[i].a);
      WriteLong(data[i].b);
      WriteLong(results[i].gcd);
      WriteLong(results[i].lcm);
      WriteLine();
      i = i + 1;
   }
 
}

/*Inputs:
35
15
144
24
55
10
512
64
2099
99
148
1065
264
185
199
199
53
90
100
45

Outputs:
 35 15 5 105
 144 24 24 144
 55 10 5 110
 512 64 64 512
 2099 99 1 207801
 148 1065 1065 148
 264 185 1 48840
 199 199 199 199
 53 90 90 53
 100 45 5 900

*/
