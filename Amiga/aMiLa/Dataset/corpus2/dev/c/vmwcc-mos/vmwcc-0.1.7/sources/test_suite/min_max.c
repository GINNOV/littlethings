#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long

const long n = 5;
long a[5];

void main()
{
  long i, min, max;
   
  a[0]=-0;
  a[1]=55;
  a[2]=-300;
  a[3]=7;
  a[4]=17;
   
  min = a[0];
  max = a[0];
  i = 1;
  while (i < n) {
    if (min > a[i]) {
      min = a[i];
    } else {
      if (max < a[i]) {
	max = a[i];
      }
    }
    i = i + 1;
  }
  WriteLong(min);
  WriteLong(max);
  WriteLine();
}

/*

expected output

*** block 1  fail  -  branch  -  rdom  -  dsc  -  next  -  link 2
        instr   1:  mul 0 8  use 2
        instr   2:  add (1) abase  use 3
        instr   3:  adda (2) GP  use 4
        instr   4:  load (3)  use 5
        instr   5:  move (4) min
        instr   6:  mul 0 8  use 7
        instr   7:  add (6) abase  use 8             ylu 2
        instr   8:  adda (7) GP  use 9             ylu 3
        instr   9:  load (8)  use 10
        instr  10:  move (9) max
        instr  11:  move 1 i

	*** block 2  fail 3   branch 8   rdom  1  dsc 8   next  -  link 3
        instr  12:  cmplt i 5  use 13
        instr  13:  blbc (12) [40]

	*** block 3  fail 4   branch 5   rdom 2   dsc 7   next  -  link 4
        instr  14:  mul i 8  use 15   xlu 12
        instr  15:  add (14) abase  use 16            ylu 7
        instr  16:  adda (15) GP  use 17            ylu 8
        instr  17:  load (16)  use 18
        instr  18:  cmple (17) min  use 19
        instr  19:  blbc (18) [26]

	*** block 4  fail  -  branch 7   rdom 3   dsc  -  next  -  link 5
        instr  20:  mul i 8  use 21   xlu 14
        instr  21:  add (20) abase  use 22            ylu 15
        instr  22:  adda (21) GP  use 23            ylu 16
        instr  23:  load (22)  use 24
        instr  24:  move (23) min
        instr  25:  br [37]

	*** block 5  fail 7   branch 7   rdom 3   dsc 6   next 4   link 6
        instr  26:  mul i 8  use 27   xlu 20
        instr  27:  add (26) abase  use 28            ylu 21
        instr  28:  adda (27) GP  use 29            ylu 22
        instr  29:  load (28)  use 30
        instr  30:  cmplt max (29)  use 31
        instr  31:  blbc (30) [37]

	*** block 6  fail 7   branch  -  rdom 5   dsc  -  next  -  link 7
        instr  32:  mul i 8  use 33   xlu 26
        instr  33:  add (32) abase  use 34            ylu 27
        instr  34:  adda (33) GP  use 35            ylu 28
        instr  35:  load (34)  use 36
        instr  36:  move (35) max

	*** block 7  fail  -  branch 2   rdom 3   dsc  -  next 5   link 8
        instr  37:  add i 1  use 38   xlu 32
        instr  38:  move (37) i
        instr  39:  br [12]

	*** block 8  fail  -  branch  -  rdom 2   dsc  -  next 3   link  -
        instr  40:  writex min           xlu 18
        instr  41:  writex max           xlu 30
        instr  42:  wrl
        instr  43:  end
*/
