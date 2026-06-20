/* Copyright (c) 1986, Greg McGary */
static char sccsid[] = "@(#)scan-c.c	1.1 86/10/09";

#include	"bool.h"
#include	<stdio.h>
#include	<stdlib.h>
#include	"string.h"
#include	"id.h"
#include	"extern.h"

char * getCId(FILE *inFILE,int *flagP);
void setCArgs(char *lang,int op,char *arg);

static void clrCtype(char *chars,int type);
static void setCtype(char *chars,int type);


#define	I1	0x0001	/* 1st char of an identifier [a-zA-Z_] */
#define	DG	0x0002	/* decimal digit [0-9] */
#define	NM	0x0004	/* extra chars in a hex or long number [a-fA-FxXlL] */
#define	C1	0x0008	/* C comment introduction char: / */
#define	C2	0x0010	/* C comment termination  char: * */
#define	Q1	0x0020	/* single quote: ' */
#define	Q2	0x0040	/* double quote: " */
#define	ES	0x0080	/* escape char: \ */
#define	NL	0x0100	/* newline: \n */
#define	EF	0x0200	/* EOF */
#define	SK	0x0400	/* Make these chars valid for names within strings */

/*
	character class membership macros:
*/
#define	ISDIGIT(c)	((rct)[c]&(DG))		/* digit */
#define	ISNUMBER(c)	((rct)[c]&(DG|NM))	/* legal in a number */
#define	ISEOF(c)	((rct)[c]&(EF))		/* EOF */
#define	ISID1ST(c)	((rct)[c]&(I1))		/* 1st char of an identifier */
#define	ISIDREST(c)	((rct)[c]&(I1|DG))	/* rest of an identifier */
#define	ISSTRKEEP(c)	((rct)[c]&(I1|DG|SK))	/* keep contents of string */
/*
	The `BORING' classes should be skipped over
	until something interesting comes along...
*/
#define	ISBORING(c)	(!((rct)[c]&(EF|NL|I1|DG|Q1|Q2|C1)))	/* fluff */
#define	ISCBORING(c)	(!((rct)[c]&(EF|C2)))	/* comment fluff */
#define	ISQ1BORING(c)	(!((rct)[c]&(EF|NL|Q1|ES)))	/* char const fluff */
#define	ISQ2BORING(c)	(!((rct)[c]&(EF|NL|Q2|ES)))	/* quoted str fluff */

static short idctype[] = {

	EF,

	/*      0       1       2       3       4       5       6       7   */
	/*    -----   -----   -----   -----   -----   -----   -----   ----- */

	/*000*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*010*/	0,	0,	NL,	0,	0,	0,	0,	0,
	/*020*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*030*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*040*/	0,	0,	Q2,	0,	0,	0,	0,	Q1,
	/*050*/	0,	0,	C2,	0,	0,	0,	0,	C1,
	/*060*/	DG,	DG,	DG,	DG,	DG,	DG,	DG,	DG,
	/*070*/	DG,	DG,	0,	0,	0,	0,	0,	0,
	/*100*/	0,	I1|NM,	I1|NM,	I1|NM,	I1|NM,	I1|NM,	I1|NM,	I1,
	/*110*/	I1,	I1,	I1,	I1,	I1|NM,	I1,	I1,	I1,
	/*120*/	I1,	I1,	I1,	I1,	I1,	I1,	I1,	I1,
	/*130*/	I1|NM,	I1,	I1,	0,	ES,	0,	0,	I1,
	/*140*/	0,	I1|NM,	I1|NM,	I1|NM,	I1|NM,	I1|NM,	I1|NM,	I1,
	/*150*/	I1,	I1,	I1,	I1,	I1|NM,	I1,	I1,	I1,
	/*160*/	I1,	I1,	I1,	I1,	I1,	I1,	I1,	I1,
	/*170*/	I1|NM,	I1,	I1,	0,	0,	0,	0,	0,

	/*200*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*210*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*220*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*230*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*240*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*250*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*260*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*270*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*300*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*310*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*320*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*330*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*340*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*350*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*360*/	0,	0,	0,	0,	0,	0,	0,	0,
	/*370*/	0,	0,	0,	0,	0,	0,	0,	0,

};

static bool eatUnder = TRUE;

/*
	Grab the next identifier the C source
	file opened with the handle `inFILE'.
	This state machine is built for speed, not elegance.
*/
char *
getCId(FILE *inFILE,int *flagP)
{
	static char	idBuf[BUFSIZ];
	static bool	newLine = TRUE;
	register short	*rct = &idctype[1];
	register int	c;
	register char	*id = idBuf;

top:
	c = getc(inFILE);

	if (ISEOF(c))
	{
		newLine = TRUE;
		return NULL;
	}

	if (newLine) {
		newLine = FALSE;
		if (c != '#')
			goto next;
		while (ISBORING(c))
		{
			c = getc(inFILE);

			if (ISEOF(c))
			{
				newLine = TRUE;
				return NULL;
			}
		}

		if (!ISID1ST(c))
			goto next;
		id = idBuf;
		*id++ = c;
		while (ISIDREST(c = getc(inFILE)))
			*id++ = c;
		if (ISEOF(c))
		{
			newLine = TRUE;
			return NULL;
		}
		*id = '\0';
		if (strcmp(idBuf, "include") == 0) {
			while (c != '"' && c != '<')
			{
				c = getc(inFILE);

				if (ISEOF(c))
				{
					newLine = TRUE;
					return NULL;
				}
			}

			id = idBuf;
			*id++ = c = getc(inFILE);

			if (ISEOF(c))
			{
				newLine = TRUE;
				return NULL;
			}

			while ((c = getc(inFILE)) != '"' && c != '>')
			{
				if (ISEOF(c))
				{
					newLine = TRUE;
					return NULL;
				}

				*id++ = c;
			}

			*id = '\0';
			*flagP = IDN_STRING;
			return idBuf;
		}
		if (strncmp(idBuf, "if", 2) == 0
		|| strcmp(idBuf, "define")  == 0
		|| strcmp(idBuf, "elif")  == 0
		|| strcmp(idBuf, "pragma")  == 0
		|| strcmp(idBuf, "line")  == 0
		|| strcmp(idBuf, "error")  == 0
		|| strcmp(idBuf, "undef")   == 0)
			goto next;
		while (c != '\n')
		{
			c = getc(inFILE);

			if (ISEOF(c))
			{
				newLine = TRUE;
				return NULL;
			}
		}
		newLine = TRUE;
		goto top;
	}

next:
	while (ISBORING(c))
	{
		c = getc(inFILE);

		if (ISEOF(c))
		{
			newLine = TRUE;
			return NULL;
		}
	}

	switch (c)
	{
	case '"':
		id = idBuf;
		*id++ = c = getc(inFILE);

		if (ISEOF(c))
		{
			newLine = TRUE;
			return NULL;
		}

		for (;;) {
			while (ISQ2BORING(c))
			{
				*id++ = c = getc(inFILE);

				if (ISEOF(c))
				{
					newLine = TRUE;
					return NULL;
				}
			}

			if (c == '\\') {
				*id++ = c = getc(inFILE);

				if (ISEOF(c))
				{
					newLine = TRUE;
					return NULL;
				}

				continue;
			} else if (c != '"')
				goto next;
			break;
		}
		*--id = '\0';
		id = idBuf;
		while (ISSTRKEEP(*id))
			id++;
		if (*id || id == idBuf) {
			c = getc(inFILE);

			if (ISEOF(c))
			{
				newLine = TRUE;
				return NULL;
			}

			goto next;
		}
		*flagP = IDN_STRING;
		if (eatUnder && idBuf[0] == '_' && idBuf[1])
			return &idBuf[1];
		else
			return idBuf;

	case '\'':
		c = getc(inFILE);

		if (ISEOF(c))
		{
			newLine = TRUE;
			return NULL;
		}
		for (;;) {
			while (ISQ1BORING(c))
			{
				c = getc(inFILE);

				if (ISEOF(c))
				{
					newLine = TRUE;
					return NULL;
				}
			}
			if (c == '\\') {
				c = getc(inFILE);

				if (ISEOF(c))
				{
					newLine = TRUE;
					return NULL;
				}

				continue;
			} else if (c == '\'') {
				c = getc(inFILE);

				if (ISEOF(c))
				{
					newLine = TRUE;
					return NULL;
				}
			}
			goto next;
		}

#ifdef pogo
#endif /* AMIGA */

	case '/':
		c = getc(inFILE);

		if (ISEOF(c))
		{
			newLine = TRUE;
			return NULL;
		}

		if (c == '/')	/* Introduces a C++ style comment. */
		{
			for (;;)
			{
				c = getc(inFILE);

				if(ISEOF(c))
				{
					newLine = TRUE;
					return NULL;
				}

				if(c == '\n')
				{
					newLine = TRUE;
					goto top;
				}
			}
		}
		else
		{
			if (c != '*')
				goto next;
		}

		c = getc(inFILE);

		if (ISEOF(c))
		{
			newLine = TRUE;
			return NULL;
		}

		for (;;) {
			while (ISCBORING(c))
			{
				c = getc(inFILE);

				if (ISEOF(c))
				{
					newLine = TRUE;
					return NULL;
				}
			}

			if ((c = getc(inFILE)) == '/') {
				c = getc(inFILE);

				if (ISEOF(c))
				{
					newLine = TRUE;
					return NULL;
				}

				goto next;
			} else if (ISEOF(c)) {
				newLine = TRUE;
				return NULL;
			}
		}

	case '\n':
		newLine = TRUE;
		goto top;

	default:
		if (ISEOF(c)) {
			newLine = TRUE;
			return NULL;
		}
	name:
		id = idBuf;
		*id++ = c;
		if (ISID1ST(c)) {
			*flagP = IDN_NAME;
			while (ISIDREST(c = getc(inFILE)))
				*id++ = c;
		} else if (ISDIGIT(c)) {
			*flagP = IDN_NUMBER;
			while (ISNUMBER(c = getc(inFILE)))
				*id++ = c;
		} else
			fprintf(stderr, "junk: `\\%3o'", c);
		if (ISEOF(c))
		{
			newLine = TRUE;
			return NULL;
		}
		ungetc(c, inFILE);
		*id = '\0';
		*flagP |= IDN_LITERAL;
		return idBuf;
	}
}

static void
setCtype(char *chars,int type)
{
	short		*rct = &idctype[1];

	while (*chars)
		rct[*chars++] |= type;
}
static void
clrCtype(char *chars,int type)
{
	short		*rct = &idctype[1];

	while (*chars)
		rct[*chars++] &= ~type;
}

extern char	*MyName;
static void
usage(char *lang)
{
	fprintf(stderr, "Usage: %s does not accept %s scanner arguments\n", MyName, lang);
	exit(1);
}
static char *cDocument[] =
{
"The C scanner arguments take the form -Sc<arg>, where <arg>",
"is one of the following: (<cc> denotes one or more characters)",
"  (+|-)u . . . . (Do|Don't) strip a leading `_' from ids in strings.",
"  -s<cc> . . . . Allow <cc> in string ids.",
NULL
};
void
setCArgs(char *lang,int op,char *arg)
{
	if (op == '?') {
		document(cDocument);
		return;
	}
	switch (*arg++)
	{
	case 'u':
		eatUnder = (op == '+');
		break;
	case 's':
		setCtype(arg, SK);
		break;
	default:
		if (lang)
			usage(lang);
		break;
	}
}
