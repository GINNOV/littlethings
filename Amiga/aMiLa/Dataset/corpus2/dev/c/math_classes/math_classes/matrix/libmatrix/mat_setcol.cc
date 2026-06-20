#include "Matrix.h"


void Matrix::setcol(unsigned int co,Matrix v)
	{
	if(v.cols()!=1) error("Column vector required");
	for(unsigned int i=1;i<=rows();i++)
		{
		(*this)(i,co)=v(i,1);
		}
	}
