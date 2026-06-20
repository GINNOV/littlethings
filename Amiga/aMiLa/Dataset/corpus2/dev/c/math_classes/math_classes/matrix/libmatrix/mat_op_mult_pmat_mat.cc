#include "Matrix.h"


Matrix operator* (const Pmatrix& p,const Matrix& m)
	{
	Matrix a(m.rows(),m.cols());
	unsigned int i;
	if(m.rows()!=p.rows() || m.rows() !=m.cols()) error("dimensions do not match");
	for(i=1;i<=p.rows();i++)
		{
		a.setrow(i,m.getrow(p[i]));
		}
	return a;
	}
