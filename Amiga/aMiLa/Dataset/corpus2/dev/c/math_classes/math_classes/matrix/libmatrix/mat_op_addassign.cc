#include "Matrix.h"


Matrix& Matrix::operator+=(const Matrix& m)
	{
	if(rows()!=m.rows() || cols()!=m.cols())error("dimensions do not match");
	for(unsigned int i=0;i<=rows();i++)
		{
		for(unsigned int j=0;j<=cols();j++)
			{
			(*this)(i,j)+=m(i,j);
			}
		}
	return *this;
	}
