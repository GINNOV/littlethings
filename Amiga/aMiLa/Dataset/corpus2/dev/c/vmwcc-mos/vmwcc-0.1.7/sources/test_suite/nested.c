#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


void main()
{
  long i;
  long j;
  long k;
  long m;

  i = 4;
  j = i * 3;
  k = j + i;
  m = k - j;
   
  if (i < j) {

     while( k >= m ) {

      if ( m <= i ) {
         k = k / 2; 
      } else {
         m = m + 1;
      }
    }
      
    j = k + m + i;
     
  }
  
  WriteLong(i);
  WriteLong(j);
  WriteLong(k);
  WriteLong(m);
  WriteLine();
}


/*
expected output:

*** block 1  fail 2   branch 8   rdom  -  dsc 8   next  -  link 2
        instr   1:  move 4 i
        instr   2:  mul i 3  use 3
        instr   3:  move (2) j
        instr   4:  add j i  use 5             ylu 2
        instr   5:  move (4) k
        instr   6:  sub k j  use 7             ylu 4
        instr   7:  move (6) m
        instr   8:  cmplt i j  use 9    xlu 4    ylu 6
        instr   9:  blbc (8) [23]

*** block 2  fail 8   branch 7   rdom 1   dsc 7   next  -  link 3
        instr  10:  cmplt m k  use 11            ylu 6
        instr  11:  blbc (10) [20]

*** block 3  fail 4   branch 5   rdom 2   dsc 6   next  -  link 4
        instr  12:  cmple m i  use 13   xlu 10   ylu 8
        instr  13:  blbc (12) [17]

*** block 4  fail  -  branch 6   rdom 3   dsc  -  next  -  link 5
        instr  14:  div k 2  use 15   xlu 10
        instr  15:  move (14) k
        instr  16:  br [19]

*** block 5  fail 6   branch  -  rdom 3   dsc  -  next 4   link 6
        instr  17:  add m 1  use 18   xlu 12
        instr  18:  move (17) m

*** block 6  fail  -  branch 2   rdom 3   dsc  -  next 5   link 7
        instr  19:  br [10]

*** block 7  fail  -  branch  -  rdom 2   dsc  -  next 3   link 8
        instr  20:  add k m  use 21   xlu 14   ylu 17
        instr  21:  add (20) i  use 22            ylu 12
        instr  22:  move (21) j

*** block 8  fail  -  branch  -  rdom 1   dsc  -  next 2   link  -
        instr  23:  end
*/
