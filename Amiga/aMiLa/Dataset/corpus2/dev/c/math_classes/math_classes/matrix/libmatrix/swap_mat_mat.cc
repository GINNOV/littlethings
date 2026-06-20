#include "Matrix.h"


void swap(Matrix& m1,Matrix& m2)
	{
	unsigned int a,b;
	mtrxtype * c;
	a=m1.r;
	b=m1.c;
	c=m1.vals;
	m1.r=m2.r;
	m1.c=m2.c;
	m1.vals=m2.vals;
	m2.r=a;
	m2.c=b;
	m2.vals=c;
	}

