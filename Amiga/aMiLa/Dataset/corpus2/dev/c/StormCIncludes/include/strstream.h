#ifndef _INCLUDE_STRSTREAM_H
#define _INCLUDE_STRSTREAM_H

/*
**  $VER: strstream.h 1.0 (25.1.96)
**  StormC Release 1.0
**
**  '(C) Copyright 1995 Haage & Partner Computer GmbH'
**	 All Rights Reserved
*/

#ifndef __cplusplus
#error <strstream.h> must be compiled in C++ mode.
#pragma +
#endif

#ifndef _INCLUDE_STDDEF_H
#include <stddef.h>
#endif

#ifndef _INCLUDE_IOSTREAM_H
#include <iostream.h>
#endif

class strstreambuf : public streambuf
{
public:
	strstreambuf();
	strstreambuf(int);
	strstreambuf(void *(*)(long), void (*)(void *));
	strstreambuf(char *, int, char * = 0);
	~strstreambuf();
	void freeze(int = 1);
	char *str();
	int pcount();
	virtual streampos seekoff(streamoff, ios::seek_dir, int = ios::in|ios::out);
	virtual streampos seekpos(streampos, int = ios::in|ios::out);
	virtual streambuf *setbuf(char * , size_t);
	virtual int sync();
protected:
	virtual int underflow();
	virtual int overflow(int = EOF);
	virtual int doallocate();
private:
	short int aUnlimited;
	short int aFrozen;
	short int aDynamic;
	int aPuddle;
	void *(*alloc_func)(long);
	void (*free_func)(void *);
};

class strstream : public iostream
{
public:
	strstream();
	strstream(char *, int, int);
	~strstream() { }
	strstreambuf *rdbuf() { return &buffer; }
	char *str() { return buffer.str(); }
	int pcount() { return buffer.pcount(); }
private:
	strstream(const strstream &);
	strstream &operator= (const strstream &);
	strstreambuf buffer;
};

class istrstream : public istream
{
public:
	istrstream(char *p);
	istrstream(char *p, int l);
	~istrstream() { }
	strstreambuf *rdbuf() { return &buffer; }
private:
	istrstream(const istrstream &);
	istrstream &operator=(const istrstream &);
	strstreambuf buffer;
};

class ostrstream : public ostream
{
public:
	ostrstream();
	ostrstream(char *s, int l, int = ios::out);
	~ostrstream() { }
	strstreambuf *rdbuf() { return &buffer; }
	char *str() { return buffer.str(); }
	int pcount() { return buffer.pcount(); }
private:
	ostrstream(const ostrstream &);
	ostrstream &operator=(const ostrstream &);
	strstreambuf buffer;
};

#endif
