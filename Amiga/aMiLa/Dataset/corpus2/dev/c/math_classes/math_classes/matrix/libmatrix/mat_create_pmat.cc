#include "Matrix.h"

Matrix::Matrix(const Pmatrix& p)
	{
	unsigned int i;
	r=p.rows();
	c=p.rows();
	vals=new mtrxtype [r*c];
	if(vals==0) error("out of mem");
	for(i=0;i<rows()*cols();i++)
		{
		vals[i]=0.0;
		}
	for(i=1;i<=rows();i++)
		{
		(*this)(i,p[i])=1.0;
		}
	}

