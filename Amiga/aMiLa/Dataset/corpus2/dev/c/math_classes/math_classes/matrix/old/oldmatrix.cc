
#include <iostream.h>
#include <iomanip.h>
#include <stdlib.h>
#include "matrix.h"


double abs(double a)
	{
	return (a>0 ? a : -a);
	}
	

Matrix::Matrix(const Vector& v,int m)
	{
	if(v.size()<1)error("bad size");
	if(m==0)  //row vector
		{
		r=1;
		c=v.size();
		vecs=new Vector [1];
		if(vecs==0)error("out of mem");
		vecs[0]=v;
		}
	else if(m==1) //column vector
		{
		r=v.size();
		c=1;
		vecs=new Vector [r];
		if(vecs==0)error("out of mem");
		for(int i=0;i<r;i++)
			{
			vecs[i]=Vector(1);
			if(vecs[i]==0)error("out of mem");
			vecs[i].selem(i,v.elem(i+1));
			}
		}
	else
		{
		error("bad mode");
		}
	}


Vector::Vector(const Matrix& m1)
	{
	int i;
	if(m1.rows()!=1 && m1.cols()!=1)
		{
		error("dimensions do not match");
		}
	if(m1.rows()==1)
		{
		l=m1.cols();
		vals=new double[l];
		for(i=0;i<l;i++)
			{
			vals[i]=m1.elem(1,i);
			}
		}
	else if(m1.cols()==1)
		{
		l=m1.rows();
		vals=new double[l];
		for(i=0;i<l;i++)
			{
			vals[i]=m1.elem(i,1);
			}
		}
	}


Matrix::Matrix()
	{
	r=0;
	c=0;
	vecs=0;
	}
	
	
Matrix::Matrix(int ro,int co)
	{
	r=ro;
	c=co;
	vecs=new Vector [r];
	for(int i=0;i<r;i++)
		{
		vecs[i]=Vector(c);
		}
	}


Matrix::Matrix(const Matrix& m)
	{
	r=m.r;
	c=m.c;
	vecs=new Vector [r];
	for(int i=0;i<r;i++)
		{
		vecs[i]=m.vecs[i];
		}
	}
	

Matrix::Matrix(const Pmatrix& p)
	{
	int i;
	r=p.rows;
	c=p.rows;
	vecs=new Vector [p.rows];
	for(i=0;i<r;i++)
		{
		vecs[i]=Vector(c);
		}
	for(i=1;i<=r;i++)
		{
		setelement(i,p[i],1.0);
		}
	}


Matrix::Matrix(int ro,int co,double *m)
	{
	int p=0;
	int i,j;
	r=ro;
	c=co;
	vecs=new Vector [r];
	for(i=0;i<r;i++)
		{
		vecs[i]=Vector(c);
		}
	for(i=0;i<r;i++)
		{
		for(j=1;j<=c;j++)
			{
			vecs[i].selem(j,m[p++]);
			}
		}
	}


Matrix::~Matrix()
	{
	if(r!=0)
	delete[] vecs;
	}


int operator==(const Matrix& m1,const Matrix& m2)
	{
	if(m1.rows()!=m2.rows() || m1.cols()!=m2.cols()) return(0);
	for(int i=1;i<=m1.rows();i++)
		{
		for(int j=1;j<=m1.cols();j++)
			{
			if(m1.elem(i,j)!=m2.elem(i,j))
				{
				return(0);
				}
			}
		}
	return(1);
	}


int operator!=(const Matrix& m1,const Matrix& m2)
	{
	if(m1.rows()!=m2.rows() || m1.cols()!=m2.cols()) return(1);
	for(int i=1;i<=m1.rows();i++)
		{
		for(int j=1;j<=m1.cols();j++)
			{
			if(m1.elem(i,j)!=m2.elem(i,j))
				{
				return(1);
				}
			}
		}
	return(0);
	}


Matrix operator+ (const Matrix& m1,const Matrix& m2)
	{
	Matrix m(m1.rows(),m1.cols());
	if(m1.rows()!=m2.rows() || m1.cols()!=m2.cols())
		{
		error("dimensions do not match");
		}
	for(int i=1;i<=m.rows();i++)
		{
		for(int j=1;j<=m.cols();j++)
			{
			m.selem(i,j,m1.elem(i,j)+m2.elem(i,j));
			}
		}
	return m;
	}	


Matrix operator- (const Matrix& m1,const Matrix& m2)
	{
	Matrix m(m1.rows(),m1.cols());
	if(m1.rows()!=m2.rows() || m1.cols()!=m2.cols())
		{
		error("dimensions do not match");
		}
	for(int i=1;i<=m.rows();i++)
		{
		for(int j=1;j<=m.cols();j++)
			{
			m.selem(i,j,m1.elem(i,j)-m2.elem(i,j));
			}
		}
	return m;
	}	


void print(const Matrix& m)
	{
	for(int i=1;i<=m.rows();i++)
		{
		for(int j=1;j<=m.cols();j++)
			{
			cout.setf(ios::left);
			cout.setf(ios::adjustfield);
			cout.setf(ios::fixed);
			cout <<setw(8) <<setprecision(4) <<m.elem(i,j);
			}
		cout << "\n";
		}
	}


LUmatrix& LUmatrix::operator= (const LUmatrix& m)
	{
	lu=m.lu;
	p=m.p;
	return *this;
	}


Matrix& Matrix::operator= (const Matrix& m)
	{
	if(r==0)
		{
		r=m.r;
		c=m.c;
		vecs=new Vector [r];
		for(int i=0;i<r;i++)
			{
			vecs[i]=m.vecs[i];
			}
		return *this;
		}
	else
		{
		if(r!=m.r || c!=m.c)error("dimensions do not match");
		for(int i=0;i<r;i++)
			{
			vecs[i]=m.vecs[i];
			}
		return *this;
		}
	}	


Matrix& Matrix::operator+=(const Matrix& m)
	{
	if(r!=m.r || c!=m.c)error("dimensions do not match");
	for(int i=0;i<r;i++)
		{
		vecs[i]+=m.vecs[i];
		}
	return *this;
	}


Matrix& Matrix::operator-=(const Matrix& m)
	{
	if(r!=m.r || c!=m.c)error("dimensions do not match");
	for(int i=0;i<r;i++)
		{
		vecs[i]-=m.vecs[i];
		}
	return *this;
	}


Matrix& Matrix::operator*=(double a)
	{
	for(int i=0;i<r;i++)
		{
		vecs[i]*=a;
		}
	return *this;
	}


Vector operator* (const Matrix& m1,const Vector& v1)
	{
	Vector a(m1.rows());
	int i,k;
	double t;
	if(m1.cols()!=v1.size())
		{
		error("dimensions do not match");
		}
	for(i=1;i<=m1.rows();i++)
		{
		t=0.0;
		for(k=1;k<=m1.cols();k++)
			{
			t+=m1.getelement(i,k)*v1.getelement(k);
			}
		a.setelement(i,t);
		}
	return a;
	}


Vector operator* (const Vector& v1,const Matrix& m1)
	{
	Vector a(m1.cols());
	int i,k;
	double t;
	if(v1.size()!=m1.rows())
		{
		error("dimensions do not match");
		}
	for(i=1;i<=m1.cols();i++)
		{
		t=0.0;
		for(k=1;k<=m1.rows();k++)
			{
			t+=m1.getelement(k,i)*v1.getelement(k);
			}
		a.setelement(i,t);
		}
	return a;
	}


Matrix operator* (const Matrix& m1,const Matrix& m2)
	{
	Matrix a(m1.rows(),m2.cols());
	int i,j,k;
	double t;
	if(m1.cols() != m2.rows()) 
		{
		error("dimensions do not match");
		}
	for(i=1;i<=m1.rows();i++)
		{
		for(j=1;j<=m2.cols();j++)
			{
			t=0.0;
			for(k=1;k<=m2.rows();k++)
				{
				t+=m1.getelement(i,k)*m2.getelement(k,j);
				}
			a.setelement(i,j,t);
			}
		}
	return a;
	}


Matrix operator* (const Matrix& m,double d)
	{
	Matrix a(m);
	int i;
	for(i=0;i<m.rows();i++)
		{
		a.vecs[i]*=d;
		}
	return a;
	}
	

Matrix operator* (double d,const Matrix& m)
	{
	Matrix a(m);
	int i;
	for(i=0;i<m.rows();i++)
		{
		a.vecs[i]*=d;
		}
	return a;
	}
	

void Matrix::setcol(int co,Vector v)
	{
	for(int i=1;i<=rows();i++)
		{
		selem(i,co,v.elem(i));
		}
	}


Vector Matrix::getcol (int co) const
	{
	Vector v(rows());
	for(int i=1;i<=rows();i++)
		{
		v.selem(i,elem(i,co));
		}
	return v;
	}


Matrix transpose(const Matrix& m)
	{
	Matrix a(m.cols(),m.rows());
	int i,j;
	if(m.cols() <1 || m.rows()<1)error("bad size");
	for (i=1;i<=m.rows();i++)
		{
		for(j=1;j<=m.cols();j++)
			{
			a.selem(j,i,m.elem(i,j));
			}
		}
	return a;
	}
	
	
Vector solve(const Matrix& m1,const Vector& v1)
	{
	Vector x(v1.size());
	int maxr;
	double maxv;
	int i,j,k,i2;
	double t1,t3;
	double t2;
	Matrix m(m1);
	Vector v(v1);
	if(m1.rows()!=v.size() || m1.cols()!=m1.rows()) 
		{
		error("dimensions do not match");
		}
	for(k=1;k<m.rows();k++)
		{
		maxr=k;
		maxv=m.elem(k,k);
		for(i2=k;i2<=m.rows();i2++)
			{
			t3=m.elem(i2,k);
			if (abs(t3)>abs(maxv))
				{
				maxr=i2;
				maxv=t3;
				}
			}
		if (maxr!=k)
			{
			m.rowexchange(k,maxr);
			t2=v.elem(k);
			v.selem(k,v.elem(maxr));
			v.selem(maxr,t2);
			}
		for(j=k+1;j<=m.rows();j++)
			{
			t1=m.elem(j,k)/m.elem(k,k);
			for(i=k;i<=m.cols();i++)
				{
				t3=m.elem(j,i)-t1*m.elem(k,i);
				m.selem(j,i,t3);
				}
			t2=v.elem(j)-t1*v.elem(k);
			v.selem(j,t2);
			}
		}
	for(j=m.rows();j>=1;j--)
		{
		t1=0.0;
		for(i=m.cols();i>j;i--)
			{
			t1+=m.elem(j,i)*x.elem(i);
			}
		t2=(v.elem(j)-t1)/m.elem(j,j);
		x.selem(j,t2);
		}
	return v;
	}


double determinant(const Matrix& m1)
	{
	int k,i2,i,j;
	int c;
	int maxr;
	double maxv;
	Matrix m(m1);
	double t1,t2,t3;
	if(m1.rows()!=m1.cols())error("dimensions do not match");
	c=1;
	for(k=1;k<m.rows();k++)
		{
		maxr=k;
		maxv=m.getelement(k,k);
		for(i2=k;i2<=m.rows();i2++)
			{
			t3=m.getelement(k,i2);
			if (abs(t3)>abs(maxv))
				{
				maxr=i2;
				maxv=t3;
				}
			}
		if (maxr!=k)
			{
			m.rowexchange(k,maxr);
			c*=-1;
			}
		for(j=k+1;j<=m.rows();j++)
			{
			t1=m.getelement(j,k)/m.getelement(k,k);
			for(i=k;i<=m.cols();i++)
				{
				t2=m.getelement(j,i)-t1*m.getelement(k,i);
				m.setelement(j,i,t2);
				}
			}
		}
	t1=1.0;
	for(i=1;i<=m.cols();i++)
		{
		t1*=m.getelement(i,i);
		}
	return(t1*c);
	}
	
	
Matrix inverse(const Matrix& a)
	{
	Matrix m(a.rows(),a.cols());
	int i,j;
	Vector v(a.cols());
	Vector x(a.cols());
	LUmatrix b;
	if(a.rows()!=a.cols())
		{
		error("dimensions do not match");
		}
	b=LUdecompose(a);
	for(i=1;i<=m.rows();i++)
		{
		for(j=1;j<=v.size();j++)
			{
			v.selem(j,0.0);
			}
		v[i]=1.0;
		x=LUsolve(b,v);
		m.setcol(i,x);
		}
	return m;
	}
	

void Matrix::setunity(void)
	{
	if(rows()!=cols()) error("dimensions do not match");
	for(int i=1;i<=rows();i++)
		{
		for(int j=1;j<=cols();j++)
			{
			if(i==j)
				{
				setelement(i,j,1.0);
				}
			else
				{
				setelement(i,j,0.0);
				}
			}
		}
	}


Matrix unity(int n)
	{
	Matrix a(n,n);
	if(n<1)error("bad size");
	for(int i=1;i<=n;i++)
		{
		a[i][i]=1.0;
		}
	return a;
	}


void swap(Matrix& m1,Matrix& m2)
	{
	int a,b;
	Vector * c;
	a=m1.r;
	b=m1.c;
	c=m1.vecs;
	m1.r=m2.r;
	m1.c=m2.c;
	m1.vecs=m2.vecs;
	m2.r=a;
	m2.c=b;
	m2.vecs=c;
	}


LUmatrix LUdecompose(const Matrix& m1)
	{
	LUmatrix m;
	int maxr;
	double maxv;
	int i,j,k,i2;
	int j2,t2,j3;
	double t1,t3;
	if(m1.cols()!=m1.rows()) 
		{
		error("dimensions do not match");
		}
	m.lu=m1;
	m.p=Pmatrix(m1.rows());
	for(k=1;k<m.lu.rows();k++)
		{
		maxr=k;
		maxv=m.lu.getelement(k,k);
		for(i2=k+1;i2<=m.lu.rows();i2++)
			{
			t3=m.lu.getelement(i2,k);
			if (abs(t3)>abs(maxv))
				{
				maxr=i2;
				maxv=t3;
				}
			}
		if (maxr!=k)
			{
			m.lu.rowexchange(k,maxr);
			t2=m.p[k];
			m.p[k]=m.p[maxr];
			m.p[maxr]=t2;
			}
		for(j=k+1;j<=m.lu.rows();j++)
			{
			t1=m.lu.getelement(j,k)/m.lu.getelement(k,k);
			for(i=k+1;i<=m.lu.cols();i++)
				{
				t3=m.lu.getelement(j,i)-t1*m.lu.getelement(k,i);
				m.lu.setelement(j,i,t3);
				}
			}
		}
	for(i=1;i<=m1.rows();i++)
		{
		m.lu[i]=m1[m.p[i]];
		}
	for(k=1;k<m.lu.rows();k++)
		{
		for(j=k+1;j<=m.lu.rows();j++)
			{
			t1=m.lu.getelement(j,k)/m.lu.getelement(k,k);
			for(i=k+1;i<=m.lu.cols();i++)
				{
				t3=m.lu.getelement(j,i)-t1*m.lu.getelement(k,i);
				m.lu.setelement(j,i,t3);
				}
			m.lu.setelement(j,k,t1);
			}
		}
	return m;
	}
	
	
Matrix getl(const LUmatrix& m)
	{
	Matrix a(m.lu);
	int i,j;
	for(i=1;i<=a.rows();i++)
		{
		for(j=i+1;j<=a.cols();j++)
			{
			a[i][j]=0.0;
			}
		}
	for(i=1;i<=a.rows();i++)
		{
		a[i][i]=1.0;
		}
	return a;
	}
	
	
Matrix getu(const LUmatrix& m)
	{
	Matrix a(m.lu);
	int i,j;
	for(i=2;i<=a.rows();i++)
		{
		for(j=1;j<i;j++)
			{
		a[i][j]=0.0;
			}
		}
	return a;
	}


Matrix getp(const LUmatrix& m)
	{
	Matrix a(m.p);
	return a;
	}


Vector solve(const LUmatrix& m1,const Vector& b)
	{
	return LUsolve(m1,b);
	}


Vector LUsolve(const LUmatrix& m1,const Vector& b) return x(b.size());
	{
	Vector x(b.size());
	int i,j;
	double t1;
	double t2;
	Vector v(b.size());
	Vector y(b.size());
	Matrix m(m1.lu.rows(),m1.lu.cols());
	if(m.rows()!=b.size() || m.cols()!=m.rows()) 
		{
		error("dimensions do not match");
		}
	for(i=1;i<=b.size();i++)
		{
		v[i]=b[m1.p[i]];
		}
	m=getl(m1);
	for(j=1;j<=m.rows();j++)
		{
		t1=0.0;
		for(i=1;i<j;i++)
			{
			t1+=m.getelement(j,i)*y[i];
			}
		t2=(v[j]-t1)/m.getelement(j,j);
		y[j]=t2;
		}
	m=getu(m1);
	for(j=m.rows();j>=1;j--)
		{
		t1=0.0;
		for(i=m.cols();i>j;i--)
			{
			t1+=m.getelement(j,i)*x[i];
			}
		t2=(y[j]-t1)/m.getelement(j,j);
		x[j]=t2;
		}
	return x;
	}


Pmatrix::Pmatrix()
	{
	rows=0;
	r=NULL;
	}


Pmatrix::Pmatrix(int s)
	{
	int i;
	if(s<1)error("bad size");
	rows=s;
	r=new int[s];
	if(r==NULL)error("out of store");
	for (i=0;i<s;i++)
		{
		r[i]=i+1;
		}
	}
	
	
Pmatrix::Pmatrix(const Pmatrix& m)
	{
	int i;
	if(m.rows==0)
		{
		rows=0;
		r=NULL;
		}
	else
		{
		rows=m.rows;
		r=new int[rows];
		if(r==NULL)error("out of store");
		for(i=0;i<rows;i++)
			{
			r[i]=m.r[i];
			}
		}
	}
	
	
Pmatrix::~Pmatrix()
	{
	if (rows!=0)
		{
		delete [] r;
		}
	}


Pmatrix& Pmatrix::operator= (const Pmatrix& m)
	{
	int i;
	if(rows!=0) 
		{
		delete[] r;
		}
	r=new int[rows=m.rows];
	for(i=0;i<rows;i++)
		{
		r[i]=m.r[i];
		}
	return *this;
	}
	
	
Pmatrix inverse(const Pmatrix& m)
	{
	Pmatrix a(m.rows);
	int i;
	for(i=0;i<m.rows;i++)
		{
		a.r[m.r[i]]=i;
		}
	return a;
	}


Pmatrix transpose(const Pmatrix& m)
	{
	Pmatrix a(m.rows);
	int i;
	for(i=0;i<m.rows;i++)
		{
		a.r[m.r[i]]=i;
		}
	return a;
	}


Matrix operator* (const Pmatrix& p,const Matrix& m)
	{
	Matrix a(m.rows(),m.cols());
	int i;
	if(m.rows()!=p.rows || m.rows() !=m.cols()) error("dimensions do not match");
	for(i=1;i<=p.rows;i++)
		{
		a[i]=m[p[i]];
		}
	return a;
	}
	
	
Vector operator* (const Pmatrix& p,const Vector& v)
	{
	Vector a(v.size());
	int i;
	if(v.size()!=p.rows) error("dimensions do not match");
	for(i=1;i<=p.rows;i++)
		{
		a[i]=v[p[i]];
		}
	return v;
	}


Pmatrix operator* (const Pmatrix& p1,const Pmatrix& p2)
	{
	Pmatrix a(p1.rows);
	int i;
	if(p1.rows!=p2.rows)error("dimensions do not match");
	for(i=0;i<p1.rows;i++)
		{
		a.r[i]=p2.r[p1.r[i]];
		}
	return a;
	}
	

int& Pmatrix::operator[](int i) const
	{
	if(i>rows || i<1)error("bad subscript");
	return r[i-1];
	}
	
	
	
