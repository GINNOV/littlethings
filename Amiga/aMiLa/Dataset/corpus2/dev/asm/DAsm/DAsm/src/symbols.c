
/*
 *  SYMBOLS.C
 *
 *  (c)Copyright 1988, Matthew Dillon, All Rights Reserved.
 */

#include "asm.h"

uword hash1 ARGS((ubyte *, short));

static SYMBOL org;
static SYMBOL special;
static SYMBOL specchk;

void
setspecial(value, flags)
int value, flags;
{
    special.value = value;
    special.flags = flags;
}

SYMBOL *
findsymbol(str, len)
ubyte *str;
int len;
{
    register uword h1;
    register SYMBOL *sym;
    ubyte buf[128];
    static SYMBOL org;

    if (str[0] == '.') {
	if (len == 1) {
	    if (Csegment->flags & SF_RORG) {
		org.flags = Csegment->rflags & SYM_UNKNOWN;
		org.value = Csegment->rorg;
	    } else {
		org.flags = Csegment->flags & SYM_UNKNOWN;
		org.value = Csegment->org;
	    }
	    return(&org);
	}
	if (len == 2 && str[1] == '.')
	    return(&special);
	if (len == 3 && str[1] == '.' && str[2] == '.') {
	    specchk.flags = 0;
	    specchk.value = CheckSum;
	    return(&specchk);
	}
	{
	    register INCFILE *inc;
	    BMov(str+1, buf, --len);
	    sprintf(buf + len, ".%ld", Localindex);
	    len += strlen(buf+len);
	    for (inc = Incfile->next; inc; inc = inc->next) {
		sprintf(buf+len,".%ld", inc->lineno);
		len += strlen(buf+len);
	    }
	    str = buf;
	}
    }
    h1 = hash1(str, (short)len);
    for (sym = SHash[h1]; sym; sym = sym->next) {
	if (sym->namelen == len && BCmp(sym->name, str, len) == 0)
	    break;
    }
    return(sym);
}

SYMBOL *
createsymbol(str, len)
ubyte *str;
int len;
{
    register SYMBOL *sym;
    register uword h1;
    ubyte buf[128];

    if (str[0] == '.') {
	register INCFILE *inc;
	BMov(str+1, buf, --len);
	sprintf(buf + len, ".%ld", Localindex);
	len += strlen(buf+len);
	for (inc = Incfile->next; inc; inc = inc->next) {
	    sprintf(buf+len,".%ld", inc->lineno);
	    len += strlen(buf+len);
	}
	str = buf;
    }
    sym = (SYMBOL *)allocsymbol();
    sym->name = permalloc(len+1);
    BMov(str, sym->name, len);        /*  permalloc zero's the array for us */
    sym->namelen = len;
    h1 = hash1(str, (short)len);
    sym->next = SHash[h1];
    sym->flags= SYM_UNKNOWN;
    SHash[h1] = sym;
    return(sym);
}

static uword
hash1(str, len)
register ubyte *str;
register short len;
{
    register uword result = 0;

    while (len--)
	result = (result << 2) ^ *str++;
    return((uword)(result & SHASHAND));
}

/*
 *  Label Support Routines
 */

void
programlabel()
{
    register uword len;
    register SYMBOL *sym;
    register SEGMENT *cseg = Csegment;
    register ubyte *str;
    ubyte   rorg = cseg->flags & SF_RORG;
    ubyte   cflags = (rorg) ? cseg->rflags : cseg->flags;
    ulong   pc = (rorg) ? cseg->rorg : cseg->org;

    Plab = cseg->org;
    Pflags = cseg->flags;
    str = Av[0];
    if (*str == 0)
	return;
    len = strlen(str);
    if (str[len-1] == ':')
	--len;

    /*
     *	Redo:	unknown and referenced
     *		referenced and origin not known
     *		known and phase error	(origin known)
     */

    if (sym = findsymbol(str, len)) {
	if ((sym->flags & (SYM_UNKNOWN|SYM_REF)) == (SYM_UNKNOWN|SYM_REF)) {
	    ++Redo;
	    Redo_why |= 1 << 13;
	    if (Xdebug)
		printf("redo 13: '%s' %04x %04x\n", sym->name, sym->flags, cflags);
	} else
	if ((cflags & SYM_UNKNOWN) && (sym->flags & SYM_REF)) {
	    ++Redo;
	    Redo_why |= 1 << 13;
	} else
	if (!(cflags & SYM_UNKNOWN) && !(sym->flags & SYM_UNKNOWN)) {
	    if (pc != sym->value) {
		printf("mismatch %10s %s  pc: %s\n", sym->name, sftos(sym->value, sym->flags), sftos(pc, cflags & 7));
		asmerr(17,0);
		++Redo;
		Redo_why |= 1 << 14;
	    }
	}
    } else {
	sym = createsymbol(str, len);
    }
    sym->value = pc;
    sym->flags = (sym->flags & ~SYM_UNKNOWN) | (cflags & SYM_UNKNOWN);
}

SYMBOL *SymAlloc;

SYMBOL *
allocsymbol()
{
    SYMBOL *sym;

    if (SymAlloc) {
	sym = SymAlloc;
	SymAlloc = SymAlloc->next;
	BZero(sym, sizeof(SYMBOL));
    } else {
	sym = (SYMBOL *)permalloc(sizeof(SYMBOL));
    }
    return(sym);
}

void
freesymbol(sym)
SYMBOL *sym;
{
    sym->next = SymAlloc;
    SymAlloc = sym;
}

void
freesymbollist(sym)
SYMBOL *sym;
{
    register SYMBOL *next;

    while (sym) {
	next = sym->next;
	sym->next = SymAlloc;
	if (sym->flags & SYM_STRING)
	    free(sym->string);
	SymAlloc = sym;
	sym = next;
    }
}

