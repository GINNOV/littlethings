#ifndef defsmat
#define defsmat 1
/* Matrix structure */
typedef struct
{
  int rows;
  int cols;
  double *block;
} matrix,*matrixptr;

/*   E.G.
double b4x4A[4][4]=
{
  6,1,6,6,
  1,6,6,0,
  0,3,2,1,
  8,6,1,9
};
matrix m4x4A={4,4,&b4x4A[0][0]};
*/

/* Function prototypes */
void mprint(matrixptr);
void smmult(matrixptr,double);
int madd(matrixptr m1,matrixptr m2,matrixptr dm);
int mmult(matrixptr m1,matrixptr m2,matrixptr dm);
int mcopy(matrixptr sm,matrixptr dm);
int mtrans(matrixptr sm,matrixptr dm);
double det(matrixptr m);
int minv(matrixptr sm,matrixptr dm);
int nsolve(int rows,double *data);
int mid(matrixptr);
void mzero(matrixptr);
#endif

