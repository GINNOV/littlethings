#include "Matrix.h"
	
Pmatrix inverse(const Pmatrix& m)
	{
	Pmatrix a(m.rws);
	unsigned int i;
	for(i=0;i<m.rws;i++)
		{
		a.r[m.r[i]]=i;
		}
	return a;
	}
