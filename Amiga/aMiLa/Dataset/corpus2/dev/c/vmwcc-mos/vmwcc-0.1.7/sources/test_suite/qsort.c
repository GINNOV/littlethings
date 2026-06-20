#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %lld", x);
#define ReadLong(a) if (fscanf(stdin, "%lld", &a) != 1) a = 0;
#define long long long


const long n = 100;
long data[100];


void Quicksort(long l, long r)
{
  long i, j;
  long x;

  i = l;
  j = r;
  x = data[(l+r)/2];
  while (i <= j) {
    while (data[i] < x) {
      i = i + 1;
    }
    while (x < data[j]) {
      j = j - 1;
    }
    if (i <= j) {
      x = data[i];
      data[i] = data[j];
      data[j] = x;
      i = i + 1;
      j = j - 1;
    }
  }
  if (l < j) {
    Quicksort(l, j);
  }
  if (i < r) {
    Quicksort(i, r);
  }
}


void main()
{
  long i;

  i = 0;
  while (i < n) {
    data[i] = n-1-i;
    i = i + 1;
  }
   
  i=0;
  while (i<n) {
     WriteLong(data[i]);
     i=i+1;
  }
   
//  WriteLong(data[0]);
//  WriteLong(data[n-1]);
  WriteLine();
  Quicksort(0, n-1);
  
   
  i=0;
  while (i<n) {
     WriteLong(data[i]);
     i=i+1;
  }
   	
 // WriteLong(data[0]);
 // WriteLong(data[n-1]);
  WriteLine();
}


/*
 expected output:

*** block 1 fail 2 branch - rdom - dsc 2 next - link 2 join Quicksort
        DELETE1:        move l0 i1
        DELETE2:        move r0 j2
        instr 3:        add l0 r0               use 4
        instr 4:        div (3) 2               use 5
        instr 5:        mul (4) 8               use 7
        instr 6:        add database gp         use 7
        instr 7:        add (5) (6)             use 8
        instr 8:        load (7)
        DELETE9:        move (8) x9

*** block 2 fail 3 branch 12 rdom 1 dsc 12 next - link 3 join Quicksort
        instr -1:       kill database
        instr -1:       kill database
        instr 10:       x10 = phi((8), x60)
        instr 11:       j11 = phi(r0, j58)
        instr 12:       i12 = phi(l0, i59)
        instr 13:       cmple i12 j11           use 14
        instr 14:       blbc (13) [BB12]

*** block 3 fail 4 branch - rdom 2 dsc 4 next - link 4 join 2
Empty Blocks will be necessary for later projects
*** block 4 fail 5 branch 6 rdom 3 dsc 6 next - link 5 join 2
        instr 15:       i15 = phi(i12, (22))
        instr 16:       mul i15 8               use 18
        DELETE17:       add database gp
        instr 18:       add (16) (6)            use 19                  ylu 7
        instr 19:       load (18)               use 20
        instr 20:       cmplt (19) x10          use 21
        instr 21:       blbc (20) [BB6]

*** block 5 fail - branch 4 rdom 4 dsc - next - link 6 join 4
        instr 22:       add i15 1                               xlu 16
        DELETE23:       move (22) i23
        instr 24:       br [BB4]

*** block 6 fail 7 branch - rdom 4 dsc 7 next 5 link 7 join 2
Empty Blocks will be necessary for later projects
*** block 7 fail 8 branch 9 rdom 6 dsc 9 next - link 8 join 2
        instr 25:       j25 = phi(j11, (32))
        instr 26:       mul j25 8               use 28
        DELETE27:       add database gp
        instr 28:       add (26) (6)            use 29                  ylu 18
        instr 29:       load (28)               use 30
        instr 30:       cmplt x10 (29)          use 31  xlu 20
        instr 31:       blbc (30) [BB9]

*** block 8 fail - branch 7 rdom 7 dsc - next - link 9 join 7
        instr 32:       sub j25 1                               xlu 26
        DELETE33:       move (32) j33
        instr 34:       br [BB7]

*** block 9 fail 10 branch 11 rdom 7 dsc 11 next 8 link 10 join 2
        instr 35:       cmple i15 j25           use 36  xlu 22  ylu 32
        instr 36:       blbc (35) [BB11]

*** block 10 fail 11 branch - rdom 9 dsc - next - link 11 join 11
        DELETE37:       mul i15 8
        DELETE38:       add database gp
        DELETE39:       add (16) (6)
        DELETE40:       load (18)
        DELETE41:       move (19) x41
        DELETE42:       mul i15 8
        DELETE43:       add database gp
        DELETE44:       add (16) (6)
        DELETE45:       mul j25 8
        DELETE46:       add database gp
        DELETE47:       add (26) (6)
        DELETE48:       load (28)
        instr 49:       store (29) (18)                         xlu 30
        instr -1:       kill database
        DELETE50:       mul j25 8
        DELETE51:       add database gp
        DELETE52:       add (26) (6)
        instr 53:       store (19) (28)                         xlu 20
        instr -1:       kill database
        instr 54:       add i15 1                               xlu 35
        DELETE55:       move (54) i55
        instr 56:       sub j25 1                               xlu 35
        DELETE57:       move (56) j57

*** block 11 fail - branch 2 rdom 9 dsc - next 10 link 12 join 2
        instr 58:       j58 = phi((56), j25)
        instr 59:       i59 = phi((54), i15)
        instr -1:       kill database
        instr -1:       kill database
        instr 60:       x60 = phi((19), x10)
        instr 61:       br [BB2]

*** block 12 fail 13 branch 15 rdom 2 dsc 15 next 3 link 13 join Quicksort
        instr 62:       cmplt l0 j11            use 63  xlu 3   ylu 13
        instr 63:       blbc (62) [BB15]

*** block 13 fail 14 branch 1 rdom 12 dsc 14 next - link 14 join 15
        instr 64:       param l0                                xlu 62
        instr 65:       param j11                               xlu 62
        instr 66:       bsr [BB1]
        instr -1:       kill database

*** block 14 fail 15 branch - rdom 13 dsc - next - link 15 join 15
Empty Blocks will be necessary for later projects
*** block 15 fail 16 branch 18 rdom 12 dsc 18 next 13 link 16 join Quicksort
        instr -1:       kill database
        instr 67:       cmplt i12 r0            use 68  xlu 13  ylu 3
        instr 68:       blbc (67) [BB18]

*** block 16 fail 17 branch 1 rdom 15 dsc 17 next - link 17 join 18
        instr 69:       param i12                               xlu 67
        instr 70:       param r0                                xlu 67
        instr 71:       bsr [BB1]
        instr -1:       kill database

*** block 17 fail 18 branch - rdom 16 dsc - next - link 18 join 18
Empty Blocks will be necessary for later projects
*** block 18 fail - branch - rdom 15 dsc - next 16 link 19 join Quicksort
        instr -1:       kill database
        instr 72:       ret

*** block 19 fail 20 branch - rdom - dsc 20 next - link 20 join main
        DELETE73:       move 0 i73

*** block 20 fail 21 branch 22 rdom 19 dsc 22 next - link 21 join main
        instr 74:       i74 = phi(0, (82))
        instr -1:       kill database
        instr 75:       cmplt i74 100           use 76
        instr 76:       blbc (75) [BB22]

*** block 21 fail - branch 20 rdom 20 dsc - next - link 22 join 20
        instr 77:       mul i74 8               use 79  xlu 75
        instr 78:       add database gp         use 79
        instr 79:       add (77) (78)           use 81
        instr 80:       sub 99 i74              use 81                  ylu 77
        instr 81:       store (80) (79)
        instr -1:       kill database
        instr 82:       add i74 1                               xlu 80
        DELETE83:       move (82) i83
        instr 84:       br [BB20]

*** block 22 fail 23 branch 1 rdom 20 dsc 23 next 21 link 23 join main
        instr 85:       add database gp         use 86  xlu 78  ylu 78
        instr 86:       add 0 (85)              use 87
        instr 87:       load (86)               use 88
        instr 88:       write (87)
        DELETE89:       add database gp
        instr 90:       add 792 (85)            use 91                  ylu 86
        instr 91:       load (90)               use 92
        instr 92:       write (91)
        instr 93:       wrl
        instr 94:       param 0
        instr 95:       param 99
        instr 96:       bsr [BB1]
        instr -1:       kill database

*** block 23 fail - branch - rdom 22 dsc - next - link - join main
        DELETE97:       add database gp
        DELETE98:       add 0 (85)
        instr 99:       load (86)               use 100 xlu 87
        instr 100:      write (99)
        DELETE101:      add database gp
        DELETE102:      add 792 (85)
        instr 103:      load (90)               use 104 xlu 91
        instr 104:      write (103)
        DELETE105:      wrl
        instr 106:      end

*/
