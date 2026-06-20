#ifndef _MATRIX_H
#define _MATRIX_H



typedef float mtrxtype;
class LUmatrix;
class Pmatrix;
class Matrix;

double abs(double a);

void error(char *);


class Matrix
{
	unsigned int r;
	unsigned int c;
	mtrxtype *vals;
public:
	Matrix();
	Matrix(unsigned int,unsigned int);
	Matrix(const Matrix&);
	Matrix(unsigned int,unsigned int,mtrxtype *);
	Matrix(const Pmatrix&);
	~Matrix();
	unsigned int rows() const
		{
		return r;
		}
	unsigned int cols() const
		{
		return c;
		}
	mtrxtype& operator()(unsigned int i,unsigned int j) const
		{
#ifdef CHECKRANGE
		if(i>rows() || i==0 || j>cols() || j==0)error("bad subscript");
#endif
		return vals[(i-1)*cols()+j-1];
		}
	void rowexchange(unsigned int,unsigned int);
	void setrow(unsigned int,Matrix);
	Matrix getrow(unsigned int) const;
	void setcol(unsigned int,Matrix);
	Matrix getcol (unsigned int) const;	
	friend void swap(Matrix& m1,Matrix& m2);
	Matrix& operator= (const Matrix&);
	Matrix& operator+=(const Matrix&);
	Matrix& operator-=(const Matrix&);
	Matrix& operator*=(mtrxtype);
	friend Matrix operator+ (const Matrix&,const Matrix&);
	friend Matrix operator- (const Matrix&,const Matrix&);
	friend Matrix operator* (const Matrix&,const Matrix&);
	friend Matrix operator* (const Matrix&,mtrxtype);
	friend Matrix operator* (mtrxtype,const Matrix&);
	friend int operator==(const Matrix&,const Matrix&);
	friend int operator!=(const Matrix&,const Matrix&);
	void setunity();
};

mtrxtype determinant(const Matrix&);
Matrix inverse(const Matrix&);
Matrix transpose(const Matrix&);
Matrix solve(const Matrix&,const Matrix&);
Matrix solve(const LUmatrix&,const Matrix&);
LUmatrix LUdecompose(const Matrix&);
Matrix unity(unsigned int);
void print(const Matrix&);

class Pmatrix
	{
	// Permutation matrix
	friend class LUmatrix;
	friend class Matrix;
	unsigned int rws;
	unsigned int *r;
public:
	Pmatrix();
	Pmatrix(unsigned int);
	Pmatrix(const Pmatrix&);
	~Pmatrix();
	unsigned int rows() const
		{
		return rws;
		}
	Pmatrix& operator= (const Pmatrix&);
	friend Pmatrix inverse(const Pmatrix&);
	friend Pmatrix transpose(const Pmatrix&);
	friend Matrix operator* (const Pmatrix&,const Matrix&);
	friend Pmatrix operator* (const Pmatrix&,const Pmatrix&);
	unsigned int& operator[](unsigned int) const;
	mtrxtype operator()(unsigned int,unsigned int) const;
	};


class LUmatrix
	{
	friend class Matrix;
	friend class Pmatrix;
	Matrix lu;
	Pmatrix p;
public:
	LUmatrix& operator= (const LUmatrix&);
	friend LUmatrix LUdecompose(const Matrix&);
	friend Matrix LUsolve(const LUmatrix&,const Matrix&);
	friend Matrix getl(const LUmatrix&);
	friend Matrix getu(const LUmatrix&);
	friend Matrix getp(const LUmatrix&);
	};


#endif /* _MATRIX_H */
