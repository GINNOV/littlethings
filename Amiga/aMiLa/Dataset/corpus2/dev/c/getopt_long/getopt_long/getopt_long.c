/*
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 1, or (at your option)
 *  any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 */

#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <proto/dos.h>
#include "getopt.h"

#ifndef __GNUC__
int optind = 1;
#endif
#ifndef __cplusplus
char *optarg = NULL;
#endif

int getopt_long (int argc, char * const argv[], const char *options, const struct option *long_options, int *opt_index)
{
static struct RDArgs *rdargs;
static STRPTR argstring;
static LONG *argarray;
static int argind;

#ifndef __MORPHOS__
if (DOSBase->dl_lib.lib_Version<36)
	return -1;
#endif
if (rdargs==NULL)
	{
	int i, l=3;
	for (i=0; long_options[i].name; i++)
		l+=strlen(long_options[i].name);
	argstring=(STRPTR) calloc(2*l+6*i, 1);
	argarray=(LONG *) calloc(i+1, sizeof(long));
	for (i=0; long_options[i].name; i++)
		{
		char *name=strdup(long_options[i].name);
		int j=-1;
		while (name[++j])
			name[j]=toupper(name[j]);
		strcat(argstring, name);
		strcat(argstring, "=--");
		strcat(argstring, long_options[i].name);
		switch (long_options[i].has_arg)
			{
			case no_argument:
				strcat(argstring, "/S");
				break;
			case required_argument:
				strcat(argstring, "/K");
				break;
			case optional_argument:
				;
			}
		strcat(argstring, ",");
		}
	strcat(argstring, "/M");/* "file..." */
	rdargs=ReadArgs(argstring, argarray, NULL);
	}
if (long_options[argind].name==0 || !rdargs)
	{
	FreeArgs(rdargs);
	free(argarray);
	free(argstring);
	return -1;
	}
*opt_index=argind++;
if (argarray[*opt_index]==-1)
	optarg=NULL;
else
	{
	optarg=(char *) argarray[*opt_index];
	if (*optarg==0)
		return '?';
	optind++;
	}
optind++;
return long_options[*opt_index].flag ? 0 : long_options[*opt_index].val;
}

#ifdef TEST

#include <stdio.h>

int
main (argc, argv)
     int argc;
     char **argv;
{
  int c;
  int digit_optind = 0;

  while (1)
    {
      int this_option_optind = optind ? optind : 1;
      int option_index = 0;
      static struct option long_options[] =
      {
	{"add", 1, 0, 0},
	{"append", 0, 0, 0},
	{"delete", 1, 0, 0},
	{"verbose", 0, 0, 0},
	{"create", 0, 0, 0},
	{"file", 1, 0, 0},
	{0, 0, 0, 0}
      };

      c = getopt_long (argc, argv, "abc:d:0123456789",
		       long_options, &option_index);
      if (c == -1)
	break;

      switch (c)
	{
	case 0:
	  printf ("option %s", long_options[option_index].name);
	  if (optarg)
	    printf (" with arg %s", optarg);
	  printf ("\n");
	  break;

	case '0':
	case '1':
	case '2':
	case '3':
	case '4':
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':
	  if (digit_optind != 0 && digit_optind != this_option_optind)
	    printf ("digits occur in two different argv-elements.\n");
	  digit_optind = this_option_optind;
	  printf ("option %c\n", c);
	  break;

	case 'a':
	  printf ("option a\n");
	  break;

	case 'b':
	  printf ("option b\n");
	  break;

	case 'c':
	  printf ("option c with value `%s'\n", optarg);
	  break;

	case 'd':
	  printf ("option d with value `%s'\n", optarg);
	  break;

	case '?':
	  break;

	default:
	  printf ("?? getopt returned character code 0%o ??\n", c);
	}
    }

  if (optind < argc)
    {
      printf ("non-option ARGV-elements: ");
      while (optind < argc)
	printf ("%s ", argv[optind++]);
      printf ("\n");
    }

  exit (0);
}

#endif /* TEST */
