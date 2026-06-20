/*
 * HCC 32 bit int scanf() and mathtrans test program by TetiSoft
 */

/*
 * Modified slightly by Jason Petty for HCE. (16/6/94)
 * Changes marked VANSOFT.
 *
 * note: when making this prog under HCE remember to set the 'use' maths
 *       library gadget in the linker-options window.
 */

main()
{
 short  w;
 int    i;
 float  f;
 double d;

/* Changed lines below slightly. VANSOFT. */
 printf(
  "\n\n\nscanf() and floating point test for the internal compiler HCC.\n");
 printf(
  "note: If run from 'HCE' click inside 'CLI' before you start typing!.\n\n");

 printf("Please enter an integer value that fits within 16 bit:\n");
 scanf ("%hd", &w);
 printf("scanf() returned %d\n\n", w);

 printf("Please enter an integer value that fits within 32 bit:\n");

 scanf ("%d", &i);
 printf("scanf() returned %d\n\n", i);

 printf("Please enter a float value:\n");
 scanf ("%f", &f);
 printf("scanf() returned %f\n\n", f);

 printf("Please enter a double value:\n");
 scanf ("%lf", &d);
 printf("scanf() returned %lf\n\n", d);

 printf("Testing mathtrans function:\n");
 printf("sin(Pi/2)=%f\n\n", sin(3.1415926/2));

 printf("Goodbye...\n\n\n");
}
