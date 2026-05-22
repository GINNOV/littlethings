#include "Matrix.h"


Matrix& Matrix::operator= (const Matrix& m)
	{
	if(rows()==0)
		{
		r=m.rows();
		c=m.cols();
		vals=new mtrxtype[rows()*cols()];
		if(vals==0) error("out of mem");
		for(unsigned int i=1;i<=rows();i++)
			{
			for(unsigned int j=1;j<=cols();j++)
				{
				(*this)(i,j)=m(i,j);
				}
			}
		return *this;
		}
	else
		{
		if(rows()!=m.rows() || cols()!=m.cols())error("dimensions do not match");
		for(unsigned int i=1;i<=rows();i++)
			{
			for(unsigned int j=1;j<=cols();j++)
				{
				(*this)(i,j)=m(i,j);
				}
			}
		return *this;
		}
	}	
