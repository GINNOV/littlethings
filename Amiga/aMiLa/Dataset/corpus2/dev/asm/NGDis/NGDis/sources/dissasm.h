#ifndef _dissasm_h_included
#define _dissasm_h_included

//

class Mem {
private:
	const unsigned char* _m;
	int _b;
public:
	Mem( const unsigned char* m, int b = 0 ) {
		_m = m;
		_b = b;
	}
	~Mem() {}

	const unsigned char* getMem() const { return _m; }
	int getBase() const { return _b; }
	void inc( int i ) { _m += i; _b += i; }
	Mem& operator++( int i ) { _m++; _b++; return *this; }
	Mem& operator++() { ++_m; ++_b; return *this; }
	Mem& operator--( int i ) { _m--; _b--; return *this; }
	Mem& operator--() {	--_m; --_b; return *this; }
	Mem& operator+=( int i ) { _m += i; _b += i; return *this; }
	Mem& operator-=( int i ) { _m -= i; _b -= i; return *this; }
	unsigned char operator[]( int i ) const { return _m[i]; }
	unsigned char operator*() const { return *_m; }
};

//

class Dissasm {
public:
	virtual ~Dissasm() {}
	virtual int decode( Mem& )=0;
	virtual const char* getFirst()=0;
	virtual const char* getSecond()=0;
	virtual const char* getName()=0;
};




#endif
