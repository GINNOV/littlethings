static char copyright[] = "@(#)Copyright (c) 1986, Greg McGary";
static char sccsid[] = "@(#)lid.c	1.4 86/11/06";

#include	"bool.h"
#include	<stdio.h>
#include	<stdlib.h>
#include	"string.h"
#include	<ctype.h>
#include	"radix.h"
#include	"id.h"
#include	"bitops.h"
#include	"extern.h"
#ifdef AMIGA
#include	<dos.h>

#include <dos/dosextens.h>
#include <dos/dostags.h>
#include <clib/dos_protos.h>
#include <pragmas/dos_pragmas.h>

extern struct DosLibrary *DOSBase;
#endif

#ifdef REGEX
extern char *regex();
extern char *regcmp();
#endif
#ifdef RE_EXEC
extern char *re_comp();
extern int re_exec();
#endif

#ifdef AMIGA
int case_sensitive = TRUE;

char *verstag = "\0$VER: lid " TOOL_VERSION " " __AMIGADATE__ "\r\n";

char *
regex(char *pattern,char *string)
{
	BOOL result;

	if(case_sensitive)
		result = MatchPattern(pattern,string);
	else
		result = MatchPatternNoCase(pattern,string);

	if(result)
		return(string);
	else
		return(NULL);
}

char *
regcmp(char *pattern,int dummy)
{
	static char *patbuf;
	static int patbuflen;
	int len;

	len = strlen(pattern);

	if(len > patbuflen)
	{
		if(patbuf)
			free(patbuf);

		if(patbuf = malloc(2 * len + 2))
			patbuflen = 2 * len + 2;
		else
		{
			patbuflen = 0;

			return(NULL);
		}
	}

	if(case_sensitive)
	{
		if(ParsePattern(pattern,patbuf,patbuflen) == -1)
			return(NULL);
	}
	else
	{
		if(ParsePatternNoCase(pattern,patbuf,patbuflen) == -1)
			return(NULL);
	}

	return(patbuf);
}

#define REGEX 1	/* We support regular expression matching. */
#endif

void lookId(char *name, char **argv);
void grepId(char *name, char **argv);
void editId(char *name, char **argv);
int skipToArgv(char **argv);
int findPlain(char *arg, void (*doit)(char *name, char **argv));
int findAnchor(char *arg, void (*doit)(char *name, char **argv));
int findRegExp(char *re, void (*doit)(char *name, char **argv));
int findNumber(char *arg, void (*doit)(char *name, char **argv));
int findNonUnique(int limit, void (*doit)(char *name, char **argv));
int findApropos(char *arg, void (*doit)(char *name, char **argv));
char *strcpos(char *s1, char *s2);
char *fileRE(char *name0, char *leftDelimit, char *rightDelimit);
long searchName(char *name);
int idCompare(char *key, char *offsetkludge);
bool isMagic(char *name);
char **bitsToArgv(char *bitArray);

#ifdef USG
#define	TOLOWER(c)	(isupper(c) ? _tolower(c) : (c))
#else
#define	TOLOWER(c)	(isupper(c) ? tolower(c) : (c))
#endif

/*
*  Sorry about all the globals, but it's really cleaner this way.
*/
FILE		*IdFILE;
bool		Merging;
bool		Radix;
char		*IdDir;
long		AnchorOffset;
int		BitArraySize;
struct idhead	Idh;
struct idarg	*IdArgs;
int		(*FindFunc)(char *re, void (*doit)(char *name, char **argv)) = NULL;
int		Solo = 0;
#define	IGNORE_SOLO(buf) \
( \
	   (Solo == '-' && !(ID_FLAGS(buf) & IDN_SOLO)) \
	|| (Solo == '+' &&  (ID_FLAGS(buf) & IDN_SOLO)) \
)

char *MyName;
static void
usage(void)
{
	fprintf(stderr, "Usage: %s [-f<file>] [-u<n>] [-mewdoxasi] patterns...\n", MyName);
	exit(1);
}

void
main(int argc,char **argv)
{
	char		*idFile = IDFILE;
	char		*arg;
	long		val;
	void		(*doit)(char *name, char **argv);
	bool		forceMerge = FALSE;
	int		uniqueLimit = 0;
	int		op;

	MyName = basename(GETARG(argc, argv));

	while (argc) {
		arg = GETARG(argc, argv);
		switch (op = *arg++)
		{
		case '-':
		case '+':
			break;
		default:
			UNGETARG(argc, argv);
			goto argsdone;
		}
		while (*arg) switch (*arg++)
		{
		case 'f': idFile = arg; goto nextarg;
		case 'u': uniqueLimit = stoi(arg); goto nextarg;
		case 'm': forceMerge = TRUE; break;
#if REGEX || RE_EXEC
		case 'e': FindFunc = findRegExp; break;
#endif
		case 'w': FindFunc = findPlain; break;
		case 'd': Radix |= RADIX_DEC; break;
		case 'o': Radix |= RADIX_OCT; break;
		case 'x': Radix |= RADIX_HEX; break;
		case 'a': Radix |= RADIX_ALL; break;
		case 's': Solo = op; break;
		case 'i': case_sensitive = FALSE; break;	/* To do case-insensitive regexp stuff  -olsen */
		default:
			usage();
		}
	nextarg:;
	}
argsdone:

	IdDir = getDirToName(idFile);
	idFile = spanPath(IdDir, idFile);
	if ((IdFILE = initID(idFile, &Idh, &IdArgs)) == NULL) {
		filerr("open", idFile);
		exit(1);
	}
	BitArraySize = (Idh.idh_pthc + 7) >> 3;

	switch (tolower(MyName[0]))
	{
	case 'a':
		FindFunc = findApropos;
		/*FALLTHROUGH*/
	case 'l':
		doit = lookId;
		break;
	case 'g':
		doit = grepId;
		break;
	case 'e':
		doit = editId;
		break;
	default:
		MyName = "[alge]id";
		usage();
	}

	if (argc == 0) {
		UNGETARG(argc, argv);
#ifdef AMIGA
		*argv = "";
#endif
#ifdef UNIX
		*argv = ".";
#endif
	}

	while (argc) {
		arg = GETARG(argc, argv);
		if (FindFunc)
			;
		else if ((radix(arg)) && (val = stoi(arg)) >= 0)
			FindFunc = findNumber;
#if REGEX || RE_EXEC
		else if (isMagic(arg))
			FindFunc = findRegExp;
#endif
		else if (arg[0] == '^')
			FindFunc = findAnchor;
		else
			FindFunc = findPlain;

		if ((doit == lookId && !forceMerge)
		|| (FindFunc == findNumber && bitCount(Radix) > 1 && val > 7))
			Merging = FALSE;
		else
			Merging = TRUE;

		if (uniqueLimit) {
			if (!findNonUnique(uniqueLimit, doit))
				fprintf(stderr, "All identifiers are unique within the first %d characters\n", uniqueLimit);
			exit(0);
		} else if (!(*FindFunc)(arg, doit)) {
			fprintf(stderr, "%s: not found\n", arg);
			continue;
		}
	}
	exit(0);
}

void
lookId(char *name,register char	**argv)
{
	register char	*arg;
	register bool	crunching = FALSE;
	register char	*dir;

	printf("%-14s ", name);
	while (*argv) {
		arg = *argv++;
		if (*argv && canCrunch(arg, *argv)) {
#ifdef AMIGA
			if (crunching)
				printf("|%s", rootName(arg));
			else if ((dir = dirname(arg)) != NULL) {
				if (*dir == '\0')
					printf("(%s", rootName(arg));
				else
					printf("%s%s%s",dir,
					   dir[strlen(dir)-1] == ':' ? "" : "/",
					   rootName(arg));
			}
#endif
#ifdef UNIX
			if (crunching)
				printf(",%s", rootName(arg));
			else if ((dir = dirname(arg)) && dir[0] == '.' &&
				 dir[1] == '\0')
				printf("{%s", rootName(arg));
			else
				printf("%s/{%s", dir, rootName(arg));
#endif
			/*}}*/
			crunching = TRUE;
		} else {
			if (crunching) /*{*/
#ifdef AMIGA
				printf("|%s)%s", rootName(arg), suffName(arg));
#else
				printf(",%s}%s", rootName(arg), suffName(arg));
#endif
			else
				fputs(arg, stdout);
			crunching = FALSE;
			if (*argv)
				putchar(' ');
		}
	}
	putchar('\n');
}

void
grepId(char *name,char **argv)
{
	FILE		*gidFILE;
	char		*gidName;
	char		buf[BUFSIZ];
	char		*delimit = "[^a-zA-Z0-9_]";
	char		*re;
	char		*reCompiled;
	int		lineNumber;

	if (!Merging || (re = fileRE(name, delimit, delimit)) == NULL)
		re = NULL;
#ifdef REGEX
	else if ((reCompiled = regcmp(re, 0)) == NULL) {
		fprintf(stderr, "%s: Syntax Error: %s\n", MyName, re);
		return;
	}
#endif
#ifdef RE_EXEC
	else if ((reCompiled = re_comp(re)) != NULL) {
		fprintf(stderr, "%s: Syntax Error: %s (%s)\n", MyName, re, reCompiled);
		return;
	}
#endif

	buf[0] = ' ';	/* sentry */
	while (*argv) {
		if ((gidFILE = fopen(gidName = *argv++, "r")) == NULL) {
			filerr("open", gidName);
			continue;
		}
		lineNumber = 0;
		while (fgets(&buf[1], sizeof(buf), gidFILE)) {
			lineNumber++;
			if (re) {
#ifdef REGEX
				if (regex(reCompiled, buf) == NULL)
#endif
#ifdef RE_EXEC
				if (!re_exec(buf))
#endif
					continue;
			} else if (!wordMatch(name, buf))
				continue;
			printf("%s:%d: %s", gidName, lineNumber, &buf[1]);
		}
		fclose(gidFILE);
	}
}

void
editId(char *name,char **argv)
{
	char		reBuf[256];
	char		edArgBuf[256];
	char		*re;
	int		c;
	int		skip;
	static char	*editor, *eidArg, *eidRightDel, *eidLeftDel;
	static char	editbuf[128];

	if (editor == NULL && (editor = getenv("EDITOR")) == NULL) {
#ifdef UNIX
		char	*ucb_vi = "/usr/ucb/vi";
		char	*bin_vi = "/usr/bin/vi";

		if (access(ucb_vi, 01) == 0)
			editor = ucb_vi;
		else if (access(bin_vi, 01) == 0)
			editor = bin_vi;
		else
			editor = "/bin/ed";	/* YUCK! */
		if (editor == ucb_vi || editor == bin_vi) {
			eidArg = "+1;/%s/";
			eidLeftDel = "\\<";
			eidRightDel = "\\>";
		}
#endif
	}
	if (eidLeftDel == NULL) {
		eidArg = getenv("EIDARG");
		if ((eidLeftDel = getenv("EIDLDEL")) == NULL)
			eidLeftDel = "";
		if ((eidRightDel = getenv("EIDRDEL")) == NULL)
			eidRightDel = "";
	}

	lookId(name, argv);
	savetty();
	for (;;) {
		printf("Edit? [y1-9^S/nq] "); fflush(stdout);
		chartty();
		c = (getchar() & 0177);
		restoretty();
		switch (TOLOWER(c))
		{
		case '/': case ('s'&037):
			putchar('/');
			/*FALLTHROUGH*/
			if ((skip = skipToArgv(argv)) < 0)
				continue;
			argv += skip;
			goto editit;
		case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9':
			putchar(c);
			skip = c - '0';
			break;
		case 'y':
			putchar(c);
			/*FALLTHROUGH*/
		case '\n':
		case '\r':
			skip = 0;
			break;
		case 'q':
			putchar(c);
			putchar('\n');
			exit(0);
		case 'n':
			putchar(c);
			putchar('\n');
			return;
		default:
			putchar(c);
			putchar('\n');
			continue;
		}

		putchar('\n');
		while (skip--)
			if (*++argv == NULL)
				continue;
		break;
	}
editit:

#ifdef AMIGA
	if (editor == NULL)
	{
/* let's assume getenv mallocs for multitasking */
		printf("\nEditor? ");
		if (!gets(editbuf))
			goto cant_edit;
		editor = editbuf;
	}
#endif
	if (!Merging || (re = fileRE(name, eidLeftDel, eidRightDel)) == NULL)
		sprintf(re = reBuf, "%s%s%s", eidLeftDel, name, eidRightDel);

#ifdef UNIX
	switch (fork())
	{
	case -1:
		fprintf(stderr, "%s: Cannot fork (%s)\n", MyName, uerror());
		exit(1);
	case 0:
		argv--;
		if (eidArg) {
			argv--;
			sprintf(edArgBuf, eidArg, re);
			argv[1] = edArgBuf;
		}
		argv[0] = editor;
		execv(editor, argv);
		filerr("exec", editor);
	default:
		wait(0);
		break;
	}
#endif /* UNIX */

#ifdef AMIGA
	{
		argv--;
		if (eidArg) {
			argv--;
			sprintf(edArgBuf, eidArg, re, argv[2]);
			argv[1] = edArgBuf;
		}
		argv[0] = editor;
#ifdef DEBUG
		printf("Execing %s %s\n",editor,argv[1]);
#endif
		{
			char *buffer = malloc(strlen(editor) + 1 + strlen(argv[1]) + 1);

			if(buffer)
			{
				static struct TagItem standard_tags[] = { SYS_UserShell,TRUE,TAG_DONE };
				int result;

				sprintf(buffer,"%s %s",editor,argv[1]);

				result = SystemTagList(buffer,standard_tags);

				free(buffer);

				if(result)
					goto cant_edit;
			}
			else
				goto cant_edit;
		}
	}
	return;

cant_edit:
	printf("Can't fork editor %s!\n",editor);
	editor = NULL;	/* so it'll ask him */
#endif /* AMIGA */
}

int
skipToArgv(char **argv)
{
	char		pattern[BUFSIZ];
	int		count;

	if (gets(pattern) == NULL)
		return -1;

	for (count = 0; *argv; count++, argv++)
		if (strcpos(*argv, pattern))
			return count;
	return -1;
}

int
findPlain(char *arg,void (*doit)(char *name, char **argv))
{
	static char	*buf, *bitArray;
	int		size;

	if (searchName(arg) == 0)
		return 0;
	if (buf == NULL) {
		buf = xmalloc(Idh.idh_bsiz);
		bitArray = xmalloc(BitArraySize);
	}
	bzero(bitArray, BitArraySize);

	if ((size = fgets0(buf, Idh.idh_bsiz, IdFILE)) == 0)
		return 0;
	size++;
	getsFF(&buf[size], IdFILE);
	if (IGNORE_SOLO(buf))
		return 0;

	vecToBits(bitArray, &buf[size], Idh.idh_vecc);
	(*doit)(ID_STRING(buf), bitsToArgv(bitArray));
	return 1;
}

int
findAnchor(char *arg,void (*doit)(char *name, char **argv))
{
	static char	*buf, *bitArray;
	int		count, size;
	int		len;

	if (searchName(++arg) == 0)
		return 0;

	if (buf == NULL) {
		buf = xmalloc(Idh.idh_bsiz);
		bitArray = xmalloc(BitArraySize);
	}
	bzero(bitArray, BitArraySize);

	len = strlen(arg);
	count = 0;
	while ((size = fgets0(buf, Idh.idh_bsiz, IdFILE)) > 0) {
		size++;
		getsFF(&buf[size], IdFILE);
		if (IGNORE_SOLO(buf))
			continue;
		if (!strnequ(arg, ID_STRING(buf), len))
			break;
		vecToBits(bitArray, &buf[size], Idh.idh_vecc);
		if (!Merging) {
			(*doit)(ID_STRING(buf), bitsToArgv(bitArray));
			bzero(bitArray, BitArraySize);
		}
		count++;
	}
	if (Merging && count)
		(*doit)(--arg, bitsToArgv(bitArray));

	return count;
}

#if REGEX || RE_EXEC
int
findRegExp(char *re,void (*doit)(char *name, char **argv))
{
	static char	*buf, *bitArray;
	int		count, size;
	char		*reCompiled;

#ifdef REGEX
	if ((reCompiled = regcmp(re, 0)) == NULL) {
		fprintf(stderr, "%s: Syntax Error: %s\n", MyName, re);
		return 0;
	}
#endif
#ifdef RE_EXEC
	if ((reCompiled = re_comp(re)) != NULL) {
		fprintf(stderr, "%s: Syntax Error: %s (%s)\n", MyName, re, reCompiled);
		return 0;
	}
#endif
	fseek(IdFILE, Idh.idh_namo, 0);

	if (buf == NULL) {
		buf = xmalloc(Idh.idh_bsiz);
		bitArray = xmalloc(BitArraySize);
	}
	bzero(bitArray, BitArraySize);

	count = 0;
	while ((size = fgets0(buf, Idh.idh_bsiz, IdFILE)) > 0) {
		size++;
		getsFF(&buf[size], IdFILE);
		if (IGNORE_SOLO(buf))
			continue;
#ifdef REGEX
		if (regex(reCompiled, ID_STRING(buf)) == NULL)
#endif
#ifdef RE_EXEC
		if (!re_exec(ID_STRING(buf)))
#endif
			continue;
		vecToBits(bitArray, &buf[size], Idh.idh_vecc);
		if (!Merging) {
			(*doit)(ID_STRING(buf), bitsToArgv(bitArray));
			bzero(bitArray, BitArraySize);
		}
		count++;
	}
	if (Merging && count)
		(*doit)(re, bitsToArgv(bitArray));

	return count;
}
#endif

int
findNumber(char *arg,void (*doit)(char *name, char **argv))
{
	static char	*buf, *bitArray;
	int		count, size;
	register int	rdx = 0;
	register int	val;
	register bool	hitDigits = FALSE;

	if ((val = stoi(arg)) <= 7)
		rdx |= RADIX_ALL;
	else
		rdx = radix(arg);
	fseek(IdFILE, Idh.idh_namo, 0);

	if (buf == NULL) {
		buf = xmalloc(Idh.idh_bsiz);
		bitArray = xmalloc(BitArraySize);
	}
	bzero(bitArray, BitArraySize);

	count = 0;
	while ((size = fgets0(buf, Idh.idh_bsiz, IdFILE)) > 0) {
		size++;
		getsFF(&buf[size], IdFILE);
		if (hitDigits) {
			if (!isdigit(*ID_STRING(buf)))
				break;
		} else if (isdigit(*ID_STRING(buf)))
			hitDigits = TRUE;

		if (!((Radix ? Radix : rdx) & radix(ID_STRING(buf)))
		|| stoi(ID_STRING(buf)) != val)
			continue;
		vecToBits(bitArray, &buf[size], Idh.idh_vecc);
		if (!Merging) {
			(*doit)(ID_STRING(buf), bitsToArgv(bitArray));
			bzero(bitArray, BitArraySize);
		}
		count++;
	}
	if (Merging && count)
		(*doit)(arg, bitsToArgv(bitArray));

	return count;
}

/*
	Find identifiers that are non-unique within
	the first `count' characters.
*/
int
findNonUnique(int limit,void (*doit)(char *name, char **argv))
{
	static char	*buf1, *buf2, *bitArray;
	register char	*old;
	register char	*new;
	register int	consecutive;
	char		*cptmp;
	int		itmp;
	int		count, oldsize, newsize = 0;	/* added init, REJ */
	char		*name;

	if (limit <= 1)
		usage();

	fseek(IdFILE, Idh.idh_namo, 0);

	if (buf1 == NULL) {
		buf1 = xmalloc(Idh.idh_bsiz);
		buf2 = xmalloc(Idh.idh_bsiz);
		bitArray = xmalloc(BitArraySize);
	}
	bzero(bitArray, BitArraySize);

	name = xcalloc(1, limit+2);
	name[0] = '^';
	old = buf1;
	*ID_STRING(new = buf2) = '\0';
	count = consecutive = 0;
	while ((oldsize = fgets0(old, Idh.idh_bsiz, IdFILE)) > 0) {
		oldsize++;
		getsFF(&old[oldsize], IdFILE);
		if (!(ID_FLAGS(old) & IDN_NAME))
			continue;
		cptmp = old; old = new; new = cptmp;
/* DANGER! newsize is unitialized! REJ (make that was) */
		itmp = oldsize; oldsize = newsize; newsize = itmp;
		if (!strnequ(ID_STRING(new), ID_STRING(old), limit)) {
			if (consecutive && Merging) {
				strncpy(&name[1], ID_STRING(old), limit);
				(*doit)(name, bitsToArgv(bitArray));
			}
			consecutive = 0;
			continue;
		}
		if (!consecutive++) {
			vecToBits(bitArray, &old[oldsize], Idh.idh_vecc);
			if (!Merging) {
				(*doit)(ID_STRING(old), bitsToArgv(bitArray));
				bzero(bitArray, BitArraySize);
			}
			count++;
		}
		vecToBits(bitArray, &new[newsize], Idh.idh_vecc);
		if (!Merging) {
			(*doit)(ID_STRING(new), bitsToArgv(bitArray));
			bzero(bitArray, BitArraySize);
		}
		count++;
	}

	return count;
}

int
findApropos(char *arg,void (*doit)(char *name, char **argv))
{
	static char	*buf, *bitArray;
	int		count, size;

	fseek(IdFILE, Idh.idh_namo, 0);

	if (buf == NULL) {
		buf = xmalloc(Idh.idh_bsiz);
		bitArray = xmalloc(BitArraySize);
	}
	bzero(bitArray, BitArraySize);

	count = 0;
	while ((size = fgets0(buf, Idh.idh_bsiz, IdFILE)) > 0) {
		size++;
		getsFF(&buf[size], IdFILE);
		if (IGNORE_SOLO(buf))
			continue;
		if (strcpos(ID_STRING(buf), arg) == NULL)
			continue;
		vecToBits(bitArray, &buf[size], Idh.idh_vecc);
		if (!Merging) {
			(*doit)(ID_STRING(buf), bitsToArgv(bitArray));
			bzero(bitArray, BitArraySize);
		}
		count++;
	}
	if (Merging && count)
		(*doit)(arg, bitsToArgv(bitArray));

	return count;
}

/*
	if string `s2' occurs in `s1', return a pointer to the
	first match.  Ignore differences in alphabetic case.
*/
char *
strcpos(char *s1, char *s2)
{
	register char	*s1p;
	register char	*s2p;
	char		*s1last;

	for (s1last = &s1[strlen(s1) - strlen(s2)]; s1 <= s1last; s1++)
		for (s1p = s1, s2p = s2; TOLOWER(*s1p) == TOLOWER(*s2p); s1p++)
			if (*++s2p == '\0')
				return s1;
	return NULL;
}

/*
	Convert the regular expression that we used to
	locate identifiers in the id database into one
	suitable for locating the identifiers in files.
*/
char *
fileRE(char *name0, char *leftDelimit, char *rightDelimit)
{
	static char	reBuf[BUFSIZ];
	register char	*name = name0;

	if (FindFunc == findNumber && Merging) {
		sprintf(reBuf, "%s0*[Xx]*0*%d[Ll]*%s", leftDelimit, stoi(name), rightDelimit);
		return reBuf;
	}

	if (!isMagic(name) && name[0] != '^')
		return NULL;

	if (name[0] == '^')
		name0++;
	else
		leftDelimit = "";
	while (*++name)
		;
	if (*--name == '$')
		*name = '\0';
	else
		rightDelimit = "";

	sprintf(reBuf, "%s%s%s", leftDelimit, name0, rightDelimit);
	return reBuf;
}

long
searchName(char *name)
{
	long		offset;

	AnchorOffset = 0;
	offset = (long)bsearch(name, (char *)(Idh.idh_namo-1), Idh.idh_endo-(Idh.idh_namo-1), 1, idCompare);
	if (offset == 0)
		offset = AnchorOffset;
	if (offset == 0)
		return 0;
	fseek(IdFILE, offset, 0);
	skipFF(IdFILE);
	return ftell(IdFILE);
}

int
idCompare(char *key, char *offsetkludge)	/* note: require the kludge since the argument must not be an integral type. */
{
	long offset;
	int c;

	offset = (long)offsetkludge;

	fseek(IdFILE, offset, 0);
	skipFF(IdFILE);
	getc(IdFILE);

	while (*key == (c = getc(IdFILE)))
		if (*key++ == '\0')
			return 0;
	if (*key == '\0' && FindFunc == findAnchor)
		AnchorOffset = offset;

	return *key - c;
}

/*
	Are there any magic Regular Expression meta-characters in name??
*/
bool
isMagic(char *name)
{
#ifdef AMIGA
	char		*magichar = "[]()%#?~*";
#else
	char		*magichar = "[]{}().*+^$";
#endif
	int		backslash = 0;

#ifdef AMIGA
	while (*name) {
		if (*name == '`')
			name++, backslash++;
		else if (strchr(magichar, *name))
			return TRUE;
		name++;
	}
	if (backslash)
		while (*name) {
			if (*name == '`')
				strcpy(name, name+1);
			name++;
		}
#else
	if (*name == '^')
		name++;
	while (*name) {
		if (*name == '\\')
			name++, backslash++;
		else if (strchr(magichar, *name))
			return TRUE;
		name++;
	}
	if (backslash)
		while (*name) {
			if (*name == '\\')
				strcpy(name, name+1);
			name++;
		}
#endif
	return FALSE;
}

char **
bitsToArgv(char *bitArray)
{
	static char	**argv;
	struct idarg	*idArgs;
	register char	**av;
	register int	i;
#define	ARGV1stPATH	3 /* available argv[] slots before first pathname */

	if (argv == NULL)
		argv = (char **)xmalloc(sizeof(char *) * (Idh.idh_pthc + ARGV1stPATH + 2));

	av = argv + ARGV1stPATH;
	for (idArgs = IdArgs, i = 0; i < Idh.idh_pthc; i++, idArgs++) {
		if (!BITTST(bitArray, i))
			continue;
		if (idArgs->ida_flags & IDA_BLANK) {
			printf("BOTCH: blank index!\n");
			abort();
		}
		if (!(idArgs->ida_flags & IDA_ADJUST)) {
			idArgs->ida_arg = strsav(spanPath(IdDir, idArgs->ida_arg));
			idArgs->ida_flags |= IDA_ADJUST;
		}
		*av++ = idArgs->ida_arg;
	}
	*av = NULL;
	return (argv + ARGV1stPATH);
}
