#include "Matrix.h"
	

unsigned int& Pmatrix::operator[](unsigned int i) const
	{
#ifdef CHECKRANGE
	if(i>rws || i<1)error("bad subscript");
#endif
	return r[i-1];
	}
