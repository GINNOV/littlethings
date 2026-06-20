#include "Matrix.h"

Matrix::~Matrix()
	{
	if(vals!=0)
	delete[] vals;
	}
