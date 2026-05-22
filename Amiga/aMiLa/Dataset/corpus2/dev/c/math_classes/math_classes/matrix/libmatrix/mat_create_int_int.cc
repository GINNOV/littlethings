#include "Matrix.h"
	
Matrix::Matrix(unsigned int ro,unsigned int co)
	{
	if(ro==0 || co==0) error("bad size");
	r=ro;
	c=co;
	vals=new mtrxtype[ro*co];
	if(vals==0) error("out of mem");
	for(unsigned int i=0;i<ro*co;i++)
		{
		vals[i]=0.0;
		}
	}
