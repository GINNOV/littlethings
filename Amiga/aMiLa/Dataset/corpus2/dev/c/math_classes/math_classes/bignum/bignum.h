
#ifndef __GNUC__
enum bool {false,true};
#endif


class Bignum
	{
	int length;
	char *digits;
	bool negative;		//true for minus
public:
	Bignum();
	Bignum(const Bignum&);
	Bignum(int);
	Bignum(double);
	Bignum(char *);
	~Bignum();
	operator int();
	operator double();
	Bignum& operator=(const Bignum&);
	friend int operator==(const Bignum&,const Bignum&);
	friend int operator!=(const Bignum&,const Bignum&);
	friend int operator<(const Bignum&,const Bignum&);
	friend int operator>(const Bignum&,const Bignum&);
	friend int operator<=(const Bignum&,const Bignum&);
	friend int operator>=(const Bignum&,const Bignum&);
	Bignum& operator+=(const Bignum&);
	Bignum& operator-=(const Bignum&);
	Bignum& operator*=(const Bignum&);
	Bignum& operator/=(const Bignum&);
	friend Bignum operator/(const Bignum&,const Bignum&);
	friend Bignum operator+(const Bignum&,const Bignum&);
	friend Bignum operator-(const Bignum&,const Bignum&);	
	friend Bignum operator*(const Bignum&,const Bignum&);
	friend Bignum operator-(const Bignum&);
	void normalize();
	friend void print(const Bignum&);
	};
	
Bignum abs(Bignum);	

	
	
	