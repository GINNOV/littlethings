#include "Matrix.h"


Pmatrix transpose(const Pmatrix& m)
	{
	Pmatrix a(m.rws);
	unsigned int i;
	for(i=0;i<m.rws;i++)
		{
		a.r[m.r[i]]=i;
		}
	return a;
	}
