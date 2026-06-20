#include "Matrix.h"
	
	
Pmatrix::Pmatrix(const Pmatrix& m)
	{
	unsigned int i;
	if(m.rows()==0)
		{
		rws=0;
		r=0;
		}
	else
		{
		rws=m.rws;
		r=new unsigned int[rws];
		if(r==0)error("out of store");
		for(i=0;i<rws;i++)
			{
			r[i]=m.r[i];
			}
		}
	}
