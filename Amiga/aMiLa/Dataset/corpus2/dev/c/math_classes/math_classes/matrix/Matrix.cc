
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
	unsigned int i;
	if(v.size()==0)error("bad size");
	if(m==0)  //row vector
		{
		r=1;
		c=v.size();
		vals=new mtrxtype[v.size()] ;
		if(vals==0)error("out of mem");
		for(i=1;i<=cols();i++)
			{
			(*this)(1,i)=v(i);
			}
		}
	else if(m==1) //column vector
		{
		r=v.size();
		c=1;
		vals=new mtrxtype[v.size()] ;
		if(vals==0)error("out of mem");
		for(i=1;i<=rows();i++)
			{
			(*this)(i,1)=v(i);
			}
		}
	else
		{
		error("bad mode");
		}
	}


Vector::Vector(const Matrix& m1)
	{
	unsigned int i;
	if(m1.rows()!=1 && m1.cols()!=1)
		{
		error("dimensions do not match");
		}
	if(m1.rows()==1)
		{
		len=m1.cols();
		vals=new vectype[len];
		for(i=1;i<=size();i++)
			{
			(*this)(i)=m1(1,i);
			}
		}
	else if(m1.cols()==1)
		{
		len=m1.rows();
		vals=new vectype[len];
		for(i=1;i<=size();i++)
			{
			(*this)(i)=m1(i,1);
			}
		}
	}


Matrix::Matrix()
	{
	r=0;
	c=0;
	vals=0;
	}
	
	
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


Matrix::Matrix(const Matrix& m)
	{
	r=m.rows();
	c=m.cols();
	vals=new mtrxtype[rows()*cols()];
	if(vals==0) error("out of mem");
	for(unsigned int i=1;i<=rows();i++)
		{
		for(unsigned int j=1;j<=cols();j++)
			{
			(*this)(i,j)=m(i,j);
			}
		}
	}
	
Matrix::Matrix(const Pmatrix& p)
	{
	unsigned int i;
	r=p.rows();
	c=p.rows();
	vals=new mtrxtype [r*c];
	if(vals==0) error("out of mem");
	for(i=0;i<rows()*cols();i++)
		{
		vals[i]=0.0;
		}
	for(i=1;i<=rows();i++)
		{
		(*this)(i,p[i])=1.0;
		}
	}


Matrix::Matrix(unsigned int ro,unsigned int co,mtrxtype *m)
	{
	unsigned int p=0;
	unsigned int i,j;
	if(ro==0 || co ==0) error("bad size");
	r=ro;
	c=co;
	vals=new mtrxtype[ro*co];
	for(i=1;i<=rows();i++)
		{
		for(j=1;j<=cols();j++)
			{
			(*this)(i,j)=m[p++];
			}
		}
	}


Matrix::~Matrix()
	{
	if(vals!=0)
	delete[] vals;
	}


int operator==(const Matrix& m1,const Matrix& m2)
	{
	if(m1.rows()!=m2.rows() || m1.cols()!=m2.cols()) return(0);
	for(unsigned int i=1;i<=m1.rows();i++)
		{
		for(unsigned int j=1;j<=m1.cols();j++)
			{
			if(m1(i,j)!=m2(i,j))
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
	for(unsigned int i=1;i<=m1.rows();i++)
		{
		for(unsigned int j=1;j<=m1.cols();j++)
			{
			if(m1(i,j)!=m2(i,j))
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
	for(unsigned int i=1;i<=m.rows();i++)
		{
		for(unsigned int j=1;j<=m.cols();j++)
			{
			m(i,j)=m1(i,j)+m2(i,j);
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
	for(unsigned int i=1;i<=m.rows();i++)
		{
		for(unsigned int j=1;j<=m.cols();j++)
			{
			m(i,j)=m1(i,j)-m2(i,j);
			}
		}
	return m;
	}	


void print(const Matrix& m)
	{
	for(unsigned int i=1;i<=m.rows();i++)
		{
		for(unsigned int j=1;j<=m.cols();j++)
			{
			cout.setf(ios::left);
			cout.setf(ios::adjustfield);
			cout.setf(ios::fixed);
			cout <<setw(8) <<setprecision(4) <<m(i,j);
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
	if(rows()==0)
		{
		r=m.rows();
		c=m.cols();
		vals=new mtrxtype[rows()*cols()];
		if(vals==0) error("out of mem");
		for(unsigned int i=1;i<=rows();i++)
			{
			for(unsigned int j=1;j<=cols();j++)
				{
				(*this)(i,j)=m(i,j);
				}
			}
		return *this;
		}
	else
		{
		if(rows()!=m.rows() || cols()!=m.cols())error("dimensions do not match");
		for(unsigned int i=1;i<=rows();i++)
			{
			for(unsigned int j=1;j<=cols();j++)
				{
				(*this)(i,j)=m(i,j);
				}
			}
		return *this;
		}
	}	


Matrix& Matrix::operator+=(const Matrix& m)
	{
	if(rows()!=m.rows() || cols()!=m.cols())error("dimensions do not match");
	for(unsigned int i=0;i<=rows();i++)
		{
		for(unsigned int j=0;j<=cols();j++)
			{
			(*this)(i,j)+=m(i,j);
			}
		}
	return *this;
	}

Matrix& Matrix::operator-=(const Matrix& m)
	{
	if(rows()!=m.rows() || cols()!=m.cols())error("dimensions do not match");
	for(unsigned int i=0;i<=rows();i++)
		{
		for(unsigned int j=0;j<=cols();j++)
			{
			(*this)(i,j)-=m(i,j);
			}
		}
	return *this;
	}




Matrix& Matrix::operator*=(mtrxtype a)
	{
	for(unsigned int i=1;i<=rows();i++)
		{
		for(unsigned int j=1;j<=rows();j++)
			{
			(*this)(i,j)*=a;
			}
		}
	return *this;
	}


Vector operator* (const Matrix& m1,const Vector& v1)
	{
	Vector a(m1.rows());
	unsigned int i,k;
	mtrxtype t;
	if(m1.cols()!=v1.size())
		{
		error("dimensions do not match");
		}
	for(i=1;i<=m1.rows();i++)
		{
		t=0.0;
		for(k=1;k<=m1.cols();k++)
			{
			t+=m1(i,k)*v1(k);
			}
		a(i)=t;
		}
	return a;
	}


Vector operator* (const Vector& v1,const Matrix& m1)
	{
	Vector a(m1.cols());
	unsigned int i,k;
	mtrxtype t;
	if(v1.size()!=m1.rows())
		{
		error("dimensions do not match");
		}
	for(i=1;i<=m1.cols();i++)
		{
		t=0.0;
		for(k=1;k<=m1.rows();k++)
			{
			t+=m1(k,i)*v1(k);
			}
		a(i)=t;
		}
	return a;
	}


Matrix operator* (const Matrix& m1,const Matrix& m2)
	{
	Matrix a(m1.rows(),m2.cols());
	unsigned int i,j,k;
	mtrxtype t;
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
				t+=m1(i,k)*m2(k,j);
				}
			a(i,j)=t;
			}
		}
	return a;
	}


Matrix operator* (const Matrix& m,mtrxtype d)
	{
	Matrix a(m);
	unsigned int i,j;
	for(i=1;i<=m.rows();i++)
		{
		for(j=1;j<=m.cols();j++)
			{
			a(i,j)*=d;
			}
		}	
	return a;
	}
	

Matrix operator* (mtrxtype d,const Matrix& m)
	{
	Matrix a(m);
	unsigned int i,j;
	for(i=1;i<=m.rows();i++)
		{
		for(j=1;j<=m.cols();j++)
			{
			a(i,j)*=d;
			}
		}	
	return a;
	}


void Matrix::rowexchange(unsigned int r1,unsigned int r2)
	{
	unsigned int i;
	mtrxtype a;
	if(r1 > rows() || r1==0 || r2 > rows() || r2==0) error("bad subscript\n");
	for(i=1;i<=cols();i++)
		{
		a=(*this)(r1,i);
		(*this)(r1,i)=(*this)(r2,i);
		(*this)(r1,i)=a;
		}
	}


void Matrix::setcol(unsigned int co,Vector v)
	{
	for(unsigned int i=1;i<=rows();i++)
		{
		(*this)(i,co)=v(i);
		}
	}


Vector Matrix::getcol (unsigned int co) const
	{
	Vector v(rows());
	for(unsigned int i=1;i<=rows();i++)
		{
		v(i)=(*this)(i,co);
		}
	return v;
	}
	
void Matrix::setrow(unsigned int ro,Vector v)
	{
	for(unsigned int i=1;i<=cols();i++)
		{
		(*this)(ro,i)=v(i);
		}
	}


Vector Matrix::getrow (unsigned int ro) const
	{
	Vector v(rows());
	for(unsigned int i=1;i<=cols();i++)
		{
		v(i)=(*this)(ro,i);
		}
	return v;
	}


Matrix transpose(const Matrix& m)
	{
	Matrix a(m.cols(),m.rows());
	unsigned int i,j;
	if(m.cols() ==0 || m.rows()==0)error("bad size");
	for (i=1;i<=m.rows();i++)
		{
		for(j=1;j<=m.cols();j++)
			{
			a(j,i)=m(i,j);
			}
		}
	return a;
	}
	
	
Vector solve(const Matrix& m1,const Vector& v1)
	{
	Vector x(v1.size());
	unsigned int maxr;
	mtrxtype maxv;
	unsigned int i,j,k,i2;
	mtrxtype t1,t3;
	mtrxtype t2;
	Matrix m(m1);
	Vector v(v1);
	if(m1.rows()!=v.size() || m1.cols()!=m1.rows()) 
		{
		error("dimensions do not match");
		}
	for(k=1;k<m.rows();k++)
		{
		maxr=k;
		maxv=m(k,k);
		for(i2=k;i2<=m.rows();i2++)
			{
			t3=m(i2,k);
			if (abs(t3)>abs(maxv))
				{
				maxr=i2;
				maxv=t3;
				}
			}
		if (maxr!=k)
			{
			m.rowexchange(k,maxr);
			t2=v(k);
			v(k)=v(maxr);
			v(maxr)=t2;
			}
		for(j=k+1;j<=m.rows();j++)
			{
			t1=m(j,k)/m(k,k);
			for(i=k;i<=m.cols();i++)
				{
				t3=m(j,i)-t1*m(k,i);
				m(j,i)=t3;
				}
			t2=v(j)-t1*v(k);
			v(j)=t2;
			}
		}
	for(j=m.rows();j>=1;j--)
		{
		t1=0.0;
		for(i=m.cols();i>j;i--)
			{
			t1+=m(j,i)*x(i);
			}
		t2=(v(j)-t1)/m(j,j);
		x(j)=t2;
		}
	return v;
	}


mtrxtype determinant(const Matrix& m1)
	{
	unsigned int k,i2,i,j;
	unsigned int c;
	unsigned int maxr;
	mtrxtype maxv;
	Matrix m(m1);
	mtrxtype t1,t2,t3;
	if(m1.rows()!=m1.cols())error("dimensions do not match");
	c=1;
	for(k=1;k<m.rows();k++)
		{
		maxr=k;
		maxv=m(k,k);
		for(i2=k;i2<=m.rows();i2++)
			{
			t3=m(k,i2);
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
			t1=m(j,k)/m(k,k);
			for(i=k;i<=m.cols();i++)
				{
				t2=m(j,i)-t1*m(k,i);
				m(j,i)=t2;
				}
			}
		}
	t1=1.0;
	for(i=1;i<=m.cols();i++)
		{
		t1*=m(i,i);
		}
	return(t1*c);
	}
	
	
Matrix inverse(const Matrix& a)
	{
	Matrix m(a.rows(),a.cols());
	unsigned int i,j;
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
			v(j)=0.0;
			}
		v(i)=1.0;
		x=LUsolve(b,v);
		m.setcol(i,x);
		}
	return m;
	}
	

void Matrix::setunity(void)
	{
	if(rows()!=cols()) error("dimensions do not match");
	for(unsigned int i=1;i<=rows();i++)
		{
		for(unsigned int j=1;j<=cols();j++)
			{
			if(i==j)
				{
				(*this)(i,j)=1.0;
				}
			else
				{
				(*this)(i,j)=0.0;
				}
			}
		}
	}


Matrix unity(unsigned int n)
	{
	Matrix a(n,n);
	if(n==0)error("bad size");
	for(unsigned int i=1;i<=n;i++)
		{
		a(i,i)=1.0;
		}
	return a;
	}


void swap(Matrix& m1,Matrix& m2)
	{
	unsigned int a,b;
	mtrxtype * c;
	a=m1.r;
	b=m1.c;
	c=m1.vals;
	m1.r=m2.r;
	m1.c=m2.c;
	m1.vals=m2.vals;
	m2.r=a;
	m2.c=b;
	m2.vals=c;
	}


LUmatrix LUdecompose(const Matrix& m1)
	{
	LUmatrix m;
	unsigned int maxr;
	mtrxtype maxv;
	unsigned int i,j,k,i2;
	unsigned int t2;
	mtrxtype t1,t3;
	if(m1.cols()!=m1.rows()) 
		{
		error("dimensions do not match");
		}
	m.lu=m1;
	m.p=Pmatrix(m1.rows());
	for(k=1;k<m.lu.rows();k++)
		{
		maxr=k;
		maxv=m.lu(k,k);
		for(i2=k+1;i2<=m.lu.rows();i2++)
			{
			t3=m.lu(i2,k);
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
			t1=m.lu(j,k)/m.lu(k,k);
			for(i=k+1;i<=m.lu.cols();i++)
				{
				t3=m.lu(j,i)-t1*m.lu(k,i);
				m.lu(j,i)=t3;
				}
			}
		}
	for(i=1;i<=m1.rows();i++)
		{
		m.lu.setrow(i,m1.getrow(m.p[i]));
		}
	for(k=1;k<m.lu.rows();k++)
		{
		for(j=k+1;j<=m.lu.rows();j++)
			{
			t1=m.lu(j,k)/m.lu(k,k);
			for(i=k+1;i<=m.lu.cols();i++)
				{
				t3=m.lu(j,i)-t1*m.lu(k,i);
				m.lu(j,i)=t3;
				}
			m.lu(j,k)=t1;
			}
		}
	return m;
	}
	
	
Matrix getl(const LUmatrix& m)
	{
	Matrix a(m.lu);
	unsigned int i,j;
	for(i=1;i<=a.rows();i++)
		{
		for(j=i+1;j<=a.cols();j++)
			{
			a(i,j)=0.0;
			}
		}
	for(i=1;i<=a.rows();i++)
		{
		a(i,i)=1.0;
		}
	return a;
	}
	
	
Matrix getu(const LUmatrix& m)
	{
	Matrix a(m.lu);
	unsigned int i,j;
	for(i=2;i<=a.rows();i++)
		{
		for(j=1;j<i;j++)
			{
			a(i,j)=0.0;
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
	unsigned int i,j;
	mtrxtype t1;
	mtrxtype t2;
	Vector v(b.size());
	Vector y(b.size());
	Matrix m(m1.lu.rows(),m1.lu.cols());
	if(m.rows()!=b.size() || m.cols()!=m.rows()) 
		{
		error("dimensions do not match");
		}
	for(i=1;i<=b.size();i++)
		{
		v(i)=b(m1.p[i]);
		}
	m=getl(m1);
	for(j=1;j<=m.rows();j++)
		{
		t1=0.0;
		for(i=1;i<j;i++)
			{
			t1+=m(j,i)*y(i);
			}
		t2=(v(j)-t1)/m(j,j);
		y(j)=t2;
		}
	m=getu(m1);
	for(j=m.rows();j>=1;j--)
		{
		t1=0.0;
		for(i=m.cols();i>j;i--)
			{
			t1+=m(j,i)*x(i);
			}
		t2=(y(j)-t1)/m(j,j);
		x(j)=t2;
		}
	return x;
	}


Pmatrix::Pmatrix()
	{
	rws=0;
	r=NULL;
	}


Pmatrix::Pmatrix(unsigned int s)
	{
	unsigned int i;
	if(s<1)error("bad size");
	rws=s;
	r=new unsigned int[s];
	if(r==NULL)error("out of store");
	for (i=0;i<s;i++)
		{
		r[i]=i+1;
		}
	}
	
	
Pmatrix::Pmatrix(const Pmatrix& m)
	{
	unsigned int i;
	if(m.rows()==0)
		{
		rws=0;
		r=NULL;
		}
	else
		{
		rws=m.rws;
		r=new unsigned int[rws];
		if(r==NULL)error("out of store");
		for(i=0;i<rws;i++)
			{
			r[i]=m.r[i];
			}
		}
	}
	
	
Pmatrix::~Pmatrix()
	{
	if (rws!=0)
		{
		delete [] r;
		}
	}


Pmatrix& Pmatrix::operator= (const Pmatrix& m)
	{
	unsigned int i;
	if(rws!=0) 
		{
		delete[] r;
		}
	r=new unsigned int[rws=m.rws];
	for(i=0;i<rws;i++)
		{
		r[i]=m.r[i];
		}
	return *this;
	}
	
	
Pmatrix inverse(const Pmatrix& m)
	{
	Pmatrix a(m.rws);
	unsigned int i;
	for(i=0;i<m.rws;i++)
		{
		a.r[m.r[i]]=i;
		}
	return a;
	}


Pmatrix transpose(const Pmatrix& m)
	{
	Pmatrix a(m.rws);
	unsigned int i;
	for(i=0;i<m.rws;i++)
		{
		a.r[m.r[i]]=i;
		}
	return a;
	}


Matrix operator* (const Pmatrix& p,const Matrix& m)
	{
	Matrix a(m.rows(),m.cols());
	unsigned int i;
	if(m.rows()!=p.rows() || m.rows() !=m.cols()) error("dimensions do not match");
	for(i=1;i<=p.rows();i++)
		{
		a.setrow(i,m.getrow(p[i]));
		}
	return a;
	}
	
	
Vector operator* (const Pmatrix& p,const Vector& v)
	{
	Vector a(v.size());
	unsigned int i;
	if(v.size()!=p.rws) error("dimensions do not match");
	for(i=1;i<=p.rws;i++)
		{
		a(i)=v(p[i]);
		}
	return v;
	}


Pmatrix operator* (const Pmatrix& p1,const Pmatrix& p2)
	{
	Pmatrix a(p1.rws);
	unsigned int i;
	if(p1.rws!=p2.rws)error("dimensions do not match");
	for(i=0;i<p1.rws;i++)
		{
		a.r[i]=p2.r[p1.r[i]];
		}
	return a;
	}
	

unsigned int& Pmatrix::operator[](unsigned int i) const
	{
#ifdef CHECKRANGE
	if(i>rws || i<1)error("bad subscript");
#endif
	return r[i-1];
	}
	
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
		
