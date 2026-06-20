/*
 *  This is a flex input file but should be edited in -*-C-*- mode
 *
 *  C++2LaTeX: Produce prettyprinted LaTeX files from  C++ or C sources.
 *  Copyright (C) 1990 Norbert Kiesel
 *
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
 *  Norbert Kiesel
 *  RWTH Aachen / Institut f. Informatik III
 *  Ahornstr. 55
 *  D-5100 Aachen
 *  West Germany
 *
 *  Phone:  +49 241 80-7266
 *  EUNET:  norbert@rwthi3.uucp
 *  USENET: ...!mcvax!unido!rwthi3!norbert
 *  X.400:  norbert@rwthi3.informatik.rwth-aachen.de
 *
 *  Please contact me for any bugs you find in this code or any
 *  improvements! I'd also be very happy to get feedback where and
 *  how frequently this program is used (just drop a little mail :-).
 *
 *  ---------------------------------------------------------------------------------
 *
 *  C++2LaTeX 2.0: Produce even more prettyprinted LaTeX files from C++ or C sources.
 *
 *  Copyright (C) 1991 Joerg Heitkoetter
 *  Systems Analysis Research Group, University of Dortmund
 *  (heitkoet@gorbi.informatik.uni-dortmund.de).
 *
 */

#ifdef LATTICE
extern int tabtobrace, tabtotab, cplusplus_mode, complete_file, piped;
extern int aligntoright, header;
extern char *font_size, *indentation, *comment_font, *header_font;
extern char *cpp_font, *string_font, *keyword_font;

/* Prototypes for functions defined in main.c */
void substitute(char *input);
void indent(char *blanks);
int main(int argc, char **argv);
void usage(char *name);
#endif

void
substitute (input)
char   *input;
{
	while (*input) {
		switch (*input) {
			case '_':
			case '&':
			case '#':
			case '$':
			case '%':
			case '{':
			case '}':
				printf ("\\%c", *input);
				break;
			case '+':
			case '=':
			case '<':
			case '>':
				printf ("$%c$", *input);
				break;
			case '*':
				printf ("$\\ast$");
				break;
			case '|':
				printf ("$\\mid$");
				break;
			case '\\':
				printf ("$\\backslash$");
				break;
			case '^':
				printf ("$\\wedge$");
				break;
			case '~':
				printf ("$\\sim$");
				break;
			default:
				printf ("%c", *input);
				break;
		}
		input++;
	}
}

void
indent (blanks)
char   *blanks;
{
	int     i;

	i = 0;
	while (*blanks) {
		if (*blanks == ' ') {
			i++;
		} else {	       /* *blanks == '\t' */
			while (++i % tabtotab);
		}
		blanks++;
	}
	printf ("\\hspace*{%d\\indentation}", i);
}

#ifdef LATTICE
#include <stdio.h>
#endif

#include "getopt.h"
#include <string.h>
#include <fcntl.h>
#include <ctype.h>
#include <time.h>

extern char *version_string;

static struct option opts[] =
{
	{"ansi-c", 0, 0, 'a'},
	{"complete-file", 0, 0, 'c'},
	{"font-size", 1, 0, 's'},
	{"indentation", 1, 0, 'i'},
	{"header", 0, 0, 'h'},
	{"piped", 0, 0, 'p'},
	{"alignment", 0, 0, 'n'},      /* turn off comment alignment  -joke */
	{"output", 1, 0, 'o'},
	{"tabstop", 1, 0, 'T'},
	{"brace-tab", 1, 0, 'b'},      /* added new tabtobrace  -joke */
	{"comment-font", 1, 0, 'C'},
	{"string-font", 1, 0, 'S'},
	{"keyword-font", 1, 0, 'K'},
	{"header-font", 1, 0, 'H'},
	{"cpp-font", 1, 0, 'P'},
	{"version", 0, 0, 'V'},
	{0, 0, 0, 0}
};

char *program_name;


main (argc, argv)
int     argc;
char  **argv;
{
	int     c;
	int     index;
	int     i;
	int     has_filename;
	char   *input_name;
	char   *output_name;
/*	char   *program_name;*/
	long    now;
	char   *today;
	char   *malloc ();

	input_name = "Standard Input";
	output_name = 0;

	now = time (0);
	today = ctime (&now);

	program_name = strrchr (argv[0], '/');
	if (program_name == NULL) {    /* no pathname */
		program_name = argv[0];
	} else {
		program_name++;
	}

 /* simple heuristic: '+' in name means C++ */
	cplusplus_mode = (strchr (program_name, '+') != 0);

	if (argc == 1)
		usage (program_name);  /* added exit with usage  -joke */

	while ((c = getopt_long (argc, argv,
				 "acpno:s:i:b:hT:C:H:S:K:P:V", opts, &index))
			!= EOF) {
		if (c == 0) {	       /* Long option */
			c = opts[index].val;
		}
		switch (c) {
			case 'a':
				cplusplus_mode = 0;
				break;
			case 'c':
				complete_file = 1;
				break;
			case 'o':
				if (piped) {
					fprintf (stderr,
						 "%s: Can't use {-p,+pipe} and {-o,+output} together\n",
						 program_name);
					exit (5);
				}
				output_name = optarg;
				break;
			case 'n':
				aligntoright = 0;
				break;
			case 's':
				font_size = optarg;
				break;
			case 'i':
				indentation = optarg;
				break;
			case 'b':
				tabtobrace = atoi (optarg);
				break;
			case 'T':
				tabtotab = atoi (optarg);
				break;
			case 'p':
				if (output_name != 0) {
					fprintf (stderr,
						 "%s: Can't use {-p,+pipe} and {-o,+output} together\n",
						 program_name);
					exit (5);
				}
				piped = 1;
				break;
			case 'h':
				header = 1;
				complete_file = 1;	/* header implies
							 * complete-file */
				break;
			case 'C':
				comment_font = optarg;
				break;
			case 'H':
				header_font = optarg;
				break;
			case 'P':
				cpp_font = optarg;
				break;
			case 'S':
				string_font = optarg;
				break;
			case 'K':
				keyword_font = optarg;
				break;
			case 'V':
				fprintf (stderr, "%s\n", version_string);
				break;
			default:
				usage (program_name);
		}
	}
	has_filename = (argc - optind == 1);
	if (has_filename) {	       /* last argument is input file name */
		input_name = argv[optind];
		if (freopen (input_name, "r", stdin) == NULL) {
			fprintf (stderr, "%s: Can't open `%s' for reading\n",
				 program_name, input_name);
			exit (2);
		}
	}
	if ((output_name == 0) && !piped) {
		char   *tmp;
		if (has_filename) {
			tmp = strrchr (input_name, '/');
			if (tmp == 0) {	/* plain filename */
				tmp = input_name;
			} else {
				tmp++;
			}
		} else {
			tmp = program_name;
		}
#ifdef LATTICE
        output_name = (char *)malloc (strlen (tmp) + 4);
#else
		output_name = malloc (strlen (tmp) + 4);
#endif
		if (output_name == 0) {
			fprintf (stderr, "%s: Virtual memory exhausted\n", program_name);
			exit (3);
		}
		strcpy (output_name, tmp);
		strcat (output_name, ".tex");
	}
	if (!piped) {
		if (freopen (output_name, "w", stdout) == NULL) {
			fprintf (stderr, "%s: Can't open `%s' for writing\n",
				 program_name, output_name);
			exit (3);
		}
	}
	printf ("\
%%\n\
%% This file was automatically produced at %.24s by\n\
%% %s", today, program_name);
	for (i = 1; i < argc; i++) {
		printf (" %s", argv[i]);
	}
	if (!has_filename) {
		printf (" (from Standard Input)");
	}
	printf ("\n%%\n");
	if (complete_file) {
		if (header) {
			if (strcmp (font_size, "10") == 0) {
				printf ("\\documentstyle[fancyheadings]{article}\n");
			} else {
				printf ("\\documentstyle[%spt,fancyheadings]{article}\n",
					font_size);
			}
		} else {
			if (strcmp (font_size, "10") == 0) {
				printf ("\\documentstyle{article}\n");
			} else {
				printf ("\\documentstyle[%spt]{article}\n", font_size);
			}
		}
		printf ("\\setlength{\\textwidth}{16cm}\n");
		printf ("\\setlength{\\textheight}{23cm}\n");
		printf ("\\setlength{\\hoffset}{-2cm}\n");
		printf ("\\setlength{\\voffset}{-2cm}\n");
		if (header) {
			printf ("\\lhead{\\%s ", header_font);
			substitute (input_name);
			printf ("}");
			printf ("\\rhead{\\rm\\thepage}\n");
			printf ("\\cfoot{}\n");
			printf ("\\addtolength{\\headheight}{14pt}\n");
			printf ("\\pagestyle{fancy}\n");
		}
		printf ("\\begin{document}\n");
	}
	printf ("\\expandafter\\ifx\\csname indentation\\endcsname\\relax%\n");
	printf ("\\newlength{\\indentation}\\fi\n");
	printf ("\\setlength{\\indentation}{%s}\n", indentation);
	printf ("\\begin{flushleft}\n");
	yylex ();
	printf ("\\end{flushleft}\n");
	if (complete_file) {
		printf ("\\end{document}\n");
	}
	exit (0);
}

void
usage (name)
char   *name;
{
	fprintf (stderr, "%s\n", version_string);
	fprintf (stderr, "\
Usage: %s [options] file\n\n\
Options:\n\
	[-a]			[-b]\n\
	[-c]			[-h]\n\
	[-i length]		[-n]\n\
	[-o file]		[-p]\n\
	[-s fontsize]		[-C font]\n\
	[-H font]		[-K font]\n\
	[-P font]		[-S font]\n\
	[-T tabulatorwidth]	[-V]\n\
	\n\
	[+ansi-c]		[+brace-tab indentation]\n\
	[+complete-file]	[+header]\n\
	[+indentation length]	[+no-alignment]\n\
	[+output file]		[+pipe]\n\
	[+font-size size]	[+comment-font font]\n\
	[+keyword-font font]	[+cpp-font font]\n\
	[+header-font font]	[+string-font font]\n\
	[+tabstop width]	[+version]\n", name);
	exit (1);
}
