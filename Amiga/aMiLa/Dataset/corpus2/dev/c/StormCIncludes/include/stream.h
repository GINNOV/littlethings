#ifndef _INCLUDE_STREAM_H
#define _INCLUDE_STREAM_H

/*
**  $VER: stream.h 1.0 (25.1.96)
**  StormC Release 1.0
**
**  '(C) Copyright 1995 Haage & Partner Computer GmbH'
**	 All Rights Reserved
*/

#ifndef _INCLUDE_IOSTREAM_H
#include <iostream.h>
#endif

#ifndef _INCLUDE_IOMANIP_H
#include <iomanip.h>
#endif

#if 0
#ifndef _INCLUDE_STDIOSTREAM_H
#include <stdiostream.h>
#endif
#endif

#ifndef _INCLUDE_FSTREAM_H
#include <fstream.h>
#endif

char *form(char * format, ... );

inline char *oct(long l, int size = 0) 
{ 
	return form("%*lo",size,l); 
}

inline char *hex(long l, int size = 0) 
{
	return form("%*lx",size,l); 
}

inline char *dec(long l, int size = 0 ) 
{ 
	return form("%*ld",size,l); 
}

inline char *chr(int i, int size = 0 )
{
	return form("%*c",size,i); 
}

inline char *str(char *s, int size = 0 ) 
{
	return form("%*s",size,s); 
}

inline istream &WS(istream &i)
{
	return i >> ws; 
}

inline void eatwhite(istream &i) 
{
	i >> ws;
}

static const int input = (ios::in);
static const int output = (ios::out);
static const int append = (ios::app);
static const int atend = (ios::ate);
static const int _good = (ios::goodbit);
static const int _bad = (ios::badbit);
static const int _fail = (ios::failbit);
static const int _eof = (ios::eofbit);

typedef ios::io_state state_value;

#endif
