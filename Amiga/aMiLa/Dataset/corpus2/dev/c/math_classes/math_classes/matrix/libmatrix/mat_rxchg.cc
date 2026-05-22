#include "Matrix.h"


void Matrix::rowexchange(unsigned int r1,unsigned int r2)
	{
	unsigned int i;
	mtrxtype a;
	if(r1 > rows() || r1==0 || r2 > rows() || r2==0) error("bad subscript\n");
	for(i=1;i<=cols();i++)
		{
		a=(*this)(r1,i);
		(*this)(r1,i)=(*this)(r2,i);
		(*this)(r1,i)=a;
		}
	}
