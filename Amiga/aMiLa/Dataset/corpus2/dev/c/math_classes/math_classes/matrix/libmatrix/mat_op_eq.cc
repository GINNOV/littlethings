#include "Matrix.h"


int operator==(const Matrix& m1,const Matrix& m2)
	{
	if(m1.rows()!=m2.rows() || m1.cols()!=m2.cols()) return(0);
	for(unsigned int i=1;i<=m1.rows();i++)
		{
		for(unsigned int j=1;j<=m1.cols();j++)
			{
			if(m1(i,j)!=m2(i,j))
				{
				return(0);
				}
			}
		}
	return(1);
	}

