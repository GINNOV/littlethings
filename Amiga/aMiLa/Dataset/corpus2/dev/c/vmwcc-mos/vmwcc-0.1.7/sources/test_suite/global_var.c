#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long

long a;

void main()
{
  long b;
  ReadLong(b);
  a = b*2;
  b = a+1;
  WriteLong(b);
  WriteLine();
}

/*

expected output
*** block  1 fail -   branch -   rdom -   dsc -   link -
     instr  1:   read                             use 2
     [-] Deleted Line:     instr  2:   move (1) b2                              
     instr  3:   add abase GP                     use 5
     instr  4:   mul (1) 2                        use 5
     instr  5:   store (4) (3)
     [3] Deleted Line:     instr  6:   add abase GP                     use 7   
     instr  7:   load (3)                         use 8
     instr  8:   add (7) 1                        use 9
     [-] Deleted Line:     instr  9:   move (8) b9                              
     instr 10:   write (8)
     instr 11:   wrl
     instr 12:   end

*/
