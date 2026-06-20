#include "Matrix.h"

LUmatrix& LUmatrix::operator= (const LUmatrix& m)
	{
	lu=m.lu;
	p=m.p;
	return *this;
	}
