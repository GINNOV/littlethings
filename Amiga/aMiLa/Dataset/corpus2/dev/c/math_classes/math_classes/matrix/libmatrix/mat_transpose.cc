#include "Matrix.h"


Matrix transpose(const Matrix& m)
	{
	Matrix a(m.cols(),m.rows());
	unsigned int i,j;
	if(m.cols() ==0 || m.rows()==0)error("bad size");
	for (i=1;i<=m.rows();i++)
		{
		for(j=1;j<=m.cols();j++)
			{
			a(j,i)=m(i,j);
			}
		}
	return a;
	}
