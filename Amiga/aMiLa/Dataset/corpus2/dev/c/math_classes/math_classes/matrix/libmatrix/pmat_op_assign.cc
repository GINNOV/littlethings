#include "Matrix.h"


Pmatrix& Pmatrix::operator= (const Pmatrix& m)
	{
	unsigned int i;
	if(rws!=0) 
		{
		delete[] r;
		}
	r=new unsigned int[rws=m.rws];
	for(i=0;i<rws;i++)
		{
		r[i]=m.r[i];
		}
	return *this;
	}
	
