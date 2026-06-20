#include "Matrix.h"

Matrix::Matrix(const Matrix& m)
	{
	r=m.rows();
	c=m.cols();
	vals=new mtrxtype[r*c];
	if(vals==0) error("out of mem");
	for(unsigned int i=1;i<=rows();i++)
		{
		for(unsigned int j=1;j<=cols();j++)
			{
			(*this)(i,j)=m(i,j);
			}
		}
	}
