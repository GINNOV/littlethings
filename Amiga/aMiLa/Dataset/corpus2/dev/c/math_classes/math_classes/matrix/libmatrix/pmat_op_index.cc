#include "Matrix.h"
	
mtrxtype Pmatrix::operator()(unsigned int i,unsigned int j) const
	{
#ifdef CHECKRANGE
	if(i>rows() || i==0 || j>rows() || j==0)error("bad subscript");
#endif	
	if(j==(*this)[i])
		return 1.0;
	else
		return 0.0;
	}
