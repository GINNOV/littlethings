#include "Matrix.h"

Matrix unity(unsigned int n)
	{
	Matrix a(n,n);
	if(n==0)error("bad size");
	for(unsigned int i=1;i<=n;i++)
		{
		a(i,i)=1.0;
		}
	return a;
	}
