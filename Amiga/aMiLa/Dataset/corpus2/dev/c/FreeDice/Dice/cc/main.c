
/*
 *  MAIN.C
 *
 *  (c)Copyright 1990, Matthew Dillon, All Rights Reserved
 *
 *  dcc <options> <files>
 */

#include "defs.h"

#ifndef AZLAT_COMPAT
#define DoLink_Dice	DoLink
#define DoCompile_Dice	DoCompile
#define DoAssemble_Dice DoAssemble
#define DoPrelink_Dice	DoPrelink
#endif

#ifdef _DCC
IDENT("DCC",".37");
DCOPYRIGHT;
#endif

Prototype   void    myexit(void);
Prototype   int     main(int, char **);
Prototype   void    AddFile(char *);
Prototype   void    help(int);
Prototype   char    *TmpFileName(char *);
Prototype   char    *MungeFile(char *, char *, char *);
Prototype   void    AddName(LIST *, char *, char *);
Prototype   void    AddOpt(LIST *, char *, char *);
Prototype   char    *Tailer(char *);
Prototype   char    *XFilePart(char *);
Prototype   char    *OptListToStr(LIST *);
Prototype   char    *OptListToStr2(LIST *, char *);
Prototype   void    run_cmd(char *);
Prototype   int     OutOfDate(char *, char *);
Prototype   void    HandleCFile(char *, int);
Prototype   void    HandleAFile(char *, int);
Prototype   void    PushTmpFile(char *);
Prototype   void    PopTmpFile(char *);
Prototype   long    LoadSegLock(long);

Prototype   int     DoCompile(char *, char *);
Prototype   int     DoCompile_Dice(char *, char *);
Prototype   int     DoCompile_Aztec(char *, char *);
Prototype   int     DoCompile_Lattice(char *, char *);
Prototype   int     DoAssemble(char *, char *);
Prototype   int     DoAssemble_Dice(char *, char *);
Prototype   int     DoAssemble_Aztec(char *, char *);
Prototype   int     DoAssemble_Lattice(char *, char *);
Prototype   char    *DoPrelink(void);
Prototype   char    *DoPrelink_Dice(void);
Prototype   char    *DoPrelink_Aztec(void);
Prototype   char    *DoPrelink_Lattice(void);
Prototype   int     DoLink(char *);
Prototype   int     DoLink_Dice(char *);
Prototype   int     DoLink_Aztec(char *);
Prototype   int     DoLink_Lattice(char *);

void OrderApp(char *);
void AddLibApp(char *, char);
void DelLibApp(char *, char);

/*
 *  Note that we use exec_dcc if DCC, which only works with 'dcc' programs
 *  thus, the executables are renamed to prevent problems.
 */

Prototype __aligned char Buf[512];


__aligned char Buf[512];
char TmpFile[64];
char ErrOptStr[128];
char *ErrFile;
char *OutFile;
char *OutDir = "T:";
char *TmpDir = "T:";
char *AmigaLib = "dlib:amiga";
char *CLib = "dlib:c";
char ALibOS[4];
char ALibApp[32] = { "s" };
char CLibApp[32] = { "s" };
LIST TmpList;
short NewOpt;
short FastOpt;
short FragOpt;
short ChipOpt;
short MC68020Opt;
short MC68881Opt;
short FFPOpt;
short DDebug;
short RegCallOpt;
short NoHeirOpt;
short NoEnvOpt;
short SlashSlashOpt;
short ProfOpt;
short DLinkPostFixOpt;

char DLINK[32];
char DAS[32];
char DC1[32];
char DCPP[32];

typedef struct NameNode {
    struct Node n_Node;
    char    *n_In;
    char    *n_Out;
    short   n_IsTmp;
} NameNode;

LIST   CList;
LIST   AList;
LIST   OList;
LIST   LList;

LIST   CppOptList;
LIST   LinkOptList;

short	NoLink;
short	NoAsm;
short	SmallCode = 1;
short	SmallData = 1;
short	ConstCode;	    /*	-ms		    */
short	AbsData;	    /*	-mw, -ma	    */
short	ResOpt;
short	AltSectOpt;
short	SymOpt;
short	RomOpt;
short	ProtoOnlyOpt;
short	NoIntermediateAssembly;
short	PIOpt;
short	GenStackOpt;
short	GenLinkOpt;
short	Verbose;
short	NoDefaultLibs;
short	CompilerOpt = DICE_C;
long	AbsDataStart;	    /*	-mw <addr>  */
char	DebugOpts[64];

extern struct Library *SysBase;

void
myexit()
{
    NODE *node;

    while (node = RemHead(&TmpList)) {
	remove(node->ln_Name);
	free(node);
    }
}

int
main(xac, xav)
int xac;
char *xav[];
{
    int fc = 0;
    int ac;
    char **av;

#ifdef LATTICE
    {
	long n = (long)Buf;
	if (n & 3) {
	    puts("software error, Buf not aligned");
	    exit(1);
	}
    }
#endif
#ifdef NOTDEF
    expand_args(xac, xav, &ac, &av);
#else
    ac = xac;
    av = xav;
#endif

    NewList(&CList);
    NewList(&AList);
    NewList(&OList);
    NewList(&LList);

    NewList(&TmpList);

    NewList(&CppOptList);
    NewList(&LinkOptList);

    atexit(myexit);

    if (ac == 1)
	help(0);

    {
	char *ptr = av[0];    /*  cmd name */
	char prefix[32];
	short i;

	for (i = strlen(ptr); i >= 0 && ptr[i] != ':' && ptr[i] != '/'; --i);
	++i;

	ptr = ptr + i;		/*  base name */
	for (i = 0; ptr[i] && ptr[i] != '_'; ++i);
	if (ptr[i] == '_') {
	    strncpy(prefix, ptr, i + 1);
	    prefix[i+1] = 0;
	} else {
	    prefix[0] = 0;
	}
	sprintf(DLINK, "%s%s", prefix, "dlink");
	sprintf(DAS  , "%s%s", prefix, "das");
	sprintf(DC1  , "%s%s", prefix, "dc1");
	sprintf(DCPP , "%s%s", prefix, "dcpp");
    }

    /*
     *	check for -no-env option before processing DCCOPTS
     */

    {
	long i;

	for (i = 1; i < ac; ++i) {
	    if (strcmp(av[i], "-no-env") == 0) {
		NoEnvOpt = 1;
		break;
	    }
	}
    }

    if (NoEnvOpt == 0) {
	char **argv = av;
	ac = ExtArgsEnv(ac, &argv, "DCCOPTS");
	av = argv;
    }

    {
	long i;
	char *dummy;

	for (i = 1; i < ac; ++i) {
	    char *ptr = av[i];

	    if (*ptr == '-') {
		ptr += 2;

		switch(ptr[-1]) {
		case '0':       /*  -020        */
		    MC68020Opt = 1;
		    break;
		case '1':       /*  1.4, 1.3    */
		case '2':       /*  2.0, 2.1..  */
		    if (ptr[0] != '.')
			help(1);
		    AddOpt(&CppOptList, ptr - 2, "");
		    ALibOS[0] = ptr[-1];
		    ALibOS[1] = ptr[1];
		    break;
		case '8':
		    MC68881Opt = 1;
		    break;
		case 'f':
		    if (*ptr == 0)
			FastOpt = 1;
		    else if (*ptr == 'r')
			FragOpt = 1;
		    else if (*ptr == 'f')
			FFPOpt = 1;
		    break;
		case 'r':
		    if (strcmp(ptr, "om") == 0) {
			RomOpt = 1;
		    } else {
			if (PIOpt && ResOpt == 0)
			    puts("DCC: Warning, -r -pi = -pr");
			ResOpt = 1;
		    }
		    break;
		case 'c':
		    if (*ptr == 0)
			NoLink = 1;
		    else if (stricmp(ptr, "hip") == 0)
			ChipOpt = 1;
		    else
			help(1);
		    break;
		case 'a':
		    if (strcmp(ptr, "ztec") == 0) {
			CompilerOpt = AZTEC_C;
			break;
		    }
		    NoAsm = 1;
		    NoLink= 1;
		    break;
		case 'g':
		    switch (*ptr) {
		    case 's':
			GenStackOpt = 1;
			break;
		    case 'l':
			GenLinkOpt = 1;
			break;
		    default:
			help(1);
		    }
		    break;
		case 'l':
		    if (strcmp(ptr, "attice") == 0) {
			CompilerOpt = LATTICE_C;
			break;
		    }
		    if (ptr[0] == '0' && ptr[1] == 0) {
			NoDefaultLibs = 1;
			break;
		    }
		    if (*ptr == 0)
			ptr = av[++i];
		    AddName(&LList, ".lib", ptr);
		    DLinkPostFixOpt = 1;
		    break;
		case 'L':   /*  -Idir   */
		    if (ptr[0] == '0' && ptr[1] == 0) {
			AddOpt(&LinkOptList, "-L0", "");
			break;
		    }
		    if (*ptr == 0)
			ptr = av[++i];
		    AddOpt(&LinkOptList, "-L", ptr);
		    break;
		case 'I':   /*  -Idir   */
		    if (ptr[0] == '0' && ptr[1] == 0) {
			AddOpt(&CppOptList, "-I0", "");
			break;
		    }
		    if (*ptr == 0)
			ptr = av[++i];
		    AddOpt(&CppOptList, "-I", ptr);
		    break;
		case 'd':   /*  -dice -d<n> -d<debug_opts>  */
		    if (strcmp(ptr, "ice") == 0) {
			CompilerOpt = DICE_C;
			break;
		    }
		    if (atoi(ptr)) {
			DDebug = atoi(ptr);
			break;
		    }
		    sprintf(DebugOpts, " -d%s", ptr);
		    break;
		case 'D':   /*  -Ddefine[=str] */
		    if (*ptr == 0)
			ptr = av[++i];
		    AddOpt(&CppOptList, "-D", ptr);
		    break;
		case 'H':   /*  -H<path>=<include_name>    */
		    if (*ptr == 0)
			ptr = av[++i];
		    AddOpt(&CppOptList, "-H", ptr);
		    break;
		case 'U':   /*  -U      -undefine certain symbols */
		    AddOpt(&CppOptList, "-U", ptr);
		    break;
		case 'o':
		    if (*ptr)
			OutFile = ptr;
		    else
			OutFile = av[++i];
		    {
			short idx = strlen(OutFile) - 2;
			if (idx >= 0) {
			    if (stricmp(OutFile + idx, ".h") == 0 || stricmp(OutFile + idx, ".c") == 0) {
				puts("ERROR! -o output file may not end in .c or .h!");
				exit(20);
			    }
			}
		    }
		    break;
		case 'O':
		    if (*ptr)
			OutDir = ptr;
		    else
			OutDir = av[++i];
		    break;
		case 'E':   /*  error output append */
		    if (*ptr == 0)
			ptr = av[++i];

		    if (freopen(ptr, "a", stderr)) {
			ErrFile = ptr;
			sprintf(ErrOptStr," -E %s", ptr);
		    } else {
			printf("unable to append to %s\n", ptr);
		    }
		    break;
		case 'p':
		    if (strcmp(ptr, "roto") == 0) {
			ProtoOnlyOpt = 1;
		    } else if (strncmp(ptr, "rof", 3) == 0) {
			ProfOpt = atoi(ptr + 3);
			if (ProfOpt == 0)
			    ProfOpt = 1;
			if (ProfOpt >= 2)
			    AddLibApp(CLibApp, 'p');
			if (ProfOpt >= 3)
			    AddLibApp(ALibApp, 'p');
		    } else if (strcmp(ptr, "i") == 0) {
			PIOpt = 1;
			if (ResOpt)
			    puts("DCC: Warning, -r -pi = -pr");
		    } else if (strcmp(ptr, "r") == 0) {
			PIOpt = 1;
			ResOpt = 1;
		    } else {
			help(1);
		    }
		    break;
		case 'T':
		    if (*ptr)
			TmpDir = ptr;
		    else
			TmpDir = av[++i];
		    break;
		case 'm':
		    switch(*ptr) {
		    case 'C':
			SmallCode = 0;
			break;
		    case 'c':
			SmallCode = 1;
			break;
		    case 'D':
			SmallData = 0;
			DelLibApp(ALibApp, 's');
			DelLibApp(CLibApp, 's');
			AddLibApp(ALibApp, 'l');
			AddLibApp(CLibApp, 'l');
			break;
		    case 'd':
			SmallData = 1;
			DelLibApp(ALibApp, 'l');
			DelLibApp(CLibApp, 'l');
			AddLibApp(ALibApp, 's');
			AddLibApp(CLibApp, 's');
			break;
		    case 'a':
		    case 'w':
			AbsData = 1;

			if (*ptr == 'a')
			    AbsData = 2;

			++ptr;
			if (*ptr == 0)
			    ptr = av[++i];

#ifdef LATTICE
			AbsDataStart = atoi(ptr);   /*  bug in lattice */
#else
			AbsDataStart = strtol(ptr, &dummy, 0);
#endif
			break;
		    case 'r':
			RegCallOpt = 1;
			break;
		    case 'R':
			AddLibApp(CLibApp, 'r');
			AddLibApp(ALibApp, 'r');

			RegCallOpt = 2;
			if (ptr[1] == 'R') {
			    RegCallOpt = 3;
			    if (ptr[2] == 'X')
				RegCallOpt = 4;
			}
			break;
		    case 's':
			if (strcmp(ptr, "as") == 0) {
			    CompilerOpt = LATTICE_C;
			    break;
			}
			if (ptr[1] == '0')
			    ConstCode = 0;
			else
			    ConstCode = 1;
			break;
		    case 'S':
			ConstCode = 2;
			break;
		    default:
			fprintf(stderr, "bad -s model\n");
			exit(1);
		    }
		    break;
		case 's':
		    SymOpt = 1;
		    break;
		case 'S':
		    AltSectOpt = 1;
		    break;
		case 'v':
		    Verbose = 1;
		    break;
		case '/':
		    if (strcmp(ptr-1, "//") == 0) {
			SlashSlashOpt = 1;
			break;
		    }
		    goto def;
		case 'n':
		    if (strcmp(ptr-1, "new") == 0) {
			NewOpt = 1;
			break;
		    }
		    if (strcmp(ptr-1, "noheir") == 0) {
			NoHeirOpt = 1;
			break;
		    }
		    if (strcmp(ptr-1, "no-env") == 0)
			break;
		    /* fall through */
		default:
		def:
		    fprintf(stderr, "bad - option\n");
		    help(1);
		}
		continue;
	    }
	    if (*ptr == '+') {
		ptr += 2;

		switch(ptr[-1]) {
		case 'I':   /*  +Idir   */
		    if (*ptr == 0)
			ptr = av[++i];
		    AddOpt(&CppOptList, "+I", ptr);
		    break;
		default:
		    fprintf(stderr, "bad + option\n");
		    help(1);
		}
		continue;
	    }
	    if (*ptr == '@') {
		FILE *fi = fopen(ptr + 1, "r");
		char buf[128];

		if (fi == NULL) {
		    printf("unable to open %s\n", ptr + 1);
		    exit(1);
		}
		while (fgets(buf, sizeof(buf), fi)) {
		    short len = strlen(buf);
		    if (len > 0)
			buf[len-1] = 0;
		    if (buf[0] && buf[0] != ';' && buf[0] != '#') {
			++fc;
			AddFile(buf);
		    }
		}
		fclose(fi);
		continue;
	    }
	    ++fc;
	    AddFile(ptr);
	}
	if (i > ac) {
	    fprintf(stderr, "file argument missing\n");
	    help(1);
	}
    }

#ifdef AZLAT_COMPAT
    if (CompilerOpt == AZTEC_C) {
	puts("DCC in AZTEC mode");
	FastOpt = 0;
	NoIntermediateAssembly = 1;
    }
    if (CompilerOpt == LATTICE_C) {
	puts("DCC in LATTICE mode");
	FastOpt = 0;
	NoIntermediateAssembly = 1;
    }
#else
    if (CompilerOpt != DICE_C)
	puts("DCC must be recompiled w/ AZLAT_COMPAT defined");
#endif

    /*
     *	Ensure CLibApp and ALibApp ordering and remove duplicates
     */

    OrderApp(CLibApp);
    OrderApp(ALibApp);

    /*
     *	Compile sources into assembly or objects
     */


    {
	NameNode *nn;

	while (nn = (NameNode *)RemHead(&CList))
	    HandleCFile(nn->n_In, fc);
	if (NoAsm == 0) {
	    while (nn = (NameNode *)RemHead(&AList))
		HandleAFile(nn->n_In, fc);
	}
    }

    /*
     *	Link objects into executable
     */

    if (NoLink == 0) {
	char *lfile = DoPrelink();
	if (lfile)
	    PushTmpFile(lfile);
	DoLink(lfile);
	if (lfile) {
	    PopTmpFile(lfile);
	    remove(lfile);
	    free(lfile);
	}
    }
    return(0);
}

void
AddFile(ptr)
char *ptr;
{
    char *t = Tailer(ptr);

    if (strncmp(t, "a", 1) == 0) {
	AddName(&AList, NULL, ptr);
    } else
    if (strncmp(t, "o", 1) == 0) {
	AddName(&OList, NULL, ptr);
    } else
    if (strncmp(t, "l", 1) == 0) {
	AddName(&LList, NULL, ptr);
    } else {
	AddName(&CList, NULL, ptr);
    }
}

DoCompile_Dice(in, out)
char *in;
char *out;
{
    char *qq = "";
    char *cptmp = TmpFileName(".i");
    char *code = (SmallCode) ? " -mc" : " -mC";
    char *data = (SmallData) ? " -md" : " -mD";
    char *rc = qq;
    char *absdata;
    char *concode;
    char *res  = (ResOpt) ? " -r" : qq;
    char *verb = (Verbose) ? " -v" : qq;
    char *optsect = (AltSectOpt) ? " -S" : qq;
    char *protoonly = (ProtoOnlyOpt) ? " -proto" : qq;
    char *prof = (ProfOpt) ? " -prof" : qq;
    char *mc68020 = (MC68020Opt) ? " -020" : qq;
    char *mc68881 = (MC68881Opt) ? " -881" : qq;
    char *piopt;
    char *ffp = (FFPOpt) ? " -ffp" : qq;
    char *genstack = (GenStackOpt) ? " -gs" : qq;
    char *genlink  = (GenLinkOpt) ? " -gl" : qq;
    char *slashopt = (SlashSlashOpt) ? " -//" : qq;

    switch(RegCallOpt) {
    case 1:
	rc = " -mr";
	break;
    case 2:
	rc = " -mR";
	break;
    case 3:
	rc = " -mRR";
	break;
    case 4:
	rc = " -mRRX";
	break;
    }

    switch(ConstCode) {
    case 1:
	concode = " -ms";
	break;
    case 2:
	concode = " -mS";
	break;
    default:
	concode = qq;
	break;
    }

    switch(AbsData) {
    case 1:
	absdata = " -mw";
	break;
    case 2:
	absdata = " -ma";
	break;
    default:
	absdata = qq;
	break;
    }

    if (PIOpt) {
	if (ResOpt)
	    piopt = " -pr";
	else
	    piopt = " -pi";
	res = qq;
	absdata = qq;
	code = qq;
	data = qq;
    } else {
	piopt = qq;
    }

    PushTmpFile(cptmp);
    sprintf(Buf+1, "%s %s -o %s%s%s%s%s",
	DCPP, in, cptmp, ErrOptStr, OptListToStr(&CppOptList),
	ffp, slashopt
    );
    run_cmd(Buf+1);
    sprintf(Buf+1, "%s %s -o %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
	DC1, cptmp, out, code, data, rc, res, verb,
	optsect, protoonly, prof, concode, absdata, piopt, ErrOptStr,
	mc68020, mc68881, ffp, genstack, genlink, DebugOpts
    );
    run_cmd(Buf+1);
    PopTmpFile(cptmp);
    remove(cptmp);
    free(cptmp);
    return(0);
}

DoAssemble_Dice(in, out)
char *in;
char *out;
{
    sprintf(Buf+1, "%s -o%s %s%s", DAS, out, in, ErrOptStr);
    run_cmd(Buf+1);
    return(0);
}

char *
DoPrelink_Dice(void)
{
    NameNode *nn;
    char *ltmp = TmpFileName(".lnk");
    FILE *fi = fopen(ltmp, "w");

    if (fi == NULL) {
	fprintf(stderr, "couldn't create %s\n", ltmp);
	exit(1);
    }

    while (nn = (NameNode *)RemHead(&OList)) {
	fputs(nn->n_In, fi);
	putc('\n', fi);
    }
    while (nn = (NameNode *)RemHead(&LList)) {
	fputs(nn->n_In, fi);
	putc('\n', fi);
    }

    /*
     *	only small-data version of auto.lib is supported currently
     */

    if (RomOpt == 0 && NoDefaultLibs == 0) {
	fprintf(fi, "%s%s.lib", CLib, CLibApp);
	fprintf(fi, " %s%s%s.lib dlib:autos.lib\n",
	    AmigaLib, ALibApp, ALibOS
	);
    }
    fclose(fi);
    return(ltmp);
}

/*
 *  dlib:x.o is a special trailer for any autoinit code (in section autoinit,code)
 *  This section is called in sequence just before main() with ac, av pushed on
 *  the stack.	The idea is that any module may reference an autoinit section to
 *  automatically initialize certain aspects of itself without requiring a call
 *  from the main program.
 */

DoLink_Dice(lfile)
char *lfile;
{
    char *qq = "";
    char *co = " ";
#ifdef NOTDEF
    char *ro = (NoDefaultLibs) ? qq : "dlib:x.o";
#endif
    char *ro = "dlib:x.o";
    char *symopt = (SymOpt) ? " -s" : qq;
    char *resopt = (ResOpt) ? " -r" : qq;
    char *fragopt= (FragOpt) ? " -frag" : qq;
    char *chipopt= (ChipOpt) ? " -chip" : qq;
    char *postfix= qq;
    char *piopt;
    char absdata[20];

    if (DLinkPostFixOpt) {
	static char PostFix[sizeof(CLibApp)+3];
	postfix = PostFix;
	sprintf(postfix, " -P%s", CLibApp);
    }

    if (RomOpt == 0 && NoDefaultLibs == 0) {       /*  RomOpt PIOpt ResOpt */
	static char *SCode[] = { "dlib:c.o ",       /*    0      0      0   */
				 "dlib:c.o ",       /*    0      0      1   */
				 "dlib:c_pi.o ",    /*    0      1      0   */
				 "dlib:c_pr.o "     /*    0      1      1   */
			       };
	co = SCode[(short)((PIOpt << 1) | ResOpt)];
    }

    if (OutFile == NULL)
	OutFile = "a.out";

    if (AbsData) {
	sprintf(absdata, " -ma 0x%lx", AbsDataStart);
    } else {
	absdata[0] = 0;
    }

    if (PIOpt) {
	if (ResOpt)
	    piopt = " -pr";
	else
	    piopt = " -pi";
	resopt = qq;
	if (AbsData) {
	    absdata[0] = 0;
	    puts("Warning: cannot mix -pi and -ma/-mw");
	}
    } else {
	piopt = qq;
    }
    if (FragOpt) {
	if (ResOpt) {
	    puts("Warning: cannot use -frag with -r");
	    fragopt = qq;
	}
    }

    sprintf(Buf+1, "%s %s @%s %s -o %s%s%s%s%s%s%s%s%s%s",
	DLINK, co, lfile, ro, OutFile,
	symopt,
	resopt,
	fragopt,
	piopt,
	absdata,
	postfix,
	chipopt,
	OptListToStr(&LinkOptList),
	ErrOptStr
    );
    run_cmd(Buf+1);
    return(0);
}



void
help(code)
{
#ifdef _DCC
    printf("%s\n%s\n", Ident, DCopyright);
#endif
    puts("Refer to DOC/DCC.DOC for options. -f for resident-hack-fast-load");
    exit(code);
}

char *
TmpFileName(tail)
char *tail;
{
    char *buf = malloc(strlen(TmpDir) + strlen(tail) + 32);
    char dummy = 0;

    sprintf(buf, "%s%06lx%s", TmpDir, (long)&dummy >> 8, tail);
    return(buf);
}

char *
MungeFile(file, hdr, tail)
char *file;
char *hdr;
char *tail;
{
    char *base = file;
    char *name;
    short i;
    short hlen = 0;

    if (hdr) {
	hlen = strlen(hdr);
	if (base = strchr(base, ':'))
	    ++base;
	else
	    base = file;
#ifdef NOTDEF
	while (*base && *base != ':' && *base != '/')
	    ++base;
	if (*base == 0)
	    base = file;
	else
	    ++base;
#endif
    } else {
	hdr = "";
    }
    for (i = strlen(base) - 1; i >= 0; --i) {
	if (base[i] == '.')
	    break;
    }
    if (i < 0)
	i = strlen(base);

    name = malloc(hlen + i + strlen(tail) + 2);
    strcpy(name, hdr);
    if (hlen && hdr[hlen-1] != ':' && hdr[hlen-1] != '/')
	strcat(name, "/");
    sprintf(name + strlen(name), "%.*s%s", i, base, tail);
    return(name);
}

void
AddName(list, tailifnone, file)
LIST *list;
char *tailifnone;
char *file;
{
    NameNode *nn = malloc(sizeof(NameNode));
    short i;

    for (i = strlen(file) - 1; i >= 0 && file[i] != '.'; --i) {
	if (file[i] == '/' || file[i] == ':')
	    i = 0;
    }

    if (i < 0 && tailifnone) {
	nn->n_In = malloc(strlen(file) + strlen(tailifnone) + 1);
	sprintf(nn->n_In, "%s%s", file, tailifnone);
    } else {
	nn->n_In = malloc(strlen(file) + 1);
	strcpy(nn->n_In, file);
    }
    nn->n_Out = NULL;
    nn->n_IsTmp = 0;
    AddTail(list, &nn->n_Node);
}

void
AddOpt(list, opt, body)
LIST *list;
char *opt;
char *body;
{
    NameNode *nn = malloc(sizeof(NameNode));

    nn->n_In = opt;
    nn->n_Out= body;
    AddTail(list, &nn->n_Node);
}

char *
Tailer(ptr)
char *ptr;
{
    short i;

    for (i = strlen(ptr) - 1; i >= 0 && ptr[i] != '.'; --i);
    if (i < 0)
	return("");
    return(ptr + i + 1);
}

char *
XFilePart(ptr)
char *ptr;
{
    short i;

    for (i = strlen(ptr) - 1; i >= 0 && ptr[i] != ':' && ptr[i] != '/'; --i);
    ++i;
    return(ptr + i);
}

char *
OptListToStr(list)
LIST *list;
{
    static char Tmp[512];
    short i;
    NameNode *scan;

    i = 0;
    Tmp[0] = 0;
    for (scan = (NameNode *)list->lh_Head; scan != (NameNode *)&list->lh_Tail; scan = (NameNode *)scan->n_Node.ln_Succ) {
	sprintf(Tmp + i, " %s%s", scan->n_In, scan->n_Out);
	i += strlen(Tmp + i);
    }
    return(Tmp);
}

#ifdef AZLAT_COMPAT

char *
OptListToStr2(list, cvt)
LIST *list;
char *cvt;
{
    static char Tmp[512];
    short i;
    NameNode *scan;

    i = 0;
    for (scan = (NameNode *)list->lh_Head; scan != (NameNode *)&list->lh_Tail; scan = (NameNode *)scan->n_Node.ln_Succ) {
	sprintf(Tmp + i, " %s%s", scan->n_In, scan->n_Out);
	{
	    char *ptr;
	    for (ptr = cvt; *ptr; ptr += 2) {
		if (Tmp[i+2] == ptr[0])
		    Tmp[i+2] = ptr[1];
	    }
	}
	i += strlen(Tmp + i);
    }
    return(Tmp);
}

#endif

/*
 *  run_cmd(buf)        buf[-1] is valid for BCPL stuff, buf[-1] is
 *			long word aligned.
 */

void
run_cmd(buf)
char *buf;
{
    short i;
    short j = strlen(buf);
    int r;

    if (Verbose)
	printf("%s\n", buf);

    if (ErrFile)
	fclose(stderr);

#if INCLUDE_VERSION >= 36
    if (SysBase->lib_Version >= 36) {
	long seg;
	long lock;
	char c;

	Process *proc = FindTask(NULL);
	CLI *cli = BTOC(proc->pr_CLI, CLI);
	long oldCommandName;

	if (DDebug)
	    puts("cmd-begin");

	for (i = 0; buf[i] && buf[i] != ' '; ++i);
	c = buf[i];
	buf[i] = 0;

	if (cli) {
	    oldCommandName = (long)cli->cli_CommandName;
	    buf[-1] = i;
	    cli->cli_CommandName = CTOB(buf - 1);
	}

	if (seg = FindSegment(buf, 0L, 0)) {
	    r = RunCommand(((long *)seg)[2], 8192, buf + i + 1, strlen(buf + i + 1));
	} else if ((lock = _SearchPath(buf)) && seg = LoadSegLock(lock)) {
	    r = RunCommand(seg, 8192, buf + i + 1, strlen(buf + i + 1));
	    UnLoadSeg(seg);
	} else {
	    buf[i] = c;
	    r = System(buf, NULL);
	}
	if (cli)
	    cli->cli_CommandName = (BSTR)oldCommandName;

	if (DDebug)
	    puts("cmd-end");
    } else {
#else
    {
#endif

#ifdef _DCC
	if (FastOpt == 0) {
#endif
	    if (Execute(buf, NULL, Output()) != -1) {
		printf("Unable to Execute %s\n", buf);
		exit(1);
	    }
	    r = 0;
#ifdef NOTDEF
	    r = IoErr();
	    if (r && r != -1) {
		puts("Non-Zero exit code");
		exit(1);
	    }
#endif

#ifdef _DCC
	} else {
	    for (i = 0; buf[i] && buf[i] != ' '; ++i);
	    buf[i] = 0;
	    if (i != j) {
		for (++i; buf[i] == ' '; ++i);
	    }
	    r = exec_dcc(buf, buf + i);
	}
#endif
    }
    if (r) {
	printf("Exit code %d\n", r);
	exit(1);
    }
    if (ErrFile)
	freopen(ErrFile, "a", stderr);
}

int
OutOfDate(in, out)
char *in;
char *out;
{
    static FIB *InFib;
    static FIB *OutFib;
    BPTR inLock, outLock;
    FIB *inFib;
    FIB *outFib;
    int r = 1;

    if (NewOpt == 0)
	return(1);

    if (InFib == NULL) {
	InFib = malloc(sizeof(FIB));
	OutFib = malloc(sizeof(FIB));
    }
    inFib = InFib;
    outFib = OutFib;

    if (inLock = Lock(in, SHARED_LOCK)) {
	if (outLock = Lock(out, SHARED_LOCK)) {
	    if (Examine(inLock, inFib) && Examine(outLock, outFib)) {
		if (inFib->fib_Date.ds_Days < outFib->fib_Date.ds_Days)
		    r = 0;
		else if (inFib->fib_Date.ds_Days == outFib->fib_Date.ds_Days) {
		    if (inFib->fib_Date.ds_Minute < outFib->fib_Date.ds_Minute)
			r = 0;
		    else if (inFib->fib_Date.ds_Minute == outFib->fib_Date.ds_Minute) {
			if (inFib->fib_Date.ds_Tick < outFib->fib_Date.ds_Tick)
			    r = 0;
		    }
		}
	    }
	    UnLock(outLock);
	}
	UnLock(inLock);
    }
    return(r);
}

void
HandleCFile(in, fc)
char *in;
int fc;
{
    char *asmName;
    char *objName;

    if (fc == 1 && OutFile && NoAsm)
	asmName = OutFile;
    else
	asmName = MungeFile(XFilePart(in), TmpDir, ".a");

    if (fc == 1 && OutFile && NoLink)
	objName = OutFile;
    else
	objName = MungeFile(in, OutDir, ".o");

    if (NoAsm) {        /*  in -> asmName           */
	if (OutOfDate(in, asmName))
	    DoCompile(in, asmName);
    } else {		/*  in -> asmName -> objName*/
	if (OutOfDate(in, objName)) {
	    PushTmpFile(asmName);
	    if (NoIntermediateAssembly) {
		DoCompile(in, objName);
	    } else {
		DoCompile(in, asmName);
		if (NoHeirOpt == 0)
		    CreateObjPath(objName);
		DoAssemble(asmName, objName);
	    }
	    PopTmpFile(asmName);
	    remove(asmName);
	}
    }
    AddName(&OList, NULL, objName);
}

void
HandleAFile(in, fc)
char *in;
int fc;
{
    char *objName;

    if (fc == 1 && OutFile && NoLink)
	objName = OutFile;
    else
	objName = MungeFile(in, OutDir, ".o");

    if (OutOfDate(in, objName)) {
	if (NoHeirOpt == 0)
	    CreateObjPath(objName);
	DoAssemble(in, objName);
    }
    AddName(&OList, NULL, objName);
}

void
PushTmpFile(name)
char *name;
{
    NODE *node = malloc(sizeof(NODE) + strlen(name) + 1);
    if (node == NULL) {
	puts("Ran out of memory!");
	exit(1);
    }
    node->ln_Name = (char *)(node + 1);
    strcpy(node->ln_Name, name);
    AddHead(&TmpList, node);
}

void
PopTmpFile(name)
char *name;
{
    NODE *node = RemHead(&TmpList);

    if (node == NULL || strcmp(name, node->ln_Name) != 0) {
	puts("PopTmpFile: software error");
	exit(1);
    }
    free(node);
}

LoadSegLock(lock)
long lock;
{
    long oldLock;
    long seg;

    oldLock = CurrentDir(lock);
    seg = LoadSeg("");
    CurrentDir(oldLock);
    return(seg);
}

/*
 *	AZTEC C, LATTICE C COMPATIBILITY OPTIONS
 */

#ifdef AZLAT_COMPAT

DoLink(lfile)
char *lfile;
{
    switch(CompilerOpt) {
    case DICE_C:
	return(DoLink_Dice(lfile));
    case LATTICE_C:
	return(DoLink_Lattice(lfile));
    case AZTEC_C:
	return(DoLink_Aztec(lfile));
    }
}

DoCompile(in, out)
char *in;
char *out;
{
    switch(CompilerOpt) {
    case DICE_C:
	return(DoCompile_Dice(in, out));
    case LATTICE_C:
	return(DoCompile_Lattice(in, out));
    case AZTEC_C:
	return(DoCompile_Aztec(in, out));
    }
    return(0);
}

DoAssemble(in, out)
char *in;
char *out;
{
    switch(CompilerOpt) {
    case DICE_C:
	return(DoAssemble_Dice(in, out));
    case LATTICE_C:
	return(DoAssemble_Lattice(in, out));
    case AZTEC_C:
	return(DoAssemble_Aztec(in, out));
    }
    return(0);
}

char *
DoPrelink(void)
{
    switch(CompilerOpt) {
    case DICE_C:
	return(DoPrelink_Dice());
    case LATTICE_C:
	return(DoPrelink_Lattice());
    case AZTEC_C:
	return(DoPrelink_Aztec());
    }
    return(0);
}

/*
 *	------------------------------------------------------------------
 */

DoCompile_Lattice(in, out)
char *in;
char *out;
{
    char *qq = "";
    char *cptmp = TmpFileName(".i");
    char *data = (SmallData) ? qq : " -b0";

    sprintf(Buf, "lc -o%s %s %s %s",
	out, OptListToStr2(&CppOptList, "DdIi"), data, in
    );
    run_cmd(Buf);

    free(cptmp);
    return(0);
}

DoAssemble_Lattice(in, out)
char *in;
char *out;
{
    sprintf(Buf, "asm -o%s %s", out, in);
    run_cmd(Buf);
    return(0);
}

char *
DoPrelink_Lattice(void)
{
    NameNode *nn;
    char *ltmp = TmpFileName(".lnk");
    FILE *fi = fopen(ltmp, "w");
    short libs = 0;

    if (fi == NULL) {
	fprintf(stderr, "couldn't create %s\n", ltmp);
	exit(1);
    }

    while (nn = (NameNode *)RemHead(&OList)) {
	fputs(nn->n_In, fi);
	putc('\n', fi);
    }

    while (nn = (NameNode *)RemHead(&LList)) {
	if (libs == 0) {
	    fprintf(fi, "LIB ");
	    libs = 1;
	}
	fputs(nn->n_In, fi);
	putc('\n', fi);
    }
    if (RomOpt == 0 && NoDefaultLibs == 0) {
	if (libs == 0) {
	    fprintf(fi, "LIB ");
	    libs = 1;
	}
	fprintf(fi, "lib:lc.lib lib:amiga.lib\n");
    }

    fclose(fi);
    return(ltmp);
}

DoLink_Lattice(lfile)
char *lfile;
{
    char *qq = "";
    char *co = " ";
    char *symopt = (SymOpt) ? " ADDSYM" : qq;
    char *scopt = (SmallData) ? " SD" : qq;
    char *sdopt = (SmallCode) ? " SC" : qq;

    if (RomOpt == 0 && NoDefaultLibs == 0) {       /*  RomOpt PIOpt ResOpt */
	static char *SCode[] = { "lib:c.o",         /*    0      0      0   */
				 "lib:cres.o",      /*    0      0      1   */
				 "lib:c.o",         /*    0      1      0   */
				 "lib:cres.o"       /*    0      1      1   */
			       };
	co = SCode[(short)((PIOpt << 1) | ResOpt)];
    }

    if (OutFile == NULL)
	OutFile = "a.out";

    sprintf(Buf, "BLink from %s with %s to %s%s%s%s",
	co, lfile, OutFile, symopt, scopt, sdopt
    );
    run_cmd(Buf);
    return(0);
}

/*
 *  ---------------------------------------------------------------------
 */

DoCompile_Aztec(in, out)
char *in;
char *out;
{
    char *qq = "";
    char *cptmp = TmpFileName(".i");
    char *data = (SmallData) ? qq : qq;

    sprintf(Buf, "cc %s %s %s -o %s",
	OptListToStr2(&CppOptList, ""), data, in, out
    );
    run_cmd(Buf);

    free(cptmp);
    return(0);
}

DoAssemble_Aztec(in, out)
char *in;
char *out;
{
    sprintf(Buf, "as %s -o %s", in, out);
    run_cmd(Buf);
    return(0);
}

char *
DoPrelink_Aztec(void)
{
    NameNode *nn;
    char *ltmp = TmpFileName(".lnk");
    FILE *fi = fopen(ltmp, "w");

    if (fi == NULL) {
	fprintf(stderr, "couldn't create %s\n", ltmp);
	exit(1);
    }

    while (nn = (NameNode *)RemHead(&OList)) {
	fputs(nn->n_In, fi);
	putc('\n', fi);
    }
    while (nn = (NameNode *)RemHead(&LList)) {
	fputs(nn->n_In, fi);
	putc('\n', fi);
    }
    if (RomOpt == 0 && NoDefaultLibs == 0) {
	fprintf(fi, "-lc\n");
    }
    fclose(fi);
    return(ltmp);
}

DoLink_Aztec(lfile)
char *lfile;
{
    char *qq = "";

    if (OutFile == NULL)
	OutFile = "a.out";

    sprintf(Buf, "ln -f %s -o %s", lfile, OutFile);
    run_cmd(Buf);
    return(0);
}

#endif

void
OrderApp(buf)
char *buf;
{
    short i;
    short c;
    char sort[26];

    setmem(sort, sizeof(sort), 0);
    for (i = 0; c = buf[i]; ++i) {
	if (c >= 'a' && c <= 'z')
	    sort[c-'a'] = 1;
    }
    for (i = sizeof(sort) - 1, c = 0; i >= 0; --i) {
	if (sort[i])
	    buf[c++] = i + 'a';
    }
    buf[c] = 0;
}

void
AddLibApp(buf, c)
char *buf;
char c;
{
    short i = strlen(buf);

    if (strchr(buf, c) == NULL) {
	buf[i+0] = c;
	buf[i+1] = 0;
    }
}

void
DelLibApp(buf, c)
char *buf;
char c;
{
    char *ptr;

    if (ptr = strchr(buf, c))
	movmem(ptr + 1, ptr, strlen(ptr + 1) + 1);
}

