#include "Matrix.h"


Matrix Matrix::getcol (unsigned int co) const
	{
	Matrix v(rows(),1);
	for(unsigned int i=1;i<=rows();i++)
		{
		v(i,1)=(*this)(i,co);
		}
	return v;
	}
