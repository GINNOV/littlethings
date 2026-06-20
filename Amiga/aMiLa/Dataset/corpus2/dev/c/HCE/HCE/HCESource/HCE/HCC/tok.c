/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	tok.c
 *
 *	Basic level token routines
 *
 *	At this level, we return the following things:
 *		id's - strings of alpha-alnum
 *		integer constants
 *		float constants
 *		string constants
 *		multi-char tokens
 *
 *	We DONT know about:
 *		keywords
 *		#defined id's
 *		any other meaning of a name
 *
 *	Interface:
 *		call nxttok() to get next token
 *		look at 'curtok' for current token
 *		note that curtok.name points to a static area
 *		  for ID or SCON
 *
 *		if EOF is seen, we call endfile() before
 *		  giving up
 *
 *	Special flags:  (tk_flags)
 *		These special flags are needed for the pre-processor.
 *		All but TK_SEENL are 1-shot.
 *
 *		TK_SEENL - want to see \n
 *		TK_WS - want to see white space (for #define)
 *		TK_NOESC - dont do '\' escapes in strings
 *		TK_LTSTR - '<' is a string starter
 *		TK_ONLY1 - skip to token after \n  (for #if--)
 *
 * Modified by Detlef Wuerkner for AMIGA
 * Changes marked with TETISOFT
 * except '#ifdef DEBUG'
 *
 * 1993
 * Modified by Jason Petty to work with hce.
 * Changes marked with VANSOFT.
 *
 */

#include "h_inc/hce_defines.h"  /* Added-VANSOFT. */
#include <clib/stdio.h>
#include "h_inc/param.h"
#include "h_inc/tok.h"

#if dLibs
#include <clib/ctype.h>
#endif

#define LINENO_X  12     /* X/Y pos, line number will appear in Msg Box, */
#define LINENO_Y  2      /* while compiling. VANSOFT. */

#define TK_SEENL  1      /* want to see NL token */
#define TK_SEEWS  2      /* want to see WS token */
#define TK_ONLY1  4      /* only want 1st token on line */
#define TK_LTSTR  8      /* '<' starts a string */
#define TK_NOESC  16     /* dont do '\' escapes in string */
#define NOCHAR	  0x100

#ifdef DEBUG
extern int oflags[];
#define debug oflags['b'-'a']
#endif

extern double f_zero, f_ten, f_tenth, f_e10, f_em10;	/* V2 */
extern FILE *input,*myinput;
extern int lineno;
extern int nmerrors;           /* Added, VANSOFT. */
extern unsigned long mem_mon;  /* Monitor memory used(see mem.c).VANSOFT.*/
extern int msg_shown;          /* Number of error msgs shown.    VANSOFT.*/
extern char ERR_BUF[128];      /* Used for error messages. VANSOFT. */

static int keepx;              /* x pos in 'LINE[][x]' */
static int keepy;              /* y pos in 'LINE[y][]' */
static int keepend;            /* If testing section of code this marks end*/

int tk_flags, sawnl;
int see_eof=FALSE;             /* Must see EOF as soon as possible. VANSOFT*/
struct tok curtok;
char curstr[MAXSTR+1];

nxttok()
{
	register struct tok *t;
	char *getname();
	long getnum();
	register int c;
	double getfrac();

	t = &curtok;
	t->name = curstr;
	t->name[0] = 0;
	t->prec = 0;
	t->flags = 0;
more:
	c = mygetchar();
	if (c == EOF) {
		tk_flags = 0;
		return 0;
	}
	if (c == '\n') {
		tk_flags &= ~TK_ONLY1;
		if ((tk_flags & TK_SEENL) == 0)
			goto more;
		t->tnum = NL;
		t->name = "\n";
		goto out;
	}
	if (tk_flags & TK_ONLY1)
		goto more;
	if (c <= ' ') {
		if ((tk_flags & TK_SEEWS) == 0)
			goto more;
		t->tnum = WS;
		t->name = " ";
		goto out;
	}
	if (c >= '0' && c <= '9') {
		t->tnum = ICON;
		t->ival = getnum(c);
		if (lookfrac(t->ival) || lookexp(t->ival,f_zero)) /* V2 */
			goto out;
	moresuf:
		c = mygetchar();
		if (tolower(c) == 'l') {
			t->flags |= SEE_L;
			goto moresuf;
		} else if (tolower(c) == 'u') {
			t->flags |= SEE_U;
			goto moresuf;
		} else {
			myungetc(c);
		}
		sprintf(curstr, "%ld",
			t->ival);
		goto out;
	}
	if (isalpha(c) || c == '_') {
		t->tnum = ID;
		t->name = getname(c);
		goto out;
	}
	if (c == '.') {
		c = mygetchar();
		if (c >= '0' && c <= '9') {
			gotfrac(0L, getfrac(c));
			goto out;
		} else {
			myungetc(c);
			matchop('.');
			goto out;
		}
	}
	if(matchop(c) == 0)
		goto more;
out:
#ifdef	DEBUG
	if (debug) printf("<%s>", t->name);
#endif
	tk_flags &= TK_SEENL;	/* all but SEENL are 1-shot */
	return 1;
}

long
getnum(c)
register int c;
{
	register long val = 0;
	int base, i;

	if (c == '0') {
		base = 8;
	} else {
		base = 10;
		val = c - '0';
	}
more:
	c = mygetchar();
	if (c == EOF)
		return val;
	if (tolower(c) == 'x' && val == 0) {
		base = 16;
		goto more;
	}
	if (c >= '0' && c <= '9') {
		val = base*val + (c - '0');
		goto more;
	}
	if (base == 16 && (i = ishexa(c))) {
		val = 16*val + i;
		goto more;
	}
	myungetc(c);
	return val;
}

double
getfrac(c)
register c;
{
	register double val;
	register double dig = f_tenth;		/* V2 */

	val = dig * (c - '0');
more:
	c = mygetchar();
	if (c >= '0' && c <= '9') {
		dig = f_tenth * dig;		/* V2 */
		val += dig * (c - '0');
		goto more;
	}
	myungetc(c);
	return val;
}

lookfrac(intpart)
long intpart;
{
	int c;
	double frac;

	c = mygetchar();
	if (c != '.') {
		myungetc(c);
		return 0;
	}
	c = mygetchar();
	if (c >= '0' && c <= '9') {
		frac = getfrac(c);
	} else {
		myungetc(c);
		frac = f_zero;			/* V2 */
	}
	gotfrac(intpart, frac);
	return 1;
}

gotfrac(intpart, frac)
long intpart;
double frac;
{
	if (lookexp(intpart, frac) == 0)
		makeflt(intpart, frac, 0);
}

lookexp(intpart, frac)
long intpart;
double frac;
{
	int c;
	int minus;
	int exp;

	minus = 0;
	c = mygetchar();
	if (tolower(c) != 'e') {
		myungetc(c);
		return 0;
	}
	c = mygetchar();
	if (c == '-') {
		minus = 1;
		c = mygetchar();
	} else if (c == '+')
		c = mygetchar();
	if (c >= '0' && c <= '9') {
		exp = getnum(c);
	} else {
		exp = 0;
		myungetc(c);
	}
	if (minus)
		exp = -exp;
	makeflt(intpart, frac, exp);
	return 1;
}

makeflt(intpart, frac, exp)
long intpart;
double frac;
{
	register double val;
	double mod, mod10;
	register struct tok *t;

	val = intpart + frac;
	if (exp > 0) {
		mod = f_ten;			/* V2 */
		mod10 = f_e10;			/* V2 */
	} else if (exp < 0) {
		mod = f_tenth;			/* V2 */
		mod10 = f_em10;			/* V2 */
		exp = -exp;
	}
	while (exp >= 10) {
		val *= mod10;
		exp -= 10;
	}
	while (exp--)
		val *= mod;		/* slow and dirty */
	t = &curtok;
	t->tnum = FCON;
	t->fval = val;
	sprintf(t->name, FLTFORM, val);
}

char *
getname(c)
register int c;
{
	register int nhave;

	nhave = 0;
	do {
		if (nhave < MAXSTR)
			curstr[nhave++] = c;
		c = mygetchar();
	} while (isalnum(c) || c == '_');
	myungetc(c);
	curstr[nhave] = 0;
	return curstr;
}

static char *holdstr;

chr_push(s)
char *s;
{
	holdstr = s;
}

static int holdchar, xholdchar;

mygetchar()
{
	register int c;
	int c2;

	if (holdchar) {
		c = holdchar;
		holdchar = 0;
		goto out;
	}
	if (holdstr) {		/* used for -D args */
		c = *holdstr++;
		if (c == 0) {
			holdstr = NULL;
			return '\n';
		}
		return c;
	}

retry:
	c = xgetc();
	if (c == EOF && see_eof)
                 goto out;
	if (c == EOF) {        
		if (endfile())
		        goto retry;
	} 
      else {
            if(c == '\\') {		/* ansi handling of backslash nl */
		  c2 = xgetc();
		 if (c2 == '\n') {
		      lineno++;
                    if(!nmerrors)      /* Show user current line.VANSOFT*/
                      (void)Show_Val((ULONG)lineno,LINENO_X,LINENO_Y);
	              goto retry;
                 } else
	              xholdchar = c2;
              }
	   }
out:
	if (c == '\n') {
		sawnl++;	/* for pre.c */
		lineno++;
             if(!nmerrors)      /* Show user current line.VANSOFT*/
                Show_Val((ULONG)lineno,LINENO_X,LINENO_Y);
	}
	return c;
}

/* This is used to reset x/y position counters for reading of*/
/* hce`s 'LINE[][]' buffer. VANSOFT. */
reset_bufxy(ystart,yend)
int ystart,yend;
{
 keepx=0;
 keepy=ystart;
 keepend=yend;
}

xgetc() /* Modified to get input from either a file or hce`s 'LINE[][]' ,*/
{       /* buffer. If 'input' is NULL then LINE[][], else file. VANSOFT. */
 register int c;

      if (xholdchar) {
          c = xholdchar;
          xholdchar = 0;
          return c;
          }

#if CC68|dLibs
#ifndef	FOR_AMIGA     /* ADDED BY TETISOFT */

      if (input == stdin)	/* bypass stupid input */
          c = hackgetc();
        else
#endif
#endif

 if(input == NULL)   /* Use 'LINE[][]' for input. VANSOFT*/
   {
   if((keepend) && (keepy >= keepend)) {
       c = EOF;                               /* Endof test.? */
      } else {
   if(!COMP_OK || LINE[keepy][0] == '\0' || keepy > (T_MAXLINE-2))
           {
            c = EOF;                          /* Endof file.? */
            }
           else {
             if(LINE[keepy][keepx] == '\0') { /* Endof line.? */
                   keepy++;
                   keepx=0;
                   }
                  c = LINE[keepy][keepx++];
                 }
      }
    }
  else {         /* Normal file input. */
       if(!COMP_OK)
          c = EOF;
        else
          c = getc(input);
        }

/* Mem check VANSOFT. */
      if(!MEM_OK) {
         strcpy(ERR_BUF,"FATAL: Memory to low to continue!!");
         Show_Status(ERR_BUF);
         Get_FstERR(ERR_BUF);
         STOP_MSG                 /* Do`nt show any more error msgs.  */
         STOP_COMPILE             /* This will cause compile to stop. */
      (void)SetMemFailed();       /* This will cause mem to be freed. */
         }

      if (c != EOF)
          c &= 0x7f;
return c;
}

myungetc(c)
char c;
{
	if (c != EOF)
		holdchar = c;
	if (c == '\n') {
		lineno--;
             if(!nmerrors)      /* Show user current line.VANSOFT*/
                Show_Val((ULONG)lineno,LINENO_X,LINENO_Y);
            }
}

struct op {
	char *name;
	char *asname;
	int flags;
	char prec;
	char value;
} ops[] = {
	{"{"},
	{"}"},
	{"["},
	{"]"},
	{"("},
	{")"},
	{"#"},
	{"\\"},
	{";"},
	{","},
	{":"},
	{"."},

	{"\"", 0, SPECIAL},
	{"'", 0, SPECIAL},

	{"==", 0, C_NOT_A, 5},
	{"=", 0, 0},

	{"++", 0, CAN_U},
	{"+", "+=", CAN_AS|C_AND_A, 2},

	{"--", 0, CAN_U},
	{"->", 0, 0, 0, ARROW},
	{"-", "-=", CAN_U|CAN_AS, 2},

	{"*", "*=", CAN_U|CAN_AS|C_AND_A, 1},
	{"%", "%=", CAN_AS, 1},

	{"/*", 0, SPECIAL},
	{"/", "/=", CAN_AS, 1},

	{"&&", 0, 0, 9},
	{"&", "&=", CAN_U|CAN_AS|C_AND_A, 6},

	{"||", 0, 0, 10},
	{"|", "|=", CAN_AS|C_AND_A, 8},

	{"!=", 0, C_NOT_A, 5, NOTEQ},
	{"!", 0, CAN_U},

	{"~", 0, CAN_U},

	{"^", "^=", CAN_AS|C_AND_A, 7},

	{"<<", "<<=", CAN_AS, 3},
	{"<=", 0, C_NOT_A, 4, LTEQ},
	{"<", 0, SPECIAL|C_NOT_A, 4},

	{">>", ">>=", CAN_AS, 3},
	{">=", 0, C_NOT_A, 4, GTEQ},
	{">", 0, C_NOT_A, 4},

	{"?", 0, 0},

	{0, 0, 0}
};

#define FIRST_C	'!'
#define LAST_C	0177
struct op *opstart[LAST_C-FIRST_C+1];

mo_init()
{
	register struct op *p;
	register c;

	for (p=ops; p->name; p++) {
		c = p->name[0];
		if (opstart[c-FIRST_C] == 0)
			opstart[c-FIRST_C] = p;
	}
}

matchop(c)
{
	register struct tok *t;
	register struct op *p;
	int nxt;
	int value;
	static first = 0;

	t = &curtok;
	nxt = mygetchar();
	value = c;
	if (first == 0) {
		mo_init();
		first = 1;
	}
	p = opstart[c-FIRST_C];
	if (p)
	for (; p->name; p++)
		if (p->name[0] == c)
			if (p->name[1] == 0 || p->name[1] == nxt) {
				if (p->name[1] == 0)
					myungetc(nxt);
				else {
					value = p->value ? p->value :
						DOUBLE value;
				}
				if (p->flags & SPECIAL)
					if (c != '<' || 
					  tk_flags & TK_LTSTR)
						return dospec(p);
				t->flags = p->flags;
				if (p->flags & CAN_AS) {
					nxt = mygetchar();
					if (nxt != '=') {
						myungetc(nxt);
					} else {
						value = ASSIGN value;
						t->flags = 0;
					}
				}
				t->name = isassign(value)?p->asname:p->name;
				t->tnum = value;
				t->prec = isassign(value)? 0 : p->prec;
				return 1;
			}
	myungetc(nxt);
	t->name = "???";
	t->tnum = BADTOK;
	return 0;
}

dospec(p)
struct op *p;
{
	register struct tok *t;
	register int c;
	int nhave;
	int endc;
        char *s;

	t = &curtok;
	switch (p->name[0]) {
	case '/':		        /* slash-star (COMMENT) */
look:
                        endc = lineno;
                        see_eof = TRUE;
		 do {                   /* Now checks for EOF. VANSOFT. */
			c = mygetchar();
		     }
                 while (c != '*' && c != EOF);
		        c = mygetchar();
                        see_eof = FALSE;
		     if(c == '/')       /* Normal end of comment. */
                        return 0;
                     if(c == EOF) {     /* Comment error. Added, VANSOFT */
                        lineno = endc;
                        error("missing end of comment:  '*/'");
                        return 0;
                        }
		  myungetc(c);
		  goto look;
	case '\'':
		t->tnum = ICON;
		t->ival = getschar('\''); /* allow only 1 for now*/
		while (getschar('\'') != NOCHAR)
			;
		sprintf(curstr, "%d", (int)t->ival);
		return 1;
	case '<':
		endc = '>';
		t->tnum = SCON2;
		goto strs;
	case '"':
		endc = '"';
		t->tnum = SCON;
	strs:
		t->name = curstr;
		nhave = 0;
		c = getschar(endc);
		while (c != NOCHAR) {
			if (c >= 0 && c <= 1 && nhave < MAXSTR) {
				 /* allow null */
				curstr[nhave++] = 1;
				c++;
			}
			if (nhave < MAXSTR)
				curstr[nhave++] = c;
			c = getschar(endc);
		}
		curstr[nhave] = 0;
		return 1;
	}
}

getoct(c)
{
	char n, i;

	n = c - '0';
	for (i=1; i < 3; i++) {
		c = mygetchar();
		if (c < '0' || c > '7') {
			myungetc(c);
			return (int)n;
		}
		n = 8*n + (c - '0');
	}
	return (int)n;
}

/* ADDED BY TETISOFT */
gethex()
{
	char c, n, basechar;
	int i;

	n = 0;
	for (i=1; i < 3; i++) {
		c = mygetchar();
		if (c >= '0' && c <= '9') {
			basechar = '0';
		} else if (c >= 'a' && c <= 'f') {
			basechar = 'a'-10;
		} else if (c >= 'A' && c <= 'F') {
			basechar = 'A'-10;
		} else {
			myungetc(c);
			return (int)n;
		}
		n = 16*n + (c - basechar);
	}
	return (int)n;
}

getschar(del)
char del;
{
	register int c;

more:
	c = mygetchar();
	if (c == del)
		return NOCHAR;
	if (c == '\n') {
		error("nl in string");
		myungetc(c);
		return NOCHAR;
	}
	if (c == '\\' && (tk_flags & TK_NOESC) == 0) {
		c = mygetchar();
		if (c == del)
			return c;
		if (c >= '0' && c <= '7')
			return getoct(c);
		switch (c) {
/*
		case '\n':
			goto more;
*/
		case 'b':
			c = '\b';
			break;
		case 'n':
			c = '\n';
			break;
		case 't':
			c = '\t';
			break;
		case 'r':
			c = '\r';
			break;
		case 'f':
			c = '\f';
			break;

/* ADDED BY TETISOFT, add ANSI Bell, Vertical Tab and hex numbers */
		case 'a':
			c = '\a'; /* was \7 when first compiled */
			break;
		case 'v':
			c = '\v'; /* was \13 when first compiled */
			break;
		case 'x':
			return gethex();

		}
	}
	return c;
}

#if !dLibs

isalpha(c)
register char c;
{
	if ((c>='a' && c<='z') ||
		(c>='A' && c<='Z'))
		return 1;
	return 0;
}

isalnum(c)
register char c;
{
	return (isalpha(c) || (c>='0' && c<='9'));
}

tolower(c)
register char c;
{
	if (c>='A' && c<='Z')
		c += 'a'-'A';
	return c;
}

#endif

ishexa(c)
register char c;
{
	if (c>='a' && c<='f')
		return (c-'a'+10);
	if (c>='A' && c<='F')
		return (c-'A'+10);
	return 0;
}

#if CC68
hackgetc()
{
	register int c;

	c = bios(2,2);
	switch (c) {
	case 4:
		return EOF;
	case '\r':
	case '\n':
		bios(3,2,'\r');
		bios(3,2,'\n');
		return '\n';
	}
	bios(3,2,c);
	return c;
}
#endif

#if dLibs

/* ADDED BY TETISOFT */
#ifndef	FOR_AMIGA

hackgetc()
{
	register int c;

	c = getchar();
	switch (c) {
	case 4:
		return EOF;
	case '\n':
		putchar('\n');
		break;
	}
	return c;
}

/* ADDED BY TETISOFT */
#endif

#endif
