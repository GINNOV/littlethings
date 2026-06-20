
/*
 *  EXP.C
 *
 *  (c)Copyright 1988, Matthew Dillon, All Rights Reserved.
 *
 *  Handle expression evaluation and addressing mode decode.
 *
 *  NOTE! If you use the string field in an expression you must clear
 *  the SYM_MACRO and SYM_STRING bits in the flags before calling
 *  freesymbollist()!
 */

#include "asm.h"


/*
 *  evaluate an expression.  Figure out the addressing mode:
 *
 *		    implied
 *	#val	    immediate
 *	val	    zero page or absolute
 *	val,x	    zero,x or absolute,x
 *	val,y	    zero,y or absolute,y
 *	(val)       indirect
 *	(val,x)     zero indirect x
 *	(val),y     zero indirect y
 *
 *	exp, exp,.. LIST of expressions
 *
 *  an absolute may be returned as zero page
 *  a relative may be returned as zero page or absolute
 *
 *  unary:  - ~ ! < >
 *  binary: (^)(* / %)(+ -)(>> <<)(& |)(`)(&& ||)(== != < > <= >=)
 *
 *  values: symbol, octal, decimal, $hex, %binary, 'c "str"
 *
 */

#define MAXOPS	32
#define MAXARGS 64

ubyte Argflags[MAXARGS];
long  Argstack[MAXARGS];
ubyte *Argstring[MAXARGS];
short Oppri[MAXOPS];
void  (*Opdis[MAXOPS]) ARGS((long, long, long, long));

uword	Argi, Opi, Lastwasop;
uword	Argibase, Opibase;

SYMBOL *
eval(str)
register char *str;
{
    register SYMBOL *base, *cur;
    uword oldargibase = Argibase;
    uword oldopibase = Opibase;
    uword scr;

    Argibase = Argi;
    Opibase = Opi;
    Lastwasop = 1;
    base = cur = allocsymbol();

    while (*str) {
	if (Xdebug)
	    printf("char '%c'\n", *str);
	switch(*str) {
	case ' ':
	case '\n':
	    ++str;
	    break;
	case '~':
	    if (Lastwasop)
		doop(op_invert, 128);
	    else
		asmerr(0,0);
	    ++str;
	    break;
	case '*':
	    doop(op_mult, 20);
	    ++str;
	    break;
	case '/':
	    doop(op_div, 20);
	    ++str;
	    break;
	case '%':
	    if (Lastwasop) {
		str = (char *)pushbin(str+1);
	    } else {
		doop(op_mod, 20);
		++str;
	    }
	    break;
	case '?':   /*  10      */
	    doop(op_question, 10);
	    ++str;
	    break;
	case '+':   /*  19      */
	    doop(op_add, 19);
	    ++str;
	    break;
	case '-':   /*  19: -   (or - unary)        */
	    if (Lastwasop) {
		doop(op_negate, 128);
	    } else {
		doop(op_sub, 19);
	    }
	    ++str;
	    break;
	case '>':   /*  18: >> <<  17: > >= <= <    */
	    if (Lastwasop) {
		doop(op_takemsb, 128);
		++str;
		break;
	    }

	    if (str[1] == '>') {
		doop(op_shiftright, 18);
		++str;
	    } else if (str[1] == '=') {
		doop(op_greatereq, 17);
		++str;
	    } else {
		doop(op_greater, 17);
	    }
	    ++str;
	    break;
	case '<':
	    if (Lastwasop) {
		doop(op_takelsb, 128);
		++str;
		break;
	    }
	    if (str[1] == '<') {
		doop(op_shiftleft, 18);
		++str;
	    } else if (str[1] == '=') {
		doop(op_smallereq, 17);
		++str;
	    } else {
		doop(op_smaller, 17);
	    }
	    ++str;
	    break;
	case '=':   /*  16: ==  (= same as ==)      */
	    if (str[1] == '=')
		++str;
	    doop(op_eqeq, 16);
	    ++str;
	    break;
	case '!':   /*  16: !=                      */
	    if (Lastwasop) {
		doop(op_not, 128);
	    } else {
		doop(op_noteq, 16);
		++str;
	    }
	    ++str;
	    break;
	case '&':   /*  15: &   12: &&              */
	    if (str[1] == '&') {
		doop(op_andand, 12);
		++str;
	    } else {
		doop(op_and, 15);
	    }
	    ++str;
	    break;
	case '^':   /*  14: ^                       */
	    doop(op_xor, 14);
	    ++str;
	    break;
	case '|':   /*  13: |   11: ||              */
	    if (str[1] == '|') {
		doop(op_oror, 11);
		++str;
	    } else {
		doop(op_or, 13);
	    }
	    ++str;
	    break;
	case '[':   /*  eventually an argument      */
	    if (Opi == MAXOPS)
		puts("too many ops");
	    else
		Oppri[Opi++] = 0;
	    ++str;
	    break;
	case ']':
	    while(Opi != Opibase && Oppri[Opi-1])
		evaltop();
	    if (Opi != Opibase)
		--Opi;
	    ++str;
	    if (Argi == Argibase) {
		puts("']' error, no arg on stack");
		break;
	    }
	    if (*str == 'd') {  /*  STRING CONVERSION   */
		char buf[32];
		++str;
		if (Argflags[Argi-1] == 0) {
		    sprintf(buf,"%ld",Argstack[Argi-1]);
		    Argstring[Argi-1] = (ubyte *)strcpy(malloc(strlen(buf)+1),buf);
		}
	    }
	    break;
	case '#':
	    cur->addrmode = AM_IMM8;
	    ++str;
	    break;
	case '(':
	    cur->addrmode = AM_INDWORD;
	    ++str;
	    break;
	case ')':
	    if (cur->addrmode == AM_INDWORD && str[1] == ',' && (str[2]|0x20) == 'y') {
		cur->addrmode = AM_INDBYTEY;
		str += 2;
	    }
	    ++str;
	    break;
	case ',':
	    while(Opi != Opibase)
		evaltop();
	    Lastwasop = 1;
	    scr = str[1]|0x20;	/* to lower case */
	    if (cur->addrmode == AM_INDWORD && scr == 'x' && !alphanum(str[2])) {
		cur->addrmode = AM_INDBYTEX;
		++str;
	    } else if (scr == 'x' && !alphanum(str[2])) {
		cur->addrmode = AM_0X;
		++str;
	    } else if (scr == 'y' && !alphanum(str[2])) {
		cur->addrmode = AM_0Y;
		++str;
	    } else {
		register SYMBOL *new = allocsymbol();
		cur->next = new;
		--Argi;
		if (Argi < Argibase)
		    asmerr(0,0);
		if (Argi > Argibase)
		    asmerr(0,0);
		cur->value = Argstack[Argi];
		cur->flags = Argflags[Argi];
		if (cur->string= (ubyte *)Argstring[Argi]) {
		    cur->flags |= SYM_STRING;
		    if (Xdebug)
			printf("STRING: %s\n", cur->string);
		}
		cur = new;
	    }
	    ++str;
	    break;
	case '$':
	    str = (char *)pushhex(str+1);
	    break;
	case '\'':
	    str = (char *)pushchar(str+1);
	    break;
	case '\"':
	    str = (char *)pushstr(str+1);
	    break;
	default:
	    if (*str == '0')
		str = (char *)pushoct(str);
	    else {
		if (*str > '0' && *str <= '9')
		    str = (char *)pushdec(str);
		else
		    str = (char *)pushsymbol(str);
	    }
	    break;
	}
    }
    while(Opi != Opibase)
	evaltop();
    if (Argi != Argibase) {
	--Argi;
	cur->value = Argstack[Argi];
	cur->flags = Argflags[Argi];
	if (cur->string= (ubyte *)Argstring[Argi]) {
	    cur->flags |= SYM_STRING;
	    if (Xdebug)
		printf("STRING: %s\n", cur->string);
	}
	if (base->addrmode == 0)
	    base->addrmode = AM_BYTEADR;
    }
    if (Argi != Argibase || Opi != Opibase)
	asmerr(0,0);
    Argi = Argibase;
    Opi  = Opibase;
    Argibase = oldargibase;
    Opibase = oldopibase;
    return(base);
}

int
alphanum(c)
int c;
{
    return ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9'));
}

void
evaltop()
{
    if (Xdebug)
	printf("evaltop @(A,O) %d %d\n", Argi, Opi);
    if (Opi <= Opibase) {
	asmerr(0,0);
	Opi = Opibase;
	return;
    }
    --Opi;
    if (Oppri[Opi] == 128) {
	if (Argi < Argibase + 1) {
	    asmerr(0,0);
	    Argi = Argibase;
	    return;
	}
	--Argi;
	(*Opdis[Opi])(Argstack[Argi], Argflags[Argi], 0, 0);
    } else {
	if (Argi < Argibase + 2) {
	    asmerr(0,0);
	    Argi = Argibase;
	    return;
	}
	Argi -= 2;
	(*Opdis[Opi])(Argstack[Argi], Argstack[Argi+1], Argflags[Argi], Argflags[Argi+1]);
    }
}

void
stackarg(val, flags, ptr1)
long val;
int flags;
ubyte *ptr1;
{
    ubyte *str = NULL;

    if (Xdebug)
	printf("stackarg %ld (@%d)\n", val, Argi);
    Lastwasop = 0;
    if (flags & SYM_STRING) {
	register ubyte *ptr = ptr1;
	register ubyte *new;
	register uword len;
	val = len = 0;
	while (*ptr && *ptr != '\"') {
	    val = (val << 8) | *ptr;
	    ++ptr;
	    ++len;
	}
	new = malloc(len + 1);
	BMov(ptr1, new, len);
	new[len] = 0;
	flags &= ~SYM_STRING;
	str = new;
    }
    Argstack[Argi] = val;
    Argstring[Argi] = str;
    Argflags[Argi] = flags;
    if (++Argi == MAXARGS) {
	puts("stackarg: maxargs stacked");
	Argi = Argibase;
    }
    while (Opi != Opibase && Oppri[Opi-1] == 128)
	evaltop();
}

void
doop(func, pri)
void (*func) ARGS((long, long, long, long));
int pri;
{
    if (Xdebug)
	puts("doop");
    Lastwasop = 1;
    if (Opi == Opibase || pri == 128) {
	if (Xdebug)
	    printf("doop @ %d unary\n", Opi);
	Opdis[Opi] = func;
	Oppri[Opi] = pri;
	++Opi;
	return;
    }
    while (Opi != Opibase && Oppri[Opi-1] && pri <= Oppri[Opi-1])
	evaltop();
    if (Xdebug)
	printf("doop @ %d\n", Opi);
    Opdis[Opi] = func;
    Oppri[Opi] = pri;
    ++Opi;
    if (Opi == MAXOPS) {
	puts("doop: too many operators");
	Opi = Opibase;
    }
    return;
}

void
op_takelsb(v1, f1, x1, x2)
long v1;
long f1;
long x1, x2;
{
    stackarg(v1 & 0xFFL, f1, NULL);
}

void
op_takemsb(v1, f1, x1, x2)
long v1;
long f1;
long x1, x2;
{
    stackarg((v1 >> 8) & 0xFF, f1, NULL);
}

void
op_negate(v1, f1, x1, x2)
long v1;
long f1;
long x1, x2;
{
    stackarg(-v1, f1, NULL);
}

void
op_invert(v1, f1, x1, x2)
long v1;
long f1;
long x1, x2;
{
    stackarg(~v1, f1, NULL);
}

void
op_not(v1, f1, x1, x2)
long v1;
long f1;
long x1, x2;
{
    stackarg((long)!v1, f1, NULL);
}

void
op_mult(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    stackarg(v1 * v2, f1|f2, NULL);
}

void
op_div(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    if (f1|f2) {
	stackarg(0L, f1|f2, NULL);
	return;
    }
    if (v2 == 0) {
	puts("division by zero");
	stackarg(0L, 0, NULL);
    } else {
	stackarg(v1 / v2, 0, NULL);
    }
}

void
op_mod(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    if (f1|f2) {
	stackarg(0L, f1|f2, NULL);
	return;
    }
    if (v2 == 0)
	stackarg(v1, 0, NULL);
    else
	stackarg(v1 % v2, 0, NULL);
}

void
op_question(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    if (f1)
	stackarg(0L, f1, NULL);
    else
	stackarg((long)((v1) ? v2 : 0), ((v1) ? f2 : 0), NULL);
}

void
op_add(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    stackarg(v1 + v2, f1|f2, NULL);
}

void
op_sub(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    stackarg(v1 - v2, f1|f2, NULL);
}

void
op_shiftright(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    if (f1|f2)
	stackarg(0L, f1|f2, NULL);
    else
	stackarg((long)(v1 >> v2), 0, NULL);
}

void
op_shiftleft(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    if (f1|f2)
	stackarg(0L, f1|f2, NULL);
    else
	stackarg((long)(v1 << v2), 0, NULL);
}

void
op_greater(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    stackarg((long)(v1 > v2), f1|f2, NULL);
}

void
op_greatereq(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    stackarg((long)(v1 >= v2), f1|f2, NULL);
}

void
op_smaller(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    stackarg((long)(v1 < v2), f1|f2, NULL);
}

void
op_smallereq(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    stackarg((long)(v1 <= v2), f1|f2, NULL);
}

void
op_eqeq(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    stackarg((long)(v1 == v2), f1|f2, NULL);
}

void
op_noteq(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    stackarg((long)(v1 != v2), f1|f2, NULL);
}

void
op_andand(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    if ((!f1 && !v1) || (!f2 && !v2)) {
	stackarg(0L, 0, NULL);
	return;
    }
    stackarg(1L, f1|f2, NULL);
}

void
op_oror(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    if ((!f1 && v1) || (!f2 && v2)) {
	stackarg(1L, 0, NULL);
	return;
    }
    stackarg(0L, f1|f2, NULL);
}

void
op_xor(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    stackarg(v1^v2, f1|f2, NULL);
}

void
op_and(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    stackarg(v1&v2, f1|f2, NULL);
}

void
op_or(v1, v2, f1, f2)
long v1, v2;
long f1, f2;
{
    stackarg(v1|v2, f1|f2, NULL);
}

ubyte *
pushchar(str)
ubyte *str;
{
    if (*str) {
	stackarg((long)*str, 0, NULL);
	++str;
    } else {
	stackarg((long)' ', 0, NULL);
    }
    return((ubyte *)str);
}

ubyte *
pushhex(str)
ubyte *str;
{
    register long val = 0;
    for (;; ++str) {
	if (*str >= '0' && *str <= '9') {
	    val = (val << 4) + (*str - '0');
	    continue;
	}
	if ((*str >= 'a' && *str <= 'f') || (*str >= 'A' && *str <= 'F')) {
	    val = (val << 4) + ((*str&0x1F) + 9);
	    continue;
	}
	break;
    }
    stackarg(val, 0, NULL);
    return((ubyte *)str);
}

ubyte *
pushoct(str)
ubyte *str;
{
    register long val = 0;
    while (*str >= '0' && *str <= '7') {
	val = (val << 3) + (*str - '0');
	++str;
    }
    stackarg(val, 0, NULL);
    return((ubyte *)str);
}

ubyte *
pushdec(str)
ubyte *str;
{
    register long val = 0;
    while (*str >= '0' && *str <= '9') {
	val = (val * 10) + (*str - '0');
	++str;
    }
    stackarg(val, 0, NULL);
    return((ubyte *)str);
}

ubyte *
pushbin(str)
ubyte *str;
{
    register long val = 0;
    while (*str == '0' || *str == '1') {
	val = (val << 1) | (*str - '0');
	++str;
    }
    stackarg(val, 0, NULL);
    return((ubyte *)str);
}

ubyte *
pushstr(str)
ubyte *str;
{
    stackarg(0L, SYM_STRING, str);
    while (*str && *str != '\"')
	++str;
    if (*str == '\"')
	++str;
    return((ubyte *)str);
}

ubyte *
pushsymbol(str)
ubyte *str;
{
    register SYMBOL *sym;
    register ubyte *ptr;
    ubyte macro = 0;

    for (ptr = str;
	*ptr == '_' ||
	*ptr == '.' ||
	(*ptr >= 'a' && *ptr <= 'z') ||
	(*ptr >= 'A' && *ptr <= 'Z') ||
	(*ptr >= '0' && *ptr <= '9');
	++ptr
    );
    if (ptr == str) {
	asmerr(9,0);
	printf("char = '%c' %d (-1: %d)\n", *str, *str, *(str-1));
	if (F_listfile)
	    fprintf(FI_listfile, "char = '%c' code %d\n", *str, *str);
	return((ubyte *)str+1);
    }
    if (sym = findsymbol(str, ptr - str)) {
	if (sym->flags & SYM_UNKNOWN)
	    ++Redo_eval;
	if (sym->flags & SYM_MACRO) {
	    macro = 1;
	    sym = eval(sym->string);
	}
	if (sym->flags & SYM_STRING)
	    stackarg(0L, SYM_STRING, sym->string);
	else
	    stackarg(sym->value, sym->flags & SYM_UNKNOWN, NULL);
	sym->flags |= SYM_REF|SYM_MASREF;
	if (macro)
	    freesymbollist(sym);
    } else {
	stackarg(0L, SYM_UNKNOWN, NULL);
	sym = createsymbol(str, ptr - str);
	sym->flags = SYM_REF|SYM_MASREF|SYM_UNKNOWN;
	++Redo_eval;
    }
    return(ptr);
}

