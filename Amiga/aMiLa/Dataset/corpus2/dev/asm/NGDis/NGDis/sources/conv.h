#ifndef _conv_h_included
#define _conv_h_included

// Heck what a class :)

#include <strstream>
#include <iostream>
#include <string>
//

class Int2NN {
protected:
	ostrstream _str;
	//Int2NN() {}
	virtual ~Int2NN() {}
public:

	//

	char* str_f() { return _str.str(); }
	const char* str() { const char* s = _str.str(); _str.freeze(0); return s; }
	void freeze( int i=0 ) { _str.freeze(i); }
	ostrstream& rdbuf() { return _str; }

	// Friend functions..

	friend ostream& operator<<( ostream& o, Int2NN& h ) {
		o << h._str.str(); h._str.freeze(0); 
		return o;
	}
	//friend string& operator<<( string& o, Int2NN& h ) {
	//	o += h._str.str(); h._str.freeze(0); 
	//	return o;
	//}
	friend string& operator+=( string& o, Int2NN& h ) {
		o += h._str.str(); h._str.freeze(0); 
		return o;
	}
	friend string& operator<<( string& o, Int2NN& h ) {
		o.assign(h._str.str()); h._str.freeze(0); 
		return o;
	}

	// Operators..

	Int2NN& operator<<( char i ) {
		_str.seekp(0,ios::beg);
		_str << (static_cast<short>(i) & 0xff) << ends;
		return *this;
	}
	Int2NN& operator<<( short i ) {
		_str.seekp(0,ios::beg);
		_str << i << ends;
		return *this;
	}
	Int2NN& operator<<( int i ) {
		_str.seekp(0,ios::beg);
		_str << i << ends;
		return *this;
	}
	Int2NN& operator<<( long i ) {
		_str.seekp(0,ios::beg);
		_str << i << ends;
		return *this;
	}
	Int2NN& operator<<( unsigned char i ) {
		_str.seekp(0,ios::beg);
		_str << (static_cast<unsigned short>(i) & 0xff) << ends;
		return *this;
	}
	Int2NN& operator<<( unsigned short i ) {
		_str.seekp(0,ios::beg);
		_str << i << ends;
		return *this;
	}
	Int2NN& operator<<( unsigned int i ) {
		_str.seekp(0,ios::beg);
		_str << i << ends;
		return *this;
	}
	Int2NN& operator<<( unsigned long i ) {
		_str.seekp(0,ios::beg);
		_str << i << ends;
		return *this;
	}

	//
};





//

class Int2Hex : public Int2NN {
public:
	Int2Hex( bool u=true ) {
		u ? _str.flags(ios::hex | ios::uppercase | ios::internal) : _str.flags(ios::hex);
	}
	Int2Hex( int i, bool u=true ) {
		u ? _str.flags(ios::hex | ios::uppercase) : _str.flags(ios::hex);
		_str << i << ends;
	}
	Int2Hex( long i, bool u=true )  {
		u ? _str.flags(ios::hex | ios::uppercase) : _str.flags(ios::hex);
		_str << i << ends;
	}
	Int2Hex( short i, bool u=true )  {
		u ? _str.flags(ios::hex | ios::uppercase) : _str.flags(ios::hex);
		_str << i << ends;
	}
	Int2Hex( char i, bool u=true ) {
		u ? _str.flags(ios::hex | ios::uppercase) : _str.flags(ios::hex);
		_str << (static_cast<short>(i) & 0xff) << ends;
	}
	Int2Hex( unsigned int i, bool u=true ) {
		u ? _str.flags(ios::hex | ios::uppercase) : _str.flags(ios::hex);
		_str << i << ends;
	}
	Int2Hex( unsigned long i, bool u=true ) {
		u ? _str.flags(ios::hex | ios::uppercase) : _str.flags(ios::hex);
		_str << i << ends;
	}
	Int2Hex( unsigned short i, bool u=true ) {
		u ? _str.flags(ios::hex | ios::uppercase) : _str.flags(ios::hex);
		_str << i << ends;
	}
	Int2Hex( unsigned char i, bool u=true ) {
		u ? _str.flags(ios::hex | ios::uppercase) : _str.flags(ios::hex);
		_str << (static_cast<unsigned short>(i) & 0xff) << ends;
	}
	~Int2Hex() {}
};

// Other massive class :)

class Int2Dec : public Int2NN {
public:
	Int2Dec( bool u=true) {
		u ? _str.flags(ios::dec | ios::uppercase) : _str.flags(ios::dec);
	}
	Int2Dec( int i, bool u=true ) {
		u ? _str.flags(ios::dec | ios::uppercase) : _str.flags(ios::dec);
		_str << i << ends;
	}
	Int2Dec( long i, bool u=true )  {
		u ? _str.flags(ios::dec | ios::uppercase) : _str.flags(ios::dec);
		_str << i << ends;
	}
	Int2Dec( short i, bool u=true )  {
		u ? _str.flags(ios::dec | ios::uppercase) : _str.flags(ios::dec);
		_str << i << ends;
	}
	Int2Dec( char i, bool u=true ) {
		u ? _str.flags(ios::dec | ios::uppercase) : _str.flags(ios::dec);
		_str << static_cast<short>(i) << ends;
	}
	Int2Dec( unsigned int i, bool u=true ) {
		u ? _str.flags(ios::dec | ios::uppercase) : _str.flags(ios::dec);
		_str << i << ends;
	}
	Int2Dec( unsigned long i, bool u=true ) {
		u ? _str.flags(ios::dec | ios::uppercase) : _str.flags(ios::dec);
		_str << i << ends;
	}
	Int2Dec( unsigned short i, bool u=true ) {
		u ? _str.flags(ios::dec | ios::uppercase) : _str.flags(ios::dec);
		_str << i << ends;
	}
	Int2Dec( unsigned char i, bool u=true ) {
		u ? _str.flags(ios::dec | ios::uppercase) : _str.flags(ios::dec);
		_str << static_cast<unsigned short>(i) << ends;
	}
	~Int2Dec() {}
};

#endif