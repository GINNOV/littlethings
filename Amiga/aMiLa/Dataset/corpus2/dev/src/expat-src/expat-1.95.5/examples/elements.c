/* This is simple demonstration of how to use expat. This program
   reads an XML document from standard input and writes a line with
   the name of each element to standard output indenting child
   elements by one tab stop more than their parent element.
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

static void
startElement(void *userData, const char *name, const char **atts)
{
  int i;
  int *depthPtr = userData;
  for (i = 0; i < *depthPtr; i++)
    putchar('\t');
  puts(name);
  *depthPtr += 1;
}

static void
endElement(void *userData, const char *name)
{
  int *depthPtr = userData;
  *depthPtr -= 1;
}

int
main(int argc, char *argv[])
{
  char buf[BUFSIZ];
  XML_Parser parser;
  int done;
  int depth = 0;

#ifdef AMIGA
  ExpatBase = (APTR) OpenLibrary("expat.library", 0);
  if(!ExpatBase)
  {
    puts("\nCouldn't open expat.library\n");
    exit(20);
  }
#endif

  parser = XML_ParserCreate(NULL);
  
  XML_SetUserData(parser, &depth);
  XML_SetElementHandler(parser, startElement, endElement);
  do {
    size_t len = fread(buf, 1, sizeof(buf), stdin);
    done = len < sizeof(buf);
    if (XML_Parse(parser, buf, len, done) == XML_STATUS_ERROR) {
      fprintf(stderr,
	      "%s at line %d\n",
	      XML_ErrorString(XML_GetErrorCode(parser)),
	      XML_GetCurrentLineNumber(parser));
#ifdef AMIGA  
      CloseLibrary((APTR) ExpatBase);;
#endif
      return 1;
    }
  } while (!done);
  XML_ParserFree(parser);
#ifdef AMIGA  
      CloseLibrary((APTR) ExpatBase);;
#endif
  return 0;
}
