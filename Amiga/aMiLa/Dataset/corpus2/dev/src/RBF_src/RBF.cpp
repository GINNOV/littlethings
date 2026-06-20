#include <RBF.h>

RBF::RBF(int nof_dimensions, DimensionalParameters *DP)
{
   int i,j,k,l;
   int stepsize;
   float c,s,r;
   float *C[32],*CC;
   d = nof_dimensions;
   assert(d>0);

   nodes = 1;
   for (i=0; i<d; i++) {
      nodes *= DP[i].nof_RBFs;
      C[i] = new float[DP[i].nof_RBFs];
   }

   printf("%d nodes\n",nodes);

   N = new RBFNode [nodes];
   Y = new float [nodes];
   assert (N);
   assert (Y);

   for (i=0; i<nodes; i++)
      N[i].Init(d);

   for (i=0; i<d; i++) {
      c = DP[i].centre;
      s = DP[i].spacing;
      r = 2*s;
      c = c-.5*s*DP[i].nof_RBFs;
      CC=C[i];
      for (j=0; j<DP[i].nof_RBFs; j++, CC++, c+=s)
         *CC = c;
   }

   stepsize=1;
   i = 0;
   j = 0;

   for (i=0; i<d; i++) {
      printf("Setting up %d-axis\n",i);
      k = 0;
      //for (j=0; j<DP[i].nof_RBFs; j++) {
         j = 0;
         for (k=0; k<(nodes); k+=stepsize) {
            for (l=k; l<k+stepsize; l++) {
//               printf("Node %d : ",l);
               assert((l>=0)&&(l<nodes));
               if (DP[i].Extremis==1) {
                  if (j==0)
                     N[l].SetCR(i, C[i][j], -1);
                  else if (l==(DP[i].nof_RBFs-1))
                     N[l].SetCR(i, C[i][j], -2);
                  else
                     N[l].SetCR(i, C[i][j], r);
               }else{
                  N[l].SetCR(i, C[i][j], r);
               }
            }
            j++;
            if (j==DP[i].nof_RBFs)
               j = 0;
         }
         //k+=stepsize;
      //}
     stepsize*=DP[i].nof_RBFs;

   }

   /*
   for (i=0; i<d; i++) {
      for (j=0; j<DP[i].nof_RBFs; j++)
         printf("%d:(%d)=%f\n",i,j,C[i][j]);
   }
   */

   for (i=0; i<d; i++) {
      if (C[i])
         delete [] C[i];
   }
}


RBF::~RBF()
{
   if (N)
      delete [] N;
   if (Y)
      delete [] Y;
}

void RBF::Encode(float *vector)
{
   int i;
   for (i=0; i<nodes; i++) {
      Y[i] = N[i].Membership(vector);
   }
}

void RBF::ShowY(int nof_dimensions, DimensionalParameters *DP)
{
   //int x,y,j,k;
   int i = 0;

   /*for (k=0; k<d; k++,DP++) {
      for (j=0; j<DP->nof_RBFs; j++,i++) {
         N[i].ShowStats();
         printf(" %f \n",Y[i]);
      }
   }*/
   for (i=0; i<nodes; i++) {
     N[i].ShowStats();
     printf(" %f \n", Y[i]);
   }

   printf("\n-------------\n\n");

}


