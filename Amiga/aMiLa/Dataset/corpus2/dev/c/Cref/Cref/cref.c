/*
**   cref - C cross referencer VERSION 2.
**	This program reads its standard input or one or more files
**	and prints the file plus an alphabetic list of word references
**	by line number.
**
**	To run:
**		cref [-q] [-lnnn] [-wnnn] [-hheading] [-tnnn] [-?] [file ...]
**
**	Options:
**		q    - don't print normal input file listing.
**		lnnn - set page length to n instead of the default 66.
**		wnnn - set page width to n instead of the default 132.
**		hccc - set page heading to 'ccc' rather than file names.
**		tnnn - set tab spaces to n instead if the default 8.
**      ?    - display this list.
**
**	Mike Edmonds - 5/81
**--------------------------------------------------------------------
**
**  VERSION 2 with comment bug fixed. May 1988
**
**  Amiga port by Joel Swank 9/87
**
**  Compiled under Manx:
**  cc cref.c
**  ln cref.o -lc
**
**  Changes besides porting:
**
**  + Deleted temporary file option because the Amiga sort command
**      cannot sort files larger than memory.
**  + Added -t option
**  + Added -? option
**  + Added Usage message and error msgs.
**  + Rewrote case statments that overflowed compiler table
**  + Fixed BUG that caused end of comment to be missed. star-star-slash
**    was missed.
*/

#include <stdio.h>
#include <ctype.h>
#include <signal.h>
#include <exec/types.h>
#include <stat.h>

#define MAXWORD		15		/* maximum chars in word */
#define MAXPAGLINES	9999	/* maximum posible lines in page */
#define MINPAGLINES	4		/* minimum posible lines in page */
#define MAXLINWIDTH	132		/* maximum posible chars in line */
#define MINLINWIDTH	MAXWORD+12	/* minimum posible chars in line */
#define MAXTABSIZE	132		/* maximum posible chars in tab */
#define MINTABSIZE	1		/* minimum posible chars in tab */

#define igncase(c)	(isupper(c)? tolower(c) : (c))

#undef FALSE
#undef TRUE
#define FALSE	0
#define TRUE	1

#ifdef	DEBUG
#define debug(a,b)	fprintf(stderr,(a),(b))
#else
#define debug(a,b)
#endif



/*
 *  global structures
 */

#define LINLIST	struct	_linlist
#define WRDLIST	struct	_wrdlist

struct	_linlist {		/* line number list node */
	long	 ln_no ;	  /* line number */
	LINLIST	*ln_next ;	  /* next element pointer (or NULL) */
} ;

struct	_wrdlist {		/* word list node */
	char	*wd_wd ;	  /* pointer to word */
	char	*wd_lwd ;	  /* pointer to word (lower case) */
	LINLIST	 wd_ln ;	  /* first element of line list */
	WRDLIST	*wd_low ;	  /* lower child */
	WRDLIST	*wd_hi ;	  /* higher child */
} ;



/*
 *  options
 */

char	*Progname ;
int	 Quiet = FALSE ;	/* don't print input file listing? (-q) */
int	 Maxpaglines = 66 ;	/* maximum lines in page (-l) */
int	 Maxlinwidth = 132 ;	/* maximum chars in print line (-w) */
int  Tabsize	= 8 ;	/* default length of tab */



/*
 *  global variables
 */

char	 Crefhdr[MAXLINWIDTH+1] ;/* report header */
char	*Filename ;		/* name of current input file */
char	 Date[30] ;		/* current or last file modify date */
long	 Hiline = 1L ;		/* current (and max.) input file line number */
int		 files=0 ;      /* count of source files */
WRDLIST	*Wdtree = NULL ;	/* ptr to root node of binary word list */



/*
 *  C language reserved keywords (in pseudo random order)
 */
char	*Ckeywords[] = {
	"char",
	"static",
	"break",
	"#define",
	"#if",
	"default",
	"#ifdef",
	"#ifndef",
	"register",
	"void",
	"if",
	"while",
	"#line",
	"union",
	"switch",
	"#else",
	"asm",
	"do",
	"#include",
	"#undef",
	"#endif",
	"long",
	"continue",
	"float",
	"short",
	"typedef",
	"for",
	"struct",
	"case",
	"else",
	"unsigned",
	"int",
	"extern",
	"auto",
	"goto",
	"entry",
	"return",
	"double",
	"sizeof",
	0
} ;




/*
 *  main - Store C keywords.
 *	   Get program options and format heading lines.
 *	   Get words from input file (or files) and store in tree.
 *	   Retrieve and print in word sequence.
 */
main(argc, argv)
int	 argc ;
char	*argv[] ;
{
	char	wordfilebuf[BUFSIZ] ;
	register FILE	*filep ;
	char	*getword(), *word ;
	struct	 stat	stbuf ;
	long	 time() ;
	register cnt ;

	Progname = *argv ;		/* get options */
	getcmd(argc, argv) ;


					/* store C keywords */
	for (cnt=0 ; Ckeywords[cnt] ; cnt++)
		storword(Ckeywords[cnt], 0L) ;


	listchr(-2);	/* clear output line */

					/* read and store files */
	for (cnt=1 ; cnt < argc ; cnt++)
		if (*argv[cnt] != '-')
		{	files++ ;
			Filename = argv[cnt] ;
			if ((filep = fopen(Filename, "r")) == NULL)
				fatal("can't open %s", Filename) ;
			stat(Filename, &stbuf) ;
			mkdate((long)stbuf.st_mtime) ;
			while (word = getword(filep))
				storword(word, Hiline);
			fclose(filep) ;
		}

	if (!files)			/* no files - read stdin */
	{	if (*Crefhdr)
			Filename = Crefhdr ;
		else
			Filename = "stdin" ;
		mkdate(time( (long *)0)) ;
		while (word = getword(stdin))
			storword(word, Hiline) ;
	}


	/*  print cross reference report */
	cref(Wdtree) ;

	exit(0) ;
}








/*
 *  getcmd - get arguments from command line & build page headings
 */
getcmd(argc, argv)
register argc ;
register char	*argv[] ;
{
	register cnt ;

	debug("GETCMD(%d", argc) ;
	debug(", %s)\n", argv[0]) ;

	*Crefhdr = '\0' ;
					/* get command options */
	for (cnt=1; cnt < argc; cnt++)
	{	if (*argv[cnt] == '-')
		{	switch(argv[cnt][1])
			{  case 'q':
				Quiet = TRUE ;
				break ;

			   case 'l':
				Maxpaglines = atoi(&argv[cnt][2]) ;
				if (Maxpaglines < MINPAGLINES
				 || Maxpaglines > MAXPAGLINES)
					fatal("Bad -l value: %s", argv[cnt]) ;
				break ;

			   case 'w':
				Maxlinwidth = atoi(&argv[cnt][2]) ;
				if (Maxlinwidth < MINLINWIDTH
				 || Maxlinwidth > MAXLINWIDTH)
					fatal("Bad -w value: %s", argv[cnt]) ;
				break ;

			   case 't':
				Tabsize = atoi(&argv[cnt][2]) ;
				if (Tabsize < MINTABSIZE
				 || Tabsize > MAXTABSIZE)
					fatal("Bad -t value: %s", argv[cnt]) ;
				break ;

			   case 'h':
				strncpy(Crefhdr, &argv[cnt][2], MAXLINWIDTH) ;
				Crefhdr[MAXLINWIDTH] = '\0' ;
				break ;

			   case '?':					/* help option */
				 usage();
				 printf(" Options:\n");
				 printf(" q    - don't print normal input file listing\n");
				 printf(" lnnn - set page length to n instead of the default 66.\n");
				 printf(" wnnn - set page width to n instead of the default 132.\n");
				 printf(" hccc - set page heading to 'ccc' rather than file names\n");
				 printf(" tnnn - set tab spacing to n instead of the default 8\n");
				 printf(" ?    - display this list.\n");
				exit(0);

			   default:
				 usage();
				 exit(0);
			}
		}
	}

					/* insert file names in hdr */
	if (!*Crefhdr)
		for (cnt=1; cnt < argc; cnt++)
			if (*argv[cnt] != '-')
				strjoin(Crefhdr, ' ', argv[cnt], MAXLINWIDTH) ;
}



usage()
{
printf("usage:cref [-q] [-lnnn] [-wnnn] [-hheading] [-tnnn] [-?] [file ...]\n");
}




/*
 *  getword - read, print and return next word from file
 */
char *
getword(filep)
FILE	*filep ;
{
	static	 char	wordbuf[MAXWORD+1] ;
	register char	*wp = wordbuf ;
	register maxw = sizeof(wordbuf) ;
	register chr ;
	int	 inword=0, lastchr=0 ;
	long	 slineno ;

#define	_listchr(chr)	if (!Quiet) listchr(chr)

#define	_rtrnwrd(wp) 			\
	{	ungetc(chr, filep) ;	\
		*(wp) = '\0' ;		\
		return wordbuf ;	\
	}

	while ((chr = getc(filep)) != EOF)
	{	
			/* normal char - add to current word */
		if ((chr <= 'z' && chr >= 'a') || 
			(chr <= 'Z' && chr >= 'A') || 
			 chr == '_' )
			{
			if (maxw-- <= 1)
				_rtrnwrd(wp) ;
			*wp++ = chr ;
			inword++ ;
			_listchr(chr) ;
			}

		else switch (chr)
		{
					/* digit - can't be 1st char in word */
		   case '0': case '1': case '2': case '3': case '4':
		   case '5': case '6': case '7': case '8': case '9':
			if (inword)
			{	if (maxw-- <= 1)
					_rtrnwrd(wp) ;
				*wp++ = chr ;
			}
			_listchr(chr) ;
			break ;

					/* '#' - must be 1st char in word */
		   case '#':
			if (inword)
				_rtrnwrd(wp) ;
			*wp++ = chr ;
			inword++ ;
			_listchr(chr) ;
			break ;

					/* newline - end current word */
		   case '\n':
			if (inword)
				_rtrnwrd(wp) ;
			_listchr(chr) ;
			Hiline++ ;
			break ;

					/* comments - print & bypass */
		   case '/':
			if (inword)
				_rtrnwrd(wp) ;
			_listchr(chr) ;
			slineno = Hiline ;
			if ((chr = getc(filep)) == '*')
			{	_listchr(chr) ;
				while (chr != EOF)
				{	chr = getc(filep) ;
					_listchr(chr) ;
					if (chr == '\n')
						Hiline++ ;
					else if (chr == '*')
					{	
					  restar:  /* Fix for missing end of comment bug */
						chr = getc(filep) ; /* star-star-slash was missed */
						_listchr(chr) ;
						if (chr == '\n')
							Hiline++ ;
						else if (chr == '/')
							break ; ;
						if (chr == '*') goto restar; /* JHS 5/24/88 */
					}
				}
				if (chr == EOF)
					fatal("unterminated comment at %ld in %s", slineno, Filename) ;
			}
			else
				ungetc(chr, filep) ;
			break ;

					/* words in quotes - print & bypass */
		   case '"':
			if (inword)
				_rtrnwrd(wp) ;
			_listchr(chr) ;
			slineno = Hiline ;
			if (lastchr != '\\')
			{	do
				{	if (chr == '\\' && lastchr == '\\')
						lastchr = '\0' ;
					else
						lastchr = chr ;
					if ((chr = getc(filep)) == EOF)
						fatal("unterminated quote at %ld in %s", slineno, Filename) ;
					_listchr(chr) ;
					if (chr == '\n')
						Hiline++ ;
				} while (chr != '"' || lastchr == '\\') ;
			}
			break ;

					/* letters in quotes - print & bypass */
		   case '\'':
			if (inword)
				_rtrnwrd(wp) ;
			_listchr(chr) ;
			if (isprint(chr = getc(filep)))
			{	_listchr(chr) ;
				if (chr == '\\')
				{	if (!isprint(chr = getc(filep)))
						goto toofar ;
					_listchr(chr) ;
				}
				if ((chr = getc(filep)) != '\'')
					goto toofar ;
				_listchr(chr) ;
			}
			else
			   toofar:
				ungetc(chr, filep) ;
			break ;

		   default:
			if (inword)
				_rtrnwrd(wp) ;
			_listchr(chr) ;
			break ;
		}

		lastchr = chr ;
	}

	if (inword)
		_rtrnwrd(wp) ;
	_listchr(EOF) ;
	return NULL ;
}








/*
 *  listchr - list the input files one character at a time
 */

static	Listpage = 0 ;
static	Listpline = MAXPAGLINES ;

listchr(chr)
register chr ;
{
	static	char	 linebuf[MAXLINWIDTH*2], *lineptr=linebuf ;
	static	lastchr=0, linecnt=0 ;
	int	remain;

	if (chr == -2)			/* clear line buffer */
		{
		setmem(linebuf,Maxlinwidth,' ');
		return;
		}

	if (chr == EOF)			/* EOF - print final line */
	{	*lineptr = '\0' ;
		listline(linebuf) ;
		Listpage = 0 ;
		Listpline = MAXPAGLINES ;
		lineptr = linebuf ;
		linecnt = 0 ;
		return ;
	}

	if (lineptr == linebuf)		/* new line - format line number */
	{	ltoc(linebuf, Hiline, 6) ;
		lineptr = linebuf+6 ;
		*lineptr++ = ' ' ;
		*lineptr++ = ' ' ;
		linecnt = 8 ;
	}

#define	_lineoflo(ctr, newctr)		\
	if ((ctr) >= Maxlinwidth)	\
	{	*lineptr = '\0' ;	\
		listline(linebuf) ;	\
		lineptr = &linebuf[8] ;	\
		linecnt = (newctr) ;	\
	}

	switch (chr)
	{				/* newline - print last line */
	   case '\n':
		if (lastchr != '\f')
		{	*lineptr = '\0' ;
			listline(linebuf) ;
		}
		lineptr = linebuf ;
		linecnt = 0 ;
		break ;

	 				/* formfeed - print line and end page */
	   case '\f':
		if (linecnt != 8)
		{	*lineptr = '\0' ;
			listline(linebuf) ;
		}
		Listpline = MAXPAGLINES ;
		lineptr = linebuf ;
		linecnt = 0 ;
		break ;

					/* tab - skip to next tab stop */
	   case '\t':
		linecnt += Tabsize ;
		remain =  linecnt % Tabsize ;
		linecnt -= remain;
		_lineoflo(linecnt, 8) ;
		lineptr += Tabsize ;
		lineptr -= remain;
		break ;

					/* backspace - print, but don't count */
	   case '\b':
		*lineptr++ = chr ;
		break ;

					/* ctl-char - print as "^x" */
		     case 001: case 002: case 003:
	   case 004: case 005: case 006: case 007:
					 case 013:
	             case 015: case 016: case 017:
	   case 020: case 021: case 022: case 023:
	   case 024: case 025: case 026: case 027:
	   case 030: case 031: case 032: case 033:
	   case 034: case 035: case 036: case 037:
		_lineoflo(linecnt+=2, 10) ;
		*lineptr++ = '^' ;
		*lineptr++ = ('A'-1) + chr ;
		break ;

	   default:
		if (isprint(chr))
		{	_lineoflo(++linecnt, 9) ;
			*lineptr++ = chr ;
		}

		else		/* non-ascii chars - print as "\nnn" */
		{	_lineoflo(linecnt+=4, 12) ;
			*lineptr++ = '\\' ;
			*lineptr++ = '0' + ((chr & 0300) >> 6) ;
			*lineptr++ = '0' + ((chr & 070) >> 3) ;
			*lineptr++ = '0' + (chr & 07) ;
		}
		break ;
	}
	lastchr = chr ;
}

			/* print a completed line from the input file */
listline(line)
register char	*line ;
{
	if (*line)
	{	if (++Listpline >= (Maxpaglines-8))
		{	if (files >1 || Listpage) putchar('\f') ;
			printf("\n%s %s  Page %d\n\n",
				Date, Filename, ++Listpage) ;
			Listpline = 0 ;
		}
		puts(line) ;
		listchr(-2);	/* clear line buffer */
	}
}









/*
 *  storword - store word and line # in binary word tree or word file
 */

storword(word, lineno)
register char	*word ;
long	 lineno ;
{
	char	 lword[MAXWORD+1] ;
	register char	*cp1, *cp2 ;
	WRDLIST	*addword() ;

					/* convert word to lower case */
	for (cp1=word, cp2=lword ; *cp2++ = igncase(*cp1) ; cp1++)
		;

					/* store words and lineno */
	Wdtree = addword(Wdtree, word, lword, lineno) ;
}



/*
 *  addword - add word and line# to in-core word list
 */
WRDLIST *
addword(wdp, word, lword, lineno)
register WRDLIST *wdp ;
char	*word, *lword ;
long	 lineno ;
{
	char	*malloc() ;
	int	 comp ;

					/* insert new word into list */
	if (wdp == NULL)
	{	register wordlen = strlen(word) + 1 ;

		wdp = (WRDLIST *)malloc((wordlen * 2) + sizeof(WRDLIST)) ;
		if (wdp == NULL)
			goto nomemory ;

		wdp->wd_wd  = (char *)wdp + sizeof(WRDLIST) ;
		wdp->wd_lwd = wdp->wd_wd + wordlen ;
		strcpy(wdp->wd_wd,  word) ;
		strcpy(wdp->wd_lwd, lword) ;

		wdp->wd_hi = wdp->wd_low = NULL ;
		wdp->wd_ln.ln_no = lineno ;
		wdp->wd_ln.ln_next = NULL ;
	}

					/* word matched in list? */
	else if (((comp = strcmp(lword, wdp->wd_lwd)) == 0)
	      && ((comp = strcmp(word,  wdp->wd_wd))  == 0))
	{	register LINLIST *lnp, **lnpp ;

		if (wdp->wd_ln.ln_no)
		{			  /* add line# to linked list */
			lnp = &wdp->wd_ln ;
			do
			{	if (lineno == lnp->ln_no)
					return wdp ;
				lnpp = &lnp->ln_next ;
			} while ((lnp = *lnpp) != NULL) ;

			*lnpp = (LINLIST *)malloc(sizeof(LINLIST)) ;
			if ((lnp = *lnpp) == NULL)
				goto nomemory ;
			lnp->ln_no = lineno ;
			lnp->ln_next = NULL ;
		}
	}

	else if (comp < 0)		/* search for word in children */
		wdp->wd_low = addword(wdp->wd_low, word, lword, lineno) ;
	else
		wdp->wd_hi = addword(wdp->wd_hi, word, lword, lineno) ;

	return wdp ;


					/* not enough memory - convert to -b */
nomemory:
	fatal("not enough memory for in-core word list") ;
}







/*
 *  cref - print cross reference report from internal word list
 */
#define MAXLNOS 2000		/* maximum line nos. for a word */
long	Linenos[MAXLNOS] ;	/* list of line numbers for a word */

cref(wdtree)
register WRDLIST *wdtree ;
{
	creftree(wdtree) ;
}

creftree(wdp)			/* recursively print word tree nodes */
register WRDLIST *wdp ;
{
	register LINLIST *lnp ;
	register nos ;

	if (wdp != NULL)
	{	creftree(wdp->wd_low) ;	/* print lower children */

		nos = 0 ;
		if (Linenos[0] = wdp->wd_ln.ln_no)
		{	lnp = &wdp->wd_ln ;
			while ((lnp = lnp->ln_next) != NULL)
				if (nos < (MAXLNOS-2))
					Linenos[++nos] = lnp->ln_no ;
			printword(wdp->wd_wd, nos) ;
		}

		creftree(wdp->wd_hi) ;	/* print higher children */
	}
}







/*
 *  printword - print a word and all its line number references
 */
printword(word, nos)
char	*word ;
register nos ;
{
	static	firstime=TRUE, linecnt, maxlnos, lnosize ;
	register cnt ;

	if (firstime)
	{	firstime = FALSE ;
		linecnt = Maxpaglines ;
		for (lnosize=1 ; Hiline ; lnosize++)
			Hiline /= 10L ;
		maxlnos = (Maxlinwidth - (MAXWORD+7)) / lnosize ;
	}

	if (linecnt >= (Maxpaglines - 8))
	{	printheads() ;
		linecnt = 5 ;
	}

	printf("%-15s%5d  ", word, ++nos) ;
	Linenos[nos] = 0 ;

	for (nos=0, cnt=0 ; Linenos[nos] ; nos++)
	{	if (++cnt > maxlnos)
		{	cnt = 1 ;
			if (linecnt++ >= (Maxpaglines - 2))
			{	printheads() ;
				linecnt = 5 ;
				printf("%-15s(cont) ", word);
			}
			else
				printf("\n%22s", " ") ;
		}
		printf("%*ld", lnosize, Linenos[nos]) ;
	}
	putchar('\n') ;

	linecnt++ ;
}



/*
 *  printheads - print page headings
 */
printheads()
{
	static	page=0 ;
	long	time() ;

	if (!page)
		mkdate(time( (long *)0)) ;

	putchar('\f') ;
	printf("\nCREF  %s %.*s  Page %d\n\n",
		Date, (Maxlinwidth-36), Crefhdr, ++page) ;
	printf("word             refs    line numbers\n\n") ;
}








/*
 *  ltoc - store ASCII equivalent of long value in given field
 */
ltoc(fld, lval, len)
register char	*fld ;
register long	lval ;
register len ;
{
	fld += len ;
	while (len-->0)
		if (lval)
		{	*--fld = '0' + (lval%10L) ;
			lval /= 10L ;
		}
		else
			*--fld = ' ' ;
}



/*
 *  mkdate - build time/date for use in heading lines
 */
mkdate(atime)
long	atime ;
{
	long	mtime ;
	char	*cp, *ctime() ;

	debug("MKDATE(%ld)\n", atime) ;

	mtime = atime ;
	cp = ctime(&mtime) ;
	*(cp+24) = ' ' ;		/* clear newline */
	strcpy(cp+16, cp+19) ;		/* shift over seconds */
	strcpy(Date, cp+4) ;
}



/*
 *  strjoin - join "str1" to "str2" (separated by "sep")
 *	Truncate if necessary to "max" chars.
 */
strjoin(str1, sep, str2, max)
register char	*str1, *str2;
char	sep ;
register max ;
{
	if (*str2)
	{	if (*str1)
		{	while (*str1++)
				if (--max <= 0)
					goto oflo ;
			max--, str1-- ;
			*str1++ = sep ;
		}
		while (*str1++ = *str2++)
			if (--max <= 0)
				goto oflo ;
	}
	return ;

oflo:
	*--str1 = '\0' ;
	return ;
}







/*
 *  error - print standard error msg
 */
error(ptrn, data1, data2)
register char	*ptrn, *data1, *data2 ;
{
	fprintf(stderr, "%s: ", Progname) ;
	fprintf(stderr, ptrn, data1, data2) ;
	putc('\n', stderr) ;
}


/*
 *  fatal - print standard error msg and halt process
 */
fatal(ptrn, data1, data2)
register char	*ptrn, *data1, *data2 ;
{
	error(ptrn, data1, data2) ;
	exit(1);
}
