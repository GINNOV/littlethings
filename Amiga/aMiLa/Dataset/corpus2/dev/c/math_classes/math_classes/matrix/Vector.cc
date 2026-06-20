

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
	len=0;
	vals=NULL;
	}


Vector::Vector(int lg)
	{
	if(lg<1)error("bad size");
	len=lg;
	vals=new vectype[lg];
	if(vals==0)error("out of mem");
	for(int i=0;i<lg;i++)vals[i]=0.0;
	}
	
Vector::Vector(const Vector& v)
	{
	if(v.len<1)error("bad size");
	len=v.len;
	vals=new vectype[v.len];
	if(vals==0)error("out of mem");
	for(int i=0;i<v.len;i++)
		{
		vals[i]=v.vals[i];
		}
	}
	
Vector::Vector(int lg,vectype *v)
	{
	len=lg;
	vals=new vectype[lg];
	if(vals==0)error("out of mem");
	for(int i=0;i<len;i++)vals[i]=v[i];
	}
	

Vector::~Vector()
	{
	if(vals!=0)
	delete[] vals;
	}


int operator!=(const Vector& v1,const Vector& v2)
	{
	if(v1.size()!=v2.size()) return(1);
	for(int i=1;i<=v1.size();i++)
		{
		if(v1(i)!=v2(i))
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
		if(v1(i)!=v2(i))
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
		v(i)=v1(i)+v2(i);
		}
	return v;
	}


vectype operator* (const Vector& v1,const Vector& v2)
	{
	vectype t;
	if(v1.size()!=v2.size())error("dimensions do not match");
	t=0.0;
	for(int i=1;i<=v1.size();i++)
		{
		t+=v1(i)*v2(i);
		}
	return t;
	}


Vector operator* (const Vector& v1,const vectype d)
	{
	Vector  v(v1.size());
	for(int i=1;i<v.size();i++)
		{
		v(i)=v1(i)*d;
		}
	return v;
	}


Vector operator* (const vectype d,const Vector& v1)
	{
	Vector  v(v1.size());
	for(int i=1;i<=v.size();i++)
		{
		v(i)=v1(i)*d;
		}
	return v;
	}


Vector& Vector::operator+=(const Vector& v1)
	{
	if(size()!=v1.size())error("dimensions do not match");
	for(int i=1;i<=size();i++)
		{
		(*this)(i)+=v1(i);
		}
	return *this;
	}


Vector& Vector::operator*=(vectype a)
	{
	for(int i=1;i<=size();i++)
		{
		(*this)(i)*=a;
		}
	return *this;
	}


Vector& Vector::operator-=(const Vector& v1)
	{
	if(size()!=v1.size())error("dimensions do not match");
	for(int i=1;i<=size();i++)
		{
		(*this)(i)-=v1(i);
		}
	return *this;
	}


Vector& Vector::operator= (const Vector& v1)
	{
	int i;
	if(v1.size()==0)
		{
		if(size()!=0)delete[] vals;
		return *this;
		}
	if(size()!=v1.size())
		{
		if(size()!=0) 
			{
			delete[] vals;
			}
		vals=new vectype[len=v1.size()];
		}
	for(i=0;i<len;i++)
		{
		vals[i]=v1.vals[i];
		}
	return *this;
	}
	
	
void swap(Vector& v1,Vector& v2)
	{
	unsigned int a;
	vectype * b;
	a=v1.len;
	v1.len=v2.len;
	v2.len=a;
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
			cout <<setw(8) <<setprecision(4) << v(i);
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
			cout << setw(8)<<setprecision(4) << v(i) << "\n";
			}
		}
	else
		{
		error("bad mode");
		}
	}

