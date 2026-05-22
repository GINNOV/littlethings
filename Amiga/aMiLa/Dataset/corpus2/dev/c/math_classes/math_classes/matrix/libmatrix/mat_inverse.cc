#include "Matrix.h"
	
	
Matrix inverse(const Matrix& a)
	{
	Matrix m(a.rows(),a.cols());
	LUmatrix b;
	if(a.rows()!=a.cols())
		{
		error("dimensions do not match");
		}
	b=LUdecompose(a);
	m=LUsolve(b,unity(a.rows()));
	return m;
	}
