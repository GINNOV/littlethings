#include "Matrix.h"


Matrix Matrix::getrow (unsigned int ro) const
	{
	Matrix v(1,cols());
	for(unsigned int i=1;i<=cols();i++)
		{
		v(1,i)=(*this)(ro,i);
		}
	return v;
	}
