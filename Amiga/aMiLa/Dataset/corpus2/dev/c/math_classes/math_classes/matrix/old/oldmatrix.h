

#include "vector.h"

class LUmatrix;
class Pmatrix;


class Matrix
{
	int r;
	int c;
	int rs;
	int cs;
	Vector *vecs;
public:
	Matrix();
	Matrix(int,int);
	Matrix(const Matrix&);
	Matrix(int,int,double *);
	Matrix(const Vector&,int);
	Matrix(const Pmatrix&);
	Matrix(int,int,int,int);
	Matrix(const Matrix&,int,int);
	Matrix(int,int,double *,int,int);
	Matrix(const Vector&,int,int,int);
	Matrix(const Pmatrix&,int,int);
	~Matrix();
	int rows() const
		{
		return r;
		}
	int cols() const
		{
		return c;
		}
	Vector& operator[](int i) const
		{
		if(i>r+rs-1 || i<rs)error("bad subscript");
		return vecs[i-rs];
		}
	void setelement(int ro,int co,double v)
		{
		if(ro>r+rs-1 || co>c+cs-1 || ro<rs || co<cs) return;
		vecs[ro-rs].selem(co,v);
		}
	void selem(int ro,int co,double v)
		{
		vecs[ro-rs].selem(co,v);
		}
	double getelement(int ro,int co) const
		{
		if(ro>r+rs-1 || co>c+cs-1 || ro<rs || co<cs)
			{
			error("bad subscript");
			}
		return (vecs[ro-rs].elem(co));
		}
	double elem(int ro,int co) const
		{
		return(vecs[ro-rs].elem(co));
		}
	void rowexchange(int r1,int r2)
		{
		if(r1>r || r2>r || r1<1 || r2 <1)error("bad subscript");
		if(r1!=r2)
			{
			swap(vecs[r1-1],vecs[r2-1]);
			}
		return;
		}
	void setrow(int ro,Vector v)
		{
		if (cols()!=v.size()) error("wrong size of vector\n");
		vecs[ro-1]=v;
		}
	Vector getrow(int ro) const
		{
		return vecs[ro-1];
		}
	void setcol(int,Vector);
	Vector getcol (int) const;	
	friend void swap(Matrix& m1,Matrix& m2);
	Matrix& operator= (const Matrix&);
	Matrix& operator+=(const Matrix&);
	Matrix& operator-=(const Matrix&);
	Matrix& operator*=(double);
	friend Matrix operator+ (const Matrix&,const Matrix&);
	friend Matrix operator- (const Matrix&,const Matrix&);
	friend Matrix operator* (const Matrix&,const Matrix&);
	friend Matrix operator* (const Matrix&,double);
	friend Matrix operator* (double,const Matrix&);
	friend Vector operator* (const Vector&,const Matrix&);
	friend Vector operator* (const Matrix&,const Vector&);
	friend int operator==(const Matrix&,const Matrix&);
	friend int operator!=(const Matrix&,const Matrix&);
	void setunity();
};

double determinant(const Matrix&);
Matrix inverse(const Matrix&);
Matrix transpose(const Matrix&);
Vector solve(const Matrix&,const Vector&);
Vector solve(const LUmatrix&,const Vector&);
LUmatrix LUdecompose(const Matrix&);
Matrix unity(int);
void print(const Matrix&);


class Pmatrix
	{
	// Permutation matrix
	friend class Vector;
	friend class LUmatrix;
	friend class Matrix;
	int rows;
	int *r;
public:
	Pmatrix();
	Pmatrix(int);
	Pmatrix(const Pmatrix&);
	~Pmatrix();
	Pmatrix& operator= (const Pmatrix&);
	friend Pmatrix inverse(const Pmatrix&);
	friend Pmatrix transpose(const Pmatrix&);
	friend Matrix operator* (const Pmatrix&,const Matrix&);
	friend Vector operator* (const Pmatrix&,const Vector&);
	friend Pmatrix operator* (const Pmatrix&,const Pmatrix&);
	int& operator[](int) const;
	};


class LUmatrix
	{
	friend class Matrix;
	friend class Vector;
	friend class Pmatrix;
	Matrix lu;
	Pmatrix p;
public:
	LUmatrix& operator= (const LUmatrix&);
	friend LUmatrix LUdecompose(const Matrix&);
	friend Vector LUsolve(const LUmatrix&,const Vector&);
	friend Matrix getl(const LUmatrix&);
	friend Matrix getu(const LUmatrix&);
	friend Matrix getp(const LUmatrix&);
	};



