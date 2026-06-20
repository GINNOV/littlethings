#ifndef INC_H
#define INC_H

#include <stdlib.h>
#include <limits.h>

#ifndef ULONG_MAX
#define ULONG_MAX 4294967295  /* max value for unsigned long int  */
#endif

#ifndef UWORD_MAX
#define UWORD_MAX 65535
#endif

/*types:*/
#ifndef _ULONG
#define _ULONG
typedef unsigned long  ulong;
#endif /* gcc really doesn't like this guy 
        
        The C language is missing the critical '#ifntypedef' token 

        */  

typedef unsigned short uword;
typedef unsigned char  ubyte;
typedef int bool;

/*macros:*/

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifdef sizeofpointer
#undef sizeofpointer
#endif

#define sizeofpointer sizeof(void *)

#ifdef smartfree
#undef smartfree
#endif

#define smartfree(m) if (m) { free(m); m = NULL; }
#define SmartFree(m,s) smartfree(m)

#define DoublePaddedSize(a) ((((a)-1)/8 + 1)*8)
/*doublepaddedsize(originalsize)*/
#define PaddedSize(a) ((((a)-1)/4 + 1)*4)
/*paddedsize(originalsize)*/
#define WordPaddedSize(a) ((((a)-1)/2 + 1)*2)
/*wordpaddedsize(originalsize)*/

#define IsOdd(a) ( ((a)/2)*2 != (a) )
#define SignOf(a) (((a) < 0) ? -1 : 1)

#ifndef max
#define max(a,b) ((a)>(b)?(a):(b))
#endif

#ifndef min
#define min(a,b) ((a)<(b)?(a):(b))
#endif

#ifndef CLOCKS_PER_SEC /* { */
#ifndef CLK_TCK
#define CLK_TCK 1000
#endif
#define CLOCKS_PER_SEC CLK_TCK
#endif /* CLOCKS_PER_SEC } */

#ifndef errputs
#define errputs(str) fprintf(stderr,"%s\n",str)
#endif

#endif /*INC_H*/
