#include "Matrix.h"
	
	
Matrix getl(const LUmatrix& m)
	{
	Matrix a(m.lu);
	unsigned int i,j;
	for(i=1;i<=a.rows();i++)
		{
		for(j=i+1;j<=a.cols();j++)
			{
			a(i,j)=0.0;
			}
		}
	for(i=1;i<=a.rows();i++)
		{
		a(i,i)=1.0;
		}
	return a;
	}
