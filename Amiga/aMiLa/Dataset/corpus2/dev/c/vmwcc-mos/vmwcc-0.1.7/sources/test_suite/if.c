#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


void main()
{
  long a, b, c, d, e, f;
  long g[5];

  g[0]=0;
  g[1]=1;
  g[2]=2;
  g[3]=3;
  g[4]=4;
  b=72;
   
  c = 0;
  ReadLong(a);
  d = b*a - 14;
  b = d*4%3;

  f = g[1];

  if (a < 0) {
    b = -1;
    a = c;
  } else {
    b = 1;
    c = a;
    g[2] = 0;
  }
  c = d*4%3;
  WriteLong(c);
  WriteLong(b);
  WriteLong(g[1]);
  WriteLine();
}

/*
expected output

*** block 1  fail  2  branch  3  rdom -  dsc 4  next -  link 2
    instr  1:
    instr  2:  read                 use 15
    instr  3:
    instr  4:  mul b0 (2)           use  5  ylu 15
    instr  5:  sub (4) 14           use  7  xlu  5
    instr  6:
    instr  7:  mul (5) 4            use  8  xlu 30
    instr  8:  mod (7) 3            use 33  xlu  8
    instr  9:
    instr 10:  mul 1 8              use 12
    instr 11:  add gbase FP         use 25
    instr 12:  add (10) (11)        use 38  xlu 12  ylu 12
    instr 13:  load (12)            use 14  xlu 13
    instr 14:
    instr 15:  cmplt (2) 0          use 16  xlu  4
    instr 16:  blbc (15) [23]               xlu 16


*** block 2  fail  -  branch  4  rdom 1  dsc -  next -  link 3
    instr 17:  neg 1                use 18
    instr 18:
    instr 19:
    instr 20:  br [27]


*** block 3  fail  4  branch  -  rdom 1  dsc -  next 2  link 4
    instr 21:
    instr 22:
    instr 23:  mul 2 8              use 25
    instr 24:
    instr 25:  add (23) (11)        use 26  xlu 25  ylu 12
    instr 26:  store 0 (25)                 ylu 26


*** block 4  fail  -  branch  -  rdom 1  dsc -  next 3  link -
    instr 27:  c27=phi 0 (2)
    instr 28:  a28=phi 0 (2)
    instr 29:  b29=phi (17) 1         ylu  4
    instr 30:
    instr 31:
    instr 32:
    instr 33:  write (8)                    xlu  9
    instr 34:  write b29                    xlu 29
    instr 35:
    instr 36:
    instr 37:
    instr 38:  load (12)            use 39  xlu 13
    instr 39:  write (38)                   xlu 39
    instr 40:  end
*/
