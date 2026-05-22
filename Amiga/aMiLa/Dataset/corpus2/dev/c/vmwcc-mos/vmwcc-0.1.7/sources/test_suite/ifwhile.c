#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


void main()
{
  long a, b, c, d;

  ReadLong(a);
  ReadLong(c);
  ReadLong(d);
  b = 38 + a;

  b = c * d - c / d;

  if (a < 0) {
    b = -1;
    a = -a;
  } else {
    b = 1;
    c = c * d - c / d;
  }
  WriteLong(c);
  while (a > 0) {
    b = b * 2;
    a = a / 2;
  }
  WriteLong(b);

  c = c * d - c / d;
  WriteLong(c);
  WriteLine();
}

/*
expected output 

*** block  1 fail 2   branch 3   rdom -   dsc 4   link 2
     instr  1:   read                             use 2
     [-] Deleted Line:     instr  2:   move (1) a2                              
     instr  3:   read                             use 4
     [-] Deleted Line:     instr  4:   move (3) c4                              
     instr  5:   read                             use 6
     [-] Deleted Line:     instr  6:   move (5) d6                              
     instr  7:   add 38 (1)                       use 8
     [-] Deleted Line:     instr  8:   move (7) b8                              
     instr  9:   mul (3) (5)                      use 11
     instr 10:   div (3) (5)                      use 11
     instr 11:   sub (9) (10)                     use 12
     [-] Deleted Line:     instr 12:   move (11) b12                            
     instr 13:   cmplt (1) 0                      use 14
     instr 14:   blbc (13) [25]

*** block  2 fail -   branch 4   rdom 1   dsc -   link 3
     instr 15:   neg 1                            use 16
     [-] Deleted Line:     instr 16:   move (15) b16                            
     instr 17:   neg (1)                          use 18
     [-] Deleted Line:     instr 18:   move (17) a18                            
     instr 19:   br [25]

*** block  3 fail 4   branch -   rdom 1   dsc -   link 4
     [-] Deleted Line:     instr 20:   move 1 b20                               
     [9] Deleted Line:     instr 21:   mul (3) (5)                      use 23  
     [10] Deleted Line:     instr 22:   div (3) (5)                      use 23 
     [11] Deleted Line:     instr 23:   sub (9) (10)                     use 24 
     [-] Deleted Line:     instr 24:   move (11) c24                            

*** block  4 fail 5   branch -   rdom 1   dsc 5   link 5
     instr 25:   c25 = phi((3),(11))                        op1lu 22
     instr 26:   b26 = phi((15),1)
     instr 27:   a27 = phi((17),(1))                                  op2lu 17
     instr 28:   nop
     instr 29:   write c25

*** block  5 fail 6   branch 7   rdom 4   dsc 7   link 6
     instr 30:   b30 = phi(b26,(34))
     instr 31:   a31 = phi(a27,(36))
     instr 32:   cmplt 0 a31                      use 33
     instr 33:   blbc (32) [39]

*** block  6 fail -   branch 5   rdom 5   dsc -   link 7
     instr 34:   mul b30 2                        use 35
     [-] Deleted Line:     instr 35:   move (34) b35                            
     instr 36:   div a31 2                        use 37
     [-] Deleted Line:     instr 37:   move (36) a37                            
     instr 38:   br [30]

*** block  7 fail -   branch -   rdom 5   dsc -   link -
     instr 39:   nop
     instr 40:   write b30
     instr 41:   mul c25 (5)                      use 43
     instr 42:   div c25 (5)                      use 43
     instr 43:   sub (41) (42)                    use 44
     [-] Deleted Line:     instr 44:   move (43) c44                            
     instr 45:   write (43)
     instr 46:   end

*/
