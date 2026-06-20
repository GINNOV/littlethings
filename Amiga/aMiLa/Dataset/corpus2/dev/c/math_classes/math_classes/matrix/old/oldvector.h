
class Matrix;

void error(char *);

class Vector
{
	int l;
	int s;
	double *vals;
public:
	Vector();
	Vector(int);
	Vector(const Vector&);
	Vector(int,double *);
	Vector(const Matrix&);
	Vector(int,int);
	Vector(const Vector&,int);
	Vector(int,double *,int);
	Vector(const Matrix&,int);
	
	~Vector();
	int size() const
		{
		return l;
		}
	double getelement(int p) const
		{
		if(p>l+s-1 || p<s)error("bad subscript");
		return(vals[p-s]);
		}
	void setelement(int p,double d)
		{
		if(p>l+s-1 || p<s)error("bad subscript");
		vals[p-s]=d;
		}
	double elem(int p) const
		{
		return(vals[p-s]);
		}
	void selem(int p,double d)
		{
		vals[p-s]=d;
		}
	double& operator[](int i) const
		{
		if(i>l+s-1 || i<s)error("bad subscript");
		return vals[i-s];
		}
	Vector& operator= (const Vector&);
	Vector& operator+=(const Vector&);
	Vector& operator-=(const Vector&);
	Vector& operator*=(double);
	friend Vector operator+ (const Vector&,const Vector&);
	friend Vector operator- (const Vector&,const Vector&);
	friend double operator* (const Vector&,const Vector&);
	friend Vector operator* (const Vector&,double);
	friend Vector operator* (double,const Vector&);
	friend int operator==(const Vector&,const Vector&);
	friend int operator!=(const Vector&,const Vector&);
	friend void swap(Vector&,Vector&);
};

void print(const Vector&,int);



