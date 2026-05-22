#include "Matrix.h"


Pmatrix operator* (const Pmatrix& p1,const Pmatrix& p2)
	{
	Pmatrix a(p1.rws);
	unsigned int i;
	if(p1.rws!=p2.rws)error("dimensions do not match");
	for(i=0;i<p1.rws;i++)
		{
		a.r[i]=p2.r[p1.r[i]];
		}
	return a;
	}
