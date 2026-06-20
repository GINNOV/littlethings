/**
***  MemPools:  malloc() replacement using standard Amiga pool functions.
***  Copyright  (C)  1994    Jochen Wiedmann
***
***  This program is free software; you can redistribute it and/or modify
***  it under the terms of the GNU General Public License as published by
***  the Free Software Foundation; either version 2 of the License, or
***  (at your option) any later version.
***
***  This program is distributed in the hope that it will be useful,
***  but WITHOUT ANY WARRANTY; without even the implied warranty of
***  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
***  GNU General Public License for more details.
***
***  You should have received a copy of the GNU General Public License
***  along with this program; if not, write to the Free Software
***  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
***
***
***  This is a very simple timing and test program for the memory
***  functions of stdlib.h.
***
***
***  Computer:  Amiga 1200
***
***  Compilers: Dice 3.01
***             SAS/C 6.3
***             gcc 2.6.1
***
***
***  Author:    Jochen Wiedmann
***             Am Eisteich 9
***       72555 Metzingen
***             Germany
***
***             Phone: (0049) 7123 14881
***             Internet: jochen.wiedmann@uni-tuebingen.de
**/




/*
    Include files and compiler specific stuff
*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE (!FALSE)
#endif

#if defined(__GNUC__)
#define stricmp strcasecmp
#define strnicmp strncasecmp
#endif





/**
***  It is important that these numbers are powers of 2, as
***  they are used as arguments for rangerand()!
**/
#define NUMALLOCS 8192
#define MAXSIZE 128



int rangerand(int max)

{ int result = rand();

  while(result >= max)
  { result = result >> 1;
  }
  return(result);
}


typedef void *APTR;



int __MemPoolPuddleSize = 16384;


int main(int argc, char *argv[])

#ifdef DEBUG
{ char *ptr;

  if (!(ptr = malloc(6)))
  { fprintf(stderr, "Cannot allocate memory.\n");
    exit(20);
  }

  if (argc > 1)
  { fprintf(stderr, "Checking library: Freeing buffer twice.\n");
    free(ptr);
    free(ptr);
  }
  else
  { fprintf(stderr, "Checking library: Extending array boundaries.\n");
    ptr[7] = '\0';
    free(ptr);
  }

  fprintf(stderr, "Library check failed: free() returned.\n");
  fprintf(stderr, "Be sure, that library is compiled with -DDEBUG.\n");
  exit(10);
}
#else
{ int i, j;
  int malloc_cnt = 0, calloc_cnt = 0, realloc_cnt = 0;
  int malloc_free = 0, calloc_free = 0, realloc_free = 0;
  APTR *malloc_table;
  APTR *calloc_table;
  APTR *realloc_table;
  int VerboseMode = FALSE;
   
  srand(27);

  for (i = 1;  i < argc;  i++)
  { if ((stricmp(argv[i], "?") == 0       ||
	 stricmp(argv[i], "help") == 0    ||
	 stricmp(argv[i], "-h") == 0))
    { printf("Usage: TimeMem [VERBOSE}\n");
      exit(5);
    }
    if (stricmp(argv[i], "verbose") == 0    ||
	stricmp(argv[i], "-v") == 0)
    { VerboseMode = TRUE;
    }
    else
    { fprintf(stderr, "Unknown option: %s\n", argv[i]);
    }
  }

  if (!(malloc_table = calloc(NUMALLOCS, sizeof(APTR)))  ||
      !(calloc_table = calloc(NUMALLOCS, sizeof(APTR)))  ||
      !(realloc_table = calloc(NUMALLOCS, sizeof(APTR))))
  { perror("malloc");
  }

  for (i = 0;  i < NUMALLOCS;  i++)
  {
    /**
    ***  Call malloc()
    **/
    if (!(malloc_table[i] = malloc(rangerand(MAXSIZE)+1)))
    { perror("malloc");
      exit(10);
    }
    malloc_cnt++;

    /**
    ***  Call calloc()
    **/
    if (!(calloc_table[i] = calloc(rangerand(MAXSIZE)+1, 1)))
    { perror("calloc");
      exit(10);
    }
    calloc_cnt++;

    /**
    ***  Call realloc()
    **/
    j = rangerand(NUMALLOCS);
    if (!(realloc_table[j] = realloc(realloc_table[j], rangerand(MAXSIZE)+1)))
    { perror("malloc");
      exit(10);
    }
    realloc_cnt++;

    /**
    ***  Free a block of memory obtained with malloc().
    **/
    j = rangerand(NUMALLOCS);
    if (malloc_table[j])
    { free(malloc_table[j]);
      malloc_table[j] = NULL;
      malloc_free++;
    }

    /**
    ***  Free a block of memory obtained with calloc().
    **/
    j = rangerand(NUMALLOCS);
    if (calloc_table[j])
    { free(calloc_table[j]);
      calloc_table[j] = NULL;
      calloc_free++;
    }

    /**
    ***  Free a block of memory obtained with realloc().
    **/
    j = rangerand(NUMALLOCS);
    if (realloc_table[j])
    { free(realloc_table[j]);
      realloc_table[j] = NULL;
      realloc_free++;
    }
  }

  if (VerboseMode)
  { printf("TimeMem statistics:\n\n");
    printf("Calls to malloc(): %d\n", malloc_cnt);
    printf("Calls to calloc(): %d\n", calloc_cnt);
    printf("Calls to realloc(): %d\n", realloc_cnt);
    printf("Calls to free() for blocks obtained by malloc(): %d\n", malloc_free);
    printf("Calls to free() for blocks obtained by calloc(): %d\n", calloc_free);
    printf("Calls to free() for blocks obtained by realloc(): %d\n", realloc_free);
  }

  exit(0);
}
#endif
