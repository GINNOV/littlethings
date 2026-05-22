#include "Matrix.h"

#define loops 40000
#define size 9
#define h 2.0
#define k 10.0

int main(int argc,char *argv[])
{
Matrix u0(size,1);
Matrix u1(size,1);
Matrix v(size,1);
mtrxtype d;
mtrxtype my;
Matrix I(size,size);
Matrix a(size,size);
LUmatrix a1;
Matrix a2(size,size);
int i;
Matrix b(size,1);
d=0.119;
my=d*h/k/k;
for(i=1;i<size;i++)
	{
	a(i,i)=2.0;
	a(i+1,i)=-1.0;
	a(i,i+1)=-1.0;
	}
a(size,size)=2.0;
b(1,1)=my*0.0;
b(size,1)=my*10.0;
for(i=1;i<=size;i++)
	{
	u1(i,1)=2.0;
	}
I.setunity();
a1=LUdecompose(I+(my/2)*a);
a2=I-(my/2)*a;
for(i=0;i<loops;i++)
	{
	u0=u1;
	v=a2*u0+b;
	u1=solve(a1,v);
	print(transpose(u1));
	}
return(0);	
}

