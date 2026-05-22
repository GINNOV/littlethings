/*****************************************************************
 * outline.c
 *
 * Copyright 1999, Clark Cooper
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the license contained in the
 * COPYING file that comes with the expat distribution.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * Read an XML document from standard input and print an element
 * outline on standard output.
 */


#include <stdio.h>
#ifndef AMIGA
#include <expat.h>
#else
#include <exec/types.h>
#include <exec/memory.h>
#include <expat/expat.h>
#include <proto/exec.h>
#include <proto/expat.h>

struct Library *ExpatBase = NULL;

#endif

#define BUFFSIZE	8192

char Buff[BUFFSIZE];

int Depth;


static void
start(void *data, const char *el, const char **attr)
{
  int i;

  for (i = 0; i < Depth; i++)
    printf("  ");

  printf("%s", el);

  for (i = 0; attr[i]; i += 2) {
    printf(" %s='%s'", attr[i], attr[i + 1]);
  }

  printf("\n");
  Depth++;
}

static void
end(void *data, const char *el)
{
  Depth--;
}

int
main(int argc, char *argv[])
{
  XML_Parser p;
#ifdef AMIGA
  ExpatBase = (APTR) OpenLibrary("expat.library", 0);
  if(!ExpatBase)
  {
    puts("\nCouldn't open expat.library\n");
    exit(20);
  }
#endif
  
  p = XML_ParserCreate(NULL);
  if (! p) {
    fprintf(stderr, "Couldn't allocate memory for parser\n");
#ifdef AMIGA  
      CloseLibrary((APTR) ExpatBase);;
#endif
    exit(-1);
  }

  XML_SetElementHandler(p, start, end);

  for (;;) {
    int done;
    int len;

    len = fread(Buff, 1, BUFFSIZE, stdin);
    if (ferror(stdin)) {
      fprintf(stderr, "Read error\n");
#ifdef AMIGA  
      CloseLibrary((APTR) ExpatBase);;
#endif
      exit(-1);
    }
    done = feof(stdin);

    if (XML_Parse(p, Buff, len, done) == XML_STATUS_ERROR) {
      fprintf(stderr, "Parse error at line %d:\n%s\n",
	      XML_GetCurrentLineNumber(p),
	      XML_ErrorString(XML_GetErrorCode(p)));
#ifdef AMIGA  
      CloseLibrary((APTR) ExpatBase);;
#endif
      exit(-1);
    }

    if (done)
      break;
  }
  
#ifdef AMIGA  
  CloseLibrary((APTR) ExpatBase);
  exit(0);
#else
  return 0;
#endif
  
}

