/*
 *	This program takes two files of numerically sorted labels,
 *	and merges them to the standard output.
 *	The lines should be of the form <VALUE> <LABEL> <SPACE(S)>.
 *	In most cases, duplicates will be filtered out.
 */

#include <stdio.h>

#define DEBUG
#define FINAL_OUTPUT

char line1[80];
char line2[80];

char *name1;
char *name2;

long value1, value2;

#ifdef DEBUG
FILE *dbgchn;
#endif

#define negabs(x)	(x>0? -x: x)

int freadln(file, line)
register FILE *file;
register char *line;
{
	register int ch = ' ';
	char *linepos = line;

	while ((line == linepos) && (ch != EOF)) {	/* Skip empty lines */
		while ((ch = getc(file)) != '\n' && (ch != EOF))
			*linepos++ = ch;
	}

	*linepos = '\0';
#ifdef DEBUG
	{
		int filenr = (line == line1)? 1 : 2;
		fprintf(dbgchn, "%d read: `%s'\n", filenr, line);
	}
#endif

	return ch == EOF;
}

int oldscanline(file, line, name, value)	/* Name first */
FILE *file;
char *line;
char **name;
long *value;
{
	register char *ch = line;

	if ( freadln(file, line) == 0 ) {
		while (*ch == ' ')	ch++;	/* Find beginning of label */
		*name = ch;					/* Return it */
		while (*ch != ' ')	ch++;	/* Find end of label */
		*ch = '\0';					/* Null-terminate it */
		if (sscanf(ch+1, "%lx", value) == 1) {	/* Skip name */
#ifdef DEBUG2
			fprintf(dbgchn, "value = %8lx\n", *value);
#endif
			return 0;				/* OK */
		}
	}
	return 1;						/* BAD */
}

int scanline(file, line, name, value)	/* Value first */
FILE *file;
char *line;
char **name;
long *value;
{
	register char *ch = &line[8];	/* Skip 8 digit value */

	if ( freadln(file, line) == 0 ) {
		while (*ch == ' ')	ch++;	/* Find beginning of label */
		*name = ch;					/* Return it */
		while (*ch != ' ')	ch++;	/* Find end of label */
		*ch = '\0';					/* Null-terminate it */
		if (sscanf(line, "%lx", value) == 1) {
#ifdef DEBUG2
			fprintf(dbgchn, "value = %8lx\n", *value);
#endif
			return 0;				/* OK */
		}
	}
	return 1;						/* BAD */
}

#ifdef FINAL_OUTPUT
int writeline(name, value)
char *name;
long value;
{
	int i;

	if (value & 0xFFFF0000)
		printf("%08lx  ", value);
	else if ((short) value & 0xFF00)
		printf("    %04lx  ", value);
	else
		printf("      %02lx  ", value);

	printf(name);

	if (negabs(value) > -65536) {
		printf("  ");
		for (i=strlen(name); i < 30; i++)
			putchar('_');
		printf(" %6ld", value);
	}

	putchar('\n');

	return 0;
}

#else

int writeline(name, value)
char *name;
long value;
{
	return printf("%-30s  %lx\n", name, value);
}

#endif

main(argc, argv)
int argc;
char *argv[];
{
	FILE *file1, *file2, *file;

	int comp;
	int finished = 0;

	if (argc != 3) {
		fprintf(stderr, "Usage: %s file1 file2\n", argv[0]);
		exit(1);
	}

	if ((file1 = fopen(argv[1], "r")) == NULL) {
		fprintf(stderr, "Cannot open %s\n", argv[1]);
		exit(1);
	}

	if ((file2 = fopen(argv[2], "r")) == NULL) {
		fprintf(stderr, "Cannot open %s\n", argv[2]);
		exit(1);
	}

#ifdef DEBUG
	/* Note: When used with ConMan 0.98B, this opens TWO windows */
	/*       but closes only one. */
	dbgchn = fopen("CON:50/0/540/160/File IO Info", "w");
#endif

	if (scanline(file1, line1, &name1, &value1))
		finished = 1;
	else if (scanline(file2, line2, &name2, &value2))
		finished = 2;

	while (finished == 0) {
		comp = strcmp(name1, name2);
		if ((value1 < value2) || 
			((value1 == value2) && (comp < 0))) {	/* First value is lower */
			writeline(name1, value1);
			if (scanline(file1, line1, &name1, &value1))
				finished = 1;
		} else if ((value1 > value2) ||
			((value1 == value2) && (comp > 0))) {	/* Second value is lower */
			writeline(name2, value2);
			if (scanline(file2, line2, &name2, &value2))
				finished = 2;
		} else {
			/* Exact duplicates. Print one and drop both */
			writeline(name1, value1);
			if (scanline(file1, line1, &name1, &value1))
				finished = 1;
			else if (scanline(file2, line2, &name2, &value2))
				finished = 2;
		}	/* End comparison */
	}	/* End while */

#ifdef DEBUG
	fprintf(dbgchn, "***** FINISHED WITH FILE %d *****\n", finished);
#endif

	if (finished == 1)	file = file2;
	else				file = file1;

	while (!scanline(file, line1, &name1, &value1))	/* Wind up rest of other file */
		writeline(name1, value1);

	fclose(file1);
	fclose(file2);

#ifdef DEBUG
	fclose(dbgchn);
#endif
	fprintf(stderr, "Terminated successfully\n");
}
