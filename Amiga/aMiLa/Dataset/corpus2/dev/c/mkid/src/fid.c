static char copyright[] = "@(#)Copyright (c) 1986, Greg McGary";
static char sccsid[] = "@(#)fid.c	1.2 86/10/17";

#include	"bool.h"
#include	<stdio.h>
#include	<stdlib.h>
#include	"string.h"
#include	<ctype.h>
#include	"radix.h"
#include	"id.h"
#include	"bitops.h"
#include	"extern.h"

void fileId(int argc,char **argv);

FILE		*IdFILE;
struct idhead	Idh;
struct idarg	*IdArgs;

#ifdef AMIGA
char *verstag = "\0$VER: fid " TOOL_VERSION " " __AMIGADATE__ "\r\n";
#endif

char *MyName;
static void
usage(void)
{
	fprintf(stderr, "Usage: %s [-f<file>] file1 file2\n", MyName);
	exit(1);
}

int
main(int argc,char **argv)
{
	char		*idFile = IDFILE;
	char		*arg;
/*	float		occurPercent = 0.0;*/
/*	int		occurNumber = 0;*/
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
		default: usage();
		}
	nextarg:;
	}
argsdone:

	idFile = spanPath(getDirToName(idFile), idFile);
	if ((IdFILE = initID(idFile, &Idh, &IdArgs)) == NULL) {
		filerr("open", idFile);
		exit(1);
	}

	if (argc < 1 || argc > 2)
		usage();

	fileId(argc, argv);
	exit(0);
}

void
fileId(int argc,char **argv)
{
	char		*buf;
	int		want, got;
	int		bitoff[2];
	int		i, j;
	int		argLength;
	int		pathLength;
	int		lengthDiff;
	char		*pathVec;
	register struct idarg	*idArgs;

	want = 0;
	for (j = 0; j < argc; j++, argv++) {
		want |= (1<<j);
		argLength = strlen(*argv);
		bitoff[j] = -1;
		for (idArgs = IdArgs, i = 0; i < Idh.idh_pthc; i++, idArgs++) {
			pathLength = strlen(idArgs->ida_arg);
			if (argLength > pathLength)
				continue;
			lengthDiff = pathLength - argLength;
			if (strequ(&idArgs->ida_arg[lengthDiff], *argv)) {
				bitoff[j] = i;
				break;
			}
		}
		if (bitoff[j] < 0) {
			fprintf(stderr, "%s: not found\n", *argv);
			exit(1);
		}
	}

	buf = xmalloc((int)Idh.idh_bsiz);
	fseek(IdFILE, Idh.idh_namo, 0);

	for (i = 0; i < Idh.idh_namc; i++) {
		pathVec = 1 + buf + fgets0(buf, Idh.idh_bsiz, IdFILE);
		getsFF(pathVec, IdFILE);
		got = 0;
		while ((*pathVec & 0xff) != 0xff) {
			j = strToInt(pathVec, Idh.idh_vecc);
			if ((want & (1<<0)) && j == bitoff[0])
				got |= (1<<0);
			if ((want & (1<<1)) && j == bitoff[1])
				got |= (1<<1);
			if (got == want) {
				printf("%s\n", ID_STRING(buf));
				break;
			}
			pathVec += Idh.idh_vecc;
		}
	}
}
