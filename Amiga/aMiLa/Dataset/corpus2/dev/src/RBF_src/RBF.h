#ifndef _RBF_H_
#define _RBF_H_

#include <assert.h>
#include <stdio.h>
#include <math.h>

// Radial Basis Function for computing memberships
class RBFNode
{
private:
   int d;
   float *C, *R;    //center, radius
   float Distance(float *X);
public:
   RBFNode();
   RBFNode(int d0);
   ~RBFNode();
   void Init(int d0);
   void SetCR(int i, float c, float r);
   float Membership(float *X);
   void ShowStats(void);
};


struct DimensionalParameters {
   int nof_RBFs;
   int Extremis;
   float centre;
   float spacing;
};


class RBF
{
private:
   int d;
   int nodes;
   float *X;         //input vector
   RBFNode *N;       //RBF Membership Nodes
//   void SetupArray(
public:
   float *Y;      //output vector
   RBF(int nof_dimensions, DimensionalParameters *DP);
   ~RBF();
   void Encode(float *vector);
   void ShowY(int nof_dimensions, DimensionalParameters *DP);
};


#endif



