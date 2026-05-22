#include <RBF.h>

void main(void)
{
   DimensionalParameters DP[] = {
      {2,1,0,1},
      {3,1,0,1},
      {4,1,0,1}, };
   RBF *R;
   float x[3];
   float i,j;

   R = NULL;

   R = new RBF(3, DP);
   printf("OK\n");
   if (!(R))
      goto bailout;

   for (i=-2; i<2; i++) {
      //for (j=-4; j<5; j++) {
         printf("X:(%f,%f)\n",i,i);
         x[0]=i;
         x[1]=i;
         x[2]=i;
         R->Encode(x);
//         R->ShowY(3, DP);
      //}
   }




bailout:
   if (R)
      delete R;

}


