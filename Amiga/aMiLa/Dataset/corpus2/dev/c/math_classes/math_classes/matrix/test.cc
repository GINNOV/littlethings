#include <stdio.h>
#include <Matrix.h>


int main(int argc,char *argv[])
	{
	mtrxtype c[]={1.0,2.0,3.0,3.0,4.0,2.0,-2.0,1.0,3.0};
	mtrxtype d[]={0.0,2.0,1.0};
	Matrix A(3,3,c);
	Matrix b(3,1,d);
	LUmatrix q;
	Matrix x(3,1);
	Matrix y(3,1);
	q=LUdecompose(A);
	x=solve(A,b);
	y=LUsolve(q,b);
	print(A);
	printf("\n");
	
	print(b);
	printf("\n");	
	
	print(getl(q));
	printf("\n");	
	
	print(getu(q));
	printf("\n");
	
	print(getp(q));
	printf("\n");	
	
	print(x);
	printf("\n");
	
	print(y);
	printf("\n");
	return 0;
	
	
	}