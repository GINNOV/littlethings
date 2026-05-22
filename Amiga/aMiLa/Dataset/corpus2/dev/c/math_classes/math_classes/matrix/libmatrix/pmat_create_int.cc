#include "Matrix.h"


Pmatrix::Pmatrix(unsigned int s)
	{
	unsigned int i;
	if(s<1)error("bad size");
	rws=s;
	r=new unsigned int[s];
	if(r==0)error("out of mem");
	for (i=0;i<s;i++)
		{
		r[i]=i+1;
		}
	}
