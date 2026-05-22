/*
 * HCC asm() demonstration program by TetiSoft
 */

/*
 * Changed slightly by Jason Petty for HCE. (15/6/94)
 * Changes marked VANSOFT.
 */

void main();
int AddByte();

int AddByte()
{
 /* HCC and TOP will add the following here:
  * link a5,#0
  * That means, our parameters are found relative to A5.
  * The first parameter is found at 8(A5),
  * the second at 12(A5), etc.
  * Since HCC expands all parameters to 32 bit when -L is specified,
  * we must NOT care if we GOT a char, short, int, long, signed or
  * unsigned parameter. We only must care if we WANTED a byte, word
  * or long value.
  * A long value could be addressed as move.l  8(a5),d0
  * A word value could be addressed as move.w 10(a5),d0
  * A byte value could be addressed as move.b 11(a5),d0
  * We are allowed to destroy d0,d1,d2,a0,a1,a6 and a7.
  * We are not allowed to destroy d3-d7 and a2-a5.
  * If we return something, it is expected in d0.
  * We should not return via rts without an unlk a5,
  * which restores a7.
  */

 asm(" move.b 11(a5),d0");
 asm(" add.b 15(a5),d0");

 /* HCC and TOP will add the following here:
  * unlk a5  ; restore a7
  * rts   ; return value in d0
  */
}

void main()
{
 char var1=1, var2=2;

 /* Changed lines below slightly. VANSOFT. */
 printf(
     "\n\nThis demonstration shows the use of the 'asm()' operator used\n");
 printf("by the internal compiler HCC. It adds two variables together\n");
 printf(
     "using a function who's body was made with the 'asm()' operator and\n");
 printf("can only add byte sized numbers, hence the name 'AddByte()'.\n\n");

 printf("Var1 = 1 and Var2 = 2:\n\n");

 printf("AddByte( (char)Var1, (char)Var2 ) = %d\n\n",
         AddByte((char)var1,(char)var2));

 printf("AddByte( (short)Var1, (short)Var2 ) = %d\n\n", 
         AddByte((short)var1,(short)var2));

 printf("AddByte( (long)Var1, (long)Var2 ) = %d\n\n", 
         AddByte((long)var1,(long)var2));

 printf("See source code for how it works...\n\n\n");
}

