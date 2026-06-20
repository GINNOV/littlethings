#include "Matrix.h"


Matrix solve(const LUmatrix& m1,const Matrix& b)
	{
	return LUsolve(m1,b);
	}
