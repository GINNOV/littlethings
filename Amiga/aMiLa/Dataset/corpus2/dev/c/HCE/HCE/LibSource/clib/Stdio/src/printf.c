#include <stdio.h>
#include <ctype.h>
#include <string.h>

/* From the Hcc.lib by Detlef Wurkner, Placed here by J.P. */
/* Modified by J.P. */
/* This version of printf does not suport floats, if you need float printf */
/* link the math.lib as first library in list. */

#define	FALSE	(0)
#define TRUE	(!FALSE)

static char	_numstr[] = "0123456789ABCDEF";

static char *_strlwr(string)
	register char *string;
	{
	register char *p = string;

	while(*string)
		tolower(*string++);
	return(p);
	}

static char *_ultoa(n, buffer, radix)
	register unsigned long n;
	register char *buffer;
	register int radix;
	{
	register char *p = buffer;

	do
		{
		*p++ = _numstr[n % radix];	/* grab each digit */
		}
		while((n /= radix) > 0);
	*p = '\0';
	return(strrev(buffer));			/* reverse and return it */
	}

static char *_ltoa(n, buffer, radix)
	register long n;
	register char *buffer;
	int radix;
	{
	register char *p = buffer;

	if (n < 0)
		{
		*p++ = '-';
		n = -n;
		}
	_ultoa(n, p, radix);
	return(buffer);
	}

static _prtfld(op, put, buf, ljustf, sign, pad, width, preci)
	register char *op;
	register int (*put)();
	register unsigned char *buf;
	int ljustf;
	register char sign;
	char pad;
	register int width;
	int preci;
/*
 *	Output the given field in the manner specified by the arguments.
 *	Return the number of characters output.
 */
	{
	register int cnt = 0, len;
	register unsigned char ch;

	len = strlen(buf);

	if (*buf == '-')
		sign = *buf++;
	else if (sign)
		len++;

	if ((preci != -1) && (len > preci))	/* limit max data width */
		len = preci;

	if (width < len)	/* flexible field width or width overflow */
		width = len;

/* at this point:
 *	width = total field width
 *	len   = actual data width (including possible sign character)
 */
	cnt = width;
	width -= len;

	while (width || len)
		{
		if (!ljustf && width)		/* left padding */
			{
			if (len && sign && (pad == '0'))
				goto showsign;
			ch = pad;
			--width;
			}
		else if (len)
			{
			if (sign)
				{
showsign:			ch = sign;	/* sign */
				sign = '\0';
				}
			else
				ch = *buf++;	/* main field */
			--len;
			}
		else
			{
			ch = pad;		/* right padding */
			--width;
			}
		(*put)(ch, op);
		}

	return(cnt);
	}


_printf(op, put, fmt, args)
	char *op;
	unsigned int (*put)();
	register unsigned char *fmt;
	register unsigned int *args;
	{
	register int i, cnt = 0, ljustf, lval;
	int preci, dpoint, width;
	char pad, sign, radix;
	register char *ptmp;
	char tmp[64], *_ltoa(), *_ultoa();

	while(*fmt)
		{
		if(*fmt == '%')
			{
			ljustf = FALSE;	/* left justify flag */
			sign = '\0';	/* sign char & status */
			pad = ' ';	/* justification padding char */
			width = -1;	/* min field width */
			dpoint = FALSE;	/* found decimal point */
			preci = -1;	/* max data width */
			radix = 10;	/* number base */
			ptmp = tmp;	/* pointer to area to print */
			lval = FALSE;	/* long value flaged */
fmtnxt:
			i = 0;
			while (isdigit(*++fmt))
				{
				i = (i * 10) + (*fmt - '0');
				if (dpoint)
					preci = i;
				else if (!i && (pad == ' '))
					{
					pad = '0';
					goto fmtnxt;
					}
				else
					width = i;
				}

			switch(*fmt)
				{
				case '\0':	/* early EOS */
					--fmt;
					goto charout;

				case '-':	/* left justification */
					ljustf = TRUE;
					goto fmtnxt;

				case ' ':
				case '+':	/* leading sign flag */
					sign = *fmt;
					goto fmtnxt;

				case '*':	/* parameter width value */
					i = *args++;
					if (dpoint)
						preci = i;
					else
						width = i;
					goto fmtnxt;

				case '.':	/* secondary width field */
					dpoint = TRUE;
					goto fmtnxt;

				case 'l':	/* long data */
					lval = TRUE;
					goto fmtnxt;

				case 'd':	/* Signed decimal */
				case 'i':
					_ltoa((long)((lval)
						?(*((long *) args))
						:(*((int  *) args))),
					      ptmp, 10);
					if(lval)
						args = ((unsigned int *)
							(((long *) args) + 1));
					else
						args = ((unsigned int *)
							(((int *) args) + 1));
					goto printit;

				case 'b':	/* Unsigned binary */
					radix = 2;
					goto usproc;

				case 'o':	/* Unsigned octal */
					radix = 8;
					goto usproc;

				case 'p':	/* Pointer */
					lval = TRUE;
					pad = '0';
					width = 6;
					preci = 8;
					/* fall thru */

				case 'x':	/* Unsigned hexadecimal */
				case 'X':
					radix = 16;
					/* fall thru */

				case 'u':	/* Unsigned decimal */
usproc:
					_ultoa((unsigned long)((lval)
						?(*((unsigned long *) args))
						: *args++ ),
					      ptmp, radix);
					if(lval)
						args = ((unsigned int *)
						(((unsigned long *) args) + 1));
					if (*fmt == 'x')
						_strlwr(ptmp);
					goto printit;

				case 'c':	/* Character */
					ptmp[0] = *args++;
					ptmp[1] = '\0';
					goto nopad;

				case 's':	/* String */
					ptmp = *((char **) args);
					args = ((unsigned int *)
						(((char **) args) + 1));
nopad:
					sign = '\0';
					pad  = ' ';
printit:
					cnt += _prtfld(op, put, ptmp, ljustf,
						       sign, pad, width, preci);
					break;

				default:	/* unknown character */
					goto charout;
				}
			}
		else
			{
charout:
			(*put)(*fmt, op);		/* normal char out */
			++cnt;
			}
		++fmt;
		}
	return(cnt);
	}
