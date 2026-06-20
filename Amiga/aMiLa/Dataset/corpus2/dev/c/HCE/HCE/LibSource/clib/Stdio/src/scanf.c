#include <stdio.h>
#include <ctype.h>
#define	FALSE	(0)
#define TRUE	(!FALSE)

/* From the Hcc.lib by Detlef Wurkner, Placed here by J.P.*/
/* Modified by J.P. */
/* This version of scanf does not suport floats, if you need float scanf */
/* link the math.lib as first library in list. */

static char	_numstr[] = "0123456789ABCDEF";

/* #define	skip()	do{c=(*get)(ip); if (c<1) goto done;}while(isspace(c))*/

#define	skip()	while(isspace(c)) { if ((c=(*get)(ip))<1) goto done; }


_scanf(ip, get, unget, fmt, args)
	register unsigned char *ip;
	int (*get)();
	int (*unget)();
	register unsigned char *fmt;
	char **args;

	{
	register long n;
	register int c, width, lval, cnt = 0;

/* ADDED BY TETISOFT */
	int sval;

	int store, neg, base, wide1, endnull, rngflag, c2;
	register unsigned char *p;
	unsigned char delim[128], digits[17], *q;
	char *strchr(), *strcpy();
	long frac, expo;
	int eneg, fraclen, fstate, trans;
	double fx, fp_scan();

	if (!*fmt)
		return(0);

	c = (*get)(ip);
	while(c > 0)
		{
		store = FALSE;
		if (*fmt == '%')
			{
			n	= 0;
			width	= -1;
			wide1	= 1;
			base	= 10;
			lval	= FALSE;

/* ADDED BY TETISOFT */
			sval	= FALSE;

			store	= TRUE;
			endnull	= TRUE;
			neg	= -1;

			strcpy(delim,  "\011\012\013\014\015 ");
			strcpy(digits, _numstr); /* "01234567890ABCDEF" */

			if (fmt[1] == '*')
				{
				endnull = store = FALSE;
				++fmt;
				}

			while (isdigit(*++fmt))		/* width digit(s) */
				{
				if (width == -1)
					width = 0;
				wide1 = width = (width * 10) + (*fmt - '0');
				}
			--fmt;
fmtnxt:
			++fmt;
			switch(tolower(*fmt))	/* tolower() is a MACRO! */
				{
				case '*':
					endnull = store = FALSE;
					goto fmtnxt;

				case 'l':	/* long data */
					lval = TRUE;

/* ADDED BY TETISOFT */			goto fmtnxt;

/* for compatability --> */	case 'h':	/* short data */

/* ADDED BY TETISOFT */			sval = TRUE;

					goto fmtnxt;

				case 'i':	/* any-base numeric */
					base = 0;
					goto numfmt;

				case 'b':	/* unsigned binary */
					base = 2;
					goto numfmt;

				case 'o':	/* unsigned octal */
					base = 8;
					goto numfmt;

				case 'x':	/* unsigned hexadecimal */
					base = 16;
					goto numfmt;

				case 'd':	/* SIGNED decimal */
					neg = FALSE;
					/* FALL-THRU */

				case 'u':	/* unsigned decimal */
numfmt:					skip();

					if (isupper(*fmt))
						lval = TRUE;

					if (!base)
						{
						base = 10;
						neg = FALSE;
						if (c == '%')
							{
							base = 2;
							goto skip1;
							}
						else if (c == '0')
							{
							c = (*get)(ip);
							if (c < 1)
								goto savnum;
							if ((c != 'x')
							 && (c != 'X'))
								{
								base = 8;
								digits[8]= '\0';
								goto zeroin;
								}
							base = 16;
							goto skip1;
							}
						}

					if ((neg == FALSE) && (base == 10)
					 && ((neg = (c == '-')) || (c == '+')))
						{
skip1:
						c = (*get)(ip);
						if (c < 1)
							goto done;
						}

					digits[base] = '\0';
					p = ((unsigned char *)
						strchr(digits,toupper(c)));

					if ((!c || !p) && width)
						goto done;

					while (p && width-- && c)
						{
						n = (n * base) + (p - digits);
						c = (*get)(ip);
zeroin:
						p = ((unsigned char *)
						strchr(digits,toupper(c)));
						}
savnum:
					if (store)
						{
						p = ((unsigned char *) *args);
						if (neg == TRUE)
							n = -n;
						if (lval)
							*((long*) p) = n;
						else

/* ADDED BY TETISOFT */				if (sval)
							*((short*) p) = n;
						else

							*((int *) p) = n;
						++cnt;
						}
					break;

				case 'e':	/* float */
				case 'f':
				case 'g':        /* floats removed J.P. */
                                          goto done;

				case 'c':	/* character data */
					width = wide1;
					endnull	= FALSE;
					delim[0] = '\0';
					goto strproc;

				case '[':	/* string w/ delimiter set */

					/* get delimiters */
					p = delim;

					if (*++fmt == '^')
						fmt++;
					else
						lval = TRUE;

					rngflag = 2;
					if ((*fmt == ']') || (*fmt == '-'))
						{
						*p++ = *fmt++;
						rngflag = FALSE;
						}

					while (*fmt != ']')
						{
						if (*fmt == '\0')
							goto done;
						switch (rngflag)
						    {
						    case TRUE:
							c2 = *(p-2);
							if (c2 <= *fmt)
							    {
							    p -= 2;
							    while (c2 < *fmt)
							    	*p++ = c2++;
							    rngflag = 2;
							    break;
							    }
						    /* fall thru intentional */

						    case FALSE:
							rngflag = (*fmt == '-');
							break;

						    case 2:
							rngflag = FALSE;
						    }

						*p++ = *fmt++;
						}

					*p = '\0';
					goto strproc;

				case 's':	/* string data */
					skip();
strproc:
					/* process string */
					p = ((unsigned char *) *args);

					/* if the 1st char fails, match fails */
					if (width)
						{
						q = ((unsigned char *)
							strchr(delim, c));
						if((c < 1)
						|| (lval ? !q : (int) q))
							{
							if (endnull)
								*p = '\0';
							goto done;
							}
						}

					for (;;) /* FOREVER */
						{
						if (store)
							*p++ = c;
						if (((c = (*get)(ip)) < 1) ||
						    (--width == 0))
							break;

						q = ((unsigned char *)
							strchr(delim, c));
						if (lval ? !q : (int) q)
							break;
						}

					if (store)
						{
						if (endnull)
							*p = '\0';
						++cnt;
						}
					break;

				case '\0':	/* early EOS */
					--fmt;
					/* FALL THRU */

				default:
					goto cmatch;
				}
			}
		else if (isspace(*fmt))		/* skip whitespace */
			{
			skip();
			}
		else 
			{			/* normal match char */
cmatch:
			if (c != *fmt) 
				break;
			c = (*get)(ip);
			}

		if (store)
			args++;

		if (!*++fmt)
			break;
		}

done:						/* end of scan */
	if ((c < 0) && (cnt == 0))
		return(EOF);

	(*unget)(c, ip);
	return(cnt);
	}
