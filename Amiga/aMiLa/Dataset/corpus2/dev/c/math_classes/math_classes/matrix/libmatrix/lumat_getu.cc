#include "Matrix.h"
	
	
Matrix getu(const LUmatrix& m)
	{
	Matrix a(m.lu);
	unsigned int i,j;
	for(i=2;i<=a.rows();i++)
		{
		for(j=1;j<i;j++)
			{
			a(i,j)=0.0;
			}
		}
	return a;
	}
