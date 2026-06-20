/**
***  MemPools:	malloc() replacement using standard Amiga pool functions.
***  Copyright	(C)  1994    Jochen Wiedmann
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
***  This is a very simple timing program.
***
***
***  Computer:	Amiga 1200
***
***  Compilers: Dice 3.01
***		SAS/C 6.3
***		gcc 2.6.1
***
***
***  Author:	Jochen Wiedmann
***		Am Eisteich 9
***	  72555 Metzingen
***		Germany
***
***		Phone: (0049) 7123 14881
***		Internet: jochen.wiedmann@uni-tuebingen.de
**/




/*
    Include files and compiler specific stuff
*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE (!FALSE)
#endif

#if defined(__GNUC__)
#define stricmp strcasecmp
#define strncimp strncasecmp
#endif





void Usage(void)

{ fprintf(stderr, "Usage: TimeProg ProgToTime [Number]\n\n");
  fprintf(stderr, "ProgToTime:  Program to execute\n");
  fprintf(stderr, "Number:      How much to execute ProgToTime (Default: 1).\n");
  exit(5);
}





int main(int argc, char *argv[])

{ int NumTimings = 1;
  int NumTimingsSeen = FALSE;
  char *TimeProg = NULL;
  int i;
  int days, hours, mins, secs, clocks;
  clock_t clk;

  for (i = 1;  i < argc;  i++)
  { if (stricmp(argv[i], "?") == 0      ||
	stricmp(argv[i], "-h") == 0     ||
	stricmp(argv[i], "help") == 0   ||
	stricmp(argv[i], "--help") == 0)
    { Usage();
    }
    else if (TimeProg == NULL)
    { TimeProg = argv[i];
    }
    else if (NumTimingsSeen)
    { Usage();
    }
    else
    { if (!(NumTimings = atoi(argv[i])))
      { Usage();
      }
      NumTimingsSeen = TRUE;
    }
  }

  clk = clock();
  for (i = 0;  i < NumTimings;  ++i)
  { int result;

    if (result = system(TimeProg))
    { fprintf(stderr, "Error while executing %s\n", TimeProg);
      exit(10);
    }
  }
  clk = clock() - clk;

  clocks = clk % CLK_TCK;
  clk /= CLK_TCK;
  secs = clk % 60;
  clk /= 60;
  mins = clk % 60;
  clk /= 60;
  hours = clk % 24;
  clk /= 24;
  days = clk;

  if (days)
  { printf("%d days, ", days);
  }
  if (days || hours)
  { printf("%d hours, ", hours);
  }
  printf("%d:%d and %d clocks\n", mins, secs, clocks);

  exit(0);
}
