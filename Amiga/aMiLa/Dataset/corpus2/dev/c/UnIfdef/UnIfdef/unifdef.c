/*
 *
 *	unifdef - remove ifdef'ed lines
 *
 *	Wishlist:
 *		provide an option which will append the name of the
 *		appropriate symbol after #else's and #endif's
 *
 *		provide an option which will check symbols after
 *		#else's and #endif's to see that they match their
 *		corresponding #ifdef or #ifndef
 *
 */

#include <stdio.h>
#include <ctype.h>
#ifdef ORIGINALCODE	/* And that's how it was folks...  (fnf) */
#include <c_env.h>
#endif

#define BSS
FILE *input;
#ifndef YES
#define YES 1
#define NO  0
#endif
typedef int Bool;

char *progname BSS;
char *filename BSS;
char text BSS;          /* -t option in effect: this is a text file */
char lnblank BSS;       /* -l option in effect: blank deleted lines */
char complement BSS;    /* -c option in effect: complement the operation */

#define MAXSYMS 100
char *sym[MAXSYMS] BSS;     /* symbol name */
char true[MAXSYMS] BSS;     /* -dsym */
char ignore[MAXSYMS] BSS;   /* -idsym or -iusym */
char insym[MAXSYMS] BSS;    /* state: false, inactive, true */
#define SYM_INACTIVE 0      /* symbol is currently inactive */
#define SYM_FALSE    1      /* symbol is currently false */
#define SYM_TRUE     2      /* symbol is currently true  */

char nsyms BSS;
char incomment BSS;         /* inside C comment */

#define QUOTE_NONE   0
#define QUOTE_SINGLE 1
#define QUOTE_DOUBLE 2
char inquote BSS;           /* inside single or double quotes */

int exitstat BSS;
char *skipcomment ();
char *skipquote ();

main (argc, argv)
int argc;
char **argv;
{
    char **curarg;
    register char *cp;
    register char *cp1;
    char ignorethis;

    progname = argv[0][0] ? argv[0] : "unifdef";

    for (curarg = &argv[1]; --argc > 0; curarg++) {
	if (*(cp1 = cp = *curarg) != '-')
	    break;
	if (*++cp1 == 'i') {
	    ignorethis = YES;
	    cp1++;
	}
	else
	    ignorethis = NO;
	if (   (   *cp1 == 'd'
		|| *cp1 == 'u'
	       )
	    && cp1[1] != '\0'
	   ) {
	    if (nsyms >= MAXSYMS) {
		prname ();
		fprintf (stderr, "too many symbols.\n");
		exit (2);
	    }
	    insym[nsyms] = SYM_INACTIVE;
	    ignore[nsyms] = ignorethis;
	    true[nsyms] = *cp1 == 'd' ? YES : NO;
	    sym[nsyms++] = &cp1[1];
	}
	else if (ignorethis)
	    goto unrec;
	else if (strcmp (&cp[1], "t") == 0)
	    text = YES;
	else if (strcmp (&cp[1], "l") == 0)
	    lnblank = YES;
	else if (strcmp (&cp[1], "c") == 0)
	    complement = YES;
	else {
 unrec:
	    prname ();
	    fprintf (stderr, "unrecognized option: %s\n", cp);
	    goto usage;
	}
    }
    if (nsyms == 0) {
 usage:
	fprintf (stderr, "\
Usage: %s [-l] [-t] [-c] [[-dsym] [-usym] [-idsym] [-iusym]]... [file]\n\
    At least one arg from [-d -u -id -iu] is required\n", progname);
	exit (2);
    }

    if (argc > 1) {
	prname ();
	fprintf (stderr, "can only do one file.\n");
    }
    else if (argc == 1) {
	filename = *curarg;
	if ((input = fopen (filename, "r")) != NULL) {
	    pfile();
	    (void) fclose (input);
	}
	else {
	    prname ();
	    fprintf (stderr, "can't open %s\n", *curarg);
	}
    }
    else {
	filename = "[stdin]";
	input = stdin;
	pfile();
    }

    (void) fflush (stdout);
    exit (exitstat);
}

/* types of input lines: */
typedef int Linetype;
#define LT_PLAIN       0   /* ordinary line */
#define LT_TRUE        1   /* a true  #ifdef of a symbol known to us */
#define LT_FALSE       2   /* a false #ifdef of a symbol known to us */
#define LT_OTHER       3   /* an #ifdef of a symbol not known to us */
#define LT_IF          4   /* an #ifdef of a symbol not known to us */
#define LT_ELSE        5   /* #else */
#define LT_ENDIF       6   /* #endif */
#define LT_LEOF        7   /* end of file */
extern Linetype checkline ();

typedef int Reject_level;
Reject_level reject BSS;    /* 0 or 1: pass thru; 1 or 2: ignore comments */
#define REJ_NO          0
#define REJ_IGNORE      1
#define REJ_YES         2

int linenum BSS;    /* current line number */
int stqcline BSS;   /* start of current coment or quote */
char *errs[] = {
#define NO_ERR      0
			"",
#define END_ERR     1
			"",
#define ELSE_ERR    2
			"Inappropriate else",
#define ENDIF_ERR   3
			"Inappropriate endif",
#define IEOF_ERR    4
			"Premature EOF in ifdef",
#define CEOF_ERR    5
			"Premature EOF in comment",
#define Q1EOF_ERR   6
			"Premature EOF in quoted character",
#define Q2EOF_ERR   7
			"Premature EOF in quoted string"
};

/* States for inif arg to doif */
#define IN_NONE 0
#define IN_IF   1
#define IN_ELSE 2

pfile ()
{
    reject = REJ_NO;
    (void) doif (-1, IN_NONE, reject, 0);
    return;
}

doif (thissym, inif, prevreject, depth)
register int thissym;   /* index of the symbol who was last ifdef'ed */
int inif;               /* YES or NO we are inside an ifdef */
Reject_level prevreject;/* previous value of reject */
int depth;              /* depth of ifdef's */
{
    register Linetype lineval;
    register Reject_level thisreject;
    int doret;          /* tmp return value of doif */
    int cursym;         /* index of the symbol returned by checkline */
    int stline;         /* line number when called this time */

    stline = linenum;
    for (;;) {
	switch (lineval = checkline (&cursym)) {
	case LT_PLAIN:
	    flushline (YES);
	    break;

	case LT_TRUE:
	case LT_FALSE:
	    thisreject = reject;
	    if (lineval == LT_TRUE)
		insym[cursym] = SYM_TRUE;
	    else {
		if (reject != REJ_YES)
		    reject = ignore[cursym] ? REJ_IGNORE : REJ_YES;
		insym[cursym] = SYM_FALSE;
	    }
	    if (ignore[cursym])
		flushline (YES);
	    else {
		exitstat = 1;
		flushline (NO);
	    }
	    if ((doret = doif (cursym, IN_IF, thisreject, depth + 1)) != NO_ERR)
		return error (doret, stline, depth);
    	    break;

	case LT_IF:
	case LT_OTHER:
	    flushline (YES);
	    if ((doret = doif (-1, IN_IF, reject, depth + 1)) != NO_ERR)
		return error (doret, stline, depth);
	    break;

	case LT_ELSE:
	    if (inif != IN_IF)
		return error (ELSE_ERR, linenum, depth);
	    inif = IN_ELSE;
	    if (thissym >= 0) {
		if (insym[thissym] == SYM_TRUE) {
		    reject = ignore[thissym] ? REJ_IGNORE : REJ_YES;
		    insym[thissym] = SYM_FALSE;
		}
		else { /* (insym[thissym] == SYM_FALSE) */
		    reject = prevreject;
		    insym[thissym] = SYM_TRUE;
		}
		if (!ignore[thissym]) {
		    flushline (NO);
		    break;
		}
	    }
	    flushline (YES);
	    break;

	case LT_ENDIF:
	    if (inif == IN_NONE)
		return error (ENDIF_ERR, linenum, depth);
	    if (thissym >= 0) {
		insym[thissym] = SYM_INACTIVE;
		reject = prevreject;
		if (!ignore[thissym]) {
		    flushline (NO);
		    return NO_ERR;
		}
	    }
	    flushline (YES);
	    return NO_ERR;

	case LT_LEOF: {
	    int err;
	    err =   incomment
		  ? CEOF_ERR
		  : inquote == QUOTE_SINGLE
		  ? Q1EOF_ERR
		  : inquote == QUOTE_DOUBLE
		  ? Q2EOF_ERR
		  : NO_ERR;
	    if (inif != IN_NONE) {
		if (err != NO_ERR)
		    (void) error (err, stqcline, depth);
		return error (IEOF_ERR, stline, depth);
	    }
	    else if (err != NO_ERR)
		return error (err, stqcline, depth);
	    else
		return NO_ERR;
	    }
	}
    }
}

#define endsym(c) (!isalpha (c) && !isdigit (c) && c != '_')

#define MAXLINE 256
char tline[MAXLINE] BSS;

Linetype
checkline (cursym)
int *cursym;
{
    register char *cp;
    register char *symp;
    register char chr;
    char *scp;
    Linetype retval;
    int symind;
#   define KWSIZE 8
    char keyword[KWSIZE];

    linenum++;
    if (getlin (tline, sizeof tline, input, NO) == EOF)
	return LT_LEOF;

    retval = LT_PLAIN;
    if (   *(cp = tline) != '#'
	|| incomment
	|| inquote == QUOTE_SINGLE
	|| inquote == QUOTE_DOUBLE
       )
	goto eol;

    cp = skipcomment (++cp);
    symp = keyword;
    while (!endsym (*cp)) {
	*symp = *cp++;
	if (++symp >= &keyword[KWSIZE])
	    goto eol;
    }
    *symp = '\0';

    if (strcmp (keyword, "ifdef") == 0) {
	retval = YES;
	goto ifdef;
    }
    else if (strcmp (keyword, "ifndef") == 0) {
	retval = NO;
 ifdef:
	scp = cp = skipcomment (++cp);
	if (incomment) {
	    retval = LT_PLAIN;
	    goto eol;
	}
	for (symind = 0; ; ) {
	    if (insym[symind] == SYM_INACTIVE) {
		for ( symp = sym[symind], cp = scp
		    ; *symp && *cp == *symp
		    ; cp++, symp++
		    )
		    continue;
		chr = *cp;
		if (*symp == '\0' && endsym (chr)) {
		    *cursym = symind;
		    retval = (retval ^ true[symind]) ? LT_FALSE : LT_TRUE;
		    break;
		}
	    }
	    if (++symind >= nsyms) {
		retval = LT_OTHER;
		break;
	    }
	}
    }
    else if (strcmp (keyword, "if") == 0)
	retval = LT_IF;
    else if (strcmp (keyword, "else") == 0)
	retval = LT_ELSE;
    else if (strcmp (keyword, "endif") == 0)
	retval = LT_ENDIF;

 eol:
    if (!text && reject == REJ_NO)
	for (; *cp; ) {
	    if (incomment)
		cp = skipcomment (cp);
	    else if (inquote == QUOTE_SINGLE)
		cp = skipquote (cp, QUOTE_SINGLE);
	    else if (inquote == QUOTE_DOUBLE)
		cp = skipquote (cp, QUOTE_DOUBLE);
	    else if (*cp == '/' && cp[1] == '*')
		cp = skipcomment (cp);
	    else if (*cp == '\'')
		cp = skipquote (cp, QUOTE_SINGLE);
	    else if (*cp == '"')
		cp = skipquote (cp, QUOTE_DOUBLE);
	    else
		cp++;
	}
    return retval;
}

/*  Skip over comments and stop at the next charaacter
/*  position that is not whitespace.
/**/
char *
skipcomment (cp)
register char *cp;
{
    if (incomment)
	goto inside;
    for (;; cp++) {
        while (*cp == ' ' || *cp == '\t')
            cp++;
	if (text)
            return cp;
	if (   cp[0] != '/'
	    || cp[1] != '*'
	   )
            return cp;
	cp += 2;
	if (!incomment) {
	    incomment = YES;
	    stqcline = linenum;
	}
 inside:
	for (;;) {
	    for (; *cp != '*'; cp++)
		if (*cp == '\0')
		    return cp;
	    if (*++cp == '/')
		break;
	}
	incomment = NO;
    }
}

/*  Skip over a quoted string or character and stop at the next charaacter
/*  position that is not whitespace.
/**/
char *
skipquote (cp, type)
register char *cp;
register int type;
{
    register char qchar;

    qchar = type == QUOTE_SINGLE ? '\'' : '"';

    if (inquote == type)
	goto inside;
    for (;; cp++) {
	if (*cp != qchar)
	    return cp;
	cp++;
	inquote = type;
	stqcline = linenum;
 inside:
	for (; ; cp++) {
	    if (*cp == qchar)
		break;
	    if (   *cp == '\0'
		|| *cp == '\\'
		&& *++cp == '\0'
	       )
		return cp;
	}
	inquote = QUOTE_NONE;
    }
}

/*
/*   special getlin - treats form-feed as an end-of-line
/*                    and expands tabs if asked for
/*
/**/
getlin (line, maxline, inp, expandtabs)
register char *line;
int maxline;
FILE *inp;
int expandtabs;
{
    int tmp;
    register int num;
    register int chr;
#ifdef FFSPECIAL
    static char havechar = NO;  /* have leftover char from last time */
    static char svchar BSS;
#endif

    num = 0;
#ifdef FFSPECIAL
    if (havechar) {
	havechar = NO;
	chr = svchar;
	goto ent;
    }
#endif
    while (num + 8 < maxline) {   /* leave room for tab */
        chr = getc (inp);
	if (isprint (chr)) {
#ifdef FFSPECIAL
 ent:
#endif
	    *line++ = chr;
	    num++;
	}
	else
	    switch (chr) {
	    case EOF:
		return EOF;

	    case '\t':
		if (expandtabs) {
		    num += tmp = 8 - (num & 7);
		    do
			*line++ = ' ';
		    while (--tmp);
		    break;
		} 
            default:
                *line++ = chr;
                num++;
		break;

	    case '\n':
                *line = '\n';
                num++;
                goto end;
    
#ifdef FFSPECIAL
	    case '\f':
		if (++num == 1)
		    *line = '\f';
		else {
		    *line = '\n';
		    havechar = YES;
                    svchar = chr;
                }
                goto end;
#endif
	    }
    }
 end:
    *++line = '\0';
    return num;
}

flushline (keep)
Bool keep;
{
    if ((keep && reject != REJ_YES) ^ complement)
	putlin (tline, stdout);
    else if (lnblank)
	putlin ("\n", stdout);
    return;
}

/*
/*  putlin - for tools
/*
/**/
putlin (line, fio)
register char *line;
register FILE *fio;
{
    register char chr;

    while (chr = *line++)
	putc (chr, fio);
    return;
}

prname ()
{
    fprintf (stderr, "%s: ", progname);
    return;
}

int
error (err, line, depth)
{
    if (err == END_ERR)
	return err;

    prname ();

#ifndef TESTING
    fprintf (stderr, "Error in %s line %d: %s.\n",
	     filename, line, errs[err]);
#endif

#ifdef TESTING
    fprintf (stderr, "Error in %s line %d: %s. ",
	     filename, line, errs[err]);
    fprintf (stderr, "ifdef depth: %d\n", depth);
#endif

    exitstat = 2;
    return depth > 1 ? IEOF_ERR : END_ERR;
}
