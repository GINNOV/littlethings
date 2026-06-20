

#include <iostream.h>
#include <iomanip.h>
#include <stdlib.h>
#include "vector.h"


void error(char *s)
	{
	cerr << s;
	cerr <<"\n";
	exit(1);
	} 


Vector::Vector()
	{
	l=0;
	s=1;
	vals=NULL;
	}


Vector::Vector(int lg)
	{
	if(lg<1)error("bad size");
	l=lg;
	s=1;
	vals=new double[lg];
	if(vals==0)error("out of mem");
	for(int i=0;i<lg;i++)vals[i]=0.0;
	}
	
Vector::Vector(int lg,int os)
	{
	Vector(lg);
	s=os;
	}

Vector::Vector(const Vector& v)
	{
	if(v.l<1)error("bad size");
	l=v.l;
	s=1;
	vals=new double[v.l];
	if(vals==0)error("out of mem");
	for(int i=0;i<v.l;i++)
		{
		vals[i]=v.vals[i];
		}
	}
	
Vector::Vector(const Vector& v,int os)
	{
	Vector(v);
	s=os;
	}
	
Vector::Vector(int lg,double *v)
	{
	l=lg;
	s=1;
	vals=new double[l];
	for(int i=0;i<l;i++)vals[i]=v[i];
	}
	
Vector::Vector(int lg,double *v,int os)
	{
	Vector(lg,v);
	s=os;
	}


Vector::~Vector()
	{
	if(l!=0)
	delete[] vals;
	}


int operator!=(const Vector& v1,const Vector& v2)
	{
	if(v1.size()!=v2.size()) return(1);
	for(int i=1;i<=v1.size();i++)
		{
		if(v1.elem(i)!=v2.elem(i))
			{
			return(1);
			}
		}
	return(0);
	}


int operator==(const Vector& v1,const Vector& v2)
	{
	if(v1.size()!=v2.size()) return(0);
	for(int i=1;i<=v1.size();i++)
		{
		if(v1.elem(i)!=v2.elem(i))
			{
			return(0);
			}
		}
	return(1);
	}


Vector operator+ (const Vector& v1,const Vector& v2)
	{
	Vector v(v1.size());
	if(v1.size()!=v2.size())error("dimensions do not match");
	for(int i=1;i<=v.size();i++)
		{
		v.selem(i,v1.elem(i)+v2.elem(i));
		}
	return v;
	}


double operator* (const Vector& v1,const Vector& v2)
	{
	double t;
	if(v1.size()!=v2.size())error("dimensions do not match");
	t=0.0;
	for(int i=1;i<=v1.size();i++)
		{
		t+=v1.elem(i)*v2.elem(i);
		}
	return t;
	}


Vector operator* (const Vector& v1,const double d)
	{
	Vector  v(v1.size());
	for(int i=1;i<v.size();i++)
		{
		v.selem(i,v1.elem(i)*d);
		}
	return v;
	}


Vector operator* (const double d,const Vector& v1)
	{
	Vector  v(v1.size());
	for(int i=1;i<=v.size();i++)
		{
		v.selem(i,v1.elem(i)*d);
		}
	return v;
	}


Vector& Vector::operator+=(const Vector& v1)
	{
	if(l!=v1.size())error("dimensions do not match");
	for(int i=0;i<l;i++)
		{
		vals[i]+=v1.vals[i];
		}
	return *this;
	}


Vector& Vector::operator*=(double a)
	{
	for(int i=0;i<size();i++)
		{
		vals[i]*=a;
		}
	return *this;
	}


Vector& Vector::operator-=(const Vector& v1)
	{
	if(l!=v1.l)error("dimensions do not match");
	for(int i=0;i<l;i++)
		{
		vals[i]-=v1.vals[i];
		}
	return *this;
	}


Vector& Vector::operator= (const Vector& v1)
	{
	int i;
	if(v1.l==0)
		{
		if(l!=0)delete[] vals;
		return *this;
		}
	if(l!=v1.l)
		{
		if(l!=0) 
			{
			delete[] vals;
			}
		vals=new double[l=v1.l];
		}
	for(i=0;i<l;i++)
		{
		vals[i]=v1.vals[i];
		}
	return *this;
	}
	
	
void swap(Vector& v1,Vector& v2)
	{
	int a;
	double * b;
	a=v1.l;
	v1.l=v2.l;
	v2.l=a;
	b=v1.vals;
	v1.vals=v2.vals;
	v2.vals=b;
	}


void print(const Vector& v,int mode)
	{
	int i;
	if(mode==0)   //row vector
		{
		for(i=1;i<=v.size();i++)
			{
			cout.setf(ios::left);
			cout.setf(ios::adjustfield);
			cout.setf(ios::fixed);
			cout <<setw(8) <<setprecision(4) <<v.elem(i);
			}
		cout << "\n";
		}
	else if(mode==1) //column vector
		{
		for(i=1;i<=v.size();i++)
			{
			cout.setf(ios::left);
			cout.setf(ios::adjustfield);
			cout.setf(ios::fixed);
			cout << setw(8)<<setprecision(4) << v[i] << "\n";
			}
		}
	else
		{
		error("bad mode");
		}
	}

