/* Matrix operation functions and typedefs */
/* Written by Nigel Salt */

#include <stdio.h>
//#include <malloc.h>

typedef struct
{
  int rows;
  int cols;
  double *block;
} matrix,*matrixptr;

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

/* function definitions */
void mprint(m)
matrixptr m;
{
  int i,j;
  int cols;
  cols=m->cols;
  for (i=0;i<m->rows;i++)
    {
    printf("\n");
    for (j=0;j<cols;j++)
      {
      printf("%8.2lf",*(m->block+i*cols+j));
      }
    }
}

/* add two matrices giving a third matrix */
int madd(m1,m2,dm)
matrixptr m1,m2,dm;
{
  int i,j;
  if (m1->rows!=m2->rows||m1->cols!=m2->cols)
    {
    fprintf(stderr,"\nmadd error - matrices different sizes");
    return(1);
    }
  if (m1->rows!=dm->rows||m1->cols!=dm->cols)
    {
    fprintf(stderr,"\nmadd error - matrices different sizes");
    return(1);
    }
  for (i=0;i<m1->rows;i++)
    for (j=0;j<m1->cols;j++)
      *(dm->block+i*m1->cols+j)=*(m1->block+i*m1->cols+j)+\
      *(m2->block+i*m1->cols+j);
  return(0);
}

int mcopy(sm,dm)
matrixptr sm,dm;
{
  int i,j;
  if (dm->rows!=sm->rows||dm->cols!=sm->cols)
    {
    fprintf(stderr,"\nmcopy error - matrices different sizes");
    return(1);
    }
  for (i=0;i<dm->rows;i++)
    for (j=0;j<dm->cols;j++)
      *(dm->block+i*dm->cols+j)=*(sm->block+i*dm->cols+j);
  return(0);
}

/* multiply matrix by scalar double */
void smmult(m,s)
matrixptr m;
double s;
{
  int i,j;
  for (i=0;i<m->rows;i++)
    for (j=0;j<m->cols;j++)
      *(m->block+i*m->cols+j)=*(m->block+i*m->cols+j)*s;
}

int mmult(m1,m2,dm)
matrixptr m1,m2,dm;
{
  int i,j,k;
  double cellval;
  if (m1->cols!=m2->rows)
    {
    fprintf(stderr,"\nmmult error - matrix 1 cols must = matrix 2 rows");
    return(1);
    }
  if (m2->cols!=dm->cols)
    {
    fprintf(stderr,"\nmmult error - dest matrix cols must = matrix 2 cols");
    return(1);
    }
  if (m1->rows!=dm->rows)
    {
    fprintf(stderr,"\nmmult error - dest matrix rows must = matrix 1 rows");
    return(1);
    }
  for (i=0;i<m1->rows;i++)
    for (j=0;j<m2->cols;j++)
      {
      cellval=0.0;
      for (k=0;k<m1->cols;k++)
        {
        cellval+=*(m1->block+i*(m1->cols)+k) * (*(m2->block+k*(m2->cols)+j));
        }
      *(dm->block+i*dm->cols+j)=cellval;
      }
  return(0);
}

int mtrans(sm,dm)
matrixptr sm,dm;
{
  int i,j;
  if (dm->rows!=sm->cols)
    {
    fprintf(stderr,"\nmtrans error - dest matrix rows must = source matrix cols");
    return(1);
    }
  if (sm->rows!=dm->cols)
    {
    fprintf(stderr,"\nmtrans error - source matrix rows must = dest matrix cols");
    return(1);
    }
  for (i=0;i<sm->rows;i++)
    for (j=0;j<sm->cols;j++)
      {
      *(dm->block+j*dm->cols+i)=*(sm->block+i*sm->cols+j);
      }
  return(0);
}

double det(m)
matrixptr m;
{
  double p1,p2,p3,d;
  int i,j,k;
  if (m->cols!=m->rows)
    {
    fprintf(stderr,"\ndet error - matrix must be square");
    return(0.0);
    }
  d=0;
  for (i=0;i<m->cols;i++)
    {
    p1=p2=1.0;
    p3=*(m->block+i);
    k=i;
    for (j=1;j<m->cols;j++)
      {
      k=(k+1)%m->cols;
      p1*= *(m->block+j*m->cols+k);
      p2*= *(m->block+(m->cols-j)*m->cols+k);
      }
    p3*=(p1-p2);
    d+=p3;
    }
  return(d);
}

int minv(sm,dm)
matrixptr sm,dm;
{
  int i,j,k,l;
        int nrow,ncol;
  double *d;
  if (sm->rows!=dm->rows||sm->cols!=dm->cols)
    {
    fprintf(stderr,"\nminv error - matrices must be same size");
    return(1);
    }
  if (det(sm)==0.0)
    {
    fprintf(stderr,"\nminv error - matrix is singular");
    return 1;
    }
  d=(double *)(malloc(sizeof(double)*sm->rows*(sm->cols+1)));
  if (d==(double *)NULL)
    {
    fprintf(stderr,"\nminv error - insufficient memory");
    return(1);
    }
  for (i=0;i<sm->rows;i++)
    {
                nrow=i-1;
                ncol=i-1;
    for (j=0;j<sm->rows;j++)
      {
      nrow=(nrow+1)%sm->rows;
      if (j==0)
        *(d+j*(sm->cols+1)+sm->cols)=1;
      else
                                *(d+j*(sm->cols+1)+sm->cols)=0;
                        for (k=0;k<sm->cols;k++)
                                {
                                ncol=(ncol+1)%sm->cols;
                                *(d+j*(sm->cols+1)+k)=*(sm->block+nrow*sm->cols+ncol);
                                }
      }
    if (nsolve(sm->rows,d))
      {
                        fprintf(stderr,"\nminv error - cannot use nsolve on row %u",i);
      free((char *)d);
      return 1;
      }
    else
                        {
                        nrow=i-1;
                        for (j=0;j<sm->rows;j++)
                                {
                                nrow=(nrow+1)%sm->rows;
                                *(dm->block+nrow*sm->cols+i)=*(d+j*(sm->cols+1)+sm->cols);
                                }
      }
    }
  free((char *)d);
  return 0;
}

int nsolve(rows,data)
int rows;
double *data;
{
  int i,j,k;
  int cols;
  double dtemp;
  cols=rows+1;
  for (i=0;i<rows;i++)
    {
    for (j=i;j<rows&&*(data+j*cols+j)==0.0;j++);
    if (*(data+j*cols+j)==0.0)
      {
      fprintf(stderr,"\nnsolve error - singular matrix");
      return 1;
      }
    if (j!=i)
      {
      for (k=0;k<cols;k++)
        {
        dtemp=*(data+i*cols+k);
        *(data+i*cols+k)=*(data+j*cols+k);
        *(data+j*cols+k)=dtemp;
        }
      }
                for (j=cols-1;j>=0;j--)
      {
                        *(data+i*cols+j) /= *(data+i*cols+i);
      }
    for (j=i+1;j<rows;j++)
      {
                        for (k=cols-1;k>=i;k--)
        *(data+j*cols+k)-=*(data+j*cols+i) * *(data+i*cols+k);
      }
                }
        for (i=rows-2;i>=0;i--)
                {
                for (j=cols-2;j>i;j--)
                        {
                        *(data+i*cols+cols-1)-= \
                        *(data+i*cols+j) * *(data+j*cols+cols-1);
                        *(data+i*cols+j)=0;
                        }
                }
  return 0;
}

int mid(m)
matrixptr m;
{
  int i,j;
  if (m->rows!=m->cols)
    {
    fprintf(stderr,"\nmid error - matrix must be square");
    return 1;
    }
  for (i=0;i<m->rows;i++)
    {
    for (j=0;j<m->cols;j++)
      *(m->block+i*m->cols+j)=0.0;
    *(m->block+i*m->cols+i)=1.0;
    }
  return 0;
}

void mzero(m)
matrixptr m;
{
  int i,j;
  for (i=0;i<m->rows;i++)
    for (j=0;j<m->cols;j++)
      *(m->block+i*m->cols+j)=0.0;
}
