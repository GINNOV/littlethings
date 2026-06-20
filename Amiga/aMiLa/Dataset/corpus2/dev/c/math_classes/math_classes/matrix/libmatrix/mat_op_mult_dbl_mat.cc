#include "Matrix.h"
	

Matrix operator* (mtrxtype d,const Matrix& m)
	{
	Matrix a(m);
	unsigned int i,j;
	for(i=1;i<=m.rows();i++)
		{
		for(j=1;j<=m.cols();j++)
			{
			a(i,j)*=d;
			}
		}	
	return a;
	}
