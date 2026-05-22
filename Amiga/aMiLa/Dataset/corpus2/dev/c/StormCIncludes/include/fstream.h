#ifndef _INCLUDE_FSTREAM_H
#define _INCLUDE_FSTREAM_H

/*
**  $VER: fstream.h 1.01 (7.2.97)
**  StormC Release 3.0
**
**  '(C) Copyright 1995/96/97 Haage & Partner Computer GmbH'
**	 All Rights Reserved
*/

#ifndef __cplusplus
#error <fstream.h> must be compiled in C++ mode.
#pragma +
#endif

#ifndef _INCLUDE_STDDEF_H
#include <stddef.h>
#endif

#ifndef _INCLUDE_IOSTREAM_H
#include <iostream.h>
#endif

class filebuf : public streambuf
{
public:
	filebuf();
	virtual ~filebuf();
	int is_open() { return aFile != NULL; }
	filebuf *open(const char *, int);
	filebuf *close();
	virtual streampos seekoff(streamoff, ios::seek_dir, int = ios::in|ios::out);
	virtual streampos seekpos(streampos, int = ios::in|ios::out);
	virtual streambuf *setbuf(char *, size_t);
	virtual int sync();
protected:
	virtual int doallocate();
	virtual int overflow(int = EOF);
	virtual int underflow();
	virtual int xsputn(const char *, int);
	virtual int xsgetn(char *, int);
	virtual int pbackfail(int);
protected:
	void *aFile;
	int aGetPos;
	int aOpenMode;
};

class fstream : public iostream
{
public:
	fstream();
	fstream(const char *, int);
	virtual ~fstream() { }
	void open(const char *, int);
	void close();
	void setbuf(char *, size_t);
	filebuf *rdbuf() { return &buffer; }
private:
	fstream(const fstream &);
	fstream &operator =(const fstream &);
	filebuf buffer;
};

class ifstream : public istream
{
public:
	ifstream();
	ifstream(const char *, int = ios::in);
	virtual ~ifstream() { }
	void open(const char *, int = ios::in);
	void close();
	void setbuf(char *, size_t);
	filebuf *rdbuf() { return &buffer; }
private:
	ifstream(const ifstream &);
	ifstream &operator =(const ifstream &);
	filebuf buffer;
};

class ofstream : public ostream
{
public:
	ofstream();
	ofstream(const char *, int = ios::out);
	virtual ~ofstream() { }
	void open(const char *, int = ios::out);
	void close();
	void setbuf(char *, size_t);
	filebuf *rdbuf() { return &buffer; }
private:
	ofstream(const ofstream &);
	ofstream &operator =(const ofstream &);
	filebuf buffer;
};

#endif
