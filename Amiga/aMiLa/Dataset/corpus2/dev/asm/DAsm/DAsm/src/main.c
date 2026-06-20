
/*
 *  MAIN.C
 *
 *  (c)Copyright 1988, Matthew Dillon, All Rights Reserved.
 *     Freely Distributable (for non-profit) ONLY.  No redistribution
 *     of any modified text files or redistribution of a subset of the
 *     source is allowed.  Redistribution of modified binaries IS allowed
 *     under the above terms.
 *
 *  DASM   sourcefile
 *
 *  NOTE: must handle mnemonic extensions and expression decode/compare.
 */

#include "asm.h"

void outlistfile ARGS((char *));
char *cleanup ARGS((ubyte *));
uword hash1 ARGS((ubyte *));

#define MAXLINE 256
#define ISEGNAME    "code"

uword _fmode = 0;	/*  was trying to port to 16 bit IBM-PC lattice C */
			/*  but failed	*/

ubyte	Disable_me;
ubyte	StopAtEnd = 0;
ubyte	*Extstr;

void
main(ac, av)
int ac;
char *av[];
{
    ubyte buf[MAXLINE];
    uword pass, i;
    register MNE *mne;
    register ulong oldredo = -1;
    register ulong oldwhy = 0;
    register ulong oldeval = 0;

    addhashtable(Ops);
    pass = 1;

    if (ac < 2) {
fail:
	puts("DASM V2.12, high level Macro Assembler");
	puts("(C)Copyright 1988 by Matthew Dillon, All Rights Reserved");
	puts("redistributable for non-profit only");
	puts("");
	puts("DASM sourcefile [options]");
	puts(" -f#      output format");
	puts(" -oname   output file");
	puts(" -lname   list file");
	puts(" -sname   symbol dump");
	puts(" -v#      verboseness");
	puts(" -Dname=exp   define label");
	exit(1);
    }
    puts("DASM V2.12, (c)Copyright 1988 Matthew Dillon, All Rights Reserved");
    puts("Warning: The meaning of <exp & >exp has been reversed in this release");
    for (i = 2; i < ac; ++i) {
	if (av[i][0] == '-') {
	    register ubyte *str = (ubyte *)av[i]+2;
	    switch(av[i][1]) {
	    case 'd':
		Xdebug = atoi(str);
		printf("Xdebug = %ld\n", Xdebug);
		break;
	    case 'D':
		while (*str && *str != '=')
		    ++str;
		if (*str == '=') {
		    *str = 0;
		    ++str;
		} else {
		    str = (ubyte *)"0";
		}
		Av[0] = (ubyte *)(av[i]+2);
		v_set(str, NULL);
		break;
	    case 'f':   /*  F_format    */
		F_format = atoi(str);
		if (F_format < 1 || F_format > 3)
		    panic("Illegal format specification");
		break;
	    case 'o':   /*  F_outfile   */
		F_outfile = (char *)str;
nofile:
		if (*str == 0)
		    panic("need file name for specified option");
		break;
	    case 'l':   /*  F_listfile  */
		F_listfile = (char *)str;
		goto nofile;
	    case 's':   /*  F_symfile   */
		F_symfile = (char *)str;
		goto nofile;
	    case 'v':   /*  F_verbose   */
		F_verbose = atoi(str);
		break;
	    case 't':   /*  F_temppath  */
		F_temppath = (char *)str;
		break;
	    default:
		goto fail;
	    }
	    continue;
	}
	goto fail;
    }

    /*	INITIAL SEGMENT */

    {
	register SEGMENT *seg = (SEGMENT *)permalloc(sizeof(SEGMENT));
	seg->name = (ubyte *)strcpy(permalloc(sizeof(ISEGNAME)), ISEGNAME);
	seg->flags= seg->rflags = seg->initflags = seg->initrflags = SF_UNKNOWN;
	Csegment = Seglist = seg;
    }
    /*	TOP LEVEL IF	*/
    {
	register IFSTACK *ifs = (IFSTACK *)zmalloc(sizeof(IFSTACK));
	ifs->file = NULL;
	ifs->flags = IFF_BASE;
	ifs->acctrue = 1;
	ifs->true  = 1;
	Ifstack = ifs;
    }
nextpass:
    Localindex = 0;
    _fmode = 0x8000;
    FI_temp = fopen(F_outfile, "w");
    _fmode = 0;
    Fisclear = 1;
    CheckSum = 0;
    if (FI_temp == NULL) {
	printf("unable to [re]open '%s'\n", F_outfile);
	exit(1);
    }
    if (F_listfile) {
	FI_listfile = fopen(F_listfile, "w");
	if (FI_listfile == NULL) {
	    printf("unable to [re]open '%s'\n", F_listfile);
	    exit(1);
	}
    }
    pushinclude(av[1]);
    while (Incfile) {
	for (;;) {
	    char *comment;
	    if (Incfile->flags & INF_MACRO) {
		if (Incfile->strlist == NULL) {
		    Av[0] = (ubyte *)"";
		    v_mexit(NULL,NULL);
		    continue;
		}
		strcpy(buf, Incfile->strlist->buf);
		Incfile->strlist = Incfile->strlist->next;
	    } else {
		if (fgets(buf, MAXLINE, Incfile->fi) == NULL)
		    break;
	    }
	    if (Xdebug)
		printf("%08lx %s\n", Incfile, buf);
	    comment = cleanup(buf);
	    if (Xdebug)
		printf("ok1 "), fflush(stdout);
	    ++Incfile->lineno;
	    parse(buf);
	    if (Xdebug)
		printf("ok2 "), fflush(stdout);
	    if (Av[1][0]) {
		findext(Av[1]);
		if (mne = findmne(Av[1])) {
		    if ((mne->flags & MF_IF) || (Ifstack->true && Ifstack->acctrue))
			(*mne->vect)(Av[2], mne);
		} else {
		    if (Ifstack->true && Ifstack->acctrue) {
			printf("unknown mnemonic: '%s'\n", Av[1]);
			asmerr(4,0);
		    }
		}
	    } else {
		if (Ifstack->true && Ifstack->acctrue)
		    programlabel();
	    }
	    if (Xdebug)
		printf("ok3 "), fflush(stdout);
	    if (F_listfile && ListMode)
		outlistfile(comment);
	}
	while (Reploop && Reploop->file == Incfile)
	    rmnode((ulong **)&Reploop, sizeof(REPLOOP));
	while (Ifstack->file == Incfile)
	    rmnode((ulong **)&Ifstack, sizeof(IFSTACK));
	fclose(Incfile->fi);
	free(Incfile->name);
	--Inclevel;
	rmnode((ulong **)&Incfile, sizeof(INCFILE));
	if (Incfile) {
	    /*
	    if (F_verbose > 1)
		printf("back to: %s\n", Incfile->name);
	    */
	    if (F_listfile)
		fprintf(FI_listfile, "------- FILE %s\n", Incfile->name);
	}
    }
    if (F_verbose >= 1) {
	SEGMENT *seg;
	char *bss;

	puts("");
	printf("END OF PASS: %d\n", pass);
	puts("Segment---     init-pc  init-rpc finl-pc  finl-rpc");
	for (seg = Seglist; seg; seg = seg->next) {
	    bss = (seg->flags & SF_BSS) ? "[u]" : "   ";
	    printf("%10s %3s ", seg->name, bss);
	    printf("%s %s ", sftos(seg->initorg, seg->initflags), sftos(seg->initrorg, seg->initrflags));
	    printf("%s %s\n", sftos(seg->org, seg->flags), sftos(seg->rorg, seg->rflags));
	}
	printf("Reasons: %4ld,%4ld   Reasoncode: %08lx\n", Redo, Redo_eval, Redo_why);
    }
    if (F_verbose >= 3) {
	SYMBOL *sym;
	short i;
	short j = 0;

	if (F_verbose == 3)
	    puts("SYMBOLIST:  (Unresolved symbols only)");
	else
	    puts("SYMBOLIST");
	for (i = 0; i < SHASHSIZE; ++i) {
	    for (sym = SHash[i]; sym; sym = sym->next) {
		if (F_verbose > 3 || (sym->flags & SYM_UNKNOWN)) {
		    printf("%10s %s\n", sym->name, sftos(sym->value, sym->flags));
		    j = 1;
		}
	    }
	}
	if (j == 0)
	    puts("NO SYMBOLS");
	else
	    puts("ENDSYMBOLIST");
    }
    closegenerate();
    fclose(FI_temp);
    if (FI_listfile)
	fclose(FI_listfile);
    if (Redo) {
	if (Redo == oldredo && Redo_why == oldwhy && Redo_eval == oldeval) {
	    puts("Error: source is not resolvable.");
	    if (F_verbose < 2)
		puts("re-run with verbose option 2 or higher to determine problem");
	    exit(1);
	}
	oldredo = Redo;
	oldwhy = Redo_why;
	oldeval = Redo_eval;
	Redo = 0;
	Redo_why = 0;
	Redo_eval = 0;
	++pass;
	if (StopAtEnd) {
	    printf("Unrecoverable error in pass, aborting assembly!\n");
	} else if (pass > 10) {
	    printf("More than 10 passes, something *must* be wrong!\n");
	    exit(1);
	} else {
	    clearrefs();
	    clearsegs();
	    goto nextpass;
	}
    }
    if (F_symfile) {
	FILE *fi = fopen(F_symfile, "w");
	if (fi) {
	    register SYMBOL *sym;
	    puts("dumping symbols...");
	    for (i = 0; i < SHASHSIZE; ++i) {
		for (sym = SHash[i]; sym; sym = sym->next) {
		    fprintf(fi, "%-15s %s", sym->name, sftos(sym->value, sym->flags));
		    if (sym->flags & SYM_STRING)
			fprintf(fi, " \"%s\"", sym->string);
		    putc('\n', fi);
		}
	    }
	    fclose(fi);
	} else {
	    printf("unable to open symbol dump file '%s'\n", F_symfile);
	}
    }
}

static void
outlistfile(comment)
char *comment;
{
    extern ubyte Gen[];
    extern short Glen;
    char c = (Pflags & SF_BSS) ? 'U' : ' ';
    static char buf1[MAXLINE+32];
    static char buf2[MAXLINE+32];
    ubyte *ptr = Extstr;
    char *dot = "";
    register int i, j;

    if (ptr)
	dot = ".";
    else
	ptr = (ubyte *)"";

    sprintf(buf1, "%6ld %c%s", Incfile->lineno, c, sftos(Plab, Pflags & 7));
    j = strlen(buf1);
    for (i = 0; i < Glen && i < 4; ++i, j += 3)
	sprintf(buf1+j, "%02x ", Gen[i]);
    if (i < Glen && i == 4)
	buf1[j-1] = '*';
    for (; i < 4; ++i) {
	buf1[j] = buf1[j+1] = buf1[j+2] = ' ';
	j += 3;
    }
    sprintf(buf1+j, "%-10s  %s%s%s\011%s\n", Av[0], Av[1], dot, ptr, Av[2]);
    if (comment[0]) { /*  tab and comment */
	j = strlen(buf1) - 1;
	sprintf(buf1+j, "\011;%s", comment);
    }
    fwrite(buf2, tabit(buf1,buf2), 1, FI_listfile);
    Glen = 0;
    Extstr = NULL;
}

int
tabit(buf1, buf2)
char *buf1, *buf2;
{
    register char *bp, *ptr;
    register short j, k;

    bp = buf2;
    ptr= buf1;
    for (j = 0; *ptr; ++ptr, ++bp, j = (j+1)&7) {
	*bp = *ptr;
	if (*ptr == 9)
	    j = 0;
	if (j == 7 && *bp == ' ' && *(bp-1) == ' ') {
	    k = j;
	    while (k-- >= 0 && *bp == ' ')
		--bp;
	    *++bp = 9;
	}
    }
    while (bp != buf2 && bp[-1] == ' ' || bp[-1] == 9)
	--bp;
    *bp = *ptr;
    return((int)(bp - buf2));
}


ubyte *
sftos(val, flags)
long val;
int flags;
{
    static char buf[64];
    static char c;
    register char *ptr = (c) ? buf : buf + 32;

    c = 1 - c;
    sprintf(ptr, "%04lx", val);
    if (flags & SYM_UNKNOWN)
	strcpy(ptr, "????");
    if (flags & SYM_STRING)
	strcpy(ptr, "str ");
    if (flags & SYM_MACRO)
	strcpy(ptr, "eqm ");
    strcpy(ptr+4, "    ");
    if (flags & (SYM_MASREF|SYM_SET)) {
	ptr[4] = '(';
	ptr[7] = ')';
    }
    if (flags & (SYM_MASREF))
	ptr[5] = 'r';
    if (flags & (SYM_SET))
	ptr[6] = 's';
    return((ubyte *)ptr);
}

void
clearsegs()
{
    register SEGMENT *seg;

    for (seg = Seglist; seg; seg = seg->next) {
	seg->flags = (seg->flags & SF_BSS) | SF_UNKNOWN;
	seg->rflags= seg->initflags = seg->initrflags = SF_UNKNOWN;
    }
}

void
clearrefs()
{
    register SYMBOL *sym;
    register short i;

    for (i = 0; i < SHASHSIZE; ++i)
	for (sym = SHash[i]; sym; sym = sym->next)
	    sym->flags &= ~SYM_REF;
}

static
char *
cleanup(buf)
register ubyte *buf;
{
    register ubyte *str;
    register STRLIST *strlist;
    register short arg, add;
    char *comment = "";

    for (str = buf; *str; ++str) {
	switch(*str) {
	case ';':
	    comment = (char *)str + 1;
	    /*	FALL THROUGH	*/
	case '\r':
	case '\n':
	    goto br2;
	case TAB:
	    *str = ' ';
	    break;
	case '\'':
	    ++str;
	    if (*str == TAB)
		*str = ' ';
	    if (*str == '\n' || *str == 0) {
		str[0] = ' ';
		str[1] = 0;
	    }
	    if (str[0] == ' ')
		str[0] = 0x80;
	    break;
	case '\"':
	    ++str;
	    while (*str && *str != '\"') {
		if (*str == ' ')
		    *str = 0x80;
		++str;
	    }
	    if (*str != '\"') {
		asmerr(0,0);
		--str;
	    }
	    break;
	case '{':
	    if (Disable_me)
		break;
	    if (Xdebug)
		printf("macro tail: '%s'\n", str);
	    arg = atoi(str+1);
	    for (add = 0; *str && *str != '}'; ++str)
		--add;
	    if (*str != '}') {
		puts("end brace required");
		--str;
		break;
	    }
	    --add;
	    ++str;
	    if (Xdebug)
		printf("add/str: %d '%s'\n", add, str);
	    for (strlist = Incfile->args; arg && strlist;) {
		--arg;
		strlist = strlist->next;
	    }
	    if (strlist) {
		add += strlen(strlist->buf);
		if (Xdebug)
		    printf("strlist: '%s' %d\n", strlist->buf, strlen(strlist->buf));
		if (str + add + strlen(str) + 1 > buf + MAXLINE) {
		    if (Xdebug)
			printf("str %8ld buf %8ld (add/strlen(str)): %d %ld\n", str, buf, add, strlen(str));
		    panic("failure1");
		}
		BMov(str, str + add, strlen(str)+1);
		str += add;
		if (str - strlen(strlist->buf) < buf)
		    panic("failure2");
		BMov(strlist->buf, str - strlen(strlist->buf), strlen(strlist->buf));
		str -= strlen(strlist->buf);
		if (str < buf || str >= buf + MAXLINE)
		    panic("failure 3");
		--str;	/*  for loop increments string	*/
	    } else {
		asmerr(7,0);
		goto br2;
	    }
	    break;
	}
    }
br2:
    while(str != buf && *(str-1) == ' ')
	--str;
    *str = 0;
    return(comment);
}

void
panic(str)
char *str;
{
    puts(str);
    exit(1);
}

/*
 *  .dir    direct		    x
 *  .ext    extended		    x
 *  .r	    relative		    x
 *  .x	    index, no offset	    x
 *  .x8     index, byte offset	    x
 *  .x16    index, word offset	    x
 *  .bit    bit set/clr
 *  .bbr    bit and branch
 *  .imp    implied (inherent)      x
 *  .b				    x
 *  .w				    x
 *  .l				    x
 *  .u				    x
 */


void
findext(str)
register ubyte *str;
{
    Mnext = -1;
    Extstr = NULL;
    while (*str && *str != '.')
	++str;
    if (*str) {
	*str = 0;
	++str;
	Extstr = str;
	switch(str[0]|0x20) {
	case '0':
	case 'i':
	    Mnext = AM_IMP;
	    switch(str[1]|0x20) {
	    case 'x':
		Mnext = AM_0X;
		break;
	    case 'y':
		Mnext = AM_0Y;
		break;
	    case 'n':
		Mnext = AM_INDWORD;
		break;
	    }
	    return;
	case 'd':
	case 'b':
	case 'z':
	    switch(str[1]|0x20) {
	    case 'x':
		Mnext = AM_BYTEADRX;
		break;
	    case 'y':
		Mnext = AM_BYTEADRY;
		break;
	    case 'i':
		Mnext = AM_BITMOD;
		break;
	    case 'b':
		Mnext = AM_BITBRAMOD;
		break;
	    default:
		Mnext = AM_BYTEADR;
		break;
	    }
	    return;
	case 'e':
	case 'w':
	case 'a':
	    switch(str[1]|0x20) {
	    case 'x':
		Mnext = AM_WORDADRX;
		break;
	    case 'y':
		Mnext = AM_WORDADRY;
		break;
	    default:
		Mnext = AM_WORDADR;
		break;
	    }
	    return;
	case 'l':
	    Mnext = AM_LONG;
	    return;
	case 'r':
	    Mnext = AM_REL;
	    return;
	case 'u':
	    Mnext = AM_BSS;
	    return;
	}
    }
}

/*
 *  bytes arg will eventually be used to implement a linked list of free
 *  nodes.
 */

void
rmnode(base, bytes)
ulong **base;
int bytes;
{
    ulong *node;

    if (node = *base) {
	*base = *(ulong **)node;
	free(node);
    }
}

/*
 *  Parse into three arguments: Av[0], Av[1], Av[2]
 */

void
parse(buf)
register ubyte *buf;
{
    register short i, j;

    i = j = 0;
    Av[0] = Avbuf;
    while (buf[i] && buf[i] != ' ') {
	if (buf[i] == 0x80)
	    buf[i] = ' ';
	Avbuf[j++] = buf[i++];
    }
    Avbuf[j++] = 0;
    while (buf[i] == ' ')
	++i;
    Av[1] = Avbuf + j;
    while (buf[i] && buf[i] != ' ') {
	if (buf[i] == 0x80)
	    buf[i] = ' ';
	Avbuf[j++] = buf[i++];
    }
    Avbuf[j++] = 0;
    while (buf[i] == ' ')
	++i;
    Av[2] = Avbuf + j;
    while (buf[i]) {
	if (buf[i] == ' ') {
	    while(buf[i+1] == ' ')
		++i;
	}
	if (buf[i] == 0x80)
	    buf[i] = ' ';
	Avbuf[j++] = buf[i++];
    }
    Avbuf[j] = 0;
}



MNE *
findmne(str)
register ubyte *str;
{
    register uword i;
    register ubyte c;
    register MNE *mne;
    ubyte buf[128];

    for (i = 0; c = str[i]; ++i) {
	if (c >= 'A' && c <= 'Z')
	    c += 'a' - 'A';
	buf[i] = c;
    }
    buf[i] = 0;
    for (mne = MHash[hash1(buf)]; mne; mne = mne->next) {
	if (strcmp(buf, mne->name) == 0)
	    break;
    }
    return(mne);
}

void
v_macro(str, mnee)
char *str;
MNE *mnee;
{
    STRLIST *base;
    ubyte defined = 0;
    register STRLIST **slp, *sl;
    register MACRO *mac;
    register MNE   *mne;
    register uword i;
    ubyte buf[MAXLINE];
    ubyte skipit = !(Ifstack->true && Ifstack->acctrue);

    strlower(str);
    if (skipit) {
	defined = 1;
    } else {
	defined = (findmne(str) != NULL);
	if (F_listfile && ListMode)
	    outlistfile("");
    }
    if (!defined) {
	base = NULL;
	slp = &base;
	mac = (MACRO *)permalloc(sizeof(MACRO));
	i = hash1(str);
	mac->next = (MACRO *)MHash[i];
	mac->vect = v_execmac;
	mac->name = (ubyte *)strcpy(permalloc(strlen(str)+1), str);
	mac->flags = MF_MACRO;
	MHash[i] = (MNE *)mac;
    }
    while (fgets(buf, MAXLINE, Incfile->fi)) {
	char *comment;

	if (Xdebug)
	    printf("%08lx %s\n", Incfile, buf);
	++Incfile->lineno;
	Disable_me = 1;
	comment = cleanup(buf);
	Disable_me = 0;
	if (parse(buf), Av[1][0]) {
	    findext(Av[1]);
	    mne = findmne(Av[1]);
	    if (mne->flags & MF_ENDM) {
		if (!defined)
		    mac->strlist = base;
		return;
	    }
	}
	if (Xdebug)
	    printf("ok1"), fflush(stdout);
	if (!skipit && F_listfile && ListMode)
	    outlistfile(comment);
	if (Xdebug)
	    printf("ok2"), fflush(stdout);
	if (!defined) {
	    sl = (STRLIST *)permalloc(5+strlen(buf));
	    strcpy(sl->buf, buf);
	    *slp = sl;
	    slp = &sl->next;
	}
	if (Xdebug)
	    printf("ok3\n"), fflush(stdout);
    }
    asmerr(8,1);
}

void
addhashtable(mne)
MNE *mne;
{
    register uword i, j;
    uword opcode[NUMOC];

    for (; mne->vect; ++mne) {
	BMov(mne->opcode, opcode, sizeof(mne->opcode));
	for (i = j = 0; i < NUMOC; ++i) {
	    mne->opcode[i] = 0;     /* not really needed */
	    if (mne->okmask & (1L << i))
		mne->opcode[i] = opcode[j++];
	}
	i = hash1(mne->name);
	mne->next = MHash[i];
	MHash[i] = mne;
    }
}

static uword
hash1(str)
register ubyte *str;
{
    register uword result = 0;

    while (*str)
	result = (result << 2) ^ *str++;
    return((uword)(result & MHASHAND));
}

void
pushinclude(str)
char *str;
{
    register INCFILE *inf;
    register FILE *fi;

    if (fi = fopen(str, "r")) {
	if (F_verbose > 1) {
#ifdef IBM
	    printf(" Include: %s\n", str);
#else
	    printf("%.*sInclude: %s\n", Inclevel*4, "", str);
#endif
	}
	++Inclevel;
	if (F_listfile)
	    fprintf(FI_listfile, "------- FILE %s\n", str);
	inf = (INCFILE *)zmalloc(sizeof(INCFILE));
	inf->next   = Incfile;
	inf->name   = (ubyte *)strcpy(malloc(strlen(str)+1), str);
	inf->fi     = fi;
	inf->lineno = 0;
	Incfile = inf;
	return;
    }
    printf("unable to open %s\n", str);
}

char Stopend[] = {
    1,1,1,1,1,1,1,1,1,1,0,1,1,0,1,1,1,0,0,1,1
};

char *Errors[] = {
    "Syntax Error",
    "Expression table overflow",
    "Unbalanced Braces []",
    "Division by zero",
    "Unknown Mnemonic",
    "Illegal Addressing mode",
    "Illegal forced Addressing mode",   /*  nu  */
    "Not enough args passed to Macro",
    "Premature EOF",
    "Illegal character",
    "Branch out of range",
    "ERR pseudo-op encountered",
    "Origin Reverse-indexed",           /*  12  */
    "EQU: Value mismatch",
    "Address must be <$100",            /*  nu  */
    "Illegal bit specification",
    "Not enough args",                  /*  16  */
    "Label Mismatch",                   /*  17  */
    "Value Undefined",
    "Illegal Forced Address mode",      /*  19  */
    "Processor not supported",          /*  20  */
    NULL
};

void
asmerr(err, abort)
short err, abort;
{
    ubyte *str;
    INCFILE *incfile;

    if (Stopend[err])
	StopAtEnd = 1;
    for (incfile = Incfile; incfile->flags & INF_MACRO; incfile=incfile->next);
    str = (ubyte *)Errors[err];
    if (F_listfile)
	fprintf(FI_listfile, "*line %4ld %-10s %s\n", incfile->lineno, incfile->name, str);
    printf("line %4ld %-10s %s\n", incfile->lineno, incfile->name, str);
    if (abort) {
	puts("Aborting assembly");
	if (F_listfile)
	    fputs("Aborting assembly\n", FI_listfile);
	exit(1);
    }
}

ubyte *
zmalloc(bytes)
int bytes;
{
    ubyte *ptr = malloc(bytes);
    if (ptr) {
	BZero(ptr, bytes);
	return(ptr);
    }
    panic("unable to malloc");
}

ubyte *
permalloc(bytes)
int bytes;
{
    static ubyte *buf;
    static int left;
    ubyte *ptr;

    bytes = (bytes + 1) & ~1;
    if (bytes > left) {
	if ((buf = malloc(ALLOCSIZE)) == NULL)
	    panic("unable to malloc");
	BZero(buf, ALLOCSIZE);
	left = ALLOCSIZE;
	if (bytes > left)
	    panic("software error");
    }
    ptr = buf;
    buf += bytes;
    left -= bytes;
    return(ptr);
}

ubyte *
strlower(str)
ubyte *str;
{
    register ubyte c;
    register ubyte *ptr;

    for (ptr = str; c = *ptr; ++ptr) {
	if (c >= 'A' && c <= 'Z')
	    *ptr = c | 0x20;
    }
    return(str);
}


#ifdef UNIX
xbset(s,n,c)
register ubyte *s;
register ulong n;
register ubyte c;
{
    while (n--)
	*s++ = c;
}
#endif

#ifdef IBM
BCmp(s,d,n)
ubyte *s, *d;
uword n;
{
    uword i;
    for (i = 0; i < n; ++i) {
	if (s[i] != d[i])
	    return(1);
    }
    return(0);
}

#endif



