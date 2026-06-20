#include "Matrix.h"

LUmatrix LUdecompose(const Matrix& m1)
	{
	LUmatrix m;
	unsigned int maxr;
	mtrxtype maxv;
	unsigned int i,j,k,i2;
	unsigned int t2;
	mtrxtype t1,t3;
	if(m1.cols()!=m1.rows()) 
		{
		error("dimensions do not match");
		}
	m.lu=m1;
	m.p=Pmatrix(m1.rows());
	for(k=1;k<m.lu.rows();k++)
		{
		maxr=k;
		maxv=m.lu(k,k);
		for(i2=k+1;i2<=m.lu.rows();i2++)
			{
			t3=m.lu(i2,k);
			if (abs(t3)>abs(maxv))
				{
				maxr=i2;
				maxv=t3;
				}
			}
		if (maxr!=k)
			{
			m.lu.rowexchange(k,maxr);
			t2=m.p[k];
			m.p[k]=m.p[maxr];
			m.p[maxr]=t2;
			}
		for(j=k+1;j<=m.lu.rows();j++)
			{
			t1=m.lu(j,k)/m.lu(k,k);
			for(i=k+1;i<=m.lu.cols();i++)
				{
				t3=m.lu(j,i)-t1*m.lu(k,i);
				m.lu(j,i)=t3;
				}
			}
		}
	for(i=1;i<=m1.rows();i++)
		{
		m.lu.setrow(i,m1.getrow(m.p[i]));
		}
	for(k=1;k<m.lu.rows();k++)
		{
		for(j=k+1;j<=m.lu.rows();j++)
			{
			t1=m.lu(j,k)/m.lu(k,k);
			for(i=k+1;i<=m.lu.cols();i++)
				{
				t3=m.lu(j,i)-t1*m.lu(k,i);
				m.lu(j,i)=t3;
				}
			m.lu(j,k)=t1;
			}
		}
	return m;
	}
