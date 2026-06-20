/* demo of use of matrix.c functions */
/* Written by Nigel Salt */

#include <matrix.h>
#include <stdio.h>

/* Matrix definitions */
double b4x4A[4][4]=
{
  6,1,6,6,
  1,6,6,0,
  0,3,2,1,
  8,6,1,9
};
matrix m4x4A={4,4,&b4x4A[0][0]};

double b4x4B[4][4];
matrix m4x4B={4,4,&b4x4B[0][0]};

double b4x4C[4][4];
matrix m4x4C={4,4,&b4x4C[0][0]};

double b4D[4];
matrix cv4D={1,4,&b4D[0]};

double b4E[4];
matrix cv4E={1,4,&b4E[0]};

double b4F[4];
matrix rv4F={4,1,&b4F[0]};

double b4G[4];
matrix rv4G={4,1,&b4G[0]};

double b3x3A[3][3]={0,1,1,1,2,3,1,1,1};
matrix m3x3A={3,3,&b3x3A[0][0]};

double b3x3B[3][3]={0,1,1,1,2,3,1,1,1};
matrix m3x3B={3,3,&b3x3B[0][0]};

double b3x3C[3][3]={0,1,1,1,2,3,1,1,1};
matrix m3x3C={3,3,&b3x3C[0][0]};


void main()
{
  int i,j;

  printf("\nMATRIX A");
	mprint(&m4x4A);
	printf("\nDET(A)=%lf",det(&m4x4A));
	minv(&m4x4A,&m4x4C);
  printf("\nINV(A)");
	mprint(&m4x4C);
	mmult(&m4x4A,&m4x4C,&m4x4B);
  printf("\nMATRIX A*INV(A)");
	mprint(&m4x4B);
  mid(&m4x4B);
  printf("\n4 x 4 ID MATRIX");
	mprint(&m4x4B);
}


