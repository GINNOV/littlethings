/*

   n2w - Convert numbers to words

   Copyright 2000, Chris F.A. Johnson

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

 */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "getopt.h"
#include "defs.h"
#include "n2w.h"

static struct option const longopts[] =
{
  {"ampersand", no_argument, 0, '&'},
  {"dollars", no_argument, 0, '$'},
  {"units", required_argument, 0, 'u'},
  {"nand", no_argument, 0, 'u'},
  {"US", no_argument, 0, 'u'},
  {"help", no_argument, 0, SHOW_USAGE},
  {"verbose", optional_argument, 0, 'V'},
  {"version", no_argument, 0, SHOW_VERSION},
  {0, 0, 0, 0}
};

unsigned int verbose = 0;
char *version_num = "1.0";
char *program_name = "n2w";

void
usage ()
{
  printf ("\n");
  printf ("   Usage: %s [OPTIONS] num [num ...]\n", program_name);
  printf ("\n");
  printf ("   OPTIONS:\n");
  printf ("\t-$, --dollars       display as dollars and cents\n");
  printf ("\t-N n                use \"n\" instead of \"minus\" before negative numbers\n");
  printf ("\t-U units, --units=units\t  print \"units\" after number\n");
  printf ("\t-u,  --nand, --US   do not use \"and\" after \"hundred\", etc.\n");
  printf ("\t-&,  --ampersand    use \"&\" instead of \"and\" after \"hundred\", etc.\n");
  printf ("\n");
  printf ("\t?    --help         display this help and exit\n");
  printf ("\t-v,  --verbose      set verbose mode on\n");
  printf ("\t-Vn, --verbose=n    set level of verbosity\n");
  printf ("\t     --version      output version information and exit\n");
  printf ("\n");
  printf ("   BUGS:\n");
  printf ("\tNo warning is given if number supplied exceeds the limit\n");
  printf ("\n");
  printf ("\tCopyright 2000 Chris F.A. Johnson\n");
  printf ("\n");
}

int
main (argc, argv)
     int argc;
     char *argv[];
{
  int c;
  char *optstring;
  n2w_and_text = N2W_AND_TEXT;

  if ( (argc > 1) && (argv[1][0] == '?') )
    {
      usage();
      return 0;
    }

  optstring = "$&N:U:uvV:";

  while ((c = getopt_long (argc, argv, optstring, longopts, 0)) != EOF)
    {
      switch (c)
	{
	case '&':
	  n2w_and_text = "&";
	  break;

	case '$':
	  n2w_unit_string = "dollars";
	  break;

	case 'N':
	  n2w_negstring = optarg;
	  break;

	case 'u':
	  n2w_and_text = "";
	  break;

	case 'U':
	  n2w_unit_string = optarg;
	  break;

	case 'v':
	  verbose = VERBOSE_DEFAULT;
	  break;

	case 'V':
	  if (optarg)
	    {
	      verbose = atoi (optarg);
	    }
	  else
	    {
	      verbose = VERBOSE_DEFAULT;
	    }
	  break;

	case SHOW_USAGE:
	  usage ();
	  return 0;
	  break;

	case SHOW_VERSION:
	  printf ("%s %s\n", program_name, version_num);
	  printf ("Copyright 2000 Chris F.A. Johnson\n");
	  return 0;
	  break;

	default:
	  usage ();
	  return 0;

	}
    }
  argc -= optind;
  argv += optind;

  while (argc)
    {
      char * words = n2w ( strtod (argv[0], NULL));

      if (words && words[0])
	{
	  words[0] = toupper (words[0]);
	}
      else
	{
	  break;
	}

      printf (" %s\n", words);
      --argc;
      ++argv;
    }

  return 0;
}

