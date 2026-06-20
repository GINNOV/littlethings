#ifndef __Font_h__
#define __Font_h__

/* Copyright (c) Mark J. Kilgard, 1994. */

/* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. */
#ifdef WIN32
#include <windows.h>
#endif

#include <GL/gl.h>

typedef struct {
  GLsizei width;
  GLsizei height;
  GLint xorig;
  GLint yorig;
  GLint advance;
  GLubyte *bitmap;
} BitmapCharRec, *BitmapCharPtr;

typedef struct {
  char *name;
  int num_chars;
  int first;
  BitmapCharPtr *ch;
} BitmapFontRec, *BitmapFontPtr;

#endif /* __Font_h__ */
