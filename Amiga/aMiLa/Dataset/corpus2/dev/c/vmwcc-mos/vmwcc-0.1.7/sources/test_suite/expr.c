#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


void main()
{
  long a, b, c, d, e, f;
  a = 3;
  b = a;
  c = b+3*a;
  d = a/3+c%b;
  e = a*(b-(c+d));
  WriteLong(e);
  f = a/3 + c%b;
  WriteLong(f);
  WriteLine();
}

/* a=3
 * b=3
 * c=3+3*3 = 12
 * d=a/3+c%b = 1+0 = 1
 * e=a*(b-(c+d)) = 3*(3-(12+1)) = -30 
 * f=a/3 + c%b = 3/3 + 12%3 = 1 */
 

/* expected output

     [-] Deleted Line:     instr  1:   move 3 a1                                
     [-] Deleted Line:     instr  2:   move 3 b2                                
     instr  3:   mul 3 3                          use 4
     instr  4:   add 3 (3)                        use 5
     [-] Deleted Line:     instr  5:   move (4) c5                              
     instr  6:   div 3 3                          use 8
     instr  7:   mod (4) 3                        use 8
     instr  8:   add (6) (7)                      use 9
     [-] Deleted Line:     instr  9:   move (8) d9                              
     instr 10:   add (4) (8)                      use 11
     instr 11:   sub 3 (10)                       use 12
     instr 12:   mul 3 (11)                       use 13
     [-] Deleted Line:     instr 13:   move (12) e13                            
     instr 14:   write (12)
     [6] Deleted Line:     instr 15:   div 3 3                          use 17  
     [7] Deleted Line:     instr 16:   mod (4) 3                        use 17  
     [8] Deleted Line:     instr 17:   add (6) (7)                      use 18  
     [-] Deleted Line:     instr 18:   move (8) f18                             
     instr 19:   write (8)
     instr 20:   end
*/
