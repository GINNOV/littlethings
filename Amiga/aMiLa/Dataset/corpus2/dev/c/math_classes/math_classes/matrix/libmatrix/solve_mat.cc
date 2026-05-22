#include "Matrix.h"


Matrix solve(const Matrix& a,const Matrix& b)
	{
	return LUsolve(LUdecompose(a),b);
	}