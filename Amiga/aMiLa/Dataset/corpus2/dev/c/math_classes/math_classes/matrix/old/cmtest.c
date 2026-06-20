#include <stdio.h>
#include <stdlib.h>
#include "cMatrix.h"

#define loops 4000
#define size 39
#define h 0.5
#define k 1.0
int main(int argc,char *argv[])
{
vptr u0,u1,v;
mtrxtype d,my;
mptr I,a,a2;
int i,j;
vptr b;

mptr t1,t2;

u0=create_vector(size);
u1=create_vector(size);
v=create_vector(size);
b=create_vector(size);
I=create_matrix(size,size);
a=create_matrix(size,size);
t1=create_matrix(size,size);
t2=create_matrix(size,size);



d=0.119;
my=d*h/k/k;
for(i=1;i<size;i++)
	{
	setelement(a,i,i,2.0);
	setelement(a,i+1,i,-1.0);
	setelement(a,i,i+1,-1.0);
	}
	
setelement(a,size,size,2.0);
*(b->v+size-1)=my*10.0;
for(i=1;i<=size;i++)
	{
	*(u1->v+i-1)=2.0;
	}
for(i=1;i<=size;i++)
	{
	setelement(I,i,i,1.0);
	}
/* a1=LUdecompose(I+(my/2)*a); */

t1=mulmat(a,my/2);
a2=sub_matrix(I,t1);
for(i=0;i<loops;i++)
	{
	for(j=0;j<size;j++)
	*(u0->v+i)=*(u1->v+i);
	v=mult_mtrx_vec(a2,u0);
	*(v->v+size-1) = 10.0*my;
	u1=solve(a2,v);
	
	printvector(u1);
	}
return(0);	
}

