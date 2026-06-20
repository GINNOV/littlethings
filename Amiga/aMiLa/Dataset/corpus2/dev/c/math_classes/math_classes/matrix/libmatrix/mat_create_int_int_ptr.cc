#include "Matrix.h"

Matrix::Matrix(unsigned int ro,unsigned int co,mtrxtype *m)
	{
	unsigned int p=0;
	unsigned int i,j;
	if(ro==0 || co ==0) error("bad size");
	r=ro;
	c=co;
	vals=new mtrxtype[ro*co];
	if(vals==0) error("Out of mem");
	for(i=1;i<=rows();i++)
		{
		for(j=1;j<=cols();j++)
			{
			(*this)(i,j)=m[p++];
			}
		}
	}
