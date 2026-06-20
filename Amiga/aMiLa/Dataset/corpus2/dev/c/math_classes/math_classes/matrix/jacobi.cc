
#include <iostream.h>
#include "Matrix.h"
#include <math.h>


double abs(double a);	// defined in matrix.cc


Matrix jacobi(Matrix a0)
	{
	Matrix a(a0);
	mtrxtype aii,aij,ajj;
	mtrxtype t,s,c,tau;
	mtrxtype r1,r2,temp;
	mtrxtype p;
	int i,j,k;
	int f,g;
	
	mtrxtype aik,ajk;
	
	if(a.rows() != a.cols()) 
		{
		cout << "Matrix must be square" << endl;
		exit(1);
		}
	
	temp=0;
	for(f=1;f<=a.rows();f++)
		{
		for(g=f+1;g<=a.cols();g++)
			{
			if(abs(a(f,g)) > temp)
				{
				temp=abs(a(f,g));
				i=f;
				j=g;
				}
			}
		}
		
		
	aii=a(i,i);
	ajj=a(j,j);
	aij=a(i,j);
	
	p=-(ajj-aii)/aij/2;
	
	r1=p+sqrt(p*p+1);
	r2=p-sqrt(p*p+1);
	
	if(abs(r1) < abs(r2))
		{
		t=r1;
		}
	else
		{
		t=r2;
		}
		
	c=1/sqrt(1+t*t);
	
	s=c*t;
	
	tau=s/(1+c);
	
	
	for(k=1;k<=a.rows();k++)
		{
		if(k!=i && k!=j)
			{
			aik=a(i,k)-s*(a(j,k)+tau*a(i,k));
			ajk=a(j,k)+s*(a(i,k)-tau*a(j,k));
			a(i,k)=aik;
			a(j,k)=ajk;
			a(k,j)=ajk;
			a(k,i)=aik;
			}
		}
		
	a(i,i)=aii-t*aij;
	a(j,j)=ajj+t*aij;
	a(i,j)=0;
	a(j,i)=0;
	
	
	return a;
	
	}
	
	
	
int main()
	{
	mtrxtype b[]={1,2,3,4,2,1,0,3,3,0,1,2,4,3,2,1};
	Matrix a(4,4,b);
	int i;	
	
	print(a);
	cout << endl;
	
	for(i=1;i<=8;i++)
		{
		a=jacobi(a);
		print(a);
		cout << endl;
		}
	return 0;
	}
	

			
			
			
			
	
	
	
	