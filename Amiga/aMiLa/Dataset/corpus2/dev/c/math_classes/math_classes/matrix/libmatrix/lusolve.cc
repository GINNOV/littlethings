#include "Matrix.h"

Matrix LUsolve(const LUmatrix& m1,const Matrix& b)
	{
	Matrix x(b.rows(),b.cols());
	unsigned int i,j,k;
	mtrxtype t1;
	mtrxtype t2;
	Matrix v(b.rows(),b.cols());
	Matrix y(b.rows(),b.cols());
	Matrix m(m1.lu.rows(),m1.lu.cols());
	if(m.rows()!=b.rows() || m.cols()!=m.rows()) 
		{
		error("dimensions do not match");
		}
	for(k=1;k<=b.cols();k++)	
		{
		for(i=1;i<=b.rows();i++)
			{
			v(i,k)=b(m1.p[i],k);
			}
		m=getl(m1);
		for(j=1;j<=m.rows();j++)
			{
			t1=0.0;
			for(i=1;i<j;i++)
				{
				t1+=m(j,i)*y(i,k);
				}
			t2=(v(j,k)-t1)/m(j,j);
			y(j,k)=t2;
			}
		m=getu(m1);
		for(j=m.rows();j>=1;j--)
			{
			t1=0.0;
			for(i=m.cols();i>j;i--)
				{
				t1+=m(j,i)*x(i,k);
				}
			t2=(y(j,k)-t1)/m(j,j);
			x(j,k)=t2;
			}
		}
	return x;
	}
