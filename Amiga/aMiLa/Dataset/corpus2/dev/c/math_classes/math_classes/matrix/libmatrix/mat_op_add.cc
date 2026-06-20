#include "Matrix.h"


Matrix operator+ (const Matrix& m1,const Matrix& m2)
	{
	Matrix m(m1.rows(),m1.cols());
	if(m1.rows()!=m2.rows() || m1.cols()!=m2.cols())
		{
		error("dimensions do not match");
		}
	for(unsigned int i=1;i<=m.rows();i++)
		{
		for(unsigned int j=1;j<=m.cols();j++)
			{
			m(i,j)=m1(i,j)+m2(i,j);
			}
		}
	return m;
	}	
