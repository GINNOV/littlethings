#include "Matrix.h"


	
void Matrix::setrow(unsigned int ro,Matrix v)
	{
	if(v.rows()!=1) error("Row vector required");
	for(unsigned int i=1;i<=cols();i++)
		{
		(*this)(ro,i)=v(1,i);
		}
	}
