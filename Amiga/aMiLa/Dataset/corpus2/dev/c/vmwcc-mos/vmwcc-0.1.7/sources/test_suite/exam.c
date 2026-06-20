#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long

const long n = 5;



void foo(long i, long j)
{
  long a[n]; 
  long x, y;

  a[0]=0;
  a[1]=1;
  a[2]=2;
  a[3]=3;
  a[4]=4;
   
  y = 2;

  x = a[i];
  if(x > 0) {
    a[j] = y;
  } else {
    y = a[j];
  }
  x = a[i]*y;
  WriteLong(x);
  WriteLine();
}


void main()
{
  long i, j;

  ReadLong(i);
  ReadLong(j);

  foo(i, j);
}

/*

expected output

*** Block 1  fail 2  branch 3  rdom -  dsc 4  next -  link 2

    instr 1  :  move   2        y1               use 0  Erased
    instr 2  :  mul    i0       8                use 4
    instr 3  :  add    abase    GP               use 4
    instr 4  :  adda   (3)      (2)              use 5
    instr 5  :  load   (4)                       use 6      [a]
    instr 6  :  move   (5)      x6               use 7  Erased
    instr 7  :  cmple  (5)      0                use 8
    instr 8  :  blbs   (7)      [14]

*** Block 2  fail -  branch 4  rdom 1  dsc -  next -  link 3

    instr 9  :  mul    j0       8                use 11
    instr 10 :  add    (3)      GP               use 11  xlu 3  ylu 3  Erased
    instr 11 :  adda   (3)      (9)              use 12
    instr 12 :  store  2        (11)                 [kill a]
    instr 13 :  br              [19]

*** Block 3  fail 4  branch -  rdom 1  dsc -  next 2  link 4

    instr 14 :  mul    j0       8                use 16  xlu 9
    instr 15 :  add    (3)      GP               use 16  xlu 10  ylu 10  Erased
    instr 16 :  adda   (3)      (14)             use 17
    instr 17 :  load   (16)                      use 18      [a]
    instr 18 :  move   (17)     y18              use 0  Erased

*** Block 4  fail -  branch -  rdom 1  dsc -  next 3  link 5

    instr 19 :  mul    (2)      8                use 21  xlu 2  Erased
    instr 20 :  add    (3)      GP               use 21  xlu 15  ylu 15  Erased
    instr 21 :  adda   (4)      (2)              use 22  Erased
    instr 22 :  load   (4)                       use 23      [a]
    instr 23 :  mul    (22)     y0               use 24
    instr 24 :  move   (23)     x24              use 25  Erased
    instr 25 :  write  (23)
    instr 26 :  ret

*** Block 5  fail -  branch 1  rdom -  dsc 6  next -  link 6

    instr 27 :  read                             use 28
    instr 28 :  move   (27)     i28              use 31  Erased
    instr 29 :  read                             use 30
    instr 30 :  move   (29)     j30              use 32  Erased
    instr 31 :  param  (27)
    instr 32 :  param  (29)
    instr 33 :  bsr             [1]

*** Block 6  fail -  branch -  rdom 5  dsc -  next -  link -

    instr 34 :  end

*/
