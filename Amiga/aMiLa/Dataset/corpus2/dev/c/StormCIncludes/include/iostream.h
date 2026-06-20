#ifndef _INCLUDE_IOSTREAM_H
#define _INCLUDE_IOSTREAM_H

/*
**  $VER: iostream.h 1.2 (7.2.97)
**  StormC Release 3.0
**
**  '(C) Copyright 1995/96/97 Haage & Partner Computer GmbH'
**	 All Rights Reserved
*/

#ifndef __cplusplus
#error <iostream.h> must be compiled in C++ mode.
#pragma +
#endif

#ifndef _INCLUDE_STDDEF_H
#include <stddef.h>
#endif

#ifndef _INCLUDE_STRING_H
#include <string.h>
#endif

#ifndef _INCLUDE_STDIO_H
#include <stdio.h>
#endif

class streambuf;
class ostream;
class istream;

typedef long streamoff;

class streampos
{
public:
	streampos() { offset = 0; }
	streampos(long o) { offset = o; }
	streampos &operator=(const streampos &s) { offset = s.offset; return *this; }
	operator long() { return offset; }
	fpos_t* fpos() { return (fpos_t *) &offset; }
	long offset;
};

class ios
{
public:
	enum io_state
	{
		goodbit  = 0x00,
		eofbit   = 0x01,
		failbit  = 0x02,
		badbit   = 0x04,
		hardfail = 0x80
	};
	enum open_mode
	{
		in        = 0x01,
		out       = 0x02,
		ate       = 0x04,
		app       = 0x08,
		trunc     = 0x10,
		nocreate  = 0x20,
		noreplace = 0x40,
		binary    = 0x80
	};
	enum seek_dir
	{
		beg = -1,
		cur = 0,
		end = 1
	};
	enum
	{
		skipws     = 0x00000001,
		left       = 0x00000002,
		right      = 0x00000004,
		internal   = 0x00000008,
		dec        = 0x00000010,
		oct        = 0x00000020,
		hex        = 0x00000040,
		showbase   = 0x00000080,
		showpoint  = 0x00000100,
		uppercase  = 0x00000200,
		showpos    = 0x00000400,
		scientific = 0x00000800,
		fixed      = 0x00001000,
		unitbuf    = 0x00002000,
		stdio      = 0x00004000,
		firstfreebit = 0x00008000
	};

	ios(streambuf *b) { init(b); }
	virtual ~ios() { }
	unsigned long flags() { return aFlags; }
	unsigned long flags(unsigned long f)
	{
		unsigned long r = aFlags;
		aFlags = f;
		return r;
	}
	unsigned long setf(unsigned long f)
	{
		unsigned long r = aFlags & f;
		aFlags |= f;
		return r;
	}
	unsigned long unsetf(unsigned long f)
	{
		unsigned long r = aFlags & f;
		aFlags &= ~f;
		return r;
	}
	unsigned long setf(unsigned long f, unsigned long m)
	{
		unsigned long r = aFlags & m;
		aFlags &= ~m;
		aFlags |= (f & m);
		return r;
	}
	int width() { return aWidth; }
	int width(int w)
	{
		int r = aWidth;
		aWidth = w;
		return r;
	}
	ostream *tie() { return aTie; }
	ostream *tie(ostream *o)
	{
		ostream *r = aTie;
		aTie = o;
		return r;
	}
	char fill() { return aFill; }
	char fill(char f)
	{
		char r = aFill;
		aFill = f;
		return r;
	}
	int precision() { return aPrecision; }
	int precision(int p)
	{
		int r = aPrecision;
		aPrecision = p;
		return r;
	}
	int rdstate() { return aState; }
	int eof() { return aState & eofbit; }
	int fail() { return aState & (failbit | badbit | hardfail); }
	int bad() { return aState & (badbit | hardfail); }
	int good() { return aState == 0; }
	void clear(int i = 0) { aState = i; }
	operator void *() { return fail() ? 0 : this; }
	int operator !() { return fail(); }
	streambuf* rdbuf() { return aBuf; }
	static void sync_with_stdio() { }
	static unsigned long bitalloc();
	static int xalloc();
	long &iword(int i) { return userword(i); }
	void *&pword(int i) { return (void *&) userword(i); }

	static const unsigned long basefield;
	static const unsigned long adjustfield;
	static const unsigned long floatfield;

protected:
	ios() { init(NULL); }
	void init(streambuf *);

	streambuf *aBuf;
	int aState;
	ostream *aTie;
	short int aPrecision;
	char aFill;
	short aWidth;
	unsigned long aFlags;

private:
	ios(const ios &);
	ios &operator =(const ios &);

	static unsigned long aNextBit;
	static int aNextWord;

	long *aUser;
	int aNuser;
	long &userword(int i);
};

ios &dec(ios &);
ios &hex(ios &);
ios &oct(ios &);
ios &showbase(ios &);
ios &hidebase(ios &);

class streambuf
{
protected:
	streambuf();
	streambuf(char *, int);
public:
	virtual ~streambuf();
	int in_avail() { return aGTop - aGPos; }
	int out_waiting() { return aPPos - aPBase; }
	int sbumpc()
	{
		return (in_avail() > 0 || underflow() != EOF) ? *((unsigned char *) (aGPos++)) : EOF;
	}
	int sgetc()
	{
		return in_avail() > 0 ? *((unsigned char *) aGPos) : underflow();
	}
	int sgetn(char *, int);
	int snextc()
	{
		return sbumpc() == EOF ? EOF : sgetc();
	}
	void stossc() { sbumpc(); }
	int sputbackc(char c)
	{
		return aGPos > aBase ? (*((unsigned char *) --aGPos) = c) : pbackfail(c);
	}
	int sputc(int c)
	{
		return aPPos < aTop ? (*((unsigned char *) aPPos++) = c) : overflow(c);
	}
	int sputn(const char *,int);
	virtual int sync()
	{
		return (in_avail() != 0 || out_waiting() != 0) ? EOF : 0;
	}
	virtual streampos seekoff(streamoff, ios::seek_dir, int = ios::in|ios::out)
	{
		return (streampos) EOF;
	}
	virtual streampos seekpos(streampos p, int mode = ios::in|ios::out)
	{
		return seekoff(streamoff(p),ios::beg,mode);
	}
	virtual streambuf *setbuf(char *, size_t);
protected:
	void setbuffer(char *, unsigned long n, int dynamic = 0);
	int allocate()
	{
		return (aBase == NULL && !aUnbuffered) ? (doallocate() == EOF ? EOF : 1) : 0;
	}
	int unbuffered() { return aUnbuffered; }
	void unbuffered(int i) { aUnbuffered = i; }
	virtual int overflow(int = EOF);
	virtual int underflow();
	virtual int xsputn(const char *,int);
	virtual int xsgetn(char *,int);
	virtual int pbackfail(int) { return EOF; }
	virtual int doallocate();
	void pbump(int i) { aPPos += i; }
	void gbump(int i) { aGPos += i; }
protected:
	char *aBase;
	char *aTop;
	char *aPBase;
	char *aPPos;
	char *aGPos;
	char *aGTop;
	short int aAlloc;
	short int aUnbuffered;
};

class istream : virtual public ios
{
public:
	istream(streambuf *b) : ios(b) { }
	virtual ~istream() { }
public:
	int ipfx(int need = 0);
	void isfx() { };
	istream &operator >>(unsigned char *s) { return (*this) >> (char *) s; }
	istream &operator >>(signed char *s) { return (*this) >> (char *) s; }
	istream &operator >>(char *);
	istream &operator >>(char &);
	istream &operator >>(unsigned char &c) { return (*this) >> (char &) c; }
	istream &operator >>(signed char &c) { return (*this) >> (char &) c; }
	istream &operator >>(short &);
	istream &operator >>(unsigned short &);
	istream &operator >>(int &);
	istream &operator >>(unsigned int &);
	istream &operator >>(long &);
	istream &operator >>(unsigned long &);
	istream &operator >>(float &);
	istream &operator >>(double &);
	istream &operator >>(long double &);
	istream &operator >>(streambuf *);
	istream &operator >>(istream &(*f)(istream &))
	{
		return (*f)(*this);
	}
	istream &operator >>(ios &(*f)(ios &))
	{
		(*f)(*this);
		return *this;
	}
	istream &get(char *, int, char = '\n');
	istream &get(unsigned char *s, int n, char delimiter = '\n')
	{
		return get((char *) s, n, delimiter);
	}
	istream &get(signed char *s, int n, char delimiter = '\n')
	{
		return get((char *) s, n, delimiter);
	}
	istream &getline(char *, int, char = '\n');
	istream &getline(unsigned char *s, int n, char delimiter = '\n')
	{
		return getline((char *) s, n, delimiter);
	}
	istream &getline(signed char *s, int n, char delimiter = '\n')
	{
		return getline((char *) s, n, delimiter);
	}
	istream &get(streambuf &, char = '\n');
	istream &get(signed char &c)
	{
		return get((char &) c);
	}
	istream &get(unsigned char &c)
	{
		return get((char &) c);
	}
	istream &get(char &);
	int get();
	istream &ignore(int = 1, int = EOF);
	istream &read(unsigned char *s, int n)
	{
		return read((char *) s, n);
	}
	istream &read(signed char *s, int n)
	{
		return read((char *) s, n);
	}
	istream &read(char *, int);
	int gcount() { return aLastCount; }
	int peek();
	istream &putback(char c)
	{
		if (good())
			rdbuf()->sputbackc(c);
		return *this;
	}
	int sync()
	{
		return rdbuf()->sync();
	}
	istream &seekg(streampos);
	istream &seekg(streamoff, ios::seek_dir);
	streampos tellg()
	{
		return rdbuf()->seekoff(0,ios::cur,ios::in);
	}
protected:
	istream() : ios() { }
private:
	istream(const istream &);
	istream &operator =(const istream &);
	int aLastCount;
};

istream &ws(istream &);

class ostream : virtual public ios
{
public:
	ostream(streambuf *b) : ios(b) { }
	virtual ~ostream() { }
public:
	int opfx();
	void osfx();
	ostream &operator <<(signed char c)
	{
		return (*this) << (char) c;
	}
	ostream &operator <<(unsigned char c)
	{
		return (*this) << (char) c;
	}
	ostream &operator <<(char);
	ostream &operator <<(const unsigned char *s)
	{
		return (*this) << (const char *) s;
	}
	ostream &operator <<(const signed char *s)
	{
		return (*this) << (const char *) s;
	}
	ostream &operator <<(const char *);
	ostream &operator <<(short i)
	{
		return (*this) << (long) i;
	}
	ostream &operator <<(unsigned short i)
	{
		return (*this) << (unsigned long) i;
	}
	ostream &operator <<(int i)
	{
		return (*this) << (long) i;
	}
	ostream &operator <<(unsigned int i)
	{
		return (*this) << (unsigned long) i;
	}
	ostream &operator <<(long);
	ostream &operator <<(unsigned long);
	ostream &operator <<(float);
	ostream &operator <<(double);
	ostream &operator <<(long double d)
	{
		// StormC: long double == double
		return (*this) << (double) d;
	}
	ostream &operator <<(void *);
	ostream &operator <<(streambuf *);
	ostream &operator <<(ostream &(*f)(ostream &))
	{
		return (*f)(*this);
	}
	ostream &operator <<(ios &(*f)(ios &))
	{
		(*f)(*this);
		return *this;
	}
	ostream &put(char c)
	{
		if (opfx() != EOF)
			rdbuf()->sputc(c);
		return *this;
	}
	ostream &write(const signed char *s, int n)
	{
		return write((const char *) s,n);
	}
	ostream &write(const unsigned char *s, int n)
	{
		return write((const char *) s,n);
	}
	ostream &write(const char *s, int n)
	{
		if (opfx() != EOF)
			rdbuf()->sputn(s,n);
		return *this;
	}
	ostream &flush()
	{
		rdbuf()->sync();
		return *this;
	}
	streampos tellp()
	{
		return rdbuf()->seekoff(0,ios::cur,ios::out);
	}
	ostream &seekp(streampos, ios::seek_dir = ios::beg);
	ostream &seekp(streamoff, ios::seek_dir);
protected:
	ostream() : ios() { }
private:
	ostream(const ostream &);
	ostream &operator =(const ostream &);
};

ostream &flush(ostream &);
ostream &endl(ostream &);
ostream &ends(ostream &);

class iostream : public virtual ios, public ostream, public istream
{
public:
	iostream(streambuf *b) : ios(b), istream(), ostream() { }
	virtual ~iostream() { }
protected:
	iostream() : ios(), istream(), ostream() { }
private:
	iostream(const iostream &);
	iostream &operator =(const iostream &);
};

class istream_withassign : public virtual ios, public istream
{
public:
	istream_withassign() : ios(0) { }
	istream_withassign(streambuf *b) : ios(b) { }
	istream_withassign(istream &i) : ios(i.rdbuf()) { }
	virtual ~istream_withassign() { }
	istream_withassign& operator =(streambuf *b) { init(b); return *this; }
	istream_withassign& operator =(istream &i) { init(i.rdbuf()); return *this; }
private:
	istream_withassign(const istream_withassign &);
	istream_withassign &operator =(const istream_withassign &);
};

class ostream_withassign : public virtual ios, public ostream
{
public:
	ostream_withassign() : ios(0) { }
	ostream_withassign(streambuf *b) : ios(b) { }
	ostream_withassign(ostream &o) : ios(o.rdbuf()) { }
	virtual ~ostream_withassign() { }
	ostream_withassign &operator =(streambuf *b) { init(b); return *this; }
	ostream_withassign &operator =(ostream &o) { init(o.rdbuf()); return *this; }
private:
	ostream_withassign(const ostream_withassign &);
	ostream_withassign &operator =(const ostream_withassign &);
};

class iostream_withassign : public virtual ios, public iostream
{
public:
	iostream_withassign() : ios(0) { }
	iostream_withassign(streambuf *b) : ios(b) { }
	iostream_withassign(ios &s) : ios(s.rdbuf()) { }
	virtual ~iostream_withassign() { }
	iostream_withassign &operator =(streambuf *b) { init(b); return *this; }
	iostream_withassign &operator =(ios &s) { init(s.rdbuf()); return *this; }
private:
	iostream_withassign(const iostream_withassign &);
	iostream_withassign &operator =(const iostream_withassign &);
};

extern istream_withassign& cin;
extern ostream_withassign& cout;
extern ostream_withassign& cerr;
extern ostream_withassign& clog;

#endif
