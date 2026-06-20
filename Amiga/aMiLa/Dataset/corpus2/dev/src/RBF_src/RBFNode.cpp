#include <RBF.h>

RBFNode::RBFNode()
{
   d = 0;
}

RBFNode::RBFNode(int d0)
{
   d = d0;
   C = new float [d];
   R = new float [d];
}

void RBFNode::Init(int d0)
{
   if (d==0) {
      d = d0;
      C = new float [d];
      R = new float [d];
   }
}



RBFNode::~RBFNode()
{
   if (C)
      delete [] C;
   if (R)
      delete [] R;
}

void RBFNode::SetCR(int i, float c, float r)
{
//   printf("Setting to %d: %f,%f\n",i,c,r);
   assert(i<d);
   if (i<d) {
      C[i] = c;
      R[i] = r;
   }
}

void RBFNode::ShowStats(void)
{
   int i;

   printf("C = (");
   for (i=0; i<d; i++) {
      if (i>0)
         printf(" ,");
      printf("%f",C[i]);
   }
   printf(")\n R = (");
   for (i=0; i<d; i++) {
      if (i>0)
         printf(" ,");
      printf("%f",R[i]);
   }
   printf(")\n");
}

float RBFNode::Distance(float *X)
{
   int i;
   float dist = 0;
   float d0;
   for (i=0; i<d; i++, X++) {
      d0 = (*X - C[i]);
      dist+=d0*d0;
   }
   return dist;
}

float RBFNode::Membership(float *X)
{

   int i;
   float dist = 0;
   float d0;
   for (i=0; i<d; i++, X++) {
      //printf("R[%d]=%f\n",i,R[i]);
      assert(R[i]!=0);
      d0 = (*X - C[i]);

      if (R[i]>0) {
         d0 = d0/R[i];
      } else {
         if (R[i]==-1)
            { if (d0<0) {d0 = 0;} }
         if (R[i]==-2)
            { if (d0>0) {d0 = 0;} }
      }

      dist+=d0*d0;

   }

   dist = (1 - dist);
   if (dist<0)
      dist=0;
   return dist;
}

