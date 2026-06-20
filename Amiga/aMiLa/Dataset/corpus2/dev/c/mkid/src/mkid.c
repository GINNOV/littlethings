static char copyright[] = "@(#)Copyright (c) 1986, Greg McGary";
static char sccsid[] = "@(#)mkid.c	1.4 86/11/06";

/* #define register */

#include	"bool.h"
#ifdef UNIX
#include	<sys/types.h>
#include	<sys/stat.h>
#endif
#include	<stdio.h>
#include	<stdlib.h>
#include	"string.h"
#include	<ctype.h>
#include	"id.h"
#include	"bitops.h"
#include	<errno.h>
#include	"extern.h"
#ifdef AMIGA
#include	<time.h>
#include	<dos.h>
#endif
#ifdef __SASC
#include	<sys/stat.h>
#endif

#ifdef AMIGA
char *verstag = "\0$VER: mkid " TOOL_VERSION " " __AMIGADATE__ "\r\n";
#endif

void extractId(char *(*getId)(FILE *,int *), FILE *srcFILE, int index);
void writeID(char *idFile, struct idarg *idArgs);
void oldIdArgs(char *idFile, struct idarg **idArgsP);
void updateID(char *idFile, struct idarg *idArgs);
void fileIdArgs(FILE *argFILE, struct idarg **idArgsP);
void initHashTable(int pathCount);
void rehash(void);
int round2(int rough);
int idnHashCmp(char *key, struct idname **idn);
int idnQsortCmp(struct idname **idn1, struct idname **idn2);
struct idname *newIdName(char *name);
int postIncr(int *ip);
int hashCompress(char **table, int size);

long	NameCount;		/* Count of names in database */
long	NumberCount;		/* Count of numbers in database */
long	StringCount;		/* Count of strings in database */
long	SoloCount;		/* Count of identifiers that occur only once */

long	HashSize;		/* Total Slots in hash table */
long	HashMaxLoad;		/* Maximum loading of hash table */
long	HashFill;		/* Number of keys inserted in table */
long	HashProbes;		/* Total number of probes */
long	HashSearches;		/* Total number of searches */
struct idname	**HashTable;	/* Vector of idname pointers */

bool	Verbose = FALSE;

int	ArgsCount = 0;		/* Count of args to save */
int	ScanCount = 0;		/* Count of files to scan */
int	PathCount = 0;		/* Count of files covered in database */
int	BitArraySize;		/* Size of bit array slice (per name) */


char	*MyName;
static void
usage(void)
{
	fprintf(stderr, "Usage: %s [-f<idfile>] [-s<dir>] [-r<dir>] [(+|-)l[<lang>]] [-v] [(+|-)S<scanarg>] [-a<argfile>] [-] [-u] [files...]\n", MyName);
	exit(1);
}

void
main(int argc,char **argv)
{
	char		*arg;
	int		op;
	FILE		*argFILE = NULL;
	char		*idFile = IDFILE;
	char		*rcsDir = NULL;
	char		*sccsDir = NULL;
	struct idarg	*idArgs, *idArgHead;
	bool		keepLang = FALSE;
	int		argsFrom = 0;
#define	AF_CMDLINE	0x1	/* file args came on command line */
#define	AF_FILE		0x2	/* file args came from a file (-f<file>) */
#define	AF_IDFILE	0x4	/* file args came from an old ID file (-u) */
#define	AF_QUERY	0x8	/* no file args necessary: usage query */

#ifdef AMIGA

	extern int expand_args(int argc,char **argv,int *_argc,char ***_argv,int all,int sort);

	if(expand_args(argc,argv,&argc,&argv,FALSE,TRUE))	/* AmigaDOS shell does no wildcard expansion  -olsen */
		exit(5);
#endif

	MyName = basename(GETARG(argc, argv));
#ifdef ERRLINEBUF
	setlinebuf(stderr);
#endif

	idArgs = idArgHead = NEW(struct idarg);

	/*
		Process some arguments, and snarf-up some
		others for processing later.
	*/
	while (argc) {
		arg = GETARG(argc, argv);
		if (*arg != '-' && *arg != '+') {
			argsFrom |= AF_CMDLINE;
			idArgs->ida_arg = arg;
			idArgs->ida_flags = IDA_SCAN|IDA_PATH;
			idArgs->ida_index = postIncr(&PathCount);
			ScanCount++;
			idArgs = (idArgs->ida_next = NEW(struct idarg));
			continue;
		}
		op = *arg++;
		switch (*arg++)
		{
		case 'u':
			argsFrom |= AF_IDFILE;
			oldIdArgs(idFile, &idArgs);
			break;
		case '\0':
			argsFrom |= AF_FILE;
			fileIdArgs(stdin, &idArgs);
			break;
		case 'a':
			if ((argFILE = fopen(arg, "r")) == NULL) {
				filerr("open", arg);
				exit(1);
			}
			argsFrom |= AF_FILE;
			fileIdArgs(argFILE, &idArgs);
			fclose(argFILE);	/* added REJ */
			break;
		case 'f':
			idFile = arg;
			break;
		case 'v':
			Verbose = TRUE;
			break;
		case 'S':
			if (strchr(&arg[-2], '?')) {
				setScanArgs(op, arg);
				argsFrom |= AF_QUERY;
			}
			/*FALLTHROUGH*/
		case 'l':
		case 's':
		case 'r':
			idArgs->ida_arg = &arg[-2];
			idArgs->ida_index = -1;
			idArgs->ida_flags = IDA_ARG;
			idArgs = (idArgs->ida_next = NEW(struct idarg));
			ArgsCount++;
			break;
		default:
			usage();
		}
	}

	if (argsFrom & AF_QUERY)
		exit(0);
	/*
		File args should only come from one place.  Ding the
		user if arguments came from multiple places, or if none
		were supplied at all.
	*/
	switch (argsFrom)
	{
	case AF_CMDLINE:
	case AF_FILE:
	case AF_IDFILE:
		if (PathCount > 0)
			break;
		/*FALLTHROUGH*/
	case 0:
		fprintf(stderr, "%s: Use -u, -f<file>, or cmd-line for file args!\n", MyName);
		usage();
	default:
		fprintf(stderr, "%s: Use only one of: -u, -f<file>, or cmd-line for file args!\n", MyName);
		usage();
	}

	if (ScanCount == 0)
		exit(0);

	BitArraySize = (PathCount + 7) >> 3;
	initHashTable(ScanCount);

	if (access(idFile, 06) < 0
	&& (errno != ENOENT || access(dirname(idFile), 06) < 0)) {
		filerr("modify", idFile);
		exit(1);
	}

	for (idArgs = idArgHead; idArgs->ida_next; idArgs = idArgs->ida_next) {
		char		*(*scanner)(FILE *,int *);
		FILE		*srcFILE;
		char		*arg, *lang = NULL, *suff;
/* added = NULL - it assumed locals were zeroed! REJ */

		arg = idArgs->ida_arg;
		if (idArgs->ida_flags & IDA_ARG) {
			op = *arg++;
			switch (*arg++)
			{
			case 'l':
				if (*arg == '\0') {
					keepLang = FALSE;
					lang = NULL;
					break;
				}
				if (op == '+')
					keepLang = TRUE;
				lang = arg;
				break;
			case 's':
				sccsDir = arg;
				break;
			case 'r':
				rcsDir = arg;
				break;
			case 'S':
				setScanArgs(op, strsav(arg));
				break;
			default:
				usage();
			}
			continue;
		}
		if (!(idArgs->ida_flags & IDA_SCAN))
			goto skip;
		if (lang == NULL) {
			if ((suff = strrchr(arg, '.')) == NULL)
				suff = "";
			if ((lang = getLanguage(suff)) == NULL) {
				fprintf(stderr, "%s: No language assigned to suffix: `%s'\n", MyName, suff);
				goto skip;
			}
		}
		if ((scanner = getScanner(lang)) == NULL) {
			fprintf(stderr, "%s: No scanner for language: `%s'\n",
				MyName, lang);
			goto skip;
		}
		if ((srcFILE = openSrcFILE(arg, sccsDir, rcsDir)) == NULL)
			goto skip;
		if (Verbose)
			fprintf(stderr, "%s: %s\n", lang, arg);
		extractId(scanner, srcFILE, idArgs->ida_index);
		fclose(srcFILE);
	skip:
		if (!keepLang)
			lang = NULL;
	}

	if (HashFill == 0)
		exit(0);

	if (Verbose)
		fprintf(stderr, "Compressing Hash Table...\n");
	hashCompress((char **)HashTable, HashSize);
	if (Verbose)
		fprintf(stderr, "Sorting Hash Table...\n");
	qsort(HashTable, HashFill, sizeof(struct idname *), idnQsortCmp);

	if (argsFrom == AF_IDFILE) {
		if (Verbose)
			fprintf(stderr, "Merging Tables...\n");
		updateID(idFile, idArgHead);
	}

	if (Verbose)
		fprintf(stderr, "Writing `%s'...\n", idFile);
	writeID(idFile, idArgHead);

	if (Verbose) {
		float loadFactor = (float)HashFill / (float)HashSize;
		float aveProbes = (float)HashProbes / (float)HashSearches;
		float aveOccur = (float)HashSearches / (float)HashFill;
		fprintf(stderr, "Names: %ld, ", NameCount);
		fprintf(stderr, "Numbers: %ld, ", NumberCount);
		fprintf(stderr, "Strings: %ld, ", StringCount);
		fprintf(stderr, "Solo: %ld, ", SoloCount);
		fprintf(stderr, "Total: %ld\n", HashFill);
		fprintf(stderr, "Occurances: %.2f, ", aveOccur);
		fprintf(stderr, "Load: %.2f, ", loadFactor);
		fprintf(stderr, "Probes: %.2f\n", aveProbes);
	}
	exit(0);
}

void
extractId(register char *(*getId)(FILE *,int *),register FILE *srcFILE,int index)
{
	register struct idname	**slot;
	register char	*key;
	int		flags;

	while ((key = (*getId)(srcFILE, &flags)) != NULL) {
		slot = (struct idname **)hashSearch(key, (char *)HashTable, HashSize, sizeof(struct idname *), h1str, h2str, (int (*)(char *,char *))idnHashCmp, &HashProbes);
		HashSearches++;
		if (*slot != NULL) {
			(*slot)->idn_flags |= flags;
			BITSET((*slot)->idn_bitv, index);
			continue;
		}
		*slot = newIdName(key);
		(*slot)->idn_flags = IDN_SOLO|flags;
		BITSET((*slot)->idn_bitv, index);
		if (HashFill++ >= HashMaxLoad)
			rehash();
	}
}

void
writeID(char *idFile, struct idarg *idArgs)
{
	register struct idname	**idnp;
	register struct idname	*idn;
	register int	i;
	char		*vecBuf;
	FILE		*idFILE;
	int		count;
	int		lasti;
	long		before, after;
	int		length, longest;
	struct idhead	idh;

/* note: for -u to work on non-unix, updateID MUST close idFILE so open */
/* can succeed REJ 							*/
	if ((idFILE = fopen(idFile, "w+")) == NULL) {
		filerr("create", idFile);
		exit(1);
	}
	fseek(idFILE, (long)sizeof(struct idhead), 0);

	/* write out the list of pathnames */
	idh.idh_argo = ftell(idFILE);
	for (i = lasti = 0; idArgs->ida_next; idArgs = idArgs->ida_next) {
		if (idArgs->ida_index > 0)
			while (++lasti < idArgs->ida_index)
				i++, putc('\0', idFILE);
		fputs(idArgs->ida_arg, idFILE);
		i++, putc('\0', idFILE);
	}
	idh.idh_argc = i;
	idh.idh_pthc = PathCount;

	/* write out the list of identifiers */
	i = 1;
	if (idh.idh_pthc >= 0x000000ff)
		i++;
	if (idh.idh_pthc >= 0x0000ffff)
		i++;
	if (idh.idh_pthc >= 0x00ffffff)
		i++;
	idh.idh_vecc = i;

	vecBuf = xmalloc((idh.idh_pthc + 1) * idh.idh_vecc);

	putc('\377', idFILE);
	before = idh.idh_namo = ftell(idFILE);
	longest = 0;
	for (idnp = HashTable, i = 0; i < HashFill; i++, idnp++) {
		idn = *idnp;
		if (idn->idn_name[0] == '\0') {
			HashFill--; i--;
			continue;
		}
		if (idn->idn_flags & IDN_SOLO)
			SoloCount++;
		if (idn->idn_flags & IDN_NUMBER)
			NumberCount++;
		if (idn->idn_flags & IDN_NAME)
			NameCount++;
		if (idn->idn_flags & IDN_STRING)
			StringCount++;

		putc((*idnp)->idn_flags, idFILE);
		fputs(idn->idn_name, idFILE);
		putc('\0', idFILE);

		count = bitsToVec(vecBuf, (*idnp)->idn_bitv, idh.idh_pthc, idh.idh_vecc);
		fwrite(vecBuf, idh.idh_vecc, count, idFILE);
		putc('\377', idFILE);
		after = ftell(idFILE);

		if ((length = (after - before)) > longest)
			longest = length;
		before = after;
	}
	idh.idh_namc = i;
	putc('\377', idFILE);
	idh.idh_endo = ftell(idFILE);
	idh.idh_bsiz = longest;

	/* write out the header */
	strncpy(idh.idh_magic, IDH_MAGIC, sizeof(idh.idh_magic));
	idh.idh_vers = IDH_VERS;
	fseek(idFILE, 0L, 0);
	fwrite((char *) &idh, sizeof(struct idhead), 1, idFILE);

	fclose(idFILE);
}

/*
	Build an idarg vector from pathnames contained in an existing
	id file.  Only include pathnames for files whose modification
	time is later than that of the id file itself.
*/
void
oldIdArgs(char *idFile, struct idarg **idArgsP)
{
#ifdef UNIX
	struct stat	statBuf;
#endif
#ifdef __SASC
	struct stat	statBuf;
#endif
	struct idhead	idh;
	FILE		*idFILE;
	register int	i;
	register char	*strings;
	time_t		idModTime;

	if ((idFILE = fopen(idFile, "r")) == NULL) {
		filerr("open", idFile);
		usage();
	}
	/*
	*  Open the id file, get its mod-time, and read its header.
	*/
#ifdef UNIX
	if (fstat(fileno(idFILE), &statBuf) < 0) {
		filerr("stat", idFile);
		usage();
	}
	idModTime = statBuf.st_mtime;
#endif

#ifdef __SASC
	if (stat(idFile, &statBuf) < 0) {
		filerr("stat", idFile);
		usage();
	}
	idModTime = statBuf.st_mtime;
#endif
	fread((char *) &idh, sizeof(struct idhead), 1, idFILE);
	if (!strnequ(idh.idh_magic, IDH_MAGIC, sizeof(idh.idh_magic))) {
		fprintf(stderr, "%s: Not an id file: `%s'\n", MyName, idFile);
		exit(1);
	}
	if (idh.idh_vers != IDH_VERS) {
		fprintf(stderr, "%s: ID version mismatch (%ld,%ld)\n", MyName, idh.idh_vers, IDH_VERS);
		exit(1);
	}

	/*
	*  Read in the id pathnames, compare their mod-times with
	*  the id file, and incorporate the pathnames of recently modified
	*  files in the idarg vector.  Also, construct a mask of
	*  bit array positions we want to turn off when we build the
	*  initial hash-table.
	*/
	fseek(idFILE, idh.idh_argo, 0);
	strings = xmalloc(i = idh.idh_namo - idh.idh_argo);
	fread(strings, i, 1, idFILE);
	ScanCount = 0;
	for (i = 0; i < idh.idh_argc; i++) {
		(*idArgsP)->ida_arg = strings;
		if (*strings == '+' || *strings == '-') {
			(*idArgsP)->ida_flags = IDA_ARG;
			(*idArgsP)->ida_index = -1;
		} else {
			(*idArgsP)->ida_flags = IDA_PATH;
			(*idArgsP)->ida_index = postIncr(&PathCount);
#ifdef __SASC
			if (stat(strings, &statBuf) < 0)
				filerr("stat", strings);
			else if (statBuf.st_mtime >= idModTime) {
#endif
/*
#ifdef UNIX
			if (stat(strings, &statBuf) < 0) {
				filerr("stat", strings);
			} else if (statBuf.st_mtime >= idModTime) {
#endif
*/
				(*idArgsP)->ida_flags |= IDA_SCAN;
				ScanCount++;
			}
		}
		(*idArgsP) = ((*idArgsP)->ida_next = NEW(struct idarg));
		while (*strings++)
			;
	}
	fclose(idFILE);

	if (ScanCount == 0) {
		exit(0);
	}
}

void
updateID(char *idFile, struct idarg *idArgs)
{
/*	struct idname	*idn;*/
	struct idhead	idh;
	register char	*bitArray;
	char		*entry0;
	register int	i;
	FILE		*idFILE;
	int		cmp, count, size;
	char		*bitsOff;
	struct idname	**newTable, **mergeTable;
	struct idname	**t1, **t2, **tm;

	if ((idFILE = fopen(idFile, "r")) == NULL)
		filerr("open", idFile);
	fread((char *) &idh, sizeof(struct idhead), 1, idFILE);

	entry0 = xmalloc(idh.idh_bsiz);

	bitsOff = xmalloc(BitArraySize);
	bzero(bitsOff, BitArraySize);
	for ( ; idArgs->ida_next; idArgs = idArgs->ida_next)
		if (idArgs->ida_flags & IDA_SCAN)
			BITSET(bitsOff, idArgs->ida_index);

	bitArray = xmalloc(BitArraySize);
	bzero(bitArray, BitArraySize);
	t2 = newTable = (struct idname **)xmalloc((idh.idh_namc + 1) * sizeof(struct idname *));
#ifdef UNIX
	fseek(idFILE, idh.idh_namo, 0);
#endif
#ifdef AMIGA	/* paranoia */
	if (fseek(idFILE, idh.idh_namo, 0) == -1)
		filerr("fseek",idFile);
#endif
	count = 0;
	for (i = 0; i < idh.idh_namc; i++) {
		size = 1 + fgets0(entry0, idh.idh_bsiz, idFILE);
		getsFF(&entry0[size], idFILE);
		vecToBits(bitArray, &entry0[size], idh.idh_vecc);
		bitsclr(bitArray, bitsOff, BitArraySize);
		if (!bitsany(bitArray, BitArraySize))
			continue;
		*t2 = newIdName(ID_STRING(entry0));
		bitsset((*t2)->idn_bitv, bitArray, BitArraySize);
		(*t2)->idn_flags = ID_FLAGS(entry0);
		bzero(bitArray, BitArraySize);
		t2++; count++;
	}
	*t2 = NULL;
#ifdef AMIGA	/* and probably others! */
	if (fclose(idFILE) == -1)
		filerr("close",idFile);
#endif

	t1 = HashTable;
	t2 = newTable;
	tm = mergeTable = (struct idname **)xcalloc(HashFill + count + 1, sizeof(struct idname *));
	while (*t1 && *t2) {
		cmp = strcmp((*t1)->idn_name, (*t2)->idn_name);
		if (cmp < 0)
			*tm++ = *t1++;
		else if (cmp > 0)
			*tm++ = *t2++;
		else {
			(*t1)->idn_flags |= (*t2)->idn_flags;
			(*t1)->idn_flags &= ~IDN_SOLO;
			bitsset((*t1)->idn_bitv, (*t2)->idn_bitv, BitArraySize);
			*tm++ = *t1;
			t1++, t2++;
		}
	}
	while (*t1)
		*tm++ = *t1++;
	while (*t2)
		*tm++ = *t2++;
	*tm = NULL;
	HashTable = mergeTable;
	HashFill = tm - mergeTable;
}

/*
	Cons up a list of idArgs as supplied in a file.
*/
void
fileIdArgs(FILE *argFILE, struct idarg **idArgsP)
{
/*	int		fileCount; not really used REJ */
	char		buf[BUFSIZ];
	char		*arg;
	int		len;	/* avoid macro trouble  -olsen */

/* 	fileCount = 0; see? REJ */
	while (fgets(buf, sizeof(buf), argFILE)) {
		len = strlen(buf);
		if (len <= 1)
			continue;	/* don't save null args REJ */
		(*idArgsP)->ida_arg = arg = strnsav(buf, len-1);
		if (*arg == '+' || *arg == '-') {
			(*idArgsP)->ida_flags = IDA_ARG;
			(*idArgsP)->ida_index = -1;
		} else {
			(*idArgsP)->ida_flags = IDA_SCAN|IDA_PATH;
			(*idArgsP)->ida_index = postIncr(&PathCount);
			ScanCount++;
		}
		(*idArgsP) = ((*idArgsP)->ida_next = NEW(struct idarg));
	}
}

void
initHashTable(int pathCount)
{
	if ((HashSize = round2((pathCount << 6) + 511)) > 0x8000)
		HashSize = 0x8000;
	HashMaxLoad = HashSize - (HashSize >> 4);	/* about 94% */
	HashTable = (struct idname **)xcalloc(HashSize, sizeof(struct idname *));
}

/*
	Double the size of the hash table in the
	event of overflow...
*/
void
rehash(void)
{
	long		oldHashSize = HashSize;
	struct idname	**oldHashTable = HashTable;
	register struct idname	**htp;
	register struct idname	**slot;

	HashSize *= 2;
	if (Verbose)
		fprintf(stderr, "Rehashing... (doubling size to %ld)\n", HashSize);
	HashMaxLoad = HashSize - (HashSize >> 4);
	HashTable = (struct idname **)xcalloc(HashSize, sizeof(struct idname *));

	HashFill = 0;
	for (htp = oldHashTable; htp < &oldHashTable[oldHashSize]; htp++) {
		if (*htp == NULL)
			continue;
		slot = (struct idname **)hashSearch((*htp)->idn_name, (char *)HashTable, HashSize, sizeof(struct idname *), h1str, h2str, (int (*)(char *,char *))idnHashCmp, &HashProbes);
		if (*slot) {
			fprintf(stderr, "%s: Duplicate hash entry!\n");
			exit(1);
		}
		*slot = *htp;
		HashSearches++;
		HashFill++;
	}
	free(oldHashTable);
}

/*
	Round a given number up to the nearest power of 2.
*/
int
round2(int rough)
{
	int		round;

	round = 1;
	while (rough) {
		round <<= 1;
		rough >>= 1;
	}
	return round;
}

/*
	`compar' function for hashSearch()
*/
int
idnHashCmp(char *key, struct idname **idn)
{
	int		collate;

	if (*idn == NULL)
		return 0;

	if ((collate = strcmp(key, (*idn)->idn_name)) == 0)
		(*idn)->idn_flags &= ~IDN_SOLO;	/* we found another occurance */

	return collate;
}

/*
	`compar' function for qsort().
*/
int
idnQsortCmp(struct idname **idn1, struct idname **idn2)
{
	if (*idn1 == *idn2)
		return 0;
	if (*idn1 == NULL)
		return 1;
	if (*idn2 == NULL)
		return -1;

	return strcmp((*idn1)->idn_name, (*idn2)->idn_name);
}

/*
	Allocate a new idname struct and fill in the name field.
	We allocate memory in large chunks to avoid frequent
	calls to malloc() which is a major pig.
*/
struct idname *
newIdName(char *name)
{
	register struct idname	*idn;
	register char	*allocp;
	register int	allocsiz;
	static char	*allocBuf = NULL;
	static char	*allocEnd = NULL;
#define	ALLOCSIZ	(8*1024)

	allocsiz = sizeof(struct idname) + strlen(name) + 1 + BitArraySize;
	allocsiz += (sizeof(long) - 1);
	allocsiz &= ~(sizeof(long) - 1);

	allocp = allocBuf;
	allocBuf += allocsiz;
	if (allocBuf > allocEnd) {
		allocBuf = xmalloc(ALLOCSIZ);
		allocEnd = &allocBuf[ALLOCSIZ];
		allocp = allocBuf;
		allocBuf += allocsiz;
	}

	idn = (struct idname *)allocp;
	allocp += sizeof(struct idname);
	idn->idn_bitv = allocp;
	for (allocsiz = BitArraySize; allocsiz--; allocp++)
		*allocp = '\0';
	idn->idn_name = strcpy(allocp, name);

	return idn;
}

int
postIncr(int *ip)
{
	register int	i;
	int		save;

	save = *ip;
	i = save + 1;
	if ((i & 0x00ff) == 0x00ff)
		i++;
	if ((i & 0xff00) == 0xff00)	/* This isn't bloody likely */
		i += 0x100;
	*ip = i;

	return save;
}

/*
	Move all non-NULL table entries to the front of the table.
	return the number of non-NULL elements in the table.
*/
int
hashCompress(char **table, int size)
{
	register char	**front;
	register char	**back;

	front = &table[-1];
	back = &table[size];

	for (;;) {
		while (*--back == NULL)
			;
		if (back < front)
			break;
		while (*++front != NULL)
			;
		if (back < front)
			break;
		*front = *back;
	}

	return (back - table + 1);
}
