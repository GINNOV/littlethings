#include "Matrix.h"
	

void Matrix::setunity(void)
	{
	if(rows()!=cols()) error("dimensions do not match");
	for(unsigned int i=1;i<=rows();i++)
		{
		for(unsigned int j=1;j<=cols();j++)
			{
			if(i==j)
				{
				(*this)(i,j)=1.0;
				}
			else
				{
				(*this)(i,j)=0.0;
				}
			}
		}
	}

