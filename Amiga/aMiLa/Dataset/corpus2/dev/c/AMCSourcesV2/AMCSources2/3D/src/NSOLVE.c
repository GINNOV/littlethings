/* Solves equations in n unknowns */
/* Written by Nigel Salt */

#include <stdio.h>
double d[4][5]=
{
  6,1,6,6,50,
  1,6,6,0,31,
  0,3,2,1,16,
  8,6,1,9,59
};
double *pd=&d[0][0];

int nsolve(int rows,double *data);

main()
{
  int i,j;
  nsolve(4,pd);
  for (i=0;i<4;i++)
    {
		printf("\n%6.2lf%6.2lf%6.2lf%6.2lf%6.2lf",\
      d[i][0],d[i][1],d[i][2],d[i][3],d[i][4]);

    }


}
int nsolve(rows,data)
int rows;
double *data;
{
  int i,j,k;
  int cols;
  cols=rows+1;
  for (i=0;i<rows;i++)
    {
    if (*(data+i*cols+i)==0.0)
      {
      fprintf(stderr,"\nnsolve error - singular matrix");
      return 1;
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

