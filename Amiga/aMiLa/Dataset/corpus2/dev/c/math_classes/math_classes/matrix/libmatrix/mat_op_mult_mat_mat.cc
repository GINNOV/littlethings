#include "Matrix.h"

Matrix operator* (const Matrix& m1,const Matrix& m2)
	{
	Matrix a(m1.rows(),m2.cols());
	unsigned int i,j,k;
	mtrxtype t;
	if(m1.cols() != m2.rows()) 
		{
		error("dimensions do not match");
		}
	for(i=1;i<=m1.rows();i++)
		{
		for(j=1;j<=m2.cols();j++)
			{
			t=0.0;
			for(k=1;k<=m2.rows();k++)
				{
				t+=m1(i,k)*m2(k,j);
				}
			a(i,j)=t;
			}
		}
	return a;
	}
