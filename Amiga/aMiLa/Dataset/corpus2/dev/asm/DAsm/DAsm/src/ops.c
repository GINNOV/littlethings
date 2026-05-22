
/*
 *  OPS.C
 *
 *  (c)Copyright 1988, Matthew Dillon, All Rights Reserved.
 *
 *  Handle mnemonics and pseudo ops
 *
 */

#include "asm.h"

ubyte	Gen[256];
ubyte	OrgFill = DEFORGFILL;
short	Glen;

/*
 *  An opcode modifies the SEGMENT flags in the following ways:
 */

void
v_processor(str, mne)
register char *str;
MNE *mne;
{
    extern MNE	Mne6502[];
    extern MNE	Mne6803[];
    extern MNE	MneHD6303[];
    extern MNE	Mne68705[];
    extern MNE	Mne68HC11[];
    static int	called;

    if (called)
	return;
    called = 1;
    if (strcmp(str,"6502") == 0) {
	addhashtable(Mne6502);
	MsbOrder = 0;	   /*  lsb,msb */
	Processor = 6502;
    }
    if (strcmp(str,"6803") == 0) {
	addhashtable(Mne6803);
	MsbOrder = 1;	   /*  msb,lsb */
	Processor = 6803;
    }
    if (strcmp(str,"HD6303") == 0 || strcmp(str, "hd6303") == 0) {
	addhashtable(Mne6803);
	addhashtable(MneHD6303);
	MsbOrder = 1;	   /*  msb,lsb */
	Processor = 6303;
    }
    if (strcmp(str,"68705") == 0) {
	addhashtable(Mne68705);
	MsbOrder = 1;	   /*  msb,lsb */
	Processor = 68705;
    }
    if (strcmp(str,"68HC11") == 0 || strcmp(str, "68hc11") == 0) {
	addhashtable(Mne68HC11);
	MsbOrder = 1;	   /*  msb,lsb */
	Processor = 6811;
    }
    if (!Processor)
	asmerr(20,1);
}

#define badcode(mne,adrmode)  (!(mne->okmask & (1L << adrmode)))

void
v_mnemonic(str, mne)
char *str;
register MNE *mne;
{
    register uword addrmode;
    register SYMBOL *sym;
    register uword opcode;
    short opidx;
    SYMBOL *symbase;
    short   opsize;

    Csegment->flags |= SF_REF;
    programlabel();
    symbase = eval(str);

    if (Xtrace)
	printf("PC: %04lx  MNE: %s  addrmode: %d  ", Csegment->org, mne->name, symbase->addrmode);
    for (sym = symbase; sym; sym = sym->next) {
	if (sym->flags & SYM_UNKNOWN) {
	    ++Redo;
	    Redo_why |= 1 << 0;
	}
    }
    sym = symbase;

    if (mne->flags & MF_IMOD) {
	if (sym->next) {
	    sym->addrmode = AM_BITMOD;
	    if ((mne->flags & MF_REL) && sym->next)
		sym->addrmode = AM_BITBRAMOD;
	}
    }
    addrmode = sym->addrmode;
    if ((sym->flags & SYM_UNKNOWN) || sym->value >= 0x100)
	opsize = 2;
    else
	opsize = (sym->value) ? 1 : 0;
    while (badcode(mne,addrmode) && Cvt[addrmode])
	addrmode = Cvt[addrmode];
    if (Xtrace)
	printf("mnemask: %08lx adrmode: %d  Cvt[am]: %d\n", mne->okmask, addrmode, Cvt[addrmode]);
    if (badcode(mne,addrmode)) {
	asmerr(5,0);
	freesymbollist(symbase);
	return;
    }
    if (Mnext >= 0 && Mnext < NUMOC) {          /*  Force   */
	addrmode = Mnext;
	if (badcode(mne,addrmode)) {
	    asmerr(19,0);
	    freesymbollist(symbase);
	    return;
	}
    }
    if (Xtrace)
	printf("final addrmode = %d\n", addrmode);
    while (opsize > Opsize[addrmode]) {
	if (Cvt[addrmode] == 0 || badcode(mne,Cvt[addrmode])) {
	    if (sym->flags & SYM_UNKNOWN)
		break;
	    asmerr(14,0);
	    break;
	}
	addrmode = Cvt[addrmode];
    }
    opcode = mne->opcode[addrmode];
    opidx = 1 + (opcode > 0xFF);
    if (opidx == 2) {
	Gen[0] = opcode >> 8;
	Gen[1] = opcode;
    } else {
	Gen[0] = opcode;
    }
    switch(addrmode) {
    case AM_BITMOD:
	sym = symbase->next;
	if (!(sym->flags & SYM_UNKNOWN) && sym->value >= 0x100)
	    asmerr(14,0);
	Gen[opidx++] = sym->value;
	if (!(symbase->flags & SYM_UNKNOWN)) {
	    if (symbase->value > 7)
		asmerr(15,0);
	    else
		Gen[0] += symbase->value << 1;
	}
	break;
    case AM_BITBRAMOD:
	if (!(symbase->flags & SYM_UNKNOWN)) {
	    if (symbase->value > 7)
		asmerr(15,0);
	    else
		Gen[0] += symbase->value << 1;
	}
	sym = symbase->next;
	if (!(sym->flags & SYM_UNKNOWN) && sym->value >= 0x100)
	    asmerr(14,0);
	Gen[opidx++] = sym->value;
	sym = sym->next;
	break;
    case AM_REL:
	break;
    default:
	if (Opsize[addrmode] > 0)
	    Gen[opidx++] = sym->value;
	if (Opsize[addrmode] == 2) {
	    if (MsbOrder) {
		Gen[opidx-1] = sym->value >> 8;
		Gen[opidx++] = sym->value;
	    } else {
		Gen[opidx++] = sym->value >> 8;
	    }
	}
	sym = sym->next;
	break;
    }
    if (mne->flags & MF_MASK) {
	if (sym) {
	    if (!(sym->flags & SYM_UNKNOWN) && sym->value >= 0x100)
		asmerr(14,0);
	    Gen[opidx] = sym->value;
	    sym = sym->next;
	} else {
	    asmerr(16, 1);
	}
	++opidx;
    }
    if ((mne->flags & MF_REL) || addrmode == AM_REL) {
	++opidx;		/*  to end of instruction   */
	if (!sym)
	    asmerr(16, 1);
	else
	if (!(sym->flags & SYM_UNKNOWN)) {
	    long    pc;
	    ubyte   pcf;
	    long    dest;
	    pc = (Csegment->flags & SF_RORG) ? Csegment->rorg : Csegment->org;
	    pcf= (Csegment->flags & SF_RORG) ? Csegment->rflags : Csegment->flags;
	    if ((pcf & 3) == 0) {
		dest = sym->value - pc - opidx;
		if (dest >= 128 || dest < -128)
		    asmerr(10,0);
	    }
	    Gen[opidx-1] = dest & 0xFF;     /*	byte before end of inst.    */
	}
    }
    Glen = opidx;
    generate();
    freesymbollist(symbase);
}

void
v_trace(str, mne)
char *str;
MNE *mne;
{
    if (str[1] == 'n')
	Xtrace = 1;
    else
	Xtrace = 0;
}

void
v_list(str, mne)
char *str;
MNE *mne;
{
    programlabel();

    Glen = 0;		/*  Only so outlist() works */
    if (strncmp(str, "off", 2) == 0 || strncmp(str, "OFF", 2) == 0)
	ListMode = 0;
    else
	ListMode = 1;
}

void
v_include(str, mne)
char *str;
MNE *mne;
{
    char    *buf;

    programlabel();
    if (*str == '\"') {
	buf = (char *)malloc(strlen(str));
	strcpy(buf, str+1);
	for (str = buf; *str && *str != '\"'; ++str);
	*str = 0;
	pushinclude(buf);
	free(buf);
    } else {
	pushinclude(str);
    }
}

void
v_seg(str, mne)
char *str;
MNE *mne;
{
    register SEGMENT *seg;

    for (seg = Seglist; seg; seg = seg->next) {
	if (strcmp(str, seg->name) == 0) {
	    Csegment = seg;
	    programlabel();
	    return;
	}
    }
    Csegment = seg = (SEGMENT *)zmalloc(sizeof(SEGMENT));
    seg->next = Seglist;
    seg->name = (ubyte *)strcpy(malloc(strlen(str)+1), str);
    seg->flags= seg->rflags = seg->initflags = seg->initrflags = SF_UNKNOWN;
    Seglist = seg;
    if (Mnext == AM_BSS)
	seg->flags |= SF_BSS;
    programlabel();
}

void
v_hex(str, mne)
register char *str;
MNE *mne;
{
    register int i;
    register int result;

    programlabel();
    Glen = 0;
    for (i = 0; str[i]; ++i) {
	if (str[i] == ' ')
	    continue;
	result = (gethexdig(str[i]) << 4) + gethexdig(str[i+1]);
	if (str[++i] == 0)
	    break;
	Gen[Glen++] = result;
    }
    generate();
}

int
gethexdig(c)
int c;
{
    if (c >= '0' && c <= '9')
	return(c - '0');
    if (c >= 'a' && c <= 'f')
	return(c - 'a' + 10);
    if (c >= 'A' && c <= 'F')
	return(c - 'A' + 10);
    asmerr(0,0);
    puts("(Must be a valid hex digit)");
    if (F_listfile)
	fputs("(Must be a valid hex digit)\n", FI_listfile);
    return(0);
}

void
v_err(str, mne)
char *str;
MNE *mne;
{
    programlabel();
    asmerr(11, 1);
    exit(1);
}

void
v_dc(str, mne)
char *str;
MNE *mne;
{
    register SYMBOL *sym;
    register SYMBOL *tmp;
    register ulong  value;
    char *macstr;
    char vmode = 0;

    Glen = 0;
    programlabel();
    if (mne->name[1] == 'v') {
	register short i;
	vmode = 1;
	for (i = 0; str[i] && str[i] != ' '; ++i);
	tmp = findsymbol(str, i);
	str += i;
	if (tmp == NULL) {
	    puts("EQM label not found");
	    return;
	}
	if (tmp->flags & SYM_MACRO) {
	    macstr = (char *)tmp->string;
	} else {
	    puts("must specify EQM label for DV");
	    return;
	}
    }
    sym = eval(str);
    for (; sym; sym = sym->next) {
	value = sym->value;
	if (sym->flags & SYM_UNKNOWN) {
	    ++Redo;
	    Redo_why |= (1 << 2);
	}
	if (sym->flags & SYM_STRING) {
	    register ubyte *ptr = (ubyte *)sym->string;
	    while (value = *ptr) {
		if (vmode) {
		    setspecial(value, 0);
		    tmp = eval(macstr);
		    value = tmp->value;
		    if (tmp->flags & SYM_UNKNOWN) {
			++Redo;
			Redo_why |= (1 << 3);
		    }
		    freesymbollist(tmp);
		}
		switch(Mnext) {
		default:
		case AM_BYTE:
		    Gen[Glen++] = value & 0xFF;
		    break;
		case AM_WORD:
		    if (MsbOrder) {
			Gen[Glen++] = (value >> 8) & 0xFF;
			Gen[Glen++] = value & 0xFF;
		    } else {
			Gen[Glen++] = value & 0xFF;
			Gen[Glen++] = (value >> 8) & 0xFF;
		    }
		    break;
		case AM_LONG:
		    if (MsbOrder) {
			Gen[Glen++] = (value >> 24)& 0xFF;
			Gen[Glen++] = (value >> 16)& 0xFF;
			Gen[Glen++] = (value >> 8) & 0xFF;
			Gen[Glen++] = value & 0xFF;
		    } else {
			Gen[Glen++] = value & 0xFF;
			Gen[Glen++] = (value >> 8) & 0xFF;
			Gen[Glen++] = (value >> 16)& 0xFF;
			Gen[Glen++] = (value >> 24)& 0xFF;
		    }
		    break;
		}
		++ptr;
	    }
	} else {
	    if (vmode) {
		setspecial(value, sym->flags);
		tmp = eval(macstr);
		value = tmp->value;
		if (tmp->flags & SYM_UNKNOWN) {
		    ++Redo;
		    Redo_why |= 1 << 4;
		}
		freesymbollist(tmp);
	    }
	    switch(Mnext) {
	    default:
	    case AM_BYTE:
		Gen[Glen++] = value & 0xFF;
		break;
	    case AM_WORD:
		if (MsbOrder) {
		    Gen[Glen++] = (value >> 8) & 0xFF;
		    Gen[Glen++] = value & 0xFF;
		} else {
		    Gen[Glen++] = value & 0xFF;
		    Gen[Glen++] = (value >> 8) & 0xFF;
		}
		break;
	    case AM_LONG:
		if (MsbOrder) {
		    Gen[Glen++] = (value >> 24)& 0xFF;
		    Gen[Glen++] = (value >> 16)& 0xFF;
		    Gen[Glen++] = (value >> 8) & 0xFF;
		    Gen[Glen++] = value & 0xFF;
		} else {
		    Gen[Glen++] = value & 0xFF;
		    Gen[Glen++] = (value >> 8) & 0xFF;
		    Gen[Glen++] = (value >> 16)& 0xFF;
		    Gen[Glen++] = (value >> 24)& 0xFF;
		}
		break;
	    }
	}
    }
    generate();
    freesymbollist(sym);
}

void
v_ds(str, mne)
char *str;
MNE *mne;
{
    register SYMBOL *sym;
    int mult = 1;
    long filler = 0;

    if (Mnext == AM_WORD)
	mult = 2;
    if (Mnext == AM_LONG)
	mult = 4;
    programlabel();
    if (sym = eval(str)) {
	if (sym->next)
	    filler = sym->next->value;
	if (sym->flags & SYM_UNKNOWN) {
	    ++Redo;
	    Redo_why |= 1 << 5;
	} else {
	    if (sym->next && sym->next->flags & SYM_UNKNOWN) {
		++Redo;
		Redo_why |= 1 << 5;
	    }
	    genfill(filler, sym->value, mult);
	}
	freesymbollist(sym);
    }
}

void
v_org(str, mne)
char *str;
MNE *mne;
{
    register SYMBOL *sym;

    sym = eval(str);
    Csegment->org = sym->value;
    if (sym->flags & SYM_UNKNOWN)
	Csegment->flags |= SYM_UNKNOWN;
    else
	Csegment->flags &= ~SYM_UNKNOWN;
    if (Csegment->initflags & SYM_UNKNOWN) {
	Csegment->initorg = sym->value;
	Csegment->initflags = sym->flags;
    }
    if (sym->next) {
	OrgFill = sym->next->value;
	if (sym->next->flags & SYM_UNKNOWN)
	    asmerr(18,1);
    }
    programlabel();
    freesymbollist(sym);
}

void
v_rorg(str, mne)
char *str;
MNE *mne;
{
    register SYMBOL *sym = eval(str);

    Csegment->flags |= SF_RORG;
    if (sym->addrmode != AM_IMP) {
	Csegment->rorg = sym->value;
	if (sym->flags & SYM_UNKNOWN)
	    Csegment->rflags |= SYM_UNKNOWN;
	else
	    Csegment->rflags &= ~SYM_UNKNOWN;
	if (Csegment->initrflags & SYM_UNKNOWN) {
	    Csegment->initrorg = sym->value;
	    Csegment->initrflags = sym->flags;
	}
    }
    programlabel();
    freesymbollist(sym);
}

void
v_rend(str, mne)
char *str;
MNE *mne;
{
    programlabel();
    Csegment->flags &= ~SF_RORG;
}

void
v_align(str, mne)
char *str;
MNE *mne;
{
    SYMBOL *sym = eval(str);
    ubyte   fill = 0;
    ubyte   rorg = Csegment->flags & SF_RORG;

    if (rorg)
	Csegment->rflags |= SF_REF;
    else
	Csegment->flags |= SF_REF;
    if (sym->next) {
	if (sym->next->flags & SYM_UNKNOWN) {
	    ++Redo;
	    Redo_why |= 1 << 6;
	} else {
	    fill = sym->value;
	}
    }
    if (rorg) {
	if ((Csegment->rflags | sym->flags) & SYM_UNKNOWN) {
	    ++Redo;
	    Redo_why |= 1 << 7;
	} else {
	    register long n = sym->value - (Csegment->rorg % sym->value);
	    if (n != sym->value)
		genfill(fill, n, 1);
	}
    } else {
	if ((Csegment->flags | sym->flags) & SYM_UNKNOWN) {
	    ++Redo;
	    Redo_why |= 1 << 8;
	} else {
	    register long n = sym->value - (Csegment->org % sym->value);
	    if (n != sym->value)
		genfill(fill, n, 1);
	}
    }
    freesymbollist(sym);
    programlabel();
}

void
v_subroutine(str, mne)
char *str;
MNE *mne;
{
    Localindex = Incfile->lineno;
    programlabel();
}

void
v_equ(str, mne)
char *str;
MNE *mne;
{
    SYMBOL *sym = eval(str);
    SYMBOL *lab;

    lab = findsymbol(Av[0], strlen(Av[0]));
    if (!lab)
	lab = createsymbol(Av[0], strlen(Av[0]));
    if (!(lab->flags & SYM_UNKNOWN)) {
	if (sym->flags & SYM_UNKNOWN) {
	    ++Redo;
	    Redo_why |= 1 << 9;
	} else {
	    if (lab->value != sym->value) {
		asmerr(13,0);
		printf("old value: $%04lx  new value: $%04lx\n", lab->value, sym->value);
		++Redo;
		Redo_why |= 1 << 10;
	    }
	}
    }
    lab->value = sym->value;
    lab->flags = sym->flags & (SYM_UNKNOWN|SYM_STRING);
    lab->string = sym->string;
    sym->flags &= ~(SYM_STRING|SYM_MACRO);
    freesymbollist(sym);
}

void
v_eqm(str, mne)
char *str;
MNE *mne;
{
    register SYMBOL *lab;
    register int len = strlen(Av[0]);

    if (lab = findsymbol(Av[0], len)) {
	if (lab->flags & SYM_STRING)
	    free(lab->string);
    } else {
	lab = createsymbol(Av[0], len);
    }
    lab->value = 0;
    lab->flags = SYM_STRING | SYM_SET | SYM_MACRO;
    lab->string = (ubyte *)strcpy(malloc(strlen(str)+1), str);
}

void
v_echo(str, mne)
char *str;
MNE *mne;
{
    SYMBOL *sym = eval(str);
    SYMBOL *s;
    char buf[256];

    for (s = sym; s; s = s->next) {
	if (!(s->flags & SYM_UNKNOWN)) {
	    if (s->flags & (SYM_MACRO|SYM_STRING))
		sprintf(buf,"%s", s->string);
	    else
		sprintf(buf,"$%lx", s->value);
	    if (FI_listfile)
		fprintf(FI_listfile, " %s", buf);
	    printf(" %s", buf);
	}
    }
    puts("");
    if (FI_listfile)
	putc('\n', FI_listfile);
}

void
v_set(str, mne)
char *str;
MNE *mne;
{
    SYMBOL *sym = eval(str);
    SYMBOL *lab;

    lab = findsymbol(Av[0], strlen(Av[0]));
    if (!lab)
	lab = createsymbol(Av[0], strlen(Av[0]));
    lab->value = sym->value;
    lab->flags = sym->flags & (SYM_UNKNOWN|SYM_STRING);
    lab->string = sym->string;
    sym->flags &= ~(SYM_STRING|SYM_MACRO);
    freesymbollist(sym);
}

void
v_execmac(str, mac)
char *str;
MACRO *mac;
{
    register INCFILE *inc;
    STRLIST *base;
    register STRLIST **psl, *sl;
    register char *s1;

    programlabel();

    if (Mlevel == MAXMACLEVEL) {
	puts("infinite macro recursion");
	return;
    }
    ++Mlevel;
    base = (STRLIST *)malloc(strlen(str)+5);
    base->next = NULL;
    strcpy(base->buf, str);
    psl = &base->next;
    while (*str && *str != '\n') {
	s1 = str;
	while (*str && *str != '\n' && *str != ',')
	    ++str;
	sl = (STRLIST *)malloc(5+(str-s1));
	sl->next = NULL;
	*psl = sl;
	psl = &sl->next;
	BMov(s1, sl->buf, (str-s1));
	sl->buf[str-s1] = 0;
	if (*str == ',')
	    ++str;
	while (*str == ' ')
	    ++str;
    }

    inc = (INCFILE *)zmalloc(sizeof(INCFILE));
    inc->next = Incfile;
    inc->name = mac->name;
    inc->fi   = Incfile->fi;	/* garbage */
    inc->lineno = 0;
    inc->flags = INF_MACRO;
    inc->saveidx = Localindex;
    inc->strlist = mac->strlist;
    inc->args	 = base;
    Incfile = inc;

    Localindex = 0;
}

void
v_end(str, mne)
char *str;
MNE *mne;
{
    puts("END not implemented yet");
}

void
v_endm(str, mne)
char *str;
MNE *mne;
{
    register INCFILE *inc = Incfile;
    register STRLIST *args, *an;

    programlabel();
    if (inc->flags & INF_MACRO) {
	--Mlevel;
	for (args = inc->args; args; args = an) {
	    an = args->next;
	    free(args);
	}
	Localindex = inc->saveidx;
	Incfile = inc->next;
	free(inc);
	return;
    }
    puts("not within a macro");
}

void
v_mexit(str, mne)
char *str;
MNE *mne;
{
    v_endm(NULL,NULL);
}

void
v_ifconst(str, mne)
char *str;
MNE *mne;
{
    SYMBOL *sym;

    programlabel();
    sym = eval(str);
    pushif(sym->flags == 0);
    freesymbollist(sym);
}

void
v_ifnconst(str, mne)
char *str;
MNE *mne;
{
    SYMBOL *sym;

    programlabel();
    sym = eval(str);
    pushif(sym->flags != 0);
    freesymbollist(sym);
}

void
v_if(str, mne)
char *str;
MNE *mne;
{
    SYMBOL *sym;

    if (!Ifstack->true || !Ifstack->acctrue) {
	pushif(0);
	return;
    }
    programlabel();
    sym = eval(str);
    if (sym->flags) {
	++Redo;
	Redo_why |= 1 << 11;
	pushif(0);
	Ifstack->acctrue = 0;
    } else {
	pushif((short)!!sym->value);
    }
    freesymbollist(sym);
}

void
v_else(str, mne)
char *str;
MNE *mne;
{
    if (Ifstack->acctrue && !(Ifstack->flags & IFF_BASE)) {
	programlabel();
	Ifstack->true = !Ifstack->true;
    }
}

void
v_endif(str, mne)
char *str;
MNE *mne;
{
    IFSTACK *ifs = Ifstack;

    if (!(ifs->flags & IFF_BASE)) {
	if (ifs->acctrue)
	    programlabel();
	if (ifs->file != Incfile) {
	    puts("too many endif's");
	} else {
	    Ifstack = ifs->next;
	    free(ifs);
	}
    }
}

void
v_repeat(str, mne)
char *str;
MNE *mne;
{
    register REPLOOP *rp;
    register SYMBOL *sym;

    if (!Ifstack->true || !Ifstack->acctrue) {
	pushif(0);
	return;
    }
    programlabel();
    sym = eval(str);
    if (sym->value == 0) {
	pushif(0);
	freesymbollist(sym);
	return;
    }
    rp = (REPLOOP *)zmalloc(sizeof(REPLOOP));
    rp->next = Reploop;
    rp->file = Incfile;
    if (Incfile->flags & INF_MACRO)
	rp->seek = (long)Incfile->strlist;
    else
	rp->seek = ftell(Incfile->fi);
    rp->lineno = Incfile->lineno;
    rp->count = sym->value;
    if (rp->flags = sym->flags) {
	++Redo;
	Redo_why |= 1 << 12;
    }
    Reploop = rp;
    freesymbollist(sym);
    pushif(1);
}

void
v_repend(str, mne)
char *str;
MNE *mne;
{
    if (!Ifstack->true || !Ifstack->acctrue) {
	v_endif(NULL,NULL);
	return;
    }
    if (Reploop && Reploop->file == Incfile) {
	if (Reploop->flags == 0 && --Reploop->count) {
	    if (Incfile->flags & INF_MACRO)
		Incfile->strlist = (STRLIST *)Reploop->seek;
	    else
		fseek(Incfile->fi,Reploop->seek,0);
	    Incfile->lineno = Reploop->lineno;
	} else {
	    rmnode((ulong **)&Reploop, sizeof(REPLOOP));
	    v_endif(NULL,NULL);
	}
	return;
    }
    puts("no repeat");
}

static long Seglen;
static long Seekback;

void
generate()
{
    long seekpos;
    static ulong org;
    short i;

    if (!Redo) {
	if (!(Csegment->flags & SF_BSS)) {
	    for (i = Glen - 1; i >= 0; --i)
		CheckSum += Gen[i];
	    if (Fisclear) {
		Fisclear = 0;
		if (Csegment->flags & SF_UNKNOWN) {
		    ++Redo;
		    Redo_why |= 1 << 1;
		    return;
		}
		org = Csegment->org;
		if (F_format < 3) {
		    putc((short)(org & 0xFF), FI_temp);
		    putc((short)((org >> 8) & 0xFF), FI_temp);
		    if (F_format == 2) {
			Seekback = ftell(FI_temp);
			Seglen = 0;
			putc(0, FI_temp);
			putc(0, FI_temp);
		    }
		}
	    }
	    switch(F_format) {
	    default:
	    case 3:
	    case 1:
		if (Csegment->org < org) {
		    printf("segment: %s %s  vs current org: %04lx\n", Csegment->name, sftos(Csegment->org, Csegment->flags), org);
		    asmerr(12, 1);
		    exit(1);
		}
		while (Csegment->org != org) {
		    putc(OrgFill, FI_temp);
		    ++org;
		}
		fwrite(Gen, Glen, 1, FI_temp);
		break;
	    case 2:
		if (org != Csegment->org) {
		    org = Csegment->org;
		    seekpos = ftell(FI_temp);
		    fseek(FI_temp, Seekback, 0);
		    putc((short)(Seglen & 0xFF), FI_temp);
		    putc((short)((Seglen >> 8) & 0xFF), FI_temp);
		    fseek(FI_temp, seekpos, 0);
		    putc((short)(org & 0xFF), FI_temp);
		    putc((short)((org >> 8) & 0xFF), FI_temp);
		    Seekback = ftell(FI_temp);
		    Seglen = 0;
		    putc(0, FI_temp);
		    putc(0, FI_temp);
		}
		fwrite(Gen, Glen, 1, FI_temp);
		Seglen += Glen;
	    }
	    org += Glen;
	}
    }
    Csegment->org += Glen;
    if (Csegment->flags & SF_RORG)
	Csegment->rorg += Glen;
}

void
closegenerate()
{
    if (!Redo) {
	if (F_format == 2) {
	    fseek(FI_temp, Seekback, 0);
	    putc((short)(Seglen & 0xFF), FI_temp);
	    putc((short)((Seglen >> 8) & 0xFF), FI_temp);
	    fseek(FI_temp, 0L, 2);
	}
    }
}

void
genfill(fill, entries, size)
long fill, entries;
int size;
{
    register long bytes = entries;  /*	multiplied later    */
    register short i;
    register ubyte c3,c2,c1,c0;

    if (!bytes)
	return;
    c3 = fill >> 24;
    c2 = fill >> 16;
    c1 = fill >> 8;
    c0 = fill;
    switch(size) {
    case 1:
	BSet(Gen, sizeof(Gen), c0);
	break;
    case 2:
	bytes <<= 1;
	for (i = 0; i < sizeof(Gen); i += 2) {
	    if (MsbOrder) {
		Gen[i+0] = c1;
		Gen[i+1] = c0;
	    } else {
		Gen[i+0] = c0;
		Gen[i+1] = c1;
	    }
	}
	break;
    case 4:
	bytes <<= 2;
	for (i = 0; i < sizeof(Gen); i += 4) {
	    if (MsbOrder) {
		Gen[i+0] = c3;
		Gen[i+1] = c2;
		Gen[i+2] = c1;
		Gen[i+3] = c0;
	    } else {
		Gen[i+0] = c0;
		Gen[i+1] = c1;
		Gen[i+2] = c2;
		Gen[i+3] = c3;
	    }
	}
	break;
    }
    for (Glen = sizeof(Gen); bytes > sizeof(Gen); bytes -= sizeof(Gen))
	generate();
    Glen = bytes;
    generate();
}

void
pushif(bool)
int bool;
{
    register IFSTACK *ifs = (IFSTACK *)zmalloc(sizeof(IFSTACK));
    ifs->next = Ifstack;
    ifs->file = Incfile;
    ifs->flags = 0;
    ifs->true  = bool;
    ifs->acctrue = Ifstack->acctrue && Ifstack->true;
    Ifstack = ifs;
}

