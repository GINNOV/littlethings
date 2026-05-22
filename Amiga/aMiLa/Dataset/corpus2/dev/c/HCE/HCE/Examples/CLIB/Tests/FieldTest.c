/*
 * HCC 32 bit int field test program by TetiSoft
 * Notice that the fields are filled from right to left,
 * which may differ from Aztec or Lattice.
 */

/*
 * Modified slightly by Jason Petty for HCE. (16/6/94)
 * Changes marked VANSOFT.
 */

union fieldtest
{
 int all;
 struct {
  int a:1;
  int b:2;
  int c:3;
  int d:4;
  int e:5;
  int f:6;
  int g:7;
 } f;
} test;

main()
{
 test.f.a=1; /* Bit      0 =                                1*/
 test.f.b=2; /* Bits  2- 1 =                              10 */
 test.f.c=5; /* Bits  5- 3 =                           101 */
 test.f.d=6; /* Bits  9- 6 =                       0110 */
 test.f.e=17; /* Bits 14-10 =                  10001  */
 test.f.f=30; /* Bits 20-15 =            011110  */
 test.f.g=65; /* Bits 27-21 =     1000001   */
  /*  unused Bits 31-28 = 0000    */
   /* all        = 00001000001011110100010110101101*/
   /*            =$   0   8   2   F   4   5   A   D*/

/* Changed lines below slightly. VANSOFT. */
 printf(
   "\n\n\n32 bit integer fields test for the internal compiler 'HCC'.\n\n");

 printf("%d %d %d %d %d %d %d - Extracted from bit field $%08x\n\n",
        test.f.a, test.f.b, test.f.c, test.f.d, test.f.e,
        test.f.f, test.f.g, test.all);

 printf("The correct result should be:\n");
 printf("1 2 5 6 17 30 65 - Extracted from bit field $082F45AD\n\n");
 printf("See source code for how it works...\n\n\n");
}

