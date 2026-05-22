#include "Matrix.h"


Matrix operator* (const Matrix& m,mtrxtype d)
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
