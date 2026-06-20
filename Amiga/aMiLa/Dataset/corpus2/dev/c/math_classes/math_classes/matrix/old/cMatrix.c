#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cMatrix.h"



mptr create_matrix(unsigned int x,unsigned int y)
	{
	unsigned int i;
	mptr a;
	mtrxtype *b;
	a=(mptr)malloc(sizeof(mtrx));
	if(a==NULL) return(NULL);
	b=(mtrxtype *)malloc(x*y*sizeof(mtrxtype));
	if(b==NULL)
		{
		free(a);
		return NULL;
		}
	for(i=0;i<x*y;i++)
		{
		b[i]=0.0;
		}
	a->m=b;
	a->x=x;
	a->y=y;
	return(a);
	}


void delete_matrix(mptr a)
	{
	if(a)
		{
		free(a->m);
		free(a);
		}
	}


void delete_vector(vptr a)
	{
	if(a)
		{
		free(a->v);
		free(a);
		}
	}


int copy_matrix(mptr s,mptr d)
	{
	if( s==NULL || d==NULL ) return 0;
	if ((s->x!=d->x) || (s->y!=d->y))
		{
		return(0);
		}
	memcpy(d->m,s->m,s->x*s->y*sizeof(mtrxtype));
	return(1);
	}


mptr duplicate_matrix(mptr s)
	{
	mptr d;
	if(s==NULL) return NULL;
	d=create_matrix(s->x,s->y);
	if(d==NULL)return(NULL);
	copy_matrix(s,d);
	return(d);
	}


void setelement(mptr d,unsigned int x,unsigned int y,mtrxtype s)
	{
	unsigned int t;
	if((x > d->x)||(y > d->y)) return;
	t=d->x*(y-1)+x-1;
	*(d->m+t)=s;
	}


mtrxtype getelement(mptr s,unsigned int x,unsigned int y)
	{
	unsigned int t;
	if((x>s->x)||(y>s->y)) return 0; /* All returnvalues are valid :-( */
	t=s->x*(y-1)+x-1;
	return(*(s->m+t));
	}


mptr add_matrix(mptr m1,mptr m2)
	{
	mptr a;
	unsigned int i;
	if(m1->x != m2->x || m1->y != m2->y) return NULL;
	a=create_matrix(m1->x,m2->y);
	if(a==NULL) return(NULL);
	for(i=0;i<m1->x*m1->y;i++)
		{
		a->m[i]=m1->m[i]+m2->m[i];
		}
	return(a);
	}


mptr sub_matrix(mptr m1,mptr m2)
	{
	mptr a;
	unsigned int i;
	if(m1->x != m2->x || m1->y != m2->y) return NULL;
	a=create_matrix(m1->x,m2->y);
	if(a==NULL) return(NULL);
	for(i=0;i<m1->x*m1->y;i++)
		{
		a->m[i]=m1->m[i]-m2->m[i];
		}
	return(a);
	}


mptr matrix_mult(mptr m1,mptr m2)
	{
	mptr a;
	unsigned int i,j,k;
	mtrxtype t;
	if(m1->y != m2->x) return(NULL);
	a=create_matrix(m1->x,m2->y);
	if(a==NULL) return(NULL);
	for(i=1;i<=m1->y;i++)
		{
		for(j=1;j<=m1->x;j++)
			{
			t=0.0;
			for(k=1;k<=m1->y;k++)
				{
				t+=getelement(m1,i,k)*getelement(m2,k,j);
				}
			setelement(a,i,j,t);
			}
		}
	return(a);
	}


mptr mulmat(mptr s,mtrxtype d)
	{
	unsigned int i;
	mptr a;
	a=create_matrix(s->x,s->y);
	if(a==NULL) return(NULL);
	for(i=0;i<s->x*s->y;i++)
		{
		a->m[i]=s->m[i]*d;
		}
	return(a);
	}


mptr matrix_transpose(mptr s)
	{
	mptr a;
	unsigned int i,j;
	a=create_matrix(s->y,s->x);
	if(a==NULL)return(NULL);
	for (i=1;i<=s->x;i++)
		{
		for(j=1;j<=s->y;j++)
			{
			setelement(a,j,i,getelement(s,i,j));
			}
		}
	return(a);
	}


vptr solve(mptr m1,vptr v)
	{
	unsigned int maxr;
	mtrxtype maxv;
	mptr m;
	vptr x;
	unsigned int i,j,k,i2;
	mtrxtype t1,t3;
	vectype t2;
	if(m1->y!=v->l || m1->x!=m1->y) return(NULL);
	m=duplicate_matrix(m1);
	if(m==NULL)return(NULL);
	x=create_vector(v->l);
	if(x==NULL)return(NULL);
	for(k=1;k<m->y;k++)
		{
		maxr=k;
		maxv=getelement(m,k,k);
		for(i2=k;i2<=m->y;i2++)
			{
			t3=getelement(m,k,i2);
			if (t3>maxv)
				{
				maxr=i2;
				maxv=t3;
				}
			}
		if (maxr!=k)
			{
			rowexchange(m,k,maxr);
			t2=v->v[k-1];
			v->v[k-1]=v->v[maxr-1];
			v->v[maxr-1]=t2;
			}
		for(j=k+1;j<=m->y;j++)
			{
			t1=getelement(m,k,j)/getelement(m,k,k);
			for(i=k;i<=m->x;i++)
				{
				t3=getelement(m,i,j)-t1*getelement(m,i,k);
				setelement(m,i,j,t3);
				}
			t2=v->v[j-1]-t1*v->v[k-1];
			v->v[j-1]=t2;
			}
		}
	for(j=m->y;j>=1;j--)
		{
		t1=0.0;
		for(i=m->x;i>j;i--)
			{
			t1+=getelement(m,i,j)*x->v[i-1];
			}
		t2=(v->v[j-1]-t1)/getelement(m,j,j);
		x->v[j-1]=t2;
		}
	delete_matrix(m);
	return(x);
	}


int rowexchange(mptr m,unsigned int r1,unsigned int r2)
	{
	mtrxtype t;
	unsigned int i;
	if(r1>m->y || r2>m->y)return(0);
	for(i=1;i<=m->x;i++)
		{
		t=getelement(m,i,r1);
		setelement(m,i,r1,getelement(m,i,r2));
		setelement(m,i,r2,t);
		}
	return(1);
	}


void printmatrix(mptr a)
	{
	unsigned int i,j;
	mtrxtype *b;
	b=a->m;
	for (j=0;j<a->y;j++)
		{
		for(i=0;i<a->x;i++)
			{
			printf("%f ",*(b+a->x*j+i));
			}
		printf("\n");
		}
	}


void printvector(vptr a)
	{
	unsigned int i;
	vectype *b;
	b=a->v;
	for (i=0;i<a->l;i++)
		{
		printf("%f\n",b[i]);
		}
	}


vptr create_vector(unsigned int l)
	{
	unsigned int i;
	vptr a;
	vectype *b;
	a=(vptr)malloc(sizeof(vec));
	if(a==NULL) return(NULL);
	b=(vectype *)malloc(l*sizeof(vectype));
	if(b==NULL) return(NULL);
	for(i=0;i<l;i++)
		{
		b[i]=0.0;
		}
	a->v=b;
	a->l=l;
	return(a);
	}


mptr vec2row_mtrx(vptr v)
	{
	mptr a;
	unsigned int i;
	a=create_matrix(v->l,1);
	if(a==NULL)return(NULL);
	for(i=0;i<v->l;i++)
		{
		a->m[i]=v->v[i];
		}
	return(a);
	}


mptr vec2col_mtrx(vptr v)
	{
	mptr a;
	unsigned int i;
	a=create_matrix(1,v->l);
	if(a==NULL)return(NULL);
	for(i=0;i<v->l;i++)
	{
	a->m[i]=v->v[i];
	}
	return(a);
	}


vptr row2vec(mptr s,unsigned int r)
	{
	vptr a;
	unsigned int i;
	if(r<1 || r>s->y)return(NULL);
	a=create_vector(s->x);
	if(a==NULL)return(NULL);
	for(i=1;i<=s->x;i++)
		{
		a->v[i]=getelement(s,i,r);
		}
	return(a);
	}


vptr col2vec(mptr s,unsigned int c)
	{
	vptr a;
	unsigned int i;
	if(c<1 || c>s->x)return(NULL);
	a=create_vector(s->y);
	if(a==NULL)return(NULL);
	for(i=1;i<=s->y;i++)
		{
		a->v[i]=getelement(s,c,i);
		}
	return(a);
	}


mtrxtype determinant(mptr m1)
	{
	unsigned int k,i2,i,j;
	unsigned int c;
	unsigned int maxr;
	mtrxtype maxv;
	mptr m;
	mtrxtype t1,t2,t3;
	if(m1->x!=m1->y)return(0.0);
	m=duplicate_matrix(m1);
	if(m==NULL)return(0.0);
	c=1;
	for(k=1;k<m->y;k++)
		{
		maxr=k;
		maxv=getelement(m,k,k);
		for(i2=k;i2<=m->y;i2++)
			{
			t3=getelement(m,k,i2);
			if (t3>maxv)
				{
				maxr=i2;
				maxv=t3;
				}
			}
		if (maxr!=k)
			{
			rowexchange(m,k,maxr);
			c*=-1;
			}
		for(j=k+1;j<=m->y;j++)
			{
			t1=getelement(m,k,j)/getelement(m,k,k);
			for(i=k;i<=m->x;i++)
				{
				t2=getelement(m,i,j)-t1*getelement(m,i,k);
				setelement(m,i,j,t2);
				}
			}
		}
	t1=1.0;
	for(i=1;i<=m->x;i++)
		{
		t1*=getelement(m,i,i);
		}
	delete_matrix(m);
	return(t1*c);
	}


void setrow(mptr d,vptr s,unsigned int r)
	{
	unsigned int i;
	if(d->x!=s->l || r>d->y)return;
	for(i=1;i<=d->x;i++)
		{
		setelement(d,i,r,s->v[i-1]);
		}
	}


void setcol(mptr d,vptr s,unsigned int c)
	{
	unsigned int i;
	if(d->y!=s->l || c>d->x)return;
	for(i=1;i<=d->y;i++)
		{
		setelement(d,c,i,s->v[i-1]);
		}
	}


mptr inverse(mptr a)
	{
	unsigned int i,j;
	mptr m;
	vptr v,x;
	if(a->x!=a->y)return(NULL);
	m=create_matrix(a->x,a->y);
	if(m==NULL)return(NULL);
	v=create_vector(m->y);
	if(v==NULL){delete_matrix(m);return(NULL);}
	for(i=1;i<=m->y;i++)
		{
		for(j=0;j<v->l;j++)
			{
			v->v[j]=0.0;
			}
		v->v[i-1]=1.0;
		x=solve(a,v);
		if(x==NULL)
			{
			delete_matrix(m);
			delete_vector(v);
			return(NULL);
			}
		setcol(m,x,i);
		delete_vector(x);
		}
	delete_vector(v);
	return(m);
	}


vectype dot_mult(vptr a,vptr b)
	{
	unsigned int i;
	vectype t=0.0;
	if(a->l!=b->l)return(0.0);
	for(i=0;i<a->l;i++)
		{
		t+=a->v[i]*b->v[i];
		}
	return(t);
	}


vptr mult_mtrx_vec(mptr a,vptr b)
	{
	mptr c,d;
	vptr v;
	c=vec2col_mtrx(b);
	d=matrix_mult(a,c);
	delete_matrix(c);
	v=col2vec(d,1);
	delete_matrix(d);
	return(v);
	}


