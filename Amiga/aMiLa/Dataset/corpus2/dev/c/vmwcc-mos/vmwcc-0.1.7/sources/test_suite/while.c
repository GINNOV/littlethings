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
  long l;
  long m;

  i = 7;
  j = 14;
  k = j/i;
  l = j * 8;
  while (i < j) {
    k = k + j;
    i = i + 1;
  }
  m = j * 8;
  j = k / i;
  WriteLong(j);
  WriteLong(m);
  WriteLine();
}


/*
expected output:
*** block  1 fail 2   branch -   rdom -   dsc 2   link 2
     [-] Deleted Line:     instr  1:   move 7 i1                                
     [-] Deleted Line:     instr  2:   move 14 j2                               
     instr  3:   div 14 7                         use 4
     [-] Deleted Line:     instr  4:   move (3) k4                              
     instr  5:   mul 14 8                         use 6
     [-] Deleted Line:     instr  6:   move (5) l6                              

*** block  2 fail 3   branch 4   rdom 1   dsc 4   link 3
     instr  7:   k7 = phi((3),(11))
     instr  8:   i8 = phi(7,(13))                           op1lu 3
     instr  9:   cmplt i8 14                      use 10
     instr 10:   blbc (9) [16]

*** block  3 fail -   branch 2   rdom 2   dsc -   link 4
     instr 11:   add k7 14                        use 12
     [-] Deleted Line:     instr 12:   move (11) k12                            
     instr 13:   add i8 1                         use 14
     [-] Deleted Line:     instr 14:   move (13) i14                            
     instr 15:   br [7]

*** block  4 fail -   branch -   rdom 2   dsc -   link -
     instr 16:   nop
     [5] Deleted Line:     instr 17:   mul 14 8                         use 18  
     [-] Deleted Line:     instr 18:   move (5) m18                             
     instr 19:   div k7 i8                        use 20
     [-] Deleted Line:     instr 20:   move (19) j20                            
     instr 21:   write (19)
     instr 22:   write (5)
     instr 23:   end
*/
