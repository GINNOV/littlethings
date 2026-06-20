#include "Matrix.h"
	
	
Pmatrix::~Pmatrix()
	{
	if (rws!=0)
		{
		delete [] r;
		}
	}
