#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


void main()
{
  long i, a[10];
  struct B {
    long x, y;
  } b;

  ReadLong(i);
  a[i] = i;
  WriteLong(a[i]);
  b.y = i;
  WriteLong(b.y);
  WriteLine();
}

/*

expected output
*** block  1 fail -   branch -   rdom -   dsc -   link -
     instr  1:   read                             use 2
     [-] Deleted Line:     instr  2:   move (1) i2                             \

     instr  3:   add abase FP                     use 5
     instr  4:   mul (1) 8                        use 5
     instr  5:   add (4) (3)                      use 6
     instr  6:   store (1) (5)
     [3] Deleted Line:     instr  7:   add abase FP                     use 9 
     [4] Deleted Line:     instr  8:   mul (1) 8                        use 9 

     [5] Deleted Line:     instr  9:   add (4) (3)                      use 10

     instr 10:   load (5)                         use 11
     instr 11:   write (10)
     instr 12:   add bbase FP                     use 13
     instr 13:   add (12) yoffs                   use 14
     instr 14:   store (1) (13)
     [12] Deleted Line:     instr 15:   add bbase FP                     use 16

     [13] Deleted Line:     instr 16:   add (12) yoffs                   use 17

     instr 17:   load (13)                        use 18
     instr 18:   write (17)
     instr 19:   end


*/
