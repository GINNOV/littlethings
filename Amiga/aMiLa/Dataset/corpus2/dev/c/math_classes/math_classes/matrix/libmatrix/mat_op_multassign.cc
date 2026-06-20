#include "Matrix.h"

Matrix& Matrix::operator*=(mtrxtype a)
	{
	for(unsigned int i=1;i<=rows();i++)
		{
		for(unsigned int j=1;j<=rows();j++)
			{
			(*this)(i,j)*=a;
			}
		}
	return *this;
	}
