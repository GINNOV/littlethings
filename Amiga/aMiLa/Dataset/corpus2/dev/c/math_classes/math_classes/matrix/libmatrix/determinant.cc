#include "Matrix.h"


mtrxtype determinant(const Matrix& m1)
	{
	unsigned int k,i2,i,j;
	unsigned int c;
	unsigned int maxr;
	mtrxtype maxv;
	Matrix m(m1);
	mtrxtype t1,t2,t3;
	if(m1.rows()!=m1.cols())error("dimensions do not match");
	c=1;
	for(k=1;k<m.rows();k++)
		{
		maxr=k;
		maxv=m(k,k);
		for(i2=k;i2<=m.rows();i2++)
			{
			t3=m(k,i2);
			if (abs(t3)>abs(maxv))
				{
				maxr=i2;
				maxv=t3;
				}
			}
		if (maxr!=k)
			{
			m.rowexchange(k,maxr);
			c*=-1;
			}
		for(j=k+1;j<=m.rows();j++)
			{
			t1=m(j,k)/m(k,k);
			for(i=k;i<=m.cols();i++)
				{
				t2=m(j,i)-t1*m(k,i);
				m(j,i)=t2;
				}
			}
		}
	t1=1.0;
	for(i=1;i<=m.cols();i++)
		{
		t1*=m(i,i);
		}
	return(t1*c);
	}
